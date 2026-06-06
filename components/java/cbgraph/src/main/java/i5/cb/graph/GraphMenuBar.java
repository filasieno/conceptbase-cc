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

import i5.cb.CBConfiguration;

import java.util.Locale;
import java.util.ResourceBundle;

import javax.swing.*;
import javax.swing.text.DefaultStyledDocument;

/**
 * The menu bar of the GraphEditor. To assure full functionality of updateLang you should only add
 * GraphMenus instead of JMenus. IMPORTANT: Currently all items that arent't used for the
 * mavisbrowser app are commented out.
 * @see GraphMenu
 * @see GraphMenuItem
 */

public class GraphMenuBar
	extends JMenuBar
	implements ILangChangeable, java.io.Serializable {

	private GraphEditor geMain;

	// Menus
    private GraphMenu jmFileMenu;
    private GraphMenu jmEditMenu;
    private GraphMenu jmOptionsMenu;
    private GraphMenu gmViewMenu;
    private JMenu jmHelpMenu;

	/**
	 * Creates a FileMenu and an OptionsMenu by default.
	 *
	 * @param GE the main <code>GraphEditor</code>
	 */
	public GraphMenuBar(GraphEditor GE) {
		this.geMain = GE;
		initFileMenu();
		initEditMenu();
		initOptionsMenu();
		initViewMenu();
		//	initHelpMenu();
	}

	public GraphMenuBar() {
	}

	public GraphMenu getFileMenu() {
		return jmFileMenu;
	}

	/**
	 * creates and adds the FileMenu with some subItems.
	 *
	 */
	private void initFileMenu() {
		jmFileMenu =
			new GraphMenu(
				"GMB_FileMenu_Title",
				GEConstants.GE_BUNDLE_NAME,
				'F');

		jmFileMenu.add(
			new GraphMenuItem(
				"GMB_FileMenu_Save",
				GEConstants.GE_BUNDLE_NAME,
				'S',
				geMain,
				GECommand.M_FILE_SAVE,
				false));
		jmFileMenu.add(
			new GraphMenuItem(
				"GMB_FileMenu_Load",
				GEConstants.GE_BUNDLE_NAME,
				'L',
				geMain,
				GECommand.M_FILE_LOAD,
				false));
		jmFileMenu.add(
			new GraphMenuItem(
				"GMB_FileMenu_Print",
				GEConstants.GE_BUNDLE_NAME,
				'P',
				geMain,
				GECommand.M_FILE_PRINT,
				false));
		jmFileMenu.add(
			new GraphMenuItem(
				"GMB_FileMenu_ScreenShot",
				GEConstants.GE_BUNDLE_NAME,
				'D',
				geMain,
				GECommand.M_FILE_SCREENSHOT,
				false));

		jmFileMenu.add(new JSeparator());

		jmFileMenu.add(
			new GraphMenuItem(
				"GMB_FileMenu_Exit",
				GEConstants.GE_BUNDLE_NAME,
				'X',
				geMain,
				GECommand.M_FILE_EXIT,
				true));

		this.add(jmFileMenu);
	}

	public GraphMenu getOptionsMenu() {
		return jmOptionsMenu;
	}

	/**
	 * creates and adds the OptionsMenu with some subItems.
	 *
	 */
	protected void initOptionsMenu() {
		jmOptionsMenu =
			new GraphMenu(
				"GMB_OptionsMenu_Title",
				GEConstants.GE_BUNDLE_NAME,
				'O');

		GraphMenu jmChangeLang =
			new GraphMenu(
				"GMB_OptionsMenu_Lang",
				GEConstants.GE_BUNDLE_NAME,
				'L');
		jmChangeLang.add(
			new GraphMenuItem(
				"GMB_OptionsMenu_German",
				GEConstants.GE_BUNDLE_NAME,
				'D',
				geMain,
				GECommand.M_OPTIONS_GERMAN,
				true));
		jmChangeLang.add(
			new GraphMenuItem(
				"GMB_OptionsMenu_English",
				GEConstants.GE_BUNDLE_NAME,
				'E',
				geMain,
				GECommand.M_OPTIONS_ENGLISH,
				true));
		jmOptionsMenu.add(jmChangeLang);

		this.add(jmOptionsMenu);
	}

	public GraphMenu getEditMenu() {
		return jmEditMenu;
	}

	protected void initEditMenu() {
		jmEditMenu =
			new GraphMenu(
				"GMB_EditMenu_Title",
				GEConstants.GE_BUNDLE_NAME,
				'E');
		jmEditMenu.setEnabled(false);
		jmEditMenu.add(
			new GraphMenuItem(
				"GMB_EditMenu_Erase",
				GEConstants.GE_BUNDLE_NAME,
				'E',
				geMain,
				GECommand.M_EDIT_ERASE,
				true));

		GraphMenu jmSelection =
			new GraphMenu(
				"GMB_EditMenu_Selection",
				GEConstants.GE_BUNDLE_NAME,
				'S');

		jmSelection.add(
			new GraphMenuItem(
				"GMB_EditMenu_SelectAll",
				GEConstants.GE_BUNDLE_NAME,
				'A',
				geMain,
				GECommand.M_EDIT_SELECT_ALL,
				true));
		jmSelection.add(
			new GraphMenuItem(
				"GMB_EditMenu_SelectNodes",
				GEConstants.GE_BUNDLE_NAME,
				'N',
				geMain,
				GECommand.M_EDIT_SELECT_NODES,
				true));
		jmSelection.add(
			new GraphMenuItem(
				"GMB_EditMenu_SelectEdges",
				GEConstants.GE_BUNDLE_NAME,
				'E',
				geMain,
				GECommand.M_EDIT_SELECT_EDGES,
				true));

		jmSelection.add(
			new GraphMenuItem(
				"GMB_EditMenu_ClearSelection",
				GEConstants.GE_BUNDLE_NAME,
				'C',
				geMain,
				GECommand.M_EDIT_CLEAR_SELECTION,
				true));
		jmEditMenu.add(jmSelection);
		this.add(jmEditMenu);
	}

    GraphMenu getViewMenu() {
        return gmViewMenu;
    }

    void initViewMenu() {
        gmViewMenu = new GraphMenu("GMB_ViewMenu_Title",
                                           GEConstants.GE_BUNDLE_NAME,'l');
        gmViewMenu.setEnabled(true);
        ResourceBundle bundle=geMain.getGEBundle();

        JCheckBoxMenuItem jcbLayoutEnable = new JCheckBoxMenuItem(bundle
            .getString("GMB_ViewMenu_LayoutCheckBx"));
        jcbLayoutEnable.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent evt) {
                if (evt.getStateChange() == java.awt.event.ItemEvent.SELECTED) {
                    if (geMain.getActiveGraphInternalFrame() != null) {
                        geMain.getActiveGraphInternalFrame().getDiagramDesktop()
                            .getLayouter().setEnable(true);
                        // Enable undo menu
                        getViewMenu().getItem(1).setEnabled(true);
                    }
                } else {
                    if (geMain.getActiveGraphInternalFrame() != null) {
                        geMain.getActiveGraphInternalFrame().getDiagramDesktop()
                            .getLayouter().setEnable(false);
                        // disable undo menu
                        getViewMenu().getItem(1).setEnabled(false);
                    }
                }
            }
        });
        if(CBConfiguration.getAutoLayout())
            jcbLayoutEnable.setSelected(true);
        else
            jcbLayoutEnable.setSelected(false);

        gmViewMenu.add(jcbLayoutEnable, 0);

        JMenuItem jmiUndo = new JMenuItem(bundle
                                          .getString("GMB_ViewMenu_LayoutUndo"));
        jmiUndo.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent ae) {
                geMain.getActiveGraphInternalFrame().getDiagramDesktop().getLayouter()
                    .undo();
                geMain.getActiveGraphInternalFrame().getDiagramDesktop().repaint();
            }
        });


        if(CBConfiguration.getAutoLayout())
            jmiUndo.setEnabled(true);
        else
            jmiUndo.setEnabled(false);
        gmViewMenu.add(jmiUndo, 1);

        JMenuItem jmiDoLayout= new JMenuItem(bundle
                                             .getString("GMB_ViewMenu_DoLayout"));
        jmiDoLayout.addActionListener(new GECommand(geMain,GECommand.M_DO_LAYOUT));
        gmViewMenu.add(jmiDoLayout);

        gmViewMenu.addSeparator();

        JMenuItem jmiZoom= new JMenuItem(bundle
                                         .getString("GMB_ViewMenu_Zoom"));
        jmiZoom.addActionListener(new GECommand(geMain,GECommand.M_VIEW_ZOOM));
        gmViewMenu.add(jmiZoom);

        // Add menu items here and use GECommand as action listener

		JMenuItem jmiViewZoom400 = new JMenuItem("400%");
		jmiViewZoom400.addActionListener(
			new GECommand(geMain, GECommand.M_VIEW_ZOOMX));
		gmViewMenu.add(jmiViewZoom400);

		JMenuItem jmiViewZoom200 = new JMenuItem("200%");
		jmiViewZoom200.addActionListener(
			new GECommand(geMain, GECommand.M_VIEW_ZOOMX));
		gmViewMenu.add(jmiViewZoom200);

		JMenuItem jmiViewZoom150 = new JMenuItem("150%");
		jmiViewZoom150.addActionListener(
			new GECommand(geMain, GECommand.M_VIEW_ZOOMX));
		gmViewMenu.add(jmiViewZoom150);

		JMenuItem jmiViewZoom125 = new JMenuItem("125%");
		jmiViewZoom125.addActionListener(
			new GECommand(geMain, GECommand.M_VIEW_ZOOMX));
		gmViewMenu.add(jmiViewZoom125);

		JMenuItem jmiViewZoom100 = new JMenuItem("100%");
		jmiViewZoom100.addActionListener(
			new GECommand(geMain, GECommand.M_VIEW_ZOOMX));
		gmViewMenu.add(jmiViewZoom100);

		JMenuItem jmiViewZoom75 = new JMenuItem("75%");
		jmiViewZoom75.addActionListener(
			new GECommand(geMain, GECommand.M_VIEW_ZOOMX));
		gmViewMenu.add(jmiViewZoom75);

		JMenuItem jmiViewZoom50 = new JMenuItem("50%");
		jmiViewZoom50.addActionListener(
			new GECommand(geMain, GECommand.M_VIEW_ZOOMX));
		gmViewMenu.add(jmiViewZoom50);

		JMenuItem jmiViewZoom25 = new JMenuItem("25%");
		jmiViewZoom25.addActionListener(
			new GECommand(geMain, GECommand.M_VIEW_ZOOMX));
		gmViewMenu.add(jmiViewZoom25);

        add(gmViewMenu);
    }

	public JMenu getHelpMenu() {
		return jmHelpMenu;
	}

	protected void initHelpMenu() {
	}

	/**
	 * If you do not know the position of a Menu, you can acces it by its keyWord, if it is a
	 * GraphMenu.
	 *
	 * @param keyWord the keyWord of the wanted Menu
	 * @return the Menu or null, if it was not found
	 */
	public GraphMenuItem getMenuItemByKeyWord(String keyWord) {
		GraphMenu menu;
		for (int i = 0; i < getMenuCount(); i++) {
			if (getMenu(i) instanceof GraphMenu) {
				menu = (GraphMenu) getMenu(i);
				//java.util.logging.Logger.getLogger("global").fine("keyword: "+keyWord+"; Current GraphMenu: "+ menu.keyWord);
				if (menu.getItemByKeyWord(keyWord) != null) {
					return menu.getItemByKeyWord(keyWord);
				}
			}
		}
		// if nothing was found
		return null;
	}

	public GraphMenu getMenuByKeyWord(String keyWord) {
		GraphMenu menu;
		for (int i = 0; i < getMenuCount(); i++) {
			if (getMenu(i) instanceof GraphMenu) {
				menu = (GraphMenu) getMenu(i);

				//java.util.logging.Logger.getLogger("global").fine("keyWord: "+keyWord+"; current menu: "+menu.keyWord);

				if (menu.keyWord.equals(keyWord)) {
					return menu;
				} else if (menu.getSubMenuByKeyWord(keyWord) != null) {
					return menu.getSubMenuByKeyWord(keyWord);
				}
			}
		}
		// if nothing was found
		return null;
	}

	/**
	 * Updates all Menus.
	 *
	 * @param loc the new locale
	 * @return always null at the moment
	 */
	public DefaultStyledDocument updateLang(Locale loc) {
		int numOfMenus = getMenuCount();
		JMenu currentMenu;
		for (int i = 0; i < numOfMenus; i++) {
			currentMenu = getMenu(i);
			if (currentMenu instanceof ILangChangeable) {
				((ILangChangeable) currentMenu).updateLang(loc);
			}
		}

		return null;
	}

}
