/*
The ConceptBase.cc Copyright

Derived from ConceptBase.cc, originally created by the ConceptBase Team under a FreeBSD-style license.

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
*   <b> InstanceDialog for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.FrameBrowser
*   @see i5.cb.workbench.CBIva
*/

package i5.cb.workbench;

import java.awt.*;
import java.awt.event.*;
import java.util.Enumeration;

import javax.swing.*;

/**  <BR>
*   Class:    <b> InstanceDialog for CBIva  </b><BR>
*   Function: <b> representing an "Display Instance"-window. </b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see java.awt.Dialog
*   @see java.awt.event.ActionListener
*   @see java.awt.event.MouseListener
*   @see java.awt.event.ItemListener
*   @see i5.cb.workbench.CBIva
*/

public class  InstanceDialog extends JInternalFrame implements ActionListener,MouseListener,ItemListener {

    private CBIva    CBI;

    private JTextField     tfTextField;
    private RList          list;
    private JButton        okButton;
    private JButton        cancelButton;
    private JButton        editorButton;
    private JPopupMenu     contextMenu;
    private JComboBox      history;


    /**
    *   <b> Constructor  </b><BR>
    *
    *   @param CBI parent CBIva
    *   @see i5.cb.workbench.CBIva
    */
    public InstanceDialog(CBIva CBI) {
        super("Display Instances",true,true,true,true);
        Dimension dimSize=new Dimension(400,300);
        this.setPreferredSize(dimSize);
        this.setMinimumSize(new Dimension(350,150));
        this.setSize(new Dimension(400,300));


        this.getContentPane().setLayout(new BorderLayout());

        this.CBI=CBI;

        JPanel header=new JPanel();
        header.setLayout(new GridLayout(1,4));
        getContentPane().add(header, BorderLayout.NORTH);

        JLabel label = new JLabel(" Class: ");
        header.add(label);

        tfTextField=new JTextField("Class",30);
        tfTextField.addActionListener(this);
        header.add(tfTextField);

        JLabel historyLabel = new JLabel("History");
        header.add(historyLabel);

        history  = new JComboBox();
        history.addItemListener(this);
        addHistoryLine("Class");

        header.add(history);

        contextMenu  = new JPopupMenu();
        JMenuItem mi1 = new JMenuItem("Display Instances");
        mi1.addActionListener(this);
        contextMenu.add(mi1);

        JMenuItem mi2 = new JMenuItem("Telos Editor");
        mi2.addActionListener(this);
        contextMenu.add(mi2);

        JMenuItem mi3 = new JMenuItem("Add to Telos Editor");
        mi3.addActionListener(this);
        contextMenu.add(mi3);

        list = new RList(contextMenu);
        list.addMouseListener(this);
        list.add("Class");
        list.setSelectionMode(ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);

        this.getContentPane().add(BorderLayout.CENTER,list.getOnScrollPane());


        JPanel buttonPanel = new JPanel();
        buttonPanel.setLayout(new GridLayout(1,3));
        this.getContentPane().add(BorderLayout.SOUTH,buttonPanel);

        okButton = new JButton("OK");
        editorButton = new JButton("Telos Editor");
        cancelButton = new JButton("Cancel");

        okButton.addActionListener(this);
        cancelButton.addActionListener(this);
        editorButton.addActionListener(this);


        buttonPanel.add("1",okButton);
        buttonPanel.add("2",editorButton);
        buttonPanel.add("3",cancelButton);


        enableEvents(AWTEvent.MOUSE_EVENT_MASK);
    }


    /**
    *   Function: <b> Excecute the Commands </b> <BR>
    *
    *   @param event the ActionEvent for the Command
    *   @see java.awt.event.ActionEvent
    */
    public void actionPerformed(ActionEvent event) {
        Object source = event.getSource();
        String command = event.getActionCommand();

        // Button "OK" or Enter in the text field are pressed
        if(source == okButton || source == tfTextField) {
            String input= tfTextField.getText();
            addHistoryLine(input);
            this.findInstances(input);
            // this.list.repaintScrollPane();

        }

        // Cancel button pressed
        else if(source == cancelButton) {
            setVisible(false);
            this.dispose();
        }


        // call Telos Editor if "Telos Editor" button is pressed or
        // the menu item "Telos Editor" of popup menu is choosen
        else if(source == editorButton || command.equals("Telos Editor")) {
            Object[] objects=list.getSelectedItems();
            if(objects.length>1) {
                StringBuffer sb=new StringBuffer();
                for(int i=0;i<objects.length;i++) {
                    sb.append(CBI.getCBClient().getObject(objects[i].toString())+System.lineSeparator());
                }
                CBI.getActiveTelosEditor().getTelosTextArea().setText(sb.toString());
            }
            else {
                Object selectedItem=list.getSelectedItem();
                if(selectedItem != null)
                    CBI.getActiveTelosEditor().getTelosTextArea().setText(CBI.getCBClient().
                        getObject(selectedItem.toString()));
            }
        }

        else if(command.equals("Add to Telos Editor")) {
            Object[] objects=list.getSelectedItems();
            String oldtext=CBI.getActiveTelosEditor().getTelosTextArea().getText();
            if(objects.length>1) {
                StringBuffer sb=new StringBuffer();
                for(int i=0;i<objects.length;i++) {
                    sb.append(CBI.getCBClient().getObject(objects[i].toString())+System.lineSeparator());
                }
                CBI.getActiveTelosEditor().getTelosTextArea().setText(oldtext+System.lineSeparator()+sb.toString());
            }
            else {
                Object selectedItem=list.getSelectedItem();
                if(selectedItem != null)
                    CBI.getActiveTelosEditor().getTelosTextArea().setText(oldtext+System.lineSeparator()+CBI.getCBClient().getObject(selectedItem.toString()));
            }
        }

        // "Display Instances" item of popup menu is selected
        else if (command.equals("Display Instances")) {
            String selectedItem=list.getSelectedItem().toString();
            if(selectedItem != null) {
                addHistoryLine(selectedItem);
                this.findInstances(selectedItem);
            }
        }


    }


    /**
    *   Function: <b> Excecute the Commands </b> <BR>
    *
    *   @param event the ActionEvent for the Command
    *   @see java.awt.event.ActionEvent
    */
    public void mouseClicked(MouseEvent event) {
        Object source = event.getSource();
        if(source == list &&  event.getClickCount()>1) {
            String selectedItem=list.getSelectedItem().toString();
            if(selectedItem != null) {
                addHistoryLine(selectedItem);
                findInstances(selectedItem);
            }
        }
    }


    /**
    *   Function: <b> Excecute the Commands </b> <BR>
    *
    *   @param event the ActionEvent for the Command
    *   @see java.awt.event.ActionEvent
    */
    public void mouseEntered(MouseEvent event) {}
    /**
    *   Function: <b> Excecute the Commands </b> <BR>
    *
    *   @param event the ActionEvent for the Command
    *   @see java.awt.event.ActionEvent
    */
    public void mouseExited(MouseEvent event) {}

    /**
    *   Function: <b> Excecute the Commands </b> <BR>
    *
    *   @param e the ActionEvent for the Command
    *   @see java.awt.event.ActionEvent
    */
    public void mousePressed(MouseEvent e) {
        if (e.isPopupTrigger() && e.getSource()==list) {
            contextMenu.show(e.getComponent(), e.getX(), e.getY());
        }
    }

    /**
    *   Function: <b> Excecute the Commands </b> <BR>
    *
    *   @param event the ActionEvent for the Command
    *   @see java.awt.event.ActionEvent
    */
    public void mouseReleased(MouseEvent event) {}

    /**
    *   Function: <b> Processed the choice of a history object </b> <BR>
    *
    *   @param e the corresponding event
    *  @see java.awt.event.ItemListener
    *  @see java.awt.event.ItemEvent
    */
    public void itemStateChanged(ItemEvent e) {
        // if an element of history list is selected
        if(e.getSource() == history ) {
            // insert it in the text field
            tfTextField.setText(history.getSelectedItem().toString());
            tfTextField.selectAll();
        }

    }

    /**
    *   Function: <b> Make a list of objects, which has been
    *         returned from cbClient.findInstances   </b> <BR>
    *
    *   @param object a object's name
    */
    void findInstances(String object) {

        // Get the list of objects names
        String result=CBI.getCBClient().findInstances(object);
        tfTextField.setText(object);
        Enumeration en = CBI.getCBClient().enParseObjectNames(result);

        // remove all old  entries from the list
        list.removeAll();
        // and add new ones
        while (en.hasMoreElements()) {
            list.addSort(en.nextElement().toString());
        }
        list.updateUI();
    }

    /**
    *   Function: <b> Inserts an object to the HistoryLine.</b> <BR>
    *
    *  @param item the input line, which should be added
    *  @see java.awt.List
    */
    private void addHistoryLine(String item) {

        int i;

        int count = history.getItemCount();
        // if there's such element in the history list already then return
        for(i=0;i<count;i++)
            if(history.getItemAt(i).toString().equals(item))
                return;
        // insert this item in the history list
        history.addItem(item);
        if(count==0) {
            validate();
        }
    }
}
