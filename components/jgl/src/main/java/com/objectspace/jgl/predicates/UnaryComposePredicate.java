// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * UnaryCompose is a unary predicate object that returns the result of executing
 * two operations in a specific sequence.
 * <p>
 * @see com.objectspace.jgl.functions.UnaryComposePredicate
 * @see com.objectspace.jgl.functions.BinaryCompose
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class UnaryComposePredicate implements UnaryPredicate
  {
  UnaryPredicate myPredicate;
  UnaryFunction myFunction;

  /**
   * Construct myself with a unary predicate object and a unary function object.
   * @param predicate The predicate object.
   * @param function The function object.
   */
  public UnaryComposePredicate( UnaryPredicate predicate, UnaryFunction function )
    {
    myPredicate = predicate;
    myFunction = function;
    }

  /**
   * Perform my unary function on the operand and then return the result of
   * applying my predicate function object to this result.
   * @param object The operand.
   * @return predicate( function( object ) )
   */
  public boolean execute( Object object )
    {
    return myPredicate.execute( myFunction.execute( object ) );
    }

  static final long serialVersionUID = -4197779030913346394L;
  }
