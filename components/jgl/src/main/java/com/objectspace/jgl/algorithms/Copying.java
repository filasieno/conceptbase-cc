// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The Copying class contains generic copying algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.CopyingExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Copying
  {
  private Copying()
    {
    }

  /**
   * Copy the elements from one range to another range of the same size.
   * Time complexity is linear and space complexity is constant.
   * @param first An iterator positioned at the first element of the input range.
   * @param last An iterator positioned immediately after the last element of the input range.
   * @param result An iterator positioned at the first element of the output range.
   * @return An iterator positioned immediately after the last element of the output range.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static OutputIterator copy( InputIterator first, InputIterator last, OutputIterator result )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator)first.clone();
    OutputIterator resultx = (OutputIterator)result.clone();

    while ( !firstx.equals( last ) )
      {
      resultx.put( firstx.nextElement() );
      resultx.advance();
      }

    return resultx;
    }

  /**
   * Copy the elements from a container to a sequence.
   * Time complexity is linear and space complexity is constant.
   * @param input The input container.
   * @param result An iterator positioned at the first element of the output sequence.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator copy( Container input, OutputIterator result )
    {
    return copy( input.start(), input.finish(), result );
    }

  /**
   * Insert the elements from one container into another container.
   * Time complexity is linear and space complexity is constant.
   * @param source The source container.
   * @param destination The destination container.
   */
  public static void copy( Container source, Container destination )
    {
    copy( source.start(), source.finish(), new com.objectspace.jgl.util.InsertIterator( destination ) );
    }

  /**
   * Copy the elements backwards from one range to another range of the same size.
   * Time complexity is linear and space complexity is constant.
   * @param first An iterator positioned at the first element of the input range.
   * @param last An iterator positioned immediately after the last element of the input range.
   * @param result An iterator positioned immediately after the last element of the output range.
   * @return An iterator positioned at the first element of the output range.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static OutputIterator copyBackward( BidirectionalIterator first, BidirectionalIterator last, BidirectionalIterator result )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    BidirectionalIterator lastx = (BidirectionalIterator)last.clone();
    BidirectionalIterator resultx = (BidirectionalIterator)result.clone();

    while ( !lastx.equals( first ) )
      {
      resultx.retreat();
      lastx.retreat();
      resultx.put( lastx.get() );
      }

    return resultx;
    }
  }
