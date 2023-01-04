/*
The ConceptBase.cc Copyright

Copyright 1987-2023 The ConceptBase Team. All rights reserved.

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
*   <b> LWFileOutputStream for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.LogWindow
*   @see i5.cb.workbench.CBIva
*/
package i5.cb.workbench;
import java.io.*;

/**  <BR>
*   Class:    <b> LWFileOutputStream for CBIva  </b><BR>
*   Function: <b> Extends FileOutputStream to write Strings</b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see java.io.FileOutputStream
*   @see i5.cb.workbench.LogWindow
*   @see i5.cb.workbench.CBIva
*/
public class LWFileOutputStream extends FileOutputStream {

    /**
    *   <b> Constructor  </b><BR>
    *
    *   @param file File to write
    *   @exception IOException
    *   @see java.io.IOException
    *
    */
    public LWFileOutputStream(File file) throws IOException {
        super(file.getPath());
    }

    private DataOutputStream dos;
    private String wort;

    /**
    *   Function: <b> write a sting to the File </b> <BR>
    *
    *   @param wort the string to write
    */
    public void write(String wort) {
        dos = new DataOutputStream(this);
        wort = wort + "\000";
        try {
            dos.writeChars(wort);
        }
        catch (IOException e) {}
        ;
    }


    /**
    *   Function: <b> write topline to file </b> <BR>
    *
    *   topline = "(Log File for CBIva) \n"
    */
    public void writeTop() {
        dos = new DataOutputStream(this);
        wort = "(Log File for CBIva) \n";
        try {
            dos.writeChars(wort);
        }
        catch (IOException e) {}
        ;
    }

}



