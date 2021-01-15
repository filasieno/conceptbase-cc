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
/*
 * CBFrameWorker.java
 *
 * Created on 13. Juni 2002, 10:00
 */

package i5.cb.graph.cbeditor;

import i5.cb.CBConfiguration;
import i5.cb.graph.GEConstants;
import i5.cb.graph.IFrameWorker;
import i5.cb.graph.diagram.*;
import i5.cb.telos.object.TelosLink;
import i5.cb.telos.object.TelosObject;
import i5.cb.api.CBanswer;
import i5.cb.graph.cbeditor.components.CBTree;

import java.awt.*;

import java.util.*;



/**
 *
 * @author  Schoeneb
 */
public class CBFrameWorker implements java.beans.PropertyChangeListener, IFrameWorker {

    /** Holds value of property currentFlag. */
    private int currentFlag;

    /** Utility field used by bound properties. */
    private java.beans.PropertyChangeSupport propertyChangeSupport =  new java.beans.PropertyChangeSupport(this);

    public final static int TASK_FIND_RELATIONS = 1;

    public final static int TASK_CONNECT = 2;

    public final static int TASK_VALIDATE = 3;

    public final static int SMALLDIAGRAMSIZE = 75; 

    private int m_iTaskID;

    private Object[] m_oTaskData;

    private CBFrame m_cbFrame;

    private int m_currentFlag;

    private Thread m_thread;

    private boolean m_bShowProgress;

    private javax.swing.JProgressBar m_progressBar;

    private int m_iProgressMax;

    private String m_sProgressString;

    /** Holds value of property status. */
    private int m_iStatus;

    /** Creates a new instance of CBFrameWorker */
    public CBFrameWorker(CBFrame cbFrame) {
        m_cbFrame = cbFrame;
        m_thread = new Thread(this);
        setStatus(IFrameWorker.STATUS_READY);
        this.addPropertyChangeListener(this);
    }

    /** Makes the m_gifWorker have a break. The method is not intended to let the thread die
     *
     */
    public void pauseFrameWorker() {
        setCurrentFlag(IFrameWorker.FLAG_PAUSE);
    }

    public void resumeFrameWorker() {
        setCurrentFlag(IFrameWorker.FLAG_RESUME);
        m_thread.notify();
    }

    /** Makes the m_gifWorker start doing its work right from the beginning. It should be irrelevant whether
     * the thread just has its break, was killed by stopGifWorker or just finished its work
     *
     */
    public void restartFrameWorker() {
        setCurrentFlag(IFrameWorker.FLAG_RESTART);
    }

    /** Makes the gifWoker stop it's work. This method is intended to make the m_gifWorker thread die
     *
     */
    public void stopFrameWorker() {
        setCurrentFlag(IFrameWorker.FLAG_STOP);
    }

    /** Tells the worker whether it shall show it's progress in the progressbar we provide
     *
     * @param bUpdate a <code>boolean</code> value used to switch on and off the progress-display
     * thus serving the worker from wasting time on updating a progressbar that isn't shown
     * @param pBar a <code>JProgressBar</code> value. That's the progressbar to use if bUpdate is true. May be null if bUpdate is false
     */

    public void setTask(int iTaskID, Object[] oTaskData) {
        switch(iTaskID) {

            case TASK_FIND_RELATIONS:
                assert(oTaskData.length == 2) && (oTaskData[0] instanceof Collection) && (oTaskData[1] instanceof Collection)
                : "CBFrameWorker.setTask: For the task 'TASK_FIND_RELATIONS oTaskData must contain 2 Collections of DiagramObjects";

                m_iProgressMax = ((Collection)oTaskData[0]).size() * ((Collection)oTaskData[1]).size();
                m_sProgressString = m_cbFrame.getBundle().getString("Progress_Search");
                break;

            case TASK_CONNECT:
                assert(oTaskData.length == 5) && (oTaskData[0] instanceof CBFrame) && (oTaskData[1] instanceof String)
                && (oTaskData[2] instanceof Integer) && (oTaskData[3] instanceof String && (oTaskData[4] instanceof String))
                : "CBFrameWorker.setTask: For the task 'TASK_CONNECT oTaskData must be a CBFrame";

                m_iProgressMax = 0;
                m_sProgressString = "";
                break;

            case TASK_VALIDATE :
                assert(oTaskData.length == 1) && (oTaskData[0] instanceof Vector)
                : "CBFrameWorker.setTask: For the task 'TASK_VALIDATE' oTaskData[0] must be a Set";
                m_iProgressMax = ((Vector)oTaskData[0]).size();
                m_sProgressString = m_cbFrame.getBundle().getString("Progress_Validate");
                break;
           default :
                assert false : "CBFrameWorker.setTask: This is no valid taskID: "
                +Integer.toString(iTaskID) ;
        }//switch
        m_oTaskData = oTaskData;
        m_iTaskID = iTaskID;
    };

    public void run() {
        assert(m_oTaskData != null) : "CBFrameWorker.run: m_oTaskData may not be 'null'";
        setStatus(IFrameWorker.STATUS_RUNNING);
        switch(m_iTaskID) {
            case TASK_FIND_RELATIONS:
                findEdges( (Collection)m_oTaskData[0], (Collection)m_oTaskData[1] );
                //java.util.logging.Logger.getLogger("global").fine("CBFrameWorker.run: finished Task 'find edges'");
                break;
            case TASK_CONNECT:
                connect( (CBFrame)m_oTaskData[0], (String)m_oTaskData[1], (Integer)m_oTaskData[2], (String)m_oTaskData[3], (String)m_oTaskData[4]);
                //java.util.logging.Logger.getLogger("global").fine("CBFrameWorker.run: finished Task 'connect'");
                break;
            case TASK_VALIDATE :
                validate( (Vector)m_oTaskData[0] );
                break;
        }
        //this gifworker might wait for this thread to finish, so we notify it
        //m_thread.notify();
        //after we'return finished, we remove the progressbar
        setUpdateProgressBar(false, null);
        setStatus(IFrameWorker.STATUS_FINISHED);
    }

    /** Tells the worker whether it shall show it's progress in the progressbar we provide
     *
     * @param bUpdate a <code>boolean</code> value used to switch on and off the progress-display
     * thus serving the worker from wasting time on updating a progressbar that isn't shown
     * @param pBar a <code>JProgressBar</code> value. That's the progressbar to use if bUpdate is true. May be null if bUpdate is false
     */
    public void setUpdateProgressBar(boolean bUpdate, javax.swing.JProgressBar pBar) {
        assert(m_oTaskData != null) : "CBFrameWorker.setUpdateProgressBar: m_oTaskData may not be null";
        m_bShowProgress = bUpdate;
        if(bUpdate) {
            m_progressBar = pBar;
            m_progressBar.setStringPainted(true);
            m_progressBar.setString(m_sProgressString);
            m_progressBar.setMaximum(m_iProgressMax);
            m_progressBar.setVisible(true);
        }
        else {
            if(m_progressBar != null) {
                m_progressBar.setVisible(false);
            }
        }
    }

    private int checkCurrentFlag() {
        switch(m_currentFlag) {
            case IFrameWorker.FLAG_PAUSE:
                setStatus(IFrameWorker.STATUS_PAUSING);
                //try{
                //m_thread.wait();
                //}catch(InterruptedException ie){
                //}
                setStatus(IFrameWorker.STATUS_RUNNING);
                m_currentFlag = IFrameWorker.FLAG_NOFLAG;
                break;
            case IFrameWorker.FLAG_RESUME:
                //we can't resume a waiting thread from inside the thread.
                //this method is supposed to be called by findedges i.e. from inside the thread
                break;
            case IFrameWorker.FLAG_RESTART:
                m_thread = new Thread(this);
                m_thread.start();
                m_currentFlag = IFrameWorker.FLAG_NOFLAG;
                setStatus(IFrameWorker.STATUS_RUNNING);
                break;
            case IFrameWorker.FLAG_STOP:

                break;
            case IFrameWorker.FLAG_NOFLAG:
                break;
            default:
                assert(false)
                : "CBFrameWorker.propertyChange: the property 'currentFlag' must be one of FLAG_RESTART, FLAG_STOP, FLAG_RESUME, FLAG_NOFLAG or FLAG_PAUSE from IFrameWorker";


        }//switch
        return m_currentFlag;
    };


    /*
     * uses createAndAddNewDiagramEdges to find edges between all nodes
     */
    private void findEdges(Collection selectedNodes1, Collection selectedNodes2) {

        // temporarily disable layout algorithm
        boolean olden = m_cbFrame.getDiagramDesktop().getLayouter().getEnable();
        m_cbFrame.getDiagramDesktop().getLayouter().setEnable(false);

        Object[] work1 = selectedNodes1.toArray();
        Object[] work2 = selectedNodes2.toArray();

        java.util.Vector vDiagEdges=new java.util.Vector();
        i5.cb.graph.diagram.DiagramNode source;
        i5.cb.graph.diagram.DiagramNode destination;
        int currentProgress = 0;
        for(int i=0; i<work1.length; i++) {   //new modified
            for(int j=0; j<work2.length; j++) {

                if(checkCurrentFlag() == FLAG_STOP) {
                    return;
                }
                source=(i5.cb.graph.diagram.DiagramNode)work1[i];
                destination=(i5.cb.graph.diagram.DiagramNode)work2[j];
                //ask CB for all edges between the Nodes
                vDiagEdges.addAll(CBUtil.createAndAddAllDiagramEdges(source,destination, m_cbFrame));
                //add Edges if present
                if(!vDiagEdges.isEmpty()) {
                    m_cbFrame.getDiagramDesktop().addDiagramEdges(vDiagEdges, source,GEConstants.DEFAULT_POSITION, true);
                    if(m_progressBar!=null && m_bShowProgress)    //new modified
                    	m_progressBar.setValue(currentProgress);
                }
                vDiagEdges.clear();
                currentProgress++;
            }
        }

        // resume and execute layout algorithm
        m_cbFrame.getDiagramDesktop().getLayouter().setEnable(olden);
        m_cbFrame.getDiagramDesktop().getLayouter().backup();
        m_cbFrame.getDiagramDesktop().getLayouter().doIncrementalLayout();
        m_cbFrame.getDiagramDesktop().adjustContentPaneSize();
    }//findEdges

    public void connect(CBFrame cbf, String sHost, Integer port, String sSelectedObject, String selectedModule) {
        java.util.logging.Logger.getLogger("global").fine("Connecting...");
        CBEditor cbEditor = cbf.getCBEditor();
        java.util.ResourceBundle bundle = cbEditor.getCBBundle();
        String sPort = port.toString();

        //This line doesn't make sense as the cbf isn't shown at this time
        //cbf.setStatusString(bundle.getString("Status_Connecting")+" "+sHost);

        cbEditor.setStatusString(bundle.getString("Status_Connecting")+" "+sHost);

        String sUser=null;
        try {
            sUser=System.getProperty("user.name");
        }
        catch(java.security.AccessControlException ace) {
            sUser="unknown";
        }

        boolean bConnectionSuccess =cbf.connectToServer(sHost,sPort,CBConstants.CBEDITOR_NAME,sUser);

        if (bConnectionSuccess) {

            propertyChangeSupport.firePropertyChange("ConnectionSuccess", new Boolean(false), new Boolean(true) );

            CBConfiguration.addNewConnection(sHost, sPort);

            cbf.setButtonEnabled(CBConstants.NEW_NODE_BUTTON, true);
            cbf.setButtonEnabled(CBConstants.SHOW_RELATIONS_BUTTON, true);
            cbf.setButtonEnabled(GEConstants.LOAD_BUTTON, true);
            cbf.setButtonEnabled(GEConstants.SAVE_BUTTON, true);
            cbf.setButtonEnabled(GEConstants.REMOVE_BUTTON, true);

            cbf.setButtonEnabled("Toolbar_AddIndividual", true);
            cbf.setButtonEnabled("Toolbar_AddAttribute", true);
            cbf.setButtonEnabled("Toolbar_AddInstantiation", true);
            cbf.setButtonEnabled("Toolbar_AddSpecialization", true);
            cbf.setButtonEnabled("Toolbar_Commit", true);
            cbf.setButtonEnabled("Toolbar_RemoveItemFromCommit", true);

            cbf.setMenuEnabled("GMB_EditMenu_Title", true);
            cbf.setMenuEnabled("GMB_ActiveFrame_Title", true);
            cbf.setItemEnabled("GMB_OptionsMenu_DDBackground", true);
            cbf.setMenuEnabled("GMB_OptionsMenu_CBComponent", true);

            // issue #26: "demo mode" flag is used for disabling some menu items
            cbf.setItemEnabled("GMB_FileMenu_Load", cbEditor.getFullMode());
            cbf.setItemEnabled("GMB_FileMenu_Save", cbEditor.getFullMode());
            cbf.setItemEnabled("GMB_FileMenu_Print", cbEditor.getFullMode());
            cbf.setItemEnabled("GMB_FileMenu_ScreenShot", cbEditor.getFullMode());

            cbf.setItemEnabled("GMB_ActiveFrameMenu_SubmitQuery", true);
            cbf.setItemEnabled("GMB_ActiveFrameMenu_ValidateObjects", true);
            cbf.setItemEnabled("GMB_ActiveFrameMenu_ValidateSelectedObjects", true);
            cbf.setItemEnabled("GMB_ActiveFrameMenu_ChangeGraphicalPalette", true);
            cbf.setItemEnabled("GMB_ActiveFrameMenu_ChangeGraphModule", true);

            cbf.setStatusString(bundle.getString("Status_Connected")+" "+sHost);

            cbEditor.addGraphInternalFrame(cbf);

            cbf.getDiagramDesktop().setInvalidNodesMethod(CBConfiguration.getInvalidOjsMethod(null, null) );
            //java.util.logging.Logger.getLogger("global").fine("CBFrameWorker.connect: Added GraphInternalFrame for connection to "+sHost);
            //trying to switch to selected Module
            try{
                CBanswer ans = cbf.getObi().getCBClient().setModule(selectedModule);
                if (ans.getCompletion() != CBanswer.OK ) {
                   javax.swing.JOptionPane.showMessageDialog(cbEditor,"Module: "+selectedModule +" does not exist");
                   ans = cbf.getObi().getCBClient().getModulePath();
                   if (ans.getCompletion() == CBanswer.OK )
                     selectedModule = ans.getResult();
                }
                cbf.setContext(selectedModule);
                cbf.loadGraphicalPaletteAndImplementation(true);
                cbf.setFrameTitle();  // refresh frame title to display connection details

            }
            catch(Exception e){
            	javax.swing.JOptionPane.showMessageDialog(cbEditor,"Unable to select Module");
            }
        }
        else {

            javax.swing.JOptionPane.showMessageDialog(
            cbEditor, bundle.getString("Error_NoConnection") );
            propertyChangeSupport.firePropertyChange("ConnectionSuccess", new Boolean(true), new Boolean(false) );
            cbf.setStatusString(bundle.getString("Status_NotConnected") );
            return;
        }
        // end of else

        if(sSelectedObject!=null){
            if(CBUtil.createAndAddNewDiagramObject(sSelectedObject, cbf, null) ) {
                CBConfiguration.addStartingObject(sSelectedObject, sHost, sPort);
                CBConfiguration.addGraphicalPalette(cbf.getGraphicalPalette() ,sHost, sPort);
            }
            else {
                javax.swing.JOptionPane.showMessageDialog(cbEditor, "Sorry, no such TelosObject found: '"+sSelectedObject.toString()+"'");
            }
        }

    }//connect

    /**
     * Checks wheter the cbUserObjects associated to the 'telosObjects' in 'mapUserObjects' still have Telosobjects in the ConceptBase Server we are connected to
     * If that's not the case, 'setValid(false)' is called. When this method is finished
     * only valid cbUserObjects are in 'CBUserObject.mapUserObjects'.
     */

    private void validate(Vector diagramNodes){
      if (diagramNodes.size() <= SMALLDIAGRAMSIZE) 
         validateBulk(diagramNodes);  // validateBulk is faster than validateIterative but both should have the same result
      else
         validateIterative(diagramNodes);
      m_cbFrame.getCBEditor().setStatusString("done.");
      m_cbFrame.getDiagramDesktop().repaint();
    }


    private void validateBulk(Vector diagramNodes){
        TelosObject currentTo;
        CBDiagramClass dc;
        m_progressBar.setVisible(false);  // do not show the progress bar in bulk mode

        m_cbFrame.getObi().emptyCache();
        boolean origMoveFlag = m_cbFrame.getDiagramDesktop().getMovableDiagramNodeOnEdge();
        // fix DNonEdges at their current position
        m_cbFrame.getDiagramDesktop().setMovableDiagramNodeOnEdge(false); 

        // #364: compute stored object names, i.e. excluding implicit links
        StringArray storedObjectNames = new StringArray();
        Vector storedDiagramNodes = new Vector();
        Vector oldUserObjects = new Vector();
        for (int i=0; i<diagramNodes.size(); i++){
            DiagramNode dn=(DiagramNode) diagramNodes.get(i);
            if (dn.isComponentVisible())
               dn.setSmallComponentVisible();
            currentTo = ((CBUserObject)dn.getUserObject()).getTelosObject();
            dc = (CBDiagramClass)dn.getDiagramClass();
            CBUserObject olduo=dc.getCBUserObject(currentTo);
            if(currentTo instanceof TelosLink) {
                TelosLink currentLink=(TelosLink)currentTo;
                if(!currentLink.isImplicit()) {
                    storedObjectNames.add(currentTo.toString());
                    storedDiagramNodes.add(dn);
                    oldUserObjects.add(olduo);
                    dc.remove(olduo);  // dc has a cash of user-objects; need to remove it for refreshing 
                }
            } else {
              storedObjectNames.add(currentTo.toString());
              storedDiagramNodes.add(dn);
              oldUserObjects.add(olduo);
              dc.remove(olduo);
            }
        }

        m_cbFrame.getCBEditor().setStatusString("Querying CBserver ...");
        Iterator itUOs1 = new CBQuery("find_object",storedObjectNames,m_cbFrame).ask().iterator();

        HashMap answerUOs = new HashMap();
        while (itUOs1.hasNext()) {
          CBUserObject nextuo=(CBUserObject) itUOs1.next();
          answerUOs.put(nextuo.toString(),nextuo);  // use object name as key
        }

        m_cbFrame.getCBEditor().setStatusString("Validating diagram ...");
        // check whether the stored nodes were returned as answer to the query
        CBUserObject newUserObject = null; 
        for(int i=0; i<storedDiagramNodes.size(); i++){
            DiagramNode dn=(DiagramNode) storedDiagramNodes.get(i);
            dc = (CBDiagramClass)dn.getDiagramClass();
            if(checkCurrentFlag() == FLAG_STOP) {
                break;
            }

            CBUserObject oldUserObject = (CBUserObject)oldUserObjects.get(i);

            if (oldUserObject==null)
                break;

            // memorize old size and location
            Dimension origDnSize=dn.getSize();
            Point origDnLoc = dn.getLocation();

            newUserObject = (CBUserObject) answerUOs.get(oldUserObject.toString());

            if (newUserObject==null) { // old user object does not occur in database anymore
               dc.addUserAndDiagramObject(oldUserObject, dn);
               oldUserObject.setValid(false);
            } else {  // oldUserObject matches
                java.util.logging.Logger.getLogger("global").fine("Updating CBUserObject for " + oldUserObject.toString());
                if(oldUserObject.getTelosObject().isAttribute() &&
                   oldUserObject.getTelosObject().getDestination() != newUserObject.getTelosObject().getDestination()) {
                    dc.addUserAndDiagramObject(oldUserObject, dn);
                    oldUserObject.setValid(false);
                    //search for source and destination, if they are not found searchDiagramObject, will create them
                    DiagramObject doSrc=CBUtil.searchDiagramObject(newUserObject.getTelosObject().getSource(),m_cbFrame);
                    DiagramObject doDst=CBUtil.searchDiagramObject(newUserObject.getTelosObject().getDestination(),m_cbFrame);
                    //create new Diagramnode and Edge
                    DiagramNode dnOnEdge =
                            new DiagramNode(newUserObject, m_cbFrame.getDiagramClass());
                    DiagramEdge deNew =
                            new DiagramEdge(dnOnEdge, doSrc, doDst, m_cbFrame.getDiagramClass());

                    Vector vTmp = new Vector(1);
                    vTmp.add(deNew);
                    //add to DiagramDesktop
                    m_cbFrame.getDiagramDesktop().addDiagramEdges(
                            vTmp,
                            doDst.getNode(),
                            i5.cb.graph.GEConstants.S_POSITION,
                            true);
                }
                else if (oldUserObject.equals(newUserObject)) {
                   dc.addUserAndDiagramObject(oldUserObject, dn);  // have same graph type in particular
                   oldUserObject.setQueryTree(new CBTree(oldUserObject) );  // palette may have changed, hence we need to adapt the queries
                }
                else {
                    dc.addUserAndDiagramObject(newUserObject, dn);
                    dn.setUserObject(newUserObject);
                    if (!origDnSize.equals(dn.getSize()) && (oldUserObject.isResizable() || newUserObject.isResizable() )) {
                      dn.setSize(origDnSize);
                    }
                    if (!origDnLoc.equals(dn.getLocation())) 
                      dn.setLocation(origDnLoc);
                }
                if(dn.isOnEdge()) {
                    dn.getDiagramEdge().updateEdgeStroke();
                }
            }  // oldUserObject and nextUserObject match
//            m_progressBar.setValue(i);
        }
        m_cbFrame.getDiagramDesktop().setMovableDiagramNodeOnEdge(origMoveFlag);
    }

/* alternative to validateBulk; should be slower but also more robust since it checks
   one node at a time; ticket #364
*/

 private void validateIterative(Vector diagramNodes){
        TelosObject currentTo;
        CBDiagramClass dc;

        m_cbFrame.getObi().emptyCache();
        boolean origMoveFlag = m_cbFrame.getDiagramDesktop().getMovableDiagramNodeOnEdge();
        // fix DNonEdges at their current position
        m_cbFrame.getDiagramDesktop().setMovableDiagramNodeOnEdge(false); 

        for(int i=0; i<diagramNodes.size(); i++){

            DiagramNode dn=(DiagramNode) diagramNodes.get(i);
            if (dn.isComponentVisible())
               dn.setSmallComponentVisible();
            if(checkCurrentFlag() == FLAG_STOP) {
                return;
            }
            dc = (CBDiagramClass)dn.getDiagramClass();
            currentTo = ((CBUserObject)dn.getUserObject()).getTelosObject();

            if(currentTo instanceof TelosLink) {
                TelosLink currentLink=(TelosLink)currentTo;
                if(currentLink.isImplicit()) {
                    continue;
                }
            }

            CBUserObject oldUserObject=dc.getCBUserObject(currentTo);
            if(oldUserObject==null)
                return;

            // memorize old size and location
            Dimension origDnSize=dn.getSize();
            Point origDnLoc = dn.getLocation();

            // First, remove old user object from DiagramClass, otherwise CBQuery.ask will return this one
            dc.remove( oldUserObject );
            Iterator itUOs = new CBQuery("find_object["+currentTo.toString()+"/objname]",m_cbFrame).ask().iterator();

            if( !itUOs.hasNext() ){
                java.util.logging.Logger.getLogger("global").fine("Setting '"+currentTo.toString()+"' invalid");
                dc.addUserAndDiagramObject(oldUserObject, dn);
                oldUserObject.setValid(false);
            }
            else {
                CBUserObject newUserObject=(CBUserObject) itUOs.next();
//System.out.println(i+"  "+newUserObject.toString());
                java.util.logging.Logger.getLogger("global").fine("Updating CBUserObject for " + currentTo.toString());
                if(oldUserObject.getTelosObject().isAttribute() &&
                   oldUserObject.getTelosObject().getDestination() != newUserObject.getTelosObject().getDestination()) {
                    dc.addUserAndDiagramObject(oldUserObject, dn);
                    oldUserObject.setValid(false);
                    //search for source and destination, if they are not found searchDiagramObject, will create them
                    DiagramObject doSrc=CBUtil.searchDiagramObject(newUserObject.getTelosObject().getSource(),m_cbFrame);
                    DiagramObject doDst=CBUtil.searchDiagramObject(newUserObject.getTelosObject().getDestination(),m_cbFrame);
                    //create new Diagramnode and Edge
                    DiagramNode dnOnEdge =
                            new DiagramNode(newUserObject, m_cbFrame.getDiagramClass());
                    DiagramEdge deNew =
                            new DiagramEdge(dnOnEdge, doSrc, doDst, m_cbFrame.getDiagramClass());

                    Vector vTmp = new Vector(1);
                    vTmp.add(deNew);
                    //add to DiagramDesktop
                    m_cbFrame.getDiagramDesktop().addDiagramEdges(
                            vTmp,
                            doDst.getNode(),
                            i5.cb.graph.GEConstants.S_POSITION,
                            true);
                }
                else if (oldUserObject.equals(newUserObject)) {
                   dc.addUserAndDiagramObject(oldUserObject, dn);  // have same graph type in particular
                   oldUserObject.setQueryTree(new CBTree(oldUserObject) );  // palette may have changed, hence we need to adapt the queries
                }
                else {
                    dc.addUserAndDiagramObject(newUserObject, dn);
                    dn.setUserObject(newUserObject);
                    if (!origDnSize.equals(dn.getSize()) && (oldUserObject.isResizable() || newUserObject.isResizable() )) {
                      dn.setSize(origDnSize);
                    }
                    if (!origDnLoc.equals(dn.getLocation())) 
                      dn.setLocation(origDnLoc);
                }
                if(dn.isOnEdge()) {
                    dn.getDiagramEdge().updateEdgeStroke();
                }
            }
            m_progressBar.setValue(i);
        }//while
        m_cbFrame.getDiagramDesktop().setMovableDiagramNodeOnEdge(origMoveFlag);
    }



    /** Adds a PropertyChangeListener to the listener list.
     * @param l The listener to add.
     */
    public void addPropertyChangeListener(java.beans.PropertyChangeListener l) {
        propertyChangeSupport.addPropertyChangeListener(l);
    }

    /** Removes a PropertyChangeListener from the listener list.
     * @param l The listener to remove.
     */
    public void removePropertyChangeListener(java.beans.PropertyChangeListener l) {
        propertyChangeSupport.removePropertyChangeListener(l);
    }

    /** Getter for property currentFlag.
     * @return Value of property currentFlag.
     */
    public int getCurrentFlag() {
        return m_currentFlag;
    }

    /** Setter for property currentFlag.
     * @param currentFlag New value of property currentFlag.
     */
    public void setCurrentFlag(int currentFlag) {
        int oldCurrentFlag = this.currentFlag;
        this.m_currentFlag = currentFlag;
        propertyChangeSupport.firePropertyChange("currentFlag", new Integer(oldCurrentFlag), new Integer(currentFlag));
    }


    public void propertyChange(java.beans.PropertyChangeEvent evt) {
        if(evt.getPropertyName().equals("currentFlag") ) {
            switch(m_currentFlag) {
                case IFrameWorker.FLAG_PAUSE:
                    //we won't make the thread pause from here. Instead the thread must check m_currentFlag itself.
                    break;
                case IFrameWorker.FLAG_RESUME:
                    m_thread.notify();
                    m_currentFlag = IFrameWorker.FLAG_NOFLAG;
                    break;
                case IFrameWorker.FLAG_RESTART:
                    //we can only start the thread from here, but we can't REstart it.
                    //This has to be done be the thread itself because in order to restart it has to end before

                    if(m_thread.isAlive() ) {
                        m_currentFlag = IFrameWorker.FLAG_STOP;
                        //try{
                        //m_thread.wait();
                        //}catch(InterruptedException ie){}
                    }
                    m_thread = new Thread(this);
                    m_thread.start();

                    m_currentFlag = IFrameWorker.FLAG_NOFLAG;
                    break;

                case IFrameWorker.FLAG_STOP:
                    //we can't stop the thread from here.
                    //Instead, every task has to check m_currentFlag for the value FLAG_STOP while running

                    //Anyway, if the thread is currently waiting we have to interrupt it from waiting
                    if( ((Integer)evt.getOldValue()).intValue() == FLAG_PAUSE) {
                        m_thread.interrupt();
                    }
                    break;
                default:
                    assert(false)
                    : "CBFrameWorker.propertyChange: the property 'currentFlag' must be one of FLAG_RESTART, FLAG_STOP, FLAG_RESUME or FLAG_PAUSE from IFrameWorker";
            }//switch
        }//if
    }

    /** Getter for property status.
     * @return Value of property status.
     */
    public int getStatus() {
        return m_iStatus;
    }

    /** Setter for property status.
     * @param status New value of property status.
     */
    public void setStatus(int status) {
        int oldStatus = this.m_iStatus;
        this.m_iStatus = status;
        propertyChangeSupport.firePropertyChange("status", new Integer(oldStatus), new Integer(m_iStatus));
    }

    public boolean showsProgressBar() {
        if(m_iTaskID == TASK_CONNECT) {
            return false;
        }
        else {
            return true;
        }
    }

}
