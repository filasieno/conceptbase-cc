// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.adapters;

import com.objectspace.jgl.*;
import java.util.Vector;
import java.io.Serializable;

/**
 * A VectorIterator is a random access iterator that allows you to iterate 
 * through the contents of a java.util.Vector.
 * <p>
 * @see com.objectspace.jgl.RandomAccessIterator
 * @see java.util.Vector;
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class VectorIterator implements RandomAccessIterator, Serializable
  {
  /**
   * Return an iterator positioned at the first element of a particular array.
   * @param array The array whose first element I will be positioned at.
   */
  public static VectorIterator begin( Vector array )
    {
    return new VectorIterator( array, 0 );
    }

  /**
   * Return an iterator positioned immediately after the last element of a particular array.
   * @param array The array whose last element I will be positioned after.
   */
  public static VectorIterator end( Vector array )
    {
    return new VectorIterator( array, array.size() );
    }

  VectorArray buffer;
  int index;

  /**
   * Construct myself to be an iterator with no associated data structure or position.
   */
  public VectorIterator()
    {
    this( new Vector(), 0 );
    }

  /**
   * Construct myself to be a copy of an existing iterator.
   * @param iterator The iterator to copy.
   */
  public VectorIterator( VectorIterator iterator )
    {
    buffer = iterator.buffer;
    index = iterator.index;
    }

  /**
   * Construct myself to be positioned at a particular index of a specific Vector.
   * @param vector My associated Vector.
   * @param index My associated index.
   */
  public VectorIterator( java.util.Vector vector, int index )
    {
    this( new VectorArray( vector ), index );
    }

  /**
   * Construct myself to be positioned at a particular index of a specific array.
   * @param array My associated VectorArray.
   * @param index My associated index.
   */
  public VectorIterator( VectorArray array, int index )
    {
    buffer = array;
    this.index = index;
    }

  /**
   * Return a clone of myself.
   */
  public Object clone()
    {
    return new VectorIterator( this );
    }

  /**
   * Return true if a specified object is the same kind of iterator as me
   * and is positioned at the same element.
   * @param object Any object.
   */
  public boolean equals( Object object )
    {
    return object instanceof VectorIterator && equals( (VectorIterator)object );
    }

  /**
   * Return true if iterator is positioned at the same element as me.
   * @param iterator The iterator to compare myself against.
   */
  public boolean equals( VectorIterator iterator )
    {
    return iterator.index == index && iterator.buffer == buffer;
    }

  /**
   * Return true if I'm before a specified iterator.
   * @param iterator The iterator to compare myself against.
   */
  public boolean less( RandomAccessIterator iterator )
    {
    return index < ( (VectorIterator)iterator ).index;
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
    return index == buffer.array.size();
    }

  /**
   * Return true if there are more elements in my input stream.
   */
  public boolean hasMoreElements()
    {
    return index < buffer.array.size();
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
      throw new java.util.NoSuchElementException( "VectorIterator" );
      }
    }

  /**
   * Return the object at my current position.
   * @exception ArrayIndexOutOfBoundsException If I'm positioned at an invalid index.
   */
  public Object get()
    {
    return get( 0 );
    }

  /**
   * Return the object that is a specified distance from my current position.
   * @param offset The offset from my current position.
   * @exception ArrayIndexOutOfBoundsException If the adjusted index is invalid.
   */
  public Object get( int offset )
    {
    return buffer.array.elementAt( index + offset );
    }

  /**
   * Set the object at my current position to a specified value.
   * @param object The object to be written at my current position.
   * @exception ArrayIndexOutOfBoundsException If I'm positioned at an invalid index.
   */
  public void put( Object object )
    {
    put( 0, object );
    }

  /**
   * Write an object at a specified distance from my current position.
   * @param offset The offset from my current position.
   * @param object The object to write.
   * @exception ArrayIndexOutOfBoundsException If the adjusted index is invalid.
   */
  public void put( int offset, Object object )
    {
    buffer.array.setElementAt( object, index + offset );
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
    return ( (VectorIterator)iterator ).index - index;
    }

  /**
   * Return my current index.
   */
  public int index()
    {
    return index;
    }

  /**
   * Return a VectorArray for my associated Container since java.util.Vector
   * isn't in the JGL hierarchy (but should be <CODE>;-)</CODE>).
   */
  public Container getContainer()
    {
    return buffer;
    }

  /**
   * Return true if both <CODE>iterator</CODE> and myself can be used
   * as a range.
   */
  public boolean isCompatibleWith( InputIterator iterator )
    {
    return iterator instanceof VectorIterator && buffer.array == ( (VectorIterator)iterator ).buffer.array;
    }

  static final long serialVersionUID = 6819025880408038288L;
  }
