// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.functions;

import com.objectspace.jgl.*;

/**
 * PlusNumber is a binary function that assumes that both of its operands are
 * instances of Number and returns the first operand added to the second operand.
 * <p>
 * @see java.lang.Number
 * @see java.math.BigInteger
 * @see java.math.BigDecimal
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class PlusNumber implements BinaryFunction
  {
  private Class mode;

  /**
   * Construct myself to use intValue() for operation.
   */
  public PlusNumber()
    {
    mode = Integer.class;
    }

  /**
   * Construct myself to operate on objects of the given class.  The class must
   * be derived from java.lang.Number.
   * @param discriminator The class of objects on which I will be operating.
   * @exception java.lang.IllegalArgumentException Throw if discriminator is not an instance of java.lang.Number.
   */
  public PlusNumber( Class discriminator )
    {
    if ( !Number.class.isAssignableFrom( discriminator ) )
      throw new IllegalArgumentException( "discriminator must be an instance of java.lang.Number" );
    mode = discriminator;
    }

  /**
   * Return the result of adding the first operand to the second operand.
   * Be aware that some floating point conversions are not exact, and may
   * cause unexpected results due to rounding.
   * @param first The first operand, which must be an instance of Number.
   * @param second The second operand, which must be an instance of Number.
   * @exception com.objectspace.jgl.InvalidOperationException Throw if I don't know how to interpret the values.
   * @return first + second
   */
  public Object execute( Object first, Object second )
    {
    return NumberHelper.plus( (Number)first, (Number)second, mode );
    }

  static final long serialVersionUID = -213012619131620299L;
  }
