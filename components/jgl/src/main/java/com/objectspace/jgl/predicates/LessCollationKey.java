// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl.predicates;

import com.objectspace.jgl.*;
import java.text.Collator;
import java.text.CollationKey;

/**
 * LessCollationKey is a binary predicate that returns true
 * if the first operand as a string is less than the
 * second operand as a string when compared using the given Collator object.
 * Instead of using the compare() call, getCollationKey() is used and the
 * results of that are compared.
 * If either operand is itself a CollationKey object, then that operand is
 * used without getting a new key from the collator.
 * <p>
 * If an explicit Collator object is not given, the default is used.
 * <p>
 * @see java.text.Collator
 * @see java.text.CollationKey
 * @see com.objectspace.jgl.examples.CollateExamples
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public final class LessCollationKey implements BinaryPredicate
  {
  Collator collator;

  /**
   * Construct a LessCollationKey function object that uses the collator
   * object for the current default locale to compare objects.
   */
  public LessCollationKey()
    {
    collator = Collator.getInstance();
    }

  /**
   * Construct a LessCollationKey function object that uses the given collator
   * object to compare objects.
   * @param collator The Collator object that is to be used for comparisons.
   */
  public LessCollationKey( Collator collator )
    {
    this.collator = collator;
    }

  /**
   * Return true if the first operand is less than the second operand.
   * <STRONG>Note:</STRONG> CollationKeys created by different Collators can 
   * not be compared.
   * @see java.text.CollationKey#compareTo
   * @param first The first operand.
   * @param second The second operand.
   * @return true if the sort key of the first operand is less than that of the second.
   */
  public boolean execute( Object first, Object second )
    {
    CollationKey firstKey = first instanceof CollationKey
      ? (CollationKey)first
      : collator.getCollationKey( first.toString() );
    CollationKey secondKey = second instanceof CollationKey
      ? (CollationKey)second
      : collator.getCollationKey( second.toString() );
    return firstKey.compareTo( secondKey ) < 0;
    }

  static final long serialVersionUID = -753602287906161248L;
  }
