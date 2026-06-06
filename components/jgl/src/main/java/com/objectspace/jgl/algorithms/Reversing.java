// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The Reversing class contains generic reversing algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.ReversingExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Reversing
  {
  private Reversing()
    {
    }

  /**
   * Reverse a sequence. The time complexity is linear and the space complexity is
   * constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static void reverse( BidirectionalIterator first, BidirectionalIterator last )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    if ( !(first.getContainer() instanceof Sequence) )
      throw new IllegalArgumentException( "iterator containers must be a Sequence" );

    if ( first instanceof RandomAccessIterator )
      {
      RandomAccessIterator firstx = (RandomAccessIterator) first.clone();
      RandomAccessIterator lastx = (RandomAccessIterator) last.clone();

      while ( firstx.less( lastx ) )
        {
        lastx.retreat();
        Swapping.iterSwap( firstx, lastx );
        firstx.advance();
        }
      }
    else
      {
      BidirectionalIterator firstx = (BidirectionalIterator) first.clone();
      BidirectionalIterator lastx = (BidirectionalIterator) last.clone();

      while ( true )
        {
        if ( firstx.equals( lastx ) )
          return;

        lastx.retreat();

        if ( firstx.equals( lastx ) )
          return;

        Swapping.iterSwap( firstx, lastx );
        firstx.advance();
        }
      }
    }

  /**
   * Reverse a container. The time complexity is linear and the space complexity is
   * constant.
   * @param container The container to reverse.
   */
  public static void reverse( Container container )
    {
    reverse( (BidirectionalIterator) container.start(), (BidirectionalIterator) container.finish() );
    }

  /**
   * Copy the reverse of a sequence into another sequence of the same size. The
   * time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element of the input sequence.
   * @param last An iterator positioned immediately after the last element of the input sequence.
   * @param result An iterator positioned at the first element of the output sequence.
   * @return An iterator positioned immediately after the last element of the output sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static OutputIterator reverseCopy( BidirectionalIterator first, BidirectionalIterator last, OutputIterator result )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    if ( !(first.getContainer() instanceof Sequence) )
      throw new IllegalArgumentException( "iterator containers must be a Sequence" );

    BidirectionalIterator lastx = (BidirectionalIterator) last.clone();
    OutputIterator resultx = (OutputIterator) result.clone();

    while ( !lastx.equals( first ) )
      {
      lastx.retreat();
      resultx.put( lastx.get() );
      resultx.advance();
      }

    return resultx;
    }

  /**
   * Copy the reverse of a container into a sequence. The time complexity is linear and
   * the space complexity is constant.
   * @param input The input container.
   * @param result An iterator positioned at the first element of the output sequence.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator reverseCopy( Container input, OutputIterator result )
    {
    return reverseCopy( (BidirectionalIterator) input.start(), (BidirectionalIterator) input.finish(), result );
    }

  /**
   * Copy the reverse of a container into another container. The time complexity is
   * linear and the space complexity is constant.
   * @param source The source container.
   * @param destination The destination container.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static void reverseCopy( Container source, Container destination )
    {
    reverseCopy( (BidirectionalIterator) source.start(), (BidirectionalIterator) source.finish(), new com.objectspace.jgl.util.InsertIterator( destination ) );
    }
  }
