// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.util;

import com.objectspace.jgl.*;

/**
 * An InsertIterator is an output iterator that adds any object that is written to it
 * into a specified Container.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class InsertIterator implements OutputIterator, java.io.Serializable
  {
  Container my_container;

  /**
   * Construct myself so that current( object ) inserts the object into a container
   * using add().
   * @param container The container to add to.
   */
  public InsertIterator( Container container )
    {
    my_container = container;
    }

  /**
   * Construct myself to be a copy of the specified iterator.
   * @param iterator The iterator to copy.
   */
  public InsertIterator( InsertIterator iterator )
    {
    my_container = iterator.my_container;
    }

  /**
   * Insert the object to my associated container using add().
   * @param object The object to be added.
   */
  public void put( Object object )
    {
    my_container.add( object );
    }

  /**
   * Advance by one. This has no effect for an InsertIterator.
   */
  public void advance()
    {
    // Do nothing.
    }

  /**
   * Advance by a specified amount. This has no effect for an InsertIterator.
   * @param n The amount to advance.
   */
  public void advance( int n )
    {
    // Do nothing.
    }

  /**
   * Return a clone of myself.
   */
  public Object clone()
    {
    return new InsertIterator( this );
    }

  static final long serialVersionUID = 4093770232146281028L;
  }
