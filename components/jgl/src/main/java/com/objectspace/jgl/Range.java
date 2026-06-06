// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

/**
 * An Range is an object that contains two forward iterators.
 * It is most commonly used for conveniently storing and passing pairs
 * of iterators.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class Range
  {
  /**
   * The begin iterator
   */
  public ForwardIterator begin;

  /**
   * The end iterator
   */
  public ForwardIterator end;

  /**
   * Construct myself to hold a pair of iterators.
   * @param x The first object.
   * @param y The second object.
   */
  public Range( ForwardIterator begin, ForwardIterator end )
    {
    this.begin = begin;
    this.end = end;
    }

  /**
   * Construct myself to hold a pair of iterators initially null.
   */
  public Range()
    {
    this.begin = null;
    this.end = null;
    }

  /**
   * Return a string that describes me.
   */
  public String toString()
    {
    return "Range( " + begin + ", " + end + " )";
    }

  public boolean equals( Object object )
    {
    return object instanceof Range && equals( (Range) object );
    }

  public boolean equals( Range range )
    {
    return begin.equals( range.begin ) && end.equals( range.end );
    }
  }
