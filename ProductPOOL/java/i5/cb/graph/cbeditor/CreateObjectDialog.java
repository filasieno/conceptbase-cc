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
package i5.cb.graph.cbeditor;

import i5.cb.graph.GEConstants;
import i5.cb.graph.diagram.*;
import i5.cb.telos.frame.ObjectName;
import i5.cb.telos.frame.ObjectNames;
import i5.cb.telos.object.*;

import java.awt.*;
import java.awt.event.*;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.util.*;

import javax.swing.*;
import javax.swing.event.PopupMenuEvent;

/**
 * <p>Title: </p>
 * <p>Description: </p>
 * <p>Copyright: Copyright (c) 2002</p>
 * <p>Company: </p>
 * @author unascribed
 * @version 1.0
 */

public class CreateObjectDialog
    extends JInternalFrame
    implements ActionListener, PropertyChangeListener, FocusListener {

    private CBFrame cbFrame;
    private JTextField jtfObject;
    private JTextField jtfLabel;
    private JTextField jtfBaseClass;
    private JTextField jtfAttributeValue;
    private JTextField jtfAttributeCategory;
    private JComboBox jcbGraphTypes;
    private int iType;
    private JTextField jtfCurrent;
    private JRadioButton jrbShowAttrInst;

    public CreateObjectDialog(int iType, CBFrame f) {
        super("Create Object", false, false, false, false);
        cbFrame = f;
        this.iType = iType;

        if (iType == TelosObject.ATTRIBUTE) {
            setTitle(getTitle()+": Attribute");
            GridBagLayout gbl = new GridBagLayout();
            getContentPane().setLayout(gbl);
            GridBagConstraints gbc = new GridBagConstraints();

            gbc.fill = GridBagConstraints.BOTH;
            gbc.weightx = 1.0;
            gbc.gridwidth = 3;
            gbc.insets = new Insets(5, 5, 0, 0);
            jtfObject = new JTextField("Source", 50);
            jtfObject.addFocusListener(this);
            gbl.setConstraints(jtfObject, gbc);
            getContentPane().add(jtfObject);

            jtfLabel = new JTextField("label", 40);
            jtfLabel.addFocusListener(this);
            gbc.gridwidth = 2;
            gbc.weightx = 0.6;
            gbc.insets = new Insets(5, 5, 0, 0);
            gbl.setConstraints(jtfLabel, gbc);
            getContentPane().add(jtfLabel);

            jtfAttributeValue = new JTextField("Destination", 50);
            jtfAttributeValue.addFocusListener(this);
            jtfAttributeValue.setEditable(true);
            gbc.weightx = 1.0;
            gbc.gridwidth = 3;
            gbl.setConstraints(jtfAttributeValue, gbc);
            getContentPane().add(jtfAttributeValue);

            JButton jbSelectAttrValue =
                new JButton(
                    cbFrame.getBundle().getString("CreateObjectDialog_Select"));
            jbSelectAttrValue.setActionCommand("SelectAttrValue");
            jbSelectAttrValue.addActionListener(this);
            gbc.weightx = 0.1;
            gbc.gridwidth = GridBagConstraints.REMAINDER;
            gbc.insets = new Insets(5, 0, 0, 5);
            gbl.setConstraints(jbSelectAttrValue, gbc);
            getContentPane().add(jbSelectAttrValue);

            gbc.weightx = 0.1;
            gbc.gridwidth = 3;
            gbc.insets = new Insets(5, 5, 0, 5);
            JLabel jlAttrClass = new JLabel("Attr. Class:");
            gbc.fill = GridBagConstraints.BOTH;
            gbl.setConstraints(jlAttrClass, gbc);
            getContentPane().add(jlAttrClass);

            jtfAttributeCategory = new JTextField("", 50);
            jtfAttributeCategory.addFocusListener(this);
            jtfAttributeCategory.setEditable(true);
            gbc.weightx = 1.0;
            gbc.insets = new Insets(5, 5, 0, 0);
            gbc.gridwidth = 5;
            gbl.setConstraints(jtfAttributeCategory, gbc);
            getContentPane().add(jtfAttributeCategory);

            JButton jbSelectAttrCat =new JButton(cbFrame.getBundle().getString("CreateObjectDialog_Select"));
            jbSelectAttrCat.setActionCommand("SelectAttrCat");
            jbSelectAttrCat.addActionListener(this);
            gbc.weightx = 0.1;
            gbc.gridwidth = GridBagConstraints.REMAINDER;
            gbc.insets = new Insets(5, 0, 0, 5);
            gbl.setConstraints(jbSelectAttrCat, gbc);
            getContentPane().add(jbSelectAttrCat);

            jrbShowAttrInst=new JRadioButton("Show Attribute Instantiation",false);
            gbc.weightx = 0.1;
            gbc.gridwidth = GridBagConstraints.REMAINDER;
            gbc.insets = new Insets(5, 0, 0, 5);
            gbl.setConstraints(jrbShowAttrInst, gbc);
            getContentPane().add(jrbShowAttrInst);

            JButton jbOk =new JButton(cbFrame.getBundle().getString("CreateObjectDialog_OK"));
            jbOk.addActionListener(this);
            gbc.gridwidth = 6;
            gbc.insets = new Insets(10, 30, 3, 10);
            gbl.setConstraints(jbOk, gbc);
            getContentPane().add(jbOk);

            JButton jbCancel =new JButton(cbFrame.getBundle().getString("CreateObjectDialog_Cancel"));
            jbCancel.setActionCommand("Cancel");
            jbCancel.addActionListener(this);
            gbc.gridwidth = GridBagConstraints.REMAINDER;
            gbc.insets = new Insets(10, 10, 3, 30);
            gbl.setConstraints(jbCancel, gbc);
            getContentPane().add(jbCancel);
            setPreferredSize(new Dimension(400, 150));
            setSize(400, 170);
        }

        if (iType == TelosObject.INDIVIDUAL) {
            setTitle(getTitle()+": Individual");
            GridBagLayout gbl = new GridBagLayout();
            getContentPane().setLayout(gbl);
            GridBagConstraints gbc = new GridBagConstraints();

            gbc.weightx = 0.0;
            gbc.insets = new Insets(0, 5, 0, 5);
            JLabel jlWith = new JLabel("Name:");
            gbc.fill = GridBagConstraints.BOTH;
            gbl.setConstraints(jlWith, gbc);
            getContentPane().add(jlWith);

            gbc.weightx = 1.0;
            gbc.gridwidth = GridBagConstraints.REMAINDER;
            gbc.fill = GridBagConstraints.HORIZONTAL;
            jtfObject = new JTextField("ObjectName", 50);
            jtfObject.addFocusListener(this);
            gbl.setConstraints(jtfObject, gbc);
            getContentPane().add(jtfObject);

            gbc.weightx = 0.0;
            JLabel jlGrType = new JLabel("GraphType:");
            gbc.gridwidth = 1;
            gbc.fill = GridBagConstraints.BOTH;
            gbl.setConstraints(jlGrType, gbc);
            getContentPane().add(jlGrType);
            gbc.weightx = 1.0;
            jcbGraphTypes = new JComboBox();
            jcbGraphTypes.setEditable(false);
            fillGraphTypes();
            gbc.gridwidth = GridBagConstraints.REMAINDER;
            gbl.setConstraints(jcbGraphTypes, gbc);
            getContentPane().add(jcbGraphTypes);

            JButton jbOk =
                new JButton(
                    cbFrame.getBundle().getString("CreateObjectDialog_OK"));
            jbOk.addActionListener(this);
            gbc.gridwidth = GridBagConstraints.RELATIVE;
            gbc.fill = GridBagConstraints.BOTH;
            gbc.weightx = 0.0;
            gbc.insets = new Insets(10, 30, 3, 0);
            gbl.setConstraints(jbOk, gbc);
            getContentPane().add(jbOk);

            JButton jbCancel =
                new JButton(
                    cbFrame.getBundle().getString("CreateObjectDialog_Cancel"));
            jbCancel.setActionCommand("Cancel");
            jbCancel.addActionListener(this);
            gbc.gridwidth = GridBagConstraints.REMAINDER;
            gbc.insets = new Insets(10, 0, 3, 30);
            gbl.setConstraints(jbCancel, gbc);
            getContentPane().add(jbCancel);
            setPreferredSize(new Dimension(250, 150));
            setSize(250, 150);

        }
        if (iType == TelosObject.INSTANTIATION
            || iType == TelosObject.SPECIALIZATION) {
            GridBagLayout gbl = new GridBagLayout();
            getContentPane().setLayout(gbl);
            GridBagConstraints gbc = new GridBagConstraints();

            gbc.fill = GridBagConstraints.BOTH;
            gbc.weightx = 1.0;
            gbc.gridwidth = 3;
            gbc.insets = new Insets(0, 5, 0, 5);
            jtfObject = new JTextField("ObjectName", 50);
            jtfObject.addFocusListener(this);
            gbl.setConstraints(jtfObject, gbc);
            getContentPane().add(jtfObject);

            gbc.weightx = 0.0;
            JLabel jlWith = null;
            if (iType == TelosObject.INSTANTIATION) {
                setTitle(getTitle()+": Instantiation");
                jlWith = new JLabel("in");
            }
            else {
                setTitle(getTitle()+": Specialization");
                jlWith = new JLabel("isA");
            }
            gbc.gridwidth = GridBagConstraints.REMAINDER;
            gbl.setConstraints(jlWith, gbc);
            getContentPane().add(jlWith);

            gbc.weightx = 1.0;
            gbc.gridwidth = GridBagConstraints.REMAINDER;
            gbc.fill = GridBagConstraints.HORIZONTAL;
            jtfBaseClass = new JTextField("Class", 50);
            jtfBaseClass.addFocusListener(this);
            gbl.setConstraints(jtfBaseClass, gbc);
            getContentPane().add(jtfBaseClass);

            JButton jbOk=new JButton(cbFrame.getBundle().getString("CreateObjectDialog_OK"));
            jbOk.addActionListener(this);
            gbc.gridwidth = GridBagConstraints.RELATIVE;
            gbc.fill = GridBagConstraints.BOTH;
            gbc.weightx = 1.0;
            gbc.insets = new Insets(10, 30, 3, 0);
            gbl.setConstraints(jbOk, gbc);
            getContentPane().add(jbOk);

            JButton jbCancel =new JButton(cbFrame.getBundle().getString("CreateObjectDialog_Cancel"));
            jbCancel.setActionCommand("Cancel");
            jbCancel.addActionListener(this);
            gbc.gridwidth = GridBagConstraints.REMAINDER;
            gbc.insets = new Insets(10, 0, 3, 30);
            gbl.setConstraints(jbCancel, gbc);
            getContentPane().add(jbCancel);
            setPreferredSize(new Dimension(220, 180));
            setSize(220, 180);
        }
        cbFrame.getDiagramDesktop().addPropertyChangeListener("selected", this);
        handleSelectedNodes(cbFrame.getDiagramDesktop().getSelectedNodes());
    }

    public void propertyChange(PropertyChangeEvent evt) {
        if (!isVisible())
            return;
        Collection c = (Collection) evt.getNewValue();
        handleSelectedNodes(c);
    }

    private void handleSelectedNodes(Collection c) {
        Iterator itSelectedNodes = c.iterator();
        if (c.size() == 1 && jtfCurrent != null) {
            DiagramNode dn = (DiagramNode) itSelectedNodes.next();
            CBUserObject cbuo = (CBUserObject) dn.getUserObject();
            jtfCurrent.setText(cbuo.getTelosObject().toString());
            return;
        }
        if (c.size() > 0) {
            DiagramNode dn = (DiagramNode) itSelectedNodes.next();
            CBUserObject cbuo = (CBUserObject) dn.getUserObject();
            jtfObject.setText(cbuo.getTelosObject().toString());
        }
        if (iType == TelosObject.ATTRIBUTE) {
            if (c.size() > 1) {
                DiagramNode dn = (DiagramNode) itSelectedNodes.next();
                CBUserObject cbuo = (CBUserObject) dn.getUserObject();
                jtfAttributeValue.setText(cbuo.getTelosObject().toString());
            }
            if (c.size() > 2) {
                DiagramNode dn = (DiagramNode) itSelectedNodes.next();
                CBUserObject cbuo = (CBUserObject) dn.getUserObject();
                if (cbuo.getTelosObject() instanceof Attribute) {
                    jtfAttributeCategory.setText(
                        cbuo.getTelosObject().toString());
                }
            }
        }
        if ((iType == TelosObject.INSTANTIATION
            || iType == TelosObject.SPECIALIZATION)
            && c.size() > 1) {
            DiagramNode dn = (DiagramNode) itSelectedNodes.next();
            CBUserObject cbuo = (CBUserObject) dn.getUserObject();
            jtfBaseClass.setText(cbuo.getTelosObject().toString());
        }
    }

    public void popupMenuCanceled(PopupMenuEvent e) {
    }

    public void popupMenuWillBecomeInvisible(PopupMenuEvent e) {
    }

    /**
     * Creates and adds an Individual to the Conceptbase
     *
     */
    private DiagramObject createIndividual(String sObject, String sGraphType, boolean bAddToDD) {
        ObjectName on=CBUtil.parseObjectName(sObject);
        if(on==null) {
            JOptionPane.showMessageDialog(this,sObject + " is not a valid object name!","Syntax Error",JOptionPane.ERROR_MESSAGE);
            return null;
        }
        TelosObject newTo = TelosObject.getIndividual(sObject);
        HashMap dummyMap = new HashMap();
        dummyMap.put(newTo.toString(), sGraphType);
        //(String)cbFrame.getDefaultGraphTypes().get("Individual"));
        CBUserObject uo =
            CBUserObject.getCBUserObject(newTo, cbFrame, dummyMap);

        //CBUtil.createAndAddNewDiagramObject(uo, cbFrame, null);

        DiagramNode newDiagNode =
            new DiagramNode(uo, cbFrame.getDiagramClass());
        if (bAddToDD) {
            cbFrame.getDiagramDesktop().addDiagramNode(newDiagNode);
        }
        cbFrame.addObjectToAdd(newDiagNode.getDiagramClass().getHashtableEntry(uo));
        closeDialog();
        return newDiagNode;
    }

    private void createInstantiationOrSpecialization(
        String sSrc,
        String sDst) {
        TelosObject toEdge = null;
        DiagramObject doSrc = getDiagramObjectForString(sSrc, true);
        DiagramObject doDst = getDiagramObjectForString(sDst, true);
        if (doSrc == null || doDst == null)
            return;
        CBUserObject uoSrc = (CBUserObject) doSrc.getUserObject();
        CBUserObject uoDst = (CBUserObject) doDst.getUserObject();

        HashMap dummyMap = new HashMap();
        if (iType == TelosObject.INSTANTIATION) {
            toEdge = TelosObject.getInstantiation( uoSrc.getTelosObject(), uoDst.getTelosObject());
            String sGraphType = null;
            if (cbFrame.getPropertiesOfGraphicalTypes().containsKey("DefaultInstanceOfGT"))
                sGraphType = "DefaultInstanceOfGT";
            else
                sGraphType =(String) cbFrame.getDefaultGraphTypes().get("Link");
            dummyMap.put(toEdge.toString(), sGraphType);
        } else {
            toEdge =
                TelosObject.getSpecialization(
                    uoSrc.getTelosObject(),
                    uoDst.getTelosObject());
            String sGraphType = null;
            if (cbFrame.getPropertiesOfGraphicalTypes().containsKey("DefaultIsAGT"))
                sGraphType = "DefaultIsAGT";
            else
                sGraphType =(String) cbFrame.getDefaultGraphTypes().get("Link");
            dummyMap.put(toEdge.toString(), sGraphType);
        }
        CBUserObject uoEdge =
            CBUserObject.getCBUserObject(toEdge, cbFrame, dummyMap);

        DiagramNode dnOnEdge =
            new DiagramNode(uoEdge, cbFrame.getDiagramClass());
        DiagramEdge deNew =
            new DiagramEdge(dnOnEdge, doSrc, doDst, cbFrame.getDiagramClass());

        Vector vTmp = new Vector(1);
        vTmp.add(deNew);

        cbFrame.getDiagramDesktop().addDiagramEdges(
            vTmp,
            doDst.getNode(),
            i5.cb.graph.GEConstants.S_POSITION,
            true);
        //save TelosObjects for commiting to CB
        cbFrame.addObjectToAdd(deNew.getDiagramClass().getHashtableEntry(uoEdge));
        closeDialog();
    }

    private void createAttribute() {
        TelosObject toAttr = null;
        String sSrc = jtfObject.getText();
        String sDst = jtfAttributeValue.getText();
        String sAttrCat = jtfAttributeCategory.getText();
        DiagramObject doSrc = getDiagramObjectForString(sSrc, true);
        DiagramObject doDst = getDiagramObjectForString(sDst, true);
        if (doSrc == null || doDst == null) {
            closeDialog();
            return;
        }
        DiagramEdge deAttrCat = null;
        if (sAttrCat != null && sAttrCat.length() > 0) {
            DiagramObject doAttrCat=getDiagramObjectForString(sAttrCat, false);
            if(doAttrCat instanceof DiagramEdge)
                deAttrCat=(DiagramEdge) doAttrCat;
            else
                JOptionPane.showMessageDialog(this,"AttrCat is a object:" + sAttrCat);
        }

        CBUserObject uoSrc = (CBUserObject) doSrc.getUserObject();
        CBUserObject uoDst = (CBUserObject) doDst.getUserObject();

        toAttr=TelosObject.getAttribute(uoSrc.getTelosObject(),jtfLabel.getText(),uoDst.getTelosObject());
        HashMap dummyMap = new HashMap();
        String sGraphType = null;
        if (cbFrame.getPropertiesOfGraphicalTypes().containsKey("DefaultAttributeGT"))
            sGraphType = "DefaultAttributeGT";
        else
            sGraphType = (String) cbFrame.getDefaultGraphTypes().get("Link");
        dummyMap.put(toAttr.toString(), sGraphType);

        CBUserObject uoEdge =
            CBUserObject.getCBUserObject(toAttr, cbFrame, dummyMap);
        DiagramNode dnOnEdge =
            new DiagramNode(uoEdge, cbFrame.getDiagramClass());
        DiagramEdge deNew =
            new DiagramEdge(dnOnEdge, doSrc, doDst, cbFrame.getDiagramClass());

        cbFrame.getDiagramDesktop().addDiagramEdge(
            deNew,
            doDst.getNode(),
            GEConstants.E_POSITION);
        cbFrame.addObjectToAdd(dnOnEdge.getDiagramClass().getHashtableEntry(uoEdge));
        //handle attribute category
        if (deAttrCat != null) {
            CBUserObject uoAttrCat = (CBUserObject) deAttrCat.getUserObject();
            TelosObject toAttrInst =TelosObject.getInstantiation(toAttr, uoAttrCat.getTelosObject());
            dummyMap = new HashMap();

            if (cbFrame.getPropertiesOfGraphicalTypes().containsKey("DefaultInstanceOfGT"))
                sGraphType = "DefaultInstanceOfGT";
            else
                sGraphType=(String) cbFrame.getDefaultGraphTypes().get("Link");

            dummyMap.put(toAttrInst.toString(), sGraphType);
            CBUserObject uoAttrInst =CBUserObject.getCBUserObject(toAttrInst, cbFrame, dummyMap);
            DiagramNode dnOnAttrInst =new DiagramNode(uoAttrInst, cbFrame.getDiagramClass());
            DiagramEdge deAttrInst =new DiagramEdge(dnOnAttrInst,deNew,deAttrCat,cbFrame.getDiagramClass());
            if(jrbShowAttrInst.isSelected()) {
                cbFrame.getDiagramDesktop().addDiagramEdge(deAttrInst,dnOnEdge,GEConstants.N_POSITION);
            }
            cbFrame.addObjectToAdd(deAttrInst.getDiagramClass().getHashtableEntry(uoAttrInst));
        }
        closeDialog();
    }

    public void actionPerformed(ActionEvent e) {
        if (e.getActionCommand() != null
            && e.getActionCommand().equals("Cancel")) {
            closeDialog();
            return;
        }
        if (e.getActionCommand() != null
            && e.getActionCommand().equals("SelectAttrCat")) {
            selectAttrCat();
            return;
        }
        if (e.getActionCommand() != null
            && e.getActionCommand().equals("SelectAttrValue")) {
            selectAttrValue();
            return;
        }

        // OK Button
        if (iType == TelosObject.INDIVIDUAL) {
            createIndividual(jtfObject.getText(),jcbGraphTypes.getSelectedItem().toString(),true);
        } else if (iType == TelosObject.INSTANTIATION || iType == TelosObject.SPECIALIZATION) {
            createInstantiationOrSpecialization(jtfObject.getText(),jtfBaseClass.getText());
        } else if (iType == TelosObject.ATTRIBUTE) {
            createAttribute();
        } else {
            closeDialog();
        }
    }

    public void focusGained(FocusEvent e) {
        jtfCurrent = (JTextField) e.getSource();
    }

    public void focusLost(FocusEvent e) {
    }

    private void closeDialog() {
        this.setVisible(false);
        cbFrame.getDiagramDesktop().removePropertyChangeListener(
            "selected",
            this);
        dispose();
        try {
            cbFrame.setSelected(true);
        } catch (java.beans.PropertyVetoException e) {
        }
    }

    private void fillGraphTypes() {
        HashMap grTypes = cbFrame.getImplementingClasses();
        Iterator grTypesIt = grTypes.keySet().iterator();
        while (grTypesIt.hasNext()) {
            String currentType = (String) grTypesIt.next();
            jcbGraphTypes.addItem(currentType);
        }
        jcbGraphTypes.setSelectedItem(
            cbFrame.getDefaultGraphTypes().get("Individual"));
    }

    private void selectAttrValue() {
        String sAttrCat = jtfAttributeCategory.getText();
        TreeSet tsAttrValues = new TreeSet(i5.cb.graph.GEUtil.stringComparator);
        if (sAttrCat != null && sAttrCat.length() > 0) {
            ObjectName onAttrCat = CBUtil.parseObjectName(sAttrCat);
            if (onAttrCat != null) {
                TelosObject toAttrCat = null;
                try {
                    toAttrCat =
                        i5.cb.telos.Transform.toTelosObject(
                            onAttrCat,
                            cbFrame.getObi());
                } catch (i5.cb.CBException cbe) {
                    JOptionPane.showMessageDialog(
                        cbFrame.getCBEditor(),
                        cbe.getMessage(),
                        "Exception",
                        JOptionPane.ERROR_MESSAGE);
                }
                if (toAttrCat != null) {
                    ITelosObjectSet tosAttrValues =
                        cbFrame.getObi().getAllInstancesOf(
                            toAttrCat.getDestination());
                    java.util.Enumeration en = tosAttrValues.elements();
                    while (en.hasMoreElements())
                        tsAttrValues.add(en.nextElement());
                }
            }
        }
        if (tsAttrValues.isEmpty())
            JOptionPane.showMessageDialog(
                cbFrame.getCBEditor(),
                cbFrame.getBundle().getString("queryResult_NoObjects"));
        else {
            Object result =
                JOptionPane.showInputDialog(
                    cbFrame.getCBEditor(),
                    cbFrame.getBundle().getString(
                        "CreateObjectDialog_SelectAttrValue"),
                    "Attribute Value",
                    JOptionPane.QUESTION_MESSAGE,
                    null,
                    tsAttrValues.toArray(),
                    null);
            if (result != null) {
                jtfAttributeValue.setText(result.toString());
            }
        }
    }

    private void selectAttrCat() {
        String sObject=jtfObject.getText();
        Vector vAttrCats=new Vector();
        if(cbFrame.getObi().contains(TelosObject.getIndividual(sObject))) {
            String sAttrCats=cbFrame.getObi().ask("find_attribute_categories["+sObject+"/objname]","LABEL");
            ObjectNames onsAttrCats=CBUtil.parseObjectNames(sAttrCats);
            Enumeration en=onsAttrCats.elements();
            while(en.hasMoreElements()) {
                vAttrCats.add(en.nextElement().toString());
            }
        }
        Object result =JOptionPane.showInputDialog(cbFrame.getCBEditor(),
                cbFrame.getBundle().getString("CreateObjectDialog_SelectAttrCat"),
                "Attribute Class",
                JOptionPane.QUESTION_MESSAGE,
                null,
                vAttrCats.toArray(),
                null);
        if (result == null)
            return;
        else {
            jtfAttributeCategory.setText(result.toString());
            return;
        }
    }

    /**
           * Returns a DiagramObject with a label determined by the string-parameter.
           * If the DiagramObject is not found on the DiagramDesktop it is tried to create it
           * from an according Individual from the ConceptBase. If there is no such in the CB,
           * 'bCreate' determines wheter one should be added.
           * If a new DiagramObject has to be created it is not added to the DiagramDesktop.
           *
           * @param sObject the name (as shown on the label) of the diagramObject
           * @param bCreate tells if a new telosobject is to be scheduled for beeing told to the CB
           */
    private DiagramObject getDiagramObjectForString(String sObject,boolean bCreate) {
        CBUserObject uo = null;
        DiagramObject dObj = null;
        Vector diagNodes = cbFrame.getDiagramDesktop().getDiagramNodes();
        Iterator it = diagNodes.iterator();

        //search for the userobject on the DiagramDesktop
        while (it.hasNext()) {
            DiagramNode currentDiagNode = (DiagramNode) it.next();
            if (currentDiagNode.getUserObject().toString().equals(sObject)) {
                uo = (CBUserObject) currentDiagNode.getUserObject();
                dObj = currentDiagNode;
            }
        }
        //if the object is not on the desktop load it from CB and add it
        if (uo == null) {
            CBQuery query=new CBQuery("find_object[" + sObject + "/objname]", cbFrame);
            Collection ansColl = query.ask();
            //check if base was found
            if (ansColl.isEmpty()) {
                if (!bCreate) {
                    JOptionPane.showMessageDialog(cbFrame.getCBEditor(),"Object '" + sObject + "' not found!");
                    return null;
                } else {
                    return createIndividual(sObject,(String) cbFrame.getDefaultGraphTypes().get("Individual"), false);
                }
            }
            Iterator ite = ansColl.iterator();
            uo = (CBUserObject) ite.next();
            if (uo.getTelosObject() instanceof TelosLink) {
                DiagramObject doSrc =
                    getDiagramObjectForString(
                        uo.getTelosObject().getSource().toString(),
                        false);
                DiagramObject doDst=getDiagramObjectForString(uo.getTelosObject().getDestination().toString(),false);
                if (doSrc != null && doDst != null) {
                    dObj=new DiagramEdge(
                            new DiagramNode(uo, cbFrame.getDiagramClass()),
                            doSrc,
                            doDst,
                            cbFrame.getDiagramClass());
                    Vector vTmp = new Vector(1);
                    vTmp.add(dObj);
                    //cbFrame.getDiagramDesktop().addDiagramEdges(vTmp,doDst.getNode(),i5.cb.graph.GEConstants.S_POSITION,false);
                }
            } else {
                dObj = new DiagramNode(uo, cbFrame.getDiagramClass());
                //cbFrame.getDiagramDesktop().addDiagramNode((DiagramNode) dObj);
            }
        }
        if((dObj instanceof DiagramNode) && ((DiagramNode) dObj).isOnEdge())
            dObj=((DiagramNode)dObj).getDiagramEdge();
        return dObj;
    }

    /** Changes the Text of a TextField matching the given Identifier.
     *  @param TextFieldIdentifier : 1 = BaseClassField
     *                               2 = ObjectNameField
     *  @param Text : Text to set
    */
    public void setTextFieldText(int TextFieldIdentifier, String Text) {

        switch (TextFieldIdentifier) {
            case 1 :
                if (jtfBaseClass != null)
                    jtfBaseClass.setText(Text);
                jtfObject.grabFocus();
                break;
            case 2 :
                jtfObject.setText(Text);
                if (jtfBaseClass != null) {
                    jtfBaseClass.grabFocus();
                }
                break;
        }
    }
}
