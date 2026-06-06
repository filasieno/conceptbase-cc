// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.util.Enumeration;
import java.io.ObjectOutputStream;
import java.io.ObjectInputStream;
import java.io.IOException;

/**
 * A PriorityQueue is an adapter that allows you to access items in a sorted order.
 * It allows you to specify a comparator that is used to sort the items.
 * The object with the highest priority will be the last item in the 
 * collection when sorted using the given comparator.
 * <p>
 * For example, the following code fragment:
 * <PRE>
 *   PriorityQueue pqueue = new PriorityQueue( new GreaterNumber() );
 *   pqueue.push( new Integer( 3 ) );
 *   pqueue.push( new Integer( 1 ) );
 *   pqueue.push( new Integer( 2 ) );
 *   while ( !pqueue.isEmpty() )
 *     System.out.println( "popped " + pqueue.pop() );
 * </PRE>
 * will have the resulting output:
 * <PRE>
 *   popped 1
 *   popped 2
 *   popped 3
 * </PRE><p>
 * A PriorityQueue accesses its underlying Array as a heap.
 * This means that although objects will always pop in the order determined
 * by the comparator, the objects are not necessarily stored in that order.
 * <p>
 * @see com.objectspace.jgl.Array
 * @see com.objectspace.jgl.Algos.Heap
 * @see com.objectspace.jgl.examples.PriorityQueueExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class PriorityQueue implements Container
  {
  protected Array myArray;
  protected BinaryPredicate myComparator;

  /**
   * Construct myself to be an empty PriorityQueue.
   * Order elements based on their hash code.
   */
  public PriorityQueue()
    {
    this( new xHashComparator() );
    }

  /**
   * Construct myself to be an empty PriorityQueue.
   * Order elements using the specified comparator.
   * @param comparator The comparator to be used for comparing elements.
   */
  public PriorityQueue( BinaryPredicate comparator )
    {
    myArray = new Array();
    myComparator = comparator;
    }

  /**
   * Construct myself to be a shallow copy of a specified PriorityQueue.
   * A shallow copy is made of its underlying sequence.
   * @param queue The instance of PriorityQueue to be copied.
   */
  public PriorityQueue( PriorityQueue queue )
    {
    synchronized( queue )
      {
      myArray = (Array)queue.myArray.clone();
      myComparator = queue.myComparator;
      }
    }

  /**
   * Return a string that describes me. Although objects will always pop 
   * in the order determined by the comparator, the objects are not 
   * necessarily stored in that order; as a result, the order they appear 
   * in a String may not be in the expected order.
   */
  public synchronized String toString()
    {
    /*
      // this will always stringify elements in the same order as they
      // are popped
      Array out = new Array( myArray );
      com.objectspace.jgl.algorithms.Sorting.sort( out, myComparator );
      com.objectspace.jgl.algorithms.Reversing.reverse( out );
      return "PriorityQueue( " + out.toString() + " )";
    */
      // this will print all elements, but in an arbitrary order
      return "PriorityQueue( " + myArray.toString() + " )";
    }

  /**
   * Return a shallow copy of myself.
   */
  public synchronized Object clone()
    {
    return new PriorityQueue( this );
    }

  /**
   * Become a shallow copy of a specified PriorityQueue.
   * By underlying data structure becomes a shallow copy of the specified
   * PriorityQueue's data structure.
   * @param queue The PriorityQueue to be copied.
   */
  public synchronized void copy( PriorityQueue queue )
    {
    synchronized( queue )
      {
      if ( this != queue )
        {
        myArray = (Array)queue.myArray.clone();
        myComparator = queue.myComparator;
        }
      }
    }

  /**
   * Return true if object is a PriorityQueue whose underlying sequence is equal to mine.
   * @param object Any object.
   */
  public boolean equals( Object object )
    {
    return object instanceof PriorityQueue && equals( (PriorityQueue)object );
    }

  /**
   * Return true if a specified PriorityQueue's sequence is equal to mine.
   * @param queue The PriorityQueue to compare myself against.
   */
  public synchronized boolean equals( PriorityQueue queue )
    {
    synchronized( queue )
      {
      return myArray.equals( queue.myArray );
      }
    }

  /**
   * Return my hash code for support of hashing containers
   */
  public synchronized int hashCode()
    {
    return myArray.hashCode();
    }

  /**
   * Return true if I contain no objects.
   */
  public boolean isEmpty()
    {
    return myArray.isEmpty();
    }

  /**
   * Return the number of objects that I contain.
   */
  public int size()
    {
    return myArray.size();
    }

  /**
   * Return the maximum number of objects that I can contain.
   */
  public int maxSize()
    {
    return myArray.maxSize();
    }

  /**
   * Remove all of my objects.
   */
  public synchronized void clear()
    {
    myArray.clear();
    }

  /**
   * Return my comparator.
   */
  public synchronized BinaryPredicate getComparator()
    {
    return myComparator;
    }

  /**
   * Return an Enumeration of my elements.
   */
  public synchronized Enumeration elements()
    {
    return myArray.elements();
    }

  /**
   * Return an iterator positioned at my first item.
   */
  public synchronized ForwardIterator start()
    {
    return myArray.start();
    }

  /**
   * Return an iterator positioned immediately afer my last item.
   */
  public synchronized ForwardIterator finish()
    {
    return myArray.finish();
    }

  /**
   * Return my top object.
   * @exception com.objectspace.jgl.InvalidOperationException If the PriorityQueue is empty.
   */
  public synchronized Object top()
    {
    return myArray.front();
    }

  /**
   * Push an object.  Add always works so return null.
   * @param object The object to push.
   */
  public Object add( Object object )
    {
    push( object );
    return null;
    }

  /**
   * Push an object.
   * @param object The object to push.
   */
  public synchronized void push( Object object )
    {
    myArray.pushBack( object );
    pushHeap( myArray.start(), myArray.finish(), myComparator );
    }

  /**
   * Pop the last object that was pushed onto me.
   * @exception com.objectspace.jgl.InvalidOperationException If the PriorityQueue is empty.
   */
  public synchronized Object pop()
    {
    if ( myArray.isEmpty() )
      throw new InvalidOperationException( "PriorityQueue is empty" );

    popHeap( myArray.start(), myArray.finish(), myComparator );
    return myArray.popBack();
    }

  /**
   * Swap my contents with another PriorityQueue.
   * @param queue The PriorityQueue that I will swap my contents with.
   */
  public synchronized void swap( PriorityQueue queue )
    {
    synchronized( queue )
      {
      Array tmpArray = myArray;
      myArray = queue.myArray;
      queue.myArray = tmpArray;

      BinaryPredicate tmpComparator = myComparator;
      myComparator = queue.myComparator;
      queue.myComparator = tmpComparator;
      }
    }

  /**
   * Remove the element at a particular position.
   * @param pos The enumeration representing of the object to remove.
   * @exception com.objectspace.jgl.InvalidOperationException Thrown by default.
   */
  public Object remove( Enumeration pos )
    {
    throw new InvalidOperationException( "cannot execute remove() on a priority queue" );
    }

  /**
   * Remove the elements in the specified range.
   * @param pos The enumeration representing of the object to remove.
   * @exception com.objectspace.jgl.InvalidOperationException Thrown by default.
   */
  public int remove( Enumeration first, Enumeration last )
    {
    throw new InvalidOperationException( "cannot execute remove() on a priority queue" );
    }

  static final long serialVersionUID = 6264990747843793967L;

  /**
   * @see com.objectspace.jgl.algorithms.Heap#pushHeap(com.objectspace.jgl.BidirectionalIterator,com.objectspace.jgl.BidirectionalIterator,com.objectspace.jgl.BinaryPredicate)
   */
  private static void pushHeap( ForwardIterator first, ForwardIterator last, BinaryPredicate comparator )
    {
    pushHeap( first, first.distance( last ) - 1, 0, last.get( -1 ), comparator );
    }

  private static void pushHeap( ForwardIterator first, int holeIndex, int topIndex, Object value, BinaryPredicate comparator )
    {
    int parent = ( holeIndex - 1 ) / 2;
    while ( holeIndex > topIndex && comparator.execute( first.get( parent ), value ) )
      {
      first.put( holeIndex, first.get( parent ) );
      holeIndex = parent;
      parent = ( holeIndex - 1 ) / 2;
      }
    first.put( holeIndex, value );
    }

  /**
   * @see com.objectspace.jgl.algorithms.Heap#popHeap(com.objectspace.jgl.BidirectionalIterator,com.objectspace.jgl.BidirectionalIterator,com.objectspace.jgl.BinaryPredicate)
   */
  private static void popHeap( ForwardIterator first, ForwardIterator last, BinaryPredicate comparator )
    {
    Object value = last.get( -1 );
    last.put( -1, first.get() );
    int holeIndex = 0; 
    int len = first.distance( last ) - 1;
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
