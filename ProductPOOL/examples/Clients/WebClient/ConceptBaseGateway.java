import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

import i5.cb.api.*;
import i5.cb.CBException;

// You MUST have LocalCBclient.java, CBanswer.java, CBException.java, and CButil.java in your project for this to compile.
// The imports for CB classes are assumed to be correct based on the provided code.
// For this example, we'll use placeholder imports for CB classes:
// import i5.cb.api.LocalCBclient; 
// import i5.cb.api.CBanswer;
// import i5.cb.api.CBException; 

public class ConceptBaseGateway {

    private static LocalCBclient client = null; // Maintains the single connection state
    private static final int PORT = 8080;

    public static void main(String[] args) throws IOException {
        // Initialize the client instance
        client = new LocalCBclient(); 

        // 1. Create HTTP Server
        HttpServer server = HttpServer.create(new InetSocketAddress(PORT), 0);
        
        // 2. Define the API context
        server.createContext("/api/cb", new CBHttpHandler());
        
        // 3. Start the server
        server.setExecutor(null); // Use default executor
        server.start();

        System.out.println("ConceptBase Gateway Server started on port " + PORT);
        System.out.println("Awaiting requests from the JavaScript client...");
    }

    // --- Minimal JSON Parser Placeholder ---
    // Parses a simple JSON string into a Map<String, String|Integer> for demonstration.
    private static Map<String, Object> parseJson(String jsonString) {
        Map<String, Object> map = new HashMap<>();
        // Simple regex/replace logic to extract key-value pairs
        String content = jsonString.trim().replaceAll("[{}]", "");
        for (String pair : content.split("\",\"")) {
            String[] parts = pair.split("\":");
            if (parts.length == 2) {
                String key = parts[0].replaceAll("\"", "").trim();
                String value = parts[1].replaceAll("\"", "").trim();
                // Attempt to parse integers for 'port', otherwise keep as String
                try {
                    if (key.equalsIgnoreCase("port")) {
                        map.put(key, Integer.parseInt(value));
                    } else {
                        map.put(key, value);
                    }
                } catch (NumberFormatException e) {
                    map.put(key, value);
                }
            }
        }
        return map;
    }
    // ----------------------------------------

    static class CBHttpHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            // Must allow all origins for the JavaScript client to connect (CORS)
            setCorsHeaders(exchange);

            if (exchange.getRequestMethod().equalsIgnoreCase("OPTIONS")) {
                exchange.sendResponseHeaders(204, -1); // 204 No Content for preflight success
                return;
            }

            if (!exchange.getRequestMethod().equalsIgnoreCase("POST")) {
                sendResponse(exchange, 405, jsonError("Method Not Allowed"));
                return;
            }

            // Read Request Body
            String requestBody = new BufferedReader(new InputStreamReader(exchange.getRequestBody()))
                    .lines().collect(Collectors.joining("\n"));

            // Process Request
            String responseJson = processCommand(requestBody);

            // Send Response
            sendResponse(exchange, 200, responseJson);
        }

        private void setCorsHeaders(HttpExchange exchange) {
            exchange.getResponseHeaders().add("Access-Control-Allow-Origin", "*");
            exchange.getResponseHeaders().add("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
            exchange.getResponseHeaders().add("Access-Control-Allow-Headers", "Content-Type");
        }

        private void sendResponse(HttpExchange exchange, int statusCode, String response) throws IOException {
            exchange.getResponseHeaders().set("Content-Type", "application/json");
            byte[] bytes = response.getBytes();
            exchange.sendResponseHeaders(statusCode, bytes.length);
            OutputStream os = exchange.getResponseBody();
            os.write(bytes);
            os.close();
        }

        private String processCommand(String requestBody) {
            try {
                Map<String, Object> request = parseJson(requestBody);
                String command = (String) request.get("command");
                
                String host = (String) request.get("host");
                int port = (Integer) request.getOrDefault("port", 4001); // Default to 4001
                String tool = (String) request.get("tool");
                String user = (String) request.get("user");
                String data = (String) request.get("data"); // Frames/Query

                System.out.println("Processing: " + command + " with data: " + data);

                switch (command) {
                    case "enrollMe":
                        // Assuming enrollment requires host, port, tool, user
                        client.enrollMe(host, port, tool, user); 
                        return jsonSuccess("Successfully connected to ConceptBase server.");

                    case "cancelMe":
                        client.cancelMe(); 
                        return jsonSuccess("Successfully disconnected from ConceptBase server.");

                    case "tell":
                        // Use the tellTransactions method for telling frames
                        // You may need to handle the returned CBanswer object properly
                        CBanswer tellAns = client.tellTransactions(data);
                        if (tellAns.getCompletion() == CBanswer.OK) {
                            return jsonSuccess("TELL command successful. Server response: " + tellAns.getResult());
                        } else {
                            // Fetch detailed error message using getErrorMessages()
                            return jsonError("TELL failed. Server Error:\n" + client.getErrorMessages());
                        }
                        
                    case "untell":
                        // Use the untell method
                        CBanswer untellAns = client.untell(data);
                        if (untellAns.getCompletion() == CBanswer.OK) {
                            return jsonSuccess("UNTELL command successful. Server response: " + untellAns.getResult());
                        } else {
                            return jsonError("UNTELL failed. Server Error:\n" + client.getErrorMessages());
                        }

                    case "ask":
                        // Use the ask method with default parameters
                        CBanswer askAns = client.ask(data, "OBJNAMES", "FRAME", "Now");
                        if (askAns.getCompletion() == CBanswer.OK) {
                            return jsonSuccess("ASK command successful. Result:\n" + askAns.getResult());
                        } else {
                            return jsonError("ASK failed. Server Error:\n" + client.getErrorMessages());
                        }

                    default:
                        return jsonError("Unknown command: " + command);
                }
            } catch (CBException e) {
                // Catch ConceptBase specific exceptions
                return jsonError("ConceptBase Error: " + e.getMessage());
            } catch (Exception e) {
                // Catch all other exceptions (e.g., connection, parsing)
                return jsonError("Internal Server Error: " + e.getMessage());
            }
        }
    }
    
    // --- Minimal JSON Creator Placeholders ---
    private static String jsonSuccess(String message) {
        // Escape newlines for valid JSON string
        String escapedMsg = message.replace("\n", "\\n").replace("\"", "\\\"");
        return "{\"status\":\"OK\",\"message\":\"" + escapedMsg + "\"}";
    }

    private static String jsonError(String message) {
        String escapedMsg = message.replace("\n", "\\n").replace("\"", "\\\"");
        return "{\"status\":\"ERROR\",\"message\":\"" + escapedMsg + "\"}";
    }
    // ----------------------------------------
}


