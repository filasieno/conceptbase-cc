// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;

/**
 * PositiveNumber is a unary predicate that assumes that its operand is an
 * instance of Number and returns true if it is positive.
 * >p>
 * @see java.lang.Number
 * @see java.math.BigInteger
 * @see java.math.BigDecimal
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class PositiveNumber implements UnaryPredicate
  {
  private Class mode;
  private static Integer zero = new Integer( 0 );

  /**
   * Construct myself to use intValue() for comparisons.
   */
  public PositiveNumber()
    {
    mode = zero.getClass();
    }

  /**
   * Construct myself to compare objects of the given class.  The class must
   * be derived from java.lang.Number.
   * @param discriminator The class of objects that I will be comparing.
   * @exception java.lang.IllegalArgumentException Throw if discriminator is not an instance of java.lang.Number.
   */
  public PositiveNumber( Class discriminator )
    {
    if ( !Number.class.isAssignableFrom( discriminator ) )
      throw new IllegalArgumentException( "discriminator must be an instance of java.lang.Number" );
    mode = discriminator;
    }

  /**
   * Return true if the operand is greater than zero.
   * Be aware that some floating point conversions are not exact, and may
   * cause unexpected results due to rounding.
   * @param object The operand, which must be a Number.
   * @exception com.objectspace.jgl.InvalidOperationException Throw if I don't know how to interpret the values.
   * @return object > 0
   */
  public boolean execute( Object object )
    {
    return NumberHelper.compare( (Number)object, zero, mode ) > 0;
    }

  static final long serialVersionUID = -161496166235724217L;
  }
