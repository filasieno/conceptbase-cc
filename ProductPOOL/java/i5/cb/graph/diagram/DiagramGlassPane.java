/*
The ConceptBase.cc Copyright

Copyright 1987-2023 The ConceptBase Team. All rights reserved.

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

import java.awt.*;

import javax.swing.JComponent;


/**
 * That's a glasspane supposed to be every {@link DiagramNode}'s
 * standard glasspane. It may be modified to make not the whole area
 * of the node sensitive for example or to paint certain symbols over parts of the DiagramNode.
 *
 * The GlassPane will be added to the PopupLayer of the DiagramDesktop
 * so it is above the DiagramObjects.
 * Then a {@link DiagramNodeMouseListener} will be added as the glasspane's mouselistener
 *
 *
 * @author <a href="mailto:Tobias.Schoeneberg@epost.de">Tobias Schoeneberg</a>
 * @version 1.0
 */
public class DiagramGlassPane extends JComponent{

    /**
     * The {@link DiagramNode} that this glasspane is associated with.
     *
     */
    private DiagramNode parentDiagramNode;

    private DiagramNodeMouseListener diagNodeML;

    /**
     * The {@link java.awt.Cursor} to be shown if the mouse is over this glasspane.
     *
     */
    private static Cursor cursor=new Cursor(Cursor.MOVE_CURSOR);

    /**
     * The bounds of this glasspane.
     * @see #rInnerBounds
     *
     */
    Rectangle rBounds;

    /**
     * The inner bounds of this glasspane. together with {@link
     * #rBounds} one can define a frame in which the mousepointer is not
     * regarded as beeing over the glasspane, which means that the user
     * can access some components of the node wich were else covered by
     * the glasspane
     *
     */
    Rectangle rInnerBounds;


    /**
     * Creates a new <code>DiagramGlassPane</code> instance.
     *
     * @param dnParent the parentNode of this glasspane.
     */
    public DiagramGlassPane(DiagramNode dnParent) {
        this.setCursor(cursor);
        this.parentDiagramNode=dnParent;
        diagNodeML = new DiagramNodeMouseListener();
        this.addMouseListener(diagNodeML);
        this.addMouseMotionListener(diagNodeML);
        rBounds=new Rectangle();
        rInnerBounds=new Rectangle();
    }

    /**
     * Gets this glasspane's parent which is the {@link DiagramNode}
     * that was provided in the constructor
     *
     * @return a <code>Container</code> value
     */
    public Container getParent() {
        return this.parentDiagramNode;
    }

    public void setParent(Container parentDiagramNode){
        this.parentDiagramNode = (DiagramNode)parentDiagramNode;
    }

    /**
     * Gets this glassPane boundaries. This method is somehow needed to correctly paint the {@link
     * DiagramNode}, but we don't understand yet, how.
     *
     * @return the bounding rectangel of this glasspane
     */
    public Rectangle getBounds() {
        Rectangle b=this.parentDiagramNode.getBounds();
        if (parentDiagramNode.isSmallComponentVisible() ) {
           rBounds.x=b.x+5;
           rBounds.y=b.y+5;
           rBounds.width=b.width-10;
           rBounds.height=b.height-10;
           return rBounds;
        } else { // large component is visible
          rInnerBounds.x=b.x;
          rInnerBounds.y=b.y;
          rInnerBounds.width = b.width;
          rInnerBounds.height=10;
          return rInnerBounds;
        }
    }





    /**
     * If the parent {@link DiagramNode} is represented by a small {@link Component}, the GlassPane
     * covers the whole Node. Else it covers a smaller Rectangle defined by inner bounds}.
     *
     * @param x horizontal coordinate relative to this GlassPane's(its Node's) position
     * @param y vertical coordinate relative to this GlassPane's(its Node's) position
     * @return true, iff the given point is inside the defined GlassPane's Bounds
     */
    public boolean contains(int x, int y) {
        Rectangle r= this.getBounds();  // applicable to both states of a component
        //As the parameters are relative to the DiagramGlassPane's Bounds
        //we have to adjust them, so they are relative to the
        //DiagramDesktop.
        x += r.x;
        y += r.y;
//System.out.println("("+x+","+y+")" + " --> " + r.toString() + " : " + r.contains(x,y));
        return r.contains(x,y);
    }

    /** Getter for property diagNodeML.
     * @return Value of property diagNodeML.
     */
    public DiagramNodeMouseListener getDiagNodeML() {
        return diagNodeML;
    }

    /** Setter for property diagNodeML.
     * @param diagNodeML New value of property diagNodeML.
     */
    public void setDiagNodeML(DiagramNodeMouseListener diagNodeML) {
        this.diagNodeML = diagNodeML;
    }

    /** Getter for property cursor.
     * @return Value of property cursor.
     */
    public Cursor getCursor() {
        return cursor;
    }
    
 }

