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
package i5.cb.graph.cbeditor.components;

import i5.cb.graph.cbeditor.*;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;



/**
 *  Handles the {@link i5.cb.graph.cbeditor.CBConnectioDialog}'s actionevents
 * I chosed not to use {@link i5.cb.graph.cbeditor.CBCommand} because there are some different actionEvents that should be handled by one instance. For example both the comboBox and the connectbutton have an ActionListener registered, but when the startbutton is presses we still nedd to know theselected combobox-item.
 *
 * @author     schoeneb
 * @created    07 March 2002
 */
class ConnectionDLGCommand implements ActionListener, PropertyChangeListener {


    private static CBFrame m_newFrame;

    private static String m_sHost;

    private static String m_sPort;

    private static Object m_oPalette;

    private static Object m_oSelectedObject;
    
    private static Object    m_oSelectedModule;

    private static CBConnectionDialog m_dOwner;

    private static CBEditor m_cbEditor;

    /** Constructor for the ConnectionDLGCommand object
     *
     * @param iActionID dtermines which action to perform when the actionperformed-method is invoked
     */
    public ConnectionDLGCommand() {
    }//<init>

    static void setOwner(CBConnectionDialog owner) {
        assert owner != null : "ConnectionDLGCommand.setCBEditor: owner may not be null";
        m_dOwner = owner;

    }//setOwner

    static void setCBEditor(CBEditor cbEditor) {
        assert cbEditor != null : "ConnectionDLGCommand.setCBEditor: cbEditor may not be null";
        m_cbEditor = cbEditor;
    }//cbEditor

    /** Do something depending on the value of the <CODE>iActionID</CODE>
     * @param ae an ActionEvent
     */
    public void actionPerformed(ActionEvent ae) {

        /*
         *  Tries to establish a connection to the user-specified
         *  ConceptBase s erver. If this was successful, a new {@link
         *  i5.cb.graph.cbeditor/CBFrame} is opened in the {@link
         *  i5.cb.graph.cbeditor.CBEditor} window
         */

        m_dOwner.dispose();

        m_sHost = m_dOwner.getHost();
        m_sPort = m_dOwner.getPort();
        m_oPalette = m_dOwner.getGraphicalPalette();
        m_oSelectedObject = m_dOwner.getSelectedObject();
        m_oSelectedModule = m_dOwner.getModule();

        m_newFrame = new CBFrame(m_cbEditor,
                                 m_sHost + ":" + m_sPort,
                                 (String)m_oPalette);
        int iPort = Integer.parseInt(m_sPort);

        Object[] task = {m_newFrame, m_sHost, new Integer(iPort), (String)m_oSelectedObject, (String) m_oSelectedModule};
        CBFrameWorker gifWorker = (CBFrameWorker)m_newFrame.getFrameWorker();

        gifWorker.addPropertyChangeListener( (PropertyChangeListener)this );

        gifWorker.setTask(CBFrameWorker.TASK_CONNECT, task);
        gifWorker.restartFrameWorker();

    }//actionPerformed

    /** used to inform this instance about a failure of the connection, which causes it to show the
     * connectiondialog again
     * @param evt
     */
    public void propertyChange(PropertyChangeEvent evt) {
        String sPropertyName = evt.getPropertyName();
        if(sPropertyName.equals("ConnectionSuccess") ) {
            if( ((Boolean)evt.getNewValue()).booleanValue() == false) {

                m_dOwner = new CBConnectionDialog(m_cbEditor, true);
                m_dOwner.setVisible(true);

            }

        }
    }//propertyChange

    static String getHost() {
        return m_sHost;
    }

    static String getPort() {
        return m_sPort;
    }

    static Object getSelectedTelosObject() {
        return m_oSelectedObject;
    }

    static Object getSelectedPalette() {
        return m_oPalette;
    }
}

