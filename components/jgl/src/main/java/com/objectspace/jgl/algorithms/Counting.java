// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The Counting class contains generic counting algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.CountingExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Counting
  {
  private Counting()
    {
    }

  /**
   * Return the number of elements in a range that match a particular object using
   * equals(). The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element in the range.
   * @param last An iterator positioned immediately after the last element in the range.
   * @param object The object to count.
   * @return The number of objects that matched.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static int count( InputIterator first, InputIterator last, Object object )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator)first.clone();
    int n = 0;

    while ( !firstx.equals( last ) )
      if ( firstx.nextElement().equals( object ) )
        ++n;

    return n;
    }

  /**
   * Return the number of elements in a container that match a particular object using
   * equals(). The time complexity is linear and the space complexity is constant.
   * @param container The container.
   * @param object The object to count.
   * @return The number of objects that matched.
   */
  public static int count( Container container, Object object )
    {
    return count( container.start(), container.finish(), object );
    }

  /**
   * Return the number of elements in a range that satisfy a predicate.
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element in the range.
   * @param last An iterator positioned immediately after the last element in the range.
   * @param predicate A unary predicate.
   * @return The number of objects that matched.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static int countIf( InputIterator first, InputIterator last, UnaryPredicate predicate )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator)first.clone();
    int n = 0;
    while ( !firstx.equals( last ) )
      if ( predicate.execute( firstx.nextElement() ) )
        ++n;

    return n;
    }

  /**
   * Return the number of elements in a container that satisfy a predicate.
   * The time complexity is linear and the space complexity is constant.
   * @param container The container.
   * @param predicate A unary predicate.
   * @return The number of objects that matched.
   */
  public static int countIf( Container container, UnaryPredicate predicate )
    {
    return countIf( container.start(), container.finish(), predicate );
    }

  /**
   * Add the value of each element in a range to an inital value and return the
   * sum.  All elements the iterators represent must be instances of
   * java.lang.Number.  Use com.objectspace.jgl.functions.PlusNumber( init.getClass() ) to perform the addition.
   * @param first An iterator positioned at the first element in the range.
   * @param last An iterator positioned immediately after the last element in the range.
   * @return The number of objects that matched.
   * @exception IllegalArgumentException If the iterators are incompatible.
   * @see java.lang.Number
   * @see com.objectspace.jgl.functions.PlusNumber
   */
  public static Number accumulate( InputIterator first, InputIterator last, Number init )
    {
    return accumulate( first, last, init, new com.objectspace.jgl.functions.PlusNumber( init.getClass() ) );
    }

  /**
   * Add the value of each element in a container to an inital value and return the
   * sum.  All elements the iterators represent must be instances of
   * java.lang.Number.  Use com.objectspace.jgl.functions.PlusNumber( init.getClass() ) to perform the addition.
   * @param container The container.
   * @return The number of objects that matched.
   * @see java.lang.Number
   * @see com.objectspace.jgl.functions.PlusNumber
   */
  public static Number accumulate( Container container, Number init )
    {
    return accumulate
      (
      container.start(),
      container.finish(),
      init,
      new com.objectspace.jgl.functions.PlusNumber( init.getClass() )
      );
    }

  /**
   * Add the value of each element in a range to an inital value and return the
   * sum.  All elements the iterators represent must be instances of
   * java.lang.Number.  Use a specified binary function to perform the addition.
   * @param first An iterator positioned at the first element in the range.
   * @param last An iterator positioned immediately after the last element in the range.
   * @param function A binary function.
   * @return The number of objects that matched.
   * @exception IllegalArgumentException If the iterators are incompatible.
   * @see java.lang.Number
   */
  public static Number accumulate( InputIterator first, InputIterator last, Number init, BinaryFunction function )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator)first.clone();

    while ( !firstx.equals( last ) )
      init = (Number)function.execute( init, firstx.nextElement() );

    return init;
    }

  /**
   * Add the value of each element in a container to an inital value and return the
   * sum.  All elements the iterators represent must be instances of
   * java.lang.Number.  Use a specified binary function to perform the addition.
   * @param container The container.
   * @return The number of objects that matched.
   * @see java.lang.Number
   */
  public static Number accumulate( Container container, Number init, BinaryFunction function )
    {
    return accumulate( container.start(), container.finish(), init, function );
    }

  /**
   * Iterate through every element in a range and calculate the difference between
   * each element and its preceding element.
   * Use com.objectspace.jgl.functions.MinusNumber() to calculate the difference.
   * Assignment back into the original range is allowed.
   * @param first An iterator positioned at the first element in the range.
   * @param last An iterator positioned immediately after the last element in the range.
   * @param result An iterator positioned at the first element of the output range.
   * @return An iterator positioned immediately after the last element of the output range.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static OutputIterator adjacentDifference( InputIterator first, InputIterator last, OutputIterator result )
    {
    return adjacentDifference( first, last, result, new com.objectspace.jgl.functions.MinusNumber() );
    }

  /**
   * Iterate through every element in a container and calculate the difference between
   * each element and its preceding element.
   * Use com.objectspace.jgl.functions.MinusNumber() to calculate the difference.
   * Assignment back into the original range is allowed.
   * @param input The input container.
   * @param result An iterator positioned at the first element of the output range.
   * @return An iterator positioned immediately after the last element of the output range.
   */
  public static OutputIterator adjacentDifference( Container input, OutputIterator result )
    {
    return adjacentDifference
      (
      input.start(),
      input.finish(),
      result,
      new com.objectspace.jgl.functions.MinusNumber()
      );
    }

  /**
   * Iterate through every element in a container and calculate the difference between
   * each element and its preceding element.
   * Use com.objectspace.jgl.functions.MinusNumber() to calculate the difference.
   * Assignment back into the original range is allowed.
   * @param source The source container.
   * @param destination The destination container.
   * @return An iterator positioned immediately after the last element of the output range.
   */
  public static OutputIterator adjacentDifference( Container source, Container destination )
    {
    return adjacentDifference
      (
      source.start(),
      source.finish(),
      new com.objectspace.jgl.util.InsertIterator( destination ),
      new com.objectspace.jgl.functions.MinusNumber()
      );
    }

  /**
   * Iterate through every element in a range and calculate the difference between
   * each element and its preceding element.
   * Assignment back into the original range is allowed.
   * @param first An iterator positioned at the first element in the range.
   * @param last An iterator positioned immediately after the last element in the range.
   * @param result An iterator positioned at the first element of the output range.
   * @param function A binary function.
   * @return An iterator positioned immediately after the last element of the output range.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static OutputIterator adjacentDifference( InputIterator first, InputIterator last, OutputIterator result, BinaryFunction function )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    OutputIterator resultx = (OutputIterator)result.clone();
    if ( first.equals( last ) )
      return resultx;

    InputIterator firstx = (InputIterator)first.clone();
    resultx.put( firstx.get() );
    resultx.advance();

    Object value = firstx.nextElement();
    while ( !firstx.equals( last ) )
      {
      Object tmp = firstx.nextElement();
      resultx.put( function.execute( tmp, value ) );
      resultx.advance();
      value = tmp;
      }

    return resultx;
    }

  /**
   * Iterate through every element in a container and calculate the difference between
   * each element and its preceding element.
   * Assignment back into the original range is allowed.
   * @param input The input container.
   * @param result An iterator positioned at the first element of the output range.
   * @param function A binary function.
   * @return An iterator positioned immediately after the last element of the output range.
   */
  public static OutputIterator adjacentDifference( Container input, OutputIterator result, BinaryFunction function )
    {
    return adjacentDifference( input.start(), input.finish(), result, function );
    }

  /**
   * Iterate through every element in a container and calculate the difference between
   * each element and its preceding element.
   * Assignment back into the original range is allowed.
   * @param source The source container.
   * @param destination The destination container.
   * @param function A binary function.
   * @return An iterator positioned immediately after the last element of the output range.
   */
  public static OutputIterator adjacentDifference( Container source, Container destination, BinaryFunction function )
    {
    return adjacentDifference
      (
      source.start(),
      source.finish(),
      new com.objectspace.jgl.util.InsertIterator( destination ),
      function
      );
    }
  }
