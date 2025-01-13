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
 * property (represents an attribute) <br>
 * immutable
 * @author Christoph Radig
 */

public final class Property
  extends ShallowCloneableNode
{
  /**
   * creates a property with the given label and target
   **/
  public Property( Label label, PropertyTarget target )
    // PRE( nonNull( label ) );
    // PRE( nonNull( target ) );
  {
    m_label = label;
    m_target = target;
  }  // ctor


  /**
   * @return the attribute's label
   **/
  public final Label getLabel()
  {
    return m_label;
  }


  /**
   * @return the attribute's target
   **/
  public final PropertyTarget getTarget()
    // POST( nonNull( result ) );
  {
    return m_target;
  }


  /**
   * @Deprecated
   * @see #getLabel()
   **/
  public final Label source()
    // POST( nonNull( result ) );
  {
    return m_label;
  }


  /**
   * @Deprecated
   * @see #getTarget()
   **/
  public final PropertyTarget target()
    // POST( nonNull( result ) );
  {
    return m_target;
  }


  /**
   * @see AST_Node#writeTelos( DataOutputStream )
   */
  public void writeTelos( DataOutputStream os )
    throws java.io.IOException
  {
    os.writeBytes( "    " );
    m_label.writeTelos( os );
    os.writeBytes( " : " );
    m_target.writeTelos( os );
  }

  /** 
   * @Deprecated
   */
  public String toSMLFragment()
  {
    String result = "";

    return result;
  }


  public boolean equals( Object other )
  {
    return ( other instanceof Property && equals( (Property) other ) );
  }

  public final boolean equals( Property other )
  {
    boolean result = 
      other != null &&
      m_label.equals( other.m_label ) &&
      m_target.equals( other.m_target );

    return result;
  }


  private Label m_label;
  private PropertyTarget m_target;

}  // class Property
