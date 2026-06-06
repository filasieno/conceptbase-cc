// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.adapters;

import com.objectspace.jgl.*;
import java.io.Serializable;

/**
 * A ByteIterator is a random access iterator that allows you to iterate through
 * the contents of a ByteBuffer.
 * <p>
 * @see com.objectspace.jgl.RandomAccessIterator
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class ByteIterator implements RandomAccessIterator, Serializable
  {
  /**
   * Return an iterator positioned at the first element of a particular array.
   * @param array The array whose first element I will be positioned at.
   */
  public static ByteIterator begin( byte[] array )
    {
    return new ByteIterator( array, 0 );
    }

  /**
   * Return an iterator positioned immediately after the last element of a particular array.
   * @param array The array whose last element I will be positioned after.
   */
  public static ByteIterator end( byte[] array )
    {
    return new ByteIterator( array, array.length );
    }

  byte buffer[];
  Container original;
  int index;

  /**
   * Construct myself to be an iterator with no associated data structure or position.
   */
  public ByteIterator()
    {
    this( new ByteArray(), 0 );
    }

  /**
   * Construct myself to be a copy of an existing iterator.
   * @param iterator The iterator to copy.
   */
  public ByteIterator( ByteIterator iterator )
    {
    buffer = iterator.buffer;
    original = iterator.original;
    index = iterator.index;
    }

  /**
   * Construct myself to be positioned at a particular index of a specific
   * array of bytes.
   * @param vector My associated byte[].
   * @param index My associated index.
   */
  public ByteIterator( byte[] vector, int index )
    {
    this( new ByteArray( vector ), index );
    }

  /**
   * Construct myself to be positioned at a particular index of a specific ByteArray.
   * @param vector My associated ByteArray.
   * @param index My associated index.
   */
  public ByteIterator( ByteArray vector, int index )
    {
    buffer = vector.array;
    original = vector;
    this.index = index;
    }

  /**
   * Construct myself to be positioned at a particular index of a specific ByteBuffer.
   * @param vector My associated ByteBuffer.
   * @param index My associated index.
   */
  public ByteIterator( ByteBuffer vector, int index )
    {
    buffer = vector.storage;
    original = vector;
    this.index = index;
    }

  /**
   * Return a clone of myself.
   */
  public Object clone()
    {
    return new ByteIterator( this );
    }

  /**
   * Return true if a specified object is the same kind of iterator as me
   * and is positioned at the same element.
   * @param object Any object.
   */
  public boolean equals( Object object )
    {
    return object instanceof ByteIterator && equals( (ByteIterator)object );
    }

  /**
   * Return true if iterator is positioned at the same element as me.
   * @param iterator The iterator to compare myself against.
   */
  public boolean equals( ByteIterator iterator )
    {
    return iterator.index == index && iterator.buffer == buffer;
    }

  /**
   * Return true if I'm before a specified iterator.
   * @param iterator The iterator to compare myself against.
   */
  public boolean less( RandomAccessIterator iterator )
    {
    return index < ( (ByteIterator)iterator ).index;
    }

  /**
   * Return true if I'm positioned at the first item of my input stream.
   */
  public boolean atBegin()
    {
    return index == 0;
    }

  /**
   * Return true if I'm positioned after the last item in my input stream.
   */
  public boolean atEnd()
    {
    return index == original.size();
    }

  /**
   * Return true if there are more elements in my input stream.
   */
  public boolean hasMoreElements()
    {
    return index < original.size();
    }

  /**
   * Advance by one.
   */
  public void advance()
    {
    ++index;
    }

  /**
   * Advance by a specified amount.
   * @param n The amount to advance.
   */
  public void advance( int n )
    {
    index += n;
    }

  /**
   * Retreat by one.
   */
  public void retreat()
    {
    --index;
    }

  /**
   * Retreat by a specified amount.
   * @param n The amount to retreat.
   */
  public void retreat( int n )
    {
    index -= n;
    }

  /**
   * Return the next element in my input stream.
   * @exception java.util.NoSuchElementException If I'm positioned at an invalid index.
   */
  public Object nextElement()
    {
    try
      {
      Object obj = get();
      advance();
      return obj;
      }
    catch ( IndexOutOfBoundsException ex )
      {
      throw new java.util.NoSuchElementException( "ByteIterator" );
      }
    }

  /**
   * Return the object at my current position.
   * @exception java.lang.ArrayIndexOutOfBoundsException If I'm positioned at an invalid index.
   */
  public Object get()
    {
    return get( 0 );
    }
  public byte getByte()
    {
    return getByte( 0 );
    }

  /**
   * Return the object that is a specified distance from my current position.
   * @param offset The offset from my current position.
   * @exception java.lang.ArrayIndexOutOfBoundsException If the adjusted index is invalid.
   */
  public Object get( int offset )
    {
    return new Byte( buffer[ index + offset ] );
    }
  public byte getByte( int offset )
    {
    return buffer[ index + offset ];
    }

  /**
   * Set the object at my current position to a specified value.
   * @param object The object to be written at my current position.
   * @exception java.lang.ArrayIndexOutOfBoundsException If I'm positioned at an invalid index.
   */
  public void put( Object object )
    {
    put( 0, object );
    }
  public void put( byte object )
    {
    put( 0, object );
    }

  /**
   * Write an object at a specified distance from my current position.
   * @param offset The offset from my current position.
   * @param object The object to write.
   * @exception java.lang.ArrayIndexOutOfBoundsException If the adjusted index is invalid.
   */
  public void put( int offset, Object object )
    {
    put( offset, ByteBuffer.asByte( object ) );
    }
  public void put( int offset, byte object )
    {
    buffer[ index + offset ] = object;
    }

  /**
   * Return the distance from myself to another iterator.
   * I should be before the specified iterator.
   * @param iterator The iterator to compare myself against.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public int distance( ForwardIterator iterator )
    {
    if ( !isCompatibleWith( iterator ) )
      throw new IllegalArgumentException( "iterators not compatible" );
    return ( (ByteIterator)iterator ).index - index;
    }

  /**
   * Return my current index.
   */
  public int index()
    {
    return index;
    }

  /**
   * Return my associated array.
   */
  public Container getContainer()
    {
    return original;
    }

  /**
   * Return true if both <CODE>iterator</CODE> and myself can be used
   * as a range.
   */
  public boolean isCompatibleWith( InputIterator iterator )
    {
    return iterator instanceof ByteIterator && buffer == ( (ByteIterator)iterator ).buffer;
    }

  static final long serialVersionUID = 4883976831804292945L;
  }
