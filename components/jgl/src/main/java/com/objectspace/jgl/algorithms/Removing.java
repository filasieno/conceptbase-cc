// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The Removing class contains generic removing algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.RemovingExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Removing
  {
  private Removing()
    {
    }

  /**
   * Remove all occurrences of an object from a sequence. The size of the sequence
   * is not altered; if n elements are removed, the last n elements of the sequence
   * will have undefined values. The time complexity is linear and the space complexity
   * is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @param object The object to remove.
   * @return An iterator positioned immediately after the last remaining element.
   * @exception IllegalArgumentException If the iterators are incompatible
   *   or if the containers upon which the iteratore operate is not a com.objectspace.jgl.Sequence.
   */
  public static ForwardIterator remove( ForwardIterator first, ForwardIterator last, Object object )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    if ( !(first.getContainer() instanceof Sequence) )
      throw new IllegalArgumentException( "iterator containers must be a Sequence" );

    first = (ForwardIterator)Finding.find( first, last, object );

    ForwardIterator i = (ForwardIterator)first.clone();
    if ( i.equals( last ) )
      {
      return i;
      }
    else
      {
      i.advance();
      return (ForwardIterator)removeCopy( i, last, first, object );
      }
    }

  /**
   * Remove all occurrences of an object from a sequence. The size of the container
   * is not altered; if n elements are removed, the last n elements of the container
   * will have undefined values. The time complexity is linear and the space complexity
   * is constant.
   * @param container The container.
   * @param object The object to remove.
   * @return An iterator positioned immediately after the last remaining element.
   */
  public static ForwardIterator remove( Sequence container, Object object )
    {
    return remove( container.start(), container.finish(), object );
    }

  /**
   * Remove all objects in a sequence that satisfy a predicate from a sequence.
   * The size of the sequence is not altered; if n elements are removed, the last n
   * elements of the sequence will have undefined values. The time complexity is linear
   * and the space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @param predicate A unary predicate.
   * @return An iterator positioned immediately after the last remaining element.
   * @exception IllegalArgumentException If the iterators are incompatible
   *   or if the containers upon which the iteratore operate is not a com.objectspace.jgl.Sequence.
   */
  public static ForwardIterator removeIf( ForwardIterator first, ForwardIterator last, UnaryPredicate predicate )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    if ( !(first.getContainer() instanceof Sequence) )
      throw new IllegalArgumentException( "iterator containers must be a Sequence" );

    first = (ForwardIterator)Finding.findIf( first, last, predicate );

    if ( first.equals( last ) )
      {
      return first;
      }
    else
      {
      ForwardIterator i = (ForwardIterator)first.clone();
      i.advance();
      return (ForwardIterator)removeCopyIf( i, last, first, predicate );
      }
    }

  /**
   * Remove all objects in a sequence that satisfy a predicate from a container.
   * The size of the container is not altered; if n elements are removed, the last n
   * elements of the container will have undefined values. The time complexity is linear
   * and the space complexity is constant.
   * @param container The container.
   * @param predicate A unary predicate.
   * @return An iterator positioned immediately after the last remaining element.
   */
  public static ForwardIterator removeIf( Sequence container, UnaryPredicate predicate )
    {
    return removeIf( container.start(), container.finish(), predicate );
    }

  /**
   * Copy one sequence to another sequence, skipping any occurrences of a particular
   * object. The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element of the input sequence.
   * @param last An iterator positioned immediately after the last element of the input sequence.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param object The object to remove.
   * @return An iterator positioned immediately after the last element of the output sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static OutputIterator removeCopy( InputIterator first, InputIterator last, OutputIterator result, Object object )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator)first.clone();
    OutputIterator resultx = (OutputIterator)result.clone();

    while ( !firstx.equals( last ) )
      {
      if ( !firstx.get().equals( object ) )
        {
        resultx.put( firstx.get() );
        resultx.advance();
        }

      firstx.advance();
      }

    return resultx;
    }

  /**
   * Copy a container to a sequence, skipping any occurrences of a particular
   * object. The time complexity is linear and the space complexity is constant.
   * @param container The source container.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param object The object to remove.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator removeCopy( Container container, OutputIterator result, Object object )
    {
    return removeCopy( container.start(), container.finish(), result, object );
    }

  /**
   * Copy one container to another container, skipping any occurrences of a particular
   * object. The time complexity is linear and the space complexity is constant.
   * @param source The source container.
   * @param destination The destination container.
   * @param object The object to remove.
   */
  public static void removeCopy( Container source, Container destination, Object object )
    {
    removeCopy( source.start(), source.finish(), new com.objectspace.jgl.util.InsertIterator( destination ), object );
    }

  /**
   * Copy one sequence to another sequence, skipping all objects that satisfy a predicate.
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element of the input sequence.
   * @param last An iterator positioned immediately after the last element of the input sequence.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param predicate A UnaryPredicate.
   * @return An iterator positioned immediately after the last element of the output sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static OutputIterator removeCopyIf( InputIterator first, InputIterator last, OutputIterator result, UnaryPredicate predicate )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator)first.clone();
    OutputIterator resultx = (OutputIterator)result.clone();

    while ( !firstx.equals( last ) )
      {
      if ( !predicate.execute( firstx.get() ) )
        {
        resultx.put( firstx.get() );
        resultx.advance();
        }

      firstx.advance();
      }

    return resultx;
    }

  /**
   * Copy a container to a sequence, skipping all objects that satisfy a predicate.
   * The time complexity is linear and the space complexity is constant.
   * @param container The source container.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param predicate A UnaryPredicate.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator removeCopyIf( Container container, OutputIterator result, UnaryPredicate predicate )
    {
    return removeCopyIf( container.start(), container.finish(), result, predicate );
    }

  /**
   * Copy one container to another container, skipping all objects that satisfy a predicate.
   * The time complexity is linear and the space complexity is constant.
   * @param source The source container.
   * @param destination The destination container.
   * @param predicate A unary predicate.
   */
  public static void removeCopyIf( Container source, Container destination, UnaryPredicate predicate )
    {
    removeCopyIf( source.start(), source.finish(), new com.objectspace.jgl.util.InsertIterator( destination ), predicate );
    }
  }
