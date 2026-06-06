// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

/**
 * OutputIterator is the interface of all iterators that can write one
 * item at a time in a forward direction.
 * <p>
 * @see com.objectspace.jgl.InputIterator
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public interface OutputIterator extends Cloneable
  {
  /**
   * Set the object at my current position to a specified value.
   * @param object The object to be written at my current position.
   */
  public void put( Object object );

  /**
   * Advance by one.
   */
  public void advance();

  /**
   * Advance by a specified amount.
   * @param n The amount to advance.
   */
  public void advance( int n );

  /**
   * Return a clone of myself.
   */
  public Object clone();
  }
