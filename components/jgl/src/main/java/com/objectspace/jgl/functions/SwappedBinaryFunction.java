// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl.functions;

import com.objectspace.jgl.*;

/**
 * SwappedBinaryFunction is a binary function that returns the result of
 * applying its operands to a BinaryFunction in the opposite order they
 * were received.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class SwappedBinaryFunction implements BinaryFunction
  {
  BinaryFunction function;

  /**
   * Construct myself with a binary function object.
   * @param function The binary function object.
   */
  public SwappedBinaryFunction( BinaryFunction function )
    {
    this.function = function;
    }

  /**
   * Swap the order of operands and return the value of my contained function.
   * @param first The first operand.
   * @param second The second operand.
   * @return function.execute( second, first )
   */
  public Object execute( Object first, Object second )
    {
    return function.execute( second, first );
    }

  static final long serialVersionUID = 3114476566955140562L;
  }
