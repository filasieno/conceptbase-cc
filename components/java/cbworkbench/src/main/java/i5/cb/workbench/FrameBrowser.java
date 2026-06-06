/*
The ConceptBase.cc Copyright

Copyright 1987-2026 The ConceptBase Team. All rights reserved.

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
/**
 *   <b> FrameBrowser for CBIva 02.98  (ConceptBase) </b>
 *
 *   @see i5.cb.workbench.CBIva
 */

package i5.cb.workbench;


import i5.cb.telos.frame.*;

import java.awt.*;
import java.io.StringReader;
import java.util.StringTokenizer;

import javax.swing.*;



/**
 *   Class:    <b> FrameBrowser for CBIva  </b><BR>
 *   Function: <b> Create a new FrameBrowser </b> <BR>
 *
 *   @version 0.8 beta
 *   @author    Rainer Langohr
 *
 *   @see i5.cb.workbench.CBIva
 */

public class FrameBrowser extends JInternalFrame {

    /**
     * the CBIvaClient
     */

    private CBIva CBI;

    private TelosFramesIO cache;
    private JTextField tfObject;

    private String sPreviousQuery;

    private RList lbAttributes;
    private RList lbSubClasses;
    private RList lbInstances;
    private RList lbSuperClasses;
    private RList lbClasses;
    private RList lbIncomingLinks;
    private RList lbAttributeClasses;

    private JInternalFrame fSuper;
    private JInternalFrame fClasses;
    private JInternalFrame fIncoming;
    private JInternalFrame fAttrCat;
    private JInternalFrame fAttr;
    private JInternalFrame fSub;
    private JInternalFrame fInstances;
    private JInternalFrame fObject;

    private JDesktopPane panMDI;


    /**
     *   <b> Constructor  </b><BR>
     *
     *   @param cbi CBIva main window
     */
    public FrameBrowser(CBIva cbi) {
        super("Frame Browser",true,false,true,true);
        this.CBI=cbi;

        // Create ListBoxes and PopupMenus
        JScrollPane panSuperClasses=new JScrollPane();
        lbSuperClasses=new RList(new FBPopup(0, this));
        panSuperClasses.getViewport().setView(lbSuperClasses);

        JScrollPane panClasses=new JScrollPane();
        lbClasses=new RList(new FBPopup(1, this));
        panClasses.getViewport().setView(lbClasses);

        JScrollPane panIncomingLinks=new JScrollPane();
        lbIncomingLinks=new RList(new FBPopup(2, this));
        panIncomingLinks.getViewport().setView(lbIncomingLinks);

        JScrollPane panAttributeClasses=new JScrollPane();
        lbAttributeClasses=new RList();
        panAttributeClasses.getViewport().setView(lbAttributeClasses);

        JScrollPane panAttributes=new JScrollPane();
        lbAttributes=new RList(new FBPopup(4, this));
        panAttributes.getViewport().setView(lbAttributes);

        JScrollPane panSubClasses=new JScrollPane();
        lbSubClasses=new RList(new FBPopup(5, this));
        panSubClasses.getViewport().setView(lbSubClasses);

        JScrollPane panInstances=new JScrollPane();
        lbInstances=new RList(new FBPopup(6, this));
        panInstances.getViewport().setView(lbInstances);

        JPanel panObject=new JPanel(new BorderLayout());
        tfObject=new JTextField();
        tfObject.setBackground(Color.white);
        tfObject.setForeground(Color.red);
        panObject.add(tfObject,BorderLayout.CENTER);

        JButton butUpdate=new JButton("Update");
        panObject.add(butUpdate,BorderLayout.SOUTH);

        // Adding the panels to individual internal frames:
        panMDI = new JDesktopPane();

        //Super Classes
        fSuper=new JInternalFrame("Super Classes");
        fSuper.setContentPane(panSuperClasses);
        fSuper.setBounds(0, 0, 0, 0);
        fSuper.setMinimumSize(new Dimension(150,20));
        fSuper.setSize(new Dimension(281,100));
        fSuper.setClosable(false);
        fSuper.setMaximizable(true);
        fSuper.setIconifiable(true);
        fSuper.setResizable(true);
        panMDI.add(fSuper);

        //Classes
        fClasses=new JInternalFrame("Classes");
        fClasses.setContentPane(panClasses);
        fClasses.setBounds(281, 0, 0, 0);
        fClasses.setMinimumSize(new Dimension(150,20));
        fClasses.setSize(new Dimension(281,100));
        fClasses.setClosable(false);
        fClasses.setMaximizable(true);
        fClasses.setIconifiable(true);
        fClasses.setResizable(true);
        panMDI.add(fClasses);

        //Incoming Links
        fIncoming=new JInternalFrame("Incoming Links");
        fIncoming.setContentPane(panIncomingLinks);
        fIncoming.setBounds(0, 100, 0, 0);
        fIncoming.setMinimumSize(new Dimension(150,20));
        fIncoming.setSize(new Dimension(154,100));
        fIncoming.setClosable(false);
        fIncoming.setMaximizable(true);
        fIncoming.setIconifiable(true);
        fIncoming.setResizable(true);
        panMDI.add(fIncoming);

        //Attributes Classes
        fAttrCat=new JInternalFrame("Attributes Classes");
        fAttrCat.setContentPane(panAttributeClasses);
        fAttrCat.setBounds(254, 100, 0, 0);
        fAttrCat.setMinimumSize(new Dimension(150,20));
        fAttrCat.setSize(new Dimension(154,100));
        fAttrCat.setClosable(false);
        fAttrCat.setMaximizable(true);
        fAttrCat.setIconifiable(true);
        fAttrCat.setResizable(true);
        panMDI.add(fAttrCat);

        //Attributes
        fAttr=new JInternalFrame("Attributes");
        fAttr.setContentPane(panAttributes);
        fAttr.setBounds(408, 100, 0, 0);
        fAttr.setMinimumSize(new Dimension(150,20));
        fAttr.setSize(new Dimension(154,100));
        fAttr.setClosable(false);
        fAttr.setMaximizable(true);
        fAttr.setIconifiable(true);
        fAttr.setResizable(true);
        panMDI.add(fAttr);

        //SubClasses
        fSub=new JInternalFrame("Subclasses");
        fSub.setContentPane(panSubClasses);
        fSub.setBounds(0, 200, 0, 0);
        fSub.setMinimumSize(new Dimension(150,20));
        fSub.setSize(new Dimension(281,100));
        fSub.setClosable(false);
        fSub.setMaximizable(true);
        fSub.setIconifiable(true);
        fSub.setResizable(true);
        panMDI.add(fSub);

        //Instances
        fInstances=new JInternalFrame("Instances");
        fInstances.setContentPane(panInstances);
        fInstances.setBounds(281, 200, 0, 0);
        fInstances.setMinimumSize(new Dimension(150,20));
        fInstances.setSize(new Dimension(281,100));
        fInstances.setClosable(false);
        fInstances.setMaximizable(true);
        fInstances.setIconifiable(true);
        fInstances.setResizable(true);
        panMDI.add(fInstances);

        // Object
        fObject=new JInternalFrame("Object");
        fObject.setContentPane(panObject);
        fObject.setBounds(154,100,0,0);
        fObject.setMinimumSize(new Dimension(100,100));
        fObject.setSize(new Dimension(100,100));
        fObject.setClosable(false);
        fObject.setMaximizable(true);
        fObject.setIconifiable(true);
        fObject.setResizable(true);
        panMDI.add(fObject);

        fSuper.setVisible(true);
        fClasses.setVisible(true);
        fIncoming.setVisible(true);
        fAttrCat.setVisible(true);
        fAttr.setVisible(true);
        fSub.setVisible(true);
        fInstances.setVisible(true);
        fObject.setVisible(true);
        fObject.setVisible(true);

        /*
         panMDI.addLink(fObject,fSuper,"isA");
         panMDI.addLink(fObject,fClasses,"in");
         panMDI.addLink(fInstances,fObject,"in");
         panMDI.addLink(fSub,fObject,"isA");
         panMDI.addLink(fObject,fAttrCat,"attribute");
         panMDI.addLink(fAttrCat,fAttr,"");
         panMDI.addLink(fIncoming,fObject,"");
         */

        // Replace the button bar...
        JButton butCache=new JButton("Cache");
        JButton butTelosEditor=new JButton("Telos Editor");
        JButton butOk=new JButton("Close");
        JButton butLoad=new JButton("Load");
        JButton butSave=new JButton("Save");
        JButton butAddQueryResult=new JButton("Add Query Result");

        JPanel panButtonBar=new JPanel(new GridLayout(1,7,10,5));

        // panButtonBar.add(butUpdate);
        // panButtonBar.add(tfObject);
        panButtonBar.add(butCache);
        panButtonBar.add(butTelosEditor);
        panButtonBar.add(butOk);
        panButtonBar.add(butLoad);
        panButtonBar.add(butSave);
        panButtonBar.add(butAddQueryResult);

        tfObject.addActionListener(new FBCommand(FBCommand.UPDATE,this));
        butOk.addActionListener(new FBCommand(FBCommand.OK,this));
        butLoad.addActionListener(new FBCommand(FBCommand.LOAD,this));
        butSave.addActionListener(new FBCommand(FBCommand.SAVE,this));
        butUpdate.addActionListener(new FBCommand(FBCommand.UPDATE,this));
        butCache.addActionListener(new FBCommand(FBCommand.CACHE,this));
        butTelosEditor.addActionListener(new FBCommand(FBCommand.TELOSEDITOR,this));
        butAddQueryResult.addActionListener(new FBCommand(FBCommand.ADDQUERYRESULT,this));
        lbAttributeClasses.addMouseListener(new FBCommand(lbAttributeClasses,this));

        cache = new TelosFramesIO();

        this.getContentPane().setLayout(new BorderLayout());
        // setBackground(Color.lightGray);
        // setForeground(Color.black);
        this.getContentPane().add(panMDI,"Center");
        this.getContentPane().add(panButtonBar,"South");

        Dimension dimSize=new Dimension(580,400);
        this.setPreferredSize(dimSize);
        this.setMinimumSize(new Dimension(200,100));
        this.setSize(dimSize);
    }

    /**
     * @return the lbAttributeClasses
     */
    public RList getAttributeClasses() {
        return lbAttributeClasses;
    }

    /**
     * @return the CBIvaClient
     */

    public CBIvaClient getCBClient() {
        return CBI.getCBClient();
    }


    /**
     * @return the cache
     */

    public TelosFramesIO getCache() {
        return cache;
    }


    /**
     * @return the tfObject
     */

    public JTextField getObject() {
        return tfObject;
    }


    /**
     *   Function: <b> Close FrameBrowser, when Close-Butten was clicked</b> <BR>
     */
    public void okClicked() {
        dispose();
    }

    /**
     *   Function: <b> Open Load-Dialog, when Load-Butten was clicked</b> <BR>
     */
    public void loadClicked() {
        cache.load();
    }


    /**
     *   Function: <b> Open Save-Dialog, when Save-Butten was clicked</b> <BR>
     */
    public void saveClicked() {
        cache.save();
    }

    /**
     *   Function: <b> Open FBResult-Dialog, when Result-Butten was clicked</b> <BR>
     */
    public void addQueryResultsClicked() {
        String sQuery=JOptionPane.showInputDialog(this,"Specify a query",sPreviousQuery);
        if(sQuery==null)
            return;
        if (this.getCBClient().isConnected()) {
            try {
                String query=new String();
                query=this.getCBClient().ask(sQuery,"OBJNAMES","FRAME");
                TelosFrames list = new TelosFrames();
                TelosParser tp= new TelosParser(new StringReader(query));
                list=tp.telosFrames();
                java.util.Enumeration e5=list.elements();
                while(e5.hasMoreElements()) {
                    this.getCache().add(e5.nextElement());
                }
            }
            catch(ParseException error) {
                JOptionPane.showMessageDialog(null,error.toString(),"Error",JOptionPane.ERROR_MESSAGE);
            }
        }
        else
            JOptionPane.showMessageDialog(null,"You are NOT CONNECTED to the ConceptBase Server","Not Connected",JOptionPane.ERROR_MESSAGE);
    }



    /**
     *   Function: <b> refresh the Objects of the FrameBrowser , when Update-Butten was clicked</b> <BR>
     */
    public void updateClicked() {
        java.util.Enumeration e=cache.elements();
        if (CBI.getCBClient().isConnected()) {
            String object=CBI.getCBClient().getObject(tfObject.getText());
            if (object.equals("error")) {
                lbSuperClasses.removeAll();
                lbClasses.removeAll();
                lbInstances.removeAll();
                lbAttributes.removeAll();
                lbAttributeClasses.removeAll();
                lbIncomingLinks.removeAll();
                lbSubClasses.removeAll();
                JOptionPane.showMessageDialog(this,"Not found in Database:"+tfObject.getText(),"Error",JOptionPane.ERROR_MESSAGE);
            }
            else {
                TelosParser tp=new TelosParser(new StringReader(object));
                try {
                    TelosFrame telosFrame=tp.telosFrame();
                    cache.pushFront(telosFrame);
                    update(0);
                }
                catch(ParseException error) {}
            }
        }
        else {
            // Get object from cache
            String on=tfObject.getText();
            TelosFrame telosFrame=new TelosFrame(new i5.cb.telos.frame.Label(""));
            int i=0;
            boolean btfObject=false;
            while(e.hasMoreElements())  {
                telosFrame=(TelosFrame)e.nextElement();
                if (on.equals(telosFrame.objectName().toString())) {
                    btfObject=true;
                    break;
                }
                i++;
            }
            if (btfObject) {
                update(i);
            }
            else {
                lbSuperClasses.removeAll();
                lbClasses.removeAll();
                lbInstances.removeAll();
                lbAttributes.removeAll();
                lbAttributeClasses.removeAll();
                lbIncomingLinks.removeAll();
                lbSubClasses.removeAll();

                JOptionPane.showMessageDialog(this,"ObjectName does not exist in Cache","Error",JOptionPane.ERROR_MESSAGE);
            }
        }

        // first check which frame is selected
        JInternalFrame f=panMDI.getSelectedFrame();

        // then select all of them once...
        try {
            fSuper.setSelected(true);
            fClasses.setSelected(true);
            fIncoming.setSelected(true);
            fAttrCat.setSelected(true);
            fAttr.setSelected(true);
            fSub.setSelected(true);
            fInstances.setSelected(true);
            fObject.setSelected(true);

            // finally, re-select the one from before.
            if (f!=null)
                f.setSelected(true);
        }
    catch (java.beans.PropertyVetoException PVE)  {}
    }

    /**
     *   Function: <b> refresh Object on cache position</b> <BR>
     *
     *   @param position cache position to refresh
     *
     */
    public void update(int position) {
        TelosFrame tfrObject =(TelosFrame)cache.at(position);
        TelosFrame tfrTmp;
        if(CBI.getCBClient().isConnected()) {
            String object = new String(tfObject.getText());

            // SuperClasses
            lbSuperClasses.removeAll();
            ObjectNames on;
            on=tfrObject.isaSpec();
            java.util.Enumeration e=on.elements();
            while(e.hasMoreElements()) {
                lbSuperClasses.add((e.nextElement()).toString());
            }

            // Classes
            lbClasses.removeAll();
            on=tfrObject.inSpec();
            e=on.elements();
            while(e.hasMoreElements()) {
                lbClasses.add((e.nextElement()).toString());
            }

            if (tfrObject.hasInOmegaSpec()) {
                lbClasses.add(tfrObject.inOmegaSpec().toString());
            }

            try {
                // Instances
                lbInstances.removeAll();
                String strInstances=CBI.getCBClient().ask("find_instances["+object+"/class]","OBJNAMES","LABEL");
                TelosParser instancesParser=new TelosParser(new StringReader(strInstances));
                on=instancesParser.objectNames();
                e=on.elements();
                while(e.hasMoreElements()) {
                    lbInstances.add((e.nextElement()).toString());
                }

                // Subclasses
                String strSubclasses=CBI.getCBClient().ask("find_specializations["+object+"/class,TRUE/ded]","OBJNAMES","LABEL");
                TelosParser subClassParser=new TelosParser(new StringReader(strSubclasses));
                on=subClassParser.objectNames();
                lbSubClasses.removeAll();
                e=on.elements();
                while(e.hasMoreElements()) {
                    lbSubClasses.add((e.nextElement()).toString());
                }

                // Incoming links
                String strIncomingLinks=CBI.getCBClient().ask("find_iattributes["+object+"/class]","OBJNAMES","LABEL");
                TelosParser incomingLinksParser=new TelosParser(new StringReader(strIncomingLinks));
                lbIncomingLinks.removeAll();
                on=incomingLinksParser.objectNames();
                e=on.elements();
                while(e.hasMoreElements()) {
                    lbIncomingLinks.add((e.nextElement()).toString());
                }
            }
            catch(ParseException error) {}
            // Attributes
            lbAttributeClasses.removeAll();
            com.objectspace.jgl.Set AttributeClasses=tfrObject.getCategories();
            e=AttributeClasses.elements();
            while(e.hasMoreElements()) {
                lbAttributeClasses.add((e.nextElement()).toString());
            }
            lbAttributes.removeAll();
        }
        else {
            // Superclasses
            lbSuperClasses.removeAll();
            ObjectNames on=new ObjectNames();
            on=tfrObject.isaSpec();
            java.util.Enumeration e=on.elements();
            while(e.hasMoreElements()) {
                lbSuperClasses.add((e.nextElement()).toString());
            }
            // Classes
            lbClasses.removeAll();
            on=tfrObject.inSpec();
            e=on.elements();
            while(e.hasMoreElements()) {
                lbClasses.add((e.nextElement()).toString());
            }
            if (tfrObject.hasInOmegaSpec()) {
                lbClasses.add(tfrObject.inOmegaSpec().toString());
            }
            // Instances
            lbInstances.removeAll();
            java.util.Enumeration e2=cache.elements();

            while(e2.hasMoreElements()) {
                tfrTmp=(TelosFrame)(e2.nextElement());
                on=tfrTmp.inSpec();
                e=on.elements();
                while(e.hasMoreElements()) {
                    if (((e.nextElement()).toString()).equals(tfrObject.objectName().toString()))
                        lbInstances.add(tfrTmp.objectName().toString());
                    break;
                }
            }
            // Subclasses
            lbSubClasses.removeAll();
            e2=cache.elements();
            while(e2.hasMoreElements()) {
                tfrTmp=(TelosFrame)(e2.nextElement());
                on=tfrTmp.isaSpec();
                e=on.elements();
                while(e.hasMoreElements()) {
                    if (((e.nextElement()).toString()).equals(tfrObject.objectName().toString()))
                        lbSubClasses.add(tfrTmp.objectName().toString());
                    break;
                }
            }
            // Attributes
            lbAttributes.removeAll();
            lbAttributeClasses.removeAll();
            com.objectspace.jgl.Set AttributeClasses=tfrObject.getCategories();
            e=AttributeClasses.elements();
            while(e.hasMoreElements()) {
                lbAttributeClasses.add((e.nextElement()).toString());
            }
            // Incoming links
            lbIncomingLinks.removeAll();
            e2=cache.elements();

            while (e2.hasMoreElements()) {
                tfrTmp = (TelosFrame)(e2.nextElement());
                AttributeClasses=tfrTmp.getCategories();
                java.util.Enumeration categories=AttributeClasses.elements();

                while (categories.hasMoreElements()) {
                    String name = categories.nextElement().toString();
                    com.objectspace.jgl.Set Property = tfrTmp.getPropertiesInCategory(new i5.cb.telos.frame.Label(name));
                    java.util.Enumeration en=Property.elements();
                    while(en.hasMoreElements()) {
                        Property pact=(Property)(en.nextElement());
                        String name2 = pact.getTarget().toString();
                        String name3 = tfrTmp.objectName().toString();
                        if ((name2).equals( tfrObject.objectName().toString() ))
                            lbIncomingLinks.add(name3 + "!" + pact.getLabel());
                    }
                }
            }
        }
    }

    /**
     *   Function: <b> work for the selected attributes</b> <BR>
     */
    public void SelectedAttributes() {
        java.util.Enumeration e=cache.elements();
        while(e.hasMoreElements()) {
            TelosFrame frame=(TelosFrame)(e.nextElement());
            if (tfObject.getText().equals(frame.objectName().toString())) {
                com.objectspace.jgl.Set setProp=frame.getPropertiesInCategory(new i5.cb.telos.frame.Label(lbAttributeClasses.getSelectedItem().toString()));
                lbAttributes.removeAll();
                java.util.Enumeration e2=setProp.elements();
                while(e2.hasMoreElements()) {
                    Property pact=(Property)(e2.nextElement());
                    lbAttributes.add(pact.getLabel().toString() + " : " + pact.getTarget().toString());
                }
                break;
            }
        }
    }

    /**
     *   Function: <b> open a Cache-Dialog</b> <BR>
     *
     *   @see i5.cb.workbench.FBCacheDialog
     */
    public void cacheClicked() {
        new FBCacheDialog(this);
    }


    /**
     *   Function: <b> transfer actual Objects to the Telos Editor </b> <BR>
     *
     *   @see i5.cb.workbench.TelosEditor
     */
    public void telosClicked() {
        if (cacheContents(tfObject.getText())) {
            java.util.Enumeration e=cache.elements();
            while(e.hasMoreElements()) {
                TelosFrame frame=(TelosFrame)(e.nextElement());
                if (tfObject.getText().equals(frame.objectName().toString())) {
                    CBI.getActiveTelosEditor().getTelosTextArea().setText(frame.toString());
                    break;
                }
            }
        }
        else {
            if (!CBI.getCBClient().isConnected()) {
                JOptionPane.showMessageDialog(this,"Not Connected!","Error",JOptionPane.ERROR_MESSAGE);
            }
            else {
                String sObject=CBI.getCBClient().getObject(tfObject.getText());
                CBI.getActiveTelosEditor().getTelosTextArea().setText(sObject);
                TelosParser parser=new TelosParser(new StringReader(sObject));
                try {
                    cache.pushFront(parser.telosFrame());
                }
                catch (ParseException e) {
                    JOptionPane.showMessageDialog(this,"Parse Error:" + e.toString(),"Parse Error",JOptionPane.ERROR_MESSAGE);
                }
                update(cache.size());
            }
        }
    }

    /**
     * @param strFrame String to check
     * @return <code>true</code>  if <code>strFrame</code> is in the Cache <BR>
     *           <code>false</code>  otherwise
     */

    private boolean cacheContents(String strFrame) {
        boolean ret=false;
        java.util.Enumeration e=cache.elements();
        while(e.hasMoreElements()) {
            TelosFrame frame=(TelosFrame)(e.nextElement());
            if (strFrame.equals(frame.objectName().toString())) {
                ret=true;
                break;
            }
        }
        return ret;
    }


    /**
     *   Function: <b> work for the selected Items of the List Box </b> <BR>
     *
     *     *  called by the PopupMenu
     *
     *   @param menId MenuIdentification Number
     */

    public void popBrowse(int menId) {
        switch(menId) {
            case 0:
                if (lbSuperClasses.getSelectedIndex()!=-1) {
                    tfObject.setText(lbSuperClasses.getSelectedItem().toString());
                    updateClicked();
                }
                break;
            case 1:
                if (lbClasses.getSelectedIndex()!=-1) {
                    tfObject.setText(lbClasses.getSelectedItem().toString());
                    updateClicked();
                }
                break;
            case 2:
                if (lbIncomingLinks.getSelectedIndex()!=-1) {
                    tfObject.setText(lbIncomingLinks.getSelectedItem().toString());
                    updateClicked();
                }
                break;
            case 3:
                if (lbAttributeClasses.getSelectedIndex()!=-1) {
                    /* Do nothing here, operation not allowed
                    tfObject.setText(lbAttributeClasses.getSelectedItem().toString());
                    updateClicked();
                     */
                }
                break;
            case 4:
                if (lbAttributes.getSelectedIndex()!=-1) {
                    String sTmp=lbAttributes.getSelectedItem().toString();
                    StringTokenizer stTmp=new StringTokenizer(sTmp," : ");
                    stTmp.nextToken();
                    tfObject.setText(stTmp.nextToken());
                    updateClicked();
                }
                break;
            case 5:
                if (lbSubClasses.getSelectedIndex()!=-1) {
                    tfObject.setText(lbSubClasses.getSelectedItem().toString());
                    updateClicked();
                }
                break;
            case 6:
                if (lbInstances.getSelectedIndex()!=-1) {
                    tfObject.setText(lbInstances.getSelectedItem().toString());
                    updateClicked();
                }
                break;
        }
    }



    /**
     * Delegates to the selected element in the TelosEditor
     */

    public void popTelos(int menId) {
        String sFrame=null;
        switch(menId) {
            case 0:
                if (lbSuperClasses.getSelectedIndex()!=-1) {
                    sFrame=lbSuperClasses.getSelectedItem().toString();
                }
                break;
            case 1:
                if (lbClasses.getSelectedIndex()!=-1) {
                    sFrame=lbClasses.getSelectedItem().toString();
                }
                break;
            case 2:
                if (lbIncomingLinks.getSelectedIndex()!=-1) {
                    sFrame=lbIncomingLinks.getSelectedItem().toString();
                }
                break;
            case 3:
                if (lbAttributeClasses.getSelectedIndex()!=-1) {
                    /* Do nothing, operation is not allowed
                    sFrame=lbAttributeClasses.getSelectedItem().toString();
                     */
                }
                break;
            case 4:
                if (lbAttributes.getSelectedIndex()!=-1) {
                    String sTmp=lbAttributes.getSelectedItem().toString();
                    StringTokenizer stTmp=new StringTokenizer(sTmp," : ");
                    stTmp.nextToken();
                    sFrame=stTmp.nextToken();
                }
                break;
            case 5:
                if (lbSubClasses.getSelectedIndex()!=-1) {
                    sFrame=lbSubClasses.getSelectedItem().toString();
                }
                break;
            case 6:
                if (lbInstances.getSelectedIndex()!=-1) {
                    sFrame=lbInstances.getSelectedItem().toString();
                }
                break;
        }
        if (!CBI.getCBClient().isConnected()) {
            JOptionPane.showMessageDialog(this,"Not Connected!","Error",JOptionPane.ERROR_MESSAGE);
        }
        else {
            if (sFrame==null)
                sFrame=CBI.getCBClient().getObject(tfObject.getText());
            CBI.getActiveTelosEditor().getTelosTextArea().setText(sFrame);
        }
    }



    /**
     *   Function: <b> opens the cacheDialog </b> <BR>
     *
     *   @param target parent Dialog
     */
    public void cacheDialog(Dialog target) {
        java.util.Enumeration e = cache.elements();
        while (e.hasMoreElements()) {
            ((FBCacheDialog)target).getCacheList().addSort((((TelosFrame)(e.nextElement())).objectName()).toString());
        }
    }
}



