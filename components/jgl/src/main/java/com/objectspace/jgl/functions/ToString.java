// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.functions;

import com.objectspace.jgl.*;

/**
 * ToString is a unary function that returns its operand as a String.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class ToString implements UnaryFunction
  {
  /**
   * Return my argument as a String, or "null" if the operand is null.
   * @param object The operand.
   * @return A String that describes the operand, using the standard Java toString() method.
   */
  public Object execute( Object object )
    {
    return object == null ? "null" : object.toString();
    }

  static final long serialVersionUID = 2164950815995006391L;
  }
