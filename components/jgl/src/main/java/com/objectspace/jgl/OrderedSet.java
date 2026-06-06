// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.util.Enumeration;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.IOException;

/**
 * A OrderedSet is a container that is optimized for fast associative lookup.
 * When an item is inserted into an OrderedSet, it is stored in a data 
 * structure that allows the item to be found very quickly. 
 * Within the data structure, the items are ordered
 * according to a comparator object. By default, the comparator will
 * order objects based on their hash value.
 * The OrderedSet class supports the full range of generic set algorithms such
 * as union() and intersection() in a user-friendly manner.  Duplicates (as
 * determined by the comparator) are not allowed by default.
 * Two OrderedSets are equal if and only if all items in one set have an
 * analogous member in the other set (items are matched using 
 * <CODE>equals()</CODE>).
 * <p>
 * OrderedSets are useful when fast associate lookup is important and when 
 * index-based lookup is unnecessary.
 * <p>
 * Strictly speaking, there is no reason why null is not a valid entry.
 * However, most comparators (including the default one) will fail
 * and throw an exception if you attempt to add a null entry because they cast
 * the entry to a class and then activate one of its methods. It is perfectly
 * possible to hand-craft a comparator that will accept null as a valid key.
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
 * that the items remain in a sorted order. This allows JGL users to iterate
 * through an associative container and access its elements in a sequenced
 * manner.
 * <p>
 * Insertion does not affect iterators or references.
 * <p>
 * Removal only invalidates the iterators and references to the removed
 * elements.
 * <p>
 * @see com.objectspace.jgl.Set
 * @see com.objectspace.jgl.BinaryPredicate
 * @see com.objectspace.jgl.algorithms.SetOperations
 * @see com.objectspace.jgl.examples.OrderedSetExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class OrderedSet implements Set
  {
  Tree myTree;
  int version = 30100; // 3.1.0

  /**
   * Construct myself to be an empty OrderedSet that orders elements based on
   * their hash value and does not allow duplicates.
   */
  public OrderedSet()
    {
    myTree = new Tree( false, false, this );
    }

  /**
   * Construct myself to be an empty OrderedSet that orders elements based on
   * their hash value and conditionally allows duplicates.
   * @param allowDuplicates true if duplicates are allowed.
   */
  public OrderedSet( boolean allowDuplicates )
    {
    myTree = new Tree( false, allowDuplicates, this );
    }

  /**
   * Construct myself to be an empty OrderedSet that orders elements using
   * a specified binary predicate and does not allow duplicates.
   * @param comparator The predicate for ordering objects.
   */
  public OrderedSet( BinaryPredicate comparator )
    {
    myTree = new Tree( false, false, comparator, this );
    }

  /**
   * Construct myself to be an empty OrderedSet that orders elements using
   * a specified binary predicate and conditionally allows duplicates.
   * @param comparator The predicate for ordering objects.
   * @param allowDuplicates true if duplicates are allowed.
   */
  public OrderedSet( BinaryPredicate comparator, boolean allowDuplicates )
    {
    myTree = new Tree( false, allowDuplicates, comparator, this );
    }

  /**
   * Construct myself to be a shallow copy of an existing OrderedSet.
   * @param set The OrderedSet to copy.
   */
  public OrderedSet( OrderedSet set )
    {
    synchronized( set )
      {
      myTree = new Tree( set.myTree, this );
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
    return new OrderedSet( this );
    }

  /**
   * Become a shallow copy of an existing OrderedSet.
   * @param set The OrderedSet that I shall become a shallow copy of.
   */
  public synchronized void copy( OrderedSet set )
    {
    synchronized( set )
      {
      myTree.copy( set.myTree );
      }
    }

  /**
   * Return a string that describes me.
   */
  public synchronized String toString()
    {
    return Algos.Printing.toString( this, "OrderedSet" );
    }

  /**
   * Return an Enumeration of my components.
   */
  public synchronized Enumeration elements()
    {
    return myTree.beginSet();
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
  public synchronized OrderedSetIterator begin()
    {
    return myTree.beginSet();
    }

  /**
   * Return an iterator positioned immediately after my last item.
   */
  public synchronized OrderedSetIterator end()
    {
    return myTree.endSet();
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
    return object instanceof OrderedSet && equals( (OrderedSet)object );
    }

  /**
   * Return true if I contain the same items in the same order as
   * another OrderedSet. Use equals() to compare the individual elements.
   * @param set The OrderedSet to compare myself against.
   */
  public synchronized boolean equals( OrderedSet set )
    {
    synchronized( set )
      {
      return Algos.Comparing.equal( this, set );
      }
    }

  /**
   * Return my hash code for support of hashing containers
   */
  public synchronized int hashCode()
    {
    return Algos.Hashing.orderedHash( begin(), myTree.size );
    }

  /**
   * Swap my contents with another OrderedSet.
   * @param set The OrderedSet that I will swap my contents with.
   */
  public synchronized void swap( OrderedSet set )
    {
    synchronized( set )
      {
      Tree tmp = myTree;
      myTree = set.myTree;
      set.myTree = tmp;
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
   * Remove all objects that match the given object.
   * @param object The object to match for removals
   * @return Return The number of objects removed.
   */
  public synchronized int remove( Object object )
    {
    Pair result = myTree.remove( object );
    return ( (Number)result.second ).intValue();
    }


  /**
   * Remove at most a given number of objects that match the given object.
   * @param object The object to match for removals
   * @param count The maximum number of objects to remove.
   * @return Return The number of objects removed.
   */
  public synchronized int remove( Object object, int count )
    {
    Pair result = myTree.remove( object, count );
    return ( (Number)result.second ).intValue();
    }

  /**
   * Remove the element at a particular position.
   * @param e An Enumeration positioned at the element to remove.
   * @exception IllegalArgumentException if the Enumeration isn't a
   * OrderedSetIterator for this OrderedSet object.
   * @return The object that was removed or null if none
   */
  public synchronized Object remove( Enumeration e )
    {
    if ( ! (e instanceof OrderedSetIterator) )
      throw new IllegalArgumentException( "Enumeration not a OrderedSetIterator" );

    if ( ((OrderedSetIterator)e).myOrderedSet != this )
      throw new IllegalArgumentException( "Enumeration not for this OrderedSet" );

    Tree.TreeNode node = myTree.remove( ((OrderedSetIterator)e).myNode );
    return ( node == null ? null : node.object );
    }

  /**
   * Remove the elements within a specified range.
   * @param first An Enumeration positioned at the first element to remove.
   * @param last An Enumeration positioned immediately after the last element to remove.
   * @exception IllegalArgumentException is the Enumeration isn't a
   * OrderedSetIterator for this OrderedSet object.
   * @return Return the nubmer of values removed.
   */
  public synchronized int remove( Enumeration first, Enumeration last )
    {
    if ( ( ! (first instanceof OrderedSetIterator) ) ||
        ( ! (last instanceof OrderedSetIterator) ) )
      throw new IllegalArgumentException( "Enumeration not a OrderedSetIterator" );

    if ( ( ((OrderedSetIterator)first).myOrderedSet != this ) ||
        ( ((OrderedSetIterator)last).myOrderedSet != this ) )
      throw new IllegalArgumentException( "Enumeration not for this OrderedSet" );

    Pair result = myTree.remove( ((OrderedSetIterator)first).myNode, ((OrderedSetIterator)last).myNode );
    return ( (Number)result.second ).intValue();
    }

  /**
   * Find an object and return its position. If the object
   * is not found, return end().
   * @param object The object to locate.
   */
  public synchronized OrderedSetIterator find( Object object )
    {
    return new OrderedSetIterator( myTree, myTree.find( object ), this );
    }

  /**
   * Return the number of items that match a particular object.
   * @param object The object to match against.
   */
  public synchronized int count( Object object )
    {
    return myTree.count( object );
    }

  /**
   * Return an iterator positioned at the first location that a
   * particular object could be inserted without violating the ordering
   * criteria. If no such location is found, return an iterator
   * positioned at end().
   * @param object The object in question.
   */
  public synchronized OrderedSetIterator lowerBound( Object object )
    {
    return new OrderedSetIterator( myTree, myTree.lowerBound( object ), this );
    }

  /**
   * Return an iterator positioned at the last location that
   * a particular object could be inserted without violating the ordering
   * criteria. If no such location is found, return an iterator
   * positioned at end().
   * @param object The object in question.
   */
  public synchronized OrderedSetIterator upperBound( Object object )
    {
    return new OrderedSetIterator( myTree, myTree.upperBound( object ), this );
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
      new OrderedSetIterator( myTree, (Tree.TreeNode)range.first, this ),
      new OrderedSetIterator( myTree, (Tree.TreeNode)range.second, this )
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
   * If the object doesn't exist or duplicates are allowed, add the object and return null,
   * otherwise don't modify the set and return the matching object.
   * @param object The object to be added.
   * @exception NullPointerException If the value of the object is equal to null.
   */
  public synchronized Object add( Object object )
    {
    if ( object == null )
      throw new NullPointerException();

    Tree.InsertResult result = myTree.insert( object );
    return result.ok ? null : result.node.object;
    }

  /**
   * Return the first object that matches the given object, or null if no match exists.
   * @param object The object to match against.
   */
  public synchronized Object get( Object object )
    {
    Tree.TreeNode node = myTree.find( object );

    if ( node.object == null )
      return null;

    return node.object.equals( object ) ? node.object : null;
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

    Tree.InsertResult result = myTree.put( object );
    if ( result.ok )
      return null;

    Object previous = result.node.object;
    result.node.object = object;
    return previous;
    }

  /**
   * Return a new OrderedSet that contains all of my elements and all of the elements in
   * a specified OrderedSet.
   * @param set The OrderedSet to union myself with.
   * @exception com.objectspace.jgl.InvalidOperationException if set is in multi-mode.
   * @see com.objectspace.jgl.algorithms.SetOperations#setUnion(com.objectspace.jgl.Container,com.objectspace.jgl.Container,com.objectspace.jgl.OutputIterator,com.objectspace.jgl.BinaryPredicate)
   */
  public synchronized OrderedSet union( OrderedSet set )
    {
    if ( myTree.myInsertAlways || set.myTree.myInsertAlways )
      throw new InvalidOperationException( "union operation invalid on multisets" );

    OrderedSet result = new OrderedSet( getComparator(), allowsDuplicates() );
    com.objectspace.jgl.algorithms.SetOperations.setUnion( this, set, new com.objectspace.jgl.util.InsertIterator( result ), getComparator() );
    return result;
    }

  /**
   * Return a new OrderedSet that contains the elements that are both in me and in
   * a specified set.
   * @param set The OrderedSet to intersect myself with.
   * @see com.objectspace.jgl.algorithms.SetOperations#setIntersection(com.objectspace.jgl.Container,com.objectspace.jgl.Container,com.objectspace.jgl.OutputIterator,com.objectspace.jgl.BinaryPredicate)
   */
  public synchronized OrderedSet intersection( OrderedSet set )
    {
    synchronized( set )
      {
      if ( myTree.myInsertAlways || set.myTree.myInsertAlways )
        throw new InvalidOperationException( "intersection operation invalid on multisets" );

      OrderedSet result = new OrderedSet( getComparator(), allowsDuplicates() );
      com.objectspace.jgl.algorithms.SetOperations.setIntersection( this, set, new com.objectspace.jgl.util.InsertIterator( result ), getComparator() );
      return result;
      }
    }

  /**
   * Return a new OrderedSet that contains the elements that are in me but not in a
   * specified set.
   * @param set The OrderedSet to difference myself with.
   * @see com.objectspace.jgl.algorithms.SetOperations#setDifference(com.objectspace.jgl.Container,com.objectspace.jgl.Container,com.objectspace.jgl.OutputIterator,com.objectspace.jgl.BinaryPredicate)
   */
  public synchronized OrderedSet difference( OrderedSet set )
    {
    synchronized( set )
      {
      if ( myTree.myInsertAlways || set.myTree.myInsertAlways )
        throw new InvalidOperationException( "difference operation invalid on multisets" );

      OrderedSet result = new OrderedSet( getComparator(), allowsDuplicates() );
      com.objectspace.jgl.algorithms.SetOperations.setDifference( this, set, new com.objectspace.jgl.util.InsertIterator( result ), getComparator() );
      return result;
      }
    }

  /**
   * Return a new OrderedSet that contains the elements that are either in me or in
   * a specified OrderedSet, but not both.
   * @param set The OrderedSet to symmetric difference myself with.
   * @see com.objectspace.jgl.algorithms.SetOperations#setSymmetricDifference(com.objectspace.jgl.Container,com.objectspace.jgl.Container,com.objectspace.jgl.OutputIterator,com.objectspace.jgl.BinaryPredicate)
   */
  public synchronized OrderedSet symmetricDifference( OrderedSet set )
    {
    synchronized( set )
      {
      if ( myTree.myInsertAlways || set.myTree.myInsertAlways )
        throw new InvalidOperationException( "symmetricDifference operation invalid on multisets" );

      OrderedSet result = new OrderedSet( getComparator(), allowsDuplicates() );
      com.objectspace.jgl.algorithms.SetOperations.setSymmetricDifference( this, set, new com.objectspace.jgl.util.InsertIterator( result ), getComparator() );
      return result;
      }
    }

  /**
   * Return true if every element in me is also in a specified OrderedSet.
   * @param set The OrderedSet to test against.
   * @see com.objectspace.jgl.algorithms.SetOperations#includes(com.objectspace.jgl.Container,com.objectspace.jgl.Container,com.objectspace.jgl.BinaryPredicate)
   */
  public synchronized boolean subsetOf( OrderedSet set )
    {
    synchronized( set )
      {
      if ( myTree.myInsertAlways || set.myTree.myInsertAlways )
        throw new InvalidOperationException( "subsetOf operation invalid on multisets" );

      return com.objectspace.jgl.algorithms.SetOperations.includes( set, this, getComparator() );
      }
    }

  /**
   * Return true if every element in me is also in a specified OrderedSet and I'm smaller
   * than the specified OrderedSet.
   * @param set The OrderedSet to test against.
   */
  public synchronized boolean properSubsetOf( OrderedSet set )
    {
    synchronized( set )
      {
      if ( myTree.myInsertAlways || set.myTree.myInsertAlways )
        throw new InvalidOperationException( "properSubsetOf operation invalid on multisets" );

      return (size() < set.size()) && subsetOf( set );
      }
    }

  private void readObject( ObjectInputStream stream ) throws IOException, ClassNotFoundException
    {
    stream.defaultReadObject();

    if ( version == 0 )
      {
      boolean allowDuplicates = stream.readBoolean();
      BinaryPredicate comparator = (BinaryPredicate)stream.readObject();

      myTree = new Tree( false, allowDuplicates, comparator, this );

      int count = stream.readInt();
      while ( count-- > 0 )
        add( stream.readObject() );
      }
    }

  static final long serialVersionUID = -4993180520108826183L;
  }
