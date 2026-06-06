// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.util.Enumeration;
import java.io.Serializable;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.IOException;

/**
 * A DList is a doubly-linked list, a sequential container that is optimized for insertion
 * and erasure at arbitrary points in its structure.
 * <p>
 * A DList is useful when the order of items and fast arbitrary insertion/erasure are
 * important. DLists are not as efficient as Deques when insertion and erasure only take
 * place at the extremities.
 * <p>
 * A DList is implemented as a doubly-linked list in which every node in the list
 * has a pointer to the previous node and a pointer to the next node.
 * <p>
 * Insertion does not affect iterators or references. Insertion of a single element into
 * a DList takes constant time. Insertion of multiple elements into a DList is linear in
 * the number of elements inserted.
 * <p>
 * Removal only invalidates the iterators and references to the removed elements. Removing
 * a single element is a constant time operation. Removing a range in a DList is linear
 * time in the size of the range.
 * <p>
 * @see com.objectspace.jgl.Sequence
 * @see com.objectspace.jgl.examples.DListExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class DList implements Sequence
  {
  transient DListNode myNode = new DListNode();
  transient int myLength;

  /**
   * Construct myself to be an empty DList.
   */
  public DList()
    {
    myNode.next = myNode;
    myNode.previous = myNode;
    }

  /**
   * Construct myself to contain a specified number of null elements.
   * @param size The number of elements to contain.
   * @exception java.lang.IllegalArgumentException If the specified size is negative.
   */
  public DList( int size )
    {
    this();
    insert( myNode.next, size, null );
    }

  /**
   * Construct myself to contain a specified number of elements set to
   * a particular object.
   * @param size The number of elements to contain.
   * @param object The initial value of each element.
   * @exception java.lang.IllegalArgumentException If the specified size is negative.
   */
  public DList( int size, Object object )
    {
    this();
    insert( myNode.next, size, object );
    }

  /**
   * Construct myself to be a shallow copy of an existing DList.
   * @param DList The DList to copy.
   */
  public DList( DList list )
    {
    this();
    synchronized( list )
      {
      insert( myNode.next, list.myNode.next, list.myNode );
      }
    }

  /**
   * Return a shallow copy of myself.
   */
  public synchronized Object clone()
    {
    return new DList( this );
    }

  /**
   * Return true if I'm equal to another object.
   * @param object The object to compare myself against.
   */
  public boolean equals( Object object )
    {
    return object instanceof DList && equals( (DList)object );
    }

  /**
   * Return true if I contain the same items in the same order as
   * another DList. Use equals() to compare the individual elements.
   * @param list The DList to compare myself against.
   */
  public synchronized boolean equals( DList list )
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
    return Algos.Hashing.orderedHash( start(), myLength );
    }


  /**
   * Return a string that describes me.
   */
  public synchronized String toString()
    {
    return Algos.Printing.toString( this, "DList" );
    }

  /**
   * Become a shallow copy of an existing DList.
   * @param list The DList that I shall become a shallow copy of.
   */
  public synchronized void copy( DList list )
    {
    if ( this == list )
      return;

    synchronized( list )
      {
      DListNode first1 = myNode.next;
      DListNode last1 = myNode;
      DListNode first2 = list.myNode.next;
      DListNode last2 = list.myNode;

      while ( first1 != last1 && first2 != last2 )
        {
        first1.object = first2.object;
        first1 = first1.next;
        first2 = first2.next;
        }

      if ( first2 == last2 )
        remove( first1, last1 );
      else
        insert( last1, first2, last2 );
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

    DListNode node = myNode.next;

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

    DListNode node = myNode.next;

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
  public synchronized DListIterator insert( DListIterator pos, Object object )
    {
    return new DListIterator( this, insert( pos.myNode, object ) );
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
  public synchronized void insert( DListIterator pos, int n, Object object )
    {
    insert( pos.myNode, n, object );
    }

  /**
   * Insert multiple objects at a particular index.
   * @param index The index of the element that the objects will be inserted immediately before.
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
  public synchronized void insert( DListIterator pos, InputIterator first, InputIterator last )
    {
    InputIterator firstx = (InputIterator) first.clone();

    while ( !firstx.equals( last ) )
      insert( pos.myNode, firstx.nextElement() );
    }

  /**
   * Return my last item.
   * @exception com.objectspace.jgl.InvalidOperationException If the DList is empty.
   */
  public synchronized Object back()
    {
    if ( myLength == 0 )
      throw new InvalidOperationException( "DList is empty" );

    return myNode.previous.object;
    }

  /**
   * Return my first item.
   * @exception com.objectspace.jgl.InvalidOperationException If the DList is empty.
   */
  public synchronized Object front()
    {
    if ( myLength == 0 )
      throw new InvalidOperationException( "DList is empty" );

    return myNode.next.object;
    }

  /**
   * Remove all of my elements.
   */
  public synchronized void clear()
    {
    myNode.next = myNode;
    myNode.previous = myNode;
    myLength = 0;
    }

  /**
   * Remove the elements within a range of indices.
   * @param first The index of the first element to remove.
   * @param last The index of the last element to remove.
   * @return The number of elements removed.
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
   * Remove the elements in the range [ first..last ).
   * @param first An Enumeration positioned at the first object to remove.
   * @param last An Enumeration positioned immediately after the last object to remove.
   * @return The number of elements removed.
   * @exception IllegalArgumentException is the Enumeration isn't a
   * DListIterator for this DList object.
   */
  public synchronized int remove( Enumeration first, Enumeration last )
    {
    if ( ( ! (first instanceof DListIterator) ) ||
        ( ! (last instanceof DListIterator) ) )
      throw new IllegalArgumentException( "Enumeration not a DListIterator" );

    if ( ( ((DListIterator)first).myDList != this ) ||
        ( ((DListIterator)last).myDList != this ) )
      throw new IllegalArgumentException( "Enumeration not for this DList" );

    DListIterator begin = (DListIterator)first;
    DListIterator end = (DListIterator)last;

    return remove( begin.myNode, end.myNode );
    }

  /**
   * Remove the element at a particular index.
   * @param index The index of the element to remove.
   * @return The object removed.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized Object remove( int index )
    {
    if ( index < 0 || index >= myLength )
      throw new IndexOutOfBoundsException( "Attempt to access index " + index + " when valid range is 0.." + (myLength - 1) );

    return remove( nodeAt( index ) );
    }

  /**
   * Remove the element at a particular position.
   * @param pos An Enumeration positioned at the element to remove.
   * @return The object removed.
   * @exception IllegalArgumentException is the Enumeration isn't a
   * DListIterator for this DList object.
   */
  public synchronized Object remove( Enumeration pos )
    {
    if ( ! (pos instanceof DListIterator) )
      throw new IllegalArgumentException( "Enumeration not a DListIterator" );

    if ( ((DListIterator)pos).myDList != this )
      throw new IllegalArgumentException( "Enumeration not for this DList" );

    Object retval = ( (DListIterator)pos ).get();
    remove( ((DListIterator)pos).myNode );
    return retval;
    }

  /**
   * Remove all of the elements in a specified DList and insert them at a particular
   * position.
   * @param index The index of the element that the items will be inserted immediately before.
   * @param list The DList to splice the elements from.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized void splice( int index, DList list )
    {
    if ( index > myLength || ( myLength == 0 && index > 0 ) )
      throw new IndexOutOfBoundsException( "Attempt to insert at index " + index + " when valid range is 0.." + myLength );

    if ( myLength == 0 )
      swap( list );
    else
      splice( nodeAt( index ), list );
    }

  /**
   * Remove all of the elements in a specified DList and insert them at a particular
   * position.
   * @param pos The position to insert the elements.
   * @param list The DList to splice the elements from.
   */
  public synchronized void splice( DListIterator pos, DList list )
    {
    splice( pos.myNode, list );
    }

  /**
   * Remove a specified element from a DList and insert it at a particular position.
   * @param to The position to insert the element.
   * @param list The DList to splice the element from.
   * @param from The position of the element to splice.
   */
  public synchronized void splice( DListIterator to, DList list, DListIterator from )
    {
    splice( to.myNode, list, from.myNode );
    }

  /**
   * Remove a specified element from a DList and insert it at a particular position.
   * @param to The index of the element that the item will be inserted immediately before.
   * @param list The DList to splice the element from.
   * @param from The index of the element to splice.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public synchronized void splice( int to, DList list, int from )
    {
    if ( to > myLength )
      throw new IndexOutOfBoundsException( "Attempt to insert at index " + to + " when valid range is 0.." + myLength );

    if ( from < 0 || from >= list.myLength )
      throw new IndexOutOfBoundsException( "Attempt to access index " + from + " when valid range is 0.." + (list.myLength - 1) );

    splice( nodeAt( to ), list, list.nodeAt( from ) );
    }

  /**
   * Splice a range of elements from a DList into a particular position.
   * @param pos The position to insert the elements.
   * @param list The list to splice the elements from.
   * @param first An iterator positioned at the first element to splice.
   * @param last An iterator positioned immediately after the last element to splice.
   */
  public synchronized void splice( DListIterator pos, DList list, DListIterator first, DListIterator last )
    {
    synchronized( list )
      {
      if ( first.myNode != last.myNode )
        {
        if ( list != this )
          {
          int n = first.distance( last );
          list.myLength -= n;
          myLength += n;
          }
        else
          {
          DListNode tmp = first.myNode.next;
          while (tmp != last.myNode)
            {
            if (pos.myNode == tmp)
              throw new InvalidOperationException("Tried to splice into an overlapping area.");
            tmp = tmp.next;
            }
          }
        transfer( pos.myNode, first.myNode, last.myNode );
        }
      }
    }

  /**
   * Splice a range of elements from a DList and insert them at a particular position.
   * @param index The index of the item that the elements should be inserted immediately before.
   * @param list The DList to splice the elements from.
   * @param first The index of the first element to splice.
   * @param last The index of the last element to splice.
   * @exception java.lang.IndexOutOfBoundsException If any index is invalid.
   */
  public synchronized void splice( int index, DList list, int first, int last )
    {
    if ( index > myLength )
      throw new IndexOutOfBoundsException( "Attempt to insert at index " + index + " when valid range is 0.." + myLength );

    if ( first < 0 || first >= list.myLength )
      throw new IndexOutOfBoundsException( "Attempt to access index " + first + " when valid range is 0.." + (list.myLength - 1) );

    if ( last < 0 || last >= list.myLength )
      throw new IndexOutOfBoundsException( "Attempt to access index " + last + " when valid range is 0.." + (list.myLength - 1) );

    splice( iteratorAt( index ), list, list.iteratorAt( first ), list.iteratorAt( last + 1 ) );
    }

  /**
   * Replace all repeating sequences of a single element by a single occurrence of
   * that element.
   */
  public synchronized void unique()
    {
    if ( myLength == 0 )
      return;

    DListNode first = myNode.next;
    DListNode last = myNode;

    for ( DListNode next = first.next; next != last; next = first.next )
      if ( first.object.equals( next.object ) )
        {
        next.previous.next = next.next;
        next.next.previous = next.previous;
        --myLength;
        }
      else
        {
        first = next;
        }
    }

  /**
   * Remove and return my last element.
   * @exception com.objectspace.jgl.InvalidOperationException If the DList is empty.
   */
  public synchronized Object popBack()
    {
    if ( myLength == 0 )
      throw new InvalidOperationException( "DList is empty" );

    DListNode node = myNode.previous;
    node.previous.next = node.next;
    node.next.previous = node.previous;
    --myLength;
    return node.object;
    }

  /**
   * Insert an object in front of my first element.
   * @param object The object to insert.
   */
  public synchronized void pushFront( Object object )
    {
    insert( myNode.next, object );
    }

  /**
   * Remove and return my first element.
   * @exception com.objectspace.jgl.InvalidOperationException If the DList is empty.
   */
  public synchronized Object popFront()
    {
    if ( myLength == 0 )
      throw new InvalidOperationException( "DList is empty" );

    DListNode node = myNode.next;
    node.previous.next = node.next;
    node.next.previous = node.previous;
    --myLength;
    return node.object;
    }

  /**
   * Add an object after my last element and return null.
   * This function is a synonym for pushBack().
   * @param object The object to add.
   */
  public synchronized Object add( Object object )
    {
    insert( myNode, object );
    return null;
    }

  /**
   * Add an object after my last element.
   * @param The object to add.
   */
  public synchronized void pushBack( Object object )
    {
    insert( myNode, object );
    }

  /**
   * Swap my contents with another DList.
   * @param list The DList that I will swap my contents with.
   */
  public synchronized void swap( DList list )
    {
    synchronized( list )
      {
      DListNode tmpNode = myNode;
      int tmpLength = myLength;
      myNode = list.myNode;

      myLength = list.myLength;
      list.myNode = tmpNode;
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
    return remove( myNode.next, myNode, object, myLength );
    }

  /**
   * Remove at most a given number of elements that match a particular object and return the number of
   * objects that were removed.
   * @param object The object to remove.
   * @param count The maximum number of objects to remove.
   */
  public synchronized int remove( Object object, int count )
    {
    return remove( myNode.next, myNode, object, count );
    }

  /**
   * Remove all elements within a specified range that match a particular object
   * and return the number of objects that were removed.
   * @param first An Enumeration positioned at the first object to remove.
   * @param last An Enumeration positioned immediately after the last object to remove.
   * @param object The object to remove.
   * @exception IllegalArgumentException is the Enumeration isn't a
   * DListIterator for this DList object.
   */
  public synchronized int remove( Enumeration first, Enumeration last, Object object )
    {
    if ( ( ! (first instanceof DListIterator) ) ||
        ( ! (last instanceof DListIterator) ) )
      throw new IllegalArgumentException( "Enumeration not a DListIterator" );

    if ( ( ((DListIterator)first).myDList != this ) ||
        ( ((DListIterator)last).myDList != this ) )
      throw new IllegalArgumentException( "Enumeration not for this DList" );

    DListIterator begin = (DListIterator)first;
    DListIterator end = (DListIterator)last;
    return remove( begin.myNode, end.myNode, object, myLength );
    }

  /**
   * Remove all elements within a specified range that match a particular object
   * and return the number of objects that were removed.
   * @param first The index of the first object to remove.
   * @param last The index of the last object to remove.
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
   * Return an iterator positioned at my first item.
   */
  public synchronized DListIterator begin()
    {
    return new DListIterator( this, myNode.next );
    }

  /**
   * Return an iterator positioned at my first item.
   */
  public ForwardIterator start()
    {
    return begin();
    }

  /**
   * Return an iterator positioned immediately after my last item.
   */
  public synchronized DListIterator end()
    {
    return new DListIterator( this, myNode );
    }

  /**
   * Return an iterator positioned immediately afer my last item.
   */
  public ForwardIterator finish()
    {
    return end();
    }

  /**
   * Return an Enumeration of my components.
   */
  public synchronized Enumeration elements()
    {
    return new DListIterator( this, myNode.next );
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
  public synchronized int replace( DListIterator first, DListIterator last, Object oldValue, Object newValue )
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
  public synchronized int count( DListIterator first, DListIterator last, Object object )
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
  public synchronized DListIterator find( Object object )
    {
    return (DListIterator)Algos.Finding.find( new DListIterator( this, myNode.next ), new DListIterator( this, myNode ), object );
    }

  /**
   * Return the index of the first object that matches a particular value, or
   * -1 if the object is not found.
   * @param object The object to find.
   */
  public synchronized int indexOf( Object object )
    {
    DListIterator iterator = (DListIterator)Algos.Finding.find( new DListIterator( this, myNode.next ), new DListIterator( this, myNode ), object );
    return iterator.myNode == myNode ? -1 : iterator.index();
    }

  /**
   * Return an iterator positioned at the first object within a specified range that
   * matches a particular object, or end() if the object is not found.
   * @param first An iterator positioned at the first object to consider.
   * @param last An iterator positioned immediately after the last object to consider.
   * @param object The object to find.
   */
  public synchronized DListIterator find( DListIterator first, DListIterator last, Object object )
    {
    return (DListIterator)Algos.Finding.find( first, last, object );
    }

  /**
   * Return an iterator positioned at the first object within a specified range that
   * matches a particular object, or -1 if the object is not found.
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
    DListIterator end = iteratorAt( last + 1 );
    DListIterator iterator = find( iteratorAt( first ), end, object );
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
   * Reverse the order of my elements.
   */
  public synchronized void reverse()
    {
    if ( myLength < 2 )
      return;

    DListNode first = myNode.next.next;

    while ( first != myNode )
      {
      DListNode old = first;
      first = first.next;
      transfer( myNode.next, old, first );
      }
    }

  private void insert( DListNode node, int n, Object value )
    {
    if ( n < 0 )
      throw new IllegalArgumentException( "Attempt to specify a insert a negative number of objects" );

    while ( n-- > 0 )
      insert( node, value );
    }

  private void splice( DListNode node, DList list )
    {
    synchronized( list )
      {
      if ( list.myLength > 0 )
        {
        transfer( node, list.myNode.next, list.myNode );
        myLength += list.myLength;
        list.myLength = 0;
        }
      }
    }

  private void splice( DListNode to, DList list, DListNode from )
    {
    synchronized( list )
      {
      if ( to != from && to != from.next )
        {
        transfer( to, from, from.next );
        ++myLength;
        --list.myLength;
        }
      }
    }

  private DListNode insert( DListNode pos, Object value )
    {
    DListNode tmp = new DListNode();
    tmp.object = value;
    tmp.next = pos;
    tmp.previous = pos.previous;
    pos.previous.next = tmp;
    pos.previous = tmp;
    ++myLength;
    return tmp;
    }

  private void insert( DListNode pos, DListNode first, DListNode last )
    {
    while ( first != last )
      {
      insert( pos, first.object );
      first = first.next;
      }
    }

  private void transfer( DListNode pos, DListNode first, DListNode last )
    {
    if ((pos != first) && (pos != last))
      {
      last.previous.next = pos;
      first.previous.next = last;
      pos.previous.next = first;
      DListNode tmp = pos.previous;
      pos.previous = last.previous;
      last.previous = first.previous;
      first.previous = tmp;
      }
    }

  private Object remove( DListNode node )
    {
    node.previous.next = node.next;
    node.next.previous = node.previous;
    --myLength;
    return node.object;
    }

  private int remove( DListNode first, DListNode last )
    {
    int removed = 0;
    while ( first != last )
      {
      first.previous.next = first.next;
      first.next.previous = first.previous;
      ++removed;
      first = first.next;
      }
    myLength -= removed;
    return removed;
    }

  private int remove( DListNode first, DListNode last, Object object, int maximum )
    {
    if ( maximum <= 0 )
      return 0;

    int n = 0;

    for ( DListNode node = first; maximum > 0 && node != last; node = node.next )
      if ( node.object.equals( object ) )
        {
        node.previous.next = node.next;
        node.next.previous = node.previous;
        ++n;
        --maximum;
        }

    myLength -= n;
    return n;
    }

  DListIterator iteratorAt( int index )
    {
    DListNode node = myNode.next;

    while ( index-- > 0 )
      node = node.next;

    return new DListIterator( this, node );
    }

  DListNode nodeAt( int index )
    {
    DListNode node = myNode.next;

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
    myNode = new DListNode();
    myNode.next = myNode;
    myNode.previous = myNode;
    myLength = 0;
    // fill list
    int count = stream.readInt();
    while ( count-- > 0 )
      add( stream.readObject() );
    }

  final static class DListNode
    {
    public DListNode previous = null;
    public DListNode next = null;
    public Object object = null;
    }

  static final long serialVersionUID = 6393954640158620295L;
  }
