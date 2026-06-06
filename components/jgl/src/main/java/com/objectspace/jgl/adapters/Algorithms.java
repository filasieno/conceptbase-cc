// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl.adapters;

import com.objectspace.jgl.*;

/**
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

final class Algorithms
  {
  private Algorithms()
    {
    }

  static final class Printing
    {
    private Printing()
      {
      }

    /**
     * @see com.objectspace.jgl.algorithms.Printing#toString(com.objectspace.jgl.Container,java.lang.String)
     */
    public static String toString( Container container, String name )
      {
      StringBuffer buffer = new StringBuffer( name );
      buffer.append( "(" );
      boolean first = true;
      java.util.Enumeration iter = container.start();
      while ( iter.hasMoreElements() )
        {
        if ( first )
          {
          buffer.append( " " );
          first = false;
          }
        else
          buffer.append( ", " );
        buffer.append( iter.nextElement() );
        }
      if ( first )
        buffer.append( ")" );
      else
        buffer.append( " )" );
      return buffer.toString();
      }
    }

  static final class Hashing
    {
    static final int HASH_SIZE = 16;
  
    private Hashing()
      {
      }
  
    /**
     * @see com.objectspace.jgl.algorithms.Hashing#orderedHash(com.objectspace.jgl.Container)
     */
    public static int orderedHash( ForwardIterator iter, int length )
      {
      int h = 0;
      int position = 0;
      int skip = 1;
      if ( length >= HASH_SIZE )
        {
        skip = length / HASH_SIZE;
        // insure that first will always exactly reach last
        iter.advance( length % HASH_SIZE );
        }
      while ( iter.hasMoreElements() )
        {
        if ( iter.get() != null )
          h ^= iter.get().hashCode() / ( ( position % HASH_SIZE ) + 1 );
        ++position;
        iter.advance( skip );
        }
      return h;
      }
  
    /**
     * @see com.objectspace.jgl.algorithms.Hashing#unorderedHash(com.objectspace.jgl.Container)
     */
    public static int unorderedHash( ForwardIterator iter )
      {
      int h = 0;
      while ( iter.hasMoreElements() )
        {
        if ( iter.get() != null )
          h ^= iter.get().hashCode();
        iter.advance();
        }
      return h;
      }
    }

  static final class Comparing
    {
    private Comparing()
      {
      }

    /**
     * @see com.objectspace.jgl.algorithms.Comparing#equal(com.objectspace.jgl.Container,com.objectspace.jgl.Container)
     */
    public static boolean equal( Container container1, Container container2 )
      {
      if ( container1.size() != container2.size() )
        return false;

      java.util.Enumeration iter1 = container1.start();
      java.util.Enumeration iter2 = container2.start();
      while ( iter1.hasMoreElements() )
        if ( !iter1.nextElement().equals( iter2.nextElement() ) )
          return false;
  
      return true;
      }
    }

  static final class Removing
    {
    private Removing()
      {
      }

    /**
     * @see com.objectspace.jgl.algorithms.Removing#remove(com.objectspace.jgl.ForwardIterator,com.objectspace.jgl.ForwardIterator,java.lang.Object)
     */
    public static ForwardIterator remove( ForwardIterator first, ForwardIterator last, Object object )
      {
      first = (ForwardIterator)Finding.find( first, last, object );
  
      if ( first.equals( last ) )
        return first;

      ForwardIterator i = (ForwardIterator)first.clone();
      i.advance();
      while ( !i.equals( last ) )
        {
        if ( !i.get().equals( object ) )
          {
          first.put( i.get() );
          first.advance();
          }
        i.advance();
        }

      return first;
      }
    }

  static final class Finding
    {
    private Finding()
      {
      }

    /**
     * @see com.objectspace.jgl.algorithms.Finding#find(com.objectspace.jgl.ForwardIterator,com.objectspace.jgl.ForwardIterator,java.lang.Object)
     */
    public static InputIterator find( InputIterator first, InputIterator last, Object object )
      {
      InputIterator firstx = (InputIterator)first.clone();
      while ( !firstx.equals( last ) && !( firstx.get().equals( object ) ) )
        firstx.advance();

      return firstx;
      }
    }

  static final class Replacing
    {
    private Replacing()
      {
      }

    /**
     * @see com.objectspace.jgl.algorithms.Replacing#replace(com.objectspace.jgl.ForwardIterator,com.objectspace.jgl.ForwardIterator,java.lang.Object,java.lang.Object)
     */
    public static int replace( ForwardIterator first, ForwardIterator last, Object oldValue, Object newValue )
      {
      ForwardIterator firstx = (ForwardIterator)first.clone();
      int n = 0;

      while ( !firstx.equals( last ) )
        {
        if ( firstx.get().equals( oldValue ) )
          {
          firstx.put( newValue );
          ++n;
          }

        firstx.advance();
        }

      return n;
      }
    }

  static final class Counting
    {
    private Counting()
      {
      }

    /**
     * @see com.objectspace.jgl.algorithms.Counting#count(com.objectspace.jgl.InputIterator,com.objectspace.jgl.InputIterator,java.lang.Object)
     */
    public static int count( InputIterator first, InputIterator last, Object object )
      {
      InputIterator firstx = (InputIterator)first.clone();
      int n = 0;
      while ( !firstx.equals( last ) )
        if ( firstx.nextElement().equals( object ) )
          ++n;
      return n;
      }
    }

  static final class Copying
    {
    private Copying()
      {
      }
  
    /**
     * @see com.objectspace.jgl.algorithms.Copying#copy(com.objectspace.jgl.InputIterator,com.objectspace.jgl.InputIterator,com.objectspace.jgl.OutputIterator)
     */
    public static OutputIterator copy( ForwardIterator first, ForwardIterator last, OutputIterator result )
      {
      ForwardIterator firstx = (ForwardIterator)first.clone();
      OutputIterator resultx = (OutputIterator)result.clone();
  
      while ( !firstx.equals( last ) )
        {
        resultx.put( firstx.nextElement() );
        resultx.advance();
        }
  
      return resultx;
      }
  
    /**
     * @see com.objectspace.jgl.algorithms.Copying#copyBackward(com.objectspace.jgl.InputIterator,com.objectspace.jgl.InputIterator,com.objectspace.jgl.OutputIterator)
     */
    public static void copyBackward( BidirectionalIterator first, BidirectionalIterator last, BidirectionalIterator result )
      {
      BidirectionalIterator lastx = (BidirectionalIterator)last.clone();
      BidirectionalIterator resultx = (BidirectionalIterator)result.clone();
  
      while ( !first.equals( lastx ) )
        {
        resultx.retreat();
        lastx.retreat();
        resultx.put( lastx.get() );
        }
      }
    }

  static final class Filling
    {
    private Filling()
      {
      }
  
    /**
     * @see com.objectspace.jgl.algorithms.Filling#fill(com.objectspace.jgl.ForwardIterator,com.objectspace.jgl.ForwardIterator,java.lang.Object)
     */
    public static void fill( ForwardIterator first, ForwardIterator last, Object object )
      {
      while ( !first.equals( last ) )
        {
        first.put( object );
        first.advance();
        }
      }
    }
  }
