/*
The ConceptBase.cc Copyright

Copyright 1987-2022 The ConceptBase Team. All rights reserved.

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
 * Created on 24.11.2004
 */
package i5.cb.graph.layout;

import i5.cb.graph.cbeditor.CBUserObject;
import i5.cb.graph.diagram.DiagramEdge;
import i5.cb.telos.object.Attribute;

import java.util.Enumeration;
import java.util.Stack;

import att.grappa.Edge;
import att.grappa.Node;

/**
 * This class encapsulates ranking algorithm. It assigns all nodes in the graph
 * with correspoding rank.
 * 
 * @author Li, Yong
 * 
 * @version 1.0
 */
public class Ranker {
    /**
     * This function assigns rank to the input graph.
     * 
     * @param g
     *            the input graph
     */
    public void ranking(LayoutGraph g) {
        for (Enumeration ne = g.nodeElements(); ne.hasMoreElements();) {
            // save previous and clear all ranks
            Node node = (Node) ne.nextElement();
            node.setAttribute(LayoutGraph.NODE_PRERANK, node
                    .getAttributeValue(LayoutGraph.NODE_RANK));
            node.setAttribute(LayoutGraph.NODE_RANK, new Integer(0));
        }

        root: for (Enumeration ne = g.nodeElements(); ne.hasMoreElements();) {
            Node curNode = (Node) ne.nextElement();
            for (Enumeration inedge = curNode.inEdgeElements(); inedge
                    .hasMoreElements();) {
                if (((Edge) inedge.nextElement()).getTail() != curNode) {
                    // not root
                    continue root;
                }
            }
            // root node, updata all children recursively
            Stack stk = new Stack();
            stk.push(curNode);
            updateRank(curNode, stk);
            stk.pop();
        }
    }

    private void updateRank(Node root, Stack stk) {
        for (Enumeration outedge = root.outEdgeElements(); outedge
                .hasMoreElements();) {
            Edge edge = (Edge) outedge.nextElement();
            if (edge.getAttributeValue(LayoutGraph.EDGE_DUMMY) == Boolean.TRUE)
                continue;
            Node child = edge.getHead();

            // cycle detected, ignore
            if (stk.contains(child))
                continue;

            // update the child's rank
            int rootRank = ((Integer) root
                    .getAttributeValue(LayoutGraph.NODE_RANK)).intValue();
            int oldChildRank = ((Integer) child
                    .getAttributeValue(LayoutGraph.NODE_RANK)).intValue();
            int newChildRank;
            DiagramEdge dEdge = (DiagramEdge) edge
                    .getAttributeValue(LayoutGraph.DIAGRAM_OBJECT);
            if ((((CBUserObject) dEdge.getNode().getUserObject())
                    .getTelosObject() instanceof Attribute)) {
                newChildRank = rootRank > oldChildRank ? rootRank
                        : oldChildRank;
            } else {
                newChildRank = rootRank >= oldChildRank ? (rootRank + 1)
                        : oldChildRank;
            }
            child
                    .setAttribute(LayoutGraph.NODE_RANK, new Integer(
                            newChildRank));

            // deal with children recursively
            stk.push(child);
            updateRank(child, stk);
            stk.pop();
        }
    }
}