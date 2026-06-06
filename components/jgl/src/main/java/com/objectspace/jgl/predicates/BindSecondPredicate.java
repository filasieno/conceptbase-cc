// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * BindSecondPredicate is a unary predicate object that allows you to apply a binary
 * predicate to an operand and a predefined value. The reason that it's called
 * BindSecondPredicate is that the predefined value is always used as the 2nd parameter
 * to the binary predicate.
 * <p>
 * @see com.objectspace.jgl.functions.BindSecond
 * @see com.objectspace.jgl.functions.BindFirstPredicate
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class BindSecondPredicate implements UnaryPredicate
  {
  BinaryPredicate myPredicate;
  Object myObject;

  /**
   * Construct myself with a binary predicate object and a predefined value.
   * @param predicate The binary predicate object.
   * @param value The object to use as the 2nd parameter.
   */
  public BindSecondPredicate( BinaryPredicate predicate, Object value )
    {
    myPredicate = predicate;
    myObject = value;
    }

  /**
   * Perform my binary predicate on the operand using the operand as the 1st parameter
   * and the predefined value as the 2nd parameter.
   * @param object The operand.
   * @return predicate( value, object )
   */
  public boolean execute( Object object )
    {
    return myPredicate.execute( object, myObject );
    }

  static final long serialVersionUID = -1538124954848081069L;
  }
