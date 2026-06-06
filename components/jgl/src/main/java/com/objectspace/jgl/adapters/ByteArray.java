// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.adapters;

import com.objectspace.jgl.*;
import java.util.Enumeration;

/**
 * ByteArray allows a native array of bytes to be accessed like a JGL
 * Container.  It is particularly useful for applying generic algorithms 
 * such as Sorting.sort() to a native array.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class ByteArray extends ArrayAdapter
  {
  byte array[];

  /**
   * Construct myself to refer to an empty array.
   */
  public ByteArray()
    {
    this( new byte[ 0 ] );
    }

  /**
   * Construct myself to refer to an existing ByteArray.
   * @param array The ByteArray to copy.
   */
  public ByteArray( ByteArray array )
    {
    this( array.array );
    }

  /**
   * Construct myself to be a copy of an existing ByteBuffer.
   * @param array The ByteBuffer to copy.
   * @since JGL3.0
   */
  public ByteArray( ByteBuffer buffer )
    {
    this( buffer.get() );
    }

  /**
   * Construct myself to refer to a native Java array.
   * @param array The byte[] to ape.
   */
  public ByteArray( byte array[] )
    {
    this.array = array;
    }

  /**
   * Return a shallow copy of myself.
   */
  public synchronized Object clone()
    {
    return new ByteArray( this );
    }

  /**
   * Return a string that describes me.
   */
  public synchronized String toString()
    {
    return Algorithms.Printing.toString( this, "byte[]" );
    }

  /**
   * Return true if I'm equal to a specified object.
   * @param object The object to compare myself against.
   * @return true if I'm equal to the specified object.
   */
  public boolean equals( Object object )
    {
    return 
      object instanceof ByteArray && equals( (ByteArray)object )
      || object instanceof ByteBuffer && equals( (ByteBuffer)object );
    }

  /**
   * Return true if I contain the same items in the same order as
   * another ByteArray.
   * @param array The ByteArray to compare myself against.
   * @return true if I'm equal to the specified object.
   */
  public boolean equals( ByteArray object )
    {
    return equals( object.array );
    }

  /**
   * Return true if I contain the same items in the same order as
   * another ByteBuffer.
   * @param buffer The ByteBuffer to compare myself against.
   * @since JGL3.0
   */
  public boolean equals( ByteBuffer buffer )
    {
    return equals( buffer.storage );
    }

  /**
   * Return true if I contain the same items in the same order as
   * a native array of bytes.
   * @param array The array to compare myself against.
   * @since JGL3.0
   */
  public synchronized boolean equals( byte array[] )
    {
    synchronized( array )
      {
      if ( this.array.length != array.length )
        return false;

      int i = 0;
      while ( i < array.length )
        {
        if ( this.array[ i ] != array[ i ] )
          return false;
        ++i;
        }
      }
    return true;
    }

  /**
   * Retrieve the underlying primitive array.
   * @since JGL3.0
   */
  public byte[] get()
    {
    return array;
    }

  /**
   * Return the number of objects that I contain.
   */
  public int size()
    {
    return array.length;
    }

  /**
   * Return the maximum number of objects that I can contain.
   */
  public int maxSize()
    {
    return array.length;
    }

  /**
   * Return an Enumeration of my components.
   */
  public Enumeration elements()
    {
    return begin();
    }

  /**
   * Return an iterator positioned at my first item.
   */
  public ForwardIterator start()
    {
    return begin();
    }

  /**
   * Return an iterator positioned at my first item.
   * @since JGL3.0
   */
  public synchronized ByteIterator begin()
    {
    return new ByteIterator( this, 0 );
    }

  /**
   * Return an iterator positioned immediately after my last item.
   */
  public ForwardIterator finish()
    {
    return end();
    }

  /**
   * Return an iterator positioned immediately after my last item.
   * @since JGL3.0
   */
  public synchronized ByteIterator end()
    {
    return new ByteIterator( this, array.length );
    }

  /**
   * Return the integer at the specified index as a Byte object.
   * @param index The index.
   */
  public Object at( int index )
    {
    return new Byte( byteAt( index ) );
    }

  /**
   * Return the integer at the specified index as a Byte object.
   * @param index The index.
   * @since JGL3.0
   */
  public synchronized byte byteAt( int index )
    {
    return array[ index ];
    }

  /**
   * Set the object at a specified index.  The object must be a Number
   * @param index The index.
   * @param object The object to place at the specified index.
   * @exception java.lang.ClassCastException if object is not a Number
   * @exception java.lang.IndexOutOfBoundsException if index is invalid.
   */
  public void put( int index, Object object )
    {
    put( index, ( (Number)object ).byteValue() );
    }

  /**
   * Set the value of a specified index.
   * @param index The index.
   * @param object The byte to place at the specified index.
   * @exception java.lang.IndexOutOfBoundsException if index is invalid.
   * @since JGL3.0
   */
  public synchronized void put( int index, byte object )
    {
    array[ index ]  = object;
    }

  static final long serialVersionUID = -6994357424699500642L;
  }
