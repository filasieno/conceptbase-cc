// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.functions;

import com.objectspace.jgl.*;

/**
 * LengthString is a unary function that returns the length of
 * its operand as a string.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class LengthString implements UnaryFunction
  {
  /**
   * Return the length of my operand's string as an Integer.
   * @param object The operand
   * @return The length of the operand.toString().
   */
  public Object execute( Object object )
    {
    return new Integer( object.toString().length() );
    }

  static final long serialVersionUID = -5115559626972883587L;
  }
