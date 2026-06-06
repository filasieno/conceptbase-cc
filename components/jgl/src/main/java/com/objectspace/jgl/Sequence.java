// Copyright(c) 1996,1997 ObjectSpace, Inc.
// Portions Copyright(c) 1995, 1996 Hewlett-Packard Company.

package com.objectspace.jgl;

import java.util.Enumeration;

/**
 * Sequence is the interface that is implemented by all Java toolkit
 * containers that are sequences of objects.
 * <p>
 * @see com.objectspace.jgl.Array
 * @see com.objectspace.jgl.Deque
 * @see com.objectspace.jgl.DList
 * @see com.objectspace.jgl.SList
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public interface Sequence extends Container
  {
  /**
   *
   */
  public Object clone();

  /**
   * Return the object at the specified index.
   * @param index The index.
   */
  public Object at( int index );

  /**
   * Set the object at a specified index.
   * @param index The index.
   * @param object The object to place at the specified index.
   */
  public void put( int index, Object object );

  /**
   * Return my last element.
   */
  public Object back();

  /**
   * Return my first element.
   */
  public Object front();

  /**
   * Insert an object in front of my first element.
   * @param object The object to insert.
   */
  public void pushFront( Object object );

  /**
   * Remove and return my first element.
   */
  public Object popFront();

  /**
   * Add an object at my end.
   * @param object The object to add.
   */
  public void pushBack( Object object );

  /**
   * Remove and return my last element.
   */
  public Object popBack();

  /**
   * Remove all elements that match a specified object and return the number of
   * objects that were removed.
   * @param object The object to remove.
   */
  public int remove( Object object );

  /**
   * Remove the element at a particular position.
   */
  public Object remove( Enumeration pos );

  /**
   * Remove at most a given number of elements that match a specified object and return the number of
   * objects that were removed.
   * @param object The object to remove.
   * @param count The maximum number of objects to remove.
   */
  public int remove( Object object, int count );

  /**
   * Remove all elements within a specified range that match a particular object
   * and return the number of objects that were removed.
   * @param first The index of the first object to remove.
   * @param last The index of the last object to remove.
   * @param object The object to remove.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public int remove( int first, int last, Object object );

  /**
   * Return the number of objects that match a specified object.
   * @param object The object to count.
   */
  public int count( Object object );

  /**
   * Return the number of objects within a specified range of that match a
   * particular value.
   * @param first The index of the first object to consider.
   * @param last The index of the last object to consider.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public int count( int first, int last, Object object );

  /**
   * Replace all elements that match a particular object with a new value and return
   * the number of objects that were replaced.
   * @param oldValue The object to be replaced.
   * @param newValue The value to substitute.
   */
  public int replace( Object oldValue, Object newValue );

  /**
   * Replace all elements within a specified range that match a particular object
   * with a new value and return the number of objects that were replaced.
   * @param first The index of the first object to be considered.
   * @param last The index of the last object to be considered.
   * @param oldValue The object to be replaced.
   * @param newValue The value to substitute.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public int replace( int first, int last, Object oldValue, Object newValue );

  /**
   * Return true if I contain a particular object.
   * @param object The object in question.
   */
  public boolean contains( Object object );

  /**
   * Return the index of the first object that matches a particular value, or
   * -1 if the object is not found.
   * @param object The object to find.
   */
  public int indexOf( Object object );

  /**
   * Return an iterator positioned at the first object within a specified range that
   * matches a particular object, or -1 if the object is not found.
   * @param first The index of the first object to consider.
   * @param last The index of the last object to consider.
   * @param object The object to find.
   * @exception java.lang.IndexOutOfBoundsException If either index is invalid.
   */
  public int indexOf( int first, int last, Object object );

  static final long serialVersionUID = 2268990129393419647L;
  }
