// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;
import java.math.BigInteger;
import java.math.BigDecimal;

final class NumberHelper
  {
  private NumberHelper()
    {
    }

  static BigDecimal asBigDecimal( Number n )
    {
    return n instanceof BigDecimal
      ? (BigDecimal)n
      : new BigDecimal( n.toString() );
    }

  static BigInteger asBigInteger( Number n )
    {
    // if not already a BigInteger, first convert to a BigDecimal
    // to avoid checking floating point types
    return n instanceof BigInteger
      ? (BigInteger)n
      : asBigDecimal( n ).toBigInteger();
    }

  static int compare( Number n1, Number n2, Class mode )
    {
    // normal subclasses
    if ( mode.equals( Integer.class ) )
      return n1.intValue() < n2.intValue()
        ? -1
        : n1.intValue() > n2.intValue()
          ? 1
          : 0;
    if ( mode.equals( Long.class ) )
      return n1.longValue() < n2.longValue()
        ? -1
        : n1.longValue() > n2.longValue()
          ? 1
          : 0;
    if ( mode.equals( Float.class ) )
      return n1.floatValue() < n2.floatValue()
        ? -1
        : n1.floatValue() > n2.floatValue()
          ? 1
          : 0;
    if ( mode.equals( Double.class ) )
      return n1.doubleValue() < n2.doubleValue()
        ? -1
        : n1.doubleValue() > n2.doubleValue()
          ? 1
          : 0;
    if ( mode.equals( Byte.class ) )
      return n1.byteValue() < n2.byteValue()
        ? -1
        : n1.byteValue() > n2.byteValue()
          ? 1
          : 0;
    if ( mode.equals( Short.class ) )
      return n1.shortValue() < n2.shortValue()
        ? -1
        : n1.shortValue() > n2.shortValue()
          ? 1
          : 0;

    // compare as BigIntegers
    if ( mode.equals( BigInteger.class ) )
      return asBigInteger( n1 ).compareTo( asBigInteger( n2 ) );

    // compare as BigDecimals
    if ( mode.equals( BigDecimal.class ) )
      return asBigDecimal( n1 ).compareTo( asBigDecimal( n2 ) );

    // don't know how to deal with mode
    throw new IllegalArgumentException
      (
      "unknown subclass of java.lang.Number: " + mode.getClass()
      );
    }
  }
