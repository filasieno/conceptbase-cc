// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl.functions;

import com.objectspace.jgl.*;

/**
 * ConstantFunction is a predicate object that will always return the same
 * value regardless of the parameters it is passed.
 * <p>
 * @see com.objectspace.jgl.UnaryFunction
 * @see com.objectspace.jgl.BinaryFunction
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class ConstantFunction implements UnaryFunction, BinaryFunction
  {
  Object returnValue;
  
  /**
   * Construct myself to always return a specific value when invoked.
   * @param value The value to return.
   */
  public ConstantFunction( Object value )
    {
    returnValue = value;
    }

  /**
   * Return my value.
   * @param object Ignored.
   * @return The value with which I was constructed.
   */
  public Object execute( Object object )
    {
    return returnValue;
    }

  /**
   * Return my value.
   * @param first Ignored.
   * @param second Ignored.
   * @return The value with which I was constructed.
   */
  public Object execute( Object first, Object second )
    {
    return returnValue;
    }

  static final long serialVersionUID = -8698708896696521134L;
  }
