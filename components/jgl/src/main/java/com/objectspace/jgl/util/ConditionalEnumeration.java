// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl.util;

import com.objectspace.jgl.UnaryPredicate;
import java.util.Enumeration;
import java.util.NoSuchElementException;

/**
 * ConditionalEnumeration is an enumeration that traverses a subset
 * of values.
 * <p>
 * @see java.util.Enumeration
 * @see com.objectspace.jgl.UnaryPredicate
 * @author ObjectSpace, Inc.
 */

public class ConditionalEnumeration implements Enumeration, java.io.Serializable
  {
  Enumeration enumeration;
  UnaryPredicate condition;
  Object object = null;
  boolean loaded = false;
  boolean hasMore = false;

  /**
   * Construct myself to iterate over the same elements as enumeration.
   * @param enumeration The enumeration to traverse.
   */
  public ConditionalEnumeration( Enumeration enumeration )
    {
    this.enumeration = enumeration;
    this.condition = new UnaryPredicate() 
      { 
      public boolean execute( Object object ){ return true; } 
      };
    }

  /**
   * Construct myself to iterate over the elements of enumeration that meet
   * the given condition.
   * @param enumeration The enumeration to traverse.
   * @param condition The predicate used to determine legal enumerated values.
   */
  public ConditionalEnumeration( Enumeration enumeration, UnaryPredicate condition )
    {
    this.enumeration = enumeration;
    this.condition = condition;
    }

  /**
   * Return <code>true</code> if there are more elements in my input stream 
   * that meet my condition.
   */
  public boolean hasMoreElements()
    {
    if ( !loaded )
      {
      hasMore = true;
      try
        {
        nextElement();
        }
      catch ( Exception ex )
        {
        hasMore = false;
        }
      loaded = true;
      }
    return hasMore;
    }

  /**
   * Return the next element in my input stream that meets my condition.
   * @exception java.util.NoSuchElementException If there are no more 
   *  elements.
   */
  public Object nextElement() throws NoSuchElementException
    {
    if ( loaded && hasMore )
      loaded = false;
    else
      {
      do
        {
        object = enumeration.nextElement();
        }
      while ( !condition.execute( object ) );
      }
    return object;
    }

  static final long serialVersionUID = 7280624882633425321L;
  }
