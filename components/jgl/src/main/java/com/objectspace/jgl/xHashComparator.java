// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl;

final class xHashComparator implements BinaryPredicate
  {
  /**
   * @see com.objectspace.jgl.predicates.HashComparator#execute(java.lang.Object,java.lang.Object)
   */
  public boolean execute( Object first, Object second )
    {
    return first.hashCode() < second.hashCode();
    }

  static final long serialVersionUID = -5935097699688512897L;
  }
