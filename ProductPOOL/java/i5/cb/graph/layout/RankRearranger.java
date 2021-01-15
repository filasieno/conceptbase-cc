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
 * Created on 2005-2-11
 * 
 * Copyright 2005 by Li Xiang,
 *
 * All rights reserved.
 * 
 */
package i5.cb.graph.layout;

import java.util.*;

import att.grappa.Edge;
import att.grappa.Node;

/**
 * this is used as an utility to rearrange the nodes in one rank to put incoming
 * edges on the left and outgoing on the right of a target node.
 * 
 * @author Li Xiang
 * 
 * @version 1.0
 */
public class RankRearranger {
	public static final int MAX_RANK_SIZE = 10;

	public static List getRearrangedRanks(Config con) {
		List result = new ArrayList();
		for (int i = 0; i < con.getRankSize(); i++)
			processRank(con.getRank(i), result);
		return result;
	}

	private static void processRank(List rank, List ranks) {
		Set oldNodes = new HashSet();
		Iterator it = rank.iterator();
		List destRank = new ArrayList();
		ranks.add(destRank);
		int count = 0;
		while (it.hasNext()) {
			Node node = (Node) it.next();
			if (count >= MAX_RANK_SIZE) {
				destRank = new ArrayList();
				ranks.add(destRank);
				count = 0;
			}
			processNode(destRank, rank, oldNodes, node);
			count++;
		}
	}

	private static void processNode(List dest, List src, Set invalidNodes,
			Node node) {

		insertRelatedNodes(dest, src, invalidNodes, node, true);
		if (!invalidNodes.contains(node)) {
			dest.add(new SimpleNode(node));
			invalidNodes.add(node);
		}
		insertRelatedNodes(dest, src, invalidNodes, node, false);

	}

	private static Enumeration getEdges(Node node, boolean isInEdge) {
		Enumeration en;
		if (isInEdge)
			en = node.inEdgeElements();
		else
			en = node.outEdgeElements();
		return en;
	}

	private static Node getEdgeLinkedNode(Node src,Edge edge,boolean isInEdge){
		Node linked = null;
//		check again because implementation of layout gives
		// wrong information
		if (isInEdge) {
			if (edge.getHead().equals(src))
				linked = edge.getTail();
			
		} else {
			if (edge.getTail().equals(src))
				linked = edge.getHead();
			
		}
		return linked;
	}
	private static void insertRelatedNodes(List dest, List src,
			Set invalidNodes, Node node, boolean isInEdge) {
		if (!invalidNodes.contains(node)) {
			Enumeration en = getEdges(node, isInEdge);
			CompositeNode composite = new CompositeNode();
			int count = 0;
			Node singleGuard = null;
			while (en.hasMoreElements()) {
				Edge edge = (Edge) en.nextElement();
				if (edge.getAttributeValue(LayoutGraph.EDGE_DUMMY) == Boolean.TRUE)
					continue;
				Node related=getEdgeLinkedNode(node,edge,isInEdge);
				if (related==null||related.equals(node) || invalidNodes.contains(related))
					continue;
				if (src.contains(related)) {
					composite.addNode(new SimpleNode(related));
					invalidNodes.add(related);
					count++;
					singleGuard = related;
				}
			}
			if (count == 1)
				dest.add(new SimpleNode(singleGuard));
			else if (composite.size() > 0)
				dest.add(composite);
		}
	}

}
