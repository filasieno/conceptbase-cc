// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl.util;

import com.objectspace.jgl.*;
import java.io.ObjectOutputStream;
import java.io.IOException;

/**
 * An ObjectOutputStreamIterator is an output iterator that writes objects
 * to an ObjectOutputStream.
 * <p>
 * @see java.io.ObjectOutputStream
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class ObjectOutputStreamIterator implements OutputIterator
  {
  ObjectOutputStream stream;

  /**
   * Construct myself to print all objects to the specified stream.
   * @param stream The stream.
   */
  public ObjectOutputStreamIterator( ObjectOutputStream stream )
    {
    this.stream = stream;
    }

  /**
   * Construct myself to be associated with the same stream as the specified
   * iterator.
   */
  public ObjectOutputStreamIterator( ObjectOutputStreamIterator iterator )
    {
    stream = iterator.stream;
    }

  /**
   * Return the stream upon which I operate.
   */
  public ObjectOutputStream getStream()
    {
    return stream;
    }

  /**
   * Print the object to my ObjectOutputStream.
   * @param object The object.
   */
  public void put( Object object )
    {
    try
      {
      stream.writeObject( object );
      }
    catch ( IOException e )
      {
      }
    }

  /**
   * Advance by one. This has no effect for an ObjectOutputStreamIterator.
   */
  public void advance()
    {
    // Do nothing.
    }

  /**
   * Advance by a specified amount. This has no effect for a
   * ObjectOutputStreamIterator.
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
    return new ObjectOutputStreamIterator( this );
    }
  }
