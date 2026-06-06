// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.util.Enumeration;

/**
 * A Queue is an adapter that allows you to use any Sequence as a
 * first-in, first-out data structure. By default, a Queue uses an
 * SList.
 * <p>
 * @see com.objectspace.jgl.Sequence
 * @see com.objectspace.jgl.SList
 * @see com.objectspace.jgl.examples.QueueExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class Queue implements Container
  {
  protected Sequence mySequence;

  /**
   * Construct myself to be an empty Queue.
   * Use an SList for my underlying implementation.
   */
  public Queue()
    {
    mySequence = new SList();
    }

  /**
   * Construct myself with a specified Sequence as my underlying implementation.
   * @param sequence The empty Sequence to be used for my implementation.
   */
  public Queue( Sequence sequence )
    {
    synchronized( sequence )
      {
      mySequence = (Sequence)sequence.clone();
      }
    }

  /**
   * Construct myself to be a shallow copy of a specified Queue.
   * @param queue The Queue to be copied.
   */
  public Queue( Queue queue )
    {
    synchronized( queue )
      {
      mySequence = (Sequence)queue.mySequence.clone();
      }
    }

  /**
   * Become a shallow copy of a Queue.
   * @param queue The Queue to be copied.
   */
  public synchronized void copy( Queue queue )
    {
    synchronized( queue )
      {
      if ( this != queue )
        mySequence = (Sequence)queue.mySequence.clone();
      }
    }

  /**
   * Return a string that describes me.
   */
  public synchronized String toString()
    {
    return "Queue( " + mySequence.toString() + " )";
    }

  /**
   * Return true if object is a Queue whose underlying sequence is equal to mine.
   * @param object Any object.
   */
  public boolean equals( Object object )
    {
    return object instanceof Queue && equals( (Queue)object );
    }

  /**
   * Return true if a Queue's sequence is equal to mine.
   * @param queue The Queue to compare myself against.
   */
  public synchronized boolean equals( Queue queue )
    {
    synchronized( queue )
      {
      return mySequence.equals( queue.mySequence );
      }
    }

  /**
   * Return my hash code for support of hashing containers
   */
  public synchronized int hashCode()
    {
    return mySequence.hashCode();
    }

  /**
   * Return a shallow copy of myself.
   * A shallow copy is made of my underlying sequence.
   */
  public synchronized Object clone()
    {
    return new Queue( (Sequence)mySequence.clone() );
    }

  /**
   * Remove all of my objects.
   */
  public synchronized void clear()
    {
    mySequence.clear();
    }

  /**
   * Return true if I contain no objects.
   */
  public boolean isEmpty()
    {
    return mySequence.isEmpty();
    }

  /**
   * Return the number of objects that I contain.
   */
  public int size()
    {
    return mySequence.size();
    }

  /**
   * Return the maximum number of objects that I can contain.
   */
  public int maxSize()
    {
    return mySequence.maxSize();
    }

  /**
   * Return the object at my front.
   * @exception com.objectspace.jgl.InvalidOperationException If the Queue is empty.
   */
  public synchronized Object front()
    {
    return mySequence.front();
    }

  /**
   * Return the object at my back.
   * @exception com.objectspace.jgl.InvalidOperationException If the Queue is empty.
   */
  public synchronized Object back()
    {
    return mySequence.back();
    }

  /**
   * Add an object to my back.
   * @param object The object to add.
   */
  public synchronized Object add( Object object )
    {
    return mySequence.add( object );
    }

  /**
   * Add an object to my back.
   */
  public void push( Object object )
    {
    add( object );
    }

  /**
   * Remove an object from my front and return it.
   * @exception com.objectspace.jgl.InvalidOperationException If the Queue is empty.
   */
  public synchronized Object pop()
    {
    return mySequence.popFront();
    }

  /**
   * Return an Enumeration of my components.
   */
  public synchronized Enumeration elements()
    {
    return mySequence.elements();
    }

  /**
   * Return an iterator positioned at my first item.
   */
  public synchronized ForwardIterator start()
    {
    return mySequence.start();
    }

  /**
   * Return an iterator positioned immediately afer my last item.
   */
  public synchronized ForwardIterator finish()
    {
    return mySequence.finish();
    }

  /**
   * Swap my contents with another Queue.
   * @param queue The Queue that I will swap my contents with.
   */
  public synchronized void swap( Queue queue )
    {
    synchronized ( queue )
      {
      Sequence tmpSequence = mySequence;
      mySequence = queue.mySequence;
      queue.mySequence = tmpSequence;
      }
    }

  /**
   * Remove the element at a particular position.
   * @param pos The enumeration representing of the object to remove.
   * @exception com.objectspace.jgl.InvalidOperationException Thrown by default.
   */
  public Object remove( Enumeration pos )
    {
    throw new InvalidOperationException( "cannot execute remove() on a queue" );
    }

  /**
   * Remove the elements in the specified range.
   * @param pos The enumeration representing of the object to remove.
   * @exception com.objectspace.jgl.InvalidOperationException Thrown by default.
   */
  public int remove( Enumeration first, Enumeration last )
    {
    throw new InvalidOperationException( "cannot execute remove() on a queue" );
    }

  static final long serialVersionUID = 7569257328785189956L;
  }
