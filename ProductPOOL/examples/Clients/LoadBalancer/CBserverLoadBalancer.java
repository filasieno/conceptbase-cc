/*
* File: CBserverLoadBalancer.java 
*
* Author: Manfred Jeusfeld (with help from LLM)
* Date: 2026-05-06 (2026-05-06)
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

public class CBserverLoadBalancer {
    private static String shutdownKey = "admin_secret"; 
    private static int balancerPort = 4001;
    private static int poolStart = 4002;
    private static int poolEnd = 4010;
    
    private static volatile boolean isRunning = true;
    private static ServerSocket serverSocket;
    private static final BlockingQueue<Integer> FREE_SERVERS = new LinkedBlockingQueue<>();
    private static final ExecutorService sessionPool = Executors.newCachedThreadPool();

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
            System.out.println("[STARTED] Balancer on port " + balancerPort);

            while (isRunning) {
                try {
                    Socket clientSocket = serverSocket.accept();
                    sessionPool.execute(new ClientHandler(clientSocket));
                } catch (SocketTimeoutException e) {
                    // Check isRunning status
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
        private String clientID = "Unknown";

        public ClientHandler(Socket socket) {
            this.clientSocket = socket;
        }

        @Override
        public void run() {
            try {
                InputStream clientIn = clientSocket.getInputStream();
                OutputStream clientOut = clientSocket.getOutputStream();

                // Initial read to check for shutdown or identity
                byte[] initialBuffer = new byte[4096];
                int bytesRead = clientIn.read(initialBuffer);
                if (bytesRead == -1) return;

                String firstMsg = new String(initialBuffer, 0, bytesRead);
                
                // Check Shutdown
                if (firstMsg.startsWith("SHUTDOWN_BALANCER") && firstMsg.contains(shutdownKey)) {
                    System.out.println("[SHUTDOWN] Valid key received.");
                    isRunning = false;
                    return;
                }

                // Acquire Backend Port
                assignedPort = FREE_SERVERS.poll(10, TimeUnit.SECONDS);
                if (assignedPort == null) {
                    System.err.println("[REJECT] No backend servers available.");
                    return;
                }

                try (Socket backendSocket = new Socket("localhost", assignedPort)) {
                    backendSocket.setTcpNoDelay(true);
                    clientSocket.setTcpNoDelay(true);
                    
                    OutputStream backendOut = backendSocket.getOutputStream();
                    InputStream backendIn = backendSocket.getInputStream();

                    // Forward the first message we already pulled from the stream
                    backendOut.write(initialBuffer, 0, bytesRead);
                    backendOut.flush();
                    System.err.print("[INITIAL_MESSAGE] ");
                    System.err.write(initialBuffer, 0, bytesRead);

                    // Start Bidirectional Proxying
                    Thread t1 = new Thread(() -> proxy(clientIn, backendOut, "C->B"));
                    Thread t2 = new Thread(() -> proxy(backendIn, clientOut, "B->C"));
                    
                    t1.start();
                    t2.start();

                    // Wait for both directions to finish
                    t1.join();
                    t2.join();
                } 
            } catch (Exception e) {
                System.err.println("[ERROR] Session interrupted: " + e.getMessage());
            } finally {
                cleanup();
            }
        }

        private void proxy(InputStream in, OutputStream out, String direction) {
            try {
                byte[] buffer = new byte[8192];
                int read;
                while ((read = in.read(buffer)) != -1) {
                    out.write(buffer, 0, read);
                    out.flush();
                    System.err.write(buffer, 0, read);
                }
            } catch (IOException e) {
                // Connection likely closed by one end
            }
        }

        private void cleanup() {
            if (assignedPort != null) {
                FREE_SERVERS.offer(assignedPort);
                System.out.println("[RELEASE] Port " + assignedPort + " returned to pool.");
                assignedPort = null;
            }
            try { clientSocket.close(); } catch (IOException ignored) {}
        }
    }

    private static void shutdownGracefully() {
        isRunning = false;
        try {
            if (serverSocket != null) serverSocket.close();
            sessionPool.shutdownNow();
        } catch (Exception e) {
            System.err.println("Shutdown error: " + e.getMessage());
        }
    }
}
