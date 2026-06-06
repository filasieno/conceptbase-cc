// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.util;

import com.objectspace.jgl.*;
import java.util.Random;

/**
 * An easy-to-use random number generator.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class Randomizer extends java.util.Random
  {
  static Randomizer random = new Randomizer();

  /**
   * Initializes the generator using a seed based on the current time.
  **/
  public Randomizer()
    {
    }

  /**
   * Initializes the generator using a specific seed; useful for generating
   * a repeatable stream of random numbers.
   * @param seed The initial seed.
   * @see java.util.Random#setSeed
  **/
  public Randomizer( long seed )
    {
    super( seed );
    }

  /**
   * Generates an int value between 1 and the given limit.
   * @param hi The upper bound.
   * @return An integer value.
   * @see java.util.Random#nextInt
  **/
  public int nextInt( int hi )
    {
    return nextInt( 1, hi );
    }

  /**
   * Generates an int value between the given limits.
   * @param lo The lower bound.
   * @param hi The upper bound.
   * @return An integer value.
   * @see java.util.Random#nextInt
  **/
  public int nextInt( int lo, int hi )
    {
    if ( lo > hi )
      throw new InvalidOperationException( "invalid range: " + lo + " > " + hi );
    return ( Math.abs( super.nextInt() ) % ( hi - lo + 1 ) ) + lo;
    }

  /**
   * Generates a long value between 1 and the given limit.
   * @param hi The upper bound.
   * @return A long value.
   * @see java.util.Random#nextLong
  **/
  public long nextLong( long hi )
    {
    return nextLong( 1, hi );
    }

  /**
   * Generates a long value between the given limits.
   * @param lo The lower bound.
   * @param hi The upper bound.
   * @return A long integer value.
   * @see java.util.Random#nextLong
  **/
  public long nextLong( long lo, long hi )
    {
    if ( lo > hi )
      throw new InvalidOperationException( "invalid range: " + lo + " > " + hi );
    return ( Math.abs( super.nextLong() ) % ( hi - lo + 1 ) ) + lo;
    }

  /**
   * Generates a float value between 1.0 and the given limit.
   * @param hi The upper bound.
   * @return A float value.
   * @see java.util.Random#nextFloat
  **/
  public float nextFloat( float hi )
    {
    return nextFloat( 1, hi );
    }

  /**
   * Generates a float value between the given limits.
   * @param lo The lower bound.
   * @param hi The upper bound.
   * @return A float value.
   * @see java.util.Random#nextFloat
  **/
  public float nextFloat( float lo, float hi )
    {
    if ( lo > hi )
      throw new InvalidOperationException( "invalid range: " + lo + " > " + hi );
    return ( Math.abs( super.nextFloat() ) % ( hi - lo + 1 ) ) + lo;
    }

  /**
   * Generates a double value between 1.0 and the given limit.
   * @param hi The upper bound.
   * @return A double value.
   * @see java.util.Random#nextDouble
  **/
  public double nextDouble( double hi )
    {
    return nextDouble( 1, hi );
    }

  /**
   * Generates a double value between the given limits.
   * @param lo The lower bound.
   * @param hi The upper bound.
   * @return A double value.
   * @see java.util.Random#nextDouble
  **/
  public double nextDouble( double lo, double hi )
    {
    if ( lo > hi )
      throw new InvalidOperationException( "invalid range: " + lo + " > " + hi );
    return ( Math.abs( super.nextDouble() ) % ( hi - lo + 1 ) ) + lo;
    }

  /**
   * Generate a random number using the default generator.
   * @see #nextInt
  **/
  public static int getInt( int hi )
    {
    return getInt( 1, hi );
    }

  /**
   * Generate a random number using the default generator.
   * @see #nextInt
  **/
  public static int getInt( int lo, int hi )
    {
    return random.nextInt( lo, hi );
    }

  /**
   * Generate a random number using the default generator.
   * @see #nextLong
  **/
  public static long getLong( long hi )
    {
    return getLong( 1, hi );
    }

  /**
   * Generate a random number using the default generator.
   * @see #nextLong
  **/
  public static long getLong( long lo, long hi )
    {
    return random.nextLong( lo, hi );
    }

  /**
   * Generate a random number using the default generator.
   * @see #nextFloat
  **/
  public static float getFloat( float hi )
    {
    return getFloat( 1, hi );
    }

  /**
   * Generate a random number using the default generator.
   * @see #nextFloat
  **/
  public static float getFloat( float lo, float hi )
    {
    return random.nextFloat( lo, hi );
    }

  /**
   * Generate a random number using the default generator.
   * @see #nextDouble
  **/
  public static double getDouble( double hi )
    {
    return getDouble( 1, hi );
    }

  /**
   * Generate a random number using the default generator.
   * @see #nextDouble
  **/
  public static double getDouble( double lo, double hi )
    {
    return random.nextDouble( lo, hi );
    }

  static final long serialVersionUID = 9176119848813218452L;
  }
