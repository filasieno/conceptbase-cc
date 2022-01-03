/*
The ConceptBase.cc Copyright

Copyright 1987-2022 The ConceptBase Team. All rights reserved.

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
package i5.cb.graph.cbeditor.components;

import i5.cb.graph.cbeditor.CBUtil;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Collection;

import javax.swing.event.TreeSelectionEvent;
import javax.swing.event.TreeSelectionListener;
import javax.swing.tree.TreePath;
import javax.swing.tree.TreeSelectionModel;

/**
* Does the work for CBCommand.
*/
class CBComponentCommand
    implements ActionListener, TreeSelectionListener {

    final static int SHOWBUTTON = 1;
    final static int ADDQUERYBUTTON = 2;
    final static int SELECTED = 3;

    CBComponent m_parent;

    int m_iActionID;

    CBComponentCommand(CBComponent parent, int iActionID) {
        m_iActionID = iActionID;
        m_parent = parent;
    }


    /** invoked when an action is performed in the CBComponent
     * @param ae An ActionEvent
     */
    public void actionPerformed(ActionEvent ae) {
        switch(m_iActionID) {
            case SHOWBUTTON:


                Collection uoc = m_parent.m_cbTree.getSelected();


                CBUtil.createAndAddNewDiagramObjects(uoc
                                                     , m_parent.m_userObject.getCBFrame(),
                                                     m_parent.m_diagNode);
                break;
            case ADDQUERYBUTTON:
                javax.swing.JOptionPane.showMessageDialog(m_parent, "Sorry, not yet implemented");
        }//switch
    }//actionPerformed

    /**
         * Prevents nodes with children and dummynodes from beeing selected; Also sets the CBComponent's
         * m_actionButton's text and action
         * @param e a TReeselectionEvent
         */
    public void valueChanged(TreeSelectionEvent e) {
        TreeSelectionModel selectionModel = m_parent.m_cbTree.getSelectionModel();
        TreePath[] paths = e.getPaths();
        if(e.isAddedPath() ) {
            //only ordinary DefaultMutableTreeNode (i.e. non MainTreeNodes) shall be selectable
            for(int i=0; i<paths.length; i++) {
                if (!(paths[i].getLastPathComponent() instanceof CBTree.CBUserObjectNode) ) {
                    selectionModel.removeSelectionPath(paths[i]);
                }
            }
        }
        //If we removed all selections, we disalbe the button and return
        if(0 == selectionModel.getSelectionCount() ) {
            m_parent.m_actionButton.setEnabled(false);
            m_parent.repaint();
            return;
        }
        else {
            m_parent.m_actionButton.setEnabled(true);
        }
        //Now we check if the selection consists of only one node which is a query.
        //If that's the case we change the button's label to "Add query" and the action id
        //to adding the new query
        /*
                      * This is not used as currently no new queries are added
                       Object[] nodesInPath = e.getPath().getPath();
        if ( 1 == selectionModel.getSelectionCount() 
                        && ( (CBQuery)( (DefaultMutableTreeNode)nodesInPath[1]
                           ).getUserObject() ).toString().equals("Available Queries")
           ){
         m_parent.m_actionButton.setText("Add this query");
         m_iActionID = ADDQUERYBUTTON;
           }else{
         m_parent.m_actionButton.setText("Show");
         m_iActionID = SHOWBUTTON;
        }
        */
        m_parent.repaint();
    }//valueChanged

}//CBComponentCommand


