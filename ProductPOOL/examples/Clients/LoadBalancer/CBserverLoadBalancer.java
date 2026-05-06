/*
 To start: java CBserverLoadBalancer <shutdownKey> <balancerPort> <poolStart> <poolEnd>
 To shutdown: echo "SHUTDOWN_BALANCER <shutdownKey>" | nc localhost <balancerPort>
*/

import java.io.*;
import java.net.*;
import java.util.*;
import java.util.concurrent.*;

public class CBserverLoadBalancer {
    // Configuration Defaults
    private static String shutdownKey = "admin_secret"; 
    private static int balancerPort = 4001;
    private static int poolStart = 4002;
    private static int poolEnd = 4010;
    
    private static volatile boolean isRunning = true;
    private static ServerSocket serverSocket;
    private static final BlockingQueue<Integer> FREE_SERVERS = new LinkedBlockingQueue<>();
    private static final ExecutorService sessionPool = Executors.newCachedThreadPool();

    public static void main(String[] args) {
        // 1. Parse Arguments: <key> <port> <start> <end>
        try {
            if (args.length >= 1) shutdownKey = args[0];
            if (args.length >= 2) balancerPort = Integer.parseInt(args[1]);
            if (args.length >= 3) poolStart = Integer.parseInt(args[2]);
            if (args.length >= 4) poolEnd = Integer.parseInt(args[3]);
        } catch (NumberFormatException e) {
            System.err.println("Invalid numeric arguments. Using defaults for ports.");
        }

        // 2. Initialize Backend Pool
        for (int i = poolStart; i <= poolEnd; i++) {
            FREE_SERVERS.add(i);
        }

        // 3. Graceful Shutdown Hook[cite: 3]
        Runtime.getRuntime().addShutdownHook(new Thread(() -> shutdownGracefully()));

        try {
            serverSocket = new ServerSocket(balancerPort);
            System.out.println("Balancer active on port: " + balancerPort);
            System.out.println("Shutdown Key: " + shutdownKey);
            System.out.println("Managing servers: " + poolStart + "-" + poolEnd);

            while (isRunning) {
                try {
                    // Unique socket per client ensures session distinction[cite: 3]
                    Socket clientSocket = serverSocket.accept();
                    sessionPool.execute(new SessionHandler(clientSocket));
                } catch (SocketException e) {
                    if (!isRunning) break;
                }
            }
        } catch (IOException e) {
            if (isRunning) System.err.println("Server error: " + e.getMessage());
        }
    }

    static class SessionHandler implements Runnable {
        private final Socket clientSocket;
        private final String clientID;
        private Integer assignedPort = null;

        public SessionHandler(Socket socket) {
            this.clientSocket = socket;
            this.clientID = socket.getRemoteSocketAddress().toString();
        }

        @Override
        public void run() {
            try {
                InputStream in = clientSocket.getInputStream();
                // PushbackInputStream peeks at the start of the stream[cite: 2]
                PushbackInputStream pushbackIn = new PushbackInputStream(in, 4096);
                
                byte[] buffer = new byte[1024];
                int bytesRead = pushbackIn.read(buffer);
                
                if (bytesRead != -1) {
                    String initialData = new String(buffer, 0, bytesRead).trim();
                    
                    // Route based on the command type[cite: 2]
                    if (initialData.startsWith("ENROLL_ME")) {
                        handleEnrollment(pushbackIn, buffer, bytesRead);
                    } 
                    else if (initialData.equals("SHUTDOWN_BALANCER " + shutdownKey)) {
                        handleRemoteShutdown();
                    }
                    else {
                        sendError("Invalid Protocol or Incorrect Key.");
                    }
                }
            } catch (IOException e) {
                System.err.println("Session Error [" + clientID + "]: " + e.getMessage());
            } finally {
                cleanup();
            }
        }

        private void handleEnrollment(PushbackInputStream pushbackIn, byte[] buffer, int len) throws IOException {
            assignedPort = FREE_SERVERS.poll();
            if (assignedPort == null) {
                sendError("No free CBservers available.");
                return;
            }

            System.out.println("[CONNECT] " + clientID + " -> Port " + assignedPort);
            pushbackIn.unread(buffer, 0, len); // Restore stream for the backend server[cite: 2, 3]
            
            try (Socket backendSocket = new Socket("localhost", assignedPort)) {
                // Bi-directional proxying of raw ConceptBase bytes[cite: 3]
                Thread c2s = new Thread(() -> bridge(pushbackIn, clientSocket, backendSocket, true));
                Thread s2c = new Thread(() -> bridge(backendSocket.getInputStream(), backendSocket, clientSocket, false));
                c2s.start(); s2c.start();
                c2s.join(); s2c.join();
            } catch (Exception e) {
                System.err.println("Backend Connection Failed: " + e.getMessage());
            }
        }

        private void handleRemoteShutdown() throws IOException {
            System.out.println("[ADMIN] Authorized shutdown from " + clientID);
            PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
            out.println("ACK: Shutting down.");
            clientSocket.close();
            System.exit(0); // Triggers the Shutdown Hook[cite: 3]
        }

        private void bridge(InputStream in, Socket src, Socket dest, boolean isClientSource) {
            try (OutputStream out = dest.getOutputStream()) {
                byte[] buffer = new byte[8192];
                int read;
                while ((read = in.read(buffer)) != -1) {
                    if (isClientSource) {
                        String chunk = new String(buffer, 0, read);
                        // Monitor for session end[cite: 1, 2]
                        if (chunk.contains("CANCEL_ME")) {
                            System.out.println("[CANCEL] Session closing for " + clientID);
                        }
                    }
                    out.write(buffer, 0, read);
                    out.flush();
                }
            } catch (IOException ignored) {}
        }

        private void cleanup() {
            if (assignedPort != null) {
                FREE_SERVERS.offer(assignedPort); // Release port back to availability pool[cite: 3]
                System.out.println("[RELEASE] Port " + assignedPort + " returned to pool.");
                assignedPort = null;
            }
            try { clientSocket.close(); } catch (IOException ignored) {}
        }

        private void sendError(String msg) throws IOException {
            PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
            out.println("ERROR: " + msg);
            clientSocket.close();
        }
    }

    private static void shutdownGracefully() {
        isRunning = false;
        System.out.println("\n[SHUTDOWN] Starting cleanup...");
        try {
            if (serverSocket != null) serverSocket.close();
            sessionPool.shutdown();
            if (!sessionPool.awaitTermination(30, TimeUnit.SECONDS)) {
                sessionPool.shutdownNow();
            }
            System.out.println("[SHUTDOWN] Exited cleanly.");
        } catch (Exception e) {
            System.err.println("Shutdown error: " + e.getMessage());
        }
    }
}
