// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.functions;

import com.objectspace.jgl.*;

/**
 * UnaryPredicateFunction allows you to use a unary predicate object as a unary
 * function object. Because a function object has to return an object, a true return value
 * is converted into Boolean.TRUE, and a false return value is converted into Boolean.FALSE.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class UnaryPredicateFunction implements UnaryFunction
  {
  UnaryPredicate myPredicate;

  /**
   * Construct myself with a unary predicate object.
   * @param predicate The unary predicate object.
   */
  public UnaryPredicateFunction( UnaryPredicate predicate )
    {
    myPredicate = predicate;
    }

  /**
   * Perform my unary predicate on the operand and return the boolean result as an object.
   * @param object The operand.
   * @return predicate( object ) converted into an object.
   */
  public Object execute( Object object )
    {
    return myPredicate.execute( object ) ? Boolean.TRUE : Boolean.FALSE;
    }

  static final long serialVersionUID = 6203177376725857447L;
  }
