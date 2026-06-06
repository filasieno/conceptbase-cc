// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

/**
 * BidirectionalIterator is the interface of all iterators that can
 * read and/or write one item at a time in a forwards or backwards direction.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public interface BidirectionalIterator extends ForwardIterator
  {
  /**
   * J++ requires clone
   */
  public Object clone();

  /**
   * Retreat by one.
   */
  public void retreat();

  /**
   * Retreat by a specified amount.
   * @param n The amount to retreat.
   */
  public void retreat( int n );
  }
