// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.util;

import com.objectspace.jgl.*;
import java.io.OutputStream;
import java.io.IOException;

/**
 * An OutputStreamIterator is an output iterator that prints objects that are written
 * to it. By default, it writes to the standard output stream System.out.
 * <p>
 * @see com.objectspace.jgl.OutputIterator
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class OutputStreamIterator implements OutputIterator
  {
  OutputStream myStream;
  String delimiter;

  /**
   * Construct myself to print all objects to the standard output stream, System.out.
   */
  public OutputStreamIterator()
    {
    myStream = System.out;
    delimiter = " ";
    }

  /**
   * Construct myself to print all objects to the standard output stream, System.out.
   * A delimiter will be printed after each object.
   * @param delimiter The string to print between objects.
   */
  public OutputStreamIterator( String delimiter )
    {
    myStream = System.out;
    this.delimiter = delimiter;
    }

  /**
   * Construct myself to print all objects to the specified PrintStream.
   * @param stream The PrintStream.
   */
  public OutputStreamIterator( OutputStream stream )
    {
    myStream = stream;
    delimiter = " ";
    }

  /**
   * Construct myself to print all objects to the specified PrintStream.
   * A delimiter will be printed after each object.
   * @param stream The PrintStream.
   * @param delimited The string to print between objects.
   */
  public OutputStreamIterator( OutputStream stream, String delimiter )
    {
    myStream = stream;
    this.delimiter = delimiter;
    }

  /**
   * Construct myself to be associated with the same PrintStream as the specified iterator.
   */
  public OutputStreamIterator( OutputStreamIterator iterator )
    {
    myStream = iterator.myStream;
    delimiter = iterator.delimiter;
    }

  void show( String s )
    {
    int len = s.length();
    try
      {
      for ( int i = 0 ; i < len ; i++ )
        myStream.write( s.charAt( i ) );
      }
    catch ( IOException exception )
      {
      System.err.println( "Caught exception " + exception );
      }
    }

  /**
   * Print the object to my OutputStream.
   * @param object The object.
   */
  public void put( Object object )
    {
    String s = ( object == null ? "null" : object.toString() );
    show( s + delimiter );
    }

  /**
   * Advance by one. This has no effect for an OutputStreamIterator.
   */
  public void advance()
    {
    // Do nothing.
    }

  /**
   * Advance by a specified amount. This has no effect for a OutputStreamIterator.
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
    return new OutputStreamIterator( this );
    }
  }
