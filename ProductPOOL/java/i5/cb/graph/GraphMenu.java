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
package i5.cb.graph;

import java.util.Locale;
import java.util.ResourceBundle;

import javax.swing.JMenu;
import javax.swing.text.DefaultStyledDocument;

/**
 * The main purpose of this extension of JMenu is the implementation of the ILangChangeable
 * interface. To create an instance of this class, you have to specify the name of a {@link
 * ResourceBundle} and a keyWord that is handled in this Bundle.
 *
 * @author <a href="mailto:">Tobias Latzke</a>
 * @version 1.0
 * @since 1.0
 * @see JMenu
 * @see ILangChangeable
 * @see ResourceBundle
 */
public class GraphMenu extends JMenu implements ILangChangeable, java.io.Serializable {

    String keyWord;
    String bundleName;


    /**
     * Creates a JMenu that reacts on the given mnemonic key. Gets the basic resource textBundle and
     * labeles the Menu with the String, that is specified by the keyWord.
     *
     * @param keyWord make sure, that this String is a valid keyWord of the given resourceBundle.
     * @param bundleName name of the resourceBundle baseclass
     * @param mnemonic the menu listens to this keyInput
     */
    public GraphMenu(String keyWord, String bundleName, char mnemonic) {
        this(keyWord,bundleName);
        setMnemonic(mnemonic);
    }

    /**
     * Creates a JMenu. Gets the basic resource textBundle and
     * labeles the Menu with the String, that is specified by the keyWord.
     *
     * @param keyWord a <code>String</code> value
     * @param bundleName a <code>String</code> value
     */
    public GraphMenu(String keyWord, String bundleName) {
        super();
        this.keyWord = keyWord;
        this.bundleName = bundleName;
        ResourceBundle bundle = ResourceBundle.getBundle(bundleName);
        setText(bundle.getString(keyWord));
    }

  
    /**
     * If you do not know the position of a GraphMenuItem, you can acces it by its keyWord.
     *
     * @param keyWord the keyWord of the wanted GraphMenuItem
     * @return the <code>GraphMenuItem</code> or null, if it was not found
     */
    public GraphMenuItem getItemByKeyWord(String keyWord) {
        GraphMenuItem item;
        for(int i=0; i<getItemCount(); i++) {
            if(getItem(i) instanceof GraphMenuItem) {
                item = (GraphMenuItem) getItem(i);
                //java.util.logging.Logger.getLogger("global").fine("keyword: "+keyWord+"; Item's keyword: "+item.keyWord);
                if(item.keyWord.equals(keyWord)) {
                    return item;
                }
            }
        }
        // if nothing was found
        return null;
    }

    /**
     * If you do not know the position of a GraphMenuItem, you can acces it by its keyWord.
     *
     * @param keyWord the keyWord of the wanted GraphMenuItem
     * @return the <code>GraphMenuItem</code> or null, if it was not found
     */
    public GraphMenu getSubMenuByKeyWord(String keyWord) {
        GraphMenu menu;
        for(int i=0; i<getItemCount(); i++) {
            if(getItem(i) instanceof GraphMenu) {
                menu = (GraphMenu) getItem(i);
                //java.util.logging.Logger.getLogger("global").fine("keyWord: "+keyWord+"; current menu: "+menu.keyWord);
                if(menu.keyWord.equals(keyWord)) {
                    return menu;
                }else if(menu.getSubMenuByKeyWord(keyWord) != null){
                    return menu.getSubMenuByKeyWord(keyWord);
                }
            }
        }
        // if nothing was found
        return null;
    }

    /**
     * Updates the textField and all subMenuItems if they implement the {@link ILangChangeable}
     * interface. Requires, that this GraphMenu's keyWord is defined in the current textBundle.
     *
     * @param loc the new locale
     * @return always null at the moment
     */
    public DefaultStyledDocument updateLang(Locale loc) {
        ResourceBundle bundle = ResourceBundle.getBundle(bundleName,loc);
        setText(bundle.getString(keyWord));
        for(int i=0; i<getItemCount(); i++) {
            if(getItem(i) instanceof ILangChangeable) {
                ((ILangChangeable)getItem(i)).updateLang(loc);
            }
        }
        return null;
    }

}
