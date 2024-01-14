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

import java.util.Comparator;
import java.util.List;

import att.grappa.GrappaPoint;
import att.grappa.Node;

/**
 * This class encapsulates cross reduction algorithm. It moves node within the
 * same level to reduce crosses.
 * 
 * @author Li, Yong
 * 
 * @version 1.0
 */
public class CrossOptimizer {
    /**
     * the backup of 2-D configuration
     */
    private List m_backupCon;

    private static final int MAX_PASS = 32;

    private static final int TIRE = 6;

    /**
     * Reorder the sequence of the nodes within the same level to reduce
     * crossings.
     * 
     * @param g
     *            working graph that the long edges have been modified to chains
     * @param config
     *            2-D array configuration
     */
    public void reOrder(Config config) {
        m_backupCon = config.backup();
        MedianCompare mc = new MedianCompare();
        CrossCompare cc = new CrossCompare();
        int best = config.getCrossings();
        int score = 0, pass = 0, tired = 0;
        while (pass < MAX_PASS && best != 0) {
            tired = 0;
            while (pass < MAX_PASS && tired < TIRE) {
                boolean right = ((pass & 1) == 0);
                boolean down = ((pass & 2) == 0);
                mc.setDirDown(!down);
                bubblePass(config, down, right, mc);
                int score2 = config.getCrossings();
                do {
                    score = score2;
                    bubblePass(config, down, right, cc);
                    score2 = config.getCrossings();
                } while (score2 < score);
                score = score2;
                if (score < best) {
                    m_backupCon = config.backup();
                    best = score;
                    tired = 0;
                } else {
                    tired++;
                }
                pass++;
            }

            if (score > best || tired == TIRE) {
                config.restore(m_backupCon);
                tired = 0;
            }
        }

        if (score >= best) {
            config.restore(m_backupCon);
        }

        score = config.getCrossings();
        boolean improved = false;
        do {
            improved = false;
            m_backupCon = config.backup();
            bubblePass(config, true, true, cc);
            int down = config.getCrossings();
            List backup2 = config.backup();
            config.restore(m_backupCon);
            bubblePass(config, false, true, cc);
            int up = config.getCrossings();
            if (down < score && down < up) {
                config.restore(backup2);
                score = down;
                improved = true;
            } else if (up < score) {
                score = up;
                improved = true;
            }
        } while (improved);
    }

    private void bubblePass(Config config, boolean down, boolean right,
            Comparator com) {
        int nrank = config.getRankSize();
        if (down) {
            for (int i = 0; i < nrank; i++) {
                if (right) {
                    bubblePassR(config.getRank(i), com);
                } else {
                    bubblePassL(config.getRank(i), com);
                }
            }
        } else {
            for (int i = nrank - 1; i >= 0; i--) {
                if (right) {
                    bubblePassR(config.getRank(i), com);
                } else {
                    bubblePassL(config.getRank(i), com);
                }
            }
        }
    }

    private void bubblePassL(List nodelist, Comparator com) {
        for (int i = nodelist.size() - 1; i > 0; i--) {
            Node cur = (Node) nodelist.get(i);
            if (cur.getAttributeValue(LayoutGraph.NODE_FIXED) == Boolean.TRUE) {
                continue;
            }
            Node next = (Node) nodelist.get(i - 1);
            if (com.compare(cur, next) < 0) {
                // it's better to swap two nodes
                cur.setAttribute(LayoutGraph.NODE_ORDER, new Integer(i - 1));
                next.setAttribute(LayoutGraph.NODE_ORDER, new Integer(i));
                GrappaPoint cp = cur.getCenterPoint();
                cur.setAttribute(LayoutGraph.NODE_POSITION, next
                        .getCenterPoint());
                next.setAttribute(LayoutGraph.NODE_POSITION, cp);
                nodelist.set(i, next);
                nodelist.set(i - 1, cur);
            }
        }
    }

    private void bubblePassR(List nodelist, Comparator com) {
        for (int i = 0; i < nodelist.size() - 1; i++) {
            Node cur = (Node) nodelist.get(i);
            if (cur.getAttributeValue(LayoutGraph.NODE_FIXED) == Boolean.TRUE) {
                continue;
            }
            Node next = (Node) nodelist.get(i + 1);
            if (com.compare(cur, next) > 0) {
                // it's better to swap two nodes
                cur.setAttribute(LayoutGraph.NODE_ORDER, new Integer(i + 1));
                next.setAttribute(LayoutGraph.NODE_ORDER, new Integer(i));
                GrappaPoint cp = cur.getCenterPoint();
                cur.setAttribute(LayoutGraph.NODE_POSITION, next
                        .getCenterPoint());
                next.setAttribute(LayoutGraph.NODE_POSITION, cp);
                nodelist.set(i, next);
                nodelist.set(i + 1, cur);
            }
        }
    }
}