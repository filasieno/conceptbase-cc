/*
The ConceptBase.cc Copyright

Copyright 1987-2025 The ConceptBase Team. All rights reserved.

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
package i5.cb.workbench;

import java.io.File;
import java.io.FilenameFilter;

/** <BR>
 * Klasse: <b> LWFileFilter for cbClient 04.97  </b><BR>
 * Funktion: <b> File-Filter fuer Load and Save - Dialoge </b> <BR>
 * Version:<b> 1.0  </b><BR>
 * Author: <b> Rainer Langohr, Rainer Hermanns, Anton van Lieshout  </b><BR>
 * Kuerzel: <b> lw  </b>
*/

public class LWFileFilter implements FilenameFilter {
    /**
    * Der Konstruktor fuer LWFileFilter()
    */
    public LWFileFilter() {}

    /**
    * Die oeffentliche Methode
    * public  boolean accept(File dir, String name)
    * ueberprueft ob ein Filename in Ordnung ist
    */
    public boolean accept(File dir, String name) {
        if (name.endsWith(".log"))
            return true;
        else
            return (new File(dir, name)).isDirectory();
    }
}
