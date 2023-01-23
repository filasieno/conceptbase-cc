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
/*
 * @(#)GraphEditor.java	0.4 b 11.09.99
 *
 * Copyright 1998, 1999 by Rainer Langohr,
 *
 * All rights reserved.
 *
 */
package i5.cb.graph.diagram;

import i5.cb.graph.*;

import java.awt.*;
import java.io.Serializable;
import java.util.*;

import javax.swing.*;
import javax.swing.text.DefaultStyledDocument;

/**
 * The DiagramClass maintains the associations between userObjects,
 * their {@link DiagramObject}s and the other items associated with
 * the userobjects. A userobject is here any {@link java.lang.Object}
 * that is supposed to be displayed in the {@link
 * i5.cb.graph.GraphEditor}. The items that may be associated with
 * one userobject include the color of the edgeline (of corse only if
 * the userobject is represented by a {@link DiagramEdge}), a {@link
 * javax.swing.text.DefaultStyledDocument}, two {@link
 * java.awt.Component}s, a {@link javax.swing.JPopupMenu} and a {@link java.awt.Shape}.
 *
 * All these items are intended to be created by the DiagramClass
 * according to the single userobjects and they are stored by the
 * DiagramClass. One might want to use one DiagramClass instance for
 * all userobjects beeing represented in the same {@link
 * i5.cb.graph.GraphInternalFrame}
 *
 * @author <a href="mailto:Tobias.Schoeneberg@epost.de">Tobias Schoeneberg</a>
 * @version 1.0
 */
public class DiagramClass implements ILangChangeable, Serializable {

    /**
     * This hashtable stores DiagramClassHashtable entries.
     * The keys are user objects.
     * */
    protected Hashtable htDiagramClass;

    /**
     * This popupMenu is invoked by a set of DiagramObjects.
     */
    protected GraphPopup multiPopup;

    /** Holds value of property graphInternalFrame. */
    protected GraphInternalFrame graphInternalFrame;

    /**
     * Creates a new <code>DiagramClass</code> instance.
     *
     */
    public DiagramClass(GraphInternalFrame gif) {
        htDiagramClass = new Hashtable(50);
        graphInternalFrame = gif;
    }

    /**
     * Get a (short) string representation of this object.
     * @param userObject an <code>Object</code> value
     * @return a <code>String</code> value
     */
    public String getName(Object userObject) {
        return userObject.toString();
        //    return userObject.getClass().getName();
    }

    /**
     * Gets the BasicStroke used to paint the edgeline of the diagramEdge belonging to this userobject
     */
    public BasicStroke getEdgeStroke(Object userObject) {
        assert getDiagramNode(userObject)
            .isOnEdge() : "DiagramClass.getEdgeColor: UserObject must belong to a diagramNode that sits on an edge";

        BasicStroke stroke = getHashtableEntry(userObject).getEdgeStroke();
        if (stroke == null) {
            stroke =
                new BasicStroke(
                    1,
                    BasicStroke.CAP_SQUARE,
                    BasicStroke.JOIN_MITER);
            getHashtableEntry(userObject).setEdgeStroke(stroke);
        }
        return stroke;
    }
    //getEdgeStroke

    /**
     * Get a (long) string representation of this object. This
     * string is used in the tooltip for the diagram object.
     *
     * @param userObject an <code>Object</code> value. The userobject we want to get the toolTipText for
     * @return a <code>String</code> value. The toolTipText itself.
     */
    public String getToolTipText(Object userObject) {
        return userObject.toString();
    }

    /**
     * Gets the {@link javax.swing.JPopupMenu} for a certain userObject
     *
     * @param userObject an <code>Object</code> value
     * @return a <code>JPopupMenu</code> value
     */
    public JPopupMenu getPopupMenu(Object userObject) {
        JPopupMenu popup = getHashtableEntry(userObject).getPopupMenu();
        if (popup == null) {
            popup = new GraphPopup(this.getDiagramNode(userObject));
            getHashtableEntry(userObject).setPopupMenu(popup);
        }
        return popup;
    }

    /**
     * The DiagramClass provides one PopupMenu that does not refer to a specific diagramObject but
     * to the whole diagramDesktop. The actionListeners in this menu should handle the current
     * selection instead of a single diagramObject.
     *
     * @return the popupMenu for multiple Nodes
     */
    public GraphPopup getMultiPopup() {
        if (multiPopup == null) {
            multiPopup =
                new GraphPopup(getGraphInternalFrame().getDiagramDesktop());
        }
        return multiPopup;
    }

    /**
    * Gets a {@link javax.swing.text.DefaultStyledDocument} that is associacted with a certain userobject
    *
    * @param userObject an <code>Object</code> value. The userobject we want to get the infodocument off.
    * @return a <code>DefaultStyledDocument</code> value. Should contain infos about the userobject
    */
    public DefaultStyledDocument getInfoDoc(Object userObject) {
        DefaultStyledDocument d = getHashtableEntry(userObject).getInfoDoc();
        if (d == null) {
            getHashtableEntry(userObject).setInfoDoc(
                new DefaultStyledDocument());
        }
        return d;
    }

    /**
     * Gets the edgecolor associated with a certain userobject. This
     * method requires the userobject to be represented by a {@link DiagramEdge}
     *
     * @param userObject an <code>Object</code> value.
     * @return a <code>Color</code> value
     */
    public Color getEdgeColor(Object userObject) {
        assert getDiagramNode(userObject)
            .isOnEdge() : "DiagramClass.getEdgeColor: UserObject must belong to a diagramNode that sits on an edge";

        Color c = getHashtableEntry(userObject).getEdgeColor();
        if (c == null) {
            c = Color.black;
            getHashtableEntry(userObject).setEdgeColor(c);
        }
        return c;
    }

    public Color getEdgeHeadColor(Object userObject) {
        assert getDiagramNode(userObject)
            .isOnEdge() : "DiagramClass.getEdgeHeadColor: UserObject must belong to a diagramNode that sits on an edge";

        Color c = getHashtableEntry(userObject).getEdgeHeadColor();
        if (c == null) {
            c = Color.black;
            getHashtableEntry(userObject).setEdgeHeadColor(c);
        }
        return c;
    }


    public Shape getEdgeHeadShape(Object userObject) {
        assert getDiagramNode(userObject)
            .isOnEdge() : "DiagramClass.getEdgeHeadShape: UserObject must belong to a diagramNode that sits on an edge";

        Shape s = getHashtableEntry(userObject).getEdgeHeadShape();
        return s;  // could be null
    }


    /**
     * Return a small component for an user object. By default, this returns
     * a {@link DiagramLabel} with the result of {@link #getName} as label.
     *
     * @param userObject any <code>Object</code>
     * @return a <code>Component</code>. null, iff the userObject itself is a Component
     */
    public Component getSmallComponent(Object userObject) {

        Component sc = getHashtableEntry(userObject).getSmallComponent();
        if (sc == null) {
            if (!(userObject instanceof Component)) {
                sc = new DiagramLabel(this.getName(userObject));
                if (this.getName(userObject).length() > 0) {
                  ((JLabel) sc).setPreferredSize(
                    new Dimension(
                        sc.getPreferredSize().width + 10,
                        sc.getPreferredSize().height + 10));
                }
                getHashtableEntry(userObject).setSmallComponent(sc);
            }
        }
        return sc;
    }

    /**
     * Returns the (big) java.awt.Component for this object. This component
     * is used when the small component is not shown. To be compatible
     * with the graph editor which is implemented in JFC/Swing, the component
     * should be a subclass of JComponent.
     * This method may return null, but then getSmallComponent must return a value.
     * By default, if the user object is a component the user object is returned.
     * Otherwise, this method returns null or a value which is stored in the hashtable.
     *
     * @param userObject an <code>Object</code> value
     * @return a <code>Component</code> value
     */
    public Component getComponent(Object userObject) {

        if (userObject instanceof Component)
            return (Component) userObject;

        Component mc = getHashtableEntry(userObject).getComponent();

        if (mc == null) {
            mc = new JTextField(this.getToolTipText(userObject));
            (
                (
                    JTextField) mc)
                        .addActionListener(new java.awt.event.ActionListener() {
                public void actionPerformed(java.awt.event.ActionEvent e) {
                    java.util.logging.Logger.getLogger("global").fine("blabla");
                }
            });
            getHashtableEntry(userObject).setComponent(mc);
        }
        return mc;
    }

    /**
     * Get the shape for this user object. The shape is drawn, when the
     * small component is shown, it is drawn as the background of the small component.
     *
     * @param userObject an <code>Object</code> value
     * @return a <code>Shape</code> value
     */
    public Shape getShape(Object userObject) {

        Shape sh = getHashtableEntry(userObject).getShape();

        if (sh == null) {
            sh = new i5.cb.graph.shapes.Star();
            getHashtableEntry(userObject).setShape(sh);
        }
        return sh;
    }

    /**
     * Gets the {@link DiagramObject} for this user object. If the user object has been used
     * for the construction of a {@link DiagramObject}, i.e. was an argument of the constructor,
     * then this method should not return null.
     *
     * @param userObject the Object we want to get the DiagramObject for.
     * @return a <code>DiagramObject</code> value
     */
    public DiagramNode getDiagramNode(Object userObject) {
        //By now only diagramNodes should be added to the diagramClass, but if this node is on an edge,
        //the edge is returned
        return getHashtableEntry(userObject).getDiagramNode();
    }

    /**
     * Add an user object with its {@link DiagramObject} to the hashtable.
     * If the user object is already in the hashtable with a DiagramObject as value,
     * then the old DiagramObject is returned and nothing is changed.
     *
     * @param userObject an <code>Object</code> value
     * @param diagObject a <code>DiagramObject</code> value
     * @return a <code>DiagramObject</code> value
     */
    public final synchronized DiagramObject addUserAndDiagramObject(
        Object userObject,
        DiagramObject diagObject) {
        assert !(
            userObject
                instanceof DiagramObject) : "DiagramClass.addUserAndDiagramObject: userObject shall not be a DiagramObject";

        //internally we add the diagramNode, even if diagObject is a diagramEdge
        DiagramNode nodeToAdd;
        if (diagObject instanceof DiagramEdge) {
            nodeToAdd = ((DiagramEdge) diagObject).getNodeOnEdge();
        } else {
            nodeToAdd = (DiagramNode) diagObject;
        }
        DiagramClassHashtableEntry dchtEntry = getHashtableEntry(userObject);
        DiagramNode diagNode2 = dchtEntry.getDiagramNode();
        if (diagNode2 == null) {
            dchtEntry.setDiagramNode(nodeToAdd);
            //java.util.logging.Logger.getLogger("global").fine(" The diagramObject wasn't there before");
            return diagObject;
        } else {
            if (diagNode2.isOnEdge()) {
                return diagNode2.getDiagramEdge();
            } else {
                return diagNode2;
            }
        }
    }

    /**
     * Removes a userobject and everything that was associated with this userobject from the table.
     *
     * @param userObject the userobject to be removed.
     */
    public void remove(Object userObject) {
        if (userObject != null)
          htDiagramClass.remove(userObject);
    }

    /**
     * Updates the {@link javax.swing.JPopupMenu} and {@link
     * javax.swing.text.DefaultStyledDocument} for every userobject
     * currently registered in this DiagramClass, provided the
     * userobject and the associated popupmenu implement the {@link
     * i5.cb.graph.ILangChangeable} Interface
     *
     * @param loc the new locale
     * @return a <code>DefaultStyledDocument</code> value
     */
    public DefaultStyledDocument updateLang(Locale loc) {
        Enumeration htWalker = htDiagramClass.keys();
        DiagramClassHashtableEntry entry = null;
        Object currentKey = null;

        while (htWalker.hasMoreElements()) {
            currentKey = (Object) htWalker.nextElement();
            entry = getHashtableEntry(currentKey);
            if (currentKey instanceof ILangChangeable) {

                DefaultStyledDocument dInfo =
                    ((ILangChangeable) currentKey).updateLang(loc);
                entry.setInfoDoc(dInfo);
                getGraphInternalFrame().getGraphEditor().setInfoDoc(dInfo);
            }
            if ((entry.getPopupMenu() != null)
                && (entry.getPopupMenu() instanceof ILangChangeable)) {
                ((ILangChangeable) entry.getPopupMenu()).updateLang(loc);
            }
        }
        if (multiPopup != null)
            multiPopup.updateLang(loc);
        return null;
    }

    /**
     * Returns the Userobjects stored in this diagramClass as enumeration
     * Returns an enumeration over the collection
     *
     * @return an <code>Enumeration</code> value
     */
    public Enumeration getUserObjects() {
        return htDiagramClass.keys();
    }

    /**
     * Tells whether a certain userobject is already associated with a {@link javax.swing.JPopupMenu}.
     *
     * @param userObject the userobject we want to check for.
     * @return a <code>boolean</code> value
     */
    public boolean hasPopupMenu(Object userObject) {
        return (getHashtableEntry(userObject).getPopupMenu() != null);
    }

    //There are a lot of debugmessages in here. Maybe someone will need it one fine day...

    /**
     * This protected method gets the {@link DiagramClassHashtableEntry} for a certain
     * userobject; if there is no entry yet it creates a new empty one.
     *
     * @param userObject an <code>Object</code> value
     * @return a <code>DiagramClassHashtableEntry</code> value
     */
    public DiagramClassHashtableEntry getHashtableEntry(Object userObject) {
        assert !(
            userObject
                instanceof DiagramObject) : "DiagramClass.getHashTableEntry:Userobject instanceof DiagramObject";

        DiagramClassHashtableEntry dchtEntry =
            (DiagramClassHashtableEntry) htDiagramClass.get(userObject);

        if (dchtEntry == null) {
            //	java.util.logging.Logger.getLogger("global").fine("DiagramClass.getHashtableEntry: HashtableEntry not found; creating new one");
            dchtEntry = new DiagramClassHashtableEntry();

            //	java.util.logging.Logger.getLogger("global").fine("DiagramClass.getHashtableEntry: Key for the new entry is: userObject: '" + userObject.toString() +
            //		   "'; HashCode: "+ userObject.hashCode() + ";");
            htDiagramClass.put(userObject, dchtEntry);
        }
        return dchtEntry;
    }

    /** Getter for property graphInternalFrame.
     * @return Value of property graphInternalFrame.
     */
    public GraphInternalFrame getGraphInternalFrame() {
        return this.graphInternalFrame;
    }

    public void resetAllComponents() {
        Enumeration enUOs = htDiagramClass.keys();
        while (enUOs.hasMoreElements()) {
            getHashtableEntry(enUOs.nextElement()).setComponent(null);
        }
    }

    public void resetAllSmallComponents() {
        Enumeration enUOs = htDiagramClass.keys();
        while (enUOs.hasMoreElements()) {
            getHashtableEntry(enUOs.nextElement()).setSmallComponent(null);
        }
    }

    public void resetAllEdgeColors() {
        Enumeration enUOs = htDiagramClass.keys();
        while (enUOs.hasMoreElements()) {
            getHashtableEntry(enUOs.nextElement()).setEdgeColor(null);
            getHashtableEntry(enUOs.nextElement()).setEdgeHeadColor(null);
            getHashtableEntry(enUOs.nextElement()).setEdgeHeadShape(null);
        }
    }

    public void resetAllEdgeStrokes() {
        Enumeration enUOs = htDiagramClass.keys();
        while (enUOs.hasMoreElements()) {
            getHashtableEntry(enUOs.nextElement()).setEdgeStroke(null);
        }
    }

    public void resetAllInfoDocs() {
        Enumeration enUOs = htDiagramClass.keys();
        while (enUOs.hasMoreElements()) {
            getHashtableEntry(enUOs.nextElement()).setInfoDoc(null);
        }
    }

    public void resetAllPopupMenus() {
        Enumeration enUOs = htDiagramClass.keys();
        while (enUOs.hasMoreElements()) {
            getHashtableEntry(enUOs.nextElement()).setPopupMenu(null);
        }
    }

    public void resetAllShapes(Object userObject) {
        Enumeration enUOs = htDiagramClass.keys();
        while (enUOs.hasMoreElements()) {
            getHashtableEntry(enUOs.nextElement()).setShape(null);
        }
    }
    public void setHashTableEntry(Object userObject,DiagramClassHashtableEntry hashEntry)
    {
        htDiagramClass.put(userObject,hashEntry);
    }

}
