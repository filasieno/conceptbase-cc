// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The Heap class contains generic heap algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.HeapExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Heap
  {
  private Heap()
    {
    }

  /**
   * Assuming that a sequence is already organized as a heap, insert the element that
   * is immediately after the sequence into the heap. The elements are organized
   * according to their hash code. The time complexity is O(log N), where N is the size of
   * the heap. Space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static void pushHeap( BidirectionalIterator first, BidirectionalIterator last )
    {
    pushHeap( first, last, new Predicates.HashComparator() );
    }

  /**
   * Assuming that a sequence is already organized as a heap, insert the element that
   * is immediately after the sequence into the heap. The elements are organized
   * according to a specified comparator. The time complexity is O(log N), where N is
   * the size of the heap. Space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @param comparator A binary predicate that returns true if its first operand is "less" than its second operand.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static void pushHeap( BidirectionalIterator first, BidirectionalIterator last, BinaryPredicate comparator )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    pushHeap( first, first.distance( last ) - 1, 0, last.get( -1 ), comparator );
    }

  static void pushHeap( BidirectionalIterator first, int holeIndex, int topIndex, Object value, BinaryPredicate comparator )
    {
    int parent = ( holeIndex - 1 ) / 2;

    BidirectionalIterator firstx = (BidirectionalIterator)first.clone();
    while ( holeIndex > topIndex && comparator.execute( firstx.get( parent ), value ) )
      {
      firstx.put( holeIndex, firstx.get( parent ) );
      holeIndex = parent;
      parent = ( holeIndex - 1 ) / 2;
      }

    firstx.put( holeIndex, value );
    }

  /**
   * Assuming that a sequence is organized as a heap, swap its first and last elements
   * and then reorganize every element except for the last element to be a heap. The
   * elements are organized according to their hash code.
   * Time complexity is 2*log(last-first) and space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static void popHeap( BidirectionalIterator first, BidirectionalIterator last )
    {
    popHeap( first, last, new Predicates.HashComparator() );
    }

  /**
   * Assuming that a sequence is organized as a heap, swap its first and last elements
   * and then reorganize every element except for the last element to be a heap. The
   * elements are organized according to a specified comparator.
   * Time complexity is 2*log(last-first) and space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @param comparator A binary predicate that returns true if its first operand is "less" than its second operand.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static void popHeap( BidirectionalIterator first, BidirectionalIterator last, BinaryPredicate comparator )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    Object old = last.get( -1 );
    last.put( -1, first.get() );
    adjustHeap( first, 0, first.distance( last ) - 1, old, comparator );
    }

  /**
   * Arrange a sequence into a heap that is ordered according to the object's hash codes.
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static void makeHeap( BidirectionalIterator first, BidirectionalIterator last )
    {
    makeHeap( first, last, new Predicates.HashComparator() );
    }

  /**
   * Arrange a sequence into a heap that is ordered according to a comparator.
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @param comparator A binary predicate that returns true if its first operand is "less" than its second operand.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static void makeHeap( BidirectionalIterator first, BidirectionalIterator last, BinaryPredicate comparator )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    int len = first.distance( last );

    if ( len < 2)
      return;

    int parent = ( len - 2 ) / 2;

    while ( true )
      {
      adjustHeap( first, parent, len, first.get( parent ), comparator );

      if ( parent == 0 )
        return;

      parent--;
      }
    }

  /**
   * Sort a heap according to the object's hash codes.
   * Time complexity is N*log(N) and the space complexity is constant.
   * @param first An iterator positioned at the first element of the heap.
   * @param last An iterator positioned immediately after the last element of the heap.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static void sortHeap( BidirectionalIterator first, BidirectionalIterator last )
    {
    sortHeap( first, last, new Predicates.HashComparator() );
    }

  /**
   * Sort a heap according to a comparator.
   * Time complexity is N*log(N) and the space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @param comparator A binary predicate that returns true if its first operand is "less" than its second operand.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static void sortHeap( BidirectionalIterator first, BidirectionalIterator last, BinaryPredicate comparator )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    BidirectionalIterator lastx = (BidirectionalIterator)last.clone();
    while ( first.distance( lastx ) > 1 )
      {
      popHeap( first, lastx, comparator );
      lastx.retreat();
      }
    }

  static void adjustHeap( BidirectionalIterator first, int holeIndex, int len, Object value, BinaryPredicate comparator )
    {
    int topIndex = holeIndex;
    int secondChild = 2 * ( holeIndex + 1 );

    while ( secondChild < len )
      {
      if ( comparator.execute( first.get( secondChild ), first.get( secondChild - 1 ) ) )
        --secondChild;

      first.put( holeIndex, first.get( secondChild ) );
      holeIndex = secondChild;
      secondChild = 2 * ( secondChild + 1 );
      }

    if ( secondChild == len )
      {
      first.put( holeIndex, first.get( secondChild - 1 ) );
      holeIndex = secondChild - 1;
      }

    pushHeap( first, holeIndex, topIndex, value, comparator );
    }
  }
