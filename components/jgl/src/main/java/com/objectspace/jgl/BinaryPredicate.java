// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.io.Serializable;

/**
 * BinaryPredicate is the interface that must be implemented by all binary predicate objects.
 * Every BinaryPredicate object must define a single method called execute() that takes
 * two objects as its arguments and returns a boolean. BinaryPredicate objects are often
 * built to operate on a specific kind of argument and must therefore cast the input
 * parameters in order to process them.
 * <p>
 * @see com.objectspace.jgl.BinaryFunction
 * @see com.objectspace.jgl.UnaryFunction
 * @see com.objectspace.jgl.UnaryPredicate
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public interface BinaryPredicate extends Serializable
  {
  /**
   * Return the result of executing with two Object arguments.
   * @param first The first object operand.
   * @param second The second object operand.
   * @return The boolean result of processing the input parameters.
   */
  boolean execute( Object first, Object second );

  static final long serialVersionUID = 7293485445871297181L;
  }
