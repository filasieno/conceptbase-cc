// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.functions;

import com.objectspace.jgl.*;

/**
 * UnaryCompose is a unary function object that returns the result of executing
 * two operations in a specific sequence.
 * <p>
 * @see com.objectspace.jgl.functions.BinaryCompose
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class UnaryCompose implements UnaryFunction
  {
  UnaryFunction myFunction1;
  UnaryFunction myFunction2;

  /**
   * Construct myself with two unary function objects.
   * @param function1 The first unary function object.
   * @param function2 The second unary function object.
   */
  public UnaryCompose( UnaryFunction function1, UnaryFunction function2 )
    {
    myFunction1 = function1;
    myFunction2 = function2;
    }

  /**
   * Perform my second unary function on the operand and then return the result of applying
   * my first unary function object to this result.
   * @param object The operand.
   * @return function1( function2( object ) )
   */
  public Object execute( Object object )
    {
    return myFunction1.execute( myFunction2.execute( object ) );
    }

  static final long serialVersionUID = 2442922436426194831L;
  }
