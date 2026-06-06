// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The Sorting class contains generic sorting algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.SortingExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Sorting
  {
  static final int stlThreshold = 16;
  Sequence base;
  BinaryPredicate comparator;

  private Sorting()
    {
    }

  /**
   * Sort the elements in a sequence according to their hash code. The object with the
   * smallest hash code is placed first. The time complexity is O(NlogN) and the space
   * complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @exception IllegalArgumentException If the iterators are incompatible
   *   or if the containers upon which the iteratore operate is not a com.objectspace.jgl.Sequence.
   */
  public static void sort( ForwardIterator first, ForwardIterator last )
    {
    sort( first, last, new Predicates.HashComparator() );
    }

  /**
   * Sort the elements in a sequence using a comparator. The time complexity is O(NlogN)
   * and the space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @param comparator A binary function that returns true if its first operand should be positioned before its second operand.
   * @exception IllegalArgumentException If the iterators are incompatible
   *   or if the containers upon which the iteratore operate is not a com.objectspace.jgl.Sequence.
   */
  public static void sort( ForwardIterator first, ForwardIterator last, BinaryPredicate comparator )
    {
    new Sorting( first, last, comparator );
    }

  /**
   * Sort the elements in a Sequence container according to their hash code. The
   * object with the smallest hash code is placed first. The time complexity is O(NlogN)
   * and the space complexity is constant.
   * @param container A Sequence container.
   */
  public static void sort( Sequence container )
    {
    sort( container.start(), container.finish(), new Predicates.HashComparator() );
    }

  /**
   * Sort the elements in a random access container using a comparator. The time
   * complexity is O(NlogN) and the space complexity is constant.
   * @param container A random access container.
   * @param comparator A BinaryFunction that returns true if its first operand should be positioned before its second operand.
   */
  public static void sort( Sequence container, BinaryPredicate comparator )
    {
    sort( container.start(), container.finish(), comparator );
    }

  private Sorting( ForwardIterator first, ForwardIterator last, BinaryPredicate comparit )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    if ( !( first.getContainer() instanceof Sequence ) )
      throw new IllegalArgumentException( "iterator containers must be a Sequence" );

    base = (Sequence) first.getContainer();
    comparator = comparit;

    // calculate first and last index into the sequence.
    int start = (base.start()).distance( first );
    int finish = (base.start()).distance( last );

    quickSortLoop( start, finish );
    finalInsertionSort( start, finish );
    }

  void finalInsertionSort( int first, int last )
    {
    if ( last - first > stlThreshold )
      {
      int limit = first + stlThreshold;

      for ( int i = first + 1; i < limit; i++ )
        linearInsert( first, i );

      for ( int i = limit; i < last; i++ )
        unguardedLinearInsert( i, base.at( i ) );
      }
    else
      {
      for ( int i = first + 1; i < last; i++ )
        linearInsert( first, i );
      }
    }

  void unguardedLinearInsert( int last, Object value )
    {
    int next = last - 1;

    while ( comparator.execute( value, base.at( next ) ) )
      base.put( last--, base.at( next-- ) );

    base.put( last, value );
    }

  void linearInsert( int first, int last )
    {
    Object value = base.at( last );

    if ( comparator.execute( value, base.at( first ) ) )
      {
      for ( int i = last; i > first; i-- )
        base.put( i, base.at( i - 1 ) );

      base.put( first, value );
      }
    else
      {
      unguardedLinearInsert( last, value );
      }
    }

  void quickSortLoop( int first, int last )
    {
    while ( last - first > stlThreshold )
      {
      Object pivot;
      Object a = base.at( first );
      Object b = base.at( first + (last - first ) / 2 );
      Object c = base.at( last - 1 );

      if ( comparator.execute( a, b ) )
        {
        if ( comparator.execute( b, c ) )
          pivot = b;
        else if ( comparator.execute( a, c ) )
          pivot = c;
        else
          pivot = a;
        }
      else if ( comparator.execute( a, c ) )
        pivot = a;
      else if ( comparator.execute( b, c ) )
        pivot = c;
      else
        pivot = b;

      int cut = first;
      int lastx = last;

      while ( true )
        {
        while ( comparator.execute( base.at( cut ), pivot ) )
          ++cut;

        --lastx;

        while ( comparator.execute( pivot, base.at( lastx ) ) )
          --lastx;

        if ( cut >= lastx )
          break;

        Object tmp = base.at( cut );
        base.put( cut++, base.at( lastx ) );
        base.put( lastx, tmp );
        }

      if ( cut - first >= last - cut )
        {
        quickSortLoop( cut, last );
        last = cut;
        }
      else
        {
        quickSortLoop( first, cut );
        first = cut;
        }
      }
    }

  /**
   * Sort the iterators in a container according to their hash code.  The 
   * object with the smallest hash code is placed first. The underlying 
   * container will not be changed, simply the order in which the elements 
   * are visited.
   * @param container A container.
   * @return a Range object composed of two ForwardIterators that will
   *   traverse the original range in the desired order.
   * @exception IllegalArgumentException If the iterators are incompatible
   *   or if the containers upon which the iteratore operate is not a com.objectspace.jgl.Sequence.
   */
  public static Range iterSort( Container container )
    {
    return iterSort( container.start(), container.finish() );
    }

  /**
   * Sort the iterators in a container using a comparator.  The 
   * object with the smallest hash code is placed first. The underlying 
   * container will not be changed, simply the order in which the elements 
   * are visited.
   * @param container A container.
   * @param comparator A binary function that returns true if its first 
   *   operand should be positioned before its second operand.
   * @return a Range object composed of two ForwardIterators that will
   *   traverse the original range in the desired order.
   * @exception IllegalArgumentException If the iterators are incompatible
   *   or if the containers upon which the iteratore operate is not a com.objectspace.jgl.Sequence.
   */
  public static Range iterSort( Container container, BinaryPredicate comparator )
    {
    return iterSort( container.start(), container.finish(), comparator );
    }

  /**
   * Sort the iterators according to their hash code.  The 
   * underlying container will not be changed, simply the order in which 
   * the elements are visited.
   * @param first An iterator positioned at the first element.
   * @param last An iterator positioned immediately after the last element.
   * @param comparator A binary function that returns true if its first 
   *   operand should be positioned before its second operand.
   * @return a Range object composed of two ForwardIterators that will
   *   traverse the original range in the desired order.
   * @exception IllegalArgumentException If the iterators are incompatible
   *   or if the containers upon which the iteratore operate is not a com.objectspace.jgl.Sequence.
   */
  public static Range iterSort( ForwardIterator first, ForwardIterator last )
    {
    return iterSort( first, last, new Predicates.HashComparator() );
    }

  /**
   * Sort the iterators using a comparator.  The underlying container will
   * not be changed, simply the order in which the elements are visited.
   * @param first An iterator positioned at the first element.
   * @param last An iterator positioned immediately after the last element.
   * @param comparator A binary function that returns true if its first 
   *   operand should be positioned before its second operand.
   * @return a Range object composed of two ForwardIterators that will
   *   traverse the original range in the desired order.
   * @exception IllegalArgumentException If the iterators are incompatible
   *   or if the containers upon which the iteratore operate is not a com.objectspace.jgl.Sequence.
   */
  public static Range iterSort( ForwardIterator first, ForwardIterator last, BinaryPredicate comparator )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    int n = first.distance( last );
    Array array = new Array();
    array.ensureCapacity( n );
    ForwardIterator firstx = (ForwardIterator)first.clone();
    while ( !firstx.equals( last ) )
      {
      array.pushBack( firstx.clone() );
      firstx.advance();
      }
    sort( array, new IteratorPredicate( comparator ) );
    return new Range
      ( 
      new IteratorIterator( array.start(), first.getContainer() ), 
      new IteratorIterator( array.finish(), first.getContainer() ) 
      );
    }
  }

class IteratorPredicate implements BinaryPredicate
  {
  BinaryPredicate comparator;
  public IteratorPredicate( BinaryPredicate comparator )
    {
    this.comparator = comparator;
    }
  public boolean execute( Object a, Object b )
    {
    return comparator.execute
      ( 
      ( (ForwardIterator)a ).get(), 
      ( (ForwardIterator)b ).get()
      );
    }
  }

class IteratorIterator implements ForwardIterator
  {
  ForwardIterator iterator;
  Container container;
  IteratorIterator( ForwardIterator iterator, Container container )
    {
    this.iterator = iterator;
    this.container = container;
    }
  public void advance()
    {
    iterator.advance();
    }
  public void advance( int n )
    {
    iterator.advance( n );
    }
  public int distance( ForwardIterator i )
    {
    if ( i instanceof IteratorIterator )
      return iterator.distance( ( (IteratorIterator)i ).iterator );
    return iterator.hasMoreElements()
      ? ( (ForwardIterator)iterator.get() ).distance( i )
      : container.finish().distance( i );
    }
  public Object clone()
    {
    return new IteratorIterator( (ForwardIterator)iterator.clone(), container );
    }
  public Container getContainer()
    {
    return container;
    }
  public boolean isCompatibleWith( InputIterator i )
    {
    return i instanceof ForwardIterator && container == ( (ForwardIterator)i ).getContainer();
    }
  public boolean atBegin()
    {
    return iterator.atBegin();
    }
  public boolean atEnd()
    {
    return iterator.atEnd();
    }
  public Object get()
    {
    return ( (ForwardIterator)iterator.get() ).get();
    }
  public Object get( int n )
    {
    return ( (ForwardIterator)iterator.get() ).get( n );
    }
  public void put( Object object )
    {
    ( (ForwardIterator)iterator.get() ).put( object );
    }
  public void put( int n, Object object )
    {
    ( (ForwardIterator)iterator.get() ).put( n, object );
    }
  public boolean equals( Object object )
    {
    return object instanceof IteratorIterator && equals( (IteratorIterator)object );
    }
  public boolean equals( IteratorIterator iterator )
    {
    return this.iterator.equals( iterator.iterator );
    }
  public boolean hasMoreElements()
    {
    return !atEnd();
    }
  public Object nextElement()
    {
    Object object = get();
    advance();
    return object;
    }
  }
