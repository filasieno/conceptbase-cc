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
 * Created on 2004-12-3
 *
 */
package i5.cb.graph.layout;

import i5.cb.graph.diagram.DiagramNode;

import java.io.Writer;
import java.util.*;

import att.grappa.*;

/**
 * This class is a utility class for manage internal layout data. In this class
 * the graph is nomalized that no edge can have length of more than 1. Long
 * edges (have length of at least 2) in the original graph is modeled into
 * chains of dummy nodes that reside in consecutive ranks(levels).
 * 
 * This class also keep a 2-D list to give functions that can access ranks and
 * nodes by providing node's rank and order(sequence within the rank).
 * 
 * @author Li, Yong
 * 
 * @version 1.0
 */
public class Config {

	/**
	 * graph name for "configuration" graph
	 */
	public static final String CONFIGURE_GRAPH_NAME = "@ConfigureGraph";

	/**
	 * 2D-array for fast accessing nodes with rank and order
	 */
	private List m_configuration;

	/**
	 * working graph for cross reduction and coordinate assigning phase.
	 */
	private LayoutGraph m_conGraph;

	public Config() {
		m_conGraph = new LayoutGraph(CONFIGURE_GRAPH_NAME);
		m_configuration = null;
	}

	/**
	 * add the node into proper position of configuration
	 * 
	 * @param node
	 *            the node to be added
	 * @param rank
	 *            the rank the node to be assigned
	 * @param x
	 *            the x position in the rank
	 */
	public void addConNode(Node node, int rank, double x) {
		List level = (List) m_configuration.get(rank);
		int i = 0;
		for (i = 0; i < level.size(); i++) {
			Node leftNode = (Node) level.get(i);
			if (leftNode.getCenterPoint().x > x)
				break;
		}
		level.add(i, node);
		for (; i < level.size(); i++) {
			Node rightNode = (Node) level.get(i);
			rightNode.setAttribute(LayoutGraph.NODE_ORDER, Integer.valueOf(i));
		}
	}

	/**
	 * add the node into the right most position of the rank
	 * 
	 * @param node
	 *            node to be added
	 * @param rank
	 *            rank the node to be assigned to
	 */
	public void addConNodeRight(Node node, int rank) {
		List level = (List) m_configuration.get(rank);
		level.add(node);
		int order = level.size() - 1;
		node.setAttribute(LayoutGraph.NODE_ORDER, Integer.valueOf(order));
		if (order == 0) {
			// the node is the first element
			node.setAttribute(LayoutGraph.NODE_POSITION, new GrappaPoint(1.0,
					1.0));
		} else {
			Node pn = (Node) level.get(order - 1);
			node.setAttribute(LayoutGraph.NODE_POSITION, new GrappaPoint(pn
					.getCenterPoint().x + 20.0, pn.getCenterPoint().y));
		}
		node.setAttribute(LayoutGraph.NODE_NEW, Boolean.FALSE);
	}

	/**
	 * Return a copy of internal 2D-array arrangement
	 * 
	 * @return the copy of 2D-array arrangement
	 */
	public List backup() {
		List back = Collections.synchronizedList(new ArrayList());
		ListIterator it = m_configuration.listIterator();
		while (it.hasNext()) {
			List temp = Collections.synchronizedList(new ArrayList());
			List rank = (List) it.next();
			ListIterator itr = rank.listIterator();
			while (itr.hasNext()) {
				temp.add(itr.next());
			}
			back.add(temp);
		}
		return back;
	}

	/**
	 * build the chain representation of long edges
	 * 
	 * @param edge
	 *            edge that is used to build the chain
	 */
	private void buildChain(Edge edge) {
		// remove the old chain
		removeChain(edge);

		// get head and tail information
		Node head = edge.getHead();
		Node tail = edge.getTail();
		int hr = ((Integer) head.getAttributeValue(LayoutGraph.NODE_RANK))
				.intValue();
		int tr = ((Integer) tail.getAttributeValue(LayoutGraph.NODE_RANK))
				.intValue();
		if (tr > hr) {
			// always make head's rank bigger than tail's rank
			tail = head;
			head = edge.getTail();
			int t = hr;
			hr = tr;
			tr = t;
		}

		// build virtual chain
		double xh = head.getCenterPoint().x;
		double xt = tail.getCenterPoint().x;
		List vedgeList = Collections.synchronizedList(new ArrayList());
		for (int i = tr + 1; i < hr; i++) {
			Node vnode = new Node(m_conGraph);
			vnode.setAttribute(LayoutGraph.NODE_RANK, Integer.valueOf(i));
			vnode.setAttribute(LayoutGraph.NODE_DUMMY, Boolean.TRUE);
			vnode.setAttribute(LayoutGraph.NODE_WIDTH, Double.valueOf(2.0));
			vnode.setAttribute(LayoutGraph.NODE_HEIGHT, Double.valueOf(2.0));
			addConNode(vnode, i, (xh * (i - tr) + xt * (hr - i)) / (hr - tr));
			Edge vedge = new Edge(m_conGraph, tail, vnode);
			vedge.setAttribute(LayoutGraph.EDGE_DUMMY, Boolean.TRUE);
			tail = vnode;
			vedgeList.add(vedge);
		}
		Edge vedge = new Edge(m_conGraph, tail, head);
		vedgeList.add(vedge);
		vedge.setAttribute(LayoutGraph.EDGE_DUMMY, Boolean.TRUE);
		edge.setAttribute(LayoutGraph.EDGE_CHAIN, vedgeList);
	}

	/**
	 * Remove redundant ranks
	 */
	private void checkRank() {
		for (int i = m_configuration.size() - 1; i >= 0; i--) {
			List rank = (List) m_configuration.get(i);
			if (!rank.isEmpty()) {
				break;
			} else {
				m_configuration.remove(i);
			}
		}
	}

	/**
	 * delete all elements that do not exist in g
	 * 
	 * @param g
	 *            user graph
	 */
	public void executeDeletion(LayoutGraph g) {
		// first, delete edges
		Enumeration ee = m_conGraph.edgeElements();
		while (ee.hasMoreElements()) {
			Edge edge = (Edge) ee.nextElement();
			if (edge.getAttributeValue(LayoutGraph.EDGE_DUMMY) == Boolean.TRUE) {
				continue;
			}
			if (g.findEdgeByName(edge.getName()) == null) {
				removeChain(edge);
				m_conGraph.removeEdge(edge.getName());
			}
		}

		// second, delete nodes
		Enumeration en = m_conGraph.nodeElements();
		while (en.hasMoreElements()) {
			Node node = (Node) en.nextElement();
			if (node.getAttributeValue(LayoutGraph.NODE_DUMMY) == Boolean.TRUE) {
				continue;
			}
			if (g.findNodeByName(node.getName()) == null) {
				removeConNode(node);
				node.delete();
			}
		}
	}

	/**
	 * Return the total number of crossings of current layout
	 * 
	 * @return number of crossings
	 */
	public int getCrossings() {
		int count = 0;
		int nranks = m_configuration.size();
		for (int i = 0; i < nranks - 1; i++) {
			List lrank = (List) m_configuration.get(i);
			int nnodes = lrank.size();
			for (int l = 0; l < nnodes - 1; l++) {
				for (int r = l + 1; r < nnodes; r++) {
					Node lnode = (Node) lrank.get(l);
					Node rnode = (Node) lrank.get(r);
					Enumeration el = lnode.outEdgeElements();
					while (el.hasMoreElements()) {
						Edge ledge = (Edge) el.nextElement();
						if (ledge.getAttributeValue(LayoutGraph.EDGE_DUMMY) == Boolean.FALSE)
							continue;
						int lorder = ((Integer) ledge.getHead()
								.getAttributeValue(LayoutGraph.NODE_ORDER))
								.intValue();
						Enumeration er = rnode.outEdgeElements();
						while (er.hasMoreElements()) {
							Edge redge = (Edge) er.nextElement();
							if (redge.getAttributeValue(LayoutGraph.EDGE_DUMMY) == Boolean.FALSE)
								continue;
							int rorder = ((Integer) redge.getHead()
									.getAttributeValue(LayoutGraph.NODE_ORDER))
									.intValue();
							if (lorder > rorder)
								count++;
						}
					}
				}
			}
		}
		return count;
	}

	/**
	 * Get the node list at given rank
	 * 
	 * @param rank
	 *            rank number
	 * @return node list of the rank
	 */
	public List getRank(int rank) {
		return (List) m_configuration.get(rank);
	}

	/**
	 * Get the number of ranks
	 * 
	 * @return number of ranks
	 */
	public int getRankSize() {
		return m_configuration.size();
	}

	/**
	 * insert newly add edges into configuration
	 */
	private void insertNewEdge(LayoutGraph g) {
		Enumeration ee = g.edgeElements();
		while (ee.hasMoreElements()) {
			Edge edge = (Edge) ee.nextElement();
			Node head = edge.getHead();
			Node tail = edge.getTail();

			if (head == tail) {
				// self-loop, ignore
				continue;
			}

			if (edge.getAttributeValue(LayoutGraph.EDGE_NEW) == Boolean.FALSE)
				continue;
			int hrank = ((Integer) head
					.getAttributeValue(LayoutGraph.NODE_RANK)).intValue();
			int trank = ((Integer) tail
					.getAttributeValue(LayoutGraph.NODE_RANK)).intValue();
			if (hrank == trank) {
				// flat edge, ignore
				continue;
			} else {
				// build virtual chain for this edge
				buildChain(edge);
			}
			edge.setAttribute(LayoutGraph.EDGE_NEW, Boolean.FALSE);
			m_conGraph.addEdge(edge);
		}
	}

	/**
	 * insert newly add nodes into configuration
	 */
	private void insertNewNode(LayoutGraph g) {
		Enumeration ne = g.nodeElements();
		while (ne.hasMoreElements()) {
			Node pNode = (Node) ne.nextElement();
			if (pNode.getAttributeValue(LayoutGraph.NODE_NEW) == Boolean.FALSE)
				continue; // old node, skip

			int rank = ((Integer) pNode
					.getAttributeValue(LayoutGraph.NODE_RANK)).intValue();
			while (rank >= m_configuration.size()) {
				// allocate enouge space
				m_configuration.add(Collections
						.synchronizedList(new ArrayList()));
			}
			addConNodeRight(pNode, rank);
			m_conGraph.addNode(pNode);
		}
	}

	/**
	 * Move the existing edges to fit the new rank assignment
	 */
	private void moveOldEdges(LayoutGraph g) {
		Enumeration ee = g.edgeElements();
		while (ee.hasMoreElements()) {
			Edge edge = (Edge) ee.nextElement();
			Node head = edge.getHead();
			Node tail = edge.getTail();

			if (head == tail) {
				// self-loop, ignore
				continue;
			}

			if (edge.getAttributeValue(LayoutGraph.EDGE_NEW) == Boolean.TRUE
					|| edge.getAttributeValue(LayoutGraph.EDGE_DUMMY) == Boolean.TRUE)
				continue;

			int ohrank = ((Integer) head
					.getAttributeValue(LayoutGraph.NODE_PRERANK)).intValue();
			int nhrank = ((Integer) head
					.getAttributeValue(LayoutGraph.NODE_RANK)).intValue();
			int otrank = ((Integer) tail
					.getAttributeValue(LayoutGraph.NODE_PRERANK)).intValue();
			int ntrank = ((Integer) tail
					.getAttributeValue(LayoutGraph.NODE_RANK)).intValue();
			if (ohrank == nhrank && otrank == ntrank) {
				// need not move this edge
				continue;
			}

			// edge need move
			if (nhrank == ntrank) {
				// flat edge
				removeChain(edge);
			} else {
				buildChain(edge);
			}
		}
	}

	/**
	 * Move the existing nodes to the new rank
	 */
	private void moveOldNodes(LayoutGraph g) {
		ArrayList moveNode = new ArrayList();
		Enumeration ne = g.nodeElements();
		while (ne.hasMoreElements()) {
			Node pNode = (Node) ne.nextElement();
			int order = ((Integer) pNode
					.getAttributeValue(LayoutGraph.NODE_ORDER)).intValue();
			if (order < 0)
				continue; // new node, skip

			moveNode.add(pNode);
		}
		Collections.sort(moveNode, new Comparator() {
			public int compare(Object o1, Object o2) {
				int oldRank1 = ((Integer) ((Node) o1)
						.getAttributeValue(LayoutGraph.NODE_PRERANK))
						.intValue();
				int oldRank2 = ((Integer) ((Node) o2)
						.getAttributeValue(LayoutGraph.NODE_PRERANK))
						.intValue();
				if (oldRank1 < oldRank2)
					return -1;
				if (oldRank1 == oldRank2)
					return 0;
				return 1;
			}

			public boolean equal(Object o1, Object o2) {
				int oldRank1 = ((Integer) ((Node) o1)
						.getAttributeValue(LayoutGraph.NODE_PRERANK))
						.intValue();
				int oldRank2 = ((Integer) ((Node) o2)
						.getAttributeValue(LayoutGraph.NODE_PRERANK))
						.intValue();
				return oldRank1 == oldRank2;
			}
		});
		Iterator it = moveNode.iterator();
		while (it.hasNext()) {
			Node node = (Node) it.next(); // current node

			int preRank = ((Integer) node
					.getAttributeValue(LayoutGraph.NODE_PRERANK)).intValue();
			int newRank = ((Integer) node
					.getAttributeValue(LayoutGraph.NODE_RANK)).intValue();
			if (preRank == newRank)
				continue; // no change need to be made

			while (newRank >= m_configuration.size()) {
				// allocate enouge space
				m_configuration.add(Collections
						.synchronizedList(new ArrayList()));
			}

			// calculate possible new x position
			Enumeration ee = node.edgeElements();
			int count = 0;
			double sum = 0.0;
			while (ee.hasMoreElements()) {
				Edge edge = (Edge) ee.nextElement();
				Node nb = edge.getHead();
				if (nb == node) {
					nb = edge.getTail();
				}

				if (nb == node) {
					continue;
				}
				sum += nb.getCenterPoint().x;
				count++;
			}
			double newX = count == 0 ? 0 : sum / count;
			node.setAttribute(LayoutGraph.NODE_POSITION, new GrappaPoint(newX,
					node.getCenterPoint().y));

			// remove the node from the old rank
			List oldLevel = (List) m_configuration.get(preRank);
			int i = ((Integer) node.getAttributeValue(LayoutGraph.NODE_ORDER))
					.intValue();
			Node cnode = (Node) oldLevel.get(i);
			oldLevel.remove(cnode);
			for (; i < oldLevel.size(); i++) {
				Node rightNode = (Node) oldLevel.get(i);
				rightNode.setAttribute(LayoutGraph.NODE_ORDER, Integer.valueOf(i));
			}

			// insert the node into the new rank with new x
			addConNode(cnode, newRank, newX);
		}
	}

	/**
	 * only for debug
	 */
	public void print(Writer writer) {
		m_conGraph.printGraph(writer);
	}

	/**
	 * remove the chain representation of long edges
	 * 
	 * @param edge
	 *            edge whose chain is to be removed
	 */
	private void removeChain(Edge edge) {
		// clear all the dummy node in the chain
		List chain = (List) edge.getAttributeValue(LayoutGraph.EDGE_CHAIN);
		if (chain.isEmpty()) {
			return;
		}
		((Edge) chain.get(0)).delete();
		for (int i = 1; i < chain.size(); i++) {
			Edge vedge = (Edge) chain.get(i);
			Node tail = vedge.getTail();
			removeConNode(tail);
			tail.delete();
		}
		chain.clear();
	}

	/**
	 * remove the node in configuration
	 * 
	 * @param node
	 *            node to be removed
	 */
	public void removeConNode(Node node) {
		int rank = ((Integer) node.getAttributeValue(LayoutGraph.NODE_RANK))
				.intValue();
		int order = ((Integer) node.getAttributeValue(LayoutGraph.NODE_ORDER))
				.intValue();
		List level = (List) m_configuration.get(rank);
		level.remove(order);
		for (int i = order; i < level.size(); i++) {
			Node rightnode = (Node) level.get(i);
			rightnode.setAttribute(LayoutGraph.NODE_ORDER, Integer.valueOf(i));
		}
	}

	/**
	 * Restore the 2D-array arrangement from a backup
	 * 
	 * @param backup
	 *            2D-array backup
	 */
	public void restore(List backup) {
		ListIterator itb = backup.listIterator();
		while (itb.hasNext()) {
			int r = itb.nextIndex();
			List oldrank = (List) itb.next();
			List rank = (List) m_configuration.get(r);
			ListIterator itr = oldrank.listIterator();
			while (itr.hasNext()) {
				int o = itr.nextIndex();
				Node node = (Node) itr.next();
				node.setAttribute(LayoutGraph.NODE_ORDER, Integer.valueOf(o));
				rank.set(o, node);
			}
		}
	}

	/**
	 * Update the configuration from current graph which contains rank
	 * information. Edges are breaked and virtual nodes are added as nessesary.
	 * 
	 * @param g
	 *            current graph
	 */
	public void updateConGraph(LayoutGraph g) {
		if (m_configuration == null) {
			m_configuration = Collections.synchronizedList(new ArrayList());
		}
		moveOldNodes(g);
		moveOldEdges(g);
		insertNewNode(g);
		insertNewEdge(g);
		checkRank();
	}

	public void fixNodes() {
		Enumeration nodes = m_conGraph.nodeElements();
		while (nodes.hasMoreElements()) {
			Node node = (Node) nodes.nextElement();
			node.setAttribute(LayoutGraph.NODE_FIXED, Boolean.TRUE);
		}
	}

	public void updateNodes() {
		for (int i = 0; i < getRankSize(); i++) {
			List rank = getRank(i);
			for (Iterator iter = rank.iterator(); iter.hasNext();) {
				Node node = (Node) iter.next();
				if (node.getAttributeValue(LayoutGraph.NODE_DUMMY).equals(
						Boolean.FALSE)) {
					DiagramNode dn = (DiagramNode) node
							.getAttributeValue(LayoutGraph.DIAGRAM_OBJECT);
					node.setAttribute(LayoutGraph.NODE_POSITION,new GrappaPoint(dn.getCenter().x, dn.getCenter().y));
				}
			}
		}
	}
}
