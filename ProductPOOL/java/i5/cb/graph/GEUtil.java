/*
The ConceptBase.cc Copyright

Copyright 1987-2021 The ConceptBase Team. All rights reserved.

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
/*
 * GEUtils.java
 *
 * Created on 23. Juni 2002, 15:08
 */

package i5.cb.graph;

import java.util.Comparator;

import javax.swing.JMenu;
import javax.swing.JMenuItem;

/**
 *  This class contains a few static methods suitable for more than one GraphEditor application
 * @author  Schoeneb
 */
public class GEUtil {

	/**
	 * Static member to sort any kind of object by its string representation
	 */
	public static Comparator stringComparator = new Comparator() {
		public int compare(Object o1, Object o2) {
			return o1.toString().compareTo(o2.toString());
		}
	};

	/**
	* This method sets the text of the submenus which contain the names
	* of the actual {@link i5.cb.telos.object.TelosObject}s that are
	* somehow related to this object. The title of the submenu is set
	* in a way that a user can see in which submenu a telosobjects name
	* must be according to its spelling(provided he or she knows the alphabet).
	*
	* @param menu the menu to process
	*/
	public static void setLetters(JMenu menu) {
		//if the first component is not submenu we don't do anything
		if (!(menu.getMenuComponent(0) instanceof JMenu)) {
			//java.util.logging.Logger.getLogger("global").fine("GenericMavisPopup.setLetters: Nothing to do for "
			//+((JMenuItem)menu.getMenuComponent(0)).getText() );
			return;
		}
		String subMenuName;
		JMenu lastSubMenu, currentSubMenu;
		currentSubMenu = (JMenu) menu.getMenuComponent(0);
		//java.util.logging.Logger.getLogger("global").fine("GenericMavisPopup.setLetters: menu: "+menu.getText() );
		//java.util.logging.Logger.getLogger("global").fine("GenericMavisPopup.setLetters: currentSubMenu: "+currentSubMenu.getText() );
		subMenuName =
			"- "
				+ prefix(
					((JMenuItem) currentSubMenu
						.getMenuComponent(currentSubMenu.getItemCount() - 1))
						.getText(),
					((JMenuItem) ((JMenu) menu.getMenuComponent(1))
						.getMenuComponent(0))
						.getText(),
					false);
		//java.util.logging.Logger.getLogger("global").fine("GenericMavisPopup.setLetters: subMenuName: "+subMenuName);
		currentSubMenu.setText(subMenuName);
		//in this for-loop we process all items of the popupmenu from the second to the 4th-last, because the last is "show all"
		//, the second-last is the seperator and the 3rd-last is processed after the loop
		for (int i = 1; i < (menu.getItemCount() - 3); i++) {
			lastSubMenu = (JMenu) menu.getMenuComponent(i - 1);
			currentSubMenu = (JMenu) menu.getMenuComponent(i);
			lastSubMenu = (JMenu) menu.getMenuComponent(i - 1);
			//this gets the string "ABC - ")
			subMenuName =
				prefix(
					((JMenuItem) lastSubMenu
						.getMenuComponent(lastSubMenu.getItemCount() - 1))
						.getText(),
					((JMenuItem) currentSubMenu.getMenuComponent(0)).getText(),
					true);
			subMenuName += " - ";
			//this gets the string "...XYZ")
			subMenuName
				+= prefix(
					((JMenuItem) currentSubMenu
						.getMenuComponent(currentSubMenu.getItemCount() - 1))
						.getText(),
					((JMenuItem) ((JMenu) menu.getMenuComponent(i + 1))
						.getMenuComponent(0))
						.getText(),
					false);
			//java.util.logging.Logger.getLogger("global").fine("GenericMavisPopup.setLetters: subMenuName: "+subMenuName);
			currentSubMenu.setText(subMenuName);

		}
		currentSubMenu = (JMenu) menu.getMenuComponent(menu.getItemCount() - 3);
		lastSubMenu = (JMenu) menu.getMenuComponent(menu.getItemCount() - 4);
		subMenuName =
			prefix(
				((JMenuItem) lastSubMenu
					.getMenuComponent(lastSubMenu.getItemCount() - 1))
					.getText(),
				((JMenuItem) currentSubMenu.getMenuComponent(0)).getText(),
				true)
				+ " - ";
		//java.util.logging.Logger.getLogger("global").fine("GenericMavisPopup.setLetters: subMenuName: "+subMenuName);
		currentSubMenu.setText(subMenuName);
	} //setLetters

	/**
	 * This method is called by {@link #setLetters} with the last item
	 * of a submenu and the first item of the following submenu. It gets
	 * two {@link java.lang.String}s and determines until which letter
	 * they are equal. for example the Strings "Daniel" and "Damien" are
	 * equal until the third letter. The boolean parameter then
	 * specifies if the method shall return "Dan" or "Dam".
	 *
	 * @param sFirst a <code>String</code> value
	 * @param sSecond a <code>String</code> value
	 * @param returnFirst a <code>boolean</code> value
	 * @return a <code>String</code> value
	 */
	private static String prefix(
		String sFirst,
		String sSecond,
		boolean returnFirst) {
		StringBuffer toReturn = new StringBuffer();
		int min;
		//java.util.logging.Logger.getLogger("global").fine("GenericMavisPopup.prefix: sFirst: "+sFirst+" sSecond : "+sSecond);
		if (sFirst.length() < sSecond.length())
			min = sFirst.length();
		else
			min = sSecond.length();
		for (int i = 0; i < min; i++) {
			if (sFirst.charAt(i) == sSecond.charAt(i)) {
				toReturn.append(sFirst.charAt(i));
				//java.util.logging.Logger.getLogger("global").fine("toReturn now: "+toReturn);
			} else {
				//min = i;
				break;
			}
		} ///for
		if (returnFirst && (sSecond.length() > toReturn.length()))
			toReturn.append(sSecond.charAt(toReturn.length()));
		else if (sFirst.length() > toReturn.length())
			toReturn.append(sFirst.charAt(toReturn.length()));
		return new String(toReturn);
	} //prefix

	/**
	 * Shifts the Positionion (define in GEConstants} anti-clockwise
	 * 
	 * @param iPos the position to be shifted.
	 * @return the shifted position.
	 */
	public static int shiftPos(int iPos) {
		switch (iPos) {
			case GEConstants.N_POSITION :
				return GEConstants.W_POSITION;
			case GEConstants.W_POSITION :
				return GEConstants.S_POSITION;
			case GEConstants.S_POSITION :
				return GEConstants.E_POSITION;
			case GEConstants.E_POSITION :
				return GEConstants.N_POSITION;
			default :
				assert false : "GEUtil.shiftPos: iPos must be one of GEConstants.N_POSITION, GEConstants.W_POSITION, GEConstants.S_POSITION or GEConstants.E_POSITION";
		}
		return iPos;
	}

	/**
	 * Returns the position which is opposite from the parameter
	 * 
	 * @param iPos the position to be switched
	 * @return the opposite position (e.g. N_POSITION for S_POSITION)
	 */
	public static int switchPos(int iPos) {
		switch (iPos) {
			case GEConstants.N_POSITION :
				return GEConstants.S_POSITION;
			case GEConstants.W_POSITION :
				return GEConstants.E_POSITION;
			case GEConstants.S_POSITION :
				return GEConstants.N_POSITION;
			case GEConstants.E_POSITION :
				return GEConstants.W_POSITION;
			default :
				assert false : "GEUtil.shiftPos: iPos must be one of GEConstants.N_POSITION, GEConstants.W_POSITION, GEConstants.S_POSITION or GEConstants.E_POSITION";
		}
		return iPos;
	}
}
