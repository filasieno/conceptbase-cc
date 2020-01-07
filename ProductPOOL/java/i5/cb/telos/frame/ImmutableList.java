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

import com.objectspace.jgl.*;


/**
 * Helper class to handle immutable lists of AST nodes. <br>
 * (immutable)
 *
 * @author Christoph Radig
 */

public abstract class ImmutableList
  extends ShallowCloneableNode
{
  /**
   * creates an empty list.
   **/
  ImmutableList()
  {
  }


  /**
   * creates a list out of an enumeration
   **/
  ImmutableList( java.util.Enumeration en )
  {
    while( en.hasMoreElements() ) {
      append( en.nextElement() );
    }
  }  // ctor


  /**
   * @return is 'this' empty?
   */
  public final boolean isEmpty()
  {
    return m_list.isEmpty();
  }


  /**
   * @return iterator to step thru the list
   * @see java.util.Enumeration
   */
  public java.util.Enumeration elements()
  {
    return m_list.elements();
  }


  /**
   * writes the text representation of 'this' in 'Plain Aachen' syntax.
   * @param os  the OutputStream to write into
   * @param _separator  a string that separates the list items
   */
  protected void writeTelos( DataOutputStream os, String _separator )
    throws java.io.IOException
  {
    ForwardIterator iter = m_list.start();
    while( iter.hasMoreElements() )
    {
      ( (AST_Node) iter.nextElement() ).writeTelos( os );
      if( iter.hasMoreElements() )
	os.writeBytes( _separator );
    }
  }  // writeTelos


  /**
   * @Deprecated
   */
  public String toSMLFragment()
  {
    String result = new String();

    ForwardIterator iter = m_list.start();
    while( iter.hasMoreElements() )
    {
      result += ( (AST_Node) iter.nextElement() ).toSMLFragment();
      if( iter.hasMoreElements() )
	result += ",";
    }

    return result;
  }  // toSMLFragment


  /**
   * append _o to the list.
   * Must <i>not</i> be called after the object is constructed
   * because otherwise the object won't be immutable.
   */
  final void append( Object _o )
  {
    m_list.add( _o );
  }

  
  /*
   * appends the whole contents of _c to the list
   * Must <i>not</i> be called after the object is constructed
   * because otherwise the object won't be immutable.
   * @Deprecated
   
  private final void append( Container _c )
  {
    m_list.insert( (SListIterator) m_list.finish(), 
		   _c.start(), _c.finish() );
  }
  */


  public boolean equals( Object other )
  {
    return ( other instanceof ImmutableList && 
      equals( (ImmutableList) other ) );
  }


  public final boolean equals( ImmutableList other )
  {
    return ( other != null && m_list.equals( other.m_list ) );
  }


  /** 
   * zur Implementierung eines clone() in mutable lists (Subklassen).
   * Die Liste wird kopiert, nicht aber die Objekte in der Liste.
   */
  ImmutableList deeperClone()
  {
    ImmutableList result = (ImmutableList) super.clone();

    result.m_list = (SList) result.m_list.clone();
    
    return result;
  }  // deeperClone


  final Sequence sequence()
  {
    return m_list;
  }


  final SList slist()
  {
    return m_list;
  }


  private SList m_list = new SList();

}  // class ImmutableList
