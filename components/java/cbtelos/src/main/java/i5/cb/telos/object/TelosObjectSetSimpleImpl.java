/*
The ConceptBase.cc Copyright

Copyright 1987-2026 The ConceptBase Team. All rights reserved.

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

package i5.cb.telos.object;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

import com.objectspace.jgl.*;
import com.objectspace.jgl.algorithms.*;
import com.objectspace.jgl.predicates.LessString;
import com.objectspace.jgl.predicates.UnaryAnd;

/**
 * Prototype object store.
 * Design goal: does not need to be extremely efficient,
 * but must be finished quickly and do everything that the
 * later 'real' object store will need to do.
 *
 * -time if not stated otherwise, n == this.size()
 * @author Christoph Radig
 **/

public class TelosObjectSetSimpleImpl
implements ITelosObjectSet, Cloneable {
    /**
     * a regular set that contains the objects
     **/
    private Set m_objects;


    /**
     * creates an empty object set
     * -time O(1)
     **/
    public TelosObjectSetSimpleImpl() {
        m_objects = new HashSet();
        //POST isEmpty()
    }

    /**
     * creates an empty object set that contains all the <code>objects</code>.
     * -time O(1)
     **/
    TelosObjectSetSimpleImpl( Set objects ) {
        m_objects = objects;
    }


    /**
     * @return a deep enough copy of this object set
     **/
    public Object clone() {
        TelosObjectSetSimpleImpl result = null;

        // 1. make shallow clone:
        try {
            result = (TelosObjectSetSimpleImpl) super.clone();
        }
        catch( CloneNotSupportedException ex ) {
            ex.printStackTrace();
            throw new Error();
        }

        // 2. clone the object set:
        result.m_objects = (Set) m_objects.clone();

        return result;
    }  // clone


    /**
     * -time time(hash table lookup), which should be nearly O(1), if the
     *   hash table is big enough.
     **/
    public boolean contains( TelosObject o ) {
        return objects().get( o ) != null;
    }


    /**
     * -time should be O(1)
     **/
    public int size() {
        return objects().size();
    }


    /**
     * -time should be O(1)
     **/
    public boolean isEmpty() {
        return objects().isEmpty();
    }


    /**
     * -time O(1)
     **/
    public TelosObject getTheOnlyMember()
    throws /*SingleMemberExpected*/Exception {
        TelosObject result = null;

        int n = size();
        if( n > 0 ) {
            if( n == 1 )
                result = (TelosObject) elements().nextElement();
            else
                throw new Exception( "single member expected." );
        }

        return result;
    }  // getTheOnlyMember


    /////////////////////////////////////////////////////////////////////////////
    // GET SINGLE OBJECT methods:
    /////////////////////////////////////////////////////////////////////////////

    /**
     * -time == time(hash table lookup)
     **/
    public Individual getIndividual( String sLabel ) {
        Individual result = TelosObject.lookupIndividual( sLabel );

        if( result != null && !this.contains( result ) )
            result = null;
        return result;
    }  // getIndividual


    /**
     * -time == time(hash table lookup)
     **/
    public Instantiation getInstantiation( TelosObject source,
    TelosObject destination ) {
        Instantiation result =
        TelosObject.lookupInstantiation( source, destination );

        if( result != null && !this.contains( result ) )
            result = null;

        return result;
    }  // getInstantiation


    /**
     * -time == time(hash table lookup)
     **/
    public Specialization getSpecialization( TelosObject source,
    TelosObject destination ) {
        Specialization result =
        TelosObject.lookupSpecialization( source, destination );

        if( result != null && !this.contains( result ) )
            result = null;

        return result;
    }  // getSpecialization


    /**
     * -time O(n)
     **/
    public Attribute getAttribute( TelosObject source, String sLabel ) {
        UnaryPredicate p = new EqualsAttribute( source, sLabel );

        return (Attribute) Finding.detect( objects(), p );
    }  // getAttribute


    /**
     * if the destination is known, we can make it in O(1)
     * -time O(1)
     **/
    public Attribute getAttribute( TelosObject source, String sLabel,
    TelosObject destination ) {
        Attribute result =
        TelosObject.lookupAttribute( source, sLabel, destination );

        if( result != null && !this.contains( result ) )
            result = null;

        return result;
    }  // getAttribute


    /**
     * don't mix up this with the ConceptBase builtin query get_object, which
     * rather is a getFrame.
     * -time O(n)
     **/
    public TelosObject getObject( TelosObject source, String sLabel,
    TelosObject destination ) {
        UnaryPredicate p = new EqualsProposition( source, sLabel, destination );

        return (TelosObject) Finding.detect( objects(), p );
    }  // getObject


    /////////////////////////////////////////////////////////////////////////////
    // UPDATE methods:
    /////////////////////////////////////////////////////////////////////////////

    /**
     * -time time(hash table insertion), which should be nearly O(1),
     * if the hash table is big enough.
     **/
    public void add( TelosObject object ) {
        m_objects.add( object );

        //POST this.contains( object )
    }  // add


    /**
     * -time time(hash table deletion), which should be nearly O(1),
     * if the hash table is big enough.
     **/
    public void remove( TelosObject object ) {
        m_objects.remove( object );

        //POST !this.contains( object )
    }  // remove


    /**
     * -time O(n), if the hash table is big enough.
     **/
    public void add( ITelosObjectSet objects ) {
        java.util.Enumeration iter = objects.elements();
        //Contract.require("TelosObjectSimpleImpl.add: objects = null", objects==null );
        while( iter.hasMoreElements() )
            add( (TelosObject) iter.nextElement() );
    }  // add

    /**
     * -time O(n), if the hash table is big enough.
     **/
    public void remove( ITelosObjectSet objects ) {
        java.util.Enumeration iter = objects.elements();
        while( iter.hasMoreElements() )
            remove( (TelosObject) iter.nextElement() );
    }  // remove


    /**
     * -time O(1)
     **/
    public void clear() {
        m_objects = new HashSet();

        //POST isEmpty()
    }  // clear


    ////////////////////////////////////////////////////////////////////////////
    // Boolean queries:
    ////////////////////////////////////////////////////////////////////////////

    /**
     * -time ==time(hash table lookup)
     **/
    public final boolean isExplicitClassOf( TelosObject o1, TelosObject o2 ) {
        return getInstantiation( o2, o1 ) != null;
    }


    /**
     * -time == time(hash table lookup)
     **/
    public final boolean isExplicitInstanceOf( TelosObject o1, TelosObject o2 ) {
        return getInstantiation( o1, o2 ) != null;
    }


    /**
     * -time == time(hash table lookup)
     **/
    public final boolean isExplicitSuperclassOf(
    TelosObject o1, TelosObject o2 ) {
        return getSpecialization( o2, o1 ) != null;
    }


    /**
     * -time == time(hash table lookup)
     **/
    public final boolean isExplicitSubclassOf( TelosObject o1, TelosObject o2 ) {
        return getSpecialization( o1, o2 ) != null;
    }


    /**
     * -time O(n)
     **/
    public final boolean isA( TelosObject o1, TelosObject o2 ) {
        return
        ((TelosObjectSetSimpleImpl) getAllSubclassesOf( o2 )).
        objects().get( o1 ) != null;
    }


    /**
     * -time O(n)
     **/
    public final boolean in( TelosObject o1, TelosObject o2 ) {
        return
        ((TelosObjectSetSimpleImpl) getAllInstancesOf( o2 )).
        objects().get( o1 ) != null;
    }


    /////////////////////////////////////////////////////////////////////////////
    // GET SETS OF INDIVIDUALS:
    /////////////////////////////////////////////////////////////////////////////

    /**
     * -time O(n)  [O(n) + O(#classes) + O(#classes) * O(1)]
     **/
    public ITelosObjectSet getExplicitClassesOf( TelosObject o ) {
        ITelosObjectSet result;

        Set set =
        (Set) Transforming.collect(
        ( (TelosObjectSetSimpleImpl) getClassificationsOf( o ) ).
        objects(), new GetDestination() );

        result = getFilteredTelosObjects( set, new IsContainedIn( this ) );

        return result;
    }  // getExplicitClassesOf


    /**
     * -time O(n)  [O(n) + O(#instances) + O(#instances) * O(1)]
     **/
    public ITelosObjectSet getExplicitInstancesOf( TelosObject object ) {
        ITelosObjectSet result;

        Set set =
        (Set) Transforming.collect(
        ( (TelosObjectSetSimpleImpl) getInstantiationsOf( object ) ).
        objects(), new GetSource() );

        result = getFilteredTelosObjects( set, new IsContainedIn( this ) );

        return result;
    }  // getExplicitInstancesOf


    /**
     * -time O(n)  [O(n) + O(#superclasses) + O(#superclasses) * O(1)]
     **/
    public ITelosObjectSet getExplicitSuperclassesOf( TelosObject object ) {
        ITelosObjectSet result;

        Set set = (Set) Transforming.collect(
        ((TelosObjectSetSimpleImpl) getGeneralizationsFrom( object )).
        objects(), new GetDestination() );

        result = getFilteredTelosObjects( set, new IsContainedIn( this ) );

        return result;
    }  // getExplicitSuperclassesOf


    /**
     * -time O(n)  [O(n) + O(#subclasses) + O(#subclasses) * O(1)]
     **/
    public ITelosObjectSet getExplicitSubclassesOf( TelosObject object ) {
        ITelosObjectSet result;

        Set set = (Set) Transforming.collect(
        ( (TelosObjectSetSimpleImpl) getSpecializationsFrom( object ) ).
        objects(), new GetSource() );

        result = getFilteredTelosObjects( set, new IsContainedIn( this ) );

        return result;
    }  // getExplicitSubclassesOf


    /**
     * naive calculation of the transitive closure of the specialization
     * relation.
     * algorithm (in functional, pseudo Haskell syntax):<br>
     * <code>result = (inject subclassSet [object] union)<br>
     *   where subclassSet = (map getAllSubclassesOf directSubclasses)<br>
     *         directSubclasses = (getExplicitSubclassesOf object)<br></code>
     *
     * <code>inject</code> is ae JGL-function.
     * <code>map</code> hei?t <code>collect</code> in JGL.
     *
     * @return the transitive closure of (result isA object)
     * -time O(n) [O(n) + #directSubclasses * time(getAllSubclassesOf) + O(n)]
     *   Note that this doesn't mean this algorithm is particularly efficient!
     **/
    public ITelosObjectSet getAllSubclassesOf( TelosObject object ) {
        TelosObjectSetSimpleImpl result = new TelosObjectSetSimpleImpl();

        TelosObjectSetSimpleImpl directSubclasses =
        (TelosObjectSetSimpleImpl) getExplicitSubclassesOf( object );

        directSubclasses.remove( object );
        // the object itself must be removed, to prevent endless recursion.

        java.util.Enumeration iter = directSubclasses.elements();
        while( iter.hasMoreElements() ) {
            TelosObject o = (TelosObject) iter.nextElement();
            TelosObjectSetSimpleImpl subclasses =
            (TelosObjectSetSimpleImpl) getAllSubclassesOf( o );
            Copying.copy( subclasses.m_objects, result.m_objects );
        }  // while

        result.add( object );
        // finally, add the object itself (o isA o is always true)

        return result;
    }  // getAllSubclassesOf


    /**
     * naive calculation of the instantiation relation, via the transitive
     * closure of the specialization relation.
     * @return the transitive closure of (result in object)
     * -time O(n) (!).
     *   Note that this doesn't mean this algorithm is particularly efficient!
     **/
    public ITelosObjectSet getAllInstancesOf( TelosObject object ) {
        // Algorithm:
        // 1. get all subclasses of object
        // 2. get all direct instances of these subclasses

        TelosObjectSetSimpleImpl result = new TelosObjectSetSimpleImpl();

        TelosObjectSetSimpleImpl subclasses =
        (TelosObjectSetSimpleImpl) getAllSubclassesOf( object );

        java.util.Enumeration iter = subclasses.elements();
        while( iter.hasMoreElements() ) {
            TelosObject cls = (TelosObject) iter.nextElement();
            TelosObjectSetSimpleImpl instances =
            (TelosObjectSetSimpleImpl) getExplicitInstancesOf( cls );
            Copying.copy( instances.m_objects, result.m_objects );
        }  // while

        return result;
    }  // getAllInstancesOf


    /////////////////////////////////////////////////////////////////////////////
    // GET SETS OF LINKS:
    /////////////////////////////////////////////////////////////////////////////

    /**
     * -time O(n)
     **/
    public ITelosObjectSet getSpecializationsFrom( TelosObject object ) {
        UnaryPredicate p =
        new UnaryAnd( new GoesInto( object ),
        new IsInSystemClass( TelosObject.SPECIALIZATION ) );

        return getFilteredTelosObjects( p );
    }  // getSpecializationsFrom


    /**
     * -time O(n)
     **/
    public ITelosObjectSet getGeneralizationsFrom( TelosObject object ) {
        UnaryPredicate p =
        new UnaryAnd( new ComesOutOf( object ),
        new IsInSystemClass( TelosObject.SPECIALIZATION ) );

        return getFilteredTelosObjects( p );
    }  // getGeneralizationsFrom


    /**
     * -time O(n)
     **/
    public ITelosObjectSet getInstantiationsOf( TelosObject object ) {
        UnaryPredicate p =
        new UnaryAnd( new GoesInto( object ),
        new IsInSystemClass( TelosObject.INSTANTIATION ) );

        return getFilteredTelosObjects( p );
    }  // getInstantiationsOf


    /**
     * -time O(n)
     **/
    public ITelosObjectSet getClassificationsOf( TelosObject object ) {
        UnaryPredicate p =
        new UnaryAnd( new ComesOutOf( object ),
        new IsInSystemClass( TelosObject.INSTANTIATION ) );

        return getFilteredTelosObjects( p );
    }  // getClassificationsOf


    /**
     * -time O(n)
     **/
    public ITelosObjectSet getAttributesOf( TelosObject object ) {
        UnaryPredicate p =
        new UnaryAnd( new ComesOutOf( object ),
        new IsInSystemClass( TelosObject.ATTRIBUTE ) );

        return getFilteredTelosObjects( p );
    }  // getAttributesOf


    /**
     * -time O(n)
     **/
    public ITelosObjectSet getAttributesTo( TelosObject object ) {
        UnaryPredicate p =
        new UnaryAnd( new GoesInto( object ),
        new IsInSystemClass( TelosObject.ATTRIBUTE ) );

        return getFilteredTelosObjects( p );
    }  // getAttributesTo


    /**
     * -time O(n) [O(n) + m * O(n)]. Slow though...
     **/
    public ITelosObjectSet getAttributesOfCategory( TelosObject o,
    Attribute attrCategory ) {
        // Algorithm:
        // 1. Compute all attributes of o
        // 2. Filter out the instances of attrCategory
        // 3. Return this

        TelosObjectSetSimpleImpl tosAllAttributes =
        (TelosObjectSetSimpleImpl) getAttributesOf( o );

        UnaryPredicate p = new In( attrCategory );

        ITelosObjectSet result =
        getFilteredTelosObjects( tosAllAttributes.objects(), p );

        // Postcondition: forall a/result: a in attrCategory

        return result;
    }  // getAttributesOfCategory


    public ITelosObjectSet getAttributesOfExplicitCategory( TelosObject o,
    Attribute attrCategory ) {
        TelosObjectSetSimpleImpl tosAllAttributes =
        (TelosObjectSetSimpleImpl) getAttributesOf( o );

        UnaryPredicate p = new IsExplicitInstanceOf( attrCategory );

        ITelosObjectSet result =
        getFilteredTelosObjects( tosAllAttributes.objects(), p );

        // Postcondition: forall a/result: a in attrCategory

        return result;
    }  // getAttributesOfExplicitCategory


    /**
     * -time O(n). Slow though...
     **/
    public Attribute getSingleAttributeOfCategory( TelosObject o,
    Attribute attrCategory )
    throws Exception {
        return (Attribute)
        getAttributesOfCategory( o, attrCategory ).getTheOnlyMember();
    }  // getSingleAttributeOf


    /**
     * Optimized version of getSingleAttributeOfCategory(
     *   TelosObject o, Attribute c )
     * Finds only direct instances of attribute category c.
     * @return the first attribute found.
     *   If several exist, this is not reported as an error.
     **/
    public Attribute getSingleAttributeOfExplicitCategory( TelosObject source,
    Attribute attrCategory ) {
        Attribute result = null;

        java.util.Enumeration iter = elements();
        while( iter.hasMoreElements() ) {
            TelosObject o = (TelosObject) iter.nextElement();
            if( o.isAttribute() && o.getSource() == source &&
            isExplicitInstanceOf( o, attrCategory ) ) {
                result = (Attribute) o;
                break;
            }
        }  // while

        return result;
    }  // getSingleExplicitAttributeOf


    /**
     * -time O(n)
     **/
    public ITelosObjectSet getOutgoingLinksOf( TelosObject object ) {
        UnaryPredicate p = new ComesOutOf( object );

        return getFilteredTelosObjects( p );
    }  // getOutgoingLinksOf


    /**
     * -time O(n)
     **/
    public ITelosObjectSet getIncomingLinksOf( TelosObject object ) {
        UnaryPredicate p = new GoesInto( object );

        return getFilteredTelosObjects( p );
    }  // getIncomingLinksOf


    /////////////////////////////////////////////////////////////////////////////
    // helper methods / classes:
    /////////////////////////////////////////////////////////////////////////////

    /**
     * -time O(n) * time(p)
     **/
    final ITelosObjectSet getFilteredTelosObjects( UnaryPredicate p ) {
        return getFilteredTelosObjects( objects(), p );
    }  // getFilteredTelosObjects


    /**
     * -time O(n) * time(p)
     **/
    static ITelosObjectSet getFilteredTelosObjects( Set set, UnaryPredicate p ) {
        return new TelosObjectSetSimpleImpl( (Set) Filtering.select( set, p ) );
    }  // getFilteredTelosObjects


    /**
     * ...
     **/
    public ITelosObjectSet map( UnaryFunction uf ) {
        ITelosObjectSet result =
        new TelosObjectSetSimpleImpl(
        (Set) Transforming.collect( objects(), uf ) );

        return result;
    }  // map


    /**
     * Filter: object of certain type (in certain system class)
     *
     * -time O(1)
     **/
    class IsInSystemClass
    implements UnaryPredicate {
        IsInSystemClass( int iSystemClass ) {
            this.iSystemClass = iSystemClass;
        }

        public boolean execute( Object o ) {
            TelosObject to = (TelosObject) o;

            return to.getSystemClass() == iSystemClass;
        }

        int iSystemClass;

    }  // inner class IsInSystemClass


    /**
     * Filter: has certain source, label and destination
     *
     * -time O(1)
     **/
    class EqualsProposition
    implements UnaryPredicate {
        EqualsProposition( TelosObject source, String sLabel,
        TelosObject destination ) {
            this.source = source;
            this.sLabel = sLabel;
            this.destination = destination;
        }

        public boolean execute( Object o ) {
            TelosObject to = (TelosObject) o;

            return to.getSource() == source &&
            to.getDestination() == destination &&
            to.getLabel().equals( sLabel );
        }

        TelosObject source;
        String sLabel;
        TelosObject destination;

    }  // inner class EqualsProposition


    /**
     * Filter: has certain source, label and destination
     *
     * -time O(1)
     **/
    class EqualsAttribute
    implements UnaryPredicate {
        EqualsAttribute( TelosObject source, String sLabel ) {
            this.source = source;
            this.sLabel = sLabel;
        }

        public boolean execute( Object o ) {
            TelosObject to = (TelosObject) o;
            //if(to.getSource()==source) System.out.println("IDENTICAL");
            //System.out.println("*** EXECUTE: " + to.getSource()+ "==" + source + " ; " + to.getLabel() + "==" + sLabel);
            if(to.getLabel().equals(sLabel)){
                //System.out.println("EqualsAttribute.execute: to.getSource: "+to.getSource()+to.getSource().hashCode() +"; source: "+ source+source.hashCode() );
                //System.out.println("EqualsAttribute.execute: to.getSystemClass() == TelosObject.ATTRIBUTE: "+new Boolean((to.getSystemClass() == TelosObject.ATTRIBUTE)));
                //System.out. println("EqualsAttribute.execute: to.getSource() == source: "+new Boolean(to.getSource() == source));
                //System.out.println("EqualsAttribute.execute: to.getLabel().equals( sLabel ): "+to.getLabel().equals( sLabel ) );
            }
            return to.getSystemClass() == TelosObject.ATTRIBUTE &&
            to.getSource() == source &&
            to.getLabel().equals( sLabel );
        }

        TelosObject source;
        String sLabel;

    }  // inner class EqualsAttribute


    /**
     * Filter: has certain label
     *
     * -time O(1)
     **/
    class HasLabel
    implements UnaryPredicate {
        HasLabel( String sLabel ) {
            this.sLabel = sLabel;
        }

        public boolean execute( Object o ) {
            TelosObject to = (TelosObject) o;

            return to.getLabel().equals( sLabel );
        }

        String sLabel;

    }  // inner class HasLabel


    /**
     * Filter: outgoing links
     *
     * -time O(1)
     **/
    class ComesOutOf
    implements UnaryPredicate {
        ComesOutOf( TelosObject to ) {
            m_to = to;
        }

        public boolean execute( Object o ) {
            TelosObject to = (TelosObject) o;

            return to.isLink() && to.getSource() == m_to;
        }

        TelosObject m_to;

    }  // inner class ComesOutOf


    /**
     * Filter: incoming links
     *
     * -time O(1)
     **/
    class GoesInto
    implements UnaryPredicate {
        GoesInto( TelosObject to ) {
            m_to = to;
        }

        public boolean execute( Object o ) {
            TelosObject to = (TelosObject) o;

            return to.isLink() && to.getDestination() == m_to;
        }

        TelosObject m_to;

    }  // inner class GoesInto


    /**
     * Filter: "in" alias "is instance of"
     *
     * -time time(in) == ?
     **/
    class In
    implements UnaryPredicate {
        public In( TelosObject to ) {
            m_to = to;
        }

        public boolean execute( Object o ) {
            TelosObject to = (TelosObject) o;

            return in( to, m_to );
        }

        TelosObject m_to;
    }  // inner class In


    /**
     * Filter: "is explicit instance of"
     *
     * -time time(isExplicitInstanceOf) == time(hash table lookup)
     **/
    class IsExplicitInstanceOf
    implements UnaryPredicate {
        public IsExplicitInstanceOf( TelosObject to ) {
            m_to = to;
        }

        public boolean execute( Object o ) {
            TelosObject to = (TelosObject) o;

            return isExplicitInstanceOf( to, m_to );
        }

        TelosObject m_to;
    }  // inner class IsExplicitInstanceOf


    /**
     * Filter: containment
     *
     * -time time(contains) == O(1)
     **/
    class IsContainedIn
    implements UnaryPredicate {
        IsContainedIn( ITelosObjectSet tos ) {
            this.tos = tos;
        }

        public boolean execute( Object o ) {
            TelosObject to = (TelosObject) o;

            return tos.contains( to );
        }

        ITelosObjectSet tos;

    }  // inner class IsContained


    /**
     * Transformation: get source
     *
     * -time O(1)
     **/
    class GetSource
    implements UnaryFunction {
        public Object execute( Object o ) {
            return ((TelosObject) o).getSource();
        }
    }  // inner class GetSource


    /**
     * Transformation: get destination
     *
     * -time O(1)
     **/
    class GetDestination
    implements UnaryFunction {
        public Object execute( Object o ) {
            return ((TelosObject) o).getDestination();
        }
    }  // inner class GetDestination


    /**
     * @return enumeration of all contained objects
     * -time O(1)
     **/
    public final java.util.Enumeration elements() {
        return m_objects.elements();
    }

    /**
     * @return a sorted enumeration of all contained objects
     * -time O(1)
     **/
    public final java.util.Enumeration sortedElements() {
        return Sorting.iterSort(m_objects.start(),m_objects.finish(), new LessString() ).begin;
    }

    /**
     * Do we want to make the use of JGL public?
     * Let's wait for JDK 1.2's collections to make a decision.
     **/
    final Set objects() {
        return m_objects;
    }


    /**
     * @return string that contains the explicit contained objects
     *   as propositions (short oid format): P(id,src,label,dest)\n...<br>
     *   Note that the object set may be incomplete, as referenced objects
     *   might not be explicitly contained in the object set.
     * -time O(n)
     **/
    public String asPropositions() {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PrintStream ps = new PrintStream( baos );

        java.util.Enumeration iter = elements();
        while( iter.hasMoreElements() )
            ps.println(
            ((TelosObject) iter.nextElement()).asProposition( false ) );

        return baos.toString();
    }  // asPropositions


    /**
     * @return String im langen Proposition-Format: P(id,src,label,dest), ...
     **/
    public String toString() {
        return objects().toString();
    }

}  // class TelosObjectSetSimpleImpl
