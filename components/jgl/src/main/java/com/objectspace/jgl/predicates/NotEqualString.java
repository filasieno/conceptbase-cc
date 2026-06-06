// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * NotEqualString is a binary predicate that returns true
 * if the first operand as a string is not equal to the second operand
 * as a string.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class NotEqualString implements BinaryPredicate
  {
  /**
   * Return true if the first operand is not equal to the second operand.
   * @return first.toString() != second.toString()
   */
  public boolean execute( Object first, Object second )
    {
    return !first.toString().equals( second.toString() );
    }

  static final long serialVersionUID = -4970749365967375045L;
  }
