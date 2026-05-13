use std::collections::HashMap;
use std::env;
use std::fs::File;
use std::io::{self, BufRead, BufReader, Read, Write};
use std::net::{TcpListener, TcpStream};
use std::sync::{Arc, Mutex};
use std::thread;

struct BalancerState {
    free_servers: Vec<i32>,
    user_to_port: HashMap<String, i32>,
    port_ref_count: HashMap<i32, i32>,
    config_file: Option<String>,
    is_fixed: bool,
}

fn main() -> io::Result<()> {
    let args: Vec<String> = env::args().collect();
    if args.len() < 5 {
        eprintln!("Usage: {} <key> <port> <start> <end> [-c file] [-fix]", args[0]);
        return Ok(());
    }

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

    let state = Arc::new(Mutex::new(BalancerState {
        free_servers: (pool_start..=pool_end).collect(),
        user_to_port: HashMap::new(),
        port_ref_count: HashMap::new(),
        config_file,
        is_fixed,
    }));

    load_mapping(Arc::clone(&state));

    let listener = TcpListener::bind(format!("0.0.0.0:{}", balancer_port))?;
    eprintln!("[STARTED] Rust Balancer on port {}", balancer_port);

    for stream in listener.incoming() {
        if let Ok(s) = stream {
            let state_ref = Arc::clone(&state);
            thread::spawn(move || handle_client(s, state_ref));
        }
    }
    Ok(())
}

fn handle_client(mut client_stream: TcpStream, state: Arc<Mutex<BalancerState>>) {
    // 1. Read the 5-byte header: 'X' + 4-byte length
    let mut header = [0u8; 5];
    if client_stream.read_exact(&mut header).is_err() { return; }

    if header[0] != b'X' {
        eprintln!("[ERROR] Invalid protocol: Expected 'X', got '{}'", header[0] as char);
        return;
    }

    // 2. Parse big-endian length from bytes 1-4
    let body_len = u32::from_be_bytes([header[1], header[2], header[3], header[4]]) as usize;
    
    // 3. Read the exact number of bytes specified by the header
    let mut body = vec![0u8; body_len];
    if client_stream.read_exact(&mut body).is_err() { return; }

    // DEBUG: Show exact message structure
    let full_msg_text = String::from_utf8_lossy(&body);
    eprintln!("[DEBUG] Header Length: {} bytes", body_len);
    eprintln!("[DEBUG] Body: {}", full_msg_text);

    // 4. Extract username from the verified body
    let user = extract_username_from_body(&body);
    let port_opt = get_port_for_user(&user, Arc::clone(&state));

    if let Some(port) = port_opt {
        eprintln!("[TRACE] Assignment: User '{}' -> Port {}", user, port);
        
        if let Ok(mut server_stream) = TcpStream::connect(format!("127.0.0.1:{}", port)) {
            // Forward header and body
            let _ = server_stream.write_all(&header);
            let _ = server_stream.write_all(&body);
            
            let mut s2c = server_stream.try_clone().unwrap();
            let mut c2s = client_stream.try_clone().unwrap();
            
            let t1 = thread::spawn(move || { let _ = io::copy(&mut s2c, &mut client_stream); });
            let _ = io::copy(&mut c2s, &mut server_stream);
            let _ = t1.join();
        }

        let mut s = state.lock().unwrap();
        let count = s.port_ref_count.entry(port).or_insert(0);
        if *count > 0 { *count -= 1; }
        if *count <= 0 {
            *count = 0;
            if !s.is_fixed || user.is_empty() {
                if !s.free_servers.contains(&port) { s.free_servers.push(port); }
            }
        }
    }
}

fn extract_username_from_body(body: &[u8]) -> String {
    let pattern = b"ENROLL_ME";
    let enroll_pos = match body.windows(pattern.len()).position(|w| w == pattern) {
        Some(idx) => idx,
        None => return "".to_string(),
    };

    let tail = &body[enroll_pos..];
    let array_start = match tail.iter().position(|&b| b == b'[') {
        Some(idx) => idx,
        None => return "".to_string(),
    };

    let mut string_list = Vec::new();
    let mut current_str = Vec::new();
    let mut in_quotes = false;

    for &b in &tail[array_start + 1..] {
        match b {
            b'"' => {
                if in_quotes {
                    string_list.push(String::from_utf8_lossy(&current_str).into_owned());
                    current_str.clear();
                    in_quotes = false;
                    // We want the 2nd string in the array
                    if string_list.len() == 2 {
                        return string_list[1].chars()
                            .filter(|&c| ! " ,()".contains(c))
                            .collect();
                    }
                } else { in_quotes = true; }
            }
            b']' if !in_quotes => break,
            _ if in_quotes => current_str.push(b),
            _ => {}
        }
    }
    "".to_string()
}

fn get_port_for_user(user: &str, state: Arc<Mutex<BalancerState>>) -> Option<i32> {
    let mut s = state.lock().unwrap();
    if !user.is_empty() {
        if let Some(&port) = s.user_to_port.get(user) {
            let is_idle = s.port_ref_count.get(&port).map_or(true, |&c| c == 0);
            if is_idle { s.free_servers.retain(|&x| x != port); }
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
    None
}

fn save_mapping_locked(s: &BalancerState) {
    if let Some(ref path) = s.config_file {
        if let Ok(mut f) = File::create(path) {
            for (u, p) in &s.user_to_port { let _ = writeln!(f, "{}:{}", u, p); }
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
                        s.user_to_port.insert(parts[0].to_string(), port);
                        s.free_servers.retain(|&x| x != port);
                    }
                }
            }
        }
    }
}
