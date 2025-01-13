/*
The ConceptBase.cc Copyright

Copyright 1987-2025 The ConceptBase Team. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted
provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of
      conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE CONCEPTBASE TEAM ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONCEPTBASE TEAM OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the authors
and should not be interpreted as representing official policies, either expressed or implied,
of the ConceptBase Team.


The ConceptBase Team is represented by

Manfred Jeusfeld, University of Skovde, 54128 Skovde, Sweden


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/

package i5.cb.telos.frame;

import java.io.DataOutputStream;


/**
 * List of object names. <br>
 * immutable
 *
 * @author Christoph Radig
 */

public final class ObjectNames
  extends ImmutableList
{
  /**
   * create an empty list of object names
   */
  public ObjectNames()
    // POST( isEmpty() );
  {
  }

  /**
   * create from array of object names 
   */
  public ObjectNames( ObjectName[] _objectNames )
  {
    for( int i=0; i < _objectNames.length; ++i )
      append( _objectNames[i] );
  }

  /** 
   * create from java.util.Enumeration
   */
  public ObjectNames( java.util.Enumeration _objectNames )
  {
    while( _objectNames.hasMoreElements() )
      append( (ObjectName) _objectNames.nextElement() );
  }

  /**
   * create from single object name (for convenience)
   */
  public ObjectNames( ObjectName _objectName )
  {
    append( _objectName );
  }


  /**
   * functional 'append'
   * @return  a clone of this, appended by o
   */
  public ObjectNames appendedBy( ObjectName o )
  {
    ObjectNames result = (ObjectNames) clone();

    result.append( (Object) o );

    return result;
  }

  /**
   * @see AST_Node#writeTelos( DataOutputStream )
   */
  public void writeTelos( DataOutputStream os )
    throws java.io.IOException
  {
    writeTelos( os, ", " );
  }


  /**
   * @Deprecated
   */
  public String toSMLFragment()
  {
    String result = "[" + super.toSMLFragment() + "]";

    return result;
  }  // toSMLFragment

}  // class ObjectNames
