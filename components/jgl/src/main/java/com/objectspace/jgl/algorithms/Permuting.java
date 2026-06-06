// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The Permuting class contains generic permuting algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.PermutingExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Permuting
  {
  private Permuting()
    {
    }

  /**
   * Arrange a sequence to become its next permutation. If it was already the last
   * permutation, become the first permutation. Logically, the entire set of permutations
   * is lexicographically ordered using a comparator.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @param comparator A binary predicate that returns true if its first operand is "less" than its second operand.
   * @return true unless the sequence was already the last permutation.
   * @exception IllegalArgumentException If the iterators are incompatible
   *   or if the containers upon which the iteratore operate is not a com.objectspace.jgl.Sequence.
   */
  public static boolean nextPermutation( BidirectionalIterator first, BidirectionalIterator last, BinaryPredicate comparator )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );
    if ( !(first.getContainer() instanceof Sequence) )
      throw new IllegalArgumentException( "iterator containers must be a Sequence" );

    BidirectionalIterator i = (BidirectionalIterator)first.clone();
    if ( i.equals( last ) )
      return false;

    i.advance();

    if ( i.equals( last ) )
      return false;

    i = (BidirectionalIterator)last.clone();
    i.retreat();

    while ( true )
      {
      BidirectionalIterator ii = (BidirectionalIterator)i.clone();
      i.retreat();

      if ( comparator.execute( i.get(), ii.get() ) )
        {
        BidirectionalIterator j = (BidirectionalIterator)last.clone();
        j.retreat();

        while ( !comparator.execute( i.get(), j.get() ) )
          j.retreat();

        Swapping.iterSwap( i, j );
        Reversing.reverse( ii, last );
        return true;
        }

      if ( i.equals( first ) )
        {
        Reversing.reverse( first, last );
        return false;
        }
      }
    }

  /**
   * Arrange a container to become its next permutation. If the container is already the
   * last permutation, become the first permutation. Logically, the entire set of
   * permutations is lexicographically ordered using a comparator.
   * @param container The container.
   * @param comparator A binary predicate that returns true if its first operand is "less" than its second operand.
   * @return true unless the container was already the last permutation.
   */
  public static boolean nextPermutation( Container container, BinaryPredicate comparator )
    {
    return nextPermutation( (BidirectionalIterator)container.start(), (BidirectionalIterator)container.finish(), comparator );
    }

  /**
   * Arrange a sequence to become its previous permutation. If it was already the first
   * permutation, become the last permutation. Logically, the entire set of permutations
   * is lexicographically ordered using a comparator.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @param comparator A binary predicate that returns true if its first operand is "less" than its second operand.
   * @return true unless the sequence was already the first permutation.
   * @exception IllegalArgumentException If the iterators are incompatible
   *   or if the containers upon which the iteratore operate is not a com.objectspace.jgl.Sequence.
   */
  public static boolean prevPermutation( BidirectionalIterator first, BidirectionalIterator last, BinaryPredicate comparator )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );
    if ( !(first.getContainer() instanceof Sequence) )
      throw new IllegalArgumentException( "iterator containers must be a Sequence" );

    BidirectionalIterator i = (BidirectionalIterator)first.clone();
    if ( i.equals( last ) )
      return false;

    i.advance();

    if ( i.equals( last ) )
      return false;

    i = (BidirectionalIterator)last.clone();
    i.retreat();

    while ( true )
      {
      BidirectionalIterator ii = (BidirectionalIterator)i.clone();
      i.retreat();

      if ( comparator.execute( ii.get(), i.get() ) )
        {
        BidirectionalIterator j = (BidirectionalIterator)last.clone();
        j.retreat();

        while ( !comparator.execute( j.get(), i.get() ) )
          j.retreat();

        Swapping.iterSwap( i, j );
        Reversing.reverse( ii, last );
        return true;
        }

      if ( i.equals( first ) )
        {
        Reversing.reverse( first, last );
        return false;
        }
      }
    }

  /**
   * Arrange a container to become its previous permutation. If it was already the first
   * permutation, become the last permutation. Logically, the entire set of permutations
   * is lexicographically ordered using a comparator.
   * @param container The container.
   * @param comparator A binary predicate that returns true if its first operand is "less" than its second operand.
   * @return true unless the container was already the first permutation.
   */
  public static boolean prevPermutation( Container container, BinaryPredicate comparator )
    {
    return prevPermutation( (BidirectionalIterator)container.start(), (BidirectionalIterator)container.finish(), comparator );
    }
  }
