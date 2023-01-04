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

package i5.cb.telos.object;


/**
 * Set of Telos objects (aka "Objektspeicher"). This interface allows 
 * multiple object storage implementations, such as "6 eggs" or "2 eggs" 
 * or "0 eggs" implementations. A Telos object set contains instances of
 * <tt>TelosObject</tt>, also known as <i>propositions</i>.
 * [Say something about Telos axioms here - some are checked, some are not.]
 * Implementors must at least define a default constructor, which creates
 * an empty object set.
 *
 * @author Christoph Radig
 **/

public interface ITelosObjectSet
{
  /////////////////////////////////////////////////////////////////////////////
  // cloning:
  /////////////////////////////////////////////////////////////////////////////

  /**
   * Cloning must be supported by implementing classes. Note that we don't
   * throw a CloneNotSupportedException here. The clone is deep enough so
   * changing the clone won't change the original and vice-versa.
   **/
  Object clone();


  /////////////////////////////////////////////////////////////////////////////
  // containment:
  /////////////////////////////////////////////////////////////////////////////

  /**
   * Note that an if an object set contains a proposition p=(id,x,l,y) it
   * does not necessarily contain x or y. Maybe this is the most important
   * feature which MiniTelos does not have.
   * @return  Does <tt>this</tt> contain <tt>object</tt>?
   **/
  boolean contains( TelosObject object );


  /**
   * @return the size of this set, that is the number of Telos objects 
   *    <code>this</code> currently contains
   **/
  int size();


  /**
   * shortcut for <code>size() == 0</code>
   **/
  boolean isEmpty();


  /**
   * convenience function to get the only member of a set that contains
   * exactly one element.
   * @return null, if <code>this</code> is empty. <code>o</code>, if 
   *    <code>o</code> is the only member of <code>this</code>.
   * @throws Exception if <code>size() greater-than 1</code>
   **/
  TelosObject getTheOnlyMember()
    throws /*OnlyOneMemberExpected*/Exception;


  /////////////////////////////////////////////////////////////////////////////
  // update methods:
  /////////////////////////////////////////////////////////////////////////////

  /**
   * adds <tt>object</tt> to <tt>this</tt>. 
   * If <tt>this</tt> already contains <tt>object</tt>, nothing happens.
   * Otherwise, some[?] Telos axioms a checked. [not yet!]
   **/
  void add( TelosObject object );
    //PRE object != null
    //POST this.contains( object )

  /**
   * removes <tt>object</tt> from <tt>this</tt>.
   * If <tt>this</tt> does not contain <tt>object</tt>, nothing happens.
   **/
  void remove( TelosObject object );
    //PRE object != null
    //POST !this.contains( object )


  /**
   * adds a set of objects to this. If any of the objects is already contained
   * in this, it is simply ignored.
   **/
  void add( ITelosObjectSet objects );
    //PRE objects != null


  /**
   * removes a set of objects from this. If any of the objects is not contained
   * in this, it is simply ignored.
   **/
  void remove( ITelosObjectSet objects );
    //PRE objects != null


  /**
   * makes the set empty
   **/
  void clear();
    //POST isEmpty()


  /////////////////////////////////////////////////////////////////////////////
  // access single objects:
  /////////////////////////////////////////////////////////////////////////////

   /**
   * @return the individual with the given label, if present, null otherwise
   **/
  Individual getIndividual( String sLabel );

  /**
   * @return the instantiation object with the given source and destination,
   *   if present, null otherwise.
   *   Only explicitly contained instantiation objects, not implicit
   *   relationships (contained in the transitive 'in' closure) are returned.
   **/
  Instantiation getInstantiation( TelosObject source, 
				  TelosObject destination );

  /**
   * @return the specialization object with the given source and destination, 
   *   if present, null otherwise.
   *   Only explicitly contained specialization objects, not implicit 
   *   relationships (contained in the transitive 'isA' closure) are returned.
   **/
  Specialization getSpecialization( TelosObject source, 
				    TelosObject destination );

  /**
   * @return the attribute object with the given source and label
   **/
  Attribute getAttribute( TelosObject source, String sLabel );

  /**
   * @return the object with the given source, label and destination,
   *   if present, null otherwise
   **/
  TelosObject getObject( TelosObject source, String sLabel, 
			 TelosObject destination );


  /////////////////////////////////////////////////////////////////////////////
  // explicit (or direct) relationships:
  /////////////////////////////////////////////////////////////////////////////

  /**
   * @return the instantiation links that go into o
   **/
  ITelosObjectSet getInstantiationsOf( TelosObject o );

  /**
   * @return the instantiation (classification) links that come out of o
   **/
  ITelosObjectSet getClassificationsOf( TelosObject o );

  /**
   * @return the specialization links that go into o
   **/
  ITelosObjectSet getSpecializationsFrom( TelosObject o );

  /**
   * @return the specialization (generalization) links that come out of o
   **/
  ITelosObjectSet getGeneralizationsFrom( TelosObject o );


  /**
   * @return the attribute links that come out of o
   **/
  ITelosObjectSet getAttributesOf( TelosObject o );

  /**
   * @return the attribute links that go into o
   **/
  ITelosObjectSet getAttributesTo( TelosObject o );

  /**
   * @return the attribute links that come out of o and are instance
   *   of the given category.
   **/
  ITelosObjectSet getAttributesOfCategory( TelosObject o, 
    Attribute attrCategory );

  /**
   * This is a special case which is often needed (e.g in table models)
   * and can be calculated much faster than getAttributesOfCategory.
   * @return the attribute links that come out of o and are 
   *   <i>explicit</i> instance of the given category.
   **/
  ITelosObjectSet getAttributesOfExplicitCategory( TelosObject o, 
    Attribute attrCategory );


  /**
   * @return the single attribute of the given category
   *    that comes out of <code>o</code>, if any. null, if none.
   * @throws Exception if there is more than one attribute of <code>o</code>
   *    with the given category.
   **/
  Attribute getSingleAttributeOfCategory( TelosObject o, 
    Attribute attrCategory )
    throws Exception;

  /**
   * This is a special case which is often needed (e.g. in table models)
   * and can be calculated much faster than getAttributesOfCategory;
   * There is no error handling, if there is more than one category.
   *
   * @return the attribute of the given category
   *    that comes out of <code>o</code>, if any. null, if none.
   * @see #getAttributesOfExplicitCategory
   **/
  Attribute getSingleAttributeOfExplicitCategory( TelosObject o, 
    Attribute attrCategory ) throws Exception;


  /**
   * @return the links that come out of o
   **/
  ITelosObjectSet getOutgoingLinksOf( TelosObject o );

  /**
   * @return the links that go into o
   **/
  ITelosObjectSet getIncomingLinksOf( TelosObject o );


  /**
   * @return the individuals that are explicitly declared classes of o
   **/
  ITelosObjectSet getExplicitClassesOf( TelosObject o );

  /**
   * @return the individuals that are explicitly declared instances of o
   **/
  ITelosObjectSet getExplicitInstancesOf( TelosObject o );

  /**
   * @return the individuals that are explicitly declared superclasses of o
   **/
  ITelosObjectSet getExplicitSuperclassesOf( TelosObject o );

  /**
   * @return the individuals that are direct (or explicit) subclasses of o
   **/
  ITelosObjectSet getExplicitSubclassesOf( TelosObject o );


  /////////////////////////////////////////////////////////////////////////////
  // implicit relationships (that respect the transitivity of 'isA'):
  /////////////////////////////////////////////////////////////////////////////

  /**
   * This function returns the transitive closure of (o isA x).
   * @return the individuals that are superclasses of o, even those which are
   *    indirect (or implicit) superclasses.
   **/
  // ITelosObjectSet getAllSuperclassesOf( TelosObject o );

  /**
   * This function returns the transitive closure of (x isA o).
   * @return the individuals that are subclasses of o, even those which are
   *    indirect (or implicit) subclasses.
   **/
  ITelosObjectSet getAllSubclassesOf( TelosObject o );

  /**
   * @return the transitive closure of (result in o)
   **/
  ITelosObjectSet getAllInstancesOf( TelosObject o );

  /**
   * @return the transitive closure of (result in o)
   **/
  // ITelosObjectSet getAllClassesOf( TelosObject o );


  /////////////////////////////////////////////////////////////////////////////
  // predicates:
  /////////////////////////////////////////////////////////////////////////////


  boolean isExplicitClassOf( TelosObject o1, TelosObject o2 );

  boolean isExplicitInstanceOf( TelosObject o1, TelosObject o2 );

  boolean isExplicitSuperclassOf( TelosObject o1, TelosObject o2 );

  boolean isExplicitSubclassOf( TelosObject o1, TelosObject o2 );

  /**
   * @return o1 isA o2 ? 
   **/
  boolean isA( TelosObject o1, TelosObject o2 );

  /**
   * @return o1 in o2 ?
   **/
  boolean in( TelosObject o1, TelosObject o2 );


  /**
   * @return enumeration of all contained objects
   **/
  java.util.Enumeration elements();


    
    /**
     * Returns an enumeration of the objects in a lexical order
     *
     * @return a <code>java.util.Enumeration</code> value
     */
    public java.util.Enumeration sortedElements();

  /**
   * @return proposition representation, like "P(oid,src,label,dest)"
   **/
  String asPropositions();

}  // interface ITelosObjectSet
