// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

/**
 * Set is the interface that is implemented by all of the
 * Generic Container Library sets.
 * <p>
 * @see com.objectspace.jgl.HashSet
 * @see com.objectspace.jgl.OrderedSet
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public interface Set extends Container
  {
  /**
   * Return the first object that matches the given object, or null if no match exists.
   * @param object The object to match against.
   * @see com.objectspace.jgl.Set#put
   */
  public Object get( Object object );

  /**
   * If the object doesn't exist, add the object and return null, otherwise replace the
   * first object that matches and return the old object.
   * @param object The object to add.
   * @see com.objectspace.jgl.Set#get
   */
  public Object put( Object object );

  /**
   * Remove all objects that match the given object.
   * @param object The object to match for removals
   * @return The number of objects removed.
   */
   public int remove( Object key );

  /**
   * Remove at most a given number of objects that match the given object.
   * @param object The object to match for removals
   * @param count The maximum number of objects to remove.
   * @return The number of objects removed.
   */
   public int remove( Object key, int count );

  /**
   * Return the number of items that match a particular object.
   * @param object The object to match against.
   */
  public int count( Object object );

  /**
   * Return a shallow copy of myself.
   */
  public Object clone();

  static final long serialVersionUID = 5169392567310475882L;
  }
