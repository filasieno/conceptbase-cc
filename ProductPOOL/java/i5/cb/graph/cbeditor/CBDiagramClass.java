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
package i5.cb.graph.cbeditor;

import i5.cb.graph.GraphInternalFrame;
import i5.cb.graph.diagram.DiagramClass;
import i5.cb.graph.diagram.DiagramNode;
import i5.cb.telos.object.TelosObject;

import java.awt.*;
import java.util.HashMap;
import java.util.Map;

import javax.swing.JComponent;
import javax.swing.JPopupMenu;

/**
 * The CBDiagramClass should be able to handle all userObjects, that can be created in a {@link CBFrame}.
 *
 * @author     <a href="mailto:">Tobias Latzke</a>
 * created    07 March 2002
 * @version    1.0
 * @since      1.0
 * @see        DiagramClass
 */
public class CBDiagramClass extends DiagramClass {

    private Map mapUserObjects = new HashMap();

    /**
     * Simply calls the super constructor with the given parameter.
     *
     * @param frame the Frame that constructs this CBDiagramClass
     */
    public CBDiagramClass(GraphInternalFrame frame) {
        super(frame);
        assert frame
            instanceof CBFrame : "In CBDiagramClass, 'frame' must be instanceof CBFrame";

    }

    /**
     * Gets the smallComponent of the CBDiagramClass object
     *
     * @param userObject The userobject we need the small component for
     * @return The small component associated with this userobject
     */
    public Component getSmallComponent(Object userObject) {
        assert(
            userObject
                instanceof CBUserObject) : "CBDiagramClass.getSmallComponent: userObject has to be instanceof CBUserObject";

        CBUserObject cbuo = (CBUserObject) userObject;

        Component smallComponent =
            (Component) getHashtableEntry(userObject).getSmallComponent();

        if (smallComponent == null) {
            smallComponent = cbuo.getSmallComponent();
        }

        if (smallComponent instanceof JComponent)
            ((JComponent) smallComponent).setPreferredSize(
                new Dimension(
                    smallComponent.getPreferredSize().width + 10,
                    smallComponent.getPreferredSize().height + 10));
        getHashtableEntry(userObject).setSmallComponent(smallComponent);
        return smallComponent;
    }

    /**
     * Returns the (big) java.awt.Component for this object. This component
     * is used when the small component is not shown. To be compatible
     * with the graph editor which is implemented in JFC/Swing, the component
     * should be a subclass of JComponent.
     * This method may return null, but then getSmallComponent must return a value.
     * Otherwise, this method returns null or a value which is stored in the hashtable.
     *
     * @param userObject The userobject we need the component for
     * @return a <code>Component</code> value
     */
    public Component getComponent(Object userObject) {
        assert(
            userObject
                instanceof CBUserObject) : "CBDiagramClass.getSmallComponent: userObject has to be instanceof CBUserObject";

        Component mc = getHashtableEntry(userObject).getComponent();
        if (mc == null) {
            mc = ((CBUserObject) userObject).getComponent();
            getHashtableEntry(userObject).setComponent(mc);
        }
        return mc;
    } //getComponent

    /** Gets the shape associtated with a certain userobject
     * @param userObject The userobject we need the shape for
     * @return The shape associated with this userobject
     */
    public Shape getShape(Object userObject) {
        assert(
            userObject
                instanceof CBUserObject) : "CBDiagramClass.getShape: userObject has to be instanceof CBUserObject";

        CBUserObject cbuo = (CBUserObject) userObject;
        Shape s = (Shape) getHashtableEntry(cbuo).getShape();
        if (s == null) {
            s = cbuo.getShape();
            if (s != null)
                getHashtableEntry(userObject).setShape(s);
            else if (getDiagramNode(cbuo)!=null)
                getDiagramNode(cbuo).setPaintShapePolicy(
                    DiagramNode.PAINT_SHAPE_NEVER);
        }
        return s;
    }

    /**
     * Gets the {@link javax.swing.JPopupMenu} for a certain userObject
     *
     * @param userObject The userobject we need the popupmenu for
     * @return The jPopuoMenu associated with this userobject
     */
    public JPopupMenu getPopupMenu(Object userObject) {
        CBUserObject cbuo = (CBUserObject) userObject;
        JPopupMenu popup = getHashtableEntry(userObject).getPopupMenu();
        if (popup == null) {

            popup = cbuo.getPopupMenu();
            getHashtableEntry(userObject).setPopupMenu(popup);
        }
        return popup;
    }

    public CBUserObject getCBUserObject(TelosObject key) {
        return (CBUserObject) mapUserObjects.get(key);
    }

    public CBUserObject putCBUserObject(TelosObject key, CBUserObject value) {
        return (CBUserObject) mapUserObjects.put(key, value);
    }

    public CBUserObject removeCBUserObject(TelosObject key) {
        return (CBUserObject) mapUserObjects.remove(key);
    }

    public boolean containsCBUserObject(CBUserObject value) {
        return mapUserObjects.containsValue(value);
    }

    public BasicStroke getEdgeStroke(java.lang.Object userObject) {
        assert(
            userObject
                instanceof CBLink) : "DiagramClass.getEdgeColor: UserObject must be a CBLink instance";

        CBLink cbuo = (CBLink) userObject;

        BasicStroke stroke = getHashtableEntry(userObject).getEdgeStroke();
        if (stroke == null) {
            stroke = cbuo.getEdgeStroke();

            getHashtableEntry(userObject).setEdgeStroke(stroke);
        }
        return stroke;
    }
    //getEdgeStroke

    public Color getEdgeColor(Object userObject) {
        assert this
            .getDiagramNode(userObject)
            .isOnEdge() : "DiagramClass.getEdgeColor: UserObject must belong to a DiagramNode that sits on an edge";
        assert(userObject instanceof CBLink);

        CBLink cbuo = (CBLink) userObject;
        Color c = getHashtableEntry(userObject).getEdgeColor();
        if (c == null) {
            c = cbuo.getEdgeColor();
        }

        getHashtableEntry(userObject).setEdgeColor(c);
        return c;
    }

    public Color getEdgeHeadColor(Object userObject) {
        assert this
            .getDiagramNode(userObject)
            .isOnEdge() : "DiagramClass.getEdgeColor: UserObject must belong to a DiagramNode that sits on an edge";
        assert(userObject instanceof CBLink);

        CBLink cbuo = (CBLink) userObject;
        Color c = getHashtableEntry(userObject).getEdgeHeadColor();
        if (c == null) {
            c = cbuo.getEdgeHeadColor();
        }

        getHashtableEntry(userObject).setEdgeHeadColor(c);
        return c;
    }

    public Shape getEdgeHeadShape(Object userObject) {
        assert this
            .getDiagramNode(userObject)
            .isOnEdge() : "DiagramClass.getEdgeShape: UserObject must belong to a DiagramNode that sits on an edge";
        assert(userObject instanceof CBLink);

        CBLink cbuo = (CBLink) userObject;
        Shape s = getHashtableEntry(userObject).getEdgeHeadShape();
        if (s == null) {
            s = cbuo.getEdgeHeadShape();
        }

        getHashtableEntry(userObject).setEdgeHeadShape(s);
        return s;
    }

    /** Getter for property cbFrame.
     * @return Value of property cbFrame.
     */
    public CBFrame getCbFrame() {
        return (CBFrame) getGraphInternalFrame();
    }

    public void remove(Object obj) {

        if (obj == null)
           return;

        assert obj instanceof CBUserObject : "CBDiagramClass.remove(o): o must be instanceof CBUserObject";

        CBUserObject userObj=(CBUserObject) obj;

        mapUserObjects.remove(userObj.getTelosObject());
        //((CBFrame) graphInternalFrame).removeObjectToAdd(userObj.getCBFrame().getDiagramClass().getHashtableEntry(userObj));
        super.remove(obj);
    }

}
