//
// File: CBserverLoadBalancer.rs 
//
// Author: Manfred Jeusfeld (with help from LLM)
// Date: 2026-05-06 (2026-05-31)
// --------------------------------------------------------------
// License: Creative Commons CC-BY 4.0
//
// THIS SOFTWARE IS PROVIDED BY THE CONCEPTBASE TEAM ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
// INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
// PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONCEPTBASE TEAM OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
// OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//

//
// This is a Reverse Proxy Load Balancer for the ConceptBase server. It pretends to ConceptBase
// clients to be a ConceptBase server. But in fact it forwards their requests to a pool of ConceptBase servers
// on localhost. When I client gracefully exits, the corresponding slot becomes free again, assuming that the
// ConceptBase server restarts itself on the same port.
//
// To compile: rustc -O  CBserverLoadBalancer.rs -o CBserverLoadBalancer
// To start: export CB_SHUTDOWN_KEY="your_secure_key"
//           ./CBserverLoadBalancer <balancerPort> <poolStart> <poolEnd>
// To shutdown: echo "SHUTDOWN_BALANCER <your_secure_key>" | nc localhost <balancerPort>
//
// With user port mapping: ./CBserverLoadBalancer <balancerPort> <poolStart> <poolEnd> -c <filename>
// Example: ./CBserverLoadBalancer 4001 5001 5002 -c up1.txt
//    
// This Rust program was translated from CBserverLoadBalancer.java
//
// 
// 2026-05-30
// -----------------------------------------------------------------------------
// SUMMARY OF SECURITY & STABILITY HARDENING
// -----------------------------------------------------------------------------
// SECURITY / VULNERABILITY FIXES:
// 1. OOM Prevention: Added a `MAX_BODY_SIZE` safety cap (10MB) on incoming payloads 
//    to prevent malicious or malformed packets from triggering memory panics.
// 2. Command Injection Fix: Tightened shutdown command validation from a loose 
//    `.contains()` lookup to a strict, exact string match (`.trim() == ...`).
// 3. Credential Masking: Extracted the shutdown key from positional command-line 
//    arguments into a `CB_SHUTDOWN_KEY` environment variable, completely hiding 
//    the secret from system process listings (`ps aux`).
//
// STABILITY / CONCURRENCY IMPROVEMENTS:
// 1. Two-Phase Timeouts: Implemented an initial 15-second socket timeout to drop 
//    unresponsive/malicious connections, which is automatically cleared (`None`) 
//    before the proxy phase to natively support long-lived, idle client sessions.
// 2. HashSet Optimization: Converted `free_servers` from a `Vec` to a `HashSet` 
//    to achieve predictable, thread-safe O(1) membership operations inside the lock.
// 3. Poison Error Handling: Swapped naked `.unwrap()` lock invocations for a robust
//    `acquire_state_lock` helper to gracefully catch and recover from a `PoisonError` 
//    if an isolated worker thread crashes.
// 4. State Invariant Guards: Enforced strict `pool_start` and `pool_end` range checks 
//    and explicit user-remapping exceptions in `load_mapping` to keep stale or 
//    corrupted state logs from causing resource exhaustion or unexpected denials.
// -----------------------------------------------------------------------------


use std::collections::{HashMap, HashSet};
use std::env;
use std::fs::File;
use std::io::{self, BufRead, BufReader, Read, Write};
use std::net::{TcpListener, TcpStream};
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::{SystemTime, UNIX_EPOCH, Duration};

const MAX_BODY_SIZE: usize = 10 * 1024 * 1024; // 10 MB safety cap

struct BalancerState {
    free_servers: HashSet<i32>, // Optimized to HashSet for O(1) membership operations
    user_to_port: HashMap<String, i32>,
    port_ref_count: HashMap<i32, i32>,
    config_file: Option<String>,
    is_fixed: bool,
    pool_start: i32,
    pool_end: i32,
}

// Helper function to format precise UTC timestamps: YYYY-MM-DD,HH:MM:SS.mmm
fn get_utc_timestamp() -> String {
    let now = SystemTime::now();
    let duration = now.duration_since(UNIX_EPOCH).unwrap_or_default();
    let total_secs = duration.as_secs();
    let millis = duration.subsec_millis();

    let seconds_in_day = 86400;
    let mut days = (total_secs / seconds_in_day) as i32;
    let mut remaining_secs = (total_secs % seconds_in_day) as i32;

    let hour = remaining_secs / 3600;
    remaining_secs %= 3600;
    let minute = remaining_secs / 60;
    let second = remaining_secs % 60;

    let mut year = 1970;
    loop {
        let is_leap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
        let days_in_year = if is_leap { 366 } else { 365 };
        if days >= days_in_year {
            days -= days_in_year;
            year += 1;
        } else {
            break;
        }
    }

    let is_leap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    let mut month_days = vec![31, if is_leap { 29 } else { 28 }, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    
    let mut month = 1;
    for days_in_month in month_days.drain(..) {
        if days >= days_in_month {
            days -= days_in_month;
            month += 1;
        } else {
            break;
        }
    }
    let day = days + 1;

    format!(
        "{:04}-{:02}-{:02},{:02}:{:02}:{:02}.{:03}",
        year, month, day, hour, minute, second, millis
    )
}

// Defensive helper to recover state access safely if a worker thread panics (PoisonError handling)
fn acquire_state_lock(state: &Arc<Mutex<BalancerState>>) -> std::sync::MutexGuard<'_, BalancerState> {
    match state.lock() {
        Ok(guard) => guard,
        Err(poisoned) => {
            eprintln!("{} CRITICAL Mutex poisoned by a panicked thread. Recovering lock state guard.", get_utc_timestamp());
            poisoned.into_inner()
        }
    }
}

fn main() -> io::Result<()> {
    let args: Vec<String> = env::args().collect();
    if args.len() < 4 {
        eprintln!("Usage: {} <balancerPort> <poolStart> <poolEnd> [-c file] [-fix]", args[0]);
        eprintln!("Note: Require CB_SHUTDOWN_KEY environment variable to be configured.");
        return Ok(());
    }

    // Fixed P1: Load secret from environment variable to mask it from process listings (ps aux)
    let shutdown_key = env::var("CB_SHUTDOWN_KEY").unwrap_or_else(|_| {
        eprintln!("FATAL: The 'CB_SHUTDOWN_KEY' environment variable is required for secure operation.");
        std::process::exit(1);
    });

    let balancer_port = args[1].parse::<u16>().unwrap_or(4001);
    let pool_start = args[2].parse::<i32>().unwrap_or(5001);
    let pool_end = args[3].parse::<i32>().unwrap_or(5002);
    
    let mut config_file = None;
    let mut is_fixed = false;

    let mut i = 4;
    while i < args.len() {
        if args[i] == "-c" && i + 1 < args.len() {
            config_file = Some(args[i+1].clone());
            i += 2;
        } else if args[i] == "-fix" {
            is_fixed = true;
            i += 1;
        } else { i += 1; }
    }

    // Cleaned up STARTED message
    eprintln!(
        "{} STARTED Rust Balancer on port {} (Pool: {}-{}, config file: {}, Fixed: {})",
        get_utc_timestamp(),
        balancer_port, 
        pool_start, 
        pool_end, 
        config_file.as_deref().unwrap_or("none"), 
        is_fixed
    );

    let state = Arc::new(Mutex::new(BalancerState {
        free_servers: (pool_start..=pool_end).collect(),
        user_to_port: HashMap::new(),
        port_ref_count: HashMap::new(),
        config_file,
        is_fixed,
        pool_start,
        pool_end,
    }));

    load_mapping(Arc::clone(&state));

    let listener = TcpListener::bind(format!("0.0.0.0:{}", balancer_port))?;

    for stream in listener.incoming() {
        if let Ok(s) = stream {
            let state_ref = Arc::clone(&state);
            let key_ref = shutdown_key.clone();
            thread::spawn(move || handle_client(s, state_ref, key_ref));
        }
    }
    Ok(())
}

fn handle_client(mut client_stream: TcpStream, state: Arc<Mutex<BalancerState>>, shutdown_key: String) {
    // PHASE 1: Protect against hung or dead connections during the initial handshake.
    // If a client connects but sends nothing within 15 seconds, terminate the thread.
    let _ = client_stream.set_read_timeout(Some(Duration::from_secs(15)));

    let mut header = [0u8; 5];
    if client_stream.read_exact(&mut header).is_err() { return; }
    if header[0] != b'X' { return; }

    let body_len = u32::from_be_bytes([header[1], header[2], header[3], header[4]]) as usize;
    if body_len > MAX_BODY_SIZE {
        eprintln!("{} REJECTED Body too large: {} bytes", get_utc_timestamp(), body_len);
        return;
    }

    let mut body = vec![0u8; body_len];
    if client_stream.read_exact(&mut body).is_err() { return; }

    // PHASE 2: Handshake complete. Clear the timeouts to allow long-lived, 
    // persistent sessions to safely sit idle without getting dropped.
    let _ = client_stream.set_read_timeout(None);

    let full_msg_text = String::from_utf8_lossy(&body);

    if full_msg_text.trim() == format!("SHUTDOWN_BALANCER {}", shutdown_key) {
        eprintln!("{} SHUTDOWN Shutdown command received.", get_utc_timestamp());
        let s = acquire_state_lock(&state);
        save_mapping_locked(&s); 
        std::process::exit(0);
    }

    let user = extract_username_from_body(&body);
    let port_opt = get_port_for_user(&user, Arc::clone(&state));

    if let Some((port, active_count)) = port_opt {
        eprintln!("{} TRACE Assignment: User '{}' -> Port {} ({} clients)", get_utc_timestamp(), user, port, active_count);
        
        if let Ok(mut server_stream) = TcpStream::connect(format!("127.0.0.1:{}", port)) {
            // Short write timeout just for the initial forward
            let _ = server_stream.set_write_timeout(Some(Duration::from_secs(15)));
            let _ = server_stream.write_all(&header);
            let _ = server_stream.write_all(&body);
            
            // Clear backend server stream timeouts before proxying data
            let _ = server_stream.set_write_timeout(None);
            let _ = server_stream.set_read_timeout(None);

            if let (Ok(mut s2c), Ok(mut c2s)) = (server_stream.try_clone(), client_stream.try_clone()) {
                let t1 = thread::spawn(move || { let _ = io::copy(&mut s2c, &mut client_stream); });
                let _ = io::copy(&mut c2s, &mut server_stream);
                let _ = t1.join();
            }
        }

        // Atomically read remaining reference metrics inside exclusive lock context before generating tracing drop telemetry
        let remaining_count = {
            let mut s = acquire_state_lock(&state);
            let count = s.port_ref_count.entry(port).or_insert(0);
            if *count > 0 { *count -= 1; }
            if *count <= 0 { *count = 0; }
            let final_count = *count; // Copying the primitive i32 value ends the borrow on s.port_ref_count
            
            if final_count <= 0 {
                if !s.is_fixed || user.is_empty() {
                    s.free_servers.insert(port); 
                }
            }
            final_count
        };

        eprintln!("{} TRACE Disconnect: User '{}' closed connection on Port {} ({} clients)", get_utc_timestamp(), user, port, remaining_count);
    }
}

fn extract_username_from_body(body: &[u8]) -> String {
    let msg = String::from_utf8_lossy(body);
    // Boundary-checked username string slice handling
    let mut parts = msg.split('"');
    let extracted = parts.nth(7).unwrap_or("");
    extracted.replace(|c| " ,()[]".contains(c), "")
}

// Adjusted to return Option<(Port, ActiveClientCount)> cleanly and thread-safely
fn get_port_for_user(user: &str, state: Arc<Mutex<BalancerState>>) -> Option<(i32, i32)> {
    let mut s = acquire_state_lock(&state);
    
    if !user.is_empty() {
        if let Some(&port) = s.user_to_port.get(user) {
            s.free_servers.remove(&port);
            let count = s.port_ref_count.entry(port).or_insert(0);
            *count += 1;
            let current_count = *count;
            return Some((port, current_count));
        }
    }

    // Safe lookup extraction from O(1) HashSet
    if let Some(&port) = s.free_servers.iter().next() {
        s.free_servers.remove(&port);
        if !user.is_empty() {
            s.user_to_port.insert(user.to_string(), port);
            save_mapping_locked(&s);
        }
        s.port_ref_count.insert(port, 1);
        return Some((port, 1));
    }

    if !s.is_fixed && !s.port_ref_count.is_empty() {
        if let Some((&port, &min_load)) = s.port_ref_count.iter().min_by_key(|&(_, count)| count) {
            eprintln!("{} OVERFLOW Sharing Port {} (Current load: {})", get_utc_timestamp(), port, min_load);
            
            let mut current_count = min_load;
            if let Some(count) = s.port_ref_count.get_mut(&port) {
                *count += 1;
                current_count = *count;
            }
            
            if !user.is_empty() {
                s.user_to_port.insert(user.to_string(), port);
                save_mapping_locked(&s);
            }
            return Some((port, current_count));
        }
    }

    eprintln!("{} DENIED Pool exhausted. No port for '{}' (Fixed: {})", get_utc_timestamp(), user, s.is_fixed);
    None
}

fn save_mapping_locked(s: &BalancerState) {
    if let Some(ref path) = s.config_file {
        if let Ok(mut f) = File::create(path) {
            for (u, p) in &s.user_to_port { 
                let _ = writeln!(f, "{}:{}", u, p); 
            }
        }
    }
}

fn load_mapping(state: Arc<Mutex<BalancerState>>) {
    let mut s = acquire_state_lock(&state);
    if let Some(path) = s.config_file.clone() {
        if let Ok(file) = File::open(&path) {
            for line in BufReader::new(file).lines().flatten() {
                let parts: Vec<&str> = line.split(':').collect();
                if parts.len() == 2 {
                    if let Ok(port) = parts[1].parse::<i32>() {
                        if port >= s.pool_start && port <= s.pool_end {
                            // Checked user-remapping exception to fix edge case denial bugs
                            if s.is_fixed {
                                if let Some(&existing_port) = s.user_to_port.get(parts[0]) {
                                    if existing_port == port {
                                        s.free_servers.remove(&port);
                                        continue;
                                    }
                                }
                                if s.user_to_port.values().any(|&p| p == port) {
                                    eprintln!("{} LOAD Warning: Skipping multi-tenant configuration record for {} in Fixed Mode.", get_utc_timestamp(), parts[0]);
                                    continue;
                                }
                            }
                            eprintln!("{} LOAD Mapping: {} -> {}", get_utc_timestamp(), parts[0], port);
                            s.user_to_port.insert(parts[0].to_string(), port);
                            s.free_servers.remove(&port);
                        }
                    }
                }
            }
        }
    }
}
