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

import java.io.DataOutputStream;

import com.objectspace.jgl.HashSet;
import com.objectspace.jgl.Set;


/**
 * Attribute declarations. <br>
 * immutable
 *
 * @author Christoph Radig
 */

public final class WithSpec
  extends ImmutableList
{
  /**
   * creates an empty WithSpec
   **/
  public WithSpec()
  {
  }


  /**
   * @param enumDeclarations enumeration of declarations
   **/
  public WithSpec( java.util.Enumeration enumDeclarations )
  {
    super( enumDeclarations );
  }


  /**
   * append the list with the given declaration
   * @return a clone of this, appended by declaration
   **/
  public WithSpec appendedBy( Declaration declaration )
  {
    WithSpec result = (WithSpec) clone();
    result.append( declaration );

    return result;
  }  // appendedBy
	
	
  /** @return  the value (target) of the attribute (property) 
   *           with the given source.
   *           == null, if there is no attribute with the given source.
   *
   * The Telos syntax allows a frame with two different properties 
   * that have the same source (but different targets). However, such a 
   * frame is semantically incorrect. For the sake of simplicity, we
   * just return the first occurence of a property with the given source.
   */
  public PropertyTarget getTargetOf( Label source )
  {
    PropertyTarget result = null;

    java.util.Enumeration iter = elements();
    while( iter.hasMoreElements() )
    {
      result = ( (Declaration) iter.nextElement() ).getTargetOf( source );
      if( result != null )
	break;
    }
    
    return result;
  }  // getTargetOf


  /**
   * @return  the set of properties in the given category
   */
  public Set getPropertiesInCategory( Label category )
    // PRE( nonNull( category ) );
    // POST( nonNull( result ) );
  {
    HashSet result = new HashSet();

    java.util.Enumeration iter = elements();
    while( iter.hasMoreElements() )
    {
      Declaration decl = (Declaration) iter.nextElement();
      HashSet s1 = (HashSet) decl.getPropertiesInCategory( category );
      result = result.union( s1 );
    }  // while

    return result;
  }  // getPropertiesInCategory


  /**
   * @return  the set of all categories contained
   */
  public synchronized Set getCategories()
    // POST( nonNull( result ) );
  {
    Set result = new HashSet();

    java.util.Enumeration iter = elements();
    while( iter.hasMoreElements() )
    {
      Declaration decl = (Declaration) iter.nextElement();

      java.util.Enumeration iter2 = decl.categories().elements();
      while( iter2.hasMoreElements() )
	result.add( iter2.nextElement() );
    }  // while

    return result;
  }  // getCategories


  /**
   * @return  the set of categories which the property with the given source
   *          is in. Empty set, if there is no such property.
   */
  public Set getCategoriesOf( Label source )
    // PRE( nonNull( source ) );
    // POST( nonNull( result ) );
  {
    HashSet result = new HashSet();

    java.util.Enumeration iter = elements();
    while( iter.hasMoreElements() )
    {
      Declaration decl = (Declaration) iter.nextElement();
      HashSet s1 = (HashSet) decl.getCategoriesOf( source );
      result = result.union( s1 );
    }  // while

    return result;
  }  // getCategoriesOf


  /**
   * @see AST_Node#writeTelos( DataOutputStream )
   */
  public void writeTelos( DataOutputStream os )
    throws java.io.IOException
  {
    super.writeTelos( os, "\n" );
  }


  /**
   * @Deprecated
   */
  public String toSMLFragment()
  {
    String result = super.toSMLFragment();

    return result;
  }

}  // class WithSpec
