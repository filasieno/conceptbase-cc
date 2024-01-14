/*
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

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
import i5.cb.graph.cbeditor.components.CBTree;
import i5.cb.graph.diagram.*;
import i5.cb.telos.object.TelosLink;
import i5.cb.telos.object.TelosObject;

import java.util.*;

import javax.swing.*;
import javax.swing.event.MenuEvent;
import javax.swing.text.DefaultStyledDocument;
import javax.swing.tree.*;

/**
 * Currently the CBPopup does not extend the GraphPopup by any feature.
 *
 * @author <a href="mailto:">Tobias Latzke</a>
 * @version 1.0
 * @since 1.0
 * @see GraphPopup
 */
public class CBPopup extends GraphPopup {

    private CBUserObject m_cbUserObject;

    private Vector m_subMenuVector;

    private JMenuItem removeItem;

    private JMenuItem straightItem;

    private JMenuItem freezeItem;

    private JMenuItem addInstItem;

    private JMenuItem addClassItem;

    private JMenuItem addSpecItem;

    private JMenuItem addAttrItem;

    private JMenuItem addSuperClassItem;

    private JMenuItem addIndividualItem;

    /**
     * Simply calls the super constructor with the given parameter.
     *
     * @param diagObj the invoking DiagramObject
     */
    public CBPopup(DiagramObject diagObj) {
        super(diagObj);

        m_cbUserObject=(CBUserObject) diagObj.getUserObject();
        addDisplayOnWorkbenchItem();
        this.addSeparator();

        m_subMenuVector=new Vector();

        produceMenu((DefaultMutableTreeNode) m_cbUserObject.getQueryTree().getModel().getRoot(),
                    (JComponent)this);


        this.addSeparator();
        // Items that manipulate the database
        addCreateObjectItems();
        addRemoveFromServerItem();

        this.addSeparator();
        // Items that change only the view
        addRemoveFromDisplayItem();
        addShowInNewFrameItem();
        addStraightenEdges();
        addFreezeNode();

    }

    /**
     * Simply calls the super constructor with the given parameter.
     *
     * @param dd the invoking DiagramDesktop
     */
    public CBPopup(DiagramDesktop dd) {
        super(dd);
    }

    /*
     * Creates a menustructure according to the tree or subtree 'node' is the root of and
     * appends it to 'parent'
     */
    private void produceMenu(DefaultMutableTreeNode node, JComponent parent) {

        assert(parent instanceof JMenuItem) || (parent instanceof JPopupMenu);

        Enumeration enChildren=node.children();

        //java.util.logging.Logger.getLogger("global").fine("produceMenu: node: "+node+"; menuentry: "+ parent.toString());

        ArrayList cbUserObjs=new ArrayList();
        JMenu newMenu=null;
        JMenuItem newMenuItem=null;

        DefaultMutableTreeNode currentNode;

        while(enChildren.hasMoreElements()) {

            currentNode=(DefaultMutableTreeNode) enChildren.nextElement();

            if(!currentNode.isLeaf()) {

                newMenu=new JMenu(currentNode.toString());
                newMenu.setDelay(CBConfiguration.getPopupMenuDelay());

                parent.add(newMenu);

                if((currentNode instanceof CBTree.QueryNode) ||
                   (currentNode instanceof CBTree.AttribCatNode)) {

                    newMenu.addMenuListener(new PopupListener(currentNode, newMenu));

                }

                produceMenu(currentNode, newMenu);

            }

            else {

                //if(!(currentNode instanceof CBTree.WaitNode)) {
                newMenuItem=new JMenuItem(currentNode.toString());

                parent.add(newMenuItem);

                if(currentNode instanceof CBTree.CBUserObjectNode) {

                    cbUserObjs.add(currentNode.getUserObject());

                    //finally we create an actionlistener

                    Vector onlyOneItem=new Vector();

                    onlyOneItem.add(currentNode.getUserObject());

                    newMenuItem.addActionListener(new PopupListener(m_diagramNode, onlyOneItem));

                }
                else {
                    newMenuItem.setEnabled(false);
                }
                //}
            }

        } //while

        if(cbUserObjs.size() != 0) {

            splitMenu((JMenu) parent, cbUserObjs);
        }

    }

    private void splitMenu(JMenu menu, ArrayList userObjs) {

        int itemCount=menu.getItemCount();

        Vector menuItems=new Vector(itemCount);

        JMenuItem currentItem;

        JMenu newMenu;

        //first we extract all JMenuItems that are not JMenus themselves

        for(int i=0; i < itemCount; i++) {
            currentItem=menu.getItem(i);
            if(!(currentItem instanceof JMenu)) {
                menuItems.add(currentItem);
            }
        }

        //if there are less menuitems than the maximum number, we don't split
        if(menuItems.size() <= CBConstants.POPUPMENU_MAX_SIZE) {
            menu.addSeparator();

            JMenuItem allItem=new JMenuItem(m_cbUserObject.getCBFrame().getCBEditor().getCBBundle().
                                            getString("PopupMenu_ShowAll"));
            allItem.addActionListener(new PopupListener(m_diagramNode, userObjs));
            menu.add(allItem);

            return;

        }

        //we remove all menuitems from the menu
        for(int i=0; i < menuItems.size(); i++) {

            menu.remove((JMenuItem) menuItems.elementAt(i));

        }

        //now we create new submenus and divide the menuitems among them
        newMenu=new JMenu();
        for(int i=0; i < menuItems.size(); i++) {

            newMenu.add((JMenuItem) menuItems.elementAt(i));

            if(newMenu.getItemCount() == CBConstants.POPUPMENU_MAX_SIZE) {

                menu.add(newMenu);
                newMenu=new JMenu();

            }
        }

        menu.add(newMenu);

        menu.addSeparator();

        JMenuItem allItem=new JMenuItem(m_cbUserObject.getCBFrame().getCBEditor().getCBBundle().
                                        getString("PopupMenu_ShowAll"));

        allItem.addActionListener(new PopupListener(m_diagramNode, userObjs));

        menu.add(allItem);

        //here we set the new submenu's labels according to the submenus that are inside them
        GEUtil.setLetters(menu);

    } //splitMenu

    private void addRemoveFromDisplayItem() {

        ResourceBundle bundle=m_cbUserObject.getCBFrame().getCBEditor().getCBBundle();
        removeItem=new JMenuItem(bundle.getString("PopupMenu_RemoveFromDisplay"));
        removeItem.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent ae) {
                DiagramDesktop dd=m_cbUserObject.getDiagramNode().getDiagramDesktop();
                dd.removeDiagramObject(m_cbUserObject.getDiagramNode());
            }
        }
        );
        this.add(removeItem);

    }


    private void addStraightenEdges(){

        ResourceBundle bundle=m_cbUserObject.getCBFrame().getCBEditor().getCBBundle();
        straightItem=new JMenuItem(bundle.getString("PopupMenu_straightenEdges"));
        straightItem.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent ae) {
                DiagramDesktop dd=m_cbUserObject.getDiagramNode().getDiagramDesktop();
                dd.setEdgesStraight(m_cbUserObject.getDiagramNode());
            }
        }
        );
        this.add(straightItem);

    }

    private void addFreezeNode(){

        ResourceBundle bundle=m_cbUserObject.getCBFrame().getCBEditor().getCBBundle();
        freezeItem=new JMenuItem(bundle.getString("PopupMenu_freezeUnfreeze"));
        freezeItem.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent ae) {
                DiagramDesktop dd=m_cbUserObject.getDiagramNode().getDiagramDesktop();
                dd.toggleFrozen(m_cbUserObject.getDiagramNode());
            }
        }
        );
        this.add(freezeItem);

    }


    private void addRemoveFromServerItem() {

        ResourceBundle bundle=m_cbUserObject.getCBFrame().getCBEditor().getCBBundle();
        removeItem=new JMenuItem(bundle.getString("PopupMenu_RemoveFromServer"));
        removeItem.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent ae) {
                //get the HashTabelentry and save it in the List
                DiagramClassHashtableEntry diagHash=m_cbUserObject.getCBFrame().getDiagramClass().
                    getHashtableEntry(m_cbUserObject);
                DiagramDesktop dd=m_cbUserObject.getCBFrame().getDiagramDesktop();
                //check if this object was added by the user, if not add it to the delete list
                if(!(m_cbUserObject.getCBFrame().getObjectsToAdd().contains(diagHash))) {
                    m_cbUserObject.getCBFrame().addObjectToDelete(diagHash);
                    // here we add the object to the list and check if we need to erase edges too
                    m_cbUserObject.getCBFrame().removeObjectToAdd(diagHash);
                    addEdgesToDelete(dd);
                    m_cbUserObject.getCBFrame().getDiagramDesktop().setNodeSelected(diagHash.
                        getDiagramNode(), false);
                    if(diagHash.getDiagramNode().isOnEdge()) {
                        m_cbUserObject.getCBFrame().getDiagramDesktop().remove(diagHash.getDiagramNode().getDiagramEdge());
                    }
                    m_cbUserObject.getCBFrame().getDiagramDesktop().remove(diagHash.getDiagramNode());
                }
                else {
                    //object not in database, so we simply erase it
                    m_cbUserObject.getCBFrame().removeObjectToAdd(diagHash);
                    dd.removeDiagramObject(diagHash.getDiagramNode());
                }
            }
        }
        );
        this.add(removeItem);

    }

    private void addEdgesToDelete(DiagramDesktop currentDiagDesktop) {
        Vector diagNodes=currentDiagDesktop.getDiagramNodes();
        Enumeration nodesEnum=diagNodes.elements();
        //loop over all diagramEdges and erase/save them if the have our object as source of destination
        while(nodesEnum.hasMoreElements()) {
            DiagramNode currentDiagNode=(DiagramNode) nodesEnum.nextElement();
            TelosObject currentTo=((CBUserObject) currentDiagNode.getUserObject()).getTelosObject();
            if(currentTo instanceof TelosLink) {
                TelosLink currentLink=(TelosLink) currentTo;
                if(currentLink.getSource() == m_cbUserObject.getTelosObject() ||
                   currentLink.getDestination() == m_cbUserObject.getTelosObject()) {
                    DiagramClassHashtableEntry currentHashEntry=currentDiagNode.getDiagramClass().
                        getHashtableEntry((CBUserObject) currentDiagNode.getUserObject());
                    DiagramEdge currentDiagEdge=currentHashEntry.getDiagramNode().getDiagramEdge();
                    m_cbUserObject.getCBFrame().addObjectToDelete(currentHashEntry);
                    m_cbUserObject.getCBFrame().removeObjectToAdd(currentHashEntry);
                    m_cbUserObject.getCBFrame().getDiagramDesktop().remove(currentDiagNode);
                    m_cbUserObject.getCBFrame().getDiagramDesktop().remove(currentDiagEdge);
                }
            }
        }
    }

    private void addCreateObjectItems() {

        ResourceBundle bundle=m_cbUserObject.getCBFrame().getCBEditor().getCBBundle();
        //add create Instance item
        addInstItem=new JMenuItem(bundle.getString("PopupMenu_addInstance"));
        addInstItem.addActionListener(new java.awt.event.ActionListener() {
            CBEditor cbEditor=m_cbUserObject.getCBFrame().getCBEditor();
            public void actionPerformed(java.awt.event.ActionEvent ae) {
                CreateObjectDialog cod=new CreateObjectDialog(TelosObject.INSTANTIATION,
                    (CBFrame) cbEditor.getActiveGraphInternalFrame());
                cbEditor.getDesktopPane().add(cod, JLayeredPane.MODAL_LAYER);
                cod.setVisible(true);
                cod.setTextFieldText(1, m_cbUserObject.toString());
                cod.setLocation(cbEditor.getDesktopPane().getWidth() - cod.getPreferredSize().width,
                                0);
            }
        }
        );
        this.add(addInstItem);
        //add create Class item
        addClassItem=new JMenuItem(bundle.getString("PopupMenu_addClass"));
        addClassItem.addActionListener(new java.awt.event.ActionListener() {
            CBEditor cbEditor=m_cbUserObject.getCBFrame().getCBEditor();
            public void actionPerformed(java.awt.event.ActionEvent ae) {
                CreateObjectDialog cod=new CreateObjectDialog(TelosObject.INSTANTIATION,
                    (CBFrame) cbEditor.getActiveGraphInternalFrame());
                cbEditor.getDesktopPane().add(cod, JLayeredPane.MODAL_LAYER);
                cod.setVisible(true);
                cod.setTextFieldText(2, m_cbUserObject.toString());
                cod.setLocation(cbEditor.getDesktopPane().getWidth() - cod.getPreferredSize().width,
                                0);
            }
        }
        );
        this.add(addClassItem);
        //add create superclass item
        addSuperClassItem=new JMenuItem(bundle.getString("PopupMenu_addSuperClass"));
        addSuperClassItem.addActionListener(new java.awt.event.ActionListener() {
            CBEditor cbEditor=m_cbUserObject.getCBFrame().getCBEditor();
            public void actionPerformed(java.awt.event.ActionEvent ae) {
                CreateObjectDialog cod=new CreateObjectDialog(TelosObject.SPECIALIZATION,
                    (CBFrame) cbEditor.getActiveGraphInternalFrame());
                cbEditor.getDesktopPane().add(cod, JLayeredPane.MODAL_LAYER);
                cod.setVisible(true);
                cod.setTextFieldText(2, m_cbUserObject.toString());
                cod.setLocation(cbEditor.getDesktopPane().getWidth() - cod.getPreferredSize().width,
                                0);
            }
        }
        );
        this.add(addSuperClassItem);
        //add create specialisation item
        addSpecItem=new JMenuItem(bundle.getString("PopupMenu_addSpecialisation"));
        addSpecItem.addActionListener(new java.awt.event.ActionListener() {
            CBEditor cbEditor=m_cbUserObject.getCBFrame().getCBEditor();
            public void actionPerformed(java.awt.event.ActionEvent ae) {
                CreateObjectDialog cod=new CreateObjectDialog(TelosObject.SPECIALIZATION,
                    (CBFrame) cbEditor.getActiveGraphInternalFrame());
                cbEditor.getDesktopPane().add(cod, JLayeredPane.MODAL_LAYER);
                cod.setVisible(true);
                cod.setTextFieldText(1, m_cbUserObject.toString());
                cod.setLocation(cbEditor.getDesktopPane().getWidth() - cod.getPreferredSize().width,
                                0);
            }
        }
        );
        this.add(addSpecItem);
        //add create attribute item
        addAttrItem=new JMenuItem(bundle.getString("PopupMenu_addAttribute"));
        addAttrItem.addActionListener(new java.awt.event.ActionListener() {
            CBEditor cbEditor=m_cbUserObject.getCBFrame().getCBEditor();
            public void actionPerformed(java.awt.event.ActionEvent ae) {
                CreateObjectDialog cod=new CreateObjectDialog(TelosObject.ATTRIBUTE,
                    (CBFrame) cbEditor.getActiveGraphInternalFrame());
                cbEditor.getDesktopPane().add(cod, JLayeredPane.MODAL_LAYER);
                cod.setVisible(true);
                cod.setTextFieldText(2, m_cbUserObject.toString());
                cod.setLocation(cbEditor.getDesktopPane().getWidth() - cod.getPreferredSize().width,
                                0);
            }
        }
        );
        this.add(addAttrItem);
        //add create class item
        addIndividualItem=new JMenuItem(bundle.getString("PopupMenu_addIndividual"));
        addIndividualItem.addActionListener(new java.awt.event.ActionListener() {
            CBEditor cbEditor=m_cbUserObject.getCBFrame().getCBEditor();
            public void actionPerformed(java.awt.event.ActionEvent ae) {
                CreateObjectDialog cod=new CreateObjectDialog(TelosObject.INDIVIDUAL,
                    (CBFrame) cbEditor.getActiveGraphInternalFrame());
                cbEditor.getDesktopPane().add(cod, JLayeredPane.MODAL_LAYER);
                cod.setVisible(true);
                cod.setLocation(cbEditor.getDesktopPane().getWidth() - cod.getPreferredSize().width,
                                0);
            }
        }
        );
        this.add(addIndividualItem);

    }

    private void addDisplayOnWorkbenchItem() {
        ResourceBundle bundle=m_cbUserObject.getCBFrame().getCBEditor().getCBBundle();
        JMenuItem dispWorkBench=new JMenuItem(bundle.getString("PopupMenu_displayOnWorkbench"));
        dispWorkBench.addActionListener(new java.awt.event.ActionListener() {
            CBEditor cbEditor=m_cbUserObject.getCBFrame().getCBEditor();
            public void actionPerformed(java.awt.event.ActionEvent ae) {
                // hook to start CBIva on the fly when it is not running
                if (cbEditor.getWorkbench() == null) {
                  cbEditor.setWorkbench(i5.cb.workbench.CBIva.startCBIvaWithCBEditor(cbEditor,false));
                }
                if(cbEditor.getWorkbench() != null && cbEditor.getWorkbench().getActiveTelosEditor() != null) {
                    String sObject=m_cbUserObject.getTelosObject().toString();
                    String sResult=cbEditor.getWorkbench().getCBClient().getObject(sObject);
                    String oldTEtext = cbEditor.getWorkbench().getActiveTelosEditor().getTelosTextArea().getText();
                    String newTEtext;
                    if (oldTEtext.equals(""))
                       newTEtext = sResult;
                    else
                       newTEtext = oldTEtext+"\n"+sResult;
                    cbEditor.getWorkbench().getActiveTelosEditor().getTelosTextArea().setText(newTEtext);
                    cbEditor.getWorkbench().setVisible(true);
                }
            }
        }
        );
        this.add(dispWorkBench);
    }

    private void addShowInNewFrameItem() {
        ResourceBundle bundle=m_cbUserObject.getCBFrame().getCBEditor().getCBBundle();
        JMenuItem newFrame=new JMenuItem(bundle.getString("PopupMenu_showInNewFrame"));
        newFrame.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent ae) {
                String sHost=m_cbUserObject.getCBFrame().getHost();
                String sPalette=m_cbUserObject.getCBFrame().getGraphicalPalette();

                CBFrame newFrame=new CBFrame(m_cbUserObject.getCBFrame().getCBEditor(),
                                             sHost + ":" + m_cbUserObject.getCBFrame().getPort(),
                                             sPalette);
                try {
                    Object[] task= {newFrame, sHost,
                                  new Integer(m_cbUserObject.getCBFrame().getPort()),
                                  m_cbUserObject.toString(),
                                  m_cbUserObject.getObi().getCBClient().getModule()};
                    CBFrameWorker gifWorker=(CBFrameWorker) newFrame.getFrameWorker();
                    gifWorker.setTask(CBFrameWorker.TASK_CONNECT, task);
                    gifWorker.restartFrameWorker();
                }
                catch(java.rmi.RemoteException rmex) {}
            }
        }
        );
        this.add(newFrame);
    }

    /** This method updates the textBundle and sets the new text for all generic items
     *
     * @return always null at the moment
     * @param loc the locale to use
     *
     */
    public DefaultStyledDocument updateLang(Locale loc) {
        //if m_cbUserObject is still set to null, the method is called by GraphPopup's constructor right before m_cbUserObject was set
        //I don't know what purpose this call serves
        if(m_cbUserObject == null)
            return null;

        Enumeration en;
        SubMenu sMenu;
        ResourceBundle bundle=m_cbUserObject.getCBFrame().getCBEditor().getCBBundle(loc);

        // -- the eraseItem has to be translated
        removeItem.setText(bundle.getString("PopupMenu_Remove"));

        // -- then every SubMenu has to be updated
        en=m_subMenuVector.elements();

        while(en.hasMoreElements()) {
            sMenu=(SubMenu) en.nextElement();
            updateLang(sMenu, bundle);
        }
        return null;
    }

    /**
     * called by public updateLang(). Translation for every SubMenu.
     * First the title has to be translated. If the {@link javax.swing.JMenu} is empty, the noObjects String is translated,
     * else there is the "show all" item that needs to be translated
     *
     * @param menu contains additional information for translation
     * @see SubMenu
     */
    private void updateLang(SubMenu menu, ResourceBundle bundle) {
        menu.m_jSubMenu.setText(bundle.getString(menu.titleKey));
        if(menu.m_jSubMenu.getItemCount() > 1)
            ((JMenuItem) menu.m_jSubMenu.getMenuComponent(menu.m_jSubMenu.getItemCount() - 1)).
                setText(bundle.getString("PopupMenu_ShowAll"));
        else
            ((JMenuItem) menu.m_jSubMenu.getMenuComponent(menu.m_jSubMenu.getItemCount() - 1)).
                setText(bundle.getString(menu.noObjectsKey));

    }

    /**
     * Inner class. For Translation it is useful to keep the JMenus and their titles and noObjects
     * Strings together in a unit
     *
     * @author <a href="mailto:">Tobias Latzke</a>
     */
    class SubMenu {

        /**
         * The name or title of this submenu
         */
        protected String titleKey;

        /**
         * The string to be displayed if there are no Objects in this submenu
         */
        protected String noObjectsKey;

        /** t       he JMenu belonging the want to retrieve with <CODE>titleKey</CODE>
         *
         */

        protected JMenu m_jSubMenu;

        /**
         *
         * Be sure to only create SubMenus with valid titles and noObjects Strings
         *
         * these Strings must be defined in the ResourceBundle
         *
         *
         *
         * @param title the name of the item
         *
         * @param noObjects if there are no objects, this String is displayed
         *
         * @param menu a <code>JMenu</code>
         *
         */

        SubMenu(String title, String noObjects, JMenu menu) {

            this.titleKey=title;

            this.noObjectsKey=noObjects;

            this.m_jSubMenu=menu;

        }

    } //SubMenu

    class PopupListener implements java.awt.event.ActionListener, javax.swing.event.MenuListener {

        private Collection m_uoc;

        private DiagramNode m_diagNode;

        private DefaultMutableTreeNode m_node;

        private JMenu m_menu;

        private boolean m_bMenuVisible;

        /**
         * This constructor is invoked when a set of
         * TelosObjects is to be added to the diagramDesktop
         */

        /** Creates a new instance of PopupListener.
         * PopupListener is used as ActionListener here
         * @param diagNode the {@link i5.cb.graph.diagram.DiagramNode} this poupMenu belongs to
         * @param uoc contains the {@link i5.cb.graph.cbeditor.CBUserObject}s
         * we shall create new diagramNodes for
         */
        public PopupListener(DiagramNode diagNode, Collection uoc) {
            m_uoc=uoc;
            m_diagNode=diagNode;
        }

        /** Creates a new instance of PopupListener.
         * PopupListener is used as MenuListener her
         * @param node the node this popupmenu belongs to
         * @param menu the JMenu may have to append a submenu to
         */
        public PopupListener(DefaultMutableTreeNode node, JMenu menu) {
            m_node=node;
            m_menu=menu;
        }

        /** adds new nodes to the diagramDesktop
         *
         * @param actionEvent
         *
         */

        public void actionPerformed(java.awt.event.ActionEvent actionEvent) {

            CBUtil.createAndAddNewDiagramObjects(m_uoc, m_cbUserObject.getCBFrame(), m_diagNode);

        }

        /** not used here, just to implement the Interface
         *
         * @param e  */
        public void menuCanceled(MenuEvent e) {
            java.util.logging.Logger.getLogger("global").fine("CBPopup.PopupListener.menuCanceled: " +
                                                 ((JMenu) e.getSource()).getText());
        }

        /** not used here, just to implement the Interface
         *
         * @param e  */
        public void menuDeselected(MenuEvent e) {
            java.util.logging.Logger.getLogger("global").fine("CBPopup.PopupListener.menuDeselected: " +
                                                 ((JMenu) e.getSource()).getText());
            m_bMenuVisible=false;
        }

        /** Invoked when a menu is selected
         * It's made sure here that the submenu's entries are extracted
         * from ConceptBase and that the submenu is created and added before it is shown
         * @param e  a MenuEvent object
         */

        public void menuSelected(MenuEvent e) {
            java.util.logging.Logger.getLogger("global").fine("CBPopup.PopupListener.menuSelected: " +
                                                 ((JMenu) e.getSource()).getText());
            m_bMenuVisible=true;
            if(m_node.getFirstChild() instanceof CBTree.WaitNode) {
                if(CBConfiguration.getPopupMenuBlocks()) {
                    extendTree();
                }
                else {
                    ExtendTreeThread thread=new ExtendTreeThread("CBPopup.ExtendTreeThread");
                    thread.start();
                }
            }
            //java.util.logging.Logger.getLogger("global").fine("CBPopup..PoupupListener.menuSelected:" +((JMenu)e.getSource()).getText() );
        }

        private void extendTree() {
            try {
                m_cbUserObject.getQueryTree().fireTreeWillExpand(new TreePath(m_node.
                    getPath()));
                //java.util.logging.Logger.getLogger("global").fine("PopupListener.run.");
            }
            catch(ExpandVetoException eve) {
                java.util.logging.Logger.getLogger("global").warning(
                    "PopupListener.run: ExpandVetoException: " + eve.getMessage());
            }
            m_menu.setPopupMenuVisible(false);

            m_menu.removeAll();
            produceMenu(m_node, m_menu);

            if(m_bMenuVisible) {
                m_menu.setPopupMenuVisible(true);
            }
        }

        private class ExtendTreeThread extends Thread {

            public ExtendTreeThread(String name) {
                super(name);
            }

            public void run() {
                extendTree();
            }

        }

    } //PopupCommand

}
