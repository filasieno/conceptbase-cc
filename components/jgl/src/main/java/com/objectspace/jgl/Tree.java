// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.io.Serializable;
import java.io.ObjectOutputStream;
import java.io.ObjectInputStream;
import java.io.IOException;

/**
 * Tree is a red-black tree structure used as the underlying data structure by all
 * all associative containers.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

final class Tree implements Serializable
  {
  public static final int RED = 1;
  public static final int BLACK = 2;
  TreeNode NIL = new TreeNode();
  int size;
  boolean myInsertAlways;
  boolean myIsMap;
  BinaryPredicate myComparator;
  Container myContainer;
  TreeNode myHeader = new TreeNode(); // Note: myHeader == end, myHeader.left == begin

  Tree( boolean isMap, boolean always, Container container )
    {
    this( isMap, always, new xHashComparator(), container );
    }

  Tree( boolean isMap, boolean always, BinaryPredicate comparator, Container container )
    {
    myContainer = container;
    myIsMap = isMap;
    myInsertAlways = always;
    myComparator = comparator;
    myHeader.color = RED;
    clear();
    }

  Tree( Tree tree, Container c )
    {
    myContainer = c;
    myIsMap = tree.myIsMap;
    myInsertAlways = tree.myInsertAlways;
    myComparator = tree.myComparator;
    myHeader.color = RED;
    copyTree( tree );
    }

  boolean compare( Object first, Object second )
    {
    return myComparator.execute( first, second );
    }

  Object key( Object object )
    {
    return myIsMap ? ( (Pair)object).first : object;
    }

  Object value( Object object )
    {
    if ( myIsMap )
      {
      if ( object == null )
        return null;

      return ( (Pair)object ).second;
      }
    else
      {
      return object;
      }
    }

  void copy( Tree tree )
    {
    if ( this != tree )
      {
      clear();
      copyTree( tree );
      }
    }

  OrderedSetIterator beginSet()
    {
    return new OrderedSetIterator( this, myHeader.left, (OrderedSet)myContainer );
    }

  OrderedSetIterator endSet()
    {
    return new OrderedSetIterator( this, myHeader, (OrderedSet)myContainer );
    }

  OrderedMapIterator beginMap( int mode )
    {
    return new OrderedMapIterator( this, myHeader.left, (OrderedMap)myContainer, mode );
    }

  OrderedMapIterator endMap( int mode )
    {
    return new OrderedMapIterator( this, myHeader, (OrderedMap)myContainer, mode );
    }

  int maxSize()
    {
    return Integer.MAX_VALUE;
    }

  TreeNode insert( TreeNode pos, Object value )
    {
    if ( pos == myHeader.left )
      {
      if ( size > 0 && compare( key( value ), key( pos.object ) ) )
        return insert( pos, pos, value );
      else
        return insert( value ).node;
      }
    else if ( pos == myHeader )
      {
      if ( compare( key( myHeader.right.object ), key( value ) ) )
        return insert( NIL, myHeader.right, value );
      else
        return insert( value ).node;
      }
    else
      {
      TreeNode before = decrement( pos, NIL );

      if ( compare( key( before.object ), key( value ) ) && compare( key( value ), key( pos.object ) ) )
        if ( before.right == NIL )
          return insert( NIL, before, value );
        else
          return insert( pos, pos, value );
      else
        return insert( value ).node;
      }
    }

  void clear()
    {
    myHeader.parent = NIL;
    myHeader.right = myHeader;
    myHeader.left = myHeader;
    size = 0;
    }

  Pair remove( Object key )
    {
    Pair range = equalRange( key );
    return remove( (TreeNode)range.first, (TreeNode)range.second, size );
    }

  Pair remove( Object key, int maximum )
    {
    Pair range = equalRange( key );
    return remove( (TreeNode)range.first, (TreeNode)range.second, maximum );
    }

  Pair remove( TreeNode first, TreeNode last )
    {
    return remove( first, last, size );
    }

  Pair remove( TreeNode first, TreeNode last, int maximum )
    {
    if ( maximum <= 0 )
      return new Pair( null, new Integer( 0 ) );

    int count = 0;
    Object rvalue = null;
    if ( first == myHeader.left && last == myHeader && size <= maximum )
      {
      count = size;
      rvalue = value( first.object );
      clear();
      }
    else
      {
      TreeNode next;
      while ( maximum > 0 && first != last )
        {
        if ( count == 0 )
          rvalue = value( first.object );
        --maximum;
        ++count;
        next = increment( first, NIL );
        remove( first );
        first = next;
        }
      }

    return new Pair( rvalue, new Integer( count ) );
    }

  TreeNode find( Object key )
    {
    TreeNode j = lowerBound( key );
    return ( j == myHeader || compare( key, key( j.object ) ) ) ? myHeader : j;
    }

  int count( Object key )
    {
    Pair range = equalRange( key );
    return distance( (TreeNode)range.first, (TreeNode)range.second, NIL );
    }

  TreeNode lowerBound( Object key )
    {
    return (TreeNode)equalRange( key ).first;
    }

  TreeNode upperBound( Object key )
    {
    return (TreeNode)equalRange( key ).second;
    }

  Pair equalRange( Object key )
    {
    TreeNode lower = lowerBoundAux( key );
    TreeNode upper = upperBoundAux( key );

    // upper == end()
    if ( upper == myHeader )
      return new Pair( lower, upper );

    // lower == end()
    if ( lower == myHeader )
      return new Pair( upper, lower );

    // advance each node until one reaches either the end of the
    // tree or the other node
    TreeNode b = lower;
    TreeNode e = upper;
    while ( true )
      {
      b = increment( b, NIL );
      e = increment( e, NIL );
      if ( e == myHeader || b == upper )
        return new Pair( lower, upper );
      if ( b == myHeader || lower == e )
        return new Pair( upper, lower );
      }
    }

  TreeNode lowerBoundAux( Object key )
    {
    TreeNode y = myHeader;
    TreeNode x = myHeader.parent;
    boolean comp = false;

    while ( x != NIL )
      {
      y = x;
      comp = compare( key( x.object ), key );
      x = comp ? x.right : x.left;
      }

    return comp ? increment( y, NIL ) : y;
    }

  TreeNode upperBoundAux( Object key )
    {
    TreeNode y = myHeader;
    TreeNode x = myHeader.parent;
    boolean comp = true;

    while ( x != NIL )
      {
      y = x;
      comp = compare( key, key( x.object ) );
      x = comp ? x.left : x.right;
      }

    return comp ? y : increment( y, NIL );
    }

  void insert( InputIterator first, InputIterator last )
    {
    InputIterator firstx = (InputIterator)first.clone();

    while ( !firstx.equals( last ) )
      insert( firstx.nextElement() );
    }

  Tree.InsertResult insertAux( Object value, boolean shortCircut )
    {
    TreeNode y = myHeader;
    TreeNode x = myHeader.parent;
    boolean comp = true;

    while ( x != NIL )
      {
      y = x;
      comp = compare( key( value ), key( x.object ) );
      x = comp ? x.left : x.right;
      }

    if ( myInsertAlways && shortCircut )
      return new Tree.InsertResult( insert( x, y, value ), true );

    TreeNode j = y;

    if ( comp )
      if ( j == myHeader.left )
        return new Tree.InsertResult( insert( x, y, value ), true );
      else
        j = decrement( j, NIL );

    if ( compare( key( j.object ), key( value ) ) )
      return new Tree.InsertResult( insert( x, y, value ), true );
    else
      return new Tree.InsertResult( j, false );
    }

  Tree.InsertResult insert( Object value )
    {
    return insertAux( value, true );
    }

  Tree.InsertResult put( Object value )
    {
    return insertAux( value, false );
    }

  Object get( Object key )
    {
    TreeNode y = myHeader;
    TreeNode x = myHeader.parent;
    boolean comp = true;

    while ( x != NIL )
      {
      y = x;
      comp = compare( key, key( x.object ) );
      x = comp ? x.left : x.right;
      }

    TreeNode j = y;

    if ( comp )
      if ( j == myHeader.left )
        return null;
      else
        j = decrement( j, NIL );

    if ( compare( key( j.object ), key ) )
      return null;
    else
      return ( (Pair)j.object ).second;
    }

  TreeNode insert( TreeNode x, TreeNode y, Object value )
    {
    ++size;
    TreeNode z = new TreeNode( value );
    boolean insertToLeft = ( y == myHeader || x != NIL || compare( key( value ), key( y.object ) ) );
    insert( insertToLeft, x, y, z );
    return z;
    }

  static int distance( TreeNode first, TreeNode last, TreeNode NIL )
    {
    int n = 0;

    while ( first != last )
      {
      first = increment( first, NIL );
      ++n;
      }

    return n;
    }

  TreeNode copyTree( TreeNode oldNode, TreeNode parent, TreeNode otherNIL )
    {
    if ( oldNode == otherNIL )
      return NIL;

    TreeNode newNode = new TreeNode( oldNode.object );
    newNode.color = oldNode.color;
    newNode.left = copyTree( oldNode.left, newNode, otherNIL );
    newNode.right = copyTree( oldNode.right, newNode, otherNIL );
    newNode.parent = parent;
    return newNode;
    }

  void copyTree( Tree tree )
    {
    myHeader.parent = copyTree( tree.myHeader.parent, myHeader, tree.NIL );
    myHeader.left = minimum( myHeader.parent );
    myHeader.right = maximum( myHeader.parent );
    size = tree.size;
    }

  Array keys()
    {
    Array array = new Array();
    int i = 0;
    TreeNode node = myHeader.left;

    while ( node != myHeader )
      {
      array.add( ( (Pair)node.object).first );
      node = increment( node, NIL );
      }

    return array;
    }

  Array keys( Object value )
    {
    Array array = new Array();
    int i = 0;
    TreeNode node = myHeader.left;

    while ( node != myHeader )
      {
      if ( ( (Pair)node.object ).second.equals( value ) )
        array.add( ( (Pair)node.object).first );

      node = increment( node, NIL );
      }

    return array;
    }


  Array values( Object key )
    {
    Array array = new Array();
    Pair range = equalRange( key );

    TreeNode node = (TreeNode)range.first;
    TreeNode last = (TreeNode)range.second;
    while ( node != last )
      {
      array.add( ( (Pair)node.object ).second );
      node = increment( node, NIL );
      }

    return array;
    }

  static TreeNode increment( TreeNode node, TreeNode NIL )
    {
    if ( node.right != NIL )
      {
      node = node.right;

      while ( node.left != NIL )
        node = node.left;

      return node;
      }
    else
      {
      while ( node == node.parent.right )
        node = node.parent;

      return node.right == node.parent ? node : node.parent;
      }
    }

  static TreeNode decrement( TreeNode node, TreeNode NIL )
    {
    if ( node.color == RED && node.parent.parent == node )
      {
      return node.right;
      }
    else if ( node.left != NIL )
      {
      node = node.left;

      while ( node.right != NIL )
        node = node.right;

      return node;
      }
    else
      {
      while ( node == node.parent.left )
        node = node.parent;

      return node.parent;
      }
    }

  TreeNode minimum( TreeNode node )
    {
    if ( node == NIL )
      {
      return myHeader;
      }
    else
      {
      while ( node.left != NIL )
        node = node.left;

      return node;
      }
    }

  TreeNode maximum( TreeNode node )
    {
    if ( node == NIL )
      {
      return myHeader;
      }
    else
      {
      while ( node.right != NIL )
        node = node.right;

      return node;
      }
    }

  void rotateLeft( TreeNode x )
    {
    TreeNode y = x.right;
    x.right = y.left;

    if ( y.left != NIL )
      y.left.parent = x;

    y.parent = x.parent;

    if ( x == myHeader.parent )
      myHeader.parent = y;
    else if ( x == x.parent.left )
      x.parent.left = y;
    else
      x.parent.right = y;

    y.left = x;
    x.parent = y;
    }

  void rotateRight( TreeNode x )
    {
    TreeNode y = x.left;
    x.left = y.right;

    if ( y.right != NIL )
      y.right.parent = x;

    y.parent = x.parent;

    if ( x == myHeader.parent )
      myHeader.parent = y;
    else if ( x == x.parent.right )
      x.parent.right = y;
    else
      x.parent.left = y;

    y.right = x;
    x.parent = y;
    }

  void insert( boolean insertToLeft, TreeNode x, TreeNode y, TreeNode z )
    {
    if ( insertToLeft )
      {
      y.left = z;

      if ( y == myHeader )
        {
        myHeader.parent = z;
        myHeader.right = z;
        }
      else if ( y == myHeader.left )
        {
        myHeader.left = z;
        }
      }
    else
      {
      y.right = z;

      if ( y == myHeader.right )
        myHeader.right = z;
      }

    z.parent = y;
    z.left = NIL;
    z.right = NIL;
    x = z;
    x.color = RED;

    while ( x != myHeader.parent && x.parent.color == RED )
      if ( x.parent == x.parent.parent.left )
        {
        y = x.parent.parent.right;

        if ( y.color == RED )
          {
          x.parent.color = BLACK;
          y.color = BLACK;
          x.parent.parent.color = RED;
          x = x.parent.parent;
          }
        else
          {
          if ( x == x.parent.right )
            {
            x = x.parent;
            rotateLeft( x );
            }

          x.parent.color = BLACK;
          x.parent.parent.color = RED;
          rotateRight( x.parent.parent );
          }
        }
      else
        {
        y = x.parent.parent.left;

        if ( y.color == RED )
          {
          x.parent.color = BLACK;
          y.color = BLACK;
          x.parent.parent.color = RED;
          x = x.parent.parent;
          }
        else
          {
          if ( x == x.parent.left )
            {
            x = x.parent;
            rotateRight( x );
            }

          x.parent.color = BLACK;
          x.parent.parent.color = RED;
          rotateLeft( x.parent.parent );
          }
        }

      myHeader.parent.color = BLACK;
    }

  TreeNode remove( TreeNode z )
    {
    TreeNode y = z;
    TreeNode x;

    if ( y.left == NIL )
      {
      x = y.right;
      }
    else if ( y.right == NIL )
      {
      x = y.left;
      }
    else
      {
      y = y.right;

      while ( y.left != NIL )
        y = y.left;

      x = y.right;
      }

    if ( y != z )
      {
      z.left.parent = y;
      y.left = z.left;

      if ( y != z.right )
        {
        x.parent = y.parent;
        y.parent.left = x;
        y.right = z.right;
        z.right.parent = y;
        }
      else
        {
        x.parent = y;
        }

      if ( myHeader.parent == z )
        myHeader.parent = y;
      else if ( z.parent.left == z )
        z.parent.left = y;
      else
        z.parent.right = y;

      y.parent = z.parent;

      // Swap color of y and z.
      int tmp = y.color;
      y.color = z.color;
      z.color = tmp;

      y = z;
      }
    else
      {
      x.parent = y.parent;

      if ( myHeader.parent == z )
        myHeader.parent = x;
      else if ( z.parent.left == z )
        z.parent.left = x;
      else
        z.parent.right = x;

      if ( myHeader.left == z )
        if ( z.right == NIL )
          myHeader.left = z.parent;
        else
          myHeader.left = minimum( x );

      if ( myHeader.right == z )
        if ( z.left == NIL )
          myHeader.right = z.parent;
        else
          myHeader.right = maximum( x );
      }

    if ( y.color != RED )
      {
      while ( x != myHeader.parent && x.color == BLACK )
        if ( x == x.parent.left )
          {
          TreeNode w = x.parent.right;

          if ( w.color == RED )
            {
            w.color = BLACK;
            x.parent.color = RED;
            rotateLeft( x.parent );
            w = x.parent.right;
            }

          if ( w.left.color == BLACK && w.right.color == BLACK )
            {
            w.color = RED;
            x = x.parent;
            }
          else
            {
            if ( w.right.color == BLACK )
              {
              w.left.color = BLACK;
              w.color = RED;
              rotateRight( w );
              w = x.parent.right;
              }

            w.color = x.parent.color;
            x.parent.color = BLACK;
            w.right.color = BLACK;
            rotateLeft( x.parent );
            break;
            }
          }
        else
          {
          TreeNode w = x.parent.left;

          if ( w.color == RED )
            {
            w.color = BLACK;
            x.parent.color = RED;
            rotateRight( x.parent );
            w = x.parent.left;
            }

          if ( w.right.color == BLACK && w.left.color == BLACK )
            {
            w.color = RED;
            x = x.parent;
            }
          else
            {
            if ( w.left.color == BLACK )
              {
              w.right.color = BLACK;
              w.color = RED;
              rotateLeft( w );
              w = x.parent.left;
              }

            w.color = x.parent.color;
            x.parent.color = BLACK;
            w.left.color = BLACK;
            rotateRight( x.parent );
            break;
            }
          }

      x.color = BLACK;
      }

    --size;
    return y;
    }

  private void readObject( ObjectInputStream stream ) throws IOException, ClassNotFoundException
    {
    stream.defaultReadObject();

    // ordering can't be off if we don't have multiple objects
    if ( size < 2 )
      return;

    // check internal order
    boolean ordered = true;
    TreeNode node = myHeader.left;
    for ( int x = 1; ordered && x < size; ++x )
      {
      TreeNode next = increment( node, NIL );
      ordered = compare( key( node.object ), key( next.object ) );
      node = next;
      }
    if ( ordered ) 
      return;

    // I am out of order!
    node = myHeader.left;
    int s = size;
    clear();
    while ( s-- > 0 )
      {
      insert( node.object );
      node = increment( node, NIL );
      }
    }

  final class TreeNode implements Serializable
    {
    public int color = Tree.BLACK;
    public TreeNode parent;
    public TreeNode left;
    public TreeNode right;
    public Object object;

    public TreeNode()
      {
      }

    public TreeNode( Object value )
      {
      object = value;
      }
    }

  final class InsertResult
    {
    public boolean ok;
    public Tree.TreeNode node;

    public InsertResult( Tree.TreeNode n, boolean b )
      {
      ok = b;
      node = n;
      }
    }

  static final long serialVersionUID = -7780623882639425521L;
  }
