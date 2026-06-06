// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The Replacing class contains generic replacing algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.ReplacingExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Replacing
  {
  private Replacing()
    {
    }

  /**
   * Traverse a sequence and replace every occurrence of a particular object with another.
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @param oldValue The object to be replaced.
   * @param newValue The replacement object.
   * @return The number of objects that were replaced.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static int replace( ForwardIterator first, ForwardIterator last, Object oldValue, Object newValue )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    ForwardIterator firstx = (ForwardIterator)first.clone();
    int n = 0;

    while ( !firstx.equals( last ) )
      {
      if ( firstx.get().equals( oldValue ) )
        {
        firstx.put( newValue );
        ++n;
        }

      firstx.advance();
      }

    return n;
    }

  /**
   * Traverse a container and replace every occurrence of a particular object with another.
   * The time complexity is linear and the space complexity is constant.
   * @param container The container.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @param oldValue The object to be replaced.
   * @param newValue The replacement object.
   * @return The number of objects that were replaced.
   */
  public static int replace( Container container, Object oldValue, Object newValue )
    {
    return replace( container.start(), container.finish(), oldValue, newValue );
    }

  /**
   * Traverse a sequence and replace every object that satisfies a predicate with another.
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @param predicate A unary predicate.
   * @param newValue The replacement object.
   * @return The number of objects that were replaced.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static int replaceIf( ForwardIterator first, ForwardIterator last, UnaryPredicate predicate, Object newValue )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    ForwardIterator firstx = (ForwardIterator)first.clone();
    int n = 0;

    while ( !firstx.equals( last ) )
      {
      if ( predicate.execute( firstx.get() ) )
        {
        firstx.put( newValue );
        ++n;
        }

      firstx.advance();
      }

    return n;
    }

  /**
   * Traverse a container and replace every object that satisfies a predicate with another.
   * The time complexity is linear and the space complexity is constant.
   * @param container The container.
   * @param predicate A unary predicate.
   * @param newValue The replacement object.
   * @return The number of objects that were replaced.
   */
  public static int replaceIf( Container container, UnaryPredicate predicate, Object newValue )
    {
    return replaceIf( container.start(), container.finish(), predicate, newValue );
    }

  /**
   * Copy one sequence to another of the same size, replacing all occurrences of a
   * particular object with another. The time complexity is linear and the space
   * complexity is constant.
   * @param first An iterator positioned at the first element of the input sequence.
   * @param last An iterator positioned immediately after the last element of the input sequence.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param oldValue The object to be replaced.
   * @param newValue The replacement object.
   * @return An iterator positioned immediately after the last element of the output sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static OutputIterator replaceCopy( InputIterator first, InputIterator last, OutputIterator result, Object oldValue, Object newValue )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator)first.clone();
    OutputIterator resultx = (OutputIterator)result.clone();

    while ( !firstx.equals( last ) )
      {
      resultx.put( firstx.get().equals( oldValue ) ? newValue : firstx.get() );
      resultx.advance();
      firstx.advance();
      }

    return resultx;
    }

  /**
   * Copy a container to a sequence, replacing all occurrences of a particular object
   * with another. The time complexity is linear and the space complexity is constant.
   * @param input The input container.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param oldValue The object to be replaced.
   * @param newValue The replacement object.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator replaceCopy( Container input, OutputIterator result, Object oldValue, Object newValue )
    {
    return replaceCopy( input.start(), input.finish(), result, oldValue, newValue );
    }

  /**
   * Copy a container to another container, replacing all occurrences of a particular object
   * with another. The time complexity is linear and the space complexity is constant.
   * @param source The source container.
   * @param destination The destination container.
   * @param oldValue The object to be replaced.
   * @param newValue The replacement object.
   */
  public static void replaceCopy( Container source, Container destination, Object oldValue, Object newValue )
    {
    replaceCopy( source.start(), source.finish(), new com.objectspace.jgl.util.InsertIterator( destination ), oldValue, newValue );
    }

  /**
   * Copy one sequence to another of the same size, replacing all objects that satisfy
   * a predicate with another. The time complexity is linear and the space complexity
   * is constant.
   * @param first An iterator positioned at the first element of the input sequence.
   * @param last An iterator positioned immediately after the last element of the input sequence.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param predicate A unary predicate.
   * @param newValue The replacement object.
   * @return An iterator positioned immediately after the last element of the output sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static OutputIterator replaceCopyIf( InputIterator first, InputIterator last, OutputIterator result, UnaryPredicate predicate, Object newValue )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator) first.clone();
    OutputIterator resultx = (OutputIterator) result.clone();

    while ( !firstx.equals( last ) )
      {
      resultx.put( predicate.execute( firstx.get() ) ? newValue : firstx.get() );
      resultx.advance();
      firstx.advance();
      }

    return resultx;
    }

  /**
   * Copy a container to a sequence, replacing all objects that satisfy a predicate
   * with another. The time complexity is linear and the space complexity is constant.
   * @param input The input container.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param predicate A unary predicate.
   * @param newValue The replacement object.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator replaceCopyIf( Container input, OutputIterator result, UnaryPredicate predicate, Object newValue )
    {
    return replaceCopyIf( input.start(), input.finish(), result, predicate, newValue );
    }

  /**
   * Copy a container to another container, replacing all objects that satisfy a predicate
   * with another. The time complexity is linear and the space complexity is constant.
   * @param source The source container.
   * @param destination The destination container.
   * @param predicate A unary predicate.
   * @param newValue The replacement object.
   */
  public static void replaceCopyIf( Container source, Container destination, UnaryPredicate predicate, Object newValue )
    {
    replaceCopyIf( source.start(), source.finish(), new com.objectspace.jgl.util.InsertIterator( destination ), predicate, newValue );
    }
  }
