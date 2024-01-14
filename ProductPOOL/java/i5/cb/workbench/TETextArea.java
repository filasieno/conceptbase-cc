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
*   <b> TelosEditor for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.CBIva
*/
package i5.cb.workbench;

import java.awt.AWTEvent;
import java.awt.Color;
import java.awt.event.MouseEvent;

import javax.swing.*;


/**
*   Class:    <b> TETextArea for CBIva  </b><BR>
*   Function: <b> Creates a TextArea with PopupMenu for the TelosEditor </b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see i5.cb.workbench.TelosEditor
*   @see i5.cb.workbench.CBIva
*/
public class TETextArea extends JTextArea {


    public void save() {
        // TODO
        // iot.save(this.getText());
    }

    public void load() {
        // TODO
        /*        String loadString=iot.askLoad(this.getText());
                if (loadString!=null)
                    this.setText(loadString);
        */
    }

    private TelosEditor te;

    private JPopupMenu pmTextAreaPopup=new JPopupMenu();

    private JTextArea taTelosTextArea=new JTextArea();

    public static final float smallFontSize = 12f;
    public static final float largeFontSize = 18f;
    private float currentFontSize = smallFontSize;  // default: small font

    public TETextArea(TelosEditor te) {
        super();
        this.te=te;
        InitPopupMenu();
        this.taTelosTextArea.setEditable(true);
        this.setBackground(Color.white);
    }

    private JMenuItem miDisIn, miLoOb, miChMod;


    private void InitPopupMenu() {
        TECommand tecClear      = new TECommand(TECommand.iCLEAR,       te);
        TECommand tecCut        = new TECommand(TECommand.iCUT,         te);
        TECommand tecCopy       = new TECommand(TECommand.iCOPY,        te);
        TECommand tecPaste      = new TECommand(TECommand.iPASTE,       te);
        TECommand tecToGrEd    = new TECommand(TECommand.iTOGRAPHEDITOR,       te);

        TECommand tecSmall      = new TECommand(TECommand.iSMALL,       te);
        TECommand tecLarge      = new TECommand(TECommand.iLARGE,       te);

        JMenuItem mi;

        miDisIn=new JMenuItem("Display Instances");
        miDisIn.addActionListener(new TECommand(TECommand.iPM_DISPLAY_INSTANCES,te));
        pmTextAreaPopup.add(miDisIn);

        miLoOb=new JMenuItem("Load Object");
        miLoOb.addActionListener(new TECommand(TECommand.iPM_LOAD_OBJECT,te));
        pmTextAreaPopup.add(miLoOb);

/* no longer use FrameTree; issue #6
        mi=new JMenuItem("View Object as Tree");
        mi.addActionListener(new TECommand(TECommand.iPM_OBJECT_TREE,te));
        pmTextAreaPopup.add(mi);
*/

        mi=new JMenuItem("Display in GraphEditor");
        mi.addActionListener(tecToGrEd);
        pmTextAreaPopup.add(mi);

        miChMod=new JMenuItem("Change Module");
        miChMod.addActionListener(new TECommand(TECommand.iPM_CHANGE_MODULE,te));
        pmTextAreaPopup.add(miChMod);

        pmTextAreaPopup.addSeparator();

        mi=new JMenuItem("Clear");
        mi.addActionListener(tecClear);
        pmTextAreaPopup.add(mi);

        mi=new JMenuItem("Cut");
        mi.addActionListener(tecCut);
        pmTextAreaPopup.add(mi);

        mi=new JMenuItem("Copy");
        mi.addActionListener(tecCopy);
        pmTextAreaPopup.add(mi);

        mi=new JMenuItem("Paste");
        mi.addActionListener(tecPaste);
        pmTextAreaPopup.add(mi);

        pmTextAreaPopup.addSeparator();

        mi=new JMenuItem("Small");
        mi.addActionListener(tecSmall);
        pmTextAreaPopup.add(mi);

        mi=new JMenuItem("Large");
        mi.addActionListener(tecLarge);
        pmTextAreaPopup.add(mi);


        enableEvents (AWTEvent.MOUSE_EVENT_MASK);
    }


    public JPopupMenu getPopupMenu() {
        return pmTextAreaPopup;
    }

    public void EnableCommand(boolean bEnable) {
        miDisIn.setEnabled(bEnable);
        miLoOb.setEnabled(bEnable);
    }


    public void setTextFontSize(float newsize) {
        currentFontSize = newsize;
        this.setFont(this.getFont().deriveFont(currentFontSize));
        if (this.te != null) {
          this.te.updateLineNumbers();
          if (this.te.getLogWindow() != null)
            this.te.getLogWindow().setLogWindowFontsize(currentFontSize);
        }
    }

    public float getTextFontSize() {
        return currentFontSize;
    }






    protected void processMouseEvent (MouseEvent e) {
        if ((e.isPopupTrigger()) | (e.getModifiers()==MouseEvent.BUTTON3_MASK)) {
            EnableCommand(te.getCBIva().getCBClient().isConnected());
            getPopupMenu().show (e.getComponent(), e.getX(), e.getY());
        }
        else
            super.processMouseEvent (e);
    }

    public void requestFocus() {
        // te.requestFocus();
        super.requestFocus();
    }


}
