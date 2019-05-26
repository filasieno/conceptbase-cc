/*
The ConceptBase.cc Copyright

Copyright 1987-2019 The ConceptBase Team. All rights reserved.

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

import javax.swing.JMenuItem;
import javax.swing.text.DefaultStyledDocument;

/**
 * The main purpose of this extension of JMenuItem is the implementation of the ILangChangeable
 * interface. To create an instance of this class, you have to specify the name of a {@link
 * ResourceBundle} and a keyWord that is handled in this Bundle.
 *
 * @author <a href="mailto:">Tobias Latzke</a>
 * @version 1.0
 * @since 1.0
 * @see JMenuItem
 * @see ILangChangeable
 * @see ResourceBundle
 */
public class GraphMenuItem extends JMenuItem implements ILangChangeable{

    String keyWord;
    String bundleName;

    //public GraphMenuItem() {}

    /**
     * Creates a JMenuItem. Gets the basic resource textBundle
     * and labeles the MenuItem with the String, that is specified by the keyWord. Then it adds an
     * {@link GECommand} specified by the GraphEditor and the actionId.
     *
     * @param keyWord make sure, that this String is a valid keyWord of the given resourceBundle.
     * @param bundleName name of the resourceBundle baseclass
     * @param ge the <code>GraphEditor</code>
     * @param actionID the ID to create the suitable ActionListener
     * @see GECommand
     */
    public GraphMenuItem(String keyWord, String bundleName, GraphEditor ge, int actionID, boolean enabled) {
        this(keyWord, bundleName, enabled);
        addActionListener(new GECommand(ge,actionID));
    }

    /**
     * Creates a JMenuItem that reacts on the given mnemonic key. Gets the basic resource textBundle
     * and labeles the MenuItem with the String, that is specified by the keyWord. Then it adds an
     * {@link GECommand} specified by the GraphEditor and the actionId.
     *
     * @param keyWord make sure, that this String is a valid keyWord of the given resourceBundle.
     * @param bundleName name of the resourceBundle baseclass
     * @param mnemonic the menu listens to this keyInput
     * @param ge the <code>GraphEditor</code>
     * @param actionID the ID to create the suitable ActionListener
     * @see GECommand
     */
    public GraphMenuItem(String keyWord, String bundleName, int mnemonic, GraphEditor ge, int actionID, boolean enabled) {
        this(keyWord, bundleName, mnemonic, enabled);
               addActionListener(new GECommand(ge,actionID));
    }

    /**
     * Creates a JMenuItem that reacts on the given mnemonic key. Gets the basic resource textBundle and
     * labeles the MenuItem with the String, that is specified by the keyWord.
     *
     * @param keyWord make sure, that this String is a valid keyWord of the given resourceBundle.
     * @param bundleName name of the resourceBundle baseclass
     * @param mnemonic the menu listens to this keyInput
     */
    public GraphMenuItem(String keyWord, String bundleName, int mnemonic, boolean enabled) {
        this(keyWord, bundleName, enabled);
       
        setMnemonic(mnemonic);
    }

    /**
     * Creates a JMenuItem. Gets the basic resource textBundle and
     * labeles the MenuItem with the String, that is specified by the keyWord.
     *
     * @param keyWord make sure, that this String is a valid keyWord of the given resourceBundle.
     * @param bundleName name of the resourceBundle baseclass
     */
    public GraphMenuItem(String keyWord, String bundleName, boolean enabled) {
        super();
        ResourceBundle bundle = ResourceBundle.getBundle(bundleName);
        setText(bundle.getString(keyWord));
        this.keyWord = keyWord;
        this.bundleName = bundleName;
             this.setEnabled(enabled);
    }

    /**
     * Updates the textField with the current language. Requires, that this GraphMenuItem's keyWord
     * is defined in the current textBundle.
     *
     * @param loc the actual language's textBundle
     * @return always null at the moment
     */
    public DefaultStyledDocument updateLang(Locale loc) {
        ResourceBundle bundle = ResourceBundle.getBundle(bundleName, loc);
        setText(bundle.getString(keyWord));
        return null;
    }

}//GraphMenuItem
