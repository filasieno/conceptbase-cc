// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * IdenticalTo is a binary predicate that returns true if the first operand
 * is exactly the same as the second operand using the standard Java == operator.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class IdenticalTo implements BinaryPredicate
  {
  /**
   * Compare two objects for identity.
   * @param first The first operand.
   * @param second The second operand.
   * @return true if the operands are the same object according to ==.
   */
  public boolean execute( Object first, Object second )
    {
    return first == second;
    }
  
  static final long serialVersionUID = -8163967741143021258L;
  }
