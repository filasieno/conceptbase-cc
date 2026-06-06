// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.adapters;

import com.objectspace.jgl.*;
import java.util.Enumeration;

/**
 * VectorArray allows a java.util.Vector to be accessed like a Container.
 * It is particularly useful for applying generic algorithms such as 
 * Sorting.sort() to a java.util.Vector.
 * <p>
 * @see java.util.Vector
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class VectorArray extends ArrayAdapter
  {
  java.util.Vector array;

  /**
   * Construct myself to refer to an empty array.
   */
  public VectorArray()
    {
    this( new java.util.Vector() );
    }

  /**
   * Construct myself to refer to a java.util.Vector.
   * @param array The Vector to ape.
   */
  public VectorArray( java.util.Vector vector )
    {
    synchronized( vector )
      {
      array = vector;
      }
    }

  /**
   * Construct myself to refer to an existing VectorArray.
   * @param array The VectorArray to copy.
   */
  public VectorArray( VectorArray vector )
    {
    this( vector.array );
    }

  /**
   * Return a shallow copy of myself.
   */
  public synchronized Object clone()
    {
    return new VectorArray( this );
    }

  /**
   * Return a string that describes me.
   */
  public synchronized String toString()
    {
    return array.toString();
    }

  /**
   * Return true if I'm equal to a specified object.
   * @param object The object to compare myself against.
   * @return true if I'm equal to the specified object.
   */
  public boolean equals( Object object )
    {
    return 
      ( object instanceof VectorArray && array.equals( ( (VectorArray)object ).array ) )
      || ( object instanceof java.util.Vector && array.equals( object ) );
    }

  /**
   * Retrieve the underlying Vector.
   * @since JGL3.0
   */
  public java.util.Vector get()
    {
    return array;
    }

  /**
   * Return the number of objects that I contain.
   */
  public int size()
    {
    return array.size();
    }

  /**
   * Return the maximum number of objects that I can contain.
   */
  public int maxSize()
    {
    return Integer.MAX_VALUE;
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
  public synchronized VectorIterator begin()
    {
    return new VectorIterator( this, 0 );
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
  public synchronized VectorIterator end()
    {
    return new VectorIterator( this, array.size() );
    }

  /**
   * Return the object at the specified index.
   * @param index The index.
   */
  public synchronized Object at( int index )
    {
    return array.elementAt( index );
    }

  /**
   * Set the object at a specified index.  The object must be a Integer
   * @param index The index.
   * @param object The object to place at the specified index.
   * @exception java.lang.IndexOutOfBoundsException if index is not in range.
   */
  public synchronized void put( int index, Object object )
    {
    array.setElementAt( object, index );
    }

  /**
   * Remove all of my objects.
   */
  public void clear()
    {
    array.removeAllElements();
    }

  /**
   * Add an object to myself.
   */
  public synchronized Object add( Object object )
    {
    array.addElement( object );
    return null;
    }

  /**
   * Insert an object in front of my first element.
   * @param object The object to insert.
   */
  public synchronized void pushFront( Object object )
    {
    array.insertElementAt( object, 0 );
    }

  /**
   * Remove and return my first element.
   */
  public synchronized Object popFront()
    {
    Object r = array.firstElement();
    array.removeElementAt( 0 );
    return r;
    }

  /**
   * Add an object at my end.
   * @param object The object to add.
   */
  public void pushBack( Object object )
    {
    add( object );
    }

  /**
   * Remove and return my last element.
   */
  public synchronized Object popBack()
    {
    Object r = array.lastElement();
    array.removeElementAt( array.size() - 1 );
    return r;
    }

  /**
   * Remove all elements that match a specified object and return the number of
   * objects that were removed.
   * @param object The object to remove.
   * @return The number of objects removed.
   */
  public synchronized int remove( Object object )
    {
    int count = 0;
    while ( array.removeElement( object ) )
      ++count;
    return count;
    }

  /**
   * Remove at most a given number of elements that match a specified object and return the number of
   * objects that were removed.
   * @param object The object to remove.
   * @param count The maximum number of objects to remove.
   * @return The number of objects removed.
   */
  public synchronized int remove( Object object, int count )
    {
    int c = 0;
    while ( count > 0 && array.removeElement( object ) )
      {
      ++c;
      --count;
      }
    return c;
    }

  /**
   * Remove all elements within a specified range that match a particular object
   * and return the number of objects that were removed.
   * @param first The index of the first object to remove.
   * @param last The index of the last object to remove.
   * @param object The object to remove.
   * @return The number of objects removed.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public synchronized int remove( int first, int last, Object object )
    {
    if ( ( first < 0 ) || ( last > array.size() - 1 ) )
      throw new IndexOutOfBoundsException( "index out of range for this Vector." );

    int count = 0;
    int index = first;

    for ( int i = first; i < last; ++i )
      {
      if ( ( array.elementAt( index ) ).equals( object ) )
        {
        array.removeElementAt( index );
        ++count;
        }
      else
        {
        ++index;
        }
      }

    return count;
    }
  
  static final long serialVersionUID = -7811353276265744416L;
  }
