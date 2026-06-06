// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.functions;

import com.objectspace.jgl.*;

/**
 * PlusString is a binary function object that
 * returns the concatenation of the operands as strings.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class PlusString implements BinaryFunction
  {
  /**
   * Return the concatenation of the two operands.
   * @return first.toString() + second.toString()
   */
  public Object execute( Object first, Object second )
    {
    return first.toString() + second.toString();
    }

  static final long serialVersionUID = -4631182353564861884L;
  }
