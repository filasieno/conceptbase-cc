// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.adapters;

import com.objectspace.jgl.*;
import java.io.Serializable;

/**
 * A FloatIterator is a random access iterator that allows you to iterate 
 * through the contents of a FloatBuffer, FloatArray, or float[]..
 * <p>
 * @see com.objectspace.jgl.RandomAccessIterator
 * @see com.objectspace.jgl.adapters.FloatArray
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class FloatIterator implements RandomAccessIterator, Serializable
  {
  /**
   * Return an iterator positioned at the first element of a particular array.
   * @param array The array whose first element I will be positioned at.
   */
  public static FloatIterator begin( float[] array )
    {
    return new FloatIterator( array, 0 );
    }

  /**
   * Return an iterator positioned immediately after the last element of a particular array.
   * @param array The array whose last element I will be positioned after.
   */
  public static FloatIterator end( float[] array )
    {
    return new FloatIterator( array, array.length );
    }

  float buffer[];
  Container original;
  int index;

  /**
   * Construct myself to be an iterator with no associated data structure or position.
   */
  public FloatIterator()
    {
    this( new FloatArray(), 0 );
    }

  /**
   * Construct myself to be a copy of an existing iterator.
   * @param iterator The iterator to copy.
   */
  public FloatIterator( FloatIterator iterator )
    {
    buffer = iterator.buffer;
    original = iterator.original;
    index = iterator.index;
    }

  /**
   * Construct myself to be positioned at a particular index of a specific
   * array of floats.
   * @param vector My associated float[].
   * @param index My associated index.
   */
  public FloatIterator( float[] vector, int index )
    {
    this( new FloatArray( vector ), index );
    }

  /**
   * Construct myself to be positioned at a particular index of a specific FloatArray.
   * @param vector My associated FloatArray.
   * @param index My associated index.
   */
  public FloatIterator( FloatArray vector, int index )
    {
    buffer = vector.array;
    original = vector;
    this.index = index;
    }

  /**
   * Construct myself to be positioned at a particular index of a specific FloatBuffer.
   * @param vector My associated FloatBuffer.
   * @param index My associated index.
   */
  public FloatIterator( FloatBuffer vector, int index )
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
    return new FloatIterator( this );
    }

  /**
   * Return true if a specified object is the same kind of iterator as me
   * and is positioned at the same element.
   * @param object Any object.
   */
  public boolean equals( Object object )
    {
    return object instanceof FloatIterator && equals( (FloatIterator)object );
    }

  /**
   * Return true if iterator is positioned at the same element as me.
   * @param iterator The iterator to compare myself against.
   */
  public boolean equals( FloatIterator iterator )
    {
    return iterator.index == index && iterator.buffer == buffer;
    }

  /**
   * Return true if I'm before a specified iterator.
   * @param iterator The iterator to compare myself against.
   */
  public boolean less( RandomAccessIterator iterator )
    {
    return index < ( (FloatIterator)iterator ).index;
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
      throw new java.util.NoSuchElementException( "FloatIterator" );
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
  public float getFloat()
    {
    return getFloat( 0 );
    }

  /**
   * Return the object that is a specified distance from my current position.
   * @param offset The offset from my current position.
   * @exception java.lang.ArrayIndexOutOfBoundsException If the adjusted index is invalid.
   */
  public Object get( int offset )
    {
    return new Float( buffer[ index + offset ] );
    }
  public float getFloat( int offset )
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
  public void put( float object )
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
    put( offset, FloatBuffer.asFloat( object ) );
    }
  public void put( int offset, float object )
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
    return ( (FloatIterator)iterator ).index - index;
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
    return iterator instanceof FloatIterator && buffer == ( (FloatIterator)iterator ).buffer;
    }

  static final long serialVersionUID = -4831335176103843922L;
  }
