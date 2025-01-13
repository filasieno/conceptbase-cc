/*
The ConceptBase.cc Copyright

Copyright 1987-2025 The ConceptBase Team. All rights reserved.

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
 * Created on 2004-12-10
 *
 */
package i5.cb.graph.layout;

import java.awt.Point;
import java.util.*;

import att.grappa.Edge;
import att.grappa.GrappaPoint;

/**
 * This class is responsible for generating polygon edge path
 * 
 * @author Li, Yong
 * 
 * @version 1.0
 */
public class EdgeRouter {
    /**
     * assign edge path
     * 
     * @param g
     *            the graph that has been properly placed
     */
    public void routeEdge(LayoutGraph g) {
        Enumeration edges = g.edgeElements();
        while (edges.hasMoreElements()) {
            Edge edge = (Edge) edges.nextElement();
            List chain = (List) edge.getAttributeValue(LayoutGraph.EDGE_CHAIN);
            List path = Collections.synchronizedList(new ArrayList());
            if (chain.size() > 0) {
                // model edge: the tail and head do not have the same rank
                for (int i = 0; i < chain.size(); i++) {
                    Edge ve = (Edge) chain.get(i);
                    GrappaPoint p = ve.getTail().getCenterPoint();
                    path.add(new Point((int) p.x, (int) p.y));
                }
                Edge ve = (Edge) chain.get(chain.size() - 1);
                GrappaPoint p = ve.getHead().getCenterPoint();
                path.add(new Point((int) p.x, (int) p.y));
                edge.setAttribute(LayoutGraph.EDGE_PATH, path);
            } else {
                // non-model edge: eg. self-loop, flat-edge
                if (edge.getTail() == edge.getHead()) {
                    // self-loop
                    GrappaPoint p = edge.getTail().getCenterPoint();
                    path.add(new Point((int) p.x - 40, (int) p.y - 40));
                    edge.setAttribute(LayoutGraph.EDGE_PATH, path);
                } else {
                    // flat-edge, deal with all parallel edges
                    Enumeration ee = Edge.findEdgesByEnds(edge.getTail(), edge
                            .getHead());
                    int count = 0;
                    while (ee.hasMoreElements()) {
                        ee.nextElement();
                        count++;
                    }
                    int y = 0, i = 0;
                    GrappaPoint pt = edge.getTail().getCenterPoint();
                    GrappaPoint ph = edge.getHead().getCenterPoint();
                    Point midp = new Point((int) (pt.x + ph.x) / 2,
                            (int) (pt.y + ph.y) / 2);
                    ee = Edge.findEdgesByEnds(edge.getTail(), edge.getHead());
                    while (ee.hasMoreElements()) {
                        Edge ve = (Edge) ee.nextElement();
                        List ppath = Collections
                                .synchronizedList(new ArrayList());
                        y = (i % 2 == 0) ? (y + i * 10) : (y - i * 10);
                        y = (count % 2 == 0) ? y : y + 5;
                        ppath.add(new Point(midp.x, midp.y + y));
                        ve.setAttribute(LayoutGraph.EDGE_PATH, ppath);
                        i++;
                    }
                }
            }
        }
    }
}