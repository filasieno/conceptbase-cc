// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * NotIdenticalTo is a binary predicate that returns true if the first operand
 * is not the same object second operand using the standard Java != operator.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class NotIdenticalTo implements BinaryPredicate
  {
  /**
   * Compare two objects for non-identity.
   * @param first The first operand.
   * @param second The second operand.
   * @return true if the operands are not the same object according to the !=.
   */
  public boolean execute( Object first, Object second )
    {
    return first != second;
    }

  static final long serialVersionUID = 6380655686377442300L;
  }
