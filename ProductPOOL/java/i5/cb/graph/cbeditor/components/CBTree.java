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
package i5.cb.graph.cbeditor.components;

import i5.cb.graph.cbeditor.*;
import i5.cb.telos.object.ITelosObjectSet;
import i5.cb.telos.object.TelosObject;

import java.util.*;

import javax.swing.JTree;
import javax.swing.event.TreeExpansionEvent;
import javax.swing.event.TreeWillExpandListener;
import javax.swing.tree.*;

import i5.cb.CBConfiguration;



/** Contains a {@link i5.cb.graph.cbeditor.CBUserObject}'s
 * {@link i5.cb.graph.cbeditor.CBQuery}s together with
 * their answers. Also contains the labels that are shown in the componentview and
 * the {@link i5.cb.graph.cbeditor.CBPopup}menu
 * @author Tobias Sch?neberg
 */

public class CBTree extends JTree {



    CBUserObject m_cbUO;

    DefaultTreeModel m_treeModel;

    CBFrame m_cbFrame;


    /** Creates a new tree with the root representing the CBUserObject's telosobject
    * @param uo the userobject of the diagramObject
    */
    public CBTree( CBUserObject uo ) {

        super();
        setRootVisible(false);
        putClientProperty("JTree.lineStyle", "Angled");
        addTreeWillExpandListener(new CBTreeWillExpandListener());

        m_cbUO = uo;
        m_cbFrame = uo.getCBFrame();
        DefaultMutableTreeNode root = new DefaultMutableTreeNode();
        m_treeModel = new DefaultTreeModel(root);

        createTreeNodes(root);
        setModel(m_treeModel);
    }

    /**
     *  Creates and adds some default queries
     *
     *@param  root  the root node of this tree
     */

    private void createTreeNodes(DefaultMutableTreeNode root) {

        CBQuery newQuery;
        QueryNode newQueryNode;
        AttribCatNode newAttribCatNode;
        LabelNode newLabelNode;

        CBQuery[] queries = createDefaultQueries();

        ResourceBundle bundle = m_cbFrame.getCBEditor().getCBBundle();

        newLabelNode = new LabelNode(bundle.getString("queryLabel_extends") );
        root.add(newLabelNode);
        {

            newQuery = queries[2];
            newQueryNode = new QueryNode(newQuery, bundle.getString("queryResult_Explicit") );
            newLabelNode.add(newQueryNode);
            newQueryNode.add(new WaitNode() );

            newQuery = queries[3];
            newQueryNode = new QueryNode(newQuery, bundle.getString("queryResult_All") );
            newLabelNode.add(newQueryNode);
            newQueryNode.add(new WaitNode() );
        }

        newLabelNode = new LabelNode(bundle.getString("queryLabel_hasExtensions") );
        root.add(newLabelNode);
        {

            newQuery = queries[0];
            newQueryNode = new QueryNode(newQuery, bundle.getString("queryResult_Explicit") );
            newLabelNode.add(newQueryNode);
            newQueryNode.add(new WaitNode() );

            newQuery = queries[1];
            newQueryNode = new QueryNode(newQuery, bundle.getString("queryResult_All") );
            newLabelNode.add(newQueryNode);
            newQueryNode.add(new WaitNode() );
        }


        newLabelNode = new LabelNode(bundle.getString("queryLabel_InstanceOf") );
        root.add(newLabelNode);
        {

            newQuery = queries[4];
            newQueryNode = new QueryNode(newQuery, bundle.getString("queryResult_Explicit") );
            newLabelNode.add(newQueryNode);
            newQueryNode.add(new WaitNode() );

            newQuery = queries[5];
            newQueryNode = new QueryNode(newQuery, bundle.getString("queryResult_All") );
            newLabelNode.add(newQueryNode);
            newQueryNode.add(new WaitNode() );
        }

        newLabelNode = new LabelNode(bundle.getString("queryLabel_hasInstances") );
        root.add(newLabelNode);
        {

            newQuery = queries[6];
            newQueryNode = new QueryNode(newQuery, bundle.getString("queryResult_Explicit") );
            newLabelNode.add(newQueryNode);
            newQueryNode.add(new WaitNode() );

            newQuery = queries[7];
            newQueryNode = new QueryNode(newQuery, bundle.getString("queryResult_All") );
            newLabelNode.add(newQueryNode);
            newQueryNode.add(new WaitNode() );
        }

        String sQueryOutgoing = m_cbFrame.getOutgoingCatsQuery() + "[";   // default "find_used_attribute_categories"
        String sQueryIncoming = m_cbFrame.getIncomingCatsQuery() + "[";   // default "find_used_incoming_attribute_categories"

/*
        if (CBConfiguration.getEnableDerivedLinks()) { 
           sQueryOutgoing = "find_used_attribute_categories[";
           sQueryIncoming = "find_used_incoming_attribute_categories[";
        }
*/

        newAttribCatNode = new AttribCatNode(bundle.getString("queryLabel_outgoingAttr"), sQueryOutgoing + m_cbUO.toString() +"/objname]", AttribCatNode.OUTGOING);
        root.add(newAttribCatNode);
        newAttribCatNode.add(new WaitNode() );

        newAttribCatNode = new  AttribCatNode(bundle.getString("queryLabel_incomingAttr"), sQueryIncoming + m_cbUO.toString() +"/objname]", AttribCatNode.INCOMING);
        root.add(newAttribCatNode);
        newAttribCatNode.add(new WaitNode() );

    }//createTreeNodes

    private CBQuery[] createDefaultQueries() {
        CBQuery[] queries = new CBQuery[8];

        try {
            queries[0] = new CBQuery("find_specializations["+ m_cbUO.toString() +"/class,FALSE/ded]", m_cbFrame, m_cbUO.getTelosObject(), "IsA", "dst");
            queries[1] = new CBQuery("find_specializations["+ m_cbUO.toString() +"/class,TRUE/ded]", m_cbFrame, m_cbUO.getTelosObject(), "IsA", "dst");
            queries[2] = new CBQuery("find_generalizations["+ m_cbUO.toString() +"/class,FALSE/ded]", m_cbFrame, m_cbUO.getTelosObject(), "IsA", "src");
            queries[3] = new CBQuery("find_generalizations["+ m_cbUO.toString() +"/class,TRUE/ded]", m_cbFrame, m_cbUO.getTelosObject(), "IsA", "src");
            queries[4] = new CBQuery("find_explicit_classes["+ m_cbUO.toString() +"/objname]", m_cbFrame, m_cbUO.getTelosObject(), "InstanceOf", "src");
            queries[5] = new CBQuery("find_classes["+ m_cbUO.toString() +"/objname]", m_cbFrame, m_cbUO.getTelosObject(), "InstanceOf", "src");
            queries[6] = new CBQuery("find_explicit_instances["+ m_cbUO.toString() +"/class]", m_cbFrame, m_cbUO.getTelosObject(), "InstanceOf", "dst");
            queries[7] = new CBQuery("find_instances["+ m_cbUO.toString() +"/class]", m_cbFrame, m_cbUO.getTelosObject(), "InstanceOf", "dst");
        }
        catch(Exception e) {
            java.util.logging.Logger.getLogger("global").fine("CBTree.createDefaultQueries: Exception: "+e.getMessage() );
        }
        return queries;
    }





    /**
     * Adds for every telosObject in the telosObjectSet one new node into the tree.
     *
     *@param cbUserObjs Collection of CBUserObjects
     *@param parent the node these new item will be children of
     */

    private void addItems(Collection cbUserObjs, DefaultMutableTreeNode parent) {

      assert cbUserObjs != null : "cbUserObjs must not be null";
        //java.util.logging.Logger.getLogger("global").fine("addItems: entered");
        parent.removeAllChildren();

        if (cbUserObjs.size() == 0) {
            i5.cb.graph.cbeditor.components.CBTree.EmptyResultNode noObjFoundNode = new i5.cb.graph.cbeditor.components.CBTree.EmptyResultNode();
            parent.add(noObjFoundNode);
            m_treeModel.reload();
            return;
        }

        Iterator itUOs = cbUserObjs.iterator();

        CBUserObject currentUO;

        CBUserObjectNode newCbUONode;


        while (itUOs.hasNext()) {
            currentUO = (CBUserObject)itUOs.next();

            newCbUONode = new CBUserObjectNode( currentUO);


            parent.add(newCbUONode);
        }
        m_treeModel.reload();

    }//addItems


    private void addItems(ITelosObjectSet tos, AttribCatNode parent) {


        QueryNode newQueryNode;

        TelosObject toAttrCat;
        CBQuery newQuery;
        LabelNode newLabelNode;
        parent.removeAllChildren();

        if (tos==null || tos.size() == 0) {
            i5.cb.graph.cbeditor.components.CBTree.EmptyResultNode noObjFoundNode = new i5.cb.graph.cbeditor.components.CBTree.EmptyResultNode();
            parent.add(noObjFoundNode);
            m_treeModel.reload();
            return;
        }

        ResourceBundle bundle = m_cbFrame.getCBEditor().getCBBundle();

        Enumeration sTos = tos.sortedElements();
        while(sTos.hasMoreElements() ) {

            toAttrCat = (TelosObject)sTos.nextElement();


            newLabelNode = new LabelNode(toAttrCat.getLabel() );
            parent.add(newLabelNode);
            try {
                if(parent.getInOrOut() == AttribCatNode.INCOMING) {
                    newQuery = new CBQuery("find_referring_objects2["+m_cbUO.toString()+"/objname,"+ toAttrCat.toString() + "/cat]",
                                           m_cbFrame, m_cbUO.getTelosObject(), "Attribute", "dst",toAttrCat);
                    newQueryNode = new QueryNode(newQuery, bundle.getString("queryResult_Explicit"));
                    newLabelNode.add(newQueryNode);
                    newQueryNode.add(new WaitNode() );

                    if (CBConfiguration.getEnableDerivedLinks()) {
                       newQuery = new CBQuery("find_all_referring_objects2["+m_cbUO.toString()+"/objname,"+ toAttrCat.toString() + "/cat]",
                                           m_cbFrame, m_cbUO.getTelosObject(), toAttrCat.toString(), "dst",toAttrCat);
                       newQueryNode = new QueryNode(newQuery, bundle.getString("queryResult_All") );
                       newLabelNode.add(newQueryNode);
                       newQueryNode.add(new WaitNode() );
                    }

                }
                else {
                    newQuery = new CBQuery("find_explicit_attribute_values["+m_cbUO.toString()+"/objname,"+ toAttrCat.toString() + "/cat]",
                                           m_cbFrame, m_cbUO.getTelosObject(), "Attribute", "src",toAttrCat);
                    newQueryNode = new QueryNode(newQuery, bundle.getString("queryResult_Explicit"));
                    newLabelNode.add(newQueryNode);
                    newQueryNode.add(new WaitNode() );

                    if (CBConfiguration.getEnableDerivedLinks()) {
                       newQuery = new CBQuery("find_attribute_values["+m_cbUO.toString()+"/objname,"+ toAttrCat.toString() + "/cat]",
                                           m_cbFrame, m_cbUO.getTelosObject(), toAttrCat.toString(), "src",toAttrCat);
                       newQueryNode = new QueryNode(newQuery, bundle.getString("queryResult_All"));
                       newLabelNode.add(newQueryNode);
                       newQueryNode.add(new WaitNode() );
                    }
                }
            }
            catch(Exception e) {
                java.util.logging.Logger.getLogger("global").fine("CBTree.createDefaultQueries: Exception: "+e.getMessage() );
            }

        }
        m_treeModel.reload();
    }

    /**
     * Returns the telosobjects from the selected treenodes.
     *
     * A classCastException is thrown if not all selected nodes have a TelosObject as userObject.
     * @return a Collection of selected CBUserObjects
     */

    Collection getSelected() {

        TreePath[] selectionPaths = getSelectionPaths();

        DefaultMutableTreeNode currentNode;
        CBUserObject currentUO;

        Vector uos = new Vector();

        for(int i=0; i< selectionPaths.length; i++) {
            currentNode = (DefaultMutableTreeNode)selectionPaths[i].getLastPathComponent();
            currentUO = (CBUserObject)currentNode.getUserObject();
            uos.add(currentUO);
        }
        return uos;
    }//getSelected




    private class CBTreeWillExpandListener implements TreeWillExpandListener {


        /** Is called <I>before</I> the tree will expand
         *
         *
         * @param e  Description of the Parameter
         */
        public void treeWillExpand(TreeExpansionEvent e) {

            TreePath path = e.getPath();

            DefaultMutableTreeNode expandedNode = (DefaultMutableTreeNode)path.getLastPathComponent();

            if(expandedNode instanceof QueryNode) {
                if( !((QueryNode)expandedNode).isHasBeenProcessed() ) {
                    ((QueryNode)expandedNode).setHasBeenProcessed(true);
                    processNode(expandedNode);
                }
            }
            if(expandedNode instanceof AttribCatNode) {
                if( !((AttribCatNode)expandedNode).isHasBeenProcessed() ) {
                    ((AttribCatNode)expandedNode).setHasBeenProcessed(true);
                    processNode(expandedNode);
                }
            }

        }//treeWillExpand


        /** Is invoked <I>before</I> the tree will collapse

         *
         * @param e  Description of the Parameter
         */

        public void treeWillCollapse(TreeExpansionEvent e) {

            //CBTree.this.repaint();
        }

        private void processNode(DefaultMutableTreeNode node) {
            //Thread thread = new  ProcessNodeThread(node);
            //thread.start();
            processNode2(node);
        }

        private void processNode2(DefaultMutableTreeNode node) {
            //CBTree.this.setCursor(new Cursor(Cursor.WAIT_CURSOR) );
            //java.util.logging.Logger.getLogger("global").fine("processNode2: started; node: "+node);
            if(node instanceof QueryNode) {
                CBQuery cbQuery = ((QueryNode)node).getQuery();
                //java.util.logging.Logger.getLogger("global").fine("processNode2: getQuery() done");
                addItems(cbQuery.ask(), (QueryNode)node);

            }
            if(node instanceof AttribCatNode) {

                addItems( ((AttribCatNode)node).askCategories(), (AttribCatNode)node);
            }
            //java.util.logging.Logger.getLogger("global").fine("processNode2: finished");
            //CBTree.this.setCursor(new Cursor(Cursor.DEFAULT_CURSOR) );
        }

 
    }//CBTreeWillExpandListener



    /** This node contains a {@link i5.cb.graph.cbeditor.CBQuery} beside its label
     */
    public class QueryNode extends LabelNode {

        private CBQuery m_query;

        /** Holds value of property hasBeenProcessed. */
        private boolean m_hasBeenProcessed;

        private QueryNode(CBQuery query, String sLabel) {
            super(sLabel);
            m_query = query;
        }

        public CBQuery getQuery() {
            return m_query;
        }

        /** Getter for property hasBeenProcessed.
         * @return true if this node already has been processed (i.e. if its query has been
         * asked and the result has been added as its children), false otherwise.
         */
        public boolean isHasBeenProcessed() {
            return this.m_hasBeenProcessed;
        }

        /** Setter for property hasBeenProcessed.
         * @param hasBeenProcessed New value of property hasBeenProcessed.
         */
        public void setHasBeenProcessed(boolean hasBeenProcessed) {
            this.m_hasBeenProcessed = hasBeenProcessed;
        }

    }

    private class LabelNode extends DefaultMutableTreeNode {

        private LabelNode(String sLabel) {
            super(sLabel);
        }

    }


    /** This node contains no CBQuery but a String which is used as param when calling
     * {@link i5.cb.telos.object.ObjectBaseInterface#askObj}
     */
    public class AttribCatNode extends DefaultMutableTreeNode {

        private static final int OUTGOING = 1;
        private static final int INCOMING = 2;

        String m_sAskString;

        /** Holds value of property hasBeenProcessed. */
        private boolean m_hasBeenProcessed;

        int m_iInOrOut;

        private AttribCatNode(String sLabel, String sAskString, int iInOrOut) {
            super(sLabel);
            m_sAskString = sAskString;
            m_iInOrOut = iInOrOut;
        }

        private ITelosObjectSet askCategories() {

            if(m_cbFrame.isConnected())
                return m_cbFrame.getObi().askObjname(m_sAskString);
            else
                return null;
        }

        private int getInOrOut() {
            return m_iInOrOut;
        }

        /** Getter for property hasBeenProcessed.
         * @return true if this node already has been processed (i.e. if
         * objectbaseInterface.askObj has been called  and the result has been
         * added as its children), false otherwise.
         */
        public boolean isHasBeenProcessed() {
            return this.m_hasBeenProcessed;
        }

        /** Setter for property hasBeenProcessed.
         * @param hasBeenProcessed New value of property hasBeenProcessed.
         */
        public void setHasBeenProcessed(boolean hasBeenProcessed) {
            this.m_hasBeenProcessed = hasBeenProcessed;
        }

    }

    /** Contains a CBUserObject that was created as a result of a CBQuery
     * Therefore these node are always leafs
     */
    public class CBUserObjectNode extends DefaultMutableTreeNode {
        private CBUserObjectNode(CBUserObject uo) {
            super(uo);
        }

    }

    /** This result is added to a CBQueryNode if the query's result was empty.
     * It contains a label telling that there is no result
     */
    public class EmptyResultNode extends LabelNode {

        private EmptyResultNode() {
            super(m_cbFrame.getCBEditor().getCBBundle().getString("queryResult_NoObjects"));
        }

    }


    /** this node is used as child of a QueryNode or an AttribCatNode <I>before</I>
     * it has been processed. It is replaced by the query's results
     */
    public class WaitNode extends LabelNode {

        private WaitNode() {
            super( m_cbFrame.getCBEditor().getCBBundle().getString("query_Wait") );
        }

    }

}//CBTree

