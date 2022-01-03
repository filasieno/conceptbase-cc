/*
The ConceptBase.cc Copyright

Copyright 1987-2022 The ConceptBase Team. All rights reserved.

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
 *   <b> LWCommand for CBIva 02.98  (ConceptBase) </b>
 *
 *   @see i5.cb.workbench.LogWindow
 *   @see i5.cb.workbench.CBIva
 */

package i5.cb.workbench;

import java.awt.event.*;

/**  <BR>
 *   Class:    <b> LWCommand for CBIva  </b><BR>
 *   Function: <b> Implements ActionListener for LogWindow </b> <BR>
 *
 *   @version 0.8 beta
 *   @author    Rainer Langohr
 *
 *   @see java.awt.event.ActionListener
 *   @see i5.cb.workbench.LogWindow
 *   @see i5.cb.workbench.CBIva
 */

public class LWCommand extends MouseAdapter implements ActionListener {

    // the different commands:
    // for LogWindow:
    /**
    *   public constant:    BACK = 1
    */
    public static final int BACK     = 1;

    /**
    *   public constant:    FOR = 2
    */
    public static final int FOR      = 2;

    /**
    *   public constant:    TELOS = 3
    */
    public static final int TELOS    = 3;

    /**
    *   public constant:    REDO = 4
    */
    public static final int REDO     = 4;

    /**
    *   public constant:    SAVE = 5
    */
    public static final int SAVE     = 5;

    /**
    *   public constant:    LOAD = 6
    */
    public static final int LOAD     = 6;

    /**
    *   public constant:    CHOISE = 7
    */
    public static final int CHOISE     = 7;

    /**
    *   public constant:    COPY = 8
    */
    public static final int COPY     = 8;

    /**
    *   public constant:    OPTIONS
    */
    public static final int OPTIONS  = 9;
    /**
    *   public constant:    MANUAL
    */
    public static final int MANUAL   = 10;

    /**
    *   public constant:    ABOUT
    */
    public static final int ABOUT    = 11;

    // for LWOptionWindow:

    private int id;
    private LogWindow      LW;
    private LWLog       log;

    /**
     *   <b> Constructor  </b><BR>
     *
     *   @param id Command identification number
     *   @param LW Parent LogWindow
     */
    public LWCommand(int id, LogWindow LW) {
        this.id = id;
        this.LW = LW;
        this.log = LW.getLog();

    }

    /**
     *   <b> Constructor  </b><BR>
     *
     *   @param id Command identification number
     */
    public LWCommand(int id) {
        this.id = id;
    }

    private int z;
    private boolean vis, first, last;

    /**
     *   Function: <b> Excecute the Commands </b> <BR>
     *
     *   @param e the ActionEvent for the Command
     *   @see java.awt.event.ActionEvent
     */
    public void actionPerformed(ActionEvent e) {
        switch (id) {
                // for the LogWindow:
            case BACK:
                z=0;
                vis=false;
                first=log.bIsFirst();
                while (!vis && !first) {
                    log.back();
                    vis=LW.isVisible(log.iGetTyp());
                    first=log.bIsFirst();
                    z++;
                }
                if (!vis) {
                    for (int i=0; (i<z); i++) {
                        log.forw();
                    }
                    ;
                };
                LW.showLog();
                break;
            case FOR:
                z=0;
                vis=false;
                last=log.bIsLast();
                while (!vis && !last) {
                    log.forw();
                    vis=LW.isVisible(log.iGetTyp());
                    last=log.bIsLast();
                    z++;
                }
                if (!vis) {
                    for (int i=0; (i<z); i++) {
                        log.back();
                    }
                    ;
                };
                LW.showLog();
                break;
            case REDO:
                if (LW.isVisible(log.iGetTyp())) {
                    LW.Redo(log.iGetTyp(),log.asGetArg());
                }
                break;
            case SAVE:
                log.save();
                break;
            case LOAD:
                log.load(LW);
                break;
            case CHOISE:
                LWChoise LWC = new LWChoise(LW);
                LW.getCBIva().add(LWC);
                break;
            case COPY:
                LW.AnzeigeArgumente.copy();
                break;
            case OPTIONS:
                LW.showOptionsDialog();
                break;
        }
    }

    public void mouseClicked(MouseEvent e) {

        if(e.getClickCount()==1) {
            if (LW.isVisible(log.iGetTyp())) {
                String[] s=log.asGetArg();
                LW.getCBIva().getTelosEditor().getTelosTextArea().setText(s[0]);
            }
        }
        else
            if (LW.isVisible(log.iGetTyp())) {
                String[] s=log.asGetArg();
                if ((log.iGetTyp()==LogWindow.LPICALL)||(log.iGetTyp()==LogWindow.RETELL))
                    LW.getCBIva().getTelosEditor().getTelosTextArea().setText(s[1]);
                if (log.iGetTyp()==LogWindow.ASK)
                    LW.getCBIva().getTelosEditor().getTelosTextArea().setText(s[4]);
            }
    }
}
