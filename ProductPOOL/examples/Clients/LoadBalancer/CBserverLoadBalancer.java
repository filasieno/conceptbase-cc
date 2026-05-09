/*
* File: CBserverLoadBalancer.java 
*
* Author: Manfred Jeusfeld (with help from LLM)
* Date: 2026-05-06 (2026-05-09)
* --------------------------------------------------------------
* License: Creative Commons CC-BY 4.0
*
* THIS SOFTWARE IS PROVIDED BY THE CONCEPTBASE TEAM ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
* INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
* PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONCEPTBASE TEAM OR CONTRIBUTORS BE
* LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
* OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
* CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
* OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
*/


/*
 This is a Reverse Proxy Load Balancer for the ConceptBase server. It pretends to ConceptBase
 clients to be a ConceptBase server. But in fact it forwards their requests to a pool of ConceptBase servers
 on localhost. When I client gracefully exits, the corresponding slot becomes free again, assuming that the
 ConceptBase server restarts itself on the same port.

 To start: java CBserverLoadBalancer <shutdownKey> <balancerPort> <poolStart> <poolEnd>
 To shutdown: echo "SHUTDOWN_BALANCER <shutdownKey>" | nc localhost <balancerPort>
*/


import java.io.*;
import java.net.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.regex.*;

/**
 * Stateful Reverse Proxy Load Balancer for ConceptBase.
 * Enhanced with patient handshake collection and transient PingClient handling.
 */
public class CBserverLoadBalancer {
    private static String shutdownKey = "admin_secret"; 
    private static int balancerPort = 4001;
    private static int poolStart = 4002;
    private static int poolEnd = 4010;
    
    private static volatile boolean isRunning = true;
    private static ServerSocket serverSocket;
    private static final BlockingQueue<Integer> FREE_SERVERS = new LinkedBlockingQueue<>();
    private static final ExecutorService sessionPool = Executors.newCachedThreadPool();

    private static final Map<String, Integer> USER_TO_PORT = new ConcurrentHashMap<>();
    private static final Map<Integer, Integer> PORT_REF_COUNT = new ConcurrentHashMap<>();

    public static void main(String[] args) {
        try {
            if (args.length >= 1) shutdownKey = args[0];
            if (args.length >= 2) balancerPort = Integer.parseInt(args[1]);
            if (args.length >= 3) poolStart = Integer.parseInt(args[2]);
            if (args.length >= 4) poolEnd = Integer.parseInt(args[3]);
        } catch (NumberFormatException e) {
            System.err.println("Invalid numeric arguments. Using defaults.");
        }

        for (int i = poolStart; i <= poolEnd; i++) {
            FREE_SERVERS.offer(i);
        }

        try {
            serverSocket = new ServerSocket(balancerPort);
            serverSocket.setSoTimeout(5000); 
            System.out.println("[STARTED] Stateful CBserverLoadBalancer on port " + balancerPort);

            while (isRunning) {
                try {
                    Socket clientSocket = serverSocket.accept();
                    sessionPool.execute(new ClientHandler(clientSocket));
                } catch (SocketTimeoutException e) {
                    // Periodic check of isRunning status
                }
            }
        } catch (IOException e) {
            if (isRunning) System.err.println("Server Error: " + e.getMessage());
        } finally {
            shutdownGracefully();
        }
    }

    private static class ClientHandler implements Runnable {
        private final Socket clientSocket;
        private Integer assignedPort = null;
        private String detectedUser = null;
        private boolean isPingOnly = false;

        public ClientHandler(Socket socket) {
            this.clientSocket = socket;
        }

        @Override
        public void run() {
            try {
                clientSocket.setTcpNoDelay(true);
                clientSocket.setKeepAlive(true);  // for not loosing messages or only receiving partial messages
                InputStream clientIn = clientSocket.getInputStream();
                OutputStream clientOut = clientSocket.getOutputStream();

                // 1. Patient Handshake Collection
                ByteArrayOutputStream handshakeCollector = new ByteArrayOutputStream();
                byte[] readBuffer = new byte[16384];
                int bytesRead;

                while (true) {
                    bytesRead = clientIn.read(readBuffer);
                    if (bytesRead == -1) return;
                    handshakeCollector.write(readBuffer, 0, bytesRead);
                    
                    byte[] currentBytes = handshakeCollector.toByteArray();
                    int offset = (currentBytes[0] == 'X') ? 5 : 0;
                    if (currentBytes.length <= offset) continue;

                    String currentMsg = new String(currentBytes, offset, currentBytes.length - offset);

                    if (currentMsg.trim().startsWith("SHUTDOWN_BALANCER " + shutdownKey)) {
                        System.err.println("[ADMIN] Shutdown triggered.");
                        isRunning = false;
                        return;
                    }

                    // Only break when we see the protocol terminator to ensure full extraction
                    if (currentMsg.contains("ENROLL_ME") && currentMsg.contains("]).")) {
                        detectedUser = extractUsername(currentMsg);
                        if (currentMsg.contains("\"PingClient\"")) {
                            isPingOnly = true;
                        }
                        break; 
                    }
                    
                    // Safety limit to prevent memory issues from malformed clients
                    if (handshakeCollector.size() > 8192) break;
                }

                byte[] fullHandshake = handshakeCollector.toByteArray();
                
                // Tracing the initial message; should be an ENROLL_ME message
                int finalOffset = (fullHandshake[0] == 'X') ? 5 : 0;
                String finalMsgStr = new String(fullHandshake, finalOffset, Math.max(0, fullHandshake.length - finalOffset));
                System.err.println("[INITIAL_MESSAGE] " + finalMsgStr.trim());

                // 2. Atomic Port Assignment
                synchronized (USER_TO_PORT) {
                    if (detectedUser != null && USER_TO_PORT.containsKey(detectedUser)) {
                        assignedPort = USER_TO_PORT.get(detectedUser);
                        int count = PORT_REF_COUNT.getOrDefault(assignedPort, 0) + 1;
                        PORT_REF_COUNT.put(assignedPort, count);
                        System.err.println("[STICKY] User " + detectedUser + " -> Port " + assignedPort + " (Active: " + count + ")");
                    } else {
                        assignedPort = FREE_SERVERS.poll(10, TimeUnit.SECONDS);
                        if (assignedPort != null) {
                            PORT_REF_COUNT.put(assignedPort, 1);
                            // Skip sticky mapping for pings or unknown users
                            if (detectedUser != null && !isPingOnly) {
                                USER_TO_PORT.put(detectedUser, assignedPort);
                                System.err.println("[ASSIGN] User " + detectedUser + " -> Port " + assignedPort);
                            } else {
                                System.err.println("[TEMP] Ping/Guest -> Port " + assignedPort);
                            }
                        }
                    }
                }

                if (assignedPort == null) {
                    new PrintWriter(clientOut, true).println("ERROR: No backends available.");
                    return;
                }

                // 3. Proxying
                try (Socket backendSocket = new Socket("127.0.0.1", assignedPort)) {
                    backendSocket.setTcpNoDelay(true);
                    InputStream backendIn = backendSocket.getInputStream();
                    OutputStream backendOut = backendSocket.getOutputStream();

                    Thread b2c = new Thread(() -> proxy(backendIn, clientOut));
                    b2c.start();

                    backendOut.write(fullHandshake);
                    backendOut.flush();

                    proxy(clientIn, backendOut);
                    b2c.join();
                } 
            } catch (Exception e) {
                // Connection closed
            } finally {
                cleanup();
            }
        }

        private String extractUsername(String msg) {
            Pattern p = Pattern.compile("\\[\\s*\"[^\"]*\"\\s*,\\s*\"([^\"]+)\"\\s*\\]");
            Matcher m = p.matcher(msg);
            return m.find() ? m.group(1) : null;
        }

        private void proxy(InputStream in, OutputStream out) {
            try {
                byte[] buffer = new byte[16384];
                int read;
                while ((read = in.read(buffer)) != -1) {
                    out.write(buffer, 0, read);
                    out.flush();
                }
            } catch (IOException ignored) { }
        }

        private void cleanup() {
            if (assignedPort != null) {
                synchronized (USER_TO_PORT) {
                    Integer count = PORT_REF_COUNT.get(assignedPort);
                    if (count != null) {
                        count--;
                        if (count <= 0) {
                            PORT_REF_COUNT.remove(assignedPort);
                            // Only remove sticky mapping if this specific port was the one mapped
                            if (detectedUser != null && assignedPort.equals(USER_TO_PORT.get(detectedUser))) {
                                USER_TO_PORT.remove(detectedUser);
                            }
                            FREE_SERVERS.offer(assignedPort);
                            System.err.println("[RELEASE] Port " + assignedPort + " returned to pool.");
                        } else {
                            PORT_REF_COUNT.put(assignedPort, count);
                            System.err.println("[RELEASE] Port " + assignedPort + " active clients: " + count);
                        }
                    }
                }
                assignedPort = null;
            }
            try { clientSocket.close(); } catch (IOException ignored) { }
        }
    }

    private static void shutdownGracefully() {
        isRunning = false;
        try {
            if (serverSocket != null) serverSocket.close();
            sessionPool.shutdownNow();
        } catch (Exception e) { }
    }
}
