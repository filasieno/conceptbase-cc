// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The Rotating class contains generic rotating algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.RotatingExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Rotating
  {
  private Rotating()
    {
    }

  /**
   * Rotate a sequence to the left. After the operation, the element that used to be
   * located by the first iterator is positioned immediately before the position
   * indicated by the second iterator. The time complexity is linear and the space
   * complexity is constant.
   * @param first An iterator positioned at the first element in the sequence.
   * @param middle An iterator positioned immediately after the target location of the first element in the sequence.
   * @param last An iterator positioned at the last element in the sequence.
   * @exception IllegalArgumentException If the iterators are incompatible
   *   or if the containers upon which the iteratore operate is not a com.objectspace.jgl.Sequence.
   */
  public static void rotate( ForwardIterator first, ForwardIterator middle, ForwardIterator last )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    if ( !(first.getContainer() instanceof Sequence) )
      throw new IllegalArgumentException( "iterator containers must be a Sequence" );

    // use clone() for proper Voyager equals() behavior
    if ( first.clone().equals( middle ) || middle.clone().equals( last ) )
      return;

    if ( first instanceof RandomAccessIterator )
      rotateRandomAccess( (RandomAccessIterator) first, (RandomAccessIterator) middle, (RandomAccessIterator) last );
    else if ( first instanceof BidirectionalIterator )
      rotateBidirectional( (BidirectionalIterator) first, (BidirectionalIterator) middle, (BidirectionalIterator) last );
    else
      rotateForward( first, middle, last );
    }

  /**
   * Perform the same operations as rotate(), except that that the result is placed
   * into a separate sequence. The time complexity is linear and the space complexity is
   * constant.
   * @param first An iterator positioned at the first element in the input sequence.
   * @param middle An iterator positioned immediately after the target location of the first element in the input sequence.
   * @param last An iterator positioned at the last element in the input sequence.
   * @param result An iterator positioned at the first element in the output sequence.
   * @return An iterator positioned immediately after the last element in the output sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static OutputIterator rotateCopy( ForwardIterator first, ForwardIterator middle, ForwardIterator last, OutputIterator result )
    {
    return Copying.copy( first, middle, Copying.copy( middle, last, result ) );
    }

  static void rotateBidirectional( BidirectionalIterator first, BidirectionalIterator middle, BidirectionalIterator last )
    {
    Reversing.reverse( first, middle );
    Reversing.reverse( middle, last );
    Reversing.reverse( first, last );
    }

  static void rotateForward( ForwardIterator first, ForwardIterator middle, ForwardIterator last )
    {
    ForwardIterator firstx = (ForwardIterator) first.clone();
    ForwardIterator middlex = (ForwardIterator) middle.clone();
    ForwardIterator i = (ForwardIterator) middle.clone();

    while ( true )
      {
      Swapping.iterSwap( firstx, i );
      firstx.advance();
      i.advance();

      if ( firstx.equals( middlex ) )
        {
        if ( i.equals( last ) )
          return;

        middlex = (ForwardIterator)i.clone();
        }
      else if ( i.equals( last ) )
        {
        i = (ForwardIterator)middlex.clone();
        }
      }
    }

  static void rotateRandomAccess( RandomAccessIterator first, RandomAccessIterator middle, RandomAccessIterator last )
    {
    int n = gcd( first.distance( last ), first.distance( middle ) );

    while ( n-- != 0 )
      {
      RandomAccessIterator i = (RandomAccessIterator) first.clone();
      i.advance( n );
      cycle( first, last, i, first.distance( middle ) );
      }
    }

  static int gcd( int m, int n )
    {
    while ( n != 0 )
      {
      int t = m % n;
      m = n;
      n = t;
      }

    return m;
    }

  static void cycle( RandomAccessIterator first, RandomAccessIterator last, RandomAccessIterator initial, int shift )
    {
    Object value = initial.get();
    RandomAccessIterator ptr1 = (RandomAccessIterator) initial.clone();
    RandomAccessIterator ptr2 = (RandomAccessIterator) ptr1.clone();
    ptr2.advance( shift );

    while ( !ptr2.equals( initial ) )
      {
      ptr1.put( ptr2.get() );
      ptr1 = (RandomAccessIterator) ptr2.clone();

      if ( ptr2.distance( last ) > shift )
        {
        ptr2.advance( shift );
        }
      else
        {
        int delta = shift - ptr2.distance( last );
        ptr2 = (RandomAccessIterator) first.clone();
        ptr2.advance( delta );
        }
      }

    ptr1.put( value );
    }
  }
