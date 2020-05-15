/*
The ConceptBase.cc Copyright

Copyright 1987-2020 The ConceptBase Team. All rights reserved.

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
import i5.cb.graph.cbeditor.components.*;
import i5.cb.telos.object.TelosObject;

import java.awt.Color;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Collection;

import javax.swing.*;
import java.awt.*;


/**
 * This ActionListener handles most ConceptBase specific Events.
 * Currently there are a few other Actionlisteners in this package,
 * which work for special-purpose-components
 *
 * @author <a href="mailto:">Tobias Latzke</a>
 * @version 1.0
 * @since 1.0
 * @see ActionListener
 */
public class CBCommand implements ActionListener, java.io.Serializable{

    // action identifier constants should have the Form <MENU>_<ITEM> = number


    public static final int FILE_CONNECT = 11;

    public static final int FILE_STARTWORKBENCH = 13;

    public static final int FILE_ADDNEWNODE = 12;

    public static final int FILE_CLOSE =14;

    public static final int EDIT_FINDRELATIONS = 21;

    // Setting background color of diagram desktop
    public static final int OPTIONS_BGCOLOR = 31;

    public static final int ACTIVEFRAME_SUBMITQUERY = 41;

    public static final int ACTIVEFRAME_VALIDATEOBJECTS = 42;

    public static final int ACTIVEFRAME_VALIDATESELECTEDOBJECTS = 43;

    public static final int ACTIVEFRAME_CHANGEGRAPHPAL=44;
    public static final int ACTIVEFRAME_CHANGEGRAPHMOD=45;

    // Creating objects in ConceptBase
    public static final int ADD_INDIVIDUAL = 401;
    public static final int ADD_ATTRIBUTE = 402;
    public static final int ADD_INSTANTIATION = 403;
    public static final int ADD_SPECIALIZATION = 404;
    public static final int ADD_COMMIT = 405;
    public static final int ADD_REMOVE = 406;


    /** Action Identifier. The action that will be Performed depends on this ID. Should be one of the constants defined above
     */
    protected int actionId;

    private CBEditor m_cbEditor;

    /** Creates a new <code>CBCommand</code> instance.
     *
     * @param cbEditor The cbEditor this object belongs to
     * @param actionId The action that will be Performed depends on this ID.
     */
    //public CBCommand(int actionId){
    //	this.actionId = actionId;
    //}



    public CBCommand(int actionId, CBEditor cbEditor){
        this.actionId = actionId;
        m_cbEditor = cbEditor;
    }//<init>


    /** Determines the action to be performed via the value of <CODE>iActionID</CODE>
     * @param ae an ActionEvent
     */
    public void actionPerformed(ActionEvent ae){
        CBFrameWorker gifWorker;
        switch(actionId){

            case FILE_CLOSE:
                 m_cbEditor.close();  // defined in class GraphEditor
                 break;
            case FILE_CONNECT:
                //java.util.logging.Logger.getLogger("global").fine("selected 'Connect' item / pressed 'Connect' button");
                assert(m_cbEditor != null): "CBCommand.actionPerformed: m_cbEditor may not be null";
                new CBConnectionDialog(m_cbEditor).setVisible(true);
                break;
            case FILE_ADDNEWNODE:
                //java.util.logging.Logger.getLogger("global").fine("selected 'Connect' item / pressed 'Connect' button");
                new AddNodeDialog(m_cbEditor, (CBFrame)m_cbEditor.getActiveGraphInternalFrame()).setVisible(true);
                break;
            case EDIT_FINDRELATIONS:
                Collection selectedNodes = m_cbEditor.getActiveGraphInternalFrame().getDiagramDesktop().getSelectedNodes();

                Object[] findTaskData = {selectedNodes, selectedNodes};
                gifWorker = (CBFrameWorker)m_cbEditor.getActiveGraphInternalFrame().getFrameWorker();
                gifWorker.setTask(CBFrameWorker.TASK_FIND_RELATIONS, findTaskData);
                m_cbEditor.showProgressStatus(true);
                gifWorker.setUpdateProgressBar(true,m_cbEditor.getProgressBar() );
                gifWorker.restartFrameWorker();
                break;

            case OPTIONS_BGCOLOR :

                Color newDDColor = JColorChooser.showDialog(m_cbEditor, "", m_cbEditor.getActiveGraphInternalFrame().getDiagramDesktop().getBackground() );
                m_cbEditor.getActiveGraphInternalFrame().getDiagramDesktop().setBackground(newDDColor);
                CBConfiguration.setDDColor(newDDColor);
                break;

            case ACTIVEFRAME_VALIDATEOBJECTS :
                ( (CBFrame)m_cbEditor.getActiveGraphInternalFrame() ).validateNodes();
                break;

            case ACTIVEFRAME_VALIDATESELECTEDOBJECTS :
                ( (CBFrame)m_cbEditor.getActiveGraphInternalFrame() ).validateSelectedNodes();
                break;
            case ACTIVEFRAME_CHANGEGRAPHPAL:
                ( (CBFrame)m_cbEditor.getActiveGraphInternalFrame() ).changeGraphicalPalette();
               break;
            case ACTIVEFRAME_CHANGEGRAPHMOD:
                ( (CBFrame)m_cbEditor.getActiveGraphInternalFrame() ).changeGraphModule();
               break;
            case ACTIVEFRAME_SUBMITQUERY :
                java.util.logging.Logger.getLogger("global").fine("Submit query");
                new SubmitQueryDialog(m_cbEditor).setVisible(true);
                break;

            case ADD_ATTRIBUTE:
                if(m_cbEditor.getActiveGraphInternalFrame()!=null) {
                    CreateObjectDialog cod=new CreateObjectDialog(TelosObject.ATTRIBUTE,(CBFrame)m_cbEditor.getActiveGraphInternalFrame());
                    m_cbEditor.getDesktopPane().add(cod,JLayeredPane.MODAL_LAYER);
                    cod.setVisible(true);
                    cod.setLocation(m_cbEditor.getDesktopPane().getWidth()-cod.getPreferredSize().width,0);
                }
                else {
                    JOptionPane.showMessageDialog(m_cbEditor,"Select an internal frame","No frame selected",JOptionPane.INFORMATION_MESSAGE);
                }
                break;

            case ADD_INDIVIDUAL:
                if(m_cbEditor.getActiveGraphInternalFrame()!=null) {
                    CreateObjectDialog cod=new CreateObjectDialog(TelosObject.INDIVIDUAL,(CBFrame)m_cbEditor.getActiveGraphInternalFrame());
                    m_cbEditor.getDesktopPane().add(cod,JLayeredPane.MODAL_LAYER);
                    cod.setVisible(true);
                    cod.setLocation(m_cbEditor.getDesktopPane().getWidth()-cod.getPreferredSize().width,0);
                }
                else {
                    JOptionPane.showMessageDialog(m_cbEditor,"Select an internal frame","No frame selected",JOptionPane.INFORMATION_MESSAGE);
                }
                break;
            case ADD_INSTANTIATION:
                if(m_cbEditor.getActiveGraphInternalFrame()!=null) {
                    CreateObjectDialog cod=new CreateObjectDialog(TelosObject.INSTANTIATION,(CBFrame)m_cbEditor.getActiveGraphInternalFrame());
                    m_cbEditor.getDesktopPane().add(cod,JLayeredPane.MODAL_LAYER);
                    cod.setVisible(true);
                    cod.setLocation(m_cbEditor.getDesktopPane().getWidth()-cod.getPreferredSize().width,0);
                }
                else {
                    JOptionPane.showMessageDialog(m_cbEditor,"Select an internal frame","No frame selected",JOptionPane.INFORMATION_MESSAGE);
                }
                break;
            case ADD_SPECIALIZATION:
                if(m_cbEditor.getActiveGraphInternalFrame()!=null) {
                    CreateObjectDialog cod=new CreateObjectDialog(TelosObject.SPECIALIZATION,(CBFrame)m_cbEditor.getActiveGraphInternalFrame());
                    m_cbEditor.getDesktopPane().add(cod,JLayeredPane.MODAL_LAYER);
                    cod.setVisible(true);
                    cod.setLocation(m_cbEditor.getDesktopPane().getWidth()-cod.getPreferredSize().width,0);
                }
                else {
                    JOptionPane.showMessageDialog(m_cbEditor,"Select an internal frame","No frame selected",JOptionPane.INFORMATION_MESSAGE);
                }
                break;
            case ADD_REMOVE:
                if(m_cbEditor.getActiveGraphInternalFrame()!=null) {
                    SelectObjectsDialog sod=new SelectObjectsDialog((CBFrame)m_cbEditor.getActiveGraphInternalFrame());
                    m_cbEditor.getDesktopPane().add(sod,JLayeredPane.MODAL_LAYER);
                    sod.setVisible(true);
                    sod.setLocation(m_cbEditor.getDesktopPane().getWidth()-sod.getPreferredSize().width,0);
                }
                else {
                    JOptionPane.showMessageDialog(m_cbEditor,"Select an internal frame","No frame selected",JOptionPane.INFORMATION_MESSAGE);
                }
                break;
            case ADD_COMMIT:
                if(m_cbEditor.getActiveGraphInternalFrame()!=null) {
                    ((CBFrame)(m_cbEditor.getActiveGraphInternalFrame())).commitChanges();

                }
                else {
                    JOptionPane.showMessageDialog(m_cbEditor,"Select an internal frame","No frame selected",JOptionPane.INFORMATION_MESSAGE);
                }
                break;
            case FILE_STARTWORKBENCH:
                if(m_cbEditor.getWorkbench() == null){
                    m_cbEditor.setWorkbench(i5.cb.workbench.CBIva.startCBIvaWithCBEditor(m_cbEditor));
                } else {
                    m_cbEditor.getWorkbench().setVisible(true);
                }
                break;
        }
    }

    /** Getter for property actionId.
     * @return Value of property actionId.
     */
    public int getActionId() {
        return actionId;
    }

    /** Setter for property actionId.
     * @param actionId New value of property actionId.
     */
    public void setActionId(int actionId) {
        this.actionId = actionId;
    }

    /** Getter for property cbEditor.
     * @return Value of property cbEditor.
     */
    public CBEditor getCbEditor() {
        return this.m_cbEditor;
    }

    /** Setter for property cbEditor.
     * @param cbEditor New value of property cbEditor.
     */
    public void setCbEditor(CBEditor cbEditor) {
        this.m_cbEditor = cbEditor;
    }

}
