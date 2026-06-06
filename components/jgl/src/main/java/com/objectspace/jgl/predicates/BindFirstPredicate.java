// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * BindFirstPredicate is a unary predicate object that allows you to apply a binary
 * predicate to a predefined value and an operand. The reason that it's called
 * BindFirstPredicate is that the predefined value is always used as the 1st parameter
 * to the binary predicate.
 * <p>
 * @see com.objectspace.jgl.functions.BindFirst
 * @see com.objectspace.jgl.functions.BindSecondPredicate
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class BindFirstPredicate implements UnaryPredicate
  {
  BinaryPredicate myPredicate;
  Object myObject;

  /**
   * Construct myself with a binary predicate object and a predefined value.
   * @param predicate The binary predicate object.
   * @param value The object to use as the 1st parameter.
   */
  public BindFirstPredicate( BinaryPredicate predicate, Object value )
    {
    myPredicate = predicate;
    myObject = value;
    }

  /**
   * Perform my binary predicate on the operand using the predefined value as the 1st
   * parameter and the operand as the 2nd parameter.
   * @param object The operand.
   * @return predicate( value, object )
   */
  public boolean execute( Object object )
    {
    return myPredicate.execute( myObject, object );
    }

  static final long serialVersionUID = 5921340373189462095L;
  }
