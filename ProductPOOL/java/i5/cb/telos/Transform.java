/*
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

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

package i5.cb.telos;



import i5.cb.CBException;
import i5.cb.telos.frame.*;
import i5.cb.telos.object.*;

import com.objectspace.jgl.*;


/**
 * Transformations between Frame and Proposition representation
 *
 * @author Christoph Radig
 **/

public class Transform
{

    /**
     * transform a Telos object into an objectname
     *
     * @param to  the object to transform
     * @return the objectname that uniquely identifies <tt>to</tt>
     * -postcondition result != null
     **/
    public static ObjectName toObjectName( TelosObject to )
     {
         ObjectName result = null;

         switch( to.getSystemClass() ) {
          case TelosObject.INDIVIDUAL:
              {
                  result = new Label( to.getLabel() );
                  break;
              }

          case TelosObject.INSTANTIATION:
          case TelosObject.SPECIALIZATION:
              {
                  ObjectName left = toObjectName( to.getSource() );
                  ObjectName right = toObjectName( to.getDestination() );

                  String sSelector =
                    ( to.getSystemClass() == TelosObject.INSTANTIATION ? "->" : "=>" );

                  result = new SelectExp( left, sSelector, right );
                  break;
              }

          case TelosObject.ATTRIBUTE:
              {
                  ObjectName left = toObjectName( to.getSource() );
                  result = new SelectExp( left, "!", new Label( to.getLabel() ) );
                  break;
              }

          default:
             throw new Error();
         }  // switch

         //POST result != null

         return result;
     }  // toObjectName( TelosObject )


    /**
     * transform a set of Telos objects into a set of objectnames
     *
     * @param tos  the objects to transform
     * @return the objectnames that uniquely identify <tt>tos</tt>' elements
     * -postcondition result != null
     **/
    public static ObjectNames toObjectNames( ITelosObjectSet tos,
                                            boolean bIncludeSystemClasses )
     {
         Set set = new HashSet();

         java.util.Enumeration iter = tos.elements();
         while( iter.hasMoreElements() ) {
             TelosObject to = (TelosObject) iter.nextElement();
             if( bIncludeSystemClasses || !to.isSystemClass() )
               set.add( Transform.toObjectName( to ) );
         }  // while

         ObjectNames result = new ObjectNames( set.elements() );

         return result;
     }  // toObjectNames( ITelosObjectSet )


    /**
     * @return a proposition-like representation, where source and destination
     *    are displayed as object names rather than OIDs
     **/
    public static String toObjectNamedProposition( TelosObject to )
     {
         String sSource =
           Transform.toObjectName( to.getSource() ).toString();
         String sDestination =
           ( to.getDestination() == null ? "<UNKNOWN>" :
            Transform.toObjectName( to.getDestination() ).toString() );
         // TODO: "<UNKNOWN>" or some wrapper method
         //   should be encapsulated in TelosObject!

         return "P( " + to.getOID() + ", " + sSource + ", " +
           to.getLabel() + ", " + sDestination + " )";
     }  // toObjectNamedProposition


    /**
     * @return a proposition-like representation, where source and destination
     *    are displayed as object names rather than OIDs
     **/
    public static String toObjectNamedPropositions( ITelosObjectSet tos )
     {
         StringBuffer sb = new StringBuffer();

         java.util.Enumeration iter = tos.elements();
         while( iter.hasMoreElements() ) {
             TelosObject to = (TelosObject) iter.nextElement();
             sb.append( Transform.toObjectNamedProposition( to ) );
             sb.append( "\n" );
         }

         return sb.toString();
     }  // toObjectNamedPropositions


    /**
     * transforms objectName into a Telos object. If the object or
     * dependant objects (source and destination) don't exist, they
     * are created on the fly. No objects are inserted into tos, though.
     *
     * @param objectName  the object name to transform
     * @param tos != null: try to refer dependant objects
     *   (source and destination) in tos. Attributes can be uniquely
     *   identified by object name within a single extension, but not within
     *   a JVM. Thus, if tos != null, we always try to refer an existing
     *   attribute in tos. If tos doesn't contain such an attribute, we
     *   create it on-the-fly (but don't insert it). As we don't know its
                               *   destination, we use null as destination.
                               * @return the Telos object that corresponds to objectName
                               * @throws CBException if the transformation is not possible. This may
                               *   only happen if the object name is not well-formed.
                               **/
    public static TelosObject toTelosObject( ObjectName objectName,
                                            ITelosObjectSet tos )
      throws CBException
     {
         //PRE objectName != null

         TelosObject result = null;

         if( objectName instanceof Label ) {
             Label label = (Label) objectName;
             result = TelosObject.getIndividual( label.toString() );
         }  // if instanceof Label
         else if( objectName instanceof SelectExp ) {
             SelectExp selectExp = (SelectExp) objectName;
             String sSelector = selectExp.getSelector();

             TelosObject left = Transform.toTelosObject( selectExp.getLeft(), tos );

             if( sSelector.equals( "!" ) ) {  // Attribute
                 Label labRight = (Label) selectExp.getRight();
                 if( tos != null )
                   result = tos.getAttribute( left, labRight.toString() );

                 if( result == null ) {
                     result = TelosObject.getAttribute( left, labRight.toString(),
                                                       null );  // destination is unknown
                 }
             }
             else {
                 TelosObject right = Transform.toTelosObject( selectExp.getRight(), tos );

                 if( sSelector.equals( "->" ) )
                   result = TelosObject.getInstantiation( left, right );
                 else if( sSelector.equals( "=>" ) )
                   result = TelosObject.getSpecialization( left, right );
                 else
                   throw new CBException( "Unknown Selector: " + sSelector );
             }
         }  // if instanceof SelectExp
         else if( objectName instanceof DeriveExp ) {
             result = TelosObject.getIndividual( objectName.toString() );
         }
         else
           throw new CBException( "Unknown ObjectName type: " +
                                 objectName.getClass().getName() );

         //POST result != null

         return result;
     }  // toTelosObject( ObjectName )


    /**
     * transforms objectNames into Telos objects.
     * @param objectNames  the object names to transform
     * @return the Telos object set that corresponds to objectNames
     * @throws CBException if the transformation is not possible. This may
     *   happen if the object name contains an attribute which is not contained
     *   in tos, or the object name consists of something other than labels and
     *   select expressions.
     **/
    public static ITelosObjectSet toTelosObjectSet( ObjectNames objectNames )
      throws CBException
     {
         ITelosObjectSet result = TelosObjectSetFactory.produce();

         java.util.Enumeration iter = objectNames.elements();
         while( iter.hasMoreElements() ) {
             ObjectName objn = (ObjectName) iter.nextElement();
             result.add( Transform.toTelosObject( objn, null ) );
         }

         return result;
     }  // toTelosObjectSet( ObjectNames )


    /**
     * same as toTelosObjectSet( ObjectNames )
     **/
    public static ITelosObjectSet toTelosObjectSet( AttrCategories categories,
                                                   ITelosObjectSet tos, ITelosObjectSet tosClasses )
      throws CBException
     {
         ITelosObjectSet result = TelosObjectSetFactory.produce();

         if( !tosClasses.isEmpty() ) {
             java.util.Enumeration iter1 = categories.elements();
             while( iter1.hasMoreElements() ) {
                 Label label = (Label) iter1.nextElement();

                 java.util.Enumeration iter2 = tosClasses.elements();
                 while( iter2.hasMoreElements() ) {
                     TelosObject toClass = (TelosObject) iter2.nextElement();

                     // try to find class!category:
                     Attribute attrCategory =
                       tos.getAttribute( toClass, label.toString() );

                     if( attrCategory != null ) {
                         result.add( attrCategory );
                         break;
                     }
                 }  // while iter2
             }  // while iter1
         }  // if

         return result;
     }  // toTelosObjectSet( AttrCategories )


    /**
     * "functional" version
     * @return tf as Telos object set
     **/
    public static ITelosObjectSet toTelosObjectSet( TelosFrame tf )
      throws CBException
     {
         ITelosObjectSet result = TelosObjectSetFactory.produce();

         addFrameToTelosObjectSet( tf, result );

         return result;
     }  // toTelosObjectSet( TelosFrame )


    /**
     * "imperative" version
     **/
    public static void addFrameToTelosObjectSet( TelosFrame tf,
                                                ITelosObjectSet tos )
      throws CBException
     {
         // what:
         TelosObject toWhat = Transform.toTelosObject( tf.objectName(), tos );
         tos.add( toWhat );

         // inOmega:
         if (tf.hasInOmegaSpec())
          {
              ObjectName objnOmega = tf.inOmegaSpec();
              TelosObject toOmega = Transform.toTelosObject( objnOmega, tos );
              tos.add( toOmega );
              tos.add( TelosObject.getInstantiation( toWhat, toOmega ) );
          }

         // in:
         ObjectNames objnsClasses = tf.inSpec();
         ITelosObjectSet tosClasses =
           Transform.toTelosObjectSet( objnsClasses );
         tos.add( tosClasses );

         ITelosObjectSet tosInstantiations =
           ((TelosObjectSetSimpleImpl)tosClasses).map(
                                                      new GetInstantiationTo( toWhat ) );
         tos.add( tosInstantiations );

         // isa:
         ObjectNames objnsSuperclasses = tf.isaSpec();
         ITelosObjectSet tosSuperclasses =
           Transform.toTelosObjectSet( objnsSuperclasses );
         tos.add( tosSuperclasses );

         ITelosObjectSet tosSpecializations =
           ((TelosObjectSetSimpleImpl)tosSuperclasses).map(
                                                           new GetSpecializationTo( toWhat ) );
         tos.add( tosSpecializations );

         // with:
         java.util.Enumeration iter1 = tf.withSpec().elements();
         while( iter1.hasMoreElements() ) {
             Declaration decl = (Declaration) iter1.nextElement();
             ITelosObjectSet tosCategories =
               Transform.toTelosObjectSet( decl.categories(), tos, tosClasses );
             java.util.Enumeration iter2 = decl.properties().elements();
             while( iter2.hasMoreElements() ) {
                 Property property = (Property) iter2.nextElement();
                 Label label = property.getLabel();
                 ObjectName objnTarget = (ObjectName) property.getTarget();

                 TelosObject toDestination =
                   Transform.toTelosObject( objnTarget, tos );
                 Attribute attr =
                   TelosObject.getAttribute( toWhat, label.toString(), toDestination);
                 tos.add( attr );

                 // add instantiation links to categories:
                 ITelosObjectSet tosAttrInstantiations =
                   ((TelosObjectSetSimpleImpl)tosCategories).map(
                                                                 new GetInstantiationTo( attr ) );
                 tos.add( tosAttrInstantiations );
             }  // while iter2
         }  // while iter1

     }  // addFrameToTelosObjectSet( TelosFrame )


    /**
     * "functional" version
     * @return tfs as Telos object set
     **/
    public static ITelosObjectSet toTelosObjectSet( TelosFrames tfs )
      throws CBException
     {
         ITelosObjectSet result = TelosObjectSetFactory.produce();

         addFramesToTelosObjectSet( tfs, result );

         return result;
     }  // toTelosObjectSet( TelosFrames )


    /**
     * "imperative" version: adds the objects contained in tfs to tos
     **/
    public static void addFramesToTelosObjectSet( TelosFrames tfs,
                                                 ITelosObjectSet tos )
      throws CBException
     {
         java.util.Enumeration iter = tfs.elements();
         while( iter.hasMoreElements() ) {
             TelosFrame tf = (TelosFrame) iter.nextElement();
             addFrameToTelosObjectSet( tf, tos );
         }  // while
     }  // addFramesToTelosObjectSet( TelosFrames )


    /**
     * @return to as TelosFrame (compare get_object[to] in ConceptBase)
     **/
    public static TelosFrame toTelosFrame( TelosObject to, ITelosObjectSet tos )
     {
         Label labOmegaClass = new Label( to.getSystemClassName() );
         ObjectName objnWhat =
           Transform.toObjectName( to );
         ObjectNames objnsIn =
           Transform.toObjectNames( tos.getExplicitClassesOf( to ), false );
         ObjectNames objnsIsa =
           Transform.toObjectNames( tos.getExplicitSuperclassesOf( to ), true );

         WithSpec withSpec = null;

         // That was easy. Now the "with" part:
         ITelosObjectSet tosAttributes = tos.getAttributesOf( to );
         if( tosAttributes != null ) {
             withSpec = new WithSpec();
             java.util.Enumeration iter1 = tosAttributes.elements();
             while( iter1.hasMoreElements() ) {
                 Attribute attr = (Attribute) iter1.nextElement();

                 // create a Declaration for each attribute:
                 ITelosObjectSet tosCategories = tos.getExplicitClassesOf( attr );

                 AttrCategories attrcats = new AttrCategories();
                 java.util.Enumeration iter2 = tosCategories.elements();
                 while( iter2.hasMoreElements() ) {
                     Attribute attrCategory = (Attribute) iter2.nextElement();
                     Label labCategory = new Label( attrCategory.getLabel() );
                     attrcats = attrcats.appendedBy( labCategory );
                 }  // while

                 ObjectName objnDestination =
                   Transform.toObjectName( attr.getDestination() );

                 Property property =
                   new Property( new Label( attr.getLabel() ), objnDestination );

                 Properties properties = new Properties().appendedBy( property );
                 Declaration decl = new Declaration( attrcats, properties );
                 withSpec = withSpec.appendedBy( decl );
             }  // while
         }  // if

         TelosFrame result =
           new TelosFrame( labOmegaClass, objnWhat, objnsIn, objnsIsa, withSpec );

         return result;
     }  // toTelosFrame( TelosObject )


    /**
     * @param toClass  "starting point"
     * @return tos as TelosFrames
     **/
    public static TelosFrames toTelosFrames( ITelosObjectSet tos,
                                            TelosObject toClass )
     {
         TelosFrames result = new TelosFrames();

         ITelosObjectSet tosInstances = tos.getAllInstancesOf( toClass );
         java.util.Enumeration iter = tosInstances.elements();

         while( iter.hasMoreElements() ) {
             TelosObject to = (TelosObject) iter.nextElement();
             result.add( Transform.toTelosFrame( to, tos ) );
         }  // while

         return result;
     }  // toTelosFrames( ITelosObjectSet )


    /**
     * @return tos as TelosFrames
     **/
    public static TelosFrames toTelosFrames( ITelosObjectSet tos )
     {
         TelosFrames result = new TelosFrames();

         java.util.Enumeration iter = tos.elements();
         while( iter.hasMoreElements() ) {
             TelosObject to = (TelosObject) iter.nextElement();
             result.add( Transform.toTelosFrame( to, tos ) );
         }  // while

         return result;
     }  // toTelosFrames( ITelosObjectSet )

     /**
      * Convert a list of Telos Objects to string of Telos frames. The argument bRecursive should
      * be true if the result is used in TELL, and should be false if the result is used in UNTELL.
      * If bRecursive is true, also the source and destination objects are represented as frames,
      * so that the referential integrity is correct.
      */
     public static String toFrameString(java.util.List telosObjects, boolean bRecursive) {
         StringBuffer sbResult=new StringBuffer();
         java.util.Iterator it=telosObjects.iterator();
         while(it.hasNext())
             sbResult.append(Transform.toFrameString((TelosObject)it.next(),bRecursive));
         return sbResult.toString();
     }

     /**
      * Convert a Telos object to a Telos frame string
      */
     public static String toFrameString(TelosObject to, boolean bRecursive) {
         String result;
         switch( to.getSystemClass() ) {
          case TelosObject.INDIVIDUAL:
              result="Individual "+to.getLabel()+" end\n";
              break;
          case TelosObject.INSTANTIATION:
              result=to.getSource()+" in "+to.getDestination()+" end\n";
              if(bRecursive)
                  result=toFrameString(to.getSource(),true) + toFrameString(to.getDestination(),true) + result;
              break;
          case TelosObject.SPECIALIZATION:
              result=to.getSource()+" isA "+to.getDestination()+" end\n";
              if(bRecursive)
                  result=toFrameString(to.getSource(),true) + toFrameString(to.getDestination(),true) + result;
              break;
          case TelosObject.ATTRIBUTE:
              result=to.getSource().toString() + " with attribute " + to.getLabel() + " : " + to.getDestination().toString() + " end\n";
              if(bRecursive)
                  result=toFrameString(to.getSource(),true) + toFrameString(to.getDestination(),true) + result;
              break;
          default:
              result=null;
              throw new Error();
         }  // switch
         return result;
     }

}  // class Transform


class GetInstantiationTo
implements UnaryFunction
{
    TelosObject toSource;

    GetInstantiationTo( TelosObject toSource )
     {
         this.toSource = toSource;
     }

    public Object execute( Object o )
     {
         return TelosObject.getInstantiation( toSource, (TelosObject) o );
     }
}  // inner class GetInstantiationTo


class GetSpecializationTo
implements UnaryFunction
{
    TelosObject toSource;

    GetSpecializationTo( TelosObject toSource )
     {
         this.toSource = toSource;
     }

    public Object execute( Object o )
     {
         return TelosObject.getSpecialization( toSource, (TelosObject) o );
     }
}  // inner class GetSpecializationTo

