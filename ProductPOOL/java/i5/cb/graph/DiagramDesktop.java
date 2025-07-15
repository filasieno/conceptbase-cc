/*
The ConceptBase.cc Copyright

Derived from ConceptBase.cc, originally created by the ConceptBase Team under a FreeBSD-style license.

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
 *  @(#)GraphEditor.java 0.5 b 11.09.99
 *
 *  Copyright 1998, 1999 by Rainer Langohr,
 *
 *  All rights reserved.
 *
 */

package i5.cb.graph;

import i5.cb.graph.diagram.*;
import i5.cb.graph.cbeditor.CBFrame;
import i5.cb.graph.cbeditor.CBConstants;
import i5.cb.graph.zooming.CBZoomer;


import java.awt.*;
import java.awt.event.MouseEvent;
import java.awt.geom.AffineTransform;
import java.awt.image.*;
import java.awt.print.*;
import java.beans.*;
import java.io.*;
import java.util.*;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.net.URL;

import javax.print.attribute.HashPrintRequestAttributeSet;
import javax.swing.*;
import javax.swing.event.MouseInputAdapter;

// for Batik 1.17
import org.apache.batik.svggen.SVGGraphics2D; 
import org.apache.batik.anim.dom.SVGDOMImplementation; 
import org.apache.batik.i18n.*;
import org.apache.batik.util.*;
import org.apache.batik.ext.awt.g2d.AbstractGraphics2D;
import org.apache.batik.css.engine.*;
import org.apache.batik.w3c.dom.*;
import org.apache.batik.parser.*;
import org.w3c.dom.DOMImplementation; 
import org.w3c.dom.Document; 
import org.w3c.dom.svg.*; 
import java.awt.Dimension; 


/**
 * Description of the Class
 *
 * @author schoeneb
 * -created 08 March 2002
 */
public class DiagramDesktop extends javax.swing.JDesktopPane implements
        Printable, PropertyChangeListener, ImageObserver {

    /**
     * In this selection mode the chosen nodes are added to the actual
     * selection.
     */
    public final static int SELECTION_MODE_NEW = 0;

    /**
     * In this selection mode the chosen nodes are removed from the actual
     * selection, if they are already selected. Otherwise they are added.
     */
    public final static int SELECTION_MODE_SWITCH = 1;

    /**
     * In this selection mode the actual selection is cleared and all chosen
     * nodes are selected.
     */
    public final static int SELECTION_MODE_ADD = 2;


    /**
     * Mask to check whether an image shall be saved/loaded; stored in bit 0 of an int number
     */
    public final static int HAS_IMAGE = 1;   // image should be stored as last element of a GEL file

    /**
     * Mask to check whether the module source shall be saved/loaded; stored in bit 1 of an int number
     * currently unused
     */
    public final static int HAS_SOURCE = 2;  

    /**
     * Mask to check whether CBGraph was started with special parameters (e.g. on synchronizing with the CBserver)
     */
    public final static int HAS_PARAMS = 4;  



    /**
     * Layer for background
     */
    public static Integer BACKGROUND_LAYER = JLayeredPane.DEFAULT_LAYER;

    /**
     * Layer for nodes
     */
    public static Integer NODE_LAYER = JLayeredPane.MODAL_LAYER;

    /**
     * Layer for edges
     */
    public static Integer EDGE_LAYER = JLayeredPane.PALETTE_LAYER;

    /**
     * the frame, this DiagramDesktop is associated to.
     */
    private GraphInternalFrame graphInternalFrame;

    /**
     * The MouseListener for all mouse manipulations on the desktop.
     */
    private DDMouseListener ddMouseListener;

    private boolean bUseSmoothLines;

    /**
     * The nodes which are currently marked by the user
     */
    private Collection m_cSelectedNodes;

    /** The nodes that are somehow invalid */
    private Collection m_cInvalidNodes;

    /** Utility field used by bound properties. */
    private PropertyChangeSupport propertyChangeSupport;

    private String m_sInvalidNodesMethod = "none_defined";

    /** Desktop layouter used for optimize layout of the graph. */
    //private DiagramDesktopLayouter m_layout;

    /** layouter using grappa */
    private DiagramDesktopGLayouter m_gLayout;

    /**CBZoomer for DiagramDesktop*/
    private CBZoomer zoomer;

    /**Background image for DiagramDesktop */
    private BufferedImage backgroundImage = null;

    /**flag for controlling the co-moving of diagram nodes that sit on edges */
    private boolean m_bMovableDNonEdge = true;

    /** flag indicating whether anything in the diagram desktop has been changed, e.g. location of a node */
    private boolean m_isEdited = false;

    /** flag indicating whether we are currently saving a screenshop */
    private boolean m_ScreenshotTaken = false;

    /** holds the CBserver host name originally loaded from a GEL file */
    private String cHostOrig = null;  

    /**
     * Creates a new <code>DiagramDesktop</code>.
     *
     * @param frame
     *            the frame, this DiagramDesktop is associated to
     */
    public DiagramDesktop(GraphInternalFrame frame) {
        super();

        setPreferredSize(new Dimension(1500, 1500));
        m_cSelectedNodes = new HashSet();   // see nissue #15: avoids duplicate entries via add()
        m_cInvalidNodes = new ArrayList();
        bUseSmoothLines = true; 
        ddMouseListener = new DDMouseListener();
        this.addMouseListener(ddMouseListener);
        this.addMouseMotionListener(ddMouseListener);
        graphInternalFrame = frame;
        //m_layout = new DiagramDesktopLayouter();
        m_gLayout = new DiagramDesktopGLayouter();
        zoomer = CBZoomer.getInstance();
    }

    /**
     * Resize desktop to given values
     */
    public void resizeDesktop(int width, int height) {
        this.setSize(width, height);
        this.setPreferredSize(new Dimension(width, height));
    }


    public GraphEditor getGraphEditor() {
      if (graphInternalFrame != null)
        return graphInternalFrame.getGraphEditor();
      else
        return null;
    }

 


    /**
     * returns the location of a rectangle with dimension newDimension that lies
     * next to oldbounds
     *
     * @param oldBounds
     *            the rectangle relative to which a new location shall be found
     * @param newDimension
     *            the size of the object that shall be placed at the new
     *            location
     * @param iPos
     *            Tells where the new location shall be relative to 'oldBounds'.
     *            One of N_POSITION, E_POSITION, S_POSITION and W_POSITION.
     * @param bCompact
     *            tells if only one axis (x or y) shall be altered or both.
     */
    static Point findNextLoc(Rectangle oldBounds, Dimension newDimension,
            int iPos, boolean bCompact) {
        Point rv = null;
        if (bCompact) {
            switch (iPos) {
            case GEConstants.N_POSITION:
                rv = new Point(oldBounds.x, oldBounds.y - newDimension.height
                        - 80);
                break;
            case GEConstants.W_POSITION:
                rv = new Point(oldBounds.x - newDimension.width - 40,
                        oldBounds.y);
                break;
            case GEConstants.S_POSITION:
                rv = new Point(oldBounds.x, oldBounds.y + oldBounds.height + 80);
                break;
            case GEConstants.E_POSITION:
                rv = new Point(oldBounds.x + oldBounds.width + 40, oldBounds.y);
                break;
            }
        } else {
            switch (iPos) {
            case GEConstants.N_POSITION:
                rv = new Point(oldBounds.x + newDimension.width + 40,
                        oldBounds.y - newDimension.height - 80);
                break;
            case GEConstants.W_POSITION:
                rv = new Point(oldBounds.x - newDimension.width - 40,
                        oldBounds.y - newDimension.height - 80);
                break;
            case GEConstants.S_POSITION:
                rv = new Point(oldBounds.x - newDimension.width - 40,
                        oldBounds.y + oldBounds.height + 80);
                break;
            case GEConstants.E_POSITION:
                rv = new Point(oldBounds.x + oldBounds.width + 40, oldBounds.y
                        + oldBounds.height + 80);
                break;
            }
        }
        return rv;
    } //findNextLoc

    /**
     * Adds a single {@link i5.cb.graph.diagram.DiagramEdge}to this
     * diagramDesktop
     *
     * @param edgeToAdd
     *            The diagramEdge we want to add.
     * @param parent
     *            The edge's source- or destination node
     * @param iPos
     *            one the N_POSITION, E_POSITION, S_POSITION or W_POSITION as
     *            defined in {@link i5.cb.graph.GEConstants}. Defines the edges
     *            position relative to 'parent'.
     */
    public void addDiagramEdge(DiagramEdge edgeToAdd, DiagramNode parent,
            int iPos) {

        Vector tmp = new Vector();
        tmp.add(edgeToAdd);
        addDiagramEdges(tmp, parent, iPos, false);
    }

    /**
     * Adds diagramEdges to this diagramDesktop. First extracts the nodes that
     * are peeers of 'parent' and those that are sitting of the edges (the two
     * groups apart from each other). Than adds the nodes with two calls of
     * addDiagramNode(Collection, DiagramNode, int, boolean). Finally adds the
     * diagramEdges themselfes.
     *
     * @param edgesToAdd
     *            a Vector containing the edges we want to add
     * @param parent
     *            a DiagramNode all new edges are incident to
     * @param iPos
     *            the new edges' relative position (i.e. north, west, south or
     *            east to parent)
     * @param bCompact
     *            tells if the new edges' endnodes (i.e. the peers of parent)
     *            shall be placed in a compact way or one a the lower right of
     *            another
     *
     */
    public void addDiagramEdges(Vector edgesToAdd, DiagramNode parent,
            int iPos, boolean bCompact) {

        if (edgesToAdd.size() == 0) {
//            java.util.logging.Logger.getLogger("global")
//                    .warning("'edgesToAdd' is emty. Returning.");
            return;
        }

        if (!parent.isShown()) {
            addDiagramNode(parent);
        }

        //contains the nodes sitting on the edges
        ArrayList aDNodesOnEdge = new ArrayList(edgesToAdd.size());

        //contains the peers of 'parent'
        ArrayList aDNodes = new ArrayList(edgesToAdd.size());

        DiagramEdge currentEdge;

        //filling 'aDNodesOnEdge'...
        Iterator itEdges = edgesToAdd.iterator();
        while (itEdges.hasNext()) {
            currentEdge = (DiagramEdge) itEdges.next();
            aDNodesOnEdge.add(currentEdge.getNodeOnEdge());
            currentEdge.setFixedPosition(true);
        }

        //filling 'aDNodes' and adding
        itEdges = edgesToAdd.iterator();
        while (itEdges.hasNext()) {
            currentEdge = (DiagramEdge) itEdges.next();
            if (currentEdge.getSource().getNode().isOnEdge()
                    && !currentEdge.getSource().getNode().getDiagramEdge()
                            .isShown()) {
                addDiagramEdge(currentEdge.getSource().getNode()
                        .getDiagramEdge(), currentEdge.getSource().getNode()
                        .getDiagramEdge().getSource().getNode(), GEUtil
                        .shiftPos(iPos));
            } else if (currentEdge.getDestination().getNode().isOnEdge()
                    && !currentEdge.getDestination().getNode().getDiagramEdge()
                            .isShown()) {
                addDiagramEdge(currentEdge.getDestination().getNode()
                        .getDiagramEdge(), currentEdge.getDestination()
                        .getNode().getDiagramEdge().getSource().getNode(),
                        GEUtil.shiftPos(iPos));
            }
            //if the node isn't already in the list, we add it now
            if (!aDNodes.contains(currentEdge.getPeer(parent).getNode())) {
                aDNodes.add(currentEdge.getPeer(parent).getNode());
            }
        }

        addDiagramNodes(aDNodes, parent, iPos, bCompact);
        addDiagramNodes(aDNodesOnEdge, parent, iPos, bCompact);

        // carry out layout algorithm
        m_gLayout.backup();
        m_gLayout.doIncrementalLayout();
        adjustContentPaneSize();

        DiagramNode currentNode;
        for (int i = 0; i < aDNodesOnEdge.size(); i++) {
            currentNode = (DiagramNode) aDNodesOnEdge.get(i);
            if (!currentNode.getDiagramEdge().isShown()) {
                super.add(currentNode.getDiagramEdge(), EDGE_LAYER);
                currentNode.getDiagramEdge().setDiagramDesktop(this);

                java.util.logging.Logger.getLogger("global")
                        .finest("DiagramDesktop.addDiagramObject: adding edge of currentNode "
                                + currentNode.getUserObject());
            }
        }
        itEdges = edgesToAdd.iterator();
        while (itEdges.hasNext()) {
            ((DiagramEdge) itEdges.next()).setFixedPosition(false);
        }
        this.setEdited(true);
        this.repaint();
    } //addDiagramEdges

    /**
     *
     * @param nodesToAdd
     *            the nodes we shall add. It's assumed that all nodes are
     *            siblings
     * @param parent
     *            a single node beeing already on the diagramDesktop, somehow
     *            related to the nodesToAdd
     * @param iPos tells if the new nodes are to be added in the south, east, north or
     *       west of as seen from othernode
     * @param bCompact
     *            tells if only one axis (x or y) shall be altered or both.
     *
     */
    public void addDiagramNodes(Collection nodesToAdd, DiagramNode parent,
            int iPos, boolean bCompact) {
        if (nodesToAdd.isEmpty()) {
            java.util.logging.Logger.getLogger("global")
                    .warning("DiagramDesktop.addNodes: parent: "
                            + parent.getUserObject() + " nodesToAdd is empty!");
            return;
        }
        Iterator itNewNodes = nodesToAdd.iterator();

        DiagramNode neighbour = parent;
        DiagramNode firstInRow = parent;

        int shiftedPos = GEUtil.shiftPos(iPos);

        // the first location right next to parent has to be in direction 'iPos'
        // instead of shiftedPos
        itNewNodes = nodesToAdd.iterator();

        boolean bFirst = true; // first node in a row?
        int iCount = 0; // number of nodes in current row

        //location of the Point currently in progress.
        Point currentLoc;

        //the nodes already beeing on the this desktop
        Vector vPresentNodes = getDiagramNodes();

        while (itNewNodes.hasNext()) {

            DiagramNode currentNewNode = (DiagramNode) itNewNodes.next();
            //java.util.logging.Logger.getLogger("global").fine("currentNewNode: " +
            // currentNewNode.getUserObject() + "; isOnEdge: " +
            // currentNewNode.isOnEdge());

            // Do not change position of already present nodes
            if (vPresentNodes.contains(currentNewNode))
                continue;

            // For nodes on edges to which also 'parent' belongs to: if source
            // and destination is already visible, place edge in the middle of
            // the two nodes (except it is recursive)
            if (currentNewNode.isOnEdge()
                    && (currentNewNode.getDiagramEdge().getSource() == parent || currentNewNode
                            .getDiagramEdge().getDestination() == parent)
                    && currentNewNode.getDiagramEdge().getPeer(parent)
                            .getNode().isShown()) {

                // recursive edge: source==destination
                Point pNew = null;
                if (currentNewNode.getDiagramEdge().getPeer(parent) == parent) {
                    pNew = new Point(parent.getCenter().x - 40, parent
                            .getCenter().y - 40);
                } else {
                    Point p1 = parent.getCenter();
                    Point p2 = currentNewNode.getDiagramEdge().getPeer(parent)
                            .getNode().getCenter();
                    pNew = new Point((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
                }
                currentNewNode.setLocation(pNew);
                addDiagramNode(currentNewNode, false, true);

                vPresentNodes.add(currentNewNode);
                continue;
                // we do not care here about intersection with other nodes
            }

            // if the node is the first node in a row, it is set next to the
            // first node of the previous row (which might be the parent)
            if (bFirst || iCount >= 10) {
                currentLoc = findPlaceNearTo(findNextLoc(
                        firstInRow.getBounds(), currentNewNode.getSize(), iPos,
                        bCompact), currentNewNode.getSize(), iPos);
                firstInRow = currentNewNode;
                bFirst = false;
                iCount = 0;
            } else { // otherwise it is positioned next to its neighbour
                currentLoc = findPlaceNearTo(findNextLoc(neighbour.getBounds(),
                        currentNewNode.getSize(), shiftedPos, bCompact),
                        currentNewNode.getSize(), iPos);
                neighbour = currentNewNode;
            }

            // if we are going out of bounds, we resize the desktop
            if ((currentLoc.x < 0)
                    || (currentLoc.y < 0)
                    || (currentLoc.x + currentNewNode.getBounds().width > getSize().width)
                    || (currentLoc.y + currentNewNode.getBounds().height > getSize().height)) {
                this.resizeDesktop(Math.max(currentLoc.x
                        + currentNewNode.getBounds().width + 50,
                        getSize().width), Math.max(currentLoc.y
                        + currentNewNode.getBounds().height, getSize().height));

            } //if( (currentLoc.x < 0) ||...

            currentNewNode.setLocation(currentLoc);

            addDiagramNode(currentNewNode, false, true);
            vPresentNodes.add(currentNewNode);
            neighbour = currentNewNode;
            iCount++;
        } // while(itNewNodes.hasNext() )
    } //addDiagramNodes

    /**
     * Adds a DiagramNode to the desktop together with its DiagramEdge (if it
     * has one)
     */
    public void addDiagramNode(DiagramNode node) {
        addDiagramNode(node, true, false);
    }

    /**
     * Adds a DiagramNode to the north, east, south or west of a certain other
     * node
     */
    public void addDiagramNode(DiagramNode nodeToAdd, DiagramNode otherNode,
            int iPos) {
        nodeToAdd.setLocation(findNextLoc(otherNode.getBounds(), nodeToAdd
                .getSize(), iPos, true));
        addDiagramNode(nodeToAdd, false, false);
    }

    /**
     * adds a diagramNode to this desktop. if the node is on an edge, the edge
     * is also added and if (later on) the node gets an edge, this edge is added
     * automatically
     *
     * @param node
     *            The node to be added
     * @param bConsiderEdge
     *            tells if a DiagramEdge belonging to this node shall also be
     *            added
     */
    private void addDiagramNode(DiagramNode node, boolean bConsiderEdge,
            boolean bOneOfMany) {
        assert (node != null) : "DiagramDesktop.addDiagramObject: 'node' equals null";

        //if this node is already in a diagramDesktop we won't add it here
        //we also don't have to bother about a possible diagramedge because
        // either it has already been added
        //as well or this dd will be notified via propertychangesupport if we
        // get one
        if (node.isShown()) {
            return;
        }

        node.addPropertyChangeListener(this);
        if (!bOneOfMany) {
            if (node.getDesignatedLocation() == null)
               node.setLocation(findPlaceNearTo(new Point(60, 60), node.getSize(),
                      GEConstants.E_POSITION));
            else
               node.setLocation(node.getDesignatedLocation());
        }
        super.add(node, NODE_LAYER);
        // set the precise position of the node in the layered pane; ticket #371
        this.setLayer(node, NODE_LAYER.intValue()+node.getNodeLevel(), -1);

        node.setDiagramDesktop(this);
        node.setVisible(true);

        //...and just to be sure the new node won't end up outside the desktop
        // we check its location
        correctLocation(node);

        if (bConsiderEdge) {
            if (node.isOnEdge()) {

                addDiagramNode(node.getDiagramEdge().getSource().getNode(),
                        bConsiderEdge, bOneOfMany);
                addDiagramNode(
                        node.getDiagramEdge().getDestination().getNode(),
                        bConsiderEdge, bOneOfMany);

                super.add(node.getDiagramEdge(), EDGE_LAYER);
                node.getDiagramEdge().setDiagramDesktop(this);
                java.util.logging.Logger.getLogger("global")
                        .finest("DiagramDesktop.addDiagramObject: adding edge of node "
                                + node.getUserObject());

            }
        }

        //zoom the node added
        zoomer.zoom(node);

        // add the new node into the abstract graph
        if (node.isOnEdge()) {
           // m_layout.addEdge(node.getDiagramEdge());
            m_gLayout.addEdge(node.getDiagramEdge());
        } else {
            //m_layout.addNode(node);
            m_gLayout.addNode(node);
        }

       this.setEdited(true);
       this.repaint();
    }

    /**
     * Finds a free rectangular area on the diagramDesktop
     *
     * @param location
     *            the location we want to find a place near to
     * @param node
     *            the Diamension of the diagramNode we search a free place for
     * @param dir
     *            the side of 'location the method should search next if the
     *            current location is not free. May be one of N_POSITION,
     *            E_POSITION, S_POSITION or W_POSITION as defined in
     *            {@link i5.cb.graph.GECONSTANTS}.
     *
     * @return the location of the node's new bounding rectangle (to be used
     *         with node.setLocation() )
     */
    private Point findPlaceNearTo(Point location, Dimension node, int dir) {
        Vector allNodes = getDiagramNodes();
        DiagramNode currentNode;
        Rectangle nodeBounds = new Rectangle(location.x, location.y,
                node.width, node.height);

        boolean bRunAgain = true;
        while (bRunAgain) {
            bRunAgain = false;
            for (int i = 0; i < allNodes.size(); i++) {
                currentNode = (DiagramNode) allNodes.get(i);
                //java.util.logging.Logger.getLogger("global").fine("checking for node
                // "+currentNode.getUserObject());
                if (currentNode.getBounds().intersects(nodeBounds)) {
                    //java.util.logging.Logger.getLogger("global").fine(currentNode.getUserObject()+"
                    // intersects with "+nodeBounds);

                    nodeBounds.setLocation(findNextLoc(nodeBounds, nodeBounds
                            .getSize(), dir, true));
                    bRunAgain = true;
                    break;
                }
            }
        }
        return new Point(nodeBounds.x, nodeBounds.y);
    } //findPlaceNearTo

    /**
     * Removes a {@link i5.cb.graph.diagram.DiagramObject}from the desktop.
     * Also calls the diagramObject's erase() method
     *
     * @param dobj
     *            The DiagramObject to be removed.
     */
    public void removeDiagramObject(DiagramObject dobj) {

        IFrameWorker gifW = graphInternalFrame.getFrameWorker();

        boolean bStoppedGifWorker = false;
        if (gifW != null && gifW.getStatus() == IFrameWorker.STATUS_RUNNING) {
            gifW.stopFrameWorker();
            bStoppedGifWorker = true;
        }
        dobj.erase();

        if (bStoppedGifWorker) {
            gifW.restartFrameWorker();
        }
        this.setEdited(true);
        this.repaint();
    } //removeDiagramObject

    /**
     * Removes diagramNodes from the desktop by calling this.removeDiagramObject
     * for each of them.
     *
     * @param cNodes
     *            the nodes that are to be removed
     */
    private void removeNodes(Collection cNodes) {
        Iterator itNodesWalker = cNodes.iterator();
        DiagramNode currentNode;
        LinkedList toRemove = new LinkedList();

        //if we want to remove a node we first have to check wheter it's on an
        // edge. If that is the case we have to remove the edge as well
        while (itNodesWalker.hasNext()) {
            currentNode = (DiagramNode) itNodesWalker.next();
//          System.out.println("To remove "+currentNode.getLabel());
            if (!currentNode.isOnEdge()
                    || (currentNode.isOnEdge() && (!cNodes.contains(currentNode
                            .getDiagramEdge().getSource()) && !cNodes
                            .contains(currentNode.getDiagramEdge()
                                    .getDestination())))) {
                toRemove.add(currentNode);
                if(m_cInvalidNodes.contains(currentNode)) {
                    m_cInvalidNodes.remove(currentNode);
                }
            } //if (!currentNode...
        } //while (sMarkedNodesWalker.hasnext())
        ListIterator toRemoveWalker = toRemove.listIterator();
        while (toRemoveWalker.hasNext()) {
            currentNode = (DiagramNode) toRemoveWalker.next();
            removeDiagramObject(currentNode);
            if (currentNode.isOnEdge()) {
               // m_layout.removeEdge(currentNode.getDiagramEdge());
                m_gLayout.removeEdge(currentNode.getDiagramEdge());
            } else {
               // m_layout.removeNode(currentNode);
                m_gLayout.removeNode(currentNode);
            }
        } //while (toRemoveWalker.hasNext())
    }

    /**
     * Removes the nodes which are currently marked.
     */
    public void removeMarkedNodes() {
        removeNodes(m_cSelectedNodes);
        m_cSelectedNodes.clear();
    }

    /**
     * Removes the nodes that are considered invalid in some sense.
     */
    public void removeInvalidNodes() {

        // Issue #57: Due to ConcurrentModificationException we may not modify a Collection that is itegrated over
        // in removeNodes; we thus use a m_cInvalidNodes_copy, which is a shallow copy of m_cInvalidNodes
        // to avoid this problem; it is a workaround until we find a better solution; Manfred J
        Collection m_cInvalidNodes_copy = new ArrayList();
        Iterator iterator1 = m_cInvalidNodes.iterator();
        while(iterator1.hasNext()){
          m_cInvalidNodes_copy.add(iterator1.next());
        }

        removeNodes(m_cInvalidNodes_copy);
        m_cInvalidNodes.clear();
    }


    /**
     * Gets this DiagramDesktop's DiagramNodes (including the nodes on Edges)
     *
     * @return a <code>Vector</code> containing the DiagramNodes residing in
     *         this DiagramDesptop
     * @see i5.cb.graph.diagram.DiagramNode
     */
    public Vector getDiagramNodes() {
        Vector vDiagramNodes = new Vector();

//        Component[] comps = this.getComponentsInLayer(DiagramDesktop.NODE_LAYER.intValue());
//      ticket #371: nodes can be at any layer via the "nodelevel" property
        Component[] comps = this.getComponents();

        for (int i = 0; i < comps.length; i++) {
            Component comp = comps[i];
            if ((comp != null) && (comp instanceof DiagramNode)
                    && !(vDiagramNodes.contains(comp))) {
                vDiagramNodes.addElement(comp);
            }
        }
        java.util.logging.Logger.getLogger("global")
                .finer("DiagramDesktop.getDiagramNodes: returning "
                        + vDiagramNodes.size() + " nodes;");
        return vDiagramNodes;
    } //getDiagramNodes



    /**
     * Gets this DiagramDesktop's proper DiagramNodes (excluding the nodes on Edges)
     *
     * @return a <code>Vector</code> containing the proper DiagramNodes residing in
     *         this DiagramDesptop
     * @see i5.cb.graph.diagram.DiagramNode
    */
    public Vector getProperDiagramNodes() {
        Vector vDiagramNodes = new Vector();

 //       Component[] comps = this.getComponentsInLayer(DiagramDesktop.NODE_LAYER.intValue());
//      ticket #371: nodes can be at any layer via the "nodelevel" property
        Component[] comps = this.getComponents();

        for (int i = 0; i < comps.length; i++) {
            Component comp = comps[i];
            if ((comp != null) && (comp instanceof DiagramNode)
                    && !(vDiagramNodes.contains(comp))) {
                DiagramNode currentNode = (DiagramNode) comp;
                if (!currentNode.isOnEdge())
                  vDiagramNodes.addElement(comp);
            }
        }
        return vDiagramNodes;
    } //getProperDiagramNodes


    /**
     * Gets this DiagramDesktop's DiagramNodes (excluding the nodes on Edges) that
     * are geometrically contained in the container node cnode
     *
     * @return a <code>Vector</code> with all proper DiagramNodes geometrically contained in cnode
     * @param cnode
     *            the container node
     * @see i5.cb.graph.diagram.DiagramNode
    */
    public Vector getContainedDiagramNodes(DiagramNode cnode) {
        Vector vDiagramNodes = new Vector();

        Component[] comps = this.getComponents();

        for (int i = 0; i < comps.length; i++) {
            Component comp = comps[i];
            if ((comp != null) && (comp instanceof DiagramNode)
                    && !(vDiagramNodes.contains(comp))) {
                DiagramNode currentNode = (DiagramNode) comp;
                if ( !currentNode.isOnEdge() && cnode.containsNode(currentNode)
                                             && currentNode.getNodeLevel() > cnode.getNodeLevel() )
                  vDiagramNodes.addElement(comp);
            }
        }
        return vDiagramNodes;
    } 


    /**
     * Gets the DiagramNode that is containing dn as component, returns null if not existent;
     * this is the reverse function of getContainedDiagramNodes
     *
     * @return the container that contains dn
     * @param dn
     *            a DiagramNode of this DiagramDesktop
     * @see i5.cb.graph.diagram.DiagramNode
    */
    public DiagramNode getContainerNode(DiagramNode dn) {

        Component[] comps = this.getComponents();
        DiagramNode cn = null; // candidate container of dn

        for (int i = 0; i < comps.length; i++) {
            Component comp = comps[i];  
            if ((comp != null) && (comp instanceof DiagramNode) ) {
                cn = (DiagramNode) comp;
                if ( !cn.isOnEdge() && cn.containsNode(dn)
                                    && dn.getNodeLevel() > cn.getNodeLevel() )
                  return cn;
            }
        }
        return null;  // if no such node is found
    } 



    

    /**
     * Returns all diagramEdges shown on this desktop. You can choose whether to
     * retrieve the {@link i5.cb.graph.diagram.DiagramEdge}s or the
     * {@link i5.cb.graph.diagram.DiagramNode}s by setting the
     * nodeRepresentation parameter.
     *
     * @param nodeRepresentation
     *            flag to indicate whether to return the DiagramEdges or the
     *            DiagramNodes on the edges
     * @return the DiagramEdges if nodeRepresentation is false. The DiagramNodes
     *         on the edges else.
     */
    public Vector getDiagramEdges(boolean nodeRepresentation) {
        DiagramNode currentNode;
        Vector edges = new Vector();
        Iterator itDiagramNodes = getDiagramNodes().iterator();
        while (itDiagramNodes.hasNext()) {
            currentNode = (DiagramNode) itDiagramNodes.next();
            if (currentNode.isOnEdge()) {
                if (nodeRepresentation) {
                    edges.add(currentNode);
                } else {
                    edges.add(currentNode.getDiagramEdge());
                }
            } // end of if (currentNode.isOnEdge())
        } // end of while (itDiagramEdges.hasNext())
        return edges;
    }


     /**
     * Returns all incident diagram edges of diagram object dn
     */
    public Vector getIncidentDiagramEdges(DiagramObject dn) {
      Vector allEdges = getDiagramEdges(false);
      Vector incidentEdges = new Vector();
      Iterator itEdges = allEdges.iterator();
      DiagramEdge currentEdge;
      while (itEdges.hasNext()) {
        currentEdge = (DiagramEdge) itEdges.next();
        if (currentEdge.getSource() == dn || currentEdge.getDestination() == dn ) {
          incidentEdges.add(currentEdge);
        }
      }
     return incidentEdges;
    }

     /**
     * Returns the set of all neighbors and neighbors of neighbors of diagram node dn
     */

    public Vector getNeighborhood(DiagramNode dn) {
       Vector allNeighbors = new Vector();
       Vector directNeighbors = getNeighbors(dn);

       for (int i=0; i<directNeighbors.size(); i++) {
          if (!allNeighbors.contains(directNeighbors.elementAt(i)))
            allNeighbors.add(directNeighbors.elementAt(i));
          DiagramNode nb = (DiagramNode) allNeighbors.elementAt(i);
          Vector nextNeighbors = getNeighbors(nb);
          for (int j=0; j<nextNeighbors.size(); j++) {
             if (!allNeighbors.contains(nextNeighbors.elementAt(j)))
                allNeighbors.add(nextNeighbors.elementAt(j));
          }
       }
/*
       System.out.println("\nNeighborhood "+allNeighbors.size());
       for (int i=0; i<allNeighbors.size(); i++) {
        System.out.print(i + ": ");
         if (allNeighbors.elementAt(i)==null) continue;
         DiagramNode n = (DiagramNode) allNeighbors.elementAt(i);
         i5.cb.graph.cbeditor.CBUserObject uo = (i5.cb.graph.cbeditor.CBUserObject) n.getUserObject();
         System.out.println(uo.toString());
       }
*/
       return allNeighbors;
    }

     /**
     * Returns the set of all direct neighbors of diagram node dn; this includes the nodes on edges incident to dn
     */

    public Vector getNeighbors(DiagramNode dn) {
       Vector neighbors = new Vector();
       Vector edges = dn.getEdges();
       if (!neighbors.contains(dn))
         neighbors.add(dn);
       if (dn.getDiagramEdge() != null) {
         if (!neighbors.contains(dn.getDiagramEdge().getSource()))
            neighbors.add(dn.getDiagramEdge().getSource());
         if (!neighbors.contains(dn.getDiagramEdge().getDestination()))
            neighbors.add(dn.getDiagramEdge().getDestination());
       }
       for (int i=0; i<edges.size(); i++) {
          DiagramEdge e = (DiagramEdge) edges.elementAt(i);
          if (e == null)
            continue;
          if (e.getSource() != null && !neighbors.contains(e.getSource()))
                neighbors.add(e.getSource()); 
          if (e.getDestination() != null && !neighbors.contains(e.getDestination()))
                neighbors.add(e.getDestination()); 
          if (e.getNodeOnEdge() != null && !neighbors.contains(e.getNodeOnEdge()))
                neighbors.add(e.getNodeOnEdge()); 
       }
       return neighbors;
    }



    /**
     * Prints this diagramDesktop along with it's content.
     */
    void printDesktop() {
        PrinterJob job = PrinterJob.getPrinterJob();
        if (job.printDialog(new HashPrintRequestAttributeSet())) {
            job.setPrintable(this);
            try {
                job.print();
            } catch (java.awt.print.PrinterException pe) {
                java.util.logging.Logger.getLogger("global")
                        .fine("DiagramDesktop.printDesktop: PrinterException: "
                                + pe.getMessage());
            }
        }
    }

    /**
     * Creates and saves a screenshot of this diagramDesktop.
     *  * * *
     * @param sFormat
     *            the format of the imagerfile
     * @param file
     *            the file the image shall be saved in
     */
    void saveScreenShot(String sFormat, File file) {
        if (sFormat.equals("svg")) {
           saveScreenShotVectorGraphics(sFormat, file);
        } else {
           saveScreenShotBitmap(sFormat, file);
        }
    }

    void saveScreenShotBitmap(String sFormat, File file) {
        m_ScreenshotTaken = true;
        BufferedImage screenShot = getImageOfDesktop();
        m_ScreenshotTaken = false;
        try {
            javax.imageio.ImageIO.write(screenShot, sFormat, file);
        } catch (java.io.IOException ioe) {
            java.util.logging.Logger.getLogger("global").warning(ioe.getMessage());
        }
    }

    // 2025-07-15; compiles and runs but produces just a while background image
    void saveScreenShotVectorGraphics(String sFormat, File file) {
//        System.out.println("saveScreenShotVectorGraphics " +  file.getAbsolutePath());
        Rectangle clipRectangle = getDiagramClipRectangle();
//        System.out.println("Clip rectangle: x="+clipRectangle.x+" y="+clipRectangle.y+" width="+clipRectangle.width+" height="+clipRectangle.height);
        DOMImplementation impl = SVGDOMImplementation.getDOMImplementation(); 
        String svgNS = SVGDOMImplementation.SVG_NAMESPACE_URI;
        Document svgdoc = impl.createDocument(svgNS, "svg", null); 
        SVGGraphics2D svgGraphics = new SVGGraphics2D(svgdoc); 
        svgGraphics.setSVGCanvasSize(new Dimension(clipRectangle.width+clipRectangle.x, clipRectangle.height+clipRectangle.y));
        svgGraphics.setClip(0, 0, clipRectangle.width+clipRectangle.x, clipRectangle.height+clipRectangle.y);
        this.paint(svgGraphics);
        try {
           Writer out = new FileWriter(file.getAbsolutePath());
           svgGraphics.stream(out, true); // true to use CSS for styling 
        } catch (Exception e) {
           e.printStackTrace();
        }
    }



    /**
     * Stores the position of all nodes, and which edges must be displayed. At
     * the moment information about the shape of the edges(if they are bent) is
     * lost. Keep in mind that there will not happen very much, if the
     * {@link GraphInternalFrame}does not implement the saveUserObject Method.
     *
     * @param out
     *            any ObjectOutput
     * @exception IOException
     *                if an error occurs
     */
    public void save(ObjectOutputStream out) throws IOException {

        Vector vNodes = getDiagramNodes();
        int nSize = vNodes.size();
        DiagramNode currentNode;

        Vector vEdges = getDiagramEdges(false);
        int eSize = vEdges.size();
        DiagramEdge currentEdge;

        Hashtable htNodeToHandle = new Hashtable();

        out.writeObject(Integer.valueOf(nSize));

        float origZoomFactor = getZoom();
        boolean zoomChanged = false;
        this.setVisible(false);
        if (Math.abs(origZoomFactor-1.0F) > 0.001F) {
          setZoom(1.0F);  // save with zoom factor 100%
          zoomChanged = true;
          this.repaint();
        }

        for (int i = 0; i < nSize; i++) {
            currentNode = (DiagramNode) vNodes.elementAt(i);
            if (currentNode.isComponentVisible())
               currentNode.setSmallComponentVisible();
            htNodeToHandle.put(currentNode, Integer.toString(i));
            graphInternalFrame.saveUserObject(currentNode.getUserObject(), out);
            Rectangle r = currentNode.getBounds();
            codeFrozenStatus(currentNode.isFrozen(),r);  // ticket #426
            out.writeObject(r);
            
            java.util.logging.Logger.getLogger("global").finer("currentNode: "
                    + currentNode.getUserObject() + "; Bounds: "
                    + currentNode.getBounds());
        }

        out.writeObject(Integer.valueOf(eSize));

        for (int i = 0; i < eSize; i++) {
            currentEdge = (DiagramEdge) vEdges.elementAt(i);

            String sSource = (String) htNodeToHandle.get(currentEdge
                    .getSource().getNode());
            String sNodeOnEdge = (String) htNodeToHandle.get(currentEdge
                    .getNodeOnEdge());
            String sDest = (String) htNodeToHandle.get(currentEdge
                    .getDestination().getNode());

            out.writeObject(sSource);
            out.writeObject(sNodeOnEdge);
            out.writeObject(sDest);
        }



        // save background color
        out.writeObject(this.getBackground());  // write background color of this diagram desktop


        out.writeObject(new Float(origZoomFactor) );   

        CBFrame cbf= null;
        if (graphInternalFrame instanceof CBFrame)
          cbf = (CBFrame)graphInternalFrame; 

        // save current host, port, module, frame title, palette
        String cModule = "oHome";
        String cHost = "localhost";
        String cPort = "4001";
        String cLongTitle = "unknown";
        String cPalette = CBConstants.DEFAULT_PALETTE;
        String cContext = null;
        if (cbf != null)  {
          cModule = cbf.getContext();
          cHost = cbf.getLogicalHost();
          cPort = cbf.getPort();
          cLongTitle = cbf.getLongTitle();
          cPalette = cbf.getGraphicalPalette();
        }
        if (cHost.equals("localhost") && cHostOrig != null)
          cHost = cHostOrig;  // to preserve the original host information
        out.writeObject(cHost);
        out.writeObject(cPort);
        out.writeObject(cModule);
        out.writeObject(cLongTitle);
        out.writeObject(cPalette);

        int saveflag = 0;  // to accumulate which optional elements will be saved in the GEL file

        //  bit2: HAS_PARAMS
        if (cbf != null && cbf.getCBEditor().getCBGraphParams() != null) {
           saveflag = saveflag | HAS_PARAMS;
        }

        //  bit1: HAS_SOURCE
        if (cbf != null && cbf.getCBEditor().getReadCBModule()) {
           saveflag = saveflag | HAS_SOURCE;
        }
        //  bit0: HAS_IMAGE  (last to be saved!)
        if (this.backgroundImage != null) 
           saveflag = saveflag | HAS_IMAGE;

        out.writeObject(Integer.valueOf(saveflag));

       // add saving HAS_PARAMS etc. here, i.e. from higher bits to lower bits
       // If HAS_PARAMS is set, then we save the current CBGraph parameters also in the GEL file

        if ((saveflag & HAS_PARAMS) > 0) {
           out.writeObject(cbf.getCBEditor().getCBGraphParams());
        }

        // add saving HAS_SOURCE etc. here, i.e. from higher bits to lower bits

        if ((saveflag & HAS_SOURCE) > 0) {
           cbf.saveModuleSources(out);
        }


        // save background image (bit HAS_IMAGE of saveflag); last optional element to be save
        if ((saveflag & HAS_IMAGE) > 0) {
          out.writeObject(graphInternalFrame.getSize());  // write the dimension of the outer window
          // BufferedImage is not directly serializable, so we use IMageIO to store it
          ImageIO.write(this.backgroundImage, "png", out); 
        }


        // restore the original zoom factor
        if (zoomChanged) {
           setZoom(origZoomFactor);
           this.repaint();
        }
        this.setVisible(true);

        graphInternalFrame.finishedSaving();
    } //save

    /**
     * Clears the DiagramDesktop and then restores a saved layout from the given
     * ObjectInput. Will only work, if this DiagramDesktop is associated to a
     * {@link GraphInternalFrame}. Keep in mind that there will not happen very
     * much, if the {@link GraphInternalFrame}does not implement the
     * loadUserObject Method.
     *
     * @param in
     *            any ObjectInput where a DiagramDesktop has been stored
     * @exception IOException
     *                if an error occurs
     * @exception ClassNotFoundException
     *                if class String or Rectangle is not found, deserialization
     *                fails
     */
    public void load(ObjectInputStream in) throws IOException,
            ClassNotFoundException {

        Hashtable htHandleToNode = new Hashtable();
        Enumeration enNewNodes;
        DiagramNode currentNode;
        Rectangle currentBounds;
        int nSize;

        String sEdgeSource, sEdgeNodeOnE, sEdgeDest;

        Vector vNewEdges = new Vector();
        DiagramEdge currentEdge;
        int eSize;

        DiagramClass newDiagClass;

        graphInternalFrame.resetDiagramClass();

        newDiagClass = graphInternalFrame.getDiagramClass();

        nSize = ((Integer) in.readObject()).intValue();

        Object currentUserObject;
        this.setVisible(false);

        for (int i = 0; i < nSize; i++) {

            currentUserObject = graphInternalFrame.loadUserObject(in);
            // System.out.println("Loading object number"+i);
            currentBounds = (Rectangle) in.readObject();
            boolean frozen = getFreezeStatus(currentBounds);
            unfreezeRectangle(currentBounds);
            java.util.logging.Logger.getLogger("global").finer("currentUserObject: "
                    + currentUserObject + "; Bounds: " + currentBounds);
            if (currentUserObject != null) {
                currentNode = new DiagramNode(currentUserObject, newDiagClass);
                currentNode.setBounds(currentBounds);
                currentNode.setSmallComponentSize(currentNode.getSize()); 
                currentNode.setFrozen(frozen);
                htHandleToNode.put(Integer.toString(i), currentNode);         
            }
        }

        eSize = ((Integer) in.readObject()).intValue();

        for (int i = 0; i < eSize; i++) {
            sEdgeSource = (String) in.readObject();
            sEdgeNodeOnE = (String) in.readObject();
            sEdgeDest = (String) in.readObject();

            currentEdge = new DiagramEdge((DiagramNode) htHandleToNode
                    .get(sEdgeNodeOnE), (DiagramNode) htHandleToNode
                    .get(sEdgeSource), (DiagramNode) htHandleToNode
                    .get(sEdgeDest), newDiagClass);

            vNewEdges.add(currentEdge);
        }
        enNewNodes = htHandleToNode.elements();
        while (enNewNodes.hasMoreElements()) {
            addDiagramNode((DiagramNode) enNewNodes.nextElement(), true, true);
        }


        try {
          // restore background color,zoomer and image
          Color bgc = (Color) in.readObject();
          this.setBackground(bgc);
          Float f0 = (Float) in.readObject();
          float newzoomfactor = f0.floatValue();
          CBFrame cbf = null;
          if (graphInternalFrame instanceof CBFrame) 
            cbf = (CBFrame)graphInternalFrame;

          String cHost = (String) in.readObject();
          String cPort = (String) in.readObject();
          String cModule = (String) in.readObject();
          String cTitle = (String) in.readObject();
          String cPalette = (String) in.readObject();

          // host/port can be overridden by a CBEditor command line argument -host
          if (cbf.getCBEditor().getOverrideHost() != null)
             cHost = cbf.getCBEditor().getOverrideHost();
          if (cbf.getCBEditor().getOverridePort() != null)
             cPort = cbf.getCBEditor().getOverridePort();


 //         System.out.println(cHost+':'+cPort+'/'+cModule);
          if (cbf != null)  {
            if (cbf.isConnected() && cbf.usingPublicCBserver()) 
              cHost = cbf.getHost();  // to re-use the same public CBserver when loading a new GEL file while connected
            cbf.setLongTitle(cTitle);
            cbf.setGraphicalPalette(cPalette);
            cbf.setContext(cModule);
            // need to check whether CBFrame is connected to a CBserver
            cbf.reconnectView(cHost,cPort,cModule);
            if (!cPalette.equals(CBConstants.DEFAULT_PALETTE))
              cbf.refreshUserObjects(getDiagramNodes());  // user objects may need refreshed CBTree's depending on cPalette
          } else {
            java.util.logging.Logger.getLogger("global").warning("No CBEditor-CBFrame found; cannot connect to "+cHost+":"+cPort+"/"+cModule);
          }


          Integer i0 = (Integer) in.readObject();
          int saveflag = i0.intValue(); //saveflag indicates which optional elements are stored in the GEL file


          // HAS_PARAMS flag indicates we stored the command line parameters +r,+w,+rw etc with this GEL file
          // We then will evaluate the stored parameters as if they were supplied by the command line
          if ((saveflag & HAS_PARAMS) > 0) {
            String [] newparams = (String[]) in.readObject();
            if (cbf != null && cbf.getCBEditor().getCBGraphParams() == null) {
              cbf.getCBEditor().analyzeCmdArgs(newparams);  // can call setReadCBModule and setWriteCBModule
            }
          }

          // HAS_SOURCE: module sources are stored in the GEL file
          if (cbf != null && (saveflag & HAS_SOURCE) > 0) {
             if (!cbf.isConnected() &&  // the previous reconnectView failed
                 (cbf.getCBEditor().getWriteCBModule() ||   // module sources are requested either for read or write
                  cbf.getCBEditor().getReadCBModule() )) {
               if (!cHost.equals("localhost"))
                 cHostOrig = cHost;  // memorize for later save()
               cbf.startLocalServerAndConnect("localhost",cPort,cModule);
              // if a local (empty) CBserver is started on the fly, we always write the module sources from the GEL file
              if (!cbf.getCBEditor().getWriteCBModule()) {
                 this.getGraphInternalFrame().setStatusString("Set to tell module sources to fresh CBserver");
                 this.getGraphInternalFrame().repaint();
                 cbf.getCBEditor().setWriteCBModule(true);  
              }
             }   
             cbf.loadModuleSources(in);
          }

          // HAS_IMAGE: background image is stored in the GEL file (last optional element in GEL file!)
          if ((saveflag & HAS_IMAGE) > 0) {
             graphInternalFrame.setSize((Dimension) in.readObject());
             this.backgroundImage = ImageIO.read(in);
          }



          this.setZoom(newzoomfactor);
          this.repaint();

          // ask the CBserver whether it knows the current graphical palette
          if (cbf.existsGraphicalPalette()) {  
            // System.out.println("Graphical palette " + cbf.getGraphicalPalette() + " was found");
            // We need to reload the graphical palette from the database and validate the graph against the
            // database, because the database could have been changed and to make sure that
            // the properties of the graphical palette are set properly in CBFrame
            cbf.loadGraphicalPalette(cbf.getGraphicalPalette());
          } else {
            JOptionPane.showMessageDialog(this,"Could not find graphical palette " + cbf.getGraphicalPalette() + " in the database");
          } 

        } catch (Exception e) {
           System.err.println(e.getMessage());
        }

        
        this.setVisible(true);
        this.setEdited(false);
        graphInternalFrame.finishedLoading();
    } //load

    /**
     * Gets this desktop's {@link i5.cb.graph.GraphInternalFrame}
     *
     * @return the Frame, this DiagramDesktop is associated to
     */
    public GraphInternalFrame getGraphInternalFrame() {
        return graphInternalFrame;
    }

    public Collection getInvalidNodes() {
        return m_cInvalidNodes;
    }


    private void codeFrozenStatus(boolean frozen, Rectangle r) {
      if (frozen)
        r.width = -r.width;
    }

    private void unfreezeRectangle(Rectangle r) {
      r.width = Math.abs(r.width);
    }

    private boolean getFreezeStatus(Rectangle r) {
      return (r.width < 0);
    }



    /**
     * calls the JDesktopPane's paintComponent method. We use it here to draw the background
     * image of the palette (if defined via CBFrame)
     *
     * @param g
     *            a <code>Graphics</code> value
     */
    public void paintComponent(Graphics g) {
        int newwidth;
        int newheight;
        super.paintComponent(g);
        // draw the background image if defined
        if (backgroundImage != null) {
/* this calculation does not work too well
          int gifborderWidth = graphInternalFrame.getInsets().left + graphInternalFrame.getInsets().right;  
          int gifborderHeight = graphInternalFrame.getInsets().top + graphInternalFrame.getInsets().bottom; 
*/
          newwidth = graphInternalFrame.getWidth()  - 26; // graphInternalFrame has title,scrollbars etc
          newheight = graphInternalFrame.getHeight()  - 52;
          g.drawImage(backgroundImage, 0, 0, newwidth, newheight, null);
        }
    }



    /**
     * calls the JDesktopPane's paint method. Then it shows black rectangles
     * around every marked node.
     *
     * @param g
     *            a <code>Graphics</code> value
     */
    public void paint(Graphics g) {
        super.paint(g);

        //now we paint rectangular frames around every node that is selected
        DiagramNode currentNode;

        Iterator itMarkedNodesWalker = m_cSelectedNodes.iterator();

        while (itMarkedNodesWalker.hasNext()) {
            currentNode = (DiagramNode) itMarkedNodesWalker.next();
            currentNode.drawRect(g);
            //this also makes sure that currentNode is is the front
            currentNode.setVisible(true);
        } // end of while (sMarkedNodesWalker.hasNext())

        //java.util.logging.Logger.getLogger("global").fine("Value of m_sInvalidNodesMethod:
        // "+m_sInvalidNodesMethod);

        if (m_sInvalidNodesMethod.equals(i5.cb.CBConfiguration.VALUE_MARK)) {

            Iterator itInvalidNodesWalker = m_cInvalidNodes.iterator();

            while (itInvalidNodesWalker.hasNext()) {
                currentNode = (DiagramNode) itInvalidNodesWalker.next();
                currentNode.drawInvalidSign(g);

                //this also makes sure that currentNode is is the front
                currentNode.setVisible(true);
            } // end of while (sMarkedNodesWalker.hasNext())
        }
        if (ddMouseListener.getSelectionRect() != null) {
            g.drawRect(ddMouseListener.selectionRect.x,
                    ddMouseListener.selectionRect.y,
                    ddMouseListener.selectionRect.width,
                    ddMouseListener.selectionRect.height);
        }
    } //paint

    /**
     * Checks a {@link i5.cb.graph.diagram.DiagramNode}wheter it is still
     * inside this desktop's bounds. Changes the node's location if it isn't.
     *
     * @param node
     *            the diagramNode we want to check for.
     *
     * @return true if the location of the node had to be changed, false
     *         otherwise
     */
    public boolean correctLocation(DiagramNode node) {

        Rectangle nodeBounds = node.getBounds();

        assert (!node.isShown() || node.getDiagramDesktop() == this) : "The node '"
                + node.getUserObject().toString()
                + "' is already shown on another DiagramDesktop";

        assert (this.getSize().width > nodeBounds.width)
                && (this.getSize().height > nodeBounds.height) : "DiagramDesktop.correctLocation: this desktop is too small for this node";

        boolean rv = false;
        if (nodeBounds.x < 0) {
            nodeBounds.x = 0;
            rv = true;
            node.setBounds(nodeBounds);
        }
        if (nodeBounds.y < 0) {
            nodeBounds.y = 0;
            rv = true;
            node.setBounds(nodeBounds);
        }
        if (nodeBounds.x + nodeBounds.width > this.getWidth()) {
            resizeDesktop(nodeBounds.x + nodeBounds.width + 50, this
                    .getHeight());
            rv = true;
        }
        if (nodeBounds.y + nodeBounds.height > this.getHeight()) {
            resizeDesktop(this.getWidth(), nodeBounds.y + nodeBounds.height
                    + 50);
            rv = true;
        }
        return rv;
    }


    /**
     *
     * @return true if diagram nodes that sit on edges shall move synchronously if one side of the edge is moved
     */
    public boolean getMovableDiagramNodeOnEdge() {
        return m_bMovableDNonEdge;
    }

    /**
     *
     * sets movability of nodes that sit on edges, i.e. when true the node representing the "middle" of 
     * the edge moves synchronously when one side of the edge is moved. This is the normal behaviour. 
     * If set to false, then the "middle" of the edge (where the edge label is shown) is fixed.
     * This behaviour is useful when changing the palette without wanting the edges to be relocated.
     * @param value
     *            the new value for movability of the nodes on edges.
     */
    public void setMovableDiagramNodeOnEdge(boolean value) {
        m_bMovableDNonEdge = value;
    }



    public float getZoom() {
        return zoomer.getFactor();
    }

    public void setZoom(float z) {

          this.getGraphInternalFrame().setStatusString("Zooming to factor " + z + " ..."); 

          float oldZ = getZoom();
          zoomer.setFactor(z);
          JViewport viewport =((JScrollPane)(this.getGraphInternalFrame().getContentPane())).getViewport();

          Dimension max = new Dimension(0,0);
          Vector v = this.getDiagramNodes();

          for (int ii = 0; ii < v.size(); ii++) {
              DiagramNode DN = (DiagramNode) (v.elementAt(ii));
              zoomer.zoom(DN);
              DN.resizeComponents();  // ticket #216: adapt size of the inner components of DN
              // System.out.println(DN + "\n");
              Rectangle b=DN.getBounds();
              if(b.x+b.width>max.width)
              	max.width=b.x+b.width;
              if(b.y+b.height>max.height)
              	max.height=b.y+b.height;
          }

          Vector ve = this.getDiagramEdges(false);
          for(int i =0; i<ve.size();i++){
          	DiagramEdge edge = (DiagramEdge)(ve.elementAt(i));
          	zoomer.zoom(edge);
          }


          Rectangle vr = zoomer.getZoomedViewportRect(viewport);
          boolean anyNodeContained = false;
          for(int i =0;i<v.size();i++){
          	DiagramNode DN = (DiagramNode) (v.elementAt(i));
          	if(vr.contains(DN.getCenter()))
          	{
          		anyNodeContained = true;
          		break;
          	}
          	if(!anyNodeContained&&i==v.size()-1){
          		vr.x = DN.getLocation().x;
          		vr.y = DN.getLocation().y;
          	}

          }
          if(anyNodeContained)
          {
          	if(vr.x+vr.width>max.width)
              	max.width= vr.x+vr.width;
              if(vr.y+vr.height>max.height)
              	max.height= vr.y+vr.height;
          }
          if(max.height<1500)
          	max.height=1500;
          if(max.width<1500)
          	max.width=1500;

          this.setPreferredSize(max);

          // resize graphInternalFrame only when this DiagramDesktop has a background image
          // that needs to adjust to the zoom factor
          if (backgroundImage != null && Math.abs(z-oldZ) > 0.01) {
             float f = z/oldZ;
             int gifwidth = (int)(f * graphInternalFrame.getWidth());
             int gifheight = (int)(f * graphInternalFrame.getHeight());
             graphInternalFrame.setSize(new Dimension(gifwidth,gifheight));
          }

          // the edge strokes of zoomed edges are misplaced from their edge heads; needs to be corrected
          // consequence of the changes of ticket #340
          if (Math.abs(z-1.0F) > 0.001F || Math.abs(z-oldZ) > 0.01) 
            this.redrawEdges();


          this.setEdited(true);
          //this.revalidate();
          this.repaint();
          ((JScrollPane)(this.getGraphInternalFrame().getContentPane())).validate();
          viewport.setViewPosition(new Point(vr.x,vr.y));
    }


    public void adjustContentPaneSize(){
    	Dimension dim = this.getSize();
    	Vector v = this.getDiagramNodes();
    	for (int i = 0; i < v.size(); i++) {
    		 DiagramNode DN = (DiagramNode) (v.elementAt(i));
    		  Rectangle b=DN.getBounds();
              if(b.x+b.width>dim.width)
              	dim.width=b.x+b.width;
              if(b.y+b.height>dim.height)
              	dim.height=b.y+b.height;
     	}
        if(dim.height<1500)
          	dim.height=1500;
        if(dim.width<1500)
          	dim.width=1500;
        this.setEdited(true);
    	this.setPreferredSize(dim);
    	this.getGraphInternalFrame().getContentPane().validate();
    }



    /**
     * computes the smallest rectangle that includes all nodes and edgens if this DiagramDesktop
     *
     * @return the clip rectangle to include the current diagram
     */

    private Rectangle getDiagramClipRectangle() {

        Vector vEdges = getDiagramEdges(false);
        Vector vNodes = getDiagramNodes();
//        ArrayList alOpaqueLabels = new ArrayList(vNodes.size());

        if (vNodes.size() == 0) {
            java.util.logging.Logger.getLogger("global")
                    .fine("DiagramDesktop.print: No DiagramNode on Desktop");
            return null;
        }

        Rectangle allBounds = ((DiagramNode) vNodes.elementAt(0)).getBounds();
        Rectangle currentBounds;
        for (int i = 0; i < vEdges.size(); i++) {
            currentBounds = ((DiagramEdge) vEdges.elementAt(i)).getBounds();
            if (currentBounds.x < allBounds.x) {
                allBounds.setBounds(currentBounds.x, allBounds.y,
                        allBounds.width + (allBounds.x - currentBounds.x),
                        allBounds.height);
            }
            if (currentBounds.y < allBounds.y) {
                allBounds.setBounds(allBounds.x, currentBounds.y,
                        allBounds.width, allBounds.height
                                + (allBounds.y - currentBounds.y));
            }
            if ((currentBounds.y + currentBounds.height) > allBounds.y
                    + allBounds.height) {
                allBounds.setBounds(allBounds.x, allBounds.y, allBounds.width,
                        (currentBounds.y + currentBounds.height) - allBounds.y);
            }
            if ((currentBounds.x + currentBounds.width) > allBounds.x
                    + allBounds.width) {
                allBounds.setBounds(allBounds.x, allBounds.y,
                        (currentBounds.x + currentBounds.width) - allBounds.x,
                        allBounds.height);
            }
        }

        for (int i = 0; i < vNodes.size(); i++) {
            DiagramNode dnCurrent = (DiagramNode) vNodes.elementAt(i);
            Component c = dnCurrent.getVisibleComponent();

            // Set all labels opaque to have a correct bufferedImage; only needed for old Java
/*
            if (DiagramNode.JAVA_VERSION <= 1.601101 && c != null && c instanceof JLabel) {
                JLabel jl = (JLabel) c;
                if (!jl.isOpaque() ) {  
                    jl.setOpaque(true);
                    alOpaqueLabels.add(jl);
                }
            }
*/
            currentBounds = dnCurrent.getBounds();
            if (currentBounds.x < allBounds.x) {
                allBounds.setBounds(currentBounds.x, allBounds.y,
                        allBounds.width + (allBounds.x - currentBounds.x),
                        allBounds.height);
            }
            if (currentBounds.y < allBounds.y) {
                allBounds.setBounds(allBounds.x, currentBounds.y,
                        allBounds.width, allBounds.height
                                + (allBounds.y - currentBounds.y));
            }
            if ((currentBounds.y + currentBounds.height) > allBounds.y
                    + allBounds.height) {
                allBounds.setBounds(allBounds.x, allBounds.y, allBounds.width,
                        (currentBounds.y + currentBounds.height) - allBounds.y);
            }
            if ((currentBounds.x + currentBounds.width) > allBounds.x
                    + allBounds.width) {
                allBounds.setBounds(allBounds.x, allBounds.y,
                        (currentBounds.x + currentBounds.width) - allBounds.x,
                        allBounds.height);
            }
        }

        if (allBounds.x < 0) {
            allBounds.width = allBounds.width + allBounds.x;
            allBounds.x = 0;

        }
        if (allBounds.y < 0) {
            allBounds.height = allBounds.height + allBounds.y;
            allBounds.y = 0;
        }

        // add 2 extra pixel on all sides of the allBound rectangle avoid nodes to touch its borders
        if (allBounds.x > 0) {
            allBounds.width = allBounds.width + 4;
            allBounds.x = allBounds.x - 2;
        }
        if (allBounds.y > 0) {
            allBounds.height = allBounds.height + 4;
            allBounds.y = allBounds.y - 2;
        }

        BufferedImage offScreen = new java.awt.image.BufferedImage(
                getSize().width, getSize().height,
                java.awt.image.BufferedImage.TYPE_INT_RGB);

        if (allBounds.x+allBounds.width > offScreen.getWidth()) {
          allBounds.width = offScreen.getWidth() - allBounds.x;
        }
        if (allBounds.y+allBounds.height > offScreen.getHeight()) {
          allBounds.height = offScreen.getHeight() - allBounds.y;
        }
        if (allBounds.x < 0) {
          allBounds.x = 0;
        }
        if (allBounds.y < 0) {
          allBounds.y = 0;
        }

        return allBounds;

    }


    /**
     * Creates a screenshot of this diagramDesktop and returns it
     *
     * @return a BufferedImage containing a screenshot of this desktop
     */
    private BufferedImage getImageOfDesktop() {

        Rectangle allBounds = getDiagramClipRectangle();

        if (allBounds == null) 
          return null;

        BufferedImage offScreen = new java.awt.image.BufferedImage(
                getSize().width, getSize().height,
                java.awt.image.BufferedImage.TYPE_INT_RGB);

        Graphics2D offScreenGraphics = offScreen.createGraphics();

        this.paint(offScreenGraphics);

        BufferedImage subimage = offScreen.getSubimage(allBounds.x, allBounds.y, allBounds.width,
                allBounds.height);
        // return scaleImage(subimage,2.0); // return a magnified version of the image
        return subimage;  // return a non-magnified version of the image

    } //getImageOfDesktop




    // scale the image for better readability
    // inspired by https://stackoverflow.com/questions/4216123/how-to-scale-a-bufferedimage
    private BufferedImage scaleImage(BufferedImage img, double scale) {
       int imgWidth = img.getWidth();
       int imgHeight = img.getHeight();
       int width = (int)(imgWidth*scale);
       int height = (int)(imgHeight*scale);
       BufferedImage newImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
       Graphics2D g = newImage.createGraphics();
       try {
           g.setRenderingHint(RenderingHints.KEY_INTERPOLATION,
                   RenderingHints.VALUE_INTERPOLATION_BICUBIC);
           //g.setBackground(img.getBackground());
           g.clearRect(0, 0, width, height);
           g.drawImage(img, 0, 0, width, height, null);
       } finally {
           g.dispose();
       }
       return newImage;
   }


    /**
     * Prints this diagramDesktop
     *
     * @param printGraphics
     *            Description of the Parameter
     * @param pageFormat
     *            Description of the Parameter
     * @param pageIndex
     *            Description of the Parameter
     * @return Description of the Return Value
     * @exception PrinterException
     *                Description of the Exception
     */
    public int print(Graphics printGraphics, PageFormat pageFormat,
            int pageIndex) throws PrinterException {
        if (pageIndex >= 1) {
            return Printable.NO_SUCH_PAGE;
        }

        BufferedImage offScreen = getImageOfDesktop();
        if (offScreen == null) {
            return Printable.NO_SUCH_PAGE;
        }

        double imgX = pageFormat.getImageableX();
        double imgY = pageFormat.getImageableY();

        double imgWidth = pageFormat.getImageableWidth();
        double imgHeight = pageFormat.getImageableHeight();

        double offScreenHeight = (double) offScreen.getHeight();
        double offScreenWidth = (double) offScreen.getWidth();

        double ratio = offScreenWidth / offScreenHeight;

        AffineTransform af;

        if ((imgWidth < offScreenWidth) || (imgHeight < offScreenHeight)) {

            if ((imgWidth / offScreenWidth) < (imgHeight / offScreenHeight)) {
                af = AffineTransform.getScaleInstance(
                        imgWidth / offScreenWidth, imgWidth / offScreenWidth
                                * (1 / ratio));
            } else {
                af = AffineTransform.getScaleInstance(imgHeight
                        / offScreenHeight * ratio, imgHeight / offScreenHeight);
            }
        } else {
            af = new AffineTransform();
        }
        AffineTransformOp op = new AffineTransformOp(af,
                AffineTransformOp.TYPE_BILINEAR);

        ((Graphics2D) printGraphics).drawImage(offScreen, op, (int) imgX,
                (int) imgY);
        return Printable.PAGE_EXISTS;
    } //print




    /**
     * True if a node is selected.
     *
     * @param dn
     *            the node we want to know about
     * @return true if the node is selected on this desktop 
     */

    public boolean isSelectedNode(DiagramNode dn) {
        return m_cSelectedNodes.contains(dn);
    }


    /**
     * True if a node and at least one other node are selected.
     *
     * @param dn
     *            the node we want to know about
     * @return true if the node is selected on this desktop and if he is not the
     *         only selected one
     */

    public boolean isInSelectedGroup(DiagramNode dn) {
        return ( m_cSelectedNodes.size() > 1 && m_cSelectedNodes.contains(dn) );
    }

    /**
     * Sets a certain {@link i5.cb.graph.diagram.DiagramNode}to be treated as
     * selected or not. A node will be shown with a rectangular frame around it
     * if it is selected.
     *
     * @param node
     *            a <code>DiagramNode</code> value
     * @param bIsSelected
     *            a <code>boolean</code> value
     * @param bIsLeftClick
     *            a <code>boolean</code> value
     */
    public void setNodeSelected(DiagramNode node, boolean bIsSelected, boolean bIsLeftClick) {

        assert (this.getDiagramNodes().contains(node)) : "DiagramDesktop.setNodeSelected: '"
                + node.getUserObject().toString()
                + "' must be inside this DiagramDesktop";

	getGraphEditor().setStatusStringDelayed("");  // clear the last status message if it is old enough
        if (bIsSelected) {
            if (m_cSelectedNodes.size() == 0)  // first node selected
              setSquareDots(true);  // set little square dots on edges opaque
            m_cSelectedNodes.add(node);  // since m_cSelectedNodes is a HashSet, duplicates are avoided, nissue #15
            if (!node.isSelected()) {
                this.setLayer(node, NODE_LAYER.intValue()+node.getNodeLevel(), 0);
            }
            if (i5.cb.CBConfiguration.isNodeLevelAware() && bIsLeftClick
                && bIsSelected && node.getNodeLevel() < 0) {
               selectContainedNodes(node);   // ticket #371: automagically add the nodes contained in 'node'
            }
        } else {
            m_cSelectedNodes.remove(node);
        }
        if (propertyChangeSupport != null)
            propertyChangeSupport.firePropertyChange("selected", null,
                    m_cSelectedNodes);
        //node.setSelected(bIsSelected);
        repaint();
    } //setNodeSelected


    // 2-arg version of setNodeSelected for legacy support
    public void setNodeSelected(DiagramNode node, boolean bIsSelected) {
        setNodeSelected(node,bIsSelected, true);
    }



    /**
     * Unselects all nodes that might be selected.
     */
    public void clearSelectedNodes() {

	getGraphEditor().setStatusStringDelayed("");  // clear the last status message if it is old enough
        m_cSelectedNodes.clear();
        setSquareDots(false);  // set little square dots on edges transparent
        repaint();

    } //clearSelectedNodes

    /**
     * Selects all nodes of this DiagramDesktop in selection mode 'new'.
     */
    public void selectAll() {
        selectNodes(getDiagramNodes(), SELECTION_MODE_NEW);
    }

    /**
     * Selects all nodes of this DiagramDesktop, that are not on an edge, in
     * selection mode 'new'.
     */
    public void selectAllNodes() {
        // selects all proper nodes, i.e. without nodes on edges
        selectNodes(getProperDiagramNodes(), SELECTION_MODE_NEW);
    }

    /**
     * Selects all nodes of this DiagramDesktop that are geometrically contained
     * in cnode; cnode is a diagram node with nodelevel below 0, hence used as a graphical container
     */
    public void selectContainedNodes(DiagramNode cnode) {
        // selects all proper nodes, i.e. without nodes on edges
        selectNodes(getContainedDiagramNodes(cnode), SELECTION_MODE_ADD);
    }

    /**
     * Selects all node on the edges of this DiagramDesktop in selection mode
     * 'new'.
     */
    public void selectAllEdges() {
        selectNodes(getDiagramEdges(true), SELECTION_MODE_NEW);
    }

    /**
     * Actualizes the current selection according to the specified selection
     * mode. See the constants defined above. For Type Integrity the ddNodes
     * Vector should be replaced by an array of DiagramNodes
     *
     * @param ddNodes
     *            the Nodes to be handled.
     * @param mode
     *            see the constants above for selection mode description
     */
    private void selectNodes(Vector ddNodes, int mode) {
        Iterator ddNodesW = ddNodes.iterator();
        DiagramNode currentNode;
        if (mode == SELECTION_MODE_ADD) {
            while (ddNodesW.hasNext()) {
                currentNode = (DiagramNode) ddNodesW.next();
                setNodeSelected(currentNode, true);
            }
            //while(markedNodesW.hasNext() )
        } else if (mode == SELECTION_MODE_SWITCH) {
            while (ddNodesW.hasNext()) {
                currentNode = (DiagramNode) ddNodesW.next();
                boolean select = !currentNode.isSelected();
                // selection shall be inverted
                setNodeSelected(currentNode, select);
            }
            //while(markedNodesW.hasNext() )
        } else {
            clearSelectedNodes();
            while (ddNodesW.hasNext()) {
                currentNode = (DiagramNode) ddNodesW.next();
                setNodeSelected(currentNode, true);
            }
            //while(markedNodesW.hasNext() )
        }
        repaint();
    } //selectNodes

    /**
     * Gets the selectedNodes attribute of the DiagramDesktop object
     *
     * @return The selectedNodes value
     */
    public Collection getSelectedNodes() {
        return m_cSelectedNodes;
    }

    public void propertyChange(PropertyChangeEvent evt) {

        String sPropertyName = evt.getPropertyName();

        //java.util.logging.Logger.getLogger("global").fine("DiagramDesktop.propertyChange:
        // "+sPropertyName);

        //If a node got an edge after he was added to the desktop, the edge is
        // also added here
        if (sPropertyName.equals("diagramEdge")) {
            //java.util.logging.Logger.getLogger("global").fine("DiagramDesktop.propertyChange:
            // diagramEdge; node: "+( (DiagramNode)evt.getSource()
            // ).getUserObject() );
            super.add(((DiagramNode) evt.getSource()).getDiagramEdge(),
                    EDGE_LAYER);
            ((DiagramNode) evt.getSource()).getDiagramEdge().setDiagramDesktop(
                    this);
        }

        //if a node was dragged around we check whether it is still inside the
        // desktop
        if (sPropertyName.equals("location")) {
            correctLocation((DiagramNode) evt.getSource());
        }

        //if the node was switched to componentview, it is made sure that no
        // other node covers it
        if (sPropertyName.equals("componentVisible")) {
            DiagramNode dn = (DiagramNode) evt.getSource();
            if (((Boolean) evt.getNewValue()).booleanValue() == true) {
                //java.util.logging.Logger.getLogger("global").fine("DiagramDesktop.propertyChange:
                // repaint.");
                this.setLayer(dn, NODE_LAYER.intValue()+dn.getNodeLevel(), 0);
                //this.repaint();
            }
//            correctLocation((DiagramNode) evt.getSource());
           zoomer.zoomSize(dn);
          // correctLocation(dn);

        }

        if (sPropertyName.equals("valid")) {
            if (((Boolean) evt.getNewValue()).booleanValue() == true) {
                m_cInvalidNodes.remove((DiagramNode) evt.getSource());
                java.util.logging.Logger.getLogger("global").fine("Removing node '"
                        + ((DiagramNode) evt.getSource()).getUserObject()
                        + "' from invalidnodes");
            } else {
                m_cInvalidNodes.add((DiagramNode) evt.getSource());
                java.util.logging.Logger.getLogger("global").fine("Adding node '"
                        + ((DiagramNode) evt.getSource()).getUserObject()
                        + "' to invalidnodes");
                if (m_sInvalidNodesMethod
                        .equals(i5.cb.CBConfiguration.VALUE_REMOVE)) {
                    removeInvalidNodes();
                }
            }
        }
        this.setEdited(true);
        this.repaint();
    } //propertyChange

    public void addPropertyChangeListener(String prop,
            java.beans.PropertyChangeListener l) {
        if (propertyChangeSupport == null) {
            propertyChangeSupport = new java.beans.PropertyChangeSupport(this);
        }
        propertyChangeSupport.addPropertyChangeListener(prop, l);
    }

    /**
     * Adds a PropertyChangeListener to the listener list.
     *
     * @param l
     *            The listener to add.
     */
    public void addPropertyChangeListener(java.beans.PropertyChangeListener l) {
        if (propertyChangeSupport == null) {
            propertyChangeSupport = new java.beans.PropertyChangeSupport(this);
        }
        propertyChangeSupport.addPropertyChangeListener(l);
    }

    /**
     * Removes a PropertyChangeListener from the listener list.
     *
     * @param l
     *            The listener to remove.
     */
    public void removePropertyChangeListener(java.beans.PropertyChangeListener l) {
        propertyChangeSupport.removePropertyChangeListener(l);
    }

    /**
     * Removes a PropertyChangeListener from the listener list for the given
     * property.
     *
     * @param prop
     *            the property
     * @param l
     *            The listener to remove.
     */
    public void removePropertyChangeListener(String prop,
            java.beans.PropertyChangeListener l) {
        propertyChangeSupport.removePropertyChangeListener(prop, l);
    }

    public void setInvalidNodesMethod(String method) {
        m_sInvalidNodesMethod = method;
        //java.util.logging.Logger.getLogger("global").fine("Value of m_sInvalidNodesMethod:
        // "+m_sInvalidNodesMethod);
        if (method.equals(i5.cb.CBConfiguration.VALUE_REMOVE)) {
            removeInvalidNodes();
        }
        this.setEdited(true);
        this.repaint();
    }

    public boolean useSmoothLines() {
      return bUseSmoothLines;
    }

    public void setUseSmoothLines(boolean newUseSmoothLines) {
      bUseSmoothLines = newUseSmoothLines;
    }

    public DiagramDesktopGLayouter getLayouter() {
        return m_gLayout;
    }

    /** 
    Expand a relative image filename to its absolute form. In particular check whether the image
    is locally stored in the CBICONS subdirectory of CB_HOME.
    */
    public static String getImageUrl(String imageFilename) {
        String result = imageFilename; // default
        // http://conceptbase.sourceforge.net/CBICONS/ is no longer served by SourceForge as of September 2022
        // so we try the relative path to the local CBICONS directory
        if (imageFilename.startsWith("http://conceptbase.sourceforge.net/CBICONS/")) {
          // remove the http address and only keep the relative path
          imageFilename = imageFilename.replaceFirst("http://conceptbase.sourceforge.net/CBICONS/","");  
        }
        try {
           if (!imageFilename.startsWith("http://") && !imageFilename.startsWith("file://")) {  // no replacement done for absolute file names
              String sCB_HOME=System.getProperty("CB_HOME", "");
              boolean bWindows = (System.getProperty("os.name").indexOf("Windows") >= 0);
              if (new java.io.File(sCB_HOME + "/CBICONS/"  + imageFilename).exists()) {
                 if (bWindows) {  // Windows local file URLs are a bit different
                   result = "file:///" + sCB_HOME.replace('\\','/') + "/CBICONS/" + imageFilename;
                 } else {
                    result = "file://" + sCB_HOME + "/CBICONS/" + imageFilename;
                 }
              } else 
                 result = imageFilename;  // was originally the http path at SourceForge but this is no longer served as they switched to https
           }
        } catch (Exception e) { // any exception may occur, since we have the default result
           System.err.println("DiagramDesktop: Image file " + imageFilename + " could not be loaded.");
        }  
        return result;
    }

    /**
     * @param imageFilename
     *            the filename of the image (gif,png,jpg) 
     */
    public void setBackgroundImage(String imageFilename) {


      if (imageFilename == null) {
        // if imageUrl is null then we disable the previous backgroundImage
        this.backgroundImage = null;  
        return;
      }

      String  imageUrl = getImageUrl(imageFilename);

      try {

        this.backgroundImage = ImageIO.read(new URL(imageUrl));

        int width = backgroundImage.getWidth();
        int height = backgroundImage.getHeight();

        Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
        double screenwidth = screenSize.getWidth();
        double screenheight = screenSize.getHeight();

        //   adapt the window sizes to the size of the background image if there is room on the screen
        if (width < 0.75*screenwidth && height < 0.75*screenheight && height < screenheight-200) {
           graphInternalFrame.setSize(width+26, height+52);   // adapt size of the frame that contains this desktop
           GraphEditor editor = graphInternalFrame.getGraphEditor();
           if (editor != null && (editor.countGIFs()==1 ||
                                  editor.getWidth() < width+36 &&  editor.getHeight() < height+182
                                 )
              )
             editor.setSize(width+36, height+182);
        }

        repaint();
      } catch (IOException ex) {  // could fail, e.g. when the file does not exist
         System.err.println("Image file " + imageUrl + " could not be loaded.");
      }



    }

    // get the background color at Point p in the diagram desktop drawing area
    // dobj is the Diagram object the point is linked to; this is used  
    // to determine whether dobj is contained in another DiagramObject (via nodelevel)
    // In such cases the background color is the color of the container DiagramObject
    public Color getBackgroundColorAt(Point p, DiagramObject dobj) {
       try {
          DiagramNode cn = null;
          if (dobj != null)
             cn = getContainerNode(dobj.getNode());
          if (cn != null) {
            Component c = cn.getVisibleComponent(); // the visible component of node cn
            return c.getBackground();
          } else if (this.backgroundImage == null) {
            return this.getBackground();
          } else {
             //ddwith,ddheight are the size of the diagram desktop drawing area
             double ddwidth = graphInternalFrame.getWidth()  - 26; 
             double ddheight = graphInternalFrame.getHeight()  - 52;
             //imgwith,imgheight are the size of original background image
             double imgwidth = this.backgroundImage.getWidth();
             double imgheight = this.backgroundImage.getHeight();
             // translate the point to the cooordinates of the original image
             int x = (int) (p.x * imgwidth / ddwidth);
             int y = (int) (p.y * imgheight / ddheight);
             // fetch the pixel at x,y
             int pixel = this.backgroundImage.getRGB(x,y);
             int red = (pixel >> 16) & 0xff;
             int green = (pixel >> 8) & 0xff;
             int blue = (pixel) & 0xff;
             int alpha = (pixel >> 24) & 0xff;
             return new Color(red,green,blue,alpha);
          }
       } catch (Exception e) {
          return Color.white;
       }
    }



    /**
     * Validate the positions of all edges on this diagram desktop;
     * they may be incorrect after moving a node whose links have links themselves
     *
     */

    public void validateEdges() {
        Vector vEdges = getDiagramEdges(false);
        int eSize = vEdges.size();
        DiagramEdge currentEdge;
        for (int i = 0; i < eSize; i++) {
           currentEdge = (DiagramEdge) vEdges.elementAt(i);
           currentEdge.validateEdge();
        }
    }


    /**
     * Redraw all edges of this DiagramDesktop
     *
     */

    public void redrawEdges() {
        Vector vEdges = getDiagramEdges(false);
        int eSize = vEdges.size();
        DiagramEdge currentEdge;
        for (int i = 0; i < eSize; i++) {
           currentEdge = (DiagramEdge) vEdges.elementAt(i);
           currentEdge.redrawEdge();  
        }
    }


     /**
     * Straighten all edges that are incident to dn
     *
     */
    
    public void setEdgesStraight(DiagramNode dn) {
        Vector vEdges = getIncidentDiagramEdges((DiagramObject)dn);
        int eSize = vEdges.size();
        DiagramEdge currentEdge;
        for (int i = 0; i < eSize; i++) {
           currentEdge = (DiagramEdge) vEdges.elementAt(i);
           currentEdge.straightenEdge();
        }
        this.setEdited(true);
        this.repaint();
    }

     /**
     * Freeze / Unfreeze a diagram node's position
     *
     */
    
    public void toggleFrozen(DiagramNode dn) {
        dn.setFrozen(!dn.isFrozen());
        // System.out.println("Freeze "+dn.getLabel()+": "+dn.isFrozen());
    }

     /**
     * Control whether the square dot symbolizing the node on an edge with empty labels shall be visible;
     * initially such square dots are not visible (opaque=false). When a node is selected on the diagram
     * desktop then the square dots are made visible; when no more nodes are selected (e.g. by clicking
     * in the background) then the square dots are made invisible
     *
     */

    public void setSquareDots(boolean visible) {
        Vector vNodes = getDiagramEdges(true);  // gets the nodes on the edges
        int nSize = vNodes.size();
        DiagramNode currentNode;
        for (int i = 0; i < nSize; i++) {
           currentNode = (DiagramNode) vNodes.elementAt(i);
           currentNode.setSquareDot(visible);
        }
    }


     /**
     * True if the graph in this diagram desktop has been edited, e.g. by adding, removing, or moving objects
     *
     */
    public boolean isEdited() {
      return m_isEdited;
    }


     /**
     * Set edited status of this diagram desktop. Used for deciding whether the content has to be saved in a
     * graph file
     *
     */
    public void setEdited(boolean newvalue) {
      if (m_isEdited != newvalue) {
        m_isEdited = newvalue;
        CBFrame cbf= null;
        if (graphInternalFrame instanceof CBFrame)
          cbf = (CBFrame)graphInternalFrame; 
        if (cbf != null)
          cbf.setFrameTitle();
      }
    }


     /**
     * True if the method saveScreenShot is currently active; controls the way how node shapes are painted
     *
     */
    public boolean isScreenshotTaken() {
      return m_ScreenshotTaken;
    }


    /**
     * This inner class enables a user to mark more than one node as selected at
     * at a time. The user can draw a rectangle on the {@link DiagramDesktop}by
     * dragging with their mouse. Afterwords, every
     * {@link i5.cb.graph.diagram.DiagramNode} being completely inside the
     * rectange is selected.
     *
     * @author schoeneb
     * -created 08 March 2002
     */
    public class DDMouseListener extends MouseInputAdapter implements
            Serializable {

        private Rectangle selectionRect = null;

        private int dragStartX;

        private int dragStartY;

        public DDMouseListener() {
            super();
        }

        /**
         * This method is envoked when a user presses a mousebotton while the
         * mousepointer is over the {@link DiagramDesktop}, but not over a
         * {@link i5.cb.graph.diagram.DiagramNode}. It stores one egde of the
         * rectangle.
         *
         * @param e
         *            a <code>MouseEvent</code> value
         */
        public void mousePressed(MouseEvent e) {

            dragStartX = e.getX();
            dragStartY = e.getY();
            selectionRect = new Rectangle();

        } //mousePressed

        /**
         * This method is invoked when a user moves the mouse while a
         * mousebutton (invocing {@link #mousePressed}) was pressed. It
         * recalculates {@link #selectionRect}and has it drawn by {@link
         * DiagramDesktop}
         *
         * @param e
         *            a <code>MouseEvent</code> value
         */
        public void mouseDragged(MouseEvent e) {
            int rLocX;
            int rLocY;
            int rDimW;
            int rDimH;



            if (e.getX() < dragStartX) {
                rLocX = e.getX();
                rDimW = dragStartX - e.getX();
            }
            // end of if (e.getX < dragStartX)
            else {
                rLocX = dragStartX;
                rDimW = e.getX() - dragStartX;
            }
            // end of else

            if (e.getY() < dragStartY) {
                rLocY = e.getY();
                rDimH = dragStartY - e.getY();
            }
            // end of if
            else {
                rLocY = dragStartY;
                rDimH = e.getY() - dragStartY;
            }
            // end of else
            if (selectionRect != null) {
                selectionRect.x = rLocX;
                selectionRect.y = rLocY;
                selectionRect.width = rDimW;
                selectionRect.height = rDimH;
            }
            repaint();
        }

        /**
         * This method is invoked when a user releases a mousebutton after
         * dragging it over the {@link DiagramDesktop}. In normal selection mode
         * it clears the collection of selected nodes and sets those to be
         * selected that are inside {@link #selectionRect}. If Control is
         * pressed, it inverts the selection status of every node inside
         * {@link #selectionRect}.
         *
         * @param e
         *            a <code>MouseEvent</code> value
         */
        public void mouseReleased(MouseEvent e) {
            Vector ddNodes = getDiagramNodes();
            DiagramNode currentNode;
            int mode;

            for (int i = ddNodes.size() - 1; i >= 0; i--) {
                currentNode = (DiagramNode) ddNodes.elementAt(i);
                if (selectionRect != null
                        && !selectionRect.contains(currentNode.getBounds())) {
                    ddNodes.remove(currentNode);
                }
            }
            if (e.isShiftDown()) {
                mode = SELECTION_MODE_ADD;
            } else if (e.isControlDown()) {
                mode = SELECTION_MODE_SWITCH;
            } else {
                mode = SELECTION_MODE_NEW;
            }
            selectNodes(ddNodes, mode);
            selectionRect = null;
            repaint();

        }

        /**
         * Getter for property dragStartX.
         *
         * @return Value of property dragStartX.
         */
        public int getDragStartX() {
            return dragStartX;
        }

        /**
         * Setter for property dragStartX.
         *
         * @param dragStartX
         *            New value of property dragStartX.
         */
        public void setDragStartX(int dragStartX) {
            this.dragStartX = dragStartX;
        }

        /**
         * Getter for property dragStartY.
         *
         * @return Value of property dragStartY.
         */
        public int getDragStartY() {
            return dragStartY;
        }

        /**
         * Setter for property dragStartY.
         *
         * @param dragStartY
         *            New value of property dragStartY.
         */
        public void setDragStartY(int dragStartY) {
            this.dragStartY = dragStartY;
        }

        /**
         * Getter for property selectionRect.
         *
         * @return Value of property selectionRect.
         */
        public java.awt.Rectangle getSelectionRect() {
            return selectionRect;
        }

        /**
         * Setter for property selectionRect.
         *
         * @param selectionRect
         *            New value of property selectionRect.
         */
        public void setSelectionRect(java.awt.Rectangle selectionRect) {
            this.selectionRect = selectionRect;
        }

        //mouseReleased

    }
    //DDMouseListener

}

