// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.io.Serializable;

/**
 * A DequeIterator is a random access iterator that allows you to iterate through
 * the contents of a Deque.
 * <p>
 * @see com.objectspace.jgl.RandomAccessIterator
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class DequeIterator implements RandomAccessIterator, Serializable, Opaque
  {
  Deque myDeque;
  int myBlockIndex;
  int myMapIndex;

  /**
   * Construct myself to be an iterator with no associated data structure or position.
   */
  public DequeIterator()
    {
    }

  /**
   * Construct myself to be a copy of an existing iterator.
   * @param iterator The iterator to copy.
   */
  public DequeIterator( DequeIterator iterator )
    {
    myDeque = iterator.myDeque;
    myMapIndex = iterator.myMapIndex;
    myBlockIndex = iterator.myBlockIndex;
    }

  /**
   * Construct myself to be positioned at a particular map and block index
   * within a specified Deque.
   */
  DequeIterator( Deque deque, int blockIndex, int mapIndex )
    {
    myDeque = deque;
    myBlockIndex = blockIndex;
    myMapIndex = mapIndex;
    }

  /**
   * Return a clone of myself.
   */
  public Object clone()
    {
    return new DequeIterator( this );
    }

  /**
   * Return true if I'm positioned at the first item of my input stream.
   */
  public boolean atBegin()
    {
    return equals( myDeque.myStart );
    }

  /**
   * Return true if I'm positioned after the last item in my input stream.
   */
  public boolean atEnd()
    {
    return equals( myDeque.myFinish );
    }

  /**
   * Return true if there are more elements in my input stream.
   */
  public boolean hasMoreElements()
    {
    return !equals( myDeque.myFinish );
    }

  /**
   * Advance by one.
   */
  public void advance()
    {
    if ( ++myBlockIndex == Deque.BLOCK_SIZE )
      {
      ++myMapIndex;
      myBlockIndex = 0;
      }
    }

  /**
   * Advance by a specified amount.
   * @param n The amount to advance.
   */
  public void advance( int n )
    {
    myBlockIndex += n;

    if ( myBlockIndex >= Deque.BLOCK_SIZE )
      {
      int jump = myBlockIndex / Deque.BLOCK_SIZE;
      myMapIndex += jump;
      myBlockIndex %= Deque.BLOCK_SIZE;
      }
    else if ( myBlockIndex < 0 )
      {
      int jump = ( Deque.BLOCK_SIZE - 1 - myBlockIndex ) / Deque.BLOCK_SIZE;
      myMapIndex -= jump;
      myBlockIndex += jump * Deque.BLOCK_SIZE;
      }
    }

  /**
   * Retreat by one.
   */
  public void retreat()
    {
    if ( --myBlockIndex == -1 )
      {
      --myMapIndex;
      myBlockIndex = Deque.BLOCK_SIZE - 1;
      }
    }

  /**
   * Retreat by a specified amount.
   * @param n The amount to retreat.
   */
  public void retreat( int n )
    {
    advance( -n );
    }

  /**
   * Return the next element in my input stream.
   * @exception java.util.NoSuchElementException If I'm positioned at an invalid position.
   */
  public Object nextElement()
    {
    try
      {
      Object object = get();
      advance();
      return object;
      }
    catch ( NullPointerException ex )
      {
      throw new java.util.NoSuchElementException( "DequeIterator" );
      }
    }

  DequeIterator copy( int i )
    {
    DequeIterator tmp = new DequeIterator( this );
    tmp.advance( i );
    return tmp;
    }

  /**
   * Return the distance from myself to another iterator.
   * I should be before the specified iterator.
   * @param iterator The iterator to compare myself against.
   */
  public int distance( ForwardIterator iter )
    {
    dequeinfo info = (dequeinfo)( (Opaque)iter ).opaqueData();
    int gap = info.block - myBlockIndex;
    return myMapIndex == info.map
      ? gap
      : Deque.BLOCK_SIZE * ( info.map - myMapIndex ) + gap;
    }

  /**
   * Return my current index.
   */
  public int index()
    {
    return myDeque.myStart.distance( this );
    }

  /**
   * Return the object at my current position.
   */
  public Object get()
    {
    return myDeque.myMap[ myMapIndex ][ myBlockIndex ];
    }

  /**
   * Set the object at my current position to a specified value.
   * @param object The object to be written at my current position.
   */
  public void put( Object object )
    {
    myDeque.myMap[ myMapIndex ][ myBlockIndex ] = object;
    }

  /**
   * Return the object that is a specified distance from my current position.
   * @param offset The offset from my current position.
   */
  public Object get( int offset )
    {
    int oldMapIndex = myMapIndex;
    int oldBlockIndex = myBlockIndex;
    advance( offset );
    Object object = get();
    myMapIndex = oldMapIndex;
    myBlockIndex = oldBlockIndex;
    return object;
    }

  /**
   * Write an object at a specified distance from my current position.
   * @param offset The offset from my current position.
   * @param object The object to write.
   */
  public void put( int offset, Object object )
    {
    int oldMapIndex = myMapIndex;
    int oldBlockIndex = myBlockIndex;
    advance( offset );
    put( object );
    myMapIndex = oldMapIndex;
    myBlockIndex = oldBlockIndex;
    }

  /**
   * Return true if a specified object is the same kind of iterator as me
   * and is positioned at the same element.
   * @param object Any object.
   */
  public boolean equals( Object object )
    {
    if ( object instanceof Opaque )
      {
      dequeinfo info = (dequeinfo)( (Opaque)object ).opaqueData();
      return 
        myMapIndex == info.map 
        && myBlockIndex == info.block
        && isCompatibleWith( (InputIterator)object );
      }
    return false;
    }

  /**
   * Return true if I'm before a specified iterator.
   * @param iterator The iterator to compare myself against.
   */
  public boolean less( RandomAccessIterator iterator )
    {
    dequeinfo info = (dequeinfo)( (Opaque)iterator ).opaqueData();
    return 
      myMapIndex < info.map 
      || ( myMapIndex == info.map && myBlockIndex < info.block );
    }

  /**
   * Return my associated container.
   */
  public Container getContainer()
    {
    return myDeque;
    }

  /**
   * Return true if both <CODE>iterator</CODE> and myself can be used
   * as a range.
   */
  public boolean isCompatibleWith( InputIterator iterator )
    {
    return 
      iterator instanceof Opaque 
      && opaqueId() == ( (Opaque)iterator ).opaqueId();
    }

  /**
   * Should not be used directly.
   * @see com.objectspace.jgl.Opaque
   */
  public Object opaqueData()
    {
    return new dequeinfo( myBlockIndex, myMapIndex );
    }

  /**
   * Should not be used directly.
   * @see com.objectspace.jgl.Opaque
   */
  public int opaqueId()
    {
    return System.identityHashCode( myDeque );
    }

  static private class dequeinfo implements Serializable
    {
    public int block;
    public int map;
    public dequeinfo( int b, int m )
      {
      block = b;
      map = m;
      }
    }

  static final long serialVersionUID = 8197515993982694406L;
  }
