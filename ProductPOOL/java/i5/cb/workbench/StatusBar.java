/*
The ConceptBase.cc Copyright

Copyright 1987-2021 The ConceptBase Team. All rights reserved.

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
*   <b> StatusBar for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.CBIva
*/
package i5.cb.workbench;

import i5.cb.Contract;
import i5.cb.CBConfiguration;

import java.awt.*;

import javax.swing.JPanel;
import javax.swing.JTextField;



/**  <BR>
*   Class:    <b> StatusBar for CBIva  </b><BR>
*   Function: <b> Creates the StatusBar for CBIva </b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see javax.swing.JPanel
*   @see i5.cb.workbench.CBIva
*/
public class StatusBar extends JPanel {

    private String displayedTime="00:00";
    private String displayedModule="oHome";
    private String displayedServer=null;
    private CBIVersion displayedVersion=null;
    private Color colStatusBackground=Color.lightGray;

    /**
     * StatusLabel (zeigt Zustand CONNECTED/DISCONNECTED an)
     */
    private JTextField tfStatusLabel;


   /**
     * return the module name displayed in status Bar of CBIva
     *
     * @return  module name displayed in status Bar of CBIva
     */

    public String getDisplayedModule() {
        return displayedModule;
    }

    /**
     * setzt den Status auf CONNECTED/DISCONNECTED
     *
     * @param bConnected true, wenn CONNECTED, sonst false
     */
    public void setStatus(boolean bConnected) {
        if (bConnected) {
            tfStatusLabel.setText("Connected");
            tfStatusLabel.setToolTipText(null);
            tfStatusLabel.setBackground(Color.green); // gruener Hintergrund, wenn CONNECTED
        }
        else {
            tfStatusLabel.setText("Disconnected");
            tfStatusLabel.setToolTipText(null);
            tfStatusLabel.setBackground(Color.red);   // roter Hintergrund, wenn nicht CONNECTED
            displayedServer = null;
        }
        tfStatusLabel.paintImmediately(tfStatusLabel.getBounds());
    }

    public void setStatus(String host, String port) {
        tfStatusLabel.setToolTipText(host + ":" + port);
        tfStatusLabel.setBackground(Color.green); // gruener Hintergrund, wenn CONNECTED
        if (host.equals("localhost") && port.equals("4001"))
           displayedServer = "Connected";
        else if (host.equals(CBConfiguration.getPublicCBserverHost()) && port.equals(CBConfiguration.getPublicCBserverPort()))
           displayedServer = "Connected";
        else if (port.equals("4001"))
           displayedServer = host;
        else
           displayedServer = host + ":" + port;
        tfStatusLabel.setText(displayedServer);
        tfStatusLabel.paintImmediately(tfStatusLabel.getBounds());
    }

    public void setStatus(String host, int port) {
        this.setStatus(host,Integer.toString(port));
    }

    public void setStatus(String statustext) {
        tfStatusLabel.setToolTipText(statustext);
        tfStatusLabel.setText(statustext);
        tfStatusLabel.setBackground(Color.orange); // orange Hintergrund, wenn Connecting
        tfStatusLabel.paintImmediately(tfStatusLabel.getBounds());
    }


    /**
     * Feld fuer kurze Meldungen
     *
     * @see java.awt.Label
     */
    private JTextField tfMessageField;

    /**
     * Feld fuer Zeitanzeige
     *
     * @see java.awt.TextField
     */
    JTextField tfTime;

    /**
     * Field fuer transaction time
     *
     * @see java.awt.TextField
     */
    private JTextField tfTATime;


    /**
     * Field for the current module
     *
     * @see java.awt.TextField
     */
    private JTextField tfModule=new JTextField("none");

    /**
     * Field to indicate linked tool like CBGraph
     *
     * @see java.awt.TextField
     */
    private JTextField tfLinkedTool = new JTextField(8);


    public void setLinkedTool(String toolname) {
        tfLinkedTool.setText(toolname);
        tfLinkedTool.setBackground(Color.white); // green background when linked to a tool
    }

    public void setModule(String s) {
        displayedModule = s;
        tfModule.setText("Module: " + displayedModule);
        insertMessage("Module switched to " + displayedModule);
    }

    private JTextField tfVersion=new JTextField();

    public void setVersion(CBIVersion ver) {
        displayedVersion=ver;
        if (displayedVersion.getName().equals(CBIVersion.Now)) {
          tfVersion.setText("Version: "+displayedVersion.getName() + " -- " + displayedTime);
          tfVersion.setBackground(colStatusBackground);
        }
        else {
          tfVersion.setText("Rollback: "+ displayedVersion.toString());
          tfVersion.setBackground(Color.orange);
        }
        insertMessage("Rollback time changed to "+displayedVersion.getName());
    }

    public void setTime(String sTime) {
        displayedTime = sTime;
        if (displayedVersion==null)
          tfVersion.setText(displayedTime);
        else if (displayedVersion.getName().equals(CBIVersion.Now)) {
          tfVersion.setText("Version: "+displayedVersion.getName() + " -- " + displayedTime);
          tfVersion.setBackground(colStatusBackground);
        }
        else {
          tfVersion.setText("Rollback: " + displayedVersion.toString());
          tfVersion.setBackground(Color.orange);
        }
    }

    public StatusBar(String sStart) {
        super();

        tfStatusLabel = new JTextField(11); // Statusanzeige
        // tfStatusLabel.setHorizontalAlignment(JTextField.CENTER);
        tfStatusLabel.setEditable(false);
        tfModule.setEditable(false);
        tfModule.setBackground(colStatusBackground);
        tfMessageField = new JTextField(sStart);
        tfMessageField.setBackground(colStatusBackground);
        tfMessageField.setEditable(false);
        tfLinkedTool.setEditable(false);
        tfLinkedTool.setBackground(colStatusBackground);
        tfLinkedTool.setText(" ");

/* not used anymore
        tfTime = new JTextField("12:00",5);
        tfTime.setBackground(colStatusBackground);
        tfTime.setEditable(false);

        tfTATime = new JTextField("0.00s",5);
        tfTATime.setBackground(colStatusBackground);
        tfTATime.setEditable(false);
*/

        TimeThread tt=new TimeThread(this);
        tt.start();


        tfVersion.setBackground(colStatusBackground);
        tfVersion.setEditable(false);
        tfVersion.setToolTipText("Rollback time");
        this.setVersion(new CBIVersion());

        // zunaecht noch:
        this.setLayout(new BorderLayout());

        this.add(tfStatusLabel,"West");

        this.add(tfMessageField,"Center");

        JPanel south=new JPanel();

        //south.setLayout(new GridLayout(1,4));
        south.setLayout(new BorderLayout());

        //south.add(tfStatusLabel);

        // the south status line now displayes only version and module; tfTime in integrated into tfVersion
        south.add(tfVersion,"West");
        south.add(tfModule,"Center");
        south.add(tfLinkedTool,"East");
        // south.add(tfTime);
        // south.add(tfTATime);

        this.add(south, "South");

    }


    /**
     * zeigt den uebergebenen Text in der Statuszeile an
     *
     * @param sText der anzuzeigende Text
     *
     * @see java.awt.Label#setText
     * @see #tfMessageField
     */
    public void insertMessage(String sText) {
        Contract.requires("StatusBar.insertMessage(String)", (sText!=null));
        tfMessageField.setText(sText);
  //      tfMessageField.paintImmediately(tfMessageField.getBounds());
        this.repaint();
    }

    /**
    * Zeigt im TransactionTime-Feld die angegebene Zeit an
    * @param iMilliSeconds Transaktionszeit in Millisekunden
    * */
    public void setTATime(long iMilliSeconds) { // not used anymore
    //    tfTATime.setText(Double.toString(iMilliSeconds/1000.0));
    }

}

