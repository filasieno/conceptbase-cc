// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The Comparing class contains generic comparison algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.ComparingExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Comparing
  {
  private Comparing()
    {
    }

  /**
   * Return the median value of three objects, using a comparator to perform
   * the comparisons.
   * @param a The first object.
   * @param b The second object.
   * @param c The third object.
   * @param comparator The comparator object.
   * @return The median value.
   */
  public static Object median( Object a, Object b, Object c, BinaryPredicate comparator )
    {
    if ( comparator.execute( a, b ) )
      {
      if ( comparator.execute( b, c ) )
        {
        return b;
        }
      else if ( comparator.execute( a, c ) )
        {
        return c;
        }
      else
        {
        return a;
        }
      }
    else if ( comparator.execute( a, c ) )
      {
      return a;
      }
    else if ( comparator.execute( b, c ) )
      {
      return c;
      }
    else
      {
      return b;
      }
    }

  /**
   * Scan two sequences and return a pair of iterators that are positioned at the first
   * mismatched elements. Use equals() to perform the comparison. If the first iterator
   * reaches past the end of the first sequence, stop the scan and return the iterator's
   * values at that point. Time complexity is linear and space complexity is constant.
   * @param first1 An iterator positioned at the first element of the first sequence.
   * @param last1 An iterator positioned immediately after the last element of the first sequence.
   * @param first2 An iterator positioned at the first element of the second sequence.
   * @return A pair of iterators positioned at the first mismatched elements.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static Pair mismatch( InputIterator first1, InputIterator last1, InputIterator first2 )
    {
    if ( !first1.isCompatibleWith( last1 ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator first1x = (InputIterator)first1.clone();
    InputIterator first2x = (InputIterator)first2.clone();

    while ( (!first1x.equals( last1 )) && first1x.get().equals( first2x.get()) )
      {
      first1x.advance();
      first2x.advance();
      }

    return new Pair( first1x, first2x );
    }

  /**
   * Scan two containers and return a pair of iterators that are positioned at the first
   * mismatched elements. Use equals() to perform the comparison. If the first iterator
   * reaches past the end of the first container, stop the scan and return the iterator's
   * values at that point. Time complexity is linear and space complexity is constant.
   * @param container1 The first container.
   * @param container2 The second container.
   * @return A pair of iterators positioned at the first mismatched elements.
   */
  public static Pair mismatch( Container container1, Container container2 )
    {
    return mismatch( container1.start(), container1.finish(), container2.start() );
    }

  /**
   * Scan two sequences and return a pair of iterators that are positioned at the first
   * mismatched elements. Use the specified predicate to perform the comparison. If the first iterator
   * reaches past the end of the first sequence, stop the scan and return the iterator's
   * values at that point. Time complexity is linear and space complexity is constant.
   * @param first1 An iterator positioned at the first element of the first sequence.
   * @param last1 An iterator positioned immediately after the last element of the first sequence.
   * @param first2 An iterator positioned at the first element of the second sequence.
   * @param predicate A binary function.
   * @return A pair of iterators positioned at the first mismatched elements.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static Pair mismatch( InputIterator first1, InputIterator last1, InputIterator first2, BinaryPredicate predicate )
    {
    if ( !first1.isCompatibleWith( last1 ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator first1x = (InputIterator)first1.clone();
    InputIterator first2x = (InputIterator)first2.clone();

    while ( (!first1x.equals( last1 )) && predicate.execute( first1x.get(), first2x.get() ) )
      {
      first1x.advance();
      first2x.advance();
      }

    return new Pair( first1x, first2x );
    }

  /**
   * Scan two containers and return a pair of iterators that are positioned at the first
   * mismatched elements. Use the specified predicate to perform the comparison. If the first iterator
   * reaches past the end of the first container, stop the scan and return the iterator's
   * values at that point. Time complexity is linear and space complexity is constant.
   * @param container1 The first container.
   * @param container2 The second container.
   * @param predicate A binary predicate.
   * @return A pair of iterators positioned at the first mismatched elements.
   */
  public static Pair mismatch( Container container1, Container container2, BinaryPredicate predicate )
    {
    return mismatch( container1.start(), container1.finish(), container2.start(), predicate );
    }

  /**
   * Scan two sequences of the same size and return true if every element in one
   * sequence matches its counterpart using equals(). The time complexity is linear and
   * the space complexity is constant.
   * @param first1 An iterator positioned at the first element of the first sequence.
   * @param last1 An iterator positioned immediately after the last element of the first sequence.
   * @param first2 An iterator positioned at the first element of the second sequence.
   * @return true if the sequences match.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static boolean equal( InputIterator first1, InputIterator last1, InputIterator first2 )
    {
    if ( !first1.isCompatibleWith( last1 ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator first1x = (InputIterator)first1.clone();
    InputIterator first2x = (InputIterator)first2.clone();

    while ( !first1x.equals( last1 ) )
      {
      if ( !first1x.get().equals( first2x.get() ) )
        return false;

      first1x.advance();
      first2x.advance();
      }

    return true;
    }

  /**
   * Scan two containers and return true if the containers are the same size and every
   * element in one container matches its counterpart using equals(). The time complexity is
   * linear and the space complexity is constant.
   * @param container1 The first container.
   * @param container2 The second container.
   * @return true if the containers match.
   */
  public static boolean equal( Container container1, Container container2 )
    {
    return container1.size() == container2.size() && equal( container1.start(), container1.finish(), container2.start() );
    }

  /**
   * Return true if one sequence is lexicographically less than another.
   * Comapre hashCode() values to determine ordering. The time complexity is
   * linear and the space complexity is constant.
   * @param first1 An iterator positioned at the first element of the first sequence.
   * @param last1 An iterator positioned immediately after the last element of the first sequence.
   * @param first2 An iterator positioned at the first element of the second sequence.
   * @param last2 An iterator positioned immediately after the last element of the second sequence.
   * @return true if the first sequence is lexicographically less than the second.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static boolean lexicographicalCompare( InputIterator first1, InputIterator last1, InputIterator first2, InputIterator last2 )
    {
    return lexicographicalCompare( first1, last1, first2, last2, new Predicates.HashComparator() );
    }

  /**
   * Return true if one container is lexicographically less than another.
   * Comapre hashCode() values to determine ordering. The time complexity is
   * linear and the space complexity is constant.
   * @param container1 The first container.
   * @param container2 The second container.
   * @return true if the first container is lexicographically less than the second.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static boolean lexicographicalCompare( Container container1, Container container2 )
    {
    return lexicographicalCompare( container1.start(), container1.finish(), container2.start(), container2.finish() );
    }

  /**
   * Return true if one sequence is lexicographically less than another.
   * Use a specified comparator to compare corresponding elements. The time complexity is
   * linear and the space complexity is constant.
   * @param first1 An iterator positioned at the first element of the first sequence.
   * @param last1 An iterator positioned immediately after the last element of the first sequence.
   * @param first2 An iterator positioned at the first element of the second sequence.
   * @param last2 An iterator positioned immediately after the last element of the second sequence.
   * @param comparator A binary predicate that returns true if its first operand is "less" than its second operand.
   * @return true if the first sequence is lexicographically less than the second.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static boolean lexicographicalCompare( InputIterator first1, InputIterator last1, InputIterator first2, InputIterator last2, BinaryPredicate comparator )
    {
    if ( ! ( first1.isCompatibleWith( last1 ) && first2.isCompatibleWith( last2 ) ) )
      throw new IllegalArgumentException( "iterators not compatible" );


    InputIterator first1x = (InputIterator)first1.clone();
    InputIterator first2x = (InputIterator)first2.clone();

    while ( !first1x.equals( last1 ) && !first2x.equals( last2 ) )
      {
      if ( comparator.execute( first1x.get(), first2x.get() ) )
        return true;

      if ( comparator.execute( first2x.get(), first1x.get() ) )
        return false;

      first1x.advance();
      first2x.advance();
      }

    return first1x.equals( last1 ) && !first2x.equals( last2 );
    }

  /**
   * Return true if one container is lexicographically less than another.
   * Use a specified comparator to compare corresponding elements. The time complexity is
   * linear and the space complexity is constant.
   * @param container1 The first container.
   * @param container2 The second container.
   * @param comparator A binary predicate that returns true if its first operand is "less" than its second operand.
   * @return true if the first container is lexicographically less than the second.
   */
  public static boolean lexicographicalCompare( Container container1, Container container2, BinaryPredicate comparator )
    {
    return lexicographicalCompare( container1.start(), container1.finish(), container2.start(), container2.finish(), comparator );
    }
  }
