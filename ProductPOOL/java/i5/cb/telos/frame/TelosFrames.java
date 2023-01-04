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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
package i5.cb.telos.frame;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;

import com.objectspace.jgl.ForwardIterator;
import com.objectspace.jgl.SList;


/** 
 * List of Telos frames. <br>
 * (mutable)
 *
 * Deriving from SList (like any other jgl class) is error prone, 
 * as SList.clone() always returns an SList, instead of returning an
 * object of the same class as we are in (as demanded in the Java
 * language specification). This means that we don't want to use the JGL
 * in the future!
 *
 * @author Christoph Radig
 */

public class TelosFrames
  extends SList
  implements AST_Node
{
  /**
   * @see AST_Node#writeTelos( DataOutputStream )
   */
  public void writeTelos( DataOutputStream os )
    throws java.io.IOException
  {
    ForwardIterator iter = start();
    while( iter.hasMoreElements() )
    {
      ( (AST_Node) iter.nextElement() ).writeTelos( os );
      if( iter.hasMoreElements() )
	os.writeByte( '\n' );
    }
    os.writeByte( '\n' );
  }  // writeTelos


  /**
   * @return  Text (Telos) representation of this (uses writeTelos())
   */
  public String toString()
  {
    ByteArrayOutputStream bos = new ByteArrayOutputStream();
    DataOutputStream dos = new DataOutputStream( bos );

    try {
      writeTelos( dos );
    }
    catch( java.io.IOException e ) {
      throw new InternalError( e.getMessage() );
    }

    return bos.toString();
  }  // toString


  /**
   * @Deprecated
   */
  public String toSMLFragment()
  {
    String result = "[";

    ForwardIterator iter = start();
    while( iter.hasMoreElements() )
    {
      result += ( (AST_Node) iter.nextElement() ).toSMLFragment();
      if( iter.hasMoreElements() )
	result += ",";
    }

    result += "]";

    return result;
  }  // toSMLFragment


  /* this implementation of clone() would work if SList.clone() was
     implemented in the right way. Unfortunately, it isn't.
 
  public Object clone()
  {
    TelosFrames result = (TelosFrames) super.clone();

    // deepen shallow copy:
    SListIterator iter = begin();
    while( iter.hasMoreElements() ) {
      iter.put( ((TelosFrame) iter.get()).clone() );
      iter.advance();
    }

    return result;
  }  // clone
  */

  public Object clone()
  {
    TelosFrames result = new TelosFrames();

    ForwardIterator iter = start();
    while( iter.hasMoreElements() ) {
      result.add( ((TelosFrame) iter.get()).clone() );
      iter.advance();
    }

    return result;
  }  // clone

}  // class TelosFrames


