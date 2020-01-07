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
package i5.cb.graph.diagram;



import i5.cb.graph.DiagramDesktop;

import java.awt.Graphics;
import java.awt.Shape;
import java.util.Vector;


/**
 * This interface defines of diagram objects, i.e.
 * nodes as well as edges. The user object that has to be specified in the
 * constructors of the subclasses can be any kind of Java object. 
 * The look and feel of the 
 * GraphEditor is determined by the DiagramClass, which constructs the 
 * components that are used to display the user objects. DiagramObjects can
 * be identified by the user objects. 
 * 
 *
 * @author <a href="mailto:Tobias.Schoeneberg@epost.de">Tobias Schoeneberg</a>
 * @version 1.0
 */
public interface DiagramObject{


        /**
         * Returns the userobject this DiagramObject is associated with. 
         *
         * @return the userobject this DiagramObject is associated
         * with. Any {@link java.lang.Object} may be associated with a DiagramObject
         */
       public Object getUserObject();

        /**
         * It's often necessary to get the node, mo matter if it sits on an edge or not
         */
        public DiagramNode getNode();

        /**
         * Sets a DiagramObject's userobject (i.e associates this
         * DiagramObject with a certain {@link java.lang.Object} which is to
         * be represented by this DiagramObject
         *
         * @param uo an <code>Object</code> value
         */
        //public void setUserObject(Object uo);

        /**
         * Gets the DiagramClass that manages all associations of this
         * DiagramObject's user{@link java.lang.Object}.
         *
         * @return a <code>DiagramClass</code> value
         */
        public DiagramClass getDiagramClass();

   
       /**
         * Gets the {@link i5.cb.graph.DiagramDesktop} this DiagramObject is currently shown in.
         *
         * @return a <code>DiagramDesktop</code> value
         */
        public DiagramDesktop getDiagramDesktop();

       /**
        * Makes this DiagramObject the source or destination of another {@link DiagramEdge}
        *
         * @param e a <code>DiagramEdge</code> value
         */
        public void addEdge(DiagramEdge e);

        /**
         * Removes a certain edge from the collection of those this DiagramObject is source or destintion of.
         *
         * @param e the DiagramEdge to be removed
         * @return a <code>boolean</code> value that can tell the called whether the operation was successfull
         */

        public boolean removeEdge(DiagramEdge e);



        /**
         * Gets the {@link DiagramEdge}s this DiagramObject is source or destination of
         *
         * @return a <code>Vector</code> value
         */
        public Vector getEdges();


       /**
         * Erases this DiagramObject from its {@link i5.cb.graph.DiagramDesktop}
         *
         */
        public void erase();

        /**
         * Determine if this DiagramObject's {@link java.awt.Component} is currently visible.
         * Only one of the components "component" and smallComponent" can be visible at the same time.
         *
         * @return a <code>boolean</code> value
         */
        public boolean isComponentVisible();

        /**
         * Determine if this DiagramObject's small{@link java.awt.Component} is currently visible.
         * Only one of the components "component" and smallComponent" can be visible at the same time.
         *
         * @return a <code>boolean</code> value
         */
        public boolean isSmallComponentVisible();

        /**
         * Set this DiagramObject's {@link java.awt.Component} visible.
         * Only one of the components "component" and smallComponent" can be
         * visible at the same time. So setting the one visible means to set
         * the other one visible.
        *
         * @return a <code>boolean</code> value
         */
        public boolean setComponentVisible();

       /**
         * Set this DiagramObject's small{@link java.awt.Component} visible.
         * Only one of the components "component" and smallComponent" can be
         * visible at the same time. So setting the one visible means to set
         * the other one visible.
         *
         * @return a <code>boolean</code> value
         */
        public boolean setSmallComponentVisible();

        /**
         * Every object implementing this inferface should have a paint
         * method as we are dealing with a graphical representation of
         * objects and their relations. Using DiagramObjects without somehow
         * painting them doesn't seem to make sense.
         *
         * @param g a <code>Graphics</code> value
         */
        public void paint(Graphics g);

        /**
         * Gets the shape associated with this DiagramObject's user{@link java.lang.Object}.
         *
         * @return a <code>Shape</code> value
         */
        public Shape getShape();

        /**
         * Determines if this DiagramObject has a fixed position on the
         * {@link i5.cb.graph.DiagramDesktop}. This member's value is true
         * for {@link DiagramEdge}s for example as they are not to be
         * removed directly but by removing their source- and
         * destinationnode and the node sitting on it. I really like long
         * sentences.
         *
         * @return a <code>boolean</code> value
         */
        public boolean hasFixedPosition();


      
}//DiagramObject


