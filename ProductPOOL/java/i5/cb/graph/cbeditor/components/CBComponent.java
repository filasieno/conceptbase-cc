/*
The ConceptBase.cc Copyright

Copyright 1987-2023 The ConceptBase Team. All rights reserved.

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

import i5.cb.graph.cbeditor.CBDiagramClass;
import i5.cb.graph.cbeditor.CBUserObject;
import i5.cb.graph.diagram.DiagramNode;
import i5.cb.telos.object.TelosObject;

import java.awt.*;

import javax.swing.*;

/**
*  This is the Component returned by the {@link CBDiagramClass}. It mainly
* contains a {@link CBTree} instance that shows some very commin queries as
* it's branches. The leafs are the telosObjects the CBserver found when asked
* the queries. There will also be a possibily to add more queries to the tree
 *
 *@author     Schoeneb
 *@created    11. M?rz 2002
 */
public class CBComponent extends JPanel {

    /**
    * The userobject of this component's {@link i5.cb.graph.diagram.DiagramObject}.
    */
    CBUserObject m_userObject;

    /**
    * The tree which is shown in the component
    */
    CBTree m_cbTree;

    DiagramNode m_diagNode;

    /**
    * A button triggering various actions depending on what kind of item in
    * the tree is selected.
    */
    JButton m_actionButton;

    /**
     *  Constructor for the CBComponent object
     *
     *@param diagNode the DiagramNode this component belongs to
     *
     *@param  uo the Userobject can't be extraced from the diagObj because it
     * is not yet necessarily set when this constructor is called
     */
    public CBComponent(DiagramNode diagNode, CBUserObject uo) {

        m_userObject = uo;
        m_diagNode = diagNode;
        TelosObject to = uo.getTelosObject();

        JLabel jlTitle = new JLabel(" "+to.getSystemClassName()+" "+to.toString() );

        i5.cb.graph.GraphMenu menu=m_userObject.getCBFrame().getGraphEditor().getGraphMenuBar().getOptionsMenu().getSubMenuByKeyWord("GMB_OptionsMenu_CBComponent");
        boolean bShowTree=menu.getItem(0).isSelected();

        JScrollPane compView=null;
        if(bShowTree) {
            m_cbTree = uo.getQueryTree();
            CBComponentCommand cbcCommand = new CBComponentCommand(this, CBComponentCommand.SHOWBUTTON);
            m_cbTree.addTreeSelectionListener(cbcCommand);

            setBorder(BorderFactory.createCompoundBorder(
                      BorderFactory.createEtchedBorder(),
                      BorderFactory.createEmptyBorder(10,10,10,10)
                  ) );

            compView = new JScrollPane(m_cbTree);
            compView.setBorder(BorderFactory.createEmptyBorder(0,0,10,0) );

            m_actionButton = new JButton("Show");
            m_actionButton.addActionListener(cbcCommand);
            m_actionButton.setEnabled(false);
        }
        else {
            JTextArea jtaObject=new JTextArea(5,40);
            jtaObject.setEditable(false);
	    try {
                jtaObject.setText(m_userObject.getObi().getCBClient().getObject(m_userObject.getTelosObject().toString()));
                jtaObject.setCaretPosition(0);
            }
            catch(Exception e) {
                JOptionPane.showMessageDialog(m_userObject.getCBFrame().getCBEditor(),"Exception while accessing ConceptBase","Exception",JOptionPane.ERROR_MESSAGE);
                jtaObject.setText("ERROR");
            }
            compView=new JScrollPane(jtaObject);
        }

        GridBagLayout gridBagL = new GridBagLayout();
        GridBagConstraints gbConstr = new GridBagConstraints();
        setLayout(gridBagL);

        gbConstr.gridwidth = 2;
        gbConstr.gridx = 0;
        gbConstr.gridy = 0;
        gbConstr.insets = new Insets(0,0,10,0);
        gbConstr.fill = GridBagConstraints.BOTH;
        gbConstr.weightx = 1;
        gridBagL.setConstraints(jlTitle, gbConstr);
        this.add(jlTitle);

        gbConstr = new GridBagConstraints();
        gbConstr.gridx = 0;
        gbConstr.gridy = 1;
        gbConstr.fill = GridBagConstraints.BOTH;
        gbConstr.weightx = 1;
        gbConstr.weighty = 1;
        gbConstr.gridwidth = 2;
        gridBagL.setConstraints(compView, gbConstr);
        this.add(compView);

        if(bShowTree) {
            gbConstr.gridx = 0;
            gbConstr.gridy = 2;
            gbConstr.fill = GridBagConstraints.NONE;
            gbConstr.weightx = 1;
            gbConstr.weighty = 0;
            gbConstr.gridwidth = 2;
            gridBagL.setConstraints(m_actionButton, gbConstr);
            this.add(m_actionButton);
        }

        this.setPreferredSize(new Dimension(220, 150));
        this.setSize(220, 150);
        this.setVisible(true);
    }

    /**
    * Returns the first seleted item's telosobject from the tree
    *
    *@return null if no or more than one item is selected or the item's TelosObject else.
    */
    /*
       TelosObject getSelectedItem(){
     try{
      return m_cbTree.getSelected().getTheOnlyMember();
     }catch(Exception e){
      //java.util.logging.Logger.getLogger("global").fine("CBComponent.getSelectedItem: more than one Item was selected!");
     }
     return null;
    }
    */
}//CBComponent
