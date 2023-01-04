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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
/*
 * CBConnectionDialog.java
 *
 * Created on 19. M?rz 2002, 09:20
 */

package i5.cb.graph.cbeditor.components;

import i5.cb.CBConfiguration;
import i5.cb.graph.cbeditor.CBConstants;
import i5.cb.graph.cbeditor.CBEditor;

import java.awt.*;
import java.util.ResourceBundle;

import javax.swing.*;
import javax.swing.text.*;

/** A Dialog shown when the user whants to open a new connection to a ConceptBase server
 *
 * @author Schoeneb
 */
public class CBConnectionDialog extends javax.swing.JDialog {

    private JLabel m_lAdress;

    private JLabel m_LPort;

    private JLabel m_lStartObject;

    private JLabel m_lGraphPalette;
    
    private JLabel m_lModule;

    JTextField m_TFAddress;

    private DefaultStyledDocument m_DAddress;

    private DefaultStyledDocument m_DPort;

    JTextField m_TFPort;

    private CBEditor m_owner;

    private JComboBox m_objectBox;

    private JComboBox m_paletteBox;
    
    private JComboBox m_moduleBox;

    CBConnectionDialog(CBEditor parent, boolean invokedByConnectionDLGCommand){
        super(parent, true);

        setLocation(100,100);

        ConnectionDLGCommand.setOwner(this);
        ConnectionDLGCommand.setCBEditor(parent);

        m_owner = parent;

        initComponents();

        ResourceBundle bundle = ResourceBundle.getBundle(CBConstants.CB_BUNDLE_NAME, getLocale());

        ConnectionDLGCommand connectCmd=new ConnectionDLGCommand();
        m_connectButton.addActionListener(connectCmd );
        m_connectButton.setText(bundle.getString("ConnectionDialog_Connect") );

        String[] asInitObjects = {"Class"};
        m_objectBox = new JComboBox(asInitObjects);
        m_objectBox.setEditable(true);

        String[] asPalette={CBConstants.DEFAULT_PALETTE};
        m_paletteBox = new JComboBox(asPalette);
        m_paletteBox.setEditable(true);
        
        String[] asInitModule = {CBConstants.CB_HOME_MODULE};
        m_moduleBox = new JComboBox(asInitModule);
        m_moduleBox.setEditable(true);

        setTitle(bundle.getString("ConnectionDialog_Title") );

        Image image = Toolkit.getDefaultToolkit().getImage(
        this.getClass().getResource(CBConstants.CB_RESOURCE_DIR + "/dialog_server.gif"));
        JLabel icon = new JLabel(new ImageIcon(image));

        m_lAdress = new JLabel(bundle.getString("ConnectionDialog_Adress") + ":");
        m_LPort = new JLabel(bundle.getString("ConnectionDialog_Port") + ":");

        m_TFAddress = new JTextField(20);
        m_TFAddress.addActionListener(connectCmd );
        m_DAddress = new AddressDocument();
        m_TFAddress.setDocument(m_DAddress);

        m_TFPort = new JTextField(5);
        m_TFPort.addActionListener(connectCmd );
        m_DPort = new PortNumDocument();
        m_TFPort.setDocument(m_DPort);


        GridBagLayout g = (GridBagLayout)adressPanel.getLayout();
        GridBagConstraints c = new GridBagConstraints();
        c.gridx = 0;
        c.gridy = 0;
        c.gridheight = 2;
        c.fill = GridBagConstraints.BOTH;
        c.weightx = 1;
        c.weighty = 1;
        c.insets = new Insets(10,10,10,10);
        //c.ipadx = 10;
        //c.ipady = 10;
        g.setConstraints(icon, c);
        adressPanel.add(icon);

        c = new GridBagConstraints();
        c.gridx = 1;
        c.gridy = 1;
        c.fill = GridBagConstraints.BOTH;
        c.weightx = 1;
        c.weighty = 1;
        //c.ipadx = 10;
        //c.ipady = 10;
        c.insets = new Insets(5,10,10,10);
        g.setConstraints(m_LPort, c);
        adressPanel.add(m_LPort);

        c = new GridBagConstraints();
        c.gridx = 1;
        c.gridy = 0;
        c.fill = GridBagConstraints.BOTH;
        c.weightx = 1;
        c.weighty = 1;
        c.insets = new Insets(10,10,5,10);
        //c.ipadx = 10;
        //c.ipady = 10;
        g.setConstraints(m_lAdress, c);
        adressPanel.add(m_lAdress);

        c = new GridBagConstraints();
        c.gridx = 2;
        c.gridy = 0;
        c.fill = GridBagConstraints.HORIZONTAL;
        c.weightx = 1;
        c.weighty = 1;
        c.insets = new Insets(10,10,5,10);
        //c.ipadx = 10;
        //c.ipady = 10;
        g.setConstraints(m_TFAddress, c);
        adressPanel.add(m_TFAddress);

        c = new GridBagConstraints();
        c.gridx = 2;
        c.gridy = 1;
        c.weightx = 1;
        c.weighty = 1;
        c.insets = new Insets(5,10,10,10);
        //c.ipadx = 10;
        //c.ipady = 10;
        c.fill = GridBagConstraints.HORIZONTAL;
        g.setConstraints(m_TFPort, c);
        adressPanel.add(m_TFPort);

        //The second tab
        image = Toolkit.getDefaultToolkit().getImage(
        this.getClass().getResource(CBConstants.CB_RESOURCE_DIR + "/dialog_initobj.gif"));
        icon = new JLabel(new ImageIcon(image));
        m_lStartObject = new JLabel(bundle.getString("ConnectionDialog_InitialObject") + ":");
        m_lGraphPalette = new JLabel(bundle.getString("ConnectionDialog_GraphicalPalette") + ":");
        m_lModule = new JLabel(bundle.getString("ConnectionDialog_Module") + ":");

        g = new GridBagLayout();
        initialObjPanel.setLayout(g);
        c = new GridBagConstraints();

        //c.ipadx = 10;
        //c.ipady = 10;
        c.insets = new Insets(10,10,10,10);
        g.setConstraints(icon, c);

        initialObjPanel.add(icon);

        c = new GridBagConstraints();
        c.gridx = 1;
        c.gridy = 0;
        c.insets = new Insets(10,10,10,10);
        g.setConstraints(m_lStartObject, c);
        initialObjPanel.add(m_lStartObject);

        c = new GridBagConstraints();
        c.gridx = 1;
        c.gridy = 1;
        c.insets = new Insets(10,10,10,10);
        g.setConstraints(m_lGraphPalette, c);
        initialObjPanel.add(m_lGraphPalette);
        
        c = new GridBagConstraints();
        c.gridx = 1;
        c.gridy = 2;
        c.insets = new Insets(10,10,10,10);
        g.setConstraints(m_lModule, c);
        initialObjPanel.add(m_lModule);

        c = new GridBagConstraints();
        c.gridx = 3;
        c.gridy = 0;
        c.insets = new Insets(10,10,10,10);
        c.fill = GridBagConstraints.HORIZONTAL;
        c.weightx = 1;
        g.setConstraints(m_objectBox, c);
        initialObjPanel.add(m_objectBox);

        c = new GridBagConstraints();
        c.gridx = 3;
        c.gridy = 1;
        c.insets = new Insets(10,10,10,10);
        c.fill = GridBagConstraints.HORIZONTAL;
        c.weightx = 1;
        g.setConstraints(m_paletteBox, c);
        initialObjPanel.add(m_paletteBox);
        
        c = new GridBagConstraints();
        c.gridx = 3;
        c.gridy = 2;
        c.insets = new Insets(10,10,10,10);
        c.fill = GridBagConstraints.HORIZONTAL;
        c.weightx = 1;
        g.setConstraints(m_moduleBox, c);
        initialObjPanel.add(m_moduleBox);

        if(invokedByConnectionDLGCommand){
            try{
                setHost(ConnectionDLGCommand.getHost() );
                setPort(ConnectionDLGCommand.getPort() );
            }catch(BadLocationException bde){}
            m_objectBox.setSelectedItem(ConnectionDLGCommand.getSelectedTelosObject() );
            m_paletteBox.setSelectedItem(ConnectionDLGCommand.getSelectedPalette() );
        }


         java.awt.Dimension screenSize = java.awt.Toolkit.getDefaultToolkit().getScreenSize();
        pack();
        setLocation((screenSize.width-getSize().width)/2,(screenSize.height-getSize().height)/2);

        String[] visitedServers=CBConfiguration.getRecentServers();
        if(visitedServers.length>=2) {
            try {
                setHost(visitedServers[0]);
                setPort(visitedServers[1]);
            }
            catch(Exception e) {}
        }


    }

    /** Creates new form CBConnectionDialog
     * @param parent the CBeditor this dialog belongs to
     */
    public CBConnectionDialog(CBEditor parent) {
        this(parent, false);

    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    private void initComponents() {//GEN-BEGIN:initComponents
        java.awt.GridBagConstraints gridBagConstraints;

        jTabbedPane1 = new javax.swing.JTabbedPane();
        adressPanel = new javax.swing.JPanel();
        initialObjPanel = new javax.swing.JPanel();
        m_connectButton = new javax.swing.JButton();

        getContentPane().setLayout(new java.awt.GridBagLayout());

        addWindowListener(new java.awt.event.WindowAdapter() {
            public void windowClosing(java.awt.event.WindowEvent evt) {
                closeDialog(evt);
            }
        });

        adressPanel.setLayout(new java.awt.GridBagLayout());

        jTabbedPane1.addTab(m_owner.getCBBundle().getString("ConnectionDialog_Adress"), adressPanel);

        jTabbedPane1.addTab(m_owner.getCBBundle().getString("ConnectionDialog_InitialObject"), initialObjPanel);

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 0;
        gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
        gridBagConstraints.weightx = 1.0;
        gridBagConstraints.weighty = 1.0;
        getContentPane().add(jTabbedPane1, gridBagConstraints);

        m_connectButton.setText("jButton1");
        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 1;
        gridBagConstraints.insets = new java.awt.Insets(10, 10, 10, 10);
        getContentPane().add(m_connectButton, gridBagConstraints);

    }//GEN-END:initComponents

    /** Closes the dialog */
    private void closeDialog(java.awt.event.WindowEvent evt) {//GEN-FIRST:event_closeDialog
        setVisible(false);
        dispose();
    }//GEN-LAST:event_closeDialog

    /**
     * @param args the command line arguments
     */
    //public static void main(String args[]) {
    //new CBConnectionDialog(new javax.swing.JFrame(), true).show();
    //}

    /**
     *  Gets the host attribute of the CBConnectionDialog object
     *
     * @return    The host value
     */
    String getHost() {
        return m_TFAddress.getText();
    }
    //getHost

    void setHost(String host)throws BadLocationException{
        SimpleAttributeSet attrs = new SimpleAttributeSet();
        StyleConstants.setFontFamily(attrs, "SansSerif");
        StyleConstants.setFontSize(attrs, 12);
        m_DAddress.insertString(0, host, attrs);
    }

    /**
     *  Gets the port attribute of the CBConnectionDialog object
     *
     * @return    The port value
     */
    String getPort() {
        return m_TFPort.getText();
    }
    //getPort

    void setPort(String port) throws BadLocationException{
        SimpleAttributeSet attrs = new SimpleAttributeSet();
        StyleConstants.setFontFamily(attrs, "SansSerif");
        StyleConstants.setFontSize(attrs, 12);
        m_DPort.insertString(0, port, attrs);

    }

    /**
     *  Gets the selectedObject attribute of the CBConnectionDialog object
     *
     * @return    The selectedObject value
     */
    Object getSelectedObject() {
        return m_objectBox.getSelectedItem();
    }

    /**
     * Return the value entered in the combo box for graphical palette.
     */
    Object getGraphicalPalette() {
        return m_paletteBox.getSelectedItem();
    }
    
    /**
     * Return the value entered in the combo box for module.
     */
    Object getModule() {
    	return m_moduleBox.getSelectedItem();
    }


    /**
     * If a connection to a conceptbase server could be established the dialog is extended by an
     * editable combobox asking for the object to display initially
     *
     * @param  comboBoxItems  Description of the Parameter
     */
    private void setStartingComboItems(String[] comboBoxItems) {
        m_objectBox.removeAllItems();
        for (int i = 0; i < comboBoxItems.length; i++) {
            m_objectBox.addItem(comboBoxItems[i]);
        }
        if (comboBoxItems.length > 0) {
            m_objectBox.setSelectedIndex(0);
        }
        //m_connectButton.setEnabled(false);

    }
    //setStartingComboItems

    private void setPaletteComboItems(String[] comboBoxItems) {
        m_paletteBox.removeAllItems();
        for (int i = 0; i < comboBoxItems.length; i++) {
            m_paletteBox.addItem(comboBoxItems[i]);
        }
        if (comboBoxItems.length > 0) {
            m_paletteBox.setSelectedIndex(0);
        }//m_connectButton.setEnabled(false);

    }
    //setStartingComboItems

    /**
     * this document only accepts numbers (0..9) as input. It might generate a beep
     * if someone tries to input anything else
     *
     * @author schoeneb
     * @created 07 March 2002
     */
    public class PortNumDocument extends DefaultStyledDocument {

        /**
         * Calls the method of the superclass if the input is a number and
         * generates a beep if the input is something else
         *
         * @param  offs                      an <code>int</code> value
         * @param  str                       a <code>String</code> value
         * @param  a                         an <code>AttributeSet</code> value
         * @exception  BadLocationException  if an error occurs
         */
        public void insertString(int offs, String str,
        AttributeSet a) throws BadLocationException {
            if (str.matches("[0-9]+") &&
            ((this.getLength() + str.length()) <= 5)) {
                super.insertString(offs, str, a);
            } else {
                Toolkit.getDefaultToolkit().beep();
            }
            // end of else
        }

    }
    //PortNumDocument


    /**
     * This class suggests completions that fit to
     * the user input (just like most web-browsers do).
     *
     * @author schoeneb
     * @created 07 March 2002
     */
    public class AddressDocument extends DefaultStyledDocument {

        /** Checks if there are any recend connections that fit to what the user typed in so far and makes suggestions if it finds something
         * @param offs  Description of the Parameter
         * @param str   Description of the Parameter
         * @param a     Description of the Parameter
         */
        public void insertString(int offs, String str,
        AttributeSet a) {

            String[] visitedServers= CBConfiguration.getRecentServers();

            try {
                String text = this.getText(0, this.getLength()) + str;

                for (int i = 0;i < (visitedServers.length / 2); i++) {

                    if (visitedServers[i * 2].matches(text + ".+")) {

                        int iCursorPos =
                        m_DAddress.getLength();
                        SimpleAttributeSet attr =
                        new SimpleAttributeSet();

                        this.remove(0,
                        m_DAddress.getLength());
                        super.insertString(0, visitedServers[i * 2], attr);

                        m_TFAddress.select(
                        iCursorPos + 1,
                        m_DAddress.getLength());

                        if (m_DPort.getLength()
                        == 0) {
                            m_DPort.insertString(
                            0
                            , visitedServers[(i * 2) + 1]
                            , attr);
                        }// end of if ((m_DPort.getLength() = 0))
                        String[] startingObjs = CBConfiguration.getStartingObjects(
                        CBConnectionDialog.this.getHost(),
                        CBConnectionDialog.this.getPort()
                        );
                        if(startingObjs.length != 0){
                            CBConnectionDialog.this.setStartingComboItems(startingObjs);
                        }
                        String[] graphPalettes = CBConfiguration.getGraphicalPalettes(
                        CBConnectionDialog.this.getHost(),
                        CBConnectionDialog.this.getPort()
                        );
                        if(graphPalettes.length != 0){
                            CBConnectionDialog.this.setPaletteComboItems(graphPalettes);
                        }
                        return;

                    }
                    // end of else

                }
                // end of for (int i; i<m_visitedServers; i++)

                //if we reach this point nothing was found
                super.insertString(offs, str, a);
            } catch (BadLocationException ble) {
                java.util.logging.Logger.getLogger("global").fine(ble.getMessage());
            }
            // end of catch

        }
        //insertString

    }
    //AddressDocument

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JPanel initialObjPanel;
    private javax.swing.JPanel adressPanel;
    private javax.swing.JButton m_connectButton;
    private javax.swing.JTabbedPane jTabbedPane1;
    // End of variables declaration//GEN-END:variables

}
