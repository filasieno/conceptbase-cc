// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;
import java.lang.Class;

/**
 * InstanceOf is a unary predicate that performs the same function as the
 * instanceof keyword.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class InstanceOf implements UnaryPredicate
  {
  private Class c;

  /**
   * Construct myself to perform the equivalent of the instanceof operator for the given class.
   */
  public InstanceOf( Class c )
    {
    this.c= c;
    }

  /**
   * Test operand for belonging to a specific class.
   * @param object The operand
   * @return true if the specified Object argument is non-null and can be
   * successfully cast to the type passed in my constructor.
   * @see java.lang.Class#isInstance
   */
  public boolean execute( Object object )
    {
    return c.isInstance( object );
    }
  
  static final long serialVersionUID = 3357430766224482427L;
  }
