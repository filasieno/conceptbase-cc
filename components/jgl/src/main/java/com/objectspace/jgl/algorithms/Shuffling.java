// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;
import java.util.Random;

/**
 * The Shuffling class contains generic shuffling algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.ShufflingExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Shuffling
  {
  static Random randgen = new Random();

  private Shuffling()
    {
    }

  /**
   * Shuffle a sequence with uniform distribution by performing as many random swaps
   * as there are elements. Time complexity is linear and space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @param rand An instance of java.util.Random to use when calculating which elements to swap.
   * @exception IllegalArgumentException If the iterators are incompatible
   *   or if the containers upon which the iteratore operate is not a com.objectspace.jgl.Sequence.
   */
  public static void randomShuffle( BidirectionalIterator first, BidirectionalIterator last, Random rand )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    if ( !(first.getContainer() instanceof Sequence) )
      throw new IllegalArgumentException( "iterator containers must be a Sequence" );

    BidirectionalIterator i = (BidirectionalIterator)first.clone();
    if ( i.equals( last ) )
      return;

    i.advance();
    int n = 2;

    while ( !i.equals( last ) )
      {
      BidirectionalIterator j = (BidirectionalIterator)first.clone();
      j.advance( Math.abs( rand.nextInt() ) % n );
      Swapping.iterSwap( i, j );
      i.advance();
      ++n;
      }
    }

  /**
   * Shuffle a sequence with uniform distribution by performing as many random swaps
   * as there are elements. Time complexity is linear and space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static void randomShuffle( BidirectionalIterator first, BidirectionalIterator last )
    {
    randomShuffle( first, last, randgen );
    }

  /**
   * Shuffle a random access container with uniform distribution by performing as many
   * random swaps as there are elements. Time complexity is linear and space complexity
   * is constant.
   * @param container The container.
   * @param rand An instance of java.util.Random to use when calculating which elements to swap.
   */
  public static void randomShuffle( Container container, Random rand )
    {
    randomShuffle( (BidirectionalIterator)container.start(), (BidirectionalIterator)container.finish(), rand );
    }

  /**
   * Shuffle a random access container with uniform distribution by performing as many
   * random swaps as there are elements. Time complexity is linear and space complexity
   * is constant.
   * @param container The container.
   */
  public static void randomShuffle( Container container )
    {
    randomShuffle( container, randgen );
    }
  }
