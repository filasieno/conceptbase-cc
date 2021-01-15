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
*   <b> for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.TelosEditor
*   @see i5.cb.workbench.CBIva
*/

package i5.cb.workbench;

import i5.cb.graph.cbeditor.CBUtil;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import i5.cb.CBConfiguration;

/**  <BR>
*   Class:    <b> TECommand for CBIva  </b><BR>
*   Function: <b> Implents ActionListener for the TelosEditor </b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see i5.cb.workbench.TelosEditor
*   @see i5.cb.workbench.CBIva
*   @see java.awt.event.ActionListener
*/

public class TECommand implements ActionListener {

    /*
     * iID_DIM legt den Umrechnungsfaktor fuer die Konstanten fest, die die Kommandos/Menues/Menueeintraege kodieren.
     * Die Funktionsweise hierbei:
     * Jedes Menue erhaelt hierbei ein Vielfaches von iID_DIM als Identifizierer zugeordnet.
     * Jeder Menueeintrag erhaelt dann als "Offset" den Identifizierer seines Menues zuzueglich einer Konstante, die den
     * Menueeintrag bestimmt, zugeordnet.
     *
     */

    /**
    *   public constant: iCLEAR       = 0
    */
    public static final int iCLEAR       = 0;

    /**
    *   public constant: iCUT         = 1
    */
    public static final int iCUT         = 1;

    /**
    *   public constant: iCOPY        = 2
    */
    public static final int iCOPY        = 2;

    /**
    *   public constant: iPASTE       = 3
    */
    public static final int iPASTE       = 3;

    /**
    *   public constant: iPM_DISPLAY_INSTANCES = 10
    */
    public static final int iPM_DISPLAY_INSTANCES = 10;

    /**
    *   public constant: iPM_LOAD_OBJECT = 11
    */
    public static final int iPM_LOAD_OBJECT = 11;

    /**
    *   public constant: iPM_OBJECT_TREE = 12
    */
    public static final int iPM_OBJECT_TREE = 12;

    /**
    *   public constant: iTOGRAPHEDITOR = 13
    */
    public static final int iTOGRAPHEDITOR = 13;

    /**
    *   public constant: iPM_CHANGE_MODULE = 14
    */
    public static final int iPM_CHANGE_MODULE = 14;

    /**
    *   public constant: iSMALL = 15
    */
    public static final int iSMALL = 15;

    /**
    *   public constant: iLARGE = 16
    */
    public static final int iLARGE = 16;

    /**
    *   public constant: iNOT_AVAILABLE = 999
    */
    static final int iNOT_AVAILABLE = 999;

    private int iIdentifier;
    private CBIvaClient CBclient;
    private TelosEditor teTelosEditor;


    /**
    *   <b> Constructor  </b><BR>
    *
    *  @param iAnIdentifier   Command identification number
    *  @param teTelosEditor  parent TelosEditor*
    *
    *  @see i5.cb.workbench.TelosEditor
    */
    public TECommand(int iAnIdentifier, TelosEditor teTelosEditor) {
        this.iIdentifier = iAnIdentifier;
        this.teTelosEditor = teTelosEditor;
        this.CBclient = teTelosEditor.getCBIva().getCBClient();
    }

    /**
    *  @param iAnIdentifier   Command identification number
    *  @param CBclient     a CBIvaClient
    *
    *  @see i5.cb.workbench.CBIvaClient
    */
    public TECommand(int iAnIdentifier, CBIvaClient CBclient) {
        this.iIdentifier = iAnIdentifier;
        this.CBclient = CBclient;
    }

    /**
    *   Function: <b> Excecute the Commands </b> <BR>
    *
    *   @param event the ActionEvent for the Command
    *   @see java.awt.event.ActionEvent
    */
    public void actionPerformed(ActionEvent event) {
        TelosEditor te=teTelosEditor;
        te.getCBIva().getStatusBar().insertMessage("");

        switch (iIdentifier) {
                /*
                 * Edit|Cut
                 */
            case iCUT:
                te.getTelosTextArea().cut();
                break;
                /*
                 * Edit|Copy
                 */
            case iCOPY:
                te.getTelosTextArea().copy();
                break;
                /*
                 * Edit|Paste
                 */
            case iPASTE:
                te.getTelosTextArea().paste();
                break;
                /*
                 * Edit|Clear
                 */
            case iCLEAR:
                te.getTelosTextArea().setText("");
                break;

            case iSMALL:
                te.getTelosTextArea().setTextFontSize(CBConfiguration.getCBIvaSmallfont());
                break;

            case iLARGE:
                te.getTelosTextArea().setTextFontSize(CBConfiguration.getCBIvaLargefont());
                break;


            case iTOGRAPHEDITOR:
                final String sObject1=te.getTelosTextArea().getSelectedText();
                if(teTelosEditor.getCBIva().getCBEditor()==null) {
                //add the object in a newly started graph browser
                   Thread th=new Thread() {
                       public void run() {
                           teTelosEditor.getCBIva().setCBEditor(i5.cb.graph.cbeditor.CBEditor.startCBEditorWithWorkbench(teTelosEditor.getCBIva(),
                               teTelosEditor.getCBIva().getCBClient(),sObject1));
                       }
                   };
                   th.start();
                } else  {
                //add the object in the graph browser also, if it is present
                  if(teTelosEditor.getCBIva().getCBEditor().getActiveGraphInternalFrame() !=null &&
                        ((i5.cb.graph.cbeditor.CBFrame)(teTelosEditor.getCBIva().getCBEditor().getActiveGraphInternalFrame())).isConnected()){
                      CBUtil.createAndAddNewDiagramObject(sObject1,
                                (i5.cb.graph.cbeditor.CBFrame)teTelosEditor.getCBIva().getCBEditor().getActiveGraphInternalFrame(),null);
                  }
                  else  {
                        te.getCBIva().getStatusBar().insertMessage("CBEditor not connected to server, or no Frame selected");
                  }
                }
                break;

                /* PopupMenu- Display Instances */
            case iPM_DISPLAY_INSTANCES: {
                    String sObject=te.getTelosTextArea().getSelectedText();
                    if (sObject!=null) {
                        InstanceDialog idDialog=new InstanceDialog(te.getCBIva());
                        te.getCBIva().add(idDialog);
                        idDialog.findInstances(sObject);
                    }
                    break;
                }

                /* PopupMenu- Load Object */
            case iPM_LOAD_OBJECT: {
                    String sObject=te.getTelosTextArea().getSelectedText();
                    if (sObject!=null) {
                        String sResult=CBclient.getObject(sObject);
                        if ((sResult!=null) && !sResult.equals("error"))
                            te.setTelosText(sResult);
                    }
                    break;
                }

                /* PopupMenu- Change Module */
            case iPM_CHANGE_MODULE: {
                    String sModule=te.getTelosTextArea().getSelectedText();
                    if (sModule!=null) {
                        CBclient.setModule(sModule);
                    }
                    break;
                }

/* FrameTree no longer in use since it depends on the old Motif package;
   It does not compile under Java 9 anymore, issue #6
            case iPM_OBJECT_TREE: {
                    String sSelected=te.getTelosTextArea().getSelectedText();
                    if (sSelected != null)  {
                        FrameTree ftObject=new FrameTree(te.getTelosTextArea().getSelectedText(),te);
                        te.getCBIva().add(ftObject);
                    }
                    else  {
                        te.getCBIva().getStatusBar().insertMessage("No Object Selected");
                    }
                }
*/



        }
    }



    /**
    *   <b> alternativ Constructor  </b><BR>
    *
    *   The iIdentificator is set to iNOT_AVAILABLE.
    *   The Constructor is used to creakte a TECommand without a
    *   special Command  (for WindowListener and MouseListener).
    *
    *  @param teATelosEditor  a TelosEditor
    *
    *  @see i5.cb.workbench.TelosEditor
    */
    public TECommand(TelosEditor teATelosEditor) {
        this(iNOT_AVAILABLE, teATelosEditor);
    }




}

