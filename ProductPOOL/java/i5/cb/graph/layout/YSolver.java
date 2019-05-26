/*
The ConceptBase.cc Copyright

Copyright 1987-2019 The ConceptBase Team. All rights reserved.

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

import java.util.Iterator;
import java.util.List;


/**
 * This class is used to assign Y coordinates to nodes
 * 
 * @author Li Yong; revised by Xiang Li
 * 
 * @version 2.0
 */
public class YSolver {
	/**
	 * Assign Y coordinates to nodes
	 * 
	 * @param con
	 *            Configuration which contains nodes' ranks and orders
	 * @param minSep
	 *            Minimal width between adjacent ranks
	 */
	public void place(Config con, double minSep) {
		double y = 60.0;
		List ranksList = RankRearranger.getRearrangedRanks(con);
		Object[] ranks = ranksList.toArray();
		for(int i = 0;i<ranks.length;i++){
			List rank = (List)ranks[i];
			double maxh = getRankMaxH(rank);
			y+=maxh/2;
			
			if(y<getRankY(rank))
				y=getRankY(rank);
			setRankY(rank,y);
			validateShownRank(rank);
			
			y += maxh/2+ minSep;	
		}
	}
//	public void placeOrig(Config con, double minSep) {
//		double y = 60.0;
//		for (int i = 0; i < con.getRankSize(); i++) {
//			List rank = RankRearranger.rearrange(con.getRank(i));
//			double maxh = getRankMaxH(rank);
//			y+=maxh/2;			
//			if(y<getRankY(rank))
//				y=getRankY(rank);
//			setRankY(rank,y);
//			validateShownRank(rank);			
//			y += maxh/2+ minSep;
//		}
//	}
	private void setRankY(List rank,double y){
		for (Iterator iter = rank.iterator(); iter.hasNext();) {
			MyNode node = (MyNode) iter.next();
			node.setY(y);
		}
	}
	private double getRankY(List rank) {
		double y = 0;
		for (Iterator iter = rank.iterator(); iter.hasNext();) {
			MyNode node = (MyNode) iter.next();
			if (node.isShown()) {
				y = node.getCenterY();
				break;
			}
		}
		return y;
	}
	private void validateShownRank(List rank){
		for (Iterator iter = rank.iterator(); iter.hasNext();) {
			MyNode node = (MyNode) iter.next();
			node.validateShown();
		}
	}
	private double getRankMaxH(List rank){
		double maxh = 0.0;
		for (Iterator iter = rank.iterator(); iter.hasNext();) {
			MyNode node = (MyNode) iter.next();
			double h = node.getHeight();
			if (h > maxh)
				maxh = h;
		}
		return maxh;
	}
}