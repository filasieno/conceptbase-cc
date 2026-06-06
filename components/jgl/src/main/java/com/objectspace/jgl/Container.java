// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.util.Enumeration;
import java.io.Serializable;

/**
 * Container is the interface that is implemented by all of the
 * Generic Container Library containers.
 * <p>
 * @see com.objectspace.jgl.Array
 * @see com.objectspace.jgl.Deque
 * @see com.objectspace.jgl.DList
 * @see com.objectspace.jgl.HashMap
 * @see com.objectspace.jgl.HashSet
 * @see com.objectspace.jgl.OrderedMap
 * @see com.objectspace.jgl.OrderedSet
 * @see com.objectspace.jgl.PriorityQueue
 * @see com.objectspace.jgl.Queue
 * @see com.objectspace.jgl.SList
 * @see com.objectspace.jgl.Stack
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public interface Container extends Cloneable, Serializable
  {
  /**
   * Return a shallow copy of myself.
   */
  public Object clone();

  /**
   * Return a string that describes me.
   */
  public String toString();

  /**
   * Return true if I'm equal to a specified object.
   * @param object The object to compare myself against.
   * @return true if I'm equal to the specified object.
   */
  public boolean equals( Object object );

  /**
   * Return the number of objects that I contain.
   */
  public int size();

  /**
   * Return the maximum number of objects that I can contain.
   */
  public int maxSize();

  /**
   * Return true if I contain no objects.
   */
  public boolean isEmpty();

  /**
   * Remove all of my objects.
   */
  public void clear();

  /**
   * Return an Enumeration of the components in this container
   */
  public Enumeration elements();

  /**
   * Return an iterator positioned at my first item.
   */
  public ForwardIterator start();

  /**
   * Return an iterator positioned immediately after my last item.
   */
  public ForwardIterator finish();

  /**
   * Add an object to myself. If appropriate, return the object that 
   * displaced it, otherwise return null.
   */
  public Object add( Object object );

  /**
   * Remove the element at a particular position.
   */
  public Object remove( Enumeration pos );

  /**
   * Remove the elements in the specified range.
   */
  public int remove( Enumeration first, Enumeration last );

  static final long serialVersionUID = -3941254391136956618L;
  }
