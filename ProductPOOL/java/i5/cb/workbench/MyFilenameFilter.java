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
*   <b> MyFilenameFilter for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.FrameBrowser
*   @see i5.cb.workbench.CBIva
*/
package i5.cb.workbench;

import java.io.File;
import java.io.FilenameFilter;

/**
*   Class:    <b> MyFilenameFilter for CBIva  </b><BR>
*   Function: <b> Creates personal FileNameFilter for TelosEditor </b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see java.io.FilenameFilter
*   @see i5.cb.workbench.TelosEditor
*   @see i5.cb.workbench.CBIva
*/
class MyFilenameFilter implements FilenameFilter {
    private String sExtension;

    /*
    *   <b> Constructor  </b><BR>
    *
    *   @param sAExtension the Extension to filter
    */
    public MyFilenameFilter(String sAExtension) {
        sExtension = sAExtension;
    }


    /**
    *   Function: <b> check if a Fiele is accepted</b> <BR>
    *
    *   @param fDir Path
    *   @param sName Filename
    */
    public boolean accept(File fDir, String sName) {
        return (sName.endsWith(sExtension));
    }
}

