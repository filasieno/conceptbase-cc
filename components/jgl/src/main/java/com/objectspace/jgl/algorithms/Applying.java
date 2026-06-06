// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The Applying class contains generic applying algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.ApplyingExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Applying
  {
  private Applying()
    {
    }

  /**
   * Apply a unary function to every element in a specified range.
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element in the range.
   * @param last An iterator positioned immediately after the last element in the range.
   * @param function The unary function to apply.
   * @return The unary function.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static UnaryFunction forEach( InputIterator first, InputIterator last, UnaryFunction function )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator)first.clone();
    while ( !firstx.equals( last ) )
      {
      function.execute( firstx.get() );
      firstx.advance();
      }

    return function;
    }

  /**
   * Apply a unary function to every element in a container.
   * The time complexity is linear and the space complexity is constant.
   * @param container The container.
   * @param function The unary function to apply.
   * @return The unary function.
   */
  public static UnaryFunction forEach( Container container, UnaryFunction function )
    {
    return forEach( container.start(), container.finish(), function );
    }

  /**
   * Inject a specified range with a binary function and an initial value.
   * Calculate the initial result by calling the function with the initial value as the
   * first parameter and the first element as the second parameter. Then apply the function
   * to the remaining elements, using the previous result as the first parameter and the
   * next element as the second parameter. Return the last result.
   * @param first An iterator positioned at the first element in the range.
   * @param last An iterator positioned immediately after the last element in the range.
   * @param object An object to use as a starting result to the binary function.
   * @param function A binary function.
   * @return The result of the last binary function call.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static Object inject( InputIterator first, InputIterator last, Object object, BinaryFunction function )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator)first.clone();
    while ( !firstx.equals( last ) )
      object = function.execute( object, firstx.nextElement() );

    return object;
    }

  /**
   * Inject a container with a binary function and an initial value.
   * Calculate the initial result by calling the function with the initial value as the
   * first parameter and the first element as the second parameter. Then apply the function
   * to the remaining elements, using the previous result as the first parameter and the
   * next element as the second parameter. Return the last result.
   * @param container A container.
   * @param object An object to use as a starting result to the binary function.
   * @param function A binary function.
   * @return The result of the last binary function call.
   */
  public static Object inject( Container container, Object object, BinaryFunction function )
    {
    return inject( container.start(), container.finish(), object, function );
    }
  }
