// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * EqualTo is a binary predicate that returns true if the first operand
 * is equal to the second operand using the standard Java equals() method.
 * <p>
 * @see com.objectspace.jgl.NotEqualTo
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class EqualTo implements BinaryPredicate
  {
  /**
   * Compare two objects for equality.
   * @param first The first operand.
   * @param second The second operand.
   * @return true if the operands are equal according to the standard Java equals() method.
   */
  public boolean execute( Object first, Object second )
    {
    return first.equals( second );
    }

  static final long serialVersionUID = -8584901860090939159L;
  }
