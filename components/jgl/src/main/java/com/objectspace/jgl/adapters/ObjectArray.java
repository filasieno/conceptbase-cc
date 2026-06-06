// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.adapters;

import com.objectspace.jgl.*;
import java.util.Enumeration;

/**
 * ObjectArray allows a native array of Objects to be accessed like a 
 * Container.  It is particularly useful for applying generic algorithms 
 * such as Sorting.sort() to a native array.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class ObjectArray extends ArrayAdapter
  {
  Object array[];

  /**
   * Construct myself to refer to an empty array.
   */
  public ObjectArray()
    {
    this( new Object[ 0 ] );
    }

  /**
   * Construct myself to refer to an existing ObjectArray.
   * @param array The ObjectArray to copy.
   */
  public ObjectArray( ObjectArray array )
    {
    this( array.array );
    }

  /**
   * Construct myself to be a copy of an existing Array.
   * @param array The Array to copy.
   * @since JGL3.0
   */
  public ObjectArray( Array array )
    {
    synchronized( array )
      {
      this.array = new Object[ array.size() ];
      array.copyTo( this.array );
      }
    }

  /**
   * Construct myself to refer to a native Java array.
   * @param array The Object[] to ape.
   * @since JGL3.0
   */
  public ObjectArray( Object array[] )
    {
    this.array = array;
    }

  /**
   * Return a shallow copy of myself.
   */
  public synchronized Object clone()
    {
    return new ObjectArray( this );
    }

  /**
   * Return a string that describes me.
   */
  public synchronized String toString()
    {
    return Algorithms.Printing.toString( this, "Object[]" );
    }

  /**
   * Return true if I'm equal to a specified object.
   * @param object The object to compare myself against.
   * @return true if I'm equal to the specified object.
   */
  public boolean equals( Object object )
    {
    return 
      ( object instanceof ObjectArray || object instanceof Array )
      && Algorithms.Comparing.equal( this, (Container)object );
    }

  /**
   * Return true if I contain the same items in the same order as
   * a native array of Objects.
   * @param array The array to compare myself against.
   * @since JGL3.0
   */
  public synchronized boolean equals( Object array[] )
    {
    synchronized( array )
      {
      if ( this.array.length != array.length )
        return false;

      int i = 0;
      while ( i < array.length )
        {
        if ( !( this.array[ i ].equals( array[ i ] ) ) )
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
  public Object[] get()
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
   * Return an Enumeration of my elements.
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
  public synchronized ObjectIterator begin()
    {
    return new ObjectIterator( this, 0 );
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
  public synchronized ObjectIterator end()
    {
    return new ObjectIterator( this, array.length );
    }

  /**
   * Return the object at the specified index.
   * @param index The index.
   */
  public synchronized Object at( int index )
    {
    return array[ index ];
    }

  /**
   * Set the object at a specified index.  The object must be a Integer
   * @param index The index.
   * @param object The object to place at the specified index.
   * @exception java.lang.IndexOutOfBoundsException if index is not in range.
   */
  public synchronized void put( int index, Object object )
    {
    array[ index ] = object;
    }

  static final long serialVersionUID = 8902585662275267473L;
  }
