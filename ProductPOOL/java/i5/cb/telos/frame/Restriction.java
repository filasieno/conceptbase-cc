/*
The ConceptBase.cc Copyright

Copyright 1987-2020 The ConceptBase Team. All rights reserved.

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

public final class Restriction
  extends ShallowCloneableNode
  implements APathTarget
{
  /**
   * creates a restriction as a label (a label is-a restriction)
   */
  public Restriction( Label _label )
    // PRE( nonNull( _label ) );
  {
    m_label = _label;
    m_target = null;
  }

  /**
   * creates a (real) restriction
   * @param _label  the label
   * @param _target  the set of objects _label is restricted to
   */
  public Restriction( Label _label, RestrictionTarget _target )
    // PRE( nonNull( _label ) );
    // PRE( nonNull( _target ) );
  {
    m_label = _label;
    m_target = _target;
  }


  public final Label label()
  {
    return m_label;
  }

  public final RestrictionTarget target()
  {
    return m_target;
  }


  /**
   * @see AST_Node#writeTelos( DataOutputStream )
   */
  public void writeTelos( DataOutputStream os )
    throws java.io.IOException
  {
    if( m_target == null )
      m_label.writeTelos( os );
    else
    {
      os.writeBytes( "( " );
      m_label.writeTelos( os );
      os.writeBytes( " : " );
      m_target.writeTelos( os );
      os.writeBytes( " )" );
    }
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
    return ( other instanceof Restriction && equals( (Restriction) other ) );
  }

  public final boolean equals( Restriction other )
  {
    boolean result = 
      other != null &&
      m_label.equals( other.m_label ) &&
      m_target.equals( other.m_target );

    return result;
  }


  public int hashCode()
  {
    return m_label.hashCode() ^ m_target.hashCode();
  }


  private Label m_label;
  private RestrictionTarget m_target;

}  // class Restriction
