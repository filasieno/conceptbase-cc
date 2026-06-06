// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * UnaryAnd is a unary predicate that returns true if the result of executing
 * all unary predicates on given operands is true.
 * <p>
 * @see com.objectspace.jgl.predicates.BinaryAnd
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class UnaryAnd implements UnaryPredicate
  {
  UnaryPredicate[] myPreds;

  /**
   * Construct myself with two unary predicate objects.
   * @param p1 A unary predicate object, which should be a predicate.
   * @param p2 A unary predicate object, which should be a predicate.
   */
  public UnaryAnd( UnaryPredicate p1, UnaryPredicate p2 )
    {
    this( new UnaryPredicate[]{ p1, p2 } );
    }

  /**
   * Construct myself to use all given predicates for testing.
   * @param p An array or UnaryPredicates.
   */
  public UnaryAnd( UnaryPredicate[] p )
    {
    myPreds = p;
    }

  /**
   * Perform my unary predicates on the operand and return true if 
   * all predicates return true.
   * @param object The operand.
   */
  public boolean execute( Object object )
    {
    for ( int i = 0; i < myPreds.length; ++i )
      if ( !myPreds[ i ].execute( object ) )
        return false;
    return true;
    }

  static final long serialVersionUID = 7907475048757210293L;
  }
