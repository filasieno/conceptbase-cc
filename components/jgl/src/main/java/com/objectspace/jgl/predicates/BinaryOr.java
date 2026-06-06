// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * BinaryOr is a unary predicate that returns true if the result of executing
 * any unary predicate on its operands is true.
 * <p>
 * @see com.objectspace.jgl.UnaryOr
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class BinaryOr implements BinaryPredicate
  {
  BinaryPredicate[] myPreds;

  /**
   * Construct myself with two unary predicate objects.
   * @param p1 A unary predicate object, which should be a predicate.
   * @param p2 A unary predicate object, which should be a predicate.
   */
  public BinaryOr( BinaryPredicate p1, BinaryPredicate p2 )
    {
    this( new BinaryPredicate[]{ p1, p2 } );
    }

  /**
   * Construct myself to use all given predicates for testing.
   * @param p An array or BinaryPredicates.
   */
  public BinaryOr( BinaryPredicate[] p )
    {
    myPreds = p;
    }

  /**
   * Perform my unary predicates on the operand and return true if 
   * any predicate returns true.
   * @param first The first operand.
   * @param second The second operand.
   */
  public boolean execute( Object first, Object second )
    {
    for ( int i = 0; i < myPreds.length; ++i )
      if ( myPreds[ i ].execute( first, second ) )
        return true;
    return false;
    }

  static final long serialVersionUID = 6050906156639016732L;
  }
