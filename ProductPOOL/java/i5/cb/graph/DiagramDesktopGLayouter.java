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
 * Created on 2004-11-13
 *
 */
package i5.cb.graph;

import i5.cb.graph.cbeditor.CBUserObject;
import i5.cb.graph.diagram.DiagramEdge;
import i5.cb.graph.diagram.DiagramNode;
import i5.cb.graph.layout.LayoutGraph;
import i5.cb.graph.layout.Layouter;
import i5.cb.telos.object.Attribute;

import java.awt.Point;
import java.util.*;

import att.grappa.*;

/**
 * This class is responsible for calculating the layout of the graph.
 * Incremental updating is supported.
 *
 * This class depends on "grappa" library. It uses grappa's graph data structure
 * to store and manipulate the underline graph on the DiagramDestop.
 *
 * @author Li, Yong
 *
 * @version 1.0
 */
public class DiagramDesktopGLayouter {
    /**
     * default graph name
     */
    public static final String GRAPH_NAME = "@CBGraph";

    /**
     * backup garph name
     */
    public static final String BACKUP_NAME = "@CBBackup";

    /**
     * abstract graph data structure
     */
    private LayoutGraph m_gGraph;

    /**
     * backup graph for undo operation
     */
    private LayoutGraph m_gBackup;

    /**
     * layouter
     */
    private Layouter m_layouter;

    /**
     * enable or disable the layouter
     */
    private boolean m_enable = false;

    public DiagramDesktopGLayouter() {
        m_gGraph = new LayoutGraph(GRAPH_NAME);
        m_gBackup = new LayoutGraph(BACKUP_NAME);
        m_layouter = new Layouter(m_gGraph);
    }

    /**
     * Add one abstract node into the graph
     *
     * @param node
     *            The DiagramNode to be added to the desktop
     */
    public void addNode(DiagramNode node) {
        // get node's label
        String label = ((CBUserObject) node.getUserObject()).getTelosObject()
                .toString();
        // search for existing nodes to avoid duplicate
        if (m_gGraph.findNodeByName(label) != null)
            return;

        // create one new node
        Node newNode = new Node(m_gGraph, label);
        newNode.setAttribute(LayoutGraph.NODE_RANK, new Integer(0));
        newNode.setAttribute(LayoutGraph.NODE_PRERANK, new Integer(0));
        newNode.setAttribute(LayoutGraph.NODE_ORDER, new Integer(-1));
        newNode.setAttribute(LayoutGraph.NODE_WIDTH,
                new Double(node.getWidth()));
        newNode.setAttribute(LayoutGraph.NODE_HEIGHT, new Double(node
                .getHeight()));
        newNode.setAttribute(LayoutGraph.NODE_POSITION, new GrappaPoint(node
                .getCenter().x, node.getCenter().y));
        newNode.setAttribute(LayoutGraph.NODE_FIXED, Boolean.FALSE);
        newNode.setAttribute(LayoutGraph.NODE_DUMMY, Boolean.FALSE);
        newNode.setAttribute(LayoutGraph.NODE_NEW, Boolean.TRUE);
        newNode.setAttribute(LayoutGraph.DIAGRAM_OBJECT, node);
        if(Collections.list(m_gGraph.nodeElements()).size()==1)
        	newNode.setAttribute(LayoutGraph.IS_NODE_SHOWN,Boolean.FALSE);
        else
        	newNode.setAttribute(LayoutGraph.IS_NODE_SHOWN,Boolean.TRUE);

    }

    /**
     * Add one abstract edge into the graph.
     *
     * @param edge
     *            The DiagramEdge to be added
     */
    public void addEdge(DiagramEdge edge) {
        DiagramNode src = edge.getSource().getNode();
        DiagramNode des = edge.getDestination().getNode();

        // based on the structure of DiagramDesktop
        // the src and des should have already been
        // in m_gGraph, search for them
        String srcLabel = ((CBUserObject) src.getUserObject()).getTelosObject()
                .toString();
        String desLabel = ((CBUserObject) des.getUserObject()).getTelosObject()
                .toString();
        Node srcNode = m_gGraph.findNodeByName(srcLabel);
        Node desNode = m_gGraph.findNodeByName(desLabel);

        if (((CBUserObject) edge.getNode().getUserObject()).getTelosObject() instanceof Attribute) {
            Edge newEdge = new Edge(m_gGraph, srcNode, desNode);
            newEdge.setAttribute(LayoutGraph.DIAGRAM_OBJECT, edge);
            newEdge.setAttribute(LayoutGraph.EDGE_NEW, Boolean.TRUE);
            newEdge.setAttribute(LayoutGraph.EDGE_CHAIN, new ArrayList());
            newEdge.setAttribute(LayoutGraph.EDGE_DUMMY, Boolean.FALSE);
        } else {
            // reverse the edge in abstract graph
            // thus, the subclass or the instance
            // is the child of superclass or class
            Edge newEdge = new Edge(m_gGraph, desNode, srcNode);
            newEdge.setAttribute(LayoutGraph.DIAGRAM_OBJECT, edge);
            newEdge.setAttribute(LayoutGraph.EDGE_NEW, Boolean.TRUE);
            newEdge.setAttribute(LayoutGraph.EDGE_CHAIN, new ArrayList());
            newEdge.setAttribute(LayoutGraph.EDGE_DUMMY, Boolean.FALSE);
        }
        addNode(edge.getNodeOnEdge());
    }

    /**
     * Remove the node and all its connecting edges from the graph
     *
     * @param node
     *            The node to be removed
     */
    public void removeNode(DiagramNode node) {
        String label = ((CBUserObject) node.getUserObject()).getTelosObject()
                .toString();
        m_gGraph.findNodeByName(label).delete();
    }

    /**
     * Remove the edge from the graph
     *
     * @param edge
     *            The edge to be removed
     */
    public void removeEdge(DiagramEdge edge) {
        for (Enumeration ee = m_gGraph.edgeElements(); ee.hasMoreElements();) {
            Edge ce = (Edge) ee.nextElement();
            if (ce.getAttributeValue(LayoutGraph.DIAGRAM_OBJECT) == edge) {
                ce.delete();
                return;
            }
        }
    }
    public void doLayout(){
    	 m_layouter.doIncrementalLayout();

         Enumeration nodes = m_gGraph.nodeElements();
         while (nodes.hasMoreElements()) {
             Node node = (Node) nodes.nextElement();
             DiagramNode dn = (DiagramNode) node
                     .getAttributeValue(LayoutGraph.DIAGRAM_OBJECT);
             int x = (int) node.getCenterPoint().x;
             int y = (int) node.getCenterPoint().y;
             dn.setCenterDirectly(x,y);
         }

         Enumeration edges = m_gGraph.edgeElements();
         while (edges.hasMoreElements()) {
             Edge edge = (Edge) edges.nextElement();
             DiagramEdge de = (DiagramEdge) edge
                     .getAttributeValue(LayoutGraph.DIAGRAM_OBJECT);
             List path = (List) edge.getAttributeValue(LayoutGraph.EDGE_PATH);
             Point p = new Point((Point) path.get(path.size() / 2));
             if (path.size() % 2 == 0) {
                 Point p2 = (Point) path.get(path.size() / 2 - 1);
                 p.x = (p.x + p2.x) / 2;
                 p.y = (p.y + p2.y) / 2;
             }
             de.getNode().setCenterDirectly(p.x,p.y);

         }

    }
    public void doIncrementalLayout() {
        if (!m_enable) {
            return;
        }
        doLayout();
    }

    /**
     * @param enable
     *            The m_enable of the layouter to set.
     */
    public void setEnable(boolean enable) {
        this.m_enable = enable;
    }

    /**
     * @return whether layouter is enabled
     */
    public boolean getEnable() {
        return m_enable;
    }

    /**
     * backup the main graph
     */
    public void backup() {
        // clear the old backup
        Enumeration ee = m_gBackup.edgeElements();
        while (ee.hasMoreElements()) {
            ((Edge) ee.nextElement()).delete();
        }
        Enumeration en = m_gBackup.nodeElements();
        while (en.hasMoreElements()) {
            ((Node) en.nextElement()).delete();
        }


        // make backup
        Enumeration nodes = m_gGraph.nodeElements();
        while (nodes.hasMoreElements()) {
            Node node = (Node) nodes.nextElement();
            Node bn = new Node(m_gBackup, node.getName());
            bn.setAttribute(LayoutGraph.NODE_FIXED, node
                    .getAttributeValue(LayoutGraph.NODE_FIXED));
            bn.setAttribute(LayoutGraph.NODE_NEW, node
                    .getAttributeValue(LayoutGraph.NODE_FIXED));
            bn.setAttribute(LayoutGraph.NODE_ORDER, new Integer(((Integer) node
                    .getAttributeValue(LayoutGraph.NODE_ORDER)).intValue()));
            bn.setAttribute(LayoutGraph.NODE_PRERANK,
                    new Integer(((Integer) node
                            .getAttributeValue(LayoutGraph.NODE_PRERANK))
                            .intValue()));
            bn.setAttribute(LayoutGraph.NODE_RANK, new Integer(((Integer) node
                    .getAttributeValue(LayoutGraph.NODE_RANK)).intValue()));
            bn.setAttribute(LayoutGraph.NODE_POSITION, node.getCenterPoint());
        }

        Enumeration edges = m_gGraph.edgeElements();
        while (edges.hasMoreElements()) {
            Edge edge = (Edge) edges.nextElement();
            String hn = edge.getHead().getName();
            String tn = edge.getTail().getName();
            Edge be = new Edge(m_gBackup, m_gBackup.findNodeByName(tn),
                    m_gBackup.findNodeByName(hn), edge.getName());
            be.setAttribute(LayoutGraph.EDGE_NEW, edge
                    .getAttributeValue(LayoutGraph.EDGE_NEW));
            List path = (List) edge.getAttributeValue(LayoutGraph.EDGE_PATH);
            List np = Collections.synchronizedList(new ArrayList());
            if (path == null) {
                np.add(new Point((int) edge.getTail().getCenterPoint().x,
                        (int) edge.getTail().getCenterPoint().y));
                np.add(new Point((int) edge.getHead().getCenterPoint().x,
                        (int) edge.getHead().getCenterPoint().y));
            } else {
                np.addAll(path);
            }
            be.setAttribute(LayoutGraph.EDGE_PATH, np);
        }
    }

    /**
     * restore the main graph using backup graph
     */
    public void undo() {
        // restore abstract graph
        Enumeration nodes = m_gGraph.nodeElements();
        while (nodes.hasMoreElements()) {
            Node node = (Node) nodes.nextElement();
            Node bn = m_gBackup.findNodeByName(node.getName());
            if(bn!=null) {
                node.setAttribute(LayoutGraph.NODE_FIXED, bn
                                  .getAttributeValue(LayoutGraph.NODE_FIXED));
                node.setAttribute(LayoutGraph.NODE_NEW, bn
                                  .getAttributeValue(LayoutGraph.NODE_FIXED));
                node.setAttribute(LayoutGraph.NODE_ORDER, new Integer(((Integer) bn
                    .getAttributeValue(LayoutGraph.NODE_ORDER)).intValue()));
                node.setAttribute(LayoutGraph.NODE_PRERANK, new Integer(
                    ((Integer) bn.getAttributeValue(LayoutGraph.NODE_PRERANK))
                    .intValue()));
                node.setAttribute(LayoutGraph.NODE_RANK, new Integer(((Integer) bn
                    .getAttributeValue(LayoutGraph.NODE_RANK)).intValue()));
                node.setAttribute(LayoutGraph.NODE_POSITION, bn.getCenterPoint());
            }
        }

        Enumeration edges = m_gGraph.edgeElements();
        while (edges.hasMoreElements()) {
            Edge edge = (Edge) edges.nextElement();
            Edge be = m_gBackup.findEdgeByName(edge.getName());
            if(be!=null) {
                edge.setAttribute(LayoutGraph.EDGE_NEW, be
                                  .getAttributeValue(LayoutGraph.EDGE_NEW));
                List path=(List) be.getAttributeValue(LayoutGraph.EDGE_PATH);
                List np=Collections.synchronizedList(new ArrayList());
                np.addAll(path);
                edge.setAttribute(LayoutGraph.EDGE_PATH, np);
            }
        }

        // restore the position of DiagramDesktop's elements
        nodes = m_gGraph.nodeElements();
        while (nodes.hasMoreElements()) {
            Node node = (Node) nodes.nextElement();
            DiagramNode dn = (DiagramNode) node
                    .getAttributeValue(LayoutGraph.DIAGRAM_OBJECT);
            int x = (int) node.getCenterPoint().x;
            int y = (int) node.getCenterPoint().y;
            dn.setCenter(x, y);
        }

        edges = m_gGraph.edgeElements();
        while (edges.hasMoreElements()) {
            Edge edge = (Edge) edges.nextElement();
            DiagramEdge de = (DiagramEdge) edge
                    .getAttributeValue(LayoutGraph.DIAGRAM_OBJECT);
            List path = (List) edge.getAttributeValue(LayoutGraph.EDGE_PATH);
            Point p = new Point((Point) path.get(path.size() / 2));
            if (path.size() % 2 == 0) {
                Point p2 = (Point) path.get(path.size() / 2 - 1);
                p.x = (p.x + p2.x) / 2;
                p.y = (p.y + p2.y) / 2;
            }
            de.getNode().setCenter(p);
        }
    }
}
