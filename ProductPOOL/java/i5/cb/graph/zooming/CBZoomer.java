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
 * Created on 2004-11-12
 * 
 * Copyright 2004 by Li Xiang,
 *
 * All rights reserved.
 * 
 */
package i5.cb.graph.zooming;

import i5.cb.graph.diagram.DiagramNode;

import java.awt.*;
import java.util.Hashtable;

import javax.swing.JViewport;

/**
 * Description: 
 *
 * @author Li Xiang
 * 
 * @version 1.0
 */
public class CBZoomer extends AbstractZoomer {

	private static CBZoomer instance;
	
	protected CBZoomer() {
		super();
		smallSize = new Hashtable(100);
		componentSize = new Hashtable(100);
	}
		
	public static CBZoomer getInstance(){
		if(instance == null)
			instance = new CBZoomer();
		return instance;
	}
	
	protected SizeHashtableEntry getComponentOriginalSize(Component c){
		SizeHashtableEntry entry ;
		if(c instanceof DiagramNode){
			DiagramNode node = (DiagramNode)c;
			if(node.isSmallComponentVisible())
				entry = (SizeHashtableEntry)smallSize.get(node);
			else
				entry = (SizeHashtableEntry)componentSize.get(node);
			
			if(entry == null){
				entry = new SizeHashtableEntry(node.getBounds(),node.getFont());
				putDiagramNodeSize(node,entry);
			}
		}else
			entry = super.getComponentOriginalSize(c);
		
		return entry; 
	}
	
	void putDiagramNodeSize(DiagramNode node,SizeHashtableEntry entry){
		
		if(node.isSmallComponentVisible())
			smallSize.put(node,entry);
		else
			componentSize.put(node,entry);
		
	}
	
	/**
	 * this method is called by DiagramDesktop to get a new viewport 
	 * after zooming.
	 */	
	public Rectangle getZoomedViewportRect(JViewport vp){
		Rectangle r = vp.getViewRect();
		Point center = new Point(r.x+r.width/2,r.y+r.height/2);
		center.x *= factor/oldFactor;
		center.y *= factor/oldFactor;
		Point newCenter =new Point(center.x-r.width/2,center.y-r.height/2);
		newCenter.x= newCenter.x<0?0:newCenter.x;
		newCenter.y= newCenter.y<0?0:newCenter.y;
		Rectangle newBound = new Rectangle(newCenter.x,newCenter.y,r.width,r.height);
		return newBound;
	}
	
	protected Hashtable smallSize;
	protected Hashtable componentSize;

}
