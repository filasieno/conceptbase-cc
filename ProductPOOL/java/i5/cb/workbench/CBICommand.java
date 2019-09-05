/*
The ConceptBase.cc Copyright

Copyright 1987-2019 The ConceptBase Team. All rights reserved.

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
/**
 *   <b> CBICommand for CBIva 02.98  (ConceptBase) </b>
 *
 *   @see i5.cb.workbench.FrameBrowser
 *   @see i5.cb.workbench.CBIva
 */
package i5.cb.workbench;

import i5.cb.CBConfiguration;
import i5.cb.CBException;
import i5.cb.api.CBanswer;
import i5.cb.api.LocalCBclient;

import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.util.*;

import javax.swing.*;
import javax.swing.text.JTextComponent;

/**  <BR>
 *   Class:    <b> CBICommand for CBIva  </b><BR>
 *   Function: <b> Implements ActionListener for CBIva </b> <BR>
 *
 *   @version 0.8 beta
 *   @author    Rainer Langohr
 *
 *   @see java.awt.event.ActionListener
 *   @see i5.cb.workbench.CBIva
 */
public class CBICommand extends MouseAdapter implements ActionListener, WindowListener {

    /*
     *  iID_DIM sets the factor for the constants, for the comands the menus and the menuitems.
     *   Every menu gets a multiple of iID_DIM as identifier.
     *   Then every menuitem gets a "offset" as identifier.
     */
    public static final int iID_DIM=25;

    /**
     * public constant for  File-Menu
     */
    public static final int iFILE_MENU=0 * iID_DIM;

    /**
     * public constant for  Edit-Menu
     */
    public static final int iEDIT_MENU=1 * iID_DIM;

    /**
     * public constant for  Browse-Menu
     */
    public static final int iBROWSE_MENU=2 * iID_DIM;

    /**
     * public constant for  Options-Menu
     */
    public static final int iOPTIONS_MENU=3 * iID_DIM;

    /**
     * public constant for  Help-Menu
     */
    public static final int iHELP_MENU=4 * iID_DIM;

    /**
     * public constant for  Windows-Menu
     */
    public static final int iWINDOWS_MENU=5 * iID_DIM;

    /**
     * public constant for File|Connect
     */
    public static final int iCONNECT=iFILE_MENU + 0;

    /**
     * public constant for File|Disconnect
     */
    public static final int iDISCONNECT=iFILE_MENU + 1;

    /**
     * public constant for File|Load TelosEditor
     */
    public static final int iLOAD_TELOS=iFILE_MENU + 2;

    /**
     * public constant for File|Save TelosEditor
     */
    public static final int iSAVE_TELOS=iFILE_MENU + 4;

    /**
     * public constant for File|Load Model
     */
    public static final int iLOAD_MODEL=iFILE_MENU + 6;

    /**
     * public constant for File|Start CBserver
     */
    public static final int iSTART_SERVER=iFILE_MENU + 7;

    /**
     * public constant for File|Stop CBserver
     */
    public static final int iSTOP_SERVER=iFILE_MENU + 8;

    /**
     * public constant for File|Close
     */
    public static final int iCLOSE=iFILE_MENU + 9;

    /**
     * public constant for File|Exit
     */
    public static final int iEXIT=iFILE_MENU + 10;

    /**
     * public constant for Edit|Clear
     */
    public static final int iCLEAR=iEDIT_MENU + 0;

    /**
     * public constant for Edit|Cut
     */
    public static final int iCUT=iEDIT_MENU + 1;

    /**
     * public constant for Edit|Copy
     */
    public static final int iCOPY=iEDIT_MENU + 2;

    /**
     * public constant for Edit|Paste
     */
    public static final int iPASTE=iEDIT_MENU + 3;

    /**
     * public constant for Edit|Tell
     */
    public static final int iTELL=iEDIT_MENU + 5;

    /**
     * public constant for Edit|Untell
     */
    public static final int iUNTELL=iEDIT_MENU + 6;

    /**
     * public constant for Edit|Retell
     */
    public static final int iRETELL=iEDIT_MENU + 7;

    /**
     * public constant for Edit|Ask
     */
    public static final int iASK=iEDIT_MENU + 8;

    /**
     * public constant for Edit|Call Query
     */
    public static final int iCALL_QUERY=iEDIT_MENU + 9;

    /**
     * public constant for Edit|Load Object
     */
    public static final int iLOAD_OBJECT=iEDIT_MENU + 10;

    public static final int iPM_OBJECT_TREE=iEDIT_MENU + 11;

    /**
     * public constant for Edit| LPI Call
     */
    public static final int iLPI_CALL=iEDIT_MENU + 12;

    public static final int iQCONNECT=iEDIT_MENU + 13;


    /**
     * public constant for List Module button
     */
    public static final int iLIST_MODULE=iEDIT_MENU + 14;

    /**
     * public constant for Browse|Telos Editor
     */
    public static final int iTELOS_EDITOR=iBROWSE_MENU + 0;

    /**
     * public constant for Browse|Display Instances
     */
    public static final int iDISPLAY_INSTANCES=iBROWSE_MENU + 1;

    /**
     * public constant for Browse|Frame Browser
     */
    public static final int iFRAME_BROWSER=iBROWSE_MENU + 2;

    /**
     * public constant for Browse|Frame Editor
     */
    // public static final int iFRAME_EDITOR      = iBROWSE_MENU + 3;


    /**
     * public constant for Browse|Query Browser
     */
    public static final int iQUERY_BROWSER=iBROWSE_MENU + 3;

    /**
     * public constant for Browse|Function Browser
     */
    public static final int iFUNCTION_BROWSER=iBROWSE_MENU + 4;

    /**
     * public constant for Browse|Query Editor
     */
    public static final int iQUERY_EDITOR=iBROWSE_MENU + 5;

    /**
     * public constant for Browse|CB Graph Editor
     */
    public static final int iGRAPH_EDITOR=iBROWSE_MENU + 6;

    /**
     * public constant for Browse|Display all queries
     */
    public static final int iQUERY_BROWSER_ALL=iBROWSE_MENU + 7;

    /**
     * public constant for Options|Set Timeout
     */
    public static final int iSET_TIMEOUT=iOPTIONS_MENU + 0;

    /**
     * public constant for Options|Save Options
     */
    public static final int iSAVE_OPTIONS=iOPTIONS_MENU + 1;

    /**
     * public constant for Options|Look and Feel
     */
    public static final int iLOOK_AND_FEEL=iOPTIONS_MENU + 2;

    /**
     * public constant for Options|Show Query Result Window on
     */
    public static final int iQRWin=iOPTIONS_MENU + 4;

    /**
     * public constant for Options|Module Settings
     */
    public static final int iMODULE_DIALOG=iOPTIONS_MENU + 5;

    /**
     * public constant for Options|set Version
     */
    public static final int iVERSION_DIALOG=iOPTIONS_MENU + 6;

    /**
     * public constant for Options- Pre-Parse Telos Frames
     */
    public static final int iCALL_TELOS_PARSER=iOPTIONS_MENU + 7;

    /**
     * public constant for Options- Edit Options
     */
    public static final int iEDIT_OPTIONS=iOPTIONS_MENU + 8;

    /**
     * public constant for Options- Show Linenumbers
     */
    public static final int iSHOW_LINE_NUMBERS=iOPTIONS_MENU + 9;

    /**
     * public constant for Help|ConceptBase.cc Manual
     */
    public static final int iCONCEPTBASE_MANUAL=iHELP_MENU + 0;

    /**
     * public constant for Help|CB-Tutorial I
     */
    public static final int iCBTUT1=iHELP_MENU + 1;

    /**
     * public constant for Help|CB-Tutorial II
     */
    public static final int iCBTUT2=iHELP_MENU + 2;

     /**
     * public constant for Help|CB-Forum
     */
    public static final int iCBFORUM=iHELP_MENU + 3;

    /**
     * public constant for Help|About
     */
    public static final int iABOUT=iHELP_MENU + 4;

    /**
     * public constant for Help|License
     */
    public static final int iLICENSE=iHELP_MENU + 5;

    /**
     * public constant for Help|CB-Team
     */
    public static final int iCBTEAM=iHELP_MENU + 6;


    /**
     * public constant for Windows|All
     */
    public static final int iWINDOWS=iWINDOWS_MENU + 0;

    /**
     * public constant for iNOT_AVAILABLE
     */
    public static final int iNOT_AVAILABLE=999;


    /**
     * Das von der aktuellen Instanz dieser Klasse repr.sentierte Kommando
     * teTelosEditor liefert eine Referenz auf die Instanz der Klasse TelosEditor, der diese
     * TECommand-Instanz zugeordnet ist.
     *
     * @see i5.cb.workbench.TelosEditor
     */
    private int iIdentifier;

    /**
     * enth.lt Referenz auf die zugeordnete TelosEditor-Instanz
     *
     * @see i5.cb.workbench.TelosEditor
     */
    private CBIvaClient CBclient;
    private CBIva CBI;

    // for L&F
    private String sLookAndFeel;
    private JFrame jfRootFrame;
    private TelosEditor te;
    private JTextComponent TC;


    /**
     *   <b> Constructor  </b><BR>
     *
     *   @param iAnIdentifier  Identifier for the Command
     *   @param CBI      Parent CBIva
     */
    public CBICommand(int iAnIdentifier, CBIva CBI) {
        this.iIdentifier=iAnIdentifier;
        this.CBI=CBI;
        this.CBclient=CBI.getCBClient();
    }

    /**
     *   <b> Constructor  </b><BR>
     *
     *   @param iIdent  Identifier for the Command
     *   @param sNewLF     Name of new Look and Feel
     *   @param jfRoot     Root JFrame for new Look and Feel
     */
    public CBICommand(int iIdent, String sNewLF, JFrame jfRoot) {

        this.iIdentifier=iIdent;
        this.sLookAndFeel=sNewLF;
        this.jfRootFrame=jfRoot;

    }

    /**
     *   <b> Constructor  </b><BR>
     *
     *   @param iAnIdentifier  Identifier for the Command
     *   @param CBclient    a CBIvaClient
     */
    public CBICommand(int iAnIdentifier, CBIvaClient CBclient) {
        this.iIdentifier=iAnIdentifier;
        this.CBclient=CBclient;
    }

    /**
     *   Function: <b> Excecute the Commands </b> <BR>
     *
     *   @param event the ActionEvent for the Command
     *   @see java.awt.event.ActionEvent
     */
    public void actionPerformed(ActionEvent event) {
        if(CBI != null) {
            CBI.getStatusBar().insertMessage("");
            this.te=CBI.getActiveTelosEditor();
            if(te != null)
                this.TC=te.getTelosTextArea();
            else
                this.TC=null;
        }

        switch(iIdentifier) {
        /*
         * File|Connect
         */
        case iCONNECT: {
            if(CBclient.getConnectDialog() != null)
                CBclient.getConnectDialog().setVisible(true);
            else {
                ConnectDialog cd=new ConnectDialog(CBI);
                cd.setVisible(true);
            }
            break;
        }
        /*
         * Tool: Quick Connect:
         */
        case iQCONNECT:
            if(CBclient.isConnected()) {
                CBclient.cancelMe();
                CBI.EnableCommands(false);
                CBI.getStatusBar().setStatus(false);
                CBI.getStatusBar().insertMessage("Disconnect successful");
            }
            else {
                CBclient.connectOrStartLocalCBserver();
            }
            break;

            /*
             * File|Disconnect
             */
        case iDISCONNECT:
            if(CBclient.isConnected()) {
                CBclient.cancelMe();
                CBI.EnableCommands(false);
                CBI.getStatusBar().setStatus(false);
                CBI.getStatusBar().insertMessage("Disconnect successful");
            }
            break;
            /*
             * File|Load TelosEditor
             */
        case iLOAD_TELOS: {
            if(CBI.getActiveTelosEditor() == null) {
                JOptionPane.showMessageDialog(CBI, "No Telos Editor selected");
                return;
            }
            FileDialog fd=new FileDialog(CBI, "Load Telos Editor", FileDialog.LOAD);
            fd.setDirectory(CBI.getLoadModel());
            fd.setFile("*.sml;*.txt");
            fd.setFilenameFilter(new FilenameFilter(){
                                     public boolean accept(File dir, String name){
                                     return (name.endsWith(".sml") || name.endsWith(".txt"));
                                       }
                                });
            fd.setVisible(true);
            CBI.setLoadModel(fd.getDirectory());
            if(fd.getFile() != null) {
                try {
                    FileInputStream fis=new FileInputStream(fd.getDirectory() + fd.getFile());
                    StringBuffer sb=new StringBuffer();
                    int c=fis.read();
                    while(c >= 0) {
                        sb.append((char) c);
                        c=fis.read();
                    }
                    fis.close();
                    CBI.getActiveTelosEditor().getTelosTextArea().setText(sb.toString());
                }
                catch(IOException ioe) {
                    java.util.logging.Logger.getLogger("global").warning("Exception while reading from file:" +
                        ioe.getMessage());
                }
            }
            else {
                CBI.getStatusBar().insertMessage("No file selected.");
            }
        }
        break;
        /*
         * File|Save TelosEditor
         */
        case iSAVE_TELOS: {
            if(CBI.getActiveTelosEditor() == null) {
                JOptionPane.showMessageDialog(CBI, "No Telos Editor selected");
                return;
            }
            FileDialog fd=new FileDialog(CBI, "Save Telos Editor", FileDialog.LOAD);
            fd.setDirectory(CBI.getLoadModel());
            fd.setFile("*.sml;*.txt");
            fd.setFilenameFilter(new FilenameFilter(){
                                     public boolean accept(File dir, String name){
                                     return (name.endsWith(".sml") || name.endsWith(".txt"));
                                       }
                                });
            fd.setVisible(true);
            CBI.setLoadModel(fd.getDirectory());
            if(fd.getFile() != null) {
                try {
                    FileWriter fw=new FileWriter(fd.getDirectory() + fd.getFile());
                    fw.write(CBI.getActiveTelosEditor().getTelosTextArea().getText());
                    fw.close();
                }
                catch(IOException ioe) {
                    java.util.logging.Logger.getLogger("global").warning("Exception while reading from file:" +
                        ioe.getMessage());
                }
            }
            else {
                CBI.getStatusBar().insertMessage("No file selected.");
            }
        }
        break;
        /*
         * File|Load Model
         */
        case iLOAD_MODEL: {
            String sFilename=null;
            FileDialog fd=new FileDialog(CBI, "Load Model", FileDialog.LOAD);
            fd.setDirectory(CBI.getLoadModel());
            fd.setFile("*.sml;*.txt");

            // Wegen eines Fehlers im JDK 1.1.1 fuer Windows 95;
            // unter Windows 95 wird der uebergebene FilenameFilter hier MyFilenameFilte,
            // initialisiert mit "sml") ignoriert. Mit der hier verwendeten Methode werden
            // wenigstens auch unter Windows 95 zun.chst nur die gew.nschten Dateien
            // angezeigt. F.r andere Betriebssysteme haben wir allerdings doch noch einen
            // FilenameFilter implementiert (s.u., Klasse FilenameFilter), der eigentlich
            // die gew.nschte Verhaltensweise zeigen sollte.

            fd.setFilenameFilter(new FilenameFilter(){
                                     public boolean accept(File dir, String name){
                                     return (name.endsWith(".sml") || name.endsWith(".txt"));
                                       }
                                });
            fd.setVisible(true);
            while((sFilename != null) && (sFilename.endsWith("sml") == false)) {
                // Dieser Test ist wichtig, weil unter
                // Windows 95 der FilenameFilter
                // ignoriert wird.
                fd.setVisible(true);
            }
            CBI.setLoadModel(fd.getDirectory());
            if(fd.getFile() != null) {
                try {
                    FileInputStream fis=new FileInputStream(fd.getDirectory() + fd.getFile());
                    StringBuffer sb=new StringBuffer();
                    int c=fis.read();
                    while(c >= 0) {
                        sb.append((char) c);
                        c=fis.read();
                    }
                    fis.close();
                    CBclient.tell(sb.toString());
                }
                catch(IOException ioe) {
                    java.util.logging.Logger.getLogger("global").warning("Exception while reading from file:" +
                        ioe.getMessage());
                }
            }
            else {
                CBI.getStatusBar().insertMessage("No file selected.");
            }
        }
        break;
        /*
         * File|Start CBserver
         */
        case iSTART_SERVER: {
            if(CBIva.jfServer != null) {
                JOptionPane.showMessageDialog(CBI,
                    "You may only start ONE server within this user interface",
                                              "There is a server already running",
                                              JOptionPane.INFORMATION_MESSAGE);
                return;
            }

            if (CBclient.isConnected()) {
                 JOptionPane.showMessageDialog(CBI, "Disconnect from current CBserver before starting a new one",
                   "Already connected", JOptionPane.ERROR_MESSAGE);
                 return;
            }

            String CBserverCmd = CBConfiguration.getCBserverCmd();

            JPanel jp=new JPanel(new GridLayout(11, 2));

            jp.add(new JLabel("Port:"));
            JTextField jtfPort=new JTextField("4001", 10);
            jp.add(jtfPort);

            jp.add(new JLabel("Database:"));
            JTextField jtfDatabase=new JTextField("cbDB", 10);
            jp.add(jtfDatabase);

            jp.add(new JLabel("Source Mode:"));
            String[] sourceModes= {"off", "on"};
            JComboBox jcbSourceMode=new JComboBox(sourceModes);
            jcbSourceMode.setSelectedIndex(0);
            jp.add(jcbSourceMode);

            jp.add(new JLabel("Trace Mode:"));
            String[] traceModes= {"no", "minimal", "low", "high", "veryhigh"};
            JComboBox jcbTraceMode=new JComboBox(traceModes);
            jcbTraceMode.setSelectedIndex(0);
            jp.add(jcbTraceMode);

            jp.add(new JLabel("Update Mode:"));
            String[] updateModes= {"persistent", "nonpersistent"};
            JComboBox jcbUpdateMode=new JComboBox(updateModes);
            jcbUpdateMode.setSelectedIndex(1);
            jp.add(jcbUpdateMode);

            jp.add(new JLabel("Untell Mode:"));
            String[] untellModes= {"verbatim", "cleanup"};
            JComboBox jcbUntellMode=new JComboBox(untellModes);
            jcbUntellMode.setSelectedIndex(1);
            jp.add(jcbUntellMode);

            jp.add(new JLabel("Multi-user Mode:"));
            String[] MultiUserModes= {"enabled", "disabled"};
            JComboBox jcbMultiUserMode=new JComboBox(MultiUserModes);
            jcbMultiUserMode.setSelectedIndex(1);
            jp.add(jcbMultiUserMode);

            jp.add(new JLabel("Predicate Typing:"));
            String[] forceConcernedClassModes= {"off", "strict", "extended"};
            JComboBox jcbForceConcernedClass=new JComboBox(forceConcernedClassModes);
            jcbForceConcernedClass.setSelectedIndex(1);
            jp.add(jcbForceConcernedClass);

            jp.add(new JLabel("Cache Mode:"));
            String[] cacheModes= {"off", "transient", "keep"};
            JComboBox jcbCacheMode=new JComboBox(cacheModes);
            jcbCacheMode.setSelectedIndex(2);
            jp.add(jcbCacheMode);

            jp.add(new JLabel("ECA Mode:"));
            String[] ecaModes= {"off", "safe", "unsafe"};
            JComboBox jcbEcaMode=new JComboBox(ecaModes);
            jcbEcaMode.setSelectedIndex(1);
            jp.add(jcbEcaMode);

            int ret=JOptionPane.showConfirmDialog(CBI, jp, "Start CBserver: Parameters",
                                                  JOptionPane.OK_CANCEL_OPTION,
                                                  JOptionPane.QUESTION_MESSAGE);
            if(ret == JOptionPane.CANCEL_OPTION) {
                return;
            }

            CBI.getStatusBar().setStatus("Connecting");

            String DbLocation = CBConfiguration.getHomedLocation(jtfDatabase.getText());
            if(System.getProperty("os.name").indexOf("Windows") >= 0) {
                  CBserverCmd = "\""+CBserverCmd+"\"";  // put the Windows command into quotes for special chars
            }

            String dbOpt = "-d";
            if (jcbSourceMode.getSelectedItem().toString()=="on") {
                  dbOpt = "-db";
            }

            String[] cmdarray= {CBserverCmd, "-port", jtfPort.getText(),
                              dbOpt, DbLocation,
                              "-t", jcbTraceMode.getSelectedItem().toString(),
                              "-u", jcbUpdateMode.getSelectedItem().toString(),
                              "-U", jcbUntellMode.getSelectedItem().toString(),
                              "-mu", jcbMultiUserMode.getSelectedItem().toString(),
                              "-cc", jcbForceConcernedClass.getSelectedItem().toString(),
                              "-eca", jcbEcaMode.getSelectedItem().toString(),
                              "-c", jcbCacheMode.getSelectedItem().toString(),
                              "-a", CBIva.getProp("user.name", "unknown")};
            try {
                CBIva.jfServer=new JFrame("CBserver output");
                CBIva.jfServer.setDefaultCloseOperation(WindowConstants.DO_NOTHING_ON_CLOSE);
                JTextArea jta=new JTextArea(50, 100);
                JScrollPane jsp=new JScrollPane(jta);

                Process p=Runtime.getRuntime().exec(cmdarray);

                BufferedReader in=new BufferedReader(new InputStreamReader(p.getInputStream()));
                BufferedReader err=new BufferedReader(new InputStreamReader(p.getErrorStream()));
                CBIva.serverThread=new ServerThread(in, err,jta, Integer.parseInt(jtfPort.getText()));
                CBIva.serverThread.start();

                JButton jb=new JButton("Stop CBserver");
                jb.addActionListener(new ActionListener() {
                    public void actionPerformed(ActionEvent e) {
                        if(CBclient.isConnected()) {
                            CBclient.cancelMe();
                            CBI.EnableCommands(false);
                            CBI.getStatusBar().setStatus(false);
                        }
                        CBIva.serverThread.stopServer();
                        CBIva.jfServer.setVisible(false);
                        CBIva.jfServer.dispose();
                        CBIva.jfServer=null;
                        CBIva.serverThread=null;
                    }
                });
                CBIva.jfServer.getContentPane().add(jsp, BorderLayout.CENTER);
                CBIva.jfServer.getContentPane().add(jb, BorderLayout.SOUTH);
                CBIva.jfServer.setSize(550, 200);
                CBIva.jfServer.setLocation(80,50);
                CBIva.jfServer.setVisible(true);
                if (jcbTraceMode.getSelectedIndex() == 0)  // no CBserver messages are being displayed
                   CBIva.jfServer.setState(Frame.ICONIFIED); // minimize the window with the CBserver output

                long curTime=System.currentTimeMillis();
                while(!CBIva.serverThread.isReady() && (System.currentTimeMillis() - curTime) < 40000) {
                    Thread.sleep(250);
                    Thread.yield();
                }
                if(!CBIva.serverThread.isReady()) {
                    CBI.getStatusBar().insertMessage(
                        "Started server not yet ready!? No Connection established!");
                    return;
                }
                if(CBclient.isConnected())
                    return;
                String sPort = jtfPort.getText();
                try {
                    CBI.getStatusBar().insertMessage("Trying to connect to localhost:" + sPort);
                    CBclient.enrollMe("localhost", Integer.parseInt(sPort),
                                      "CBIva", System.getProperty("user.name", "unknown"));
                }
                catch(CBException CBE) {
                    System.out.println("Exception:" + CBE.getMessage());
                }
                if(CBclient.isConnected()) {
                    CBI.EnableCommands(true);
                    CBI.getStatusBar().insertMessage("Connection established to localhost:"+sPort);
                    CBI.getStatusBar().setStatus("localhost",sPort);
                }
                else {
                    CBI.getStatusBar().insertMessage("Connection failed, try again");
                }
                CBI.repaint();
            }
            catch(Exception e) {
                System.out.println("Exception: " + e.getMessage());
            }

        }
        break;
        /*
         * File|Stop Server
         */
        case iSTOP_SERVER:
            if(CBclient.isConnected()) {
                if(CBIva.jfServer != null) {
                    CBclient.cancelMe();
                    CBIva.serverThread.stopServer();
                    CBIva.jfServer.dispose();
                    CBIva.jfServer=null;
                    CBIva.serverThread=null;
                    CBI.getStatusBar().insertMessage("Server stopped");
                    CBI.EnableCommands(false);
                    CBI.getStatusBar().setStatus(false);
                }
                else {
                    CBanswer answer=CBclient.stopServer();
                    if(answer.getCompletion() == CBanswer.OK) {
                        CBI.getStatusBar().insertMessage("Server stopped");
                        CBI.EnableCommands(false);
                        CBI.getStatusBar().setStatus(false);
                    }
                    else {
                        CBI.getStatusBar().insertMessage("Server could not be stopped");
                    }
                }
            }
            break;

            /*
             * File|Close
             */
        case iCLOSE:
            CBI.getStatusBar().setStatus("Closing ...");
            CBI.closeCBIva();
            break;

            /*
             * File|Exit
             */
        case iEXIT:
            CBI.getStatusBar().setStatus("Exiting ...");
            CBI.exitCBIva();
            break;

            /*
             * Edit|Cut
             */
        case iCUT:
            if(TC == null) {
                CBI.getStatusBar().insertMessage("no Text Field selected");
            }
            else {
                TC.cut();
            }
            break;
            /*
             * Edit|Copy
             */
        case iCOPY:
            if(TC == null) {
                CBI.getStatusBar().insertMessage("no Text Field selected");
            }
            else {
                TC.copy();
            }
            break;
            /*
             * Edit|Paste
             */
        case iPASTE:
            if(TC == null) {
                CBI.getStatusBar().insertMessage("no Text Field selected");
            }
            else {
                TC.paste();
            }
            break;
            /*
             * Edit|Clear
             */
        case iCLEAR:
            if(TC == null) {
                CBI.getStatusBar().insertMessage("no Text Field selected");
            }
            else {
                TC.setText("");
            }
            break;
            /*
             * Edit|Tell
             *
             */
        case iTELL:
            if(te == null) {
                CBI.getStatusBar().insertMessage("no Telos Editor selected");
            }
            else {
                CBI.getStatusBar().setStatus("TELL");
                CBclient.tell(te.getTelosTextArea().getText());
                CBI.getStatusBar().setStatus(true);
            }
            break;
            /*
             * Edit|Untell
             *
             */
        case iUNTELL:
            if(te == null) {
                CBI.getStatusBar().insertMessage("no Telos Editor selected");
            }
            else {
                CBI.getStatusBar().setStatus("UNTELL");
                CBclient.untell(te.getTelosTextArea().getText());
                CBI.getStatusBar().setStatus(true);
            }
            break;
            /*
             * Edit|Retell
             */
        case iRETELL:
            CBI.showRetellDialog();
            break;
            /*
             * Edit|Ask
             */
        case iASK: {
            if(te == null) {
                CBI.getStatusBar().insertMessage("no Telos Editor selected");
            }
            else {
                CBI.getStatusBar().setStatus("ASK");
                CBclient.ask(te.getTelosTextArea().getText(), "FRAMES", "FRAME", te);
                CBI.getStatusBar().setStatus(true);
            }
        }
        break;
        /*
         * Edit|Call Query
         */
        case iCALL_QUERY: {
            if(te == null) {
                CBI.getStatusBar().insertMessage("no Telos Editor selected");
            }
            else {
                CBI.getStatusBar().setStatus("ASK");
                String result=CBclient.ask(te.getTelosTextArea().getText(), "OBJNAMES", "FRAME");
                CBI.getStatusBar().setStatus(true);
                if(!result.equals("")) {
                    new QueryResultWindow(result, CBI);
                }
            }
        }
        break;

/* FrameTree no longer in use since it depends on the old Motif package;
   It does not compile under Java 9 anymore, issue #6
        case iPM_OBJECT_TREE: {
            if(te == null) {
                CBI.getStatusBar().insertMessage("no Telos Editor selected");
            }
            else {
                String sObject=te.getTelosTextArea().getSelectedText();
                if(sObject != null) {
                    FrameTree ftObject=new FrameTree(sObject, te);
                    CBI.add(ftObject);
                }
                else
                    te.getCBIva().getStatusBar().insertMessage("No Object Selected");
            }
        }
        break;
*/

        /*
         * Edit|Load Object
         */
        case iLOAD_OBJECT:
            CBI.showLoadObjectDialog();
            break;
        /*
         * List Module button
         */
        case iLIST_MODULE:
            CBI.getStatusBar().setStatus("LIST MODULE");
            te.getTelosTextArea().setBackground(new Color(230,230,230));
            te.paintImmediately(te.getBounds());
            String modulecontent=CBclient.ask("listModule", "OBJNAMES", "FRAME");
            if(!modulecontent.equals("")) {
               new QueryResultWindow(modulecontent, CBI);
            }
            te.getTelosTextArea().setBackground(Color.white);
            CBI.getStatusBar().setStatus(true);
            break;
            /*
             * Edit|LPI Call
             */
        case iLPI_CALL:
            if(te == null) {
                CBI.getStatusBar().insertMessage("no Telos Editor selected");
            }
            else {
                String result=CBclient.LPIcall(te.getTelosTextArea().getText());
                if(!result.equals(""))
                    te.getTelosTextArea().setText(result);
            }
            break;
            /*
             * Browse|Telos Editor
             */
        case iTELOS_EDITOR: {
            TelosEditor TEditor=new TelosEditor(CBI);
            CBI.add(TEditor);
            break;
        }
        /*
         * Browse|Display Instances
         */
        case iDISPLAY_INSTANCES: {
            InstanceDialog idDialog=new InstanceDialog(CBI);
            CBI.add(idDialog);
            break;
        }
        /*
         * Browse|Frame Browser
         */
        case iFRAME_BROWSER: {
            FrameBrowser fbBrowser=new FrameBrowser(CBI);
            CBI.add(fbBrowser);
            break;
        }
        /*
         * Browse|Frame Editor
         */
        /*             case iFRAME_EDITOR:
         {
          String[] s= {"test1","test2","test3"};


          AttributeLayout alObjectName
            = new FETextField("Objektname",null,
               AttributeLayout.NECESSARY,null,s);

          AttributeLayout alName
            = new FETextField("Name","name",
               AttributeLayout.NECESSARY+AttributeLayout.STRING,
               null,s);

          AttributeLayout alAdresse
            = new FETextArea("Adresse","address",
              AttributeLayout.NECESSARY+AttributeLayout.STRING,
              null,s);

          AttributeLayout alAbteilung
            = new FEComboBox("Abteilung","dept",
              0,"find_instances[Department/class]",s);

          AttributeLayout alGehalt
            = new FETextField("Gehalt","salary",
               AttributeLayout.INTEGER,null,s);

          AttributeLayout aalAttributes[] =
           { alName, alAdresse,alAbteilung,alGehalt};

          LayoutDefinition ldEmpLayout=new LayoutDefinition ("Employee",
                      "Geben Sie die Daten fuer einen Angestellten ein.",
                      alObjectName,aalAttributes);

          FrameEditor feWindow = new FrameEditor (CBclient.getCBClient() ,ldEmpLayout);

          CBI.add(feWindow);



          break;
         }
         */

        case iQUERY_BROWSER: {
            String[] buttonLabels= {"Ask", "Telos Editor", "Cancel"};
            String result=CBclient.ask("find_instances[vQueryClass/class]", "OBJNAMES", "LABEL");
            String[] listElements=CBclient.asParseObjectNames(result);

            QueryBrowser qb=new QueryBrowser(CBI, buttonLabels, listElements, "Display Queries");
            CBI.add(qb);
            break;
        }

        case iQUERY_BROWSER_ALL: {
            String[] buttonLabels= {"Ask", "Telos Editor", "Cancel"};
            String result=CBclient.ask("find_instances[QueryClass/class]", "OBJNAMES", "LABEL");
            String[] listElements=CBclient.asParseObjectNames(result);

            QueryBrowser qb=new QueryBrowser(CBI, buttonLabels, listElements, "Display All Queries");
            CBI.add(qb);
            break;
        }

        case iFUNCTION_BROWSER: {
            String[] buttonLabels= {"Call", "Telos Editor", "Cancel"};
            String result=CBclient.ask("find_instances[Function/class]", "OBJNAMES", "LABEL");
            String[] listElements=CBclient.asParseObjectNames(result);

            QueryBrowser qb=new QueryBrowser(CBI, buttonLabels, listElements, "Display Functions");
            CBI.add(qb);
            break;
        }

        /*
         * Browse|Query Editor
         */
        case iQUERY_EDITOR: {
            QueryEditor QE=new QueryEditor(CBI);
            CBI.add(QE);
            break;
        }
        case iGRAPH_EDITOR: {
            Thread th=new Thread() {
                public void run() {
                    CBI.setCBEditor(i5.cb.graph.cbeditor.CBEditor.startCBEditorWithWorkbench(CBI,
                        CBI.getCBClient()));
                }
            };
            th.start();
            break;
        }
        /*
         * Options|Set Options
         */
        case iSET_TIMEOUT:
            CBI.setTimeoutOption();
            break;
            /*
             * Options|Save Options
             */
        case iSAVE_OPTIONS:
            i5.cb.CBConfiguration.storeConfig();
            break;
            /*
             * Options| Look And Feel
             */
        case iLOOK_AND_FEEL:
            try {
                UIManager.setLookAndFeel(sLookAndFeel);
                SwingUtilities.updateComponentTreeUI(jfRootFrame);
            }
            catch(Exception e) {
                System.out.println("Sorry, Look And Feel not supported by this platform!");
                System.out.println(e.getMessage());
            }
            break;
            /*
             * Options| Query Result Window on
             */
        case iQRWin:
            boolean bQRW=!CBI.useQueryResultWindow();
            CBI.setUseQueryResultWindow(bQRW);
            i5.cb.CBConfiguration.setUseQueryResultWindow(bQRW);
            break;

            /*
             * OPTIONS|Module Settings
             */
        case iMODULE_DIALOG: {
            String[] buttonLabels= {"Change", "Cancel"};
            String result=CBclient.findModules();
            String[] listElements=CBclient.asParseObjectNames(result);

            ModuleDialog dlg=new ModuleDialog(CBI, CBclient.getModule(), buttonLabels, listElements);
            dlg.setVisible(true);
            CBI.add(dlg, JLayeredPane.MODAL_LAYER);
            break;

        }

        /*
         * OPTIONS|Set Version
         */
        case iVERSION_DIALOG: {
            String[] buttonLabels= {"Change", "New Version", "Cancel", "Help"};
            CBIVersion currentVersion=CBclient.getVersion();

            CBIVersion[] listElements=CBclient.getVersions();

            VersionDialog dlg=new VersionDialog(CBI, currentVersion, buttonLabels, listElements);
            dlg.setVisible(true);
            CBI.add(dlg, JLayeredPane.MODAL_LAYER);
            break;

        }
        case iCALL_TELOS_PARSER: {
            if(event.getSource() instanceof JCheckBoxMenuItem) {
                JCheckBoxMenuItem jcmi=(JCheckBoxMenuItem) event.getSource();
                CBI.getCBClient().setCallTelosParser(jcmi.isSelected());
                i5.cb.CBConfiguration.setCallTelosParser(jcmi.isSelected());
            }
            break;
        }

        case iSHOW_LINE_NUMBERS: {
            if(event.getSource() instanceof JCheckBoxMenuItem) {
                JCheckBoxMenuItem jcmi=(JCheckBoxMenuItem) event.getSource();
                CBI.getCBClient().setShowLineNumbers(jcmi.isSelected());
                i5.cb.CBConfiguration.setShowLineNumbers(jcmi.isSelected());
            }
            break;
        }

        case iEDIT_OPTIONS: {
            Properties props=CBConfiguration.getProperties();
            Enumeration enPropNames=props.propertyNames();
            ArrayList alPropNames=new ArrayList();
            while(enPropNames.hasMoreElements()) {
                String propName=(String) enPropNames.nextElement();
                if(propName.indexOf("For_")<0)
                    alPropNames.add(propName);
            }
            JPanel jp=new JPanel(new GridLayout(alPropNames.size(),2));
            ArrayList alTextFields=new ArrayList(alPropNames.size());
            for(int i=0;i<alPropNames.size();i++) {
                JLabel jl=new JLabel((String) alPropNames.get(i));
                jp.add(jl);
                String propValue=props.getProperty((String) alPropNames.get(i));
                int maxLen=propValue.length()<40 ? propValue.length() : 40;
                JTextField jtf=new JTextField(propValue,maxLen);
                jp.add(jtf);
                alTextFields.add(jtf);
            }
            int ret=JOptionPane.showConfirmDialog(CBI, jp, "Edit Options",
                                                  JOptionPane.OK_CANCEL_OPTION,
                                                  JOptionPane.QUESTION_MESSAGE);
            if(ret == JOptionPane.CANCEL_OPTION) {
                return;
            }
            else {
                for(int i=0;i<alPropNames.size();i++) {
                    props.setProperty((String) alPropNames.get(i),((JTextField) alTextFields.get(i)).getText());
                }
            }
            break;
        }

        /*
         * Help|ConceptBase Manual
         */
        case iCONCEPTBASE_MANUAL:
            CBI.showWebPage("http://conceptbase.sourceforge.net/userManual81/");
            break;

        /*
         * Help|ConceptBase Tutorial 1
         */
        case iCBTUT1:
            CBI.showWebPage("http://conceptbase.sourceforge.net/cbTutorial/");
            break;

        /*
         * Help|ConceptBase Tutorial 2
         */
        case iCBTUT2:
            CBI.showWebPage("http://conceptbase.cc/cbTutorial2/");
            break;

        /*
         * Help|CB-Forum
         */
        case iCBFORUM:
            CBI.showWebPage("http://conceptbase.cc/CB-Forum.html");
            break;
            /*
             * Help|About
             */
        case iABOUT:
            CBI.showAboutWindow();
            break;
             /*
             * Help|License
             */
        case iLICENSE:
            CBI.showLicenseWindow();
            break;
             /*
             * Help|CB-Team
             */
        case iCBTEAM:
            // show with disabled hyperlinks
            CBI.showWebPageWithoutBrowser("http://conceptbase.cc/cbteam.html",false);
            break;

            /*
             * Windows
             */
        case iWINDOWS:
            CBI.showWindowsWithTitel(event.getSource());
            break;
        }
    }



    /**
     *   <b> alternativ Constructor  </b><BR>
     *
     *   The iIdentificator is set to iNOT_AVAILABLE.
     *   The Constructor is used to creakte a TECommand without a
     *   special Command  (for WindowListener and MouseListener).
     *
     *  @param CBI parent CBIva
     *
     *  @see i5.cb.workbench.CBIva
     */
    public CBICommand(CBIva CBI) {
        this(iNOT_AVAILABLE, CBI);
    }

    /**
     * @see WindowListener#windowClosed
     */
    public void windowClosed(WindowEvent event) {}

    /**
     * @see WindowListener#windowDeiconified
     */
    public void windowDeiconified(WindowEvent event) {}

    /**
     * @see WindowListener#windowIconified
     */
    public void windowIconified(WindowEvent event) {}

    /**
     * @see WindowListener#windowActivated
     */
    public void windowActivated(WindowEvent event) {}

    /**
     * @see WindowListener#windowDeactivated
     */
    public void windowDeactivated(WindowEvent event) {}

    /**
     * @see WindowListener#windowOpened
     */
    public void windowOpened(WindowEvent event) {}

    /**
     * @see WindowListener#windowClosing
     *
     * Shut down connection and exit
     *
     * @see java.lang.System#exit
     */
    public void windowClosing(WindowEvent event) {
        CBI.getStatusBar().setStatus(byeString());
        if(CBclient.isConnected()) {
            CBclient.cancelMe();
        }
        if(CBIva.serverThread != null) {
            CBIva.serverThread.stopServer();
        }
        if(CBI.getCBEditor() != null) {
            CBI.setVisible(false);
            CBI.getCBEditor().setWorkbench(null);
        }
        else {
            System.exit(0);
        }
    }

    /* print famous last word */
    private static String byeString() {
      String[] lastWords = {"Bye :)", "Why?", "See ya!", "Schaaaade",
                           "Und weg", "Wrooom", "Come back!", "Model!", "foo!=bar",
                           "(0,0,NUL,0)", "(1,0,IN,0)", "X=X"}; 
      return lastWords[(int) (java.lang.System.currentTimeMillis() % lastWords.length)];
    }

}

class ServerThread extends Thread {

    private JTextArea jta;
    private BufferedReader in;
    private int port;
    private boolean bIsReady=false;
    private boolean bDoIt=true;
    private ErrorReaderThread errReaderThread;

    public ServerThread(BufferedReader inReader, BufferedReader errReader, JTextArea textarea,
                        int portnumber) {
        in=inReader;
        errReaderThread=new ErrorReaderThread(errReader, textarea);
        jta=textarea;
        port=portnumber;
        errReaderThread.start();
    }

    public void run() {
        String line=null;
        while(bDoIt) {
            try {
                line=in.readLine();
            }
            catch(Exception e) {}
            if(!bIsReady && line!=null && line.indexOf("ready") > 0) {
                bIsReady=true;
            }
            //if(!bIsReady)
            //    sleep(1000);
            synchronized(jta) {
                jta.append(line);
                jta.append("\n");
                if(jta.getLineCount() > 300) {
                    jta.setSelectionStart(0);
                    try {
                        jta.setSelectionEnd(jta.getLineEndOffset(100));
                    }
                    catch(javax.swing.text.BadLocationException ble) {}
                    jta.replaceSelection("");
                }
                jta.setCaretPosition(jta.getText().length());
            }
        }
    }

    public void stopServer() {
        try {
            LocalCBclient cb=new LocalCBclient("localhost", port, "StopServer",
                                               CBIva.getProp("user.name", "unknown"));
            cb.stopServer();
        }
        catch(CBException cbex) {
            System.out.println("Exception while trying to stop server:" + cbex.getMessage());
        }
        bDoIt=false;
        errReaderThread.stopThread();
    }

    public boolean isReady() {
        return bIsReady;
    }

    class ErrorReaderThread extends Thread {

        private BufferedReader errReader;
        private boolean bDoIt=true;
        private JTextArea jta;

        public ErrorReaderThread(BufferedReader err, JTextArea jta) {
            errReader=err;
            this.jta=jta;
        }

        public void run() {
            String errorLine=null;
            while(bDoIt) {
                try {
                    errorLine=errReader.readLine();
                }
                catch(Exception e) {}
                if(errorLine!=null && errorLine.length()>0) {
                    synchronized(jta) {
                        jta.append(errorLine);
                        jta.append("\n");
                        if(jta.getLineCount() > 300) {
                            jta.setSelectionStart(0);
                            try {
                                jta.setSelectionEnd(jta.getLineEndOffset(100));
                            }
                            catch(javax.swing.text.BadLocationException ble) {}
                            jta.replaceSelection("");
                        }
                        jta.setCaretPosition(jta.getText().length());
                    }
                }
            }
        }

        public void stopThread() {
            bDoIt=false;
        }
    }

}

