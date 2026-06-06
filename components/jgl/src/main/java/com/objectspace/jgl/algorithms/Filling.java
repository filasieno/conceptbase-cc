// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The Filling class contains generic filling algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.FillingExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Filling
  {
  private Filling()
    {
    }

  /**
   * Fill a specified range with a particular value.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @param object The object to fill the sequence with.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static void fill( ForwardIterator first, ForwardIterator last, Object object )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    ForwardIterator firstx = (ForwardIterator)first.clone();
    while ( !firstx.equals( last ) )
      {
      firstx.put( object );
      firstx.advance();
      }
    }

  /**
   * Fill a container with a particular value.
   * @param container The container.
   * @param object The object to fill the container with.
   */
  public static void fill( Container container, Object object )
    {
    fill( container.start(), container.finish(), object );
    }

  /**
   * Assign an object to a number of elements starting at a specified location.
   * @param output An iterator positioned at the first element of the sequence.
   * @param n The number of objects to assign.
   * @param object The object to fill the sequence with.
   */
  public static void fillN( OutputIterator output, int n, Object object )
    {
    OutputIterator outputx = (OutputIterator)output.clone();

    while ( n-- > 0 )
      {
      outputx.put( object );
      outputx.advance();
      }
    }
  }
