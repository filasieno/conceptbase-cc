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
/**
*   <b> ConnectDialog for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.CBIva
*/
package i5.cb.workbench;

import java.awt.*;
import java.util.Vector;

import javax.swing.*;

/**  <BR>
*   Class:    <b> ConnectDialog for CBIva  </b><BR>
*   Function: <b> Dialog to make a connection to a ConceptBase-Server </b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see java.awt.Dialog
*   @see i5.cb.workbench
*   @see i5.cb.workbench.CBIva
*/
public class ConnectDialog extends JDialog {

    /**
     * ComboBox for Host
     */
    private JComboBox jcbHost;


    /**
    *   @see #jcbHost
    *   @return the String in the Textfield jcbHost
    */
    public String getHost() {
        return jcbHost.getSelectedItem().toString();
    }

    /**
     * ComboBox for Port
     */
    private JComboBox jcbPort;

    /**
    *   @see #jcbPort
    *   @return the Integer-Value of the Textfield jcbPort
    *
    */
    public int getPort() {
        return Integer.parseInt(jcbPort.getSelectedItem().toString());
    }

    /**
     * return the port number as String
     */
    public String getPortString() {
        return jcbPort.getSelectedItem().toString();
    }

    private CBIva CBI;

    /**
    *   @see i5.cb.workbench.CBIva
    *   @return the CBIva
    */
    public CBIva getCBIva() {
        return CBI;
    }


    /**
    *   <b> Constructor  </b><BR>
    *
    *   Function: <b> Creates a ConnectDialog </b> <BR>
    *
    *  @param CBI      CBIva
    *
    *  @see java.awt.Dialog
    *  @see i5.cb.workbench.TelosEditor
    *  @see i5.cb.workbench.TECommand
    */
    public ConnectDialog(CBIva CBI) {
        super(CBI, "Connect", true);

        this.CBI = CBI;

        CDCommand OkCmd = new CDCommand(CDCommand.OK,this);
        CDCommand CancelCmd = new CDCommand(CDCommand.CANCEL,this);

        JPanel p;
        JLabel l;
        GridBagLayout gbl;
        GridBagConstraints c;

        this.getContentPane().setLayout(new BorderLayout(15, 15));

        // getRecentServers returns an array containing host names and
        // port numbers, if host name is at position i, then there is a port
        // number at position i+1
        String[] hostsAndPorts=i5.cb.CBConfiguration.getRecentServers();
        Vector hosts=new Vector(hostsAndPorts.length/2+1);
        Vector ports=new Vector(hostsAndPorts.length/2+1);
        int i=0;
        for(i=0;i<hostsAndPorts.length/2;i++) {
            if(!hosts.contains(hostsAndPorts[2*i]))
                hosts.add(hostsAndPorts[2*i]);
            if(!ports.contains(hostsAndPorts[2*i+1]))
                ports.add(hostsAndPorts[2*i+1]);
        }
        // defaults
        if(hosts.size()==0) {
           String pubCBserver = i5.cb.CBConfiguration.getPublicCBserverHost();
           // if public CBserver is defined then offer it in the dialog
           if (!pubCBserver.equals("none")) 
               hosts.add(pubCBserver);
           else
               hosts.add("localhost");
        }
        if(ports.size()==0)
            ports.add(i5.cb.CBConfiguration.getPublicCBserverPort());

        // Textfeld fuer Host mit Label
        p = new JPanel();
        gbl = new GridBagLayout();
        p.setLayout(gbl);
        l = new JLabel("Host: ");
        c = new GridBagConstraints();
        c.gridx = 0;
        c.gridy = 0;
        c.gridwidth = GridBagConstraints.RELATIVE;
        c.gridheight = GridBagConstraints.RELATIVE;
        c.fill = GridBagConstraints.HORIZONTAL;
        gbl.setConstraints(l, c);
        p.add(l);
        jcbHost = new JComboBox(hosts);
        jcbHost.setEditable(true);
        c = new GridBagConstraints();
        c.gridx = GridBagConstraints.RELATIVE;
        c.gridy = 0;
        c.gridwidth = GridBagConstraints.REMAINDER;
        c.gridheight = GridBagConstraints.RELATIVE;
        c.fill = GridBagConstraints.HORIZONTAL;
        gbl.setConstraints(jcbHost, c);
        p.add(jcbHost);

        // Textfeld fuer Port mit Label
        l = new JLabel("Port: ");
        c = new GridBagConstraints();
        c.gridx = 0;
        c.gridy = GridBagConstraints.RELATIVE;
        c.gridwidth = 1;
        c.gridheight = 1;
        c.fill = GridBagConstraints.HORIZONTAL;
        gbl.setConstraints(l, c);
        p.add(l);
        jcbPort = new JComboBox(ports);
        jcbPort.setEditable(true);
        c = new GridBagConstraints();
        c.gridx = GridBagConstraints.RELATIVE;
        c.gridy = GridBagConstraints.RELATIVE;
        c.gridwidth = GridBagConstraints.REMAINDER;
        c.gridheight = GridBagConstraints.REMAINDER;
        c.fill = GridBagConstraints.HORIZONTAL;
        gbl.setConstraints(jcbPort, c);
        p.add(jcbPort);
        this.getContentPane().add(BorderLayout.CENTER, p);

        p = new JPanel();
        p.setLayout(new FlowLayout(FlowLayout.CENTER, 15, 15));

        JButton b = new JButton("OK");
        b.addActionListener(OkCmd); // wird in CDCommand verarbeitet
        p.add(b);

        b = new JButton("Cancel");
        b.addActionListener(CancelCmd); // wird in TECommand verarbeitet
        p.add(b);
        this.getContentPane().add(BorderLayout.SOUTH, p);

        this.setLocation(380,300);

        this.pack();

        CBI.getCBClient().setConnectDialog(this); // Parent ist ein TelosEditor!
    }
}

