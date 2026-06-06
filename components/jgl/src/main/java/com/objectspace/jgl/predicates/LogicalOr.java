// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * LogicalOr is a binary predicate that returns true if either operand is equal to
 * Boolean.TRUE.
 * <p>
 * @see com.objectspace.jgl.LogicalAnd
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class LogicalOr implements BinaryPredicate
  {
  /**
   * Perform a logical OR.
   * @param first The first operand, which must be an instance of Boolean.
   * @param second The second operand, which must be an instance of Boolean.
   * @return true if either operand is equal to Boolean.TRUE.
   */
  public boolean execute( Object first, Object second )
    {
    return ((Boolean) first).booleanValue() || ((Boolean) second).booleanValue();
    }

  static final long serialVersionUID = -2400350545997220552L;
  }
