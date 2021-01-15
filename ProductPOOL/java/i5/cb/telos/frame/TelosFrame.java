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

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;

import com.objectspace.jgl.HashSet;
import com.objectspace.jgl.Set;

/**
 * A single Telos frame. May be used to access frames received
 * from the parser as well as to construct arbitrary frames.
 * This is recommended rather than constructing Telos frames as strings
 * because of better encapsulation of the Telos syntax. <br>
 * (mutable)
 *
 * @author Christoph Radig
 */

/* Implementation details:
 + Da Listen von Telos frames sehr gross werden koennen, versuchen wir,
   mit dem Speicher moeglichst sparsam umzugehen. Daher koennen leere Listen
   intern als Nullreferenzen repraesentiert werden. Nach aussen erscheinen sie
   aber stets als leere Listen.
   Das macht sich besonders bei grosser Anzahl von TelosFrames bemerkbar, die
   nur aus Objektnamen bestehen.
 */

public class TelosFrame extends ShallowCloneableNode implements AST_Node {
    /**
     * constructs a Telos frame with the given Omega class, object name,
     * classes, superclasses and attributes
     * @param _inOmegaSpec  the 'Omega class' 'this' is in (optional)
     * @param _objectName   the name of this frame
     * @param _inSpec       the classes 'this' is in (optional)
     * @param _isaSpec      the superclasses 'this' is derived from (optional)
     * @param _withSpec     definition of attributes (optional)
     */
    public TelosFrame(ObjectName _inOmegaSpec, ObjectName _objectName,
                      ObjectNames _inSpec, ObjectNames _isaSpec, WithSpec _withSpec)
    // _inOmegaSpec darf null sein.
    // PRE( nonNull( _objectName ) );
    // _inSpec, _isaSpec und _withSpec duerfen null sein.
    {
        m_inOmegaSpec=_inOmegaSpec;
        m_objectName=_objectName;
        m_inSpec=_inSpec;
        m_isaSpec=_isaSpec;
        m_withSpec=_withSpec;
    } // ctor

    /**
     * constructs a Telos frame without classes, superclasses or attributes
     * @param _objectName  the name of this frame
     */
    public TelosFrame(ObjectName _objectName) {
        this(null, _objectName, null, null, null);
    } // ctor

    /**
     * @return   != null: the Omega class 'this' is in
     *           == null: there is no Omega class 'this' is in
     */
    public synchronized final ObjectName inOmegaSpec() {
        return m_inOmegaSpec;
    }

    /**
     * sets the Omega classes 'this' is in
     * @param _inOmegaSpec  != null: the Omega classes 'this' is in
     *                      == null: there is no Omega class 'this' is in
     */
    public synchronized final void setInOmegaSpec(ObjectName _inOmegaSpec)
    // POST( inOmegaSpec() == _inOmegaSpec );
    {
        m_inOmegaSpec=_inOmegaSpec;
    }

    /**
     * @return this frame's object name
     */
    public synchronized final ObjectName objectName()
    // POST( nonNull( result ) );
    {
        return m_objectName;
    }

    /**
     * sets this frame's object name
     * @param _objectName   the new object name
     */
    public synchronized final void setObjectName(ObjectName _objectName)
    // PRE( nonNull( _objectName ) );
    // POST( objectName().equals( _objectName ) );
    {
        m_objectName=_objectName;
    }

    /**
     * @return the classes 'this' is in
     */
    public synchronized final ObjectNames inSpec()
    // POST( nonNull( result ) );
    {
        ObjectNames result;

        if(m_inSpec != null)
            result=m_inSpec;
        else
            result=new ObjectNames();

        return result;
    }

    /**
     * sets the classes 'this' is in
     * @param _inSpec  != null: the classes 'this' is in
     *                 == null: there are no classes 'this' is in
     *                          (same as empty _inSpec)
     */
    public synchronized final void setInSpec(ObjectNames _inSpec)
    // POST( inSpec().equals( _inSpec ) );
    {
        m_inSpec=_inSpec;
    }

    /**
     * @return the subclasses 'this' is derived from
     */
    public synchronized final ObjectNames isaSpec()
    // POST( nonNull(result) );
    {
        ObjectNames result;

        if(m_isaSpec != null)
            result=m_isaSpec;
        else
            result=new ObjectNames();

        return result;
    }

    /**
     * sets the superclasses 'this' is derived from
     * @param _isaSpec  != null: the superclasses 'this' is derived from
     *                  == null: there are no superclasses 'this' is derived from
     *                           (same as empty list)
     */
    public synchronized final void setIsaSpec(ObjectNames _isaSpec)
    // POST( isaSpec().equals( _isaSpec ) );
    {
        m_isaSpec=_isaSpec;
    }

    /**
     * @return the definition of attributes
     */
    public synchronized final WithSpec withSpec()
    // POST( nonNull(result) );
    {
        WithSpec result;

        if(m_withSpec != null)
            result=m_withSpec;
        else
            result=new WithSpec();

        return result;
    }

    /**
     * sets the superclasses 'this' is derived from
     * @param _withSpec  != null: definition of attributes (declarations)
     *                   == null: same as empty _withSpec (no declarations)
     */
    public synchronized final void setWithSpec(WithSpec _withSpec)
    // POST( withSpec().equals( _withSpec ) );
    {
        m_withSpec=_withSpec;
    }

    /**
     * @return does 'this' have Omega classes specified?
     */
    public synchronized final boolean hasInOmegaSpec() {
        return m_inOmegaSpec != null;
    }

    /**
     * @return does 'this' have classes specified?
     */
    public synchronized final boolean hasInSpec() {
        return m_inSpec != null && !m_inSpec.isEmpty();
    }

    /**
     * @return does 'this' have subclasses specified?
     */
    public synchronized final boolean hasIsaSpec() {
        return m_isaSpec != null && !m_isaSpec.isEmpty();
    }

    /**
     * @return does 'this' have attributes specified?
     */
    public synchronized final boolean hasWithSpec() {
        return m_withSpec != null && !m_withSpec.isEmpty();
    }

    /**
     * @see AST_Node#writeTelos( DataOutputStream )
     */
    public void writeTelos(DataOutputStream os) throws java.io.IOException { // nosynch
        if(hasInOmegaSpec()) {
            inOmegaSpec().writeTelos(os);
            os.writeByte(' ');
        }

        objectName().writeTelos(os);
        os.writeByte(' ');

        if(hasInSpec()) {
            os.writeBytes("in ");
            inSpec().writeTelos(os);
            os.writeByte(' ');
        }

        if(hasIsaSpec()) {
            os.writeBytes("isA ");
            isaSpec().writeTelos(os);
            os.writeByte(' ');
        }

        if(hasWithSpec()) {
            os.writeBytes("with\n");
            withSpec().writeTelos(os);
            os.writeByte('\n');
        }

        os.writeBytes("end\n");
    } // writeTelos

    public String toString() {
        ByteArrayOutputStream bos=new ByteArrayOutputStream();
        try {
            writeTelos(new DataOutputStream(bos));
        }
        catch (java.io.IOException ex) {}
        return bos.toString();
    }

    /**
     * @Deprecated
     */
    public String toSMLFragment() {
        String result=
            "SMLfragment(what(" + objectName().toSMLFragment() +
            "),in_omega(";

        if(hasInOmegaSpec())
            result+="[" + inOmegaSpec().toSMLFragment() + "]";
        else
            result+="nil";

        result+="),in(";

        if(hasInSpec())
            result+=inSpec().toSMLFragment();
        else
            result+="nil";

        result+="),isa(";

        if(hasIsaSpec())
            result+=isaSpec().toSMLFragment();
        else
            result+="nil";

        result+="),with(";

        if(hasWithSpec())
            result+=withSpec().toSMLFragment();
        else
            result+="nil";

        result+="))";

        return result;
    } // toSMLFragment

    /**
     * @see #equals( TelosFrame )
     */
    public synchronized boolean equals(Object other) {
        return(other instanceof TelosFrame && equals((TelosFrame) other));
    }

    /**
     * As a TelosFrame object represents a syntactic Telos object, equals
     * compares two Telos frames on a syntactical basis.
     * Example: The two frames
     * <tt> a in A, B end </tt>
     * and
     * <tt> a in B, A end </tt>
     * are <i>not</i> equal.
     * The same applies to the equals function of all other AST_Node's.
     */
    public synchronized final boolean equals(TelosFrame other) {
        boolean result=
            other != null &&
            objectName().equals(other.objectName()) &&
            inOmegaSpecIsEqual(other) &&
            inSpecIsEqual(other) &&
            isaSpecIsEqual(other) &&
            withSpecIsEqual(other);

        return result;
    } // equals

    /**
     * @return  the inOmega spec of the two frames is syntactically equal.
     */
    public synchronized final boolean inOmegaSpecIsEqual(TelosFrame other)
// PRE( nonNull( other ) );
    {
        boolean result=
            (m_inOmegaSpec == null && other.m_inOmegaSpec == null) ||
            (m_inOmegaSpec != null && m_inOmegaSpec.equals(other.m_inOmegaSpec));

        return result;
    }

    /**
     * @return  the in spec of the two frames is syntactically equal.
     */
    public synchronized final boolean inSpecIsEqual(TelosFrame other)
// PRE( nonNull( other ) );
    {
        boolean result=inSpec().equals(other.m_inSpec);

        return result;
    }

    /**
     * @return  the isa spec of the two frames is syntactically equal.
     */
    public synchronized final boolean isaSpecIsEqual(TelosFrame other)
// PRE( nonNull( other ) );
    {
        boolean result=isaSpec().equals(other.m_isaSpec);

        return result;
    }

    /**
     * @return  the with spec of the two frames is syntactically equal.
     */
    public synchronized final boolean withSpecIsEqual(TelosFrame other)
// PRE( nonNull( other ) );
    {
        boolean result=withSpec().equals(other.m_withSpec);

        return result;
    }

    /** @return  the value (target) of the attribute (property)
     *           with the given source.
     *           == null, if there is no attribute with the given source.
     * Example: In the frame <br> <br>
     * <tt>
     * Employee John with <br>
     *   name <br>
     *     johnsName : "John" <br>
     * end </tt> <br> <br>
     * getTargetOf( new Label( "johnsName" ) ) would return "John". <br>
     *
     * The Telos syntax allows a frame with two different properties
     * that have the same source (but different targets). However, such a
     * frame is semantically incorrect. For the sake of simplicity, we
     * just return the first occurence of a property with the given source.
     */
    public synchronized PropertyTarget getTargetOf(Label source) {
        PropertyTarget result=null;

        if(hasWithSpec())
            result=withSpec().getTargetOf(source);

        return result;
    } // getTargetOf

    /**
     * @return  the set of properties in the given category
     */
    public synchronized Set getPropertiesInCategory(Label category)
// PRE( nonNull( category ) );
// POST( nonNull( result ) );
    {
        Set result;

        if(!hasWithSpec())
            result=new HashSet();
        else
            result=withSpec().getPropertiesInCategory(category);

        return result;
    } // getPropertiesInCategory

    /**
     * @return  the set of all attribute categories in the frame
     */
    public synchronized Set getCategories()
// POST( nonNull( result ) );
    {
        Set result;

        if(!hasWithSpec())
            result=new HashSet();
        else
            result=withSpec().getCategories();

        return result;
    } // getCategories

    /**
     * @return  the set of categories which the property with the given source
     *          is in. Empty set, if there is no such property.
     */
    public synchronized Set getCategoriesOf(Label source)
// PRE( nonNull( source ) );
// POST( nonNull( result ) );
    {
        Set result;

        if(!hasWithSpec())
            result=new HashSet();
        else
            result=withSpec().getCategoriesOf(source);

        return result;
    } // getCategoriesOf

    public int hashCode() {
        return m_objectName.hashCode();
        // das muss reichen
    }

    /** Adds an attribute declaration to the telos frame
     * @param attrCategory the category of the attribute
     * @param attrLabel the label of the attribute
     * @param attrTarget the target of the attribute
     * */
    public synchronized void addAttribute(Label attrCategory, Label attrLabel,
                                          PropertyTarget attrTarget) {

        AttrCategories acs=new AttrCategories();
        acs.append(attrCategory);

        addAttribute(acs, attrLabel, attrTarget);
    }

    /** Adds an attribute declaration to the telos frame
     * @param attrCats a list of attribute categories
     * @param attrLabel the label of the attribute
     * @param attrTarget the target of the attribute
     * */
    public synchronized void addAttribute(AttrCategories attrCats, Label attrLabel,
                                          PropertyTarget attrTarget) {

        Property p=new Property(attrLabel, attrTarget);
        Properties ps=new Properties();
        ps.append(p);

        Declaration d=new Declaration(attrCats, ps);
        m_withSpec.append(d);
    }

    /**
     * this' object name
     */
    private ObjectName m_objectName;

    /**
     * the 'Omega class' we're in
     */
    private ObjectName m_inOmegaSpec;

    /**
     * the classes we're in
     */
    private ObjectNames m_inSpec;

    /**
     * the subclasses we're derived from
     */
    private ObjectNames m_isaSpec;

    /**
     * definition of attributes
     */
    private WithSpec m_withSpec;

}
