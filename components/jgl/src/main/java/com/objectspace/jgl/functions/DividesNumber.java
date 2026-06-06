// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.functions;

import com.objectspace.jgl.*;
import java.math.BigDecimal;

/**
 * DividesNumber is a binary function that assumes that both of its operands are
 * instances of Number and returns the first operand divided by the second operand.
 * <p>
 * @see java.lang.Number
 * @see java.math.BigInteger
 * @see java.math.BigDecimal
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class DividesNumber implements BinaryFunction
  {
  private Class mode;
  private int rounding;

  /**
   * Construct myself to use intValue() for operation.
   */
  public DividesNumber()
    {
    mode = Integer.class;
    rounding = java.math.BigDecimal.ROUND_DOWN;
    }

  /**
   * Construct myself to operate on objects of the given class.  The class must
   * be derived from java.lang.Number.  If the discriminating class is
   * java.math.BigDecimal, use ROUND_DOWN as the rounding mode.
   * @param discriminator The class of objects on which I will be operating.
   * @exception java.lang.IllegalArgumentException Throw if discriminator is not an instance of java.lang.Number.
   * @see java.math.BigDecimal
   */
  public DividesNumber( Class discriminator )
    {
    if ( !Number.class.isAssignableFrom( discriminator ) )
      throw new IllegalArgumentException( "discriminator must be an instance of java.lang.Number" );
    mode = discriminator;
    rounding = java.math.BigDecimal.ROUND_DOWN;
    }

  /**
   * Construct myself to operate on objects of the given class.  The class must
   * be derived from java.lang.Number.  If the class is an instance of
   * java.math.BigDecimal, use the given rounding mode.
   * @param discriminator The class of objects on which I will be operating.
   * @param rounding The specified rounding mode. Only used when the discriminator is a java.math.BigDecimal.
   * @exception java.lang.IllegalArgumentException Throw if discriminator is not an instance of java.lang.Number.
   * @see java.math.BigDecimal#divide
   */
  public DividesNumber( Class discriminator, int rounding )
    {
    if ( !Number.class.isAssignableFrom( discriminator ) )
      throw new IllegalArgumentException( "discriminator must be an instance of java.lang.Number" );
    mode = discriminator;
    this.rounding = rounding;
    }

  /**
   * Return the result of dividing the first operand by the second operand.
   * Be aware that some floating point conversions are not exact, and may
   * cause unexpected results due to rounding.
   * @param first The first operand, which must be an instance of Number.
   * @param second The second operand, which must be an instance of Number.
   * @exception com.objectspace.jgl.InvalidOperationException Throw if I don't know how to interpret the values.
   * @return first / second
   */
  public Object execute( Object first, Object second )
    {
    return NumberHelper.divides( (Number)first, (Number)second, mode, rounding );
    }

  static final long serialVersionUID = -8721191830483136810L;
  }
