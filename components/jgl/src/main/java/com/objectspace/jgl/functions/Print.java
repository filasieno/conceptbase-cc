// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.functions;

import com.objectspace.jgl.*;
import java.io.PrintStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.IOException;

/**
 * Print is a unary function object that prints its operand to a PrintStream 
 * followed by a newline.
 * <p>
 * @see com.objectspace.jgl.util.OutputStreamIterator
 * @see java.io.PrintStream
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Print implements UnaryFunction
  {
  transient PrintStream stream;

  /**
   * Construct myself to print all objects to the standard output stream, System.out.
   */
  public Print()
    {
    stream = System.out;
    }

  /**
   * Construct myself to print all objects to the specified PrintStream.
   * @param stream The PrintStream.
   */
  public Print( PrintStream stream )
    {
    this.stream = stream;
    }

  /**
   * Print my operand to my PrintStream.
   * @param object The operand.
   * @return The operand.
   */
  public Object execute( Object object )
    {
    stream.println( object );
    return object;
    }

  private synchronized void writeObject( ObjectOutputStream stream ) throws IOException
    {
    stream.defaultWriteObject();
    if ( this.stream == System.out )
      stream.writeObject( new Boolean( true ) );
    else if ( this.stream == System.err )
      stream.writeObject( new Boolean( false ) );
    else
      stream.writeObject( this.stream );
    }
 
  private void readObject( ObjectInputStream stream ) throws IOException, ClassNotFoundException
    {
    stream.defaultReadObject();
    Object obj = stream.readObject();
    if ( obj instanceof Boolean )
      this.stream = ( (Boolean)obj ).booleanValue()
        ? System.out
        : System.err;
    else
      this.stream = (PrintStream)obj;
    }

  static final long serialVersionUID = -5840439502902947163L;
  }
