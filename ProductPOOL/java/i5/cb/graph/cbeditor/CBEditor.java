/*
The ConceptBase.cc Copyright

Copyright 1987-2026 The ConceptBase Team. All rights reserved.

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
package i5.cb.graph.cbeditor;

import i5.cb.CBConfiguration;
import i5.cb.graph.*;
import i5.cb.graph.diagram.DiagramNode;
import i5.cb.graph.cbeditor.StringArray;
import i5.cb.workbench.*;
import i5.cb.api.CBanswer;
import i5.cb.api.CBclient;

import java.applet.Applet;
import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.io.File;
import java.util.*;

import java.awt.*;
import javax.swing.*;
import javax.swing.text.DefaultStyledDocument;

// for more modern FlatLight Look&Feel
import com.formdev.flatlaf.FlatLightLaf;
import com.formdev.flatlaf.ui.FlatListUI;

import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;


/**
 * The CBEditor is the main class for the ConceptBase application. It can
 * contain several {@linkCBFrame}s and controls the ToolBar and the MenuBar.
 *
 * @author <a href="mailto:">Tobias Latzke </a>
 * @version 1.0
 * @since 1.0
 * @see GraphEditor
 */
public class CBEditor extends GraphEditor {

    private CBIva m_CBIva;

    private boolean m_writeCBModule = false;
    private boolean m_readCBModule = false;
    private boolean m_dumpSourceFiles= false;
    private boolean m_CommandLineOptionsPresent = false;
    private boolean m_demoMode = false;
    private boolean m_resyncMode = false;
    private String m_saveDiagramMode = null;
    private boolean m_revalidateMode = false;

    public StringArray gelFilenames = null;
    private String m_overrideHost = null;
    private String m_overridePort = null;

    // link category for "shows links between marked objects" button
    private String sSessionLinkCategory = CBConfiguration.getShowLinkCategory();  

    public static final String CBGRAPH_VERSION = "3.0.02";
    public static final String CBGRAPH_DATE = "2025-10-09";
    public static final String JAVA_VERSION = System.getProperty("java.runtime.version");

    /**
     * Creates a new <code>CBEditor</code> instance with Title 'Concept Base
     * Editor', a toolbar, but no infoWindow. Extends MenuBar and ToolBar by
     * ConceptBase specific items/buttons.
     */
    public CBEditor(CBEditorApplet applet) {
        super("ConceptBase.cc " + CBConstants.CBEDITOR_NAME, false, true, (Applet) applet);
        setLocation(110, 110);
        extendMenuBar();
        extendToolBar();
        currentLayoutDir = new File(CBConfiguration.getLoadLayoutPath());

        // set icon for CBGraph need to use resources/... instead /resources/... for an unknown reason
        java.net.URL url = ClassLoader.getSystemResource("resources/graph_resources/CBGraphS.gif");
        this.setIconImage(getToolkit().getImage(url));   

        changeStatusString(getCBBundle().getString("Status_NotConnected"));

        this.addWindowListener(new java.awt.event.WindowAdapter() {
            public void windowClosed(java.awt.event.WindowEvent e) {
                CBConfiguration.storeConfig();
                shutdown();
            }

            public void windowClosing(java.awt.event.WindowEvent e) {
                //shutdown the CBEditor if no Workbench is present
                if (getWorkbench() == null) {
                    CBConfiguration.storeConfig();
                    shutdown();
                }
                getWorkbench().setCBEditor(null);
                java.util.Iterator it = getGraphInternalFrames().iterator();
                // iterate over all internal Frames, disconnect and dispose them
                while (it.hasNext()) {
                    Object o = it.next();
                    if (o instanceof CBFrame) {
                        CBFrame cbf = (CBFrame) o;
                        if (cbf.isConnected()) {
                            cbf.disconnect(false);
                            it.remove();
                        }
                        cbf.dispose();
                    }
                }
                //hide CBEditor, we can't dispose it because this would dispose
                // the Workbench too.
                setVisible(false);
            }
        });

//reset look&feel to metal, others will produce errors
//        try {
//            UIManager.setLookAndFeel("javax.swing.plaf.metal.MetalLookAndFeel");
//            SwingUtilities.updateComponentTreeUI(this);
//        } catch (Exception e) {
//            System.err.println("Sorry, Look And Feel not supported by this platform!");
//            System.err.println(e.getMessage());
//        }

    }

    private static boolean linuxHost() {
        String osName = System.getProperty("os.name");
        int linuxFound = osName.indexOf("Linux");
        return (linuxFound != -1);
    }


    // nissue #69
    public void setSessionLinkCategory(String category) {
        sSessionLinkCategory = category;
    }

    public String getSessionLinkCategory() {
        return sSessionLinkCategory;
    }


    /**
     * The 'main' method is only called when the CBEditor is used as a standalone program, i.e. not as
     * part of a running CBIva. It creates a CBEditor instance.
     * If a command line arguments contain filenames , then a CBFrame is added and loaded with
     * the content of the GEL file.
     *
     * @param args command line arguments for the stand-alone call of the GraphEditor/CBEditor
     */

    public static void main(String args[]) {
        // all interaction shall be in English since the CBserver also speaks English only
        Locale.setDefault(new Locale("en", "GB"));
        if (args.length > 0)
          if (args[0].equals("-v") || args[0].equals("-version")) {
                  System.out.println("CBGraph " + CBGRAPH_VERSION + " (Java " + JAVA_VERSION + "), " + CBGRAPH_DATE );
                  System.out.println("Copyright 1987-2026 by The ConceptBase Team. All rights reserved.");
                  System.out.println("Original software by Tobias Schoeneberg, Tobias Latzke and others.");
                  System.out.println("This is free software. See http://conceptbase.cc for details.");
                  System.out.println("No warranty, not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.");
                  System.exit(0);
          }


        CBConfiguration.openConfig();
        // activate FlatLightLaf Look & Feel if possible
        try {
            if (CBConfiguration.hasUIDarkMode()) {
              UIManager.setLookAndFeel("com.formdev.flatlaf.FlatDarkLaf");

            } else {
              UIManager.setLookAndFeel("com.formdev.flatlaf.FlatLightLaf");
            }
            com.formdev.flatlaf.FlatLightLaf.installLafInfo();
            com.formdev.flatlaf.FlatDarkLaf.installLafInfo();
        } catch (Exception ex) {
            System.out.println("Java version is: "+DiagramNode.JAVA_VERSION);
            System.err.println("CBEditor: Failed to initialize Look&Feel FlatLightLaf");
        }

        // No OS window frame, instead let Look&Feel create a custom frame (default on Windows)
        // Only works with FlatLaf Look&Feels!
        // if (UIManager.getLookAndFeel().getName().startsWith("Flat") && linuxHost()) {
        //    JFrame.setDefaultLookAndFeelDecorated(true);
        //    JDialog.setDefaultLookAndFeelDecorated(true);
        // }

        CBEditor editor = new CBEditor(null);
        editor.analyzeCmdArgs(args);

        if (editor.getResyncMode() && editor.gelFilenames.size != 1) {
          System.err.println("Option -resync can only be used when providing a single GEL file as argument.");
          System.exit(1);
        }

        editor.setVisible(true);

        for (int i = 0; i < editor.gelFilenames.size; i++) {
          String filename = editor.gelFilenames.get(i);
          CBFrame newFrame = new CBFrame(editor, "new CBFrame "+filename, CBConstants.DEFAULT_PALETTE);
          newFrame.setGelfile(filename);
          editor.addCBFrame(newFrame);
          try {
            // will change title and content of newFrame, can connect to a CBserver if the connection
            // details in the GEL file point to an accessible CBserver
            editor.loadGraphInternalFrame(newFrame,filename);  
          } catch (Exception e) {
            System.err.println("Problem loading the GEL file " + filename);
            System.err.println(e.getMessage());
          }
          if (editor.getRevalidateMode()) {
            newFrame.validateNodes();  // issue #56; validate if option -revalidate was set
          }
          newFrame.repaint();
        }

        // issue #56: save GEL file and then exit if option -resync was used
        if (editor.getResyncMode()) {
           editor.saveGraphForResync(editor.gelFilenames.get(0));
           int invalidNr = ( (CBFrame)editor.getActiveGraphInternalFrame() ).getNrInvalidNodes();
           System.out.println("Resynced GEL file " + editor.gelFilenames.get(0) 
                  + " (" + invalidNr + " invalid)");
           editor.shutdown();
           if (invalidNr == 0) 
              System.exit(0);
           else 
              System.exit(1);  // allow bash shell to check wether resync was successful
        }
        

        // issue #26: disable some menu items in the "demo mode"
        if (editor.m_demoMode) {
          for (int pos = 0; pos < editor.m_graphMenuBar.getFileMenu().getItemCount()-1; pos++) { 
             JMenuItem jmi = editor.getGraphMenuBar().getFileMenu().getItem(pos);
             if (jmi != null)
               jmi.setEnabled(false);
          }
        }

        // if no GEL files were provided then just open an empty unconnected inner frame
        if (editor.gelFilenames.size == 0) 
          editor.openStartFrame();
//          editor.openNewFrame();
    }

    /**
     Open a start frame for a CBGraph editor that was not started with GEL files as arguments
    */
    public void openStartFrame() {
      CBFrame newFrame = this.createFrame("Not Connected");
      addCBFrame(newFrame);
      if (newFrame.usePublicCBserver()) {  // autoconnect if a public CBserver is configured
         String host = CBConfiguration.getPublicCBserverHost();
         String port = CBConfiguration.getPublicCBserverPort();
         newFrame.connectToServerFromDisconnected(host,port,"oHome");
         if (newFrame.isConnected()) {
           newFrame.setModule(newFrame.getUserHome());
           newFrame.setContext();
           newFrame.setFrameTitle(); // refresh the title based on connection status     
         }  
      }
    }



    /**
     * scan for command line arguments, set options and GEL filenames if they occur
    */

    public void analyzeCmdArgs(String[] cmdargs) {
      if (this.gelFilenames == null)  // reuse gelFilenames if already defined; ticket #429
         this.gelFilenames = new StringArray();
      int i = 0;

      // default
      this.setReadCBModule(true); 
      this.setWriteCBModule(true);
      String specificArgs = "";

      while (i < cmdargs.length) {

         if (cmdargs[i].startsWith("-") || cmdargs[i].startsWith("+"))
           this.setCommandLineOptionsPresent(true);

         if (cmdargs[i].equals("-rw")) {
            this.setReadCBModule(false);
            this.setWriteCBModule(false);
            specificArgs = specificArgs + " -rw";
         } else if (cmdargs[i].equals("+r")) {
            this.setReadCBModule(true);
            this.setWriteCBModule(false);
            specificArgs = specificArgs + " +r";
         }
         else if (cmdargs[i].equals("+w")) {
            this.setReadCBModule(false);
            this.setWriteCBModule(true);
            specificArgs = specificArgs + " +w";
         }
         else if (cmdargs[i].equals("+rw")) {
            this.setReadCBModule(true);
            this.setWriteCBModule(true);
            specificArgs = specificArgs + " +rw";
         }
         else if (cmdargs[i].equals("-demo")) {   // issue #26: disable some menu items in the "demo mode"
            m_demoMode = true;
         }
         else if (cmdargs[i].equals("-resync")) {   // issue #56: resync mode 
            this.setResyncMode(true);
         }
         else if (cmdargs[i].equals("-savepng")) {   // issue #56: savepng mode 
            this.setSaveDiagramMode("png");
         }
         else if (cmdargs[i].equals("-savesvg")) {   // issue #85: savesvg mode 
            this.setSaveDiagramMode("svg");
         }
         else if (cmdargs[i].equals("-revalidate")) {   // issue #56: revalidate mode 
            this.setRevalidateMode(true);
         }
         else if (cmdargs[i].equals("+f")) {  // for dumping module sources to a text file
            this.setReadCBModule(true);
            this.setWriteCBModule(true);
            this.setDumpSourceFiles(true);
            specificArgs = specificArgs + " +f";
         }
         else if (cmdargs[i].equals("-host") && i+1 < cmdargs.length) {  // for  overriding the host name
            this.setOverrideHostPort(cmdargs[i+1]);
            i++;
         }
         else if (!cmdargs[i].startsWith("-")) {
            if (!cmdargs[i].equals(""))  // do not add empty file names; ticket #429
               this.gelFilenames.add(cmdargs[i]);
         }
         else
            System.err.println("Unknown option " + cmdargs[i]);
         i++;
      } // while

      // CBGraphParams could already been set via the call of analyzeCmdArgs in main();
      // we then do not overwrite those parameters via the parameters from the GEL file; 
      // the call of analyzeCmdArgs in main() precedes the call in DiagramDesktop.java
      if (!specificArgs.equals("") && this.getCBGraphParams() == null)
        this.setCBGraphParams(specificArgs.split(" "));  // memorize the CBGraph parameters; will then also be stored in the GEL file


    }

    /**
     * Creates a CBFrame with the given title.
     *
     * @param title
     *            the title as shown on the cbframe's titlebar
     * @return the new CBFrame
     */
    public CBFrame createFrame(String title) {

        CBFrame frame = new CBFrame(this, title, CBConstants.DEFAULT_PALETTE);
        return frame;
    }

    /**
     * Some Sample Extensions of the MenuBar. It is ok to use integers instead
     * of constants to define the position of a menu or item, because this is
     * the only time you care for the position. For later access you should use
     * the GraphMenuBar's getMenuByKeyWord method.
     */
    private void extendMenuBar() {

        // modify an existing menu (FileMenu)
        GraphMenuItem item = new GraphMenuItem("GMB_FileMenu_Connect",
                CBConstants.CB_BUNDLE_NAME, 'C', true);
        item.addActionListener(new CBCommand(CBCommand.FILE_CONNECT, this));
        // adds a new MenuItem at first Position
        m_graphMenuBar.getFileMenu().add(item, 0);

        // modify an existing menu (FileMenu)
        GraphMenuItem close = new GraphMenuItem("GMB_FileMenu_Close",
                CBConstants.CB_BUNDLE_NAME, 'S', true);
        close.addActionListener(new CBCommand(CBCommand.FILE_CLOSE, this));
        // adds a new MenuItem at second but last position
        m_graphMenuBar.getFileMenu().add(close,
                m_graphMenuBar.getFileMenu().getItemCount() - 1);

        // modify an existing menu (OptionsMenu)
        GraphMenuItem workbench = new GraphMenuItem(
                "GMB_FileMenu_StartWorkbench", CBConstants.CB_BUNDLE_NAME, 'W',
                true);
        workbench.addActionListener(new CBCommand(
                CBCommand.FILE_STARTWORKBENCH, this));
        m_graphMenuBar.getFileMenu().add(workbench, 1);

        ResourceBundle bundle = ResourceBundle.getBundle(CBConstants.CB_BUNDLE_NAME);

        // Option for selecting background color
        GraphMenuItem ddBGColor = new GraphMenuItem(
                "GMB_OptionsMenu_DDBackground", CBConstants.CB_BUNDLE_NAME,
                'B', false);
        ddBGColor.addActionListener(new CBCommand(CBCommand.OPTIONS_BGCOLOR,
                this));
        m_graphMenuBar.getOptionsMenu().add(ddBGColor);

        // Option for selecting component type
        GraphMenu gmComponent = new GraphMenu("GMB_OptionsMenu_CBComponent",
                CBConstants.CB_BUNDLE_NAME);
        gmComponent.setEnabled(false);

        ButtonGroup groupComp = new ButtonGroup();
        JRadioButtonMenuItem jrbmi4 = new JRadioButtonMenuItem(bundle
                .getString("GMB_OptionsMenu_CBComponent_Tree"));
        jrbmi4.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent ie) {
                CBConfiguration.setComponentView(CBConfiguration.VALUE_TREE);
                if (getActiveGraphInternalFrame() != null) {
                    getActiveGraphInternalFrame().getDiagramClass()
                            .resetAllComponents();
                }
            }
        });

        JRadioButtonMenuItem jrbmi5 = new JRadioButtonMenuItem(bundle
                .getString("GMB_OptionsMenu_CBComponent_Frame"));
        jrbmi5.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent ie) {
                CBConfiguration.setComponentView(CBConfiguration.VALUE_FRAME);
                if (getActiveGraphInternalFrame() != null) {
                    getActiveGraphInternalFrame().getDiagramClass()
                            .resetAllComponents();
                }
            }
        });

        groupComp.add(jrbmi4);
        groupComp.add(jrbmi5);
        CBConfiguration.getComponentView(jrbmi4, jrbmi5);

        gmComponent.add(jrbmi4);
        gmComponent.add(jrbmi5);
        m_graphMenuBar.getOptionsMenu().add(gmComponent);

        GraphMenu gmInvalidObjs = new GraphMenu(
                "GMB_OptionsMenu_InvalidObjsMethod", CBConstants.CB_BUNDLE_NAME);
        ButtonGroup groupInval = new ButtonGroup();

        JRadioButtonMenuItem jrMark = new JRadioButtonMenuItem(bundle
                .getString("GMB_OptionsMenu_InvalidObjs_Mark"));
        JRadioButtonMenuItem jrRemove = new JRadioButtonMenuItem(bundle
                .getString("GMB_OptionsMenu_InvalidObjs_Remove"));

        CBConfiguration.getInvalidOjsMethod(jrMark, jrRemove);

        jrMark.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent ae) {
                CBConfiguration.setInvalidOjsMethod(CBConfiguration.VALUE_MARK);
                if (getActiveGraphInternalFrame() != null) {
                    getActiveGraphInternalFrame().getDiagramDesktop()
                            .setInvalidNodesMethod(CBConfiguration.VALUE_MARK);
                }
            }
        });

        jrRemove.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent ae) {
                CBConfiguration
                        .setInvalidOjsMethod(CBConfiguration.VALUE_REMOVE);
                if (getActiveGraphInternalFrame() != null) {
                    getActiveGraphInternalFrame()
                            .getDiagramDesktop()
                            .setInvalidNodesMethod(CBConfiguration.VALUE_REMOVE);
                }
            }
        });

        groupInval.add(jrMark);
        groupInval.add(jrRemove);

        gmInvalidObjs.add(jrMark);
        gmInvalidObjs.add(jrRemove);

        m_graphMenuBar.getOptionsMenu().add(gmInvalidObjs);

        // Options for Popup Menu
        GraphMenu gmPopupMenu = new GraphMenu("GMB_OptionsMenu_PopupMenu",
                CBConstants.CB_BUNDLE_NAME);
        JCheckBoxMenuItem jcbmiPopupBlocks = new JCheckBoxMenuItem(bundle
                .getString("GMB_OptionsMenu_PopupMenu_Blocks"), CBConfiguration
                .getPopupMenuBlocks());
        jcbmiPopupBlocks.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent ae) {
                CBConfiguration.setPopupMenuBlocks(((JCheckBoxMenuItem) ae
                        .getSource()).isSelected());
            }
        });
        JMenuItem jmiPopupDelay = new JMenuItem(bundle
                .getString("GMB_OptionsMenu_PopupMenu_Delay"));
        jmiPopupDelay.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent ae) {
                String res = JOptionPane.showInputDialog(
                        "Enter delay for popup menu in milliseconds",
                        Integer.valueOf(CBConfiguration.getPopupMenuDelay()));
                if (res != null)
                    CBConfiguration.setPopupMenuDelay(Integer.parseInt(res));
            }
        });

        gmPopupMenu.add(jmiPopupDelay);
        gmPopupMenu.add(jcbmiPopupBlocks);

        m_graphMenuBar.getOptionsMenu().add(gmPopupMenu);

        JMenu mLookAndFeel = new JMenu("Look & Feel");

        // Vordefinierte Look And Feels
        UIManager.LookAndFeelInfo[] lafInfo = UIManager
                .getInstalledLookAndFeels();
        if (lafInfo != null) {
            for (int i = 0; i < lafInfo.length; i++) {
                JMenuItem mi = new JMenuItem(lafInfo[i].getName());
                mi.addActionListener(new CBICommand(CBICommand.iLOOK_AND_FEEL,
                        lafInfo[i].getClassName(), this));
                mLookAndFeel.add(mi);
            }
        }
        m_graphMenuBar.getOptionsMenu().add(mLookAndFeel);

        // We configure FlatLaf in CBEditor.java in a way that disables the OS frame around the CBIva window
        // FlatLaf can deal by this by creating its own frame but older Look&Feels cannat deal with this
        // Hence we disable changing the Look&Feel if FlatFaf is used
        //if (UIManager.getLookAndFeel().getName().startsWith("FlatLaf"))
        //   mLookAndFeel.setEnabled(false);


       // Checkbox for enabling click actions
       // --------------------------
        JCheckBoxMenuItem jcbClickActionsEnable = new JCheckBoxMenuItem(bundle.getString("GMB_OptionsMenu_ClickActCheckBx"));
        jcbClickActionsEnable.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent evt) {
                if (evt.getStateChange() == java.awt.event.ItemEvent.SELECTED) {
                   CBConfiguration.setEnableClickActions(true);
                } else {
                   CBConfiguration.setEnableClickActions(false);
                }
            }
        });
        if (CBConfiguration.getEnableClickActions())
            jcbClickActionsEnable.setSelected(true);
        else
            jcbClickActionsEnable.setSelected(false);

        m_graphMenuBar.getOptionsMenu().add(jcbClickActionsEnable);
       // --------------------------


       // Checkbox for enabling derived links in CBGraph; GitLab issue #5
       // --------------------------
        JCheckBoxMenuItem jcbDerivedLinksEnable = new JCheckBoxMenuItem(bundle.getString("GMB_OptionsMenu_DerivedLinksCheckBx"));
        jcbDerivedLinksEnable.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent evt) {
                if (evt.getStateChange() == java.awt.event.ItemEvent.SELECTED) {
                   CBConfiguration.setEnableDerivedLinks(true);
                } else {
                   CBConfiguration.setEnableDerivedLinks(false);
                }
            }
        });
        if (CBConfiguration.getEnableDerivedLinks())
            jcbDerivedLinksEnable.setSelected(true);
        else
            jcbDerivedLinksEnable.setSelected(false);

        m_graphMenuBar.getOptionsMenu().add(jcbDerivedLinksEnable);
       // --------------------------


       // Sub-menu for show links (nissue #69)

        JMenuItem jmi = new JMenuItem(bundle.getString("GMB_OptionsMenu_ShowLinkOptions"));

        jmi.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent ev) {
                String sRet=JOptionPane.showInputDialog("Enter category",getSessionLinkCategory());
                if (sRet != null && !sRet.trim().equals("")) {
                    setSessionLinkCategory(sRet);
                }
            }
        });

        m_graphMenuBar.getOptionsMenu().add(jmi);





       // entries for the "Current connection" menu

        GraphMenu gmActiveCBFrame = new GraphMenu("GMB_ActiveFrame_Title",
                CBConstants.CB_BUNDLE_NAME, 'a');
        gmActiveCBFrame.setEnabled(false);
        GraphMenuItem submitQuery = new GraphMenuItem(
                "GMB_ActiveFrameMenu_SubmitQuery", CBConstants.CB_BUNDLE_NAME,
                's', false);
        submitQuery.addActionListener(new CBCommand(
                CBCommand.ACTIVEFRAME_SUBMITQUERY, this));
        GraphMenuItem validateObjects = new GraphMenuItem(
                "GMB_ActiveFrameMenu_ValidateObjects",
                CBConstants.CB_BUNDLE_NAME, 'v', false);
        validateObjects.addActionListener(new CBCommand(
                CBCommand.ACTIVEFRAME_VALIDATEOBJECTS, this));
        GraphMenuItem validateSelectedObjects = new GraphMenuItem(
                "GMB_ActiveFrameMenu_ValidateSelectedObjects",
                CBConstants.CB_BUNDLE_NAME, false);
        validateSelectedObjects.addActionListener(new CBCommand(
                CBCommand.ACTIVEFRAME_VALIDATESELECTEDOBJECTS, this));
        GraphMenuItem changeGraphPal = new GraphMenuItem(
                "GMB_ActiveFrameMenu_ChangeGraphicalPalette",
                CBConstants.CB_BUNDLE_NAME, false);
        changeGraphPal.addActionListener(new CBCommand(
                CBCommand.ACTIVEFRAME_CHANGEGRAPHPAL, this));
        GraphMenuItem changeGraphModule = new GraphMenuItem(
                "GMB_ActiveFrameMenu_ChangeGraphModule",
                CBConstants.CB_BUNDLE_NAME, false);
        changeGraphModule.addActionListener(new CBCommand(
                CBCommand.ACTIVEFRAME_CHANGEGRAPHMOD, this));
        gmActiveCBFrame.add(submitQuery);
        gmActiveCBFrame.add(validateObjects);
        gmActiveCBFrame.add(validateSelectedObjects);
        gmActiveCBFrame.add(changeGraphPal);
        gmActiveCBFrame.add(changeGraphModule);
        m_graphMenuBar.add(gmActiveCBFrame);


    }

    /**
     * Add cbeditor-specific items to the toolbar
     *
     */
    private void extendToolBar() {
        // an additional Button
        //ResourceBundle bundle =
        // ResourceBundle.getBundle(CBConstants.CB_BUNDLE_NAME, getLocale());
        addButtonToToolBar(
                CBConstants.CB_RESOURCE_DIR + "/toolbar_connect.gif",
                new CBCommand(CBCommand.FILE_CONNECT, this),
                CBConstants.NEW_CONNECTION_BUTTON, getCBBundle(getLocale())
                        .getString("ToolTip_Connect"));

        addButtonToToolBar(CBConstants.CB_RESOURCE_DIR + "/dialog_initobj.gif",
                new CBCommand(CBCommand.FILE_ADDNEWNODE, this),
                CBConstants.NEW_NODE_BUTTON,
                getCBBundle(getLocale()).getString("ToolTip_AddNewNode"))
                .setEnabled(false);

        addButtonToToolBar(
                CBConstants.CB_RESOURCE_DIR + "/toolbar_findrelations.gif",
                new CBCommand(CBCommand.EDIT_FINDRELATIONS, this),
                CBConstants.SHOW_RELATIONS_BUTTON,
                getCBBundle(getLocale()).getString("ToolTip_ShowRelations"))
                .setEnabled(false);


        m_graphToolBar.addSeparator();
        m_graphToolBar.addSeparator();
        m_graphToolBar.addSeparator();
        m_graphToolBar.add(new JLabel(getCBBundle(getLocale()).getString(
                "Toolbar_AddObjects")));
        m_graphToolBar.addSeparator();

        addButtonToToolBar(CBConstants.CB_RESOURCE_DIR + "/toolbar_newobj.gif",
                new CBCommand(CBCommand.ADD_INDIVIDUAL, this),
                "Toolbar_AddIndividual",
                getCBBundle(getLocale()).getString("Toolbar_AddIndividual"))
                .setEnabled(false);

        addButtonToToolBar(CBConstants.CB_RESOURCE_DIR + "/toolbar_attr.gif",
                new CBCommand(CBCommand.ADD_ATTRIBUTE, this),
                "Toolbar_AddAttribute",
                getCBBundle(getLocale()).getString("Toolbar_AddAttribute"))
                .setEnabled(false);

        addButtonToToolBar(CBConstants.CB_RESOURCE_DIR + "/toolbar_in.gif",
                new CBCommand(CBCommand.ADD_INSTANTIATION, this),
                "Toolbar_AddInstantiation",
                getCBBundle(getLocale()).getString("Toolbar_AddInstantiation"))
                .setEnabled(false);

        addButtonToToolBar(CBConstants.CB_RESOURCE_DIR + "/toolbar_isa.gif",
                new CBCommand(CBCommand.ADD_SPECIALIZATION, this),
                "Toolbar_AddSpecialization",
                getCBBundle(getLocale()).getString("Toolbar_AddSpecialization"))
                .setEnabled(false);

        m_graphToolBar.addSeparator();

        addButtonToToolBar(
                CBConstants.CB_RESOURCE_DIR + "/toolbar_lists.gif",
                new CBCommand(CBCommand.ADD_REMOVE, this),
                "Toolbar_RemoveItemFromCommit",
                getCBBundle(getLocale()).getString(
                        "Toolbar_RemoveItemFromCommit")).setEnabled(false);

        m_graphToolBar.addSeparator();

        addButtonToToolBar(CBConstants.CB_RESOURCE_DIR + "/toolbar_commit.gif",
                new CBCommand(CBCommand.ADD_COMMIT, this), "Toolbar_Commit",
                getCBBundle(getLocale()).getString("Toolbar_Commit"))
                .setEnabled(false);


    }//extendToolBar


    /**
     * Sets the background color of a toolbar button to light green
     *
     * @param sHandle
     *            the name associated to the button, e.g. "Toolbar_Commit"
     * @param highlight
     *            true if button showd be highlighted, else false
     */
    public void highlightButton(String sHandle, boolean highlight) {
       JButton button = this.getToolBarButton(sHandle);
       if (button == null)
         return;
       if (highlight)
         button.setBackground(new Color(170,240,160));  // set background of the button to light green
       else
         button.setBackground(null);  // set background of the button to default
    }



    /**
     * Gets the resourcebundle which fits best to a given locale The cbBundle is
     * sometimes needed for translation purposes
     *
     * @return the editor's textBundle that fits best to the given locale
     * @param loc
     *            The locale to which the resourcebundle shall belong
     */
    public ResourceBundle getCBBundle(Locale loc) {
        return ResourceBundle.getBundle(CBConstants.CB_BUNDLE_NAME, loc);
    }

    /**
     * Gets the resourcebundle which is currently in use
     *
     * @return the editors textbundle
     */
    public ResourceBundle getCBBundle() {
        return ResourceBundle
                .getBundle(CBConstants.CB_BUNDLE_NAME, getLocale());
    }




   /*
    * memorize command line options
   */


    public void setWriteCBModule(boolean value) {
      m_writeCBModule = value;
    }

    public boolean getWriteCBModule() {
      return m_writeCBModule;
    }

    public void setReadCBModule(boolean value) {
      m_readCBModule = value;
    }

    public boolean getReadCBModule() {
      return m_readCBModule;
    }

    public void setDumpSourceFiles(boolean value){
      m_dumpSourceFiles = value;
    }

    public boolean getDumpSourceFiles() {
      return m_dumpSourceFiles;
    }

    public void setCommandLineOptionsPresent(boolean value) {
      m_CommandLineOptionsPresent = value;
    }

    public boolean getCommandLineOptionsPresent() {
      return m_CommandLineOptionsPresent;
    }

    public void setResyncMode(boolean value) {
      m_resyncMode = value;
    }

    public boolean getResyncMode() {
      return m_resyncMode;
    }

    public void setSaveDiagramMode(String value) {
      m_saveDiagramMode = value;
    }

    public String getSaveDiagramMode() {
      return m_saveDiagramMode;
    }

    public void setRevalidateMode(boolean value) {
      m_revalidateMode = value;
    }

    public boolean getRevalidateMode() {
      return m_revalidateMode;
    }




    /**
     * Redirect the connection to be used by DiagramDesktop.load() to hostport 
     *
     * @param hostport
     *            the host and port; syntax either hostname or hostname:portnr
     */
    public void setOverrideHostPort(String hostport) {

      String[] parts = hostport.split(":");
      if (parts.length == 1) {
        m_overrideHost = parts[0];
      } else if (parts.length == 2) {
        m_overrideHost = parts[0];
        m_overridePort = parts[1];
      }
    }

   public String getOverrideHost() {
     return m_overrideHost;
   }

   public String getOverridePort() {
     return m_overridePort;
   }

   // issue #26: "demo mode" flkag is used for disabling some menu items
   public boolean getDemoMode() {
     return m_demoMode;
   }

   public boolean getFullMode() {
     return !m_demoMode;
   }



    /**
     * Updates language-specific strings such as tooltiptexts and labels of
     * menuitems
     *
     * @param loc
     *            the Locale to which the language-update shall conform
     * @return null
     */
    public DefaultStyledDocument updateLang(Locale loc) {

        setLocale(loc);
        //Contract.requires("CBEditor.updateLang: locale error!", getLocale()
        // == loc);
        super.updateLang(loc);

        ResourceBundle bundle = getCBBundle(loc);
        //ResourceBundle bundle =
        // ResourceBundle.getBundle(CBConstants.CB_BUNDLE_NAME,loc);

        getToolBarButton(CBConstants.NEW_CONNECTION_BUTTON).setToolTipText(
                bundle.getString("ToolTip_Connect"));
        getToolBarButton(CBConstants.NEW_NODE_BUTTON).setToolTipText(
                bundle.getString("ToolTip_AddNewNode"));
        getToolBarButton(CBConstants.SHOW_RELATIONS_BUTTON).setToolTipText(
                bundle.getString("ToolTip_ShowRelations"));
        return null;
    }//updateLang

    /**
     * Changes the Status display regarding the connection which is shown in the
     * Mainwindow
     *
     * @param newStatResource
     *            telling what RESOURCE to show in the Statusbar(might be
     *            translated).
     * @param additional
     *            containing additional info that is displayed as is.
     */
    public void changeStatusString(String sStatus) {
        m_statusConnectionLabel.setText(sStatus);
        //	java.util.logging.Logger.getLogger("global").fine("Changing status to RESOURCE '"
        // + newStatResource
        //			   + "' (" + geBundle.getString(newStatResource) + ") + additional '" +
        // additional + "'");
    }

    /**
     * Stores the configuration and exits
     */
    public void shutdown() {
        saveLayoutPath();
        CBConfiguration.storeConfig();

        // issue #56
        if (getSaveDiagramMode() != null) {
           super.saveDiagramFile(getSaveDiagramMode());
           setSaveDiagramMode(null);
        }


        Iterator it = m_vGraphInternalFrames.iterator();
        while (it.hasNext()) {
            Object o = it.next();
            if (o instanceof CBFrame) {
                CBFrame cbf = (CBFrame) o;
                if (cbf.isConnected()) 
                  cbf.disconnect(false);
                it.remove();
            }
        }

        if (getWorkbench() != null) {
            getWorkbench().setCBEditor(null);
            getWorkbench().exitCBIva();
        } else {
            super.shutdown();
        }
    }//shutdown




    public void openNewFrame() {
        CBFrame cbf = new CBFrame(this, "Not Connected", "NoPalette");
        addCBFrame(cbf);
    }

    public CBFrame addNewCBFrame() {
        CBFrame cbf = new CBFrame(this, "Not Connected", "NoPalette");
        addCBFrame(cbf);
        return cbf;
    }



    public void addCBFrame(CBFrame cbf) {
        addGraphInternalFrame(cbf);

        cbf.setButtonEnabled(CBConstants.NEW_NODE_BUTTON, false);
        cbf.setButtonEnabled(CBConstants.SHOW_RELATIONS_BUTTON, false);
        cbf.setButtonEnabled(GEConstants.LOAD_BUTTON, true);
        cbf.setButtonEnabled(GEConstants.SAVE_BUTTON, true);
        cbf.setButtonEnabled(GEConstants.REMOVE_BUTTON, true);

        cbf.setButtonEnabled("Toolbar_AddIndividual", true);
        cbf.setButtonEnabled("Toolbar_AddAttribute", true);
        cbf.setButtonEnabled("Toolbar_AddInstantiation", true);
        cbf.setButtonEnabled("Toolbar_AddSpecialization", true);
        cbf.setButtonEnabled("Toolbar_Commit", false);
        cbf.setButtonEnabled("Toolbar_RemoveItemFromCommit", true);

        cbf.setMenuEnabled("GMB_EditMenu_Title", true);
        cbf.setMenuEnabled("GMB_ActiveFrame_Title", true);
        cbf.setItemEnabled("GMB_OptionsMenu_DDBackground", true);
        cbf.setMenuEnabled("GMB_OptionsMenu_CBComponent", true);

        cbf.setItemEnabled("GMB_FileMenu_Load", getFullMode());
        cbf.setItemEnabled("GMB_FileMenu_Save", getFullMode());
        cbf.setItemEnabled("GMB_FileMenu_Print", getFullMode());
        cbf.setItemEnabled("GMB_FileMenu_ScreenShot", getFullMode());

        cbf.setItemEnabled("GMB_ActiveFrameMenu_SubmitQuery", false);
        cbf.setItemEnabled("GMB_ActiveFrameMenu_ValidateObjects", false);
        cbf
                .setItemEnabled("GMB_ActiveFrameMenu_ValidateSelectedObjects",
                        false);
        cbf.setItemEnabled("GMB_ActiveFrameMenu_ChangeGraphicalPalette", false);
        cbf.setItemEnabled("GMB_ActiveFrameMenu_ChangeGraphModule", false);

        cbf.loadGraphicalPaletteAndImplementation(false);
    }


    /**
     * erases the DiagramNode corresponding to the given TelosObject from the
     * DiagramDesktop of the given cbFrame
     */
    public void removeNode(i5.cb.graph.diagram.DiagramNode diagNodeToErase,
            CBFrame activeFrame) {
        CBFrame cbFrame = activeFrame;
        i5.cb.graph.DiagramDesktop diagDesktop = cbFrame.getDiagramDesktop();
        //select the node which should be erased and do so
        diagDesktop.clearSelectedNodes();
        diagDesktop.setNodeSelected(diagNodeToErase, true);
        diagDesktop.removeMarkedNodes();

    }

    /**
     * set the workbench related to this cbeditor
     *
     * @param workbench:
     *            The workbench to set
     */
    public void setWorkbench(CBIva workbench) {
        m_CBIva = workbench;
    }

    /**
     * returns the vector containing all opened InternalFrames
     *
     * @return Vector containing opened Frames
     */
    public Vector getGraphInternalFrames() {
        return m_vGraphInternalFrames;
    }

    /**
     * get the workbench related to this cbeditor
     *
     * @return the {@link CBIva}related to this {@link CBEditor}
     */
    public CBIva getWorkbench() {
        return m_CBIva;
    }

    /**
     * saves the last visited path, from which a layout was loaded, in
     * {@link CBConfiguration}
     */
    public void saveLayoutPath() {
        CBConfiguration.setLoadLayoutPath(currentLayoutDir.getPath());
    }

    /**
     * Starts a new {@link CBEditor}with CBI, and connects to the server
     * cbIClient is connected to
     *
     * @param CBI
     *            The workbench which should relate to this {@link CBEditor}
     * @param cbIClient
     *            Client of the workbench, if it is connected we will connect to
     *            the same server
     * @return the started {@link CBEditor}
     */
    public static CBEditor startCBEditorWithWorkbench(CBIva CBI,
            CBIvaClient cbIClient) {
        //allow only one CBEditor for a workbench
        if (CBI.getCBEditor() != null) {
            return CBI.getCBEditor();
        }
        String sObject = null;
        String sPalette = null;
        String sModule = null;

        if (cbIClient != null && cbIClient.isConnected()) {
            JPanel jp = new JPanel(new FlowLayout());
            JPanel jpLeft = new JPanel();
            JPanel jpRight = new JPanel();
            jpLeft.setLayout(new BoxLayout(jpLeft, BoxLayout.Y_AXIS));
            jpRight.setLayout(new BoxLayout(jpRight, BoxLayout.Y_AXIS));

            jpLeft.add(new JLabel("Object:"), BorderLayout.WEST);
            jpLeft.add(new JLabel("Graphical Palette:"), BorderLayout.WEST);
            jpLeft.add(new JLabel("Module:"), BorderLayout.WEST);

            JTextField jtfObject = new JTextField("Class", 30);
            jpRight.add(jtfObject, BorderLayout.EAST);
            String sInst = cbIClient.findInstances("JavaGraphicalPalette");
            StringTokenizer st = new StringTokenizer(sInst, ",");
            Vector vGraphPals = new Vector(st.countTokens());
            while (st.hasMoreTokens())
                vGraphPals.add(st.nextToken());
            JComboBox jcbGraphPal = new JComboBox(vGraphPals);
 //           jcbGraphPal.setSelectedItem(CBConstants.DEFAULT_PALETTE);
            jcbGraphPal.setSelectedIndex(0);    // user defined palettes are sorted before the default palette
            jcbGraphPal.setEditable(false);
            jpRight.add(jcbGraphPal, BorderLayout.EAST);
            JTextField jtfModule = new JTextField(cbIClient.getModule(), 30);
            jpRight.add(jtfModule, BorderLayout.EAST);

            jp.add(jpLeft);
            jp.add(jpRight);

            int ret = JOptionPane.showConfirmDialog(CBI, jp,
                    "Select object, graphical palette and Module",
                    JOptionPane.OK_CANCEL_OPTION, JOptionPane.QUESTION_MESSAGE);
            if (ret == JOptionPane.OK_OPTION) {
                sObject = jtfObject.getText();
                sPalette = jcbGraphPal.getSelectedItem().toString();
                sModule = jtfModule.getText();

            } else
                return null;
        }
        CBEditor editor = null;
        editor = new CBEditor(null);
        editor.setVisible(true);
        editor.setWorkbench(CBI);
        CBI.getStatusBar().setLinkedTool("CBGraph");
        editor.setReadCBModule(true);  // will enable saving module sources in GEL files
        String cbivaModule = getClientModulePath(cbIClient.getCBClient());

        // establish connection to CB if cbIclient is connected
        if (cbIClient != null && cbIClient.isConnected()) {
            try {
//                String sTitle = cbIClient.getCBClient().getHostName()+":"+cbIClient.getCBClient().getPort();
                String sTitle = sPalette + ": " + sModule;
                CBFrame newFrame = new CBFrame(editor, sTitle, sPalette, sModule);
                CBFrameWorker cbf = (CBFrameWorker) newFrame.getFrameWorker();
                cbf.connect(newFrame,
                            cbIClient.getCBClient().getHostName(),
                            Integer.valueOf(cbIClient.getCBClient().getPort()),
                            sObject, combiPath(cbivaModule,sModule));
                newFrame.setFrameTitle(); // refresh the title based on connection status
            } catch (java.rmi.RemoteException rme) {
            }
        }
        return editor;
    }



// this version starts the CBEditor for a given sObject; no further dialogs to determine sModule and sPalette
public static CBEditor startCBEditorWithWorkbench(CBIva CBI, CBIvaClient cbIClient, String sObject) {
        //allow only one CBEditor for a workbench
        if (CBI.getCBEditor() != null) {
            return CBI.getCBEditor();
        }

        String sPalette = "DefaultJavaPalette";
        String sModule = "oHome";

        if (cbIClient != null && cbIClient.isConnected()) {
            sModule = cbIClient.getModule();
            String sInst = cbIClient.findInstances("JavaGraphicalPalette");
            StringTokenizer st = new StringTokenizer(sInst, ",");
            if (st.hasMoreTokens()) {
                sPalette = st.nextToken();  // take the very first graphical palette
            }
        }
        CBEditor editor = null;
        editor = new CBEditor(null);
        editor.setVisible(true);
        editor.setWorkbench(CBI);
        editor.setReadCBModule(true);  // will enable saving module sources in GEL files
        String cbivaModule = getClientModulePath(cbIClient.getCBClient());

        // establish connection to CB if cbIclient is connected
        if (cbIClient != null && cbIClient.isConnected()) {
            try {
//                String sTitle = cbIClient.getCBClient().getHostName()+":"+cbIClient.getCBClient().getPort();
                String sTitle = sPalette + ": " + sModule;
                CBFrame newFrame = new CBFrame(editor, sTitle, sPalette, sModule);
                CBFrameWorker cbf = (CBFrameWorker) newFrame.getFrameWorker();
                cbf.connect(newFrame,
                            cbIClient.getCBClient().getHostName(),
                            Integer.valueOf(cbIClient.getCBClient().getPort()),
                            sObject, combiPath(cbivaModule,sModule));
                newFrame.setFrameTitle(); // refresh the title based on connection status
            } catch (java.rmi.RemoteException rme) {
            }
        }
        return editor;
    }



    /**
     * Retrieve the absolute module path that the given CBclient has registered with the CBserver
     *
     * @param cbclient
     *            The CBlient connected to a CBserver
     * @return the absolute module path of the CBclient
     */


    public static String getClientModulePath(CBclient cbclient) {
        try {
          CBanswer ans=cbclient.getModulePath();
          if (ans.getCompletion() == CBanswer.OK ) {
             return ans.getResult();
          }
          else
             return CBConstants.CB_HOME_MODULE;
        }
        catch (Exception e) {
          return CBConstants.CB_HOME_MODULE;
        }
    }



    /**
     * Commbine two module paths referencing database modules
     *
     * @param path1 The first path
     * @param path1 The second path
     * @return the combination of the two paths
     */


    public static String combiPath(String path1, String path2) {
      // path2 is absolute or path1 is undefined
      if (path2.startsWith(CBConstants.CB_SYSTEM_MODULE) || path1 == null)
        return path2;
      // path2 is undefined or path2 is included in path1
      else if (path2 == null || path1.endsWith(path2))
        return path1;
      // else concat them
      else
        return path1 + CBConfiguration.getModuleSeparator() + path2;
    }



    /**
     * removes this {@link CBFrame}from the Editor if it is present
     *
     * @param cbf
     *            {@link CBFrame}to erase
     */
    public void removeGraphInternalFrame(CBFrame cbf) {
        m_vGraphInternalFrames.remove(cbf);
    }




}//CBEditor



