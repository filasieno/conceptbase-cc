/*
The ConceptBase.cc Copyright

Copyright 1987-2021 The ConceptBase Team. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted
provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of
      conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE CONCEPTBASE TEAM ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONCEPTBASE TEAM OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the authors
and should not be interpreted as representing official policies, either expressed or implied,
of the ConceptBase Team.


The ConceptBase Team is represented by

Manfred Jeusfeld, University of Skovde, 54128 Skovde, Sweden
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
package i5.cb.api;

import i5.cb.CBException;
import i5.cb.Contract;

import java.io.*;
import java.net.*;
import java.nio.charset.*;
import java.nio.channels.FileChannel;
import java.nio.MappedByteBuffer;

/**
 * A client class for ConceptBase. Represents a local, that is not RMI-able
 * connection to a ConceptBase server.
 * This class is by design _not_ threadsafe, although some methods like
 * sendMessage() are synchronized to prevent the worst. If you want multiple
 * threads to communicate to the server, use different connections for each
 * thread.
 *
 * @see CBclient
 *
 * @author   Christoph Quix
 * @author   Rainer Hermanns
 * @author   Christoph Radig
 * @version  0.5
 * @see      java.net.Socket
 */
public class LocalCBclient implements ICBclient {
    /**
     * Constructs a new LocalCBclient object without any connection to a server
     **/
    public LocalCBclient() {
        this.sHost="";
        this.iPort=0;
        this.sUser="";
        this.sTool="";
        this.sServerId="";
        this.sToolId="";
        this.setConnected(false);
    } // ctor1

    /**
     * Constructs a new LocalCBclient object and connect to the specified host and port
     *
     * @param sHost hostname of the machine where the server runs
     * @param iPort port number of server
     * @param sTool the name of the tool
     * @param sUser the name of the user
     * @exception CBException if an error occurs when connecting
     * @see i5.cb.api.LocalCBclient#enrollMe(String,int,String,String)
     */
    public LocalCBclient(String sHost, int iPort, String sTool, String sUser) throws CBException {
        this.sHost="";
        this.iPort=0;
        this.sUser="";
        this.sTool="";
        this.sServerId="";
        this.sToolId="";
        this.setConnected(false);

        enrollMe(sHost, iPort, sTool, sUser);
    } // ctor2

    /**
     * Attempt to fetch this client's computer's full domain name; returns "unknown" if unsuccessfull
    */
    private String clientDomainName() {
        InetAddress addr;
        String hostnameCanonical;
        try{
            addr = InetAddress.getByName(InetAddress.getLocalHost().getHostName());
            return addr.getCanonicalHostName();
        } 
        catch (Exception e) {
          return "unknown";
        }
    }


    /**
     * Pings a ConceptBase Server
     *
     * @param sHost hostname of the machine where the server runs
     * @param iPort port number of server
     * @return a true if the ConceptBase server is alive, else false
     */
    public synchronized boolean pingCBserver(String sHost, int iPort)  {
        assert((sHost != null) && (iPort >= 0) && (iPort <= 99999) &&
               (!this.bConnected)):"LocalCBclient.enrollMe(String,int,String,String)";

        // Set Tool and User 
        String sTool = "PingClient";
        String sUser;
        try {
            sUser=System.getProperty("user.name", "unknown");
        }
        catch(SecurityException se) {
            sUser="unknown";
        }
        sUser = sUser.replace('.','_');   // do not use "." in user names

        String sLocalHostName = clientDomainName();
        String sLocalOS="anyos";
        String sLocalARCH="anyarch";
        try {
          sLocalOS = System.getProperty("os.name").replaceAll(" ",""); // OS name with blanks removed
          sLocalARCH = System.getProperty("os.arch").replaceAll(" ",""); 
        } catch (Exception e) { }

        // Set skServer with new Host & Port
        if (skServer == null) {
           try {
               skServer=new Socket(sHost, iPort);
           }
           // Catch unknown Host
           catch(UnknownHostException e1) {
               return false;
           }
           // Catch Misc IOException
           catch(IOException e2) {
               return false;
           }
        }

        try {
            if (dsIn == null)
               dsIn=new DataInputStream(skServer.getInputStream());
            if (dsOut == null)
               dsOut=new DataOutputStream(skServer.getOutputStream());
        }
        catch (Exception e) {
            return false;
        }

        CBanswer caAns=null;
        try {
            caAns = sendMessage("ENROLL_ME", CButil.encodeString(sTool) + "," +
                            CButil.encodeString(sUser + "@" + sLocalHostName + "_" + sLocalARCH + "_" + sLocalOS));
        } catch (Exception e) {
           return false;
        }

        if(caAns != null && caAns.getCompletion() == CBanswer.OK)
            return true;
        else
            return false;

    } // pingCBserver



    /**
     * Connects to a ConceptBase Server
     *
     * @param sHost hostname of the machine where the server runs
     * @param iPort port number of server
     * @param sTool the name of the tool
     * @param sUser the name of the user
     * @return a CBanswer object containing the result and the completion
     * @exception CBException if an error occurs when connecting
     * @see java.net.Socket#Socket(String, int)
     */
    public synchronized CBanswer enrollMe(String sHost, int iPort, String sTool, String sUser) throws
        CBException {
        assert((sHost != null) && (iPort >= 0) && (iPort <= 99999) &&
               (!this.bConnected)):"LocalCBclient.enrollMe(String,int,String,String)";

        // Set Tool and User to default values, if they are null
        if(sTool == null) {
            sTool="JavaClient";
        }
        if(sUser == null) {
            try {
                sUser=System.getProperty("user.name", "unknown");
            }
            catch(SecurityException se) {
                sUser="unknown";
            }
        }
        sUser = sUser.replace('.','_');   // do not use "." in user names

        String sLocalHostName = clientDomainName();
        String sLocalOS="anyos";
        String sLocalARCH="anyarch";
        try {
          sLocalOS = System.getProperty("os.name").replaceAll(" ",""); // OS name with blanks removed
          sLocalARCH = System.getProperty("os.arch").replaceAll(" ",""); 
        } catch (Exception e) {
        }

        // Set skServer with new Host & Port; could already be set by pingCBserver
        if (skServer == null) {
           try {
               skServer=new Socket(sHost, iPort);
           }
           // Catch unknown Host
           catch(UnknownHostException e1) {
               throw new CBConnectionException(
                   "CBConnectionException in LocalCBclient.enrollMe(String)" + e1.getMessage());
           }
           // Catch Misc IOException
           catch(IOException e2) {
               throw new CBIOException(
                   "CBIOException in LocalCBclient.enrollMe(String); Exceptionmessage:" + e2.getMessage());
           }
        }

        // set Server TimeOut
        // SocketException wird von der Methode geworfen, wenn TimeOut nicht gesetzt
        // werden kann. Da fuer Client uninteressant, wird die Exception nicht weiter
        // gereicht
        try {
            skServer.setSoTimeout(200000); // about 3 minutes timeout
        }
        catch(SocketException e3) {
            // Do nothing
        }

        // Deprecated, aber bessere Loesung nicht bekannt!?
        try {
            if (dsIn == null)
               dsIn=new DataInputStream(skServer.getInputStream());
            if (dsOut == null)
               dsOut=new DataOutputStream(skServer.getOutputStream());
        }
        // Catch appearing Exceptions with getInputStream()m getOutputStream()
        catch(IOException e) {
            throw new CBIOException("CBIOException in LocalCBclient.enrollMe(String)" +
                                    e.getMessage());
        }

        // sendMessage "Enroll_Me" sends Message to CBServer with method ENROLL_ME
        // and data

        CBanswer caAns=
            sendMessage("ENROLL_ME", CButil.encodeString(sTool) + "," +
                        CButil.encodeString(sUser + "@" + sLocalHostName + "_" + sLocalARCH + "_" + sLocalOS));

        if(caAns.getCompletion() == CBanswer.OK) {
            this.setConnected(true);
            this.sHost=sHost;
            this.iPort=iPort;
            this.sUser=sUser;
            this.sTool=sTool;
            this.sServerId=caAns.getRespondingTool();
            this.sToolId=caAns.getResult();

            if(sToolId == null || sToolId.equals(""))
                throw new CBException("tool id is empty!");
        }
        else
            throw new CBException("enroll me failed.");

        Contract.ensures("LocalCBclient.enrollMe(String,int,String,String)",
                         (((caAns.getCompletion() == CBanswer.OK) && (this.bConnected) &&
                           (this.sHost != null) && (this.iPort >= 2000) && (this.iPort <= 99999) &&
                           (this.sTool != null) && (this.sUser != null)) ||
                          (caAns.getCompletion() != CBanswer.OK)));

        return caAns;
    } // enrollMe

    /**
     * Disconnects from a ConceptBase Server
     *
     * @return a CBanswer object containing the result and the completion
     * @exception CBException if an error occurs when disconnecting
     */
    public synchronized CBanswer cancelMe() throws CBException {
        assert bConnected:"LocalCBclient.cancelMe()";

        CBanswer caAns=sendMessage("CANCEL_ME", "");

        if(caAns.getCompletion() == CBanswer.OK) {
            this.sHost="";
            this.iPort=0;
            this.sUser="";
            this.sTool="";
            this.sServerId="";
            this.sToolId="";
            this.setConnected(false);

            try {
                skServer.close();
            }

            catch(IOException e) {
                throw new CBIOException("CBIOException in LocalCBclient.cancelMe" + e.getMessage());
            }

            skServer = null;
            dsOut=null;
            dsIn=null;
        }

        assert(((caAns.getCompletion() == CBanswer.OK) && (!bConnected)) ||
               (caAns.getCompletion() != CBanswer.OK)):"LocalCBclient.cancelMe()";

        return caAns;
    } // cancelMe

    /**
     * Destroys the client object
     * @exception CBException if an error occurs when disconnecting
     */
    protected void finalize() throws Throwable {

        if(isConnected()) {

            try {
                cancelMe();
            }
            catch(Exception ex) {
                System.out.println("LocalCBclient.finalize: Closing " +
                                   getClientId() + " failed. Exception thrown:" + ex.toString());
                ex.printStackTrace();
            }
        } // if

        super.finalize();

    } // finalize

    /**
     * Tells frames to the server
     *
     * @param sFrames the frames
     * @return a CBanswer object containing the result and the completion
     * @exception CBException if an error occurs while processing this method
     * @see i5.cb.api.CBanswer
     */
    public CBanswer tell(String sFrames) throws CBException {
        assert bConnected && (sFrames != null):"LocalCBclient.tell(String)";

        return sendMessage("TELL", CButil.encodeString(sFrames));
    } // tell

    /**
     * Tells transactions to the server
     *
     * @param sTransactions consisting of frames possibly separated by {---}
     * @return a CBanswer object containing the result and the completion
     * @exception CBException if an error occurs while processing this method
     * @see i5.cb.api.CBanswer
     */
    // this method is introduce for solving some issues when telling a module source
    // that was constructed in several tell constructions; ticket #384
    public CBanswer tellTransactions(String sTransactions) throws CBException {
          CBanswer ans=null;
          if (sTransactions.contains("{---}")) {
             String[] transactions = sTransactions.split("\\{---\\}");
             CBanswer oldanswer = null;
             for (int i = 0; i < transactions.length; i++) {
               ans = tell(transactions[i]);
               ans.mergeCBanswer(oldanswer);
               oldanswer = ans;
             }
          } else {

              ans = tell(sTransactions);
          }
          return ans;
    } // tellTransactions



    /**
     * Untells frames to the server
     *
     * @param sFrames the frames
     * @return a CBanswer object containing the result and the completion
     * @exception CBException if an error occurs while processing this method
     * @see i5.cb.api.CBanswer
     */
    public CBanswer untell(String sFrames) throws CBException {
        assert bConnected && (sFrames != null):"LocalCBclient.untell(String)";

        return sendMessage("UNTELL", CButil.encodeString(sFrames));
    } // untell

    /**
     * Tells files containing frames to the server
     *
     * @param asFiles an array of filenames
     * @return a CBanswer object containing the result and the completion
     * @exception CBException if an error occurs while processing this method
     * @see i5.cb.api.CBanswer
     */
    public CBanswer tellModel(String[] asFiles) throws CBException {

       if (asFiles.length > 0 && new File(asFiles[0]).isFile())
          return tellModelLocal(asFiles);   // tell local file contents
       else
          return tellModelRemote(asFiles);  // let CBserver load the files 

    } // tellModel


    // implementation for tellModel where files are assumed to be on the computer of CBserver
    private CBanswer tellModelRemote(String[] asFiles) throws CBException {
        assert bConnected && (asFiles[0] != null):"LocalCBclient.tellModel(String[])";

        StringBuffer sbFiles=new StringBuffer(asFiles.length * 100);
        sbFiles.append('[');

        // Enkodiere jedes File einzeln, und haenge es an sbFiles an
        for(int i=0; i < asFiles.length; i++) {
            sbFiles.append(CButil.encodeString(asFiles[i]));
            if(i + 1 < asFiles.length)
                sbFiles.append(',');
        }

        sbFiles.append(']');

        return sendMessage("TELL_MODEL", sbFiles.toString());
    } // tellModelRemote



    // implementation for tellModel where files are assumed to be on the computer of the CBclient
    private CBanswer tellModelLocal(String[] asFiles) throws CBException {
        assert bConnected && (asFiles[0] != null):"LocalCBclient.tellModel(String[])";

        StringBuffer sbContent=new StringBuffer(asFiles.length * 1000);

        // build one big stringbuffer out of all file contents
        for(int i=0; i < asFiles.length; i++) {
            try {
               addFileContent(sbContent,asFiles[i]);
            } catch (IOException e) {
            }
        }
        return tellTransactions(sbContent.toString());
        //return sendMessage("TELL", CButil.encodeString(sbContent.toString()) );

    } // tellModelLocal


    // add the whole contents of the file path to StringBuffer sb
    private static void addFileContent(StringBuffer sb, String path) throws IOException {
      FileInputStream fis=new FileInputStream(new File(path));
      try {
        int c=fis.read();
        while(c >= 0) {
           sb.append((char) c);
           c=fis.read();
        }
      } finally {
        fis.close();
      }
    }

   



    /**
     * Untells specified frames and tells new frames to the server in one transaction
     *
     * @param sUntellFrames frames to untell
     * @param sTellFrames frames to tell
     * @exception CBException if an error occurs while processing this method
     * @see i5.cb.api.CBanswer
     * @see i5.cb.api.LocalCBclient#tell(String)
     * @see i5.cb.api.LocalCBclient#untell(String)
     */
    public CBanswer retell(String sUntellFrames, String sTellFrames) throws CBException {
        assert bConnected && (sUntellFrames != null) && (sTellFrames != null)
        :
            "LocalCBclient.retell(String,String)";

        StringBuffer sbFrames=
            new StringBuffer(sUntellFrames.length() + sTellFrames.length() + 100);

        sbFrames.append('[');
        sbFrames.append(CButil.encodeString(sUntellFrames));
        sbFrames.append(',');
        sbFrames.append(CButil.encodeString(sTellFrames));
        sbFrames.append(']');

        return sendMessage("RETELL", sbFrames.toString());
    } // retell

    /**
     * Sends a query to the ConceptBase server
     *
     * @param sQuery the query
     * @param sQueryFormat the format of the query (FRAMES or OBJNAMES)
     * @param sAnswerRep the format of the answer (e.g. FRAME, LABEL,...)
     * @param sRollbackTime Rollback Time (e.g.\ "Now")
     * @return a CBanswer object containing the result and the completion
     * @exception CBException if an error occurs while processing this method
     * @see i5.cb.api.CBanswer
     */
    public CBanswer ask(String sQuery, String sQueryFormat, String sAnswerRep,
                        String sRollbackTime) throws CBException {
        assert bConnected:"LocalCBclient.ask(): not connected.";
        assert(sQuery != null) && (sAnswerRep != null) && (sRollbackTime != null):
            "LocalCBclient.ask";

        return sendMessage("ASK", sQueryFormat + "," +
                           CButil.encodeString(sQuery) + "," + CButil.encodeString(sAnswerRep) +
                           "," + CButil.encodeString(sRollbackTime));
    } // ask

    /**
     * Sends a query in frame format to the server and returns the answer of the ConceptBase server
     *
     * @param sQuery the query
     * @param sAnswerRep the format of the answer (e.g. FRAME, LABEL,...)
     * @param sRollbackTime Rollback Time (e.g.\ "Now")
     * @return a CBanswer object containing the result and the completion
     * @exception CBException if an error occurs while processing this method
     * @see i5.cb.api.CBanswer
     */
    public CBanswer askFrames(String sQuery, String sAnswerRep, String sRollbackTime) throws
        CBException {
        assert bConnected && (sQuery != null) && (sAnswerRep != null) && (sRollbackTime != null):
            "LocalCBclient.askFrames(String,String,String,String)";

        return sendMessage("ASK", "FRAMES," + CButil.encodeString(sQuery) + "," +
                           CButil.encodeString(sAnswerRep) + "," +
                           CButil.encodeString(sRollbackTime));
    } // askFrames

    /**
     *
     * Sends a query (as objectname) to the server and returns the answer of the server
     *
     * @param sQuery the query
     * @param sAnswerRep the format of the answer (e.g. FRAME, LABEL,...)
     * @param sRollbackTime Rollback Time (e.g.\ "Now")
     * @return a CBanswer object containing the result and the completion
     * @exception CBException if an error occurs while processing this method
     * @see i5.cb.api.CBanswer
     */
    public CBanswer askObjNames(String sQuery, String sAnswerRep, String sRollbackTime) throws
        CBException {
        Contract.requires("LocalCBclient.askObjNames(String,String,String,String)",
                          bConnected && (sQuery != null) && (sAnswerRep != null) && (sRollbackTime != null));

        return sendMessage("ASK", "OBJNAMES," + CButil.encodeString(sQuery) + "," +
                           CButil.encodeString(sAnswerRep) + "," +
                           CButil.encodeString(sRollbackTime));
    } // askObjNames

    /**
     * Tells the specified frames temporarily to the ConceptBase Server,
     * and evaluate the query on the temporarily object base.
     *
     * @param sFrames the frames
     * @param sQuery the query
     * @param sQueryFormat the format of the query (FRAMES or OBJNAMES)
     * @param sAnswerRep the format of the answer (e.g. FRAME, LABEL,...)
     * @param sRollbackTime Rollback Time (e.g.\ "Now")
     * @return a CBanswer object containing the result and the completion
     * @exception CBException if an error occurs while processing this method
     * @see i5.cb.api.CBanswer
     */
    public CBanswer hypoAsk(String sFrames, String sQuery, String sQueryFormat,
                            String sAnswerRep, String sRollbackTime) throws CBException {
        assert bConnected && (sFrames != null) && (sQuery != null) && (sQueryFormat != null) &&
            (sAnswerRep != null) && (sRollbackTime != null):
            "LocalCBclient.hypoAsk(String,String,String,String,String)";

        return sendMessage("HYPO_ASK", CButil.encodeString(sFrames) + "," + sQueryFormat +
                           "," + CButil.encodeString(sQuery) + "," + CButil.encodeString(sAnswerRep) +
                           "," + CButil.encodeString(sRollbackTime));
    } // hypoAsk

    /**
     * Calls the builtin query get_object with the given parameter
     *
     * @param sObjname the parameter for the query
     * @return a string containing the frame for the object, or "error" otherwise
     * @exception CBException if an error occurs while processing this method
     */
    public String getObject(String sObjname) throws CBException {
        assert(sObjname != null) && bConnected:"LocalCBclient.getObject(String)";

        CBanswer caAns=ask("get_object[" + sObjname + "/objname]", "OBJNAMES", "FRAME", "Now");
        String sRet;

        if(caAns.getCompletion() == CBanswer.OK) {
            sRet=caAns.getResult();
        }
        else {
            sRet="error";
        }

        return sRet;
    } // getObject

    /**
     * Calls the builtin query find_instances with the given parameter
     *
     * @param sObjname the parameter for the query
     * @return a string containing a comma-separated list of object names, or "error" otherwise
     * @exception CBException if an error occurs while processing this method
     */
    public String findInstances(String sObjname) throws CBException {
        assert(sObjname != null) && bConnected:"LocalCBclient.getObject(String)";

        CBanswer caAns=ask("find_instances[" + sObjname + "/class]", "OBJNAMES", "LABEL", "Now");

        String sRet;

        if(caAns.getCompletion() == CBanswer.OK) {
            sRet=caAns.getResult();
        }
        else {
            sRet="error";
        }

        return sRet;
    } // findInstances

    /**
     * Stops the ConceptBase server
     *
     * @return a CBanswer object containing the result and the completion
     * @exception CBException if an error occurs while processing this method
     */
    public CBanswer stopServer() throws CBException {
        assert bConnected:"LocalCBclient.stopServer()";

        CBanswer result=sendMessage("STOP_SERVER", "");

        if(result.getCompletion() == CBanswer.OK) {
            this.sHost="";
            this.iPort=0;
            this.sUser="";
            this.sTool="";
            this.sServerId="";
            this.sToolId="";
            this.setConnected(false);

            try {
                skServer.close();
            }

            catch(IOException e) {
                throw new CBIOException("CBIOException in LocalCBclient.cancelMe" + e.getMessage());
            }

            dsOut=null;
            dsIn=null;
        }

        return result;
    } // stopServer

    /**
     * Performs an LPI-Call at the server. With LPI (Logic Programming Interface)
     * one can call ProLog predicates defined in an LPI-Module.
     * @param lpicall the predicate to be called
     * @return the result of the method
     * @exception CBException if an error occurs while processing this method
     */
    public CBanswer LPIcall(String lpicall) throws CBException {
        assert bConnected && (lpicall != null):"LocalCBclient.LPIcall()";

        return sendMessage("LPI_CALL", CButil.encodeString(lpicall));
    } // LPIcall

    /**
     * Gets a message from the server
     *
     * @param sType the type of the message to be retrieved
     * @return a CBanswer object containing the result and the completion
     * @exception CBException if an error occurs while processing this method
     */
    public CBanswer nextMessage(String sType) throws CBException {
        assert bConnected && (sType != null):"LocalCBclient.nextMessage()";

        return sendMessage("NEXT_MESSAGE", sType);
    } // nextMessage

    /**
     * Gets the error messages from the server for the previous
     * method.
     *
     * @return a string containing all error messages
     * @exception CBException if an error occurs while processing this method
     */
    public synchronized String getErrorMessages() throws CBException {
        assert bConnected:"LocalCBclient.getErrorMessages()";

        CBanswer caAns=nextMessage("ERROR_REPORT");
        StringBuffer sbErrMsg=new StringBuffer(200);

        try {
            while(caAns.getResult().compareTo("empty_queue") != 0) {

                CBterm cbtAns=new CBterm(caAns.getResult());

                if(cbtAns.getFunctor().equals("ipcmessage") && cbtAns.getArgs().length == 4) {
                    sbErrMsg.append(CButil.decodeString(cbtAns.getArg(3).getArg(0).toString()));
                }
                else {
                    break;
                }
                // Get next message
                caAns=nextMessage("ERROR_REPORT");
            } // while
        } // try
        catch(Exception e) {
            throw new CBMessageException(
                "CBMessageException in LocalCBclient.getErrorMessages(String):" + e.getMessage());
        }

        assert(sbErrMsg.toString() != null):"LocalCBclient.getErrorMessages()";

        return sbErrMsg.toString();
    } // getErrorMessages

    /**
     * Checks, if the client is connected to a server
     *
     * @return true if connected, false otherwise
     */
    public synchronized boolean isConnected() {
        return bConnected;
    }

    /**
     * Return the hostname of the current server
     **/
    public String getHostName() {
        return sHost;
    }

    /**
     * Return the port number of the current server
     **/
    public int getPort() {
        return iPort;
    }

    /**
     * Return the user name of the currently used in the client
     **/
    public String getUserName() {
        return sUser;
    }

    /**
     * Return the tool name of the client
     **/
    public String getToolName() {
        return sTool;
    }

    /**
     * Return the ID of the server. This ID is also used in the CBanswer
     * objects returned by the methods tell, untell, etc.
     **/
    public String getServerId() {
        return sServerId;
    }

    /**
     * Return the ID of this client. This ID has been assigned by the
     * server to the client when the client has connected to the server.
     * It can be used to send a message to another client.
     **/
    public String getClientId() {
        return sToolId;
    }

    /**
     * Set the timeout time for the connection
     *
     * @param iMilliSecs Timeout in milli seconds
     * @return true on success, false otherwise
     **/
    public boolean setTimeOut(int iMilliSecs) {
        try {
            skServer.setSoTimeout(iMilliSecs);
        }
        catch(SocketException e3) {
            return false;
        }
        iTimeOut=iMilliSecs;
        return true;
    } // setTimeOut

    /**
     * Get the timeout time for the connection
     * @return the timeout time in milliseconds
     **/
    public int getTimeOut() {
        return iTimeOut;
    }

    /**
     * Set the module context of the current client.
     * @param s the new module
     * @return CBanswer object with completion CBanswer.ok if the call was successful
     * @exception CBException if an error occurs while processing this method
     **/
    public CBanswer setModule(String s) throws CBException {
        String sq = quoteModuleNames(s);
        CBanswer ans=sendMessage("SET_MODULE_CONTEXT", CButil.encodeString(sq));
        return ans;
    }

    // dirty trick to deal with issue #34 (module names starting with digits)
    // fool Prolog to believe that the module path is a legal term when using the '-' operator.
    // Example 'oHome'-'123Mod' instead oHome-123Mod
    // Only inserts the quotes when s contains a substring -D or /D where D is a digit
    public static String quoteModuleNames(String s) {
        if (s.matches("(.*)-[0-9](.*)")) {   
           return "'" + s.replaceAll("-","'-'") + "'";
        } else if (s.matches("(.*)/[0-9](.*)")) {
           return "'" + s.replaceAll("/","'/'") + "'";
        } else {
           return s;
        }
    }

    /**
     * Get the current module context of the client.
     * @return the module
     **/
    public String getModule() {
        try {
            CBanswer ans=sendMessage("GET_MODULE_CONTEXT", "");
            return ans.getResult();
        }
        catch(Exception e) {
            return null;
        }
    }


    /**
     * Get the current module context of the client.
     * @return the module path as CBanser with String like "System-oHome-subModule"
     **/
    public CBanswer getModulePath() {
        try {
            CBanswer ans=sendMessage("GET_MODULE_PATH", "");
            return ans;
        }
        catch(Exception e) {
            return null;
        }
    }


    /**
     * list the source of the given module
     * @return the module source as string, null if an error occurs
     **/
    public String listModule(String sModule) {
        try {
            CBanswer ans=ask("listModule[" + sModule + "/module]", "OBJNAMES", "FRAME", "Now");
            return ans.getResult();
        }
        catch(Exception e) {
            return null;
        }
    }

    /**
     * purge the contents of the current module; use with great care because it delete the whole
     * module content
     * @return "yes" if successful, "no" otherwise
     **/
    public String purgeCurrentModuleContent() {
        try {
            CBanswer ans=ask("purgeModule", "OBJNAMES", "FRAME", "Now");
            return ans.getResult();
        }
        catch(Exception e) {
            return "no";
        }
    }


    /**
     * Establish a request for notification messages of the specified type.
     *
     * @param sAbout the type of the notification request, e.g. view(MyView)
     * @return a CBanswer object with completion OK, if the request is accepted and
     * an initial value as result (depends on the the type of the request)
     * @exception CBException if an error occurs when proccessing this request
     **/
    public CBanswer notificationRequest(String sAbout) throws CBException {
        return notificationRequest(sAbout, getClientId());
    }

    /**
     * Establish a request for notification messages of the specified type for a given tool.
     *
     * @param sAbout the type of the notification request, e.g. view(MyView)
     * @param sTool the tool identifier (returned by getClientId()) of the tool
     *   which should receive the messages
     * @return a CBanswer object with completion OK, if the request is accepted and
     *   an initial value as result (depends on the the type of the request)
     * @exception CBException if an error occurs when proccessing this request
     * @see i5.cb.api.CBclient#getClientId()
     **/
    public CBanswer notificationRequest(String sAbout, String sTool) throws CBException {
        return sendMessage("NOTIFICATION_REQUEST",
                           CButil.encodeString(sAbout) + "," + CButil.encodeString(sTool));
    }

    /**
     * Gets a notification message from the server
     *
     * @param iTimeOut the time to wait for a message in milli seconds
     * @return a CBanswer object with the notification message, or null
     * if no message was available.
     * @exception CBException if an error occurs while reading the message
     **/
    public CBanswer getNotificationMessage(int iTimeOut) throws CBException {
        int iOldTimeOut=getTimeOut();
        setTimeOut(iTimeOut);

        CBanswer result=readAnswer();

        setTimeOut(iOldTimeOut);

        return result;
    } // getNotificationMessage


    /* ================== Protected section ================== */

    /**
     * Sends a message to the ConceptBase Server
     *
     * @param sMethod the method
     * @param sData the data to be sent to the server
     * @return a CBanswer object containing the result and the completion
     * @exception CBException if an error occurs while processing this method
     * @see i5.cb.api.CBanswer
     */
    protected synchronized CBanswer sendMessage(String sMethod, String sData) throws CBException {
        assert(sMethod != null) && (sData != null) &&
            ((bConnected) || (sMethod.compareTo("ENROLL_ME") == 0))
        :"LocalCBclient.sendMessage";

        try {
            String sMsg="ipcmessage(" + CButil.encodeString(sToolId) +
                        "," + CButil.encodeString(sServerId) +
                        "," + sMethod + ",[" + sData + "]).\n";
            // send length of message (requires ConceptBase server 7.0 or later)
            int len=sMsg.length();
            dsOut.writeByte('X');
            dsOut.writeByte((len / (256 * 256 * 256)) % 256);
            dsOut.writeByte((len / (256 * 256)) % 256);
            dsOut.writeByte((len / 256) % 256);
            dsOut.writeByte(len % 256);

            dsOut.writeBytes(sMsg);
            dsOut.flush();
        }

        // TODO: Ueberpruefe ob diese Exceptions wirklich geworfen werden!!!
        /* Exception in readLine oder read */
        catch(InterruptedIOException e1) {
            throw new CBTimeOutException("CBTimeOutException in LocalCBclient.sendMessage(String)" +
                                         e1.getMessage());
        }
        /* Andere IOException waehrend read */
        catch(IOException e2) {
            try {
                skServer.close();
            }
            catch(IOException e3) {
            }

            // Reset Values to default
            this.sHost="";
            this.iPort=0;
            this.sUser="";
            this.sTool="";
            this.sServerId="";
            this.sToolId="";
            this.setConnected(false);

            // Wirf exception, damit der Client mitbekommt, dass die Verbindung gecancelt wurde
            throw new CBConnectionBrokenException(
                "CBConnectionBrokenException in LocalCBclient.sendMessages(String):" +
                e2.getMessage());
        } // catch IOException

        // readAnswer in Extra-Methode ausgelagert, da es auch fuer
        // getNotificationMessage gebraucht wird.
        CBanswer result=readAnswer();

        return result;
    } // sendMessage

    protected synchronized CBanswer readAnswer() throws CBException {
        String sAns;
        String sLen = "dummy";

        try {
            // Deprecated, aber geht leider nicht anders

            sLen=dsIn.readLine();
            int iLen=Integer.parseInt(sLen);
            // message length - 1 (!)
            ++iLen;
            // this is the message length
            // "+1" fuer abschliessendes line feed? CR

            byte abtRead[]=new byte[iLen];
            int iRead=0;

            while(iRead < iLen) {
                int iJustRead=dsIn.read(abtRead, iRead, iLen - iRead);
                iRead+=iJustRead;
            }
            sAns=new String(abtRead,"ISO-8859-1");
        } // try

        /* Es werden nur IOException geworfen !!!!
         * CBMessageException wenn die Laenge der Antwort nicht gelesen werden konnte,
         *   die NumberException tritt im Constructor von Integer auf.
         * CBTimeOutException wird geworfen wenn ein TimeOut auftritt,
         *   d.h. die Antwort des Servers nicht einer bestimmten Zeit gekommen ist.
         *   Dies wird signalisiert durch InterruptedIOException in der readLine-Methode.
         *   Allerdings wird InterruptedIOException auch beim Verbindungsabbruch
         *   (z.B. Server-Absturz) geworfen. Dann sollte eine CBConnectionBrokenException
         *   geworfen werden.
         *   TODO: Fallunterscheidung dafuer und RESET bei ConnectionBroken
         **/

        /* Exception in Integer Constructor */
        catch(NumberFormatException e) {
            System.err.println("LocalCBclient.java: Could not read message length from string " + sLen);
            throw new CBConnectionBrokenException(
                "NumberFormatException in LocalCBclient.readAnswer(): " + e.getMessage());
        }
        /* Exception in readLine oder read */
        catch(InterruptedIOException e1) {
            throw new CBTimeOutException(
                "InterruptedIOException in LocalCBclient.readAnswer(): " + e1.getMessage());
        }
        /* Andere IOException waehrend read */
        catch(IOException e2) {
            try {
                skServer.close();
            }
            catch(IOException e3) {
            }

            // Reset Values to default
            this.sHost="";
            this.iPort=0;
            this.sUser="";
            this.sTool="";
            this.sServerId="";
            this.sToolId="";
            this.setConnected(false);

            // Werfe Exception, damit der Client mitbekommt, dass die Verbindung gecancelt wurde
            throw new CBConnectionBrokenException(
                "IOException in LocalCBclient.readAnswer(): " + e2.getMessage());
        } // catch

        return new CBanswer(sAns);
    } // readAnswer

    /* ================== Protected members ==================== */

    protected Socket skServer;

    protected DataOutputStream dsOut;
    protected DataInputStream dsIn;

    protected String sHost;
    protected int iPort;
    protected String sUser;
    protected String sTool;
    protected String sServerId;
    protected String sToolId;
    protected boolean bConnected;
    protected int iTimeOut;

    public void setConnected(boolean connected) {
        bConnected=connected;
    }



    /* ----- Simplified interface with String results */

    public String connect( String sHost, int iPort, String sTool, String sUser ) {
       try { 
          if (!this.isConnected()) {
              this.enrollMe(sHost, iPort, sTool, sUser);
          }
          if (this.isConnected())
            return "yes";
          else
            return "no";
       } catch (Exception e) {
         return "no";
       }
    }

    public String connect() {
       if (this.isConnected()) 
         return "yes";
       i5.cb.CBConfiguration.openConfig();  // read the configuration file .CBjavaInterface
       String pubCBserver = i5.cb.CBConfiguration.getPublicCBserverHost();
       // use public CBserver if not null/none
       if (pubCBserver != null && !pubCBserver.equals("none")) {
          int iPort; 
          try {
            iPort = Integer.parseInt(i5.cb.CBConfiguration.getPublicCBserverPort());
          } catch(Exception e) { iPort = 4001; }
          return this.connect(pubCBserver,iPort,"LocalCBClient",null);
       // else try to startup a local CBserver
       } else if (this.cbserver().equals("yes")) {
          return this.connect("localhost",4001,"LocalCBClient",null);
       } else {
          return "no";
       }
    }


    public String disconnect() {
       try { 
          if (this.isConnected()) {
              this.cancelMe();
          }
          if (!this.isConnected())
            return "yes";
          else
            return "no";
       } catch (Exception e) {
         return "no";
       }
    }

    public String pwd() {
       try { 
          CBanswer ans=this.getModulePath();
          if (ans.getCompletion() == CBanswer.OK )
             return ans.getResult();
          else
             return "no";
       } catch (Exception e) {
         return "no";
       }
    }

    public String cd(String newModule) {
       try { 
         CBanswer ans=this.setModule(newModule);
         if (ans.getCompletion() == CBanswer.OK ) {
           return "yes";
         } else {
           return "no";
         }
       } catch (Exception e) {
         return "no";
       }
    }

    // mkdir is just a shortcut for a tell
    public String mkdir(String newModule) {
       return this.tells(newModule + " in Module end");
    }


    public String untells(String sFrames) {
       try { 
         CBanswer ans=this.untell(sFrames);
         if (ans.getCompletion() == CBanswer.OK) {
           return "yes";
         } else {
           return this.getErrorMessages().trim();
         }
       } catch (Exception e) {
         return "no";
       }
    }

    public String tells(String sFrames) {
       try { 
         CBanswer ans=this.tellTransactions(sFrames);
         if (ans.getCompletion() == CBanswer.OK) {
           return "yes";
         } else {
           return this.getErrorMessages().trim();
         }
       } catch (Exception e) {
         return "no";
       }
    }



    public String asks(String sQuery, String sFormat) {
       try { 
         CBanswer ans=this.ask(sQuery,"OBJNAMES",sFormat,"Now");
         if (ans.getCompletion() == CBanswer.OK) {
           return ans.getResult();
         } else {
           return "no";
         }
       } catch (Exception e) {
         return "no";
       }
    }


    public String asks(String sQuery) {
       return this.asks(sQuery,"default");
    }

    // try to delete all objects from the current module
    public String clearall() {
       return this.purgeCurrentModuleContent();
    }



    // to start a CBserver on localhost with portnumber 4001
    public String cbserver() {
       if (this.isConnected()) 
         return "yes";
       boolean started = i5.cb.api.CBclient.startLocalCBserver("4001");
       boolean enrolled = false;
       if (started) {
         long waittime = 200L;  // millisec
         for (int i=1; i<=15; i++) {
           enrolled = testEnroll();
           // System.out.println("Attempt to connect "+i);
           if (enrolled) {
             break;
           }
           try {
             Thread.sleep(waittime);
           } catch (Exception e) {}
           waittime =+ waittime;
         }
       }
       if (enrolled) {
          return "yes";
       } else {
          return "no";
       }
    }


    // return the clientid under which this client is registered to a CBserver
    public String clientid() {
       return this.getClientId();
    }


    private boolean testEnroll() {
        try {
          this.enrollMe("localhost", 4001, "LocalCBclient", null);
          return true;
        } catch (Exception e) {
          return false;
        }
    }



    // main

} // class LocalCBclient
