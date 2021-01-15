/*
The ConceptBase.cc Copyright

Copyright 1987-2021 The ConceptBase Team. All rights reserved.

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
 * Created on 2004-12-7
 *
 */
package i5.cb.graph.layout;

import java.util.*;

import att.grappa.Edge;

/**
 * This class is used to assign X coordinates to nodes
 * 
 * @author Li Yong; revised by Xiang Li
 * 
 * @version 2.0
 */
public class XSolver {
	/**
	 * Assign X coordinates to nodes
	 * 
	 * @param con
	 *            Configuration which contains nodes' ranks and orders
	 * @param minSep
	 *            Minimal width between adjacent nodes
	 */
	public void place(Config con, double minSep) {
		double maxWidth = 0.0;
		int maxWRank = 0;
		List ranksList = RankRearranger.getRearrangedRanks(con);
		Object[] ranks = ranksList.toArray();
		for (int i = 0; i < ranks.length; i++) {
			List rank = (List) ranks[i];
			double x = 60.0;
			double initialX = getRankInitialXWithCenterUnchanged(rank, minSep);
			if (x < initialX)
				x = initialX;
			else
				initialX = x;
			boolean newRank = true;
			for (Iterator iter = rank.iterator(); iter.hasNext();) {
				MyNode node = (MyNode) iter.next();
				double w = node.getWidth();
				x += w / 2.0 + node.getAdditionalSep();
				node.setX(x);
				x += w / 2.0 + minSep;
				newRank = newRank && !node.isShown();
			}
			if (x - initialX > maxWidth) {
				if (!newRank) {
					maxWidth = x - initialX;
					maxWRank = i;
				}
			}
		}

		//		maxWRank = getMaxWidthRankIndex(con,minSep);
		reformat(ranks, maxWRank, minSep);
		//		if(con.getRank(maxWRank).size()==1)
		//			reformat(con,getMaxWidthRank(con),minSep);
	}



	private void reformat(Object[] ranks, int maxWidthRank, double minSep) {
		//adjust all ranks based on the widest one
		for (int i = maxWidthRank - 1; i >= 0; i--)
			relocateRank((List) ranks[i], minSep, OUT_EDGE);
		for (int i = maxWidthRank + 1; i < ranks.length; i++)
			relocateRank((List) ranks[i], minSep, IN_EDGE);
	}

	private double getRankInitialXWithCenterUnchanged(List rank, double sep) {
		Iterator it = rank.iterator();
		double sum = 0;
		int count = 0;
		boolean newRank = true;
		while (it.hasNext()) {
			MyNode node = (MyNode) it.next();
			if (node.isShown()) {
				sum += node.getCenterX();
				count++;
				newRank = false;
			}
		}
		if (newRank)
			return 0;
		double rankCenter = sum / count;
		return rankCenter - getRankLength(rank, sep) / 2.0;
	}

	private double getRankLength(List rank, double sep) {
		double length = 0;
		Iterator it = rank.iterator();
		int count = 0;
		while (it.hasNext()) {
			MyNode node = (MyNode) it.next();
			length += node.getWidth() + node.getAdditionalSep();
			count++;
		}
		it = rank.iterator();
		if (it.hasNext()) {
			MyNode node = (MyNode) it.next();
			length -= node.getAdditionalSep();
		}
		length += (count - 1) * sep;
		return length;
	}



	private void relocateRank(List rank, double minSep, int edgeType) {
		double x = 0.0;
		for (Iterator iter = rank.iterator(); iter.hasNext();) {
			MyNode node = (MyNode) iter.next();
			double w = node.getWidth();
			x += w / 2.0 + node.getAdditionalSep();

			double sumx = 0.0;
			int count = 0;

			Enumeration e;
			if (edgeType == IN_EDGE)
				e = node.inEdgeElements();
			else
				e = node.outEdgeElements();
			while (e.hasMoreElements()) {
				Edge edge = (Edge) e.nextElement();
				if (edge.getAttributeValue(LayoutGraph.EDGE_DUMMY) == Boolean.FALSE) {
					continue;
				}
				if (edgeType == IN_EDGE)
					sumx += edge.getTail().getCenterPoint().x;
				else
					sumx += edge.getHead().getCenterPoint().x;
				count++;
			}
			if (count > 0) {
				sumx /= count;
			}
			x = x > sumx ? x : sumx;
			if (node.isShown() && node.getCenterX() > x)
				x = node.getCenterX();
			node.setX(x);
			x += w / 2.0 + minSep;
		}
	}

	final static int IN_EDGE = 11;

	final static int OUT_EDGE = 12;
}