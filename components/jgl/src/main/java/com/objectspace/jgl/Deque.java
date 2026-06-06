// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.util.Enumeration;

/**
 * A Deque is a sequential container that is optimized for fast indexed-based access
 * and efficient insertion at either of its extremities.
 * <p>
 * Deques are useful in circumstances where order, compact storage, and fast insertion at
 * extremeties is important. A Deque is ideal for implementing any kind of FIFO structure.
 * If a strict FIFO structure is required that does not allow index-based access, then
 * you should consider using a Queue adaptor with a Deque as the underlying container.
 * If you require very fast insertion near the middle of a sequential structure, then
 * consider using a List instead of a Deque.
 * <p>
 * The implementation allocates storage for a Deque's elements in 4K blocks
 * (a usual page size) of contiguous memory, and use an array to keep track of a deque's
 * blocks. When a Deque is constructed, it has no associated storage. As elements are
 * added, blocks of storage are added to the beginning or the end of the deque as
 * necessary. A result of this architecture is that items may be inserted very
 * efficiently near either extremity. Once a block has been allocated to a Deque, it is
 * not deallocated until the Deque is destroyed. Insertions are careful to expand the
 * Deque in the direction that involves the least amount of copying. Removals take
 * similar precautions.
 * <p>
 * If an insertion causes reallocation, all iterators and references are invalidated;
 * otherwise, iterators and references are only invalidated if an item is not inserted
 * at an extremity. In the worst cast, inserting a single element into a Deque takes
 * linear time in the minimum of the distance from the insertion point to the beginning
 * of the Deque and the distance from the insertion point to the end of the Deque.
 * Inserting a single element either at the beginning or end of a Deque always takes
 * constant time.
 * <p>
 * If the first or last item is removed, all iterators and references remain valid; if any
 * other item is removed, all iterators and references are invalidated.
 * <p>
 * @see com.objectspace.jgl.Sequence
 * @see com.objectspace.jgl.examples.DequeExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class Deque implements Sequence
  {
  DequeIterator myStart = new DequeIterator( this, 0, 0 );
  DequeIterator myFinish = new DequeIterator( this, 0, 0 );
  int myLength;
  Object[][] myMap;
  static final int pageSize = 1024;
  static final int BLOCK_SIZE = pageSize / 8;

  /**
   * Construct myself to be an empty Deque.
   */
  public Deque()
    {
    }

  /**
   * Construct myself to contain a specified number of null elements.
   * @param size The number of elements to contain.
   * @exception java.lang.IllegalArgumentException If size is negative.
   */
  public Deque( int size )
    {
    insert( myStart, size, null );
    }

  /**
   * Construct myself to contain a specified number of elements set to
   * a particular object.
   * @param size The number of elements to contain.
   * @param object The initial value of each element.
   * @exception java.lang.IllegalArgumentException If size is negative.
   */
  public Deque( int size, Object object )
    {
    insert( myStart, size, object );
    }

  /**
   * Construct myself to be a shallow copy of an existing Deque.
   * @param deque The Deque to copy.
   */
  public Deque( Deque deque )
    {
    synchronized( deque )
      {
      DequeIterator iter = deque.begin();
      while ( iter.hasMoreElements() )
        add( iter.nextElement() );
      }
    }

  /**
   * Return a shallow copy of myself.
   */
  public synchronized Object clone()
    {
    return new Deque( this );
    }

  /**
   * Return true if I'm equal to another object.
   * @param object The object to compare myself against.
   */
  public boolean equals( Object object )
    {
    return object instanceof Deque && equals( (Deque)object );
    }

  /**
   * Return true if I contain the same items in the same order as
   * another Deque. Use equals() to compare the individual elements.
   * @param deque The Deque to compare myself against.
   */
  public synchronized boolean equals( Deque deque )
    {
    synchronized( deque )
      {
      return Algos.Comparing.equal( this, deque );
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
    return Algos.Printing.toString( this, "Deque" );
    }

  /**
   * Become a shallow copy of an existing Deque.
   * @param deque The Deque that I shall become a shallow copy of.
   */
  public synchronized void copy( Deque deque )
    {
    if ( this == deque )
      return;

    synchronized( deque )
      {
      if ( myLength >= deque.myLength )
        {
        DequeIterator begin = copy( deque.myStart, deque.myFinish, myStart );
        remove( begin, myFinish );
        }
      else
        {
        DequeIterator end = deque.myStart.copy( myLength );
        copy( deque.myStart, end, myStart );

        for ( DequeIterator iterator = end; iterator.hasMoreElements(); iterator.advance() )
          add( iterator.get() );
        }
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
   * Add an object after my last element and return null.
   * This function is a synonym for pushBack().
   * @param object The object to add.
   */
  public synchronized Object add( Object object )
    {
    if ( myLength++ == 0 )
      {
      createMap();
      myMap[ myFinish.myMapIndex ][ myFinish.myBlockIndex++ ] = object;
      }
    else
      {
      myMap[ myFinish.myMapIndex ][ myFinish.myBlockIndex++ ] = object;

      if ( myFinish.myBlockIndex == BLOCK_SIZE )
        {
        if ( myFinish.myMapIndex == myMap.length - 1 )
          growMap();

        myMap[ ++myFinish.myMapIndex ] = new Object[ BLOCK_SIZE ];
        myFinish.myBlockIndex = 0;
        }
      }
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
   * Insert an object in front of my first element.
   * @param object The object to insert.
   */
  public synchronized void pushFront( Object object )
    {
    if ( myLength == 0 )
      {
      add( object );
      return;
      }

    ++myLength;
    if ( --myStart.myBlockIndex < 0 )
      {
      if ( myStart.myMapIndex == 0 )
        growMap();

      myMap[ --myStart.myMapIndex ] = new Object[ BLOCK_SIZE ];
      myStart.myBlockIndex = BLOCK_SIZE - 1;
      }

    myMap[ myStart.myMapIndex ][ myStart.myBlockIndex ] = object;
    }

  /**
   * Remove and return my first element.
   * @exception com.objectspace.jgl.InvalidOperationException If the Deque is empty.
   */
  public synchronized Object popFront()
    {
    if ( myLength == 0 )
      throw new InvalidOperationException( "Deque is empty" );

    Object r = at(0);
    if ( --myLength == 0 )
      {
      clear();
      }
    else
      {
      r = myMap[ myStart.myMapIndex ][ myStart.myBlockIndex ];
      myMap[ myStart.myMapIndex ][ myStart.myBlockIndex++ ] = null;

      if ( myStart.myBlockIndex == BLOCK_SIZE )
        {
        myMap[ myStart.myMapIndex++ ] = null;
        myStart.myBlockIndex = 0;
        }
      }
    return r;
    }

  /**
   * Remove and return my last element.
   * @exception com.objectspace.jgl.InvalidOperationException If the Deque is empty.
   */
  public synchronized Object popBack()
    {
    if ( myLength == 0 )
      throw new InvalidOperationException( "Deque is empty" );

    Object r = at(0);
    if ( --myLength == 0 )
      {
      clear();
      }
    else
      {
      if ( myFinish.myBlockIndex-- == 0 )
        {
        myMap[ myFinish.myMapIndex-- ] = null;
        myFinish.myBlockIndex = BLOCK_SIZE - 1;
        }
      r = myMap[ myFinish.myMapIndex ][ myFinish.myBlockIndex ];
      myMap[ myFinish.myMapIndex ][ myFinish.myBlockIndex ] = null;
      }
    return r;
    }

  /**
   * Remove all of my elements.
   */
  public synchronized void clear()
    {
    myMap = null;
    myStart.myMapIndex = 0;
    myStart.myBlockIndex = 0;
    myFinish.myMapIndex = 0;
    myFinish.myBlockIndex = 0;
    myLength = 0;
    }

  /**
   * Return an Enumeration of my components
   */
  public synchronized Enumeration elements()
    {
    return new DequeIterator( myStart );
    }

  /**
   * Return an iterator positioned at my first item.
   */
  public synchronized DequeIterator begin()
    {
    return new DequeIterator( myStart );
    }

  /**
   * Return an iterator positioned immediately after my last item.
   */
  public synchronized DequeIterator end()
    {
    return new DequeIterator( myFinish );
    }

  /**
   * Return an iterator positioned at my first item
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
   * Return my first item.
   * @exception com.objectspace.jgl.InvalidOperationException If the Deque is empty.
   */
  public synchronized Object front()
    {
    if ( myLength == 0 )
      throw new InvalidOperationException( "Deque is empty" );

    return myMap[ myStart.myMapIndex ][ myStart.myBlockIndex ];
    }

  /**
   * Return my last item.
   * @exception com.objectspace.jgl.InvalidOperationException If the Deque is empty.
   */
  public synchronized Object back()
    {
    if ( myLength == 0 )
      throw new InvalidOperationException( "Deque is empty" );

    if ( myFinish.myBlockIndex > 0 )
      return myMap[ myFinish.myMapIndex ][ myFinish.myBlockIndex - 1 ];
    else
      return myMap[ myFinish.myMapIndex - 1 ][ BLOCK_SIZE - 1 ];
    }

  /**
   * Return the element at the specified index.
   * @param index The index.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized Object at( int index )
    {
    if ( index < 0 || index >= myLength )
      throw new IndexOutOfBoundsException( "Attempt to access index " + index + " when valid range is 0.." + (myLength - 1) );

    int blockIndex = myStart.myBlockIndex + index;
    int mapIndex = myStart.myMapIndex;

    if ( blockIndex >= BLOCK_SIZE )
      {
      int jump = blockIndex / BLOCK_SIZE;
      mapIndex += jump;
      blockIndex %= BLOCK_SIZE;
      }
    else if ( blockIndex < 0 )
      {
      int jump = ( BLOCK_SIZE - 1 - blockIndex ) / BLOCK_SIZE;
      mapIndex -= jump;
      blockIndex += jump * BLOCK_SIZE;
      }

    return myMap[ mapIndex ][ blockIndex ];
    }

  /**
   * Set the element at the specified index to a particular object.
   * @param index The index.
   * @param object The object.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized void put( int index, Object object )
    {
    if ( index < 0 || index >= myLength )
      throw new IndexOutOfBoundsException( "Attempt to access index " + index + " when valid range is 0.." + (myLength - 1) );

    int blockIndex = myStart.myBlockIndex + index;
    int mapIndex = myStart.myMapIndex;

    if ( blockIndex >= BLOCK_SIZE )
      {
      int jump = blockIndex / BLOCK_SIZE;
      mapIndex += jump;
      blockIndex %= BLOCK_SIZE;
      }
    else if ( blockIndex < 0 )
      {
      int jump = ( BLOCK_SIZE - 1 - blockIndex ) / BLOCK_SIZE;
      mapIndex -= jump;
      blockIndex += jump * BLOCK_SIZE;
      }

    myMap[ mapIndex ][ blockIndex ] = object;
    }

  /**
   * Swap my contents with another Deque.
   * @param deque The Deque that I will swap my contents with.
   */
  public synchronized void swap( Deque deque )
    {
    synchronized( deque )
      {
      DequeIterator tmpStart = myStart;
      myStart = deque.myStart;
      myStart.myDeque = this;
      deque.myStart = tmpStart;
      deque.myStart.myDeque = deque;

      DequeIterator tmpFinish = myFinish;
      myFinish = deque.myFinish;
      myFinish.myDeque = this;
      deque.myFinish = tmpFinish;
      deque.myFinish.myDeque = deque;

      int tmpLength = myLength;
      myLength = deque.myLength;
      deque.myLength = tmpLength;

      Object[][] tmpMap = myMap;
      myMap = deque.myMap;
      deque.myMap = tmpMap;
      }
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

    return remove( myStart.copy( index ) );
    }

  /**
   * Remove the element at a particular position.
   * @param e An Enumeration positioned at the element to remove.
   * @return The object removed.
   * @exception IllegalArgumentException if the Enumeration isn't a
   * DequeIterator for this Deque object.
   */
  public synchronized Object remove( Enumeration e )
    {
    if ( ! (e instanceof DequeIterator) )
      throw new IllegalArgumentException( "Enumeration not a DequeIterator" );

    if ( ((DequeIterator)e).myDeque != this )
      throw new IllegalArgumentException( "Enumeration not for this Deque" );

    DequeIterator pos = (DequeIterator)e;
    Object retval = pos.get();
    DequeIterator tmp = pos.copy( 1 );

    if ( myStart.distance( pos ) < pos.distance( myFinish ) )
      {
      copy( tmp, myFinish, pos );
      popBack();
      }
    else
      {
      copyBackward( myStart, pos, tmp );
      popFront();
      }

    return retval;
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
    return remove( myStart.copy( first ), myStart.copy( last + 1 ) );
    }

  /**
   * Remove the elements in the range [ first..last ).
   * @param first An Enumeration positioned at the first element to remove.
   * @param last An Enumeration positioned immediately after the last element to remove.
   * @return The number of elements removed.
   * @exception IllegalArgumentException if the Enumeration isn't a
   * DequeIterator for this Deque object.
   */
  public synchronized int remove( Enumeration first, Enumeration last )
    {
    if ( ( ! (first instanceof DequeIterator) ) ||
        ( ! (last instanceof DequeIterator) ) )
      throw new IllegalArgumentException( "Enumeration not a DequeIterator" );

    if ( ( ((DequeIterator)first).myDeque != this ) ||
        ( ((DequeIterator)last).myDeque != this ) )
      throw new IllegalArgumentException( "Enumeration not for this Deque" );

    DequeIterator begin = (DequeIterator)first;
    DequeIterator end = (DequeIterator)last;

    int n = begin.distance( end );
    int count = n;

    if ( end.distance( myFinish ) > myStart.distance( begin ) )
      {
      copyBackward( myStart, begin, end );

      while ( n-- > 0 )
        popFront();
      }
    else
      {
      copy( end, myFinish, begin );

      while ( n-- > 0 )
        popBack();
      }

    return count;
    }

  /**
   * Insert an object at a particular index and return an iterator
   * positioned at the new element.
   * @param index The index of the element that the object will be inserted immediately before.
   * @param object The object to insert.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized DequeIterator insert( int index, Object object )
    {
    if ( index < 0 || index > myLength )
      throw new IndexOutOfBoundsException( "Attempt to insert at index " + index + " when valid range is 0.." + myLength );

    return insert( myStart.copy( index ), object );
    }

  /**
   * Insert an object at a particular position and return an iterator
   * positioned at the new element.
   * @param pos An iterator positioned at the element that the object will be inserted immediately before.
   * @param object The object to insert.
   */
  public synchronized DequeIterator insert( DequeIterator pos, Object value )
    {
    if ( pos.equals( myStart ) )
      {
      pushFront( value );
      return new DequeIterator( myStart );
      }
    else if ( pos.equals( myFinish ) )
      {
      pushBack( value );
      return myFinish.copy( -1 );
      }
    else
      {
      int index = myStart.distance( pos );

      if ( pos.distance( myFinish ) > index )
        {
        pushFront( myStart.get() );
        copy( myStart.copy( 2 ), myStart.copy( index + 1 ), myStart.copy( 1 ) );
        DequeIterator i = myStart.copy( index );
        i.put( value );
        return i;
        }
      else
        {
        DequeIterator i2 = myFinish.copy( -1 );
        pushBack( i2.get() );
        DequeIterator i = myStart.copy( index );
        copyBackward( i, myFinish.copy( -2 ), myFinish.copy( -1 ) );
        i.put( value );
        return i;
        }
      }
    }

  /**
   * Insert multiple objects at a particular index.
   * @param index The index of the element that the objects will be inserted immediately before.
   * @param object The object to insert.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   * @exception java.lang.IllegalArgumentException If the number of objects to insert is negative.
   */
  public synchronized void insert( int index, int n, Object value )
    {
    if ( n < 0 )
      throw new IllegalArgumentException( "Attempt to insert a negative n1umber of objects." );

    if ( index < 0 || index > myLength )
      throw new IndexOutOfBoundsException( "Attempt to insert at index " + index + " when valid range is 0.." + myLength );

    insert( myStart.copy( index ), n , value );
    }

  /**
   * Insert multiple objects at a particular position.
   * @param pos An iterator positioned at the element that the objects will be inserted immediately before.
   * @param n The number of objects to insert.
   * @param object The object to insert.
   * @exception java.lang.IllegalArgumentException If the number of objects to insert is negative.
   */
  public synchronized void insert( DequeIterator pos, int n, Object value )
    {
    if ( n < 0 )
      throw new IllegalArgumentException( "Attempt to insert a negative number of objects" );

    if ( n == 0 )
      return;

    int left = myStart.distance( pos ); // Number to left of insertion point.
    int right = pos.distance( myFinish ); // Number to right of insertion point.

    if ( right > left )
      {
      if ( n > left )
        {
        int m = n - left;

        while ( m-- > 0 )
          pushFront( value );

        for ( int j = 1; j <= left; j++ )
          pushFront( at( n - 1 ) );

        fill( myStart.copy( n ), myStart.copy( n + left ), value );
        }
      else
        {
        for ( int j = 1; j <= n; j++ )
          pushFront( at( n - 1 ) );

        DequeIterator i = myStart.copy( n + left );
        copy( myStart.copy( n + n ), i, myStart.copy( n ) );
        fill( myStart.copy( left ), i, value );
        }
      }
    else
      {
      int oldSize = size(); // Size of deque before insertion.

      if ( n > right )
        {
        int m = n - right;

        while ( m-- > 0 )
          pushBack( value );

        for ( int j = left; j < oldSize; j++ )
          pushBack( at( j ) );

        fill( myStart.copy( left ), myStart.copy( oldSize ), value );
        }
      else
        {
        int index = oldSize - n;

        for ( int j = index; j < oldSize; j++ )
          pushBack( at( j ) );

        DequeIterator i = myStart.copy( left );
        copyBackward( i, myStart.copy( index ), myStart.copy( oldSize ) );
        fill( i, myStart.copy( left + n ), value );
        }
      }
    }

  /**
   * Insert a sequence of objects at a particular index.
   * @param pos The index of the element that the objects will be inserted immediately before.
   * @param first An iterator positioned at the first element to insert.
   * @param last An iterator positioned immediately after the last element to insert.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized void insert( int index, BidirectionalIterator first, BidirectionalIterator last )
    {
    if ( index < 0 || index > myLength )
      throw new IndexOutOfBoundsException( "Attempt to insert at index " + index + " when valid range is 0.." + myLength );

    insert( myStart.copy( index ), first, last );
    }

  /**
   * Insert a sequence of objects at a particular location.
   * @param pos The location of the element that the objects will be inserted immediately before.
   * @param first An iterator positioned at the first element to insert.
   * @param last An iterator positioned immediately after the last element to insert.
   */
  public synchronized void insert( DequeIterator pos, BidirectionalIterator first, BidirectionalIterator last )
    {
    int n = first.distance( last );
    int left = myStart.distance( pos ); // Number to left of insertion point.
    int right = pos.distance( myFinish ); // Number to right of insertion point.

    if ( right > left )
      {
      if ( n > left )
        {
        BidirectionalIterator m = (BidirectionalIterator)last.clone();
        m.retreat( left );
        BidirectionalIterator q = (BidirectionalIterator)m.clone();

        while ( !m.equals( first ) )
          {
          m.retreat();
          pushFront( m.get() );
          }

        for ( int j = 1; j <= left; j++ )
          pushFront( at( n - 1 ) );

        copy( q, last, myStart.copy( n ) );
        }
      else
        {
        for ( int j = 1; j <= n; j++ )
          pushFront( at( n - 1 ) );

        copy( myStart.copy( n + n ), myStart.copy( n + left ), myStart.copy( n ) );
        copy( first, last, myStart.copy( left ) );
        }
      }
    else
      {
      int oldSize = size(); // Size of deque before insertion.

      if ( n > right )
        {
        BidirectionalIterator m = (BidirectionalIterator) first.clone();
        m.advance( right );
        BidirectionalIterator q = (BidirectionalIterator) m.clone();

        while ( !m.equals( last ) )
          pushBack( m.nextElement() );

        for ( int j = left; j < oldSize; j++ )
          pushBack( at( j ) );

        copy( first, q, myStart.copy( left ) );
        }
      else
        {
        int index = oldSize - n;

        for ( int j = index; j < oldSize; j++ )
          pushBack( at( j ) );

        DequeIterator i = myStart.copy( left );
        copyBackward( i, myStart.copy( index ), myStart.copy( oldSize ) );
        copy( first, last, myStart.copy( left ) );
        }
      }
    }

  /**
   * Remove all elements that match a particular object and return the numbers of
   * objects that were removed.
   * @param object The object to remove.
   * @return The number of objects removed.
   */
  public int remove( Object object )
    {
    return remove( 0, myLength - 1, object );
    }

  /**
   * Remove at most a given number of elements that match a particular 
   * object and return the number of
   * objects that were removed.
   * @param object The object to remove.
   * @param count The maximum number of objects to remove.
   * @return The number of objects removed.
   */
  public synchronized int remove( Object object, int count )
    {
    int removed = 0;
    while ( count > 0 )
      {
      int i = indexOf( object );
      if ( i < 0 )
        break;

      --count;
      ++removed;
      remove( i );
      }
    return removed;
    }

  /**
   * Remove all elements within a range of indices that match a particular object
   * and return the number of objects that were removed.
   * @param first The index of the first object to consider.
   * @param last The index of the last object to consider.
   * @param object The object to remove.
   * @return The number of objects removed.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public synchronized int remove( int first, int last, Object object )
    {
    if ( last < first )
      return 0;

    checkRange( first, last );
    DequeIterator firstx = myStart.copy( first );
    DequeIterator lastx = myStart.copy( last + 1 );
    DequeIterator finish = (DequeIterator)Algos.Removing.remove( firstx, lastx, object );
    int n = finish.distance( lastx );
    remove( finish, lastx );
    return n;
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
   * Replace all elements within a range of indices that match a particular object
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
    return Algos.Replacing.replace( myStart.copy( first ), myStart.copy( last + 1 ), oldValue, newValue );
    }

  /**
   * Return the number of objects that match a particular value.
   * @param object The object to count.
   */
  public int count( Object object )
    {
    if ( size() == 0 )
      return 0;
    return count( 0, myLength - 1, object );
    }

  /**
   * Return the number of objects within a particular range of indices that match a
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
    return Algos.Counting.count( myStart.copy( first ), myStart.copy( last + 1 ), object );
    }

  /**
   * Return the index of the first object that matches a particular value, or -1
   * if the object is not found.
   * @param object The object to find.
   */
  public int indexOf( Object object )
    {
    return indexOf( myStart, myFinish, object );
    }

  /**
   * Return the index of the first object within a range of indices that match a
   * particular object, or -1 if the object is not found.
   * @param first The index of the first object to consider.
   * @param last The index of the last object to consider.
   * @param object The object to find.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public int indexOf( int first, int last, Object object )
    {
    if ( last < first )
      return -1;

    checkRange( first, last );
    DequeIterator end = myStart.copy( last + 1 );
    return indexOf( myStart.copy( first ), end, object );
    }

  synchronized int indexOf( DequeIterator first, DequeIterator last, Object object )
    {
    DequeIterator i = (DequeIterator)Algos.Finding.find( first, last, object );
    return i.equals( last ) ? -1 : myStart.distance( i );
    }

  /**
   * Return true if I contain a particular object.
   * @param object The object in question.
   */
  public boolean contains( Object object )
    {
    return indexOf( object ) != -1;
    }

  private void growMap()
    {
    // Create space for new map that is twice the size of the current map.
    int newMapSize = myMap.length * 2;
    Object[][] tmp = new Object[ newMapSize ][];

    // Copy the old map to the new map.
    int i = newMapSize / 4;
    int count = myFinish.myMapIndex - myStart.myMapIndex + 1;
    System.arraycopy( myMap, myStart.myMapIndex, tmp, i, count );

    // Update the start, finish, and map variables.
    myStart.myMapIndex = i;
    myFinish.myMapIndex = i + count - 1;
    myMap = tmp;
    }

  private void createMap()
    {
    myMap = new Object[ pageSize ][];
    int mapIndex = myMap.length / 2;
    myMap[ mapIndex ] = new Object[ BLOCK_SIZE ];
    int blockIndex = BLOCK_SIZE / 2;
    myStart.myBlockIndex = blockIndex;
    myStart.myMapIndex = mapIndex;
    myFinish.myBlockIndex = blockIndex;
    myFinish.myMapIndex = mapIndex;
    }

  private void checkRange( int lo, int hi )
    {
    if ( lo < 0 || lo >= myLength )
      throw new IndexOutOfBoundsException( "Attempt to access index " + lo + " when valid range is 0.." + (myLength - 1) );

    if ( hi < 0 || hi >= myLength )
      throw new IndexOutOfBoundsException( "Attempt to access index " + hi + " when valid range is 0.." + (myLength - 1) );
    }

  /**
   * @see com.objectspace.jgl.algorithms.Copying#copy(com.objectspace.jgl.InputIterator,com.objectspace.jgl.InputIterator,com.objectspace.jgl.OutputIterator)
   */
  private static DequeIterator copy( BidirectionalIterator first, BidirectionalIterator last, DequeIterator result )
    {
    BidirectionalIterator firstx = (BidirectionalIterator)first.clone();
    DequeIterator resultx = (DequeIterator)result.clone();

    while ( !firstx.equals( last ) )
      {
      resultx.put( firstx.nextElement() );
      resultx.advance();
      }

    return resultx;
    }

  /**
   * @see com.objectspace.jgl.algorithms.Copying#copyBackward(com.objectspace.jgl.InputIterator,com.objectspace.jgl.InputIterator,com.objectspace.jgl.OutputIterator)
   */
  private static void copyBackward( BidirectionalIterator first, BidirectionalIterator last, DequeIterator result )
    {
    BidirectionalIterator lastx = (BidirectionalIterator)last.clone();
    DequeIterator resultx = (DequeIterator)result.clone();

    while ( !first.equals( lastx ) )
      {
      resultx.retreat();
      lastx.retreat();
      resultx.put( lastx.get() );
      }
    }
  
  /**
   * @see com.objectspace.jgl.algorithms.Filling#fill(com.objectspace.jgl.ForwardIterator,com.objectspace.jgl.ForwardIterator,java.lang.Object)
   */
  private static void fill( DequeIterator first, DequeIterator last, Object object )
    {
    while ( !first.equals( last ) )
      {
      first.put( object );
      first.advance();
      }
    }

  static final long serialVersionUID = 8175162724553274000L;
  }
