// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.io.Serializable;

/**
 * An ArrayIterator is a random access iterator that allows you to iterate through
 * the contents of a Array.
 * <p>
 * @see com.objectspace.jgl.RandomAccessIterator
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class ArrayIterator implements RandomAccessIterator, Serializable, Opaque
  {
  Array myArray;
  int myIndex;

  /**
   * Construct myself to be an iterator with no associated data structure or position.
   */
  public ArrayIterator()
    {
    }

  /**
   * Construct myself to be a copy of an existing iterator.
   * @param iterator The iterator to copy.
   */
  public ArrayIterator( ArrayIterator iterator )
    {
    myArray = iterator.myArray;
    myIndex = iterator.myIndex;
    }

  /**
   * Construct myself to be positioned at a particular index of a specific Array.
   * @param vector My associated Array.
   * @param index My associated index.
   */
  public ArrayIterator( Array vector, int index )
    {
    myArray = vector;
    myIndex = index;
    }

  /**
   * Return a clone of myself.
   */
  public Object clone()
    {
    return new ArrayIterator( this );
    }

  /**
   * Return true if a specified object is the same kind of iterator as me
   * and is positioned at the same element.
   * @param object Any object.
   */
  public boolean equals( Object object )
    {
    if ( object instanceof RandomAccessIterator )
      {
      // cache so we don't cast twice
      RandomAccessIterator iter = (RandomAccessIterator)object;
      return myIndex == iter.index() && isCompatibleWith( iter );
      }
    return false;
    }

  /**
   * Return true if I'm before a specified iterator.
   * @param iterator The iterator to compare myself against.
   */
  public boolean less( RandomAccessIterator iterator )
    {
    return myIndex < iterator.index();
    }

  /**
   * Return the object that is a specified distance from my current position.
   * @param offset The offset from my current position.
   * @exception ArrayIndexOutOfBoundsException If the adjusted index is invalid.
   */
  public Object get( int offset )
    {
    return myArray.at( myIndex + offset );
    }

  /**
   * Write an object at a specified distance from my current position.
   * @param offset The offset from my current position.
   * @param object The object to write.
   * @exception ArrayIndexOutOfBoundsException If the adjusted index is invalid.
   */
  public void put( int offset, Object object )
    {
    myArray.put( myIndex + offset, object );
    }

  /**
   * Return true if I'm positioned at the first item of my input stream.
   */
  public boolean atBegin()
    {
    return myIndex == 0;
    }

  /**
   * Return true if I'm positioned after the last item in my input stream.
   */
  public boolean atEnd()
    {
    return myIndex == myArray.size();
    }

  /**
   * Return true if there are more elements in my input stream.
   */
  public boolean hasMoreElements()
    {
    return myIndex < myArray.size();
    }

  /**
   * Advance by one.
   */
  public void advance()
    {
    ++myIndex;
    }

  /**
   * Advance by a specified amount.
   * @param n The amount to advance.
   */
  public void advance( int n )
    {
    myIndex += n;
    }

  /**
   * Retreat by one.
   */
  public void retreat()
    {
    --myIndex;
    }

  /**
   * Retreat by a specified amount.
   * @param n The amount to retreat.
   */
  public void retreat( int n )
    {
    myIndex -= n;
    }

  /**
   * Return the next element in my input stream.
   * @exception java.util.NoSuchElementException If I'm positioned at an invalid index.
   */
  public Object nextElement()
    {
    try
      {
      return myArray.at( myIndex++ );
      }
    catch ( IndexOutOfBoundsException ex )
      {
      throw new java.util.NoSuchElementException( "ArrayIterator" );
      }
    }

  /**
   * Return the object at my current position.
   * @exception ArrayIndexOutOfBoundsException If I'm positioned at an invalid index.
   */
  public Object get()
    {
    return myArray.at( myIndex );
    }

  /**
   * Set the object at my current position to a specified value.
   * @param object The object to be written at my current position.
   * @exception ArrayIndexOutOfBoundsException If I'm positioned at an invalid index.
   */
  public void put( Object object )
    {
    myArray.put( myIndex, object );
    }

  /**
   * Return the distance from myself to another iterator.
   * I should be before the specified iterator.
   * @param iterator The iterator to compare myself against.
   */
  public int distance( ForwardIterator iterator )
    {
    return iterator instanceof RandomAccessIterator
      ? ( (RandomAccessIterator)iterator ).index() - myIndex
      : -1;
    }

  /**
   * Return my current index.
   */
  public int index()
    {
    return myIndex;
    }

  /**
   * Return my associated array.
   */
  public Container getContainer()
    {
    return myArray;
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
    return null;
    }

  /**
   * Should not be used directly.
   * @see com.objectspace.jgl.Opaque
   */
  public int opaqueId()
    {
    return System.identityHashCode( myArray );
    }

  static final long serialVersionUID = 5656837180380660021L;
  }
