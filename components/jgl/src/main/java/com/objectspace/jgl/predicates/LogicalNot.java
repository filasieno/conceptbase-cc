// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * LogicalNot is a unary predicate that returns true if its operand is equal to false.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class LogicalNot implements UnaryPredicate
  {
  /**
   * Perform a logical NOT.
   * @param object The operand, which must be an instance of Boolean.
   * @return true if the operand is equal to Boolean.FALSE.
   */
  public boolean execute( Object object )
    {
    return !( (Boolean)object ).booleanValue();
    }

  static final long serialVersionUID = 5011663867079005719L;
  }
