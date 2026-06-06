// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.functions;

import com.objectspace.jgl.*;

/**
 * SelectFirst is a unary function that assumes that its operand is a Pair and returns
 * its first instance variable.
 * <p>
 * @see com.objectspace.jgl.functions.SelectSecond
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class SelectFirst implements UnaryFunction
  {
  /**
   * Return the first instance variable of my operand.
   * @param object The operand, which must be an instance of Pair.
   * @return object.first
   */
  public Object execute( Object object )
    {
    return ((Pair) object).first;
    }

  static final long serialVersionUID = -5535405068776967023L;
  }
