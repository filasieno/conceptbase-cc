// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.util.Enumeration;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.IOException;

/**
 * A HashSet is a container that is optimized for fast associative lookup.
 * Items are matched by default using a BinaryPredicate that uses equals() 
 * for comparisons.
 * <p>
 * When an item is inserted into a HashSet, it is stored in a data structure
 * that allows the item to be found very quickly. Items are stored in buckets
 * based on their hash value, computed using the standard function hashCode().
 * By default, a HashSet cannot contain items that match.
 * The HashSet class supports the full range of generic set algorithms such as
 * union() and intersection() in a user-friendly manner.
 * <p>
 * HashSets are useful when fast associate lookup is important, when
 * index-based lookup is unnecessary, and when duplicates are not allowed.
 * <p>
 * Insertion can invalidate iterators.
 * <p>
 * Removal can invalidate iterators.
 * <p>
 * @see com.objectspace.jgl.Set
 * @see com.objectspace.jgl.BinaryPredicate
 * @see com.objectspace.jgl.algorithms.SetOperations
 * @see com.objectspace.jgl.examples.HashSetExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class HashSet implements Set
  {
  static final int DEFAULT_SIZE = 257;
  static final float DEFAULT_RATIO = 0.75F;

  BinaryPredicate comparator;
  boolean allowDups = false; // does the set allow duplicates?
  boolean expandActive = true; // will expand() have any effect?
  transient int size = 0; // # nodes.
  transient HashSetNode[] buckets; // Array of buckets.
  int length; // buckets.length, cached for speed.
  int limit;
  float ratio;

  /**
   * Construct myself to be an empty HashSet that compares objects using equals() and
   * does not allow duplicates.
   */
  public HashSet()
    {
    this( new xEqualTo(), false, DEFAULT_SIZE, DEFAULT_RATIO );
    }

  /**
   * Construct myself to be an empty HashSet that compares objects using equals() and
   * that conditionally allows duplicates.
   * @param allowDuplicates true if duplicates are allowed.
   */
  public HashSet( boolean allowDuplicates )
    {
    this( new xEqualTo(), allowDuplicates, DEFAULT_SIZE, DEFAULT_RATIO );
    }

  /**
   * Construct myself to be an empty HashSet that compares objects using the specified
   * binary predicate and does not allow duplicates.
   * @param comparator The predicate for comparing objects.
   */
  public HashSet( BinaryPredicate comparator )
    {
    this( comparator, false, DEFAULT_SIZE, DEFAULT_RATIO );
    }

  /**
   * Construct myself to be an empty HashSet that compares objects using the specified
   * binary predicate and conditionally allows duplicates.
   * @param comparator The predicate for comparing objects.
   * @param allowDuplicates true if duplicates are allowed.
   */
  public HashSet( BinaryPredicate comparator, boolean allowDuplicates )
    {
    this( comparator, allowDuplicates, DEFAULT_SIZE, DEFAULT_RATIO );
    }

  /**
   * Construct myself to be an empty HashSet that compares objects using the specified
   * binary predicate and conditionally allows duplicates. The initial capacity and
   * load ratio must also be specified.
   * @param comparator The predicate for comparing objects.
   * @param capacity The initial number of hash buckets to reserve.
   * @param loadRatio The maximum load ratio.
   */
  public HashSet( BinaryPredicate comparator, int capacity, float loadRatio  )
    {
    this( comparator, false, capacity, loadRatio );
    }

  /**
   * Construct myself to be an empty HashSet that compares objects using the specified
   * binary predicate and conditionally allows duplicates. The initial capacity and
   * load ratio must also be specified.
   * @param comparator The predicate for comparing objects.
   * @param allowDuplicates true if duplicates are allowed.
   * @param capacity The initial number of hash buckets to reserve.
   * @param loadRatio The maximum load ratio.
   */
  public HashSet( BinaryPredicate comparator, boolean allowDuplicates, int capacity, float loadRatio  )
    {
    this.comparator = comparator;
    allowDups = allowDuplicates;
    ratio = loadRatio;
    length = capacity;
    limit = (int)( length * ratio );
    buckets = new HashSetNode[ length ];
    }

  /**
   * Construct myself to be a shallow copy of an existing HashSet.
   * @param set The HashSet to copy.
   */
  public HashSet( HashSet set )
    {
    copy( set );
    }

  /**
   * Return true if I allow duplicate objects.
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
    return new HashSet( this );
    }

  /**
   * Become a shallow copy of an existing HashSet.
   * @param set The HashSet that I shall become a shallow copy of.
   */
  public synchronized void copy( HashSet set )
    {
    synchronized( set )
      {
      comparator = set.comparator;
      length = set.length;
      ratio = set.ratio;
      limit = set.limit;
      size = set.size;
      buckets = new HashSetNode[ length ];
      allowDups = set.allowDups;

      for ( int i = 0; i < length; i++ )
        {
        HashSetNode oldNode = null;
        HashSetNode node = set.buckets[ i ];

        while ( node != null )
          {
          HashSetNode newNode = new HashSetNode();
          newNode.object = node.object;
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
    return Algos.Printing.toString( this, "HashSet" );
    }

  /**
   * Return an Enumeration of my objects.
   */
  public synchronized Enumeration elements()
    {
    return new HashSetIterator( first(), this );
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
   * Return an iterator positioned at my first item.
   */
  public synchronized HashSetIterator begin()
    {
    return new HashSetIterator( first(), this );
    }

  /**
   * Return an iterator positioned immediately after my last item.
   */
  public synchronized HashSetIterator end()
    {
    return new HashSetIterator( null, this );
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
    return object instanceof HashSet && equals( (HashSet)object );
    }

  /**
   * Return true if I contain exactly the same items as another HashSet.
   * Use equals() to compare the individual elements.
   * @param set The HashSet to compare myself against.
   */
  public synchronized boolean equals( HashSet set )
    {
    synchronized( set )
      {
      if ( size != set.size )
        return false;

      if ( allowDups )
        {
        Object previous = null;

        for ( HashSetIterator iterator = begin(); iterator.hasMoreElements(); iterator.advance() )
          {
          Object object = iterator.get();

          // Execute the following code for each unique object in the source.
          if ( previous == null || !object.equals( previous ) )
            {
            if ( count( object ) != set.count( object ) )
              return false;

            previous = object;
            }
          }
        }
      else
        {
        for ( HashSetIterator iterator = begin(); iterator.hasMoreElements(); iterator.advance() )
          if ( set.count( iterator.get() ) == 0 )
            return false;
        }
      }
    return true;
    }

  /**
   * Return my hash code for support of hashing containers
   */
  public synchronized int hashCode()
    {
    return Algos.Hashing.unorderedHash( begin() );
    }

  /**
   * Swap my contents with another HashSet.
   * @param set The HashSet that I will swap my contents with.
   */
  public synchronized void swap( HashSet set )
    {
    synchronized( set )
      {
      int tmpSize = size;
      size = set.size;
      set.size = tmpSize;

      HashSetNode[] tmpBuckets = buckets;
      buckets = set.buckets;
      set.buckets = tmpBuckets;

      int tmpLength = length;
      length = set.length;
      set.length = tmpLength;

      int tmpLimit = limit;
      limit = set.limit;
      set.limit = tmpLimit;

      float tmpRatio = ratio;
      ratio = set.ratio;
      set.ratio = tmpRatio;

      boolean tmpDups = allowDups;
      allowDups = set.allowDups;
      set.allowDups = tmpDups;
      }
    }

  /**
   * Remove all of my elements.
   */
  public synchronized void clear()
    {
    buckets = new HashSetNode[ length ];
    size = 0;
    }

  /**
   * Remove all objects that match the given object.
   * @param object The object to match for removals
   * @return Return the number of values removed.
   */
  public int remove( Object object )
    {
    Pair result = removeAux( object, size );
    return ( (Number)result.second ).intValue();
    }

  /**
   * Remove at most a given number of objects that match the given object.
   * @param object The object to match for removals
   * @param count The maximum number of the pair(s) to remove.
   * @return Return the number of values removed.
   */
  public int remove( Object key, int count )
    {
    Pair result = removeAux( key, count );
    return ( (Number)result.second ).intValue();
    }

  synchronized Pair removeAux( Object object, int maximum )
    {
    if ( maximum > 0 )
      {
      int hash = object.hashCode() & 0x7FFFFFFF;
      int probe = hash % length;

      for ( HashSetNode node = buckets[ probe ], previous = null; node != null; previous = node, node = node.next )
        if ( node.hash == hash && comparator.execute( node.object, object ) )
          {
          int count = 1;
          --maximum;

          HashSetNode end = node.next;
          Object value = node.object;  // we only want the first one.

          if ( allowDups )
            {
            while ( maximum > 0 && end != null && end.hash == hash && comparator.execute( end.object, object ) )
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
   * HashSetIterator for this HashSet object.
   * @return Return the pair associated with the enumeration or null if none.
   */
  public synchronized Object remove( Enumeration e )
    {
    if ( ! (e instanceof HashSetIterator) )
      throw new IllegalArgumentException( "Enumeration not a HashSetIterator" );

    if ( ((HashSetIterator)e).myHashSet != this )
      throw new IllegalArgumentException( "Enumeration not for this HashSet" );

    HashSetIterator pos = (HashSetIterator)e;
    HashSetNode target = pos.myNode;
    int probe = target.hash % length;
    HashSetNode node = buckets[ probe ];

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
      : target.object;
    }

  /**
   * Remove the elements within a specified range.
   * @param first An Enumeration positioned at the first element to remove.
   * @param last An Enumeration positioned immediately after the last element to remove.
   * @exception IllegalArgumentException is the Enumeration isn't a
   * HashSetIterator for this HashSet object.
   * @return Return the number of values removed.
   */
  public synchronized int remove( Enumeration first, Enumeration last )
    {
    if ( ( ! (first instanceof HashSetIterator) ) ||
        ( ! (last instanceof HashSetIterator) ) )
      throw new IllegalArgumentException( "Enumeration not a HashSetIterator" );

    if ( ( ((HashSetIterator)first).myHashSet != this ) ||
        ( ((HashSetIterator)last).myHashSet != this ) )
      throw new IllegalArgumentException( "Enumeration not for this HashSet" );

    HashSetIterator begin = (HashSetIterator)first;
    HashSetIterator end = (HashSetIterator)last;

    int count = 0;
    while ( !begin.equals( end ) )
      {
      HashSetIterator next = new HashSetIterator( begin );
      next.advance();
      remove( begin );
      begin = next;
      ++count;
      }
    return count;
    }

  /**
   * Find an object and return its position. If the object
   * is not found, return end().
   * @param object The object to locate.
   */
  public synchronized HashSetIterator find( Object object )
    {
    int hash = object.hashCode() & 0x7FFFFFFF;

    for ( HashSetNode node = buckets[ hash % length ]; node != null; node = node.next )
      if ( hash == node.hash && comparator.execute( node.object, object ) )
        return new HashSetIterator( node, this );

    return new HashSetIterator( null, this );
    }

  /**
   * Return the number of items that match a particular object.
   * @param object The object to match against.
   */
  public synchronized int count( Object object )
    {
    int hash = object.hashCode() & 0x7FFFFFFF;

    for ( HashSetNode node = buckets[ hash % length ]; node != null; node = node.next )
      if ( hash == node.hash && comparator.execute( node.object,object ) )
        {
        if ( allowDups )
          {
          int n = 1;
          node = node.next;

          while ( node != null && hash == node.hash && comparator.execute( node.object, object ) )
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
   * If the object doesn't exist or duplicates are allowed, add the object and return null,
   * otherwise don't modify the set and return the matching object.
   * @param object The object to be added.
   * @exception NullPointerException If the value of the object is equal to null.
   */
  public synchronized Object add( Object object )
    {
    if ( object == null )
      throw new NullPointerException();

    int hash = object.hashCode() & 0x7FFFFFFF;
    int probe = hash % length;

    // find if object already exists first
    for ( HashSetNode node = buckets[ probe ]; node != null; node = node.next )
      if ( hash == node.hash && comparator.execute( node.object, object ) )
        {
        if ( allowDups )
          {
          // duplicate key, add this pair to end and return success.
          HashSetNode newNode = new HashSetNode();
          newNode.object = object;
          newNode.hash = hash;
          newNode.next = node.next;
          node.next = newNode;

          if ( ++size > limit )
            expand();

          return null;
          }
        else
          {
          // return the object that already exists. DO NOT add
          return node.object;
          }
       }

    // object doesn't exists, add appropriately
    HashSetNode newNode = new HashSetNode();
    newNode.object = object;
    newNode.hash = hash;
    newNode.next = buckets[ probe ];
    buckets[ probe ] = newNode;

    if ( ++size > limit )
      expand();

    return null;
    }

  /**
   * Return the first object that matches the given object, or null if no match exists.
   * @param object The object to match against.
   */
  public synchronized Object get( Object object )
    {
    int hash = object.hashCode() & 0x7FFFFFFF;

    for ( HashSetNode node = buckets[ hash % length ]; node != null; node = node.next )
      if ( hash == node.hash && comparator.execute( node.object, object ) )
        return node.object;

    return null;
    }

  /**
   * If the object doesn't exist, add the object and return null, otherwise replace the
   * first object that matches and return the old object.
   * @param object The object to add.
   * @exception NullPointerException If the value of the object is equal to null.
   */
  public synchronized Object put( Object object )
    {
    if ( object == null )
      throw new NullPointerException();

    int hash = object.hashCode() & 0x7FFFFFFF;
    int probe = hash % length;

    // find if object already exists first
    for ( HashSetNode node = buckets[ probe ]; node != null; node = node.next )
      if ( hash == node.hash && comparator.execute( node.object, object ) )
        {
        // an object matches, replace with new object and return old one.
        Object previous = node.object;
        node.object = object;
        return previous;
        }

    // object doesn't exists, add appropriately
    HashSetNode newNode = new HashSetNode();
    newNode.object = object;
    newNode.hash = hash;
    newNode.next = buckets[ probe ];
    buckets[ probe ] = newNode;

    if ( ++size > limit )
      expand();

    return null;
    }

  /**
   * Return a new HashSet that contains all of my elements and all of the elements in
   * a specified HashSet.
   * @param set The HashSet to union myself with.
   */
  public synchronized HashSet union( HashSet set )
    {
    synchronized( set )
      {
      if ( allowDups || set.allowDups )
        throw new InvalidOperationException( "union operation invalid on multisets" );

      HashSet result = new HashSet( this );
      HashSetIterator iterator = set.begin();
      while ( iterator.hasMoreElements() )
        result.add( iterator.nextElement() );
      return result;
      }
    }

  /**
   * Return a new HashSet that contains the elements that are both in me and in
   * a specified set.
   * @param set The HashSet to intersect myself with.
   */
  public synchronized HashSet intersection( HashSet set )
    {
    synchronized( set )
      {
      if ( allowDups || set.allowDups )
        throw new InvalidOperationException( "intersection operation invalid on multisets" );

      HashSet result = new HashSet( comparator, size + set.size, ratio );
      HashSetIterator iterator;

      // Loop through the smallest set.
      if ( size >= set.size )
        {
        iterator = begin();
        }
      else
        {
        iterator = set.begin();
        set = this;
        }

      while ( iterator.hasMoreElements() )
        {
        Object object = iterator.nextElement();

        if ( set.count( object ) > 0 )
          result.add( object );
        }
      return result;
      }
    }

  /**
   * Return a new HashSet that contains the elements that are in me but not in a
   * specified set.
   * @param set The HashSet to difference myself with.
   */
  public synchronized HashSet difference( HashSet set )
    {
    synchronized( set )
      {
      if ( allowDups || set.allowDups )
        throw new InvalidOperationException( "difference operation invalid on multisets" );

      HashSet result = new HashSet( comparator, size + set.size, ratio );
      HashSetIterator iterator = begin();

      while ( iterator.hasMoreElements() )
        {
        Object object = iterator.nextElement();

        if ( set.count( object ) == 0 )
          result.add( object );
        }

      return result;
      }
    }

  /**
   * Return a new HashSet that contains the elements that are either in me or in
   * a specified HashSet, but not both.
   * @param set The HashSet to symmetric difference myself with.
   */
  public synchronized HashSet symmetricDifference( HashSet set )
    {
    synchronized( set )
      {
      if ( allowDups || set.allowDups )
        throw new InvalidOperationException( "symmetricDifference operation invalid on multisets" );

      HashSet result = new HashSet( comparator, size + set.size, ratio );
      HashSetIterator iterator = begin();

      while ( iterator.hasMoreElements() )
        {
        Object object = iterator.nextElement();

        if ( set.count( object ) == 0 )
          result.add( object );
        }

      iterator = set.begin();

      while ( iterator.hasMoreElements() )
        {
        Object object = iterator.nextElement();

        if ( count( object ) == 0 )
          result.add( object );
        }

      return result;
      }
    }

  /**
   * Return true if every element in me is also in a specified HashSet.
   * @param set The HashSet to test against.
   */
  public synchronized boolean subsetOf( HashSet set )
    {
    synchronized( set )
      {
      if ( allowDups || set.allowDups )
        throw new InvalidOperationException( "subsetOf operation invalid on multisets" );

      HashSetIterator iterator = begin();

      while ( iterator.hasMoreElements() )
        if ( set.count( iterator.nextElement() ) == 0 )
          return false;

      return true;
      }
    }

  /**
   * Return true if every element in me is also in a specified HashSet and I'm smaller
   * than the specified HashSet.
   * @param set The HashSet to test against.
   */
  public synchronized boolean properSubsetOf( HashSet set )
    {
    synchronized( set )
      {
      if ( allowDups || set.allowDups )
        throw new InvalidOperationException( "properSubsetOf operation invalid on multisets" );

      return size < set.size && subsetOf( set );
      }
    }

  /**
   * Return an iterator positioned at the first location that a
   * particular object could be inserted without violating the ordering
   * criteria. If no such location is found, return an iterator
   * positioned at end().
   * @param object The object in question.
   */
  public synchronized HashSetIterator lowerBound( Object object )
    {
    return (HashSetIterator)equalRange( object ).begin;
    }

  /**
   * Return an iterator positioned at the last location that
   * a particular object could be inserted without violating the ordering
   * criteria. If no such location is found, return an iterator
   * positioned at end().
   * @param object The object in question.
   */
  public synchronized HashSetIterator upperBound( Object object )
    {
    return (HashSetIterator)equalRange( object ).end;
    }

  /**
   * Return a range whose first element is an iterator positioned
   * at the first occurence of a specific object and whose second element is an
   * iterator positioned immediately after the last occurence of that object.
   * Note that all objects inbetween these iterators will also match the specified
   * object. If no matching object is found, both ends of the range will be
   * the same.
   * @param object The object whose bounds are to be found.
   */
  public synchronized Range equalRange( Object object )
    {
    int hash = object.hashCode() & 0x7FFFFFFF;

    for ( HashSetNode node = buckets[ hash % length ]; node != null; node = node.next )
      if ( hash == node.hash && comparator.execute( node.object, object ) )
        {
        HashSetNode begin = node;
        node = node.next;

        while ( node != null && hash == node.hash && comparator.execute( node.object, object ) )
          node = node.next == null ? next( node ) : node.next;

        return new Range
          (
          new HashSetIterator( begin, this ),
          new HashSetIterator( node, this )
          );
        }

    return new Range( end(), end() );
    }

  private HashSetNode first()
    {
    if ( size > 0 )
      for ( int i = 0; i < length; i++ )
        if ( buckets[ i ] != null )
          return buckets[ i ];

    return null;
    }

  private HashSetNode next( HashSetNode node )
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
    HashSetNode[] newBuckets = new HashSetNode[ newLength ];

    for ( int i = 0; i < length; i++ )
      {
      HashSetNode node = buckets[ i ];

      while ( node != null )
        {
        HashSetNode current = node;
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
    buckets = new HashSetNode[ length ];
    int count = stream.readInt();
    while ( count-- > 0 )
      add( stream.readObject() );
    }

  static final class HashSetNode
    {
    Object object = null;
    int hash = 0;
    HashSetNode next = null;
    }
  
  static final long serialVersionUID = 647750600220545407L;
  }
