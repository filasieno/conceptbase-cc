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
*   <b> FBCommand for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.FrameBrowser
*   @see i5.cb.workbench.CBIva
*/
package i5.cb.workbench;

import java.awt.Dialog;
import java.awt.event.*;

/**
*   Class:    <b> FBCommand for CBIva  </b><BR>
*   Function: <b> Implements ActionListener for the FrameBrowser </b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see java.awt.event.ActionListener
*   @see i5.cb.workbench.FrameBrowser
*   @see i5.cb.workbench.CBIva
*/
public class FBCommand extends MouseAdapter implements ActionListener  {

    /**
     *  public Constant:         OK=0
     */
    public static final int OK=0;
    /**
     *  public Constant:         LOAD=1
     */
    public static final int LOAD=1;
    /**
     *  public Constant:         SAVE=2
     */
    public static final int SAVE=2;
    /**
     *  public Constant:         DELETE_CACHE=3
     */
    public static final int DELETE_CACHE=3;
    /**
     *  public Constant:         UPDATE=4
     */
    public static final int UPDATE=4;
    /**
     *  public Constant:         CACHE=5;
     */
    public static final int CACHE=5;
    /**
     *  public Constant:         TELOSEDITOR=6
     */
    public static final int TELOSEDITOR=6;
    /**
     *  public Constant:  ADDQUERYRESULT=13
     */
    public static final int ADDQUERYRESULT=13;
    /**
     *  public Constant: CANCEL_RESULT=9
     */
    public static final int CANCEL_RESULT=9;
    /**
     *  public Constant: POPUP_BROWSE=10
     */
    public static final int POPUP_BROWSE=10;
    /**
     *  public Constant: POPUP_TELOS=11
     */
    public static final int POPUP_TELOS=11;
    /**
     *  public Constant: LIST=12
     */
    public static final int LIST=12;
    /**
     *  public Constant: OK_RESULT=14
     */
    public static final int OK_RESULT=14;
    /**
     *  public Constant: CLEAR_CACHE=15
     */
    public static final int CLEAR_CACHE=15;
    /**
     *  public Constant: OK_CACHE=16
     */
    public static final int OK_CACHE=16;
    /**
     *  public Constant: DOUBLECLICK_CACHE=17
     */
    public static final int DOUBLECLICK_CACHE=17;


    private int id;
    private Dialog target;
    private FrameBrowser fb;
    private RList list;
    private int menId;

    /**
    *   <b> Constructor  </b><BR>
    *
    *   @param id Identification Number
    *
    */
    public FBCommand(int id) {
        this.id=id;
    }

    /**
    *   <b> Constructor  </b><BR>
    *
    *   @param id   Identification Number
    *   @param menId Identification Number of the Menu
    *   @param fb   FrameBrowser
    *
    *   @see i5.cb.workbench.FrameBrowser
    */
    public FBCommand(int id, int menId, FrameBrowser fb) {
        this.id=id;
        this.menId=menId;
        this.fb=fb;
    }



    /*  * Command fuer FrameBrowser-Window: <BR>
     * Diese oeffentliche Methode
     * ordnet die einzelnen Commandos des FrameBrowser-Windows zu
     * @see i5.cb.workbench.FrameBrowser
     */
    public FBCommand(int id, FrameBrowser fb) {
        this.id=id;
        this.fb=fb;
    }

    /**
    *   <b> Constructor  </b><BR>
    *
      @param id    Identification Number
    *   @param target  a Dialog
    *   @param fb    FrameBrowser
    *
    *  @see java.awt.Dialog
    *  @see i5.cb.workbench.FrameBrowser
    */
    public FBCommand(int id, Dialog target, FrameBrowser fb) {
        this.id=id;
        this.target=target;
        this.fb=fb;
    }


    /**
     * Fuer MouseListener der Listbox AttributeClasses
     * */
    public FBCommand(RList lb, FrameBrowser fb)  {
        list=lb;
        this.fb=fb;
    }

    /**
    *   Function: <b> Excecute the Commands </b> <BR>
    *
    *   @param e the ActionEvent for the Command
    *   @see java.awt.event.ActionEvent
    */
    public void actionPerformed (ActionEvent e) {
        switch (id) {

            case OK:
                fb.okClicked();
                break;

            case LOAD:
                fb.loadClicked();
                break;

            case UPDATE:
                fb.updateClicked();
                break;

            case SAVE:
                fb.saveClicked();
                break;

            case ADDQUERYRESULT:
                fb.addQueryResultsClicked();
                break;
            case POPUP_TELOS:
                fb.popTelos(menId);
                break;

            case POPUP_BROWSE:
                fb.popBrowse(menId);
                break;

            case TELOSEDITOR:
                fb.telosClicked();
                break;

            case CACHE:
                fb.cacheClicked();
                break;

            case CLEAR_CACHE:
                fb.getCache().clear();
                target.dispose();
                break;

            case OK_CACHE:
                if (((FBCacheDialog)target).getCacheList().getSelectedIndex()!=-1) {

                    fb.getObject().setText(((FBCacheDialog)target).getObject());
                    fb.update(((FBCacheDialog)target).getCacheList().getSelectedIndex());
                }
                target.dispose();
                break;

            case DOUBLECLICK_CACHE:
                fb.getObject().setText(((FBCacheDialog)target).getObject());
                fb.update(((FBCacheDialog)target).getCacheList().getSelectedIndex());
                target.dispose();
                break;

            case DELETE_CACHE:
                if (((FBCacheDialog)target).getCacheList().getSelectedIndex()!=-1) {

                    int i=((FBCacheDialog)target).getCacheList().getSelectedIndex();
                    fb.getCache().remove(i);
                    ((FBCacheDialog)target).getCacheList().remove(i);
                }
                break;
        }
    }

    /**
    *   Function: <b> Excecute the Commands </b> <BR>
    *
    *   @param e the ActionEvent for the Command
    *   @see java.awt.event.ActionEvent
    */
    public void mouseReleased(MouseEvent e) {
        if (list.getSelectedIndex()!=-1) {
            fb.SelectedAttributes();
        }

    }
}
