// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * BinaryAnd is a unary predicate that returns true if the result of executing
 * all unary predicates on given operands is true.
 * <p>
 * @see com.objectspace.jgl.UnaryAnd
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class BinaryAnd implements BinaryPredicate
  {
  BinaryPredicate[] myPreds;

  /**
   * Construct myself with two unary predicate objects.
   * @param p1 A unary predicate object, which should be a predicate.
   * @param p2 A unary predicate object, which should be a predicate.
   */
  public BinaryAnd( BinaryPredicate p1, BinaryPredicate p2 )
    {
    this( new BinaryPredicate[]{ p1, p2 } );
    }

  /**
   * Construct myself to use all given predicates for testing.
   * @param p An array or BinaryPredicates.
   */
  public BinaryAnd( BinaryPredicate[] p )
    {
    myPreds = p;
    }

  /**
   * Perform my unary predicates on the operand and return true if 
   * all predicates return true.
   * @param first The operand.
   * @param second The operand.
   */
  public boolean execute( Object first, Object second )
    {
    for ( int i = 0; i < myPreds.length; ++i )
      if ( !myPreds[ i ].execute( first, second ) )
        return false;
    return true;
    }

  static final long serialVersionUID = -2539776898467830505L;
  }
