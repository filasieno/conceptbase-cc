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


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
package i5.cb.graph;

import i5.cb.graph.diagram.*;

import java.io.Serializable;
import java.util.Locale;
import java.util.Vector;

import javax.swing.JPopupMenu;
import javax.swing.text.DefaultStyledDocument;

/**
 * This Class is instanciated the firsts time a user rightclicks on a DiagramNode.
 * A PopupMenu consist of GraphMenuItems and SubMenus
 *
 * @author     <a href="mailto:">Tobias Schoeneberg</a>
 * -created    08 March 2002
 * @version    1.0
 * @see        JPopupMenu
 * @see        GraphMenuItem
 * @see        GraphMenu
 * @see        ILangChangeable
 * @since      1.0
 */
public class GraphPopup
         extends JPopupMenu
         implements ILangChangeable,Serializable{

    /**
     * the {@link i5.cb.graph.diagram.DiagramNode} associated with this instance of GraphPopup
     */
    protected DiagramNode m_diagramNode;

    /**
     * the diagNode associated with this instance of GraphPopup
     */
    protected DiagramDesktop m_diagramDesktop;

    /**
     * contains all subMenus of this PopupMenu
     */
    protected Vector m_subMenuVector = new Vector();

    /**
     * the Item to erase this DiagramObject
     */
    protected GraphMenuItem m_eraseItem = null;

    /**
     *Description of the Field
     */
    protected GraphMenuItem m_switchItem = null;


    /**
     * Creates a new <code>GraphPopup</code> instance with all its items and submenus. Gets the
     * GraphEditor's {@link Locale} and updates the Language immediately. The Items' actionListeners
     * should refer to the invoking DiagramObject.
     *
     * @param  diagObj  the invoker of this PopupMenu
     */
    public GraphPopup(DiagramObject diagObj) {
        super("More...");
        if (diagObj instanceof DiagramEdge) {
            // the Menu was invoked by an edge.
            this.m_diagramNode = ((DiagramEdge) diagObj).getNodeOnEdge();
        } else {
            // the Menu was invoked by a node.
            this.m_diagramNode = (DiagramNode) diagObj;
        }
        m_diagramDesktop = m_diagramNode.getDiagramDesktop();

        createSwitchComponentsButton();

        // when all items have been added, the menu has to be translated to the current language
        updateLang(m_diagramDesktop.getGraphInternalFrame().getGraphEditor().getLocale());
    }


    /**
     * Creates a new <code>GraphPopup</code> instance with all its items and submenus. Gets the
     * GraphEditor's {@link Locale} and updates the Language immediately. The Items' actionListeners
     * should refer to the current selection of the DiagramDesktop.
     *
     * @param  dd  the invoking DiagramDesktop
     */
    public GraphPopup(DiagramDesktop dd) {
        this.m_diagramDesktop = dd;
        // createEraseButton();
        // when all items have been added, the menu has to be translated to the current language
        updateLang(dd.getGraphInternalFrame().getGraphEditor().getLocale());
    }

    public GraphPopup() {
    }

    /**
     *Description of the Method
     */
    private void createSwitchComponentsButton() {
        m_switchItem = new GraphMenuItem("GP_SwitchComponents", GEConstants.GE_BUNDLE_NAME, true);
        m_switchItem.addActionListener(
            new java.awt.event.ActionListener() {
                public void actionPerformed(java.awt.event.ActionEvent ae) {
                    m_diagramNode.toggleComponentView();
                }
            });
            this.add(m_switchItem);
    }




    /**
     *Description of the Method
     *
     * @param  loc  Description of the Parameter
     * @return      Description of the Return Value
     */
    public DefaultStyledDocument updateLang(Locale loc) {
        for (int i = 0; i < getComponentCount(); i++) {
            if (getComponent(i) instanceof ILangChangeable) {
                ((ILangChangeable) getComponent(i)).updateLang(loc);
            }
        }
        return null;
    }//updateLang

}//GraphPopup

