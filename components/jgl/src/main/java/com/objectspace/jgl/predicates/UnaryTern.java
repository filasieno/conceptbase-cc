// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * UnaryTern is a unary predicate that represents the ternary operator (?:)
 * in JGL.
 * <p>
 * @see com.objectspace.jgl.predicates.BinaryTern
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class UnaryTern implements UnaryPredicate
  {
  UnaryPredicate ifPredicate;
  UnaryPredicate thenPredicate;
  UnaryPredicate elsePredicate;

  /**
   * Construct myself to emulate the ternary operator.  All parameters should
   * be UnaryPredicates.
   * @param ifPred The condition.
   * @param thenPred Evaluated if <CODE>ifPred</CODE> returns true.
   * @param elsePred Evaluated if <CODE>ifPred</CODE> returns false.
   */
  public UnaryTern( UnaryPredicate ifPred, UnaryPredicate thenPred, UnaryPredicate elsePred )
    {
    ifPredicate = ifPred;
    thenPredicate = thenPred;
    elsePredicate = elsePred;
    }

  /**
   * Perform my conditional predicate on the operand, and use the return
   * value of that to determine which predicate to evaluate.
   * @param object The operand.
   * @return ifPred( object ) ? thenPred( object ) : elsePred( object )
   */
  public boolean execute( Object object )
    {
    return ifPredicate.execute( object )
      ? thenPredicate.execute( object )
      : elsePredicate.execute( object );
    }

  static final long serialVersionUID = 8571343789204866000L;
  }
