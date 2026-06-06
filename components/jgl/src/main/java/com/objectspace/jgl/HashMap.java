// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.util.Enumeration;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.IOException;

/**
 * A HashMap is an associative container that manages a set of key/value pairs.
 * A pair is stored in a hashing structure based on the hash code of its key,
 * which is obtained by using the standard hashCode() function. Keys are
 * matched by default using a BinaryPredicate that uses equals() for 
 * comparisons. Duplicate keys are not allowed unless explicitly specified.
 * <p>
 * A HashMap is useful for implementing a collection of one-to-one or
 * one-to-many mappings.
 * <p>
 * Insertion can invalidate iterators.
 * <p>
 * Removal can invalidate iterators.
 * <p>
 * @see com.objectspace.jgl.BinaryPredicate
 * @see com.objectspace.jgl.examples.HashMapExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class HashMap extends Map
  {
  static final int DEFAULT_SIZE = 257;
  static final float DEFAULT_RATIO = 0.75F;

  BinaryPredicate comparator;
  boolean allowDups; // does the map allow duplicate keys?
  boolean expandActive = true; // will expand() have any effect?
  transient int size; // # nodes.
  transient HashMapNode[] buckets; // Array of buckets.
  int length; // buckets.length, cached for speed.
  int limit;
  float ratio;

  /**
   * Construct myself to be an empty HashMap that compares key using equals() and
   * does not allow duplicates.
   */
  public HashMap()
    {
    this( new xEqualTo(), false, DEFAULT_SIZE, DEFAULT_RATIO );
    }

  /**
   * Construct myself to be an empty HashMap that compares keys using equals() and
   * conditionally allows duplicates.
   * @param allowDuplicates true if duplicates are allowed.
   */
  public HashMap( boolean allowDuplicates )
    {
    this( new xEqualTo(), allowDuplicates, DEFAULT_SIZE, DEFAULT_RATIO );
    }

  /**
   * Construct myself to be an empty HashMap that compares keys using the specified
   * binary predicate and does not allow duplicates.
   * @param comparator The predicate for comparing keys.
   */
  public HashMap( BinaryPredicate comparator )
    {
    this( comparator, false, DEFAULT_SIZE, DEFAULT_RATIO );
    }

  /**
   * Construct myself to be an empty HashMap that compares keys using the specified
   * binary predicate and conditionally allows duplicates.
   * @param comparator The predicate for comparing keys.
   * @param allowDuplicates true if duplicates are allowed.
   */
  public HashMap( BinaryPredicate comparator, boolean allowDuplicates )
    {
    this( comparator, allowDuplicates, DEFAULT_SIZE, DEFAULT_RATIO );
    }

  /**
   * Construct myself to be an empty HashMap that compares keys using the specified
   * binary predicate. The initial buckets and load ratio must also be specified.
   * @param comparator The predicate for comparing keys.
   * @param capacity The initial number of hash buckets to reserve.
   * @param loadRatio The maximum load ratio.
   */
  public HashMap( BinaryPredicate comparator, int capacity, float loadRatio )
    {
    this( comparator, false, capacity, loadRatio );
    }

  /**
   * Construct myself to be an empty HashMap that compares keys using the specified
   * binary predicate and conditionally allows duplicates. The initial buckets and
   * load ratio must also be specified.
   * @param comparator The predicate for comparing keys.
   * @param allowDuplicates true if duplicates are allowed.
   * @param capacity The initial number of hash buckets to reserve.
   * @param loadRatio The maximum load ratio.
   */
  public HashMap( BinaryPredicate comparator, boolean allowDuplicates, int capacity, float loadRatio )
    {
    this.comparator = comparator;
    ratio = loadRatio;
    length = capacity;
    limit = (int)( length * ratio );
    buckets = new HashMapNode[ length ];
    allowDups = allowDuplicates;
    }

  /**
   * Construct myself to be a shallow copy of an existing HashMap.
   * @param map The HashMap to copy.
   */
  public HashMap( HashMap map )
    {
    copy( map );
    }

  /**
   * Return true if I allow duplicate keys.
   */
  public boolean allowsDuplicates()
    {
    return allowDups;
    }

  /**
   * Return my comparator.
   */
  public BinaryPredicate getComparator()
    {
    return comparator;
    }

  /**
   * Return my load ratio.
   */
  public float getLoadRatio()
    {
    return ratio;
    }

  /**
   * Return a shallow copy of myself.
   */
  public synchronized Object clone()
    {
    return new HashMap( this );
    }

  /**
   * Become a shallow copy of an existing HashMap.
   * @param map The HashMap that I shall become a shallow copy of.
   */
  public synchronized void copy( HashMap map )
    {
    synchronized( map )
      {
      comparator = map.comparator;
      length = map.length;
      ratio = map.ratio;
      limit = map.limit;
      size = map.size();
      buckets = new HashMapNode[ length ];
      allowDups = map.allowDups;

      for ( int i = 0; i < length; i++ )
        {
        HashMapNode oldNode = null;
        HashMapNode node = map.buckets[ i ];

        while ( node != null )
          {
          HashMapNode newNode = new HashMapNode();
          newNode.key = node.key;
          newNode.value = node.value;
          newNode.hash = node.hash;

          if ( buckets[ i ] == null )
            buckets[ i ] = newNode;
          else
            oldNode.next = newNode;

          oldNode = newNode;
          node = node.next;
          }
        }
      }
    }

  /**
   * Return a string that describes me.
   */
  public synchronized String toString()
    {
    return Algos.Printing.toString( this, "HashMap" );
    }

  /**
   * Return an Enumeration to my values.
   */
  public synchronized Enumeration elements()
    {
    return new HashMapIterator( first(), this, HashMapIterator.VALUE );
    }

  /**
   * Return an iterator positioned at my first pair.
   */
  public ForwardIterator start()
    {
    return begin();
    }

  /**
   * Return an iterator positioned immediately afer my last pair.
   */
  public ForwardIterator finish()
    {
    return end();
    }

  /**
   * Return an iterator positioned at my first pair.
   */
  public synchronized HashMapIterator begin()
    {
    return new HashMapIterator( first(), this, HashMapIterator.PAIR );
    }

  /**
   * Return an iterator positioned immediately after my last pair.
   */
  public synchronized HashMapIterator end()
    {
    return new HashMapIterator( null, this, HashMapIterator.PAIR );
    }

  /**
   * Return true if I contain no entries.
   */
  public boolean isEmpty()
    {
    return size == 0;
    }

  /**
   * Return the number of entries that I contain.
   */
  public int size()
    {
    return size;
    }

  /**
   * Return the maximum number of entries that I can contain.
   */
  public int maxSize()
    {
    return Integer.MAX_VALUE;
    }

  /**
   * Return true if I'm equal to another object.
   * @param object The object to compare myself against.
   */
  public boolean equals( Object object )
    {
    return object instanceof HashMap && equals( (HashMap)object );
    }

  /**
   * Return true if I contain exactly the same key/value pairs as another HashMap.
   * Use equals() to compare values.
   * @param map The HashMap to compare myself against.
   */
  public synchronized boolean equals( HashMap map )
    {
    synchronized( map )
      {
      if ( size() != map.size() )
        return false;

      if ( allowDups )
        {
        Object previous = null;

        for ( HashMapIterator iterator = begin(); iterator.hasMoreElements(); iterator.advance() )
          {
          Object key = iterator.key();

          // Execute the following code for each unique key in the source.
          if ( previous == null || !key.equals( previous ) )
            {
            previous = key;
            if ( !same( values( key ), map.values( key ) ) )
              return false;
            }
          }
        }
      else
        {
        for ( HashMapIterator iterator = begin(); iterator.hasMoreElements(); iterator.advance() )
          {
          Object value = map.get( iterator.key() );

          if ( value == null || !value.equals( iterator.value() ) )
            return false;
          }
        }
      }
    return true;
    }

  /**
   * Return my hash code for support of hashing containers
   */
  public synchronized int hashCode()
    {
    ForwardIterator start = new HashMapIterator( first(), this, HashMapIterator.KEY );
    return Algos.Hashing.unorderedHash( start );
    }

  /**
   * Swap my contents with another HashMap.
   * @param map The HashMap that I will swap my contents with.
   */
  public synchronized void swap( HashMap map )
    {
    synchronized( map )
      {
      int tmpSize = size;
      size = map.size();
      map.size( tmpSize );

      HashMapNode[] tmpBuckets = buckets;
      buckets = map.buckets;
      map.buckets = tmpBuckets;

      int tmpLength = length;
      length = map.length;
      map.length = tmpLength;

      int tmpLimit = limit;
      limit = map.limit;
      map.limit = tmpLimit;

      float tmpRatio = ratio;
      ratio = map.ratio;
      map.ratio = tmpRatio;

      boolean tmpDups = allowDups;
      allowDups = map.allowDups;
      map.allowDups = tmpDups;
      }
    }

  /**
   * Remove all of my elements.
   */
  public synchronized void clear()
    {
    buckets = new HashMapNode[ length ];
    size = 0;
    }

  /**
   * Remove all key/value pairs that match a particular key.
   * @param key The key of the pair(s) to be removed.
   * @return the first value pair removed or null if not changed.
   */
  public Object remove( Object key )
    {
    return removeAux( key, size ).first;
    }

  /**
   * Remove at most a given number of key/value pairs that match a particular key.
   * @param key The key of the pair(s) to be removed.
   * @param count The maximum number of the pair(s) to remove.
   * @return Return the number of pairs removed.
   */
  public int remove( Object key, int count )
    {
    Pair result = removeAux( key, count );
    return ( (Number)result.second ).intValue();
    }

  synchronized Pair removeAux( Object key, int maximum )
    {
    if ( maximum > 0 )
      {
      int hash = key.hashCode() & 0x7FFFFFFF;
      int probe = hash % length;

      for ( HashMapNode node = buckets[ probe ], previous = null; node != null; previous = node, node = node.next )
        if ( node.hash == hash && comparator.execute( node.key, key ) )
          {
          int count = 1;
          --maximum;

          HashMapNode end = node.next;
          Object value = node.value; // we only want the first one.

          if ( allowDups )
            {
            while ( maximum > 0 && end != null && end.hash == hash && comparator.execute( end.key, key ) )
              {
              ++count;
              --maximum;
              end = end.next;
              }
            }

          if ( previous == null )
            buckets[ probe ] = end;
          else
            previous.next = end;

          size -= count;
          return new Pair( value, new Integer( count ) );
          }
      }
    return new Pair( null, new Integer( 0 ) );
    }

  /**
   * Remove the element at a particular position.
   * @param e An Enumeration positioned at the element to remove.
   * @exception IllegalArgumentException is the Enumeration isn't a
   * HashMapIterator for this HashMap object.
   * @return Return the value associated with the enumeration.
   */
  public synchronized Object remove( Enumeration e )
    {
    if ( ! (e instanceof HashMapIterator) )
      throw new IllegalArgumentException( "Enumeration not a HashMapIterator" );

    if ( ((HashMapIterator)e).myHashMap != this )
      throw new IllegalArgumentException( "Enumeration not for this HashMap" );

    HashMapNode target = ( (HashMapIterator)e ).myNode;
    int probe = target.hash % length;
    HashMapNode node = buckets[ probe ];

    if ( target == node )
      {
      buckets[ probe ] = target.next;
      }
    else
      {
      while ( node.next != target )
        node = node.next;

      node.next = target.next;
      }

    --size;
    return target == null
      ? null
      : target.value;
    }

  /**
   * Remove the elements within a specified range.
   * @param first An Enumeration positioned at the first element to remove.
   * @param last An Enumeration positioned immediately after the last element to remove.
   * @exception IllegalArgumentException is the Enumeration isn't a
   * HashMapIterator for this HashMap object.
   * @return Return the number of pairs removed.
   */
  public synchronized int remove( Enumeration first, Enumeration last )
    {
    if ( ( ! (first instanceof HashMapIterator) ) ||
        ( ! (last instanceof HashMapIterator) ) )
      throw new IllegalArgumentException( "Enumeration not a HashMapIterator" );

    if ( ( ((HashMapIterator)first).myHashMap != this ) ||
        ( ((HashMapIterator)last).myHashMap != this ) )
      throw new IllegalArgumentException( "Enumeration not for this HashMap" );

    HashMapIterator begin = (HashMapIterator)first;
    HashMapIterator end = (HashMapIterator)last;

    int count = 0;
    while ( !begin.equals( end ) )
      {
      HashMapIterator next = new HashMapIterator( begin );
      next.advance();
      remove( begin );
      begin = next;
      ++count;
      }
    return count;
    }

  /**
   * Find the first key/value pair based on its key and return its position.
   * If the key is not found, return end().
   * @param key The key to locate.
   */
  public synchronized HashMapIterator find( Object key )
    {
    int hash = key.hashCode() & 0x7FFFFFFF;

    for ( HashMapNode node = buckets[ hash % length ]; node != null; node = node.next )
      if ( hash == node.hash && comparator.execute( node.key, key ) )
        return new HashMapIterator( node, this, HashMapIterator.PAIR );

    return new HashMapIterator( null, this, HashMapIterator.PAIR );
    }

  /**
   * Return the number of key/value pairs that match a particular key.
   * @param key The key to match against.
   */
  public synchronized int count( Object key )
    {
    int hash = key.hashCode() & 0x7FFFFFFF;

    for ( HashMapNode node = buckets[ hash % length ]; node != null; node = node.next )
      if ( hash == node.hash && comparator.execute( node.key, key ) )
        {
        if ( allowDups )
          {
          int n = 1;
          node = node.next;

          while ( node != null && hash == node.hash && comparator.execute( node.key, key ) )
            {
            ++n;
            node = node.next;
            }

          return n;
          }
        else
          {
          return 1;
          }
        }

    return 0;
    }

  /**
   * Return the number of values that match a given object.
   * @param value The value to match against.
   */
  public synchronized int countValues( Object value )
    {
    return Algos.Counting.count
      (
      new HashMapIterator( first(), this, HashMapIterator.VALUE ),
      new HashMapIterator( null, this, HashMapIterator.VALUE ),
      value
      );
    }

  /**
   * Return the value associated with key, or null if the key does not exist.
   * @param key The key to search against.
   */
  public synchronized Object get( Object key )
    {
    int hash = key.hashCode() & 0x7FFFFFFF;

    for ( HashMapNode node = buckets[ hash % length ]; node != null; node = node.next )
      if ( hash == node.hash && comparator.execute( node.key, key ) )
        return node.value;

    return null;
    }

  /**
   * If the key doesn't exist, associate the value with the key and return null,
   * otherwise replace the first value associated with the key and return the old value.
   * @param key The key.
   * @param value The value.
   * @exception NullPointerException If the key or value are equal to null
   */
  public synchronized Object put( Object key, Object value )
    {
    if ( key == null || value == null )
      throw new NullPointerException();

    int hash = key.hashCode() & 0x7FFFFFFF;
    int probe = hash % length;

    // find if key already exists first
    for ( HashMapNode node = buckets[ probe ]; node != null; node = node.next )
      if ( hash == node.hash && comparator.execute( node.key, key ) )
        {
        // replace old version & return it
        node.key = key;
        Object previous = node.value;
        node.value = value;
        return previous;
        }

    // key doesn't exists, add appropriately
    HashMapNode newNode = new HashMapNode();
    newNode.key = key;
    newNode.value = value;
    newNode.hash = hash;
    newNode.next = buckets[ probe ];
    buckets[ probe ] = newNode;

    if ( ++size > limit )
      expand();

    return null;
    }

  /**
   * Assume that the specified object is a Pair whose first field is a key and whose
   * second field is a value. If the key doesn't exist or duplicates are allowed,
   * associate the value with the key and return null, otherwise don't modify the map and
   * return the current value associated with the key.
   * @param object The pair to add.
   * @exception java.lang.IllegalArgumentException If the object is not a Pair
   * @exception java.lang.NullPointerException If the object is null or if the first
   * or second items in the pair are null.
   */
  public Object add( Object object )
    {
    if ( object == null )
      throw new NullPointerException();

    if ( !(object instanceof Pair) )
      throw new IllegalArgumentException( "object is not pair" );

    if ( ((Pair)object).first == null || ((Pair)object).second == null )
      throw new NullPointerException();

    Pair pair = (Pair) object;
    return add( pair.first, pair.second );
    }

  /**
   * If the key doesn't exist or duplicates are allowed, associate the value with the
   * key and return null, otherwise don't modify the map and return the current value
   * associated with the key.
   * @param key The key.
   * @param value The value.
   * @exception java.lang.NullPointerException If the key or value is null.
   */
  public synchronized Object add( Object key, Object value )
    {
    if ( key == null || value == null )
      throw new NullPointerException();

    int hash = key.hashCode() & 0x7FFFFFFF;
    int probe = hash % length;

    // find if key already exists first
    for ( HashMapNode node = buckets[ probe ]; node != null; node = node.next )
      if ( hash == node.hash && comparator.execute( node.key, key ) )
        {
        if ( allowDups )
          {
          // duplicate key, add this pair to end and return success.
          HashMapNode newNode = new HashMapNode();
          newNode.key = key;
          newNode.value = value;
          newNode.hash = hash;
          newNode.next = node.next;
          node.next = newNode;

          if ( ++size > limit )
            expand();

          return null;
          }
        else
          {
          // return the value of the key/value that already exists. DO NOT add
          return node.value;
          }
        }

    // key doesn't exists, add appropriately
    HashMapNode newNode = new HashMapNode();
    newNode.key = key;
    newNode.value = value;
    newNode.hash = hash;
    newNode.next = buckets[ probe ];
    buckets[ probe ] = newNode;

    if ( ++size > limit )
      expand();

    return null;
    }

  /**
   * Return an Enumeration of all my keys.
   */
  public synchronized Enumeration keys()
    {
    return new HashMapIterator( first(), this, HashMapIterator.KEY );
    }

  /**
   * Return an Enumeration of all my keys that are associated with a particular value.
   * @param value The value to match.
   */
  public synchronized Enumeration keys( Object value )
    {
    Array array = new Array();

    for ( HashMapIterator iterator = begin(); iterator.hasMoreElements(); iterator.advance() )
      if ( iterator.value().equals( value ) )
        array.pushBack( iterator.key() );

    return array.elements();
    }

  /**
   * Return an Enumeration of all my values that are associated with a particular key.
   * @param key The key to match.
   */
  public synchronized Enumeration values( Object key )
    {
    Array array = new Array();
    Range range = equalRange( key );

    HashMapIterator iter = (HashMapIterator)range.begin;
    HashMapIterator last = (HashMapIterator)range.end;
    while ( !iter.equals( last ) )
      {
      array.add( iter.value() );
      iter.advance();
      }

    return array.elements();
    }

  /**
   * Return an iterator positioned at the first location that a
   * pair with a specified key could be inserted without violating the ordering
   * criteria. If no such location is found, return an iterator positioned at end().
   * @param key The key.
   */
  public synchronized HashMapIterator lowerBound( Object key )
    {
    return (HashMapIterator)equalRange( key ).begin;
    }

  /**
   * Return an iterator positioned at the last location that
   * a pair with a specified key could be inserted without violating the ordering
   * criteria. If no such location is found, return an iterator positioned at end().
   * @param key The key.
   */
  public synchronized HashMapIterator upperBound( Object key )
    {
    return (HashMapIterator)equalRange( key ).end;
    }

  /**
   * Return a range whose first element is an iterator positioned
   * at the first occurence of a specific key and whose second element is an
   * iterator positioned immediately after the last occurence of that key.
   * Note that all key inbetween these iterators will also match the specified
   * key. If no matching key is found, both ends of the range will be the
   * same.
   * @param object The key whose bounds are to be found.
   */
  public synchronized Range equalRange( Object key )
    {
    int hash = key.hashCode() & 0x7FFFFFFF;

    for ( HashMapNode node = buckets[ hash % length ]; node != null; node = node.next )
      if ( hash == node.hash && comparator.execute( node.key, key ) )
        {
        HashMapNode begin = node;
        node = node.next == null ? next( node ) : node.next;  // fixed 8/9/96 pdj

        while ( node != null && hash == node.hash && comparator.execute( node.key, key ) )
          node = node.next == null ? next( node ) : node.next;

        return new Range( new HashMapIterator( begin, this, HashMapIterator.PAIR ),
                          new HashMapIterator( node, this, HashMapIterator.PAIR ) );
        }

    return new Range( end(), end() );
    }

  private HashMapNode first()
    {
    if ( size > 0 )
      for ( int i = 0; i < length; i++ )
        if ( buckets[ i ] != null )
          return buckets[ i ];

    return null;
    }

  private HashMapNode next( HashMapNode node )
    {
    for ( int i = ( node.hash % length ) + 1; i < length; i++ )
      if ( buckets[ i ] != null )
        return buckets[ i ];

    return null;
    }

  /**
   * Return true if adding an object to myself could result in an expansion
   * of the number of hash buckets I currently use.
   */
  public boolean expansionAllowed()
    {
    return expandActive;
    }

  /**
   * Enable or disable the current expansion mode.  If disabled, no new
   * hash buckets will ever be created regardless of my size.
   * @param allow The new expansion mode.
   */
  public synchronized void allowExpansion( boolean allow )
    {
    expandActive = allow;
    }

  /**
   * Return the number of new buckets to create when expanding the
   * collection.  The number returned must be positive, and should be
   * greater than the current bucket size. It is advisable to have
   * the new size be prime (or have few divisors less than 20) for
   * the best hash distribution.
   * @param length The current number of buckets.
   * @return length * 2 + 1
   */
  protected int nextBucketSize( int length )
    {
    return length * 2 + 1;
    }

  private void expand()
    {
    if ( !expansionAllowed() )
      return;

    int newLength = nextBucketSize( length );
    HashMapNode[] newBuckets = new HashMapNode[ newLength ];

    for ( int i = 0; i < length; i++ )
      {
      HashMapNode node = buckets[ i ];

      while ( node != null )
        {
        HashMapNode current = node;
        node = node.next;
        int probe = current.hash % newLength;
        current.next = newBuckets[ probe ];
        newBuckets[ probe ] = current;
        }
      }

    buckets = newBuckets;
    length = newLength;
    limit = (int)( length * ratio );
    }

  private boolean same( Enumeration src, Enumeration dst )
    {
    Array srcValues = new Array();
    Array dstValues = new Array();

    while ( src.hasMoreElements() )
      srcValues.add( src.nextElement() );

    while ( dst.hasMoreElements() )
      dstValues.add( dst.nextElement() );

    if ( srcValues.size() != dstValues.size() )
      return false;

    for ( int i = 0; i < srcValues.size(); i++ )
      {
      Object x = srcValues.at( i );
      int srcCount = 0;
      int dstCount = 0;

      // Count the number of times 'x' occurs in each array of values.
      for ( int j = 0; j < dstValues.size(); j++ )
        {
        if ( srcValues.at( j ).equals( x ) )
          ++srcCount;

        if ( dstValues.at( j ).equals( x ) )
          ++dstCount;
        }

      if ( srcCount != dstCount )
        return false;
      }

    return true;
    }

  private void size( int newsize )
    {
    size = newsize;
    }

  private synchronized void writeObject( ObjectOutputStream stream ) throws IOException
    {
    stream.defaultWriteObject();
    stream.writeInt( size );
    Enumeration iter = begin();
    while ( iter.hasMoreElements() )
      stream.writeObject( iter.nextElement() );
    }

  private void readObject( ObjectInputStream stream ) throws IOException, ClassNotFoundException
    {
    stream.defaultReadObject();
    buckets = new HashMapNode[ length ];
    int count = stream.readInt();
    while ( count-- > 0 )
      add( stream.readObject() );
    }

  static final class HashMapNode
    {
    Object key = null;
    Object value = null;
    int hash = 0;
    HashMapNode next = null;
    }
  
  static final long serialVersionUID = 6756413513418169292L;
  }
