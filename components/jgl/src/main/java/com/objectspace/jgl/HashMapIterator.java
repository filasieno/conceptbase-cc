// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

/**
 * A HashMapIterator is a forward iterator that allows you to iterate through
 * the contents of a HashMap. It has a mode that allows selection of the current
 * position's key, value, or key-value pair.
 * <p>
 * @see com.objectspace.jgl.ForwardIterator
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class HashMapIterator implements ForwardIterator, Opaque
  {
  public final static int PAIR = 1;
  public final static int KEY = 2;
  public final static int VALUE = 3;

  HashMap myHashMap;
  HashMap.HashMapNode myNode;
  int myMode = PAIR;

  /**
   * Construct myself to be an iterator with no associated data structure or position.
   */
  public HashMapIterator()
    {
    }

  /**
   * Construct myself to be a copy of an existing iterator.
   * @param iterator The iterator to copy.
   */
  public HashMapIterator( HashMapIterator iterator )
    {
    myHashMap = iterator.myHashMap;
    myNode = iterator.myNode;
    myMode = iterator.myMode;
    }

  /**
   * Construct myself to be positioned at a particular node in a specified Table.
   * @param table My associated table.
   * @param node My associated node.
   * @param mode My mode for returning( PAIR, KEY, VALUE )
   */
  HashMapIterator( HashMap.HashMapNode node, HashMap map, int mode )
    {
    myHashMap = map;
    myNode = node;
    myMode = mode;
    }

  /**
   * Return a clone of myself.
   */
  public Object clone()
    {
    return new HashMapIterator( this );
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
    for ( int i = 0; i < myHashMap.length; i++ )
      if ( myHashMap.buckets[ i ] != null )
        return myNode == myHashMap.buckets[ i ];

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
      Object result = null;

      switch ( myMode )
        {
        case PAIR:
          result = new Pair( myNode.key, myNode.value );
          break;

        case KEY:
          result = myNode.key;
          break;

        case VALUE:
          result = myNode.value;
          break;
        }

      myNode = ( myNode.next != null ? myNode.next : next( myNode ) );
      return result;
      }
    catch ( NullPointerException ex )
      {
      throw new java.util.NoSuchElementException( "HashMapIterator" );
      }
    }

  /**
   * Return the object at my current position.
   */
  public Object get()
    {
    switch ( myMode )
      {
      case PAIR:
        return new Pair( myNode.key, myNode.value );

      case KEY:
        return myNode.key;

      case VALUE:
        return myNode.value;
      }

    return null;
    }

  /**
   * Return the object that is a specified distance from my current position.
   * @param offset The offset from my current position.
   * @exception com.objectspace.jgl.InvalidOperationException If the parameter is less than zero.
   */
  public Object get( int offset )
    {
    HashMapIterator i = new HashMapIterator( this );
    i.advance( offset );
    return i.get();
    }

  /**
   * Set the object at my current position to a specified value.
   * @param object The object to be written at my current position.
   */
  public void put( Object object )
    {
    switch ( myMode )
      {
      case PAIR:
        Pair pair = (Pair) object;
        myNode.key = pair.first;
        myNode.value = pair.second;
        break;

      case KEY:
        myNode.key = object;
        break;

      case VALUE:
        myNode.value = object;
        break;
      }
    }

  /**
   * Write an object at a specified distance from my current position.
   * @param offset The offset from my current position.
   * @param object The object to write.
   * @exception com.objectspace.jgl.InvalidOperationException If the parameter is less than zero.
   */
  public void put( int offset, Object object )
    {
    HashMapIterator i = new HashMapIterator( this );
    i.advance( offset );
    i.put( object );
    }

  /**
   * Return the key of my current key/value pair.
   */
  public Object key()
    {
    return myNode.key;
    }

  /**
   * Return the value of my current key/value pair.
   */
  public Object value()
    {
    return myNode.value;
    }

  /**
   * Change the value of my current key/value pair.
   * @param object The new value.
   */
  public void value( Object value )
    {
    myNode.value = value;
    }

  /**
   * Return the distance from myself to another iterator.
   * I should be before the specified iterator.
   * @param iterator The iterator to compare myself against.
   */
  public int distance( ForwardIterator iterator )
    {
    HashMap.HashMapNode oldNode = myNode;
    HashMap.HashMapNode node = (HashMap.HashMapNode)( (Opaque)iterator ).opaqueData();
    int n = 0;

    while ( myNode != node )
      {
      ++n;
      myNode = ( myNode.next != null ? myNode.next : next( myNode ) );
      }

    myNode = oldNode;
    return n;
    }

  private HashMap.HashMapNode next( HashMap.HashMapNode node )
    {
    for ( int i = ( node.hash % myHashMap.length ) + 1; i < myHashMap.length; i++ )
      if ( myHashMap.buckets[ i ] != null )
        return myHashMap.buckets[ i ];

    return null;
    }

  /**
   * Return my associated container.
   */
  public Container getContainer()
    {
    return myHashMap;
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
    return System.identityHashCode( myHashMap );
    }
  }
