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
/**
*   <b> for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.FrameBrowser
*   @see i5.cb.workbench.CBIva
*/
package i5.cb.workbench;

import i5.cb.CBConfiguration;
import i5.cb.CBException;
import i5.cb.graph.cbeditor.CBEditor;
import i5.cb.graph.cbeditor.CBFrame;

import java.awt.*;
import java.util.*;

import javax.swing.*;
import javax.swing.event.*;

/**  <BR>
*   Class:    <b> for CBIva  </b><BR>
*   Function: <b>  </b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see i5.cb.workbench
*   @see i5.cb.workbench.CBIva
*/
public class CBIva extends JFrame implements InternalFrameListener, HyperlinkListener {

    // For Server
    static JFrame jfServer=null;
    static ServerThread serverThread=null;

    public static final String CBIVA_VERSION = "2.2.00";
    public static final String CBIVA_DATE = "2020-05-31";
    public static final String JAVA_VERSION = System.getProperty("java.runtime.version");

    private JDesktopPane desktopPane;
    private CBEditor m_cbEditor;
    private boolean bLPIcall;
    private boolean bQRWindow;

    private boolean startedFromCBGraph = false;  // indicated whether this CBIva was started from CBGraph

    /**
    *   @return bLPIcall
    */
    public boolean getLPIcall()  {
        return bLPIcall;
    }

    /**
    *   @return bQRWindow
    */
    public boolean useQueryResultWindow()  {
        return bQRWindow;
    }

    public void setUseQueryResultWindow(boolean b)  {
        bQRWindow=b;
    }


    private String sLoadModel;

    /**
    *   @return LoadModel
    */
    public String getLoadModel()  {
        return sLoadModel;
    }

    /**
    *   @param s path to the model to be loaded
    */
    public void setLoadModel(String s)  {
        sLoadModel = s ;
        CBConfiguration.setLoadModelPath(s);
    }

    private CBIvaClient cbClient;

    /**
    *   @return CBIvaClient
    */
    public CBIvaClient getCBClient() {
        return cbClient;
    }

    private LogWindow logWindow;

    private TelosEditor teMain;
    private TelosEditor teActive;

    private StatusBar SB;

    /**
    *   @return StausBar of CBIva
    */
    public StatusBar getStatusBar() {
        return SB;
    }

    /**
    *   @return MenuBar of CBIva
    */
    public CBIMenuBar getCBIMenuBar() {
        return MenuBar;
    }

    /**
    *   @return LogWindow
    */
    public LogWindow getLogWindow() {
        return logWindow;
    }

    /**
    *   @return TelosEditor
    */
    public TelosEditor getTelosEditor() {
        return teMain;
    }

    private CBIToolBar ToolBar;
    private CBIMenuBar MenuBar;

    /**
    *   Function: <b> Enable the Commands in the ToolBar and MenuBar </b> <BR>
    *
    *   @param  b  <code>true</code>  if CBServer is connected  <BR>
    *             <code>false</code>  otherwise
    *
    */
    public void EnableCommands(boolean b) {
        // Enabele ToolBar; MenuBar
        ToolBar.EnableCommands(b);
        //    MenuBar.EnableCommands(b);
    }

    public boolean isConnected() {
        return cbClient.isConnected();
    }


    /**
    *   Function: <b> Returns the activ TelosEditor</b> <BR>
    *
    *   if no TelosEditor is activ return <code>null</code>
    *
    *   @return activ TelosEditor
    */
    public TelosEditor getActiveTelosEditor() {
        return teActive;
    }

    public void setActiveTelosEditor(TelosEditor te) {
        teActive=te;
    }

    private String sStart="Successfully started";

    private LoadWindow loadWindow;

    public CBIva() {
       this(true); // show LoadWindow when starting CBIva
    }

    public CBIva(boolean showLoadWindow) {
        CBConfiguration.openConfig();

        if (showLoadWindow) {
           loadWindow= new LoadWindow(this);
           loadWindow.setText("CBIva Client");
           // wait some milliseconds to let the user see the load window
           try {
                 Thread.sleep(50);  
               }
           catch (InterruptedException e) {}
        }

        cbClient = new CBIvaClient(this);  // cbClient initialisieren
        getParameter();

        if (showLoadWindow) 
          loadWindow.setText("CBIva Window");

        desktopPane=new JDesktopPane();
        this.getContentPane().add(desktopPane,BorderLayout.CENTER);

        //Window Options
        this.setLocation(155,95);
        this.setTitle("CBIva - ConceptBase.cc User Interface in Java");
        this.setIconImage(this.LoadImage("CBIvaS.gif"));
        this.setSize(new Dimension(700,600)); // Fenstergroesse setzen
        if (showLoadWindow) 
          loadWindow.setText("Telos Editor/Log Window");
        initTeloslogWindow();
        if (showLoadWindow) {
          loadWindow.setText("ready");
          loadWindow.dispose();
        }
        this.getStatusBar().insertMessage("CBIva ready, running under Java " + JAVA_VERSION);
        this.setVisible(true);
    }


    /**
    * If the variable PublicCBserver is set to a value different from "none" then CBIva shall
    * attempt to connect to this CBserver on port 4001 when it is started
    */

    public void connectToPublicCBserverIfConfigured() {
       String pubCBserver = i5.cb.CBConfiguration.getPublicCBserverHost();
       try {
          // if public CBserver is defined then prefer it
           if (!pubCBserver.equals("none")) {
             String pubPort = i5.cb.CBConfiguration.getPublicCBserverPort();
             int port = Integer.parseInt(pubPort);
             this.getStatusBar().insertMessage("Trying to connect to " + pubCBserver + ":" + pubPort);
             cbClient.enrollMe(pubCBserver, port, "CBIva", CBIva.getProp("user.name", "unknownuser"));
             if (cbClient.isConnected()) {
                 this.EnableCommands(true);
                 this.getStatusBar().insertMessage("Connection to " + pubCBserver + ":" + pubPort  + " established");
                 this.getStatusBar().setStatus(pubCBserver,pubPort);
             }
           }
       } catch (Exception e) {
          System.err.println("CBIva Exception:" + e.getMessage());
          this.getStatusBar().insertMessage("Connection to public CBserver " 
                      + pubCBserver + " could not be established.");
       }
    }


    /**
    * try to connect to a local or public CBserver when CBIva is started as a standalone program
    */

   public void quickConnectCBserver() {
      cbClient.connectOrStartLocalCBserver();
   }



    private class WindowMenuItem extends JMenuItem{
		private JInternalFrame intFrame;

		public WindowMenuItem(String text,JInternalFrame reference){
			super(reference.getTitle());
			intFrame=reference;
		}

		public JInternalFrame getJif(){
			return intFrame;
		}
    }


    public void add(JInternalFrame jif) {
        if(jif.isClosed())
            return;
        desktopPane.add(jif);
        jif.addInternalFrameListener(this);
        jif.setVisible(true);
        WindowMenuItem mi=new WindowMenuItem(jif.getTitle(), jif);
        mi.addActionListener(new CBICommand(CBICommand.iWINDOWS, this));
        this.getCBIMenuBar().getWindowsMenu().add(mi);
    }

    public void add(JInternalFrame jif, Integer layer) {
        if(jif.isClosed())
            return;
        desktopPane.add(jif,layer);
        jif.addInternalFrameListener(this);
        jif.setVisible(true);
        WindowMenuItem mi=new WindowMenuItem(jif.getTitle(), jif);
        mi.addActionListener(new CBICommand(CBICommand.iWINDOWS, this));
        this.getCBIMenuBar().getWindowsMenu().add(mi);
    }

    /**
     * Moves JInteralFrame which is associated with mObj to front of the desktopane and selects it
     *
     * @param mObj WindowsMenuItem with associated JInternalFrame
     */
    public void showWindowsWithTitel(Object mObj){
    	try{
    		WindowMenuItem mItem=(WindowMenuItem)mObj;
    		JInternalFrame intFrame=mItem.getJif();
			if(desktopPane.getSelectedFrame()!= null){
				desktopPane.getSelectedFrame().setSelected(false);
			}
			if(intFrame.isIcon()){
				intFrame.setIcon(false);
			}
			desktopPane.setSelectedFrame(intFrame);
			desktopPane.moveToFront(intFrame);
			if(!intFrame.isSelected()){
				intFrame.setSelected(true);
			}
    	}
    	catch(Exception e){
            java.util.logging.Logger.getLogger("global").severe("Exception in CBIva.showWindowsWithTitle '" +
                e.getMessage());
        }
    }

    /**
    *   Function: <b> Load an Image from the CBIva Image Directory </b> <BR>
    *
    *   @param s Filename
    */
    public Image LoadImage(String s) {
        return Toolkit.getDefaultToolkit().getImage(getClass().getResource("gif/"+s));
    }

    /**
     * Wrapper for System.getProperty that catch SecurityException (if running inside
     * an applet).
     */
    public static String getProp(String sName, String sPreSet) {

        String s=null;
        try {
            s=System.getProperty(sName);
        }
        catch(SecurityException secex) {
        }

        if (s==null) {
            s=sPreSet;
        }
        return s;
    }


    private void getParameter() {
        this.bLPIcall = CBConfiguration.getLPICall();
        this.setUseQueryResultWindow(CBConfiguration.getUseQueryResultWindow());
        sLoadModel  = CBConfiguration.getLoadModelPath();
        cbClient.setTimeOut(CBConfiguration.getTimeout());
        cbClient.setCallTelosParser(CBConfiguration.getCallTelosParser());
    }


    private void initTeloslogWindow() {

        if (loadWindow != null)
          loadWindow.setText("StatusBar");
        SB         = new StatusBar(sStart);
        if (loadWindow != null)
          loadWindow.setText("ToolBar");
        ToolBar    = new CBIToolBar(this);


        this.addWindowListener(new CBICommand(this)); // Fensterereignisse in TECommand verarbeiten
        SB.setStatus(false);                 // Status auf DISCONNECTED setzen
        if (loadWindow != null)
          loadWindow.setText("MenuBar");
        MenuBar   = new CBIMenuBar(this);
        EnableCommands(false);                // unzulaessige Menues sperren

        if (loadWindow != null)
          loadWindow.setText("LogWindow");
        logWindow   = new LogWindow(this);
        if (loadWindow != null)
          loadWindow.setText("TelosEditor");

        teMain = new TelosEditor(this, logWindow);
        setActiveTelosEditor(teMain);
        this.getContentPane().add(SB,BorderLayout.SOUTH);
        this.getContentPane().add(ToolBar,BorderLayout.NORTH);
        this.setJMenuBar(MenuBar);
    }

    public void showAboutWindow() {
        JPanel jpAbout=new JPanel();
        jpAbout.setLayout(new BorderLayout());
        ImageIcon ICBIva = new ImageIcon(this.LoadImage("CBIva.gif"));
        JLabel LCBIva=new JLabel(ICBIva);
        jpAbout.add(LCBIva, BorderLayout.CENTER);

        JPanel panI5 = new JPanel();
        panI5.setLayout(new BorderLayout());
        panI5.add(new JLabel("Informatik 5, RWTH Aachen",JLabel.LEFT),BorderLayout.NORTH);
        panI5.add(new JLabel("52056 Aachen, Germany",JLabel.LEFT),BorderLayout.CENTER);
        JPanel panI5a = new JPanel();
        panI5a.setLayout(new BorderLayout());
        panI5a.add(new JLabel("http://conceptbase.cc/cbteam.html",JLabel.LEFT),BorderLayout.NORTH);
        panI5.add(panI5a,BorderLayout.SOUTH);

        JPanel panProg = new JPanel();
        panProg.setLayout(new BorderLayout());
        panProg.add(new JLabel("University of Skovde, IIT",JLabel.RIGHT),BorderLayout.NORTH);
        panProg.add(new JLabel("S-54128 Skovde, Sweden",JLabel.RIGHT),BorderLayout.CENTER);
        JPanel panProga = new JPanel();
        panProga.setLayout(new BorderLayout());
        panProga.add(new JLabel("manfred.jeusfeld@acm.org",JLabel.RIGHT),BorderLayout.NORTH);
        panProg.add(panProga,BorderLayout.SOUTH);


        JPanel panName = new JPanel();
        panName.setLayout(new GridLayout(4,1));
        panName.add(new JLabel("ConceptBase.cc User Interface in Java -- http://conceptbase.cc",JLabel.CENTER));
        panName.add(new JLabel("Version "+CBIVA_VERSION+" ("+CBIVA_DATE+")",JLabel.CENTER),BorderLayout.CENTER);
        panName.add(new JLabel("Copyright 1987-2021 by The ConceptBase Team. All rights reserved.",JLabel.CENTER));
        panName.add(new JLabel("Distributed under a FreeBSD-style copyright license.",JLabel.CENTER));
        panName.setBorder(new javax.swing.border.TitledBorder(javax.swing.border.LineBorder.createGrayLineBorder()));


        JPanel panSouth = new JPanel();
        panSouth.setLayout(new BorderLayout());
        panSouth.add(panName,BorderLayout.NORTH);
        panSouth.add(panI5,BorderLayout.WEST);
        panSouth.add(panProg,BorderLayout.EAST);

        jpAbout.add(panSouth, "South");
        JOptionPane.showMessageDialog(this,jpAbout,"About CBIva",JOptionPane.INFORMATION_MESSAGE);
    }

    // Methods for InternalFrameListener
    public void internalFrameOpened(InternalFrameEvent ife)  {}
    public void internalFrameClosing(InternalFrameEvent ife)  {
    }
    public void internalFrameClosed(InternalFrameEvent ife)  {
        JMenu jm=getCBIMenuBar().getWindowsMenu();
        for(int i=0; i < jm.getItemCount(); i++) {
            JMenuItem jmi=jm.getItem(i);
            if(jmi instanceof WindowMenuItem &&
               ((WindowMenuItem) jmi).getJif().equals(ife.getSource()))
                jm.remove(jmi);
        }
    }
    public void internalFrameIconified(InternalFrameEvent ife)  {}
    public void internalFrameDeactivated(InternalFrameEvent ife)  {}
    public void internalFrameDeiconified(InternalFrameEvent ife)  {}
    public void internalFrameActivated(InternalFrameEvent ife)  {
        if (ife.getInternalFrame() instanceof TelosEditor) {
            this.setActiveTelosEditor((TelosEditor) ife.getInternalFrame());
        }
    }


    public void setTimeoutOption() {
        String sRet=JOptionPane.showInputDialog(this,"Enter the timeout value in milli-seconds",new Integer(CBConfiguration.getTimeout()));

        if(sRet!=null) {
            this.getCBClient().setTimeOut(Integer.parseInt(sRet));
            CBConfiguration.setTimeout(Integer.parseInt(sRet));
        }
    }

    public void showRetellDialog() {

        JTextArea jtaUntellFrames=new JTextArea(this.getActiveTelosEditor().getTelosTextArea().getText(),5,30);
        JScrollPane jspUntell=new JScrollPane(jtaUntellFrames);
        JTextArea jtaTellFrames=new JTextArea(this.getActiveTelosEditor().getTelosTextArea().getText(),5,30);
        JScrollPane jspTell=new JScrollPane(jtaTellFrames);

        JPanel jpUntell=new JPanel();
        jpUntell.add(new JLabel("Untell:",JLabel.RIGHT),BorderLayout.WEST);
        jpUntell.add(jspUntell,BorderLayout.CENTER);
        JPanel jpTell=new JPanel();
        jpTell.add(new JLabel("    Tell:",JLabel.RIGHT),BorderLayout.WEST);
        jpTell.add(jspTell,BorderLayout.CENTER);

        JPanel jpMain=new JPanel(new BorderLayout());
        jpMain.add(jpUntell,BorderLayout.NORTH);
        jpMain.add(jpTell,BorderLayout.SOUTH);

        int ret=JOptionPane.showConfirmDialog(this,jpMain,"Enter Frames for Retell",JOptionPane.OK_CANCEL_OPTION);
        if(ret==JOptionPane.OK_OPTION) {
            this.getCBClient().retell(jtaUntellFrames.getText(),jtaTellFrames.getText());
        }
    }

    public void showLoadObjectDialog() {
        String sObject=JOptionPane.showInputDialog(this,"Enter Objectname","Load Object",JOptionPane.QUESTION_MESSAGE);
        if(sObject!=null) {
            String sResult=this.getCBClient().getObject(sObject);
            if(sResult!=null) {
                this.getActiveTelosEditor().setTelosText(sResult);
            }
        }
    }


    /**
    *   Shows a web page, preferably with the standard Web browser. If not possible, then uses
    *   the less elegant Java JEditorPane to display the web page.
    *   @param sUrl URL of a web page to be displayed
    */

    public void showWebPage(String sUrl) {
        String javaVersion = System.getProperty("java.version");
        String osName = System.getProperty("os.name");
	String javaXprefix = "1.";
	String linuxprefix = "Linux";
        int vIndex = javaVersion.indexOf(javaXprefix);
        int linuxFound = osName.indexOf(linuxprefix);

        if ( (vIndex != -1) && (javaVersion.charAt(vIndex+2) >= '6') 
                            && Desktop.isDesktopSupported() )     // use web browser for help pages on Java6 platforms
           {
           try {
               java.awt.Desktop.getDesktop().browse(java.net.URI.create(sUrl));
               }
           catch (Exception e) {
 //            System.out.println("CBIva.java: " + e.getMessage());
               showWebPageWithoutBrowser(sUrl);  // when calling the browser fails, we use the simple Java HTML 
               }
           }
        else
           {
           showWebPageWithoutBrowser(sUrl);  // no Java Desktop integration found
           }
    }


    /**
    *  showWebPageWithoutBrowser displays a web page with a JEditorPane. This is supported
    *  by older Java VMs like Java 1.4 and by Java VMs that have no Desktop integration.
    */

    public void showWebPageWithoutBrowser(String sUrl) {
       showWebPageWithoutBrowser(sUrl,true);
    }
    
    public void showWebPageWithoutBrowser(String sUrl, boolean linksEnabled) {

        JEditorPane editorPane = new JEditorPane();
        editorPane.setEditable(false);
        editorPane.setContentType("text/html");
        editorPane.setEditorKit(new javax.swing.text.html.HTMLEditorKit());

        try {
            java.net.URL helpURL = new java.net.URL(sUrl);
            editorPane.setPage(helpURL);
            if (linksEnabled)
              editorPane.addHyperlinkListener(this);
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this,"Could not open URL: " + sUrl +
                "\n" + e.getMessage(),"Error",JOptionPane.ERROR_MESSAGE);
        }
        JScrollPane jsp=new JScrollPane(editorPane);
        JFrame jfHelp=new JFrame(sUrl);  // use sUrl as window title
        jfHelp.getContentPane().add(jsp);
        jfHelp.setSize(750,550);
        jfHelp.setVisible(true);
    }


    public void showLicenseWindow() {
        JEditorPane editorPane = new JEditorPane();
        editorPane.setEditable(false);
        String sCB_HOME=null;
        try {
             sCB_HOME=System.getProperty("CB_HOME", "");
            }
        catch(SecurityException secex) {
            sCB_HOME="";
            }
        String sUrl="file:///"+sCB_HOME+"/CB-FreeBSD-License.txt";
        try {
            java.net.URL helpURL = new java.net.URL(sUrl);
            editorPane.setPage(helpURL);
            editorPane.addHyperlinkListener(this);
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this,"Could not open URL: " + sUrl + "\n" + e.getMessage(),"Error",JOptionPane.ERROR_MESSAGE);
        }
        JScrollPane jsp=new JScrollPane(editorPane);
        JFrame jfHelp=new JFrame("CB-FreeBSD-License.txt");
        jfHelp.getContentPane().add(jsp);
        jfHelp.setSize(750,550);
        jfHelp.setVisible(true);
    }

    public void hyperlinkUpdate(HyperlinkEvent e) {
        if (e.getEventType() == HyperlinkEvent.EventType.ACTIVATED) {
            JEditorPane pane = (JEditorPane) e.getSource();
            if (e instanceof javax.swing.text.html.HTMLFrameHyperlinkEvent) {
                javax.swing.text.html.HTMLFrameHyperlinkEvent  evt = (javax.swing.text.html.HTMLFrameHyperlinkEvent)e;
                javax.swing.text.html.HTMLDocument doc = (javax.swing.text.html.HTMLDocument)pane.getDocument();
                doc.processHTMLFrameHyperlinkEvent(evt);
            } else {
                try {
                    pane.setPage(e.getURL());
                } catch (Throwable t) {
                    t.printStackTrace();
                }
            }
        }
    }


    /**
    *   Function: <b> Start CBIva </b> <BR>
    */
    public static void main(String[] args) {
        // all interaction shall be in English since the CBserver also speaks English only
        Locale.setDefault(new Locale("en", "GB"));
        if (args.length > 0)
          if (args[0].equals("-v") || args[0].equals("-version")) {
                  System.out.println("CBIva " + CBIVA_VERSION + " (Java " + JAVA_VERSION + "), " + CBIVA_DATE );
                  System.out.println("Copyright 1987-2021 by The ConceptBase Team. All rights reserved.");
                  System.out.println("Original software by Rainer Langohr and others.");
                  System.out.println("This is free software. See http://conceptbase.cc for details.");
                  System.out.println("No warranty, not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.");
                  System.exit(0);
          }
        CBIva cbiva = new CBIva(true);
        // try to connect to CBserver 
        cbiva.quickConnectCBserver();
    }




    public static CBIva startCBIvaWithCBEditor(CBEditor cbe) {
       return startCBIvaWithCBEditor(cbe,true);
    }

    public static CBIva startCBIvaWithCBEditor(CBEditor cbe, boolean showModule) {
        // we allow only one Workbench for a CBEditor
        if(cbe.getWorkbench() != null){
            return cbe.getWorkbench();
        }
        CBIva CBI = new CBIva(false);  // without showing the LoadWindow
        CBIvaClient CBClient = CBI.getCBClient();
        CBFrame cbf =(CBFrame)cbe.getActiveGraphInternalFrame();
        CBI.setCBEditor(cbe);
        //connect if there is an active frame, and the frame is connected
        if(cbf != null){
            try {
                if(cbf.isConnected()){
                    java.lang.Integer Port = new Integer(cbf.getPort());
                    CBI.getStatusBar().insertMessage("Trying to connect...");
                    CBClient.enrollMe(cbf.getHost(),Port.intValue(), "CBIva",
                              System.getProperty("user.name","unknownuser"));
                }
            }
            catch (CBException cbex) {
                java.util.logging.Logger.getLogger("global").severe("Exception:" + cbex.getMessage());
            }
            if (CBClient.isConnected()) {
                  CBI.EnableCommands(true);
                  CBI.getStatusBar().insertMessage("Connection established to "+cbf.getHost()+":"+cbf.getPort());
                  // set CBIva to the same module context as the active CBFrame
                  CBClient.setModule(cbf.getShortContext());  
                  CBI.getStatusBar().setStatus(cbf.getHost(),cbf.getPort());
                  if (showModule) {
                     CBI.getActiveTelosEditor().getTelosTextArea().setText(CBClient.ask("listModule", "OBJNAMES", "FRAME"));
                     CBI.getActiveTelosEditor().getTelosTextArea().setCaretPosition(0);
                  }
            }
            else {
                  CBI.getStatusBar().insertMessage("Connection failed, try again");
            }
        }
        CBI.startedFromCBGraph = true;
        return CBI;
    }

    public void setCBEditor(CBEditor cbEditor){
        m_cbEditor= cbEditor;
    }
    public CBEditor getCBEditor(){
        return m_cbEditor;
    }

    /**
    if no CBEditor is present, then call exitCBIva(); 
    if started from CBGraph and CBGraph is still there, we only hide this CBIva
    */
    public void closeCBIva(){
        if (getCBEditor() == null && !startedFromCBGraph) {
            exitCBIva();
        } else {
            this.setVisible(false);
        }
    }


    /**
    disconnect from CBserver if connected and close CBIva including CBEditor (if present)
    */
    public void exitCBIva() {
        if(cbClient.isConnected()) {
            cbClient.cancelMe();
        }
        if(serverThread != null) {
            serverThread.stopServer();
        }
        i5.cb.CBConfiguration.storeConfig();
        try {
            if(getCBEditor() != null)
                getCBEditor().shutdown();
            System.exit(0);
        }
        catch(java.security.AccessControlException ace) {
            // probably running as applet so we just dispose
            dispose();
        }
    }
}
