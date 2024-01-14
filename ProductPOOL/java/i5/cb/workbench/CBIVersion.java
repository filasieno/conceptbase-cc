/*
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

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
*   <b> CBICommand for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.FrameBrowser
*   @see i5.cb.workbench.CBIva
*/

package i5.cb.workbench;

import java.util.StringTokenizer;

/**  <BR>
*   Class:    <b> CBIVersion for CBIva  </b><BR>
*   Function: <b> contains a version for CBIvaClient </b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see i5.cb.workbench.CBIvaClient
*   @see i5.cb.workbench.CBIva
*/
public class CBIVersion {
    private String text;

    private String Version;

    private String Name;



    public static String Now="Now";


    public String toString() {
        return text;
    }


    public String getVersion() {
        return Version;
    }


    public CBIVersion() {
        this.text=Now;
        this.Version=Now;
        this.Name=Now;
    }

    public String getName() {
        return Name;
    }




    public String takeTime(String time) {
        int year,month,day,hours,minutes;

        String cutTime=time.substring(12); //cut first 15
        StringTokenizer st=new StringTokenizer(cutTime, ",");
        if (!st.hasMoreElements())
            return "Time Error";
        year=Integer.parseInt(st.nextToken().trim());
        if (!st.hasMoreElements())
            return "Time Error";
        month=Integer.parseInt(st.nextToken().trim());
        if (!st.hasMoreElements())
            return "Time Error";
        day=Integer.parseInt(st.nextToken().trim());
        if (!st.hasMoreElements())
            return "Time Error";
        hours=Integer.parseInt(st.nextToken().trim());
        if (!st.hasMoreElements())
            return "Time Error";
        minutes=Integer.parseInt(st.nextToken().trim());
        return i5.cb.workbench.TimeThread.isoLikeTime(year,month,day,hours,minutes);
        // time string in ISO format assuming UTC timing

    }


    public CBIVersion(String s, String time) {
        this.text=s+ " -- " + takeTime(time);
        this.Version=time;
        this.Name=s;
    }

}



