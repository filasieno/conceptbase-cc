/*
The ConceptBase.cc Copyright

Copyright 1987-2020 The ConceptBase Team. All rights reserved.

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
 * Created on 2005-2-9
 * 
 * Copyright 2005 by Li Xiang,
 *
 * All rights reserved.
 * 
 */
package i5.cb.graph.layout;

import java.util.*;

import att.grappa.GrappaPoint;
/**
 * this is a composite of MyNodes which behaves like a single one
 *
 * @author Xiang Li
 * 
 * @version 1.0
 */
public class CompositeNode implements MyNode {

	final double ySep = 40;
	
	public CompositeNode() {
		super();
		nodes = new ArrayList(5);
	}

	void addNode(MyNode node){
		nodes.add(node);
	}
//	MyNode removeNode(int index){
//		return (MyNode)nodes.remove(index);
//	}
	
	/* (non-Javadoc)
	 * @see i5.cb.graph.layout.MyNode#getCenterPoint()
	 */
	public GrappaPoint getCenterPoint() {
		// TODO Auto-generated method stub
		Iterator it = nodes.iterator();
		double sumX=0,sumY=0,count=0;
		while(it.hasNext()){
			MyNode node = (MyNode)it.next();
			if(node.isShown()){
				sumX += node.getCenterPoint().x;
				sumY += node.getCenterPoint().y;
				count++;
			}			
		}
		if(count>0){
			sumX/=count;
			sumY/=count;
		}			
		return new GrappaPoint(sumX,sumY);
	}

	List nodes;

	/* (non-Javadoc)
	 * @see i5.cb.graph.layout.MyNode#getHeight()
	 */
	public double getHeight() {
		assert(!nodes.isEmpty());
		double heightSum=0;
		Iterator it = nodes.iterator();
		while(it.hasNext()){
			MyNode node = (MyNode)it.next();
			heightSum += node.getHeight()+ySep;
		}
		heightSum -= ySep;
		
		return heightSum;
	}

	/* (non-Javadoc)
	 * @see i5.cb.graph.layout.MyNode#getWidth()
	 */
	public double getWidth() {
		double maxWidth=0.0;
		Iterator it = nodes.iterator();
		while(it.hasNext()){
			MyNode node = (MyNode)it.next();
			if(node.getWidth()>maxWidth)
				maxWidth = node.getWidth();
		}
		return maxWidth;
	}

	/* (non-Javadoc)
	 * @see i5.cb.graph.layout.MyNode#isShown()
	 */
	public boolean isShown() {
		Iterator it = nodes.iterator();
		while(it.hasNext()){
			MyNode node = (MyNode)it.next();
			if(node.isShown())
				return true;
		}
		return false;
	}

	/* (non-Javadoc)
	 * @see i5.cb.graph.layout.MyNode#setX(double)
	 */
	public void setX(double x) {
		Iterator it = nodes.iterator();
		while(it.hasNext()){
			MyNode node = (MyNode)it.next();
			node.setX(x);
		}
		
	}

	/* (non-Javadoc)
	 * @see i5.cb.graph.layout.MyNode#setY(double)
	 */
	public void setY(double y) {
		int size = nodes.size();
		double _y = y-(size-1)*ySep/2;
		Iterator it = nodes.iterator();
		while(it.hasNext()){
			MyNode node = (MyNode)it.next();
			node.setY(_y);
			_y += ySep;
		}
	}
	public double getCenterX() {
		// TODO Auto-generated method stub
		return getCenterPoint().x;
	}


	/* (non-Javadoc)
	 * @see i5.cb.graph.layout.MyNode#getCenterY()
	 */
	public double getCenterY() {
		// TODO Auto-generated method stub
		return getCenterPoint().y;
	}

	/* (non-Javadoc)
	 * @see i5.cb.graph.layout.MyNode#setShown(boolean)
	 */
	public void validateShown() {
		// TODO Auto-generated method stub
		Iterator it = nodes.iterator();
		while(it.hasNext()){
			MyNode node = (MyNode)it.next();
			node.validateShown();
		}
	}

	public int size(){
		return nodes.size();
	}
	/* (non-Javadoc)
	 * @see i5.cb.graph.layout.MyNode#inEdgeElements()
	 */
	public Enumeration inEdgeElements() {
		return new NullEnum();
	}

	/* (non-Javadoc)
	 * @see i5.cb.graph.layout.MyNode#outEdgeElements()
	 */
	public Enumeration outEdgeElements() {
		return new NullEnum();
	}
	
	class NullEnum implements Enumeration{

		/* (non-Javadoc)
		 * @see java.util.Enumeration#hasMoreElements()
		 */
		public boolean hasMoreElements() {
			// TODO Auto-generated method stub
			return false;
		}

		/* (non-Javadoc)
		 * @see java.util.Enumeration#nextElement()
		 */
		public Object nextElement() {
			// TODO Auto-generated method stub
			return null;
		}
		
	}

	/* This function is used to make the sepration
	 * of compositenode larger than simple node
	 * @see i5.cb.graph.layout.MyNode#getAdditionalSep()
	 */
	public double getAdditionalSep() {
		// TODO Auto-generated method stub
		return 60;
	}

}
