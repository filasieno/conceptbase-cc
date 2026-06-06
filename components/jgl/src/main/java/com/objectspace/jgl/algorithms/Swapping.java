// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The Swapping class contains generic swapping algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.SwappingExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Swapping
  {
  private Swapping()
    {
    }

  /**
   * Swap the objects referenced by two iterators.
   * @param iterator1 The first iterator.
   * @param iterator2 The second iterator.
   **/
  public static void iterSwap( ForwardIterator iterator1, ForwardIterator iterator2 )
    {
    Object tmp = iterator1.get();
    iterator1.put( iterator2.get() );
    iterator2.put( tmp );
    }

  /**
   * Swap the elements in one sequence with the elements in another sequence of the
   * same size.
   * @param first1 An iterator positioned at the first element of the first sequence.
   * @param last1 An iterator positioned immediately after the last element of the first sequence.
   * @param first2 An iterator positioned at the first element of the second sequence.
   * @return An iterator positioned immediately after the last element in the second sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static ForwardIterator swapRanges( ForwardIterator first1, ForwardIterator last1, ForwardIterator first2 )
    {
    if ( !first1.isCompatibleWith( last1 ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    ForwardIterator first1x = (ForwardIterator) first1.clone();
    ForwardIterator first2x = (ForwardIterator) first2.clone();

    while ( !first1x.equals( last1 ) )
      {
      iterSwap( first1x, first2x );
      first1x.advance();
      first2x.advance();
      }

    return first2x;
    }

  /**
   * Swap the elements in one container with the elements in another container of the
   * same size.
   * @param container1 The first container.
   * @param container2 The second container.
   * @return An iterator positioned immediately after the last element in the second container.
   */
  public static ForwardIterator swapRanges( Container container1, Container container2 )
    {
    return swapRanges( container1.start(), container1.finish(), container2.start() );
    }
  }
