// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.functions;

import com.objectspace.jgl.*;

/**
 * BinaryCompose is a binary function object that returns the result of executing
 * three operations in a specific sequence.
 * <p>
 * @see com.objectspace.jgl.functions.UnaryCompose
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class BinaryCompose implements BinaryFunction
  {
  BinaryFunction myFunction1;
  UnaryFunction myFunction2;
  UnaryFunction myFunction3;

  /**
   * Construct myself with a single binary function object and two unary function objects.
   * @param function1 The single binary function object.
   * @param function2 The first unary function object.
   * @param function3 The second unary function object.
   */
  public BinaryCompose( BinaryFunction function1, UnaryFunction function2, UnaryFunction function3 )
    {
    myFunction1 = function1;
    myFunction2 = function2;
    myFunction3 = function3;
    }

  /**
   * Perform my unary functions on each operand and then return the result of applying
   * my binary function object to these results.
   * @param first The first operand.
   * @param second The second operand.
   * @return function1( function2( first ), function3( second ) )
   */
  public Object execute( Object first, Object second )
    {
    return myFunction1.execute( myFunction2.execute( first ), myFunction3.execute( second ) );
    }

  static final long serialVersionUID = -5783675586648912146L;
  }
