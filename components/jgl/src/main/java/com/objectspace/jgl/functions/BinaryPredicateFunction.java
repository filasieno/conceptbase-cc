// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.functions;

import com.objectspace.jgl.*;

/**
 * BinaryPredicateFunction allows you to use a binary predicate object as a binary
 * function object. Because a function object has to return an object, a true return value
 * is converted into Boolean.TRUE, and a false return value is converted into Boolean.FALSE.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class BinaryPredicateFunction implements BinaryFunction
  {
  BinaryPredicate myPredicate;

  /**
   * Construct myself with a binary predicate object.
   * @param predicate The binary predicate object.
   */
  public BinaryPredicateFunction( BinaryPredicate predicate )
    {
    myPredicate = predicate;
    }

  /**
   * Perform my binary predicate on the operand and return the boolean result as an object.
   * @param first The first operand.
   * @param second The second operand.
   * @return predicate( first, second ) converted into an object.
   */
  public Object execute( Object first, Object second )
    {
    return myPredicate.execute( first, second ) ? Boolean.TRUE : Boolean.FALSE;
    }

  static final long serialVersionUID = 899507603755754314L;
  }
