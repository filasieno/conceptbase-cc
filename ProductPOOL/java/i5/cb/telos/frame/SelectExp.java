/*
The ConceptBase.cc Copyright

Copyright 1987-2021 The ConceptBase Team. All rights reserved.

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
 * Select expression of type 1 or 2. <br>
 * immutable
 * @author Christoph Radig
 */

public final class SelectExp
  extends ShallowCloneableNode
  implements ObjectName
{
  /**
   * creates a select expression.
   * @see #isSelector1
   * @see #isSelector2
   * @param _selector selector of type 1 or 2
   **/
  public SelectExp( ObjectName _left, String _selector, ObjectName _right )
    // PRE( SelectExp.isSelector1( _selector ) || SelectExp.isSelector2( _selector ) );
    // PRE( SelectExp.isSelector1( _selector ) --> (_right instanceof Label) );
    //
    // POST( left().equals( _left ) );
    // POST( selector().equals( _selector ) );
    // POST( right().equals( _right ) );
  {
    m_left = _left;
    m_selector = _selector;
    m_right = _right;
  }  // ctor


  /**
   * Is _selector a type 1 selector? Possible type 1 selectors are:
   * <code> !  ^  @ </code>
   **/
  public static boolean isSelector1( String _selector )
    // POST( result <--> _selector.equals("!") || _selector.equals("^") || 
    //                   _selector.equals("@") );
  {
    boolean result = (_selector.length() == 1) && 
                     ( "!^@".indexOf(_selector.charAt(0)) > -1 );

    return result;
  }  // isSelector1


  /**
   * Is _selector a type-2 selector for a Telos object reference? 
   **/
  public static boolean isSelector2( String _selector )
    // POST( result <--> _selector.equals("->") || _selector.equals("=>") );
  {
    boolean result = ( _selector.equals("->") || _selector.equals("=>") );

    return result;
  }  // isSelector2


  public final ObjectName getLeft()
  {
    return m_left;
  }


  public final ObjectName getRight()
  {
    return m_right;
  }


  public final String getSelector()
    // besser: abstrakten Typ liefern statt konkreter Syntax!
  {
    return m_selector;
  }


  /**
   * @Deprecated
   * @see #getLeft()
   **/
  public final ObjectName left()
  {
    return m_left;
  }


  /**
   * @Deprecated
   * @see #getRight()
   **/
  public final ObjectName right()
  {
    return m_right;
  }


  /**
   * @Deprecated
   **/
  public final String selector()
    // besser: abstrakten Typ liefern statt konkreter Syntax!
  {
    return m_selector;
  }


  /**
   * @see AST_Node#writeTelos( DataOutputStream )
   */
  public void writeTelos( DataOutputStream os )
    throws java.io.IOException
  {
    left().writeTelos( os );
    os.writeBytes( selector() );

    /* Das folgende enthaelt einen Denkfehler:
       Da auf der rechten Seite eines Selektor1-Ausdrucks (zumindest bisher)
       kein Selektor2-Ausdruck auftauchen kann, sondern immer nur ein Label,
       braucht hier nie geklammert zu werden.
       Ich lasse den Code aber stehen fuer den Fall, dass die Grammatik 
       dahingehend erweitert werden sollte. (Instanzbeziehungen als Attribute wie 
       z.B. A!(B->C) koennten vielleicht doch einmal interessant sein)

    // Wenn this einen Selektor1 und right einen Selektor2 enthaelt, 
    // muss right geklammert werden, da Selektor2 niedrigere Prioritaet als Selektor2
    // hat und ausserdem beide linksassoziativ sind.

    boolean needsBraces =
      SelectExp.isSelector1( this.selector() ) && 
      right() instanceof SelectExp &&
      SelectExp.isSelector2( ((SelectExp) right()).selector() );
    */

    // if( needsBraces ) os.writeByte( '(' );
    right().writeTelos( os );
    // if( needsBraces ) os.writeByte( ')' );
  }  // writeTelos


  /** 
   * @Deprecated
   */
  public String toSMLFragment()
  {
    String result = "select(" + left().toSMLFragment()
      + ",\'" + selector() + "\'," + right().toSMLFragment() + ")";

    return result;
  }


  public boolean equals( Object other )
  {
    return ( other instanceof SelectExp && equals( (SelectExp) other ) );
  }


  public final boolean equals( SelectExp other )
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


  private ObjectName m_left;
  private String     m_selector;
  private ObjectName m_right;

}  // class SelectExp
