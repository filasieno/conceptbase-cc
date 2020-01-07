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
package i5.cb.graph;

import java.util.Enumeration;
import java.util.Hashtable;

import javax.swing.event.InternalFrameAdapter;
import javax.swing.event.InternalFrameEvent;

/**
 * Currently this class is needed to monitor if the certain GraphInternalFrame it is added to
 * is active or deactivated. if the frame is activated it tells the frames m_gifWorker to show its progress,
 * if the frame is deactivated it tells the owrker to stop showing its progress
 *
 * @author <a href="mailto:Tobias.Schoeneberg@epost.de">Tobias Schoeneberg</a>
 * @version 1.0
 * @since 1.0
 * @see InternalFrameAdapter
 */
class GraphInternalFrameListener extends InternalFrameAdapter {

	private static GraphEditor m_graphEditor;

	private static Hashtable m_gifPropertiesTable = new java.util.Hashtable();

	public GraphInternalFrameListener(GraphEditor geMain) {
		GraphInternalFrameListener.m_graphEditor = geMain;
	}

	/**
	 * This method is executed if the frame is activeted, for example by a mouseclick or such stuff
	 * It the calls the {@link IFrameWorker#updateProgressBar} method to make the worker update the progressbar
	 *
	 * @param e an <code>InternalFrameEvent</code> value
	 */
	public void internalFrameActivated(InternalFrameEvent e) {
		GraphInternalFrame gif = (GraphInternalFrame) e.getInternalFrame();

		GifProperties props = (GifProperties) m_gifPropertiesTable.get(gif);

		GraphMenuBar graphMenuBar = m_graphEditor.getGraphMenuBar();

		m_graphEditor.setStatusString(props.getStatus());

                if (gif.getGelfile() != null)
                    m_graphEditor.setSubtitle(gif.getGelfile());
               
		java.util.Enumeration buttonKeys = props.getButtons();
		java.util.Enumeration itemKeys = props.getItems();
		java.util.Enumeration menuKeys = props.getMenus();

		String currentKey;

		while (buttonKeys.hasMoreElements()) {
			currentKey = (String) buttonKeys.nextElement();
			//java.util.logging.Logger.getLogger("global").fine("currentKey: "+currentKey);
			m_graphEditor.getToolBarButton(currentKey).setEnabled(
				props.isButtonEnabled(currentKey));
		}

		while (itemKeys.hasMoreElements()) {
			currentKey = (String) itemKeys.nextElement();
			//java.util.logging.Logger.getLogger("global").fine("currentKey: "+currentKey);
			graphMenuBar.getMenuItemByKeyWord(currentKey).setEnabled(
				props.isItemEnabled(currentKey));
		}

		while (menuKeys.hasMoreElements()) {
			currentKey = (String) menuKeys.nextElement();
			//java.util.logging.Logger.getLogger("global").fine("currentKey: "+currentKey);
			graphMenuBar.getMenuByKeyWord(currentKey).setEnabled(
				props.isMenuEnabled(currentKey));
		}

		IFrameWorker gifWorker = gif.getFrameWorker();
		if (gifWorker != null) {
			if (gifWorker.getStatus() == IFrameWorker.STATUS_RUNNING
				&& gifWorker.showsProgressBar()) {
				m_graphEditor.showProgressStatus(true);
				gifWorker.setUpdateProgressBar(
					true,
					m_graphEditor.getProgressBar());
			}
		}
	} //internalFrameActivated

	/**
	 * This method is executed if the frame is deactivated, for example by a mouseclick or such
	 * stuff It the calls the {@link IFrameWorker#setUpdateProgressBar} method with parameter false to
	 * make the worker stop updating the progressbar
	 *
	 * @param e an <code>InternalFrameEvent</code> value
	 */
	public void internalFrameDeactivated(InternalFrameEvent e) {
		m_graphEditor.showProgressStatus(false);
		GraphInternalFrame gif = (GraphInternalFrame) e.getInternalFrame();
		//gif.setSelected(false);
		IFrameWorker gifWorker = gif.getFrameWorker();
		if (gifWorker != null) {
			if (gifWorker.getStatus() == IFrameWorker.STATUS_RUNNING
				&& gifWorker.showsProgressBar()) {
				gifWorker.setUpdateProgressBar(false, null);
			}
		}
	}

	public static void setButtonEnabled(
		GraphInternalFrame gif,
		String sButton,
		boolean enabled) {
		GifProperties props = (GifProperties) m_gifPropertiesTable.get(gif);
		props.setButtonEnabled(sButton, enabled);
		if (gif == m_graphEditor.getActiveGraphInternalFrame()) {
			m_graphEditor.getToolBarButton(sButton).setEnabled(enabled);
		}
	}

	public static void setItemEnabled(
		GraphInternalFrame gif,
		String sItem,
		boolean bEnabled) {
		GifProperties props = (GifProperties) m_gifPropertiesTable.get(gif);
		props.setItemEnabled(sItem, bEnabled);
		if (gif == m_graphEditor.getActiveGraphInternalFrame()) {
			GraphMenuBar graphMenuBar = m_graphEditor.getGraphMenuBar();
			graphMenuBar.getMenuItemByKeyWord(sItem).setEnabled(bEnabled);
		}
	}

	public static void setMenuEnabled(
		GraphInternalFrame gif,
		String sMenu,
		boolean bEnabled) {
		GifProperties props = (GifProperties) m_gifPropertiesTable.get(gif);
		props.setMenuEnabled(sMenu, bEnabled);
		if (gif == m_graphEditor.getActiveGraphInternalFrame()) {
			GraphMenuBar graphMenuBar = m_graphEditor.getGraphMenuBar();
			graphMenuBar.getMenuByKeyWord(sMenu).setEnabled(bEnabled);
		}
	}

	public static void setStatus(GraphInternalFrame gif, String status) {
		GifProperties props = (GifProperties) m_gifPropertiesTable.get(gif);
		props.setStatus(status);

		if (gif == m_graphEditor.getActiveGraphInternalFrame()) {
			m_graphEditor.setStatusString(status);
		}
	}

	/**
	 * Supposed to be called only by GraphEditor.addGRaphInternalFrame
	 *
	 */
   static void addGifPropertiesEntry(GraphInternalFrame gif) {
		
		m_gifPropertiesTable.put(gif, new GifProperties());
	}

	
} //GraphInternalFrameListener

class GifProperties {

        /** Holds value of property sStatus. */
        private String m_sStatus;

        private Hashtable htButtons = new java.util.Hashtable();

        private Hashtable htItems = new java.util.Hashtable();

        private Hashtable htMenus = new java.util.Hashtable();

        /** Getter for property sStatus.
         * @return Value of property sStatus.
         */
         String getStatus() {
            return m_sStatus;
        }

        /** Setter for property sStatus.
         * @param sStatus New value of property sStatus.
         */
         void setStatus(String status) {
            this.m_sStatus = status;
        }

         void setButtonEnabled(String sButton, boolean enabled) {
            htButtons.put(sButton, new Boolean(enabled));
        }

         void setItemEnabled(String sItem, boolean enabled) {
            htItems.put(sItem, new Boolean(enabled));
        }

         void setMenuEnabled(String sMenu, boolean enabled) {

            htMenus.put(sMenu, new Boolean(enabled));
        }

         boolean isButtonEnabled(String sButton) {
            return ((Boolean) htButtons.get(sButton)).booleanValue();
        }

         boolean isItemEnabled(String sItem) {
            return ((Boolean) htItems.get(sItem)).booleanValue();
        }

         boolean isMenuEnabled(String sMenu) {
            return ((Boolean) htMenus.get(sMenu)).booleanValue();
        }

         java.util.Enumeration getButtons() {
            return htButtons.keys();
        }

         java.util.Enumeration getItems() {
            return htItems.keys();
        }

         Enumeration getMenus() {
            return htMenus.keys();
        }
    } //GifProperties
