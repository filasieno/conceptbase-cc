/*
The ConceptBase.cc Copyright

Copyright 1987-2020 The ConceptBase Team. All rights reserved.

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
*   <b> CDCommand for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.FrameBrowser
*   @see i5.cb.workbench.CBIva
*/

package i5.cb.workbench;

import i5.cb.CBException;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Arrays;


/**
*   Class:    <b> CDCommand for CBIva  </b><BR>
*   Function: <b> Implements ActionListener for the ConnectDialog </b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see java.awt.event.ActionListener
*   @see i5.cb.workbench.ConnectDialog
*   @see i5.cb.workbench.CBIva
*/
public class CDCommand implements ActionListener {

    // the different Commands
    // for the  ConnectDialog:
    /**
    *   public constant:    OK = 1
    */
    public static final int OK     = 1;

    /**
    *   public constant:    CANCEL = 2
    */
    public static final int CANCEL = 2;


    private int id;
    private ConnectDialog cd;
    private CBIvaClient CBClient;
    private CBIva CBI;


    /**
    *   <b> Constructor  </b><BR>
    *
    *   @param id  Identificator
    *   @param cd  parent ConnectDialog
    */
    public CDCommand(int id, ConnectDialog cd) {
        this.id       = id;
        this.cd       = cd;
        this.CBI      = cd.getCBIva();
        this.CBClient = CBI.getCBClient();
    }


    /**
    *   Function: <b> Excecute the Commands </b> <BR>
    *
    *   @param e the ActionEvent for the Command
    *   @see java.awt.event.ActionEvent
    */
    public void actionPerformed(ActionEvent e) {
        switch (id) {
                // fuer das LogWindow:
            case OK:
                okCmd();
                break;
                /*
                 * ConnectDialog: Cancel-Button
                 */
            case CANCEL:
                CBI.getStatusBar().insertMessage("Connect cancelled");
                cd = CBClient.getConnectDialog();
                if (cd != null) {
                    cd.setVisible(false);
                }
                break;
        }
    }


    public void okCmd() {
        if (cd != null) {
            if (CBClient.isConnected()) {
                CBClient.cancelMe();
            }
            try {
                CBI.getStatusBar().insertMessage("Trying to connect...");
                String userName=null;
                try {
                    userName=CBIva.getProp("user.name","unknown");
                }
                catch(SecurityException e) {
                    userName="unknown";
                }
                CBClient.enrollMe(cd.getHost(), cd.getPort(), "CBIva", userName);
            }
            catch (CBException cbe) {
                System.out.println("Exception:" + cbe.getMessage());
            }
            if (CBClient.isConnected()) {
                CBI.EnableCommands(true);
                CBI.getStatusBar().insertMessage("Connection established to "+cd.getHost()+":"+cd.getPort());
                CBI.getStatusBar().setStatus(cd.getHost(),cd.getPort());
                cd.setVisible(false);
                java.util.List lHostsAndPorts=Arrays.asList(i5.cb.CBConfiguration.getRecentServers());
                if(!lHostsAndPorts.contains(cd.getHost()) || !lHostsAndPorts.contains(cd.getPortString())) {
                    i5.cb.CBConfiguration.addNewConnection(cd.getHost(),cd.getPortString());
                }
            }
            else {
                CBI.getStatusBar().insertMessage("Connection failed, try again");
            }
        }
    }
}
