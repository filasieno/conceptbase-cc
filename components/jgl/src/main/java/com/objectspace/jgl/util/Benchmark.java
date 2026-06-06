// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.util;

import com.objectspace.jgl.*;
import java.util.Date;

/**
 * A utility class for performing benchmarks.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public class Benchmark implements java.io.Serializable
  {
  long begin;
  long total;
  String title;
  int count;
  int cycle = 100;

  /**
   * Construct a benchmark with the specified title that displays its status
   * automatically after every specified number of start/stop cycles.
   * @param string The title
   * @param n The number of cycles
   */
  public Benchmark( String string, int n )
    {
    title = string;
    cycle = n;
    }

  /**
   * Construct a benchmark with the specified title that never displays its status
   * automatically.
   */
  public Benchmark( String string )
    {
    this( string, 0 );
    }

  /**
   * Construct a benchmark with the title <untitled> that never displays its status
   * automatically.
   */
  public Benchmark()
    {
    this( "<untitled>", 0 );
    }

  /**
   * Start/resume the benchmark clock.
   */
  public void start()
    {
    begin = (new Date()).getTime(); // Current time.
    }

  /**
   * Stop the benchmark clock.
   */
  public void stop()
    {
    total += ((new Date()).getTime() - begin);

    if ( count > 0 && cycle > 0 && count % cycle == 0 )
      System.out.println( this );

    ++count;
    }

  /**
   * Return the current number of milliseconds on the benchmark clock.
   */
  public long getMilliseconds()
    {
    return total;
    }

  /**
   * Return my title.
   */
  public String getTitle()
    {
    return title;
    }

  /**
   * Return the number of times I've been started/restarted.
   */
  public int getCount()
    {
    return count;
    }

  /**
   * Return a string that describes me.
   */
  public String toString()
    {
    return "Benchmark( " + getTitle() + " x " + count + ": " + total + " ms )";
    }

  /**
   * Display a string that compares me with another benchmark to
   * System.out.
   * @param benchmark The benchmark to compare myself against.
   */
  public void compareTo( Benchmark benchmark )
    {
    float ratio = ((float) total) / ((float) benchmark.total);
    System.out.println( "ratio of " + getTitle() + " to " + benchmark.getTitle() + " is " + ratio );
    }
  }
