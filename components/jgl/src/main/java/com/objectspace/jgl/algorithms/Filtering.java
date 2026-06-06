// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

/**
 * The Filtering class contains generic filtering algorithms.
 * <p>
 * @see com.objectspace.jgl.examples.FilteringExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class Filtering
  {
  private Filtering()
    {
    }

  /**
   * Replace all consecutive occurrences of an object in a sequence by a single
   * instance of that object. Use equals() to perform the equality test. The size of the
   * sequence is not altered; if n elements are removed, the last n elements will have
   * undefined values. The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @return An iterator positioned immediately after the last element of the "new" sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static OutputIterator unique( ForwardIterator first, ForwardIterator last )
    {
    return unique( first, last, new Predicates.EqualTo() );
    }

  /**
   * Replace all consecutive occurrences of an object in a container by a single
   * instance of that object. Use equals() to perform the equality test. The size of the
   * container is not altered; if n elements are removed, the last n elements will have
   * undefined values. The time complexity is linear and the space complexity is constant.
   * @param container The container.
   * @return An iterator positioned immediately after the last element of the "new" sequence.
   */
  public static OutputIterator unique( Container container )
    {
    return unique( container.start(), container.finish(), new Predicates.EqualTo() );
    }

  /**
   * Replace all consecutive occurrences of an object in a sequence by a single
   * instance of that object. The size of the sequence is not altered; if n elements are
   * removed, the last n elements will have undefined values. The time complexity is
   * linear and the space complexity is constant.
   * @param first An iterator positioned at the first element of the sequence.
   * @param last An iterator positioned immediately after the last element of the sequence.
   * @param predicate A binary predicate that returns true if both of its operands are "equal".
   * @return An iterator positioned immediately after the last element of the new sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static OutputIterator unique( ForwardIterator first, ForwardIterator last, BinaryPredicate predicate )
    {
    first = (ForwardIterator)Finding.adjacentFind( first, last, predicate );
    return uniqueCopy( first, last, first, predicate );
    }

  /**
   * Replace all consecutive occurrences of an object in a container by a single
   * instance of that object. The size of the container is not altered; if n elements are
   * removed, the last n elements will have undefined values. The time complexity is
   * linear and the space complexity is constant.
   * @param container The container.
   * @param predicate A binary predicate that returns true if both of its operands are "equal".
   * @return An iterator positioned immediately after the last element of the "new" sequence.
   */
  public static OutputIterator unique( Container container, BinaryPredicate predicate )
    {
    return unique( container.start(), container.finish(), predicate );
    }

  /**
   * Copy a sequence into another sequence, replacing all consecutive occurrences of an
   * object by a single instance of that object. Use equals() to perform the equality test.
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element of the input sequence.
   * @param last An iterator positioned immediately after the last element of the input sequence.
   * @param result An iterator positioned at the first element of the output sequence.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator uniqueCopy( InputIterator first, InputIterator last, OutputIterator result )
    {
    return uniqueCopy( first, last, result, new Predicates.EqualTo() );
    }

  /**
   * Copy a container into another sequence, replacing all consecutive occurrences of an
   * object by a single instance of that object. Use equals() to perform the equality test.
   * The time complexity is linear and the space complexity is constant.
   * @param container The container.
   * @param result An iterator positioned at the first element of the output sequence.
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator uniqueCopy( Container container, OutputIterator result )
    {
    return uniqueCopy( container.start(), container.finish(), result, new Predicates.EqualTo() );
    }

  /**
   * Copy the contents of one container into another container, replacing all consecutive
   * occurrences of an object by a single instance of that object. Use equals() to perform
   * the equality test. The time complexity is linear and the space complexity is constant.
   * @param source The source container.
   * @param destination The destination container.
   */
  public static void uniqueCopy( Container source, Container destination )
    {
    uniqueCopy( source.start(), source.finish(), new com.objectspace.jgl.util.InsertIterator( destination ), new Predicates.EqualTo() );
    }

  /**
   * Copy a sequence into another sequence, replacing all consecutive occurrences of an
   * object by a single instance of that object. The time complexity is linear and the
   * space complexity is constant.
   * @param first An iterator positioned at the first element of the input sequence.
   * @param last An iterator positioned immediately after the last element of the input sequence.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param predicate A binary predicate that returns true if both of its operands are "equal".
   * @return An iterator positioned immediately after the last element of the output sequence.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static OutputIterator uniqueCopy( InputIterator first, InputIterator last, OutputIterator result, BinaryPredicate predicate )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    InputIterator firstx = (InputIterator)first.clone();
    if ( firstx.equals( last ) )
      {
      return (OutputIterator)result.clone();
      }
    else if ( result instanceof ForwardIterator )
      {
      ForwardIterator resultx = (ForwardIterator)result.clone();
      resultx.put( firstx.nextElement() );

      while ( !firstx.equals( last ) )
        {
        if ( !predicate.execute( resultx.get(), firstx.get() ) )
          {
          resultx.advance();
          resultx.put( firstx.get() );
          }

        firstx.advance();
        }

      resultx.advance();
      return resultx;
      }
    else
      {
      Object value = firstx.get();
      OutputIterator resultx = (OutputIterator)result.clone();
      resultx.put( value );
      firstx.advance();

      while ( !firstx.equals( last ) )
        {
        if ( !predicate.execute( value, firstx.get() ) )
          {
          value = firstx.get();
          resultx.advance();
          resultx.put( value );
          }

        firstx.advance();
        }

      resultx.advance();
      return resultx;
      }
    }

  /**
   * Copy a container into another sequence, replacing all consecutive occurrences of an
   * object by a single instance of that object. The time complexity is linear and the
   * space complexity is constant.
   * @param container A container.
   * @param result An iterator positioned at the first element of the output sequence.
   * @param predicate A binary predicate that returns true if both of its operands are "equal".
   * @return An iterator positioned immediately after the last element of the output sequence.
   */
  public static OutputIterator uniqueCopy( Container container, OutputIterator result, BinaryPredicate predicate )
    {
    return uniqueCopy( container.start(), container.finish(), result, predicate );
    }

  /**
   * Copy the contents of one container into another container, replacing all consecutive
   * occurrences of an object by a single instance of that object. The time complexity is
   * linear and the space complexity is constant.
   * @param source The source container.
   * @param destination The destination container.
   * @param predicate A binary predicate that returns true if both of its operands are "equal".
   */
  public static void uniqueCopy( Container source, Container destination, BinaryPredicate predicate )
    {
    uniqueCopy( source.start(), source.finish(), new com.objectspace.jgl.util.InsertIterator( destination ), predicate );
    }

  /**
   * Select elements in a range. Return a container that is the same type
   * as that bein iterated over and only contains the elements within the range that satisfy
   * a particular predicate. The original container is not modified.
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element in the range.
   * @param last An iterator positioned immediately after the last element in the range.
   * @param predicate A unary predicate.
   * @return A new container containing the elements that satisfied the predicate.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static Container select( InputIterator first, InputIterator last, UnaryPredicate predicate )
    {
    Container c;
    if ( first instanceof ForwardIterator )
      c = (Container)( (ForwardIterator)first ).getContainer().clone();
    else
      c = new DList();
    return select( first, last, predicate, c );
    }

  /**
   * Select elements in a container. Return a container that is the same class as
   * the original and only contains the elements that satisfy a particular predicate.
   * The original container is not modified.
   * The time complexity is linear and the space complexity is constant.
   * @param container A container.
   * @param predicate A unary predicate.
   * @return A new container containing the elements that satisfied the predicate.
   */
  public static Container select( Container container, UnaryPredicate predicate )
    {
    Container c = (Container)container.clone();
    try
      {
      // fast way - remove all elements that aren't wanted
      c.remove
        (
        Removing.removeIf( c.start(), c.finish(), new UnaryNot( predicate ) ),
        c.finish()
        );
      }
    catch ( IllegalArgumentException ex )
      {
      // containers that don't support remove()
      return select( container.start(), container.finish(), predicate, c );
      }
    return c;
    }

  /**
   * Reject elements in a range. Return a container that is the same class as the
   * original and only contains the elements within the range that do not satisfy a
   * particular predicate. The original container is not modified.
   * The time complexity is linear and the space complexity is constant.
   * @param first An iterator positioned at the first element of the range.
   * @param last An iterator positioned immediately after the last element of the range.
   * @param predicate A unary predicate.
   * @return A new container containing the elements that do not satisfy the predicate.
   * @exception IllegalArgumentException If the iterator container types are different.
   * @exception IllegalArgumentException If the iterators are incompatible.
   */
  public static Container reject( InputIterator first, InputIterator last, UnaryPredicate predicate )
    {
    return select( first, last, new UnaryNot( predicate ) );
    }

  /**
   * Reject elements in a container. Return a container that is the same class as
   * the original and only contains the elements that do not satisfy a particular predicate.
   * The original container is not modified.
   * The time complexity is linear and the space complexity is constant.
   * @param container A container
   * @param predicate A unary predicate.
   * @return A new container containing the elements that do not satisfy the predicate.
   */
  public static Container reject( Container container, UnaryPredicate predicate )
    {
    Container c = (Container)container.clone();
    try
      {
      // fast way - remove all elements that aren't wanted
      c.remove
        (
        Removing.removeIf( c.start(), c.finish(), predicate ),
        c.finish()
        );
      }
    catch ( IllegalArgumentException ex )
      {
      // containers that don't support remove()
      return select( container.start(), container.finish(), new UnaryNot( predicate ), c );
      }
    return c;
    }

  private static Container select( InputIterator first, InputIterator last, UnaryPredicate predicate, Container container )
    {
    if ( !first.isCompatibleWith( last ) )
      throw new IllegalArgumentException( "iterators not compatible" );

    // make sure container is empty
    container.clear();

    InputIterator firstx = (InputIterator)first.clone();
    while ( !firstx.equals( last ) )
      {
      Object object = firstx.nextElement();
      if ( predicate.execute( object ) )
        container.add( object );
      }

    return container;
    }

  final static class UnaryNot implements UnaryPredicate
    {
    UnaryPredicate myPredicate;
    public UnaryNot( UnaryPredicate predicate )
      {
      myPredicate = predicate;
      }
  
    /**
     * @see com.objectspace.jgl.predicates.UnaryNot#execute(java.lang.Object)
     */
    public boolean execute( Object object )
      {
      return !myPredicate.execute( object );
      }
    }
  }
