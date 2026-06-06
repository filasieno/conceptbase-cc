// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.util;

import com.objectspace.jgl.*;

/**
 * A ReverseIterator is a bidirectional iterator that allows
 * you to iterate backwards through the contents of a data structure that
 * supports bidirectional iteration.
 * <p>
 * @see com.objectspace.jgl.BidirectionalIterator
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class ReverseIterator implements BidirectionalIterator, java.io.Serializable
  {
  BidirectionalIterator myIterator;

  /**
   * Construct myself to operate using a bidirectional iterator.
   * @param iterator The iterator to use.
   */
  public ReverseIterator( BidirectionalIterator iterator )
    {
    myIterator = iterator;
    }

  /**
   * Construct myself to be a copy of an existing iterator.
   * @param iterator The iterator to copy.
   */
  public ReverseIterator( ReverseIterator iterator )
    {
    myIterator = (BidirectionalIterator) iterator.myIterator.clone();
    }

  /**
   * Return a clone of myself.
   */
  public Object clone()
    {
    return new ReverseIterator( this );
    }

  /**
   * Return true if I'm positioned after the last item in my input stream.
   */
  public boolean atEnd()
    {
    return myIterator.atBegin();
    }

  /**
   * Return true if I'm positioned at the first item of my input stream.
   */
  public boolean atBegin()
    {
    return myIterator.atEnd();
    }

  /**
   * Return true if a specified object is the same kind of iterator as me
   * and is positioned at the same element.
   * @param object Any object.
   */
  public boolean equals( Object object )
    {
    return object instanceof ReverseIterator && equals( (ReverseIterator)object );
    }

  /**
   * Return true if iterator is positioned at the same element as me.
   * @param iterator The iterator to compare myself against.
   */
  public boolean equals( ReverseIterator iterator )
    {
    return myIterator.equals( iterator.myIterator );
    }

  /**
   * Return true if there are more elements in my input stream.
   */
  public boolean hasMoreElements()
    {
    return !myIterator.atBegin();
    }

  /**
   * Advance by one.
   */
  public void advance()
    {
    myIterator.retreat();
    }

  /**
   * Advance by a specified amount.
   * @param n The amount to advance.
   */
  public void advance( int n )
    {
    myIterator.retreat( n );
    }

  /**
   * Retreat by one.
   */
  public void retreat()
    {
    myIterator.advance();
    }

  /**
   * Retreat by a specified amount.
   * @param n The amount to retreat.
   */
  public void retreat( int n )
    {
    myIterator.advance( n );
    }

  /**
   * Return the next element in my input stream.
   */
  public Object nextElement()
    {
    myIterator.retreat();
    return myIterator.get();
    }

  /**
   * Return the object at my current position.
   */
  public Object get()
    {
    myIterator.retreat();
    Object object = myIterator.get();
    myIterator.advance();
    return object;
    }

  /**
   * Set the object at my current position to a specified value.
   * @param object The object to be written at my current position.
   */
  public void put( Object object )
    {
    myIterator.retreat();
    myIterator.put( object );
    myIterator.advance();
    }

  /**
   * Return the distance from myself to another iterator.
   * I should be before the specified iterator.
   * @param iterator The iterator to compare myself against.
   */
  public int distance( ForwardIterator iterator )
    {
    return iterator.distance( this );
    }

  /**
   * Return the object that is a specified distance from my current position.
   * @param offset The offset from my current position.
   */
  public Object get( int offset )
    {
    return myIterator.get( -( offset + 1 ) );
    }

  /**
   * Write an object at a specified distance from my current position.
   * @param offset The offset from my current position.
   * @param object The object to write.
   */
  public void put( int offset, Object object )
    {
    myIterator.put( -( offset + 1 ), object );
    }

  /**
   * Return my associated container via my BidirectionalIterator.
   */
  public Container getContainer()
    {
    return myIterator.getContainer();
    }

  /**
   * Return true if both <CODE>iterator</CODE> and myself can be used
   * as a range.
   */
  public boolean isCompatibleWith( InputIterator iterator )
    {
    return iterator instanceof ReverseIterator && myIterator.isCompatibleWith( iterator );
    }

  static final long serialVersionUID = 4070239314672281028L;
  }
