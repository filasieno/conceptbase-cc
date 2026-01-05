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
*   <b> LWCCommand for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.LWChoise
*   @see i5.cb.workbench.LogWindow
*   @see i5.cb.workbench.CBIva
*/

package i5.cb.workbench;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

/**  <BR>
*   Class:    <b> LWCCommand for CBIva  </b><BR>
*   Function: <b> Implements ActionListener for LWChoise </b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see java.awt.event.ActionListener
*   @see i5.cb.workbench.LogWindow
*   @see i5.cb.workbench.CBIva
*/

public class LWCCommand implements ActionListener {

    // the different commands:
    // for LogWindow:
    /**
    *   public constant:    Redo = 1
    */
    public static final int REDO     = 1;

    /**
    *   public constant:    Clear = 2
    */
    public static final int CLEAR    = 2;

    /**
    *   public constant:    Exit = 3
    */
    public static final int EXIT    = 3;


    private int id;
    private LWChoise      LWC;

    /**
    *   <b> Constructor  </b><BR>
    *
    *   @param id Command identification number
    *   @param LWC Parent LWChoise
    */
    public LWCCommand(int id, LWChoise LWC) {
        this.id = id;
        this.LWC = LWC;
    }


    /**
    *   Function: <b> Excecute the Commands </b> <BR>
    *
    *   @param e the ActionEvent for the Command
    *   @see java.awt.event.ActionEvent
    */
    public void actionPerformed(ActionEvent e) {
        switch (id) {
            case REDO:
                LWC.RedoButton();
                break;
            case CLEAR:
                LWC.ClearButton();
                break;
            case EXIT:
                LWC.ExitButton();
                break;


        }
    }
}
