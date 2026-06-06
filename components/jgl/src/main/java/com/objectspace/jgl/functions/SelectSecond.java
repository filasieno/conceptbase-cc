// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.functions;

import com.objectspace.jgl.*;

/**
 * SelectSecond is a unary function that assumes that its operand is a Pair and returns
 * its second instance variable.
 * <p>
 * @see com.objectspace.jgl.functions.SelectFirst
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class SelectSecond implements UnaryFunction
  {
  /**
   * Return the second instance variable of my operand.
   * @param object The operand, which must be an instance of Pair.
   * @return object.second
   */
  public Object execute( Object object )
    {
    return ((Pair) object).second;
    }

  static final long serialVersionUID = -210091122974618674L;
  }
