// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The OrderedSetOperations class contains generic set operation algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.OrderedSetOperationsExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class OrderedSetOperations
  {
  private OrderedSetOperations()
    {
    }

  /**
   * Return true if every element in the first sequence is also in the second.
   * It assumed that both sequences were sorted prior to this operation according
   * to their hash code. The time complexity is linear and the space complexity
   * is constant.
   * @param first1 An iterator positioned at the first element of the first sequence.
   * @param last1 An iterator positioned immediately after the last element of the first sequence.
   * @param first2 An iterator positioned at the first element of the second sequence.
   * @param last2 An iterator positioned immediately after the last element of the second sequence.
   * @return True if every element in the first sequence is also in the second.
   */
  public static boolean includes( InputIterator first1, InputIterator last1, InputIterator first2, InputIterator last2 )
    {
    return includes( first1, last1, first2, last2, new Predicates.HashComparator() );
    }

  /**
   * Return true if every element in the second sequence is also in the first.
   * It assumed that both sequences were sorted prior to this operation according
   * to the specified comparator. The time complexity is linear and the space complexity
   * is constant.
   * @param first1 An iterator positioned at the first element of the first sequence.
   * @param last1 An iterator positioned immediately after the last element of the first sequence.
   * @param first2 An iterator positioned at the first element of the second sequence.
   * @param last2 An iterator positioned immediately after the last element of the second sequence.
   * @param comparator A BinaryPredicate that returns true if its first operand is "less" than its second operand.
   * @return True if every element in the second sequence is also in the first.
   */
  public static boolean includes( InputIterator first1, InputIterator last1, InputIterator first2, InputIterator last2, BinaryPredicate comparator )
    {
    InputIterator first1x = (InputIterator)first1.clone();
    InputIterator first2x = (InputIterator)first2.clone();

    while ( !first1x.equals( last1 ) && !first2x.equals( last2 ) )
      if ( comparator.execute( first2x.get(), first1x.get() ) )
        {
        return false;
        }
      else if ( comparator.execute( first1x.get(), first2x.get() ) )
        {
        first1x.advance();
        }
      else
        {
        first1x.advance();
        first2x.advance();
        }

    return first2x.equals( last2 );
  }

  /**
   * Return true if every element in the second container is also in the first.
   * It assumed that both containers were sorted prior to this operation according
   * to the specified comparator. The time complexity is linear and the space complexity
   * is constant.
   * @param container1 The first container.
   * @param container2 The second container.
   * @param comparator A BinaryPredicate that returns true if its first operand is "less" than its second operand.
   * @return True if every element in the second container is also in the first.
   */
  public static boolean includes( Container container1, Container container2, BinaryPredicate comparator )
    {
    return includes( container1.start(), container1.finish(), container2.start(), container2.finish(), comparator );
    }

  /**
   * Place the sorted union of two sequences into another sequence.
   * It assumed that both sequences were sorted prior to this operation according
   * to their hash code. The result is undefined if the two input sequences overlap.
   * If an element occurs in both sequences, the element from the first sequence is
   * copied into the result sequence. The time complexity is linear and the space
   * complexity is constant.
   * @param first1 An iterator positioned at the first element of the first input sequence.
   * @param last1 An iterator positioned immediately after the last element of the first input sequence.
   * @param first2 An iterator positioned at the first element of the second input sequence.
   * @param last2 An iterator positioned immediately after the last element of the second input sequence.
   * @param result An iterator positioned at the first element of the output sequence.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator setUnion( InputIterator first1, InputIterator last1, InputIterator first2, InputIterator last2, OutputIterator result )
    {
    return setUnion( first1, last1, first2, last2, result, new Predicates.HashComparator() );
    }

  /**
   * Place the sorted union of two sequences into another sequence.
   * It assumed that both sequences were sorted prior to this operation according
   * to the specified comparator. The result is undefined if the two input sequences
   * overlap. If an element occurs in both sequences, the element from the first sequence
   * is copied into the result sequence. The time complexity is linear and the space
   * complexity is constant.
   * @param first1 An iterator positioned at the first element of the first input sequence.
   * @param last1 An iterator positioned immediately after the last element of the first input sequence.
   * @param first2 An iterator positioned at the first element of the second input sequence.
   * @param last2 An iterator positioned immediately after the last element of the second input sequence.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param comparator A BinaryPredicate that returns true if its first operand is "less" than its second operand.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator setUnion( InputIterator first1, InputIterator last1, InputIterator first2, InputIterator last2, OutputIterator result, BinaryPredicate comparator )
    {
    InputIterator first1x = (InputIterator)first1.clone();
    InputIterator first2x = (InputIterator)first2.clone();
    OutputIterator resultx = (OutputIterator)result.clone();

    while ( !first1x.equals( last1 ) && !first2x.equals( last2 ) )
      if ( comparator.execute( first1x.get(), first2x.get() ) )
        {
        resultx.put( first1x.get() );
        resultx.advance();
        first1x.advance();
        }
      else if ( comparator.execute( first2x.get(), first1x.get() ) )
        {
        resultx.put( first2x.get() );
        resultx.advance();
        first2x.advance();
        }
      else
        {
        resultx.put( first1x.get() );
        resultx.advance();
        first1x.advance();
        first2x.advance();
        }

      return Copying.copy( first2x, last2, Copying.copy( first1x, last1, resultx ) );
    }

  /**
   * Place the sorted union of two containers into a sequence.
   * It assumed that both containers were sorted prior to this operation according
   * to the specified comparator. If an element occurs in both containers, the element
   * from the first container is copied into the result sequence. The time complexity is
   * linear and the space complexity is constant.
   * @param container1 The first container.
   * @param container2 The second container.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param comparator A BinaryPredicate that returns true if its first operand is "less" than its second operand.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator setUnion( Container container1, Container container2, OutputIterator result, BinaryPredicate comparator )
    {
    return setUnion( container1.start(), container1.finish(), container2.start(), container2.finish(), result, comparator );
    }

  /**
   * Place the sorted intersection of two sequences into another sequence.
   * It assumed that both sequences were sorted prior to this operation according
   * to their hash code. The result is undefined if the two input sequences overlap.
   * If an element occurs in both sequences, the element from the first sequence is
   * copied into the result sequence. The time complexity is linear and the space
   * complexity is constant.
   * @param first1 An iterator positioned at the first element of the first input sequence.
   * @param last1 An iterator positioned immediately after the last element of the first input sequence.
   * @param first2 An iterator positioned at the first element of the second input sequence.
   * @param last2 An iterator positioned immediately after the last element of the second input sequence.
   * @param result An iterator positioned at the first element of the output sequence.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator setIntersection( InputIterator first1, InputIterator last1, InputIterator first2, InputIterator last2, OutputIterator result )
    {
    return setIntersection( first1, last1, first2, last2, result, new Predicates.HashComparator() );
    }

  /**
   * Place the sorted intersection of two sequences into another sequence.
   * It assumed that both sequences were sorted prior to this operation according
   * to the specified comparator. The result is undefined if the two input sequences
   * overlap. If an element occurs in both sequences, the element from the first sequence
   * is copied into the result sequence. The time complexity is linear and the space
   * complexity is constant.
   * @param first1 An iterator positioned at the first element of the first input sequence.
   * @param last1 An iterator positioned immediately after the last element of the first input sequence.
   * @param first2 An iterator positioned at the first element of the second input sequence.
   * @param last2 An iterator positioned immediately after the last element of the second input sequence.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param comparator A BinaryPredicate that returns true if its first operand is "less" than its second operand.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator setIntersection( InputIterator first1, InputIterator last1, InputIterator first2, InputIterator last2, OutputIterator result, BinaryPredicate comparator )
    {
    InputIterator first1x = (InputIterator)first1.clone();
    InputIterator first2x = (InputIterator)first2.clone();
    OutputIterator resultx = (OutputIterator)result.clone();

    while ( !first1x.equals( last1 ) && !first2x.equals( last2 ) )
      if ( comparator.execute( first1x.get(), first2x.get() ) )
        {
        first1x.advance();
        }
      else if ( comparator.execute( first2x.get(), first1x.get() ) )
        {
        first2x.advance();
        }
      else
        {
        resultx.put( first1x.get() );
        resultx.advance();
        first1x.advance();
        first2x.advance();
        }

      return resultx;
    }

  /**
   * Place the sorted intersection of two containers into a sequence.
   * It assumed that both containers were sorted prior to this operation according
   * to the specified comparator. If an element occurs in both containers, the element
   * from the first container is copied into the result sequence. The time complexity is
   * linear and the space complexity is constant.
   * @param container1 The first container.
   * @param container2 The second container.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param comparator A BinaryPredicate that returns true if its first operand is "less" than its second operand.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator setIntersection( Container container1, Container container2, OutputIterator result, BinaryPredicate comparator )
    {
    return setIntersection( container1.start(), container1.finish(), container2.start(), container2.finish(), result, comparator );
    }

  /**
   * Place the sorted difference of two sequences into another sequence.
   * The output sequence will contain all elements that are in the first sequence
   * but not in the second sequence.
   * It assumed that both sequences were sorted prior to this operation according
   * to their hash code. The result is undefined if the two input sequences overlap.
   * If an element occurs in both sequences, the element from the first sequence is
   * copied into the result sequence. The time complexity is linear and the space
   * complexity is constant.
   * @param first1 An iterator positioned at the first element of the first input sequence.
   * @param last1 An iterator positioned immediately after the last element of the first input sequence.
   * @param first2 An iterator positioned at the first element of the second input sequence.
   * @param last2 An iterator positioned immediately after the last element of the second input sequence.
   * @param result An iterator positioned at the first element of the output sequence.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator setDifference( InputIterator first1, InputIterator last1, InputIterator first2, InputIterator last2, OutputIterator result )
    {
    return setDifference( first1, last1, first2, last2, result, new Predicates.HashComparator() );
    }

  /**
   * Place the sorted difference of two sequences into another sequence.
   * The output sequence will contain all elements that are in the first sequence
   * but not in the second sequence.
   * It assumed that both sequences were sorted prior to this operation according
   * to the specified comparator. The result is undefined if the two input sequences
   * overlap. If an element occurs in both sequences, the element from the first sequence
   * is copied into the result sequence. The time complexity is linear and the space
   * complexity is constant.
   * @param first1 An iterator positioned at the first element of the first input sequence.
   * @param last1 An iterator positioned immediately after the last element of the first input sequence.
   * @param first2 An iterator positioned at the first element of the second input sequence.
   * @param last2 An iterator positioned immediately after the last element of the second input sequence.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param comparator A BinaryPredicate that returns true if its first operand is "less" than its second operand.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator setDifference( InputIterator first1, InputIterator last1, InputIterator first2, InputIterator last2, OutputIterator result, BinaryPredicate comparator )
    {
    InputIterator first1x = (InputIterator)first1.clone();
    InputIterator first2x = (InputIterator)first2.clone();
    OutputIterator resultx = (OutputIterator)result.clone();

    while ( !first1x.equals( last1 ) && !first2x.equals( last2 ) )
      if ( comparator.execute( first1x.get(), first2x.get() ) )
        {
        resultx.put( first1x.get() );
        resultx.advance();
        first1x.advance();
        }
      else if ( comparator.execute( first2x.get(), first1x.get() ) )
        {
        first2x.advance();
        }
      else
        {
        first1x.advance();
        first2x.advance();
        }

      return Copying.copy( first1x, last1, resultx );
    }

  /**
   * Place the sorted difference of two containers into a sequence.
   * The output sequence will contain all elements that are in the first container
   * but not in the second container.
   * It assumed that both containers were sorted prior to this operation according
   * to the specified comparator. If an element occurs in both containers, the element
   * from the first container is copied into the result sequence. The time complexity is
   * linear and the space complexity is constant.
   * @param container1 The first container.
   * @param container2 The second container.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param comparator A BinaryPredicate that returns true if its first operand is "less" than its second operand.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator setDifference( Container container1, Container container2, OutputIterator result, BinaryPredicate comparator )
    {
    return setDifference( container1.start(), container1.finish(), container2.start(), container2.finish(), result, comparator );
    }

  /**
   * Place the sorted symmetric difference of two sequences into another sequence.
   * The output sequence will contain all elements that are in one sequence
   * but not in the other.
   * It assumed that both sequences were sorted prior to this operation according
   * to their hash code. The result is undefined if the two input sequences overlap.
   * If an element occurs in both sequences, the element from the first sequence is
   * copied into the result sequence. The time complexity is linear and the space
   * complexity is constant.
   * @param first1 An iterator positioned at the first element of the first input sequence.
   * @param last1 An iterator positioned immediately after the last element of the first input sequence.
   * @param first2 An iterator positioned at the first element of the second input sequence.
   * @param last2 An iterator positioned immediately after the last element of the second input sequence.
   * @param result An iterator positioned at the first element of the output sequence.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator setSymmetricDifference( InputIterator first1, InputIterator last1, InputIterator first2, InputIterator last2, OutputIterator result )
    {
    return setSymmetricDifference( first1, last1, first2, last2, result, new Predicates.HashComparator() );
    }

  /**
   * Place the sorted symmetric difference of two sequences into another sequence.
   * The output sequence will contain all elements that are in one sequence
   * but not in the other.
   * It assumed that both sequences were sorted prior to this operation according
   * to the specified comparator. The result is undefined if the two input sequences
   * overlap. If an element occurs in both sequences, the element from the first sequence
   * is copied into the result sequence. The time complexity is linear and the space
   * complexity is constant.
   * @param first1 An iterator positioned at the first element of the first input sequence.
   * @param last1 An iterator positioned immediately after the last element of the first input sequence.
   * @param first2 An iterator positioned at the first element of the second input sequence.
   * @param last2 An iterator positioned immediately after the last element of the second input sequence.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param comparator A BinaryPredicate that returns true if its first operand is "less" than its second operand.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator setSymmetricDifference( InputIterator first1, InputIterator last1, InputIterator first2, InputIterator last2, OutputIterator result, BinaryPredicate comparator )
    {
    InputIterator first1x = (InputIterator)first1.clone();
    InputIterator first2x = (InputIterator)first2.clone();
    OutputIterator resultx = (OutputIterator)result.clone();

    while ( !first1x.equals( last1 ) && !first2x.equals( last2 ) )
      if ( comparator.execute( first1x.get(), first2x.get() ) )
        {
        resultx.put( first1x.get() );
        resultx.advance();
        first1x.advance();
        }
      else if ( comparator.execute( first2x.get(), first1x.get() ) )
        {
        resultx.put( first2x.get() );
        resultx.advance();
        first2x.advance();
        }
      else
        {
        first1x.advance();
        first2x.advance();
        }

      return Copying.copy( first2x, last2, Copying.copy( first1x, last1, resultx ) );
    }

  /**
   * Place the sorted symmetric difference of two containers into a sequence.
   * The output sequence will contain all elements that are in one container
   * but not in the other.
   * It assumed that both containers were sorted prior to this operation according
   * to the specified comparator. If an element occurs in both containers, the element
   * from the first container is copied into the result sequence. The time complexity is
   * linear and the space complexity is constant.
   * @param container1 The first container.
   * @param container2 The second container.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param comparator A BinaryPredicate that returns true if its first operand is "less" than its second operand.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator setSymmetricDifference( Container container1, Container container2, OutputIterator result, BinaryPredicate comparator )
    {
    return setSymmetricDifference( container1.start(), container1.finish(), container2.start(), container2.finish(), result, comparator );
    }
  }
