// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.functions;

import com.objectspace.jgl.*;

/**
 * BindFirst is a unary function object that allows you to apply a binary function to
 * a predefined value and an operand. The reason that it's called BindFirst is that the
 * predefined value is always used as the 1st parameter to the binary function.
 * <p>
 * @see com.objectspace.jgl.functions.BindSecond
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class BindFirst implements UnaryFunction
  {
  BinaryFunction myFunction;
  Object myObject;

  /**
   * Construct myself with a binary function object and a predefined value.
   * @param function The binary function object.
   * @param value The object to use as the 1st parameter.
   */
  public BindFirst( BinaryFunction function, Object value )
    {
    myFunction = function;
    myObject = value;
    }

  /**
   * Perform my binary function on the operand using the predefined value as the 1st
   * parameter and the operand as the 2nd parameter.
   * @param object The operand.
   * @return function( value, object )
   */
  public Object execute( Object object )
    {
    return myFunction.execute( myObject, object );
    }

  static final long serialVersionUID = 5980683360162906941L;
  }
