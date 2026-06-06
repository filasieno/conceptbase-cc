// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * SwappedBinaryPredicate is a binary predicate that returns the result of
 * applying its operands to a BinaryPredicate in the opposite order they
 * were received.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class SwappedBinaryPredicate implements BinaryPredicate
  {
  BinaryPredicate predicate;

  /**
   * Construct myself with a binary predicate object.
   * @param predicate The binary predicate object.
   */
  public SwappedBinaryPredicate( BinaryPredicate predicate )
    {
    this.predicate = predicate;
    }

  /**
   * Swap the order of operands and return the value of my contained predicate.
   * @param first The first operand.
   * @param second The second operand.
   * @return predicate.execute( second, first )
   */
  public boolean execute( Object first, Object second )
    {
    return predicate.execute( second, first );
    }

  static final long serialVersionUID = 3114476566955140562L;
  }
