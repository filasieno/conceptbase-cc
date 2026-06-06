// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * HashComparator is a binary predicate that returns true if the hash code of its
 * first operand is less than the hash code of its second operand. It is used as the
 * default comparator by many algorithms and containers. It is especially useful for
 * sorting numbers, as the hash code of the Number subclasses are equal to their primitive
 * value.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class HashComparator implements BinaryPredicate
  {
  /**
   * Compare the operands based on their hash code.
   * @param first The first object.
   * @param second The second object.
   * @return true if the hash code of the first operand is less than the hash code of
   * the second operand using the standard Java hashCode() method.
   */
  public boolean execute( Object first, Object second )
    {
    return first.hashCode() < second.hashCode();
    }

  static final long serialVersionUID = -5935097699688512897L;
  }
