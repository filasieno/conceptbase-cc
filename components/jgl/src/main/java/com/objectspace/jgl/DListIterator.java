// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.io.Serializable;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.IOException;

/**
 * A DListIterator is a bidirectional iterator that allows you to iterate through
 * the contents of a DList.
 * <p>
 * @see com.objectspace.jgl.BidirectionalIterator
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class DListIterator implements BidirectionalIterator, Serializable, Opaque
  {
  DList myDList;
  transient DList.DListNode myNode;

  /**
   * Construct myself to be an iterator with no associated object structure or position.
   */
  public DListIterator()
    {
    }

  /**
   * Construct myself to be positioned at a particular node in a specified list.
   * @param list My associated list.
   * @param node My associated node.
   */
  DListIterator( DList list, DList.DListNode node )
    {
    myDList = list;
    myNode = node;
    }

  /**
   * Construct myself to be a copy of an existing iterator.
   * @param iterator The iterator to copy.
   */
  public DListIterator( DListIterator iterator )
    {
    myDList = iterator.myDList;
    myNode = iterator.myNode;
    }

  /**
   * Return a clone of myself.
   */
  public Object clone()
    {
    return new DListIterator( this );
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
    return myNode == myDList.myNode.next;
    }

  /**
   * Return true if I'm positioned after the last item in my input stream.
   */
  public boolean atEnd()
    {
    return myNode == myDList.myNode;
    }

  /**
   * Return true if there are more elements in my input stream.
   */
  public boolean hasMoreElements()
    {
    return myNode != myDList.myNode;
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
   */
  public void advance( int n )
    {
    myNode = nodeAt( n );
    }

  /**
   * Retreat by one.
   */
  public void retreat()
    {
    myNode = myNode.previous;
    }

  /**
   * Retreat by a specified amount.
   * @param n The amount to retreat.
   */
  public void retreat( int n )
    {
    myNode = nodeAt( -n );
    }

  /**
   * Return the next element in my input stream.
   * @exception java.util.NoSuchElementException If I'm positioned at an invalid position.
   */
  public Object nextElement()
    {
    if ( myNode == myNode.next )
      throw new java.util.NoSuchElementException( "DListIterator" );

    Object object = myNode.object;
    myNode = myNode.next;
    return object;
    }

  /**
   * Return the object at my current position.
   */
  public Object get()
    {
    return myNode.object;
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
   * Return the object that is a specified distance from my current position.
   * @param offset The offset from my current position.
   */
  public Object get( int offset )
    {
    return nodeAt( offset ).object;
    }

  /**
   * Write an object at a specified distance from my current position.
   * @param offset The offset from my current position.
   * @param object The object to write.
   */
  public void put( int offset, Object object )
    {
    nodeAt( offset ).object = object;
    }

  /**
   * Return the distance from myself to another iterator.
   * I should be before the specified iterator.
   * @param iterator The iterator to compare myself against.
   */
  public int distance( ForwardIterator iterator )
    {
    return distance( myNode, (DList.DListNode)( (Opaque)iterator).opaqueData() );
    }

  /**
   * Return my current index.
   */
  public int index()
    {
    return distance( myDList.myNode.next, myNode );
    }

  private int distance( DList.DListNode from, DList.DListNode to )
    {
    int n = 0;

    while ( from != to )
      {
      ++n;
      from = from.next;
      }

    return n;
    }

  private DList.DListNode nodeAt( int offset )
    {
    DList.DListNode node = myNode;

    if ( offset >= 0 )
      while ( offset-- > 0 )
        node = node.next;
    else
      while ( offset++ < 0 )
        node = node.previous;

    return node;
    }

  /**
   * Return my associated container.
   */
  public Container getContainer()
    {
    return myDList;
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
    return System.identityHashCode( myDList );
    }

  private synchronized void writeObject( ObjectOutputStream stream ) throws IOException
    {
    stream.defaultWriteObject();
    stream.writeInt( index() );
    }

  private void readObject( ObjectInputStream stream ) throws IOException, ClassNotFoundException
    {
    stream.defaultReadObject();
    myNode = myDList.nodeAt( stream.readInt() );
    }

  static final long serialVersionUID = 6859136066046499203L;
  }
