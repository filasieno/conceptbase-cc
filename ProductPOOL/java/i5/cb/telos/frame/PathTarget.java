/*
The ConceptBase.cc Copyright

Copyright 1987-2019 The ConceptBase Team. All rights reserved.

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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/

package i5.cb.telos.frame;

import java.io.DataOutputStream;


/**
 * immutable
 * @author Christoph Radig
 */

public final class PathTarget 
  extends ShallowCloneableNode
  implements APathTarget
{
  public PathTarget( APathTarget _left, String _selector, Restriction _right )
    // PRE( PathExp.isSelectorB( _selector ) );
    //
    // POST( left().equals( _left ) );
    // POST( selector().equals( _selector ) );
    // POST( right().equals( _right ) );
  {
    m_left = _left;
    m_selector = _selector;
    m_right = _right;
  }


  public final APathTarget left()
  {
    return m_left;
  }

  public final Restriction right()
  {
    return m_right;
  }

  public final String selector()
    // besser: abstrakten Typ liefern statt konkreter Syntax!
    // POST( PathExp.isSelectorB( result ) );
  {
    String result = m_selector;

    return result;
  }


  /**
   * @see AST_Node#writeTelos( DataOutputStream )
   */
  public void writeTelos( DataOutputStream os )
    throws java.io.IOException
  {
    left().writeTelos( os );
    os.writeBytes( selector() );
    right().writeTelos( os );
  }  // writeTelos


  /**
   * @Deprecated
   */
  public String toSMLFragment()
  {
    return null;
  }


  public boolean equals( Object other )
  {
    return ( other instanceof PathTarget && equals( (PathTarget) other ) );
  }

  public final boolean equals( PathTarget other )
  {
    boolean result = 
      other != null &&
      m_left.equals( other.m_left ) &&
      m_selector.equals( other.m_selector ) &&
      m_right.equals( other.m_right );

    return result;
  }


  public int hashCode()
  {
    return m_left.hashCode() ^ m_selector.hashCode() ^ m_right.hashCode();
  }


  private APathTarget m_left;
  private String m_selector;
  private Restriction m_right;

}  // class PathTarget
