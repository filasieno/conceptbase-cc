// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.util.Enumeration;

/**
 * A Stack is an adapter that allows you to use any Sequence as a
 * first-in, last-out data structure. By default, a Stack uses an
 * Array.
 * <p>
 * @see com.objectspace.jgl.Sequence
 * @see com.objectspace.jgl.Array
 * @see com.objectspace.jgl.examples.StackExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class Stack implements Container
  {
  protected Sequence mySequence;

  /**
   * Construct myself to be an empty Stack.
   * Use an Array for my underlying implementation.
   */
  public Stack()
    {
    mySequence = new Array();
    }

  /**
   * Construct myself with a specified Sequence as my underlying implementation.
   * @param sequence The empty Sequence to be used for my implementation.
   */
  public Stack( Sequence sequence )
    {
    synchronized( sequence )
      {
      mySequence = (Sequence)sequence.clone();
      }
    }

  /**
   * Construct myself to be a shallow copy of a specified Stack.
   * @param stack The Stack to be copied.
   */
  public Stack( Stack stack )
    {
    synchronized( stack )
      {
      mySequence = (Sequence)stack.mySequence.clone();
      }
    }

  /**
   * Become a shallow copy of a specified Stack.
   * A shallow copy is made of the Stack's underlying sequence.
   * @param stack The Stack to be copied.
   */
  public synchronized void copy( Stack stack )
    {
    synchronized( stack )
      {
      if ( this != stack )
        mySequence = (Sequence)stack.mySequence.clone();
      }
    }

  /**
   * Return a shallow copy of myself.
   */
  public synchronized Object clone()
    {
    return new Stack( (Sequence)mySequence.clone() );
    }

  /**
   * Return a string that describes me.
   */
  public synchronized String toString()
    {
    return "Stack( " + mySequence.toString() + " )";
    }

  /**
   * Return true if object is a Stack whose underlying sequence is equal to mine.
   * @param object Any object.
   */
  public boolean equals( Object object )
    {
    return object instanceof Stack && equals( (Stack)object );
    }

  /**
   * Return true if a specified Stack's sequence is equal to mine.
   * @param stack The Stack to compare myself against.
   */
  public synchronized boolean equals( Stack stack )
    {
    return mySequence.equals( stack.mySequence );
    }

  /**
   * Return my hash code for support of hashing containers
   */
  public synchronized int hashCode()
    {
    return mySequence.hashCode();
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
   * Return the last object that was pushed onto me.
   * @exception com.objectspace.jgl.InvalidOperationException if the Stack is empty.
   */
  public synchronized Object top()
    {
    return mySequence.back();
    }

  /**
   * Push an object.  Return null as add's always work for Stacks
   * @param object The object to push.
   */
  public synchronized Object add( Object object )
    {
    mySequence.pushBack( object );
    return null;
    }

  /**
   * Push an object.
   * @param object The object to push.
   */
  public void push( Object object )
    {
    add( object );
    }

  /**
   * Pop the last object that was pushed onto me.
   * @exception com.objectspace.jgl.InvalidOperationException if the Stack is empty.
   */
  public synchronized Object pop()
    {
    return mySequence.popBack();
    }

  /**
   * Remove all of my objects.
   */
  public synchronized void clear()
    {
    mySequence.clear();
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
   * Swap my contents with another Stack.
   * @param stack The Stack that I will swap my contents with.
   */
  public synchronized void swap( Stack stack )
    {
    synchronized( stack )
      {
      Sequence tmp_sequence = mySequence;
      mySequence = stack.mySequence;
      stack.mySequence = tmp_sequence;
      }
    }

  /**
   * Remove the element at a particular position.
   * @param pos The enumeration representing of the object to remove.
   * @exception com.objectspace.jgl.InvalidOperationException Thrown by default.
   */
  public Object remove( Enumeration pos )
    {
    throw new InvalidOperationException( "cannot execute remove() on a stack" );
    }

  /**
   * Remove the elements in the specified range.
   * @param pos The enumeration representing of the object to remove.
   * @exception com.objectspace.jgl.InvalidOperationException Thrown by default.
   */
  public int remove( Enumeration first, Enumeration last )
    {
    throw new InvalidOperationException( "cannot execute remove() on a stack" );
    }

  static final long serialVersionUID = 96346749151780292L;
  }
