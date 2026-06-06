// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;
import java.io.Serializable;

/**
 * ConstantPredicate is a predicate object that will always return the same
 * value regardless of the parameters it is passed.
 * <p>
 * @see com.objectspace.jgl.UnaryPredicate
 * @see com.objectspace.jgl.BinaryPredicate
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class ConstantPredicate implements UnaryPredicate, BinaryPredicate
  {
  public static ConstantPredicate TRUE = new ConstantPredicate( true );
  public static ConstantPredicate FALSE = new ConstantPredicate( false );

  boolean returnValue;
  
  /**
   * Construct myself to always return a specific value when invoked.
   * @param value The value to return.
   */
  public ConstantPredicate( boolean value )
    {
    returnValue = value;
    }

  /**
   * Return my value.
   * @param object Ignored.
   * @return The value with which I was constructed.
   */
  public boolean execute( Object object )
    {
    return returnValue;
    }

  /**
   * Return my value.
   * @param first Ignored.
   * @param second Ignored.
   * @return The value with which I was constructed.
   */
  public boolean execute( Object first, Object second )
    {
    return returnValue;
    }

  static final long serialVersionUID = -4504560734661298681L;
  }
