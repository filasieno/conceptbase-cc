// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.functions;

import com.objectspace.jgl.*;

/**
 * NegateNumber is a binary function that assumes its operand is an
 * instance of Number and returns its negation.
 * <p>
 * @see java.lang.Number
 * @see java.math.BigInteger
 * @see java.math.BigDecimal
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class NegateNumber implements UnaryFunction
  {
  private Class mode;
  private static Integer zero = new Integer( 0 );

  /**
   * Construct myself to use intValue() for operation.
   */
  public NegateNumber()
    {
    mode = Integer.class;
    }

  /**
   * Construct myself to operate on objects of the given class.  The class must
   * be derived from java.lang.Number.
   * @param discriminator The class of objects on which I will be operating.
   * @exception java.lang.IllegalArgumentException Throw if discriminator is not an instance of java.lang.Number.
   */
  public NegateNumber( Class discriminator )
    {
    if ( !Number.class.isAssignableFrom( discriminator ) )
      throw new IllegalArgumentException( "discriminator must be an instance of java.lang.Number" );
    mode = discriminator;
    }

  /**
   * Return the negation of my operand.
   * Be aware that some floating point conversions are not exact, and may
   * cause unexpected results due to rounding.
   * @param object The operand, which must be an instance of Number.
   * @exception com.objectspace.jgl.InvalidOperationException Throw if I don't know how to interpret the values.
   * @return -object
   */
  public Object execute( Object object )
    {
    return NumberHelper.minus( zero, (Number)object, mode );
    }

  static final long serialVersionUID = -6940014532687872929L;
  }
