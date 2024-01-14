/*
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

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
 * Created on 2004-12-3
 *
 */
package i5.cb.graph.layout;

import java.util.*;

import att.grappa.Edge;
import att.grappa.Node;

/**
 * Compare the number of crossings changed
 * 
 * @author Li, Yong
 * 
 * @version 1.0
 */
public class CrossCompare implements Comparator {

    /*
     * (non-Javadoc)
     * 
     * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
     */
    public int compare(Object arg0, Object arg1) {
        int cross = 0;
        Enumeration e1 = ((Node) arg0).outEdgeElements();
        Enumeration e2 = ((Node) arg1).outEdgeElements();
        Vector v1 = new Vector();
        Vector v2 = new Vector();
        while (e1.hasMoreElements()) {
            v1.add(((Edge) e1.nextElement()).getHead().getAttributeValue(
                    LayoutGraph.NODE_ORDER));
        }
        while (e2.hasMoreElements()) {
            v2.add(((Edge) e2.nextElement()).getHead().getAttributeValue(
                    LayoutGraph.NODE_ORDER));
        }

        Collections.sort(v1);
        Collections.sort(v2);
        for (int i = 0; i < v1.size(); i++) {
            int j = 0;
            int o1 = ((Integer)v1.get(i)).intValue();
            while (j < v2.size() && ((Integer)v2.get(j)).intValue() < o1) {
                j++;
            }
            cross += j;
        }
        if (2 * cross < v1.size() * v2.size()) {
            return -1;
        }
        if (2 * cross > v1.size() * v2.size()) {
            return 1;
        }
        return 0;
    }

}