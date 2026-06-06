// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.util.Enumeration;
import java.io.ObjectOutputStream;
import java.io.ObjectInputStream;
import java.io.IOException;

/**
 * An OrderedMap is an associative container that manages a set of ordered
 * key/value pairs. The pairs are ordered by key, using a comparator. By
 * default, a comparator is used which orders keys based on their hash
 * value. By default, only one value may be associated with a particular key.
 * An OrderedMap's underlying data structure allows you to very efficiently
 * find all of the values associated with a particular key.
 * <p>
 * An OrderedMap is useful for implementing a collection of one-to-one and
 * one-to-many mappings.
 * <p>
 * Strictly speaking, there is no reason why null is not a valid key. However,
 * most comparators (including the default one) will fail and throw
 * an exception if you attempt to add a null key because they cast the key to
 * a class and then activate one of its methods. It is perfectly possible to
 * hand-craft a comparator that will accept null as a valid key.
 * <p>
 * There are many different approaches that could be used to implementing an
 * associative container. For example, most of the older libraries used a
 * hashing scheme for positioning and retrieving items. This implementation
 * uses a data structure called a red-black tree. A red-black tree is a binary
 * search tree that uses an extra field in every node to store the node's
 * color. Red-black trees constrain the way that nodes may be colored in such a
 * way that the tree remains reasonably balanced. This property is important
 * for ensuring a good overall performance - red-black trees guarantee that the
 * worst case performance for the most common dynamic set operations is
 * O( log N ). One conseqence of using a binary tree for storage of data is
 * the items remain in a sorted order. This allows JGL users to iterate through
 * an associative container and access its elements in a sequenced manner. Each
 * node of the red-black tree holds a Pair( key, value ). The comparator is
 * used to order the Pairs based only on their keys.
 * <p>
 * Insertion does not affect iterators or references.
 * <p>
 * Removal only invalidates the iterators and references to the removed
 * elements.
 * <p>
 * @see com.objectspace.jgl.BinaryPredicate
 * @see com.objectspace.jgl.examples.OrderedMapExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class OrderedMap extends Map
  {
  Tree myTree;
  int version = 30100; // 3.1.0

  /**
   * Construct myself to be an empty OrderedMap that orders its keys based on
   * their hash value and does not allow duplicates.
   */
  public OrderedMap()
    {
    myTree = new Tree( true, false, this );
    }

  /**
   * Construct myself to be an empty OrderedMap that orders its keys based on
   * their hash value and conditionally allows duplicates.
   * @param allowDuplicates true if duplicates are allowed.
   */
  public OrderedMap( boolean allowDuplicates )
    {
    myTree = new Tree( true, allowDuplicates, this );
    }


  /**
   * Construct myself to be an empty OrderedMap that orders its keys using
   * a specified binary predicate and does not allow duplicates.
   * @param comparator The predicate for ordering keys.
   */
  public OrderedMap( BinaryPredicate comparator )
    {
    myTree = new Tree( true, false, comparator, this );
    }

  /**
   * Construct myself to be an empty OrderedMap that orders its keys using
   * a specified binary predicate and conditionally allows duplicates.
   * @param comparator The predicate for ordering keys.
   * @param allowDuplicates true if duplicates are allowed.
   */
  public OrderedMap( BinaryPredicate comparator, boolean allowDuplicates )
    {
    myTree = new Tree( true, allowDuplicates, comparator, this );
    }

  /**
   * Construct myself to be a shallow copy of an existing OrderedMap.
   * @param map The OrderedMap to copy.
   */
  public OrderedMap( OrderedMap map )
    {
    synchronized( map )
      {
      myTree = new Tree( map.myTree, this );
      }
    }

  /**
   * Return true if duplicates are allowed.
   */
  public boolean allowsDuplicates()
    {
    return myTree.myInsertAlways;
    }

  /**
   * Return a shallow copy of myself.
   */
  public synchronized Object clone()
    {
    return new OrderedMap( this );
    }

  /**
   * Become a shallow copy of an existing OrderedMap.
   * @param map The OrderedMap that I shall become a shallow copy of.
   */
  public synchronized void copy( OrderedMap map )
    {
    synchronized( map )
      {
      myTree.copy( map.myTree );
      }
    }

  /**
   * Return a string that describes me.
   */
  public synchronized String toString()
    {
    return Algos.Printing.toString( this, "OrderedMap" );
    }

  /**
   * Return an Enumeration of my values
   */
  public synchronized Enumeration elements()
    {
    return myTree.beginMap( OrderedMapIterator.VALUE );
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
  public synchronized OrderedMapIterator begin()
    {
    return myTree.beginMap( OrderedMapIterator.PAIR );
    }

  /**
   * Return an iterator positioned immediately after my last pair.
   */
  public synchronized OrderedMapIterator end()
    {
    return myTree.endMap( OrderedMapIterator.PAIR );
    }

  /**
   * Return true if I contain no entries.
   */
  public boolean isEmpty()
    {
    return myTree.size == 0;
    }

  /**
   * Return the number of entries that I contain.
   */
  public int size()
    {
    return myTree.size;
    }

  /**
   * Return the maximum number of entries that I can contain.
   */
  public int maxSize()
    {
    return myTree.maxSize();
    }

  /**
   * Return true if I'm equal to another object.
   * @param object The object to compare myself against.
   */
  public boolean equals( Object object )
    {
    return object instanceof OrderedMap && equals( (OrderedMap)object );
    }

  /**
   * Return true if I contain the same items in the same order as
   * another OrderedMap. Use equals() to compare the individual elements.
   * @param map The OrderedMap to compare myself against.
   */
  public synchronized boolean equals( OrderedMap map )
    {
    synchronized( map )
      {
      return Algos.Comparing.equal( this, map );
      }
    }

  /**
   * Return my hash code for support of hashing containers
   */
  public synchronized int hashCode()
    {
    ForwardIterator start = myTree.beginMap( OrderedMapIterator.KEY );
    return Algos.Hashing.orderedHash( start, myTree.size );
    }

  /**
   * Swap my contents with another OrderedMap.
   * @param map The OrderedMap that I will swap my contents with.
   */
  public synchronized void swap( OrderedMap map )
    {
    synchronized( map )
      {
      Tree tmp = myTree;
      myTree = map.myTree;
      map.myTree = tmp;
      }
    }

  /**
   * Remove all of my elements.
   */
  public synchronized void clear()
    {
    myTree.clear();
    }

  /**
   * If I contain key/value pair(s) that matches a particular key,
   * remove them all and return the number of pairs removed.
   * @param key The key of the pair(s) to be removed.
   * @return The first key/value pair removed or null if the container is unchanged.
   */
  public synchronized Object remove( Object object )
    {
    return myTree.remove( object ).first;
    }

  /**
   * If I contain key/value pair(s) that matches a particular key,
   * remove at most a given number and return the number of pairs removed.
   * @param key The key of the pair(s) to be removed.
   * @param count The maximum number of objects to remove.
   * @return The number of pairs removed.
   */
  public synchronized int remove( Object key, int count )
    {
    Pair result = myTree.remove( key, count );
    return ( (Number)result.second ).intValue();
    }

  /**
   * Remove the element at a particular position and return its value.
   * @param pos An Enumeration positioned at the element to remove.
   * @exception IllegalArgumentException is the Enumeration isn't an
   * OrderedMapIterator for this OrderedMap object.
   * @return The value that was removed or null if none.
   */
  public synchronized Object remove( Enumeration pos )
    {
    if ( ! (pos instanceof OrderedMapIterator) )
      throw new IllegalArgumentException( "Enumeration not an OrderedMapIterator" );

    if ( ((OrderedMapIterator)pos).myOrderedMap != this )
      throw new IllegalArgumentException( "Enumeration not for this OrderedMap" );

    Tree.TreeNode node = myTree.remove( ((OrderedMapIterator)pos).myNode );
    return ( node == null ? null : node.object );
    }

  /**
   * Remove the elements within a specified range, returning the first value
   * of the key in that range.
   * @param first An iterator positioned at the first element to remove.
   * @param last An iterator positioned immediately after the last element to remove.
   * @exception IllegalArgumentException is the Enumeration isn't an
   * OrderedMapIterator for this OrderedMap object.
   * @return Return the number of pairs removed.
   */
  public synchronized int remove( Enumeration first, Enumeration last )
    {
    if ( ( ! (first instanceof OrderedMapIterator) ) ||
        ( ! (last instanceof OrderedMapIterator) ) )
      throw new IllegalArgumentException( "Enumeration not an OrderedMapIterator" );

    if ( ( ((OrderedMapIterator)first).myOrderedMap != this ) ||
        ( ((OrderedMapIterator)last).myOrderedMap != this ) )
      throw new IllegalArgumentException( "Enumeration not for this OrderedMap" );

    Pair result = myTree.remove( ((OrderedMapIterator)first).myNode,
                          ((OrderedMapIterator)last).myNode );
    return ( (Number)result.second ).intValue();
    }

  /**
   * Find a key/value pair based on its key and return its position.
   * If the pair is not found, return end().
   * @param object The object to locate.
   */
  public synchronized OrderedMapIterator find( Object key )
    {
    return new OrderedMapIterator( myTree, myTree.find( key ), this, OrderedMapIterator.PAIR );
    }

  /**
   * Return the number of key/value pairs that match a particular key.
   * @param key The key to match against.
   */
  public synchronized int count( Object key )
    {
    return myTree.count( key );
    }

  /**
   * Return the number of values that match a given object.
   * @param value The value to match against.
   */
  public synchronized int countValues( Object value )
    {
    return Algos.Counting.count( myTree.beginMap( OrderedMapIterator.VALUE ),
                           myTree.endMap( OrderedMapIterator.VALUE ),
                           value );
    }

  /**
   * Return an iterator positioned at the first location that a
   * pair with a specified key could be inserted without violating the ordering
   * criteria. If no such location is found, return an iterator positioned at end().
   * @param key The key.
   */
  public synchronized OrderedMapIterator lowerBound( Object key )
    {
    return new OrderedMapIterator( myTree, myTree.lowerBound( key ), this, OrderedMapIterator.PAIR );
    }

  /**
   * Return an iterator positioned at the last location that
   * a pair with a specified key could be inserted without violating the ordering
   * criteria. If no such location is found, return an iterator positioned at end().
   * @param key The key.
   */
  public synchronized OrderedMapIterator upperBound( Object key )
    {
    return new OrderedMapIterator( myTree, myTree.upperBound( key ), this, OrderedMapIterator.PAIR );
    }

  /**
   * Return a pair of iterators whose first element is equal to
   * lowerBound() and whose second element is equal to upperBound().
   * @param object The object whose bounds are to be found.
   */
  public synchronized Range equalRange( Object object )
    {
    Pair range = myTree.equalRange( object );
    return new Range
      (
      new OrderedMapIterator( myTree, (Tree.TreeNode)range.first, this, OrderedMapIterator.PAIR ),
      new OrderedMapIterator( myTree, (Tree.TreeNode)range.second, this, OrderedMapIterator.PAIR )
      );
    }

  /**
   * Return my comparator.
   */
  public BinaryPredicate getComparator()
    {
    return myTree.myComparator;
    }

  /**
   * Return the value associated with key, or null if the key does not exist.
   * @param key The key to search against.
   */
  public synchronized Object get( Object key )
    {
    return myTree.get( key );
    }

  /**
   * If the key doesn't exist, associate the value with the key and return null,
   * otherwise replace the first value associated with the key and return the old value.
   * @param key The key.
   * @param value The value.
   * @exception java.lang.NullPointerException If the key or value is null.
   */
  public synchronized Object put( Object key, Object value )
    {
    if ( key == null || value == null )
      throw new NullPointerException();

    Tree.InsertResult result = myTree.put( new Pair( key, value ) );
    if ( result.ok )
      return null;

    Pair pair = (Pair)result.node.object;
    Object previous = pair.second;
    pair.second = value;
    return previous;
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
      throw new IllegalArgumentException( "object is not Pair" );

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

    Tree.InsertResult result = myTree.insert( new Pair( key, value ) );
    return result.ok ? null : ( (Pair)result.node.object).second;
    }

  /**
   * Return an Enumeration of all my keys.
   */
  public synchronized Enumeration keys()
    {
    return myTree.beginMap( OrderedMapIterator.KEY );
    }

  /**
   * Return an Enumeration of all my keys that are associated with a particular value.
   * @param value The value to match.
   */
  public synchronized Enumeration keys( Object value )
    {
    return myTree.keys( value ).elements();
    }

  /**
   * Return an Enumeration of all my values that are associated with a particular key.
   * @param key The key to match.
   */
  public synchronized Enumeration values( Object key )
    {
    return myTree.values( key ).elements();
    }

  private void readObject( ObjectInputStream stream ) throws IOException, ClassNotFoundException
    {
    stream.defaultReadObject();

    if ( version == 0 )
      {
      boolean allowDuplicates = stream.readBoolean();
      BinaryPredicate comparator = (BinaryPredicate)stream.readObject();

      myTree = new Tree( true, allowDuplicates, comparator, this );

      int count = stream.readInt();
      while ( count-- > 0 )
        add( stream.readObject() );
      }
    }

  static final long serialVersionUID = -8187379858339202062L;
  }
