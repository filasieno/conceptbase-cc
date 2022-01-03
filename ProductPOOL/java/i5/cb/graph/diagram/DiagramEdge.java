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
package i5.cb.graph.diagram;

import i5.cb.graph.DiagramDesktop;
import i5.cb.graph.shapes.*;
import i5.cb.graph.zooming.Zoomable;

import java.awt.*;
import java.awt.geom.*;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.util.Vector;

import javax.swing.JComponent;

/**
 * This class represents the binary relations or edges between two
 * userObjects. It draws an edge between two {@link DiagramNode}s and
 * makes sure that the line lies somehow near the DiagramNode instance
 * that represents the this edge's userobject. It also moves this
 * DiagramNode if the source- or the destinationnode is moved
 *
 *
 * Created: Tue Dec 18 10:14:17 2001
 *
 * @author <a href="mailto:Tobias.Schoeneberg@epost.de">Tobias Schoeneberg</a>
 * @version 2.0
 */

public class DiagramEdge
    extends JComponent
    implements DiagramObject, PropertyChangeListener,Zoomable {

    private DiagramObject m_doSource;
    private DiagramObject m_doDest;
    private DiagramNode m_dnNodeOnEdge;
    private DiagramClass m_dc;

    //these 3 points store the position of the 3 nodes this edge has to
    //care about.
    private Point m_pCurrentCenter_source = null;
    private Point m_pCurrentCenter_dest = null;
    private Point m_pCurrentCenter_nodeOnEdge = null;

    boolean old_bHeightAbove = false;

    private Point m_DestArrowHeadPoint = null;  // point at the tip of the destination arrow head
    private Point m_SourceArrowHeadPoint = null;  // point at the tip of the source arrow head
    private Color m_DestArrowHeadBackgroundcolor = null;  // color of the point
    private Color m_SourceArrowHeadBackgroundcolor = null;  // color of the point

    //this is the shape that hold the edge's line going from m_doSource
    //to m_doDest
    private Shape m_sEdgeShape;

    //that's the shape's color
    private Color m_cEdgeColor;

    //that's the shape's head color
    private Color m_cEdgeHeadColor;



    //this rectangle's upperleft and lowerright are determined by
    //m_doSource and m_doDest (therefore it might differ a lot from the
    //result of this.getBounds()
    private Rectangle m_rBounds;

    private boolean m_bFixedPosition;

    //two shapes are placed on the two endpoints of the edgeline
    private Shape m_sSourceEdgeHead;  // not yet used!
    private Shape m_sDestEdgeHead;

    private BasicStroke m_sEdgeStroke;

    private String m_sEdgeStyle;

    private DiagramDesktop m_diagramDesktop;

    private AffineTransform m_atSourceEdgeHead;

    private AffineTransform m_atDestEdgeHead;


    ///-------------------------debug stuff begin
    /*
    //These Variables can be set in 'getEdgeShape_setCompBounds' and their location than can be drawn in the paint method
    private double m_controllPointX;
    private double m_controllPointY;
    private double m_edgeCenterX;
    private double m_edgeCenterY;
    */
    ///-------------------------debug stuff end

    /**
     * Creates a new diagramEdge with the provided diagramNode
     * The diagramNode's location is not changed
     */
    public DiagramEdge(
        DiagramNode nodeOnEdge,
        DiagramObject source,
        DiagramObject destination,
        DiagramClass diagramClass) {

        setNodeOnEdge(nodeOnEdge);
        initEdge(source, destination, diagramClass);

    }

    /**
     * Creates a diagramEdge with a new diagramNode using a provided userobject
     * the diagramNode's location is NOT set by this diagramClass.
     */
    public DiagramEdge(
        Object userObject,
        DiagramObject source,
        DiagramObject destination,
        DiagramClass diagramClass) {
        m_dnNodeOnEdge = new DiagramNode(userObject, diagramClass);
        setNodeOnEdge(m_dnNodeOnEdge);
        initEdge(source, destination, diagramClass);
    }

    private void initEdge(
        DiagramObject doSource,
        DiagramObject doDest,
        DiagramClass diagramClass) {
        assert((doSource != null) && (doDest != null));

        setSource(doSource);
        setDestination(doDest);
        m_dc = diagramClass;

        diagramClass.addUserAndDiagramObject(getUserObject(), getNodeOnEdge());

        m_cEdgeColor = diagramClass.getEdgeColor(getUserObject());
        m_cEdgeHeadColor = diagramClass.getEdgeHeadColor(getUserObject());
        m_sEdgeStroke = diagramClass.getEdgeStroke(getUserObject());
        m_sDestEdgeHead = diagramClass.getEdgeHeadShape(getUserObject());

/**
        if (m_sEdgeStroke.getLineWidth() < 2.5F) 
          m_sDestEdgeHead = new VeeArrow();  // thin edges get a slightly modified edge head
        else
          m_sDestEdgeHead = new Arrow();
**/

        // The arrow is initially dimensioned for an edge that has a width
        // of around 3 pixels. So, we enlarge/shrink it depending on the edge
        // width. 
	AffineTransform at = new AffineTransform();
        float scalefactor = m_sEdgeStroke.getLineWidth()/3.0F;
        if (scalefactor < 0.8F) 
          scalefactor = 0.8F;
	at.scale(scalefactor,scalefactor);

        if (m_sDestEdgeHead != null)
          m_sDestEdgeHead = at.createTransformedShape(m_sDestEdgeHead);

        m_pCurrentCenter_source = m_doSource.getNode().getCenter();
        m_pCurrentCenter_dest = m_doDest.getNode().getCenter();
        m_pCurrentCenter_nodeOnEdge = m_dnNodeOnEdge.getCenter();

        m_doSource.addEdge(this);

        m_doSource.getNode().addPropertyChangeListener(this);

        if (m_doDest != m_doSource) {
            m_doDest.addEdge(this);
            m_doDest.getNode().addPropertyChangeListener(this);
        }

        m_dnNodeOnEdge.addPropertyChangeListener(this);

        //The next lines calculate the bounds this edge would have
        m_rBounds = new Rectangle();
        m_rBounds = getEdgeBounds();

        getEdgeShape_setCompBounds();

        factor = oldFactor = 1f;
    } //<init>

    /**
     * Reload EdgeStroke and Edge color from DiagramClass
     */
    public void updateEdgeStroke() {
        m_cEdgeColor = this.getDiagramClass().getEdgeColor(getUserObject());
        m_cEdgeHeadColor = this.getDiagramClass().getEdgeHeadColor(getUserObject());
        m_sEdgeStroke = this.getDiagramClass().getEdgeStroke(getUserObject());
        m_DestArrowHeadBackgroundcolor = null; // needs to be recomputed 
    }


    /**
     * Computes the width of a the arrow head(s) of this edge. The width determines
     * how much space we need to paint the edge stroke including its heads.
     */
    public int getArrowWidth() {
       int edgeHeadWidthSource = 9; // heads are 3 times large than edgewidth, which defaults to 3
       int edgeHeadWidthDest = 9;
       if (m_sDestEdgeHead != null) {
         if (m_sDestEdgeHead.getBounds().height > m_sDestEdgeHead.getBounds().width)
           edgeHeadWidthDest = m_sDestEdgeHead.getBounds().height;
         else
           edgeHeadWidthDest = m_sDestEdgeHead.getBounds().width;
       }
       if (m_sSourceEdgeHead != null) {
         if (m_sSourceEdgeHead.getBounds().height > m_sSourceEdgeHead.getBounds().width)
           edgeHeadWidthSource = m_sSourceEdgeHead.getBounds().height;
         else
           edgeHeadWidthSource = m_sSourceEdgeHead.getBounds().width;
       }
      return Math.max(edgeHeadWidthSource,edgeHeadWidthDest);
    }


    // get the color at the background of the destination arrow head point
    public Color getDestArrowHeadBackgroundcolor() {
       if (m_DestArrowHeadBackgroundcolor == null) {
          int x = (int) (this.getX()+m_DestArrowHeadPoint.getX());
          int y = (int) (this.getY()+m_DestArrowHeadPoint.getY());
          Point p = new Point(x,y);
          m_DestArrowHeadBackgroundcolor = getDiagramDesktop().getBackgroundColorAt(p,m_doDest);
       }
       return m_DestArrowHeadBackgroundcolor;
    }




    public void setEdgeStroke(BasicStroke edgeStroke) {
        m_sEdgeStroke = edgeStroke;
    }
    //setEdgeStroke

    public Stroke getEdgeStroke() {
        return m_sEdgeStroke;
    }
    //getEdgeStroke

    void setNodeLocation(Point location) {
        m_dnNodeOnEdge.setLocation(location);
    } //setNodeOffset

    public Color getEdgeColor() {
        return m_cEdgeColor;
    } //getEdgeColor

    public void setEdgeColor(Color value) {
        m_cEdgeColor = value;
    }

    public Color getEdgeHeadColor() {
        return m_cEdgeHeadColor;
    }

    public void setEdgeHeadColor(Color value) {
        m_cEdgeHeadColor = value;
    }


    public void setEdgeStyle(String sStyle) {
        m_sEdgeStyle = sStyle;
    }

    public String getEdgeStyle() {
        return m_sEdgeStyle;
    }

    public DiagramObject getSource() {
        return m_doSource;
    } //getSource

    public void setSource(DiagramObject source) {
        m_doSource = source;
    }

    public DiagramObject getDestination() {
        return m_doDest;
    } //getDestination

    public void setDestination(DiagramObject destination) {
        m_doDest = destination;
    }

    public Object getUserObject() {
        return m_dnNodeOnEdge.getUserObject();
    }

    /*
    public void setUserObject(Object userObject) {
        m_dnNodeOnEdge.setUserObject(userObject);
    }//setUserObject
    */

    /**
     * Get the value of property m_dc (a DiagramClass).
     * @return value of m_dc.
     */
    public DiagramClass getDiagramClass() {
        return m_dc;
    }

    public boolean isReflexive() {
        return (m_doSource == m_doDest);
    } //isReflexive

    public DiagramDesktop getDiagramDesktop() {
        return m_diagramDesktop;
    } //getDiagramDesktop

    public void setDiagramDesktop(DiagramDesktop dd) {
        m_diagramDesktop = dd;

    }

    public void setPaintShapePolicy(int policy) {
        m_dnNodeOnEdge.setPaintShapePolicy(policy);
    }


    /**
     * Checks whether we need to call moveNode when a "location" change event occurred.
     * We normally always need to move the node upon such events. The only exception is when 
     * the getMovableDiagramNodeOnEdge flag is false (set by CBFrameWorker.validate) or
     * when the location is really different.
     *
     * @param evt the change event 
     * @return true if we need to move the node
     */

    private boolean needToMove(PropertyChangeEvent evt) {
        if (getDiagramDesktop() == null)  // can apparently occur when the edge is new!
          return true;
        boolean locChanged = true;
        if (evt.getSource() != null) {
          try {
             DiagramNode dn = (DiagramNode)evt.getSource();   // could be null or casting could fail
             Point newLoc = (Point)evt.getNewValue();        
             Point dnLoc = dn.getLocation();
             locChanged = !newLoc.equals(dnLoc);
           } catch (Exception e) {}  // forget about any exception
        }
        return (locChanged || getDiagramDesktop().getMovableDiagramNodeOnEdge());
    }

    /**
     * Set the edge middle point to the arithmetic center between
     * the source abd destination of this edge
     */
    public void straightenEdge() {
       if (!isReflexive() && m_pCurrentCenter_source != null &&
           m_pCurrentCenter_dest != null &&
           m_dnNodeOnEdge != null) {
         int newx = (int)Math.round((m_pCurrentCenter_source.x + m_pCurrentCenter_dest.x)/2.0);
         int newy = (int)Math.round((m_pCurrentCenter_source.y + m_pCurrentCenter_dest.y)/2.0);
         m_dnNodeOnEdge.setCenter(new Point(newx,newy));
         updateEdge();  // causes redrawing and setting the location of the nodon on edge
       }
    }

    /**
     * Adds a new DiagramEdge to the node sitting on this edge. This is
     * called by another diagramEdge instance if this edge is the source
     * or destination of this other edge
     *
     * @param edge the edge we are source or destination of.
     */
    final public void addEdge(DiagramEdge edge) {
        this.m_dnNodeOnEdge.addEdge(edge);
    }

    /**
     * Removes a diagramEdge by calling the removeEdge-method of the diagramNode sitting on this Edge
     *
     * @param e the egde to be removed
     * @return the result of DiagramNode.removeEdge(e)
     */
    public boolean removeEdge(DiagramEdge e) {
        return m_dnNodeOnEdge.removeEdge(e);
    }

    /**
     * Returns a vector containing the edges this edge is source or destination of.
     * The result is similar to the result of <code>this.getnode().getEdges()</code>
     *
     * @return a <code>Vector</code> value containing the edges this edge is source or destination of.
     */
    public Vector getEdges() {
        return this.m_dnNodeOnEdge.getEdges();
    }

    /**
     * Removes this DiagramEdge from the diagramDesktop. The Nodes that
     * are connected by this edge are not removed.
     */
    public void erase() {
        m_dc.remove(this.getUserObject());
        getDiagramDesktop().remove(this);
        m_doSource.removeEdge(this);
        m_doDest.removeEdge(this);

        m_doSource.getNode().removePropertyChangeListener(this);
        m_doDest.getNode().removePropertyChangeListener(this);
        m_dnNodeOnEdge.getNode().removePropertyChangeListener(this);
        m_diagramDesktop=null;
    }

    /**
     * Tells whether this edge's component is visible or not.The result
     * is similar to the result of
     * <code>this.getnode().isComponentVisible()</code>
     *
     * @return a <code>boolean</code> value
     */
    public boolean isComponentVisible() {
        return this.m_dnNodeOnEdge.isComponentVisible();
    } //isComponentVisible

    /**
     * Makes this edge's component (which is actually the Component of
     * this edge's node) visible on the desktop The result is similar to
     * the result of <code>this.getnode().setComponentVisible</code>
     *
     * @return false iff the component is null
     */
    public boolean setComponentVisible() {
        return this.m_dnNodeOnEdge.setComponentVisible();
    } //setComponentVisible

    /**
     * Tells whether this edge's smallComponent is visible or not
     *
     * @return a <code>boolean</code> value
     */
    public boolean isSmallComponentVisible() {
        return this.m_dnNodeOnEdge.isSmallComponentVisible();
    } //isSmallComponentVisible

    /**
     * Makes this edge's smallComponent (which is actually the
     * smallComponent of this edge's node) visible on the desktop The
     * result is similar to the result of
     * <code>this.getnode().setSmallComponentVisible</code>
     *
     * @return false iff the smallComponent is null
     */
    public boolean setSmallComponentVisible() {
        return this.m_dnNodeOnEdge.setSmallComponentVisible();
    }

    /**
     * Returns a shape containing both this edge's shape and the
     * shape of the node sitting in this edge
     *
     * @return a <code>Shape</code> value
     */
    public Shape getShape() {
        Area a = new Area(m_sEdgeShape);
        a.add(m_dnNodeOnEdge.getArea());
        return a;
    }

    /**
     * Tells whether this edge is moveable or not
     *
     * @return the value of bFixedPosition
     */
    final public boolean hasFixedPosition() {
        return m_bFixedPosition;
    }

    final public void setFixedPosition(boolean fixedPosition) {
        m_bFixedPosition = fixedPosition;
    }

    //------------------------the following part concerns with Painting the Edge and moveing the node on it-------------------

    /**
     * Decides if the DiagramEdges's edgeline and the position of
     * m_dnNodeOnEdge is still up to date and corrects them if neccessary
     *
     * @return a <code>boolean</code> value. True if the edge didn't have to be updated, false otherwise.
     */
    private boolean updateEdge() {

        if (m_doSource.getNode().getCenter().equals(m_pCurrentCenter_source)
            && m_doDest.getNode().getCenter().equals(m_pCurrentCenter_dest)
            && m_dnNodeOnEdge.getCenter().equals(m_pCurrentCenter_nodeOnEdge)
            && m_sEdgeShape != null) {
            //	java.util.logging.Logger.getLogger("global").fine("Returning without change");
            return true;
        } else {

            //debugging stuff
            m_pCurrentCenter_nodeOnEdge = m_dnNodeOnEdge.getCenter();

            if (Double.isNaN(m_pCurrentCenter_nodeOnEdge.x)
                || Double.isNaN(m_pCurrentCenter_nodeOnEdge.y)) {
                java.util.logging.Logger.getLogger("global").fine("NaN");

            } // end of if (Double.isNaN(m_pCurrentCenter_nodeOnEdge.x) || Double.isNaN(m_pCurrentCenter_nodeOnEdge))

            getEdgeBounds();
            getEdgeShape_setCompBounds();

            return false;
        } // end of else
    } //updateEdge

    private Rectangle getEdgeBounds() {

        Point pSourceCenter = m_doSource.getNode().getCenter();
        Point pDestCenter = m_doDest.getNode().getCenter();

        int dX, dY, dH, dW;

        dX = Math.min(pSourceCenter.x, pDestCenter.x);
        dY = Math.min(pSourceCenter.y, pDestCenter.y);
        dW = Math.max(pSourceCenter.x, pDestCenter.x) - dX;
        dH = Math.max(pSourceCenter.y, pDestCenter.y) - dY;

        m_rBounds.setRect(dX, dY, dW, dH);

        return m_rBounds;
    } //getEdgeBounds

    /**
     * Calculates the edgeline for this edge such that it goes from
     * m_doSource to m_doDest passing below m_dnNodeOnEdge
     *
     * @param pSource a <code>Point2D.Double</code> value
     * @param pDest a <code>Point2D.Double</code> value
     * @param pNodeOnEdge a <code>Point2D.Double</code> value
     * @return a <code>Shape</code> value
     */
    private Shape getEdgeShape_setCompBounds() {

        double sourceX = m_doSource.getNode().getCenter().x;
        double sourceY = m_doSource.getNode().getCenter().y;
        double destX = m_doDest.getNode().getCenter().x;
        double destY = m_doDest.getNode().getCenter().y;

        double edgeCenterX = m_rBounds.x + 0.5 * m_rBounds.width;
        double edgeCenterY = m_rBounds.y + 0.5 * m_rBounds.height;

        //nodex and nodeY contain the offset from the edge's center.

        if (isReflexive()) {

            double nodeX = m_dnNodeOnEdge.getCenter().x;
            double nodeY = m_dnNodeOnEdge.getCenter().y;

            double controllPoint1X =
                -1.0 / 3.0 * sourceX
                    + 4.0 / 3.0 * nodeY
                    + 4.0 / 3.0 * nodeX
                    - 4.0 / 3.0 * sourceY;
            double controllPoint1Y =
                -1.0 / 3.0 * sourceY
                    + 4.0 / 3.0 * sourceX
                    + 4.0 / 3.0 * nodeY
                    - 4.0 / 3.0 * nodeX;
            double controllPoint2X =
                -1.0 / 3.0 * sourceX
                    - 4.0 / 3.0 * nodeY
                    + 4.0 / 3.0 * nodeX
                    + 4.0 / 3.0 * sourceY;
            double controllPoint2Y =
                -1.0 / 3.0 * sourceY
                    - 4.0 / 3.0 * sourceX
                    + 4.0 / 3.0 * nodeY
                    + 4.0 / 3.0 * nodeX;

            CubicCurve2D.Double cubic = new CubicCurve2D.Double();

            cubic.setCurve(
                sourceX,
                sourceY,
                controllPoint1X,
                controllPoint1Y,
                controllPoint2X,
                controllPoint2Y,
                destX,
                destY);

            this.setBounds(cubic.getBounds());

            m_sEdgeShape = cubic;

        } // end of if (isReflexive)
        else {

            double nodeX = m_dnNodeOnEdge.getCenter().x - edgeCenterX;
            double nodeY = m_dnNodeOnEdge.getCenter().y - edgeCenterY;

            double controllPointX = (sourceX + destX + 5.0 * nodeX) / 2.0;
            double controllPointY = (sourceY + destY + 5.0 * nodeY) / 2.0;


            /*
            m_controllPointX = controllPointX;
            m_controllPointY = controllPointY;
            */

            //here we add a linear correction for the controllpoint gets to far away from the edge's center
            double dist_center_controllpX = edgeCenterX - controllPointX;
            double dist_center_controllpY = edgeCenterY - controllPointY;
            double factor = 0.2;

            controllPointX += dist_center_controllpX * factor;
            controllPointY += dist_center_controllpY * factor;

            QuadCurve2D.Double quad = new QuadCurve2D.Double();

            quad.setCurve(
                destX,
                destY,
                controllPointX,
                controllPointY,
                sourceX,
                sourceY);
            
            Rectangle r = quad.getBounds();


            // correct the dimension of the bounding rectangle
            int d = getArrowWidth();  // minimum width for the painting the edge including its heads

            // extend the width or height to be able to paint at the whole edge head
            // the relocation of r.x,r.y needs to be compensated in DiagramEdge.paint()
            r.x = r.x - d;
            r.y = r.y - d;
            r.width = r.width + 2*d;
            r.height = r.height + 2*d;

            this.setBounds(r);

            m_sEdgeShape = quad;

        }
        assert m_sEdgeShape

            != null : "DiagramEdge.getEdgeShape_setCompBounds : m_sEdgeShape == null";
        assert this.getBounds()
            != null : "DiagramEdge.getEdgeShape_setCompBounds: this.bounds == null";

        return m_sEdgeShape;

    } //getEdgeShape_setCompBounds

    /**
     * @return an edge from {@link #m_doSource} to {@link
     * #m_doDest} that passes through {@link
     * #m_dnNodeOnEdge}
     *
     */
    public Shape getEdgeShape() {
        updateEdge();
        return m_sEdgeShape;
    } //getEdgeShape

    public void setEdgeShape(Shape value) {
        m_sEdgeShape = value;
    }

    private double getAlpha(Point2D pA, Point2D pB, Point2D pC) {

        double dSideASq, dSideBSq, dSideCSq, dSideC, dSideB;

        dSideASq = pB.distanceSq(pC); //getDistance(pB, pC);
        dSideBSq = pC.distanceSq(pA); //GetDistance(pA, pC);
        dSideCSq = pA.distanceSq(pB); //GetDistance(pA, pB);

        dSideC = pB.distance(pA);
        dSideB = pC.distance(pA);

        // Here I use the cosine..aeh..theoreme!
        return Math.acos(
            (dSideASq - dSideCSq - dSideBSq) / (-2 * dSideC * dSideB));
    } //getAlpha

    /*
    private Point2D getNearest(PathIterator pi, Point2D point){
      if (pi.isDone() )
        return null;

      Point2D.Double pNearest =  new Point2D.Double(Double.POSITIVE_INFINITY, Double.POSITIVE_INFINITY);
      double[] points = new double[6];
      while (!pi.isDone()) {
        pi.currentSegment(points);

        if (point.distance(points[0],points[1])
     < point.distance(pNearest)) {

    pNearest.setLocation(points[0],points[1]);

        } // end of if (m_pCurrentCenter_nodeOnEdge.distan..

        pi.next();

      } // end of while (!piInterSectionPoints.isDone())

      return pNearest;
    }
     */

    private Point2D getFarest(PathIterator pi, Point2D point) {
        if (pi.isDone()) {
            //java.util.logging.Logger.getLogger("global").fine("DiagramEdge.getFarest: pi was already done");

            return null;
        }
        Point2D.Double pFarest = new Point2D.Double(point.getX(), point.getY());
        double[] points = new double[6];
        while (!pi.isDone()) {
            pi.currentSegment(points);
            //java.util.logging.Logger.getLogger("global").fine("DiagramEdge.getFarest: point = "+point+"; points = ["+Math.round(points[0])+","+Math.round(points[1])+"]; distance: "+ point.distance(points[0],points[1]) );
      
            if (point.distance(points[0], points[1])
                > point.distance(pFarest)) {
                pFarest.setLocation(points[0], points[1]);
            } // end of if (m_pCurrentCenter_nodeOnEdge.distan..
            pi.next();

        } // end of while (!piInterSectionPoints.isDone())
      
        //java.util.logging.Logger.getLogger("global").fine("DiagramEdge.getFarest: pFarest: "+pFarest);
        return pFarest;

    } //getFarest

    /**
     * Places the edgehead for the specified DiagramObject, which is either m_doSource or m_doDest
     *
     * @param doObj a <code>DiagramObject</code> value
     */
    private AffineTransform placeEdgeHead(DiagramObject doObj) {
        if (this.getDiagramDesktop() == null) {
            return null;
        }

        DiagramNode dnNode;
        if (doObj instanceof DiagramEdge) {
            dnNode = ((DiagramEdge) doObj).getNodeOnEdge();
        } // end of if (do instanceof DiagramEdge)
        else {
            dnNode = (DiagramNode) doObj;
        } // end of else
        //stroke is needed to create a shape from an area
        BasicStroke stroke =
            new BasicStroke(1, BasicStroke.CAP_SQUARE, BasicStroke.JOIN_MITER);

        //We translate the node's area from the diagramDesktop's
        //coordinatespace to the edge's coordinatespace
        AffineTransform at = new AffineTransform();
        at.translate(
            - (double) this.getBounds().x,
            - (double) this.getBounds().y);

        Area arNode = new Area(at.createTransformedShape(dnNode.getShape()));

        Point2D pCenterNode = at.transform(dnNode.getCenter(), null);

        //the whole curve
        Shape sWorkingWhole = null;
        double dEdgeHeadLength = 0;

        //the following if-block determines which edgehead we shall draw
        //(m_sSourceEdgehead or m_sDestEdgeHead) and creates the two
        //shapes for sWorkingWhole and sWorkingHalf
        if (m_sEdgeShape instanceof QuadCurve2D) {
            if (doObj == m_doDest) {
                //( (QuadCurve2D)m_sEdgeShape).subdivide(curve, null);
                dEdgeHeadLength = m_sDestEdgeHead.getBounds2D().getWidth();
            } // end of if (doObj == m_doDest)
            else {
                //( (QuadCurve2D)m_sEdgeShape).subdivide(null, curve);
                dEdgeHeadLength = m_sSourceEdgeHead.getBounds2D().getWidth();
            } // end of else

            //sWorkingHalf =  at.createTransformedShape(stroke.createStrokedShape(curve) );
            sWorkingWhole =
                at.createTransformedShape(
                    stroke.createStrokedShape(m_sEdgeShape));
        } // end of if (m_sEdgeShape instanceof QuadCurve2D)
        else {

            CubicCurve2D.Double cubic = new CubicCurve2D.Double();
            if (doObj == m_doDest) {
                ((CubicCurve2D) m_sEdgeShape).subdivide(cubic, null);
                dEdgeHeadLength = m_sDestEdgeHead.getBounds2D().getWidth();
            } // end of if (doObj == m_doDest)
            else {
                //( (CubicCurve2D)m_sEdgeShape).subdivide(null, cubic);
                dEdgeHeadLength = m_sSourceEdgeHead.getBounds2D().getWidth();
            } // end of else

            //sWorkingHalf =  at.createTransformedShape(stroke.createStrokedShape(cubic) );
            sWorkingWhole =
                at.createTransformedShape(
                    stroke.createStrokedShape(m_sEdgeShape));
        } // end of else

        //Area nodeEdgeIntersect = new Area(sWorkingHalf);
        Area nodeEdgeIntersect = new Area(sWorkingWhole);

        //nodeEdgeIntersect now is the intersection between the node's and the edgeline's area
        nodeEdgeIntersect.intersect(
            new Area(stroke.createStrokedShape(arNode)));

        Point2D pWorkPoint = null;

        pWorkPoint =
            getFarest(nodeEdgeIntersect.getPathIterator(null), pCenterNode);

        if (pWorkPoint == null) {
            return null;
        }

        Point pEdgeHead1 =
            new Point(
                (int) Math.round(pWorkPoint.getX()),
                (int) Math.round(pWorkPoint.getY()));
        assert pEdgeHead1
            != null : "DiagramEdgde.drawEdgeHead: pEdgehead1==null";
        //-------Now we look for the second point------//

        //this create a circle having the radius of the edgehead's length
        Area aCircle =
            new Area(
                stroke.createStrokedShape(
                    new Ellipse2D.Double(
                        pEdgeHead1.x - dEdgeHeadLength,
                        pEdgeHead1.y - dEdgeHeadLength,
                        dEdgeHeadLength * 2,
                        dEdgeHeadLength * 2)));

        aCircle.intersect(new Area(sWorkingWhole));

        pWorkPoint = getFarest(aCircle.getPathIterator(null), pCenterNode);
        if (pWorkPoint == null) {
            return null;
        }
        Point pEdgeHead2 =
            new Point(
                (int) Math.round(pWorkPoint.getX()),
                (int) Math.round(pWorkPoint.getY()));

        if (!pEdgeHead1.equals(m_DestArrowHeadPoint))
           m_DestArrowHeadBackgroundcolor = null;  // old color is potetially invalid
        m_DestArrowHeadPoint = pEdgeHead1; // memorize the distant corner of the edge head
        at.setToIdentity();

        double dAlpha =
            getAlpha(
                pEdgeHead1,
                pEdgeHead2,
                new Point(pEdgeHead1.x + 1, pEdgeHead1.y));
        if (pEdgeHead2.y < pEdgeHead1.y) {
            dAlpha *= -1;
        } // end of if (pEdgeHead2.x > pEdgeHead1.x)

        at.translate(pEdgeHead1.x, pEdgeHead1.y);
        at.rotate(dAlpha);

        return at;
    } //drawEdgeHead

    /**
     * This method moves {@link DiagramEdge#m_dnNodeOnEdge} on the
     * {@link i5.cb.graph.DiagramDesktop} if {@link
     * DiagramEdge#m_doSource} or {@link DiagramEdge#m_doDest} is
     * dragged by the user while the other one stays fixed. The new
     * position consits actually of two components: First m_dnNodeOnEdge
     * is rotated around the fixed node the same angle as the dragged
     * node is. Secondly m_dnNode on edge is moved on a line which is
     * parallel to the line between m_doSource and m_doDest.
     * The main problem implementing this seems to be the lack of precision...
     * How does it work?
     *
     */
    private void moveNode() {
        if (Double.isNaN(m_pCurrentCenter_nodeOnEdge.x)
            || Double.isNaN(m_pCurrentCenter_nodeOnEdge.y)) {
            java.util.logging.Logger.getLogger("global").fine("NaN");

        }
        if (m_diagramDesktop != null
            && m_diagramDesktop.isInSelectedGroup(m_dnNodeOnEdge)) {
//			Logger.getLogger("global").fine(
//				"Node '"
//					+ m_dnNodeOnEdge.getUserObject().toString()
//					+ "' is in selected group and thus not moved here.");
            return;
        }
        if(m_pCurrentCenter_source.equals(m_doSource.getNode().getCenter())
        	&&m_pCurrentCenter_dest.equals(m_doDest.getNode().getCenter())){
        	return;        
        }

        if (m_dnNodeOnEdge.isFrozen()) 
          return;

        if (isReflexive()) {
            //java.util.logging.Logger.getLogger("global").fine(
            //	"Moving a node on a reflexive edge");
            Point pCurrentCenter_nodeOnEdge = m_dnNodeOnEdge.getCenter();
            java.awt.Point pNodeCenter = null;

            pNodeCenter = m_doDest.getNode().getCenter();

            Point pDelta =
                new Point(
                    (int) Math.round(m_pCurrentCenter_dest.getX())
                        - pNodeCenter.x,
                    (int) Math.round(m_pCurrentCenter_dest.getY())
                        - pNodeCenter.y);
            //java.util.logging.Logger.getLogger("global").fine("DiagramEdge.moveNode: pCurrentLoc_destNode: "+pCurrentLoc_destNode+"; m_pCurrentCenter_descvct: "+m_pCurrentCenter_dest+"; Delta: "+pDelta);

            //of course source and dest have the same center
            m_pCurrentCenter_dest =
                m_pCurrentCenter_source = m_doDest.getNode().getCenter();
            // getDiagObjectCenter(m_doDest);

            m_dnNodeOnEdge.setCenter_DontFire(
                new Point(
                    pCurrentCenter_nodeOnEdge.x - pDelta.x,
                    pCurrentCenter_nodeOnEdge.y - pDelta.y));
            return;
        } // end of if (isReflexive())

        //the distance between m_doSource and m_dnNodeOnEdge BEFORE the user's dragging-operation
        double dOldDist_Source_NodeOnEdge =
            m_pCurrentCenter_source.distance(m_pCurrentCenter_nodeOnEdge);

        //the distance between m_doDest and m_dnNodeOnEdge BEFORE the user's dragging-operation
        double dOldDist_Dest_NodeOnEdge =
            m_pCurrentCenter_dest.distance(m_pCurrentCenter_nodeOnEdge);

        //the distance between m_doSource and m_doDest BEFORE the user's dragging-operation
        double dOldDist_Source_Dest =
            m_pCurrentCenter_source.distance(m_pCurrentCenter_dest);

        //Looking at the triangle defined by the three nodes' centers this
        //is the angle at m_pCurrentCenter_source
        double dAngle_source =
            getAlpha(
                m_pCurrentCenter_source,
                m_pCurrentCenter_dest,
                m_pCurrentCenter_nodeOnEdge);

        //Looking at the triangle defined by the three nodes' centers this
        //is the angle at m_pCurrentCenter_dest
        double dAngle_dest =
            getAlpha(
                m_pCurrentCenter_dest,
                m_pCurrentCenter_source,
                m_pCurrentCenter_nodeOnEdge);

        //the height (a line that is right-angled to the line from
        //m_doSource to m_doDest and starts at the m_dnNodeOnEdge's
        //center) Though the height should of of corse be the same no
        //matter from which point (source or dest) it is seen we computer
        //the average value to be shure.

        //the distance of m_pCurrentCenter_source from the point where the
        //height and the line between source and dest meet
        double dOldDist_Source_Height =
            Math.cos(dAngle_source) * dOldDist_Source_NodeOnEdge;

        final double dHeightLength =
            Math.sqrt(
                Math.pow(dOldDist_Source_NodeOnEdge, 2)
                    - Math.pow(dOldDist_Source_Height, 2));

        //A kind of vector having a length of one and the same direction
        //as an arrow pointing from source to dest
        final Point2D.Double pOldSource_Dest_Direction =
            new Point2D.Double(
                (m_pCurrentCenter_dest.x - m_pCurrentCenter_source.x)
                    / dOldDist_Source_Dest,
                (m_pCurrentCenter_dest.y - m_pCurrentCenter_source.y)
                    / dOldDist_Source_Dest);

        //the direction of height (pointing from the side between source
        //and dest to m_pCurrentCenter_nodeOnEdge)
        Point2D.Double pDir_Height;

        //due to a bug in the jvm (1.4.0) we have to copy the members
        //values to tempoary vars to prevend some of them from becoming NaN
        if (dHeightLength != 0.0) {
            double m_pCurrentCenter_nodeOnEdgex = m_pCurrentCenter_nodeOnEdge.x;

            double m_pCurrentCenter_nodeOnEdgey = m_pCurrentCenter_nodeOnEdge.y;

            double m_pCurrentCenter_sourcex = m_pCurrentCenter_source.x;

            double m_pCurrentCenter_sourcey = m_pCurrentCenter_source.y;

            double pOldSource_Dest_Directionx = pOldSource_Dest_Direction.x;

            double pOldSource_Dest_Directiony = pOldSource_Dest_Direction.y;

            pDir_Height =
                new Point2D.Double(
                    (m_pCurrentCenter_nodeOnEdgex
                        - m_pCurrentCenter_sourcex
                        - pOldSource_Dest_Directionx * dOldDist_Source_Height)
                        / dHeightLength,
                    (m_pCurrentCenter_nodeOnEdgey
                        - m_pCurrentCenter_sourcey
                        - pOldSource_Dest_Directiony * dOldDist_Source_Height)
                        / dHeightLength);
        } // end of if (dHeightLength != 0.0)
        else {
            pDir_Height = new Point2D.Double(0.0, 0.0);
        } // end of else

        //tells if the angle between pOldSource_Dest_Direction and pDir_Height is 90 or 270 degrees

        int xh = (int) (pDir_Height.x * 100);
        int yh = (int) (pOldSource_Dest_Direction.y * 100);

        boolean bHeightAbove = (yh == - xh);

        // special case: value 0,100,-100 lead to wrong values of bHeightAbove; 
        // then take the previous value old_bHeightAbove; ticket #407

        if (yh != 0 && xh != 100 && xh != -100 && yh != 100 && yh != -100) {
           old_bHeightAbove = bHeightAbove;
        } else {
           bHeightAbove = old_bHeightAbove;
        }
        // System.out.println(xh + " - " + yh);

        //the distance of m_pCurrentCenter_dest from the point where the
        //height and the line between source and dest meet
        double dOldDist_Dest_Height =
            Math.cos(dAngle_dest) * dOldDist_Dest_NodeOnEdge;

        //Now we can calculate new values:
        double dNewDist_Source_Dest =
            m_doSource.getNode().getCenter().distance(
                m_doDest.getNode().getCenter());

        //the new value is calculated in a way that the ratio between the
        //distance from source and the distance from dest remains the same
        double dNewDist_Source_Height =
            (dOldDist_Source_Height * dNewDist_Source_Dest)
                / (dOldDist_Source_Height + dOldDist_Dest_Height);

        Point2D.Double pNewDir_Source_Dest =
            new Point2D.Double(
                (m_doDest.getNode().getCenter().x
                    - m_doSource.getNode().getCenter().x)
                    / dNewDist_Source_Dest,
                (m_doDest.getNode().getCenter().y
                    - m_doSource.getNode().getCenter().y)
                    / dNewDist_Source_Dest);
        // now the new vector from the line between
        //source and dest and the nodeOnEdge is calculated. It's as long
        //as the old one was and it has the same angle from
        //pNewDir_Source_Dest as the old one had from pOldDir_Source_Dest
        
    		
        	pDir_Height.x = pNewDir_Source_Dest.y;
            pDir_Height.y = pNewDir_Source_Dest.x;
            if (bHeightAbove) {
                pDir_Height.x *= -1;
            } // end of if (bHeightAbove)
            else {
                pDir_Height.y *= -1;
            } // end of else

    	
        if (Double.isNaN(m_pCurrentCenter_nodeOnEdge.x)
            || Double.isNaN(m_pCurrentCenter_nodeOnEdge.y)) {
            java.util.logging.Logger.getLogger("global").fine("NaN");

        } // end of if ((m_pCurrentCenter_nodeOnEdge.x == Double.NaN) !!( m_pCurrentCenter_nodeOnEdge.y == Double.NaN))

        //finally the new position of nodeOnEdge is calculated from the
        //position of source, the line from source to dest (having the
        //length of dNewDist_Source_Height) and pDir_Height (having the
        //lenght it had before)
        m_pCurrentCenter_nodeOnEdge.x =
            m_doSource.getNode().getCenter().x
                + (int) Math.round(
                    pNewDir_Source_Dest.x * dNewDist_Source_Height
                        + pDir_Height.x * dHeightLength);
        m_pCurrentCenter_nodeOnEdge.y =
            m_doSource.getNode().getCenter().y
                + (int) Math.round(
                    pNewDir_Source_Dest.y * dNewDist_Source_Height
                        + pDir_Height.y * dHeightLength);
        if(m_pCurrentCenter_nodeOnEdge.equals(m_doSource.getNode().getCenter())){
        	m_pCurrentCenter_nodeOnEdge.x = (m_doSource.getNode().getCenter().x+m_doDest.getNode().getCenter().x)/2;
        	m_pCurrentCenter_nodeOnEdge.y = (m_doSource.getNode().getCenter().y+m_doDest.getNode().getCenter().y)/2;
        }
        Point newPoint =
            new Point(
                m_pCurrentCenter_nodeOnEdge.x,
                m_pCurrentCenter_nodeOnEdge.y);

        m_pCurrentCenter_source = m_doSource.getNode().getCenter();
        m_pCurrentCenter_dest = m_doDest.getNode().getCenter();

        m_dnNodeOnEdge.setCenter_DontFire(newPoint);
    } //moveNode


    public void updateManually(){
    	updateEdge();
    	m_pCurrentCenter_source = m_doSource.getNode().getCenter();
    	m_pCurrentCenter_dest = m_doDest.getNode().getCenter();
    	m_pCurrentCenter_nodeOnEdge = m_dnNodeOnEdge.getCenter();
    	 if (m_sDestEdgeHead != null) {
            m_atDestEdgeHead = placeEdgeHead(m_doDest);
        }
        if (m_sSourceEdgeHead != null) {
            m_atSourceEdgeHead = placeEdgeHead(m_doSource);
        }
    }





    public void paint(Graphics g1) {
          assert(
            m_sEdgeShape != null) : "DiagramEdge.paint: m_sEdgeShape == null";

        Graphics2D g = (Graphics2D)g1;

        boolean normalPaint = (!m_dnNodeOnEdge.isDragged() ||     // highlight the dragged edge
                               (getArrowWidth() < 15));           // if it is rather wide


        // set highest rendering quality
        if (getDiagramDesktop() != null) {
          if (getDiagramDesktop().useSmoothLines()) {
             RenderingHints renderHints = new RenderingHints(RenderingHints.KEY_ANTIALIASING,
                                                             RenderingHints.VALUE_ANTIALIAS_ON);
             renderHints.put(RenderingHints.KEY_RENDERING,
                             RenderingHints.VALUE_RENDER_QUALITY);
             g.setRenderingHints(renderHints);
          } else {
             g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                                RenderingHints.VALUE_ANTIALIAS_OFF);
          }
        }

        g.setColor(getEdgeColor());

        ///-----------------debug begin
        /*
        g.drawRect( (int)m_edgeCenterX-m_sEdgeShape.getBounds().x, (int)m_edgeCenterY-m_sEdgeShape.getBounds().y, 1, 1);
        g.drawRect((int)m_controllPointX-m_sEdgeShape.getBounds().x, (int)m_controllPointY-m_sEdgeShape.getBounds().y, 1, 1);
        g.drawLine((int)m_edgeCenterX-m_sEdgeShape.getBounds().x,(int)m_edgeCenterY-m_sEdgeShape.getBounds().y ,(int)m_controllPointX-m_sEdgeShape.getBounds().x ,(int)m_controllPointY-m_sEdgeShape.getBounds().y);
        */
        ///----------------debug end

        //This at is needed to translate the shape's position from the
        //DiagramDesktops coordinatespace to the diagramEdge's
        AffineTransform at = new AffineTransform();
        if (isReflexive()) {
           at.translate(-m_sEdgeShape.getBounds().x, -m_sEdgeShape.getBounds().y);
        }
        else {
           // we have shifted the bounding rectangle before by getArrowWidth() to the left and to the top
           // this has to be compensated here for painting the edge shape
           at.translate(-m_sEdgeShape.getBounds().x+getArrowWidth(), -m_sEdgeShape.getBounds().y+getArrowWidth());
        }

        // if the edge has a head, but the corresponding AffineTransform object has not yet been
        // created, then create it now
        if (m_sSourceEdgeHead != null && m_atSourceEdgeHead == null) {
            m_atSourceEdgeHead = placeEdgeHead(m_doSource);
        }
        if (m_sDestEdgeHead != null && m_atDestEdgeHead == null) {
            m_atDestEdgeHead = placeEdgeHead(m_doDest);  
        }


        // first draw the edge itself
        if (normalPaint)
          g.fill(at.createTransformedShape(m_sEdgeStroke.createStrokedShape(m_sEdgeShape)));
        else
          g.draw(at.createTransformedShape(m_sEdgeStroke.createStrokedShape(m_sEdgeShape)));

        // then the source head (mostly null)
        if (m_atSourceEdgeHead != null) {
            if (normalPaint)
              g.fill(m_atSourceEdgeHead.createTransformedShape(m_sSourceEdgeHead));
            else
              g.draw(m_atSourceEdgeHead.createTransformedShape(m_sSourceEdgeHead));
        }


        // draw a background color circle around the arrow head peak to overwrite the edge stroke there
        if (m_DestArrowHeadPoint != null) {
          g.setColor(getDestArrowHeadBackgroundcolor());
          g.fillOval(m_DestArrowHeadPoint.x-6,m_DestArrowHeadPoint.y-6,13,13);
          
        }

        // then the destination head
        if (m_atDestEdgeHead != null) {
            if ( !getEdgeHeadColor().equals(getEdgeColor()) ) {
              // head color is different from edge color
              g.setColor(getEdgeHeadColor());
              g.fill(m_atDestEdgeHead.createTransformedShape(m_sDestEdgeHead));
              g.setColor(getEdgeColor());
              g.draw(m_atDestEdgeHead.createTransformedShape(m_sDestEdgeHead));
            }
            else {
              g.setColor(getEdgeColor());
              g.fill(m_atDestEdgeHead.createTransformedShape(m_sDestEdgeHead));
            }
        }


    } //paint

    /** Getter for property dnNodeOnEdge.
     * @return Value of property dnNodeOnEdge.
     */
    public DiagramNode getNodeOnEdge() {
        return m_dnNodeOnEdge;
    }

    /** Setter for property dnNodeOnEdge.
     * @param dnNodeOnEdge New value of property dnNodeOnEdge.
     */

    public void setNodeOnEdge(DiagramNode dnNodeOnEdge) {
        m_dnNodeOnEdge = dnNodeOnEdge;
        if (dnNodeOnEdge.getDiagramEdge() != this) {
            dnNodeOnEdge.setDiagramEdge(this);
        };
    }

    public void propertyChange(PropertyChangeEvent evt) {
        String sPropertyName = evt.getPropertyName();

        if (m_sDestEdgeHead != null) {
            m_atDestEdgeHead = placeEdgeHead(m_doDest);
        }
        if (m_sSourceEdgeHead != null) {
            m_atSourceEdgeHead = placeEdgeHead(m_doSource);
        }
        if (sPropertyName.equals("location")) {
            updateEdge();
            if (needToMove(evt)) {
              moveNode();
            }
        } // end of if
        
        if (sPropertyName.equals("setDirectly")){
        	updateManually();
        }
        //java.util.logging.Logger.getLogger("global").fine("DiagramEdge.propertyChange: location");
        if (isShown()) {
            getDiagramDesktop().repaint();
        }

        if (sPropertyName.equals("size")) {
            //java.util.logging.Logger.getLogger("global").fine("DiagramEdge.propertyChange: size");
            if (isShown()) {
                getDiagramDesktop().repaint();
            }
        }
    } //propertyChange

    /**
     * The same as property getter 'getNodeOnEdge'. Implements the interface
     */
    public DiagramNode getNode() {
        return getNodeOnEdge();
    }

    /*
     * Tells if the edge has already been added to the diagramdesktop
     */
    public boolean isShown() {
        return m_diagramDesktop != null;
    }

    /**
     * Gets a node's (must be source- or destinationnode of this edge) peer.
     *
     *@param diagObj the source- or destination-diagramObject of this edge.
    * @return the edges sourcediagObject node if 'diagObj' is the edge's destination and the destination if 'diagObj' is the source
     */
    public DiagramObject getPeer(DiagramObject diagObj) {
        DiagramObject oldDO=null;
        if(diagObj instanceof DiagramNode) {
            DiagramNode dn=(DiagramNode) diagObj;
            if(dn.isOnEdge()) {
                oldDO=diagObj;
                diagObj=dn.getDiagramEdge();
            }
        }
        if (diagObj == m_doDest || oldDO == m_doDest) {
            return m_doSource;
        }
        else if(diagObj == m_doSource || oldDO == m_doSource) {
            return m_doDest;
        }
        else {
            throw new Error("DiagramEdge.getPeer:" + diagObj.getUserObject().toString() + " is not source or destination of " + this.getUserObject().toString());
        }
    } //getPeer

	/* (non-Javadoc)
	 * @see i5.cb.graph.zooming.Zoomable#setZoom(float)
	 */
	public void setZoom(float factor) {
		setOldFactor(this.factor);
		setFactor(factor);
		// zoom EdgeHead
		AffineTransform at = new AffineTransform();
		at.scale(factor/oldFactor,factor/oldFactor);
		if (m_sSourceEdgeHead != null)
			m_sSourceEdgeHead = at.createTransformedShape(m_sSourceEdgeHead);
		if (m_sDestEdgeHead != null)
			m_sDestEdgeHead = at.createTransformedShape(m_sDestEdgeHead);
		//zoom edge stroke
		float newWidth = m_sEdgeStroke.getLineWidth() * (factor/oldFactor);
		
                if (m_sEdgeStroke.getDashArray() == null) {
		   m_sEdgeStroke = new BasicStroke(newWidth,m_sEdgeStroke.getEndCap(),m_sEdgeStroke.getLineJoin());
                } else { // issue #10: keep the dash parameters originally from 'edgestyle' parameter when zooming
		   float[] dasharray = m_sEdgeStroke.getDashArray();
                   for (int i=0; i < dasharray.length; i++) {
		      dasharray[i] = dasharray[i] * (factor/oldFactor);
                   }
		   float dashphase = m_sEdgeStroke.getDashPhase() * (factor/oldFactor);
		   m_sEdgeStroke = new BasicStroke(newWidth,
						m_sEdgeStroke.getEndCap(),
						m_sEdgeStroke.getLineJoin(),
						m_sEdgeStroke.getMiterLimit(),
						dasharray,
						dashphase);
                }
		repaint();
	}
	private float factor,oldFactor;

	/**
	 * @param factor The factor to set.
	 */
	public void setFactor(float factor) {
		this.factor = factor;
	}
	/**
	 * @param oldFactor The oldFactor to set.
	 */
	public void setOldFactor(float oldFactor) {
		this.oldFactor = oldFactor;
	}


   /**
   * Correct the locations of end points after a move. Edges of edges can be misplaced because 
   * the graph editor failes to update them while moving a node. So we correct the misplacement
   * when the mouse button is released (DiagramNodeMouseListener.java)
   */
   public void validateEdge() {
      Point sourceP = m_doSource.getNode().getCenter();
      Point destP = m_doDest.getNode().getCenter();
      int dx1,dy1,dx2,dy2; // either -1 or 1 to avoid that the corrections has a too big effect
      if ((sourceP.x & 1) == 0) // even coordinate
        dx1 = 1;
      else
        dx1 = -1;
      if ((sourceP.y & 1) == 0) // even coordinate
        dy1 = 1;
      else
        dy1 = -1;
      // this source point of this edge is misplaced
      if (!m_pCurrentCenter_source.equals(sourceP)) {
        moveNode();  // recalculate a good middle point of the edge
        m_doSource.getNode().setCenter(sourceP.x+dx1, sourceP.y+dy1);  // a bit apart to trigger repainting
        m_doSource.getNode().setCenter(sourceP);  // back to original point
      }
      if ((destP.x & 1) == 0) // even coordinate
        dx2 = 1;
      else
        dx2 = -1;
      if ((destP.y & 1) == 0) // even coordinate
        dy2 = 1;
      else
        dy2 = -1;
     // this destination point of this edge is misplaced
      if (!m_pCurrentCenter_dest.equals(destP)) {
        moveNode();
        m_doDest.getNode().setCenter(destP.x+dx2, destP.y+dy2);
        m_doDest.getNode().setCenter(destP);
      }
   }


  /**
  Make sure that this edge is redrawn.
  */

   public void redrawEdge() {
      // a brute force method to redraw an edge; don't know a better way at the moment, Manfred J.
      Point sourceP = m_doSource.getNode().getCenter();
      int dx1,dy1; // either -1 or 1 to avoid that the corrections has a too big effect
      if ((sourceP.x & 1) == 0) // even coordinate
        dx1 = 1;
      else
        dx1 = -1;
      if ((sourceP.y & 1) == 0) // even coordinate
        dy1 = 1;
      else
        dy1 = -1;
      moveNode();  // recalculate a good middle point of the edge
      m_doSource.getNode().setCenter(sourceP.x+dx1, sourceP.y+dy1);  // a bit apart to trigger repainting
      m_doSource.getNode().setCenter(sourceP);  // back to original point
   }

} // DiagramEdge
