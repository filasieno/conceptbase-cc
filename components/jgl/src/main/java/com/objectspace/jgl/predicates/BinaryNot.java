// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * BinaryNot is a binary predicate that returns true if the result of executing
 * a binary predicate on its operands is false.
 * <p>
 * @see com.objectspace.jgl.UnaryNot
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class BinaryNot implements BinaryPredicate
  {
  BinaryPredicate myPredicate;

  /**
   * Construct myself with a single binary predicate object.
   * @param predicate The binary predicate object.
   */
  public BinaryNot( BinaryPredicate predicate )
    {
    myPredicate = predicate;
    }

  /**
   * Perform my binary predicate on the operands and return true if the predicate
   * returns false.
   * @param first The first operand.
   * @param second The second operand.
   * @return !function( first, second )
   */
  public boolean execute( Object first, Object second )
    {
    return !myPredicate.execute( first, second );
    }

  static final long serialVersionUID = -6075581711734872145L;
  }
