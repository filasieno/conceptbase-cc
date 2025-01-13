/*
The ConceptBase.cc Copyright

Copyright 1987-2025 The ConceptBase Team. All rights reserved.

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
/*
 * @(#)GraphEditor.java	0.5 b 11.09.99
 *
 * Copyright 1998, 1999 by Rainer Langohr,
 *
 * All rights reserved.
 *
 */
package i5.cb.graph;

import i5.cb.CBConfiguration;

import java.applet.Applet;
import java.awt.*;
import java.awt.event.ActionListener;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.io.*;
import java.text.DateFormat;
import java.util.*;
import java.util.logging.*;
import i5.cb.graph.cbeditor.CBEditor;
import i5.cb.graph.cbeditor.CBFrame;
import i5.cb.graph.cbeditor.StringArray;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

import javax.swing.*;
import javax.swing.filechooser.FileView;
import javax.swing.text.DefaultStyledDocument;

/**
 * The basic of all GraphEditor Components.
 * The GraphEditor is the main Frame with a Menu,
 * a toolbar and a status bar.
 * You can add your own GraphInternalFrames to this object.
 *
 */
public class GraphEditor
    extends JFrame
    implements ILangChangeable, PropertyChangeListener {

    private static Applet m_applet;

    private static Handler m_currentHandler=null;

    protected File currentLayoutDir;

    /**
     * This is where we add all the GraphInternalFrames and maybe the infowindow
     */
    private JDesktopPane m_mainDesktopPane;

    /**
     * The editor's ToolBar. Usually contains save, open, new...etc buttons.
     */
    protected JToolBar m_graphToolBar;

    protected JToolBar m_graphStatusBar;

    /**
     * The editor's MenuBar. Usually contains file, edit, language,...etc menus.
     */
    protected GraphMenuBar m_graphMenuBar;

    /**
     * A progressbar that is placed in the <code>m_graphStatusBar</code>. It's passed to the gifworker
     * of the currently active GraphInternal Frame so the m_gifWorker can issue information concerning
     * its progress
     */
    protected JProgressBar m_statusProgressBar;

    protected JLabel m_statusConnectionLabel;


    /**
     * The current command line arguments by which CBGraph was started or that are imported from the GEL file
     */
    protected String[] s_cbgraphParams = null; 

    /**
     * Here the information about a single node is displayed
     */
    private JTextPane m_infoPane;

    /**
     * The GraphInternalFrames currently placed inside this GraphEditor window
     */
    protected Vector m_vGraphInternalFrames;

    /**
     *
     */
    private Hashtable m_toolBarButtons;

    private GraphInternalFrameListener m_graphInternalFrameListener;

    private boolean bSizeSet = false; // to control setting the size of this GraphEditor

    /**
     * Instanciates a new GraphEditor Object and specifies the bShowInfoWindow Flag. If the
     * Constructor is called without a String specifying the Mainwindow's title, it is called with
     * the default title "GraphEditor 0.5 b"
     *
     * @param bShowInfoWindow - shall the info window be shown?
     */
    public GraphEditor(boolean bShowInfoWindow) {
        this("GraphEditor", bShowInfoWindow, false, null);

    }

    /**
     * Creates a new GraphEditor instance with the specified title.
     *
     * @param title the title of the editor's mainWindow
     */
    public GraphEditor(String title) {
        this(title, true, false, null);
    }

    /**
     * Creates a new GraphEditor Object with a progressbar
     *
     * @param title specifies the windowtitle to be displayed on the mainwindow
     * @param bShowInfoWindow true will provide some space to show information about any object
     * @param bShowGraphToolBar true will show a toolBar (currently with no buttons)
     * @param applet applet of this grah editor instance (null if run as application)
     */
    public GraphEditor(
        String title,
        boolean bShowInfoWindow,
        boolean bShowGraphToolBar,
        Applet applet) {
        super(title);
        m_applet = applet;

        // Init global logger
        Logger.getLogger("global");

        CBConfiguration.openConfig();
        Level dbgLevel=i5.cb.CBConfiguration.getDebugLevel();

        // Logging only works for "normal" applications
        try {
            // show "FINE" and more important messages
            Logger.getLogger("global").setLevel(dbgLevel);
            Logger.getLogger("global").setUseParentHandlers(false);
            ConsoleHandler ch = new ConsoleHandler();
            ch.setFormatter(new java.util.logging.Formatter() {
                public String format(LogRecord lr) {
                    StringBuffer sb = new StringBuffer();
                    sb.append(
                        DateFormat.getTimeInstance(DateFormat.MEDIUM).format(
                            new Date(lr.getMillis())));
                    sb.append(":");
                    if (lr.getSourceClassName() != null) {
                        sb.append(" in ");
                        sb.append(lr.getSourceClassName());
                    } else {
                        sb.append(lr.getLoggerName());
                    }
                    if (lr.getSourceMethodName() != null) {
                        sb.append(".");
                        sb.append(lr.getSourceMethodName());
                        sb.append(": ");
                    }
                    sb.append(lr.getMessage());
                    if (lr.getParameters() != null) {
                        Object[] params = lr.getParameters();
                        for (int i = 0; i < params.length; i++) {
                            sb.append(params[i].toString());
                            if (i + 1 < params.length)
                                sb.append(", ");
                        }
                    }
                    if (lr.getThrown() != null) {
                        try {
                            StringWriter sw = new StringWriter();
                            PrintWriter pw = new PrintWriter(sw);
                            lr.getThrown().printStackTrace(pw);
                            pw.close();
                            sb.append("\nLogging in Exception:");
                            sb.append(sw.toString());
                        } catch (Exception ex) {
                        }
                    }
                    sb.append("\n");
                    return sb.toString();
                }
            });
            ch.setLevel(dbgLevel);
            m_currentHandler = ch;
        } catch (java.security.AccessControlException ace) {
            //i5.cb.GUIHandler gh = new i5.cb.GUIHandler();
            //gh.setLevel(dbgLevel);
            //m_currentHandler = gh;
        }

        // Add console handler
        if(m_currentHandler!=null)
            Logger.getLogger("global").addHandler(m_currentHandler);

        currentLayoutDir=new File("");
        m_toolBarButtons = new Hashtable();
        m_vGraphInternalFrames = new Vector(5);
        JPanel mainPane = new JPanel(new BorderLayout());
        m_mainDesktopPane = new JDesktopPane();

        m_graphInternalFrameListener = new GraphInternalFrameListener(this);

        m_mainDesktopPane.setMinimumSize(new java.awt.Dimension(1, 1));
        m_mainDesktopPane.setPreferredSize(new java.awt.Dimension(750, 500));

        m_infoPane = new JTextPane();
        m_infoPane.setEditable(false);

        JScrollPane infoScrollPane =
            new JScrollPane(
                m_infoPane,
                JScrollPane.VERTICAL_SCROLLBAR_ALWAYS,
                JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
        infoScrollPane.setMinimumSize(new Dimension(1, 1));
        JSplitPane jSplitPane =
            new JSplitPane(
                JSplitPane.VERTICAL_SPLIT,
                m_mainDesktopPane,
                infoScrollPane);
        jSplitPane.setDividerLocation(500);
        jSplitPane.setResizeWeight(0.75);
        if (bShowInfoWindow) {
            mainPane.add(jSplitPane, BorderLayout.CENTER);
        } else {
            m_mainDesktopPane.setBorder(BorderFactory.createEtchedBorder());
            mainPane.add(m_mainDesktopPane, BorderLayout.CENTER);
        }
        if (bShowGraphToolBar) {
            m_graphToolBar = new JToolBar();

            addButtonToToolBar(
                GEConstants.GE_RESOURCE_DIR + "/toolbar_newframe.gif",
                new GECommand(this, GECommand.M_FILE_NEW),
                GEConstants.NEWFRAME_BUTTON,
                getGEBundle().getString("ToolTip_NewFrame")).setEnabled(
                true);
            addButtonToToolBar(
                GEConstants.GE_RESOURCE_DIR + "/toolbar_load.gif",
                new GECommand(this, GECommand.M_FILE_LOAD),
                GEConstants.LOAD_BUTTON,
                getGEBundle().getString("ToolTip_Load")).setEnabled(
                false);
            addButtonToToolBar(
                GEConstants.GE_RESOURCE_DIR + "/toolbar_save.gif",
                new GECommand(this, GECommand.M_FILE_SAVE),
                GEConstants.SAVE_BUTTON,
                getGEBundle().getString("ToolTip_Save")).setEnabled(
                false);
            m_graphToolBar.addSeparator();
            addButtonToToolBar(
                GEConstants.GE_RESOURCE_DIR + "/toolbar_erase.gif",
                new GECommand(this, GECommand.M_EDIT_ERASE),
                GEConstants.REMOVE_BUTTON,
                getGEBundle().getString("ToolTip_Remove")).setEnabled(
                false);
            m_graphToolBar.addSeparator();

            mainPane.add(m_graphToolBar, BorderLayout.NORTH);
        }

        m_graphStatusBar = new JToolBar();
        mainPane.add(m_graphStatusBar, BorderLayout.SOUTH);
        m_statusConnectionLabel = new JLabel();
        m_graphStatusBar.add(m_statusConnectionLabel);

        // Menu Bar
        m_graphMenuBar = new GraphMenuBar(this);
        this.setJMenuBar(m_graphMenuBar);
        this.setContentPane(mainPane);

        // guard the closing of the graph editor; we might have to save the graph file
        this.addWindowListener(new WindowAdapter()
        {
            public void windowClosing(WindowEvent e)
            {
                java.awt.Window w = e.getWindow();
                if (w instanceof GraphEditor) {
                   ((GraphEditor) w).close();
                }
            }
        });

        this.setSize(700, 600);
    }



    /**
     * Set the current CBGraph startup parameters; can come from the args of the cbgraph script call or
     * from the GEL file; only set if the parameters specify the synchronization of module sources
     */
   public void setCBGraphParams(String[] newparams) {
     s_cbgraphParams = newparams;
   }

    /**
     * Get the current CBGraph startup parameters
     */
   public String[] getCBGraphParams() {
     return s_cbgraphParams;
   }



    /**
     * The GraphEditor frame title is of the form "CBGraph - <subtitle>". This method updates the subtitle, e.g.
     * by the name of the currently loaded graph file.
     */
   public void setSubtitle(String subtitle) {
     String[] parts = this.getTitle().split("-");
     if (parts.length == 2) {
       this.setTitle(parts[0].trim() + " - " + subtitle);
     }
   }

    /**
     * Returns a button from the toolbar
     */
    public JButton getToolBarButton(String sHandle) {
        return (JButton) m_toolBarButtons.get(sHandle);
    }

    /**
     * Creates a {@link JButton} that performs the specified action on mouse click. If the pic
     * parameter is the correct filename(incl.path) of a picture, an image is created. Else the
     * button is labeled with the String. Currently the button is always added at the end of the
     * toolBar.
     *
     * @param pic filename of an icon including the path
     * @param action the action that will be done on mouse click
     */
    public JButton addButtonToToolBar(
        String pic,
        ActionListener action,
        String sHandle) {
        return addButtonToToolBar(pic, action, sHandle, null);
    }

    /**
         * Creates a {@link JButton} that performs the specified action on mouse click. If the pic
         * parameter is the correct filename(incl.path) of a picture, an image is created. Else the
         * button is labeled with the String. Currently the button is always added at the end of the
         * toolBar.
         *
         * @param pic filename of an icon including the path
         * @param action the action that will be done on mouse click
         * @param sToolTipText a TooltipText for the new Button
         */
    public JButton addButtonToToolBar(
        String pic,
        ActionListener action,
        String sHandle,
        String sToolTipText) {
        JButton button;
        java.net.URL picURL = this.getClass().getResource(pic);

        if (picURL != null) { // an image button is created
            Image image = Toolkit.getDefaultToolkit().getImage(picURL);
            button = new JButton(new ImageIcon(image));
            button.setMargin(new Insets(0, 0, 0, 0));
        } else { // a text button is created - cannot be translated at the moment
            button = new JButton(pic);
            // icrease the button's margin so that it's heigth equals the images' height(22 pix).
            Insets m = button.getMargin();
            button.setMargin(
                new Insets(m.top + 1, m.left - 10, m.bottom + 1, m.right - 10));
        }
        button.addActionListener(action);
        if (sToolTipText != null) {
            button.setToolTipText(sToolTipText);
        }
        m_toolBarButtons.put(sHandle, button);
        m_graphToolBar.add(button);
        return button;
    }

    /**
     * Displays the specified document on the InfoPane.
     *
     * @param dInfo any DefaultStyledDocument - should not be null
     */
    public void setInfoDoc(DefaultStyledDocument dInfo) {
        if (dInfo != null) {
            m_infoPane.setDocument(dInfo);
        }
    }

    /**
     * Adds the given frame to this editor's desktopPane and creates a new {@link
     * i5.cb.graph.GraphInternalFrameListener}. If editor and GIF are visible, the frame is also set selected;
     *
     * @param gif the frame to be added
     */
    public void addGraphInternalFrame(GraphInternalFrame gif) {
        assert(gif != null) : "GraphEditor.addGraphInternalFrame: 'gif' equals null";
        getDesktopPane().add(gif);

        gif.addInternalFrameListener(m_graphInternalFrameListener);
        gif.addPropertyChangeListener(this);
        setStatusString(gif.getStatus());

        m_vGraphInternalFrames.add(gif);
        try {
            gif.setSelected(true);
        } catch (java.beans.PropertyVetoException e) {
            Logger.getLogger("global").warning(e.getMessage());
        }
    }

    /**
     * Opens a filedialog to choose the filename and -format for a screenshot of the
     * Currently active diagramDesktop
    */
    void saveScreenShot() {

        GraphInternalFrame gif = getActiveGraphInternalFrame();

        if (gif == null) {
            JOptionPane.showMessageDialog(
                this,
                "No frame selected",
                "Error",
                JOptionPane.ERROR_MESSAGE);
        } else {

            // -- a dialog is created to choose a file
            JFileChooser dialog = new JFileChooser();

            dialog.setMultiSelectionEnabled(false);
            dialog.setFileSelectionMode(JFileChooser.FILES_ONLY);
            dialog.setAcceptAllFileFilterUsed(false);
            String[] imageFormatNames =
                javax.imageio.ImageIO.getWriterFormatNames();

            TreeSet lowerCaseFN = new TreeSet();

            boolean pngFound = false;
            for (int i = 0; i < imageFormatNames.length; i++) {
                String formatname = imageFormatNames[i].toLowerCase();
                if (formatname.equals("png"))
                  pngFound = true;
                else
                  lowerCaseFN.add(formatname);
            }

            Iterator itFormatNames = lowerCaseFN.iterator();
            GEFileFilter filter;


            // new Java: put PNG at first position if found; this one is preselected 
            if (i5.cb.graph.diagram.DiagramNode.JAVA_VERSION > 1.6011 && pngFound) {
               filter =
                 new GEFileFilter(
                     "png",
                     ".png" ,
                     "*.png");
                dialog.addChoosableFileFilter(filter);
            }

            String currentExtension;
            while (itFormatNames.hasNext()) {
                currentExtension = (String) itFormatNames.next();
                filter =
                    new GEFileFilter(
                        currentExtension,
                        "." + currentExtension,
                        "*." + currentExtension);
                dialog.addChoosableFileFilter(filter);
            }

            // old JAVA: put PNG at last position if found; this one is preselected 
            if (i5.cb.graph.diagram.DiagramNode.JAVA_VERSION <= 1.601101 && pngFound) {
               filter =
                 new GEFileFilter(
                     "png",
                     ".png" ,
                     "*.png");
                dialog.addChoosableFileFilter(filter);
            }


            if (currentLayoutDir != null)
              dialog.setCurrentDirectory(currentLayoutDir);

            // if CBEditor was started with a single file as argument then we preset it as selected file if possible
            if (this instanceof CBEditor) {
              CBEditor cbed = (CBEditor)this;
              if ( cbed.gelFilenames != null &&
                   cbed.gelFilenames.size == 1) {
                 String pngfilename = cbed.gelFilenames.get(0).replace(".gel","");
                 File selfile = new File(pngfilename);
                 dialog.setSelectedFile(selfile);
              }
            }


            if (dialog.showSaveDialog(this) != JFileChooser.APPROVE_OPTION)
                return;

            File saveFile = dialog.getSelectedFile();

            if (dialog.getFileFilter() != dialog.getAcceptAllFileFilter()) {
                String fileFormat =
                    ((GEFileFilter) dialog.getFileFilter()).getFilterFormat();

                if (!saveFile.getName().endsWith("." + fileFormat)) {
                    saveFile = new File(saveFile.getPath() + "." + fileFormat);
                }
            }

            gif.getDiagramDesktop().saveScreenShot(
                ((GEFileFilter) dialog.getFileFilter()).getFilterFormat(),
                saveFile);
        }

    }

    /**
     * Opens a {@link FileDialog} to create an {@link java.io.FileOutputStream}. Writes the Title and
     * the {@link DiagramDesktop} of the active GraphInternalFrame to this stream Expects one Frame
     * to be selected. Keep in mind that there will not happen very much, if the {@link
     * GraphInternalFrame} does not implement the saveUserObject Method.
     *
     * @exception IOException if an error occurs
     */
    void saveActiveGraphInternalFrame() throws IOException {
        GraphInternalFrame gif = getActiveGraphInternalFrame();

        if (gif == null) {
            JOptionPane.showMessageDialog(
                this,
                "No frame selected",
                "Error",
                JOptionPane.ERROR_MESSAGE);
        } else {

            // -- a dialog is created to choose a file
            GELFileChooser dialog;
            if (this instanceof CBEditor && gif instanceof CBFrame) {
              CBEditor cbed = (CBEditor)this;
              CBFrame cbframe = (CBFrame)gif;
              // to preset a checkbox about including module sources
              boolean includeSrc = cbed.getReadCBModule() &&
                                   (cbframe.isConnected() || (cbframe.moduleSourcesSize()>0));
              dialog = new GELFileChooser(includeSrc);
            }
            else
              dialog = new GELFileChooser();

            dialog.setMultiSelectionEnabled(false);
            dialog.setFileSelectionMode(JFileChooser.FILES_ONLY);
            dialog.setAcceptAllFileFilterUsed(false);
            // -- only files with suffix ".gel"(for GraphEditorLayout) are shown.
            GEFileFilter filter =
                new GEFileFilter(
                    "gel",
                    ".gel",
                    "ConceptBase Grapheditorlayout");

            dialog.setFileFilter(filter);
            dialog.setCurrentDirectory(currentLayoutDir);

            // if CBEditor was started with a single file as argument then we preset it as selected file if possible

            if (gif.getGelfile() != null) {
              File selfile = new File(gif.getGelfile());
              dialog.setSelectedFile(selfile);
            }

/*

            if (this instanceof CBEditor) {
              CBEditor cbed = (CBEditor)this;
              if ( cbed.gelFilenames != null &&
                   cbed.gelFilenames.size == 1) {
                 if (!cbed.gelFilenames.get(0).toLowerCase().endsWith("ohome.gel")) {
                    File selfile = new File(cbed.gelFilenames.get(0));
                    dialog.setSelectedFile(selfile);
                 }
              }
            }
*/

            if (dialog.showSaveDialog(this) != GELFileChooser.APPROVE_OPTION)
                return;

            File saveFile = dialog.getSelectedFile();
            saveToGEL(saveFile,gif,dialog.includeSources());
            currentLayoutDir=dialog.getCurrentDirectory();


        }
    }


    private void saveToGEL(File saveFile, GraphInternalFrame gif, boolean includeSources) {

            // -- if the chosen file does not end with .gel, the suffix is appended automatically

            if (!saveFile.getName().endsWith(".gel")) {
                saveFile = new File(saveFile.getPath() + ".gel");
            }

            // user can change the read/write of modules by the includeSources checkbox in GELFileChooser
            if (this instanceof CBEditor) {
              CBEditor cbed = (CBEditor)this;
              cbed.setReadCBModule(includeSources);
            }

         try {
            FileOutputStream FOStream = new FileOutputStream(saveFile);

            ObjectOutputStream out = new ObjectOutputStream(FOStream);
            gif.setStatusString("Saving graph file ...");

            // -- save title and DiagramDesktop
            out.writeObject(gif.getTitle());
            out.writeObject(this.getSize());  // size of graph editor
            out.writeObject(gif.getSize());   // size of internal frame
            out.writeObject(gif.getDiagramDesktop().getSize()); // size of diagram desktop
            gif.getDiagramDesktop().save(out);
            gif.getDiagramDesktop().setEdited(false);
            FOStream.close(); 
            gif.setStatusString("Saved graph to "+saveFile.getName());
            gif.setGelfile(saveFile.getAbsolutePath());
         } catch (IOException e) {
            Logger.getLogger("global").warning(e.getMessage());
         }
    }




    /**
     * Returns a the file specified by the given filename. If the filename is null, a
     * file chooser dialogue is used to select a GEL file (type *.gel). This method
     * is only called by loadGraphInternalFrame.
     *
     * @exception IOException if an error occurs
     */


    public File getGelFileForLoad(String filename) throws IOException {
      File selfile = null;
      CBEditor cbed = null;
      if (this instanceof CBEditor) {
         cbed = (CBEditor) this;
      }

      if (filename == null) {
         // -- a dialog is created to choose a file
         GELFileChooser dialog;
         if (cbed != null) {
           dialog = new GELFileChooser(cbed.getWriteCBModule());  // adds a checkbox for including sources
         }
         else
           dialog = new GELFileChooser();

         dialog.setMultiSelectionEnabled(false);
         dialog.setFileSelectionMode(JFileChooser.FILES_ONLY);
         dialog.setAcceptAllFileFilterUsed(false);
            // -- only files with suffix ".gel"(for GraphEditorLayout) are shown.
         GEFileFilter filter =
                new GEFileFilter(
                    "gel",
                    ".gel",
                    "ConceptBase Grapheditorlayout");

         dialog.setFileFilter(filter);
         dialog.setCurrentDirectory(currentLayoutDir);

         if (dialog.showOpenDialog(this) != JFileChooser.APPROVE_OPTION)
           return null;
         else {
           currentLayoutDir=dialog.getCurrentDirectory();  // memorize directory of gelfile
           selfile = dialog.getSelectedFile();
         }
         if (cbed != null)
           cbed.setWriteCBModule(dialog.includeSources()); // memorize checkbox info for including sources
      }
      else {
        selfile = new File(filename);
        // memorize directory of gelfile in currentLayoutDir
        if (selfile.exists() && !selfile.isDirectory()) {
          File dir = selfile.getParentFile();  
          if (dir != null && !filename.toLowerCase().endsWith("ohome.gel")) {
            currentLayoutDir = dir;
          } else { // Attempt current dir if filename had no path expression
            dir = new File(System.getProperty("user.home"));
            if (dir != null && dir.isDirectory()) {
// System.out.println("set "+System.getProperty("user.home"));
              currentLayoutDir = dir;
            }
          }
        }
      }

      if (cbed != null && selfile != null) {
              if (cbed.gelFilenames == null) 
                cbed.gelFilenames = new StringArray();
              if (cbed.gelFilenames.size == 0)
                 cbed.gelFilenames.add(selfile.getAbsolutePath());
              else if (cbed.gelFilenames.size == 1)  // we have loaded a new GEL file replacing the previous one
                 cbed.gelFilenames.replace(0,selfile.getAbsolutePath());
      }

      return selfile;

    }


    /**
     * calls loadGraphInternalFrame(.,.), i.e. forces the file chooser dialogue to select the GEL file,
     * uses the currently active (selected) GraphInternalFrame as target for the load
    */

    public void loadGraphInternalFrame() throws IOException, ClassNotFoundException {
      if (this instanceof CBEditor) {
        // current gif is empty --> reuse it
        if (getActiveGraphInternalFrame() != null && getActiveGraphInternalFrame() instanceof CBFrame &&
            getActiveGraphInternalFrame().getDiagramDesktop() != null &&
            getActiveGraphInternalFrame().getDiagramDesktop().getDiagramNodes().size() == 0) {
           loadGraphInternalFrame(getActiveGraphInternalFrame(),null);
        } else {
           CBEditor cbed = (CBEditor) this;
           CBFrame newframe = cbed.addNewCBFrame();
           loadGraphInternalFrame(newframe,null);
        }
      } else {
        loadGraphInternalFrame(getActiveGraphInternalFrame(),null);
      }
    }


    /**
     * Opens GEL file to create a {@link java.io.FileInputStream}. Replaces the title and
     * the {@link DiagramDesktop} of the active Frame by the title and DiagramDesktop loaded from
     * this stream. Expects one Frame to be selected. Keep in mind that there will not happen very
     * much, if the {@link GraphInternalFrame} does not implement the loadUserObject Method.
     * Loads the diagram desktop with the content stored in the GEL file. If the GEL file name is
     * null, then a file chooser dialog is used to select it.
     *
     * @param frame the internal frame into which the content of the GEL file shall be loaded
     * @param gelFilename the name of the GEL file
    */

    public void loadGraphInternalFrame(GraphInternalFrame frame, String gelFilename)
        throws IOException, ClassNotFoundException {

        if (frame == null) {
            JOptionPane.showMessageDialog(
                this,
                "No frame selected",
                "Error",
                JOptionPane.ERROR_MESSAGE);
        } else {

            File loadFile = getGelFileForLoad(gelFilename);
            if (loadFile == null)
              return;   // no valid file was provided

            frame.setStatusString("Loading graph file ...");
            FileInputStream FIStream = new FileInputStream(loadFile);

            ObjectInputStream in = new ObjectInputStream(FIStream);
            //XMLDecoder in = new XMLDecoder(new BufferedInputStream(FIStream) );

            ResourceBundle bundle = getGEBundle();

            Color ddColor = frame.getDiagramDesktop().getBackground();
            DiagramDesktop dd = new DiagramDesktop(frame);
            frame.setTitle((String) in.readObject());


            // read the window dimensions; old GEL files have only one dimension
            // stored for the diagram desktop; the new ones store three dimensions.
            Dimension d1 = (Dimension) in.readObject();
            if (d1.width >= 1500 && d1.height >= 1500) {
              // GEL file only contains the dd dimension
              dd.setSize(d1); 
            } else {
              // GEL file contains the three dimension objects
              
              this.setSize(fitToScreen(d1));
              this.bSizeSet = true;
              Dimension d2 = (Dimension) in.readObject();
              frame.setSize(fitToGE(d1,d2));
              dd.setSize((Dimension) in.readObject());
            }

            dd.setBackground(ddColor);  // bgcolor of current diagram desktop
            frame.setDiagramDesktop(dd);
            dd.load(in);
            FIStream.close();
            if (!loadFile.getName().toLowerCase().endsWith("ohome.gel")) {
               frame.setStatusString(loadFile.getName() + " loaded");
               this.setSubtitle(loadFile.getAbsolutePath());
               this.repaint();
            }
            frame.setGelfile(loadFile.getAbsolutePath());

            //getActiveGraphInternalFrame().validateNodes();
        }
    }



     /** 
     * Adapt the window size to the screen size.
     * @param d  original Dimension of a window to be displayed on the current screen
     * @return Dimension that is the reduction of Dimension d to the screen size
     */

    public Dimension fitToScreen(Dimension d) {
      Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
      int w = d.width;
      int oldw = this.getSize().width;
      if (this.bSizeSet && oldw > w)  // do not get smaller than originally
        w = oldw;
      if (w > screenSize.width - 63)
        w = screenSize.width - 63;
      int h = d.height;
      int oldh = this.getSize().height;
      if (this.bSizeSet && oldh > h)
        h = oldh;      
      if (h > screenSize.height - 24)
        h = screenSize.height - 24;
      return new Dimension(w,h);
    }

     /** 
     * Adapt the window size of a graph internal frame to the size of the graph editor window-
     * @param geSize size of the graph editor window
     * @param gifSize proposed size of the graph internal window
     * @return Dimension that is the reduction of Dimension gifSize to the geSize
     */

    public Dimension fitToGE(Dimension geSize, Dimension gifSize) {
      int w = gifSize.width;
      if (w > geSize.width - 2)
        w = geSize.width - 2;
      int h = gifSize.height;
      if (h > geSize.height - 91)  // the toolbar plus border of the graph editor is 111 (91!) points high
        h = geSize.height - 91;
      return new Dimension(w,h);
    }

    /**
     * @return the active GIF, null if no GIF is selected.
     */
    public GraphInternalFrame getActiveGraphInternalFrame() {
        for (int i = 0; i < m_vGraphInternalFrames.size(); i++) {
            GraphInternalFrame gif = (GraphInternalFrame) m_vGraphInternalFrames.get(i);
            if (gif.isSelected()) {
                return gif;
            }
        }
        return null;
    }


    /**
     * @return the number of graph internal frames of this graph editor
     */
    public int countGIFs() {
      if (m_vGraphInternalFrames==null) 
        return 0;
      else
        return m_vGraphInternalFrames.size();
    }

    /**
     * @return the DesktopPane of the GraphEditor
     */
    public JDesktopPane getDesktopPane() {
        return m_mainDesktopPane;
    }

    /**
     * Gets you the m_graphToolBar for editing
     *
     * @return the editor's toolbar
     */
    public JToolBar getGraphToolBar() {
        return m_graphToolBar;
    }

    public void setGraphToolBar(JToolBar graphToolBar) {
        this.m_graphToolBar = graphToolBar;
    }

    /**
     * The geBundle is sometimes needed for translation purposes
     *
     * @return this editor's textBundle
     */
    public ResourceBundle getGEBundle() {
        return ResourceBundle.getBundle(
            GEConstants.GE_BUNDLE_NAME,
            getLocale());
    }

    /**
     * Lets one controll if the program's progressbar shall be shown
     * (if the gifworker wants to show something) or not.
     *
     * The method is used by the {@link IFrameWorker} of the currently active GraphInternalFrame,
     * as we only want to see the progressbar while the m_gifWorker is working
     *
     * @param bShowIt a <code>boolean</code> value
     */
    public void showProgressStatus(boolean bShowIt) {
        if (bShowIt) {
            if (m_statusProgressBar == null) {
                m_statusProgressBar = new JProgressBar();
                m_statusProgressBar.setVisible(false);

                m_graphStatusBar.addSeparator();
                m_graphStatusBar.add(m_statusProgressBar);
            }
        } else {
            if (m_statusProgressBar != null) {
                m_graphStatusBar.remove(m_statusProgressBar);
                //That's the separator after the connection status label
                m_graphStatusBar.remove(1);
                m_statusProgressBar.setVisible(false);
                m_statusProgressBar = null;
            }
        }
    } //showProgressStatus

    public GraphMenuBar getGraphMenuBar() {
        return m_graphMenuBar;
    }

    /**
    * Returns the progressbar
    * This is used to hand over the progressbar to a m_gifWorker so it can manipulate it thus showing its progress
    *
    * @return a <code>JProgressBar</code> value
    */
    public JProgressBar getProgressBar() {
        return m_statusProgressBar;
    }

    /**
     * Sets this GraphEditor's Locale to the specified value and updates the MenuBar, the ToolBar
     * and all {@link GraphInternalFrame}s.
     *
     * @param loc the new Locale
     * @return always null at the moment
     */
    public DefaultStyledDocument updateLang(Locale loc) {
        setLocale(loc);
        ResourceBundle bundle = this.getGEBundle();

        //update the GraphInternalFrames
        Enumeration framesWalker = m_vGraphInternalFrames.elements();
        GraphInternalFrame currentGif;
        while (framesWalker.hasMoreElements()) {
            currentGif = (GraphInternalFrame) framesWalker.nextElement();
            currentGif.updateLang(loc);
        }

        //update the graphMenubar if one is present
        if (m_graphMenuBar != null)
            m_graphMenuBar.updateLang(loc);

        //update the graphtoolbar
        getToolBarButton(GEConstants.NEWFRAME_BUTTON).setToolTipText(
            bundle.getString("ToolTip_NewFrame"));
        getToolBarButton(GEConstants.SAVE_BUTTON).setToolTipText(
            bundle.getString("ToolTip_Save"));
        getToolBarButton(GEConstants.LOAD_BUTTON).setToolTipText(
            bundle.getString("ToolTip_Load"));
        getToolBarButton(GEConstants.REMOVE_BUTTON).setToolTipText(
            bundle.getString("ToolTip_Remove"));

        return null;
    }



    /**
     * Shutdown this graph editor. If started as applet, the applet will be destroyed and disposed.
     * If the graph editor was started as application, then it the application process is exited.
     */

    public void shutdown() {

        if(m_currentHandler != null){
            m_currentHandler.close();
        }
        if (m_applet == null) {
            System.exit(0);
        } else {
            m_applet.destroy();
            this.dispose();
        }
    }


    /**
     * Close this graph editor. If it was not connected to a CBIva workbench, then a shutdown is
     * performed. Otherwise, it disconnects from CBIva, dosposes its  internal frames, and sets itself
     * to invisible. If the graph was changed, the user conforms whether the changes should be saved
     * to a file.
     */

   public void close() {
        // save the current graph if it has been edited
        saveGraphIfNeeded();
        //shutdown the GraphEditor if no Workbench is present
        if (!(this instanceof CBEditor)) {
          shutdown();
          return;
        }

        CBEditor cbEditor = (CBEditor) this;

        // issue #56: save the image of the diagram desktop as PNG file if option -savepng was used with CBGraph
        if (cbEditor.getSavePngMode()) {
           savePngFile();
           cbEditor.setSavePngMode(false);
        }

        if (cbEditor.getWorkbench()==null){
           shutdown();
        }

        cbEditor.getWorkbench().setCBEditor(null);
        java.util.Iterator it=cbEditor.getGraphInternalFrames().iterator();
        // iterate over all internal Frames, disconnect and dispose them
        while (it.hasNext()) {
              Object o=it.next();
              if (o instanceof CBFrame) {
                  CBFrame cbf=(CBFrame) o;
                  if (cbf.isConnected()){
                     cbf.disconnect(false);
                     it.remove();
                  }
                  cbf.dispose();
              }
        }
        cbEditor.saveLayoutPath();
        //hide GraphEditor, we can't dispose it because this would dispose the Workbench too.
        setVisible(false);
   }


    public void openNewFrame() {
        addGraphInternalFrame(new GraphInternalFrame(this, "New Frame"));
    }

    public boolean isApplet() {
        return m_applet != null;
    }

    /** Getter for property infoPane.
     * @return Value of property infoPane.
     */
    public JTextPane getInfoPane() {
        return m_infoPane;
    }

    /** Setter for property infoPane.
     * @param infoPane New value of property infoPane.
     */
    public void setInfoPane(JTextPane infoPane) {
        this.m_infoPane = infoPane;
    }

    /** Getter for property m_mainDesktopPane.
     * @return Value of property m_mainDesktopPane.
     */
    public JDesktopPane getMainDesktopPane() {
        return this.m_mainDesktopPane;
    }

    /** Setter for property m_mainDesktopPane.
     * @param mainDesktopPane New value of property m_mainDesktopPane.
     */
    public void setMainDesktopPane(JDesktopPane mainDesktopPane) {
        this.m_mainDesktopPane = mainDesktopPane;
    }

    /**
     * Supposed to be called only by m_GraphIntenalFrameListener or extensions of this
     *
     * @param sStatus the new status we want to change to.
     */
    public void setStatusString(String sStatus) {
        m_statusConnectionLabel.setText(sStatus);
        if (sStatus == null)
          return;
// System.out.println("GraphEditor: "+sStatus);
    }

    public void propertyChange(PropertyChangeEvent evt) {
        String sPropertyName = evt.getPropertyName();
        if (sPropertyName.equals("status")) {
            if (((GraphInternalFrame) evt.getSource()).isSelected()) {
                setStatusString((String) evt.getNewValue());
            }
        }

    }

    public GraphInternalFrameListener getGifListener() {
        return m_graphInternalFrameListener;
    }


    /**
     * Propose to save graph to a GEL file if it has been loaded from a GEL file and it was edited
    */

    public void saveGraphIfNeeded() {
       DiagramDesktop dd = null;
       String filename = null;
       if (this.getActiveGraphInternalFrame() != null) {
          dd = this.getActiveGraphInternalFrame().getDiagramDesktop();
          filename = this.getActiveGraphInternalFrame().getGelfile();
       }
       saveGraphIfNeeded(dd,filename);
    }

    public void saveGraphIfNeeded(DiagramDesktop dd) {
       String filename = null;
       if (this.getActiveGraphInternalFrame() != null) {
          filename = this.getActiveGraphInternalFrame().getGelfile();
       }
       saveGraphIfNeeded(dd,filename);
    }

    public void saveGraphIfNeeded(DiagramDesktop dd,String gelFilename) {
          if (!(this instanceof CBEditor))
            return;
          CBEditor cbed = (CBEditor)this;
          if (cbed.gelFilenames == null)
            return;
  
          if (gelFilename == null && cbed.gelFilenames.size == 1)
            gelFilename = cbed.gelFilenames.get(0);
          if (gelFilename == null)
            return;
          if (gelFilename.toLowerCase().endsWith("ohome.gel")) {
            return;
          }
          if (
                gelFilename.toLowerCase().startsWith("/tmp")      ||    // Linux temporary directory
                gelFilename.toLowerCase().indexOf("temp\\") != -1 ||    // Windows temporary directory
                gelFilename.toLowerCase().indexOf("tmp\\") != -1  ||    // another Windows temporary directory
                gelFilename.toLowerCase().indexOf("\\temporary") != -1  ||   // yet another Windows temporary directory
                gelFilename.toLowerCase().indexOf("downloads\\") != -1  // the Windows download directory
             )
            return; // GEL is in a temporary directory; will not propose to save it
          if (dd != null && dd.isEdited()) {
             try {
                showSaveGraphDialog(gelFilename);
             } catch (Exception ex) {
             }
          }
    }


    // issue #56: synchronize the module sources in the GEL file from the CBserver if flag -resync was used to start CBGraph

    public void saveGraphForResync(String gelFilename) {
       DiagramDesktop dd = null;
       if (this.getActiveGraphInternalFrame() != null) {
          dd = this.getActiveGraphInternalFrame().getDiagramDesktop();
       }
       saveGraphForResync(dd,gelFilename);
    }

    public void saveGraphForResync(DiagramDesktop dd,String gelFilename) {
          if (!(this instanceof CBEditor))
            return;
          if (dd != null) {
             saveToGEL(new File(gelFilename), getActiveGraphInternalFrame(), true);
          }
    }


    /* savePngFile is called on close() of the GraphEditor if the flag -savepng was used to start CBGraph */

    public void savePngFile() {
       DiagramDesktop dd = null;
       String pngFilename = null;
       if (this.getActiveGraphInternalFrame() != null) {
          dd = this.getActiveGraphInternalFrame().getDiagramDesktop();
          pngFilename = this.getActiveGraphInternalFrame().getGelfile().replaceAll(".gel",".png");
       }
       if (dd == null)
         return;
       File pngFile = new File(pngFilename);
       dd.saveScreenShot("png",pngFile);
    }


    public void showSaveGraphDialog(String gelFilename) {
        int response =JOptionPane.showConfirmDialog(this,
                                  getGEBundle().getString("GMB_SaveGraphFile_Question")+gelFilename+"?",
                                  getGEBundle().getString("GMB_SaveGraphFile_Title"),
                                  JOptionPane.YES_NO_OPTION, JOptionPane.QUESTION_MESSAGE);
        if (response == JOptionPane.YES_OPTION) {
          saveToGEL(new File(gelFilename), getActiveGraphInternalFrame(), true);
        }
    }



    /** Inner class to implement the FilenameFilter interface
     *
     * @author <a href="mailto:">Tobias Latzke</a>
     * @see FilenameFilter
     */
    public class GEFileFilter
        extends javax.swing.filechooser.FileFilter
        implements Serializable {

        private ArrayList m_Extensions = new ArrayList();
        private String m_sDescription;
        private String m_sExtension = "";
        private String m_sFormat;

        /**
         * Creates a new FileFilter
         *
         * @param sFormat the name of the desired format
         * @param sExtension the fileExtension to filter for
         * @param sDescription a description of the desire file.
         */
        GEFileFilter(String sFormat, String sExtension, String sDescription) {
            m_sFormat = sFormat;
            m_sExtension = sExtension;
            m_sDescription = sDescription;

        }

        /** Whether the given file is accepted by this filter.
         */
        public boolean accept(java.io.File file) {
            String extension = getFileExtension(file);

            Logger.getLogger("global").finest(
                "fileExtension: "
                    + extension
                    + "; m_sExtension: "
                    + m_sExtension
                    + ";");

            if (extension.equals(m_sExtension)
                || m_Extensions.contains(extension)
                || file.isDirectory())
                return true;
            else
                return false;
        }

        /** The description of this filter. For example: "JPG and GIF Images"
         * @see FileView#getName
         */
        public String getDescription() {
            return m_sDescription;
        }

        private String getFileExtension(java.io.File f) {
            String ext = null;
            String s = f.getName();
            int i = s.lastIndexOf('.');

            if (i > 0 && i < s.length() - 1) {
                ext = s.substring(i).toLowerCase();
            }
            if (ext == null) {
                ext = "";
            }
            //Logger.getLogger("global").fine("ext = '"+ext+"'; s = '"+s+"';");
            return ext;
        }

        private String getFilterFormat() {
            return m_sFormat;
        }

    } // end inner class GEFileFilter

} // end class GraphEditor
