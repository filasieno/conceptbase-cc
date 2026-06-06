// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.adapters;

import com.objectspace.jgl.*;
import java.util.Enumeration;

/**
 * FloatArray allows a native array of floats to be accessed like a JGL
 * Container.  It is particularly useful for applying generic algorithms 
 * such as Sorting.sort() to a native array.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class FloatArray extends ArrayAdapter
  {
  float array[];

  /**
   * Construct myself to refer to an empty array.
   */
  public FloatArray()
    {
    this( new float[ 0 ] );
    }

  /**
   * Construct myself to refer to an existing FloatArray.
   * @param array The FloatArray to copy.
   */
  public FloatArray( FloatArray array )
    {
    this( array.array );
    }

  /**
   * Construct myself to be a copy of an existing FloatBuffer.
   * @param array The FloatBuffer to copy.
   * @since JGL3.0
   */
  public FloatArray( FloatBuffer buffer )
    {
    this( buffer.get() );
    }

  /**
   * Construct myself to refer to a native Java array.
   * @param array The float[] to ape.
   */
  public FloatArray( float array[] )
    {
    this.array = array;
    }

  /**
   * Return a shallow copy of myself.
   */
  public synchronized Object clone()
    {
    return new FloatArray( this );
    }

  /**
   * Return a string that describes me.
   */
  public synchronized String toString()
    {
    return Algorithms.Printing.toString( this, "float[]" );
    }

  /**
   * Return true if I'm equal to a specified object.
   * @param object The object to compare myself against.
   * @return true if I'm equal to the specified object.
   */
  public boolean equals( Object object )
    {
    return 
      object instanceof FloatArray && equals( (FloatArray)object )
      || object instanceof FloatBuffer && equals( (FloatBuffer)object );
    }

  /**
   * Return true if I contain the same items in the same order as
   * another FloatArray.
   * @param array The FloatArray to compare myself against.
   * @return true if I'm equal to the specified object.
   */
  public boolean equals( FloatArray object )
    {
    return equals( object.array );
    }

  /**
   * Return true if I contain the same items in the same order as
   * another FloatBuffer.
   * @param buffer The FloatBuffer to compare myself against.
   * @since JGL3.0
   */
  public boolean equals( FloatBuffer buffer )
    {
    return equals( buffer.storage );
    }

  /**
   * Return true if I contain the same items in the same order as
   * a native array of floats.
   * @param array The array to compare myself against.
   * @since JGL3.0
   */
  public synchronized boolean equals( float array[] )
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
  public float[] get()
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
  public synchronized FloatIterator begin()
    {
    return new FloatIterator( this, 0 );
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
  public synchronized FloatIterator end()
    {
    return new FloatIterator( this, array.length );
    }

  /**
   * Return the integer at the specified index as a Float object.
   * @param index The index.
   */
  public Object at( int index )
    {
    return new Float( floatAt( index ) );
    }

  /**
   * Return the integer at the specified index as a Float object.
   * @param index The index.
   * @since JGL3.0
   */
  public synchronized float floatAt( int index )
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
    put( index, ( (Number)object ).floatValue() );
    }

  /**
   * Set the value of a specified index.
   * @param index The index.
   * @param object The float to place at the specified index.
   * @exception java.lang.IndexOutOfBoundsException if index is invalid.
   * @since JGL3.0
   */
  public synchronized void put( int index, float object )
    {
    array[ index ]  = object;
    }
 
  static final long serialVersionUID = 2024495121036254354L;
  }
