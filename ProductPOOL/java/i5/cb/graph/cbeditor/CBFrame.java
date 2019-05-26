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
package i5.cb.graph.cbeditor;



import i5.cb.CBConfiguration;
import i5.cb.CBException;
import i5.cb.api.CBclient;
import i5.cb.api.CButil;
import i5.cb.api.CBanswer;
import i5.cb.graph.cbeditor.CBEditor;
import i5.cb.graph.*;
import i5.cb.graph.diagram.DiagramClassHashtableEntry;
import i5.cb.graph.diagram.DiagramNode;
import i5.cb.telos.object.*;
import i5.cb.graph.cbeditor.StringArray;
import i5.cb.graph.cbeditor.CBUserObject;
import i5.cb.graph.cbeditor.components.CBTree;

import java.io.*;
import java.rmi.RemoteException;
import java.util.*;

import javax.swing.*;
import javax.swing.event.InternalFrameAdapter;
import javax.swing.event.InternalFrameEvent;
import javax.xml.parsers.*;
import java.awt.Dimension;

import org.w3c.dom.*;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;



/** This class both is a container for the {@link i5.cb.graph.DiagramDesktop} and
 * the ConceptBaseEditor's interface to a certain CB-Server
 *
 * @author schoeneb
 * created 08 March 2002
 */

public class CBFrame extends GraphInternalFrame implements java.beans.PropertyChangeListener{



    CBDiagramClass m_cbDC;
    CBclient m_cbClient;
    ObjectBaseInterface m_obi;
    ResourceBundle m_bundle;
    String m_sHost;
    String m_sPort;
    String m_sPalette;
    String m_sTitle;  // the title of the CBFrame without connection status
    String m_bgcolor; // expected RGB format like "255,255,255"
    String m_bgimage; // background image for the DiagramDesktop of this CBFrame
    String m_longtitle; //long title of the palette of this CBFrame
    String m_Context;  // name of an object, model or module that characterizes this CBFrame
    String m_UserHome = "System"+CBConfiguration.getModuleSeparator()+"oHome";  // module path of the home module of the user
    HashMap m_PropertiesOfGraphicalTypes;
    HashMap m_implementedBy;
    HashMap m_defaultGraphTypes;
    boolean savedGrTypesAndImpl;
    boolean loadedGrTypesAndImpl;
    boolean m_bIsConnected=false;
    private List m_DiagHashObjectsToAdd;
    private List m_DiagHashObjectsToDelete;
    String modulesToBeSaved=null;     // can hold the sequence of modules sources to be saved in GEL file, e.g. "oHome-M1"
    StringArray moduleSources=null;  // can hold the module sources read from a GEL file


    /** Constructor for the CBFrame object
     *
     * @param editor the cbEditor this object belongs to
     * @param title this CBFrame's default title as shown in the titlebar
     * @param sPalette this CBFrame's graphical palette
     */

    public CBFrame(CBEditor editor, String title, String sPalette) {
      this(editor, title, sPalette, null);
    }


    /** Constructor for the CBFrame object
     *
     * @param editor the cbEditor this object belongs to
     * @param title this CBFrame's default title as shown in the titlebar
     * @param sPalette this CBFrame's graphical palette
     * @param sContext label of the module or model or object that is displayed with this CBFrame
     */
    
    public CBFrame(CBEditor editor, String title, String sPalette, String sContext) {
        super(editor, title);

        m_DiagHashObjectsToAdd=new ArrayList();
        m_DiagHashObjectsToDelete=new ArrayList();
        m_PropertiesOfGraphicalTypes=new HashMap();
        m_defaultGraphTypes=new HashMap();
        m_implementedBy=new HashMap();
        m_Context = sContext;
        m_cbDC = new CBDiagramClass(this);

        resetPaletteProperties();  // bgcolor etc. can be set via the palette but need defaults

        m_bundle = ResourceBundle.getBundle(CBConstants.CB_BUNDLE_NAME);
        m_gifWorker = new CBFrameWorker(this);
        this.addInternalFrameListener(
        new InternalFrameAdapter() {
            //public void windowClosed(java.awt.event.WindowEvent e) {
            //}
            public void internalFrameClosing(InternalFrameEvent e) {
                //JOptionPane.showConfirmDialog((CBFrame) e.getSource(),
                //		m_bundle.getString("CBFrame_confirmDisconnect_message"),
                //		m_bundle.getString("CBFrame_confirmDisconnect_title"),
                //		JOptionPane.YES_NO_OPTION);
                disconnect(true);
            }
        });

        setFrameTitle(title);
        setCBEditor(editor);
        setGraphicalPalette(sPalette);   // can also reset the title if the palette defines a longtitle

        setResizable(true);
        setClosable(true);
        setIconifiable(true);
        getDiagramDesktop().setBackground(CBConfiguration.getDDColor() );
    }

    /** Makes sure that the frame's DiagramClass is a completely empty {@link CBDiagramClass}.
     */

    public void resetDiagramClass() {
        m_diagramClass = new CBDiagramClass(this);
    }



    /** Connects to a ConceptBase Server
     *
     * @param host  : the host our server runs on
     * @param sPort  : the portnumber we want to connect to
     * @param tool informs the CB server abount the program which wants to connect.
     * @param user  : the user who wants to connect
     * @return false iff a {@link i5.cb.CBException} occured
     */


    public boolean connectToServer(String host, String sPort, String tool, String user) {
        try {
            int port = Integer.parseInt(sPort);
            m_cbClient = new CBclient(host, port, tool, user);
            m_cbClient.addPropertyChangeListener(this);
            m_obi = new ObjectBaseInterface(m_cbClient);
            m_obi.setUseCache(true);
            m_sHost = host;
            m_sPort = sPort;
            m_bIsConnected=true;
         /**   loadGraphicalPaletteAndImplementation(true);     loaded in CBFrameWorker.java after module switch! */
        }
        catch(java.security.AccessControlException ace) {
            JOptionPane.showMessageDialog(getCBEditor(), 
                "Access to this host not allowed for this applet","Error",JOptionPane.ERROR_MESSAGE);
            return false;
        }
        catch (CBException ce) {
            java.util.logging.Logger.getLogger("global").fine("caught CBException!\n" + ce.getMessage());
            return false;
        }

        return true;
    }

    /**
     *Description of the Method
     */

    public void disconnect(boolean removeFromCBEditor ) {
        if(m_cbClient==null)
            return;
        try{
            m_cbClient.cancelMe();
            //m_cbEditor.getToolBarButton(CBConstants.NEW_NODE_BUTTON).setEnabled(false);
            setButtonEnabled(CBConstants.NEW_NODE_BUTTON, false);
            //m_cbEditor.getToolBarButton(CBConstants.SHOW_RELATIONS_BUTTON).setEnabled(false);
            setButtonEnabled(CBConstants.SHOW_RELATIONS_BUTTON, false);


            setButtonEnabled(GEConstants.LOAD_BUTTON, false);
            setButtonEnabled(GEConstants.SAVE_BUTTON, false);
            setButtonEnabled(GEConstants.REMOVE_BUTTON, false);

            setButtonEnabled("Toolbar_AddIndividual", false);
            setButtonEnabled("Toolbar_AddAttribute", false);
            setButtonEnabled("Toolbar_AddInstantiation", false);
            setButtonEnabled("Toolbar_AddSpecialization", false);
            setButtonEnabled("Toolbar_Commit", false);
            setButtonEnabled("Toolbar_RemoveItemFromCommit", false);

            setMenuEnabled("GMB_EditMenu_Title", false);
            setMenuEnabled("GMB_ActiveFrame_Title", false);
            setItemEnabled("GMB_OptionsMenu_DDBackground", false);
            setMenuEnabled("GMB_OptionsMenu_CBComponent", false);

            setItemEnabled("GMB_FileMenu_Load", false);
            setItemEnabled("GMB_FileMenu_Save", false);
            setItemEnabled("GMB_FileMenu_Print", false);
            setItemEnabled("GMB_FileMenu_ScreenShot", false);

            setItemEnabled("GMB_ActiveFrameMenu_SubmitQuery", false);
            setItemEnabled("GMB_ActiveFrameMenu_ValidateObjects", false);
            setItemEnabled("GMB_ActiveFrameMenu_ValidateSelectedObjects", false);

            if(removeFromCBEditor){
                ((CBEditor)(m_graphEditor)).removeGraphInternalFrame(this);
            }
        }catch (CBException cbe){
            java.util.logging.Logger.getLogger("global").warning(cbe.getMessage());
        }catch(RemoteException re){
            java.util.logging.Logger.getLogger("global").warning(re.getMessage());
        }
    }

    /** Gets this object's {@link i5.cb.telos.object.ObjectBaseInterface}
     * @return The objectbaseinterface
     */

    public ObjectBaseInterface getObi() {
        return m_obi;
    }

    /** Get's the cbEditor the frame belongs to
     * @return this frame's cbeditor (kind of parent)
     */

    public CBEditor getCBEditor(){
        return (CBEditor)m_graphEditor;
    }



    public void setCBEditor(CBEditor value){
        m_graphEditor = value;
    }

    /** Gets this cbFrames {@link java.util.ResourceBundle}
     * @return The resourcebundle currently used by this cbFrame
     */

    public ResourceBundle getBundle(){
        return m_bundle;
    }

    /**
     * Return the name of the graphical palette used in this frame.
     */

    public String getGraphicalPalette(){
        return m_sPalette;
    }

    /**
     * Return the module context of this frame.
     */

    public String getContext() {
        return m_Context;
    }

    /**
     * Return the compressed module context of this frame; like getContext but leaves out prefix System-oHome when possible
     */

    public String getShortContext() {
        return compressedPath(m_Context);
    }




    /** Gets the name of the host on which the CB server runs
     * @return The CB server's hostname
     */

    public String getHost() {
        return m_sHost;
    }


    /** Gets the logical name of the host on which the CB server runs;
     * this is the same as getHost() except when this CBFrame is using
     * a public CBserver; in this case the logical hostname is "localhost"
     * @return The CB server's logical hostname
     */
    public String getLogicalHost(){
       if (usingPublicCBserver())
         return "localhost";
       else
         return getHost();
    }


    /** Gets the name of the title of this CBFrame without connection status
     */

    public String getFrameTitle(){
        return m_sTitle;
    }



    /** Gets the port on which the CB server runs
     * @return the CB server's portnumber
     */

    public String getPort(){
        return m_sPort;
    }

    /** Gets the long title of this CBFrame palette
     * @return the long title
     */

    public String getLongTitle(){
        return m_longtitle;
    }

    /** Gets the CBclient of this CBFrame
     * @return the CBclient of this CBFrame
     */

    public CBclient getCBclient(){
        return m_cbClient;
    }


    /** True if this CBFrame shall attempt to use a public CBserver 
    */

    public boolean usePublicCBserver() {
        return !CBConfiguration.getPublicCBserverHost().equals("none");
    }

    /** True if this CBFrame is actually using a public CBserver 
    */
    public boolean usingPublicCBserver() {
        return CBConfiguration.getPublicCBserverHost().equals(m_sHost) &&
               CBConfiguration.getPublicCBserverPort().equals(m_sPort);
    }


    /** set the graphical palette of this CBFrame
     * @value the object name of the new palette 
     */

    public void setGraphicalPalette(String value){
       if (getDiagramDesktop() != null &&
           m_sPalette != null &&
           !m_sPalette.equals(value)) {
          getDiagramDesktop().setEdited(true);
        }
        m_sPalette = value;
    }

    /** set the hostname that this CBFrame shall be connected to
     * @value the name of the host
     */

    public void setHost(String value){
        m_sHost = value;
    }

    /** set the portnumber that this CBFrame shall be connected to
     * @value the port number
     */

    public void setPort(String value){
        m_sPort = value;
    }

    /** set the long title of this CBFrame
     * @value the long title
     */

    public void setLongTitle(String value){
       m_longtitle = value;
    }

    /** set the module context of this CBFrame
     * @value the default label of the module context
     */

    public void setContext(String value){
        m_Context = value;
        try {
          CBanswer ans=getCBclient().getModulePath();
          if (ans.getCompletion() == CBanswer.OK ) {
             m_Context = ans.getResult();
          }
        }
        catch (Exception e) {
        }
    }

     /** set the module context of this CBFrame from current module of the CBclient
     * 
     */

    public void setContext(){
        try {
          CBanswer ans=getCBclient().getModulePath();
          if (ans.getCompletion() == CBanswer.OK ) {
             m_Context = ans.getResult();
          }
        }
        catch (Exception e) {
        }
    }


    /** sets the CBFrame to the configuration of the new view extracted from a GEL file
     * @newHost the label of the new host of the CBserver we want to be connected with
     * @newPort the portnumber of the CBserver we want to be connected with
     * @newContext the label of the module context
     */

    public void reconnectView(String newHost, String newPort, String newContext) {
        setStatusString("Re-connecting to the CBserver ...");
        // only module is different and CBFrame is connected to CBserver
        if (isConnected() && newHost.equals(getHost()) && newPort.equals(getPort()) && !newContext.equals(getContext()) ) {
           java.util.logging.Logger.getLogger("global").fine("Need to switch module");
           setModulePath(newContext);
        }
        // expected host or port are different from current one to which CBFrame is connected
        else if (isConnected() && (!newHost.equals(getHost()) || !newPort.equals(getPort())) ) {
           java.util.logging.Logger.getLogger("global").fine("Need to disconnect and then reconnect");
           reconnectToServer(newHost,newPort,newContext);
        }
        // the CBFrame is currently unconnected
        else if (!isConnected() ) {
           java.util.logging.Logger.getLogger("global").fine("Need to connect from scratch");
           connectToServerFromDisconnected(newHost,newPort,newContext);
        }
        // we are running the right server and use the right module context
        else
           java.util.logging.Logger.getLogger("global").fine("Already connected to right server and module");
        setFrameTitle();  // because the connection status could have been changed
    }


    /** set the module context at the CBserver connected to this CBFrame via its CBclient
     * @newContext the label of the module context
     */


    public boolean setModule(String newContext) {
       try {
         CBanswer ans=getCBclient().setModule(newContext);
         if (ans.getCompletion() == CBanswer.OK ) {
           return true;
         } else {

           java.util.logging.Logger.getLogger("global").finer("Failed to set the module context to "+newContext);
           return false;
         }
       }
       catch (Exception e) {
         java.util.logging.Logger.getLogger("global").warning("Error when setting the module context to "+newContext);
         return false;
       }
    }




    /* like setModule but strips the prefix "System-oHome-" from the module context before setting it
     * @newContext the label of the module context
    */


    public boolean setModulePath(String newContext) {
      boolean success;
      CBConfiguration.setModuleSeparator(newContext);
      if (usingPublicCBserver()) { // connected to a public CBserver
         String prefix = "System" + CBConfiguration.getModuleSeparator() 
                                  + "oHome" + CBConfiguration.getModuleSeparator();
         success = setModule(newContext.replaceFirst(prefix,""));  // strip the absolute path
      } else
         success = setModule(newContext);
      if (success) {
           setContext(newContext);  // just to memorize it
           this.setStatusString("Module set to "+newContext);
      }
      return success;
    }
   

    public void setUserHome() {
        try {
          CBanswer ans=getCBclient().getModulePath();
          if (ans.getCompletion() == CBanswer.OK ) {
             String answer = ans.getResult();
             CBConfiguration.setModuleSeparator(answer);
             m_UserHome = answer;
          }
        }
        catch (Exception e) {
        }
    }

    public String getUserHome() {
      return m_UserHome;
    }



     /** disconnect from current server and then reconnect to the new server
     * @newHost the label of the new host of the CBserver we want to be connected with
     * @newPort the portnumber of the CBserver we want to be connected with
     * @newContext the label of the module context
     */


    public void reconnectToServer(String newHost, String newPort, String newContext) {
      disconnect(false);  // stay linked to the CBIva if linked before
      connectToServerFromDisconnected(newHost,newPort,newContext);
    }


     /** connect to the new server from a disconnected state
     * @newHost the label of the new host of the CBserver we want to be connected with
     * @newPort the portnumber of the CBserver we want to be connected with
     * @newContext the label of the module context
     */

    public void connectToServerFromDisconnected(String newHost, String newPort, String newContext) {
      String username = System.getProperty("user.name");
      String toolname = CBConstants.CBEDITOR_NAME;
      m_bIsConnected = connectToServer(newHost, newPort, toolname, username);
      if (m_bIsConnected) {
        m_sHost = newHost;
        m_sPort = newPort;
        setUserHome();  // the home module of user username, being the current module just after connectToServer
        setModulePath(newContext);
        this.setButtonEnabled(CBConstants.NEW_NODE_BUTTON, true);
        this.setButtonEnabled(CBConstants.SHOW_RELATIONS_BUTTON, true);
        this.setButtonEnabled("Toolbar_Commit", true);
        this.setItemEnabled("GMB_ActiveFrameMenu_SubmitQuery", true);
        this.setItemEnabled("GMB_ActiveFrameMenu_ValidateObjects", true);
        this.setItemEnabled("GMB_ActiveFrameMenu_ValidateSelectedObjects", true);
        this.setItemEnabled("GMB_ActiveFrameMenu_ChangeGraphicalPalette", true);
        this.setItemEnabled("GMB_ActiveFrameMenu_ChangeGraphModule", true);
        this.setStatusString(getBundle().getString("Status_Connected")+" "+newHost);
      }
    }


    /**
    * 2nd try; start  a local slave CBserver or use public CBserver;
    * called in DiagramDesktop when the moduleSources are not empty and the previous attempt
    * to a running CBserver failed; we can only start a CBserver on localhost though
    */

    public void startLocalServerAndConnect(String newHost, String newPort, String newContext) {
      if (m_bIsConnected)
         return;
      if (usePublicCBserver() && newHost.equals("localhost")) {
        setStatusString("Connecting to public CBserver ...");
        connectToServerFromDisconnected(CBConfiguration.getPublicCBserverHost(),newPort,newContext);
      }
      if (!m_bIsConnected && newHost.equals("localhost")) {
        setStatusString("Starting up local CBserver on port " + newPort + " ...");
        boolean started = CBclient.startLocalCBserver(newPort);
        if (started) {
          connectToServerFromDisconnected(newHost,newPort,newContext);
        }
      } 
      if (!m_bIsConnected)
        showNotConnected();
    }


    /**
     * load all the module sources stored in the input file and try to tell them to the CBserver;
     * the input file shall have a String like "oHome-M1" specifying which modules are stored
     * on the input file; note that we have to read the module sources from the input file even if the
     * option "-w"  was not set in the call of cbgraph because there can be further elements after
     * the module sources on the input file
     * @param in input file 
     */

    public void loadModuleSources(ObjectInputStream in) throws IOException, ClassNotFoundException {
       modulesToBeSaved = (String) in.readObject();
       String[] modules = modulesToBeSaved.split(CBConfiguration.getModuleSeparator(modulesToBeSaved));
         moduleSources = new StringArray();
       for (int i = 0; i < modules.length; i++)
        loadOneModuleSource(modules[i],in);
       setContext();     // shall be the module context after loading the last module source
       setFrameTitle();  // update the frame title to show the current module context
    }


    /**
     * load the next string, interpreted as module source, from the input file and tell it to the given module ;
     * it is only told to the CBserver if the write option -w was set in the call of 'cbgraph' and
     * this CBFrame is conncted to a CBserver
     * @param modName name of a single module
     * @param in input file 
     */

    public void loadOneModuleSource(String modName, ObjectInputStream in) {
       try {
         String sModSource = (String) in.readObject();
         if (isConnected() && getCBEditor().getWriteCBModule()) {
            // ticket #384: make sure the module exists
            getObi().getCBClient().tell(getLastModuleName(modName)+" in Module end");  
            CBanswer ans=getObi().getCBClient().setModule(effectiveModuleName(modName));
            if (ans.getCompletion() == CBanswer.OK ) {
              setStatusString("Telling source for "+modName+" ...");
              getObi().getCBClient().tellTransactions(sModSource);  // ticket #384: tell in separate transactions
              setStatusString("Source for "+modName+" loaded");
            }
            else
              java.util.logging.Logger.getLogger("global").warning("Cannot set module "+modName);
         } else {
            moduleSources.add(sModSource);
         }
       } catch (Exception e) {
        java.util.logging.Logger.getLogger("global").warning("Failed to write module source to CBserver "+modName);
       }
    }



    /**
     * replace the module name "oHome" or "$Home" by the current user home directory if we are
     * connected to the public CBserver; hence when telling the modules of a GEL file
     * the oHome or $Home module effectively is told to the user home module, not the physical oHome;
     * the prefix System-oHome- is stripped
     * @param modName
     */

    // a bit dirty trick; would be nicer if the GEL file would have a logical module path
    // such as $Home-MyModule
    private String effectiveModuleName(String modName) {
      String prefix = "System" + CBConfiguration.getModuleSeparator()  + "oHome";
      if ((modName.equals("oHome")) && usingPublicCBserver() && !getUserHome().equals(prefix)) 
        return getUserHome();
      else if (modName.equals("$Home"))
        return getUserHome();
     else
        return modName;
    }

    // return the last module name (like MyMod) in a path like System-oHome-MyMod 
    private String getLastModuleName(String modPath) {
      if (modPath.contains(CBConfiguration.getModuleSeparator())) {
         String[] modules = modPath.split(CBConfiguration.getModuleSeparator(modPath));
         return modules[modules.length-1] ;
      } else {
         return modPath;
      }
    }

     


    /**
     * The relative module path is the path starting with the home module of this client's user;
     * The home module is replaced by $Home if the user has a dedicated home module if this
     * client is logged into a public CBserver. Otherwise we just strip off the prefix System-
     * because the System module is never saved
     * @return String containing a module path 
     */

    private String getRelativeModPath() {
      String prefix = "System" + CBConfiguration.getModuleSeparator();
      if (usingPublicCBserver())
        return getContext().replace(getUserHome(),"$Home"); // example: System-oHome-freddy becomes $Home
      else
        return getContext().replace(prefix,""); // System module is not to be saved because it is not changed
    }

    

    /**
     * extract the sources of all modules except System of the current module context and save it to the output file;
     * this method is on called when this CBFrame is conected to a CBserver
     * @param out output file 
     */

    public void saveModuleSources(ObjectOutputStream out) throws IOException {
      if (isConnected())
        modulesToBeSaved = getRelativeModPath();  // without System and replacing user home
      String[] modules = modulesToBeSaved.split(CBConfiguration.getModuleSeparator(modulesToBeSaved));
      if (!isConnected() && modules.length != moduleSources.size) {
         java.util.logging.Logger.getLogger("global").warning("Alarm: Inconsistent module numbers: "+modulesToBeSaved+
                                                 " must have "+moduleSources.size + " module labels");
         modulesToBeSaved = "";
         out.writeObject(modulesToBeSaved);  // empty module path
         return;                             // no module sources written
      }
      out.writeObject(modulesToBeSaved);
      for (int i = 0; i < modules.length; i++)
        saveOneModuleSource(modules,i,out);
    }



    /**
     * extract the source of the specified module from the CBserver annd save it as String to the output file
     * @param modName CBserver module to be saved
     * @param out output file 
     */

    public void saveOneModuleSource(String[] modules, int index, ObjectOutputStream out) {
 //      System.out.println("To be saved: "+modName);
       String modName = modules[index];
       if (isConnected()) {
          try {
            String sModSource=getObi().getCBClient().listModule(effectiveModuleName(modName));
            if (getCBEditor().getDumpSourceFiles())
               dumpModuleSource(modName,sModSource);
            out.writeObject(sModSource);
          } catch (Exception e) {
            java.util.logging.Logger.getLogger("global").warning("Failed to save module "+modName);
          }
       } else if (modulesToBeSaved != null && moduleSources != null && index < moduleSources.size) {
          try {
            out.writeObject(moduleSources.get(index));
          } catch (Exception e) {
            java.util.logging.Logger.getLogger("global").warning("Failed to save module "+modName);
          }
       }
    }



    /**
     * print the source of the module to a text file with name modName_saved.sml.txt
     * @param modName CBserver module to be saved
     * @param sModSource module source as string of Telos frames
     */

    public static void dumpModuleSource(String modName, String sModSource)  {
       String filename = modName + "_saved.sml.txt";
       FileWriter writer = null;
        try {
            File newTextFile = new File(filename);
            writer = new FileWriter(newTextFile);
            writer.write(sModSource);
            writer.close();
        } catch (Exception ex) {
            java.util.logging.Logger.getLogger("global").warning("Failed to dump module source  "+modName);
        } finally {
            try {
                writer.close();
            } catch (Exception ex) {
            java.util.logging.Logger.getLogger("global").warning("Failed to dump module source  "+modName);
            }
        }
       
    }


    public int moduleSourcesSize() {
      if (moduleSources == null)
        return 0;
      else
        return moduleSources.size;
    }


    /**
     * load a certain cbUserobject belonging to this cbFrame's CBserver
     * @param in input file
     * @return Object read from the input file
     */

    public Object loadUserObject(ObjectInputStream in) throws IOException, ClassNotFoundException {

        CBUserObject cbuo=null;
        String implby=null;
        if(!loadedGrTypesAndImpl){
            //check if HashMaps containing GraphTypes and Implementing classes can be loaded
            boolean loadGrTypesAndImpl = in.readBoolean();
            if(loadGrTypesAndImpl){
                m_defaultGraphTypes=(HashMap)in.readObject();
                m_implementedBy=(HashMap)in.readObject();
                m_PropertiesOfGraphicalTypes=(HashMap)in.readObject();
            }
            loadedGrTypesAndImpl=true;
        }
        TelosObject to = (TelosObject)in.readObject();
        String sGraphType=(String)in.readObject();

        //create Query
        //ticket #410: implicit attributes may have a user-defined graphtype matching "ImplicitGT_*"
        boolean hasImplicitGT = false;
        if (sGraphType != null) {
          hasImplicitGT = (sGraphType.startsWith("ImplicitGT_"));
        }
        if(to instanceof TelosLink && ((TelosLink) to).isImplicit() && !hasImplicitGT) {
            try {
                if(to instanceof i5.cb.telos.object.Specialization){
                    implby=(String) m_implementedBy.get("ImplicitIsAGT");
                }
                if(to instanceof i5.cb.telos.object.Instantiation){
                    implby=(String) m_implementedBy.get("ImplicitInstanceOfGT");
                }
                if(to instanceof i5.cb.telos.object.Attribute){
                    implby=(String) m_implementedBy.get("ImplicitAttributeGT");
                }
                Class cls=Class.forName(implby);
                Object obj=cls.newInstance();
                if(obj instanceof CBUserObject) {
                    cbuo=(CBUserObject) obj;
                    cbuo.setTelosObject(to);
                    cbuo.setCBFrame(this);
                }
                else {
                    java.util.logging.Logger.getLogger("global").fine("The class " + implby + " is not an extension of i5.cb.graph.cbeditor.CBUserObject\n" +
                    "Therefore, the default graphical type will be used");
                }
            }
            catch(Exception e) {
                java.util.logging.Logger.getLogger("global").fine("Exception while creating user object: " + e.getMessage());
            }
            String sDefaultGT=(String)m_defaultGraphTypes.get(to.getSystemClassName());
            if(sDefaultGT!=null) {
                //get Properties of the defaultType
                CBGraphTypePropertySet cbGtSet=(CBGraphTypePropertySet) getPropertiesOfGraphicalTypes().get(sDefaultGT);
                java.util.Iterator iterator=cbGtSet.getProperties().iterator();
                //set properties
                while(iterator.hasNext()) {
                    CBGraphTypeProperty prCurrent=(CBGraphTypeProperty) iterator.next();
                    cbuo.setProperty(prCurrent.getName(),prCurrent.getValue());
                }
            }
            return cbuo;
        }
        else{
            HashMap graphTypesPropertiesDummy= new HashMap();
            graphTypesPropertiesDummy.put(to.toString(),sGraphType);
            return i5.cb.graph.cbeditor.CBUserObject.getCBUserObject(to,this,graphTypesPropertiesDummy);
        }
    }



    /**
     * Saves a certain cbUserobject belonging to this cbFrame's CBserver
     * @param uo online select online/offline mode
     * @param out output file
     */

    public void saveUserObject(Object uo, ObjectOutputStream out) throws IOException{
        assert(uo instanceof CBUserObject) : "CBFrame.saveUserObject: uo must be an instance of 'CBUserOBject'";
        //check for save option
        // i5.cb.graph.GraphMenu menu=m_graphEditor.getGraphMenuBar().getOptionsMenu().getSubMenuByKeyWord("GMB_OptionsMenu_SaveGrTypes");
        // boolean saveGrTypesAndImpl=menu.getItem(0).isSelected();
        boolean saveGrTypesAndImpl = true;  // always save graphical types in the GEL file; they would be rather useless otherwise

        if(!savedGrTypesAndImpl && saveGrTypesAndImpl){
            //save info and HashMaps
            out.writeBoolean(saveGrTypesAndImpl);
            out.writeObject(m_defaultGraphTypes);
            out.writeObject(m_implementedBy);
            out.writeObject(m_PropertiesOfGraphicalTypes);
            savedGrTypesAndImpl=true;
        }
        else if(!savedGrTypesAndImpl && !saveGrTypesAndImpl){
            //save info
            out.writeBoolean(saveGrTypesAndImpl);
            savedGrTypesAndImpl=true;
        }
        out.writeObject( ((CBUserObject)uo).getTelosObject()  );
        out.writeObject(((CBUserObject)uo).getProperty("GraphType"));
    }



    /** Loads all graphical types and their corressponding implementations
     *  @param online flag to signal wether the CBFrame is connected to a CBserver or not
     *  , if not load the graphTypes from the xml ressource file.
     */

    public void loadGraphicalPaletteAndImplementation(boolean online) {

        Document DOM_Tree;
        InputSource source;
        String name=null;
        Node Sibling;
        StringReader reader;
        ObjectBaseInterface obi=getObi();

        //set up XML-Parser
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setIgnoringElementContentWhitespace(true);
        factory.setValidating(false);

        try{
            DocumentBuilder builder = factory.newDocumentBuilder();
            if(online){
                //ask database for palette
                String ans=obi.ask("GetJavaGraphicalPalette[" + this.getGraphicalPalette() + "/pal]","XML_JavaGraphicalPalette");
                if(ans==null)
                    JOptionPane.showMessageDialog(this,"Could not load graphical palette");
                reader= new StringReader(ans);
                source = new InputSource(reader);
                //parse answer and generate DOMTree
                DOM_Tree= builder.parse(source);
            }
            // load data from ressource xml file
            else{
                java.net.URL xmlURL = this.getClass().getResource(CBConstants.CB_RESOURCE_DIR + "/defaultGraphTypes.xml");
                //xmlInput=new FileInputStream(xmlURL.getFile());
                //parse answer and generate DOMTree
                DOM_Tree= builder.parse(xmlURL.openStream());
            }



            if(DOM_Tree!=null){
                Element result = DOM_Tree.getDocumentElement();
                Sibling = result.getFirstChild();
            }
            else{
                Sibling=null;
            }

            // set palproperties to default
            resetPaletteProperties();

            //iterate over all objects returned by Cbase
            while( Sibling != null) {
                //pick node containing the graphtypes
                if(Sibling.getNodeName().equals("contains")) {
                    Node possibleGraphType=Sibling.getFirstChild();
                    //iterates over all graphtypes
                    while(possibleGraphType!= null) {
                        //if node is a GraphType process it
                        if(possibleGraphType.getNodeName().equals("graphtype")){

                            CBGraphTypePropertySet propertySet=new CBGraphTypePropertySet();
                            Node graphType=possibleGraphType.getFirstChild();

                            //iterate over all grsphtypes
                            while(graphType!=null){
                                //read content, first name
                                if(graphType.getNodeName().equals("name")){
                                    Text NameNode=(Text) graphType.getFirstChild();
                                    name=(String) NameNode.getNodeValue();
                                }

                                //process properties of the graphType
                                if(graphType.getNodeName().equals("property")){
                                    Node Values=graphType.getFirstChild();
                                    String PropertyName="";
                                    while(Values!=null){
                                        // read PropertyName
                                        if(Values.getNodeName().equals("name")){
                                            Text PropertyNameNode=(Text) Values.getFirstChild();
                                            PropertyName=(String) PropertyNameNode.getNodeValue();
                                        }

                                        //read PropertyValue
                                        if(Values.getNodeName().equals("value")){
                                            CBGraphTypeProperty property;
                                            Text PropertyValueNode=(Text) Values.getFirstChild();
                                            String sPropertyValue=(String) PropertyValueNode.getNodeValue();

                                            //erase \" at beginning and end
                                            sPropertyValue=CButil.decodeStringIfPossible(sPropertyValue);

                                            //create new  CBGraphTypePropertyObject and add it to the set
                                            property=new CBGraphTypeProperty(PropertyName,sPropertyValue);
                                            propertySet.put(property);


                                        }
                                        Values=Values.getNextSibling();
                                    }
                                    //insert into HashMap (name,(name,value)
                                    getPropertiesOfGraphicalTypes().put(name,propertySet);
                                }

                                //read implementing classes
                                if(graphType.getNodeName().equals("implementedBy")){
                                    Text ClassNameNode=(Text) graphType.getFirstChild();
                                    String ClassName=(String) ClassNameNode.getNodeValue();

                                    //cut " at the end and beginning
                                    ClassName= ClassName.substring(1,(ClassName.length()-1));

                                    //add values to the Map
                                    m_implementedBy.put(name,ClassName);
                                }
                                graphType=graphType.getNextSibling();
                            }
                        }
                        possibleGraphType=possibleGraphType.getNextSibling();
                    }
                }

                //read out default GraphTypes
                String gtName;
                if(Sibling.getNodeName().equals("defaultIndividual")){
                    Text defaultType=(Text) Sibling.getFirstChild();
                    gtName=(String) defaultType.getNodeValue();
                    gtName=pickGraphtypeName("DefaultIndividualGT",gtName);
                    m_defaultGraphTypes.put("Individual",gtName);
                }
                if(Sibling.getNodeName().equals("defaultLink")){
                    Text defaultType=(Text) Sibling.getFirstChild();
                    gtName=(String) defaultType.getNodeValue();
                    gtName=pickGraphtypeName("DefaultLinkGT",gtName);
                    m_defaultGraphTypes.put("Link",gtName);
                }
                if(Sibling.getNodeName().equals("implicitIsA")){
                    Text defaultType=(Text) Sibling.getFirstChild();
                    gtName=(String) defaultType.getNodeValue();
                    gtName=pickGraphtypeName("ImplicitIsAGT",gtName);
                    m_defaultGraphTypes.put("IsA",gtName);
                }
                if(Sibling.getNodeName().equals("implicitInstanceOf")){
                    Text defaultType=(Text) Sibling.getFirstChild();
                    gtName=(String) defaultType.getNodeValue();
                    gtName=pickGraphtypeName("ImplicitInstanceOfGT",gtName);
                    m_defaultGraphTypes.put("InstanceOf",gtName);
                }
                if(Sibling.getNodeName().equals("implicitAttribute")){
                    Text defaultType=(Text) Sibling.getFirstChild();
                    gtName=(String) defaultType.getNodeValue();
                    gtName=pickGraphtypeName("ImplicitAttributeGT",gtName);
                    m_defaultGraphTypes.put("Attribute",gtName);
                }


                /* a graphical palette can optionally contain name/value pairs for
                   global properties, called palproperty.
                */
                if (Sibling.getNodeName().equals("palproperty")){
                   Node Values=Sibling.getFirstChild();
                   String sPropertyName="";
                   String sPropertyValue="";
                   while(Values!=null){
                     // read PropertyName
                     if(Values.getNodeName().equals("name")){
                        Text PropertyNameNode=(Text) Values.getFirstChild();
                        sPropertyName=(String) PropertyNameNode.getNodeValue();
                        sPropertyName=CButil.decodeStringIfPossible(sPropertyName);
                     }
                     //read PropertyValue
                     if(Values.getNodeName().equals("value")){
                        Text PropertyValueNode=(Text) Values.getFirstChild();
                        sPropertyValue=(String) PropertyValueNode.getNodeValue();
                        //erase \" at beginning and end
                        sPropertyValue=CButil.decodeStringIfPossible(sPropertyValue);
                     }


                     Values=Values.getNextSibling();
                   } // while

                   // a new pair sPropertyName/sPropertyValue  is found, so store it in instance variables
                   if (sPropertyName.equals("bgcolor")) 
                      m_bgcolor = sPropertyValue;
                   else if (sPropertyName.equals("bgimage"))
                      m_bgimage = sPropertyValue;
                   else if (sPropertyName.equals("longtitle"))
                      m_longtitle = sPropertyValue;
                }  

                Sibling = Sibling.getNextSibling();

            }
        }
        catch (ParserConfigurationException pce) {
            // Parser with specified options can't be built
            pce.printStackTrace();
        } catch (SAXException sxe) {
            // Error generated during parsing
            Exception x = sxe;
            if (sxe.getException() != null) {
                x = sxe.getException();
            }
            x.printStackTrace();
        }catch (IOException ioe){
            // I/O error
            ioe.printStackTrace();
        }

        // set background color of the diagram desktop of this CBFrame
        getDiagramDesktop().setBackground(CBUtil.stringToColor(m_bgcolor));
        getDiagramDesktop().setBackgroundImage(m_bgimage);  // m_bgimage can be null
        // set the title of this CBFrame/graph internal frame
        if (m_longtitle == null)
          m_longtitle = m_sPalette;
        setFrameTitle();
    }


   /**
   Ticket #406: The CBserver returns the graphical palette including some implicit (=for derived links)
   and default graphtypes. If they are defined by rules, then there could be several fillers,
   separated by commas. Hence, we need to pick the right one of such a list is returned.
   We take the last one from such a list that does not equal the default one. Hence, any overruling
   definition supersedes the default ones defined in the Telos class DefaultJavaPalette.
   */

   private static String pickGraphtypeName(String defaultGT,String gtCandidates) {
      if (gtCandidates == null) 
        return defaultGT;
      String[] gtList = gtCandidates.split(",");
      if (gtList.length == 1)
        return gtList[0];
      String result = gtList[0];
      for (int i=1; i < gtList.length; i++) {
        if (!gtList[i].equals(defaultGT))
          result = gtList[i];
      }
      return result;
   }


    /** display the memorized title of this CBFrame
    */

    public void setFrameTitle() {
        if (m_longtitle == null)
          m_longtitle = m_sPalette;
        if (getDiagramDesktop().isEdited() && !m_longtitle.startsWith("*"))
          m_longtitle = "*" + m_longtitle;
        if (!getDiagramDesktop().isEdited() && m_longtitle.startsWith("*"))
          m_longtitle = m_longtitle.substring(1);
        if (m_longtitle.equals(""))
          setFrameTitle(compressedPath(m_Context));
        else
          setFrameTitle(m_longtitle + ": " + compressedPath(m_Context));
    }

    /** set title and include the connection status
     *@param mainTitle the prefix of the title that this CBFrame shall display
    */

    public void setFrameTitle(String mainTitle) {
        m_sTitle = mainTitle;
        String gelname = "";
        String connectStatus = "  -- offline";
        if (isConnected())
           connectStatus = " - " + getHost() + ":" + getPort();
        if (getGelfile() != null) {
          String separator = "/";  // path separator
          if (CBConfiguration.anyWindows())
            separator = "\\\\";  // complicated way to specify the backslash character for split
          String[] parts = getGelfile().split(separator);
          gelname = " - " + parts[parts.length-1];
        }
        super.setTitle(mainTitle + connectStatus + gelname);
    }


    /** determine a shorter representation of a module path that removes the prefix System-oHome when
        possible; this is a useful compression since System-oHome is the default home directory
        in ConceptBase
     *@param path  the (potentially) absolute representation of the module path
    */

    private static String compressedPath(String path) {
       String sep = CBConfiguration.getModuleSeparator(path);
       if (path == null)
          return sep;
       String homePath = CBConstants.CB_SYSTEM_MODULE + sep + CBConstants.CB_HOME_MODULE;
       String homePrefix = homePath + sep;
       String sep2 = CBConfiguration.otherSep(sep);
       String homePath2 = CBConstants.CB_SYSTEM_MODULE + sep2 + CBConstants.CB_HOME_MODULE;
       String homePrefix2 = homePath2 + sep2;
       if (path.startsWith(homePrefix)) 
         return path.substring(homePrefix.length());
       else if (path.equals(homePath)) 
         return CBConstants.CB_HOME_MODULE;
       else if (path.startsWith(homePrefix2)) 
         return path.substring(homePrefix2.length());
       else if (path.equals(homePath2))
         return CBConstants.CB_HOME_MODULE;
       else
         return path;
    }


   /** reset the palette properties (bgcolor etc.) to their defaults; 
     */
    private void resetPaletteProperties() {
        m_bgcolor = "255,255,255";   //default background for the diagram desktop of this CBFrame
        m_bgimage = null;            // undefined by default
        m_longtitle = null;          // undefined by default
    }

    /** returns the Hashmap containing the properties of all graphicalTypes of the current DB, this
     * is empty if loadGraphicalPaletteAndImplementation() wasn?t called before
     * @return HashMap containing the GraphicalTypes with names as key.
     */



    public HashMap getPropertiesOfGraphicalTypes() {
        return m_PropertiesOfGraphicalTypes;
    }

    /** returns the HashMap containing all implementing classes of the graphtypes,
     * this is empty if loadGraphicalPaletteAndImplementation() wasn?t called
     * before.
     * @return HashMap containing the implementing classes, keys are the names of
     * the graphicaltypes.
     */



    public HashMap getImplementingClasses() {
        return m_implementedBy;
    }

    /** returns a HashMap containing all default Graphtypes which have been returned by
     * CBase while connecting
     *@return HashMap containing default GraphTypes
     */

    public HashMap getDefaultGraphTypes(){
        return m_defaultGraphTypes;
    }

    public void propertyChange(java.beans.PropertyChangeEvent evt) {
        if(evt.getPropertyName().equals("connected") ){
        }
    }

    public void finishedLoading(){
        loadedGrTypesAndImpl=false;
    }
    public void finishedSaving(){
        savedGrTypesAndImpl=false;
    }

    public void addNodesToAdd(Collection diagramNodes){
        Iterator itNodes = diagramNodes.iterator();
        DiagramNode currentDiagNode;
        while(itNodes.hasNext()){
            currentDiagNode= (DiagramNode)itNodes.next();
            if(!m_DiagHashObjectsToAdd.contains(currentDiagNode) ){
                addObjectToAdd(currentDiagNode.getDiagramClass().getHashtableEntry((CBUserObject)currentDiagNode.getUserObject()));
            }
        }
    }

    public boolean removeObjectToAdd(DiagramClassHashtableEntry to){
        if(m_DiagHashObjectsToAdd.contains(to)){
            m_DiagHashObjectsToAdd.remove(to);
            firePropertyChange("update",null,null);
            return true;
        }
        return false;
    }

    public boolean removeObjectFromWasteBasket(DiagramClassHashtableEntry to){
        if(m_DiagHashObjectsToDelete.contains(to)){
            m_DiagHashObjectsToDelete.remove(to);
            firePropertyChange("update",null,null);
            return true;
        }
        return false;
    }


    /** adds the given TelosObject to the set that will be added to CB by pressing
     *  the confirm button
     *  @param to Telosobject to add
     *
     * @return true iff this operation changed the list of Telosobject to add (and false if the Telosobject was already in it)
     */
    public boolean addObjectToAdd(DiagramClassHashtableEntry to){
        if(!m_DiagHashObjectsToAdd.contains(to)){
            m_DiagHashObjectsToAdd.add(to);
            firePropertyChange("update",null,null);
            return true;
        }
        return false;
    }

    /** adds the given TelosObject to the set that will be removed to CB by pressing
     *  the confirm button
     *  @param to Telosobject to add
     */
    public void addObjectToDelete(DiagramClassHashtableEntry to){
        m_DiagHashObjectsToDelete.add(to);
        firePropertyChange("update",null,null);
    }

    public void commitChanges(){
        Iterator iterator;
        // Forget old error messages
        try {
            m_obi.getCBClient().getErrorMessages();
        }
        catch(Exception e1) {}

        // First, call doCommit for all visible objects
        Vector vNodes=getDiagramDesktop().getDiagramNodes(); // includes nodes on edges
        for(int i=0;i<vNodes.size();i++) {
            CBUserObject cbuo=(CBUserObject) ((DiagramNode)vNodes.get(i)).getUserObject();
            if(!cbuo.doCommit()) {
                JOptionPane.showMessageDialog(this,"Commit aborted by object " + cbuo.toString(),"Commit aborted",JOptionPane.INFORMATION_MESSAGE);
                return;
            }
        }
        try {
            iterator= m_DiagHashObjectsToDelete.iterator();
            DiagramNode  currentDiagNode;
            ArrayList tempDelete=new ArrayList();
            ArrayList tempAdd=new ArrayList();
            // ierate over all deleted objects and add their TelosObjects to tempDelete for commiting
            while(iterator.hasNext()){
                currentDiagNode=((DiagramClassHashtableEntry)(iterator.next())).getDiagramNode();
                tempDelete.add(((CBUserObject)(currentDiagNode.getUserObject())).getTelosObject());
                getDiagramClass().remove(currentDiagNode.getUserObject());
            }

            Iterator itAdd=m_DiagHashObjectsToAdd.iterator();
            // loop over all added objects and add their TelosObjects to tempAdd for commiting
            while(itAdd.hasNext()) {
                currentDiagNode = ((DiagramClassHashtableEntry)itAdd.next()).getDiagramNode();
                tempAdd.add(((CBUserObject)(currentDiagNode.getUserObject())).getTelosObject());
            }
            m_obi.removeAndAdd(tempDelete,tempAdd);
            m_DiagHashObjectsToDelete.clear();
            m_DiagHashObjectsToAdd.clear();
        }
        catch(Exception e) {
            String sError="Error while adding/removing objects:\n" + e.getMessage();
            Object msg=null;
            if(sError.length()>200) {
                JTextArea jtaError=new JTextArea(20,50);
                jtaError.setText(sError);
                jtaError.setEditable(false);
                jtaError.setLineWrap(true);
	        jtaError.setWrapStyleWord(true);
                JScrollPane jsp=new JScrollPane(jtaError,JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED,JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED);
                msg=jsp;
            }
            else {
                msg=sError;
            }
            JOptionPane.showMessageDialog(getCBEditor(),
                    msg,
                    "Error",
                    JOptionPane.ERROR_MESSAGE);
            return;
        }
        validateNodes();
        JOptionPane.showMessageDialog(getCBEditor(),"Changes committed");
    }

    public void setDiagramDesktop(DiagramDesktop diagramDesktop) {
        super.setDiagramDesktop(diagramDesktop);
        diagramDesktop.setInvalidNodesMethod(CBConfiguration.getInvalidOjsMethod(null, null));
    }

    /**
     * Validates all DiagramNodes on the active DiagramDesktop.
     *
     */
    public void validateNodes(){
        validateNodes(m_diagramDesktop.getDiagramNodes() );
        m_diagramDesktop.repaint();
    }

    public void validateSelectedNodes() {
        validateNodes(new Vector(m_diagramDesktop.getSelectedNodes()));
    }

    public void validateNodes(Vector vNodes) {

        if(!isConnected()) {
            return;
        }

        CBEditor cbEditor = (CBEditor)m_graphEditor;
        java.util.logging.Logger.getLogger("global").fine("Validate Objects");

        Object[] valTaskData = { vNodes };

        CBFrameWorker gifWorker = (CBFrameWorker)cbEditor.getActiveGraphInternalFrame().getFrameWorker();
        gifWorker.setTask(CBFrameWorker.TASK_VALIDATE, valTaskData);
        cbEditor.showProgressStatus(true);
        gifWorker.setUpdateProgressBar(true,cbEditor.getProgressBar() );
        gifWorker.restartFrameWorker();
    }

    /**
     * Returns the List containing new created objects
     */
    public List getObjectsToAdd()
    {
        return m_DiagHashObjectsToAdd;
    }
    /**
     * Returns the List containing objects that should be erased
     */
    public List getObjectsToErase()
    {
        return m_DiagHashObjectsToDelete;
    }


    /**
     * Show error message that current frame has no connection
     */
    public void showNotConnected() {
        JOptionPane.showMessageDialog(getCBEditor(),
                                      getBundle().getString("Frame_NoConnection"),
                                      "Error",
                                      JOptionPane.ERROR_MESSAGE);
        return;

    }

    public boolean isConnected() {
        return m_bIsConnected;
    }


    /**
     * Opens a dialog to select a new graphical palette for this CBFrame
     */
    public void changeGraphicalPalette() {
        if(!isConnected()) {
            showNotConnected();
            return;
        }
        try {
            Dimension geSize=m_graphEditor.getSize();
            Dimension frameSize = this.getSize();
            String sInst=getObi().getCBClient().findInstances("JavaGraphicalPalette");
            StringTokenizer st=new StringTokenizer(sInst,",");
            Vector vGraphPals=new Vector(st.countTokens());
            while(st.hasMoreTokens())
                vGraphPals.add(st.nextToken());
            String newGraphPal=(String) JOptionPane.showInputDialog(getCBEditor(),"Select Graphical Palette",
                "Change Graphical Palette",JOptionPane.QUESTION_MESSAGE,
                null,vGraphPals.toArray(),getGraphicalPalette());
            if(newGraphPal!=null) {
                setGraphicalPalette(newGraphPal);
                m_defaultGraphTypes=new HashMap();
                m_implementedBy=new HashMap();
                m_PropertiesOfGraphicalTypes=new HashMap();
                this.setStatusString("Loading new graphical palette "+newGraphPal);
                loadGraphicalPaletteAndImplementation(true);
                // previous command could changes the window sizes of the palette has a bgimage
                // revert those changes here
                this.setSize(frameSize);
                m_graphEditor.setSize(geSize);
                validateNodes();
                this.getCBEditor().setStatusString("Graphical palette is "+this.getGraphicalPalette());
            }
        }
        catch(Exception ex) {
            JOptionPane.showMessageDialog(getCBEditor(),ex.getMessage(),"Exception",JOptionPane.ERROR_MESSAGE);
        }

    }


    /**
     * Opens a dialog to select a database module that this CBFrame is connected to
     */


    public void changeGraphModule() {
        if(!isConnected()) {
            showNotConnected();
            return;
        }
        try {
            String sInst=getObi().getCBClient().findInstances("Module");
            StringTokenizer st=new StringTokenizer(sInst,",");
            Vector vModules=new Vector(st.countTokens());
            while (st.hasMoreTokens())
                vModules.add(st.nextToken());
            String newModule=(String) JOptionPane.showInputDialog(getCBEditor(),"Change module",
                "Select new module",JOptionPane.QUESTION_MESSAGE,
                null,vModules.toArray(),getContext());
            if (newModule!=null) {
                if (setModule(newModule)) {
                  setContext();     // refresh from CBserver
                  setFrameTitle();  // to update the frame title
                  if (getDiagramDesktop() != null)
                     getDiagramDesktop().setEdited(true);
                } else
                  JOptionPane.showMessageDialog(this,"Access to module "+newModule+" denied by CBserver.");
            }
        }
        catch(Exception ex) {
            JOptionPane.showMessageDialog(getCBEditor(),ex.getMessage(),"Exception",JOptionPane.ERROR_MESSAGE);
        }


    }


    /**
     * Set a newly computed CBTree for the user objects linked to nodes. 
     * This is needed when a graph file is loaded via DiagramDesktop.load and
     * the graphical palette is not DefaultJavaPalete. The CBTree contains the
     * preconfigured queries e.g. to display the instances of a node. Hence,
     * this has to use the current palette of this CBFrame.
     * @param nodes vector of diagram nodes of the diagram desktop.
     */

    public void refreshUserObjects(Vector nodes) {
      DiagramNode currentNode;
  
      for (int i = nodes.size() - 1; i >= 0; i--) {
          currentNode = (DiagramNode) nodes.elementAt(i);
          CBUserObject uo = (CBUserObject)currentNode.getUserObject();
          uo.setQueryTree(new CBTree(uo));  
      }
    }







}





