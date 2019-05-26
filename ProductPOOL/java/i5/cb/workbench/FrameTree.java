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
/**
*   <b> FrameTree for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.CBIva
*/

package i5.cb.workbench;

// Local includes
//import de.unikl.awtnode.AWTNode;
import i5.cb.telos.frame.*;

import java.awt.*;
import java.awt.event.*;
import java.io.StringReader;

import javax.swing.*;
import javax.swing.tree.*;

/**
*   Class:    <b> FrameTree for CBIva  </b><BR>
*   Function: <b> Display a Telos Frame as a Tree (like in NT explorer) </b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see javax.swing.JFrame
*   @see i5.cb.workbench.CBIva
*/
public class FrameTree extends JInternalFrame implements ActionListener {

    private TelosEditor teEditor;
    private JButton btOk;
    private JButton btTelosEditor;
    private JButton btFrameTree;
    private TelosTreeNode anRoot;
    private JTree tree;
    private DefaultTreeModel DTM;

    public FrameTree(String sObject, TelosEditor teEditor) {

        super(sObject,true,false,true,true);

        this.teEditor=teEditor;

        this.getContentPane().setLayout(new BorderLayout());

        JScrollPane spTreePane=new JScrollPane();

        anRoot=new TelosTreeNode(teEditor, sObject, true);

        anRoot.Rescan();

        DTM = new DefaultTreeModel(anRoot);

        this.tree = new JTree(DTM);

        try {
            javax.swing.plaf.TreeUI uiTree = new com.sun.java.swing.plaf.motif.MotifTreeUI();
            tree.setUI(uiTree);
            tree.updateUI();
        }
        catch (Exception exc) {
            System.err.println("Error loading L&F: " + exc);
        }



        // the Mouse Listener
        MouseListener ml = new MouseAdapter()  {
                               public void mousePressed (MouseEvent e) {
                                   TreePath selPath = tree.getClosestPathForLocation(e.getX(), e.getY());
                                   if (selPath!=null)  {

                                       Object obj=new Object();
                                       try {
                                           obj = selPath.getLastPathComponent();
                                       }
                                       catch (IllegalArgumentException iae)  {}
                                       if (obj instanceof TelosTreeNode) {

                                           TelosTreeNode TTN=(TelosTreeNode)obj;

                                           TTN.Rescan();

                                           DTM.reload(TTN);
                                           tree.treeDidChange();

                                       }

                                   }
                               }
                           };


        tree.addMouseListener(ml);
        tree.setCellRenderer(new MyTreeCellRenderer(teEditor.getCBIva()));


        spTreePane.getViewport().add(tree);
        this.getContentPane().add(spTreePane,BorderLayout.CENTER);

        btOk=new JButton("Ok");
        btOk.addActionListener(this);

        btTelosEditor=new JButton("TelosEditor");
        btTelosEditor.addActionListener(this);

        btFrameTree=new JButton("View Object as Tree");
        btFrameTree.addActionListener(this);


        JPanel panButtons=new JPanel();
        panButtons.setLayout(new FlowLayout());

        panButtons.add(btOk);
        panButtons.add(btTelosEditor);
        panButtons.add(btFrameTree);

        this.getContentPane().add(panButtons,BorderLayout.SOUTH);

        this.setMinimumSize(new Dimension(350,100));
        this.setPreferredSize(new Dimension(400,300));
        this.setSize(new Dimension(400,300));
    }


    /*
     public void ProcessMouseEvent (MouseEvent e) {
      int selRow = tree.getRowForLocation(e.getX(), e.getY());
      TreePath selPath = tree.getPathForLocation(e.getX(), e.getY());
      if (selRow != -1)  {
       if (e.getClickCount() == 1)  {
        Object obj=new Object();
        try {
         obj = selPath.getLastPathComponent();
        }
        catch (IllegalArgumentException iae)  {}
        if (obj instanceof TelosTreeNode) {
         TelosTreeNode TTN=(TelosTreeNode)obj;
         if (TTN.isObject()) TTN.Rescan();
        }

       }
       else if (e.getClickCount() == 2)  {
        //...
       }
      }
     }
    */


    /**
    *   Function: <b> Excecute the Commands </b> <BR>
    *
    *   @param e the ActionEvent for the Command
    *   @see java.awt.event.ActionEvent
    */
    public void actionPerformed(ActionEvent e) {

        if (e.getSource()==btOk) {
            this.setVisible(false);
            this.dispose();
        }
        else {
            Object objSelect = tree.getSelectionPath().getLastPathComponent();
            if (objSelect instanceof TelosTreeNode)  {
                TelosTreeNode TTNSelect = (TelosTreeNode)objSelect;
                if (TTNSelect.isObject())  {

                    if (e.getSource()==btTelosEditor) {
                        teEditor.getTelosTextArea().setText(teEditor.getCBIva().getCBClient().getObject(TTNSelect.toString()));
                    }
                    else
                        if (e.getSource()==btFrameTree) {
                            FrameTree FT = new FrameTree(TTNSelect.toString(), teEditor);
                            teEditor.getCBIva().add(FT);
                        }
                }
            }
        }
    }

}

/** Erweiterung der Klasse AWTNode um
* Knoten dynamisch expandieren zu koennen.
* (noch nicht fertig)
* */

class TelosTreeNode extends DefaultMutableTreeNode implements ActionListener {

    private String sLabel;
    private TelosEditor teEditor;
    private boolean bisObject;

    public boolean isObject() {
        return bisObject;
    }

    public TelosTreeNode() {
        super("dummi");
    }

    public TelosTreeNode(TelosEditor teEditor, String sLabel, boolean bisObject) {
        super(sLabel);
        this.sLabel=sLabel;
        this.teEditor=teEditor;
        this.bisObject=bisObject;
        if (bisObject)
            this.add(new TelosTreeNode());
    }

    public TelosTreeNode(TelosEditor teEditor, String sLabel, boolean bisObject, String sAttribut) {
        super(sAttribut + " : " +  sLabel);
        this.sLabel=sLabel;
        this.teEditor=teEditor;
        this.bisObject=bisObject;
        if (bisObject)
            this.add(new TelosTreeNode());
    }

    private boolean bScanned=false;

    public void Rescan() {

        if (bisObject && !bScanned)  {

            bScanned=true;
            if (sLabel!=null) {
                // Alte/Dummy Eintraege loeschen
                this.removeAllChildren();

                // Hole ein Objekt als String
                String sFrame=teEditor.getCBIva().getCBClient().getObject(sLabel);

                // Erstelle einen TelosParser
                TelosParser tpParser=new TelosParser(new StringReader(sFrame));

                // Parse das Objekt
                TelosFrames tfsFrames=null;
                try {
                    tfsFrames=tpParser.telosFrames();
                }
                catch(ParseException e)  {
                    System.out.println("ParseException:" +e.getMessage());
                    return;
                }
                catch(TokenMgrError te)  {
                    System.out.println("ParseException:" +te.getMessage());
                    return;
                }

                // Hole den ersten TelosFrame (das muss der richtige sein)
                java.util.Enumeration eFrames=tfsFrames.elements();
                TelosFrame tfrFrame=(TelosFrame) eFrames.nextElement();

                // Knoten fuer die InSpecs
                TelosTreeNode anInSpecs=new TelosTreeNode(teEditor,"in",false);

                if(tfrFrame.hasInOmegaSpec()) {
                    anInSpecs.add(new TelosTreeNode(teEditor,tfrFrame.inOmegaSpec().toString(), true));
                }

                if(tfrFrame.hasInSpec()) {
                    java.util.Enumeration eInClasses=tfrFrame.inSpec().elements();
                    while (eInClasses.hasMoreElements())  {
                        anInSpecs.add(new TelosTreeNode(teEditor,((ObjectName)eInClasses.nextElement()).toString(), true));
                    }
                }
                // In-Knoten zur Wurzel hinzufuegen
                this.add(anInSpecs);

                // Knoten fuer die IsaSpecs
                TelosTreeNode anIsaSpecs=new TelosTreeNode(teEditor,"isA", false);

                if(tfrFrame.hasIsaSpec()) {
                    java.util.Enumeration eIsaClasses=tfrFrame.isaSpec().elements();
                    while (eIsaClasses.hasMoreElements())  {
                        anIsaSpecs.add(new TelosTreeNode(teEditor,((ObjectName)eIsaClasses.nextElement()).toString(), true));
                    }
                }
                // Isa-Knoten zur Wurzel hinzufuegen
                this.add(anIsaSpecs);


                // Nun holen wir alle Attributkategorien
                if (tfrFrame.hasWithSpec()) {
                    java.util.Enumeration eCategories=tfrFrame.getCategories().elements();
                    while(eCategories.hasMoreElements()) {

                        i5.cb.telos.frame.Label labCategory=(i5.cb.telos.frame.Label) eCategories.nextElement();

                        TelosTreeNode anAttrCat=new TelosTreeNode(teEditor, labCategory.toString(), false);


                        java.util.Enumeration eProperties=tfrFrame.getPropertiesInCategory(labCategory).elements();

                        while (eProperties.hasMoreElements()) {
                            Property prpAttribute=(Property) eProperties.nextElement();

                            anAttrCat.add(new TelosTreeNode(teEditor, prpAttribute.getTarget().toString(), true, prpAttribute.getLabel().toString()));
                        }
                        this.add(anAttrCat);
                    }
                }
            }
        }
    }

    public void actionPerformed(ActionEvent e) {

        FrameTree ftObject=new FrameTree(((Button) e.getSource()).getLabel(),teEditor);
        ftObject.setVisible(true);
    }
}




