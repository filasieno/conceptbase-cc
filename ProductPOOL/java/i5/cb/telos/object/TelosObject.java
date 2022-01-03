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
package i5.cb.telos.object;

import java.util.Hashtable;


/**
 * Telos object, also known as Proposition.<br>
 * TelosObjects are immutable. They don't contain context information about
 * incoming / outgoing links, so they may be contained in more than one object
 * set.<br>
 * Because of immutability, it is possible to share TelosObject instances
 * within a JVM. Thus we can implement the equality relation based on the
 * object ids, which are regular Java object references in our case. This
 * makes equality tests and hash table lookups as fast as possible.
 * Note that we don't have to redefine equals() or hashCode() here, as we
 * inherit the implementation from Object.<br>
 * TelosObject is an abstract class. It has four subclasses: Individual,
 * Instantiation, Specialization and Attribute. The latter three are derived
 * from TelosLink.
 *
 * @author Christoph Radig
 **/

public abstract class TelosObject
  implements java.io.Serializable
{
  /**
   * system class Individual (individual object)
   **/
  public final static int INDIVIDUAL = 0;

  /**
   * system class InstanceOf (instantiation relationship)
   **/
  public final static int INSTANTIATION = 1;

  /**
   * system class IsA (specialization relationship)
   **/
  public final static int SPECIALIZATION = 2;

  /**
   * system class Attribute (attribute relationship)
   **/
  public final static int ATTRIBUTE = 3;


  /**
   * label used for instantiation links
   **/
  public final static String INLABEL = "*in";

  /**
   * label used for specialization links
   **/
  public final static String ISALABEL = "*isa";


  /**
   * global dictionary of all Telos objects
   **/
  protected static Hashtable m_dictAllTelosObjects = new Hashtable();


  /**
   * system classes
   **/
  private static final ITelosObjectSet tosSystemClasses;


  static {
    // create system classes:
    tosSystemClasses = TelosObjectSetFactory.produce();
    tosSystemClasses.add( TelosObject.getIndividual( "Individual" ) );
    tosSystemClasses.add( TelosObject.getIndividual( "InstanceOf" ) );
    tosSystemClasses.add( TelosObject.getIndividual( "IsA" ) );
    tosSystemClasses.add( TelosObject.getIndividual( "Attribute" ) );
  }


  /**
   * @return this object's system class, as an int value
   **/
  public abstract int getSystemClass();
    //POST result >= INDIVIDUAL && result <= ATTRIBUTE


  /**
   * @return this object's system class' name
   **/
  public abstract String getSystemClassName();


  /**
   * @return is this object an individual ("node") object?
   **/
  public final boolean isIndividual()
  {
    return getSystemClass() == INDIVIDUAL;
  }


  /**
   * @return is this object a link (as opposed to an individual object)?
   **/
  public final boolean isLink()
  {
    return getSystemClass() != INDIVIDUAL;
  }


  /**
   * @return is this object an instantiation?
   **/
  public final boolean isInstantiation()
  {
    return getSystemClass() == INSTANTIATION;
  }


  /**
   * @return is this object a specialization?
   **/
  public final boolean isSpecialization()
  {
    return getSystemClass() == SPECIALIZATION;
  }


  /**
   * @return is this object an attribute?
   **/
  public final boolean isAttribute()
  {
    return getSystemClass() == ATTRIBUTE;
  }


  /**
   * @return is this object one of the four system classes?
   **/
  public final boolean isSystemClass()
  {
    return tosSystemClasses.contains( this );
  }


  /**
   * @return this object's source
   **/
  public abstract TelosObject getSource();
    //POST result != null


  /**
   * @return this object's label
   **/
  public abstract String getLabel();


  /**
   * @return this object's destination. Might be null for attributes.
   * @see i5.cb.telos.Transform#toTelosObject
   **/
  public abstract TelosObject getDestination();


  /**
   * @param  bLong  long OID format? The long format includes the class name.
   * @return  String representation of this object's OID, which correspond
   *    to the object's reference (=address or handle) in this JVM.
   *    That is, our OIDs are unique in one JVM.
   **/
  public String getOID( boolean bLong )
  {
    return bLong ? super.toString() : getOID();
  }


  /**
   * @return  String representation of this object's OID, short format.
   **/
  public final String getOID()
  {
    return String.valueOf( System.identityHashCode( this ) );
  }


  /**
   * @return Proposition representation: P(id,src,label,dest)
   * @param bLongOID  long OID format?
   **/
  public String asProposition( boolean bLongOID )
  {
    String result =
      "P(" + getOID( bLongOID ) + "," + getSource().getOID( bLongOID ) + "," +
      getLabel() + "," +
      ( getDestination() != null ?
    getDestination().getOID( bLongOID ) : "<UNKNOWN>" ) +
      ")";

    return result;
  }  // asProposition


  /**
   * @return Proposition representation: P(id,src,label,dest).
   *   Short OID format.
   **/
  public final String asProposition()
  {
    return asProposition( false );
  }


  /**
   * @return the full object name of the object as string
   **/
  public String toString()
  {
      if(isInstantiation())
        return "(" + getSource().toString() + "->" + getDestination().toString() + ")";
      if(isSpecialization())
        return "(" + getSource().toString() + "=>" + getDestination().toString() + ")";
      if(isAttribute())
        return getSource().toString() + "!" + getLabel();

      return getLabel(); // if individual
  }


  /*
  static Object getTelosObject( TelosObject source, String sLabel,
                TelosObject destination )
  {
    String sKey =
      "src:" + getOID() + " label:" + sLabel + " dest:" + destination;
    cr.Debug.one.println( "TelosObject.getTelosObject: key == " + sKey );

    return m_dictAllTelosObjects.get( sKey );
  }  // getTelosObject
  */


  /**
   * @return the individual with the given label, if there is one.
   *   null otherwise.
   **/
  static Individual lookupIndividual( String sLabel )
  {
    //PRE sLabel != null

    String sKey = sLabel;

    return (Individual) m_dictAllTelosObjects.get( sKey );
  }


  static Instantiation lookupInstantiation(
    TelosObject source, TelosObject destination )
  {
    //PRE source != null
    //PRE destination != null

    String sKey = getKey( source, INLABEL, destination );

    return (Instantiation) m_dictAllTelosObjects.get( sKey );
  }


  static Specialization lookupSpecialization(
    TelosObject source, TelosObject destination )
  {
    //PRE source != null
    //PRE destination != null

    String sKey = getKey( source, ISALABEL, destination );

    return (Specialization) m_dictAllTelosObjects.get( sKey );
  }


  /**
   * @param destination  is needed here. May be null.
   *   @see i5.cb.telos.Transform#toTelosObject
   **/
  static Attribute lookupAttribute(
    TelosObject source, String sLabel, TelosObject destination )
  {
    //PRE source != null
    //PRE sLabel != null

    String sKey = getKey( source, sLabel, destination );

    return (Attribute) m_dictAllTelosObjects.get( sKey );
  }


  /**
   * @return the individual with the given label, if there is one.
   *   a freshly created individual, otherwise.
   **/
  public static Individual getIndividual( String sLabel )
  {
    //PRE sLabel != null

    Individual result = lookupIndividual( sLabel );

    if( result == null ) {
      result = new Individual( sLabel );
      String sKey = sLabel;
      m_dictAllTelosObjects.put( sKey, result );
    }

    //POST result != null

    return result;
  }  // getIndividual


  public static Instantiation getInstantiation( TelosObject source,
                        TelosObject destination )
  {
    //PRE source != null
    //PRE destination != null

    Instantiation result = lookupInstantiation( source, destination );

    if( result == null ) {
      result = new Instantiation( source, destination );
      String sKey = getKey( source, INLABEL, destination );
      m_dictAllTelosObjects.put( sKey, result );
    }

    //POST result != null

    return result;
  }  // getInstantiation


  public static Specialization getSpecialization( TelosObject source,
                          TelosObject destination )
  {
    //PRE source != null
    //PRE destination != null

    Specialization result = lookupSpecialization( source, destination );

    if( result == null ) {
      result = new Specialization( source, destination );
      String sKey = getKey( source, ISALABEL, destination );
      m_dictAllTelosObjects.put( sKey, result );
    }

    //POST result != null

    return result;
  }  // getSpecialization


  /**
   * @param destination  is needed here. May be null.
   *   @see i5.cb.telos.Transform#toTelosObject
   **/
  public static Attribute getAttribute( TelosObject source, String sLabel,
                    TelosObject destination )
  {
    //PRE source != null
    //PRE sLabel != null

    Attribute result = lookupAttribute( source, sLabel, destination );

    if( result == null ) {
      result = new Attribute( source, sLabel, destination );
      String sKey = getKey( source, sLabel, destination );
      m_dictAllTelosObjects.put( sKey, result );
    }

    //POST result != null

    return result;
  }  // getAttribute


  /**
   * @return  a unique key used to identify TelosObjects
   * @param destination  may be null for attributes.
   *   @see i5.cb.telos.Transform#toTelosObject
   **/
  protected static final String getKey( TelosObject source, String sLabel,
    TelosObject destination )
  {
    //PRE source != null
    //PRE sLabel != null

    return source.getOID() + "-" + sLabel + "-" +
      ( destination != null ? destination.getOID() : "<UNKNOWN>" );
  }


  /**
   * Get all Telos objects that have been created at the client side
   */
  public static final java.util.Collection getAllTelosObjects() {
      return m_dictAllTelosObjects.values();
  }

}  // class TelosObject


