import java.io.*;
import java.net.*;
import java.util.*;
import java.util.concurrent.*;

/**
 * A protocol-aware load balancer for ConceptBase.
 * It listens on a public port and routes clients to a pool of backend CBservers.
 */
public class ConceptBaseLoadBalancer {
    // Default configuration values
    private static int balancerPort = 4001;
    private static int poolStart = 4002;
    private static int poolEnd = 4010;

    // A thread-safe queue to manage available server ports
    private static final BlockingQueue<Integer> FREE_SERVERS = new LinkedBlockingQueue<>();

    public static void main(String[] args) {
        // Parse command line arguments for dynamic port configuration
        try {
            if (args.length >= 1) balancerPort = Integer.parseInt(args[0]);
            if (args.length >= 2) poolStart = Integer.parseInt(args[1]);
            if (args.length >= 3) poolEnd = Integer.parseInt(args[2]);
        } catch (NumberFormatException e) {
            System.err.println("Invalid port numbers. Falling back to defaults.");
        }

        // Populate the pool with the designated range of backend ports[cite: 3]
        for (int i = poolStart; i <= poolEnd; i++) {
            FREE_SERVERS.add(i);
        }

        try (ServerSocket serverSocket = new ServerSocket(balancerPort)) {
            System.out.println("Balancer running on: " + balancerPort);
            System.out.println("Managing servers: " + poolStart + "-" + poolEnd);

            while (true) {
                // Every connection gets a unique socket, allowing us to distinguish clients[cite: 3]
                Socket clientSocket = serverSocket.accept();
                String clientID = clientSocket.getRemoteSocketAddress().toString();
                
                // Hand off the connection to a new thread to keep the balancer responsive
                new Thread(new SessionHandler(clientSocket, clientID)).start();
            }
        } catch (IOException e) {
            System.err.println("Critical Balancer Failure: " + e.getMessage());
        }
    }

    static class SessionHandler implements Runnable {
        private final Socket clientSocket;
        private final String clientID;
        private Integer assignedPort = null;

        public SessionHandler(Socket socket, String id) {
            this.clientSocket = socket;
            this.clientID = id;
        }

        @Override
        public void run() {
            try {
                InputStream in = clientSocket.getInputStream();
                // PushbackInputStream allows us to "peek" at the ENROLL_ME command[cite: 2]
                // and then return it to the stream so the backend server can read it too.
                PushbackInputStream pushbackIn = new PushbackInputStream(in, 4096);
                
                byte[] buffer = new byte[1024];
                int bytesRead = pushbackIn.read(buffer);
                
                if (bytesRead != -1) {
                    String initialData = new String(buffer, 0, bytesRead);
                    
                    // Protocol Check: The first command must be ENROLL_ME[cite: 2]
                    if (initialData.contains("ENROLL_ME")) {
                        assignedPort = FREE_SERVERS.poll(); // Request a port from the pool
                        
                        if (assignedPort == null) {
                            sendError(clientSocket, "No free ConceptBase servers available.");
                            return;
                        }

                        System.out.println("[SESSION START] Client " + clientID + " assigned to port " + assignedPort);
                        
                        // Return the initial data to the stream for the backend to process
                        pushbackIn.unread(buffer, 0, bytesRead);
                        proxyToBackend(pushbackIn, assignedPort);
                    } else {
                        sendError(clientSocket, "Invalid Protocol: Expected ENROLL_ME.");
                    }
                }
            } catch (IOException e) {
                System.err.println("Session error for " + clientID + ": " + e.getMessage());
            } finally {
                cleanup(); // Ensure port is returned to pool even on error[cite: 3]
            }
        }

        private void proxyToBackend(InputStream clientIn, int port) {
            try (Socket backendSocket = new Socket("localhost", port)) {
                // Establish bi-directional piping (Forwarding)
                // Thread t1: Client -> Balancer -> Backend
                // Thread t2: Backend -> Balancer -> Client
                Thread t1 = new Thread(() -> bridge(clientIn, clientSocket, backendSocket, true));
                Thread t2 = new Thread(() -> bridge(backendSocket.getInputStream(), backendSocket, clientSocket, false));

                t1.start();
                t2.start();

                // Wait for both directions of the socket to close[cite: 3]
                t1.join();
                t2.join();
            } catch (Exception e) {
                System.err.println("Backend connection failed on port " + port);
            }
        }

        private void bridge(InputStream in, Socket src, Socket dest, boolean isClientSource) {
            try (OutputStream out = dest.getOutputStream()) {
                byte[] buffer = new byte[8192];
                int read;
                while ((read = in.read(buffer)) != -1) {
                    if (isClientSource) {
                        // Monitor for CANCEL_ME to log the session teardown[cite: 2]
                        String chunk = new String(buffer, 0, read);
                        if (chunk.contains("CANCEL_ME")) {
                            System.out.println("[DISCONNECT] Client " + clientID + " requested CANCEL_ME.");
                        }
                    }
                    out.write(buffer, 0, read);
                    out.flush();
                }
            } catch (IOException ignored) { 
                // Socket closure or reset is expected during session termination
            }
        }

        private void cleanup() {
            if (assignedPort != null) {
                FREE_SERVERS.offer(assignedPort); // Make the port available for the next client[cite: 3]
                System.out.println("[SESSION END] Port " + assignedPort + " returned to pool.");
                assignedPort = null;
            }
            try { clientSocket.close(); } catch (IOException ignored) { }
        }

        private void sendError(Socket s, String msg) throws IOException {
            PrintWriter out = new PrintWriter(s.getOutputStream(), true);
            out.println("ERROR: " + msg);
            s.close();
        }
    }
}
