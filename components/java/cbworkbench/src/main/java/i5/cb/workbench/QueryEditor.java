/*
The ConceptBase.cc Copyright

Copyright 1987-2016 The ConceptBase Team. All rights reserved.

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
 * @(#)QueryEditor.java 1.00 97/05/28
 *
 *
 */
package i5.cb.workbench;
import i5.cb.telos.frame.*;

import java.awt.*;
import java.awt.event.*;
import java.io.StringReader;

import javax.swing.*;
import javax.swing.border.LineBorder;
import javax.swing.border.TitledBorder;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

import com.objectspace.jgl.Set;

/**
 *
 * class QueryEditor
 *
 */
class QueryEditor extends JInternalFrame implements ActionListener, ListSelectionListener, FocusListener
{
    private JButton bTell, bAsk, bClose;
    private JTextField tfQueryName, tfIsa;
    private RList lRetrievedAttributes, lComputedAttributes;
    private JTextArea taConstraint, taTelosDefinition;
    private JPopupMenu pmCompAttributes;
    private JPopupMenu pmRetrAttributes;
    private CBIva CBI;
    private JSplitPane jspAttributes;


    /**
     *
     * Constructor for the QueryEditor
     *
     */
    public QueryEditor(CBIva CBI)
    {
        super("Query Editor",true,false,true,true);

        this.CBI=CBI;

        JPanel p1,p1a,p1b,p5;
        JScrollPane p2a,p2b,p3,p4;

        JLabel l;

        // the frame is created
        this.getContentPane().setLayout(new BorderLayout());

        p1 = new JPanel();
        p1.setLayout(new BorderLayout());
        p1.setBorder(new TitledBorder(LineBorder.createGrayLineBorder()));

        // text field for query name
        p1a = new JPanel();
        p1a.setLayout(new BorderLayout());
        l = new JLabel("Query Name ");
        p1a.add(l, "West");

        tfQueryName = new JTextField(10);
        tfQueryName.addFocusListener(this);
        tfQueryName.setBackground(Color.white);
        tfQueryName.addActionListener(this);
        p1a.add(tfQueryName, "Center");

        // text field for specialization
        p1b = new JPanel();
        p1b.setLayout(new BorderLayout());

        l = new JLabel("Specialization of ");
        p1b.add(l, "West");

        tfIsa = new JTextField(10);
        tfIsa.addFocusListener(this);
        tfIsa.setBackground(Color.white);
        tfIsa.addActionListener(this);
        p1b.add(tfIsa, "Center");

        p1.add(p1a, "West");
        p1.add(p1b, "East");

        p2a = new JScrollPane();
        p2a.setBorder(new TitledBorder(LineBorder.createGrayLineBorder(), "Retrieved Attributes"));

        // pop-up menu for retrieved attributes is created
        pmRetrAttributes = new JPopupMenu();
        JMenuItem miSelectAll = new JMenuItem("Select All");
        miSelectAll.addActionListener(this);
        pmRetrAttributes.add(miSelectAll);
        JMenuItem miDeselectAll = new JMenuItem("Deselect All");
        miDeselectAll.addActionListener(this);
        pmRetrAttributes.add(miDeselectAll);

        lRetrievedAttributes = new RList(pmRetrAttributes);
        lRetrievedAttributes.setToolTipText("Select Retrived Attributes");
        lRetrievedAttributes.setBackground(Color.white);
        lRetrievedAttributes.addListSelectionListener(this);
        lRetrievedAttributes.setSelectionMode(ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);
        p2a.getViewport().setView(lRetrievedAttributes);

        p2a.setSize(new Dimension(50,50));

        p2b = new JScrollPane();
        p2b.setBorder(new TitledBorder(LineBorder.createGrayLineBorder(), "Computed Attributes"));

        // pop-up menu for computed attributes is created
        pmCompAttributes = new JPopupMenu();
        JMenuItem miAddAttribute = new JMenuItem("Add Attribute");
        miAddAttribute.addActionListener(this);
        pmCompAttributes.add(miAddAttribute);
        JMenuItem miDelAttribute = new JMenuItem("Delete Attribute");
        miDelAttribute.addActionListener(this);
        pmCompAttributes.add(miDelAttribute);

        lComputedAttributes = new RList(pmCompAttributes);
        lComputedAttributes.setToolTipText("Add Computed Attribute");
        lComputedAttributes.setBackground(Color.white);
        p2b.getViewport().setView(lComputedAttributes);

        p2b.setSize(new Dimension(50,50));

        jspAttributes = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, p2a,p2b);

        p3 = new JScrollPane();
        p3.setBorder(new TitledBorder(LineBorder.createGrayLineBorder(), "Constraint"));

        taConstraint = new JTextArea();
        taConstraint.setBackground(Color.white);
        p3.getViewport().setView(taConstraint);
        p3.setSize(new Dimension(100,100));
        p3.setPreferredSize(new Dimension(100,100));

        p4 = new JScrollPane();
        p4.setBorder(new TitledBorder(LineBorder.createGrayLineBorder(), "Telos Definition"));

        // Text-Area Telos Definition

        taTelosDefinition = new JTextArea();
        taTelosDefinition.setBackground(Color.white);
        p4.getViewport().setView(taTelosDefinition);


        p5 = new JPanel();
        p5.setLayout(new FlowLayout(FlowLayout.CENTER, 15, 15));

        // Add buttons
        bTell = new JButton("Tell");
        bTell.addActionListener(this);
        p5.add(bTell);

        bAsk = new JButton("Ask Query");
        bAsk.addActionListener(this);
        p5.add(bAsk);

        bClose = new JButton("Cancel");
        bClose.addActionListener(this);
        p5.add(bClose);

        this.getContentPane().add(p1, BorderLayout.NORTH);

        JSplitPane VS1 = new JSplitPane(JSplitPane.VERTICAL_SPLIT, p3, p4);
        VS1.setSize(new Dimension(300,300));
        JSplitPane VS2 = new JSplitPane(JSplitPane.VERTICAL_SPLIT, jspAttributes, VS1);

        this.getContentPane().add(VS2,BorderLayout.CENTER);
        this.getContentPane().add(p5, BorderLayout.SOUTH);

        jspAttributes.setSize(new Dimension(80,80));

        Dimension dimSize=new Dimension(500,550);
        this.setPreferredSize(dimSize);
        this.setMinimumSize(new Dimension(450,200));
        this.setSize(dimSize);

        this.enableFields(false);
    }

    public void valueChanged(ListSelectionEvent e) {
        updateTelosFrame(false);

    }


    private void setLogToFront()  {

        CBI.getTelosEditor().setRequestFocusEnabled(true);
        CBI.getTelosEditor().requestFocus();
    }

    public void actionPerformed(ActionEvent event) {
        int i;
        Object source = event.getSource();
        String sCommand = event.getActionCommand();
        // Tell-Button
        if (source == bTell) {
            CBI.getCBClient().tell(this.taTelosDefinition.getText());
            // Close-Button
        }
        else if (source == bClose) {
            this.dispose();
            // Ask-Button
        }
        else if (source == bAsk) {
            String answer = CBI.getCBClient().ask(this.taTelosDefinition.getText(), "FRAMES", "FRAME");
            if (answer != "error") {
                new QueryResultWindow(answer, CBI);
            }
            else
                setLogToFront();
            // popup menu: Select all
        }
        else if (sCommand.equals("Select All")) {
            lRetrievedAttributes.selectAll();
            // popup menu: Deselect all
        }
        else if (sCommand.equals("Deselect All")) {
            lRetrievedAttributes.deselectAll();
        }
        // popup menu: Add Attribute
        else if (sCommand.equals("Add Attribute")) {
            addComputedAttribute();
        }
        // popup menu: Delete Attribute
        else if (sCommand.equals("Delete Attribute")) {
            i = this.lComputedAttributes.getSelectedIndex();
            if (i != -1) {
                this.lComputedAttributes.delItem(i);
            };
            updateTelosFrame(false);
        }
        else if ((source == tfQueryName) | (source == tfIsa)) {
            if (((tfQueryName.getText()).length() != 0) & ((tfIsa.getText()).length() != 0)) {
                this.enableFields(true);
                lRetrievedAttributes.removeAll();
                lComputedAttributes.removeAll();
                taTelosDefinition.setText("");
                taConstraint.setText("");
                updateTelosFrame(true);

            }
            else {
                this.enableFields(false);
                lRetrievedAttributes.removeAll();
                lComputedAttributes.removeAll();
                taTelosDefinition.setText("");
                taConstraint.setText("");
            }
        }
    }

    /**
     * Enables or disables dialog elements
     */
    private void enableFields(boolean bEnable) {
        taConstraint.setEnabled(bEnable);
        taTelosDefinition.setEnabled(bEnable);
        lRetrievedAttributes.setEnabled(bEnable);
        lComputedAttributes.setEnabled(bEnable);
        bAsk.setEnabled(bEnable);
        bTell.setEnabled(bEnable);
    }

    /**
     * @see FocusListener#focusGained
     */
    public void focusGained(FocusEvent e) { }

    /**
     * @see FocusListener#focusLost
     *
     * One of the text fields lost focus.
     * Possibly update the corresponding dialog elements.
     */
    public void focusLost(FocusEvent e) {
        Object source = e.getSource();
        if ((source == tfQueryName) | (source == tfIsa)) {
            if (((tfQueryName.getText()).length() != 0) & ((tfIsa.getText()).length() != 0)) {
                this.enableFields(true);
                lRetrievedAttributes.removeAll();
                lComputedAttributes.removeAll();
                taTelosDefinition.setText("");
                taConstraint.setText("");
                updateTelosFrame(true);
            }
            else {
                this.enableFields(false);
                lRetrievedAttributes.removeAll();
                lComputedAttributes.removeAll();
                taTelosDefinition.setText("");
                taConstraint.setText("");
            }
        }
    }

    /**
     * Updates the Telos frame object and possibly the list boxes
     */
    private TelosFrame updateTelosFrame(boolean bcompleteUpdate) {
        int i;
        TelosFrame tfrTemp = null;
        TelosFrame tfrAFrame;
        tfrTemp = new TelosFrame(new i5.cb.telos.frame.Label("QueryClass"),
                                 new i5.cb.telos.frame.Label(tfQueryName.getText()),
                                 new ObjectNames(),
                                 new ObjectNames(new i5.cb.telos.frame.Label(tfIsa.getText())),
                                 new WithSpec());
        // fetch attributes
        if (bcompleteUpdate) {
            String answer = CBI.getCBClient().ask("get_object[" + tfIsa.getText() + "/objname,FALSE/dedIn,FALSE/dedIsa,TRUE/dedWith]",
                                         "OBJNAMES",
                                         "FRAME");

            if (answer != "error") {
                this.setTitle("Query Editor (Latest operation status: Operation successful)");


                // update the list boxes
                TelosParser tpParser=new TelosParser(new StringReader(answer));
                TelosFrames tfsFrames = null;
                try {
                    tfsFrames = tpParser.telosFrames();
                    for (java.util.Enumeration eFrames = tfsFrames.elements(); eFrames.hasMoreElements(); ) {
                        tfrAFrame = (TelosFrame)eFrames.nextElement();
                        Set setASet = tfrAFrame.getPropertiesInCategory(new i5.cb.telos.frame.Label("attribute"));
                        for (java.util.Enumeration eAttributes = setASet.elements(); eAttributes.hasMoreElements(); ) {
                            Property prpAttribute=(Property) eAttributes.nextElement();
                            lRetrievedAttributes.addSort(prpAttribute.getLabel().toString() + " : " + prpAttribute.getTarget().toString());
                        }
                    }
                    jspAttributes.setDividerLocation(0.5);
                }
                catch(ParseException er)  {
                    System.out.println("ParseException:" +er.getMessage());
                }
            }
        }



        // add selected attributes to the Telos frame object
        String sItem, sSource, sTarget;

        Object[] asRetrievedItems = lRetrievedAttributes.getSelectedItems();

        for (i = 0; i < asRetrievedItems.length; i++) {
            sItem = (String)asRetrievedItems[i];
            sSource = sItem.substring(0, sItem.indexOf(":") - 1);
            sTarget = sItem.substring(sItem.indexOf(":") + 2);
            tfrTemp.addAttribute(new i5.cb.telos.frame.Label("retrieved_attribute"),
                                 new i5.cb.telos.frame.Label(sSource),
                                 new i5.cb.telos.frame.Label(sTarget));
        }
        // add computed attributes to the Telos frame object
        Object[] asComputedItems = lComputedAttributes.getItems();
        for (i = 0; i < asComputedItems.length; i++) {
            sItem = (String)asComputedItems[i];
            sSource = sItem.substring(0, sItem.indexOf(":") - 1);
            sTarget = sItem.substring(sItem.indexOf(":") + 2);
            tfrTemp.addAttribute(new i5.cb.telos.frame.Label("computed_attribute"),
                                 new i5.cb.telos.frame.Label(sSource),
                                 new i5.cb.telos.frame.Label(sTarget));
        }
        // add the constraint area to the Telos frame object
        if (taConstraint.getText().length() != 0) {
            tfrTemp.addAttribute(new i5.cb.telos.frame.Label("constraint"),
                                 new i5.cb.telos.frame.Label("c"),
                                 new i5.cb.telos.frame.Label(taConstraint.getText()));
        }
        taTelosDefinition.setText(tfrTemp.toString());


        lRetrievedAttributes.repaint();
        lComputedAttributes.repaint();


        return tfrTemp;
    }

    public void addComputedAttribute() {
        // text field for attribute label with label
        JPanel p = new JPanel();
        GridBagLayout gbl = new GridBagLayout();
        p.setLayout(gbl);
        JLabel l = new JLabel("Label");
        GridBagConstraints c = new GridBagConstraints();
        c.gridx = 0;
        c.gridy = 0;
        c.gridwidth = GridBagConstraints.RELATIVE;
        c.gridheight = GridBagConstraints.RELATIVE;
        c.fill = GridBagConstraints.HORIZONTAL;
        gbl.setConstraints(l, c);
        p.add(l);
        JTextField tfAttrLabel = new JTextField(50);
        c = new GridBagConstraints();
        c.gridx = GridBagConstraints.RELATIVE;
        c.gridy = 0;
        c.gridwidth = GridBagConstraints.REMAINDER;
        c.gridheight = GridBagConstraints.RELATIVE;
        c.fill = GridBagConstraints.HORIZONTAL;
        gbl.setConstraints(tfAttrLabel, c);
        p.add(tfAttrLabel);

        // text field for attribute value with label
        l = new JLabel("Class");
        c = new GridBagConstraints();
        c.gridx = 0;
        c.gridy = GridBagConstraints.RELATIVE;
        c.gridwidth = 1;
        c.gridheight = 1;
        c.fill = GridBagConstraints.HORIZONTAL;
        gbl.setConstraints(l, c);
        p.add(l);
        JTextField tfAttrDest = new JTextField(50);
        c = new GridBagConstraints();
        c.gridx = GridBagConstraints.RELATIVE;
        c.gridy = GridBagConstraints.RELATIVE;
        c.gridwidth = GridBagConstraints.REMAINDER;
        c.gridheight = GridBagConstraints.REMAINDER;
        c.fill = GridBagConstraints.HORIZONTAL;
        gbl.setConstraints(tfAttrDest, c);
        p.add(tfAttrDest);

        int ret=JOptionPane.showConfirmDialog(this,p,"Add computed attribute",JOptionPane.OK_CANCEL_OPTION);

        if(ret==JOptionPane.OK_OPTION) {
            this.lComputedAttributes.addSort(tfAttrLabel.getText() + " : " + tfAttrDest.getText());
            updateTelosFrame(false);
        }
    }
}
