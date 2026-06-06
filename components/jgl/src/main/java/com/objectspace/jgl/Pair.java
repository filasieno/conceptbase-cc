// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.io.Serializable;

/**
 * A Pair is an object that contains two other objects. It is
 * most commonly used for conveniently storing and passing pairs
 * of objects.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class Pair implements Serializable
  {
  /**
   * The first object.
   */
  public Object first;

  /**
   * The second object.
   */
  public Object second;

  /**
   * Construct myself to hold a pair of objects.
   * @param x The first object.
   * @param y The second object.
   */
  public Pair( Object x, Object y )
    {
    first = x;
    second = y;
    }

  /**
   * Construct myself to hold a pair of objects initially null.
   */
  public Pair()
    {
    first = null;
    second = null;
    }

  /**
   * Construct myself to be a copy of an existing Pair.
   * @param pair The Pair to copy.
   */
  public Pair( Pair pair )
    {
    first = pair.first;
    second = pair.second;
    }

  /**
   * Return my hash code.
   */
  public int hashCode()
    {
    int h = first == null ? 0 : first.hashCode();
    if ( second != null )
      h ^= second.hashCode();
    return h;
    }

  /**
   * Return a string that describes me.
   */
  public String toString()
    {
    return "Pair( " + first + ", " + second + " )";
    }

  public boolean equals( Object object )
    {
    return object instanceof Pair && equals( (Pair)object );
    }

  public boolean equals( Pair pair )
    {
    if ( pair == null )
      return false;

    return
      ( first == null ? pair.first == null : first.equals( pair.first ) )
      && ( second == null ? pair.second == null : second.equals( pair.second ) );
    }

  /**
   * Return a copy of myself.
   */
  public synchronized Object clone()
    {
    return new Pair( this );
    }

  static final long serialVersionUID = 3690756099267025454L;
  }
