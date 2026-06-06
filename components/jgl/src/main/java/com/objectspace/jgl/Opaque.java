// Copyright(c) 1997 ObjectSpace, Inc.

package com.objectspace.jgl;

/**
 * Opaque is a methos of exposing data that would normally be hidden.
 * It should not be used directly, but is used internally to assist
 * distributed communication.
 * <p>
 * @version 3.1.0
 * @author ObjectSpace, Inc.
 */

public interface Opaque 
  {
  /**
   * Should not be used directly.
   */
  public Object opaqueData();

  /**
   * Should not be used directly.
   */
  public int opaqueId();
  }
