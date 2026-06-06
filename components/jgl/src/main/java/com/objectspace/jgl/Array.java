// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.util.Enumeration;
import java.lang.Math;

/**
 * An Array is a sequence that is very similar to a regular array except that it
 * can expand to accomodate new elements.
 * <p>
 * An Array is the simplest kind of JGL container. In addition to the common container
 * functions described earlier in this book, an Array includes functions for accessing
 * its extremities, appending, inserting, erasing, and adjusting its capacity.
 * <p>
 * The underlying architecture of Arrays makes them ideal for storing elements whose
 * order is significant and where fast numeric indexing is important. Inserting elements
 * anywhere except at the end of an Array is slow, so they should not be used where
 * this kind of operation is common. If inserting is common, consider using a List or
 * a Deque instead.
 * <p>
 * The implementation store elements in a contiguous linear memory space so that
 * index-based access is very quick. When an Array's originally allocated memory space
 * is exceeded, its elements are copied into a new memory space that is larger than the
 * old space and then the old space is deallocated. 
 * <p>
 * If an insertion causes reallocation, all iterators and references are invalidated;
 * otherwise, only the iterators and references after the insertion point are invalidated.
 * Inserting a single element into an Array is linear in the distance from the insertion
 * point to the end of the array.  Insertion of multiple elements
 * into an Array with a single call of the insert member is linear in the sum of the
 * number of elements plus the distance to the end of the Array. In other words, it is
 * much faster to insert many elements into the middle of an Array at once than to do the
 * insertion one at a time.
 * <p>
 * A remove invalidates all of the iterators and references after the point of the remove.
 * <p>
 * @see com.objectspace.jgl.Sequence
 * @see com.objectspace.jgl.examples.ArrayExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class Array implements Sequence
  {
  Object myStorage[]; // My storage.
  int myLength; // The number of objects I currently contain.
  static final int DEFAULT_SIZE = 10;
  static final int THRESHOLD = 2000;
  static final int MULTIPLIER = 2;

  /**
   * Construct myself to be an empty Array.
   */
  public Array()
    {
    myStorage = new Object[ DEFAULT_SIZE ];
    }

  /**
   * Construct myself to contain a specified number of null elements.
   * @param size The number of elements to contain.
   * @exception java.lang.IllegalArgumentException If size is negative.
   */
  public Array( int size )
    {
    if ( size < 0 )
      throw new IllegalArgumentException( "Attempt to create an Array with a negative size" );

    myLength = size;
    myStorage = new Object[ myLength ];
    }

  /**
   * Construct myself to contain a specified number of elements set to
   * a particular object.
   * @param size The number of elements to contain.
   * @param object The initial value of each element.
   * @exception java.lang.IllegalArgumentException If size is negative.
   */
  public Array( int size, Object object )
    {
    this( size );

    for ( int i = 0; i < myLength; i++ )
      myStorage[ i ] = object;
    }

  /**
   * Construct myself to use a specified array as my initial storage.
   * @param The array to use as initial storage.
   */
  public Array( Object[] array )
    {
    synchronized( array )
      {
      myLength = array.length;
      myStorage = new Object[ myLength ];
      System.arraycopy( array, 0, myStorage, 0, myLength );
      }
    }

  /**
   * Construct myself to be a shallow copy of an existing Array.
   * @param array The Array to copy.
   */
  public Array( Array array )
    {
    synchronized( array )
      {
      myLength = array.myLength;
      myStorage = new Object[ myLength ];
      System.arraycopy( array.myStorage, 0, myStorage, 0, myLength );
      }
    }

  /**
   * Return a shallow copy of myself.
   */
  public synchronized Object clone()
    {
    return new Array( this );
    }

  /**
   * Return true if I'm equal to another object.
   * @param object The object to compare myself against.
   */
  public boolean equals( Object object )
    {
    return object instanceof Array && equals( (Array)object );
    }

  /**
   * Return true if I contain the same items in the same order as
   * another Array. Use equals() to compare the individual elements.
   * @param array The Array to compare myself against.
   */
  public synchronized boolean equals( Array array )
    {
    synchronized( array )
      {
      return Algos.Comparing.equal( this, array );
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
    return Algos.Printing.toString( this, "Array" );
    }

  /**
   * Become a shallow copy of an existing Array.
   * @param array The Array that I shall become a shallow copy of.
   */
  public synchronized void copy( Array array )
    {
    if ( this == array )
      return;

    synchronized( array )
      {
      if ( array.myLength > myStorage.length )
        {
        myStorage = new Object[ array.myLength ];
        System.arraycopy( array.myStorage, 0, myStorage, 0, array.myLength );
        }
      else if ( myLength > array.myLength )
        {
        System.arraycopy( array.myStorage, 0, myStorage, 0, array.myLength );

        for ( int i = array.myLength; i < myLength; i++ )
          myStorage[ i ] = null; // To allow garbage collection.
        }
      else
        {
        System.arraycopy( array.myStorage, 0, myStorage, 0, array.myLength );
        }

      myLength = array.myLength;
      }
    }

  /**
   * Copy my elements into the specified array.
   * The number of items that are copied is equal to the smaller of my
   * length and the size of the specified array.
   * @param array The array that I shall copy my elements into.
   */
  public synchronized void copyTo( Object[] array )
    {
    synchronized( array )
      {
      if ( myLength < array.length )
        System.arraycopy( myStorage, 0, array, 0, myLength );
      else
        System.arraycopy( myStorage, 0, array, 0, array.length );
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
   * Return the number of elements that I contain without allocating more
   * internal storage.
   */
  public int capacity()
    {
    return myStorage.length;
    }

  /**
   * Return my last item.
   * @exception com.objectspace.jgl.InvalidOperationException If the Array is empty.
   */
  public synchronized Object back()
    {
    if ( myLength == 0 )
      throw new InvalidOperationException( "Array is empty" );

    return myStorage[ myLength - 1 ];
    }

  /**
   * Return my first item.
   * @exception com.objectspace.jgl.InvalidOperationException If the Array is empty.
   */
  public synchronized Object front()
    {
    if ( myLength == 0 )
      throw new InvalidOperationException( "Array is empty" );

    return myStorage[ 0 ];
    }

  /**
   * Return the element at the specified index.
   * @param index The index.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized Object at( int index )
    {
    checkIndex( index, myLength );
    return myStorage[ index ];
    }

  /**
   * Set the element at the specified index to a particular object.
   * @param index The index.
   * @param object The object.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized void put( int index, Object object )
    {
    checkIndex( index, myLength );
    myStorage[ index ] = object;
    }

  /**
   * Remove all of my elements.
   */
  public synchronized void clear()
    {
    myStorage = new Object[ DEFAULT_SIZE ];
    myLength = 0;
    }

  /**
   * Remove the element at a particular position.
   * @param pos An enumeration positioned at the element to remove.
   * @exception IllegalArgumentException is the Enumeration isn't an
   * ArrayIterator for this Array object.
   */
  public Object remove( Enumeration pos )
    {
    if ( ! (pos instanceof ArrayIterator) )
      throw new IllegalArgumentException( "Enumeration not an ArrayIterator" );

    if ( ((ArrayIterator)pos).myArray != this )
      throw new IllegalArgumentException( "Enumeration not for this Array " );

    Object retval = ( (ArrayIterator)pos ).get();
    remove( ((ArrayIterator)pos).myIndex );
    return retval;
    }

  /**
   * Remove the element at a particular index.
   * @param index The index of the element to remove.
   * @return The object removed.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized Object remove( int index )
    {
    checkIndex( index, myLength );
    Object retval = myStorage[ index ];
    System.arraycopy( myStorage, index + 1, myStorage, index, myLength - index - 1 );

    myStorage[ --myLength ] = null;
    return retval;
    }

  /**
   * Remove the elements in the specified range.
   * @param first An Enumeration positioned at the first element to remove.
   * @param last An Enumeration positioned immediately after the last element to remove.
   * @return The number of elements removed.
   * @exception IllegalArgumentException is the Enumeration isn't an
   * ArrayIterator for this Array object.
   */
  public int remove( Enumeration first, Enumeration last )
    {
    if ( !( first instanceof ArrayIterator && last instanceof ArrayIterator ) )
      throw new IllegalArgumentException( "Enumeration not an ArrayIterator" );

    if ( ( (ArrayIterator)first ).myArray != this || ( (ArrayIterator)last ).myArray != this )
      throw new IllegalArgumentException( "Enumeration not for this Array " );

    return remove( ( (ArrayIterator)first ).myIndex, ( (ArrayIterator)last ).myIndex - 1 );
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

    checkRange( first, last, myLength );
    int amount = last - first + 1;
    System.arraycopy( myStorage, last + 1, myStorage, first, myLength - last - 1 );

    for ( int i = myLength - amount; i < myLength; i++ )
      myStorage[ i ] = null;

    myLength -= amount;
    return amount;
    }

  /**
   * Remove and return my last element.
   * @exception com.objectspace.jgl.InvalidOperationException If the Array is empty.
   */
  public synchronized Object popBack()
    {
    if ( myLength == 0 )
      throw new InvalidOperationException( "Array is empty" );

    Object r = myStorage[ --myLength ];
    myStorage[ myLength ] = null;
    return r;
    }

  /**
   * Add an object after my last element.  Returns null.
   * This function is a synonym for pushBack().
   * @param object The object to add.
   */
  public synchronized Object add( Object object )
    {
    if ( myLength == myStorage.length )
      {
      Object[] tmp = getNextStorage( 1 );
      System.arraycopy( myStorage, 0, tmp, 0, myLength );
      myStorage = tmp;
      }

    myStorage[ myLength++ ] = object;
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
   * Insert an object at a particular position and return an iterator
   * positioned at the new element.
   * @param pos An iterator positioned at the element that the object will be inserted immediately before.
   * @param object The object to insert.
   */
  public ArrayIterator insert( ArrayIterator pos, Object object )
    {
    insert( pos.myIndex, object );
    return new ArrayIterator( this, pos.myIndex );
    }

  /**
   * Insert an object at a particular index.
   * @param index The index of the element that the object will be inserted immediately before.
   * @param object The object to insert.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized void insert( int index, Object object )
    {
    checkIndex( index, myLength + 1 );
    if ( myLength != myStorage.length )
      {
      if ( index != myLength )
        System.arraycopy( myStorage, index, myStorage, index + 1, myLength - index );
      }
    else
      {
      Object[] tmp = getNextStorage( 1 );
      System.arraycopy( myStorage, 0, tmp, 0, index );
      System.arraycopy( myStorage, index, tmp, index + 1, myLength - index );
      myStorage = tmp;
      }

    myStorage[ index ] = object;
    ++myLength;
    }

  /**
   * Insert multiple objects at a particular position.
   * @param pos An iterator positioned at the element that the objects will be inserted immediately before.
   * @param n The number of objects to insert.
   * @param object The object to insert.
   */
  public void insert( ArrayIterator pos, int n, Object object )
    {
    insert( pos.myIndex, n, object );
    }

  /**
   * Insert multiple objects at a particular index.
   * @param index The index of the element that the objects will be inserted immediately before.
   * @param object The object to insert.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   * @exception java.lang.IllegalArgumentException If the number of objects is negative.
   */
  public synchronized void insert( int index, int n, Object object )
    {
    checkIndex( index, myLength + 1 );
    if ( n < 0 )
      throw new IllegalArgumentException( "Attempt to insert a negative number of objects." );

    if ( n == 0 )
      return;

    if ( myStorage.length - myLength >= n )
      {
      System.arraycopy( myStorage, index, myStorage, index + n, myLength - index );
      }
    else
      {
      Object[] tmp = getNextStorage( n );
      System.arraycopy( myStorage, 0, tmp, 0, index );
      System.arraycopy( myStorage, index, tmp, index + n, myLength - index );
      myStorage = tmp;
      }

    for ( int i = index; i < index + n; i++ )
      myStorage[ i ] = object;

    myLength += n;
    }

  /**
   * Insert a sequence of objects at a particular location.
   * @param pos The location of the element that the objects will be inserted immediately before.
   * @param first An iterator positioned at the first element to insert.
   * @param last An iterator positioned immediately after the last element to insert.
   */
  public void insert( ArrayIterator pos, ForwardIterator first, ForwardIterator last )
    {
    insert( pos.myIndex, first, last );
    }

  /**
   * Insert a sequence of objects at a particular index.
   * @param index The index of the element that the objects will be inserted immediately before.
   * @param first An iterator positioned at the first element to insert.
   * @param last An iterator positioned immediately after the last element to insert.
   */
  public synchronized void insert( int index, ForwardIterator first, ForwardIterator last )
    {
    checkIndex( index, myLength + 1 );
    int n = first.distance( last );

    if ( n == 0 )
      return;

    ForwardIterator firstx = (ForwardIterator) first.clone();

    if ( myStorage.length - myLength >= n )
      {
      System.arraycopy( myStorage, index, myStorage, index + n, myLength - index );
      }
    else
      {
      Object[] tmp = getNextStorage( n );
      System.arraycopy( myStorage, 0, tmp, 0, index );
      System.arraycopy( myStorage, index, tmp, index + n, myLength - index );
      myStorage = tmp;
      }

    for ( int i = index; i < index + n; i++ )
      myStorage[ i ] = firstx.nextElement();

    myLength += n;
    }

  /**
   * Swap my contents with another Array.
   * @param array The Array that I will swap my contents with.
   */
  public synchronized void swap( Array array )
    {
    synchronized( array )
      {
      int oldSize = myLength;
      Object oldStorage[] = myStorage;

      myLength = array.myLength;
      myStorage = array.myStorage;

      array.myLength = oldSize;
      array.myStorage = oldStorage;
      }
    }

  /**
   * Return an Enumeration of my components.
   */
  public synchronized Enumeration elements()
    {
    return new ArrayIterator( this, 0 );
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
  public ForwardIterator finish()
    {
    return end();
    }

  /**
   * Return an iterator positioned at my first item.
   */
  public synchronized ArrayIterator begin()
    {
    return new ArrayIterator( this, 0 );
    }

  /**
   * Return an iterator positioned immediately after my last item.
   */
  public synchronized ArrayIterator end()
    {
    return new ArrayIterator( this, myLength );
    }

  /**
   * If my storage space is currently larger than my total number of elements,
   * reallocate the elements into a storage space that is exactly the right size.
   */
  public synchronized void trimToSize()
    {
    if ( myLength < myStorage.length )
      {
      Object oldData[] = myStorage;
      myStorage = new Object[ myLength ];
      System.arraycopy( oldData, 0, myStorage, 0, myLength );
      }
    }

  /**
   * Pre-allocate enough space to hold a specified number of elements.
   * This operation does not change the value returned by size().
   * @param n The amount of space to pre-allocate.
   * @exception java.lang.IllegalArgumentException If the specified size is negative.
   */
  public synchronized void ensureCapacity( int n )
    {
    if ( n < 0 )
      throw new IllegalArgumentException( "Attempt to reserve a negative size." );

    if ( myStorage.length < n )
      {
      Object[] tmp = new Object[ n ];

      if ( myLength > 0 )
        System.arraycopy( myStorage, 0, tmp, 0, myLength );

      myStorage = tmp;
      }
    }

  /**
   * Remove and return my first element.
   * @exception com.objectspace.jgl.InvalidOperationException If the Array is empty.
   */
  public synchronized Object popFront()
    {
    if ( myLength == 0 )
      throw new InvalidOperationException( "Array is empty" );

    Object result = myStorage[ 0 ];
    remove( 0 );
    return result;
    }

  /**
   * Insert an object in front of my first element.
   * @param object The object to insert.
   */
  public void pushFront( Object object )
    {
    insert( 0, object );
    }

  /**
   * Remove all elements that match a particular object and return the number of
   * objects that were removed.
   * @param object The object to remove.
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
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public synchronized int remove( int first, int last, Object object )
    {
    if ( last < first )
      return 0;

    checkRange( first, last, myLength );
    ArrayIterator firstx = new ArrayIterator( this, first );
    ArrayIterator lastx = new ArrayIterator( this, last + 1 );
    ArrayIterator finish = (ArrayIterator)Algos.Removing.remove( firstx, lastx, object );
    return remove( finish.myIndex, last );
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

    checkRange( first, last, myLength );
    return Algos.Replacing.replace( new ArrayIterator( this, first ), new ArrayIterator( this, last + 1 ), oldValue, newValue );
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

    checkRange( first, last, myLength );
    return Algos.Counting.count( new ArrayIterator( this, first ), new ArrayIterator( this, last + 1 ), object );
    }

  /**
   * Return the index of the first object that matches a particular value, or -1
   * if the object is not found.
   * @param object The object to find.
   */
  public int indexOf( Object object )
    {
    return indexOf( 0, myLength - 1, object );
    }

  /**
   * Return the index of the first object within a range of indices that match a
   * particular object, or -1 if the object is not found.
   * @param first The index of the first object to consider.
   * @param last The index of the last object to consider.
   * @param object The object to find.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public synchronized int indexOf( int first, int last, Object object )
    {
    if ( last < first )
      return -1;

    checkRange( first, last, myLength );
    int index = ( (ArrayIterator)Algos.Finding.find( new ArrayIterator( this, first ), new ArrayIterator( this, last + 1 ), object ) ).myIndex;
    return index == last + 1 ? -1 : index;
    }

  /**
   * Sets the size of the Array. if the size shrinks, the extra elements (at
   * the end of the array) are lost; if the size increases, the new elements
   * are set to null.
   * @param newSize The new size of the Array.
   */
  public synchronized void setSize( int newSize )
    {
    if ( newSize < 0 )
      throw new IllegalArgumentException( "Attempt to become a negative size." );
    if ( myLength > newSize )
      remove( newSize, myLength - 1 );
    else if ( myLength < newSize )
      insert( myLength, newSize - myLength, null );
    }

  /**
   * Return true if I contain a particular object.
   * @param object The object in question.
   */
  public boolean contains( Object object )
    {
    return indexOf( object ) != -1;
    }

  final protected static void checkIndex( int i, int size )
    {
    if ( i < 0 || i >= size )
      throw new IndexOutOfBoundsException
        ( 
        "Attempt to access index " + i + "; valid range is 0.." + ( size - 1 )
        );
    }

  final protected static void checkRange( int lo, int hi, int size )
    {
    checkIndex( lo, size );
    checkIndex( hi, size );
    }

  final static int getNextSize( int cursize )
    {
    // multiply by MULTIPLIER until THRESHOLD reached; increment by THRESHOLD
    // from then on
    int newSize = cursize > THRESHOLD
      ? cursize + THRESHOLD
      : cursize * MULTIPLIER;
    return Math.max( 1, newSize );
    }

  /**
   * Ensure that there is enough space for at least n new objects.
   */
  private Object[] getNextStorage( int n )
    {
    int newSize = Math.max( getNextSize( myLength ), myLength + n );
    Object[] tmp = new Object[ newSize ];
    return tmp;
    }

  static final long serialVersionUID = 2600370816661330188L;
  }
