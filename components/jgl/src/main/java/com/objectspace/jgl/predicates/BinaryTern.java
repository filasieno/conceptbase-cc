// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * BinaryTern is a unary predicate that represents the ternary operator (?:)
 * in JGL.
 * <p>
 * @see com.objectspace.jgl.UnaryTern
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class BinaryTern implements BinaryPredicate
  {
  BinaryPredicate ifPredicate;
  BinaryPredicate thenPredicate;
  BinaryPredicate elsePredicate;

  /**
   * Construct myself to emulate the ternary operator.  All parameters should
   * be BinaryPredicates.
   * @param ifPred The condition.
   * @param thenPred Evaluated if <CODE>ifPred</CODE> returns true.
   * @param elsePred Evaluated if <CODE>ifPred</CODE> returns false.
   */
  public BinaryTern( BinaryPredicate ifPred, BinaryPredicate thenPred, BinaryPredicate elsePred )
    {
    ifPredicate = ifPred;
    thenPredicate = thenPred;
    elsePredicate = elsePred;
    }

  /**
   * Perform my conditional predicate on the operand, and use the return
   * value of that to determine which predicate to evaluate.
   * @param first The operand.
   * @param second The operand.
   * @return ifPred( object ) ? thenPred( object ) : elsePred( object )
   */
  public boolean execute( Object first, Object second )
    {
    return ifPredicate.execute( first, second )
      ? thenPredicate.execute( first, second )
      : elsePredicate.execute( first, second );
    }

  static final long serialVersionUID = 7612655449099156576L;
  }
