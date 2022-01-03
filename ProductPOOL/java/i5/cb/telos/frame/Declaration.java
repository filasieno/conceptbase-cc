/*
The ConceptBase.cc Copyright

Copyright 1987-2022 The ConceptBase Team. All rights reserved.

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
import com.objectspace.jgl.algorithms.Finding;
import com.objectspace.jgl.predicates.BindFirstPredicate;
import com.objectspace.jgl.predicates.BindSecondPredicate;



/**
 * immutable
 * @author Christoph Radig
 */

public final class Declaration
  extends ShallowCloneableNode
{
  public Declaration( AttrCategories _categories, Properties _properties )
    // PRE( nonNull( _categories ) );
    // PRE( nonNull( _properties ) );
  {
    m_categories = _categories;
    m_properties = _properties;
  }


  public final AttrCategories categories()
  {
    return m_categories;
  }

  public final Properties properties()
  {
    return m_properties;
  }


  public final PropertyTarget getTargetOf( Label label )
  {
    return m_properties.getTargetOf( label );
      // attribute categories are ignored.
  }

  /**
   * @return  empty, if category is not element of categories
   *          set of properties in this category, otherwise
   */
  public final Set getPropertiesInCategory( Label category )
    // PRE( nonNull( category ) );
    // POST( nonNull( result ) );
  {
    Set result = new HashSet();

    UnaryPredicate eq = new BindFirstPredicate( new com.objectspace.jgl.predicates.EqualTo(), category );
    if( Finding.some( categories().sequence(), eq ) ) {
      java.util.Enumeration iter = properties().elements();
      while( iter.hasMoreElements() )
	result.add( iter.nextElement() );
    }

    return result;
  }  // getPropertiesInCategory


  public Set getCategoriesOf( Label source )
    // PRE( nonNull( source ) );
    // POST( nonNull( result ) );
  {
    Set result = new HashSet();

    class HasSource implements BinaryPredicate {
      public boolean execute( Object property, Object _source )
      {
	return ((Property) property).getLabel().equals( (Label)_source );
      }
    }  // class HasSource

    UnaryPredicate hasSource = new BindSecondPredicate( new HasSource(), source );
    if( Finding.some( properties().sequence(), hasSource ) )
    {
      // copy categories:
      java.util.Enumeration iter = categories().elements();
      while( iter.hasMoreElements() )
	result.add( iter.nextElement() );
    }

    return result;
  }  // getCategoriesOf


  /**
   * @see AST_Node#writeTelos( DataOutputStream )
   */
  public void writeTelos( DataOutputStream os )
    throws java.io.IOException
  {
    m_categories.writeTelos( os );
    m_properties.writeTelos( os );
  }


  /**
   * @Deprecated
   */
  public String toSMLFragment()
  {
    String result = new String();

    // ...

    return result;
  }


  public boolean equals( Object other )
  {
    return ( other instanceof Declaration && equals( (Declaration) other ) );
  }

  public final boolean equals( Declaration other )
  {
    boolean result =
      other != null &&
      m_categories.equals( other.m_categories ) &&
      m_properties.equals( other.m_properties );

    return result;
  }


  public int hashCode()
  {
    return m_categories.hashCode() ^ m_properties.hashCode();
  }


  private AttrCategories m_categories;
  private Properties m_properties;

}  // class Declaration
