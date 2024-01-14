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
package i5.cb.graph;

import javax.swing.JProgressBar;

/**
 * Every graphInternalFrame may have a thread running in background which implements this interface, 
 * so that it can give us some info about its working progress. The info should be used in a progressbar
 *
 * @author <a href="mailto:">Tobias Schoeneberg</a>
 * @version 1.0
 * @since 1.0
 */
public interface IFrameWorker extends Runnable {


    public final int FLAG_PAUSE = 1;
    public final int FLAG_RESUME = 2;
    public final int FLAG_STOP = 3;
    public final int FLAG_RESTART = 4;
    public final int FLAG_NOFLAG = 5;

    public final int STATUS_READY = 10;
    public final int STATUS_RUNNING = 7;
    public final int STATUS_PAUSING = 8;
    public final int STATUS_FINISHED = 9;

    /**
     * Tells the worker whether it shall show it's progress in the progressbar we provide
     *
     * @param bUpdate a <code>boolean</code> value used to switch on and off the progress-display 
     * thus serving the worker from wasting time on updating a progressbar that isn't shown
     * @param pBar a <code>JProgressBar</code> value. That's the progressbar to use if bUpdate is true. May be null if bUpdate is false
     */
    public void setUpdateProgressBar(boolean bUpdate, JProgressBar pBar);


    /**
     * Makes the gifWoker stop it's work. This method is intended to make the m_gifWorker thread die
     *
     */
    public void stopFrameWorker();


    /**
     * Makes the m_gifWorker have a break. The method is not intended to let the thread die
     *
     */
    public void pauseFrameWorker();


    public void resumeFrameWorker();

    /**
     * Makes the m_gifWorker start doing its work right from the beginning. It should be irrelevant whether 
     * the thread just has its break, was killed by stopGifWorker or just finished its work
     *
     */
    public void restartFrameWorker();


/**
 * Tells the current Status of this.
 * 
 * @return one of N_POSITION, E_POSITION, S_POSITION or E_POSITION.
 */
    public int getStatus();

    /**
     * Tells if this gifworker wants to maintain show a progressbar.
     */
    public boolean showsProgressBar();

}
