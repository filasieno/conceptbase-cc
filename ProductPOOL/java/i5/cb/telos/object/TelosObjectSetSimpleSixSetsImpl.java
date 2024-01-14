/*
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

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

package i5.cb.telos.object;

import java.util.Hashtable;


/**
 * Simple implementation that provides fast lookups but slow 
 * insertions/deletions.
 *
 * if not stated otherwise, n == this.size()
 * @author Christoph Radig
 **/

public class TelosObjectSetSimpleSixSetsImpl
  extends TelosObjectSetSimpleImpl
{
  Hashtable entries = new Hashtable();


  /**
   * @return a deep enough copy of this object set.
   * This is a simple implementation that returns a TelosObjectSetSimpleImpl
   * object.
   **/
  public Object clone()
  {
    // quick & dirty (no good! Funktioniert nicht mit Unterklasse Extension!):
    // return new TelosObjectSetSimpleImpl( objects() );

    // create empty set and add this set's objects:
    // funktioniert nicht, da Extension keinen Default ctor hat!
    /*
    TelosObjectSetSimpleSixSetsImpl result = null;
    try {
        result = 
          (TelosObjectSetSimpleSixSetsImpl) this.getClass().newInstance();
    }
    catch( IllegalAccessException ex ) {
      ex.printStackTrace();
      throw new Error();
    }
    catch( InstantiationException ex ) {
      ex.printStackTrace();
      throw new Error();
    }

    result.add( this );
    */

    TelosObjectSetSimpleSixSetsImpl result = 
      (TelosObjectSetSimpleSixSetsImpl) super.clone();

    result.clear();
      // this is the only way to create an empty set 
      // of the right class! Slow but correct.

    result.add( this );

    return result;
  }  // clone



  /**
   * @object Telos object
   * @return the entry that contains object, if this contains object,
   *    null otherwise.
   **/
  SixSetsEntry getEntry( TelosObject object )
  {
    return (SixSetsEntry) entries.get( object );
  }


  /**
   * @param object Telos object
   * -time O(n)
   **/
  public void add( TelosObject object )
  {
    // 1. create entry:
    SixSetsEntry entry = new SixSetsEntry( object );

    // 2. add to entry all links that contain object as their 
    //    source or destination:
    java.util.Enumeration iter = elements();
    while( iter.hasMoreElements() ) {
      TelosObject to = (TelosObject) iter.nextElement();
      if( to.isLink() ) {
        if( to.getSource() == object )
          entry.addToSet( to.getSystemClass(), SixSetsEntry.OUT, to );
        if( to.getDestination() == object )
          entry.addToSet( to.getSystemClass(), SixSetsEntry.IN, to );
      }  // if
    }  // while

    // 3. if the object itself is a link, we must add it to its source's and
    //    destination's entries:
    if( object.isLink() ) 
    {
      // 3.1 source:
      SixSetsEntry entrySource = getEntry( object.getSource() );
      if( entrySource != null )
        entrySource.addToSet( object.getSystemClass(), 
          SixSetsEntry.OUT, object );

      // 3.2 destination:
      if( object.getDestination() != null ) 
	// attributes may have a null (unknown) destination
      {
	SixSetsEntry entryDestination = getEntry( object.getDestination() );
	if( entryDestination != null )
	  entryDestination.addToSet( object.getSystemClass(), 
	    SixSetsEntry.IN, object );
      }
      else {
	if( object.getSystemClass() != TelosObject.ATTRIBUTE )
	  throw new Error( "Non-attribute has null destination." );
      }
    }  // if

    // 4. add the entry:
    entries.put( object, entry );

    // 5. add the object itself:
    super.add( object );
  }  // add


  /**
   * @param object Telos object
   * -time O(n)
   **/
  public void remove( TelosObject object )
  {
    // 1. remove the object itself:
    super.remove( object );

    // 2. remove the entry:
    entries.remove( object );

    // 3. if the object is a link, we must remove it from its source's and
    //    destination's entries:
    if( object.isLink() )
    {
      // 3.1 source:
      SixSetsEntry entrySource = getEntry( object.getSource() );
      if( entrySource != null )
        entrySource.removeFromSet( object.getSystemClass(), 
          SixSetsEntry.OUT, object );

      // 3.2 destination:
      if( object.getDestination() != null ) 
	// attributes may have a null (unknown) destination
      {
	SixSetsEntry entryDestination = getEntry( object.getDestination() );
	if( entryDestination != null )
	  entryDestination.removeFromSet( object.getSystemClass(), 
	    SixSetsEntry.IN, object );
      }
      else {
	if( object.getSystemClass() != TelosObject.ATTRIBUTE )
	  throw new Error( "Non-attribute has null destination." );
      }
    }  // if
  }  // remove


  /**
   * -time O(1)
   **/
  public void clear()
  {
    super.clear();

    entries = new Hashtable();

    //POST isEmpty()
  }  // clear


  /////////////////////////////////////////////////////////////////////////////
  // GET SETS OF LINKS:
  /////////////////////////////////////////////////////////////////////////////

  /**
   * @param o Telos object
   * -time O(#classes)
   **/
  public ITelosObjectSet getSpecializationsFrom( TelosObject o )
  {
    ITelosObjectSet result;

    SixSetsEntry entry = getEntry( o );

    if( entry == null )
      result = super.getSpecializationsFrom( o );
    else
      result = entry.getSet( TelosObject.SPECIALIZATION, SixSetsEntry.IN );

    return result;
  }  // getSpecializationsFrom


  /**
   * @param object Telos object
   * -time O(#classes)
   **/
  public ITelosObjectSet getGeneralizationsFrom( TelosObject object )
  {
    ITelosObjectSet result;

    SixSetsEntry entry = getEntry( object );

    if( entry == null )
      result = super.getGeneralizationsFrom( object );
    else
      result = entry.getSet( TelosObject.SPECIALIZATION, SixSetsEntry.OUT );

    return result;
  }  // getGeneralizationsFrom


  /**
   * @param object Telos object
   * -time O(#classes)
   **/
  public ITelosObjectSet getInstantiationsOf( TelosObject object )
  {
    ITelosObjectSet result;

    SixSetsEntry entry = getEntry( object );

    if( entry == null )
      result = super.getInstantiationsOf( object );
    else
      result = entry.getSet( TelosObject.INSTANTIATION, SixSetsEntry.IN );

    return result;
  }  // getInstantiationsOf


  /**
   * @param object Telos object
   * -time O(#classes)
   **/
  public ITelosObjectSet getClassificationsOf( TelosObject object )
  {
    ITelosObjectSet result;

    SixSetsEntry entry = getEntry( object );

    if( entry == null )
      result = super.getClassificationsOf( object );
    else
      result = entry.getSet( TelosObject.INSTANTIATION, SixSetsEntry.OUT );

    return result;
  }  // getClassificationsOf


  /**
   * @param object Telos object
   * -time O(#classes)
   **/
  public ITelosObjectSet getAttributesOf( TelosObject object )
  {
    ITelosObjectSet result;

    SixSetsEntry entry = getEntry( object );

    if( entry == null )
      result = super.getAttributesOf( object );
    else
      result = entry.getSet( TelosObject.ATTRIBUTE, SixSetsEntry.OUT );

    return result;
  }  // getAttributesOf


  /**
   * @param object Telos object
   * -time O(#classes)
   **/
  public ITelosObjectSet getAttributesTo( TelosObject object )
  {
    ITelosObjectSet result;

    SixSetsEntry entry = getEntry( object );

    if( entry == null )
      result = super.getAttributesTo( object );
    else
      result = entry.getSet( TelosObject.ATTRIBUTE, SixSetsEntry.IN );

    return result;
  }  // getAttributesTo


  /*
  public ITelosObjectSet getAttributesOfExplicitCategory( TelosObject o, 
    Attribute attrCategory )
  {
    TelosObjectSetSimpleImpl tosAllAttributes = 
      (TelosObjectSetSimpleImpl) getAttributesOf( o );

    UnaryPredicate p = new IsExplicitInstanceOf( attrCategory );

    ITelosObjectSet result =
      getFilteredTelosObjects( tosAllAttributes.objects(), p );

    // Nachbedingung: forall a/result: a in attrCategory

    return result;
  }  // getAttributesOfExplicitCategory
  */


  /**
   * optimierte Version von getSingleAttributeOfCategory(
   *   TelosObject o, Attribute c )
   * Findet nur direkte Instanzen der Attributkategorie c.
   * @return das erstbeste Attribut, das gefunden wird. 
   *   Falls mehrere existieren, wird dies nicht als Fehler angezeigt.
   **/
  public Attribute getSingleAttributeOfExplicitCategory( TelosObject source,
    Attribute attrCategory )
  {
    Attribute result;

    SixSetsEntry entry = getEntry( source );
    if( entry == null ) 
      result = 
        super.getSingleAttributeOfExplicitCategory( source, attrCategory );
    else {
      result = null;
      
      java.util.Enumeration iter = 
        entry.getSet( TelosObject.ATTRIBUTE, SixSetsEntry.OUT ).elements();
      while( iter.hasMoreElements() ) {
        Attribute attr = (Attribute) iter.nextElement();
        if( isExplicitInstanceOf( attr, attrCategory ) ) {
          result = attr;
          break;
        }  // if
      }  // while
    }  // else
    
    return result;
  }  // getSingleExplicitAttributeOf
  
}  // class TelosObjectSetSimpleSixSetsImpl


class SixSetsEntry {
  /**
   * This class relies on the constants defined in TelosObject. If those
   * are changed, the implementation of this class needs to be changed.
   **/
  static {
    if( TelosObject.INSTANTIATION != 1 ||
      TelosObject.SPECIALIZATION != 2 ||
      TelosObject.ATTRIBUTE != 3 )
      throw new Error();
  }

  /**
   * represents incoming links
   **/  
  final static int IN = 0;

  /**
   * represents outgoing links
   **/
  final static int OUT = 1;
  

  /**
   * reference to the object itself
   **/
  TelosObject to;
  

  /**
   * three kinds of links (instantiations, specializations, attributes),
   * each of them in two directions (incoming, outgoing).
   **/  
  private ITelosObjectSet[][] sets = new ITelosObjectSet[3][2];


  SixSetsEntry( TelosObject to )
  {
    this.to = to;
  }


  /**
   * @return is iSystemClass a valid system class?
   *   Must be a link. Individuals are not allowed here.
   **/
  static boolean systemClassIsValid( int iSystemClass )
  {
    return 
      iSystemClass == TelosObject.INSTANTIATION ||
      iSystemClass == TelosObject.SPECIALIZATION ||
      iSystemClass == TelosObject.ATTRIBUTE;
  }
  

  /**
   * provides access to the six sets. Those are created when first accessed.
   * @param iSystemClass  the system class that represents the set
   * @param iInOut  incoming/outgoing links
   * @return  the set represented by iSystemClass and iInOut
   **/
  ITelosObjectSet getSet( int iSystemClass, int iInOut )
  {
    //PRE systemClassIsValid( iSystemClass )

    if( sets[iSystemClass-1][iInOut] == null )
      sets[iSystemClass-1][iInOut] = new TelosObjectSetSimpleImpl();

    return sets[iSystemClass-1][iInOut];
  }


  /**
   * adds object to the set specified by iSystemClass and iInOut
   * @param iSystemClass  the system class that represents the set
   * @param iInOut  incoming/outgoing links
   **/
  void addToSet( int iSystemClass, int iInOut, TelosObject object )
  {
    //PRE systemClassIsValid( iSystemClass )

    ITelosObjectSet set = getSet( iSystemClass, iInOut );
    set.add( object );
  }  // addToSet
  
  
  /**
   * removes object from the set specified by iSystemClass and iInOut
   * @param iSystemClass  the system class that represents the set
   * @param iInOut  incoming/outgoing links
   **/
  void removeFromSet( int iSystemClass, int iInOut, TelosObject object )
  {
    //PRE systemClassIsValid( iSystemClass )
    
    ITelosObjectSet set = getSet( iSystemClass, iInOut );
    set.remove( object );
    
    // moegliche Optimierung (?)
    // if( sets[iSystemClass-1][iInOut].isEmpty() )
    //   sets[iSystemClass-1][iInOut] = null;
  }  // removeFromSet
  
}  // class SixSetsEntry



/*****************************************************************************/
// obsolete:
/*****************************************************************************/

  /**
   * adds entry to the set specified by iSystemClass and iInOut
   * @param iSystemClass  the system class that represents the set
   * @param iInOut  incoming/outgoing links
   * @param entry  the entry to be added
   **/
/*
  void addToSet( int iSystemClass, int iInOut, SixSetsEntry entry )
  {
    //PRE systemClassIsValid( iSystemClass )

    ITelosObjectSet set = getSet( iSystemClass, iInOut );
    set.add( entry );
  }  // addToSet
*/
  
  /**
   * removes entry from the set specified by iSystemClass and iInOut
   * @param iSystemClass  the system class that represents the set
   * @param iInOut  incoming/outgoing links
   * @param entry  the entry to be removed
   **/
/*
  void removeFromSet( int iSystemClass, int iInOut, SixSetsEntry entry )
  {
    //PRE systemClassIsValid( iSystemClass )
    
    ITelosObjectSet set = getSet( iSystemClass, iInOut );
    set.remove( entry );
    
    // moegliche Optimierung (?)
    // if( sets[iSystemClass-1][iInOut].isEmpty() )
    //   sets[iSystemClass-1][iInOut] = null;
  }  // removeFromSet
*/
