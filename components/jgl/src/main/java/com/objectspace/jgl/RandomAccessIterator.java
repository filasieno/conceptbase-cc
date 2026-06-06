// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

/**
 * RandomAccessIterator is the interface of all iterators that can
 * read and/or write one item at a time in a forwards or backwards
 * direction. In addition, two random access iterators may be efficiently
 * compared for their relative location to each other.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public interface RandomAccessIterator extends BidirectionalIterator
  {
  /**
   * Return the index of my current position.
   */
  public int index();

  /**
   * Return true if I'm before a specified iterator.
   * @param iterator The iterator to compare myself against.
   */
  public boolean less( RandomAccessIterator iterator );

  /**
   * Return a clone of myself.
   */
  public Object clone();
  }
