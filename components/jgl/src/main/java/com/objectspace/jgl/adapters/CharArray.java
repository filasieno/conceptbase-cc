// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.adapters;

import com.objectspace.jgl.*;
import java.util.Enumeration;

/**
 * CharArray allows a native array of chars to be accessed like a JGL
 * Container.  It is particularly useful for applying generic algorithms 
 * such as Sorting.sort() to a native array.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class CharArray extends ArrayAdapter
  {
  char array[];

  /**
   * Construct myself to refer to an empty array.
   */
  public CharArray()
    {
    this( new char[ 0 ] );
    }

  /**
   * Construct myself to refer to an existing CharArray.
   * @param array The CharArray to copy.
   */
  public CharArray( CharArray array )
    {
    this( array.array );
    }

  /**
   * Construct myself to be a copy of an existing CharBuffer.
   * @param array The CharBuffer to copy.
   * @since JGL3.0
   */
  public CharArray( CharBuffer buffer )
    {
    this( buffer.get() );
    }

  /**
   * Construct myself to refer to a native Java array.
   * @param array The char[] to ape.
   */
  public CharArray( char array[] )
    {
    this.array = array;
    }

  /**
   * Return a shallow copy of myself.
   */
  public synchronized Object clone()
    {
    return new CharArray( this );
    }

  /**
   * Return a string that describes me.
   */
  public synchronized String toString()
    {
    return Algorithms.Printing.toString( this, "char[]" );
    }

  /**
   * Return true if I'm equal to a specified object.
   * @param object The object to compare myself against.
   * @return true if I'm equal to the specified object.
   */
  public boolean equals( Object object )
    {
    return 
      object instanceof CharArray && equals( (CharArray)object )
      || object instanceof CharBuffer && equals( (CharBuffer)object );
    }

  /**
   * Return true if I contain the same items in the same order as
   * another CharArray.
   * @param array The CharArray to compare myself against.
   * @return true if I'm equal to the specified object.
   */
  public boolean equals( CharArray object )
    {
    return equals( object.array );
    }

  /**
   * Return true if I contain the same items in the same order as
   * another CharBuffer.
   * @param buffer The CharBuffer to compare myself against.
   * @since JGL3.0
   */
  public boolean equals( CharBuffer buffer )
    {
    return equals( buffer.storage );
    }

  /**
   * Return true if I contain the same items in the same order as
   * a native array of chars.
   * @param array The array to compare myself against.
   * @since JGL3.0
   */
  public synchronized boolean equals( char array[] )
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
  public char[] get()
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
  public synchronized CharIterator begin()
    {
    return new CharIterator( this, 0 );
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
  public synchronized CharIterator end()
    {
    return new CharIterator( this, array.length );
    }

  /**
   * Return the integer at the specified index as a Char object.
   * @param index The index.
   */
  public Object at( int index )
    {
    return new Character( charAt( index ) );
    }

  /**
   * Return the integer at the specified index as a Char object.
   * @param index The index.
   * @since JGL3.0
   */
  public synchronized char charAt( int index )
    {
    return array[ index ];
    }

  /**
   * Set the object at a specified index.  The object must be a Character
   * @param index The index.
   * @param object The object to place at the specified index.
   * @exception java.lang.ClassCastException if object is not a Character
   * @exception java.lang.IndexOutOfBoundsException if index is invalid.
   */
  public void put( int index, Object object )
    {
    put( index, ( (Character)object ).charValue() );
    }

  /**
   * Set the value of a specified index.
   * @param index The index.
   * @param object The char to place at the specified index.
   * @exception java.lang.IndexOutOfBoundsException if index is invalid.
   * @since JGL3.0
   */
  public synchronized void put( int index, char object )
    {
    array[ index ]  = object;
    }

  static final long serialVersionUID = -7920180968357434958L;
  }
