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

import com.objectspace.jgl.ForwardIterator;
import com.objectspace.jgl.SList;


/** 
 * Derive expression. <br>
 * immutable
 * @author Christoph Radig
 */

public final class DeriveExp
  extends ShallowCloneableNode
  implements ObjectName 
{
  // private Label m_label;
  private ObjectName objname;
  private SList bindings;


  /**
   * @param objname  The Telos grammar requires that objname is a Label.
   *   Notifications, however, may contain derive expressions that contain
   *   select expressions. In the future, ConceptBase may (should!) generally
   *   allow an object name here, esp. another derive expression.
   **/
  public DeriveExp( ObjectName objname, java.util.Enumeration bindings )
  {
    //PRE objname != null
    //PRE bindings != null

    this.objname = objname;

    this.bindings = new SList();
    java.util.Enumeration iter = bindings;
    while( iter.hasMoreElements() )
      this.bindings.add( iter.nextElement() );
  }  // ctor


  /**
   * @Deprecated
   **/  
  /*
  public DeriveExp( Label label, Sequence _bindings )
    // PRE( nonNull( _label ) );
    // PRE( nonNull( _bindings ) );
  {
    this( _label, _bindings.elements() );
  }  // ctor
  */


  /**
   * Used by Notification parser. Generally, the usage of JGL should not
   * be public.
   **/
  public DeriveExp( ObjectName objname, SList bindings )
  {
    //PRE objname != null
    //PRE bindings != null

    this.objname = objname;
    this.bindings = bindings;
  }  // ctor
  

  public final ObjectName getObjectName()
  {
    return objname;

    //POST result != null
  }


  /**
   * @Deprecated  use getObjectName
   **/
  public final Label getLabel()
  {
    return (Label) objname;

    //POST result != null
  }


  public final java.util.Enumeration getBindings()
  {
    return bindings.elements();

    //POST result != null
  }


  /**
   * @Deprecated  use getObjectName()
   **/
  public final Label label()
  {
    return getLabel();

    //POST result != null
  }


  /**
   * @Deprecated  use getBindings()
   **/
  public final java.util.Enumeration bindings()
  {
    return getBindings();

    //POST result != null
  }


  /**
   * @see AST_Node#writeTelos( DataOutputStream )
   */
  public void writeTelos( DataOutputStream os )
    throws java.io.IOException
  {
    getObjectName().writeTelos( os );
    os.writeByte( '[' );

    ForwardIterator iter = bindings.start();
    while( iter.hasMoreElements() )
    {
      ( (Binding) iter.nextElement() ).writeTelos( os );
      if( iter.hasMoreElements() )
	os.writeBytes( ", " );
    }

    os.writeByte( ']' );
  }  // writeTelos


  /**
   * @Deprecated
   */
  public String toSMLFragment()
  {
    String result = "derive(" + getObjectName() + ",[";

    ForwardIterator iter = bindings.start();
    while( iter.hasMoreElements() )
    {
      result += ( (Binding) iter.nextElement() ).toSMLFragment();
      if( iter.hasMoreElements() )
	result += ",";
    }

    result += "])";

    return result;
  }  // toSMLFragment


  public boolean equals( Object other )
  {
    return ( other instanceof DeriveExp && equals( (DeriveExp) other ) );
  }


  public final boolean equals( DeriveExp other )
  {
    boolean result = 
      other != null &&
      getObjectName().equals( other.getObjectName() ) &&
      bindings.equals( other.bindings );

    return result;
  }


  public int hashCode()
  {
    return getObjectName().hashCode() ^ bindings.hashCode();
  }

}  // class DeriveExp
