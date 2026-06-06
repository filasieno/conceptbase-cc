// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * NotEqualTo is a binary predicate that returns false if the first operand
 * is equal to the second operand using the standard Java equals() method.
 * <p>
 * @see com.objectspace.jgl.predicates.EqualTo
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class NotEqualTo implements BinaryPredicate
  {
  /**
   * Compare two objects for inequality.
   * @param first The first operand.
   * @param second The second operand.
   * @return false if the operands are equal according to the standard Java equals() method.
   */
  public boolean execute( Object first, Object second )
    {
    return !first.equals( second );
    }

  static final long serialVersionUID = 23142966957285542L;
  }
