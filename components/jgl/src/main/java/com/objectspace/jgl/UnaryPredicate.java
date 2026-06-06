// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.io.Serializable;

/**
 * UnaryPredicate is the interface that must be implemented by all unary predicate objects.
 * Every UnaryPredicate object must define a single method called execute() that takes
 * a single object as its argument and returns a boolean. UnaryPredicate objects are often
 * built to operate on a specific kind of object and must therefore cast the input parameter
 * in order to process it.
 * <p>
 * @see com.objectspace.jgl.UnaryFunction
 * @see com.objectspace.jgl.BinaryFunction
 * @see com.objectspace.jgl.BinaryPredicate
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public interface UnaryPredicate extends Serializable
  {
  /**
   * Return the result of executing with a single Object.
   * @param object The object to process.
   * @return The result of processing the input Object.
   */
  boolean execute( Object object );

  static final long serialVersionUID = -7338805652755311253L;
  }
