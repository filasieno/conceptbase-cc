// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.adapters;

import com.objectspace.jgl.*;
import java.util.Enumeration;

/**
 * ArrayAdapter is the base class of all array adapters, including those
 * that adapt the JDK Vector and Java native arrays.
 * <p>
 * @see com.objectspace.jgl.adapters.BooleanArray
 * @see com.objectspace.jgl.adapters.ByteArray
 * @see com.objectspace.jgl.adapters.CharArray
 * @see com.objectspace.jgl.adapters.DoubleArray
 * @see com.objectspace.jgl.adapters.FloatArray
 * @see com.objectspace.jgl.adapters.IntArray
 * @see com.objectspace.jgl.adapters.LongArray
 * @see com.objectspace.jgl.adapters.ObjectArray
 * @see com.objectspace.jgl.adapters.ShortArray
 * @see com.objectspace.jgl.adapters.VectorArray
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

abstract public class ArrayAdapter implements Sequence
  {
  static final int DEFAULT_SIZE = 10;
  static final int THRESHOLD = 2000;
  static final int MULTIPLIER = 2;

  // needed for Visual J++ bug workaround
  public Object clone()
    {
    return null;
    }

  // needed for Visual J++ bug workaround
  public boolean equals( Object object )
    {
    return false;
    }

  /**
   * Return my hash code for support of hashing containers
   */
  public synchronized int hashCode()
    {
    return Algorithms.Hashing.orderedHash( start(), size() );
    }

  /**
   * Return true if I contain no objects.
   */
  public boolean isEmpty()
    {
    return size() == 0;
    }

  /**
   * Return my last element.
   */
  public Object back()
    {
    return at( size() - 1 );
    }

  /**
   * Return my first element.
   */
  public Object front()
    {
    return at( 0 );
    }

  /**
   * Return the number of objects that match a specified object.
   * @param object The object to count.
   */
  public int count( Object object )
    {
    return count( 0, size() - 1, object );
    }

  /**
   * Return the number of objects within a specified range of that match a
   * particular value.  the range is inclusive
   * @param first The index of the first object to consider.
   * @param last The index of the last object to consider.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public synchronized int count( int first, int last, Object object )
    {
    int count = 0;

    for ( int i=first; i <= last; i++ )
      if ( at( i ).equals( object ) )
        ++count;

    return count;
    }

  /**
   * Replace all elements that match a particular object with a new value and return
   * the number of objects that were replaced.
   * @param oldValue The object to be replaced.
   * @param newValue The value to substitute.
   */
  public int replace( Object oldValue, Object newValue )
    {
    return replace( 0, size() - 1, oldValue, newValue );
    }

  /**
   * Replace all elements within a specified range that match a particular object
   * with a new value and return the number of objects that were replaced.
   * @param first The index of the first object to be considered.
   * @param last The index of the last object to be considered.
   * @param oldValue The object to be replaced.
   * @param newValue The value to substitute.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public synchronized int replace( int first, int last, Object oldValue, Object newValue )
    {
    int count = 0;
    for ( int i=first; i <= last; i++ )
      if ( at( i ).equals( oldValue ) )
        {
        put( i, newValue );
        ++count;
        }

    return count;
    }

  /**
   * Return true if I contain a particular object using .equals()
   * @param object The object in question.
   */
  public boolean contains( Object object )
    {
    return indexOf( object ) != -1;
    }

  /**
   * Return the index of the first object that matches a particular value, or
   * -1 if the object is not found.  Uses .equals() to find a match
   * @param object The object to find.
   * @exception java.lang.ClassCastException if objects are not Boolean
   */
  public int indexOf( Object object )
    {
    return indexOf( 0, size() - 1, object );
    }


  /**
   * Return an index positioned at the first object within a specified range that
   * matches a particular object, or -1 if the object is not found.
   * @param first The index of the first object to consider.
   * @param last The index of the last object to consider.
   * @param object The object to find.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   * @exception java.lang.ClassCastException if objects are not Boolean
   */
  public synchronized int indexOf( int first, int last, Object object )
    {
    for ( int i=first; i <= last; i++ )
      if ( at( i ).equals( object ) )
        return i;

    return -1;
    }

  /**
   * Remove all of my objects. By default, this method throws an exception.
   * @exception com.objectspace.jgl.InvalidOperationException Thrown by default.
   */
  public void clear()
    {
    throw new InvalidOperationException( "cannot execute clear() on a native array" );
    }

  /**
   * Add an object to myself. By default, this method throws an exception.
   * @param object The object to add.
   * @exception com.objectspace.jgl.InvalidOperationException Thrown by default.
   */
  public Object add( Object object )
    {
    throw new InvalidOperationException( "cannot execute add() on a native array" );
    }

  /**
   * Insert an object in front of my first element. By default, this method throws
   * an exception.
   * @param object The object to insert.
   * @exception com.objectspace.jgl.InvalidOperationException Thrown by default.
   */
  public void pushFront( Object object )
    {
    throw new InvalidOperationException( "cannot execute pushFront() on a native array" );
    }

  /**
   * Remove and return my first element. By default, this method throws an exception.
   * @exception com.objectspace.jgl.InvalidOperationException Thrown by default.
   */
  public Object popFront()
    {
    throw new InvalidOperationException( "cannot execute popFront() on a native array" );
    }

  /**
   * Add an object at my end. By default, this method throws an exception.
   * @param object The object to add.
   * @exception com.objectspace.jgl.InvalidOperationException Thrown by default.
   */
  public void pushBack( Object object )
    {
    throw new InvalidOperationException( "cannot execute pushBack() on a native array" );
    }

  /**
   * Remove and return my last element. By default, this method throws an exception.
   * @exception com.objectspace.jgl.InvalidOperationException Thrown by default.
   */
  public Object popBack()
    {
    throw new InvalidOperationException( "cannot execute popBack() on a native array" );
    }

  /**
   * Remove the element at a particular position.
   * @param pos The enumeration representing of the object to remove.
   * @exception com.objectspace.jgl.InvalidOperationException Thrown by default.
   */
  public Object remove( Enumeration pos )
    {
    throw new InvalidOperationException( "cannot execute remove() on a native array" );
    }

  /**
   * Remove the elements in the specified range.
   * @param pos The enumeration representing of the object to remove.
   * @exception com.objectspace.jgl.InvalidOperationException Thrown by default.
   */
  public int remove( Enumeration first, Enumeration last )
    {
    throw new InvalidOperationException( "cannot execute remove() on a native array" );
    }

  /**
   * Remove all elements that match a specified object and return the number of
   * objects that were removed. By default, this method throws an exception.
   * @param object The object to remove.
   * @exception com.objectspace.jgl.InvalidOperationException Thrown by default.
   */
  public int remove( Object object )
    {
    throw new InvalidOperationException( "cannot execute remove() on a native array" );
    }

  /**
   * Remove at most a given number of elements that match a specified object and return the number of
   * objects that were removed. By default, this method throws an exception.
   * @param object The object to remove.
   * @param count The maximum number of objects to remove.
   * @exception com.objectspace.jgl.InvalidOperationException Thrown by default.
   */
  public int remove( Object object, int count )
    {
    throw new InvalidOperationException( "cannot execute remove() on a native array" );
    }

  /**
   * Remove all elements within a specified range that match a particular object
   * and return the number of objects that were removed. By default, this method throws
   * an exception.
   * @param first The index of the first object to remove.
   * @param last The index of the last object to remove.
   * @param object The object to remove.
   * @exception java.lang.IndexOutOfBoundsException Thrown by default.
   */
  public int remove( int first, int last, Object object )
    {
    throw new InvalidOperationException( "cannot execute remove() on a native array" );
    }

  /**
   * Return the maximum number of entries that I can contain.
   * @since JGL3.0
   */
  public int maxSize()
    {
    return Integer.MAX_VALUE;
    }

  final protected static void checkIndex( int i, int size )
    {
    if ( i < 0 || i >= size )
      throw new IndexOutOfBoundsException
        ( 
        "Attempt to access index " + i + "; valid range is 0.." + ( size - 1 )
        );
    }

  final protected static void checkRange( int lo, int hi, int size )
    {
    checkIndex( lo, size );
    checkIndex( hi, size );
    }

  final static int getNextSize( int cursize )
    {
    // multiply by MULTIPLIER until THRESHOLD reached; increment by THRESHOLD
    // from then on
    int newSize = cursize > THRESHOLD
      ? cursize + THRESHOLD
      : cursize * MULTIPLIER;
    return Math.max( 1, newSize );
    }

  static final long serialVersionUID = 6128010853760609317L;
  }
