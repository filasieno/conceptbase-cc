// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.io.Serializable;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.IOException;

/**
 * An SListIterator is a forward iterator that allows you to iterate through
 * the contents of an SList.
 * <p>
 * @see com.objectspace.jgl.ForwardIterator
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class SListIterator implements ForwardIterator, Serializable, Opaque
  {
  SList mySList;
  transient SList.SListNode myNode;

  /**
   * Construct myself to be an iterator with no associated data structure or position.
   */
  public SListIterator()
    {
    }

  /**
   * Construct myself to be positioned at a particular node in a specified list.
   * @param list My associated list.
   * @param node My associated node.
   */
  SListIterator( SList list, SList.SListNode node )
    {
    mySList = list;
    myNode = node;
    }

  /**
   * Construct myself to be a copy of an existing iterator.
   * @param iterator The iterator to copy.
   */
  public SListIterator( SListIterator iterator )
    {
    mySList = iterator.mySList;
    myNode = iterator.myNode;
    }

  /**
   * Return a clone of myself.
   */
  public Object clone()
    {
    return new SListIterator( this );
    }

  /**
   * Return true if a specified object is the same kind of iterator as me
   * and is positioned at the same element.
   * @param object Any object.
   */
  public boolean equals( Object object )
    {
    return object instanceof Opaque && myNode == ( (Opaque)object ).opaqueData();
    }

  /**
   * Return true if I'm positioned at the first item of my input stream.
   */
  public boolean atBegin()
    {
    return myNode == mySList.myHead;
    }

  /**
   * Return true if I'm positioned after the last item in my input stream.
   */
  public boolean atEnd()
    {
    return myNode == null;
    }

  /**
   * Return true if there are more elements in my input stream.
   */
  public boolean hasMoreElements()
    {
    return myNode != null;
    }

  /**
   * Advance by one.
   */
  public void advance()
    {
    myNode = myNode.next;
    }

  /**
   * Advance by a specified amount.
   * @param n The amount to advance.
   * @exception com.objectspace.jgl.InvalidOperationException If the parameter is less than zero.
   */
  public void advance( int n )
    {
    if ( n < 0 )
      throw new InvalidOperationException( "Attempt to advance a ForwardIterator in the wrong direction." );
    while ( n-- > 0 )
      myNode = myNode.next;
    }

  /**
   * Return the next element in my input stream.
   * @exception java.util.NoSuchElementException If I'm positioned at an invalid position.
   */
  public Object nextElement()
    {
    try
      {
      Object object = myNode.object;
      myNode = myNode.next;
      return object;
      }
    catch ( NullPointerException ex )
      {
      throw new java.util.NoSuchElementException( "SListIterator" );
      }
    }

  /**
   * Return the object at my current position.
   */
  public Object get()
    {
    return myNode.object;
    }

  /**
   * Return the object that is a specified distance from my current position.
   * @param offset The offset from my current position.
   * @exception com.objectspace.jgl.InvalidOperationException If the parameter is less than zero.
   */
  public Object get( int offset )
    {
    SListIterator i = new SListIterator( this );
    i.advance( offset );
    return i.get();
    }

  /**
   * Set the object at my current position to a specified value.
   * @param object The object to be written at my current position.
   */
  public void put( Object object )
    {
    myNode.object = object;
    }

  /**
   * Write an object at a specified distance from my current position.
   * @param offset The offset from my current position.
   * @param object The object to write.
   * @exception com.objectspace.jgl.InvalidOperationException If the parameter is less than zero.
   */
  public void put( int offset, Object object )
    {
    SListIterator i = new SListIterator( this );
    i.advance( offset );
    i.put( object );
    }

  /**
   * Return the distance from myself to another iterator.
   * I should be before the specified iterator.
   * @param iterator The iterator to compare myself against.
   */
  public int distance( ForwardIterator iterator )
    {
    return distance( myNode, (SList.SListNode)( (Opaque)iterator).opaqueData() );
    }

  /**
   * Return my current index.
   */
  public int index()
    {
    return distance( mySList.myHead, myNode );
    }

  private int distance( SList.SListNode from, SList.SListNode to )
    {
    int n = 0;

    while ( from != to )
      {
      ++n;
      from = from.next;
      }

    return n;
    }

  /**
   * Return my associated SList.
   */
  public Container getContainer()
    {
    return mySList;
    }

  /**
   * Return true if both <CODE>iterator</CODE> and myself can be used
   * as a range.
   */
  public boolean isCompatibleWith( InputIterator iterator )
    {
    return 
      iterator instanceof Opaque 
      && opaqueId() == ( (Opaque)iterator ).opaqueId();
    }

  /**
   * Should not be used directly.
   * @see com.objectspace.jgl.Opaque
   */
  public Object opaqueData()
    {
    return myNode;
    }

  /**
   * Should not be used directly.
   * @see com.objectspace.jgl.Opaque
   */
  public int opaqueId()
    {
    return System.identityHashCode( mySList );
    }

  private synchronized void writeObject( ObjectOutputStream stream ) throws IOException
    {
    stream.defaultWriteObject();
    stream.writeInt( index() );
    }

  private void readObject( ObjectInputStream stream ) throws IOException, ClassNotFoundException
    {
    stream.defaultReadObject();
    myNode = mySList.nodeAt( stream.readInt() );
    }

  static final long serialVersionUID = 8962846440793994417L;
  }
