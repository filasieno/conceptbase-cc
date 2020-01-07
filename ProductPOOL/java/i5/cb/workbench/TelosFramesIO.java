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
 *   <b> TelosFrames for CBIva 02.98  (ConceptBase) </b>
 *
 *   @see i5.cb.workbench.FrameBrowser
 *   @see i5.cb.workbench.CBIva
 */

package i5.cb.workbench;

import i5.cb.telos.frame.*;

import java.awt.FileDialog;
import java.awt.Frame;
import java.io.*;

import javax.swing.JOptionPane;

/**
 *   Class:    <b> TelosFramesIO for CBIva  </b><BR>
 *   Function: <b> Extends TelosFrames with Load and Save </b> <BR>
 *
 *   @version 0.8 beta
 *   @author    Rainer Langohr
 *
 *   @see i5.cb.telos.frame.TelosFrames
 *   @see i5.cb.workbench.CBIva
 */
public class TelosFramesIO extends TelosFrames {
    /**
     *   Function: <b> save the TelosFrames </b> <BR>
     */
    public void save() {
        FileDialog fdSave=new FileDialog(new Frame());
        fdSave.setDirectory(CBIva.getProp("user.dir",""));
        fdSave.setFile("*.sml");
        fdSave.setMode(1);
        fdSave.setVisible(true);
        if (fdSave.getDirectory()!=null && fdSave.getFile()!=null) {
            File file = new File(fdSave.getDirectory(),fdSave.getFile());
            // Save:
            try {
                FileOutputStream FOS=new FileOutputStream(file);
                DataOutputStream DOS=new DataOutputStream(FOS);
                java.util.Enumeration en=this.elements();
                while (en.hasMoreElements())
                    ((TelosFrame)(en.nextElement())).writeTelos(DOS);
                FOS.flush();
                FOS.close();
            }
            catch(FileNotFoundException e) {
                System.out.println(e);
            }
            catch(IOException e) {
                System.out.println(e);
            }
        }
    }

    /**
     *   Function: <b> load TelosFrames </b> <BR>
     */
    public void load() {
        FileDialog fdLoad=new FileDialog(new Frame());
        fdLoad.setDirectory(CBIva.getProp("user.dir",""));
        fdLoad.setMode(0);
        fdLoad.setFile("*.sml");
        fdLoad.setVisible(true);
        String sDir  = fdLoad.getDirectory();
        String sFile = fdLoad.getFile();
        if (sDir!=null && sFile!=null) {
            File file= new File(sDir,sFile);
            boolean bRead=false;
            try {
                FileInputStream FIS=new FileInputStream(file);
                TelosParser parser=new TelosParser(FIS);
                TelosFrames frames=parser.telosFrames();
                java.util.Enumeration eframes=frames.elements();
                while(eframes.hasMoreElements()) {
                    bRead=true;
                    this.add(eframes.nextElement());
                }
                FIS.close();
            }
            catch(ParseException e1) {}
            catch (FileNotFoundException error) {
                JOptionPane.showMessageDialog(null,"File not found","Error",JOptionPane.ERROR_MESSAGE);
            }
            catch(IOException e2) {}
            if (!(bRead))
                JOptionPane.showMessageDialog(null,"Error while loading file","Error",JOptionPane.ERROR_MESSAGE);
        }
    }
}
