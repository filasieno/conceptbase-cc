/*
The ConceptBase.cc Copyright

Derived from ConceptBase.cc, originally created by the ConceptBase Team under a FreeBSD-style license.

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
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITYs, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the authors
and should not be interpreted as representing official policies, either expressed or implied,
of the ConceptBase Team.


The ConceptBase Team is represented by

Manfred Jeusfeld, University of Skovde, 54128 Skovde, Sweden


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
package i5.cb;

import i5.cb.CBException;
import i5.cb.api.*;

import java.io.*;
import java.util.ArrayList;
import java.util.regex.*;

/**
 * This class offers a shell environment for ConceptBase. All commands which the CBclient supports are
 * also available in the shell. Commands are read from stdin, meaning one can either start the CBShell and type in commands
 * or, for test purposes, pipe a textfile containing commands into it.
 * The command result will check for the given completion and answer, and write error/result into logfiles error.log, stat.log respectively.
 * This is useful in cases where you pipe series of commands from a textfile into the CBShell, the answer of the server is also accessible using the
 * command showAnswer.
 * @author Achim Schlosser
 */
public class CBShell {

    private CBclient cbClient=null;
    private CBanswer currentAns=null;
    private BufferedWriter output=null;
    private BufferedWriter stats=null;
    private String[] currentCommand=null;
    private String[] previousCommand=null;
    private String command=null;
    private boolean isConnected=false;
    private boolean bServerStarted=false;
    private int commandCounter=1;
    ServerThread serverThread;
    private static Pattern varPattern=Pattern.compile("\\$[A-Za-z_]+");
    private long commandExecutionTime;
    private String scriptFile=null;
    private boolean bTraceMode=false;
    private boolean bDisplayPrompt=true;
    private boolean bShowAnswer=false;
    private boolean bcommandVerbose = false;
    private boolean bReplaceQuote=false;
    private boolean bStartInteractiveServer=false;
    private boolean bHasParams=false;  /// CBShell has command line parameters
    private String[] paramList = null;

    private static char defaultArgDelimiter='"';  // default argument delimiter
    private static char argDelimiter;             // for enclosing arguments that have blanks; either " or '

    /**
     * Starts a new shell, without Server.
     */
    public static void main(String[] args) {

        argDelimiter = defaultArgDelimiter; // initialize
        CBShell cbs=new CBShell();
        int pStart = -1;
        boolean showAnswerDisabled = false;

        if (args.length>0) {
           for(int i=0;i<args.length;i++) {
              if (args[i].equals("-l")) {
                  try {
                      cbs.output=new BufferedWriter(new FileWriter("error.log", false));
                      cbs.stats=new BufferedWriter(new FileWriter("stat.log", false));
                  }
                  catch(IOException ex) {
                      System.out.println("Unable to open logfiles");
                  }
                  if (args.length>1)
                      cbs.scriptFile=args[1];
              }
              else if (args[i].equals("-f")) {
                  i++;
                  if (i<args.length)
                      cbs.scriptFile=args[i];
                  else {
                      System.out.println("Missing scriptFile for option '-f'");
                      System.exit(1);
                  }
              }
              else if (args[i].equals("-t")) {
                  cbs.bTraceMode=true;
              }
              else if (args[i].equals("-p")) {
                  cbs.bDisplayPrompt=false;    // controls whether to show the command prompt in interactive mode
              }
              else if (args[i].equals("-a")) {
                  cbs.bShowAnswer=false;    // controls whether to show answer after each command
                  showAnswerDisabled = true;
              }
              else if (args[i].equals("-v")) {
                  cbs.bShowAnswer=true;    // controls whether to show answer after each command
                  showAnswerDisabled = false;
                  cbs.bcommandVerbose = true;
              }
              else if (args[i].equals("-q")) {
                  cbs.bReplaceQuote=true;
              }
              else if (args[i].equals("-i")) {
                  cbs.bStartInteractiveServer=true;
              }
              else if (args[i].equals("-v") || args[i].equals("-version")) {
                  System.out.println("This is CBShell, the command line interface to ConceptBase.cc");
                  System.out.println("Copyright 1987-2024 by The ConceptBase Team. All rights reserved.");
                  System.out.println("Original software by Achim Schlosser and others.");
                  System.out.println("This is free software. See http://conceptbase.cc for details.");
                  System.out.println("No warranty, not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.");
                  System.exit(0);
              }
              else if (cbs.scriptFile == null) {
                  // interpret the argument as scriptfile 
                  cbs.scriptFile=args[i];
              } else if (!cbs.bHasParams) {  // collect the command line parameters in cbs.paramList
                  cbs.paramList = new String[args.length - i];
                  cbs.paramList[0] = args[i];
                  cbs.bHasParams = true;
                  pStart = i;
              } else if (cbs.bHasParams) {
                  cbs.paramList[i-pStart] = correctlyQuoted(args[i],cbs.bReplaceQuote);
              }
           }
        }

        // read the configuration file 
        i5.cb.CBConfiguration.openConfig();


        // enable bShowAnswer in interactive mode unless explicitly disabled
        if (cbs.bDisplayPrompt && cbs.scriptFile == null && !showAnswerDisabled) 
            cbs.bShowAnswer = true;  

        BufferedReader inputStream=null;
        if (cbs.scriptFile!=null) {
            try {
                inputStream=new BufferedReader(new FileReader(cbs.scriptFile));
            }
            catch(FileNotFoundException fnfex) {
                System.out.println("Script file " + cbs.scriptFile + " not found\n" + fnfex.getMessage());
                System.exit(0);
            }
        }
        else {
            // Create a single shared BufferedReader for keyboard input
            inputStream=new BufferedReader(new InputStreamReader(System.in));
            if (cbs.bDisplayPrompt) 
               System.out.println("This is CBShell, the command line interface to ConceptBase.cc");
        }
        while(true) {
            argDelimiter = defaultArgDelimiter; // may change from command to command
            if (cbs.scriptFile==null) {
                String prompt="[offline]>";
                try {
                    if (cbs.cbClient != null && cbs.cbClient.isConnected()) {
                        prompt="[" + cbs.cbClient.getHostName() + ":" +
                               cbs.cbClient.getPort() + "]>";
                    }
                }
                catch(java.rmi.RemoteException rmex) {}

                if (cbs.bDisplayPrompt) 
                   System.out.print(prompt);
            }

            try {
                StringBuffer input=null;
                String line=null;
                do {
                    line=inputStream.readLine();
                    if (line!=null) {
                        line = replaceParams(line,cbs);
                        input=new StringBuffer(line);
                    }
                } while(isCommentLine(input));
                int prevLen=0;
                setArgDelimiterOnTheFly(line);
                while(containsUnclosedQuote(input,prevLen)) {
                    line=inputStream.readLine();
                    // If at EOF, readLine returns null
                    if (line==null) {
                        System.out.println("Unmatched \"");
                        cbs.exitShell(0);
                    } else {
                        line = replaceParams(line,cbs);
                    }
                    prevLen=input.length();
                    input.append("\n");
                    input.append(line);
                }
                // If at EOF, readLine returns null
                if (input==null)
                    cbs.exitShell(0);

                cbs.previousCommand=cbs.currentCommand;
                cbs.currentCommand=CBShell.getCommandAndArgs(input);
                if (cbs.currentCommand.length>0) {
                    cbs.command=cbs.currentCommand[0];
                    cbs.processCommand();
                }
            }
            catch(EOFException ex) {
                cbs.exitShell(0);
            }
            catch(Exception e) {
                System.out.println("Exception: " + e.getMessage() + e.getClass().getName());
                e.printStackTrace();
 //               Thread.dumpStack();
                cbs.exitShell(0);
            }
        }
    }

    private void writeError(String str) {
        if (output!=null) {
            try {
                output.write(str);
                output.flush();
            }
            catch(IOException ioex) {
                System.out.println("Exception while writing error.log:" + ioex.getMessage());
            }
        }
    }

    private void writeStat(String command, String argument, String result, long time) {
        if (stats!=null) {
            commandCounter++;
            try {
                stats.write(Integer.toString(commandCounter) + ";" +
                            command + ";" + argument + ";" + result + ";" +
                            String.valueOf(time) + "\n");
                stats.flush();
            }
            catch(IOException ioex) {
                System.out.println("Exception while writing stat.log:" + ioex.getMessage());
            }
        }
    }


    /**
    If the line starts with tell then we sense the argument delimiter from
    the character following the tell substring. Allows to mix tell 'xxx' and
    tell "xxx" in a CBShell script
    */

    private static void setArgDelimiterOnTheFly(String aLine) {
       if (aLine == null)
         return;
       String line = aLine.trim();

       // proceed to the first blank after the command label
       int s;
       for (s = 0; s < line.length(); s++) {
         if (line.charAt(s) == ' ')
            break;
       }

       // set the argDelimiter to the first quote character after the command name (if existent)
       for (int i = s; i < line.length(); i++) {
          if (allowedArgDelimiter(line.charAt(i))) 
             argDelimiter = line.charAt(i);
          if (line.charAt(i) != ' ') 
             break;
       }
    }


   /**
   Returns true if ch is an allowed argument delimiter for CBShell commands
   */

    private static boolean allowedArgDelimiter(char ch) {
       return (ch == '\'' || ch == '"');
    }


    /**
    Replaces in text the occurences of shell variables $0 ... $9 by
    the actual command line parameters of the CBshell call. 
    The shell variable $0 is replaced by the name of the script file.
    At most 9 user-defined command line parameters are supported.
    */


    private static String replaceParams(String text, CBShell cbs) {
      StringBuffer result = new StringBuffer();
      if (isCommentLine(text)) {
        return text;
      } else {
        int i = 0;
        while (i < text.length()) {
          if ((text.charAt(i)=='$') && (i+1 < text.length()) 
                                    && (text.charAt(i+1) >= '0')
                                    && (text.charAt(i+1) <= '9')) {
            int param = (int)text.charAt(i+1) - (int)'0';
            appendParam(result,param,cbs);
            i = i + 2;
          } else {
            result.append(text.charAt(i));
            i++;
          } // if
        } // while
      } // if cbs.paramList


      return result.toString();
    }

   /** append the value of parameter $p to the result string;
       $0 replaced by cbs.scriptFile 
       $1 replaced by cbs.paramList[0] 
       ...
       $9 replaced by cbs.paramList[8] 
   */

    private static void appendParam(StringBuffer result, int p, CBShell cbs) {
      if (p==0) {
        result.append(cbs.scriptFile);   // $0 is replaced by the name of the scriptfile
      } else if (p > 0 && cbs.paramList != null && p <= cbs.paramList.length) {
        result.append(cbs.paramList[p-1]); // $1..$9 replaced by the provided shell parameter
      } else if (p > 0) {
        System.err.println("CBShell: Undefined parameter $" + p);
        System.err.println("Exiting CBShell ...");
        cbs.exitShell(1);
      }
    }

    // get the value of the environment variable CB_HOME
    private static String getCbHome() {
      String sCB_HOME = "";
      try {
          if (System.getProperty("os.name").indexOf("Windows") >= 0)
            sCB_HOME = System.getProperty("CB_HOME", "C:\\conceptbase");
          else
            sCB_HOME = System.getProperty("CB_HOME", "$HOME/conceptbase");
      } catch (Exception ex) {
          sCB_HOME = "";
      }
      return sCB_HOME;
    }

    // start a CBserver with the provided command and port number
    public void startconnectCbServer(String[] cmdarray, String port) {
      try {
          //starting CBserver
          if (scriptFile==null && bDisplayPrompt)
              System.out.println("Starting ConceptBase Server, please wait");
          Process p=Runtime.getRuntime().exec(cmdarray);
          //Connect to both input and error stream to flush them
          BufferedReader in=new BufferedReader(new InputStreamReader(p.getInputStream()));
          BufferedReader err=new BufferedReader(new InputStreamReader(p.getErrorStream()));
          serverThread=new ServerThread(in, err, Integer.parseInt(port));
          serverThread.start();
          //wait until server start is completed
          long curTime=System.currentTimeMillis();
          while(!serverThread.isReady() &&
                (System.currentTimeMillis() - curTime) < 100000) {
              if (scriptFile==null)
                  System.err.print(".");
              Thread.sleep(300);
              Thread.yield();
          }
          // Wait additionally 0.2 second to make sure that server is up and running
          Thread.sleep(200);
          //connect to server
          cbClient=new CBclient("localhost", Integer.parseInt(port), "CBshell", null);
          cbClient.setTimeOut(36000000); // ten hours timeout
          isConnected=true;
          bServerStarted=true;
          if (scriptFile==null && bDisplayPrompt)
              System.out.println("Successfully started and connected to CBserver");
       }
      catch(Exception e) {
          System.out.println("Unable to start ConceptBase Server");
          System.out.println(e.getMessage());
      }
    }


   /** if bQuote is true then any occurrence of a single quote in param is
       replaced by \"
   */

    private static String correctlyQuoted(String param, boolean bQuote) {
      if (!bQuote) {
        return param;
      } else {
        StringBuffer result = new StringBuffer();
        for (int i = 0; i < param.length(); i++) {
          if (param.charAt(i)=='\'') 
            result.append("\\\"");
          else
            result.append(param.charAt(i));
        }
        return result.toString();
      }
    }


    private static boolean containsUnclosedQuote(StringBuffer input,int prevLen) {
        if (input==null)
            return false;
        boolean unclosedQuote=false;
        if (prevLen!=0)
            unclosedQuote=true;
        for(int i=prevLen;i<input.length();i++) {
            if (argDelimiter == '"' && input.charAt(i)=='\\') 
                i++; // skip the " when escaped like in \"
            else if (input.charAt(i) == argDelimiter)
                unclosedQuote=!unclosedQuote;
        }
        return unclosedQuote;
    }

    private static boolean isCommentLine(StringBuffer line) {
        if (line!=null) {
            String str=line.toString();
            if (str.trim().length()>0 && str.trim().charAt(0)=='#')
                return true;
        }
        return false;
    }

    private static boolean isCommentLine(String str) {
        if (str.length()!=0) {
            if (str.trim().length()>0 && str.trim().charAt(0)=='#')
                return true;
        }
        return false;
    }

    /**
     * Processes the current command
     */
    private void processCommand() {
        long currTime=System.currentTimeMillis();

        if (bTraceMode && !command.equals("result")) {
            System.out.print("Execute command " + command);
            for(int i=1;i<currentCommand.length;i++)
                System.out.print(" " + currentCommand[i]);
            System.out.println("? (Y/n)");
            BufferedReader inputReader=new BufferedReader(new InputStreamReader(System.in));
            try {
                String input=inputReader.readLine();
                if (input.equals("n") || input.equals("N"))
                    return;
            }
            catch(IOException ioex) {}
        }
        if (command.equals("startServer") || command.equals("cbserver")) {
            String[] cmdarray=null;
            if (bStartInteractiveServer)
                cmdarray=new String[currentCommand.length+2];
            else
                cmdarray=new String[currentCommand.length];
            String port=System.getProperty("CB_PORTNR", "4001");
            if (System.getProperty("os.name").indexOf("Windows") >= 0) {
                cmdarray[0] = getCbHome() + "\\cbserver.bat";
            }
            else {
                cmdarray[0] = getCbHome() + "/cbserver";
            }
            int optionsOffset=0;
            if (bStartInteractiveServer) {
                optionsOffset=2;
                cmdarray[1]="-i";
                cmdarray[2]="a";
            }
            for(int i=1; i < currentCommand.length; i++) {
                cmdarray[i+optionsOffset]=currentCommand[i];
                if ((currentCommand[i].equals("-p") || 
                    currentCommand[i].equals("-port")
                   ) &&
                    currentCommand.length > (i + 1)) {
                    port=currentCommand[i + 1];
                }
            }

            startconnectCbServer(cmdarray,port); // start the CBserver with the collected cmdarray on port

        }
        else if (command.equals("enrollMe") || command.equals("connect")) {
            String pubCBserver = i5.cb.CBConfiguration.getPublicCBserverHost();
            String hostname = "localhost";
            if (pubCBserver != null && !pubCBserver.equals("none"))
              hostname = pubCBserver;
            if (currentCommand.length >= 2)
              hostname=currentCommand[1];
            String port = i5.cb.CBConfiguration.getPublicCBserverPort();  // defaults to 4001
            if (currentCommand.length >= 3)
               port=currentCommand[2];
            try {
                //connect to running server; null is used to indicate that username is determined by cbClient
                cbClient=new CBclient(hostname, Integer.parseInt(port), "CBshell", null);
                cbClient.setTimeOut(36000000); // ten hours timeout
                isConnected=true;
                if (scriptFile==null && bDisplayPrompt)
                    System.out.println("Successfully connected to server");
            }
            catch(Exception e) {
                // Linux computer can start a cbserver on the fly
                if (currentCommand.length == 1 &&
                    System.getProperty("os.name").indexOf("Linux") >= 0) {   
                  String[] cmdarray=new String[1];
                  cmdarray[0] = getCbHome() + "/cbserver";
                  startconnectCbServer(cmdarray,port); // start the CBserver with the collected cmdarray on port  
                }    
            }
        }
        else if (command.equals("cancelMe") || command.equals("disconnect")) {
            if (isConnected) {
                try {
                    cbClient.cancelMe();
                    cbClient=null;
                    isConnected=false;
                }
                catch(Exception ex) {}
            }
            else {
                System.err.println("Unable to cancel connection, not connected to server");
            }
        }
        else if (command.equals("stopServer")|| command.equals("stop")) {
            try {
                if (bServerStarted || isConnected) {
                    if (bServerStarted) {
                        serverThread.stopServer();
                        serverThread=null;
                    }
                    else if (isConnected) {
                        cbClient.stopServer();
                    }
                    cbClient=null;
                    isConnected=false;
                    bServerStarted=false;
                }
            }
            catch(Exception e) {
            }
        }
        else if (command.equals("tell")) {
            if (isConnected && currentCommand.length == 2) {
                try {
                    currentAns=cbClient.tell(currentCommand[1]);
                }
                catch(CBException e) {
                    System.err.println("Exception: " + e.getMessage());
                }
                catch(IOException rme) {
                    System.err.println("Exception: " + rme.getMessage());
                }
            }
            else {
                if (!isConnected) {
                    System.out.println(
                        "Unable to tell, not connected to server");
                }
                else {
                    System.err.println("Usage: tell Frames");
                }
            }
        }
        else if (command.equals("tellModel")) {
            if (isConnected) {
                try {
                    //create string array with frames
                    String[] asFiles=new String[currentCommand.length - 1];
                    for(int i=0; i < currentCommand.length - 1; i++) {
                        asFiles[i]=currentCommand[i + 1];
                    }
                    //tellModel with cbClient
                    currentAns=cbClient.tellModel(asFiles);
                }
                catch(CBException e) {
                    System.err.println("Exception: " + e.getMessage());
                }
                catch(IOException rme) {
                    System.err.println("Exception: " + rme.getMessage());
                }
            }
            else {
                System.err.println(
                    "Unable to tellModel, not connected to server");
            }
        }
        else if (command.equals("untell")) {
            if (isConnected && currentCommand.length == 2) {
                try {
                    currentAns=cbClient.untell(currentCommand[1]);
                }
                catch(CBException e) {
                    System.err.println("Exception: " + e.getMessage());
                }
                catch(IOException rme) {
                    System.err.println("Exception: " + rme.getMessage());
                }
            }
            else {
                if (!isConnected) {
                    System.err.println(
                        "Unable to untell, not connected to server");
                }
                else {
                    System.err.println("Usage: untell Frames");
                }
            }
        }
        else if (command.equals("retell")) {
            if (isConnected && currentCommand.length == 3) {
                try {
                    currentAns=cbClient.retell(currentCommand[1],
                                               currentCommand[2]);
                }
                catch(CBException e) {
                    System.err.println("Exception: " + e.getMessage());
                }
                catch(IOException rme) {
                    System.err.println("Exception: " + rme.getMessage());
                }
            }
            else {
                if (!isConnected) {
                    System.out.println(
                        "Unable to retell, not connected to server");
                }
                else {
                    System.out.println("Usage: retell UntellFrames TellFrames");
                }
            }
        }
        else if (command.equals("ask")) {
            if (isConnected && currentCommand.length <= 5 && currentCommand.length > 1) {
                String query=currentCommand[1];
                String queryRep="OBJNAMES";
                if (currentCommand.length>2)
                    queryRep=currentCommand[2];
                String answerRep="LABEL";
                if (currentCommand.length>3)
                    answerRep=currentCommand[3];
                String rollbackTime="Now";
                if (currentCommand.length>4)
                    rollbackTime=currentCommand[4];
                try {
                    currentAns=cbClient.ask(query,queryRep,answerRep,rollbackTime);
                }
                catch(Exception e) {
                    System.err.println("Exception: " + e.getMessage());
                }
            }
            else {
                if (!isConnected) {
                    System.err.println("Unable to ask, not connected to server");
                }
                else {
                    System.err.println(
                        "Usage: ask Query [QueryFormat [AnswerRep [RollbackTime]]]");
                }
            }
        }
        else if (command.equals("hypoAsk")) {
            if (isConnected && currentCommand.length <= 6 && currentCommand.length > 2) {
                String frames=currentCommand[1];
                String query=currentCommand[2];
                String queryRep="OBJNAMES";
                if (currentCommand.length>3)
                    queryRep=currentCommand[3];
                String answerRep="LABEL";
                if (currentCommand.length>4)
                    answerRep=currentCommand[4];
                String rollbackTime="Now";
                if (currentCommand.length>5)
                    rollbackTime=currentCommand[5];
                try {
                    currentAns=cbClient.hypoAsk(frames,query,queryRep,answerRep,rollbackTime);
                }
                catch(Exception e) {
                    System.err.println("Exception: " + e.getMessage());
                }
            }
            else {
                if (!isConnected) {
                    System.err.println(
                        "Unable to hypoAsk , not connected to server");
                }
                else {
                    System.err.println(
                        "Usage: hypoAsk  Frames Query [QueryFormat [AnswerRep [RollbackTime]]]");
                }
            }
        }
        else if (command.equals("lpicall")) {
            if (isConnected && currentCommand.length == 2) {
                try {
                    currentAns=cbClient.LPIcall(currentCommand[1]);
                }
                catch(CBException e) {
                    System.err.println("Exception: " + e.getMessage());
                }
                catch(IOException rme) {
                    System.err.println("Exception: " + rme.getMessage());
                }
            }
            else {
                if (!isConnected) {
                    System.err.println(
                        "Unable to perform LPIcall, not connected to server");
                }
                else {
                    System.out.println("Usage: lpicall <lpicall>");
                }
            }
        }
        else if (command.equals("prolog")) {
            if (isConnected && currentCommand.length == 2) {
                try {
                    currentAns=cbClient.LPIcall("PROLOG_CALL," + currentCommand[1]);
                }
                catch(CBException e) {
                    System.err.println("Exception: " + e.getMessage());
                }
                catch(IOException rme) {
                    System.err.println("Exception: " + rme.getMessage());
                }
            }
            else {
                if (!isConnected) {
                    System.err.println(
                        "Unable to execute the prolog call , not connected to server");
                }
                else {
                    System.out.println("Usage: prolog prolog_code");
                }
            }
        }

        else if (command.equals("setModule") || command.equals("cd") ) {
            String newmod = "$Home";  // default, shall be evaluated by CBserver to the user's home module
            if (currentCommand.length == 2)
              newmod = currentCommand[1];
            if (isConnected && currentCommand.length >= 1) {
                try {
                    currentAns=cbClient.setModule(newmod);
                }
                catch(CBException e) {
                    System.err.println("Exception: " + e.getMessage());
                }
                catch(IOException rme) {
                    System.err.println("Exception: " + rme.getMessage());
                }
            }
            else {
                if (!isConnected) {
                    System.err.println(
                        "Unable to setModule , not connected to server");
                }
                else {
                    System.out.println("Usage: setModule <Module>   or   cd <Module>");
                }
            }
        }

        else if (command.equals("getModulePath") || command.equals("pwd") ) {
            if (isConnected && currentCommand.length >= 1) {
                try {
                    currentAns=cbClient.getModulePath();
                }
                catch(Exception e) {
                    System.err.println("Exception: " + e.getMessage());
                }
            }
            else {
                if (!isConnected) {
                    System.err.println(
                        "Unable to getModulePath , not connected to server");
                }
                else {
                    System.out.println("Usage: getModulePath or pwd");
                }
            }
        }

        else if (command.equals("newModule") || command.equals("mkdir")) {
            if (isConnected && currentCommand.length == 2) {
                try {
                    String newModule = currentCommand[1] + " in Module end";  // new module as a Telos frame
                    currentAns=cbClient.tell(newModule);
                }
                catch(CBException e) {
                    System.err.println("Exception: " + e.getMessage());
                }
                catch(IOException rme) {
                    System.err.println("Exception: " + rme.getMessage());
                }
            }
            else {
                if (!isConnected) {
                    System.out.println(
                        "Unable to create new module, not connected to server");
                }
                else {
                    System.err.println("Usage: newModule <ModuleName>   or  mkdir <ModuleName>");
                }
            }
        }
        else if (command.equals("getErrorMessages") || command.equals("why")) {
            try {
                System.out.println(cbClient.getErrorMessages().trim());
            }
            catch(Exception e) {
                System.out.println("Exception: " + e.getMessage());
            }
        }
        else if (command.equals("showUsers") || command.equals("who")) {
            if (isConnected) {
                String query="find_instances[CB_User/class]";
                String queryRep="OBJNAMES";
                String answerRep="LABEL";
                String rollbackTime="Now";
                try {
                    currentAns=cbClient.ask(query,queryRep,answerRep,rollbackTime);
                }
                catch(Exception e) {
                    System.err.println("Exception: " + e.getMessage());
                }
            }
            else {
                if (!isConnected) {
                    System.err.println("Not connected to server");
                }
            }
        }
        else if (command.equals("showModules") || command.equals("sub")) {
            if (isConnected) {
                String query="find_instances[Module/class]";
                String queryRep="OBJNAMES";
                String answerRep="LABEL";
                String rollbackTime="Now";
                try {
                    currentAns=cbClient.ask(query,queryRep,answerRep,rollbackTime);
                }
                catch(Exception e) {
                    System.err.println("Exception: " + e.getMessage());
                }
            }
            else {
                if (!isConnected) {
                    System.err.println("Not connected to server");
                }
            }
        }
        else if (command.equals("listClass") || command.equals("ls")) {
            if (isConnected) {
                String className = "Individual";
                if (currentCommand.length == 2)
                   className = currentCommand[1];
                String query="find_instances[" + className + "/class]";
                String queryRep="OBJNAMES";
                String answerRep="LABEL";
                String rollbackTime="Now";
                try {
                    currentAns=cbClient.ask(query,queryRep,answerRep,rollbackTime);
                }
                catch(Exception e) {
                    System.err.println("Exception: " + e.getMessage());
                }
            }
            else {
                if (!isConnected) {
                    System.err.println("Not connected to server");
                }
            }
        }
        else if (command.equals("listModule") || command.equals("lm")) {
            if (isConnected) {
                String query = "listModule";
                if (currentCommand.length == 2)
                   query="listModule[" + currentCommand[1] + "/module]";
                String queryRep="OBJNAMES";
                String answerRep="FRAME";
                String rollbackTime="Now";
                try {
                    currentAns=cbClient.ask(query,queryRep,answerRep,rollbackTime);
                }
                catch(Exception e) {
                    System.err.println("Exception: " + e.getMessage());
                }
            }
            else {
                if (!isConnected) {
                    System.err.println("Not connected to server");
                }
            }
        }
        else if (command.equals("show")) {
            if (currentCommand.length == 2 && isConnected) {
                String query="get_object[" + currentCommand[1] + "/objname]";
                String queryRep="OBJNAMES";
                String answerRep="FRAME";
                String rollbackTime="Now";
                try {
                    currentAns=cbClient.ask(query,queryRep,answerRep,rollbackTime);
                }
                catch(Exception e) {
                    System.err.println("Exception: " + e.getMessage());
                }
            }
            else {
                if (!isConnected) {
                    System.err.println("Not connected to server");
                }
                else {
                    System.err.println("Usage: show <ObjectName>");
                }
            }
        }
        else if (command.equals("result")) {
            if (currentCommand.length == 3 && currentAns != null) {
                //look for first linebreak in input
                int index = -1;
                if (previousCommand.length > 1) 
                  index=previousCommand[1].indexOf('\n');
                String firstline;
                //if input contains more than one line extract it
                if (index != -1) {
                    firstline=previousCommand[1].substring(0, index);
                }
                //if input contain only one line use it
                else if (previousCommand.length > 1) {
                    firstline=previousCommand[1];
                } else {
                    firstline="";
                    System.err.println("Command 'result' cannot find previous command?");
                }
                firstline=firstline.replace(';', ':');

                if (currentCommand[1].equals(currentAns.getCompletionString()) &&
                   (currentCommand[2].trim().equals("_") || sameWords(currentCommand[2],currentAns.getResult()))) {
                    if (scriptFile==null)
                        System.out.println("result ok");
                    if (currentAns.getCompletion()==CBanswer.ERROR) {
                        try {
                            cbClient.getErrorMessages();
                        }
                        catch(Exception ex) {
                            System.err.println("Exception:" + ex.getMessage());
                        }
                    }
                    writeStat(previousCommand[0], firstline, "ok", commandExecutionTime);
                }
                else {
                    if (scriptFile==null)
                        System.out.println("result error");
                    //write detailed error into error.log
                    writeError("**************************************\n");
                    writeError("Error during interaction with server\n");
                    writeError(Integer.toString(commandCounter) + ";" +
                               "Method was:\n");
                    for(int i=0; i < previousCommand.length; i++) {
                        writeError(previousCommand[i] + " ");
                    }
                    writeError("\n");
                    writeError("Expected Answer:" + currentCommand[1] + "\n");
                    writeError(currentCommand[2] + "\n");
                    writeError("Received answer:" + currentAns.getCompletionString() + "\n");
                    writeError(currentAns.getResult());
                    if (currentAns.getCompletion()==CBanswer.ERROR) {
                        writeError("Error Messages:");
                        try {
                            writeError(cbClient.getErrorMessages());
                        }
                        catch(Exception ex) {
                            System.out.println("Exception:" + ex.getMessage());
                        }
                    }
                    writeError("\n**************************************\n");
                    //write summary into stat.log
                    writeStat(previousCommand[0], firstline, "error", commandExecutionTime);
                }
            }
            else if (currentAns != null) {
                System.err.println("Usage: \"result completion Answer \"");
            }
        }
        else if (command.equals("showAnswer")) {
            if (currentAns != null) {
                if (currentCommand.length == 1) {
                  System.out.println(currentAns.getResult());
                } else if (currentCommand.length == 3 && 
                           currentCommand[1].equals(">")) {     // user asked for output redirection
                  String outFilename = currentCommand[2];
                  try {
                    java.io.PrintWriter outFile = new PrintWriter(outFilename);
                    outFile.println(currentAns.getResult());
                    outFile.close();
                  } catch (Exception ex) {
                     System.err.println(ex.toString());
                  }
                }
            }
        }
        else if (command.equals("newline") || command.equals("nl")) {
           System.out.println();
        }
        else if (command.equals("echo")) {
           if (currentCommand.length == 3 && currentCommand[1].equals("-n"))
             echo(false,currentCommand[2]);
           else
             echo(true,currentCommand[1]);
        }
        else if (command.equals("help")) {
            System.out.println("The following commands are available:");
            System.out.println("  startServer <serveroptions>    or  cbserver <serveroptions>");
            System.out.println("      starts a CBserver with the specified options and connects to it");
            System.out.println("  enrollMe [<host> [<port>]]     or  connect [<host> [<port>]]");
            System.out.println("      connects to a server; default host is localhost or the public CBserver (if defined), default port number is 4001");
            System.out.println("  cancelMe   or  disconnect");
            System.out.println("      disconnects from a server");
            System.out.println("  stopServer   or  stop");
            System.out.println("      stops the server which is currently connected");
            System.out.println("  tell <frames>");
            System.out.println("      tells frames to the server; enclose the frames in single or double quotes");
            System.out.println("  untell <frames>");
            System.out.println("      untells frames from the server");
            System.out.println("  retell <untellFrames> <tellFrames>");
            System.out.println("      untells and tells frames to a server in one transaction");
            System.out.println("  tellModel <file1> <file2> ...");
            System.out.println("      tells files to the server");
            System.out.println("  ask <Query> [<QueryFormat> [<AnswerRep> [<RollbackTime>]]]");
            System.out.println("      asks a query");
            System.out.println("  hypoAsk <frames> <Query>  [<QueryFormat> [<AnswerRep> [<RollbackTime>]]]");
            System.out.println("      tells frames temporarily and asks a query");
            System.out.println("  lpicall <lpicall>");
            System.out.println("      executes the LPI call");
            System.out.println("  prolog <prolog_statement>");
            System.out.println("      executes the Prolog statement");
            System.out.println("  getErrorMessages   or  why");
            System.out.println("      gets error messages for the last transaction and prints them on stdout");
            System.out.println("  result <completion> <result>");
            System.out.println("      compares the given result with the last result which has been received");
            System.out.println("  setModule <module>    or  cd <module>");
            System.out.println("      changes the module context of this shell");
            System.out.println("  getModulePath    or  pwd");
            System.out.println("      display the current absolute module path");
            System.out.println("  newModule <module>    or  mkdir <module>");
            System.out.println("      shortcut for tell \"<module> in Module end\"");
            System.out.println("  showUsers   or  who");
            System.out.println("      display instances of CB_User, i.e. all users who have logged into this database");
            System.out.println("  showModules   or  sub");
            System.out.println("      display the currently vissible submodules");
            System.out.println("  showAnswer");
            System.out.println("      shows answer to the last query on stdout; use '> filename' for output redirection");
            System.out.println("  show <name>");
            System.out.println("      display the frame of object <name>; shortcut for ask get_object[<name>/objname]");
            System.out.println("  listModule [<module>]   or  lm [<module>]");
            System.out.println("      shortcut for ask listModule[<module>/module]; uses currentmodule if called without parameter");
            System.out.println("  listClass [<class>]   or  ls [<class>]");
            System.out.println("      display the instances of <class>; uses Individual as class if called without parameter");
            System.out.println("  echo [-n] <string>");
            System.out.println("      echoes the string to standard output; use quotes if the string has multiple words;");
            System.out.println("      newline at end is surpressed if the option -n is used;");
            System.out.println("  exit");
            System.out.println("      exits the shell (also stops a server which has been started in this shell)");
            System.out.println("Command arguments with white space characters have to be enclosed in single or double quotes");
            System.out.println("Command arguments may then also span multiple lines.\n");
            System.out.println("More information is in the ConceptBase.cc User Manual.");
        }
        else if (command.equals("exit")) {
            exitShell(0);
        } else if (command.equals("quit")) {
            quitShell(0);
        }
        // if the command is a single token cf. Java conventions and CBShell is in interactive mode
        // then we interpret the single token as a query and process it via 'ask'
        else if (bShowAnswer && currentCommand.length == 1) {
            if (isConnected) {
                String query = currentCommand[0];
                String queryRep="OBJNAMES";
                String answerRep="default";
                String rollbackTime="Now";
                try {
                    currentAns=cbClient.ask(query,queryRep,answerRep,rollbackTime);
                }
                catch(Exception e) {
                    System.err.println("Exception: " + e.getMessage());
                }
            }
            else {
                if (!isConnected) {
                    System.err.println("Not connected to server");
                } else {
                  try {
                       System.out.println(cbClient.getErrorMessages().trim());
                  }
                  catch(Exception e) {
                       System.out.println("Exception: " + e.getMessage());
                  }
                }
            }
        }
        else {
            System.err.println("Unknown Command");
            writeStat("Unknown Command","???","error",0);
        }

       
        // show the command if option -v is set
        if (bcommandVerbose && currentAns != null) {
          System.out.println();
          for (int i=0; i < currentCommand.length; i++) {
             if (currentCommand[i].contains(" "))
                System.out.print("'" + currentCommand[i] + "'" + " ");
             else
                System.out.print(currentCommand[i] + " ");
          }
          System.out.println();
        }

        // show the Answer for each command when -a option is enabled
        if (bShowAnswer && currentAns != null) {
          System.out.println(currentAns.getResult());
          currentAns = null;  // only show once
        }
        commandExecutionTime=System.currentTimeMillis()-currTime;
    }

    private void exitShell(int status) {
        try {
            if (isConnected) {
                if (bServerStarted) {
                    serverThread.stopServer();
                    int i=0;
                    while(serverThread.isAlive() && i<20) {
                        Thread.sleep(100);
                        i++;
                    }
                }
                else
                    cbClient.cancelMe();
            }
        }
        catch(Exception ex) {
            System.out.println(ex.getMessage());
        }
//        System.err.println("> Goodbye from CBShell");
        System.exit(status);
    }



    /**
     * Quit CBShell without explicitely stopping the CBserver
    */
    private void quitShell(int status) {
        System.exit(status);
    }

    /**
     * Processes the given input and splits it into an array containing the command and the given arguments.
     * All arguments enclosed in "" will be merged.
     * @param input String to process
     * @return Array containing command and its arguments
     */
    private static String[] getCommandAndArgs(StringBuffer input) {

        ArrayList alCommandAndArgs=new ArrayList();
        StringBuffer sbCurrentArg=new StringBuffer();
        String command = "undefined";  // to be able to check the current command
        int i=0;
        while(i<input.length()) {
            if (argDelimiter == '"' && input.charAt(i) == '\\') {
                i++;
                if (input.charAt(i) == '=' || command.equals("tellModel") || command.equals("showAnswer"))  // isuue #64
                   sbCurrentArg.append('\\');  // take care that substrings \= remain \= 
                sbCurrentArg.append(input.charAt(i));
                i++;
            }
            else if (Character.isWhitespace(input.charAt(i))) {
                i++;
                if (sbCurrentArg.length()>0) {
                    alCommandAndArgs.add(sbCurrentArg.toString());
                    if (command.equals("undefined")) {
                       command = sbCurrentArg.toString();  // memorize the first word as the command
                    }
                    sbCurrentArg=new StringBuffer();
                }
            }
            else if (input.charAt(i) == argDelimiter) {
                i++;
                boolean bInQuotes=true;
                while(bInQuotes && i<input.length()) {
                    if (argDelimiter == '"' && input.charAt(i) == '\\') {
                        i++;
                       if (input.charAt(i) == '=' || command.equals("tellModel") || command.equals("showAnswer"))  // issue #64
                           sbCurrentArg.append('\\');  // take care that substrings \= remain \= 
                        sbCurrentArg.append(input.charAt(i));
                        i++;
                    }
                    else if (input.charAt(i) == argDelimiter) {
                        bInQuotes=false;
                        i++;
                        alCommandAndArgs.add(sbCurrentArg.toString());
                        sbCurrentArg=new StringBuffer();
                    }
                    else {
                        sbCurrentArg.append(input.charAt(i));
                        i++;
                    }
                }
            }
            else {
                sbCurrentArg.append(input.charAt(i));
                i++;
            }
        }

        if (sbCurrentArg.length()>0)
            alCommandAndArgs.add(sbCurrentArg.toString());
        String[] result=new String[alCommandAndArgs.size()];
        for(int j=0;j<alCommandAndArgs.size();j++) {
            result[j]=(String) alCommandAndArgs.get(j);
            Matcher m=varPattern.matcher(result[j]);
            while(m.find()) {
                if (m.group().length()>1) {
                    String propValue=System.getProperty(m.group().substring(1));
                    if (propValue != null) {
                        result[j]=result[j].replaceAll("\\" + m.group(), propValue);
                    }
                }
            }
        }
        return result;
     }


      /**
      * Print a line on standard output; print a newline if a sequence '\n' is detected
      * @param printNewlineAtEnd print an additional newline after aLine if set to true
      * @param aLine String to be printed
      */
     private static void echo(boolean printNewlineAtEnd, String aLine) {
     
       for (int i=0; i < aLine.length(); i++) {
         if ((aLine.charAt(i) == '\\') && (i+1 < aLine.length()) && (aLine.charAt(i+1) == 'n')) {
           System.out.println();
           i++;
         } else
           System.out.print(aLine.charAt(i));
       }
       if (printNewlineAtEnd)
         System.out.println();
     }




     /**
      * Check if two strings contain the same words, i.e. a string compare that
      * ignores internal whitespaces.
      * @param s1 String (from script, may contain regexp)
      * @param s2 String (result from server)
      * @return true if they strings contain the same words
      */
     private boolean sameWords(String s1, String s2) {
         Pattern p=Pattern.compile("\\S+");
         Matcher m1=p.matcher(s1);
         Matcher m2=p.matcher(s2);
         while(m1.find()) {
             if (!m2.find())
                 return false;
             String p1=m1.group();
             String p2=m2.group();
             if (!p1.equals(p2)) {
                 try {
                     if (!Pattern.matches(p1, p2)) {
                         return false;
                     }
                 }
                 catch(PatternSyntaxException pse) {
                     return false;
                 }
             }
         }
         if (m2.find())
             return false;
         return true;
     }



    /**
     * Thread which processes the output of a CBserver started in the CBShell
     */
    class ServerThread extends Thread {

        private BufferedReader inReader;
        private ErrorReaderThread errReaderThread;
        private int port;
        private boolean bIsReady=false;
        private boolean bDoIt=true;

        /**
         * Creates a new Thread which fetches the output of the CBServer associated with the given stream
         * @param in Inputstream of the underlying CBserver
         * @param err Errorstream of the underlying CBServer
         * @param p Port of the underlying CBServer
         */
        public ServerThread(BufferedReader in, BufferedReader err, int p) {
            inReader=in;
            errReaderThread=new ErrorReaderThread(err);
            errReaderThread.start();
            port=p;
        }

        public void run() {
            try {
                while(bDoIt) {
                    String inputLine=inReader.readLine();
                    while(inputLine != null) {
                        //collect output to check whether server started succesfully
                        if (!bIsReady) {
                            if (inputLine.indexOf("ready") >= 0) {
                                bIsReady=true;
				// CBserver ready message is routed to stderr to avoid spoiling the output stream
				// This is related to ticket #183
				// System.err.println(inputLine);  
			    } else {
				System.out.println(inputLine);
			    }
                        }
			else {
				System.out.println(inputLine);
			}
                        yield();
                        inputLine=inReader.readLine();
                    }
                }
            }
            catch(Exception e) {
                System.out.println("Exception:" + e.getMessage());
            }
        }

        /**
         * Stops the Server
         */
        public void stopServer() {
            try {
                String userName=null;
                try {
                    userName=System.getProperty("user.name","unknown");
                }
                catch(SecurityException secex) {
                    userName="unknown";
                }
                LocalCBclient cb=new LocalCBclient("localhost", port,
                    "StopServer", userName);
                cb.stopServer();
            }
            catch(CBException cbex) {
                System.out.println("Exception while trying to stop server:" +
                                   cbex.getMessage());
            }
            bDoIt=false;
            errReaderThread.stopThread();
        }

        /**
         * Returns if Server is ready
         * @return true if CBserver fully started, else false
         */
        public boolean isReady() {
            return bIsReady;
        }

    }

    class ErrorReaderThread extends Thread {

        BufferedReader errReader;
        boolean bDoIt=true;

        public ErrorReaderThread(BufferedReader err) {
            errReader=err;
        }

        public void run() {
            try {
                while(bDoIt) {
                    String errorLine=errReader.readLine();
                    while(errorLine != null) {
                        System.out.println(errorLine);
                        //collect output to check whether server started succesfully
                        yield();
                        errorLine=errReader.readLine();
                    }
                }
            }
            catch(Exception e) {
                System.out.println(e.getMessage());
            }
        }

        public void stopThread() {
            bDoIt=false;
        }
    }
}
