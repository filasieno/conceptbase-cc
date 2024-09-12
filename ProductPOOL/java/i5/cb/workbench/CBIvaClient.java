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
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
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
/**
 *   <b> CBIvaClient for CBIva 02.98  (ConceptBase) </b>
 *
 *   @see i5.cb.workbench.CBIva
 */
package i5.cb.workbench;


import i5.cb.CBException;
import i5.cb.api.CBanswer;
import i5.cb.api.CBclient;
import i5.cb.telos.frame.*;

import java.io.IOException;
import java.io.StringReader;
import java.util.Enumeration;

import javax.swing.JOptionPane;

/**
 *   Class:    <b> CBIvaClient for CBIva  </b><BR>
 *   Function: <b> Implements the Interface to CBClient </b> <BR>
 *
 *   @version 0.8 beta
 *   @author    Rainer Langohr
 *
 *   @see i5.cb.workbench.CBIva
 *   @see i5.cb.api.CBclient
 */
public class CBIvaClient {


    /**
     * contains the  Connect-Dialog
     *
     * @see i5.cb.workbench.ConnectDialog
     */
    private ConnectDialog cdConnectDialog=null;

    /**
     * contains the Options-Dialog
     *
     * @see i5.cb.workbench.OptionsDialog
     */



    /**
     *   @return <code>true</code>  if the TelosPareser should be called <BR>
     *           <code>false</code>  otherwise
     */
    private boolean bCallTelosParser;

    // true when TelosEditor shall show line numbers
    private boolean bShowLineNumbers;

    // Creates New Version "Now";

    private CBIVersion Version=new CBIVersion();


    private CBclient cbc=null;



    private CBIva CBI;

    /**
     *   <b> Constructor  </b><BR>
     *
     *   Function: <b> Create a new Client from CBIva to a CBserver</b> <BR>
     *
     *   @param CBI   CBIva
     *   @see i5.cb.api.CBclient
     *
     */
    public CBIvaClient(CBIva CBI) {
        this.CBI=CBI;
        cdConnectDialog = null;      // Dialoge mit "null" initialisieren
        // init the subsequent flags from CBConfiguration, file .CBjavaInterface
        bCallTelosParser=i5.cb.CBConfiguration.getCallTelosParser();
        bShowLineNumbers=i5.cb.CBConfiguration.getShowLineNumbers();
    }


    public CBIVersion getVersion() {
        return this.Version;
    }

    public void setVersion(CBIVersion ver) {
        this.Version = ver;
        CBI.getStatusBar().setVersion(ver);
    }



    public CBclient getCBClient()  {
        return cbc;
    }

    /**
     *   @return <code>true</code>  if CBclient is connectet <BR>
     *           <code>false</code>  otherwise
     *
     */
    public boolean isConnected() {
        try {
            if (cbc!=null)
                return cbc.isConnected();
            else
                return false;
        }
        catch (java.rmi.RemoteException e) {
            return false;
        }
    }

    /**
     *   @return the CBanswer from the CBclient
     */
    public CBanswer stopServer() {
        CBanswer answer=null;
        try  {
            if(cbc!=null)
                answer = cbc.stopServer();
        }
        catch (CBException e)  {
            CBI.getStatusBar().insertMessage("Could not stop server");
            TelosParserError(e.getHelpText());
        }
        catch (java.rmi.RemoteException e2)  {
            CBI.getStatusBar().insertMessage("Could not stop server: RMI Exception");
        }

        return answer;
    }

    /**
     *   Function: <b> start CBclient.LPIcall(String) </b> <BR>
     *   @param s the String for the LPIcall
     *   @see i5.cb.api.CBclient#LPIcall
     */
    public String LPIcall(String s) {

        if (isConnected()) {

            long iMilliSeconds=System.currentTimeMillis();

            CBanswer cbAns=null;


            try  {
                cbAns=cbc.LPIcall("PROLOG_CALL,( "+ s +" )");
            }
            catch (CBException e)  {
                CBI.getStatusBar().insertMessage("Prolog Call Error");
                TelosParserError(e.getHelpText());
                return "error";
            }
            catch (java.rmi.RemoteException e2)  {
                CBI.getStatusBar().insertMessage("RMI Exception");
                return "error";
            }

            String[] asArgs = new String[2];
            asArgs[0] = s;

            if (cbAns.getCompletion() == CBanswer.OK) {
                CBI.getStatusBar().insertMessage("Prolog Call successful");
                asArgs[1]=cbAns.getResult();
                CBI.getLogWindow().insertOperation(LogWindow.LPICALL, asArgs, true);
            }
            else {
                CBI.getLogWindow().insertOperation(LogWindow.LPICALL, asArgs, false);
                CBI.getStatusBar().insertMessage("Prolog Call Error");
                String[] asErrorArgs=new String[1];
                try  {
                    asErrorArgs[0] = cbc.getErrorMessages();
                }
                catch (CBException e)  {
                    CBI.getStatusBar().insertMessage("Prolog Call Error");
                    TelosParserError(e.getHelpText());
                }
                catch (java.rmi.RemoteException e2)  {
                    CBI.getStatusBar().insertMessage("Prolog Call Error: RMI Exception");
                }
                CBI.getLogWindow().insertOperation(LogWindow.ERROR, asErrorArgs, false);
            }
            CBI.getStatusBar().setTATime(System.currentTimeMillis()-iMilliSeconds);
            return cbAns.getResult();
        }
        else  {
            CBI.getStatusBar().insertMessage("Not connected!");
            return "error";
        }
    }



    /**
     *   Function: <b> Cancel the Connection to the CBserver </b> <BR>
     *   @see i5.cb.api.CBclient#cancelMe
     */
    public void cancelMe() {
        try  {
            if(cbc!=null) {
                cbc.cancelMe();
		CBI.getStatusBar().insertMessage("Connection successfully terminated");
                CBI.getStatusBar().setModule("none");
            }
        }
        catch (CBException e)  {
            CBI.getStatusBar().insertMessage("Unable to disconnect from server");
            TelosParserError(e.getHelpText());
        }
        catch (java.rmi.RemoteException e2)  {
            CBI.getStatusBar().insertMessage("Unable to disconnect from server: RMI Exception");
        }
    }

    /**
     *   Function: <b> Enroll the CBclient with the parameters </b> <BR>
     *   @exception CBException  from CBclient.enrollMe()
     *   @see i5.cb.api.CBclient#enrollMe
     *   @see i5.cb.CBException
     */
    public void enrollMe(String hostname, int port, String toolname, String username) throws CBException {

        try {
            cbc=new CBclient(hostname, port, toolname, username);
            CBI.getStatusBar().setModule(getModule());
            if (CBI.getTelosEditor() != null)
              CBI.getTelosEditor().setTitle("Telos Editor -- "+hostname+':'+port);
        }
        catch (CBException e) {
            throw e;
        }
    }

   private void TelosParserError(String sErrorMessage) {
        JOptionPane.showMessageDialog(CBI,sErrorMessage,"Telos Parser Error",JOptionPane.ERROR_MESSAGE);
    }



    /**
     *   Function: <b> Tells to CBserver </b> <BR>
     *   Tells frames to the database and inserts messages into
     *   TelosEditor and LogWindow
     *
     *   @param sFrames the frames
     *   @see i5.cb.api.CBclient#tell
     *   @return the completion of the tell method
     */
    public int tell(String sFrames) {


        if (isConnected()) {

            if(!parseFrames(sFrames,true))
                return CBanswer.ERROR;

            long iMilliSeconds=System.currentTimeMillis();

            CBanswer cbaAns=null;


            try  {
                cbaAns=cbc.tellTransactions(sFrames);
            }
            catch (CBException e)  {
                CBI.getStatusBar().insertMessage("Telos Parser Error");
                TelosParserError(e.getHelpText());
                return CBanswer.ERROR;
            }
            catch (java.rmi.RemoteException e2)  {
                CBI.getStatusBar().insertMessage("RMI Exception");
                return CBanswer.ERROR;
            }

            String[] asArgs = new String[1];
            asArgs[0] = sFrames;

            if (cbaAns.getCompletion() == CBanswer.OK) {
                CBI.getStatusBar().insertMessage("Successfully told");
                updateCBIvaWindows(sFrames);
                CBI.getLogWindow().insertOperation(LogWindow.TELL, asArgs, true);
            }
            else {
                CBI.getLogWindow().insertOperation(LogWindow.TELL, asArgs, false);
                CBI.getStatusBar().insertMessage("Tell failed");
                asArgs = new String[1];
                try  {
                    asArgs[0] = cbc.getErrorMessages();
                }
                catch (CBException e)  {
                    CBI.getStatusBar().insertMessage("Telos Parser Error");
                    TelosParserError(e.getHelpText());
                }
                catch (java.rmi.RemoteException e2)  {
                    CBI.getStatusBar().insertMessage("RMI Exception");
                }
                CBI.getLogWindow().insertOperation(LogWindow.ERROR, asArgs, false);
            }

            CBI.getStatusBar().setTATime(System.currentTimeMillis()-iMilliSeconds);

            return cbaAns.getCompletion();

        }
        else  {
            CBI.getStatusBar().insertMessage("Not connected!");
            return CBanswer.NOTHANDLED;
        }

    }

    /**
     *   Function: <b> Untell to CBserver </b> <BR>
     *
     *  Untells frames to the database and inserts messages into
     *   TelosEditor and LogWindow
     *
     *  @param sFrames the frames
     *  @return the completion of the untell method
     */

    public int untell(String sFrames) {


        if (isConnected()) {

            if(!parseFrames(sFrames,true))
                return CBanswer.ERROR;

            long iMilliSeconds=System.currentTimeMillis();
            CBanswer cbaAns=null;


            try  {
                cbaAns=cbc.untell(sFrames);
            }
            catch (CBException e)  {
                CBI.getStatusBar().insertMessage("Telos Parser Error");
                TelosParserError(e.getHelpText());
                return CBanswer.ERROR;
            }
            catch (java.rmi.RemoteException e2)  {
                CBI.getStatusBar().insertMessage("RMI Exception");
                return CBanswer.ERROR;
            }


            String[] asArgs = new String[1];
            asArgs[0] = sFrames;

            if (cbaAns.getCompletion() == CBanswer.OK) {
                CBI.getStatusBar().insertMessage("Successfully untold");
                updateCBIvaWindows(sFrames);
                CBI.getLogWindow().insertOperation(LogWindow.UNTELL, asArgs, true);
            }
            else {
                CBI.getLogWindow().insertOperation(LogWindow.UNTELL, asArgs, false);
                CBI.getStatusBar().insertMessage("Untell failed");
                asArgs = new String[1];
                try  {
                    asArgs[0] = cbc.getErrorMessages();
                }
                catch (CBException e)  {
                    CBI.getStatusBar().insertMessage("Telos Parser Error");
                    TelosParserError(e.getHelpText());
                }
                catch (java.rmi.RemoteException e2)  {
                    CBI.getStatusBar().insertMessage("RMI Exception");
                }
                CBI.getLogWindow().insertOperation(LogWindow.ERROR, asArgs, false);
            }

            CBI.getStatusBar().setTATime(System.currentTimeMillis()-iMilliSeconds);
            return cbaAns.getCompletion();

        }
        else  {
            CBI.getStatusBar().insertMessage("Not connected!");
            return CBanswer.NOTHANDLED;
        }

    }

    /**
     *   Function: <b> Retell to CBserver </b> <BR>
     *
     *  Retells frames with the database and inserts messages into
     *   TelosEditor and LogWindow
     *
     *  @param sTellFrames the frames to retell
     *  @return the completion of the untell method
     */
    public int retell(String sUntellFrames, String sTellFrames) {

        if (isConnected()) {

            if(!parseFrames(sUntellFrames,true))
                return CBanswer.ERROR;

            if(!parseFrames(sTellFrames,true))
                return CBanswer.ERROR;

            long iMilliSeconds=System.currentTimeMillis();
            CBanswer cbaAns=null;


            try  {
                cbaAns=cbc.retell(sUntellFrames,sTellFrames);
            }
            catch (CBException e)  {
                CBI.getStatusBar().insertMessage("Telos Parser Error");
                TelosParserError(e.getHelpText());
                return CBanswer.ERROR;
            }
            catch (java.rmi.RemoteException e2)  {
                CBI.getStatusBar().insertMessage("RMI Exception");
                return CBanswer.ERROR;
            }


            String[] asArgs = new String[2];
            asArgs[0] = sUntellFrames;
            asArgs[1] = sTellFrames;

            if (cbaAns.getCompletion() == CBanswer.OK) {
                CBI.getStatusBar().insertMessage("Successfully re-told");
                updateCBIvaWindows(sUntellFrames+sTellFrames);
                CBI.getLogWindow().insertOperation(LogWindow.RETELL, asArgs, true);
            }
            else {
            	CBI.getLogWindow().insertOperation(LogWindow.RETELL, asArgs, false);
                CBI.getStatusBar().insertMessage("Retell failed");
                asArgs = new String[1];
                try  {
                    asArgs[0] = cbc.getErrorMessages();
                }
                catch (CBException e)  {
                    CBI.getStatusBar().insertMessage("Telos Parser Error");
                    TelosParserError(e.getHelpText());
                }
                catch (java.rmi.RemoteException e2)  {
                    CBI.getStatusBar().insertMessage("RMI Exception");
                }
                CBI.getLogWindow().insertOperation(LogWindow.ERROR, asArgs, false);
            }

            CBI.getStatusBar().setTATime(System.currentTimeMillis()-iMilliSeconds);
            return cbaAns.getCompletion();
        }
        else  {
            CBI.getStatusBar().insertMessage("Not connected!");
            return CBanswer.NOTHANDLED;
        }

    }



    /**
     *   Function: <b> Ask from CBserver </b> <BR>
     *
     *  Executes the query on the database and inserts messages into
     *  TelosEditor and LogWindow
     *  @param sQuery the query
     *  @param sQueryFormat the format of the query (FRAMES or OBJNAMES)
     *  @param sAnswerRep the format of the answer (e.g. FRAME, LABEL,...)
     *  @param te The TelosEditor where to insert the answertext
     */
    public void ask(String sQuery, String sQueryFormat, String sAnswerRep, TelosEditor te) {
        if (!sQuery.trim().endsWith("end") && sQueryFormat.equals("FRAMES")) {
           sQueryFormat = "OBJNAMES";   // ticket #232: a query that does not end with "end" is actually an OBJNAMES query
           sAnswerRep = "default";
        }
        String result = this.ask(sQuery, sQueryFormat, sAnswerRep);
        if (!result.equals("error")) {
            new QueryResultWindow(result, CBI);
        }
        else
            te.getCBIva().getStatusBar().insertMessage("Ask failed");
    }



    /**
     *   Function: <b> Ask from CBserver </b> <BR>
     *
     *  Executes the query on the database and inserts messages into
     *  TelosEditor and LogWindow
     *  @param sQuery the query
     *  @param sQueryFormat the format of the query (FRAMES or OBJNAMES)
     *  @param sAnswerRep the format of the answer (e.g. FRAME, LABEL,...)
     *  @return the result ("error" on error)
     */
    public String ask(String sQuery, String sQueryFormat, String sAnswerRep) {

        if (isConnected()) {

            if(sQueryFormat.equals("FRAMES") && !parseFrames(sQuery,false)) {
                if(parseObjectNames(sQuery,false))
                    sQueryFormat="OBJNAMES";
                else
                    return "error";
            }
            else if(sQueryFormat.equals("OBJNAMES") && !parseObjectNames(sQuery,false)) {
                if(parseFrames(sQuery,false))
                    sQueryFormat="FRAMES";
                else
                    return "error";
            }
            long iMilliSeconds=System.currentTimeMillis();
            CBanswer cbaAns=null;

            try  {
                cbaAns=cbc.ask(sQuery,sQueryFormat,sAnswerRep, this.getVersion().getVersion());
            }
            catch (CBException e)  {
                CBI.getStatusBar().insertMessage("Telos Parser Error");
                TelosParserError(e.getHelpText());
                return "error";
            }
            catch (java.rmi.RemoteException e2)  {
                CBI.getStatusBar().insertMessage("RMI Exception");
                return "error";
            }

            String[] asArgs = new String[5];
            asArgs[0] = sQuery;
            asArgs[1] = sQueryFormat;
            asArgs[2] = sAnswerRep;
            asArgs[3] = this.getVersion().getVersion();
            asArgs[4] = cbaAns.getResult();

            if (cbaAns.getCompletion() == CBanswer.OK) {
 //               CBI.getStatusBar().insertMessage("Query successful");
                CBI.getLogWindow().insertOperation(LogWindow.ASK, asArgs, true);
            }
            else {
            	CBI.getLogWindow().insertOperation(LogWindow.ASK, asArgs, false);
                CBI.getStatusBar().insertMessage("Ask failed");
                asArgs = new String[1];
                try  {
                    asArgs[0] = cbc.getErrorMessages();
                }
                catch (CBException e)  {
                    CBI.getStatusBar().insertMessage("Telos Parser Error");
                    TelosParserError(e.getHelpText());
                }
                catch (java.rmi.RemoteException e2)  {
                    CBI.getStatusBar().insertMessage("RMI Exception");
                }
                CBI.getLogWindow().insertOperation(LogWindow.ERROR, asArgs, false);
            }
            CBI.getStatusBar().setTATime(System.currentTimeMillis()-iMilliSeconds);
            return cbaAns.getResult();
        }
        else  {
            CBI.getStatusBar().insertMessage("Not connected!");
            return "error";
        }
    }

    /**
     *   Function: <b> get an Object from CBserver </b> <BR>
     *
     *  Executes the query get_object on the database and inserts
     *  messages into TelosEditor and LogWindow
     *
     *  @param sObjectName the object name
     *  @return the frame for the object
     */
    public String getObject(String sObjectName) {
        return this.ask("get_object[" + sObjectName + "/objname]","OBJNAMES","FRAME");
    }


    /**
     *   Function: <b> Find Instances on CBserver </b> <BR>
     *
     *  Executes the query find_instances on the database and inserts
     *  messages into TelosEditor and LogWindow
     *
     *  @param sObjectName the object name
     *  @return the frame for the object
     */
    public String findInstances(String sObjectName) {
        return this.ask("find_instances[" + sObjectName + "/class]","OBJNAMES","LABEL");
    }

    public String findModules() {
        return this.ask("find_instances[Module/class]","OBJNAMES","LABEL");

    }
    public String getModule() {
        try {
            if (cbc!=null)
                return cbc.getModule();
            else
                return null;
        }
        catch (java.rmi.RemoteException e2)  {
            return "System";
        }
    }


    // CBIva maintains a main QueryBrowser wondow and a main ModuleDialog; these contain views on the database
    // and should be kept up to date; The parameter 'about' is usually the tell/untell transaction if it contains
    // some of the keyword "QueryClass" or "Module", then the windows need to be updated
    public void updateCBIvaWindows(String about) {
        if (CBI.getMainQueryBrowser() != null && about.contains("QueryClass")) {
            CBI.updateMainQueryBrowser();
        }
        if (CBI.getMainModuleDialog() != null && about.contains("Module")) {
            CBI.updateMainModuleDialog();
        }
    }

    public void setModule(String s) {
        try {
            if (isConnected()) {
                CBanswer ans=cbc.setModule(s);
                if(ans.getCompletion() == CBanswer.OK ) {
                    CBI.getStatusBar().setModule(s);
                    updateCBIvaWindows("QueryClass, Module");
                } else {
                    String errMsg=cbc.getErrorMessages();
                    JOptionPane.showMessageDialog(CBI,errMsg,"Unable to change module",JOptionPane.ERROR_MESSAGE);
                    CBI.getStatusBar().insertMessage("Unable to change module");
                }
            }
            else {
                CBI.getStatusBar().insertMessage("Not connected!");
            }
        }
        catch (CBException e) {
            CBI.getStatusBar().insertMessage("Unable to change module");
        }
        catch (java.rmi.RemoteException e2)  {
            CBI.getStatusBar().insertMessage("RMI Exception");
        }
    }

    /**
     *   Function: <b> Tell Models to CBserver </b> <BR>
     *
     *  Tells files with rames to the database and inserts messages into
     *  TelosEditor and LogWindow
     *
     *  @param asFiles the filenames
     *  @return the completion of the tell method
     */
    public int tellModel(String[] asFiles) {

        if (isConnected()) {

            CBanswer cbaAns=null;

            try  {
                cbaAns=cbc.tellModel(asFiles);
            }
            catch (CBException e)  {
                CBI.getStatusBar().insertMessage("Telos Parser Error");
                TelosParserError(e.getHelpText());
                return CBanswer.ERROR;
            }
            catch (java.rmi.RemoteException e2)  {
                CBI.getStatusBar().insertMessage("RMI Exception");
                return CBanswer.ERROR;
            }

            if (cbaAns.getCompletion() == CBanswer.OK) {
                CBI.getStatusBar().insertMessage("Successfully told");
                CBI.getLogWindow().insertOperation(LogWindow.TELLMODEL, asFiles, true);
                updateCBIvaWindows("QueryClass,Module");
            }
            else {
            	CBI.getLogWindow().insertOperation(LogWindow.TELLMODEL, asFiles, false);
                CBI.getStatusBar().insertMessage("Tell Model failed");
                String[] asArgs = new String[1];
                try  {
                    asArgs[0] = cbc.getErrorMessages();
                }
                catch (CBException e)  {
                    CBI.getStatusBar().insertMessage("Telos Parser Error");
                    TelosParserError(e.getHelpText());
                }
                catch (java.rmi.RemoteException e2)  {
                    CBI.getStatusBar().insertMessage("RMI Exception");
                }
                CBI.getLogWindow().insertOperation(LogWindow.ERROR, asArgs, false);
            }

            return cbaAns.getCompletion();

        }
        else  {
            CBI.getStatusBar().insertMessage("Not connected!");
            return CBanswer.NOTHANDLED;
        }

    }


    /**
     *   Function: <b> Parse Telos-Frames </b> <BR>
     *
     *  @param sFrames the frames
     *  @return true if parsing is successful or bCallTelosParser is false
     */
    public boolean parseFrames(String sFrames, boolean bShowError) {

        if (bCallTelosParser) {
 //           CBI.getStatusBar().insertMessage("Preprocessing Telos frames");
            TelosParser tpParser=new TelosParser(new StringReader(sFrames + "\n"));
            try {
                tpParser.telosFrames();
            }
            catch (ParseException e) {
                if(bShowError)
                    TelosParserError(e.getMessage());
                CBI.getStatusBar().insertMessage("Telos Parser Error");
                return false;
            }
            catch (TokenMgrError tme) {
                if(bShowError)
                    TelosParserError(tme.getMessage());
                CBI.getStatusBar().insertMessage("Telos Parser Error");
                return false;
            }

            CBI.getStatusBar().insertMessage("Telos frames successfully parsed!");
            return true;
        }
        else
            return true;
    }


    public Enumeration enParseObjectNames(String sObjectNames) {
//        CBI.getStatusBar().insertMessage("Preprocessing Telos object names");
        TelosParser tpParser=new TelosParser(new StringReader(sObjectNames));
        ObjectNames on;

        try {
            on=tpParser.objectNames();
        }
        catch (ParseException pe) {
            TelosParserError(pe.getMessage());
            CBI.getStatusBar().insertMessage("Telos Parser Error");
            return null;
        }
        catch (TokenMgrError tme) {
            TelosParserError(tme.getMessage());
            CBI.getStatusBar().insertMessage("Telos Parser Error");
            return null;
        }

        Enumeration e=on.elements();
        return e;
    }


    public CBIVersion[] getVersions() {
        CBIVersion[] Versions=new CBIVersion[1];
        Versions[0]=this.getVersion();

        if (!isConnected()) {
            CBI.getStatusBar().insertMessage("Not Connected to Server!");
            return Versions;
        }

        try  {
            String s=cbc.ask("AvailableVersions" , "OBJNAMES","FRAME", "Now").getResult();


   //         CBI.getStatusBar().insertMessage("Preprocessing Telos object names");
            TelosParser tpParser=new TelosParser(new StringReader(s));

            TelosFrames tf;
            try {
                tf=tpParser.telosFrames();
            }
            catch (ParseException pe) {
                TelosParserError(pe.getMessage());
                CBI.getStatusBar().insertMessage("Telos Parser Error");
                return Versions;
            }
            catch (TokenMgrError tme) {
                TelosParserError(tme.getMessage());
                CBI.getStatusBar().insertMessage("Telos Parser Error");
                return Versions;
            }
            catch (Exception ex) {
                TelosParserError(ex.getMessage());
                CBI.getStatusBar().insertMessage("Not connected to Server");
                return Versions;
            }


            Enumeration e=tf.elements();
            Enumeration f=tf.elements();

            int count=0;

            while (f.hasMoreElements()) {
                f.nextElement();
                count++;
            }



            Versions = new CBIVersion[count+1];
            Versions[0] = new CBIVersion();  // "Now" Version


            for (int i=0; i<count; i++) {
                TelosFrame tframe=(TelosFrame)(e.nextElement());

                i5.cb.telos.frame.Label labCategory= (i5.cb.telos.frame.Label)(tframe.getCategories().elements().nextElement());

                i5.cb.telos.frame.Property prp = (i5.cb.telos.frame.Property)(tframe.getPropertiesInCategory(labCategory).elements().nextElement());

                String time1=prp.getTarget().toString();
                String time=time1.substring(4,time1.length()-2);
                Versions[i+1]=new CBIVersion((tframe.objectName()).toString(),time);
            }

            return Versions;


        }
        catch (CBException e)  {
            CBI.getStatusBar().insertMessage("Telos Parser Error");
            TelosParserError(e.getHelpText());
            return Versions;
        }
        catch (java.rmi.RemoteException e2)  {
            CBI.getStatusBar().insertMessage("RMI Exception");
            return Versions;
        }
    }




    public String[] asParseObjectNames(String sObjectNames) {
 //       CBI.getStatusBar().insertMessage("Preprocessing Telos object names");
        TelosParser tpParser=new TelosParser(new StringReader(sObjectNames));

        ObjectNames on;
        try {
            on=tpParser.objectNames();
        }
        catch (ParseException pe) {
            TelosParserError(pe.getMessage());
            CBI.getStatusBar().insertMessage("Telos Parser Error");
            return null;
        }
        catch (TokenMgrError tme) {
            TelosParserError(tme.getMessage());
            CBI.getStatusBar().insertMessage("Telos Parser Error");
            return null;
        }

        Enumeration e=on.elements();
        Enumeration f=on.elements();

        int count=0;

        while (f.hasMoreElements()) {
            f.nextElement();
            count++;
        }

        String[] s= new String[count];

        for (int i=0; i<count; i++)
            s[i]=(e.nextElement()).toString();

        return s;
    }


    /**
     *   Function: <b> Parse Object Names </b> <BR>
     *
     *  @param sObjectNames
     *  @return true if parsing is successful or bCallTelosParser is false
     */
    public boolean parseObjectNames(String sObjectNames, boolean showError) {

        if (bCallTelosParser) {
//            CBI.getStatusBar().insertMessage("Preprocessing Telos object names");
            TelosParser tpParser=new TelosParser(new StringReader(sObjectNames+ "\n"));
            try {
                tpParser.objectNames();
            }
            catch (ParseException e) {
                if(showError)
                    TelosParserError(e.getMessage());
                CBI.getStatusBar().insertMessage("Telos Parser Error");
                return false;
            }
            catch (TokenMgrError tme) {
                if(showError)
                    TelosParserError(tme.getMessage());
                CBI.getStatusBar().insertMessage("Telos Parser Error");
                return false;
            }
//            CBI.getStatusBar().insertMessage("Telos frames successfully parsed!");
            return true;
        }
        else
            return true;
    }


    public void setCallTelosParser(boolean val) {
        bCallTelosParser=val;
    }

    public boolean getCallTelosParser() {
        return bCallTelosParser;
    }


    // setter and getter for the flag on showing line numbers in TelosEditor
    public void setShowLineNumbers(boolean val) {
        bShowLineNumbers=val;
        if (CBI != null && CBI.getActiveTelosEditor() != null)
           CBI.getActiveTelosEditor().updateLineNumbers();
    }

    public boolean getShowLineNumbers() {
        return bShowLineNumbers;
    }



    /**
     *   @param iTime TimeOut Time in millsec.
     */
    public void setTimeOut(int iTime) {
        try {
            if(cbc!=null)
                cbc.setTimeOut(iTime);
        }
        catch(java.rmi.RemoteException e) {}
    }
    /**
     *   @return the TimeOut Time
     */
    public int getTimeOut() {
        try {
            if (cbc!=null)
                return cbc.getTimeOut();
            else
                return 0;
        }
        catch(java.rmi.RemoteException e) {
            return 0;
        }
    }



    /**
     * @return the ConnectDialog
     */
    public ConnectDialog getConnectDialog() {
        return this.cdConnectDialog;
    }

    /**
     *   @param cdAConnectDialog value for property cdConnectDialog
     */

    public void setConnectDialog(ConnectDialog cdAConnectDialog) {
        this.cdConnectDialog = cdAConnectDialog;
    }

    /**
     * @exception java.io.IOException
     * @exception java.lang.Throwable
     */
    protected void finalize() throws IOException, java.lang.Throwable {
        super.finalize();
        if (isConnected()) {
            cancelMe();
        }
    }

    /**
     *
     * Try to start a local CBserver and connect to it. This requires that the platform supports
     * to start a local CBserver. It will only be attempted if CBIva's configuration does not
     * include the feature to use a public CBserver.
     *
     *  @param newPort portnumber to be used when starting the CBserver on localhost
     *
     *  @return true if the CBserver startup and connection was successful
     */

    public boolean tryStartLocalCBserverAndConnect(String newPort) {
        if (this.isConnected()) 
          return true;
        if (!i5.cb.CBConfiguration.getPublicCBserverHost().equals("none")) {
          return false;  // we do not start up a local CBserver if CBIva is
                         // configured to use a public CBserver
        }
        CBI.getStatusBar().insertMessage("Trying to start CBserver on localhost:" + newPort);
        boolean started = i5.cb.api.CBclient.startLocalCBserver(newPort);
        boolean enrolled = false;
        if (started) {
          CBI.getStatusBar().insertMessage("Trying to connect to " + "localhost" + ":" + newPort);
          long waittime = 200L;  // millisec
          for (int i=1; i<=15; i++) {
            enrolled = testEnroll(newPort);
            // System.out.println("Attempt to connect "+i);
            if (enrolled) {
              break;
            }
            CBI.getStatusBar().insertMessage("Attempt to connect #"+i);
            try {
              Thread.sleep(waittime);
            } catch (Exception e) {}
            waittime =+ waittime;
          }
        }
        CBI.repaint();
        if (enrolled) {
          CBI.getStatusBar().setStatus("localhost",newPort);
          CBI.getTelosEditor().setTitle("Telos Editor -- "+"localhost"+':'+newPort);
        }
        return enrolled;  
    }


    private boolean testEnroll(String newPort) {
        try {
          this.enrollMe("localhost", Integer.parseInt(newPort), "CBIva",
                                   CBIva.getProp("user.name", "unknownuser"));
          return true;
        } catch (Exception e) {
          return false;
        }
    }


   /** 
    * connect to a local (or public) CBserver. If not possible, then try to start a local CBserver and then
    * connect to it.
    */

    public void connectOrStartLocalCBserver() {

                String sHost=null;
                String sPort=null;
                try {
                    if(this.getConnectDialog() != null) {
                        sHost=this.getConnectDialog().getHost();
                        sPort=this.getConnectDialog().getPortString();
                    }
                    else {
                        String[] hostsAndPorts=i5.cb.CBConfiguration.getRecentServers();
                        String pubCBserver = i5.cb.CBConfiguration.getPublicCBserver();
                        // if public CBserver is defined then prefer it
                        if (!pubCBserver.equals("none")) {
                            sHost=i5.cb.CBConfiguration.getPublicCBserverHost();
                            sPort=i5.cb.CBConfiguration.getPublicCBserverPort();
                        } else if (hostsAndPorts.length > 1) {
                            sHost=hostsAndPorts[0];
                            sPort=hostsAndPorts[1];
                        }
                        else {
                            sHost="localhost";
                            sPort="4001";
                        }
                    }

                    CBI.getStatusBar().setStatus("Connecting");
                    CBI.getStatusBar().insertMessage("Trying to connect to " + sHost + ":" + sPort);
                    CBI.repaint();


                    this.enrollMe(sHost, Integer.parseInt(sPort), "CBIva",
                                      CBIva.getProp("user.name", "unknownuser"));
                }
                catch(CBException CBE) {
                    // if a connection to a running CBserver failed, then try to start a local
                    // CBserver in the background and connect
                    CBI.getStatusBar().setStatus("Upstarting");
                    CBI.getStatusBar().insertMessage("Starting a local CBserver on port 4001");
                    CBI.repaint();
                    boolean success = this.tryStartLocalCBserverAndConnect("4001");
                    if (!success)
                      System.out.println("Exception:" + CBE.getMessage());
                }
                if(this.isConnected()) {
                    CBI.EnableCommands(true);
                    CBI.getStatusBar().insertMessage("Connection to " + sHost + ":" + sPort +
                        " established");
                    CBI.getStatusBar().setStatus(sHost,sPort);
                    CBI.getTelosEditor().setTitle("Telos Editor -- "+sHost+':'+sPort);
                }
                else {
                    CBI.getStatusBar().insertMessage("Connection to " + sHost + ":" + sPort +
                        " failed, try again");
                }
                CBI.repaint();
    }


}
