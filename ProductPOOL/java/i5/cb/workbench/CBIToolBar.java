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
/**
*   <b> CBIToolBar for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.CBIva
*/
package i5.cb.workbench;

import java.awt.Insets;

import javax.swing.*;

/**  <BR>
*   Class:    <b> CBIToolBar for CBIva  </b><BR>
*   Function: <b> Extends JToolBar for CBIva </b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see javax.swing.JToolBar
*   @see i5.cb.workbench.CBIva
*/
public class CBIToolBar extends JToolBar {

    private CBIva CBI;

    private ImageIcon IIqconnect;

    private static JButton bTell, bUntell, bRetell, bAsk, bListModule, bQConnect, bLPIcall;

    private static JButton bClear, bExit, bCut, bCopy, bPaste;


    /**
    *   Function: <b> Enable the Buttons for Connect/disconnect </b> <BR>
    *
    *   @param bEnable Connect/Disconnect
    */
    public void EnableCommands(boolean bEnable) {
        bTell.setEnabled(bEnable);
        bUntell.setEnabled(bEnable);
        bRetell.setEnabled(bEnable);
        bAsk.setEnabled(bEnable);
        bListModule.setEnabled(bEnable);
        bLPIcall.setEnabled(bEnable);

        if (bEnable) {
            IIqconnect = new ImageIcon(CBI.LoadImage("disconnect.gif"),"disconnect");
            bQConnect.setToolTipText("Disconnect from CBserver");
            bQConnect.setIcon(IIqconnect);
        }
        else {
            IIqconnect = new ImageIcon(CBI.LoadImage("connect.gif"),"connect");
            bQConnect.setToolTipText("Quick Connect to CBserver");
            bQConnect.setIcon(IIqconnect);
        }
    }



    /**
    *   <b> Constructor  </b><BR>
    *
    *   @param CBI parent CBIva
    */
    public CBIToolBar(CBIva CBI) {
        this.CBI=CBI;
        CBICommand cbicTell       = new CBICommand(CBICommand.iTELL,        CBI);
        CBICommand cbicUntell     = new CBICommand(CBICommand.iUNTELL,      CBI);
        CBICommand cbicRetell     = new CBICommand(CBICommand.iRETELL,      CBI);
        CBICommand cbicAsk        = new CBICommand(CBICommand.iASK,         CBI);
        CBICommand cbicListModule = new CBICommand(CBICommand.iLIST_MODULE, CBI);
        CBICommand cbicLPIcall    = new CBICommand(CBICommand.iLPI_CALL,    CBI);

        CBICommand cbicClear      = new CBICommand(CBICommand.iCLEAR,       CBI);
        CBICommand cbicCut        = new CBICommand(CBICommand.iCUT,         CBI);
        CBICommand cbicCopy       = new CBICommand(CBICommand.iCOPY,        CBI);
        CBICommand cbicPaste      = new CBICommand(CBICommand.iPASTE,       CBI);

        CBICommand cbicExit       = new CBICommand(CBICommand.iEXIT,        CBI);
        CBICommand cbicQConnect   = new CBICommand(CBICommand.iQCONNECT, CBI);




        this.setAlignmentX(LEFT_ALIGNMENT);
        this.setAlignmentY(TOP_ALIGNMENT);



        /*
        * Leerzeichen in der Button-Beschriftung deshalb, weil zumindest unter Windows 95
        * die Buttons nicht auf eine Aenderung der Groesse mittels Button.setSize(int, int) reagieren.
        * Ausschlaggebend ist allein der im Button enthaltene Text (und seine horizontale und vertikale Ausdehnung).
        */

        // Quick Connect

        IIqconnect = new ImageIcon(CBI.LoadImage("connect.gif"),"connect");
        bQConnect = new JButton(IIqconnect);
        bQConnect.setHorizontalTextPosition(AbstractButton.CENTER);
        bQConnect.setVerticalTextPosition(AbstractButton.BOTTOM);
        bQConnect.setToolTipText("Quick Connect to CBserver");
        bQConnect.addActionListener(cbicQConnect);
        bQConnect.setMargin(new Insets(0,0,0,0));
        this.add(bQConnect);

        this.addSeparator();

        // Clear

        ImageIcon IIclear = new ImageIcon(CBI.LoadImage("clear.gif"),"Clear");
        bClear = new JButton(IIclear);
        bClear.setHorizontalTextPosition(AbstractButton.CENTER);
        bClear.setVerticalTextPosition(AbstractButton.BOTTOM);
        bClear.setToolTipText("Clear Telos Editor");
        bClear.addActionListener(cbicClear);
        bClear.setMargin(new Insets(0,0,0,0));
        this.add(bClear);



        // Cut

        ImageIcon IIcut = new ImageIcon(CBI.LoadImage("cut.gif"),"Cut");
        bCut = new JButton(IIcut);
        bCut.setHorizontalTextPosition(AbstractButton.CENTER);
        bCut.setVerticalTextPosition(AbstractButton.BOTTOM);
        bCut.setToolTipText("Cut");
        bCut.addActionListener(cbicCut);
        bCut.setMargin(new Insets(0,0,0,0));
        this.add(bCut);

        // Copy
        ImageIcon IIcopy = new ImageIcon(CBI.LoadImage("copy.gif"),"Copy");
        bCopy = new JButton(IIcopy);
        bCopy.setHorizontalTextPosition(AbstractButton.CENTER);
        bCopy.setVerticalTextPosition(AbstractButton.BOTTOM);
        bCopy.setToolTipText("Copy");
        bCopy.addActionListener(cbicCopy);
        bCopy.setMargin(new Insets(0,0,0,0));
        this.add(bCopy);

        // Paste
        ImageIcon IIpaste = new ImageIcon(CBI.LoadImage("paste.gif"),"Paste");
        bPaste = new JButton(IIpaste);
        bPaste.setHorizontalTextPosition(AbstractButton.CENTER);
        bPaste.setVerticalTextPosition(AbstractButton.BOTTOM);
        bPaste.setToolTipText("Paste");
        bPaste.addActionListener(cbicPaste);
        bPaste.setMargin(new Insets(0,0,0,0));
        this.add(bPaste);

        this.addSeparator();



        // Tell
        ImageIcon IItell = new ImageIcon(CBI.LoadImage("tell.gif"),"Tell to CBServer");
        bTell = new JButton(IItell);
        bTell.setHorizontalTextPosition(AbstractButton.CENTER);
        bTell.setVerticalTextPosition(AbstractButton.BOTTOM);
        bTell.setToolTipText("Tells content of Telos Editor");
        bTell.addActionListener(cbicTell);
        bTell.setMargin(new Insets(0,0,0,0));
        this.add(bTell);

        // Untell
        ImageIcon IIuntell = new ImageIcon(CBI.LoadImage("untell.gif"),"Untell to CBServer");
        bUntell = new JButton(IIuntell);
        bUntell.setHorizontalTextPosition(AbstractButton.CENTER);
        bUntell.setVerticalTextPosition(AbstractButton.BOTTOM);
        bUntell.setToolTipText("Untells content of Telos-Editor");
        bUntell.addActionListener(cbicUntell);
        bUntell.setMargin(new Insets(0,0,0,0));
        this.add(bUntell);

        // Retell
        ImageIcon IIretell = new ImageIcon(CBI.LoadImage("retell.gif"),"Retell to CBServer");
        bRetell = new JButton(IIretell);
        bRetell.setHorizontalTextPosition(AbstractButton.CENTER);
        bRetell.setVerticalTextPosition(AbstractButton.BOTTOM);
        bRetell.setToolTipText("Open Retell window");
        bRetell.addActionListener(cbicRetell);
        bRetell.setMargin(new Insets(0,0,0,0));
        this.add(bRetell);

        // Ask
        ImageIcon IIask = new ImageIcon(CBI.LoadImage("ask.gif"),"Ask the query to CBServer");
        bAsk = new JButton(IIask);
        bAsk.setHorizontalTextPosition(AbstractButton.CENTER);
        bAsk.setVerticalTextPosition(AbstractButton.BOTTOM);
        bAsk.setToolTipText("Ask/evaluate");
        bAsk.addActionListener(cbicAsk);
        bAsk.setMargin(new Insets(0,0,0,0));
        this.add(bAsk);

        // ListModule 
        ImageIcon IIlistModule = new ImageIcon(CBI.LoadImage("frame.gif"),"List current module from CBserver");
        bListModule = new JButton(IIlistModule);
        bListModule.setHorizontalTextPosition(AbstractButton.CENTER);
        bListModule.setVerticalTextPosition(AbstractButton.BOTTOM);
        bListModule.setToolTipText("List current module");
        bListModule.addActionListener(cbicListModule);
        bListModule.setMargin(new Insets(0,0,0,0));
        this.add(bListModule);

        this.addSeparator();



        // LPIcall
        ImageIcon IILPIcall = new ImageIcon(CBI.LoadImage("lpicall.gif"),"LPI Call");
        bLPIcall = new JButton(IILPIcall);
        bLPIcall.setHorizontalTextPosition(AbstractButton.CENTER);
        bLPIcall.setVerticalTextPosition(AbstractButton.BOTTOM);
        bLPIcall.setToolTipText("LPI Call");
        bLPIcall.addActionListener(cbicLPIcall);
        bLPIcall.setMargin(new Insets(0,0,0,0));



        if (CBI.getLPIcall())  {
            this.add(bLPIcall);
            this.addSeparator();
        }



        // Exit
        ImageIcon IIexit = new ImageIcon(CBI.LoadImage("exit.gif"),"Exit");
        bExit = new JButton(IIexit);
        bExit.setHorizontalTextPosition(AbstractButton.CENTER);
        bExit.setVerticalTextPosition(AbstractButton.BOTTOM);
        bExit.setToolTipText("Exit CBIva");
        bExit.addActionListener(cbicExit);
        bExit.setMargin(new Insets(0,0,0,0));
        this.add(bExit);

    }

}
