// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The Hashing class contains generic hashing algorithms.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Hashing
  {
  static final int HASH_SIZE = 16;

  private Hashing()
    {
    }

  /**
   * Compute an hash value for an ordered container.
   */
  public static int orderedHash( Container c )
    {
    return orderedHash( c.start(), c.finish() );
    }

  /**
   * Compute a hash value for a range of elements in an ordered container
   * Hashing on an ordered container requires that all
   * elements in the container that are used in the hash
   * have the position taken into account.
   * The hashing scheme uses all contained elements if the size
   * of the range is less than HASH_SIZE.  If the size of the range
   * is > HASH_SIZE, only representative samples are used to increase
   * performance.  Position is taken into account for each element
   * used in the hash by taking the position modulo HASH_SIZE plus one
   * and using this result as a divisor on the actual hash code
   * of the element.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static int orderedHash( ForwardIterator first, ForwardIterator last )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    int h = 0;
    int length = first.distance( last );
    int position = 0;
    int skip = 1;
    if ( length >= HASH_SIZE )
      {
      skip = length / HASH_SIZE;
      // insure that first will always exactly reach last
      first.advance( length % HASH_SIZE );
      }
    ForwardIterator firstx = (ForwardIterator)first.clone();
    while ( !firstx.equals( last ) )
      {
      Object obj = firstx.get();
      if ( obj != null )
        h ^= obj.hashCode() / ( ( position % HASH_SIZE ) + 1 );
      ++position;
      firstx.advance( skip );
      }
    return h;
    }

  /**
   * Compute an hash value for an unordered container.
   */
  public static int unorderedHash( Container c )
    {
    return unorderedHash( c.start(), c.finish() );
    }

  /**
   * Compute a hash value for a range of elements in an
   * uordered container.
   * Hashing on an unordered container requires that all
   * elements in the container are used in the hash.
   * A simple XOR scheme is used over all elements to
   * ensure that equality is maintained over like ranges.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static int unorderedHash( ForwardIterator first, ForwardIterator last )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    int h = 0;
    ForwardIterator firstx = (ForwardIterator)first.clone();
    while ( !firstx.equals( last ) )
      {
      Object obj = firstx.get();
      if ( obj != null )
        h ^= obj.hashCode();
      firstx.advance();
      }
    return h;
    }
 }
