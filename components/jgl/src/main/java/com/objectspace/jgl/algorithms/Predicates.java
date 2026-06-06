// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl.algorithms;

import com.objectspace.jgl.*;

final class Predicates
  {
  private Predicates()
    {
    }

  static final class EqualTo implements BinaryPredicate, java.io.Serializable
    {
    /**
     * @see com.objectspace.jgl.predicates.EqualTo#execute(java.lang.Object,java.lang.Object)
     */
    final public boolean execute( Object first, Object second )
      {
      return first.equals( second );
      }

    static final long serialVersionUID = -8584901860090939159L;
    }

  static final class HashComparator implements BinaryPredicate, java.io.Serializable
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
  }
