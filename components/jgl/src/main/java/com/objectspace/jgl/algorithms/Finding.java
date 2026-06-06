// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The Finding class contains generic Finding algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.FindingExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Finding
  {
  private Finding()
    {
    }

  /**
   * Find the first element in a sequence that matches a particular object using equals().
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @param object The object to find.
   * @return An iterator positioned at the first element that matches. If no match is
   * found, return an iterator positioned immediately after the last element of
   * the sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static InputIterator find( InputIterator first, InputIterator last, Object object )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator)first.clone();

    while ( !firstx.equals( last ) && !( firstx.get().equals( object ) ) )
      firstx.advance();

    return firstx;
    }

  /**
   * Find the first element in a container that matches a particular object using equals().
   * The time complexity is linear and the space complexity is constant.
   * @param container The container.
   * @param object The object to find.
   * @return An iterator positioned at the first element that matches. If no match is
   * found, return an iterator positioned immediately after the last element of
   * the container.
   */
  public static InputIterator find( Container container, Object object )
    {
    return find( container.start(), container.finish(), object );
    }

  /**
   * Find the first element in a sequence that satisfies a predicate.
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @param predicate A unary predicate.
   * @return An iterator positioned at the first element that matches. If no match is
   * found, return an iterator positioned immediately after the last element of
   * the sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static InputIterator findIf( InputIterator first, InputIterator last, UnaryPredicate predicate )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator)first.clone();
    while ( !firstx.equals( last ) && !predicate.execute( firstx.get() ) )
      firstx.advance();

    return firstx;
    }

  /**
   * Find the first element in a container that satisfies a predicate.
   * The time complexity is linear and the space complexity is constant.
   * @param container The container.
   * @param predicate A unary predicate.
   * @return An iterator positioned at the first element that matches. If no match is
   * found, return an iterator positioned immediately after the last element of
   * the sequence.
   */
  public static InputIterator findIf( Container container, UnaryPredicate predicate )
    {
    return findIf( container.start(), container.finish(), predicate );
    }

  /**
   * Find the first consecutive sequence of elements that match using equals().
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @return An iterator positioned at the first element in the consecutive sequence. If
   * no consecutive sequence is found, return an iterator positioned immediately after
   * the last element of the input sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static InputIterator adjacentFind( InputIterator first, InputIterator last )
    {
    return adjacentFind( first, last, new Predicates.EqualTo() );
    }

  /**
   * Find the first consecutive sequence of elements that match using equals().
   * The time complexity is linear and the space complexity is constant.
   * @param container The container to search.
   * @return An iterator positioned at the first element in the consecutive sequence. If
   * no consecutive sequence is found, return an iterator positioned immediately after
   * the last element of the container.
   */
  public static InputIterator adjacentFind( Container container )
    {
    return adjacentFind( container.start(), container.finish() );
    }

  /**
   * Find the first consecutive sequence of elements that match using a predicate.
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @param predicate A binary predicate.
   * @return An iterator positioned at the first element in the consecutive sequence. If
   * no consecutive sequence is found, return an iterator positioned immediately after
   * the last element of the input sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static InputIterator adjacentFind( InputIterator first, InputIterator last, BinaryPredicate predicate )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator)first.clone();
    if ( firstx.equals( last ) )
      return last;

    InputIterator next = (InputIterator)first.clone();
    next.advance();

    while ( !next.equals( last ) )
      {
      if ( predicate.execute( firstx.get(), next.get() ) )
        return firstx;

      firstx.advance();
      next.advance();
      }

    return next;
    }

  /**
   * Find the first consecutive sequence of elements that match using a predicate.
   * The time complexity is linear and the space complexity is constant.
   * @param container The container to search.
   * @param predicate A binary predicate.
   * @return An iterator positioned at the first element in the consecutive sequence. If
   * no consecutive sequence is found, return an iterator positioned immediately after
   * the last element of the container.
   */
  public static InputIterator adjacentFind( Container container, BinaryPredicate predicate )
    {
    return adjacentFind( container.start(), container.finish(), predicate );
    }

  /**
   * Return the first object in a range that satisfies a specified predicate, or null
   * if no such object exists.
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element in the range.
   * @param last An iterator positioned immediately after the last element in the range.
   * @param predicate A unary predicate.
   * @return The first object that causes the predicate to return true.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static Object detect( InputIterator first, InputIterator last, UnaryPredicate predicate )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator)first.clone();
    while ( !firstx.equals( last ) )
      {
      Object object = firstx.nextElement();

      if ( predicate.execute( object ) )
        return object;
      }

    return null;
    }

  /**
   * Return the first object in a container that satisfies a specified predicate, or null
   * if no such object exists.
   * The time complexity is linear and the space complexity is constant.
   * @param container The container to search.
   * @param predicate A unary predicate.
   * @return The first object that causes the predicate to return true.
   * @exception IllegalArgumentException If the iterator containers are different.
   */
  public static Object detect( Container container, UnaryPredicate predicate )
    {
    return detect( container.start(), container.finish(), predicate );
    }

  /**
   * Return true if at least one object in the given range satisfies the specified
   * unary predicate. The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element in the range.
   * @param last An iterator positioned immediately after the last element in the range.
   * @param predicate A unary predicate.
   * @return true if at least one object satisfies the predicate.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static boolean some( InputIterator first, InputIterator last, UnaryPredicate predicate )
    {
    return detect( first, last, predicate ) != null;
    }

  /**
   * Return true if at least one object in the container satisfies the specified
   * unary predicate. The time complexity is linear and the space complexity is constant.
   * @param container A container to search
   * @param predicate A unary predicate.
   * @return true if at least one object satisfies the predicate.
   */
  public static boolean some( Container container, UnaryPredicate predicate )
    {
    return some( container.start(), container.finish(), predicate );
    }

  /**
   * Return true if every object in the specified range satisfies a particular predicate.
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element in the range.
   * @param last An iterator positioned immediately after the last element in the range.
   * @param predicate A unary predicate.
   * @return true if all objects satisfy the predicate.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static boolean every( InputIterator first, InputIterator last, UnaryPredicate predicate )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator)first.clone();
    while ( !firstx.equals( last ) )
      {
      if ( !predicate.execute( firstx.nextElement() ) )
        return false;
      }

    return true;
    }

  /**
   * Return true if every object in the container satisfies a particular predicate.
   * The time complexity is linear and the space complexity is constant.
   * @param container A container to search
   * @param predicate A unary predicate.
   * @return true if all objects satisfy the predicate.
   */
  public static boolean every( Container container, UnaryPredicate predicate )
    {
    return every( container.start(), container.finish(), predicate );
    }
  }
