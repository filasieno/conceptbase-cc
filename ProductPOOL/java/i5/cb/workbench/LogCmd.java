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
*   <b> LWChoise for CBIva 11.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.CBIva
*/
package i5.cb.workbench;

import java.awt.event.ItemListener;

import javax.swing.JCheckBox;


/**
*   Class:    <b> LWChoise for CBIva  </b><BR>
*   Function: <b> Creates a Choise-List to Redo the List </b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see javax.swing.JFrame
*   @see i5.cb.workbench.CBIva
*/
public class LogCmd {

    /**
    *   <b> Constructor  </b><BR>
    *
    *   Function: <b> creates a LWChoise for CBIva</b> <BR>
    *
    *   @param LWLog Log
    */

    private String sTyp;
    private int iTyp;
    private String[] asArg;
    private int No=0;


    private boolean bisSelected=true;

    private LWChoise LWC=null;

    public void setLWChoise(LWChoise LWC) {
        this.LWC=LWC;
    }

    public void setText() {
        if (LWC!=null)
            LWC.setText(this);
    }

    public void invert() {
        this.bisSelected=(!this.bisSelected);
    }



    public void setSelected(boolean b) {
        this.bisSelected=b;
    }


    public LogCmd(String sTyp, int iTyp, String[] asArg, int No) {
        this.sTyp=sTyp;
        this.iTyp=iTyp;
        this.asArg=asArg;
        this.No=No;
    }

    public String toString() {
        String sNo=Integer.toString(No);


        return sNo+"  : "+sTyp;
    }

    public JCheckBox getCheckBox() {
        JCheckBox JCB = new JCheckBox(this.toString());
        JCB.setSelected(true);
        JCB.addItemListener(new CheckBoxListener(this));
        return JCB;
    }

    public String getText() {
        String text="";
        Integer i = Integer.valueOf(No);
        String s = i.toString();
        if (iTyp==LogWindow.TELL) {
            text=s+":  "+sTyp+"\nFrames told:\n"+asArg[0];
        }
        else if (iTyp==LogWindow.UNTELL) {
            text=s+":  "+sTyp+"\nFrames untold:\n"+asArg[0];
        }
        else if (iTyp==LogWindow.RETELL) {
            text=s+":  "+sTyp+"\nFrames untold:\n"+asArg[0] +
                 "Frames told:\n"+asArg[1];
        }
        else if (iTyp==LogWindow.ASK) {
            text=s+":  "+sTyp+"\nQuery:\n"+asArg[0]+"\n\n"+
                 "Format: "+asArg[1]+"\n"+
                 "Answer Format: "+asArg[2]+"\n"+
                 "Rollback Time: "+asArg[3]+"\n"+
                 "Result: \n" + asArg[4] + "\n";
        }
        else if (iTyp==LogWindow.TELLMODEL) {
            text=s+":  "+sTyp+"\nFiles: "+asArg[0];
        }
        else if (iTyp==LogWindow.LPICALL) {
            text=s+":  "+sTyp+"\nLPICall: "+asArg[0];
        }
        else if(iTyp==LogWindow.ERROR) {
            text=s+":  "+sTyp+"\nError Message:\n" + asArg[0] + "\n";
        }
        else {      // Other
        }

        return text;
    }

    public void Redo(LogWindow LW) {
        if (bisSelected)
            LW.Redo(iTyp, asArg);
    }



}

class CheckBoxListener implements ItemListener {

    private LogCmd LC;

    public CheckBoxListener(LogCmd LC) {
        this.LC=LC;
    }

    public void itemStateChanged(java.awt.event.ItemEvent e) {
        LC.setText();
        LC.invert();
    }
}


