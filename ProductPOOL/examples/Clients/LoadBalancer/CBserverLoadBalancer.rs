//
// File: CBserverLoadBalancer.rs 
//
// Author: Manfred Jeusfeld (with help from LLM)
// Date: 2026-05-06 (2026-05-15)
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
// To start: ./CBserverLoadBalancer <shutdownKey> <balancerPort> <poolStart> <poolEnd>
// To shutdown: echo "SHUTDOWN_BALANCER <shutdownKey>" | nc localhost <balancerPort>
//
// With user port mapping: ./CBserverLoadBalancer <shutdownKey> <balancerPort> <poolStart> <poolEnd> -c <filename>
// Example: ./CBserverLoadBalancer stop319 4001 5001 5002 -c up1.txt
//    
// This Rust program was translated from CBserverLoadBalancer.java
//


use std::collections::HashMap;
use std::env;
use std::fs::File;
use std::io::{self, BufRead, BufReader, Read, Write};
use std::net::{TcpListener, TcpStream};
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::{SystemTime, UNIX_EPOCH};

struct BalancerState {
    free_servers: Vec<i32>,
    user_to_port: HashMap<String, i32>,
    port_ref_count: HashMap<i32, i32>,
    config_file: Option<String>,
    is_fixed: bool,
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

fn main() -> io::Result<()> {
    let args: Vec<String> = env::args().collect();
    if args.len() < 5 {
        eprintln!("Usage: {} <shutdownKey> <balancerPort> <poolStart> <poolEnd> [-c file] [-fix]", args[0]);
        return Ok(());
    }

    let shutdown_key = args[1].clone();
    let balancer_port = args[2].parse::<u16>().unwrap_or(4001);
    let pool_start = args[3].parse::<i32>().unwrap_or(5001);
    let pool_end = args[4].parse::<i32>().unwrap_or(5002);
    
    let mut config_file = None;
    let mut is_fixed = false;

    let mut i = 5;
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
        "{} STARTED Rust Balancer on port {} (Key: {}, Pool: {}-{}, config file: {}, Fixed: {})",
        get_utc_timestamp(),
        balancer_port, 
        shutdown_key, 
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
    let mut header = [0u8; 5];
    if client_stream.read_exact(&mut header).is_err() { return; }
    if header[0] != b'X' { return; }

    let body_len = u32::from_be_bytes([header[1], header[2], header[3], header[4]]) as usize;
    let mut body = vec![0u8; body_len];
    if client_stream.read_exact(&mut body).is_err() { return; }

    let full_msg_text = String::from_utf8_lossy(&body);

    if full_msg_text.contains(&format!("SHUTDOWN_BALANCER {}", shutdown_key)) {
        eprintln!("{} SHUTDOWN Shutdown command received.", get_utc_timestamp());
        let s = state.lock().unwrap();
        save_mapping_locked(&s); 
        std::process::exit(0);
    }

    let user = extract_username_from_body(&body);
    let port_opt = get_port_for_user(&user, Arc::clone(&state));

    if let Some(port) = port_opt {
        eprintln!("{} TRACE Assignment: User '{}' -> Port {}", get_utc_timestamp(), user, port);
        
        if let Ok(mut server_stream) = TcpStream::connect(format!("127.0.0.1:{}", port)) {
            let _ = server_stream.write_all(&header);
            let _ = server_stream.write_all(&body);
            
            let mut s2c = server_stream.try_clone().unwrap();
            let mut c2s = client_stream.try_clone().unwrap();
            
            let t1 = thread::spawn(move || { let _ = io::copy(&mut s2c, &mut client_stream); });
            let _ = io::copy(&mut c2s, &mut server_stream);
            let _ = t1.join();
        }

        // Trace message when the session ends or connection drops
        eprintln!("{} TRACE Disconnect: User '{}' closed connection on Port {}", get_utc_timestamp(), user, port);

        let mut s = state.lock().unwrap();
        let count = s.port_ref_count.entry(port).or_insert(0);
        if *count > 0 { *count -= 1; }
        if *count <= 0 {
            *count = 0;
            if !s.is_fixed || user.is_empty() {
                if !s.free_servers.contains(&port) { 
                    s.free_servers.push(port); 
                }
            }
        }
    }
}

fn extract_username_from_body(body: &[u8]) -> String {
    let msg = String::from_utf8_lossy(body);
    msg.split('"').nth(7).unwrap_or("").replace(|c| " ,()[]".contains(c), "")
}

fn get_port_for_user(user: &str, state: Arc<Mutex<BalancerState>>) -> Option<i32> {
    let mut s = state.lock().unwrap();
    
    if !user.is_empty() {
        if let Some(&port) = s.user_to_port.get(user) {
            s.free_servers.retain(|&x| x != port);
            let count = s.port_ref_count.entry(port).or_insert(0);
            *count += 1;
            return Some(port);
        }
    }

    if !s.free_servers.is_empty() {
        let port = s.free_servers.remove(0);
        if !user.is_empty() {
            s.user_to_port.insert(user.to_string(), port);
            save_mapping_locked(&s);
        }
        s.port_ref_count.insert(port, 1);
        return Some(port);
    }

    if !s.is_fixed && !s.port_ref_count.is_empty() {
        if let Some((&port, &min_load)) = s.port_ref_count.iter().min_by_key(|&(_, count)| count) {
            eprintln!("{} OVERFLOW Sharing Port {} (Current load: {})", get_utc_timestamp(), port, min_load);
            let count = s.port_ref_count.get_mut(&port).unwrap();
            *count += 1;
            
            if !user.is_empty() {
                s.user_to_port.insert(user.to_string(), port);
                save_mapping_locked(&s);
            }
            return Some(port);
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
    let mut s = state.lock().unwrap();
    if let Some(path) = s.config_file.clone() {
        if let Ok(file) = File::open(&path) {
            for line in BufReader::new(file).lines().flatten() {
                let parts: Vec<&str> = line.split(':').collect();
                if parts.len() == 2 {
                    if let Ok(port) = parts[1].parse::<i32>() {
                        eprintln!("{} LOAD Mapping: {} -> {}", get_utc_timestamp(), parts[0], port);
                        s.user_to_port.insert(parts[0].to_string(), port);
                        s.free_servers.retain(|&x| x != port);
                    }
                }
            }
        }
    }
}
