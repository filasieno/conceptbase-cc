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
/*
 * Created on 2004-12-3
 *
 */
package i5.cb.graph.layout;

import java.util.Comparator;
import java.util.Enumeration;

import att.grappa.Edge;
import att.grappa.Node;

/**
 * Compare two nodes median value
 * 
 * @author Li, Yong
 * 
 * @version 1.0
 */
public class MedianCompare implements Comparator {
    /**
     * direction of calculating median
     */
    private boolean dirDown = true;

    private static final double EPSILON = 0.25;

    /*
     * (non-Javadoc)
     * 
     * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
     */
    public int compare(Object arg0, Object arg1) {
        Enumeration e1 = null, e2 = null;
        if (dirDown) {
            e1 = ((Node) arg0).outEdgeElements();
            e2 = ((Node) arg1).outEdgeElements();
        } else {
            e1 = ((Node) arg0).inEdgeElements();
            e2 = ((Node) arg0).inEdgeElements();
        }
        double med1 = 0.0;
        int count1 = 0;
        while (e1.hasMoreElements()) {
            Edge edge = (Edge) e1.nextElement();
            if (edge.getAttributeValue(LayoutGraph.EDGE_DUMMY) == Boolean.FALSE) {
                continue;
            }
            Node adj = null;
            if (dirDown) {
                adj = edge.getHead();
            } else {
                adj = edge.getTail();
            }
            med1 += adj.getCenterPoint().x;
            count1++;
        }
        if (count1 > 0) {
            med1 /= count1;
        }
        double med2 = 0.0;
        int count2 = 0;
        while (e2.hasMoreElements()) {
            Edge edge = (Edge) e2.nextElement();
            if (edge.getAttributeValue(LayoutGraph.EDGE_DUMMY) == Boolean.FALSE) {
                continue;
            }
            Node adj = null;
            if (dirDown) {
                adj = edge.getHead();
            } else {
                adj = edge.getTail();
            }
            med2 += adj.getCenterPoint().x;
            count2++;
        }
        if (count2 > 0) {
            med2 /= count2;
        }
        if (med1 < med2 - EPSILON)
            return -1;
        if (med1 > med2 + EPSILON)
            return 1;
        return 0;
    }

    /**
     * @return Returns the dirDown.
     */
    public boolean isDirDown() {
        return dirDown;
    }

    /**
     * @param dirDown
     *            The dirDown to set.
     */
    public void setDirDown(boolean dirDown) {
        this.dirDown = dirDown;
    }
}