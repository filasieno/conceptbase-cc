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

import i5.cb.graph.diagram.DiagramClassHashtableEntry;
import i5.cb.telos.object.TelosLink;

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;

import javax.swing.*;

/**
 * Select objects to undo creation/deletion from object base
 */

public class SelectObjectsDialog extends JInternalFrame implements ActionListener, PropertyChangeListener{

  private CBFrame cbFrame;
  private JList ObjectsToAdd;
  private JList ObjectstoErase;
  JLabel jLabel1 = new JLabel();
  JLabel jLabel2 = new JLabel();
  JList jList1 = new JList();

  public SelectObjectsDialog(CBFrame f) {
    super(f.getBundle().getString("SelectObjectsDialog_Heading"),false,false,false,false);
    cbFrame = f;
    ObjectsToAdd = new JList(f.getObjectsToAdd().toArray());
    ObjectstoErase =new JList (f.getObjectsToErase().toArray());

    GridBagLayout gbl=new GridBagLayout();
    getContentPane().setLayout(gbl);
    GridBagConstraints gbc=new GridBagConstraints();

    gbc.fill=GridBagConstraints.BOTH;
    JLabel jlToAdd=new JLabel(cbFrame.getBundle().getString("SelectObjectsDialog_Added"));
    gbc.gridwidth=1;
    gbc.weightx=1;
    gbl.setConstraints(jlToAdd,gbc);
    getContentPane().add(jlToAdd);

    JSeparator sep=new JSeparator();
    gbl.setConstraints(sep,gbc);
    getContentPane().add(sep);

    JLabel jlToErase=new JLabel(cbFrame.getBundle().getString("SelectObjectsDialog_Removed"));
    gbc.weightx=1;
    gbc.gridwidth=GridBagConstraints.REMAINDER;
    gbl.setConstraints(jlToErase,gbc);
    getContentPane().add(jlToErase);

    JScrollPane scrollPaneAdd = new JScrollPane(ObjectsToAdd);
    gbc.weightx=1.0;
    gbc.weighty=1.0;
    gbc.gridwidth=1;
    gbc.gridheight=4;
    gbl.setConstraints(scrollPaneAdd,gbc);
    getContentPane().add(scrollPaneAdd);

    JScrollPane scrollPaneErase = new JScrollPane(ObjectstoErase);
    gbc.weightx=1.0;
    gbc.gridwidth=GridBagConstraints.REMAINDER;
    gbl.setConstraints(scrollPaneErase,gbc);
    getContentPane().add(scrollPaneErase);

    JButton jbRemoveAdd=new JButton(cbFrame.getBundle().getString("SelectObjectsDialog_Commit"));
    jbRemoveAdd.setActionCommand("RemoveAdd");
    jbRemoveAdd.addActionListener(this);
    gbc.weighty=0.0;
    gbc.gridwidth=1;
    gbl.setConstraints(jbRemoveAdd,gbc);
    getContentPane().add(jbRemoveAdd);

    JButton jbCancel=new JButton(cbFrame.getBundle().getString("SelectObjectsDialog_Close"));
    jbCancel.setActionCommand("Cancel");
    jbCancel.addActionListener(this);
    gbc.gridwidth=GridBagConstraints.REMAINDER;
    gbl.setConstraints(jbCancel,gbc);
    getContentPane().add(jbCancel);

    setPreferredSize(new Dimension(300,250));
    setSize(300,250);
    cbFrame.addPropertyChangeListener("update",this);
  }
  public void actionPerformed(ActionEvent e) {
        if(e.getActionCommand() != null && e.getActionCommand().equals("Cancel"))
          {
              closeDialog();
              return;
          }
        if(e.getActionCommand() != null && e.getActionCommand().equals("RemoveAdd"))
          {
              DiagramClassHashtableEntry currentDiagHashObject;
              Object selectObj[] = ObjectsToAdd.getSelectedValues();
              //erase all objects from the diagramdesktop that were selected in the list
              for(int i=0;i<selectObj.length;i++) {
                  currentDiagHashObject = (DiagramClassHashtableEntry)selectObj[i];
                  cbFrame.removeObjectToAdd(currentDiagHashObject);
                  cbFrame.getCBEditor().removeNode(currentDiagHashObject.getDiagramNode(),cbFrame);
              }
              selectObj=ObjectstoErase.getSelectedValues();

              //first loop over selected objects and create Individuals
              for(int j =0; j < selectObj.length; j++){
                  currentDiagHashObject = (DiagramClassHashtableEntry)selectObj[j];
                  CBUserObject currentUo = (CBUserObject)(currentDiagHashObject.getDiagramNode().getUserObject());
                  if(!(currentUo.getTelosObject() instanceof TelosLink )){
                      //remove the object from the EraseList and read it to the DiagramDesktop
                      cbFrame.removeObjectFromWasteBasket(currentDiagHashObject);
                      cbFrame.getDiagramDesktop().add(currentDiagHashObject.getDiagramNode());
                  }
              }
              //now loop again, but here we add the missing edges
              for(int j =0; j < selectObj.length; j++){
                  currentDiagHashObject = (DiagramClassHashtableEntry)selectObj[j];
                  CBUserObject currentUo = (CBUserObject)(currentDiagHashObject.getDiagramNode().getUserObject());
                  if(currentUo.getTelosObject() instanceof TelosLink) {
                      //remove the object from the EraseList and read it to the DiagramDesktop
                      cbFrame.removeObjectFromWasteBasket(currentDiagHashObject);
                      cbFrame.getDiagramDesktop().add(currentDiagHashObject.getDiagramNode().getDiagramEdge());
                      cbFrame.getDiagramDesktop().add(currentDiagHashObject.getDiagramNode());
                  }
              }
              //refresh the lists
              ObjectsToAdd.setListData(cbFrame.getObjectsToAdd().toArray());
              ObjectstoErase.setListData(cbFrame.getObjectsToErase().toArray());
              return;
          }
  }
  private void closeDialog() {
        cbFrame.updateToolbar();
        this.setVisible(false);
        dispose();
        try
        {
                cbFrame.setSelected(true);
        }
        catch(java.beans.PropertyVetoException e)
        {
        }
  }
  public void propertyChange(PropertyChangeEvent evt) {
        if(!isVisible())
                return;
        ObjectsToAdd.setListData(cbFrame.getObjectsToAdd().toArray());
        ObjectstoErase.setListData(cbFrame.getObjectsToErase().toArray());

  }
}
