// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.functions;

import com.objectspace.jgl.*;

/**
 * Hash is a unary function that returns the hash code of its operand.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class Hash implements UnaryFunction
  {
  /**
   * Return the hash code of my operand as an Integer, or 0 if the operand is null.
   * @param object The operand.
   * @return The hash code of the operand, using the standard Java hashCode() method.
   */
  public Object execute( Object object )
    {
    return new Integer( object == null ? 0 : object.hashCode() );
    }

  static final long serialVersionUID = 1316300039283310140L;
  }
