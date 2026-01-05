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
package i5.cb.graph;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Locale;
import java.util.logging.Logger;
import i5.cb.graph.cbeditor.CBEditor;

import javax.swing.JMenuItem;
import javax.swing.JOptionPane;

/**
 * ActionListener for all possible actions that can be chosen in the menuBar
 *
 * @author     <a href="mailto:">Tobias Latzke</a>
 * -created    07 March 2002
 * @version    1.0
 * @since      1.0
 * @see        ActionListener
 */
public class GECommand implements ActionListener {

	// File Menu IDs
	public final static int M_FILE_NEW = 1;
	public final static int M_FILE_OPEN = 2;
	public final static int M_FILE_CLOSE = 3;
	public final static int M_FILE_SAVE = 4;
	public final static int M_FILE_PRINT = 5;
	public final static int M_FILE_PAGE_SETUP = 6;
	public final static int M_FILE_EXIT = 7;
	public final static int M_FILE_LOAD = 8;
	public final static int M_FILE_SCREENSHOT = 9;

	// Edit Menu Ids
	public final static int M_EDIT_ERASE = 10;
	public final static int M_EDIT_COPY = 11;
	public final static int M_EDIT_ADDNODE = 12;
	public final static int M_EDIT_SELECT_ALL = 13;
	public final static int M_EDIT_SELECT_NODES = 14;
	public final static int M_EDIT_SELECT_EDGES = 15;
	public final static int M_EDIT_CLEAR_SELECTION = 16;

	// View Menu Ids
	public final static int M_VIEW_ZOOM = 20;
	public final static int M_VIEW_ZOOMX = 21;

	// Help Menu Ids
	public final static int M_HELP_ABOUT = 51;

	//Options Menu Ids
    public final static int M_OPTIONS_GERMAN = 61;
	public final static int M_OPTIONS_ENGLISH = 62;
	public final static int M_DO_LAYOUT = 63;

	private int iActionId;
	private GraphEditor geMain;

	/**
	 * This constructor is used by the JMenuItems in {@link GraphMenuBar}
	 *
	 * @param  ge  the GraphEditor owning the {@link GraphMenuBar}
	 * @param  id  by the id we know which action to perform
	 */
	public GECommand(GraphEditor ge, int id) {
		geMain = ge;
		iActionId = id;
	}

	/**
	 * For Checkboxes we have a special constructor, as we need to acces the JCheckBoxMenuItem(get
	 * the state) when it is selected.
	 *
	 * -param  ge    the GraphEditor owning the {@link GraphMenuBar}
	 * -param  item  a <code>JCheckBoxMenuItem</code>
	 * -param  id    by the id we know which action to perform
	 */
/*
	public GECommand(GraphEditor ge, JCheckBoxMenuItem item, int id) {
		geMain = ge;
		checkboxItem = item;
		iActionId = id;
	}
*/

	public GECommand() {
	}



	/**
	 * Depending on the invokers id this method executes the correct action. Not all ids are handled
	 * yet.
	 *
	 * @param  e  an <code>ActionEvent</code>
	 */
	public void actionPerformed(ActionEvent e) {

		DiagramDesktop DD = null;
		if (geMain.getActiveGraphInternalFrame() != null) {
			DD = geMain.getActiveGraphInternalFrame().getDiagramDesktop();
		}
		Locale loc = null;
		switch (iActionId) {
			case M_FILE_NEW :
				// Open new frame without connection
				geMain.openNewFrame();
				break;
			case M_FILE_OPEN :
				break;
			case M_FILE_CLOSE :  // not used in GraphMenuBar
				break;
			case M_FILE_SAVE :
				if (DD == null) {
					return;
				}
				// no current Desktop
				try {
					geMain.saveActiveGraphInternalFrame();
				} catch (Exception ex) {
					java.util.logging.Logger.getLogger("global").fine(ex.getMessage());
				}
				break;
			case M_FILE_LOAD :
				try {
					geMain.loadGraphInternalFrame();
				} catch (java.io.IOException ioe) {
					java.util.logging.Logger.getLogger("global").fine(
						"GECommand.actionPerformed: IOException: "
							+ ioe.getMessage());
				} catch (ClassNotFoundException ce) {
					java.util.logging.Logger.getLogger("global").fine(
						"GECommand.actionPerformed: ClassNotFoundException: "
							+ ce.getMessage());
				}
				break;
			case M_FILE_PRINT :
				if (DD == null) {
					return;
				}
				// no current Desktop
				DD.printDesktop();

				break;

			case M_FILE_SCREENSHOT :
				geMain.saveScreenShot();
				break;

			case M_FILE_PAGE_SETUP :
				if (DD == null) {
					return;
				}
				// no current Desktop
				//DD.pageSetup();

				break;
			case M_FILE_EXIT :
                                // if the currently active graph is edited then propose to save it before shutdown
                                geMain.saveGraphIfNeeded(DD);
				geMain.shutdown();
				break;
			case M_EDIT_ADDNODE :
				java.util.logging.Logger.getLogger("global").fine(
					"GECommand: 'AddNode' was called from the menubar, but not by DiagramEdit");
				break;
			case M_EDIT_ERASE :
				if (DD != null) {
					DD.removeMarkedNodes();
				}
				break;
			case M_EDIT_SELECT_ALL :
				DD.selectAll();
				break;
			case M_EDIT_SELECT_NODES :
				DD.selectAllNodes();
				break;
			case M_EDIT_SELECT_EDGES :
				DD.selectAllEdges();
				break;
			case M_EDIT_CLEAR_SELECTION :
				DD.clearSelectedNodes();
				break;
			case M_DO_LAYOUT:
				DD.getLayouter().doLayout();
				break;
			case M_OPTIONS_GERMAN :
				loc = new Locale("de", "DE");
				if (!(geMain.getLocale().equals(loc))) {
					geMain.updateLang(loc);
				}
				break;
			case M_OPTIONS_ENGLISH :
				loc = new Locale("en", "GB");
				if (!(geMain.getLocale().equals(loc))) {
					geMain.updateLang(loc);
				}
				break;
			case M_VIEW_ZOOM :
                Object res=JOptionPane.showInputDialog(geMain,geMain.getGEBundle().getString("GMB_ViewMenu_ZoomDialogMsg"),
                                            String.valueOf(DD.getZoom()*100)
                                            );
               if(res!=null) {
                   float factor=parseZoomFactor(res);
                   DD.setZoom(factor);
               }
				break;
            case M_VIEW_ZOOMX :
                if(e.getSource() instanceof JMenuItem) {
                    String resStr=((JMenuItem) e.getSource()).getText();
                    if(resStr!=null) {
                       float factor=parseZoomFactor(resStr);
                       DD.setZoom(factor);
                   }
               }
                break;
			case M_HELP_ABOUT :
				break;
		}
		//end switch
	} //actionPerformed

	float parseZoomFactor(Object item){
		float factor=1;
		if(item instanceof String){
			String string=(String)item;
			try{
				if((string.charAt(string.length()-1))=='%'){
					factor = Float.parseFloat(string.substring(0,string.length()-1));
				}else{
					factor=Float.parseFloat(string);
				}
				//we require the zooming factor to be a percentage
				factor/=100;
			}catch(Exception e){
				Logger.getLogger("global").warning(e.getMessage());
				factor = 1;
			}
		}else
			Logger.getLogger("global").warning("Item from combo is not string!");

		return factor;
	}
} //GECommand
