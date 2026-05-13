/*
* File: CBserverLoadBalancer.java 
*
* Author: Manfred Jeusfeld (with help from LLM)
* Date: 2026-05-06 (2026-05-13)
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

 With user port mapping: java CBserverLoadBalancer <shutdownKey> <balancerPort> <poolStart> <poolEnd> -c <filename>
 Example: java CBserverLoadBalancer stop319 4001 5001 5002 -c up1.txt
    
*/


/* Edits:
* 2026-05-10: add a -c command line paramter to memorize, which users were
* assigned to which port in previous session. The user-port mapping is
* save every 60 seconds if -c is used; at the next start of the load
* balancer, the mappings are initialized from the file and users get
* assigned the same pool server. This allows to have different databases
* at different ports for diffrent users and always assign them to the
* right database.
* 2026-05-10: add a -fix command line parameter to make the user-port assignment
* exclusive. Once a port is assigned to a user, it is never returned
* to the free pool for other users, even if the user is currently offline.
*/



import java.io.*;
import java.net.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.regex.*;

public class CBserverLoadBalancer {
    private static String shutdownKey = "admin_secret"; 
    private static int balancerPort = 4001;
    private static int poolStart = 4002;
    private static int poolEnd = 4010;
    private static String configFilePath = null;  // stores USER_TO_PORT mapping
    private static boolean isFixed = false;       // will keep USER_TO_PORT mapping permanent
    
    private static volatile boolean isRunning = true;  // load balancer is running
    private static volatile boolean savedOnShutdown = false; 
    private static ServerSocket serverSocket;
    private static final BlockingQueue<Integer> FREE_SERVERS = new LinkedBlockingQueue<>();
    private static final ExecutorService sessionPool = Executors.newCachedThreadPool();
    private static final ScheduledExecutorService persistenceScheduler = Executors.newSingleThreadScheduledExecutor();

    // stores username:portnr pairs
    private static final Map<String, Integer> USER_TO_PORT = new ConcurrentHashMap<>();    

    // count how many clients are served by the same port
    private static final Map<Integer, Integer> PORT_REF_COUNT = new ConcurrentHashMap<>(); 



    public static void main(String[] args) {

        List<String> remainingArgs = new ArrayList<>();


        // scan for -c and -fix command line parameters
        for (int i = 0; i < args.length; i++) {
            if (args[i].equals("-c") && i + 1 < args.length) {
                configFilePath = args[++i];
            } else if (args[i].equals("-fix")) {
                isFixed = true;
            } else {
                remainingArgs.add(args[i]);
            }
        }

        // rest is for finding the shutdown key, the portnr of the load balancer and the 
        // interval of pool server port numbers
        try {
            if (remainingArgs.size() >= 1) shutdownKey = remainingArgs.get(0);
            if (remainingArgs.size() >= 2) balancerPort = Integer.parseInt(remainingArgs.get(1));
            if (remainingArgs.size() >= 3) poolStart = Integer.parseInt(remainingArgs.get(2));
            if (remainingArgs.size() >= 4) poolEnd = Integer.parseInt(remainingArgs.get(3));
        } catch (NumberFormatException e) {
            System.err.println("Invalid numeric arguments.");
        }

        // 1. Initialize the complete pool of ports
        List<Integer> initialPool = new ArrayList<>();
        for (int i = poolStart; i <= poolEnd; i++) {
            initialPool.add(i);
        }

        // 2. Load mappings and REMOVE those ports from the initial pool
        if (configFilePath != null) {
            loadUserPortMapping(initialPool);
            persistenceScheduler.scheduleAtFixedRate(CBserverLoadBalancer::saveUserPortMapping, 60, 60, TimeUnit.SECONDS);
        }

        // 3. Put ONLY the remaining (truly unassigned) ports into the FREE_SERVERS queue
        for (Integer p : initialPool) {
            FREE_SERVERS.offer(p);
        }
        
        // 4. In default mode, ports that ARE in USER_TO_PORT but have no active connections 
        // must also be available in the pool.
        // If -fix is active, we skip this to ensure the port remains exclusive to the user.
        if (!isFixed) {
            for (Integer mappedPort : USER_TO_PORT.values()) {
                if (!FREE_SERVERS.contains(mappedPort)) {
                    FREE_SERVERS.offer(mappedPort);
                }
            }
        } else {
            System.err.println("[INIT] Fixed mode enabled: Mapped ports are reserved exclusively.");
        }

        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            System.err.println("\n[SHUTDOWN] Signal caught.");
            shutdownGracefully();
        }));

        try {
            serverSocket = new ServerSocket(balancerPort);
            serverSocket.setSoTimeout(2000); 
            System.out.println("[STARTED] LoadBalancer on port " + balancerPort);

            while (isRunning) {
                try {
                    Socket clientSocket = serverSocket.accept();
                    sessionPool.execute(new ClientHandler(clientSocket));
                } catch (SocketTimeoutException e) { }
            }
        } catch (IOException e) {
            if (isRunning) System.err.println("Server Error: " + e.getMessage());
        } finally {
            shutdownGracefully();
        }
    }


    /**
    loadUserPortMapping(List<Integer> initialPool)
    - read the user to port mapping from the file specified in the -c command line parameter
    */

    private static void loadUserPortMapping(List<Integer> initialPool) {
        File file = new File(configFilePath);
        if (!file.exists()) {
            System.err.println("[LOAD] No persistence file found at " + configFilePath);
            return;
        }
        System.err.println("[LOAD] Reading mappings from " + configFilePath + "...");
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            int count = 0;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(":", 2);
                if (parts.length == 2) {
                    try {
                        String user = parts[0];
                        int port = Integer.parseInt(parts[1]);
                        if (port >= poolStart && port <= poolEnd) {
                            USER_TO_PORT.put(user, port);
                            initialPool.remove(Integer.valueOf(port));
                            System.err.println("   [RESTORED] User: " + user + " -> Port: " + port);
                            count++;
                        }
                    } catch (NumberFormatException e) { }
                }
            }
            System.err.println("[LOAD-SUCCESS] Loaded " + count + " persistent associations.");
        } catch (IOException e) {
            System.err.println("[LOAD-ERROR] " + e.getMessage());
        }
    }


    /**
    saveUserPortMapping()
    - saves the user to port mapping to the file specified in the -c command line parameter
    - this can then be loaded at the next start-up of the load balancer
    */
    private static synchronized void saveUserPortMapping() {
        if (configFilePath == null || USER_TO_PORT.isEmpty()) return;
        System.err.println("[SAVE] Persisting " + USER_TO_PORT.size() + " mappings...");
        try (PrintWriter writer = new PrintWriter(new FileWriter(configFilePath, false))) {
            for (Map.Entry<String, Integer> entry : USER_TO_PORT.entrySet()) {
                writer.println(entry.getKey() + ":" + entry.getValue());
            }
            writer.flush();
            System.err.println("[SAVE-SUCCESS] File " + configFilePath + " updated.");
        } catch (IOException e) {
            System.err.println("[SAVE-ERROR] " + e.getMessage());
        }
    }


    // last operations of main()
    private static synchronized void shutdownGracefully() {
        if (savedOnShutdown) return; 
        isRunning = false;
        persistenceScheduler.shutdownNow(); 
        saveUserPortMapping(); 
        savedOnShutdown = true;
        try {
            if (serverSocket != null) serverSocket.close();
            sessionPool.shutdownNow();
        } catch (Exception e) { }
    }


    /**
    * ClientHandler
    * Internal class to provide the run() for reading new incoming ENROLL_MEs of clients and then spawing the proxy thread 
    * for the new client
    */

    private static class ClientHandler implements Runnable {
        private final Socket clientSocket;
        private Integer assignedPort = null;
        private String detectedUser = null;

        public ClientHandler(Socket socket) { this.clientSocket = socket; }

        @Override
        public void run() {
            try {
                InputStream clientIn = clientSocket.getInputStream();
                OutputStream clientOut = clientSocket.getOutputStream();
                ByteArrayOutputStream collector = new ByteArrayOutputStream();
                byte[] buffer = new byte[4096];
                int n;

                while (true) {
                    n = clientIn.read(buffer);
                    if (n == -1) return;
                    collector.write(buffer, 0, n);
                    String msg = collector.toString();

                    if (msg.contains("SHUTDOWN_BALANCER " + shutdownKey)) {
                        isRunning = false;
                        shutdownGracefully();
                        System.exit(0);
                        return;
                    }
                    if (msg.contains("ENROLL_ME") && msg.contains("]).")) {
                        detectedUser = extractUsername(msg);
                        System.err.println("[INITIAL MSG] User " + msg);
                        break;
                    }
                    if (collector.size() > 8192) break;
                }

                synchronized (USER_TO_PORT) {
                    if (detectedUser != null && USER_TO_PORT.containsKey(detectedUser)) {
                        int pref = USER_TO_PORT.get(detectedUser);
                        
                        if (isFixed) {
                            // Fixed Mode: Reclaim the port directly. It is never in FREE_SERVERS.
                            assignedPort = pref;
                            PORT_REF_COUNT.put(assignedPort, PORT_REF_COUNT.getOrDefault(assignedPort, 0) + 1);
                            System.err.println("[FIXED-MATCH] User " + detectedUser + " using reserved Port " + assignedPort);
                        } else {
                            // Default Mode: Check if the sticky port is currently available in the free pool
                            if (FREE_SERVERS.remove(pref)) {
                                assignedPort = pref;
                                PORT_REF_COUNT.put(assignedPort, 1);
                                System.err.println("[MATCH] Sticky port " + assignedPort + " reclaimed for " + detectedUser);
                            } else if (PORT_REF_COUNT.containsKey(pref)) {
                                // Port is busy, but we join the existing session
                                assignedPort = pref;
                                PORT_REF_COUNT.put(assignedPort, PORT_REF_COUNT.get(assignedPort) + 1);
                                System.err.println("[SHARED] Sticky port " + assignedPort + " shared for " + detectedUser);
                            }
                        }
                    }
                    
                    if (assignedPort == null) {
                        assignedPort = FREE_SERVERS.poll(2, TimeUnit.SECONDS);
                        if (assignedPort != null) {
                            PORT_REF_COUNT.put(assignedPort, 1);
                            if (detectedUser != null) {
                                USER_TO_PORT.put(detectedUser, assignedPort);
                                System.err.println("[NEW-ASSIGN] User " + detectedUser + " -> Port " + assignedPort);
                            }
                        } else {
                            System.err.println("[CRITICAL] No ports available in pool for " + detectedUser);
                        }
                    }
                }

                if (assignedPort == null) return;

                try (Socket backend = new Socket("127.0.0.1", assignedPort)) {
                    final InputStream bIn = backend.getInputStream();
                    final OutputStream bOut = backend.getOutputStream();
                    Thread b2c = new Thread(() -> proxy(bIn, clientOut));  // stream answers from back pool server to client
                    b2c.start();
                    bOut.write(collector.toByteArray());
                    bOut.flush();
                    proxy(clientIn, bOut); // stream messages from client to back pool server
                    b2c.join();
                }
            } catch (Exception e) {
                System.err.println("[HANDLER-ERROR] " + e.getMessage());
            } finally {
                cleanup();
            }
        }

        // overkill pattern matcher for a user name
        private String extractUsername(String msg) {
            Matcher m = Pattern.compile("\\[\\s*\"[^\"]*\"\\s*,\\s*\"([^\"]+)\"\\s*\\]").matcher(msg);
            return m.find() ? m.group(1) : null;
        }

        // keep reading messages from input stream and passing it to output steam
        private void proxy(InputStream in, OutputStream out) {
            try {
                byte[] b = new byte[8192];
                int r;
                while ((r = in.read(b)) != -1) { out.write(b, 0, r); out.flush(); }
            } catch (IOException e) {}
        }

        // last operations before stopping the ClientHandler
        private void cleanup() {
            if (assignedPort != null) {
                synchronized (USER_TO_PORT) {
                    int count = PORT_REF_COUNT.getOrDefault(assignedPort, 1) - 1;
                    if (count <= 0) {
                        PORT_REF_COUNT.remove(assignedPort);
                        
                        // If -fix is active and the port belongs to a user, do not return to pool.
                        if (isFixed && detectedUser != null) {
                            System.err.println("[RELEASE] Port " + assignedPort + " is now idle but remains reserved for " + detectedUser);
                        } else {
                            FREE_SERVERS.offer(assignedPort);
                            System.err.println("[RELEASE] Port " + assignedPort + " returned to free pool.");
                        }
                    } else {
                        PORT_REF_COUNT.put(assignedPort, count);
                    }
                }
            }
            try { clientSocket.close(); } catch (IOException e) {}
        }
    }  // end ClientHandler



}
