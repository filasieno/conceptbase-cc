// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * Printing is a class that contains generic printing algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.PrintingExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Printing
  {
  private Printing()
    {
    }

  /**
   * Return a string that describes a container.
   * @param container The container to describe.
   * @param name The type of the container.
   * @return A string that describes the container.
   */
  public static String toString( Container container, String name )
    {
    return name + toString( container.start(), container.finish() );
    }

  /**
   * Return a string that describes the contents of the sequence
   * associated with an iterator.
   * @param first An iterator positioned at the first element to describe.
   * @param last An iterator positioned immediately after the last element to describe.
   * @return A string that describes the container's contents.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static String toString( InputIterator first, InputIterator last )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    if ( first.atEnd() )
      return "()";

    InputIterator firstx = (InputIterator)first.clone();
    StringBuffer buffer = new StringBuffer();
    buffer.append( "( " );
    
    boolean firstone = true;
    while ( !firstx.equals( last ) )
      {
      if ( firstone )
        firstone = false;
      else
        buffer.append( ", " );
      buffer.append( firstx.nextElement() );
      }

    buffer.append( " )");
    return buffer.toString();
    }

  /**
   * Print the contents of the data structure associated with a particular iterator
   * to the standard output stream, System.out.
   * @param first An iterator positioned at the first element to print.
   * @param last An iterator positioned immediately after the last element to print.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static void print( InputIterator first, InputIterator last )
    {
    System.out.print( toString( first, last ) );
    }

  /**
   * Print the contents of the container
   * to the standard output stream, System.out.
   * @param container The container to describe.
   */
  public static void print( Container container )
    {
    System.out.print( toString( container.start(), container.finish() ) );
    }

  /**
   * Print the contents of the data structure associated with a particular iterator
   * to the standard output stream, System.out, followed by a newline.
   * @param first An iterator positioned at the first element to print.
   * @param last An iterator positioned immediately after the last element to print.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static void println( InputIterator first, InputIterator last )
    {
    System.out.println( toString( first, last ) );
    }

  /**
   * Print the contents of the container
   * to the standard output stream, System.out, followed by a newline.
   * @param container The container to describe.
   */
  public static void println( Container container )
    {
    System.out.println( toString( container.start(), container.finish() ) );
    }
  }
