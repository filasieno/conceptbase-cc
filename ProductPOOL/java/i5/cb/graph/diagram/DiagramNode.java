/*
The ConceptBase.cc Copyright

Copyright 1987-2026 The ConceptBase Team. All rights reserved.

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
package i5.cb.graph.diagram;

import i5.cb.graph.*;
import i5.cb.graph.cbeditor.CBUserObject;
import i5.cb.graph.shapes.IGraphShape;

import java.awt.*;
import java.awt.geom.Area;
import java.util.*;

import javax.swing.*;
import javax.swing.plaf.basic.BasicInternalFrameUI;
import javax.swing.text.DefaultStyledDocument;

import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import i5.cb.CBConfiguration;

/**
 * A DiagramNode is a visible node shown on a {@link
 * i5.cb.graph.DiagramDesktop} to represent a certain userobject. Two
 * DiagramNodes may be connected via a {@link DiagramEdge}. A DiagramNode may also 'sit' on a {@link DiagramEdge}.q
 *
 * @author     <a href="mailto:Tobias.Schoeneberg@epost.de">Tobias Schoeneberg</a>
 * @version    1.0
 */
public class DiagramNode
    extends JInternalFrame
    implements DiagramObject, ILangChangeable {

    /**
     * Alays paint this node's shape on the diagramdesktop
     */
    public static final int PAINT_SHAPE_ALWAYS = 1;

    /**
     * Only paint the shape if the small component is currently visible
     */
    public static final int PAINT_SHAPE_SMALLCOMPONENT = 2;

    /**
     * Only paint the shape if the component is currently visible
     */
    public static final int PAINT_SHAPE_COMPONENT = 3;

    /**
     * No shape is ever painted
     */
    public static final int PAINT_SHAPE_NEVER = 4;

    /** memorize the Java JRE version as double number */
    public static final double JAVA_VERSION = getJavaVersion();


    /**
     * The userobject that is to be represented on the {@link i5.cb.graph.DiagramDesktop} by this DiagramNode
     */
    protected Object m_userObject;

    /**
     * The {@link DiagramClass} that manages the associated items such
     * as {@link javax.swing.JPopupMenu} or the infodocument for every
     * userobject
     */
    protected DiagramClass m_diagramClass;

    /**
     * A vector of edges that are linked to this object.
     */
    private Vector m_vEdges;

    /**
     * True if the component is visible.
     */
    private boolean bComponentVisible;

    /**
     * True if the small component (and shape) is visible.
     * Should be equal to !bComponentVisible
     */
    private boolean bSmallComponentVisible;

    /**
     * True if the small component is represented by a small square dot,
     * which is used to display the diagram node on edges that have empty labels
     */
    private boolean bHasSquareDot=false;  

    /**
     * Size of a small square dot
     */
    private Dimension m_Dot= new Dimension(6,6); 

    /**
    * True, if the objec can not be dragged around on the desktop, e.g.
    * edges, nodes that are placed on edges.
    */
    private boolean m_bHasFixedPosition;

    /**
     * This is the edge, if this Node is on an edge.
     */
    private DiagramEdge m_diagramEdge;

    private Dimension m_dSmallComponentSize = null;
    private Dimension m_dComponentSize = null;

    private int m_iPaintShapePolicy = PAINT_SHAPE_SMALLCOMPONENT;

    private ResourceBundle m_bundle;

    /** Utility field used by bound properties. */
    private java.beans.PropertyChangeSupport propertyChangeSupport;

    private DiagramDesktop m_diagramDesktop;

    /** False if this node shall be marked as invalid on the DiagramDesktop */
    private boolean m_bValid;

    /** True is this diagram node is currently being dragged */
    private boolean m_isDragged=false;


    /** Node level relative to the JLayeredPane level */
    private int m_nodeLevel=0;

    /** True is this diagram node is frozen to its current position */
    private boolean m_isFrozen=false;


    /** designated location of this node */
    private Point m_designatedLocation = null;


    // ***** Public Constructors *****

    /**
     * Creates a new <code>DiagramNode</code> instance. This
     * constructor is used if an ordinary node is desired, which does not
     * sit on a {@link DiagramEdge}.
     *
     * @param  uo  an <code>Object</code> value. The userObject this node is to represent
     * @param  dc  a <code>DiagramClass</code> value. The DiagramClass that defines this node's properties
     */
    public DiagramNode(Object uo, DiagramClass dc) {
        this(uo, null, dc);
    }

    /**
     * Creates a new <code>DiagramNode</code> instance which sits on a {@link DiagramEdge}.
     *
     * @param  uo  an <code>Object</code> value. The userObject this node is to represent
     * @param  de  a <code>DiagramEdge</code> value. The DiagramEdge this node sits on.
     * @param  dc  a <code>DiagramClass</code> value. The DiagramClass that defines this node's properties
     */
    DiagramNode(Object uo, DiagramEdge de, DiagramClass dc) {

        assert !(
            uo
                instanceof DiagramObject) : "DiagramNode.<init>: uo instanceof DiagramObject";
        assert dc != null : "DiagramNode.<init>: 'dc' equals null";

        m_vEdges = new Vector(5);

        m_bundle = ResourceBundle.getBundle(GEConstants.GE_BUNDLE_NAME);

        this.setResizable(false);
        bComponentVisible = false;
        //bSmallComponentVisible = false;

        m_bValid = true;

        // The DiagramNode's NorthPane is not used
        BasicInternalFrameUI ui = (BasicInternalFrameUI) getUI();
        ui.setNorthPane(null);

        DiagramGlassPane dgl = new DiagramGlassPane(this);
        this.setGlassPane(dgl);
        dgl.setVisible(true);

        m_userObject = uo;
        if (de != null) {
            setDiagramEdge(de);
        }
        m_diagramClass = dc;

        //we don't add a diagramEdge to the diagramClass anymore (but only its nodeOnEdge)
        dc.addUserAndDiagramObject(getUserObject(), this);

        if (JAVA_VERSION > 1.6011) {
           this.addComponentListener(new ComponentAdapter() {
             public void componentResized(ComponentEvent e) {
                DiagramNode dn= (DiagramNode) e.getSource();
                dn.resizeComponents();
             }
           });
        }

        // ticket #371: memorize the user-defined layer of this node
        CBUserObject u = (CBUserObject)uo;
        if (u.hasProperty("nodelevel") ) {
           setNodeLevel(u.getProperty("nodelevel"));
        }

        setSmallComponentVisible();
        setToolTipText(m_userObject.toString());
    }

    // ***** Public Methods *****

    /**
     * Gets the userObject this node represents on the {@link i5.cb.graph.DiagramDesktop}.
     *
     * @return    an <code>Object</code> value. This DiagramNode's userobject.
     */
    final public Object getUserObject() {
        assert !(
            m_userObject
                instanceof DiagramObject) : "DiagramNode.getUserObject: uo may not be instanceof DiagramObject";
        return m_userObject;
    }

    /**
     * Sets the Diagram Node's user object to <code>uo</code>. Required for updating
     * the view of of a diagram object
     *
     * @param uo the diagram node's user object to be set to
     * @see        i5.cb.graph.diagram.DiagramObject
     */
    public void setUserObject(Object uo) {
        assert(!(uo instanceof DiagramObject)) : "DiagramNode.setUserObject: uo instanceof DiagramObject";
        this.m_userObject = uo;
        // refresh the visible component
        if(isSmallComponentVisible()) {
            this.setSmallComponentVisible(true);  // force the setting
        }
        else {
            this.setComponentVisible(true);  // force the setting
        }
    }


    public String getLabel() {
      return this.getUserObject().toString();
    }

    /**
     * Sets this diagram nodes small component size to <code>dim</code> if 
     * <code>dim</code> is not null
     *
     * @param dim the proposed new small component size
     */
    public void setSmallComponentSize(Dimension dim) {
       if (dim != null) {
         m_dSmallComponentSize = dim;
       }
    }



    /**
     * Sets this diagram node's designated location to <code>p</code>; the designation is typically set
     * by the graph property "location" of this node.
     *
     * @param p the designated location of this diagram node
     */
    public void designateLocation(Point p) {
       m_designatedLocation = p;
    }


    public Point getDesignatedLocation() {
       return m_designatedLocation;
    }




    /**
     * Tells this node whether it shall draw it's shape.
     * Possible values are PAINT_SHAPE_ALWAYS, PAINT_SHAPE_COMPONENT,
     * PAINT_SHAPE_SMALLCOMPONET and PAINT_SHAPE_NEVER(default)
     */
    final public void setPaintShapePolicy(int policy) {
        m_iPaintShapePolicy = policy;
    }

    /**
    * the value of paintShapePolicy tells wheter this node's shape is to be painted
    * in the node's paint method.
    */
    /*
    final int getPaintShapePolicy() {
        return m_iPaintShapePolicy;
    }
    */

    /**
     * Gets the {@link i5.cb.graph.DiagramDesktop} this node is shown on.
     *
     * @return     a <code>DiagramDesktop</code> value
     */
    final public DiagramDesktop getDiagramDesktop() {
        return m_diagramDesktop;
    }

    final public void setDiagramDesktop(DiagramDesktop dd) {
        assert m_diagramDesktop
            == null : "DiagramNode.setDiagramDesktop: m_diagramDesktop was already set to something";
        m_diagramDesktop = dd;
    }

    /**
     * Gets the {@link DiagramClass} which defines this DiagramNode's properties such as it's popupmenu.
     *
     * @return a <code>DiagramClass</code> value
     */
    final public DiagramClass getDiagramClass() {
        return m_diagramClass;
    }

    /**
     * Is called by the constructor of DiagramEdge to add itself to the
     * edges coming out or going into this node.
     * If this node is on an edge, the edge is not added to this node's edges.
     *
     * @param  de  the diagramEdge to be added
     */
    final public void addEdge(DiagramEdge de) {
        if (de != null) {
            m_vEdges.add(de);
        }
    }

    /**
     * Tells this DiagramNode that  it is not the source or the destination of a particular {@link DiagramEdge} anymore.
     *
     * @param  e  a <code>DiagramEdge</code> value. The {@link DiagramEdge} that shall be removed from the collection of this DiagramNode's edges.
     *
     * @return    true if the edge was connected to this node.
     */
    final public boolean removeEdge(DiagramEdge e) {
        return m_vEdges.remove(e);
    }

    /**
     * <code>getEdges</code> returns the edges connected to this node.
     *
     * @return    a <code>Vector</code> containing all edges linked to this node
     */
    final public Vector getEdges() {
        return m_vEdges;
    }

    /*
    public void setEdges(Vector edges) {
        m_vEdges = edges;
    }
    */

    /**
     * Removes this node from its diagramDesktop. Also erases all {@link
     * DiagramEdge}s that were connected to this node.
     */
    final public void erase() {

        // issue #57: check for null values; getDiagramDesktop() could already be null
        if (this == null || getDiagramDesktop() == null)
           return;

        DiagramEdge currentDiagramEdge;
        int numberOfEdges = getEdges().size();
        getDiagramDesktop().setNodeSelected(this, false);
        getDiagramDesktop().remove(this);

        for (int i = numberOfEdges; i > 0; i--) {
            currentDiagramEdge = ((DiagramEdge) getEdges().elementAt(i - 1));
            getDiagramDesktop().setNodeSelected(
                currentDiagramEdge.getNodeOnEdge(),
                false);
            currentDiagramEdge.getNodeOnEdge().erase();
        }
        if (isOnEdge()) {
            m_diagramEdge.erase();
        }
        getDiagramClass().remove(m_userObject);
        m_diagramDesktop=null;
    }

    /**
     * Tells if the Component this node is associated with is
     * visible. The association is managed by {@link DiagramClass}
     *
     * @return    True if this node's Component is currently visible
     */
    final public boolean isComponentVisible() {
        return bComponentVisible;
    }


    /**
     * Tells if the Component this node is associated with is
     * visible. The association is managed by {@link DiagramClass}
     *
     * @return    True if this node's SmallComponent is currently visible
     */
    final public boolean isSmallComponentVisible() {
        return bSmallComponentVisible;
    }

    /**
     *Description of the Method
     *
     */
    public void toggleComponentView() {
        if (this.isFrozen())
           return; // do not toggle component view if the node is frozen
        if (bSmallComponentVisible) {
            setComponentVisible();

        } else {
            setSmallComponentVisible();
        }
    }

    final public boolean setComponentVisible() {
      return setComponentVisible(false);  // forcing the setting is disabled
    }

    /**
     * Sets this DiagramNode's "Component" visible together with a small empty titlebar. Every
     * DiagramNode is associated with two {@link java.awt.Component}s. One of them is referred to as
     * "Component " and one as "SmallComponent". They cannot be shown at the same time. The titlebar
     * can be covered by the {@link DiagramGlassPane}, so that you can move the node and still have
     * full access to the complete Component.
     *
     * @param forceSet true if the seeting shall be enforced
     * @return    true if the node's "Component" was already visible or if
     *it was successfully set visible. False if there was no "Component"
     *associated with this node.
     */
    final public boolean setComponentVisible(boolean forceSet) {

        // nissue #74
        if (CBConfiguration.getComponentViewSetting() == null || CBConfiguration.getComponentViewSetting().equals("none")) {
          getDiagramDesktop().getGraphEditor().setStatusString("No graph component view enabled in CBConfiguration");
          return false; // no large component such as "ObjectFrame" enabled in CBConfiguration
        }

        if (!isComponentVisible() || forceSet) {
            Component c = getDiagramClass().getComponent(getUserObject());
            if (c != null) {

                if (m_dComponentSize == null) {
                    m_dComponentSize = c.getPreferredSize();
                }
                // memorize the size of the small component for the toggling
                if (m_dSmallComponentSize != null && isSmallComponentVisible()) {
                    m_dSmallComponentSize = this.getSize();
                }

                Dimension oldSize = getSize();
                Point center = getCenter();
                JPanel movablePanel = new JPanel(new BorderLayout());
                // contains the moveBar and the Component
                JComponent moveBar = new JPanel();
                moveBar.setToolTipText(
                    m_bundle.getString("DiagramNode_rightClick"));
                moveBar.setBackground(new Color(210, 210, 255));
                // lightBlue. Immitates the JInternalFrames' titleBars
                movablePanel.add(moveBar, BorderLayout.NORTH);
                movablePanel.add(c, BorderLayout.CENTER);

                this.setContentPane((Container) movablePanel);

                this.setSize(m_dComponentSize);

                this.setResizable(true);
                bComponentVisible = true;
                bSmallComponentVisible = false;
                setCenter(center);
                if (JAVA_VERSION > 1.6011) {
//                   movablePanel.setSize(m_dComponentSize);
 //                  movablePanel.setCenter(center);
                }
                this.pack();

                propertyChangeSupport.firePropertyChange(
                    "size",
                    oldSize,
                    getSize());
                propertyChangeSupport.firePropertyChange(
                    "componentVisible",
                    false,
                    true);
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }


    final public boolean setSmallComponentVisible() {
      return setSmallComponentVisible(false);  // forcing the setting is disabled
    }

    /**
     * Sets this DiagramNode's "SmallComponent" visible. Every DiagramNode is
     * associated with two {@link java.awt.Component}s. One of them is
     * referred to as "Component " and one as "SmallComponent". They
     * cannot be shown at the same time. The actuall {@link
     * java.awt.Component}s are below the properties managed by
     * {@link DiagramClass}
     *
     * @param forceSet true if the seeting shall be enforced
     * @return    true if the node's "SmallComponent" was already visible or if
     *it was successfully set visible. False if there was no "SmallComponent"
     *associated with this node.
     */
    final public boolean setSmallComponentVisible(boolean forceSet) {

        if (!isSmallComponentVisible() || forceSet) {

            Component c = getDiagramClass().getSmallComponent(getUserObject());
            if (c != null) {

                if (m_dSmallComponentSize == null) {
                   m_dSmallComponentSize = c.getPreferredSize();
                }

                // memorize the size of the (big) component for the toggling
                if (m_dComponentSize != null && isComponentVisible()) {
                    m_dComponentSize = this.getSize();
                }

                Dimension oldSize = getSize();

                Point center = getCenter();

                this.setMinimumSize(c.getMinimumSize());
                this.setContentPane((Container) c);
                bSmallComponentVisible = true;
                bComponentVisible = false;

                

                // 2 pixel wider for italics labels
                CBUserObject u = (CBUserObject)this.getUserObject();
                if (u.hasProperty("fontstyle") ) {
                   String sFontStyle = u.getProperty("fontstyle");
                   if (sFontStyle.equals("italic")) {
                      m_dSmallComponentSize.setSize(m_dSmallComponentSize.getWidth() + 2,   
                             m_dSmallComponentSize.getHeight());
                   }
                }



                this.setSize(m_dSmallComponentSize);


                if (u.hasProperty("size") )   // either "resizable" or some explicit size like "20x20"
                   this.setResizable(true);
                else
                   this.setResizable(false);
                propertyChangeSupport.firePropertyChange(
                    "size",
                    oldSize,
                    getSize());
                propertyChangeSupport.firePropertyChange(
                    "componentVisible",
                    true,
                    false);
                setCenter(center);   
                resizeComponents(); // Ticket #216: take care with Java 6 Build 12 onwards
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }


    /**
     * Take care that the rootpane, glasspane, layered pan and content pane of this DiagramNode
     * have the right sizes. That was done automatically by Swing up to Java 6 Update 11. 
     *
     */
    // Ticket #216: take care with newer Java version from Java 6 Build 12 onwards
    final public void resizeComponents() {
       if (JAVA_VERSION <= 1.601101) 
         return;
       // 1. Get current zoom factor safely
       float zoom = 1.0F;
       if (getDiagramDesktop() != null && getDiagramDesktop().getZoomer() != null) {
        zoom = (float)getDiagramDesktop().getZoomer().getFactor();
       }
       Dimension compSize; 
       Point compLoc;
       if (isSmallComponentVisible()) {
         m_dSmallComponentSize = this.getSize();
         // m_dSmallComponentSize = new Dimension((int)(this.getWidth() / zoom), (int)(this.getHeight() / zoom));
         if (hasSquareDot()) {
           compSize = this.getMinimumSize();
         }
         else {
           compSize = m_dSmallComponentSize;
           Dimension minCompSize = getContentPane().getMinimumSize();
           Dimension prefCompSize = getContentPane().getPreferredSize();
           // the contentPane may actually be too big for the DiagramNode; then the DiagramNode is enlarged
           // if the required enlargement is only small
           if (compSize.width - minCompSize.width < 4 &&
               minCompSize.width - compSize.width < 12) {
              compSize = minCompSize;
              m_dSmallComponentSize = new Dimension(minCompSize.width+4, m_dSmallComponentSize.height);
              this.setSize(m_dSmallComponentSize);
             // the content pane may be smaller than the diagram node itself
           } else if (prefCompSize != null &&
                      prefCompSize.width < m_dSmallComponentSize.width &&
                      prefCompSize.height <= m_dSmallComponentSize.height &&
                      prefCompSize.width > 0) {
              compSize = prefCompSize;
           }
         }
         // place the small component (DiagramLabel) inside m_dSmallComponentSize
         // depending on its "align" property
         compLoc = new Point((m_dSmallComponentSize.width - compSize.width)/2,
                             (m_dSmallComponentSize.height -compSize.height)/2);

         if (m_userObject != null && m_userObject instanceof CBUserObject)
            compLoc = ((CBUserObject)m_userObject).getAlignedLocation(m_dSmallComponentSize,compSize);
         this.getRootPane().setSize(m_dSmallComponentSize);
         if (hasSquareDot()) {
            this.getGlassPane().setSize(compSize);
            this.getGlassPane().setBounds(compLoc.x,compLoc.y,compSize.width,compSize.height);
         }
         this.getLayeredPane().setSize(m_dSmallComponentSize);
         this.getContentPane().setSize(compSize);
         this.getContentPane().setBounds(compLoc.x,compLoc.y,compSize.width,compSize.height);
// --- TRACE LOG START ---
        // This will expose if m_dSmallComponentSize is polluted with zoomed pixels
        // or if compSize (the label) is failing to scale.
//        System.out.println();
//        System.out.println("--- Dimensions of " + this.getLabel() + " ---");
//        System.out.print("Zoom Factor: " + zoom);
//        System.out.println("m_dSmallComponentSize: " + m_dSmallComponentSize.width + "x" + m_dSmallComponentSize.height);
//        System.out.println("contentPane: " + this.getContentPane().getSize().width + "x" + this.getContentPane().getSize().height);
//        System.out.println(", compLoc: ("+ compLoc.x+","+compLoc.y+")");
// --- TRACE LOG END ---

       } else {  // big component is visible
         m_dComponentSize = this.getSize();
         compSize = new Dimension(m_dComponentSize.width-10,m_dComponentSize.height-10);
         this.getRootPane().setSize(m_dComponentSize);
         this.getLayeredPane().setSize(m_dComponentSize);
         this.getContentPane().setSize(compSize);
         compLoc = new Point((m_dComponentSize.width - compSize.width)/2,
                             (m_dComponentSize.height -compSize.height)/2);
         this.getContentPane().setBounds(compLoc.x,compLoc.y,compSize.width,compSize.height);
         this.getContentPane().revalidate();
         this.pack();
         this.revalidate();
       }
    }


    /**
     * Gets this node's infoDocument by calling the method of this
     * node's {@link DiagramClass}. This document contains information
     * about the userobjet this node represents and is shown in the
     * grapheditor's informationwindow.
     *
     * @return    a <code>DefaultStyledDocument</code> value
     */
    final public DefaultStyledDocument getInfoDoc() {
        return m_diagramClass.getInfoDoc(m_userObject);
    }

    /**
     * tells if this node has been added to the diagramDesktop.
     * adding a node to the dd means that it has been made visible
     *
     * @return    a <code>boolean</code> value
     */
    final public boolean isShown() {
        return getDiagramDesktop() != null;
    }


    /**
     * checks whether the center point of dn is contained in this DiagramNode
     *
     * @return    true if tn and this DiagramNode are different proper nodes and
     *            the center of dn is contained in this DiagramNode's bounds
     */
    public boolean containsNode(DiagramNode dn) {
       if (this.isOnEdge() || dn.isOnEdge())
          return false;
       else if (this == dn)
          return false;
       else
          return (this.getBounds().contains(dn.getCenter()) );
    }




    // only for debugging paint
    private void printComp(int lev, JComponent comp) {

      System.out.print(lev+" ");
      for (int i=0;i<lev;i++)
         System.out.print(" ");
      if (lev==3) {
        System.out.println(comp.toString() + ": " + comp.getSize());
      }
      for (int ind=0; ind<comp.getComponentCount(); ind++) {
        printComp(lev+1,(JComponent)comp.getComponent(ind));
      }

    }



    /**
     * This node's paint method.
     * @param  g  a <code>Graphics</code> value
     */
    final public void paint(Graphics g) {

 // System.out.println(); printComp(0,this);


        if (m_iPaintShapePolicy == PAINT_SHAPE_ALWAYS
            || (bSmallComponentVisible
                && m_iPaintShapePolicy == PAINT_SHAPE_SMALLCOMPONENT)
            || (bComponentVisible
                && m_iPaintShapePolicy == PAINT_SHAPE_COMPONENT)) {
            paintShape(g,true);
        }
        paintChildren(g);

        // draw the shapes border again for a screendump because the node area could overlap some shape borders
        if (getDiagramDesktop().isScreenshotTaken()) {

           if (m_iPaintShapePolicy == PAINT_SHAPE_ALWAYS
               || (bSmallComponentVisible
                   && m_iPaintShapePolicy == PAINT_SHAPE_SMALLCOMPONENT)
               || (bComponentVisible
                   && m_iPaintShapePolicy == PAINT_SHAPE_COMPONENT)) {
               paintShape(g,false);
           }
        }

    }

    /**
     * Draws a red rectangle around this node to show that it's marked.
     * Called by its diagramDesktop which should be the only place to call this method from.
     *
     * @param  g
     */
    final public void drawRect(Graphics g) {
        Rectangle rBounds = this.getBounds();
        if (isFrozen())
           g.setColor(Color.BLUE); // to indicate that the node is frozen
        else
           g.setColor(Color.RED);
        g.drawRect(
            rBounds.x + 1,
            rBounds.y + 1,
            rBounds.width - 2,
            rBounds.height - 2);

        /* --- for debugging component sizes
        if (isSmallComponentVisible()) {

          Color transparentBLUE = new Color(0.2F,0.2F,1.0F,0.25F);  // last argument is alpha value
          g.setColor(transparentBLUE);
          Rectangle cpBounds = this.getContentPane().getBounds();
          g.drawRect(
            rBounds.x + cpBounds.x + 1,
            rBounds.y + cpBounds.y + 1,
            cpBounds.width - 2,
            cpBounds.height - 2);

          Color transparentGREEN = new Color(0.2F,1.0F,0.2F,0.25F);  // last argument is alpha value
          g.setColor(transparentGREEN);
          Rectangle gpBounds = this.getGlassPane().getBounds();
          g.fillRect(
            gpBounds.x + 1,
            gpBounds.y + 1,
            gpBounds.width - 2,
            gpBounds.height - 2);
        }
        --- for debugging component sizes*/

          Color transparentRED;
          if (isFrozen())
             transparentRED = new Color(0.3F,0.3F,1.0F,0.10F);  // blueish; last argument is alpha value
          else
             transparentRED = new Color(1.0F,0.3F,0.3F,0.10F);  // redish; last argument is alpha value
          g.setColor(transparentRED);
          Rectangle gpBounds = this.getGlassPane().getBounds();
          g.fillRect(
            gpBounds.x + 1,
            gpBounds.y + 1,
            gpBounds.width - 2,
            gpBounds.height - 2);
    }

    /**
    * Kind of crosses out this node on its diagramDesktop which
    * should be the only place to call this method from.
    *
    * @param  g
    */
    final public void drawInvalidSign(Graphics g) {
        Rectangle rBounds = this.getBounds();
        g.setColor(Color.RED);
        g.drawLine(
            rBounds.x + 1,
            rBounds.y + 1,
            rBounds.x + rBounds.width - 2,
            rBounds.y + rBounds.height - 2);
        g.drawLine(
            rBounds.x + 1,
            rBounds.y + rBounds.height - 2,
            rBounds.x + rBounds.width - 2,
            rBounds.y + 1);
    }

    /**
     * Return the {@link java.awt.Shape} of this node. This includes the area of the {@link javax.swing.JInternalFrame}
     * and the area of the shape if it is visible and not null.
     * Note, that this method returns the shape of the whole diagram node and
     * not only the shape that is painted when the diagram node shows the small
     * component.
     *
     * @return    the shape of this DiagramNode.
     */
    final public Shape getShape() {
        if (isSmallComponentVisible()) {
            return this.getArea();
        } else {
            return this.getBounds();
        }
    }

    /**
     * Gets the Area occupied by this DiagramNode
     *
     * @return an <code>Area</code> value
     */
    final Area getArea() {

        Rectangle bounds = this.getBounds();

        Shape shape = getDiagramClass().getShape(getUserObject());
        if (shape == null) {
            return new Area(bounds);
        }
        // if no Shape is set, return the Bounds of the DiagramObject

        // else produce a Area with the shape and set it in the Bounds of the DiagramNode

        Area newArea = new Area(shape);
        java.awt.geom.AffineTransform at;

        Rectangle boundsShape = shape.getBounds();

        // set to Null-Point
        at = new java.awt.geom.AffineTransform();
        at.translate(-boundsShape.getX(), -boundsShape.getY());
        newArea.transform(at);
        // set Location to Null

        // set the Size:
        at = new java.awt.geom.AffineTransform();

        double sx = bounds.getWidth() / boundsShape.getWidth();
        double sy = bounds.getHeight() / boundsShape.getHeight();
        at.scale(sx, sy);

        newArea.transform(at);
        // set Size

        // set the Loacation:
        at = new java.awt.geom.AffineTransform();
        at.translate(bounds.getX(), bounds.getY());

        newArea.transform(at);
        // set Location

        return newArea;
    }

    /**
     * Gets the center of this node's bounding-rectangel
     */
    final public Point getCenter() {
        Rectangle bounds = getBounds();
        return new Point(
            bounds.x + bounds.width / 2,
            bounds.y + bounds.height / 2);
    }

    /**
     * Sets this node's location in a way that
     * its bounding-rectangle's center ist at newCenter and notifies the DiagramDesktop
     */
    final public void setCenter(Point newCenter) {

        Rectangle bounds = getBounds();
        Point newLocation =
            new Point(
                newCenter.x - bounds.width / 2,
                newCenter.y - bounds.height / 2);

        setLocation(newLocation);
        this.validateCenterSetting();
        java.util.logging.Logger.getLogger("global").finer(
            "DiagramNode.setCenter: Node: "
                + getUserObject()
                + "; new Center: "
                + getCenter()
                + "; new bounds: "
                + getBounds());
    }

    final public void setCenter(int x, int y) {
        setCenter(new Point(x, y));
    }

    final public void setLocation(int x, int y) {
        Point oldLocation = getLocation();
        super.setLocation(x, y);
        propertyChangeSupport.firePropertyChange(
            "location",
            oldLocation,
            getLocation());
    }

    final public void setLocation(Point location) {
        Point oldLocation = getLocation();
        setLocation(location.x, location.y);
        propertyChangeSupport.firePropertyChange(
            "location",
            oldLocation,
            getLocation());
    }



    /**
     * Sets this nodes center without calling 'firePropertyChange'.
     * This method is to be called only by {@link i5.cb.graph.diagram.DiagramEdge#moveNode} to prevent a statckoverflow as 'moveNode' is called as reaction of a propertyChange.
     *
     * @param center the point this node's center shall be at.
     */
    final void setCenter_DontFire(Point center) {
        Rectangle bounds = getBounds();
        Point newLocation =
            new Point(
                center.x - bounds.width / 2,
                center.y - bounds.height / 2);

        super.setLocation(newLocation.x,newLocation.y);
    }

    /**
     *
     */
    final public void setBounds(Rectangle r){
        	super.setBounds(r);
        	validateCenterSetting();
    }

    /**
	 * Description:
	 *
	 * author Li Xiang
	 */
	public void validateCenterSetting() {
		propertyChangeSupport.firePropertyChange(
		        "setDirectly",
		        null,
		        null);
	}

	final public void setCenterDirectly(int x,int y){
    	Rectangle rect = new Rectangle();
    	rect.x = x - getWidth()/2;
    	rect.y = y - getHeight()/2;
    	rect.width = getWidth();
    	rect.height = getHeight();
    	setBounds(rect);
    }
    /**
     * Tells if this DiagramNode is on a {@link DiagramEdge}
     *
     * @return    a <code>boolean</code> value
     */
    final public boolean isOnEdge() {
        return m_diagramEdge != null;
    }

    public boolean hasFixedPosition() {
        return m_bHasFixedPosition;
    }

    /**
     * Paints the {@link java.awt.Shape} associated with this
     * DiagramNode. The association is managed by this node's
     * {@link DiagramClass}
     *
     * @param  g  a <code>Graphics</code> value
     */

    protected void paintShape(Graphics g) {
        paintShape(g,true);
    }

    protected void paintShape(Graphics g1, boolean flagFillShape) {

        Graphics2D g = (Graphics2D)g1;
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,   
                        RenderingHints.VALUE_ANTIALIAS_ON);   // enable anti-aliasing

        Rectangle bounds = this.getBounds();
        Shape shape = getDiagramClass().getShape(getUserObject());
        if (shape == null) {
            return;
        }
        // if no Shape is set, return
        // else produce a Area with the shape and set it in the Bounds of the DiagramNode
        Area newArea = new Area(shape);
        java.awt.geom.AffineTransform at;
        Rectangle boundsShape = shape.getBounds();

        // set the Size and location of shape inside the diagram nodes bounds
        // the location is adapted by translate(); see issue #76
        at = new java.awt.geom.AffineTransform();


        // Get the full line width for stroke padding
        float lineWidth = ((IGraphShape) shape).getLineWidth();
        float zoomfactor = getDiagramDesktop().getZoomer().getFactor();
        float scaledLineWidth = (float)(lineWidth * zoomfactor);

        double sx = (bounds.getWidth() - scaledLineWidth - 1) / boundsShape.getWidth();
        double sy = (bounds.getHeight() - scaledLineWidth - 1) / boundsShape.getHeight();

        // Center the scaled shape
        double scaledWidth = boundsShape.width * sx;
        double scaledHeight = boundsShape.height * sy;
        double offsetX = (bounds.width - scaledWidth) / 2;
        double offsetY = (bounds.height - scaledHeight) / 2;


        at.translate(offsetX, offsetY);
        at.scale(sx, sy);
        at.translate(-boundsShape.x, -boundsShape.y);

        newArea.transform(at);

        // set Size

        //newArea.subtract( horizontalLine);
        //newArea.subtract(verticalLine);

        if (newArea != null) {
            // draw the shape
            Color fillColor;
            Color outlineColor;
            if (shape instanceof IGraphShape) {
                fillColor = ((IGraphShape) shape).getFillColor();
                outlineColor = ((IGraphShape) shape).getOutlineColor();
            } else {
                fillColor = IGraphShape.DEFAULT_FILL_COLOR;
                outlineColor = IGraphShape.DEFAULT_OUTLINE_COLOR;
            }

            if (flagFillShape) {
               g.setColor(fillColor);
               g.fill(newArea);
            }
            g.setColor(outlineColor);

            if(shape instanceof IGraphShape) {
                if (0.95f < zoomfactor && zoomfactor < 1.05f)
                   g.setStroke(new BasicStroke(((IGraphShape) shape).getLineWidth()));
                else
                   g.setStroke(new BasicStroke(scaledLineWidth));
            }
            g.draw(newArea);
            g.setColor(Color.yellow);

        }
    }


    public DefaultStyledDocument updateLang(Locale l) {
        return null;

    }

    /**
    * Setter for property bundle.
    * @param bundle New value of property bundle.
    */
    final public void setBundle(ResourceBundle bundle) {
        m_bundle = bundle;
    }

    /** Adds a PropertyChangeListener to the listener list.
     * @param l The listener to add.
     */
    final public void addPropertyChangeListener(
        java.beans.PropertyChangeListener l) {
        if (propertyChangeSupport == null) {
            propertyChangeSupport = new java.beans.PropertyChangeSupport(this);
        }
        propertyChangeSupport.addPropertyChangeListener(l);
    }

    /** Removes a PropertyChangeListener from the listener list.
     * @param l The listener to remove.
     */
    final public void removePropertyChangeListener(
        java.beans.PropertyChangeListener l) {
        propertyChangeSupport.removePropertyChangeListener(l);
    }

    /**
     * Gets the {@link DiagramEdge} this DiagramNode is on or null if
     * this node is not on a DiagramEdge.
     *
     * @return    a <code>DiagramEdge</code> value
     */
    final public DiagramEdge getDiagramEdge() {
        return m_diagramEdge;
    }

    /** Setter for property diagramEdge. diagramEdge may not be null.
     * @param diagramEdge New value of property diagramEdge. If the param is null,
     * this node is added to the diagramDesktop's edgelayer
     */
    final public void setDiagramEdge(DiagramEdge diagramEdge) {
        assert(diagramEdge != null)
            && ((m_diagramEdge == null)
                || (diagramEdge
                    == m_diagramEdge)) : "DiagramNode.setDiagramEdge: diagramEdge may not be set to 'null' and it may not be changed once it was set";

        DiagramEdge oldEdge = this.m_diagramEdge;
        this.m_diagramEdge = diagramEdge;
        if (diagramEdge.getNodeOnEdge() != this) {
            diagramEdge.setNodeOnEdge(this);
        }
        propertyChangeSupport.firePropertyChange(
            "diagramEdge",
            oldEdge,
            diagramEdge);
    }

    /**
     * Returns this node itself
     */
    final public DiagramNode getNode() {
        return this;
    }

    /**
     * Tells if this node is a sibling of another node.
     *
     * @return true iff the two nodes are on two edges that are incident with the
     * same node or if the two nodes are adjacent to the same node
     */
    final public boolean isSibling(DiagramObject diagObj) {
        DiagramNode otherNode = diagObj.getNode();
        if (this.isOnEdge() && otherNode.isOnEdge()) {
            if ((this.getDiagramEdge().getSource().getNode()
                == otherNode.getDiagramEdge().getSource().getNode())
                || (this.getDiagramEdge().getSource().getNode()
                    == otherNode.getDiagramEdge().getDestination().getNode())
                || (this.getDiagramEdge().getDestination().getNode()
                    == otherNode.getDiagramEdge().getSource().getNode())
                || (this.getDiagramEdge().getDestination().getNode()
                    == otherNode.getDiagramEdge().getDestination().getNode())) {
                return true;
            }
        }
        Iterator itThisEdges = m_vEdges.iterator();
        Iterator itOtherEdges = otherNode.getEdges().iterator();
        DiagramEdge currentThisEdge, currentOtherEdge;

        while (itThisEdges.hasNext()) {
            currentThisEdge = (DiagramEdge) itThisEdges.next();

            while (itOtherEdges.hasNext()) {
                currentOtherEdge = (DiagramEdge) itOtherEdges.next();
                //java.util.logging.Logger.getLogger("global").fine("currentThisEdge: "+currentThisEdge.getUserObject() +"; peer: "+ currentThisEdge.getPeer(this).getUserObject()+"; currentOtherEdge: "+currentOtherEdge.getUserObject()+"; peer: "+currentOtherEdge.getPeer(otherNode).getUserObject() );
                if (currentThisEdge.getPeer(this)
                    == currentOtherEdge.getPeer(otherNode)) {
                    //java.util.logging.Logger.getLogger("global").fine("DiagramNode.isSibling: this: '"+getUserObject()+"' other: '"+diagObj.getUserObject()+"' are siblings: true");
                    return true;
                }
            }
        }
        //java.util.logging.Logger.getLogger("global").fine("DiagramNode.isSibling: this: '"+getUserObject()+"' other: '"+diagObj.getUserObject()+"' are siblings: false");
        return false;
    }

    /**
     * Returns the component which is currently visible (i.e. small component or *the* component)
     */

    final public Component getVisibleComponent() {
        if (isSmallComponentVisible())
            return getDiagramClass().getSmallComponent(getUserObject());
        else
            return getDiagramClass().getComponent(getUserObject());
    }

    /** Getter for property valid.
     * @return true iff this node (or its userobject) is still valid in a certain sense, which is usually related to the userObject
     *
     */
    final public boolean isValid() {
        return m_bValid;
    }

    /** Setter for property valid.
     * @param valid New value of property valid.
     */
    final public void setValid(boolean valid) {
        boolean oldValid = this.m_bValid;
        this.m_bValid = valid;
        propertyChangeSupport.firePropertyChange(
            "valid",
            new Boolean(oldValid),
            new Boolean(m_bValid));
    }

    public void updateUI() {
        super.updateUI();
        ((BasicInternalFrameUI) getUI()).setNorthPane(null);
    }



    /** Getter for property isDragged.
     * @return true iff this node is currently being dragged (see DiagramNodeMouseListener.java)
     *
     */
    public boolean isDragged() {
        return m_isDragged;
    }


    /** Setter for property isDragged.
     * @param newDragged New value of property isDragged.
     */
    public void setDragged(boolean newDragged) {
        m_isDragged = newDragged;
    }


    /** Getter for property isFrozen.
     * @return true iff this node is currently being frozen (see DiagramNodeMouseListener.java)
     *
     */
    public boolean isFrozen() {
        return m_isFrozen;
    }


    /** Setter for property isFrozen.
     * @param newFrozen New value of property isFrozen.
     */
    public void setFrozen(boolean newFrozen) {
        m_isFrozen = newFrozen;
        if (m_isFrozen) {
           this.setResizable(false);  // frozen nodes are not resizable
        } else { // unfrozen nodes are resizable when configured so by theur CBUserObject 
           this.setResizable(m_userObject != null && m_userObject instanceof CBUserObject
                                                  && ((CBUserObject)m_userObject).hasProperty("size"));
        }
        this.repaint();
    }



   
    /** Getter for property m_nodeLevel.
     * @return the nodelevel of this node relative to DiagramDesktop.NODE_LAYER
     * (=JLayeredPane.MODAL_LAYER=Integer.valueOf(200))
     *
     */
    public int getNodeLevel() {
        return m_nodeLevel;
    }

    public void setNodeLevel(String s) {
        try {
           m_nodeLevel = Integer.parseInt(s);
        }
        catch (Exception e) {
           m_nodeLevel = 0;
        }
    }

    public void setNodeLevel(int nodelevel) {
        m_nodeLevel = nodelevel;
    }



    /**
    * set the square dot of the diagram labels of this diagram node with empty text visible via its opacity;
    * only called for diagram nodes that sit on edges; called in DiagramDesktop.setSquareDots
    */
    public void setSquareDot(boolean visible) {
        Container c = this.getContentPane();
        if (c instanceof DiagramLabel) {
          DiagramLabel dl = (DiagramLabel)c;
          if (isSmallComponentVisible() &&
              dl.getText().length()==0) {
            dl.setOpaque(visible);
            bHasSquareDot = true;
            this.resizeComponents();
          } 
        } 
    }

    public boolean hasSquareDot() {
        return bHasSquareDot;
    }


    // this method was designed when Java 8 carried the version number 1.8... 
    // This has changed since then. For example Java 11.0.22 would have been Java 1.11.0.22 in the old scheme.
    private static double getJavaVersion() {
        int first = 1;
        int major = 4;
        int minor = 0;
        int update = 0;
        try {
           String[] javaVersionElements = System.getProperty("java.runtime.version").split("\\.|_|-|\\+");
          // some java version strings are very short; hence we need to check the array length
          // typical java.runtime.versions are 1.7.0_91 or 1.5.0_06-b05 or 1.8.0_03-Ubuntu 
           if (javaVersionElements.length > 0)
              first  = Integer.parseInt(javaVersionElements[0]);
           if (javaVersionElements.length > 1)
              major  = Integer.parseInt(javaVersionElements[1]);
           if (javaVersionElements.length > 2)
              minor  = Integer.parseInt(javaVersionElements[2]);
           try {
              if (javaVersionElements.length > 3)
                 update = Integer.parseInt(javaVersionElements[3]);
           } catch (Exception e) {}
        } catch (Exception e) { // if the calculation fails, we assume Java 8 
            first = 1;
            major = 8;
            minor = 0;
            update = 0;
        }

        return first + major/10.0 + minor/1000 + update/10000.0;
    }


}
