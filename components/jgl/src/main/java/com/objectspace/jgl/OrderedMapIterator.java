// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

/**
 * A OrderedMapIterator is a bidirectional iterator that allows you to iterate through
 * the contents of a OrderedMap. It has a mode that allows selection of the current
 * position's key, value, or key-value pair.
 * <p>
 * @see com.objectspace.jgl.BidirectionalIterator
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class OrderedMapIterator implements BidirectionalIterator, Opaque
  {
  public final static int PAIR = 1;
  public final static int KEY = 2;
  public final static int VALUE = 3;

  OrderedMap myOrderedMap;
  Tree myTree;
  Tree.TreeNode myNode;
  int myMode = PAIR;

  /**
   * Construct myself to be an iterator with no associated data structure or position.
   */
  public OrderedMapIterator()
    {
    }

  /**
   * Construct myself to be a copy of an existing iterator.
   * @param iterator The iterator to copy.
   */
  public OrderedMapIterator( OrderedMapIterator iterator )
    {
    myOrderedMap = iterator.myOrderedMap;
    myTree = iterator.myTree;
    myNode = iterator.myNode;
    myMode = iterator.myMode;
    }

  /**
   * Construct myself to be positioned at a particular node in a specified Tree.
   * @param tree My associated tree.
   * @param node My associated node.
   * @param mode My mode for returning( PAIR, KEY, VALUE )
   */
  OrderedMapIterator( Tree tree, Tree.TreeNode node, OrderedMap map, int mode )
    {
    myOrderedMap = map;
    myTree = tree;
    myNode = node;
    myMode = mode;
    }

  /**
   * Return a clone of myself.
   */
  public Object clone()
    {
    return new OrderedMapIterator( this );
    }

  /**
   * Return true if a specified object is the same kind of iterator as me
   * and is positioned at the same element.
   * @param object Any object.
   */
  public boolean equals( Object object )
    {
    return object instanceof Opaque && myNode == ( (Opaque)object ).opaqueData();
    }

  /**
   * Return true if I'm positioned at the first item of my input stream.
   */
  public boolean atBegin()
    {
    return myNode == myTree.myHeader.left;
    }

  /**
   * Return true if I'm positioned after the last item in my input stream.
   */
  public boolean atEnd()
    {
    return myNode == myTree.myHeader;
    }

  /**
   * Return true if there are more elements in my input stream.
   */
  public boolean hasMoreElements()
    {
    return myNode != myTree.myHeader;
    }

  /**
   * Advance by one.
   */
  public void advance()
    {
    myNode = Tree.increment( myNode, myTree.NIL );
    }

  /**
   * Advance by a specified amount.
   * @param n The amount to advance.
   */
  public void advance( int n )
    {
    if ( n >= 0 )
      while ( n-- > 0 )
        advance();
    else
      while ( n++ < 0 )
        retreat();
    }

  /**
   * Retreat by one.
   */
  public void retreat()
    {
    myNode = Tree.decrement( myNode, myTree.NIL );
    }

  /**
   * Retreat by a specified amount.
   * @param n The amount to retreat.
   */
  public void retreat( int n )
    {
    advance( -n );
    }

  /**
   * Return the next element in my input stream.
   * @exception java.util.NoSuchElementException If I'm positioned at an invalid position.
   */
  public Object nextElement()
    {
    if ( myNode == myTree.myHeader ) // at end?
      throw new java.util.NoSuchElementException( "OrderedMapIterator" );

    Object object = myNode.object;
    myNode = Tree.increment( myNode, myTree.NIL );

    switch ( myMode )
      {
      case PAIR:
        return object;

      case KEY:
        return ((Pair) object).first;

      case VALUE:
        return ((Pair) object).second;
      }

    return null;
    }

  /**
   * Return the object at my current position.
   */
  public Object get()
    {
    switch ( myMode )
      {
      case PAIR:
        return myNode.object;

      case KEY:
        return ((Pair) myNode.object).first;

      case VALUE:
         return ((Pair) myNode.object).second;
      }

    return null;
    }

  /**
   * Set the object at my current position to a specified value.
   * @param object The object to be written at my current position.
   */
  public void put( Object object )
    {
    myNode.object = object;
    }

  /**
   * Return the key of my current key/value pair.
   */
  public Object key()
    {
    return ((Pair) myNode.object).first;
    }

  /**
   * Return the value of my current key/value pair.
   */
  public Object value()
    {
    return ((Pair) myNode.object).second;
    }

  /**
   * Change the value of my current key/value pair.
   * @param object The new value.
   */
  public void value( Object object )
    {
    ((Pair) myNode.object).second = object;
    }

  /**
   * Return the object that is a specified distance from my current position.
   * @param offset The offset from my current position.
   */
  public Object get( int offset )
    {
    Tree.TreeNode oldNode = myNode;
    advance( offset );
    Object object = get();
    myNode = oldNode;

    switch ( myMode )
      {
      case PAIR:
        return object;

      case KEY:
        return ((Pair) object).first;

      case VALUE:
        return ((Pair) object).second;
      }

    return null;
    }

  /**
   * Write an object at a specified distance from my current position.
   * @param offset The offset from my current position.
   * @param object The object to write.
   */
  public void put( int offset, Object object )
    {
    Tree.TreeNode oldNode = myNode;
    advance( offset );
    put( object );
    myNode = oldNode;
    }

  /**
   * Return the distance from myself to another iterator.
   * I should be before the specified iterator.
   * @param iterator The iterator to compare myself against.
   */
  public int distance( ForwardIterator iterator )
    {
    Tree.TreeNode node = (Tree.TreeNode)( (Opaque)iterator ).opaqueData();
    int n = 0;

    while ( node != myNode )
      {
      ++n;
      node = Tree.decrement( node, myTree.NIL );
      }

    return n;
    }

  /**
   * Return my associated container.
   */
  public Container getContainer()
    {
    return myOrderedMap;
    }

  /**
   * Return true if both <CODE>iterator</CODE> and myself can be used
   * as a range.
   */
  public boolean isCompatibleWith( InputIterator iterator )
    {
    return 
      iterator instanceof Opaque 
      && opaqueId() == ( (Opaque)iterator ).opaqueId();
    }

  /**
   * Should not be used directly.
   * @see com.objectspace.jgl.Opaque
   */
  public Object opaqueData()
    {
    return myNode;
    }

  /**
   * Should not be used directly.
   * @see com.objectspace.jgl.Opaque
   */
  public int opaqueId()
    {
    return System.identityHashCode( myOrderedMap );
    }
  }
