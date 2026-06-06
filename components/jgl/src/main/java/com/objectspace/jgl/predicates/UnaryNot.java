// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * UnaryNot is a unary predicate that returns true if the result of executing
 * a unary predicate on its operands is false.
 * <p>
 * @see com.objectspace.jgl.predicates.BinaryNot
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class UnaryNot implements UnaryPredicate
  {
  UnaryPredicate myPredicate;

  /**
   * Construct myself with a single unary predicate object.
   * @param predicate The unary predicate object, which should be a predicate.
   */
  public UnaryNot( UnaryPredicate predicate )
    {
    myPredicate = predicate;
    }

  /**
   * Perform my unary predicate on the operand and return true if the predicate
   * returns false.
   * @param object The operand.
   * @return !predicate( object )
   */
  public boolean execute( Object object )
    {
    return !myPredicate.execute( object );
    }

  static final long serialVersionUID = 8432503484398104635L;
  }
