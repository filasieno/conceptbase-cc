// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl.functions;

import com.objectspace.jgl.*;

/**
 * IdentityFunction is a unary function that returns its operand.
 * <p>
 * @see com.objectspace.jgl.UnaryFunction
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class IdentityFunction implements UnaryFunction
  {
  /**
   * Return the operand.
   * @param object The operand.
   * @return The operand.
   */
  public Object execute( Object object )
    {
    return object;
    }

  static final long serialVersionUID = 4194043794604382425L;
  }
