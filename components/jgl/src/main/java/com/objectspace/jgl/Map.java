// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl;

import java.util.Dictionary;
import java.util.Enumeration;

/**
 * Map is the abstract class that in implemented by all JGL maps.
 * <p>
 * This is an abstract class and not an interface because it extends the JDK
 * Dictionary class.
 * <p>
 * @see com.objectspace.jgl.HashMap
 * @see com.objectspace.jgl.OrderedMap
 * @see java.util.Dictionary
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public abstract class Map extends Dictionary implements Container
  {
  /**
   * Return the number of key/value pairs that match a particular key.
   * @param key The key to match against.
   */
  public abstract int count( Object key );

  /**
   * Return the number of values that match a given object.
   * @param value The value to match against.
   */
  public abstract int countValues( Object value );

  /**
   * Return an Enumeration of all my keys that are associated with a particular value.
   * @param value The value to match.
   */
  public abstract Enumeration keys( Object value );

  /**
   * Return an Enumeration of all my values that are associated with a particular key.
   * @param key The key to match.
   */
  public abstract Enumeration values( Object key );

  //
  // The following methods are all from the Container interface.
  // They are listed here again in this manner to avoid a compiler problem.
  // Please consider them abstract.
  //

  /**
   * Return a shallow copy of myself.
   */
  public /* abstract */ Object clone()
    {
    throw new AbstractMethodError( "Map error: Redefine in derived classes" );
    }

  /**
   * Return a string that describes me.
   */
  public /* abstract */ String toString()
    {
    throw new AbstractMethodError( "Map error: Redefine in derived classes" );
    }

  /**
   * Return true if I'm equal to a specified object.
   * @param object The object to compare myself against.
   * @return true if I'm equal to the specified object.
   */
  public /* abstract */ boolean equals( Object object )
    {
    throw new AbstractMethodError( "Map error: Redefine in derived classes" );
    }

  /**
   * Return the number of objects that I contain.
   */
  public /* abstract */ int size()
    {
    throw new AbstractMethodError( "Map error: Redefine in derived classes" );
    }

  /**
   * Return the maximum number of objects that I can contain.
   */
  public /* abstract */ int maxSize()
    {
    throw new AbstractMethodError( "Map error: Redefine in derived classes" );
    }

  /**
   * Return true if I contain no objects.
   */
  public /* abstract */ boolean isEmpty()
    {
    throw new AbstractMethodError( "Map error: Redefine in derived classes" );
    }

  /**
   * Remove all of my objects.
   */
  public /* abstract */ void clear()
    {
    throw new AbstractMethodError( "Map error: Redefine in derived classes" );
    }

  /**
   * Return an Enumeration of the components in this container
   */
  public /* abstract */ Enumeration elements()
    {
    throw new AbstractMethodError( "Map error: Redefine in derived classes" );
    }

  /**
   * Return an iterator positioned at my first item.
   */
  public /* abstract */ ForwardIterator start()
    {
    throw new AbstractMethodError( "Map error: Redefine in derived classes" );
    }

  /**
   * Return an iterator positioned immediately after my last item.
   */
  public /* abstract */ ForwardIterator finish()
    {
    throw new AbstractMethodError( "Map error: Redefine in derived classes" );
    }

  /**
   * Add an object to myself. If appropriate, return the object that it replaced, otherwise
   * return null.
   */
  public /* abstract */ Object add( Object object )
    {
    throw new AbstractMethodError( "Map error: Redefine in derived classes" );
    }

  static final long serialVersionUID = 7514329613574089280L;
  }
