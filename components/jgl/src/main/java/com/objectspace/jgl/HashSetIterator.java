// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

/**
 * A HashSetIterator is a forward iterator that allows you to iterate through
 * the contents of a HashSet.
 * <p>
 * @see com.objectspace.jgl.ForwardIterator
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class HashSetIterator implements ForwardIterator, Opaque
  {
  HashSet myHashSet;
  HashSet.HashSetNode myNode;

  /**
   * Construct myself to be an iterator with no associated data structure or position.
   */
  public HashSetIterator()
    {
    }

  /**
   * Construct myself to be a copy of an existing iterator.
   * @param iterator The iterator to copy.
   */
  public HashSetIterator( HashSetIterator iterator )
    {
    myHashSet = iterator.myHashSet;
    myNode = iterator.myNode;
    }

  /**
   * Construct myself to be positioned at a particular node in a specified Table.
   * @param node My associated node.
   * @param set My associated HashSet.
   */
  HashSetIterator( HashSet.HashSetNode node, HashSet set )
    {
    myHashSet = set;
    myNode = node;
    }

  /**
   * Return a clone of myself.
   */
  public Object clone()
    {
    return new HashSetIterator( this );
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
    if ( myHashSet == null )
      return false;

    for ( int i = 0; i < myHashSet.length; i++ )
      if ( myHashSet.buckets[ i ] != null )
        return myNode == myHashSet.buckets[ i ];

    return true;
    }

  /**
   * Return true if I'm positioned after the last item in my input stream.
   */
  public boolean atEnd()
    {
    return myNode == null;
    }

  /**
   * Return true if there are more elements in my input stream.
   */
  public boolean hasMoreElements()
    {
    return myNode != null;
    }

  /**
   * Advance by one.
   */
  public void advance()
    {
    myNode = ( myNode.next != null ? myNode.next : next( myNode ) );
    }

  /**
   * Advance by a specified amount.
   * @param n The amount to advance.
   * @exception com.objectspace.jgl.InvalidOperationException If the parameter is less than zero.
   */
  public void advance( int n )
    {
    if ( n < 0 )
      throw new InvalidOperationException( "Attempt to advance a ForwardIterator in the wrong direction." );
    while ( n-- > 0 )
      advance();
    }

  /**
   * Return the next element in my input stream.
   * @exception java.util.NoSuchElementException If I'm positioned at an invalid position.
   */
  public Object nextElement()
    {
    try
      {
      Object object = myNode.object;
      myNode = ( myNode.next != null ? myNode.next : next( myNode ) );
      return object;
      }
    catch ( NullPointerException ex )
      {
      throw new java.util.NoSuchElementException( "HashSetIterator" );
      }
    }

  /**
   * Return the object at my current position.
   */
  public Object get()
    {
    return myNode.object;
    }

  /**
   * Return the object that is a specified distance from my current position.
   * @param offset The offset from my current position.
   * @exception com.objectspace.jgl.InvalidOperationException If the parameter is less than zero.
   */
  public Object get( int offset )
    {
    HashSetIterator i = new HashSetIterator( this );
    i.advance( offset );
    return i.get();
    }

  /**
   * Write an object at a specified distance from my current position.
   * @param offset The offset from my current position.
   * @param object The object to write.
   * @exception com.objectspace.jgl.InvalidOperationException If the parameter is less than zero.
   */
  public void put( int offset, Object object )
    {
    HashSetIterator i = new HashSetIterator( this );
    i.advance( offset );
    i.put( object );
    }

  /**
   * HashSet the object at my current position to a specified value.
   * @param object The object to be written at my current position.
   */
  public void put( Object object )
    {
    myNode.object = object;
    }

  /**
   * Return the distance from myself to another iterator.
   * I should be before the specified iterator.
   * @param iterator The iterator to compare myself against.
   */
  public int distance( ForwardIterator iterator )
    {
    HashSet.HashSetNode oldNode = myNode;
    HashSet.HashSetNode node = (HashSet.HashSetNode)( (Opaque)iterator ).opaqueData();
    int n = 0;

    while ( myNode != node )
      {
      ++n;
      myNode = ( myNode.next != null ? myNode.next : next( myNode ) );
      }

    myNode = oldNode;
    return n;
    }

  /**
   * Return my associated HashSet
   */
  public Container getContainer()
    {
    return myHashSet;
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
    return System.identityHashCode( myHashSet );
    }

  private HashSet.HashSetNode next( HashSet.HashSetNode node )
    {
    for ( int i = ( node.hash % myHashSet.length ) + 1; i < myHashSet.length; i++ )
      if ( myHashSet.buckets[ i ] != null )
        return myHashSet.buckets[ i ];

    return null;
    }
  }
