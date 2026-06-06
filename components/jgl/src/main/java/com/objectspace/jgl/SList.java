// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.util.Enumeration;
import java.io.Serializable;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.IOException;

/**
 * An SList is a sequential container that is optimized for insertion and erasure at
 * its extremities.
 * <p>
 * An SList is useful when the order of items and fast insertion/erasure at extremeties is
 * important.
 * <p>
 * An SList is implemented as a singly linked list in which every node in the list
 * has a pointer to the next node.
 * <p>
 * Insertion does not affect iterators or references.
 * <p>
 * Removal only invalidates the iterators and references to the removed elements.
 * <p>
 * @see com.objectspace.jgl.Sequence
 * @see com.objectspace.jgl.examples.SListExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class SList implements Sequence
  {
  transient SListNode myHead;
  transient SListNode myTail;
  transient int myLength;

  /**
   * Construct myself to be an empty SList.
   */
  public SList()
    {
    }

  /**
   * Construct myself to contain a specified number of null elements.
   * @param size The number of elements to contain.
   * @exception java.lang.IllegalArgumentException If the specified size is negative.
   */
  public SList( int size )
    {
    while ( --size >= 0 )
      add( null );
    }

  /**
   * Construct myself to contain a specified number of elements set to
   * a particular object.
   * @param size The number of elements to contain.
   * @param object The initial value of each element.
   * @exception java.lang.IllegalArgumentException If the specified size is negative.
   */
  public SList( int size, Object object )
    {
    while ( --size >= 0 )
      add( object );
    }

  /**
   * Construct myself to be a shallow copy of an existing SList.
   * @param list The SList to copy.
   */
  public SList( SList list )
    {
    copy( list );
    }

  /**
   * Return a shallow copy of myself.
   */
  public synchronized Object clone()
    {
    return new SList( this );
    }

  /**
   * Return true if I'm equal to another object.
   * @param object The object to compare myself against.
   */
  public boolean equals( Object object )
    {
    return object instanceof SList && equals( (SList)object );
    }

  /**
   * Return true if I contain the same items in the same order as
   * another SList. Use equals() to compare the individual elements.
   * @param list The SList to compare myself against.
   */
  public synchronized boolean equals( SList list )
    {
    synchronized( list )
      {
      return Algos.Comparing.equal( this, list );
      }
    }

  /**
   * Return my hash code for support of hashing containers
   */
  public synchronized int hashCode()
    {
    return Algos.Hashing.orderedHash( begin(), myLength );
    }

  /**
   * Return a string that describes me.
   */
  public synchronized String toString()
    {
    return Algos.Printing.toString( this, "SList" );
    }

  /**
   * Return an iterator positioned at my first item.
   */
  public synchronized SListIterator begin()
    {
    return new SListIterator( this, myHead );
    }

  /**
   * Return an iterator positioned immediately after my last item.
   */
  public synchronized SListIterator end()
    {
    return new SListIterator( this, null );
    }

  /**
   * Return an Enumeration to my components.
   */
  public synchronized Enumeration elements()
    {
    return new SListIterator( this, myHead );
    }

  /**
   * Return an iterator positioned at my first item.
   */
  public ForwardIterator start()
    {
    return begin();
    }

  /**
   * Return an iterator positioned immediately afer my last item.
   */
  public ForwardIterator finish()
    {
    return end();
    }

  /**
   * Become a shallow copy of an existing SList.
   * @param list The SList that I shall become a shallow copy of.
   */
  public synchronized void copy( SList list )
    {
    if ( this == list )
      return;

    synchronized( list )
      {
      myHead = null;
      myTail = null;

      for ( SListNode node = list.myHead; node != null; node = node.next )
        {
        SListNode newNode = new SListNode();
        newNode.object = node.object;

        if ( myTail == null )
          myHead = newNode;
        else
          myTail.next = newNode;

        myTail = newNode;
        }

      myLength = list.myLength;
      }
    }

  /**
   * Return true if I contain no entries.
   */
  public boolean isEmpty()
    {
    return myLength == 0;
    }

  /**
   * Return the number of entries that I contain.
   */
  public int size()
    {
    return myLength;
    }

  /**
   * Return the maximum number of entries that I can contain.
   */
  public int maxSize()
    {
    return Integer.MAX_VALUE;
    }

  /**
   * Return the element at the specified index.
   * @param index The index.
   * @exception java.lang.IndexOutOfBoundsException If the index is not valid.
   */
  public synchronized Object at( int index )
    {
    if ( index < 0 || index >= myLength )
      throw new IndexOutOfBoundsException( "Attempt to access index " + index + " when valid range is 0.." + (myLength - 1) );

    SListNode node = myHead;

    while ( index-- > 0 )
      node = node.next;

    return node.object;
    }

  /**
   * Set the element at the specified index to a particular object.
   * @param index The index.
   * @param object The object.
   * @exception java.lang.IndexOutOfBoundsException If the index is not valid.
   */
  public synchronized void put( int index, Object object )
    {
    if ( index < 0 || index >= myLength )
      throw new IndexOutOfBoundsException( "Attempt to access index " + index + " when valid range is 0.." + (myLength - 1) );

    SListNode node = myHead;

    while ( index-- > 0 )
      node = node.next;

    node.object = object;
    }

  /**
   * Insert an object at a particular position and return an iterator
   * positioned at the new element.
   * @param pos An iterator positioned at the element that the object will be inserted immediately before.
   * @param object The object to insert.
   */
  public synchronized SListIterator insert( SListIterator pos, Object object )
    {
    return new SListIterator( this, insert( pos.myNode, object ) );
    }

  /**
   * Insert an object at a particular index.
   * @param index The index of the element that the object will be inserted immediately before.
   * @param object The object to insert.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized void insert( int index, Object object )
    {
    if ( index > myLength || ( myLength == 0 && index > 0 ) )
      throw new IndexOutOfBoundsException( "Attempt to insert at index " + index + " when valid range is 0.." + myLength );

    if ( myLength == 0 )
      pushFront( object );
    else
      insert( nodeAt( index ), object );
    }

  /**
   * Insert multiple objects at a particular position.
   * @param pos An iterator positioned at the element that the objects will be inserted immediately before.
   * @param n The number of objects to insert.
   * @param object The object to insert.
   */
  public synchronized void insert( SListIterator pos, int n, Object object )
    {
    insert( pos.myNode, n, object );
    }

  /**
   * Insert multiple objects at a particular index.
   * @param index The index of the element that the objects will be inserted immediately before.
   * @param n The number of objects to insert.
   * @param object The object to insert.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized void insert( int index, int n, Object object )
    {
    if ( index > myLength || ( myLength == 0 && index > 0 ) )
      throw new IndexOutOfBoundsException( "Attempt to insert at index " + index + " when valid range is 0.." + myLength );

    if ( myLength == 0 )
      {
      pushFront( object );
      --n;
      }

    insert( nodeAt( index ), n, object );
    }

  /**
   * Insert a sequence of objects at a particular location.
   * @param pos The location of the element that the objects will be inserted immediately before.
   * @param first An iterator positioned at the first element to insert.
   * @param last An iterator positioned immediately after the last element to insert.
   */
  public synchronized void insert( SListIterator pos, InputIterator first, InputIterator last )
    {
    InputIterator firstx = (InputIterator) first.clone();

    while ( !firstx.equals( last ) )
      insert( pos, firstx.nextElement() );
    }

  /**
   * Return my last item.
   * @exception com.objectspace.jgl.InvalidOperationException If the SList is empty.
   */
  public synchronized Object back()
    {
    if ( myLength == 0 )
      throw new InvalidOperationException( "SList is empty" );

    return myTail.object;
    }

  /**
   * Return my first item.
   * @exception com.objectspace.jgl.InvalidOperationException If the SList is empty.
   */
  public synchronized Object front()
    {
    if ( myLength == 0 )
      throw new InvalidOperationException( "SList is empty" );

    return myHead.object;
    }

  /**
   * Remove all of my elements.
   */
  public synchronized void clear()
    {
    myHead = null;
    myTail = null;
    myLength = 0;
    }

  /**
   * Remove my last element.
   * @exception com.objectspace.jgl.InvalidOperationException If the SList is empty.
   */
  public synchronized Object popBack()
    {
    if ( myLength == 0 )
      throw new InvalidOperationException( "SList is empty" );

    SListNode previous = null;

    for ( SListNode node = myHead; node != myTail; node = node.next )
      previous = node;

    Object r;
    if ( previous == null )
      {
      r = myHead.object;
      myHead = null;
      }
    else
      {
      r = previous.next.object;
      previous.next = null;
      }

    myTail = previous;
    --myLength;
    return r;
    }

  /**
   * Insert an object in front of my first element.
   * @param object The object to insert.
   */
  public synchronized void pushFront( Object object )
    {
    SListNode node = new SListNode();
    node.object = object;
    node.next = myHead;
    myHead = node;

    if ( ++myLength == 1 )
      myTail = node;
    }

  /**
   * Remove my first element.
   * @exception com.objectspace.jgl.InvalidOperationException If the SList is empty.
   */
  public synchronized Object popFront()
    {
    if ( myLength == 0 )
      throw new InvalidOperationException( "Slist is empty" );

    Object r = myHead.object;
    myHead = myHead.next;

    if ( --myLength == 0 )
      myTail = null;

    return r;
    }

  /**
   * Add an object after my last element.
   * This function is a synonym for pushBack().
   * @param object The object to add.
   */
  public synchronized Object add( Object object )
    {
    SListNode node = new SListNode();
    node.object = object;

    if ( ++myLength == 1 )
      myHead = node;
    else
      myTail.next = node;

    myTail = node;
    return null;
    }

  /**
   * Add an object after my last element.
   * @param The object to add.
   */
  public void pushBack( Object object )
    {
    add( object );
    }

  /**
   * Swap my contents with another SList.
   * @param list The SList that I will swap my contents with.
   */
  public synchronized void swap( SList list )
    {
    synchronized( list )
      {
      SListNode tmpHead = myHead;
      myHead = list.myHead;
      list.myHead = tmpHead;

      SListNode tmpTail = myTail;
      myTail = list.myTail;
      list.myTail = tmpTail;

      int tmpLength = myLength;
      myLength = list.myLength;
      list.myLength = tmpLength;
      }
    }

  /**
   * Remove all elements that match a particular object and return the numbers of
   * objects that were removed.
   * @param object The object to remove.
   */
  public synchronized int remove( Object object )
    {
    return remove( myHead, null, object, myLength );
    }

  /**
   * Remove at most a given number of elements that match a particular object and return the number of
   * objects that were removed.
   * @param object The object to remove.
   * @param count The maximum number of objects to remove.
   */
  public synchronized int remove( Object object, int count )
    {
    return remove( myHead, null, object, count );
    }

  /**
   * Remove all elements within a specified range that match a particular object
   * and return the number of objects that were removed.
   * @param first An Enumeration positioned at the first object to remove.
   * @param last An Enumeration positioned immediately after the last object to remove.
   * @param object The object to remove.
   * @exception IllegalArgumentException is the Enumeration isn't a
   * SListIterator for this SList object.
   */
  public synchronized int remove( Enumeration first, Enumeration last, Object object )
    {
    if ( ( ! (first instanceof SListIterator) ) ||
        ( ! (last instanceof SListIterator) ) )
      throw new IllegalArgumentException( "Enumeration not a SListIterator" );

    if ( ( ((SListIterator)first).mySList != this ) ||
        ( ((SListIterator)last).mySList != this ) )
      throw new IllegalArgumentException( "Enumeration not for this SList" );

    SListIterator begin = (SListIterator)first;
    SListIterator end = (SListIterator)last;
    return remove( begin.myNode, end.myNode, object, myLength );
    }

  /**
   * Remove all elements within a specified range that match a particular object
   * and return the number of objects that were removed.
   * @param first The index of the first object to remove.
   * @param last The index of last object to remove.
   * @param object The object to remove.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public synchronized int remove( int first, int last, Object object )
    {
    if ( last < first )
      return 0;

    checkRange( first, last );
    return remove( nodeAt( first ), nodeAt( last + 1 ), object, myLength );
    }

  /**
   * Replace all elements that match a particular object with a new value and return
   * the number of objects that were replaced.
   * @param oldValue The object to be replaced.
   * @param newValue The value to substitute.
   */
  public synchronized int replace( Object oldValue, Object newValue )
    {
    return Algos.Replacing.replace( begin(), end(), oldValue, newValue );
    }

  /**
   * Replace all elements within a specified range that match a particular object
   * with a new value and return the number of objects that were replaced.
   * @param first An iterator positioned at the first object to be considered.
   * @param last An iterator positioned immediately after the last object to be considered.
   * @param oldValue The object to be replaced.
   * @param newValue The value to substitute.
   */
  public synchronized int replace( SListIterator first, SListIterator last, Object oldValue, Object newValue )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );
    return Algos.Replacing.replace( first, last, oldValue, newValue );
    }

  /**
   * Replace all elements within a specified range that match a particular object
   * with a new value and return the number of objects that were replaced.
   * @param first The index of the first object to be considered.
   * @param last The index of the last object to be considered.
   * @param oldValue The object to be replaced.
   * @param newValue The value to substitute.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public synchronized int replace( int first, int last, Object oldValue, Object newValue )
    {
    if ( last < first )
      return 0;

    checkRange( first, last );
    return Algos.Replacing.replace( iteratorAt( first ), iteratorAt( last + 1 ), oldValue, newValue );
    }

  /**
   * Return the number of objects that match a particular value.
   * @param object The object to count.
   */
  public int count( Object object )
    {
    return count( begin(), end(), object );
    }

  /**
   * Return the number of objects within a specified range of that match a
   * particular value.
   * @param first An iterator positioned at the first object to consider.
   * @param last An iterator positioned immediately after the last object to consider.
   */
  public synchronized int count( SListIterator first, SListIterator last, Object object )
    {
    return Algos.Counting.count( first, last, object );
    }

  /**
   * Return the number of objects within a specified range of that match a
   * particular value.
   * @param first The index of the first object to consider.
   * @param last The index of the last object to consider.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public synchronized int count( int first, int last, Object object )
    {
    if ( last < first )
      return 0;

    checkRange( first, last );
    return Algos.Counting.count( iteratorAt( first ), iteratorAt( last + 1 ), object );
    }

  /**
   * Return an iterator positioned at the first object that matches a particular value, or
   * end() if the object is not found.
   * @param object The object to find.
   */
  public synchronized SListIterator find( Object object )
    {
    return (SListIterator)Algos.Finding.find( new SListIterator( this, myHead ), new SListIterator( this, null ), object );
    }

  /**
   * Return the index of the first object that matches a particular value, or
   * -1 if the object is not found.
   * @param object The object to find.
   */
  public synchronized int indexOf( Object object )
    {
    SListIterator iterator = (SListIterator)Algos.Finding.find( new SListIterator( this, myHead ), new SListIterator( this, null ), object );
    return iterator.myNode == null ? -1 : iterator.index();
    }

  /**
   * Return an iterator positioned at the first object within a specified range that
   * match a particular object, or end() if the object is not found.
   * @param first An iterator positioned at the first object to consider.
   * @param last An iterator positioned immediately after the last object to consider.
   * @param object The object to find.
   */
  public synchronized SListIterator find( SListIterator first, SListIterator last, Object object )
    {
    return (SListIterator)Algos.Finding.find( first, last, object );
    }

  /**
   * Return the index of the first object within a specified range that
   * match a particular object, or -1 if the object is not found.
   * @param first The index of the first object to consider.
   * @param last The index of the last object to consider.
   * @param object The object to find.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public synchronized int indexOf( int first, int last, Object object )
    {
    if ( last < first )
      return 0;

    checkRange( first, last );
    SListIterator end = iteratorAt( last + 1 );
    SListIterator iterator = (SListIterator)Algos.Finding.find( iteratorAt( first ), end, object );
    return iterator.myNode == end.myNode ? -1 : iterator.index();
    }

  /**
   * Return true if I contain a particular object.
   * @param object The object in question.
   */
  public synchronized boolean contains( Object object )
    {
    return !find( object ).equals( end() );
    }

  /**
   * Remove the element at a particular position.
   * @param pos An Enumeration positioned at the element to remove.
   * @exception IllegalArgumentException is the Enumeration isn't a
   * SListIterator for this SList object.
   */
  public synchronized Object remove( Enumeration pos )
    {
    if ( ! (pos instanceof SListIterator) )
      throw new IllegalArgumentException( "Enumeration not a SListIterator" );

    if ( ((SListIterator)pos).mySList != this )
      throw new IllegalArgumentException( "Enumeration not for this SList" );

    Object retval = ( (SListIterator)pos ).get();
    remove( ((SListIterator)pos).myNode );
    return retval;
    }

  /**
   * Remove the element at a particular index.
   * @param index The index of the element to remove.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized Object remove( int index )
    {
    if ( index < 0 || index >= myLength )
      throw new IndexOutOfBoundsException( "Attempt to access index " + index + " when valid range is 0.." + (myLength - 1) );

    return remove( nodeAt( index ) );
    }

  /**
   * Remove the elements in the range [ first..last ).
   * @param first An Enumeration positioned at the first object to remove.
   * @param last An Enumeration positioned immediately after the last object to remove.
   * @exception IllegalArgumentException is the Enumeration isn't a
   * SListIterator for this SList object.
   */
  public synchronized int remove( Enumeration first, Enumeration last )
    {
    if ( ( ! (first instanceof SListIterator) ) ||
        ( ! (last instanceof SListIterator) ) )
      throw new IllegalArgumentException( "Enumeration not a SListIterator" );

    if ( ( ((SListIterator)first).mySList != this ) ||
        ( ((SListIterator)last).mySList != this ) )
      throw new IllegalArgumentException( "Enumeration not for this SList" );

    SListIterator begin = (SListIterator)first;
    SListIterator end = (SListIterator)last;

    return remove( begin.myNode, end.myNode );
    }

  /**
   * Remove the elements in the specified range.
   * @param first The index of the first element to remove.
   * @param last The index of the last element to remove.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public synchronized int remove( int first, int last )
    {
    if ( last < first )
      return 0;

    checkRange( first, last );
    return remove( nodeAt( first ), nodeAt( last + 1 ) );
    }

  /**
   * Remove all of the elements in a specified list and insert them at a particular
   * position.
   * @param pos The position to insert the elements.
   * @param list The list to splice the elements from.
   */
  public synchronized void splice( SListIterator pos, SList list )
    {
    splice( pos.myNode, list );
    }

  /**
   * Remove all of the elements in a specified list and insert them at a particular
   * index.
   * @param index The index of the item that the elements should be inserted immediately before.
   * @param list The list to splice the elements from.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized void splice( int index, SList list )
    {
    if ( index > myLength || ( myLength == 0 && index > 0 ) )
      throw new IndexOutOfBoundsException( "Attempt to insert at index " + index + " when valid range is 0.." + myLength );

    if ( myLength == 0 )
      swap( list );
    else
      splice( nodeAt( index ), list );
    }

  /**
   * Remove a specified element from a list and insert it at a particular position.
   * @param to The position to insert the element.
   * @param list The list to splice the element from.
   * @param from The position of the element to remove.
   */
  public synchronized void splice( SListIterator to, SList list, SListIterator from )
    {
    splice( to.myNode, list, from.myNode );
    }

  /**
   * Remove a specified element from a list and insert it at a particular position.
   * @param to The index of the item that the element should be inserted immediately before.
   * @param list The list to splice the element from.
   * @param from The index of the element to remove.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public synchronized void splice( int to, SList list, int from )
    {
    if ( to > myLength )
      throw new IndexOutOfBoundsException( "Attempt to insert at index " + to + " when valid range is 0.." + myLength );

    if ( from < 0 || from >= list.myLength )
      throw new IndexOutOfBoundsException( "Attempt to access index " + from + " when valid range is 0.." + (list.myLength - 1) );

    splice( nodeAt( to ), list, list.nodeAt( from ) );
    }

  /**
   * Remove a range of elements from a list and insert them at a particular position.
   * @param pos The position to insert the elements.
   * @param list The list to splice the elements from.
   * @param first An iterator positioned at the first element to remove.
   * @param last An iterator positioned immediately after the last element to remove.
   */
  public synchronized void splice( SListIterator pos, SList list, SListIterator first, SListIterator last )
    {
    splice( pos.myNode, list, first.myNode, last.myNode );
    }

  /**
   * Remove a range of elements from a list and insert them at a particular position.
   * @param pos The index of the item that the elements should be inserted immediately before.
   * @param list The list to splice the elements from.
   * @param first The index of the first element to remove.
   * @param last The index of the last element to remove.
   * @exception java.lang.IndexOutOfBoundsException If any index is invalid.
   */
  public synchronized void splice( int pos, SList list, int first, int last )
    {
    if ( pos > myLength )
      throw new IndexOutOfBoundsException( "Attempt to insert at index " + pos + " when valid range is 0.." + myLength );

    if ( first < 0 || first >= list.myLength )
      throw new IndexOutOfBoundsException( "Attempt to access index " + first + " when valid range is 0.." + (list.myLength - 1) );

    if ( last < 0 || last >= list.myLength )
      throw new IndexOutOfBoundsException( "Attempt to access index " + last + " when valid range is 0.." + (list.myLength - 1) );

    splice( nodeAt( pos ), list, list.nodeAt( first ), list.nodeAt( last + 1 ) );
    }

 private Object remove( SListNode target )
   {
    SListNode previous = null;

    for ( SListNode node = myHead; node != target; node = node.next )
      previous = node;

    if ( previous == null )
      myHead = target.next;
    else
      previous.next = target.next;

    if ( target == myTail )
      myTail = previous;

    --myLength;

    return target.object;
    }

  private int remove( SListNode begin, SListNode end )
    {
    SListNode previous = null;

    for ( SListNode node = myHead; node != begin; node = node.next )
      previous = node;

    if ( previous == null )
      myHead = end;
    else
      previous.next = end;

    if ( end == null )
      myTail = previous;

    int n = 0;

    while ( begin != end )
      {
      begin = begin.next;
      ++n;
      }

    myLength -= n;
    return n;
    }

  private void splice( SListNode begin, SList list )
    {
    synchronized( list )
      {
      if ( this == list || list.myLength == 0 )
        return;

      SListNode previous = null;

      for ( SListNode node = myHead; node != begin; node = node.next )
        previous = node;

      if ( previous == null )
        myHead = list.myHead;
      else
        previous.next = list.myHead;

      if ( begin == null )
        myTail = list.myTail;
      else
        list.myTail.next = begin;

      myLength += list.myLength;
      list.clear();
      }
    }

  private void splice( SListNode insertNode, SList list, SListNode newNode )
    {
    synchronized( list )
      {
      if ( insertNode == newNode || insertNode == newNode.next )
        return;

      list.remove( newNode );
      SListNode previous = null;

      for ( SListNode node = myHead; node != insertNode; node = node.next )
        previous = node;

      if ( previous == null )
        myHead = newNode;
      else
        previous.next = newNode;

      if ( insertNode == null )
        myTail = newNode;

      newNode.next = insertNode;
      ++myLength;
      }
    }

  private void splice( SListNode pos, SList list, SListNode begin, SListNode pastEnd )
    {
    if ( begin == pastEnd )
      return;

    synchronized( list )
      {
      if ( list == this )
        {
        SListNode tmp = begin;
        if ( ( pos == begin ) || ( pos == pastEnd ) )
          return;

        while ( tmp != pastEnd )
          {
          if ( pos == tmp )
            {
            throw new InvalidOperationException("Tried to splice into an overlapping area.");
            }
          tmp = tmp.next;
          }
        }

      list.remove( begin, pastEnd );
      SListNode previous = null;

      for ( SListNode node = myHead; node != pos; node = node.next )
        previous = node;

      if ( previous == null )
        myHead = begin;
      else
        previous.next = begin;

      SListNode end = begin;
      int n = 1;

      while ( end.next != pastEnd )
        {
        end = end.next;
        ++n;
        }

      if ( pos == null )
        myTail = end;

      end.next = pos;
      myLength += n;
      }
    }

  private SListNode insert( SListNode target, Object object )
    {
    SListNode previous = null;

    for ( SListNode node = myHead; node != target; node = node.next )
      previous = node;

    SListNode newNode = new SListNode();
    newNode.object = object;

    if ( previous == null )
      myHead = newNode;
    else
      previous.next = newNode;

    newNode.next = target;
    ++myLength;
    return newNode;
    }

  private void insert( SListNode target, int n, Object object )
    {
    SListNode previous = null;
    SListNode newNode = null;
    myLength += n;

    for ( SListNode node = myHead; node != target; node = node.next )
      previous = node;

    while ( --n >= 0 )
      {
      newNode = new SListNode();
      newNode.object = object;

      if ( previous == null )
        myHead = newNode;
      else
        previous.next = newNode;

      previous = newNode;
      }

    newNode.next = target;
    }

  private int remove( SListNode first, SListNode last, Object object, int maximum )
    {
    if ( maximum <= 0 )
      return 0;

    int n = 0;
    SListNode previous = null;
    SListNode node;

    for ( node = myHead; node != first; node = node.next )
      previous = node;

    while ( maximum > 0 && node != last )
      {
      if ( node.object.equals( object ) )
        {
        if ( previous == null )
          myHead = node.next;
        else
          previous.next = node.next;

        if ( node == myTail )
          myTail = previous;

        ++n;
        --maximum;
        }
      else
        {
        previous = node;
        }

      node = node.next;
      }

    myLength -= n;
    return n;
    }

  SListIterator iteratorAt( int index )
    {
    SListNode node = myHead;

    while ( index-- > 0 )
      node = node.next;

    return new SListIterator( this, node );
    }

  SListNode nodeAt( int index )
    {
    SListNode node = myHead;

    int i = index;

    while ( index-- > 0 )
      node = node.next;

    return node;
    }

  private void checkRange( int lo, int hi )
    {
    if ( lo < 0 || lo >= myLength )
      throw new IndexOutOfBoundsException( "Attempt to access index " + lo + " when valid range is 0.." + (myLength - 1) );

    if ( hi < 0 || hi >= myLength )
      throw new IndexOutOfBoundsException( "Attempt to access index " + hi + " when valid range is 0.." + (myLength - 1) );
    }

  private synchronized void writeObject( ObjectOutputStream stream ) throws IOException
    {
    stream.defaultWriteObject();
    stream.writeInt( size() );
    Enumeration iter = begin();
    while ( iter.hasMoreElements() )
      stream.writeObject( iter.nextElement() );
    }

  private void readObject( ObjectInputStream stream ) throws IOException, ClassNotFoundException
    {
    stream.defaultReadObject();
    // create empty list
    clear();
    // fill list
    int count = stream.readInt();
    while ( count-- > 0 )
      add( stream.readObject() );
    }

  final static class SListNode
    {
    public SListNode next = null;
    public Object object = null;
    }

  static final long serialVersionUID = -5092823079416449151L;
  }
