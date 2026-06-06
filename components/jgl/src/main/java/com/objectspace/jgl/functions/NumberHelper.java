// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.functions;

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

  static Number plus( Number n1, Number n2, Class mode )
    {
    // normal subclasses
    if ( mode.equals( Integer.class ) )
      return new Integer( n1.intValue() + n2.intValue() );
    if ( mode.equals( Long.class ) )
      return new Long(  n1.longValue() + n2.longValue() );
    if ( mode.equals( Float.class ) )
      return new Float(  n1.floatValue() + n2.floatValue() );
    if ( mode.equals( Double.class ) )
      return new Double(  n1.doubleValue() + n2.doubleValue() );
    if ( mode.equals( Byte.class ) )
      return new Byte(  (byte)( n1.byteValue() + n2.byteValue() ) );
    if ( mode.equals( Short.class ) )
      return new Short(  (short)( n1.shortValue() + n2.shortValue() ) );

    // compare as BigIntegers
    if ( mode.equals( BigInteger.class ) )
      return asBigInteger( n1 ).add( asBigInteger( n2 ) );

    // compare as BigDecimals
    if ( mode.equals( BigDecimal.class ) )
      return asBigDecimal( n1 ).add( asBigDecimal( n2 ) );

    // don't know how to deal with mode
    throw new IllegalArgumentException
      (
      "unknown subclass of java.lang.Number: " + mode.getClass()
      );
    }

  static Number minus( Number n1, Number n2, Class mode )
    {
    // normal subclasses
    if ( mode.equals( Integer.class ) )
      return new Integer( n1.intValue() - n2.intValue() );
    if ( mode.equals( Long.class ) )
      return new Long(  n1.longValue() - n2.longValue() );
    if ( mode.equals( Float.class ) )
      return new Float(  n1.floatValue() - n2.floatValue() );
    if ( mode.equals( Double.class ) )
      return new Double(  n1.doubleValue() - n2.doubleValue() );
    if ( mode.equals( Byte.class ) )
      return new Byte(  (byte)( n1.byteValue() - n2.byteValue() ) );
    if ( mode.equals( Short.class ) )
      return new Short(  (short)( n1.shortValue() - n2.shortValue() ) );

    // compare as BigIntegers
    if ( mode.equals( BigInteger.class ) )
      return asBigInteger( n1 ).subtract( asBigInteger( n2 ) );

    // compare as BigDecimals
    if ( mode.equals( BigDecimal.class ) )
      return asBigDecimal( n1 ).subtract( asBigDecimal( n2 ) );

    // don't know how to deal with mode
    throw new IllegalArgumentException
      (
      "unknown subclass of java.lang.Number: " + mode.getClass()
      );
    }

  static Number multiply( Number n1, Number n2, Class mode )
    {
    // normal subclasses
    if ( mode.equals( Integer.class ) )
      return new Integer( n1.intValue() * n2.intValue() );
    if ( mode.equals( Long.class ) )
      return new Long(  n1.longValue() * n2.longValue() );
    if ( mode.equals( Float.class ) )
      return new Float(  n1.floatValue() * n2.floatValue() );
    if ( mode.equals( Double.class ) )
      return new Double(  n1.doubleValue() * n2.doubleValue() );
    if ( mode.equals( Byte.class ) )
      return new Byte(  (byte)( n1.byteValue() * n2.byteValue() ) );
    if ( mode.equals( Short.class ) )
      return new Short(  (short)( n1.shortValue() * n2.shortValue() ) );

    // compare as BigIntegers
    if ( mode.equals( BigInteger.class ) )
      return asBigInteger( n1 ).multiply( asBigInteger( n2 ) );

    // compare as BigDecimals
    if ( mode.equals( BigDecimal.class ) )
      return asBigDecimal( n1 ).multiply( asBigDecimal( n2 ) );

    // don't know how to deal with mode
    throw new IllegalArgumentException
      (
      "unknown subclass of java.lang.Number: " + mode.getClass()
      );
    }

  static Number divides( Number n1, Number n2, Class mode, int round_mode )
    {
    // normal subclasses
    if ( mode.equals( Integer.class ) )
      return new Integer( n1.intValue() / n2.intValue() );
    if ( mode.equals( Long.class ) )
      return new Long(  n1.longValue() / n2.longValue() );
    if ( mode.equals( Float.class ) )
      return new Float(  n1.floatValue() / n2.floatValue() );
    if ( mode.equals( Double.class ) )
      return new Double(  n1.doubleValue() / n2.doubleValue() );
    if ( mode.equals( Byte.class ) )
      return new Byte(  (byte)( n1.byteValue() / n2.byteValue() ) );
    if ( mode.equals( Short.class ) )
      return new Short(  (short)( n1.shortValue() / n2.shortValue() ) );

    // compare as BigIntegers
    if ( mode.equals( BigInteger.class ) )
      return asBigInteger( n1 ).divide( asBigInteger( n2 ) );

    // compare as BigDecimals
    if ( mode.equals( BigDecimal.class ) )
      return asBigDecimal( n1 ).divide( asBigDecimal( n2 ), round_mode );

    // don't know how to deal with mode
    throw new IllegalArgumentException
      (
      "unknown subclass of java.lang.Number: " + mode.getClass()
      );
    }

  static Number modulus( Number n1, Number n2, Class mode, int round_mode )
    {
    // normal subclasses
    if ( mode.equals( Integer.class ) )
      return new Integer( n1.intValue() % n2.intValue() );
    if ( mode.equals( Long.class ) )
      return new Long(  n1.longValue() % n2.longValue() );
    if ( mode.equals( Float.class ) )
      return new Float(  n1.floatValue() % n2.floatValue() );
    if ( mode.equals( Double.class ) )
      return new Double(  n1.doubleValue() % n2.doubleValue() );
    if ( mode.equals( Byte.class ) )
      return new Byte(  (byte)( n1.byteValue() % n2.byteValue() ) );
    if ( mode.equals( Short.class ) )
      return new Short(  (short)( n1.shortValue() % n2.shortValue() ) );

    // compare as BigIntegers
    if ( mode.equals( BigInteger.class ) )
      return asBigInteger( n1 ).mod( asBigInteger( n2 ) );

    // compare as BigDecimals
    if ( mode.equals( BigDecimal.class ) )
      {
      // return rounding difference
      BigDecimal b1 = asBigDecimal( n1 );
      BigDecimal b2 = asBigDecimal( n2 );
      BigDecimal d = b1.divide( b2, round_mode );
      return b1.subtract( d.multiply( b2 ) );
      }

    // don't know how to deal with mode
    throw new IllegalArgumentException
      (
      "unknown subclass of java.lang.Number: " + mode.getClass()
      );
    }
  }
