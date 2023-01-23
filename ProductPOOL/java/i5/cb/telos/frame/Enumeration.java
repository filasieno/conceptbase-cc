/*
The ConceptBase.cc Copyright

Copyright 1987-2023 The ConceptBase Team. All rights reserved.

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
 * enumerates multiple object names.
 * Do not mix up with java.util.Enumeration!
 * immutable
 * @author Christoph Radig
 */
public final class Enumeration
  extends ShallowCloneableNode
  implements RestrictionTarget
{
  /**
   * An enumeration is a list of object names, with special syntax, and
   * in the context of a RestrictionTarget
   * @param _objectNames  list of object names
   */
  public Enumeration( ObjectNames _objectNames )
  {
    m_objectNames = _objectNames;
  }


  public final ObjectNames objectNames()
  {
    return m_objectNames;
  }


  /**
   * @see AST_Node#writeTelos( DataOutputStream )
   */
  public void writeTelos( DataOutputStream os )
    throws java.io.IOException
  {
    os.writeBytes( "[ " );
    m_objectNames.writeTelos( os );
    os.writeBytes( " ]" );
  }  // writeTelos

  /**
   * @Deprecated
   */
  public String toSMLFragment()
  {
    String result = "[" + m_objectNames.toSMLFragment() + "]";

    return result;
  }


  public boolean equals( Object other )
  {
    return ( other instanceof Enumeration && equals( (Enumeration) other ) );
  }

  public final boolean equals( Enumeration other )
  {
    return ( other != null && m_objectNames.equals( other.m_objectNames ) );
  }


  public int hashCode()
  {
    return m_objectNames.hashCode();
  }


  private ObjectNames m_objectNames;

}  // class Enumeration

