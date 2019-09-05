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
 *   <b> CBIMenuBar for CBIva 02.98  (ConceptBase) </b>
 *
 *   @see i5.cb.workbench.CBIva
 */
package i5.cb.workbench;

import java.awt.event.ActionEvent;
import java.awt.event.KeyEvent;

import javax.swing.*;
import javax.swing.event.MenuEvent;
import javax.swing.event.MenuListener;

/**  <BR>
 *   Class:    <b> CBIMenuBar for CBIva  </b><BR>
 *   Function: <b> Extends JMenuBar for CBIva </b> <BR>
 *
 *   @version 0.8 beta
 *   @author    Rainer Langohr
 *
 *   @see javax.swing.JMenuBar
 *   @see i5.cb.workbench.CBIva
 */
public class CBIMenuBar extends JMenuBar implements MenuListener {

    private CBIva CBI;

    private JMenu mFile, mEdit, mOptions, mHelp, mWindows;

    private JMenuItem miLPIcall;

    /**
     *   @return the File Menu
     */
    public JMenu getFileMenu() {
        return mFile;
    }

    /**
     *   @return the Edit Menu
     */
    public JMenu getEditMenu() {
        return mEdit;
    }

    /**
     *   @return the Options Menu
     */
    public JMenu getOptionsMenu() {
        return mOptions;
    }

    /**
     *   @return the Help Menu
     */
    public JMenu getHelpMenu() {
        return mHelp;
    }

	/**
	 *   @return the Windows Menu
	 */
	public JMenu getWindowsMenu() {
		return mWindows;
	}

    private JCheckBoxMenuItem miQRW = new JCheckBoxMenuItem("Use Query Result Window");


    // Menu Listener:

    public void menuCanceled(MenuEvent me)    { }
    public void menuDeselected(MenuEvent me)    { }
    public void menuSelected(MenuEvent me)    {
        this.EnableCommands(CBI.isConnected());

    }





    private boolean connected=true;




    /**
     *   Function: <b> Enable the Menuitem for Connection/Disconection</b> <BR>
     *
     *   @param bEnable
     */
    public void EnableCommands(boolean bEnable) {
        if (connected!=bEnable) {
            connected=bEnable;


            JMenu m;

            m = this.getMenu(CBICommand.iFILE_MENU / CBICommand.iID_DIM);
            (m.getItem(CBICommand.iDISCONNECT  - CBICommand.iFILE_MENU)).setEnabled(bEnable);
            (m.getItem(CBICommand.iLOAD_MODEL  - CBICommand.iFILE_MENU)).setEnabled(bEnable);
            (m.getItem(CBICommand.iSTOP_SERVER - CBICommand.iFILE_MENU)).setEnabled(bEnable);

            m = this.getMenu(CBICommand.iEDIT_MENU / CBICommand.iID_DIM);

            (m.getItem(CBICommand.iCLEAR       - CBICommand.iEDIT_MENU)).setEnabled(true);
            (m.getItem(CBICommand.iCUT         - CBICommand.iEDIT_MENU)).setEnabled(true);
            (m.getItem(CBICommand.iCOPY        - CBICommand.iEDIT_MENU)).setEnabled(true);
            (m.getItem(CBICommand.iPASTE       - CBICommand.iEDIT_MENU)).setEnabled(true);
            (m.getItem(CBICommand.iTELL        - CBICommand.iEDIT_MENU)).setEnabled(bEnable);
            (m.getItem(CBICommand.iUNTELL      - CBICommand.iEDIT_MENU)).setEnabled(bEnable);
            (m.getItem(CBICommand.iRETELL      - CBICommand.iEDIT_MENU)).setEnabled(bEnable);
            (m.getItem(CBICommand.iASK         - CBICommand.iEDIT_MENU+1)).setEnabled(bEnable);
            (m.getItem(CBICommand.iCALL_QUERY  - CBICommand.iEDIT_MENU+1)).setEnabled(bEnable);
            (m.getItem(CBICommand.iLOAD_OBJECT - CBICommand.iEDIT_MENU+2)).setEnabled(bEnable);
            (m.getItem(CBICommand.iPM_OBJECT_TREE - CBICommand.iEDIT_MENU+2)).setEnabled(bEnable);



            miLPIcall.setEnabled(bEnable);





            m = this.getMenu(CBICommand.iBROWSE_MENU / CBICommand.iID_DIM);
            (m.getItem(CBICommand.iTELOS_EDITOR      - CBICommand.iBROWSE_MENU)).setEnabled(true); // always active
            (m.getItem(CBICommand.iDISPLAY_INSTANCES - CBICommand.iBROWSE_MENU)).setEnabled(bEnable);
            (m.getItem(CBICommand.iFRAME_BROWSER     - CBICommand.iBROWSE_MENU)).setEnabled(true); // always active
            (m.getItem(CBICommand.iQUERY_BROWSER     - CBICommand.iBROWSE_MENU)).setEnabled(bEnable);
            (m.getItem(CBICommand.iQUERY_BROWSER_ALL - CBICommand.iBROWSE_MENU)).setEnabled(bEnable);
            (m.getItem(CBICommand.iFUNCTION_BROWSER  - CBICommand.iBROWSE_MENU)).setEnabled(bEnable);
            (m.getItem(CBICommand.iQUERY_EDITOR      - CBICommand.iBROWSE_MENU)).setEnabled(bEnable);
            (m.getItem(CBICommand.iGRAPH_EDITOR      - CBICommand.iBROWSE_MENU)).setEnabled(true); // always active


        }
    }





    /**
     *   <b> Constructor  </b><BR>
     *
     *   @param CBI parent CBIva
     */
    public CBIMenuBar(CBIva CBI) {
        this.CBI=CBI;

        JMenuItem mi;

        JMenu m;


        // Menue "File" erzeugen
        mFile = new JMenu("File");
        mFile.addMenuListener(this);

        mi = new JMenuItem("Connect");
        mi.addActionListener(new CBICommand(CBICommand.iCONNECT,     CBI));
        mFile.add(mi);

        mi = new JMenuItem("Disconnect");
        mi.addActionListener(new CBICommand(CBICommand.iDISCONNECT,  CBI));
        mFile.add(mi);

        mFile.addSeparator();

        mi = new JMenuItem("Load Telos Editor");
        mi.addActionListener(new CBICommand(CBICommand.iLOAD_TELOS,  CBI));
        mFile.add(mi);

        mi = new JMenuItem("Save Telos Editor");
        mi.addActionListener(new CBICommand(CBICommand.iSAVE_TELOS,  CBI));
        mFile.add(mi);

        mFile.addSeparator();

        mi = new JMenuItem("Load Model");
        mi.addActionListener(new CBICommand(CBICommand.iLOAD_MODEL,  CBI));
        mFile.add(mi);

        mi = new JMenuItem("Start CBserver");
        mi.addActionListener(new CBICommand(CBICommand.iSTART_SERVER, CBI));
        mFile.add(mi);

        mi = new JMenuItem("Stop CBserver");
        mi.addActionListener(new CBICommand(CBICommand.iSTOP_SERVER, CBI));
        mFile.add(mi);

        mFile.addSeparator();

        mi = new JMenuItem("Close");
        mi.addActionListener(new CBICommand(CBICommand.iCLOSE,        CBI));
        mFile.add(mi);

         mi = new JMenuItem("Exit");
        mi.addActionListener(new CBICommand(CBICommand.iEXIT,        CBI));
        mFile.add(mi);

        this.add(mFile);

        // Menue "Edit" erzeugen
        mEdit = new JMenu("Edit");
        mEdit.addMenuListener(this);

        mi = new JMenuItem("Clear");
        mi.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_N, ActionEvent.CTRL_MASK));
        mi.addActionListener(new CBICommand(CBICommand.iCLEAR,       CBI));
        mEdit.add(mi);

        mi = new JMenuItem("Cut");
        mi.addActionListener(new CBICommand(CBICommand.iCUT,         CBI));
        mi.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_X, ActionEvent.CTRL_MASK));
        mEdit.add(mi);

        mi = new JMenuItem("Copy");
        mi.addActionListener(new CBICommand(CBICommand.iCOPY,        CBI));
        mi.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_C, ActionEvent.CTRL_MASK));
        mEdit.add(mi);

        mi = new JMenuItem("Paste");
        mi.addActionListener(new CBICommand(CBICommand.iPASTE,       CBI));
        mi.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_V, ActionEvent.CTRL_MASK));
        mEdit.add(mi);

        mEdit.addSeparator();

        mi = new JMenuItem("Tell");
        mi.addActionListener(new CBICommand(CBICommand.iTELL,        CBI));
        mEdit.add(mi);

        mi = new JMenuItem("Untell");
        mi.addActionListener(new CBICommand(CBICommand.iUNTELL,      CBI));
        mEdit.add(mi);

        mi = new JMenuItem("Retell");
        mi.addActionListener(new CBICommand(CBICommand.iRETELL,      CBI));
        mEdit.add(mi);

        mEdit.addSeparator();

        mi = new JMenuItem("Ask Frame");
        mi.addActionListener(new CBICommand(CBICommand.iASK,         CBI));
        mEdit.add(mi);

        mi = new JMenuItem("Ask Query Call");
        mi.addActionListener(new CBICommand(CBICommand.iCALL_QUERY,  CBI));
        mEdit.add(mi);

        mEdit.addSeparator();

        mi = new JMenuItem("Load Object");
        mi.addActionListener(new CBICommand(CBICommand.iLOAD_OBJECT, CBI));
        mEdit.add(mi);

/* no longer use FrameTree; issue #6
        mi=new JMenuItem("View Object as Tree");
        mi.addActionListener(new CBICommand(CBICommand.iPM_OBJECT_TREE,CBI));
        mEdit.add(mi);
*/


        miLPIcall = new JMenuItem("Prolog Call");
        miLPIcall.addActionListener(new CBICommand(CBICommand.iLPI_CALL,    CBI));


        if (CBI.getLPIcall())  {
            mEdit.add(miLPIcall);
        }



        this.add(mEdit);

        // Menue "Browse" erzeugen
        m = new JMenu("Browse");
        m.addMenuListener(this);

        mi = new JMenuItem("New Telos Editor");
        mi.addActionListener(new CBICommand(CBICommand.iTELOS_EDITOR     , CBI));
        m.add(mi);

        mi = new JMenuItem("Display Instances");
        mi.addActionListener(new CBICommand(CBICommand.iDISPLAY_INSTANCES, CBI));
        m.add(mi);

        mi = new JMenuItem("Frame Browser");
        mi.addActionListener(new CBICommand(CBICommand.iFRAME_BROWSER    , CBI));
        m.add(mi);

        mi = new JMenuItem("Display Queries");
        mi.addActionListener(new CBICommand(CBICommand.iQUERY_BROWSER    , CBI));
        m.add(mi);

        mi = new JMenuItem("Display All Queries");
        mi.addActionListener(new CBICommand(CBICommand.iQUERY_BROWSER_ALL, CBI));
        m.add(mi);

        mi = new JMenuItem("Display Functions");
        mi.addActionListener(new CBICommand(CBICommand.iFUNCTION_BROWSER    , CBI));
        m.add(mi);

        mi = new JMenuItem("Query Editor");
        mi.addActionListener(new CBICommand(CBICommand.iQUERY_EDITOR     , CBI));
        m.add(mi);

        mi = new JMenuItem("Graph Editor");
        mi.addActionListener(new CBICommand(CBICommand.iGRAPH_EDITOR     , CBI));
        m.add(mi);

        this.add(m);

        // Menue "Options" erzeugen
        mOptions = new JMenu("Options");
        mOptions.addMenuListener(this);

        mi = new JMenuItem("Set Timeout");
        mi.addActionListener(new CBICommand(CBICommand.iSET_TIMEOUT,  CBI));
        mOptions.add(mi);

        mi = new JMenuItem("Select Module");
        mi.addActionListener(new CBICommand(CBICommand.iMODULE_DIALOG    , CBI));
        mOptions.add(mi);

        mi = new JMenuItem("Select Version");
        mi.addActionListener(new CBICommand(CBICommand.iVERSION_DIALOG    , CBI));
        mOptions.add(mi);

        JCheckBoxMenuItem jcmi = new JCheckBoxMenuItem("Pre-Parse TelosFrames");
        jcmi.addActionListener(new CBICommand(CBICommand.iCALL_TELOS_PARSER,CBI));
        jcmi.setSelected(CBI.getCBClient().getCallTelosParser());
        mOptions.add(jcmi);

        JCheckBoxMenuItem jcmi2 = new JCheckBoxMenuItem("Show Line Numbers");
        jcmi2.addActionListener(new CBICommand(CBICommand.iSHOW_LINE_NUMBERS,CBI));
        jcmi2.setSelected(CBI.getCBClient().getShowLineNumbers());
        mOptions.add(jcmi2);

        // Query Result Window Optionen einstellen:
        miQRW.addActionListener(new CBICommand(CBICommand.iQRWin, CBI));
        miQRW.setSelected(CBI.useQueryResultWindow());
        mOptions.add(miQRW);

        JMenu mLookAndFeel= new JMenu("Look & Feel");

        // Vordefinierte Look And Feels
        UIManager.LookAndFeelInfo[] lafInfo=UIManager.getInstalledLookAndFeels();
        if (lafInfo!=null)  {
            for (int i=0; i<lafInfo.length; i++) {
                mi= new JMenuItem(lafInfo[i].getName());
                mi.addActionListener(new CBICommand(CBICommand.iLOOK_AND_FEEL,lafInfo[i].getClassName(),CBI));
                mLookAndFeel.add(mi);
            }
        }
        mOptions.add(mLookAndFeel);

        mOptions.addSeparator();

        mi = new JMenuItem("Save Options");
        mi.addActionListener(new CBICommand(CBICommand.iSAVE_OPTIONS, CBI));
        mOptions.add(mi);

        mi = new JMenuItem("Edit Options Manually");
        mi.addActionListener(new CBICommand(CBICommand.iEDIT_OPTIONS, CBI));
        mOptions.add(mi);

        this.add(mOptions);

		// Menue "Windows" erzeugen
		mWindows = new JMenu("Windows");
		mWindows.addMenuListener(this);

		this.add(mWindows);

        // Menue "Help" erzeugen
        mHelp = new JMenu("Help");
        mHelp.addMenuListener(this);

        mi = new JMenuItem("ConceptBase.cc Manual");
        mi.addActionListener(new CBICommand(CBICommand.iCONCEPTBASE_MANUAL, CBI));
        mHelp.add(mi);

        mi = new JMenuItem("CB Tutorial I");
        mi.addActionListener(new CBICommand(CBICommand.iCBTUT1, CBI));
        mHelp.add(mi);

        mi = new JMenuItem("CB Tutorial II");
        mi.addActionListener(new CBICommand(CBICommand.iCBTUT2, CBI));
        mHelp.add(mi);

        mi = new JMenuItem("CB-Forum");
        mi.addActionListener(new CBICommand(CBICommand.iCBFORUM, CBI));
        mHelp.add(mi);

        mi = new JMenuItem("About");
        mi.addActionListener(new CBICommand(CBICommand.iABOUT,              CBI));
        mHelp.add(mi);

        mi = new JMenuItem("License");
        mi.addActionListener(new CBICommand(CBICommand.iLICENSE,              CBI));
        mHelp.add(mi);

        mi = new JMenuItem("CB-Team");
        mi.addActionListener(new CBICommand(CBICommand.iCBTEAM,              CBI));
        mHelp.add(mi);


        this.add(mHelp);

    }
}
