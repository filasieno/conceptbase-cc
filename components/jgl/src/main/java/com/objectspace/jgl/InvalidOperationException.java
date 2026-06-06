// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

/**
 * InvalidOperationException is a runtime exception that is thrown when a container
 * is asked to perform an inappropriate operation.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class InvalidOperationException extends RuntimeException
  {
  /**
   * Constructs a InvalidOperationException with no detail message.
   * A detail message is a String that describes this particular exception.
   */
  public InvalidOperationException()
    {
    }

  /**
   * Constructs a InvalidOperationException with the specified detail message.
   * A detail message is a String that describes this particular exception.
   * @param message The detail message.
   */
  public InvalidOperationException( String message )
    {
    super( message );
    }
 
  static final long serialVersionUID = -4612378873430396615L;
  }
