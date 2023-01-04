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
/*
 * @(#)GraphEditor.java 0.5 b 11.09.99
 *
 * Copyright 1998, 1999 by Rainer Langohr,
 * 
 * All rights reserved.
 *
 */
package i5.cb.graph.diagram;

import java.awt.*;
import java.awt.geom.Rectangle2D;

import javax.swing.JLabel;
import javax.swing.SwingConstants;



/**
 * DiagramLabel is the default to be returned by the DiagramClass' getSmallComponent-mehod.
 *
 * @author <a href="mailto:Tobias.Schoeneberg@epost.de">Tobias Schoeneberg</a>
 * @version 1.0
 * @see JLabel
 * @since 1.0
 */
public class DiagramLabel extends JLabel implements java.io.Serializable {


    /**
     * Describe variable <code>oldSize</code> here.
     *
     */
    Dimension oldSize;
    private Dimension m_defaultminsize = new Dimension(3,3);

    /**
      * Creates a new <code>DiagramLabel</code> instance.
      *
      */
    public DiagramLabel() {
        super("",SwingConstants.CENTER);
        this.setMinimumSize(m_defaultminsize);
        this.setPreferredSize(m_defaultminsize);
    }



    /**
     * Creates a new <code>DiagramLabel</code> instance using the
     * specified text and {@link java.awt.Color}
     *
     * @param text a <code>String</code> value
     * @param textColor a <code>Color</code> value
     */
    public DiagramLabel(String text, Color textColor) {
        super(text,SwingConstants.CENTER);
        setForeground(textColor);
        if (text.length()==0) {
          this.setMinimumSize(m_defaultminsize);
          this.setPreferredSize(m_defaultminsize);
        }
        this.setSize(getPreferredSize());
    }


    /**
     * Creates a new <code>DiagramLabel</code> instance using the
     * specified text and {@link java.awt.Color#white} as textcolor.
     *
     * @param text a <code>String</code> value
     */
    // this is the constructor used by the other classes to create DiagramLabels
    public DiagramLabel(String text) {
        super(text,SwingConstants.CENTER);  
        setForeground(java.awt.Color.white);
        if (text.length()==0) {
          this.setMinimumSize(m_defaultminsize);
          this.setPreferredSize(m_defaultminsize);
        }
        this.setSize(getPreferredSize());
    }

    /**
     * Creates a new <code>DiagramLabel</code> instance using the
     * specified text and allignment.
     *
     * @param text a <code>String</code> value
     * @param alignment One of the following constants defined in SwingConstants: LEFT, CENTER, RIGHT, LEADING or TRAILING.
     */
    public DiagramLabel(String text, int alignment) {
        super(text,alignment);
        setForeground(java.awt.Color.white);
        if (text.length()==0) {
          this.setMinimumSize(m_defaultminsize);
          this.setPreferredSize(m_defaultminsize);
        }
        this.setSize(getPreferredSize());
    }



    /**
     * Tells if a {@link java.awt.Point} lies within this DiagramLabel's bounds
     *
     * @param   p  
     * @return true iff p lies inside this DiagramLabel's bounds
     */
    public boolean contains(Point p) {
        return contains(p.x, p.y);
    }



    /**
     * Tells if a point specified by two int values lies within this DiagramLabel's bounds/
     * 
     * @param   x  
     * @param   y  
     * @return true iff the point specified by x and y lies inside this DiagramLabel's bounds. 
     */
    public boolean contains(int x, int y) {
        return this.getBounds().contains(x,y);
    }



    /**
     * Describe <code>setFont</code> method here.
     *
     * @param   c  
     * @param   g
     */
    public void setFont(Component c, Graphics g) {
        Dimension dSource = c.getSize();
        if (!dSource.equals(oldSize)) {
            oldSize=dSource;

            Dimension d=new Dimension(dSource.width-40, dSource.height-40);

            Font  font = this.getFont();

            // Sonderbehandlung fuer DiagramEdges
            if (c instanceof DiagramEdge) {

                font=font.deriveFont(100);

                this.setFont(font);
                return;
            }

            FontMetrics FM  = this.getFontMetrics(font);
            Rectangle2D RF=FM.getStringBounds(this.getText(), g);

            double TextHeight = RF.getHeight();
            double TextWidth  = RF.getWidth();


            if ((TextWidth<=0) | (TextHeight<=0))
                return;

            double f1=d.height * Math.pow(TextHeight, -1);
            double f2=d.width  * Math.pow(TextHeight,  -1);

            double f=Math.min(f1, f2);

            if (f!=1) {
                float size=(new Float(font.getSize()*f)).floatValue();
                if (size<10)
                    size=10;

                font=font.deriveFont(size);
                this.setFont(font);
            }
        }
    }

    /**
      * This DiagramLabel's paint method. Doesn't do that much...
      *
      * @param g a <code>Graphics</code> value
      */
    public void paint(Graphics g) {
        //if (flattering) this.setFont(this, g);
        super.paint(g);
    }

}
