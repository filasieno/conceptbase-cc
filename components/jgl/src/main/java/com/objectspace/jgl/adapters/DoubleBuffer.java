// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.adapters;

import com.objectspace.jgl.*;
import java.util.Enumeration;
import java.lang.Math;

/**
 * A DoubleBuffer is a sequence that is very similar to a regular 
 * DoubleArray, except that it can expand to accomodate new elements.
 * <p>
 * The implementation store elements in a contiguous linear memory space 
 * so that index-based access is very quick. When an DoubleBuffer's originally 
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
 * @see com.objectspace.jgl.adapters.DoubleArray
 * @see com.objectspace.jgl.adapters.DoubleIterator
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class DoubleBuffer implements Sequence
  {
  final static double defaultValue = 0.0;
  double storage[]; // My storage.
  int length; // The number of objects I currently contain.

  /**
   * Construct myself to be an empty DoubleBuffer.
   */
  public DoubleBuffer()
    {
    clear();
    }

  /**
   * Construct myself to contain a specified number of null elements.
   * @param size The number of elements to contain.
   * @exception java.lang.IllegalArgumentException If size is negative.
   */
  public DoubleBuffer( int size )
    {
    if ( size < 0 )
      throw new IllegalArgumentException
        ( 
        "Attempt to create an DoubleBuffer with a negative size" 
        );

    length = size;
    storage = new double[ length ];
    }

  /**
   * Construct myself to contain a specified number of elements set to
   * a particular object.
   * @param size The number of elements to contain.
   * @param object The initial value of each element.
   * @exception java.lang.IllegalArgumentException If size is negative.
   */
  public DoubleBuffer( int size, double object )
    {
    this( size );
    for ( int i = 0; i < length; i++ )
      storage[ i ] = object;
    }

  /**
   * Construct myself to use a specified array as my initial storage.
   * @param The array to use as initial storage.
   */
  public DoubleBuffer( double array[] )
    {
    this( array, true );
    }

  DoubleBuffer( double array[], boolean copyBuffer )
    {
    synchronized( array )
      {
      length = array.length;
      if ( copyBuffer )
        {
        storage = new double[ length ];
        System.arraycopy( array, 0, storage, 0, length );
        }
      else
        storage = array;
      }
    }

  /**
   * Construct myself to be a copy of an existing DoubleBuffer.
   * @param array The DoubleBuffer to copy.
   */
  public DoubleBuffer( DoubleBuffer array )
    {
    this( array.storage );
    }

  /**
   * Return a shallow copy of myself.
   */
  public synchronized Object clone()
    {
    return new DoubleBuffer( this );
    }

  /**
   * Return true if I'm equal to another object.
   * @param object The object to compare myself against.
   */
  public boolean equals( Object object )
    {
    return 
      object instanceof DoubleBuffer && equals( (DoubleBuffer)object )
      || object instanceof DoubleArray && equals( (DoubleArray)object );
    }

  /**
   * Return true if I contain the same items in the same order as
   * another DoubleBuffer.
   * @param array The DoubleBuffer to compare myself against.
   */
  public boolean equals( DoubleBuffer buffer )
    {
    return equals( new DoubleArray( buffer.storage ) );
    }

  /**
   * Return true if I contain the same items in the same order as
   * a DoubleArray.
   * @param array The DoubleArray to compare myself against.
   */
  public synchronized boolean equals( DoubleArray array )
    {
    return array.equals( storage );
    }

  /**
   * Return true if I contain the same items in the same order as
   * a native array of doubles.
   * @param array The array to compare myself against.
   */
  public boolean equals( double array[] )
    {
    return equals( new DoubleArray( array ) );
    }

  /**
   * Return a string that describes me.
   */
  public synchronized String toString()
    {
    return Algorithms.Printing.toString( this, "DoubleBuffer" );
    }

  /**
   * Become a shallow copy of an existing DoubleBuffer.
   * @param array The DoubleBuffer that I shall become a shallow copy of.
   */
  public synchronized void copy( DoubleBuffer buffer )
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
  public synchronized void copyTo( double[] array )
    {
    synchronized( array )
      {
      System.arraycopy( storage, 0, array, 0, Math.min( length, array.length ) );
      }
    }

  /**
   * Retrieve the underlying primitive array.
   */
  public synchronized double[] get()
    {
    double data[] = new double[ length ];
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
    return new Double( doubleAt( index ) );
    }

  /**
   * Return the double at the specified index.
   * @param index The index.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized double doubleAt( int index )
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
    put( index, asDouble( object ) );
    }

  /**
   * Set the double at the specified index to a particular value.
   * @param index The index.
   * @param object The value.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized void put( int index, double object )
    {
    ArrayAdapter.checkIndex( index, length );
    storage[ index ] = object;
    }

  /**
   * Remove all of my elements.
   */
  public synchronized void clear()
    {
    storage = new double[ ArrayAdapter.DEFAULT_SIZE ];
    length = 0;
    }

  /**
   * Remove the element at a particular position.
   * @param pos An enumeration positioned at the element to remove.
   * @exception IllegalArgumentException is the Enumeration isn't an
   * DoubleIterator for this DoubleBuffer object.
   */
  public Object remove( Enumeration pos )
    {
    if ( !( pos instanceof DoubleIterator ) )
      throw new IllegalArgumentException( "Enumeration not an DoubleIterator" );

    if ( ( (DoubleIterator)pos ).buffer != storage )
      throw new IllegalArgumentException( "Enumeration not for this DoubleBuffer " );

    Object retval = ( (DoubleIterator)pos ).get();
    remove( ( (DoubleIterator)pos ).index );
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
    Object retval = new Double( storage[ index ] );
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
   * DoubleIterator for this DoubleBuffer object.
   */
  public int remove( Enumeration first, Enumeration last )
    {
    if ( !( first instanceof DoubleIterator && last instanceof DoubleIterator ) )
      throw new IllegalArgumentException( "Enumeration not an DoubleIterator" );

    if ( ( (DoubleIterator)first ).buffer != storage || ( (DoubleIterator)first ).isCompatibleWith( (DoubleIterator)last ) )
      throw new IllegalArgumentException( "Enumeration not compatible" );

    return remove( ( (DoubleIterator)first ).index, ( (DoubleIterator)last ).index - 1 );
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
   * @exception com.objectspace.jgl.InvalidOperationException If the DoubleBuffer is empty.
   */
  public synchronized Object popBack()
    {
    if ( length == 0 )
      throw new InvalidOperationException( "DoubleBuffer is empty" );

    Object r = new Double( storage[ --length ] );
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
    add( asDouble( object ) );
    return null;
    }

  /**
   * Add a double after my last element.  Returns null.
   * This function is a synonym for pushBack().
   * @param object The object to add.
   */
  public synchronized void add( double object )
    {
    if ( length == storage.length )
      {
      double[] tmp = getNextStorage( 1 );
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
    add( asDouble( object ) );
    }

  /**
   * Add a double after my last element.
   * @param The object to add.
   */
  public void pushBack( double object )
    {
    add( object );
    }

  /**
   * Insert an object at a particular position and return an iterator
   * positioned at the new element.
   * @param pos An iterator positioned at the element that the object will be inserted immediately before.
   * @param object The object to insert.
   */
  public DoubleIterator insert( DoubleIterator pos, Object object )
    {
    return insert( pos, asDouble( object ) );
    }

  /**
   * Insert a value at a particular position and return an iterator
   * positioned at the new element.
   * @param pos An iterator positioned at the element that the object will be inserted immediately before.
   * @param object The object to insert.
   */
  public DoubleIterator insert( DoubleIterator pos, double object )
    {
    insert( pos.index, object );
    return new DoubleIterator( this, pos.index );
    }

  /**
   * Insert an object at a particular index.
   * @param index The index of the element that the object will be inserted immediately before.
   * @param object The object to insert.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public void insert( int index, Object object )
    {
    insert( index, asDouble( object ) );
    }

  /**
   * Insert a value at a particular index.
   * @param index The index of the element that the object will be inserted immediately before.
   * @param object The value to insert.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized void insert( int index, double object )
    {
    ArrayAdapter.checkIndex( index, length + 1 );

    if ( length != storage.length )
      {
      if ( index != length )
        System.arraycopy( storage, index, storage, index + 1, length - index );
      }
    else
      {
      double[] tmp = getNextStorage( 1 );
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
  public void insert( DoubleIterator pos, int n, Object object )
    {
    insert( pos, n, asDouble( object ) );
    }

  /**
   * Insert multiple values at a particular position.
   * @param pos An iterator positioned at the element before which the
   *   elements will be inserted.
   * @param n The number of values to insert.
   * @param object The value to insert.
   */
  public void insert( DoubleIterator pos, int n, double object )
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
    insert( index, n, asDouble( object ) );
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
  public synchronized void insert( int index, int n, double object )
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
      double[] tmp = getNextStorage( n );
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
  public void insert( DoubleIterator pos, ForwardIterator first, ForwardIterator last )
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
      double[] tmp = getNextStorage( n );
      System.arraycopy( storage, 0, tmp, 0, index );
      System.arraycopy( storage, index, tmp, index + n, length - index );
      storage = tmp;
      }

    length += n;
    for ( int i = index; i < index + n; i++ )
      put( i, firstx.nextElement() );
    }

  /**
   * Swap my contents with another DoubleBuffer.
   * @param array The DoubleBuffer that I will swap my contents with.
   */
  public synchronized void swap( DoubleBuffer array )
    {
    synchronized( array )
      {
      int oldLength = length;
      double oldStorage[] = storage;

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
  public synchronized DoubleIterator begin()
    {
    return new DoubleIterator( this, 0 );
    }

  /**
   * Return an iterator positioned immediately after my last item.
   */
  public synchronized DoubleIterator end()
    {
    return new DoubleIterator( this, length );
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
      double[] tmp = new double[ n ];

      if ( length > 0 )
        System.arraycopy( storage, 0, tmp, 0, length );

      storage = tmp;
      }
    }

  /**
   * Remove and return my first element.
   * @exception com.objectspace.jgl.InvalidOperationException If the DoubleBuffer is empty.
   */
  public synchronized Object popFront()
    {
    if ( length == 0 )
      throw new InvalidOperationException( "DoubleBuffer is empty" );

    Object result = new Double( storage[ 0 ] );
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
  public void pushFront( double object )
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
    double tmp = asDouble( object );
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
    asDouble( object ); // check param
    if ( last < first )
      return 0;

    ArrayAdapter.checkRange( first, last, length );
    DoubleIterator firstx = new DoubleIterator( this, first );
    DoubleIterator lastx = new DoubleIterator( this, last + 1 );
    DoubleIterator finish = (DoubleIterator)Algorithms.Removing.remove( firstx, lastx, object );
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
    return replace( asDouble( oldValue ), asDouble( newValue ) );
    }

  /**
   * Replace all doubles that match a particular object with a new value and return
   * the number of objects that were replaced.
   * @param oldValue The double to be replaced.
   * @param newValue The value to substitute.
   */
  public int replace( double oldValue, double newValue )
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
    return replace( first, last, asDouble( oldValue ), asDouble( newValue ) );
    }

  /**
   * Replace all values within a range of indices that match a particular double
   * with a new value and return the number of objects that were replaced.
   * @param first The index of the first element to be considered.
   * @param last The index just past the last element to be considered.
   * @param oldValue The double to be replaced.
   * @param newValue The value to substitute.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public synchronized int replace( int first, int last, double oldValue, double newValue )
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
    return count( asDouble( object ) );
    }

  /**
   * Return the number of objects that equal a particular value.
   * @param object The double to count.
   */
  public int count( double object )
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
    return count( first, last, asDouble( object ) );
    }

  /**
   * Return the number of objects within a particular range of indices 
   * that match a particular double.
   * @param first The index of the first object to consider.
   * @param last The index of the last object to consider.
   * @exception java.lang.IndexOutOfBoundsException If either index is 
   *   invalid.
   */
  public synchronized int count( int first, int last, double object )
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
    return indexOf( asDouble( object ) );
    }

  /**
   * Return the index of the first double that matches a particular value, 
   * or -1 if the value is not found.
   * @param object The double to find.
   */
  public int indexOf( double object )
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
    return indexOf( first, last, asDouble( object ) );
    }

  /**
   * Return the index of the first double within a range of indices that 
   * match a particular value, or -1 if the double is not found.
   * @param first The index of the first value to consider.
   * @param last The index of the last value to consider.
   * @param object The value to find.
   * @exception java.lang.IndexOutOfBoundsException If either index is 
   *   invalid.
   */
  public synchronized int indexOf( int first, int last, double object )
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
   * Sets the size of the DoubleBuffer. if the size shrinks, the extra elements (at
   * the end of the array) are lost; if the size increases, the new elements
   * are set to null.
   * @param newSize The new size of the DoubleBuffer.
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
    return contains( asDouble( object ) );
    }

  /**
   * Return true if I contain a particular double.
   * @param object The double for which ot search.
   */
  public boolean contains( double object )
    {
    return indexOf( object ) != -1;
    }

  /**
   * Ensure that there is enough space for at least n new objects.
   */
  private double[] getNextStorage( int n )
    {
    int newSize = Math.max( ArrayAdapter.getNextSize( length ), length + n );
    double[] tmp = new double[ newSize ];
    return tmp;
    }

  static double asDouble( Object object )
    {
    return ( (Number)object ).doubleValue();
    }

  static final long serialVersionUID = 2440304957869661623L;
  }
