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
/**
*   <b> TimeThread for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.FrameBrowser
*   @see i5.cb.workbench.CBIva
*/
package i5.cb.workbench;

import java.util.*;


/**
*   Class:    <b> TimeThread for CBIva  </b><BR>
*   Function: <b> Updates every 60 seconds the time textfield of the Telos Editor. </b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see java.lang.Thread
*   @see i5.cb.workbench.StatusBar
*   @see i5.cb.workbench.CBIva
*/
public class TimeThread extends Thread {
    private StatusBar SB;

    public TimeThread( StatusBar SB) {
        super();
        this.SB=SB;
    }

    /**
    *   Function: <b> Start the Thread </b> <BR>
    */
    public void run() {
        while(true) {
            int year,month,day,hours,minutes;
            Calendar cal = new GregorianCalendar(TimeZone.getTimeZone("UTC"));
            cal.setTime(new Date());
            year = cal.get(Calendar.YEAR);
            month = cal.get(Calendar.MONTH)+1;  // january is internally month 0
            day = cal.get(Calendar.DAY_OF_MONTH);
            hours=cal.get(Calendar.HOUR_OF_DAY);
            minutes=cal.get(Calendar.MINUTE);

            SB.setTime(isoLikeTime(year,month,day,hours,minutes));

            try {
                Thread.sleep(50000);
            }
            catch (InterruptedException e) {}
        }
    }

   /**
   return a string consisting of the decimal digits of val; if the number has only 1 digit, a leading"o" is prepended
   */
   public static String fix2(int val) {
     if (val >= 0 && val <= 9)
       return "0"+val;
     else
      return Integer.toString(val);
   }


    public static String isoLikeTime(int year, int month, int day, int hours, int minutes) {
       return year + "-" + fix2(month) + "-" 
                                  + fix2(day) + " " 
                                  + fix2(hours) + ":" 
                                  + fix2(minutes) + " (UTC)";
    }
}
