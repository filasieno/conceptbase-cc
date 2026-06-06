// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * BinaryComposePredicate is a binary predicate object that returns the result of executing
 * three operations in a specific sequence.
 * <p>
 * @see com.objectspace.jgl.functions.UnaryComposePredicate
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class BinaryComposePredicate implements BinaryPredicate
  {
  BinaryPredicate myPredicate;
  UnaryFunction myFunction1;
  UnaryFunction myFunction2;

  /**
   * Construct myself with a single binary predicate object and two unary function objects.
   * @param predicate The single binary predicate object.
   * @param function1 The first unary function object.
   * @param function2 The second unary function object.
   */
  public BinaryComposePredicate( BinaryPredicate predicate, UnaryFunction function1, UnaryFunction function2 )
    {
    myPredicate = predicate;
    myFunction1 = function1;
    myFunction2 = function2;
    }

  /**
   * Perform my unary functions on each operand and then return the result of applying
   * my binary predicate object to these results.
   * @param first The first operand.
   * @param second The second operand.
   * @return predicate( function1( first ), function2( second ) )
   */
  public boolean execute( Object first, Object second )
    {
    return myPredicate.execute( myFunction1.execute( first ), myFunction2.execute( second ) );
    }

  static final long serialVersionUID = -3630218671639562542L;
  }
