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
 *   <b> LWLog for CBIva 02.98  (ConceptBase) </b>
 *
 *   @see i5.cb.workbench.LogWindow
 *   @see i5.cb.workbench.CBIva
 */
package i5.cb.workbench;

import java.awt.*;
import java.io.*;

/**
 *   Class:    <b> LWLog for CBIva  </b><BR>
 *   Function: <b> Contains a Logbook for LogWindow </b> <BR>
 *
 *   @version 0.8 beta
 *   @author    Rainer Langohr
 *
 *   @see i5.cb.workbench.LogWindow
 *   @see i5.cb.workbench.CBIva
 */
class LWLog {

    private FileDialog openLogDialog, saveLogDialog;
    private String[] str={"","","",""};
    private boolean bSaved;
    private String sFileName="new.log";
    private String sFilename=null;
    private File file;
    private FilenameFilter filter = new MyFilenameFilter(".log");

    protected Event event;
    protected LogI FIRST, LAST, AKTUELL;
    protected int iAnzahl=0;
    protected Frame fOpen = new Frame();
    protected Frame fSave = new Frame();

    protected class LogI {
        public LogI NEXT, BACK;
        public int iNr;
        public String sTypLog;
        public int iTypLog;
        public String[] asArgLog;
        public boolean bSuccessLog;

        public LogI(LogI back, String sTyp, int iTyp, String[] asArg, boolean bSuccess, int iNummer) {
            BACK = back;
            sTypLog = sTyp;
            iTypLog = iTyp;
            asArgLog=asArg;
            bSuccessLog=bSuccess;
            iNr=iNummer;
        }
    }

    private void init() {
        iAnzahl = 0;
        bSaved = true;
        // Erzeugen eines Dummy-Elementes:
        FIRST = new LogI(FIRST, null, 0, str, true, iAnzahl);
        AKTUELL = FIRST;
        LAST = FIRST;
    }


    /**
     *   <b> Constructor  </b><BR>
     *
     *   Function: <b> creates a new logbook </b> <BR>
     */
    public LWLog() {
        init();
        openLogDialog = new FileDialog(fOpen,"Load Log",FileDialog.LOAD);
        saveLogDialog = new FileDialog(fSave,"Save Log File",FileDialog.SAVE);
    };

    /**
     *   Function: <b> creates a new entry with the given values </b> <BR>
     *
     *   @param sTyp Commandname
     *  @param iTyp Commandnumber
     *  @param asArg  Arguments of the Command
     *  @param bSuccess Successfully?
     */
    public void add
        (String sTyp, int iTyp, String[] asArg, boolean bSuccess) {
        iAnzahl++;
        bSaved=false;
        LAST.NEXT = new LogI(LAST, sTyp, iTyp, asArg, bSuccess, iAnzahl);
        LAST = LAST.NEXT;
    };

    /**
     *   @return actual Commandname 
     */
    public String sGetTyp() {
        return AKTUELL.sTypLog;
    }
    /**
     *   @return actual Commandnumber 
     */
    public int    iGetTyp() {
        return AKTUELL.iTypLog;
    }
    /**
     *   @return actual Commandarguments </b> <BR>
     */
    public String[] asGetArg() {
        return AKTUELL.asArgLog;
    }
    /**
     *   @return actual Commands counter </b> <BR>
     */
    public int iGetNumber() {
        return AKTUELL.iNr;
    }

    /**
     *   @return <code>true</code>  if actual command was successfully <BR>
     *           <code>false</code>  otherwise
     */
    public boolean bGetSuccess() {
        return AKTUELL.bSuccessLog;
    }
    /**
     *   @return <code>true</code>  if Loogbook is empty <BR>
     *           <code>false</code>  otherwise
     */
    public boolean bIsEmpty() {
        return (iAnzahl==0);
    };
    /**
     *   @return <code>true</code>  if command is first entry of the Loogbook<BR>
     *           <code>false</code>  otherwise
     */
    public boolean bIsFirst() {
        return (AKTUELL.iNr<=1);
    }
    /**
     *   @return <code>true</code>  if command is last entry of the Loogbook<BR>
     *           <code>false</code>  otherwise
     */
    public boolean bIsLast()  {
        return (AKTUELL.iNr==iAnzahl);
    }
    /**
     *   @return <code>true</code>  if Loogbook is saved<BR>
     *           <code>false</code>  otherwise
     */
    public boolean bIsSaved() {
        return bSaved;
    }

    /**
     *   Function: <b> go one entry back </b> <BR>
     */
    public void back() {
        if (!bIsFirst()) {
            AKTUELL = AKTUELL.BACK;
        }
        ;
    }
    /**
     *   Function: <b> go one entry forward </b> <BR>
     */
    public void forw() {
        if (!bIsLast()) {
            AKTUELL = AKTUELL.NEXT;
        }
        ;
    }
    /**
     *   Function: <b> go to last entry </b> <BR>
     */
    public void last() {
        AKTUELL = LAST;
    };

    /**
     *   Function: <b> delete all entries </b> <BR>
     */
    public void delete() {
        init();
    }


    /**
     *   Function: <b> save logbook </b> <BR>
     */
    public void save() {
        if (!bSaved) {
            saveLogDialog.setFile(sFileName);
            saveLogDialog.setFilenameFilter(filter);
            saveLogDialog.setVisible(true);
            sFilename = null;
            sFilename = saveLogDialog.getFile();
            if (sFilename!=null) {
                LWFileOutputStream fos = null;
                try {
                    file = new File(sFilename);
                    if (!file.exists() || (file.isFile() && file.canWrite())) {
                        try {
                            fos = new LWFileOutputStream(file);
                        }
                        catch (IOException e) {}
                        ;
                        sFileName = sFilename;
                        bSaved = true;
                        LogI P = FIRST;
                        fos.writeTop(); // Schreibt Identifikation
                        for(int i=0; i<iAnzahl; i++) {
                            P = P.NEXT;
                            fos.write(P.sTypLog);
                            fos.write(P.asArgLog[0]);
                            if (P.iTypLog == LogWindow.RETELL || P.iTypLog==LogWindow.LPICALL)
                                fos.write(P.asArgLog[1]);
                            if (P.iTypLog == LogWindow.ASK) {
                                fos.write(P.asArgLog[1]);
                                fos.write(P.asArgLog[2]);
                                fos.write(P.asArgLog[3]);
                                fos.write(P.asArgLog[4]);
                            }
                        } // for
                    } // if ex
                } // try
                finally {
                    try {
                        fos.close();
                    }
                    catch(IOException e) {}
                    ;
                }
            } // null
        } // saved?
    } // Metode

    private LogWindow LW;

    /**
     *   Function: <b> load logbook </b> <BR>
     */
    public void load(LogWindow LW) {
        this.LW = LW;
        LoadNow();
    }

    private String sInput;


    public LogCmd[] getList() {
        //  String[] List=new String[iAnzahl*6];
        LogCmd[] List=new LogCmd[iAnzahl];


        LogI P = FIRST;
        for(int i=0; i<iAnzahl; i++) {
            P = P.NEXT;
            List[i] = new LogCmd(P.sTypLog, P.iTypLog, P.asArgLog, i+1);
        }

        return List;

    }














    public void LoadNow() {
        openLogDialog.setFilenameFilter(filter);
        openLogDialog.setVisible(true);
        sFilename = null;
        sFilename = openLogDialog.getDirectory() + openLogDialog.getFile();
        if (openLogDialog.getFile()!=null) {
            LWFileInputStream fis = null;
            try {
                file = new File(sFilename);
                if (file.exists() && file.isFile())  {
                    try {
                        fis = new LWFileInputStream(file);
                    }
                    catch (IOException e) {}
                    ;
                    if (fis.IsTop()) {              // prueft Identifikation
                        sFileName = sFilename;
                        init();                     // Loeschen des Logbuches
                        LW.showLog();
                        do {
                            sInput = fis.readStr();
                            if (sInput == null)
                                break;
                            String[] as={null, null, null, null,null};
                            int id = 99;
                            if      (sInput.equals("TELL"))   {
                                id=LogWindow.TELL;
                                as[0]= fis.readStr();
                            }
                            else if (sInput.equals("UNTELL")) {
                                id=LogWindow.UNTELL;
                                as[0]= fis.readStr();
                            }
                            else if (sInput.equals("RETELL")) {
                                id=LogWindow.RETELL;
                                as[0]= fis.readStr();
                                as[1]=fis.readStr();
                            }
                            else if (sInput.equals("ASK"))    {
                                id=LogWindow.ASK;
                                as[0]= fis.readStr();
                                as[1]= fis.readStr();
                                as[2]= fis.readStr();
                                as[3]= fis.readStr();
                                as[4]= fis.readStr();
                            }
                            else if (sInput.equals("TELLMODEL")) {
                                id=LogWindow.TELLMODEL;
                                as[0]= fis.readStr();
                            }
                            else if (sInput.equals("LPICALL")) {
                                id=LogWindow.LPICALL;
                                as[0]= fis.readStr();
                                as[1]=fis.readStr();
                            }
                            else if (sInput.equals("ERROR")) {
                                id=LogWindow.ERROR;
                                as[0]= fis.readStr();
                            }
                            else if (sInput.equals("OTHER")) {
                                id=LogWindow.OTHER;
                                as[0]= fis.readStr();
                            }
                            LW.insertOperation(id, as, true);
                        }
                        while(true);
                        bSaved = true;
                    } // isTop
                } // if ex
            } // try
            finally {
                try {
                    fis.close();
                }
                catch(IOException e) {}
                ;
            }
        } // null
    } // metode
}

















