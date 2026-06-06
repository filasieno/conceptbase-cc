// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The MinMax class contains generic min/max algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.MinMaxExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class MinMax
  {
  private MinMax()
    {
    }

  /**
   * Find the maximum element in a sequence. Compare objects based on the hash code.
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element in the sequence.
   * @param last An iterator positioned immediately after the last element in the sequence.
   * @return An iterator positioned at the maximum element in the sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static InputIterator maxElement( InputIterator first, InputIterator last )
    {
    return maxElement( first, last, new Predicates.HashComparator() );
    }

  /**
   * Find the maximum element in a container. Compare objects based on the hash code.
   * The time complexity is linear and the space complexity is constant.
   * @param container The container.
   * @param last An iterator positioned immediately after the last element in the sequence.
   * @return An iterator positioned at the maximum element in the container.
   */
  public static InputIterator maxElement( Container container )
    {
    return maxElement( container.start(), container.finish(), new Predicates.HashComparator() );
    }

  /**
   * Find the maximum element in a sequence. Use a comparator to perform the comparison.
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element in the sequence.
   * @param last An iterator positioned immediately after the last element in the sequence.
   * @param comparator A binary predicate that returns true if the first operand is "less" than the second operand.
   * @return An iterator positioned at the maximum element in the sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static InputIterator maxElement( InputIterator first, InputIterator last, BinaryPredicate comparator )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator)first.clone();

    if ( firstx.equals( last ) )
      return firstx;

    InputIterator result = (InputIterator)firstx.clone();
    firstx.advance();

    while ( !firstx.equals( last ) )
      {
      if ( comparator.execute( result.get(), firstx.get() ) )
        result = (InputIterator)firstx.clone();
      firstx.advance();
      }

    return result;
  }

  /**
   * Find the maximum element in a container. Use a comparator to perform the comparison.
   * The time complexity is linear and the space complexity is constant.
   * @param container The container.
   * @param comparator A binary predicate that returns true if the first operand is "less" than the second operand.
   * @return An iterator positioned at the maximum element in the container.
   */
  public static InputIterator maxElement( Container container, BinaryPredicate comparator )
    {
    return maxElement( container.start(), container.finish(), comparator );
    }

  /**
   * Find the minimum element in a sequence. Compare objects based on the hash code.
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element in the sequence.
   * @param last An iterator positioned immediately after the last element in the sequence.
   * @return An iterator positioned at the minimum element in the sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static InputIterator minElement( InputIterator first, InputIterator last )
    {
    return minElement( first, last, new Predicates.HashComparator() );
    }

  /**
   * Find the minimum element in a container. Compare objects based on the hash code.
   * The time complexity is linear and the space complexity is constant.
   * @param container The container.
   * @return An iterator positioned at the minimum element in the container.
   */
  public static InputIterator minElement( Container container )
    {
    return minElement( container.start(), container.finish(), new Predicates.HashComparator() );
    }

  /**
   * Find the minimum element in a sequence. Use a comparator to perform the comparison.
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element in the sequence.
   * @param last An iterator positioned immediately after the last element in the sequence.
   * @param comparator A binary predicate that returns true if the first operand is "less" than the second operand.
   * @return An iterator positioned at the minimum element in the sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static InputIterator minElement( InputIterator first, InputIterator last, BinaryPredicate comparator )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator)first.clone();

    if ( firstx.equals( last ) )
      return firstx;

    InputIterator result = (InputIterator)firstx.clone();
    firstx.advance();

    while ( !firstx.equals( last ) )
      {
      if ( comparator.execute( firstx.get(), result.get() ) )
        result = (InputIterator)firstx.clone();
      firstx.advance();
      }

    return result;
    }

  /**
   * Find the minimum element in a container. Use a comparator to perform the comparison.
   * The time complexity is linear and the space complexity is constant.
   * @param container The container.
   * @param comparator A binary predicate that returns true if the first operand is "less" than the second operand.
   * @return An iterator positioned at the minimum element in the container.
   */
  public static InputIterator minElement( Container container, BinaryPredicate comparator )
    {
    return minElement( container.start(), container.finish(), comparator );
    }
  }
