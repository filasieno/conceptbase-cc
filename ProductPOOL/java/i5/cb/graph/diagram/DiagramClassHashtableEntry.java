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
 * @(#)GraphEditor.java	0.4 b 11.09.99
 *
 * Copyright 1998, 1999 by Rainer Langohr,
 *
 * All rights reserved.
 *
 */

package i5.cb.graph.diagram;


import java.awt.*;

import javax.swing.JPopupMenu;
import javax.swing.text.DefaultStyledDocument;


/**
 * These entries contain the userobject specific items of a {@link DiagramObject}
 *
 * @author <a href="mailto:Tobias.Schoeneberg@epost.de">Tobias Schoeneberg</a>
 * @version 1.0
 */

public class DiagramClassHashtableEntry
{



	/**
	 * The small component associated with a certain userObject
	 *
	 */
	protected Component smallComponent;

	/**
	 * The main component associated with a certain userObject
	 *
	 */
	protected Component mainComponent;

	/**
	 * The {@link DiagramNode} associated with a certain userObject
	 *
	 */
	 protected DiagramNode diagramNode;

	/**
	 * The {@link javax.swing.JPopupMenu} associated with a certain userObject
	 *
	 */
	protected JPopupMenu popupMenu;

	/**
	 * The {@link java.awt.Shape} associated with a certain userObject
	 *
	 */
	protected Shape shape;

	/**
	 * The information document assocated with a certain userobject
	 *
	 */
	protected DefaultStyledDocument infoDoc;

	/**
	 * The color of the edgeline associated with a certain userObject
	 * (used only if the userobject is represented by a {@link DiagramEdge}).
	 *
	 */
	protected Color edgeColor;

	protected Color edgeHeadColor;

	protected Shape edgeHeadShape;

	protected BasicStroke m_stroke;

	/**
	 * Creates a new empty DiagramClassHashtableEntry
	 *
	 */
	public DiagramClassHashtableEntry() {

		smallComponent=null;
		mainComponent=null;
		//diagramObject=null;
		diagramNode=null;
                popupMenu=null;
		shape=null;
		infoDoc = null;
		edgeColor = null;
		edgeHeadColor = null;
		m_stroke = null;
	}


	public BasicStroke getEdgeStroke(){
		return m_stroke;
	}

	public void setEdgeStroke(BasicStroke newStroke){
		m_stroke = newStroke;
	}


	/**
	 * Gets the color of the edgeline associated with a certain
	 * userObject (used only if the userobject is represented by a
	 * {@link DiagramEdge}).
	 *
	 * @return a <code>Color</code> value
	 */
	public Color getEdgeColor(){
		return edgeColor;
	}

	public Color getEdgeHeadColor(){
		return edgeHeadColor;
	}

	public Shape getEdgeHeadShape(){
		return edgeHeadShape;
	}




	/**
	 * Sets the color of the edgeline associated with a certain
	 * userObject (used only if the userobject is represented by a
	 * {@link DiagramEdge}).
	 *
* @param edgeColor a <code>Color</code> value
	 */
	public void setEdgeColor(Color edgeColor){
		this.edgeColor = edgeColor;
	}

	public void setEdgeHeadColor(Color edgeHeadColor){
		this.edgeHeadColor = edgeHeadColor;
	}

	public void setEdgeHeadShape(Shape newshape){
		this.edgeHeadShape = newshape;
	}

	/**
	 * Gets the information document associated with a certain userobject.
	 *
	 * @return a <code>DefaultStyledDocument</code> value
	 */
	public DefaultStyledDocument getInfoDoc(){
		return this.infoDoc;
	}


	/**
	 * Sets the information document associated with a certain userobject
	 *
	 * @param infoDoc a <code>DefaultStyledDocument</code> value
	 */
	public void setInfoDoc(DefaultStyledDocument infoDoc){
		this.infoDoc = infoDoc;
	}

/**
	 * Gets the {@link DiagramObject} associated with a certain userobject.
	 *
	 * @return a <code>DiagramObject</code> value
	 */
	 public DiagramNode getDiagramNode()
	{
		return this.diagramNode;
	}

	/**
	 * Sets the {@link DiagramObject} associated with a certain userobject.
	 *
	 * @param diagramNode a <code>DiagramNode</code> value
	 */
	   public void setDiagramNode(DiagramNode diagramNode)
	{
		this.diagramNode = diagramNode;
	}


    /**
	 * Gets the main component associated with a certain userobject.
	 *
	 * @return a <code>Component</code> value
	 */
	public Component getComponent()
	{
		return this.mainComponent;
	}

	/**
	 * Sets the main component associated with a certain userobject.
	 *
	 * @param mainComponent a <code>Component</code> value
	 */
	public void setComponent(Component mainComponent)
	{
		this.mainComponent = mainComponent;
	}

	/**
	 * Gets the {@link javax.swing.JPopupMenu} associated with a certain userobject.
	 *
	 * @return a <code>JPopupMenu</code> value
	 */
	public JPopupMenu getPopupMenu()
	{
		return this.popupMenu;
	}

	/**
	 * Sets the {@link javax.swing.JPopupMenu} associated with a certain userobject.
	 *
	 * @param popupMenu a <code>JPopupMenu</code> value
	 */
	public void setPopupMenu(JPopupMenu popupMenu)
	{
		this.popupMenu = popupMenu;
	}

	/**
	 * Gets the small component associated with a certain userobject.
	 *
	 * @return a <code>Component</code> value
	 */
	public Component getSmallComponent()
	{
		return this.smallComponent;
	}
	/**
	 * Sets the small component associated with a certain userobject.
	 *
	 * @param smallComponent a <code>Component</code> value
	 */
	public void setSmallComponent(Component smallComponent)
	{
		this.smallComponent = smallComponent;
	}

	/**
	 * Gets the {@link java.awt.Shape} associated with a certain userobject.
	 *
	 * @return a <code>Shape</code> value
	 */
	public Shape getShape()
	{
		return this.shape;
	}

	/**
	 * Sets the {@link java.awt.Shape} associated with a certain userobject.
	 *
	 * @param shape a <code>Shape</code> value
	 */
	public void setShape(Shape shape)
	{
		this.shape = shape;
	}

        public String toString(){
                return((i5.cb.graph.cbeditor.CBUserObject)(this.diagramNode.getUserObject())).toString();
        }


}//DiagramClassHashTAbleEntry

