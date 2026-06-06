// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.adapters;

import com.objectspace.jgl.*;
import java.io.Serializable;

/**
 * A BooleanIterator is a random access iterator that allows you to iterate through
 * the contents of a BooleanBuffer.
 * <p>
 * @see com.objectspace.jgl.RandomAccessIterator
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class BooleanIterator implements RandomAccessIterator, Serializable
  {
  /**
   * Return an iterator positioned at the first element of a particular array.
   * @param array The array whose first element I will be positioned at.
   */
  public static BooleanIterator begin( boolean[] array )
    {
    return new BooleanIterator( array, 0 );
    }

  /**
   * Return an iterator positioned immediately after the last element of a particular array.
   * @param array The array whose last element I will be positioned after.
   */
  public static BooleanIterator end( boolean[] array )
    {
    return new BooleanIterator( array, array.length );
    }

  byte offset; // set to 0xFF when original is an instance of BooleanArray
  int index;
  Sequence original;

  /**
   * Construct myself to be an iterator with no associated data structure or position.
   */
  public BooleanIterator()
    {
    this( new BooleanArray(), 0 );
    }

  /**
   * Construct myself to be a copy of an existing iterator.
   * @param iterator The iterator to copy.
   */
  public BooleanIterator( BooleanIterator iterator )
    {
    offset = iterator.offset;
    index = iterator.index;
    original = iterator.original;
    }

  BooleanIterator( boolean[] array, int index )
    {
    this( new BooleanArray( array ), index );
    }

  BooleanIterator( BooleanArray array, int index )
    {
    offset = (byte)0xFF;
    this.index = index;
    original = array;
    }

  /**
   * Construct myself to be positioned at a particular index of a specific BooleanBuffer.
   * @param vector My associated BooleanBuffer.
   * @param index My associated index.
   * @since JGL3.0
   */
  public BooleanIterator( BooleanBuffer vector, int index )
    {
    original = vector;
    this.index = index / 8;
    offset = (byte)( index % 8 );
    }

  /**
   * Return a clone of myself.
   */
  public Object clone()
    {
    return new BooleanIterator( this );
    }

  /**
   * Return true if a specified object is the same kind of iterator as me
   * and is positioned at the same element.
   * @param object Any object.
   */
  public boolean equals( Object object )
    {
    return object instanceof BooleanIterator && equals( (BooleanIterator)object );
    }

  /**
   * Return true if iterator is positioned at the same element as me.
   * @param iterator The iterator to compare myself against.
   */
  public boolean equals( BooleanIterator iterator )
    {
    return 
      index == iterator.index 
      && offset == iterator.offset 
      && isCompatibleWith( iterator );
    }

  /**
   * Return true if I'm before a specified iterator.
   * @param iterator The iterator to compare myself against.
   */
  public boolean less( RandomAccessIterator iterator )
    {
    if ( offset == (byte)0xFF && index == ( (BooleanIterator)iterator ).index )
      return offset < ( (BooleanIterator)iterator ).offset;
    return index < ( (BooleanIterator)iterator ).index;
    }

  /**
   * Return true if I'm positioned at the first item of my input stream.
   */
  public boolean atBegin()
    {
    return index == 0 && ( offset == (byte)0xFF || offset == 0 );
    }

  /**
   * Return true if I'm positioned after the last item in my input stream.
   */
  public boolean atEnd()
    {
    return offset == (byte)0xFF
      ? index == original.size()
      : equals( original.finish() );
    }

  /**
   * Return true if there are more elements in my input stream.
   */
  public boolean hasMoreElements()
    {
    return !atEnd();
    }

  /**
   * Advance by one.
   */
  public void advance()
    {
    if ( offset == (byte)0xFF )
      ++index;
    else
      if ( ++offset == 8 )
        {
        offset = 0;
        ++index;
        }
    }

  /**
   * Advance by a specified amount.
   * @param n The amount to advance.
   */
  public void advance( int n )
    {
    if ( offset == (byte)0xFF )
      index += n;
    else
      {
      int old = offset;
      offset = (byte)( n % 8 );
      index += n / 8;
      if ( old > offset )
        ++index;
      }
    }

  /**
   * Retreat by one.
   */
  public void retreat()
    {
    if ( offset == (byte)0xFF )
      --index;
    else
      if ( offset == 0 )
        {
        offset = 7;
        --index;
        }
      else
        --offset;
    }

  /**
   * Retreat by a specified amount.
   * @param n The amount to retreat.
   */
  public void retreat( int n )
    {
    if ( offset == (byte)0xFF )
      index -= n;
    else
      {
      int old = offset;
      offset = (byte)( ( offset + 8 - n % 8 ) % 8 );
      index += n / 8;
      if ( old < offset )
        ++index;
      }
    }

  /**
   * Return the next element in my input stream.
   * @exception java.util.NoSuchElementException If I'm positioned at an invalid index.
   */
  public Object nextElement()
    {
    try
      {
      Object object = get();
      advance();
      return object;
      }
    catch ( IndexOutOfBoundsException ex )
      {
      throw new java.util.NoSuchElementException( "BooleanIterator" );
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
   * Return the boolean at my current position.
   * @exception ArrayIndexOutOfBoundsException If I'm positioned at an invalid index.
   * @since JGL3.0
   */
  public boolean getBoolean()
    {
    return getBoolean( 0 );
    }

  /**
   * Return the object that is a specified distance from my current position.
   * @param offset The offset from my current position.
   * @exception ArrayIndexOutOfBoundsException If the adjusted index is invalid.
   */
  public Object get( int offset )
    {
    return new Boolean( getBoolean( offset ) );
    }

  /**
   * Return the boolean that is a specified distance from my current position.
   * @param offset The offset from my current position.
   * @exception ArrayIndexOutOfBoundsException If the adjusted index is invalid.
   * @since JGL3.0
   */
  public boolean getBoolean( int offset )
    {
    return original instanceof BooleanArray
      ? ( (BooleanArray)original ).booleanAt( index + offset )
      : ( ( (BooleanBuffer)original ).storage.byteAt( index ) & mask() ) > 0;
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
   * Set the boolean at my current position to a specified value.
   * @param object The value to be written at my current position.
   * @exception ArrayIndexOutOfBoundsException If I'm positioned at an invalid index.
   * @since JGL3.0
   */
  public void put( boolean object )
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
    put( offset, BooleanBuffer.asBoolean( object ) );
    }

  /**
   * Write a value at a specified distance from my current position.
   * @param offset The offset from my current position.
   * @param object The boolean to write.
   * @exception ArrayIndexOutOfBoundsException If the adjusted index is invalid.
   * @since JGL3.0
   */
  public void put( int offset, boolean object )
    {
    if ( original instanceof BooleanArray )
      ( (BooleanArray)original ).put( offset, object );
    else
      {
      ByteBuffer storage = ( (BooleanBuffer)original ).storage;
      byte b = storage.byteAt( index );
      if ( object )
        b |= mask();
      else
        b &= ~mask();
      storage.put( index, b );
      }
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
    return ( (BooleanIterator)iterator).index() - index();
    }

  /**
   * Return my current index.
   */
  public int index()
    {
    return offset == (byte)0xFF
      ? index
      : index * 8 + offset;
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
   * @since JGL3.0
   */
  public boolean isCompatibleWith( InputIterator iterator )
    {
    if ( iterator instanceof BooleanIterator )
      {
      BooleanIterator i = (BooleanIterator)iterator;
      if ( original instanceof BooleanArray )
        return 
          i.original instanceof BooleanArray
          && ( (BooleanArray)original ).array == ( (BooleanArray)i.original ).array;
      return 
        original instanceof BooleanBuffer
        && i.original instanceof BooleanBuffer
        && ( (BooleanBuffer)original ).storage == ( (BooleanBuffer)i.original ).storage;
      }
    return false;
    }

  final byte mask()
    {
    return (byte)( 1 << offset );
    }

  static final long serialVersionUID = 9093107050268453497L;
  }
