// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.adapters;

import com.objectspace.jgl.*;
import java.util.Enumeration;
import java.lang.Math;

/**
 * A BooleanBuffer is a sequence that is very similar to a regular 
 * BooleanArray, except that it can expand to accomodate new elements.
 * <p>
 * The implementation store elements in a contiguous linear memory space 
 * so that index-based access is very quick. When an BooleanBuffer's originally 
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
 * @see com.objectspace.jgl.adapters.BooleanArray
 * @see com.objectspace.jgl.adapters.BooleanIterator
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 * @since JGL3.0
 */

public class BooleanBuffer extends ArrayAdapter
  {
  ByteBuffer storage; 
  int size;

  /**
   * Construct myself to be an empty BooleanBuffer.
   */
  public BooleanBuffer()
    {
    this( 0 );
    }

  /**
   * Construct myself to contain a specified number of null elements.
   * @param size The number of elements to contain.
   * @exception java.lang.IllegalArgumentException If size is negative.
   */
  public BooleanBuffer( int size )
    {
    if ( size < 0 )
      throw new IllegalArgumentException
        ( 
        "Attempt to create an BooleanBuffer with a negative size" 
        );
    storage = new ByteBuffer( size / 8 + 1 );
    this.size = size;
    }

  /**
   * Construct myself to contain a specified number of elements set to
   * a particular object.
   * @param size The number of elements to contain.
   * @param object The initial value of each element.
   * @exception java.lang.IllegalArgumentException If size is negative.
   */
  public BooleanBuffer( int size, boolean object )
    {
    this( size );
    for ( int i = 0; i < storage.size(); i++ )
      storage.put( i, (byte)( object ? 0xFF : 0 ) );
    }

  /**
   * Construct myself to use a specified array as my initial storage.
   * @param The array to use as initial storage.
   */
  public BooleanBuffer( boolean array[] )
    {
    this( new BooleanArray( array ) );
    }

  BooleanBuffer( ByteBuffer array )
    {
    storage = array;
    size = 0;
    }

  /**
   * Construct myself to be a copy of an existing BooleanBuffer.
   * @param array The BooleanBuffer to copy.
   */
  public BooleanBuffer( BooleanBuffer array )
    {
    storage = array.storage; 
    size = array.size;
    }

  /**
   * Construct myself to be a copy of an existing BooleanArray.
   * @param array The BooleanArray to copy.
   */
  public BooleanBuffer( BooleanArray array )
    { 
    this( array.size() );
    Algorithms.Copying.copy( array.begin(), array.end(), begin() );
    }

  /**
   * Construct myself to be a copy of an existing BitSet.
   * @param array The BitSet to copy.
   * @see java.util.BitSet
   */
  public BooleanBuffer( java.util.BitSet bitset )
    { 
    this( bitset.size() );
    BooleanIterator b = begin();
    synchronized( bitset )
      {
      for ( int i = 0; i < size(); ++i )
        b.put( i, bitset.get( i ) );
      }
    }

  /**
   * Return a shallow copy of myself.
   */
  public synchronized Object clone()
    {
    return new BooleanBuffer( this );
    }

  /**
   * Return my hash code for support of hashing containers
   */
  public synchronized int hashCode()
    {
    return storage.hashCode();
    }

  /**
   * Return true if I'm equal to another object.
   * @param object The object to compare myself against.
   */
  public boolean equals( Object object )
    {
    return 
      object instanceof BooleanBuffer && equals( (BooleanBuffer)object )
      || object instanceof BooleanArray && equals( (BooleanArray)object );
    }

  /**
   * Return true if I contain the same items in the same order as
   * another BooleanBuffer.
   * @param array The BooleanBuffer to compare myself against.
   */
  public boolean equals( BooleanBuffer array )
    {
    synchronized( array )
      {
      return Algorithms.Comparing.equal( this, array );
      }
    }

  /**
   * Return true if I contain the same items in the same order as
   * a BooleanArray.
   * @param array The BooleanArray to compare myself against.
   */
  public boolean equals( BooleanArray array )
    {
    synchronized( array )
      {
      return Algorithms.Comparing.equal( this, array );
      }
    }

  /**
   * Return true if I contain the same items in the same order as
   * a native array of booleans.
   * @param array The array to compare myself against.
   */
  public boolean equals( boolean array[] )
    {
    return equals( new BooleanArray( array ) );
    }

  /**
   * Return a string that describes me.
   */
  public synchronized String toString()
    {
    return Algorithms.Printing.toString( this, "BooleanBuffer" );
    }

  /**
   * Become a copy of an existing BooleanBuffer.
   * @param array The BooleanBuffer that I shall become a copy of.
   */
  public synchronized void copy( BooleanBuffer array )
    {
    if ( this == array )
      return;

    storage = new ByteBuffer( array.storage );
    size = array.size;
    }

  /**
   * Copy my elements into the specified array.
   * The number of items that are copied is equal to the smaller of my
   * length and the size of the specified array.
   * @param array The array that I shall copy my elements into.
   */
  public synchronized void copyTo( boolean[] array )
    {
    synchronized( array )
      {
      int x = 0;
      BooleanIterator b = begin();
      while ( x < size() )
        {
        array[ x ] = b.getBoolean( x );
        ++x;
        }
      }
    }

  /**
   * Copy all my elements into the specified BitSet, expanding the
   * BitSet if necessary.
   * @param bitset The bitset that I shall copy my elements into.
   * @see java.util.BitSet
   */
  public synchronized void copyTo( java.util.BitSet bitset )
    {
    synchronized( bitset )
      {
      int x = 0;
      BooleanIterator b = begin();
      while ( x < size() )
        {
        if ( b.getBoolean( x ) )
          bitset.set( x );
        else
          bitset.clear( x );
        ++x;
        }
      }
    }

  /**
   * Retrieve the underlying primitive array.
   */
  public synchronized boolean[] get()
    {
    boolean data[] = new boolean[ size() ];
    copyTo( data );
    return data;
    }

  /**
   * Return the number of entries that I contain.
   */
  public int size()
    {
    return size;
    }

  /**
   * Return the number of elements that I contain without allocating more
   * internal storage.
   */
  public int capacity()
    {
    return storage.size() * 8 - 1;
    }

  /**
   * Return the element at the specified index.
   * @param index The index.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized Object at( int index )
    {
    ArrayAdapter.checkIndex( index, size );
    return new BooleanIterator( this, index ).get();
    }

  /**
   * Return the boolean at the specified index.
   * @param index The index.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public boolean booleanAt( int index )
    {
    return ( (Boolean)at( index ) ).booleanValue();
    }

  /**
   * Set the element at the specified index to a particular object.
   * @param index The index.
   * @param object The object.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public void put( int index, Object object )
    {
    put( index, asBoolean( object ) );
    }

  /**
   * Set the boolean at the specified index to a particular value.
   * @param index The index.
   * @param object The value.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized void put( int index, boolean object )
    {
    ArrayAdapter.checkIndex( index, size );
    begin().put( index, object );
    }

  /**
   * Remove all of my elements.
   */
  public synchronized void clear()
    {
    storage.clear();
    size = 0;
    }

  /**
   * Remove the element at a particular position.
   * @param pos An enumeration positioned at the element to remove.
   * @exception IllegalArgumentException is the Enumeration isn't an
   * BooleanIterator for this BooleanBuffer object.
   */
  public Object remove( Enumeration pos )
    {
    if ( !( pos instanceof BooleanIterator ) )
      throw new IllegalArgumentException( "Enumeration not an BooleanIterator" );

    if ( ( (BooleanBuffer)( (BooleanIterator)pos ).original ).storage != storage )
      throw new IllegalArgumentException( "Enumeration not for this BooleanBuffer " );

    Object retval = ( (BooleanIterator)pos ).get();
    BooleanIterator iter = new BooleanIterator( this, ( (BooleanIterator)pos ).index() + 1 );
    BooleanIterator finish = new BooleanIterator( this, size );
    if ( !iter.equals( finish ) )
      Algorithms.Copying.copy( iter, finish, (BooleanIterator)pos );
    --size;
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
    ArrayAdapter.checkIndex( index, size );
    return remove( new BooleanIterator( this, index ) );
    }

  /**
   * Remove the elements in the specified range.
   * @param first An Enumeration positioned at the first element to remove.
   * @param last An Enumeration positioned immediately after the last element to remove.
   * @return The number of elements removed.
   * @exception IllegalArgumentException is the Enumeration isn't an
   * BooleanIterator for this BooleanBuffer object.
   */
  public int remove( Enumeration first, Enumeration last )
    {
    if ( !( first instanceof BooleanIterator && last instanceof BooleanIterator ) )
      throw new IllegalArgumentException( "Enumeration not an BooleanIterator" );

    if ( ( (BooleanBuffer)( (BooleanIterator)first ).original ).storage != storage || ( (BooleanIterator)first ).isCompatibleWith( (BooleanIterator)last ) )
      throw new IllegalArgumentException( "Enumeration not compatible" );

    int dist = ( (BooleanIterator)first ).distance( (BooleanIterator)last );
    BooleanIterator i = (BooleanIterator)Algorithms.Copying.copy
      ( 
      (BooleanIterator)last, 
      new BooleanIterator( this, size ), 
      (BooleanIterator)first 
      );
    size -= dist;
    return dist;
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

    ArrayAdapter.checkRange( first, last, size );
    return remove
      ( 
      new BooleanIterator( this, first ),
      new BooleanIterator( this, last )
      );
    }

  /**
   * Remove and return my last element.
   * @exception com.objectspace.jgl.InvalidOperationException If the BooleanBuffer is empty.
   */
  public synchronized Object popBack()
    {
    if ( size == 0 )
      throw new InvalidOperationException( "BooleanBuffer is empty" );

    return new BooleanIterator( this, --size ).get();
    }

  /**
   * Add an object after my last element.  Returns null.
   * This function is a synonym for pushBack().
   * @param object The object to add.
   */
  public Object add( Object object )
    {
    add( asBoolean( object ) );
    return null;
    }

  /**
   * Add a boolean after my last element.  Returns null.
   * This function is a synonym for pushBack().
   * @param b The value to add.
   */
  public synchronized void add( boolean b )
    {
    BooleanIterator finish = new BooleanIterator( this, size );
    if ( atEnd() )
      insertAux( finish, b );
    else
      {
      ++size;
      finish.put( b );
      }
    }

  /**
   * Add an object after my last element.
   * @param The object to add.
   */
  public void pushBack( Object object )
    {
    add( asBoolean( object ) );
    }

  /**
   * Add a boolean after my last element.
   * @param b The boolean value to add.
   */
  public void pushBack( boolean b )
    {
    add( b );
    }

  /**
   * Insert an object at a particular position and return an iterator
   * positioned at the new element.
   * @param pos An iterator positioned at the element that the object will be inserted immediately before.
   * @param object The object to insert.
   */
  public BooleanIterator insert( BooleanIterator pos, Object object )
    {
    return insert( pos, asBoolean( object ) );
    }

  /**
   * Insert a value at a particular position and return an iterator
   * positioned at the new element.
   * @param pos An iterator positioned at the element that the object will be inserted immediately before.
   * @param object The object to insert.
   */
  public BooleanIterator insert( BooleanIterator pos, boolean object )
    {
    int n = pos.index();
    if ( n == size )
      pushBack( object );
    else
      insertAux( pos, object );
    return new BooleanIterator( this, n );
    }

  /**
   * Insert an object at a particular index.
   * @param index The index of the element that the object will be inserted immediately before.
   * @param object The object to insert.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public void insert( int index, Object object )
    {
    insert( index, asBoolean( object ) );
    }

  /**
   * Insert a value at a particular index.
   * @param index The index of the element that the object will be inserted immediately before.
   * @param object The value to insert.
   * @exception java.lang.IndexOutOfBoundsException If the index is invalid.
   */
  public synchronized void insert( int index, boolean object )
    {
    ArrayAdapter.checkIndex( index, size + 1 );
    insert( new BooleanIterator( this, index ), object );
    }

  /**
   * Insert multiple objects at a particular position.
   * @param pos An iterator positioned at the element before which the
   *   elements will be inserted.
   * @param n The number of objects to insert.
   * @param object The object to insert.
   */
  public void insert( BooleanIterator pos, int n, Object object )
    {
    if ( n < 0 )
      throw new IllegalArgumentException( "Attempt to insert a negative number of objects." );

    if ( n == 0 )
      return;

    if ( capacity() - size >= n )
      {
      BooleanIterator b = new BooleanIterator( this, size + n );
      Algorithms.Copying.copyBackward( pos, new BooleanIterator( this, size ), b );
      Algorithms.Filling.fill( pos, new BooleanIterator( this, pos.index() + n ), object );
      size += n;
      }
    else
      {
      BooleanBuffer tmp = new BooleanBuffer( new ByteBuffer( new byte[ size + Math.max( size, n ) ], false ) );
      Algorithms.Copying.copy( storage.begin(), new ByteIterator( storage, pos.index() < size ? pos.index + 1 : pos.index ), tmp.storage.begin() );
      BooleanIterator i = new BooleanIterator( tmp, pos.index() );
      while ( n-- > 0 )
        {
        i.put( object );
        i.advance();
        }
      Algorithms.Copying.copy( pos, new BooleanIterator( this, size ), i );
      copy( tmp );
      }
    }

  /**
   * Insert multiple values at a particular position.
   * @param pos An iterator positioned at the element before which the
   *   elements will be inserted.
   * @param n The number of values to insert.
   * @param object The value to insert.
   */
  public void insert( BooleanIterator pos, int n, boolean object )
    {
    insert( pos, n, new Boolean( object ) );
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
    ArrayAdapter.checkIndex( index, size + 1 );
    insert( new BooleanIterator( this, index ), n, object );
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
  public synchronized void insert( int index, int n, boolean object )
    {
    insert( index, n, new Boolean( object ) );
    }

  /**
   * Insert a sequence of objects at a particular location.
   * @param pos The location of the element that the objects will be inserted immediately before.
   * @param first An iterator positioned at the first element to insert.
   * @param last An iterator positioned immediately after the last element to insert.
   */
  public void insert( BooleanIterator pos, ForwardIterator first, ForwardIterator last )
    {
    int n = first.distance( last );
    if ( n == 0 )
      return;

    if ( capacity() - size >= n )
      {
      BooleanIterator b = new BooleanIterator( this, size + n );
      Algorithms.Copying.copyBackward( pos, new BooleanIterator( this, size ), b );
      Algorithms.Copying.copy( first, last, pos );
      size += n;
      }
    else
      {
      BooleanBuffer tmp = new BooleanBuffer( new ByteBuffer( new byte[ size + Math.max( size, n ) ], false ) );
      Algorithms.Copying.copy( storage.begin(), new ByteIterator( storage, pos.index() < size ? pos.index + 1 : pos.index ), tmp.storage.begin() );
      BooleanIterator i = new BooleanIterator( tmp, pos.index() );
      Algorithms.Copying.copy( first, last, i );
      i.advance( n );
      Algorithms.Copying.copy( pos, new BooleanIterator( this, size ), i );
      copy( tmp );
      }
    }

  /**
   * Insert a sequence of objects at a particular index.
   * @param index The index of the element that the objects will be inserted immediately before.
   * @param first An iterator positioned at the first element to insert.
   * @param last An iterator positioned immediately after the last element to insert.
   */
  public synchronized void insert( int index, ForwardIterator first, ForwardIterator last )
    {
    ArrayAdapter.checkIndex( index, size + 1 );
    insert( new BooleanIterator( this, index ), first, last );
    }

  /**
   * Swap my contents with another BooleanBuffer.
   * @param array The BooleanBuffer that I will swap my contents with.
   */
  public synchronized void swap( BooleanBuffer array )
    {
    synchronized( array )
      {
      int oldSize = size;
      ByteBuffer oldStorage = storage;

      size = array.size;
      storage = array.storage;

      array.size = oldSize;
      array.storage = oldStorage;
      }
    }

  /**
   * Return an Enumeration of my components.
   */
  public synchronized Enumeration elements()
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
  public synchronized BooleanIterator begin()
    {
    return new BooleanIterator( this, 0 );
    }

  /**
   * Return an iterator positioned immediately after my last item.
   */
  public synchronized BooleanIterator end()
    {
    return new BooleanIterator( this, size );
    }

  /**
   * If my storage space is currently larger than my total number of elements,
   * reallocate the elements into a storage space that is exactly the right size.
   */
  public synchronized void trimToSize()
    {
    if ( size() < capacity() )
      copy( new BooleanBuffer( get() ) );
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

    if ( capacity() < n )
      storage.ensureCapacity( n / 8 + 1 );
    }

  /**
   * Remove and return my first element.
   * @exception com.objectspace.jgl.InvalidOperationException If the BooleanBuffer is empty.
   */
  public synchronized Object popFront()
    {
    if ( size() == 0 )
      throw new InvalidOperationException( "BooleanBuffer is empty" );

    Object result = at( 0 );
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
  public void pushFront( boolean object )
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
    return remove( object, size() );
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
    boolean tmp = asBoolean( object );
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
    asBoolean( object ); // check param
    if ( last < first )
      return 0;

    ArrayAdapter.checkRange( first, last, size );
    BooleanIterator firstx = new BooleanIterator( this, first );
    BooleanIterator lastx = new BooleanIterator( this, last + 1 );
    BooleanIterator finish = (BooleanIterator)Algorithms.Removing.remove( firstx, lastx, object );
    return remove( finish.index(), last );
    }

  /**
   * Replace all elements that match a particular object with a new value and return
   * the number of objects that were replaced.
   * @param oldValue The object to be replaced.
   * @param newValue The value to substitute.
   */
  public int replace( Object oldValue, Object newValue )
    {
    return replace( asBoolean( oldValue ), asBoolean( newValue ) );
    }
  public int replace( boolean oldValue, boolean newValue )
    {
    return replace( 0, size() - 1, oldValue, newValue );
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
  public int replace( int first, int last, Object oldValue, Object newValue )
    {
    if ( last < first )
      return -1;

    ArrayAdapter.checkRange( first, last, size );
    return Algorithms.Replacing.replace( new BooleanIterator( this, first ), new BooleanIterator( this, last + 1 ), oldValue, newValue );
    }

  public synchronized int replace( int first, int last, boolean oldValue, boolean newValue )
    {
    return replace( first, last, new Boolean( oldValue ), new Boolean( newValue ) );
    }

  /**
   * Return the number of objects that match a particular value.
   * @param object The object to count.
   */
  public int count( Object object )
    {
    return Algorithms.Counting.count( begin(), end(), object );
    }

  /**
   * Return the number of objects that equal a particular value.
   * @param object The boolean to count.
   */
  public int count( boolean object )
    {
    return count( new Boolean( object ) );
    }

  /**
   * Return the number of objects within a particular range of indices 
   * that match a particular value.
   * @param first The index of the first object to consider.
   * @param last The index of the last object to consider.
   * @exception java.lang.IndexOutOfBoundsException If either index is 
   *   invalid.
   */
  public synchronized int count( int first, int last, Object object )
    {
    if ( last < first )
      return -1;

    ArrayAdapter.checkRange( first, last, size );
    int index = ( (BooleanIterator)Algorithms.Finding.find( new BooleanIterator( this, first ), new BooleanIterator( this, last + 1 ), object )).index();
    return index == last + 1 ? -1 : index;
    }

  /**
   * Return the number of objects within a particular range of indices 
   * that match a particular boolean.
   * @param first The index of the first object to consider.
   * @param last The index of the last object to consider.
   * @exception java.lang.IndexOutOfBoundsException If either index is 
   *   invalid.
   */
  public int count( int first, int last, boolean object )
    {
    return count( first, last, new Boolean( object ) );
    }

  /**
   * Return the index of the first boolean that matches a particular value, 
   * or -1 if the value is not found.
   * @param object The boolean to find.
   */
  public int indexOf( boolean object )
    {
    return indexOf( 0, size() - 1, object );
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
    if ( last < first )
      return -1;

    ArrayAdapter.checkRange( first, last, size );
    int index = ( (BooleanIterator)Algorithms.Finding.find( new BooleanIterator( this, first ), new BooleanIterator( this, last + 1 ), object )).index();
    return index == last + 1 ? -1 : index;
    }

  /**
   * Return the index of the first boolean within a range of indices that 
   * match a particular value, or -1 if the boolean is not found.
   * @param first The index of the first value to consider.
   * @param last The index of the last value to consider.
   * @param object The value to find.
   * @exception java.lang.IndexOutOfBoundsException If either index is 
   *   invalid.
   */
  public synchronized int indexOf( int first, int last, boolean object )
    {
    return indexOf( first, last, new Boolean( object ) );
    }

  /**
   * Sets the size of the BooleanBuffer. if the size shrinks, the extra elements (at
   * the end of the array) are lost; if the size increases, the new elements
   * are set to null.
   * @param newSize The new size of the BooleanBuffer.
   */
  public synchronized void setSize( int newSize )
    { 
    if ( size() > newSize )
      remove( newSize, size() - 1 );
    else if ( size() < newSize )
      insert( size(), newSize - size(), false );
    }

  /**
   * Return true if I contain a particular boolean.
   * @param object The boolean for which ot search.
   */
  public boolean contains( boolean object )
    {
    return indexOf( object ) != -1;
    }

  private void insertAux( BooleanIterator iter, boolean b )
    {
    if ( atEnd() )
      {
      BooleanBuffer tmp = new BooleanBuffer( new ByteBuffer( new byte[ ArrayAdapter.getNextSize( size ) ], false ) );
      Algorithms.Copying.copy( storage.begin(), new ByteIterator( storage, iter.index() < size ? iter.index + 1 : iter.index ), tmp.storage.begin() );
      BooleanIterator i = new BooleanIterator( tmp, iter.index() );
      i.put( b );
      i.advance();
      Algorithms.Copying.copy( iter, new BooleanIterator( this, size ), i );
      copy( tmp );
      }
    else
      {
      Algorithms.Copying.copyBackward
        ( 
        iter, 
        new BooleanIterator( this, size + 1 ),
        new BooleanIterator( this, size )
        );
      iter.put( b );
      }
    }

  final static boolean asBoolean( Object b )
    {
    return ( (Boolean)b ).booleanValue();
    }

  final private boolean atEnd()
    {
    return size / 8 == storage.size();
    }

  static final long serialVersionUID = -1087317977793221720L;
  }
