// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.adapters;

import com.objectspace.jgl.*;
import java.util.Enumeration;
import java.lang.Math;

/**
 * A LongBuffer is a sequence that is very similar to a regular 
 * LongArray, except that it can expand to accomodate new elements.
 * <p>
 * The implementation store elements in a contiguous linear memory space 
 * so that index-based access is very quick. When an LongBuffer's originally 
 * allocated memory space is exceeded, its elements are copied into a new 
 * memory space that is large enough to accomodate everything.
 * <p>
 * If an insertion causes reallocation, all iterators and references are 
 * invalidated; otherwise, only the iterators and references after the 
 * insertion point are invalidated.
 * <p>
 * A remove invalidates all of the iterators and references after the point 
 * of the remove.
 * <p>
 * @see com.objectspace.jgl.adapters.LongArray
 * @see com.objectspace.jgl.adapters.LongIterator
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class LongBuffer implements Sequence
  {
  final static long defaultValue = 0;
  long storage[]; // My storage.
  int length; // The number of objects I currently contain.

  /**
   * Construct myself to be an empty LongBuffer.
   */
  public LongBuffer()
    {
    clear();
    }

  /**
   * Construct myself to contain a specified number of null elements.
   * @param size The number of elements to contain.
   * @exception java.lang.IllegalArgumentException If size is negative.
   */
  public LongBuffer( int size )
    {
    if ( size < 0 )
      throw new IllegalArgumentException
        ( 
        "Attempt to create an LongBuffer with a negative size" 
        );

    length = size;
    storage = new long[ length ];
    }

  /**
   * Construct myself to contain a specified number of elements set to
   * a particular object.
   * @param size The number of elements to contain.
   * @param object The initial value of each element.
   * @exception java.lang.IllegalArgumentException If size is negative.
   */
  public LongBuffer( int size, long object )
    {
    this( size );
    for ( int i = 0; i < length; i++ )
      storage[ i ] = object;
    }

  /**
   * Construct myself to use a specified array as my initial storage.
   * @param The array to use as initial storage.
   */
  public LongBuffer( long array[] )
    {
    this( array, true );
    }

  LongBuffer( long array[], boolean copyBuffer )
    {
    synchronized( array )
      {
      length = array.length;
      if ( copyBuffer )
        {
        storage = new long[ length ];
        System.arraycopy( array, 0, storage, 0, length );
        }
      else
        storage = array;
      }
    }

  /**
   * Construct myself to be a copy of an existing LongBuffer.
   * @param array The LongBuffer to copy.
   */
  public LongBuffer( LongBuffer array )
    {
    this( array.storage );
    }

  /**
   * Return a shallow copy of myself.
   */
  public synchronized Object clone()
    {
    return new LongBuffer( this );
    }

  /**
   * Return true if I'm equal to another object.
   * @param object The object to compare myself against.
   */
  public boolean equals( Object object )
    {
    return 
      object instanceof LongBuffer && equals( (LongBuffer)object )
      || object instanceof LongArray && equals( (LongArray)object );
    }

  /**
   * Return true if I contain the same items in the same order as
   * another LongBuffer.
   * @param array The LongBuffer to compare myself against.
   */
  public boolean equals( LongBuffer buffer )
    {
    return equals( new LongArray( buffer.storage ) );
    }

  /**
   * Return true if I contain the same items in the same order as
   * a LongArray.
   * @param array The LongArray to compare myself against.
   */
  public synchronized boolean equals( LongArray array )
    {
    return array.equals( storage );
    }

  /**
   * Return true if I contain the same items in the same order as
   * a native array of longs.
   * @param array The array to compare myself against.
   */
  public boolean equals( long array[] )
    {
    return equals( new LongArray( array ) );
    }

  /**
   * Return a string that describes me.
   */
  public synchronized String toString()
    {
    return Algorithms.Printing.toString( this, "LongBuffer" );
    }

  /**
   * Become a shallow copy of an existing LongBuffer.
   * @param array The LongBuffer that I shall become a shallow copy of.
   */
  public synchronized void copy( LongBuffer buffer )
    {
    if ( this == buffer )
      return;

    synchronized( buffer )
      {
      if ( buffer.length > storage.length )
        {
        storage = buffer.get();
        }
      else
        {
        System.arraycopy( buffer.storage, 0, storage, 0, buffer.length );
        for ( int i = buffer.length; i < length; ++i )
          storage[ i ] = defaultValue; // To avoid suprises later
        }
      length = buffer.length;
      }
    }

  /**
   * Copy my elements into the specified array.
   * The number of items that are copied is equal to the smaller of my
   * length and the size of the specified array.
   * @param array The array that I shall copy my elements into.
   */
  public synchronized void copyTo( long[] array )
    {
    synchronized( array )
      {
      System.arraycopy( storage, 0, array, 0, Math.min( length, array.length ) );
      }
    }

  /**
   * Retrieve the underlying primitive array.
   */
  public synchronized long[] get()
    {
    long data[] = new long[ length ];
    copyTo( data );
    return data;
    }

  /**
   * Return my hash code for support of hashing containers
   */
  public synchronized int hashCode()
    {
    return Algorithms.Hashing.orderedHash( begin(), length );
    }

  /**
   * Return true if I contain no objects.
   */
  public boolean isEmpty()
    {
    return size() == 0;
    }

  /**
   * Return my last element.
   */
  public Object back()
    {
    return at( size() - 1 );
    }

  /**
   * Return my first element.
   */
  public Object front()
    {
    return at( 0 );
    }

  /**
   * Return the number of entries that I contain.
   */
  public int size()
    {
    return length;
    }

  /**
   * Return the number of elements that I contain without allocating more
   * internal storage.
   */
  public int capacity()
    {
    return storage.length;
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
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public Object at( int index )
    {
    return new Long( longAt( index ) );
    }

  /**
   * Return the long at the specified index.
   * @param index The index.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized long longAt( int index )
    {
    ArrayAdapter.checkIndex( index, length );
    return storage[ index ];
    }

  /**
   * Set the element at the specified index to a particular object.
   * @param index The index.
   * @param object The object.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized void put( int index, Object object )
    {
    put( index, asLong( object ) );
    }

  /**
   * Set the long at the specified index to a particular value.
   * @param index The index.
   * @param object The value.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized void put( int index, long object )
    {
    ArrayAdapter.checkIndex( index, length );
    storage[ index ] = object;
    }

  /**
   * Remove all of my elements.
   */
  public synchronized void clear()
    {
    storage = new long[ ArrayAdapter.DEFAULT_SIZE ];
    length = 0;
    }

  /**
   * Remove the element at a particular position.
   * @param pos An enumeration positioned at the element to remove.
   * @exception IllegalArgumentException is the Enumeration isn't an
   * LongIterator for this LongBuffer object.
   */
  public Object remove( Enumeration pos )
    {
    if ( !( pos instanceof LongIterator ) )
      throw new IllegalArgumentException( "Enumeration not an LongIterator" );

    if ( ( (LongIterator)pos ).buffer != storage )
      throw new IllegalArgumentException( "Enumeration not for this LongBuffer " );

    Object retval = ( (LongIterator)pos ).get();
    remove( ( (LongIterator)pos ).index );
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
    ArrayAdapter.checkIndex( index, length );
    Object retval = new Long( storage[ index ] );
    System.arraycopy( storage, index + 1, storage, index, length - index - 1 );

    storage[ --length ] = defaultValue;
    return retval;
    }

  /**
   * Remove the elements in the specified range.
   * @param first An Enumeration positioned at the first element to remove.
   * @param last An Enumeration positioned immediately after the last element to remove.
   * @return The number of elements removed.
   * @exception IllegalArgumentException is the Enumeration isn't an
   * LongIterator for this LongBuffer object.
   */
  public int remove( Enumeration first, Enumeration last )
    {
    if ( !( first instanceof LongIterator && last instanceof LongIterator ) )
      throw new IllegalArgumentException( "Enumeration not an LongIterator" );

    if ( ( (LongIterator)first ).buffer != storage || ( (LongIterator)first ).isCompatibleWith( (LongIterator)last ) )
      throw new IllegalArgumentException( "Enumeration not compatible" );

    return remove( ( (LongIterator)first ).index, ( (LongIterator)last ).index - 1 );
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

    ArrayAdapter.checkRange( first, last, length );
    int amount = last - first + 1;
    System.arraycopy( storage, last + 1, storage, first, length - last - 1 );

    for ( int i = length - amount; i < length; i++ )
      storage[ i ] = defaultValue;

    length -= amount;
    return amount;
    }

  /**
   * Remove and return my last element.
   * @exception com.objectspace.jgl.InvalidOperationException If the LongBuffer is empty.
   */
  public synchronized Object popBack()
    {
    if ( length == 0 )
      throw new InvalidOperationException( "LongBuffer is empty" );

    Object r = new Long( storage[ --length ] );
    storage[ length ] = defaultValue;
    return r;
    }

  /**
   * Add an object after my last element.  Returns null.
   * This function is a synonym for pushBack().
   * @param object The object to add.
   */
  public synchronized Object add( Object object )
    {
    add( asLong( object ) );
    return null;
    }

  /**
   * Add a long after my last element.  Returns null.
   * This function is a synonym for pushBack().
   * @param object The object to add.
   */
  public synchronized void add( long object )
    {
    if ( length == storage.length )
      {
      long[] tmp = getNextStorage( 1 );
      copyTo( tmp );
      storage = tmp;
      }

    storage[ length++ ] = object;
    }

  /**
   * Add an object after my last element.
   * @param The object to add.
   */
  public void pushBack( Object object )
    {
    add( asLong( object ) );
    }

  /**
   * Add a long after my last element.
   * @param The object to add.
   */
  public void pushBack( long object )
    {
    add( object );
    }

  /**
   * Insert an object at a particular position and return an iterator
   * positioned at the new element.
   * @param pos An iterator positioned at the element that the object will be inserted immediately before.
   * @param object The object to insert.
   */
  public LongIterator insert( LongIterator pos, Object object )
    {
    return insert( pos, asLong( object ) );
    }

  /**
   * Insert a value at a particular position and return an iterator
   * positioned at the new element.
   * @param pos An iterator positioned at the element that the object will be inserted immediately before.
   * @param object The object to insert.
   */
  public LongIterator insert( LongIterator pos, long object )
    {
    insert( pos.index, object );
    return new LongIterator( this, pos.index );
    }

  /**
   * Insert an object at a particular index.
   * @param index The index of the element that the object will be inserted immediately before.
   * @param object The object to insert.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public void insert( int index, Object object )
    {
    insert( index, asLong( object ) );
    }

  /**
   * Insert a value at a particular index.
   * @param index The index of the element that the object will be inserted immediately before.
   * @param object The value to insert.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized void insert( int index, long object )
    {
    ArrayAdapter.checkIndex( index, length + 1 );

    if ( length != storage.length )
      {
      if ( index != length )
        System.arraycopy( storage, index, storage, index + 1, length - index );
      }
    else
      {
      long[] tmp = getNextStorage( 1 );
      System.arraycopy( storage, 0, tmp, 0, index );
      System.arraycopy( storage, index, tmp, index + 1, length - index );
      storage = tmp;
      }

    storage[ index ] = object;
    ++length;
    }

  /**
   * Insert multiple objects at a particular position.
   * @param pos An iterator positioned at the element before which the
   *   elements will be inserted.
   * @param n The number of objects to insert.
   * @param object The object to insert.
   */
  public void insert( LongIterator pos, int n, Object object )
    {
    insert( pos, n, asLong( object ) );
    }

  /**
   * Insert multiple values at a particular position.
   * @param pos An iterator positioned at the element before which the
   *   elements will be inserted.
   * @param n The number of values to insert.
   * @param object The value to insert.
   */
  public void insert( LongIterator pos, int n, long object )
    {
    insert( pos.index, n, object );
    }

  /**
   * Insert multiple objects at a particular index.
   * @param index The index of the element immediately before the values will 
   *   be inserted.
   * @param object The object to insert.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   * @exception java.lang.IllegalArgumentException If the number of values 
   *   is negative.
   */
  public void insert( int index, int n, Object object )
    {
    insert( index, n, asLong( object ) );
    }

  /**
   * Insert multiple objects at a particular index.
   * @param index The index of the element immediately before the values will 
   *   be inserted.
   * @param object The value to insert.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   * @exception java.lang.IllegalArgumentException If the number of values 
   *   is negative.
   */
  public synchronized void insert( int index, int n, long object )
    {
    if ( n < 0 )
      throw new IllegalArgumentException( "Attempt to insert a negative number of objects." );

    if ( n == 0 )
      return;

    ArrayAdapter.checkIndex( index, length + 1 );
    if ( storage.length - length >= n )
      {
      System.arraycopy( storage, index, storage, index + n, length - index );
      }
    else
      {
      long[] tmp = getNextStorage( n );
      System.arraycopy( storage, 0, tmp, 0, index );
      System.arraycopy( storage, index, tmp, index + n, length - index );
      storage = tmp;
      }

    for ( int i = index; i < index + n; i++ )
      storage[ i ] = object;

    length += n;
    }

  /**
   * Insert a sequence of objects at a particular location.
   * @param pos The location of the element that the objects will be inserted immediately before.
   * @param first An iterator positioned at the first element to insert.
   * @param last An iterator positioned immediately after the last element to insert.
   */
  public void insert( LongIterator pos, ForwardIterator first, ForwardIterator last )
    {
    insert( pos.index, first, last );
    }

  /**
   * Insert a sequence of objects at a particular index.
   * @param index The index of the element that the objects will be inserted immediately before.
   * @param first An iterator positioned at the first element to insert.
   * @param last An iterator positioned immediately after the last element to insert.
   */
  public synchronized void insert( int index, ForwardIterator first, ForwardIterator last )
    {
    int n = first.distance( last );

    if ( n == 0 )
      return;

    ForwardIterator firstx = (ForwardIterator)first.clone();

    if ( storage.length - length >= n )
      {
      System.arraycopy( storage, index, storage, index + n, length - index );
      }
    else
      {
      long[] tmp = getNextStorage( n );
      System.arraycopy( storage, 0, tmp, 0, index );
      System.arraycopy( storage, index, tmp, index + n, length - index );
      storage = tmp;
      }

    length += n;
    for ( int i = index; i < index + n; i++ )
      put( i, firstx.nextElement() );
    }

  /**
   * Swap my contents with another LongBuffer.
   * @param array The LongBuffer that I will swap my contents with.
   */
  public synchronized void swap( LongBuffer array )
    {
    synchronized( array )
      {
      int oldLength = length;
      long oldStorage[] = storage;

      length = array.length;
      storage = array.storage;

      array.length = oldLength;
      array.storage = oldStorage;
      }
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
   * Return an iterator positioned immediately after my last item.
   */
  public ForwardIterator finish()
    {
    return end();
    }

  /**
   * Return an iterator positioned at my first item.
   */
  public synchronized LongIterator begin()
    {
    return new LongIterator( this, 0 );
    }

  /**
   * Return an iterator positioned immediately after my last item.
   */
  public synchronized LongIterator end()
    {
    return new LongIterator( this, length );
    }

  /**
   * If my storage space is currently larger than my total number of elements,
   * reallocate the elements into a storage space that is exactly the right size.
   */
  public synchronized void trimToSize()
    {
    if ( length < storage.length )
      storage = get();
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

    if ( storage.length < n )
      {
      long[] tmp = new long[ n ];

      if ( length > 0 )
        System.arraycopy( storage, 0, tmp, 0, length );

      storage = tmp;
      }
    }

  /**
   * Remove and return my first element.
   * @exception com.objectspace.jgl.InvalidOperationException If the LongBuffer is empty.
   */
  public synchronized Object popFront()
    {
    if ( length == 0 )
      throw new InvalidOperationException( "LongBuffer is empty" );

    Object result = new Long( storage[ 0 ] );
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
   * Insert a value in front of my first element.
   * @param object The object to insert.
   */
  public void pushFront( long object )
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
    return remove( object, length );
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
    long tmp = asLong( object );
    int removed = 0;
    while ( count > 0 )
      {
      int i = indexOf( tmp );
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
    asLong( object ); // check param
    if ( last < first )
      return 0;

    ArrayAdapter.checkRange( first, last, length );
    LongIterator firstx = new LongIterator( this, first );
    LongIterator lastx = new LongIterator( this, last + 1 );
    LongIterator finish = (LongIterator)Algorithms.Removing.remove( firstx, lastx, object );
    return remove( finish.index, last );
    }

  /**
   * Replace all elements that match a particular object with a new value and return
   * the number of objects that were replaced.
   * @param oldValue The object to be replaced.
   * @param newValue The value to substitute.
   */
  public int replace( Object oldValue, Object newValue )
    {
    return replace( asLong( oldValue ), asLong( newValue ) );
    }

  /**
   * Replace all longs that match a particular object with a new value and return
   * the number of objects that were replaced.
   * @param oldValue The long to be replaced.
   * @param newValue The value to substitute.
   */
  public int replace( long oldValue, long newValue )
    {
    return replace( 0, length - 1, oldValue, newValue );
    }

  /**
   * Replace all elements within a range of indices that match a particular object
   * with a new value and return the number of objects that were replaced.
   * @param first The index of the first object to be considered.
   * @param last The index just past the last object to be considered.
   * @param oldValue The object to be replaced.
   * @param newValue The value to substitute.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public int replace( int first, int last, Object oldValue, Object newValue )
    {
    return replace( first, last, asLong( oldValue ), asLong( newValue ) );
    }

  /**
   * Replace all values within a range of indices that match a particular long
   * with a new value and return the number of objects that were replaced.
   * @param first The index of the first element to be considered.
   * @param last The index just past the last element to be considered.
   * @param oldValue The long to be replaced.
   * @param newValue The value to substitute.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public synchronized int replace( int first, int last, long oldValue, long newValue )
    {
    ArrayAdapter.checkRange( first, last, length );
    int n = 0;
    while ( first < last )
      {
      if ( storage[ first ] == oldValue )
        {
        storage[ first ] = newValue;
        ++n;
        }
      ++first;
      }
    return n;
    }

  /**
   * Return the number of objects that match a particular value.
   * @param object The object to count.
   */
  public int count( Object object )
    {
    return count( asLong( object ) );
    }

  /**
   * Return the number of objects that equal a particular value.
   * @param object The long to count.
   */
  public int count( long object )
    {
    return count( 0, length - 1, object );
    }

  /**
   * Return the number of objects within a particular range of indices 
   * that match a particular value.
   * @param first The index of the first object to consider.
   * @param last The index of the last object to consider.
   * @exception java.lang.IndexOutOfBoundsException If either index is 
   *   invalid.
   */
  public int count( int first, int last, Object object )
    {
    return count( first, last, asLong( object ) );
    }

  /**
   * Return the number of objects within a particular range of indices 
   * that match a particular long.
   * @param first The index of the first object to consider.
   * @param last The index of the last object to consider.
   * @exception java.lang.IndexOutOfBoundsException If either index is 
   *   invalid.
   */
  public synchronized int count( int first, int last, long object )
    {
    ArrayAdapter.checkRange( first, last, length );
    int n = 0;
    while ( first < last )
      {
      if ( storage[ first ] == object )
        ++n;
      ++first;
      }
    return n;
    }

  /**
   * Return the index of the first object that matches a particular value, or
   * -1 if the object is not found.  Uses .equals() to find a match
   * @param object The object to find.
   * @exception java.lang.ClassCastException if objects are not Boolean
   */
  public int indexOf( Object object )
    {
    return indexOf( asLong( object ) );
    }

  /**
   * Return the index of the first long that matches a particular value, 
   * or -1 if the value is not found.
   * @param object The long to find.
   */
  public int indexOf( long object )
    {
    return indexOf( 0, length - 1, object );
    }

  /**
   * Return the index of the first object within a range of indices that 
   * match a particular object, or -1 if the object is not found.
   * @param first The index of the first object to consider.
   * @param last The index of the last object to consider.
   * @param object The object to find.
   * @exception java.lang.IndexOutOfBoundsException If either index is 
   *   invalid.
   */
  public int indexOf( int first, int last, Object object )
    {
    return indexOf( first, last, asLong( object ) );
    }

  /**
   * Return the index of the first long within a range of indices that 
   * match a particular value, or -1 if the long is not found.
   * @param first The index of the first value to consider.
   * @param last The index of the last value to consider.
   * @param object The value to find.
   * @exception java.lang.IndexOutOfBoundsException If either index is 
   *   invalid.
   */
  public synchronized int indexOf( int first, int last, long object )
    {
    if ( last < first )
      return -1;
    ArrayAdapter.checkRange( first, last, length );

    for ( ; first < last; ++first )
      if ( storage[ first ] == object )
        return first;
    return -1;
    }

  /**
   * Sets the size of the LongBuffer. if the size shrinks, the extra elements (at
   * the end of the array) are lost; if the size increases, the new elements
   * are set to null.
   * @param newSize The new size of the LongBuffer.
   */
  public synchronized void setSize( int newSize )
    {
    if ( newSize < 0 )
      throw new IllegalArgumentException( "Attempt to become a negative size." );
    if ( length > newSize )
      remove( newSize, length - 1 );
    else if ( length < newSize )
      insert( length, newSize - length, defaultValue );
    }

  /**
   * Return true if I contain a particular object using .equals()
   * @param object The object in question.
   */
  public boolean contains( Object object )
    {
    return contains( asLong( object ) );
    }

  /**
   * Return true if I contain a particular long.
   * @param object The long for which ot search.
   */
  public boolean contains( long object )
    {
    return indexOf( object ) != -1;
    }

  /**
   * Ensure that there is enough space for at least n new objects.
   */
  private long[] getNextStorage( int n )
    {
    int newSize = Math.max( ArrayAdapter.getNextSize( length ), length + n );
    long[] tmp = new long[ newSize ];
    return tmp;
    }

  static long asLong( Object object )
    {
    return ( (Number)object ).longValue();
    }

  static final long serialVersionUID = 568000230794422863L;
  }
