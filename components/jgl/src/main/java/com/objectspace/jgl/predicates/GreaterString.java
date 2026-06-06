// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * GreaterString is a binary predicate that
 * returns true if the first operand as a string
 * is greater than the second operand as a string.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class GreaterString implements BinaryPredicate
  {
  /**
   * Return true if the first operand is greater than the second operand.
   * @param first The first operand, which is converted into a String if necessary.
   * @param second The second operand, which is converted into a String if necessary.
   * @return first.toString() > second.toString()
   */
  public boolean execute( Object first, Object second )
    {
    return first.toString().compareTo( second.toString() ) > 0;
    }

  static final long serialVersionUID = -8683393645480843386L;
  }
