// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * LessString is a binary predicate that returns true
 * if the first operand as a string is less than the second operand
 * as a string.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class LessString implements BinaryPredicate
  {
  /**
   * Return true if the first operand is less than the second operand.
   * @return first.toString() < second.toString()
   */
  public boolean execute( Object first, Object second )
    {
    return first.toString().compareTo( second.toString() ) < 0;
    }

  static final long serialVersionUID = -5398274395395704408L;
  }
