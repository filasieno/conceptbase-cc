// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * UnaryOr is a unary predicate that returns true if the result of executing
 * any unary predicate on its operands is true.
 * <p>
 * @see com.objectspace.jgl.predicates.BinaryOr
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class UnaryOr implements UnaryPredicate
  {
  UnaryPredicate[] myPreds;

  /**
   * Construct myself with two unary predicate objects.
   * @param p1 A unary predicate object, which should be a predicate.
   * @param p2 A unary predicate object, which should be a predicate.
   */
  public UnaryOr( UnaryPredicate p1, UnaryPredicate p2 )
    {
    this( new UnaryPredicate[]{ p1, p2 } );
    }

  /**
   * Construct myself to use all given predicates for testing.
   * @param p An array or UnaryPredicates.
   */
  public UnaryOr( UnaryPredicate[] p )
    {
    myPreds = p;
    }

  /**
   * Perform my unary predicates on the operand and return true if 
   * any predicate returns true.
   * @param object The operand.
   */
  public boolean execute( Object object )
    {
    for ( int i = 0; i < myPreds.length; ++i )
      if ( myPreds[ i ].execute( object ) )
        return true;
    return false;
    }

  static final long serialVersionUID = -861534142287187168L;
  }
