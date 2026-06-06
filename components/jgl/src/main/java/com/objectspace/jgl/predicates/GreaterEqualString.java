// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * GreaterEqualString is a binary predicate that
 * returns true if the first operand as a string is greater
 * than or equal to the second operand as a string.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class GreaterEqualString implements BinaryPredicate
  {
  /**
   * Return true if the first operand is greater than or equal to the second operand.
   * @return first.toString() >= second.toString()
   */
  public boolean execute( Object first, Object second )
    {
    return first.toString().compareTo( second.toString() ) >= 0;
    }

  static final long serialVersionUID = -939391485433126263L;
  }
