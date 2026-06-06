// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The Transforming class contains generic transforming algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.TransformingExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Transforming
  {
  private Transforming()
    {
    }

  /**
   * Traverse a sequence and store the results of invoking a UnaryFunction on each
   * element into another sequence of the same size. The time complexity is linear and
   * the space complexity is constant.
   * @param first An iterator positioned at the first element of the input sequence.
   * @param last An iterator positioned immediately after the last element of the input sequence.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param function A uanry function.
   * @return An iterator positioned immediately after the last element of the output sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static OutputIterator transform( InputIterator first, InputIterator last, OutputIterator result, UnaryFunction function )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator) first.clone();
    OutputIterator resultx = (OutputIterator) result.clone();

    while ( !firstx.equals( last ) )
      {
      resultx.put( function.execute( firstx.nextElement() ) );
      resultx.advance();
      }

    return resultx;
    }

  /**
   * Traverse a container and store the results of invoking a UnaryFunction on each
   * element into a sequence. The time complexity is linear and the space complexity is
   * constant.
   * @param input The input container.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param function A unary function.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator transform( Container input, OutputIterator result, UnaryFunction function )
    {
    return transform( input.start(), input.finish(), result, function );
    }

  /**
   * Traverse a container and add the results of invoking a UnaryFunction on each
   * element into another container. The time complexity is linear and the space complexity is
   * constant.
   * @param source The source container.
   * @param desination The destination container.
   * @param function A unary function.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static void transform( Container source, Container destination, UnaryFunction function )
    {
    transform( source.start(), source.finish(), new com.objectspace.jgl.util.InsertIterator( destination ), function );
    }

  /**
   * Traverse two sequences and store the results of invoking a BinaryFunction on
   * corresponding elements into another sequence of the same size. Stop when the
   * end of the first sequence is reached. The time complexity is linear and
   * the space complexity is constant.
   * @param first1 An iterator positioned at the first element of the first input sequence.
   * @param last1 An iterator positioned immediately after the last element of the first input sequence.
   * @param first2 An iterator positioned at the first element of the second input sequence.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param function A binary function.
   * @return An iterator positioned immediately after the last element of the output sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  static public OutputIterator transform( InputIterator first1, InputIterator last1, InputIterator first2, OutputIterator result, BinaryFunction function )
    {
    if ( !first1.isCompatibleWith( last1 ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator first1x = (InputIterator) first1.clone();
    InputIterator first2x = (InputIterator) first2.clone();
    OutputIterator resultx = (OutputIterator) result.clone();

    while ( !first1x.equals( last1 ) )
      {
      resultx.put( function.execute( first1x.nextElement(), first2x.nextElement() ) );
      resultx.advance();
      }

    return resultx;
    }

  /**
   * Traverse two containers and store the results of invoking a BinaryFunction on
   * corresponding elements into a sequence. Stop when the end of the first container is
   * reached. The time complexity is linear and the space complexity is constant.
   * @param input1 The first input container.
   * @param input2 The second input container.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param function A binary function.
   * @return An iterator positioned immediately after the last element of the output container.
   */
  static public OutputIterator transform( Container input1, Container input2, OutputIterator result, BinaryFunction function )
    {
    return transform( input1.start(), input1.finish(), input2.start(), result, function );
    }

  /**
   * Traverse two containers and add the results of invoking a BinaryFunction on
   * corresponding elements to another container. Stop when the end of the first
   * container is reached. The time complexity is linear and the space complexity
   * is constant.
   * @param input1 The first input container.
   * @param input2 The second input container.
   * @param output The output container.
   * @param function A binary function.
   * @return An iterator positioned immediately after the last element of the output container.
   */
  static public void transform( Container input1, Container input2, Container output, BinaryFunction function )
    {
    transform( input1.start(), input1.finish(), input2.start(), new com.objectspace.jgl.util.InsertIterator( output ), function );
    }

  /**
   * Return a container that is the same class as the original and contains
   * the result of applying the given unary function to each element in the range.
   * The original container is not modified.
   * @param first An iterator positioned at the first element in the range.
   * @param last An iterator positioned immediately after the last element in the range.
   * @param function A unary function.
   * @return A new container that contains the result of applying the unary function.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static Container collect( ForwardIterator first, ForwardIterator last, UnaryFunction function )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    return collect
      (
      first,
      last,
      function,
      (Container)first.getContainer().clone()
      );
    }

  /**
   * Return a container that is the same class as the original and contains
   * the result of applying the given unary function to each element in the original.
   * The original container is not modified.
   * @param container A container.
   * @param function A unary function.
   * @return A new container containing the result of applying the unary function.
   */
  public static Container collect( Container container, UnaryFunction function )
    {
    return collect
      (
      container.start(),
      container.finish(),
      function,
      (Container)container.clone()
      );
    }

  private static Container collect( ForwardIterator first, ForwardIterator last, UnaryFunction function, Container container )
    {
    // make sure it is empty
    container.clear();

    // add in modified elements
    // didn't use transform() here because function may affect ordering
    // in ordered containers
    ForwardIterator firstx = (ForwardIterator) first.clone();
    while ( !firstx.equals( last ) )
      container.add( function.execute( firstx.nextElement() ) );

    return container;
    }
  }
