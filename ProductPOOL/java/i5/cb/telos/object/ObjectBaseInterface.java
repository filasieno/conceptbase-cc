/*
The ConceptBase.cc Copyright

Copyright 1987-2019 The ConceptBase Team. All rights reserved.

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
package i5.cb.telos.object;

import i5.cb.api.*;
import i5.cb.telos.Transform;
import i5.cb.telos.frame.*;

import java.io.StringReader;
import java.util.HashMap;
import java.util.List;

/**
 * This implementation of ITelosObjectSet uses a direct connection
 * to a CBserver to retrieve all information which is necessary to answer
 * the questions. Query results may be cached, but the caches are not maintained.
 *
 * @author Christoph Quix
 **/

public class ObjectBaseInterface implements ITelosObjectSet {

    /// inital capacity of the cache
    private static final int INIT_CAPACITY = 50;

    /// The HashMap used to cache queries and their answers
    private HashMap cache = new HashMap(INIT_CAPACITY);

    /// The connection to the CBserver
    protected ICBclient cb;

    /// Cache query results or not (default: true)
    protected boolean bUseCache=true;

    /// Refresh cache query results on retrieval or not (default: true)
    protected boolean bRefreshCache=true;

    /// Set cache usage
    public void setUseCache(boolean b) {
        bUseCache=b;
    }

    /// Get cache usage
    public boolean getUseCache( ) {
        return bUseCache;
    }


    /// Set refreshing of cache
    public void setRefreshCache(boolean b) {
        bRefreshCache=b;
    }

    /// Is refreshing of cache enabled?
    public boolean getRefreshCache( ) {
        return bRefreshCache;
    }

    /**
     * Empty cache. All cached answers are removed from the cache.
     */
    public void emptyCache() {
        cache.clear();
    }

    public ObjectBaseInterface(ICBclient cbc) {
        this.cb=cbc;
    }

    /**
     * Send the query to server.
     * @return the answer as string with the specified answer representation, "null" on error.
     * */
    public String ask(String sQuery, String sAnswerRep) {

        String sKey;

        sKey=sQuery+sAnswerRep;

        if(bUseCache) {
            if(cache.containsKey(sKey)) {
                String result = (String) cache.get(sKey);
                return result;
            }
        }

        try {
            CBanswer ans=cb.askObjNames(sQuery,sAnswerRep,"Now");
            if (ans.getCompletion()==CBanswer.OK) {
                if(bRefreshCache) {
                    cache.put(sKey, ans.getResult());  // update the cache with recently acquired results
                }
                return ans.getResult();
            }
            else
              return null;
        }
        catch(Exception e) {
            System.out.println("Exception: " +e.getMessage());
            return null;
        }
    }



    /**
     * Send the query to server, the answer is returned as a set of frames which are
     * transformed into a set of telos objects.
     * @return the set of telos objects that represents the telos frames, null on error
     * */
    public ITelosObjectSet askFrame(String sQuery) {
        return askFrame(sQuery,false);
    }

    /**
     * Like askFrame(sQuery) but if firstFrameOnly is true, then only the
     * TelosObjects in the first frame will be included in the result.
     */
    public ITelosObjectSet askFrame(String sQuery, boolean firstFrameOnly) {

        String sKey=sQuery + "TOS_FRAME";

        if(bUseCache) {
            if(cache.containsKey(sKey)==true) {
                // Looks strange but double cast is necessary because clone is protected in java.lang.Object
                // and returns a java.lang.Object
                return (ITelosObjectSet) ((ITelosObjectSet)cache.get(sKey)).clone();
            }
        }

        try {
            CBanswer ans=cb.askObjNames(sQuery,"FRAME","Now");

            if (ans.getCompletion()==CBanswer.OK) {
                if(ans.getResult().startsWith("nil"))
                  return TelosObjectSetFactory.produce();

                TelosParser tp=new TelosParser(new StringReader(ans.getResult()));
                TelosFrames tfs=null;
                if(firstFrameOnly) {
                    TelosFrame tfr=tp.telosFrame();
                    tfs=new TelosFrames();
                    tfs.add(tfr);
                }
                else {
                    tfs=tp.telosFrames();
                }
                ITelosObjectSet tos=Transform.toTelosObjectSet(tfs);
                removeUnknownAttributeDestinations(tos);
                if(bRefreshCache) {
                    cache.put(sKey, tos.clone());  // update the cache with recently acquired results
                }
                return tos;
            }
            else
              return null;
        }
        catch(Exception e){
            System.out.println("Exception in ObjectBaseInterface.askFrame( " + sQuery + " ): " + e.getMessage());
            return null;
        }
    }

    /**
     * Send the query to the server, the answer is returned as a set of object names which
     * are transformed into a set of telos objects.
     * @return the set of telos objects that represents the object names, null on error.
     * */
    public ITelosObjectSet askObjname(String sQuery) {
        String sKey=sQuery + "TOS_OBJNAME";

        if(bUseCache) {
            if(cache.containsKey(sKey)==true) {
                // Looks strange but double cast is necessary because clone is protected in java.lang.Object
                // and returns a java.lang.Object
                return (ITelosObjectSet) ((ITelosObjectSet)cache.get(sKey)).clone();
            }

        }
        try {
            CBanswer ans=cb.askObjNames(sQuery,"LABEL","Now");

            if (ans.getCompletion()==CBanswer.OK) {
                if(ans.getResult().startsWith("nil"))
                  return TelosObjectSetFactory.produce();
                TelosParser tp=new TelosParser(new StringReader(ans.getResult()));
                ObjectNames ons=tp.objectNames();
                ITelosObjectSet tos=Transform.toTelosObjectSet(ons);
                removeUnknownAttributeDestinations(tos);
                if(bRefreshCache) {
                    cache.put(sKey, tos.clone());  // update the cache with recently acquired results
                }
                return tos;
            }
            else
              return null;
        }
        catch(Exception e){
            System.out.println("Exception in ObjectBaseInterface.askObjname( " + sQuery + " ): " + e.getMessage());
            return null;
        }
    }

    protected void removeUnknownAttributeDestinations(ITelosObjectSet tos) {

        java.util.Enumeration en=tos.elements();

        while(en.hasMoreElements()) {
            Object obj=en.nextElement();
            if(obj instanceof Attribute) {
                Attribute attr=(Attribute) obj;
                if(attr.getDestination()==null) {
                    tos.remove(attr);
                    TelosObject to=this.getAttribute(attr.getSource(),attr.getLabel());
                    if(to!=null)
                        tos.add(to);
                }
            }
        }
    }


    /**
     * Cloning creates a new ObjectBaseInterface with a new connection to
     * the same CBserver. The cloned object does not have anything in its
     * caches.
     **/
    public Object clone() {
        try {
            return new ObjectBaseInterface(new CBclient(cb.getHostName(),cb.getPort(),cb.getToolName(),cb.getUserName()));
        }
        catch(Exception e) {
            System.out.println("Exception: " +e.getMessage());
            return null;
        }
    }


    /**
     * Calls <code>exists[object/objname]</code>
     * @return  Does <tt>this</tt> contain <tt>object</tt>?
     **/
    public boolean contains( TelosObject object ) {
        String res=ask("exists[" +Transform.toObjectName(object).toString() + "/objname]","FRAME");
        if (res!=null && res.startsWith("yes"))
          return true;
        else
          return false;
    }


    /**
     * Calls <code>COUNT[Proposition/class]</code>
     * @return the size of this set, that is the number of Telos objects
     *    <code>this</code> currently contains
     **/
    public int size() {
        String res=ask("COUNT[Proposition/class]","LABEL");
        return Integer.parseInt(res);
    }


    /**
     * Always false for this implementation.
     **/
    public boolean isEmpty() {
        return false;
    }



    /**
     * This set has more than one member, so the method throws always an exception.
     **/
    public TelosObject getTheOnlyMember() throws Exception {
        throw  new Exception("More than one member in this set");
    }



    /**
     * Transform the objects to Telos frames and tell them to the server.
     *
     **/
    public void add( ITelosObjectSet objects ) {
        if (objects.isEmpty()) return;
        java.util.Enumeration en=objects.elements();
        String result="";
        while(en.hasMoreElements())  {
            TelosObject to=(TelosObject)en.nextElement();
            result=result + Transform.toFrameString(to,true) + "\n";
        }
        try {
            cb.tell(result);
        }
        catch (Exception e) {
            System.out.println("Error: Cannot add objects: "+e.getMessage());
        }
    }

    /**
     * Transform the objects to Telos frames and tell them to the server.
     * This version of add should be preferred as it guarantees to preserve the order
     * of elements.
     *
     **/
    public boolean add( List objects ) throws Exception {
        if (objects.isEmpty()) return true;
        String result=Transform.toFrameString(objects,true);
        CBanswer ans=cb.tell(result);
        if(ans.getCompletion()==CBanswer.OK)
            return true;
        else
            throw new i5.cb.CBException(cb.getErrorMessages());
    }

    /**
     * Transform the objects to Telos frames and delete them in the server.
     **/
    public void remove( ITelosObjectSet objects ) {
        if (objects.isEmpty()) return;
        java.util.Enumeration en=objects.elements();
        String result="";
        while(en.hasMoreElements())  {
            TelosObject to=(TelosObject)en.nextElement();
            result=result + Transform.toFrameString(to,false) + "\n";
        }
        try {
            cb.untell(result);
        }
        catch (Exception e) {
            System.out.println("Error: Cannot remove objects: "+e.getMessage());
        }
    }

    /**
     * Transform the objects to Telos frames and delete them in the server.
     * This version of add should be preferred as it guarantees to preserve the order
     * of elements.
     *
     **/
    public boolean remove( List objects ) throws Exception {
        if (objects.isEmpty()) return true;
        String result=Transform.toFrameString(objects,false);
        CBanswer ans=cb.untell(result);
        if(ans.getCompletion()==CBanswer.OK)
            return true;
        else
            throw new i5.cb.CBException(cb.getErrorMessages());
    }

    /**
     * Removing a single object does not make sense, use remove(ITelosObjectSet) instead
     **/
    public void remove( TelosObject to ) {
        String result=Transform.toFrameString(to,false);
        try {
              cb.untell(result);
        } catch(Exception e)  {
              System.out.println("Error: Cannot remove object: "+e.getMessage());
        }
    }

    /**
     * Adding a single object does not make sense, use add(ITelosObjectSet) instead
     **/
    public void add( TelosObject to ) {
        String result=Transform.toFrameString(to,false);
        try {
              cb.tell(result);
        } catch(Exception e)  {
              System.out.println("Error: Cannot add object: "+e.getMessage());
        }
    }

    public boolean removeAndAdd(List removeObjects, List addObjects) throws Exception {
        if(removeObjects.isEmpty())
            return add(addObjects);
        if(addObjects.isEmpty())
            return remove(removeObjects);

        String sUntell=Transform.toFrameString(removeObjects,false);
        String sTell=Transform.toFrameString(addObjects,true);
        CBanswer ans=cb.retell(sUntell,sTell);
        if(ans.getCompletion()==CBanswer.OK)
            return true;
        else
            throw new i5.cb.CBException(cb.getErrorMessages());
    }


    /**
     * This method is not allowed in ConceptBase.
     **/
    public void clear() {
        // throw new Exception("Method clear not allowed for this Telos object set implementation");
    }


    /**
     * @return the individual with the given label, if present, null otherwise
     **/
    public Individual getIndividual( String sLabel ) {
        ITelosObjectSet tos=askFrame("get_object[" + sLabel + "/objname]");

        if(tos!=null)
          return tos.getIndividual(sLabel);
        else
          return null;
    }

    /**
     * @return the links between src and dst which are instances of cat.
     */
    public ITelosObjectSet getLinks(TelosObject src, TelosObject dst, TelosObject cat) {
        ITelosObjectSet tos=askObjname("get_links3[" + Transform.toObjectName(src).toString() +
            "/src,"+Transform.toObjectName(dst).toString() + "/dst," + Transform.toObjectName(cat).toString() + "/cat]");
        if(tos == null){
        return null;
    }
        java.util.Enumeration en=tos.elements();
        while(en.hasMoreElements()) {
            TelosObject to=(TelosObject) en.nextElement();
            // replace the attributes with unknown destination with correct attributes
            if((to instanceof Attribute) && (to.getDestination()==null)) {
                TelosObject toNew=TelosObject.getAttribute(src,to.getLabel(),dst);
                tos.remove(to);
                tos.add(toNew);
            }
        }
        return tos;
    }

    /**
     * @return all explicit links between src and dst
     */
    public ITelosObjectSet getLinks(TelosObject src, TelosObject dst) {
        ITelosObjectSet tos=askObjname("get_links2[" + Transform.toObjectName(src).toString() +
            "/src,"+Transform.toObjectName(dst).toString() + "/dst]");
          if(tos == null){
        return null;
    }
        java.util.Enumeration en=tos.elements();
        while(en.hasMoreElements()) {
            TelosObject to=(TelosObject) en.nextElement();
            // replace the attributes with unknown destination with correct attributes
            if((to instanceof Attribute) && (to.getDestination()==null)) {
                TelosObject toNew=TelosObject.getAttribute(src,to.getLabel(),dst);
                tos.remove(to);
                tos.add(toNew);
            }
        }
        return tos;
    }


    /**
     * @return the instantiation object with the given source and destination,
     *   if present, null otherwise.
     *   Only explicitly contained instantiation objects, not implicit
     *   relationships (contained in the transitive 'in' closure) are returned.
     **/
    public Instantiation getInstantiation( TelosObject source, TelosObject destination ) {
        ITelosObjectSet tos=askFrame("get_object[" + Transform.toObjectName(source).toString() +
                                     "->" + Transform.toObjectName(destination).toString() + "/objname]");

        if(tos!=null)
          return tos.getInstantiation(source,destination);
        else
          return null;
    }

    /**
     * @return the specialization object with the given source and destination,
     *   if present, null otherwise.
     *   Only explicitly contained specialization objects, not implicit
     *   relationships (contained in the transitive 'isA' closure) are returned.
     **/
    public Specialization getSpecialization( TelosObject source,
                                            TelosObject destination ) {
        ITelosObjectSet tos=askFrame("get_object[" + Transform.toObjectName(source).toString() +
                                     "=>" + Transform.toObjectName(destination).toString() + "/objname]");

        if(tos!=null)
          return tos.getSpecialization(source,destination);
        else
          return null;
    }


    /**
     * @return the attribute object with the given source and label
     **/
    public Attribute getAttribute( TelosObject source, String sLabel ) {
        ITelosObjectSet tos=askFrame("get_object[" + Transform.toObjectName(source).toString() +
                                     "/objname,FALSE/dedIn,FALSE/dedIsa,TRUE/dedWith]");

        //System.out.println("**** TOS in getAttribute ***");
        //java.util.Enumeration en=tos.elements();
        //while(en.hasMoreElements())
        //    System.out.println(en.nextElement());
        if(tos!=null)
          return tos.getAttribute(source,sLabel);
        else
          return null;
    }

    /**
     * @return the object with the given source, label and destination,
     *   if present, null otherwise
     **/
    public TelosObject getObject( TelosObject source, String sLabel,
                                 TelosObject destination ) {

        // Individual
        if(source.getLabel().equals(sLabel) && destination.getLabel().equals(sLabel))
          return getIndividual(sLabel);

        // Instantiation
        if(sLabel.equals(TelosObject.INLABEL))
          return getInstantiation(source,destination);

        // Specialization
        if(sLabel.equals(TelosObject.ISALABEL))
          return getSpecialization(source,destination);

        //Attribute
        TelosObject to=getAttribute(source,sLabel);
        // Check if destinations are identical
        if (Transform.toObjectName(to.getDestination()).toString().equals(Transform.toObjectName(destination).toString()))
          return to;
        else
          return null;
    }


    /////////////////////////////////////////////////////////////////////////////
    // explicit (or direct) relationships:
    /////////////////////////////////////////////////////////////////////////////

    /**
     * @return the instantiation links that go into o
     **/
    public ITelosObjectSet getInstantiationsOf( TelosObject o ) {
        return askObjname("find_incoming_links[" + Transform.toObjectName(o).toString()
                          + "/objname,InstanceOf/category]");
    }

    /**
     * @return the instantiation (classification) links that come out of o
     **/
    public ITelosObjectSet getClassificationsOf( TelosObject o ) {
        return askObjname("find_outgoing_links[" + Transform.toObjectName(o).toString()
                          + "/objname,InstanceOf/category]");
    }

    /**
     * @return the specialization links that go into o
     **/
    public ITelosObjectSet getSpecializationsFrom( TelosObject o ) {
        return askObjname("find_incoming_links[" + Transform.toObjectName(o).toString()
                          + "/objname,IsA/category]");
    }

    /**
     * @return the specialization (generalization) links that come out of o
     **/
    public ITelosObjectSet getGeneralizationsFrom( TelosObject o ) {
        return askObjname("find_outgoing_links[" + Transform.toObjectName(o).toString()
                          + "/objname,IsA/category]");
    }

    public ITelosObjectSet getExplicitAttributesOfCategoryTo(TelosObject o, Attribute cat) {
      return askObjname("find_incoming_links[" + Transform.toObjectName(o).toString()
          + "/objname," + cat + "/category]");      
    }
    
    /**
     * @return the attribute links that come out of o (includes implicit attributes)
     **/
    public ITelosObjectSet getAttributesOf( TelosObject o ) {
        ITelosObjectSet tos=askFrame("get_object[" + Transform.toObjectName(o).toString() + "/objname,FALSE/dedIn,FALSE/dedIsa,TRUE/dedWith]");

        if(tos!=null)
          return tos.getAttributesOf(o);
        else
          return null;
    }

    /**
     * @return only the explicit attribute links that come out of o
     **/
    public ITelosObjectSet getExplicitAttributesOf( TelosObject o ){
     ITelosObjectSet tos=askFrame("get_object[" + Transform.toObjectName(o).toString() + "/objname,FALSE/dedIn,FALSE/dedIsa,FALSE/dedWith]");

        if(tos!=null)
          return tos.getAttributesOf(o);
        else
          return null;
    }


    /**
    * Gets the Individuals the telosObject to refers to via attribute links
    */
    public ITelosObjectSet getExplicitAttributeValuesOf( TelosObject to){
        java.util.Enumeration enAttrs = getAttributesOf(to).elements();
        TelosObjectSetSimpleImpl rv = new TelosObjectSetSimpleImpl();
        while(enAttrs.hasMoreElements() ){
            rv.add( ( (Attribute)enAttrs.nextElement() ).getDestination() );
        }
        return rv;
    }

    /**
     * @return the attribute links that go into o (only explicit attributes)
     **/
    public ITelosObjectSet getAttributesTo( TelosObject o ) {
        ITelosObjectSet tos=askFrame("find_referring_objects[" + Transform.toObjectName(o).toString() + "/class]");

        if(tos!=null)
          return tos.getAttributesTo(o);
        else
          return null;
    }

    /**
    * Gets the Individuals which refer to the telosObject to via attribute links
    */
    public ITelosObjectSet getSourcesOfAttributesTo(TelosObject to){
        java.util.Enumeration enAttrs = getAttributesTo(to).elements();
        TelosObjectSetSimpleImpl rv = new TelosObjectSetSimpleImpl();
        while(enAttrs.hasMoreElements() ){
            rv.add( ( (Attribute)enAttrs.nextElement() ).getSource() );
        }
        return rv;
    }

    /**
     * @return the attribute links that come out of o and are instance
     *   of the given category. In this implementation, explicit attributes
     * and implicit attributes (deduced by rules) are returned.
     **/
    public ITelosObjectSet getAttributesOfCategory( TelosObject o, Attribute attrCategory ) {
        ITelosObjectSet tos=this.getAttributesOf(o);
        java.util.Enumeration en=tos.elements();
        ITelosObjectSet tosResult=TelosObjectSetFactory.produce();

        while(en.hasMoreElements()) {
            TelosObject attr=(TelosObject) en.nextElement();
            String res=this.ask("IS_ATTRIBUTE_OF[" + o.toString() + "/src," +
                                attrCategory.toString() + "/attrCat," +
                                attr.getDestination().toString() + "/dst]","LABEL");
            if(res!=null && res.startsWith("TRUE"))
              tosResult.add(attr);
        }
        return tosResult;
    }


    /**
     * @return the attribute links that come out of o and are instance
     *   of the given category. In this implementation, only explicit attributes
     * and no implicit attributes (deduced by rules) are returned.
     **/
    public ITelosObjectSet getAttributesOfExplicitCategory( TelosObject o,
                                                           Attribute attrCategory ) {
        ITelosObjectSet tos=this.getAttributesOf(o);
        java.util.Enumeration en=tos.elements();
        ITelosObjectSet tosResult=TelosObjectSetFactory.produce();

        while(en.hasMoreElements()) {
            TelosObject attr=(TelosObject) en.nextElement();
            String res=this.ask("IS_EXPLICIT_INSTANCE[" + attr.toString() + "/obj," +
                                attrCategory.toString() + "/class]","LABEL");
            if(res!=null && res.startsWith("TRUE"))
              tosResult.add(attr);
        }
        return tosResult;
    }



    /**
     * @return the single attribute of the given category
     *    that comes out of <code>o</code>, if any. null, if none.
     * @throws Exception if there is more than one attribute of <code>o</code>
     *    with the given category.
     * @see #getAttributesOfCategory
     **/
    public Attribute getSingleAttributeOfCategory( TelosObject o, Attribute attrCategory) throws Exception {
        return (Attribute) getAttributesOfCategory(o,attrCategory).getTheOnlyMember();
    }


    /**
     * @return the attribute of the given category
     *    that comes out of <code>o</code>, if any. null, if none.
     * @throws Exception if there is more than one attribute of <code>o</code>
     *    with the given category.
     * @see #getAttributesOfExplicitCategory
     **/
    public Attribute getSingleAttributeOfExplicitCategory( TelosObject o, Attribute attrCategory )  throws Exception {
        return (Attribute) getAttributesOfExplicitCategory(o,attrCategory).getTheOnlyMember();
    }


    /**
     * @return the links that come out of o
     **/
    public ITelosObjectSet getOutgoingLinksOf( TelosObject o ) {
        return askObjname("find_outgoing_links_simple[" + Transform.toObjectName(o).toString()
                          + "/objname]");
    }

    /**
     * @return the links that go into o
     **/
    public ITelosObjectSet getIncomingLinksOf( TelosObject o ) {
        return askObjname("find_incoming_links_simple[" + Transform.toObjectName(o).toString()
                          + "/objname]");
    }


    /**
     * @return the individuals that are explicitly declared classes of o
     **/
    public ITelosObjectSet getExplicitClassesOf( TelosObject o ) {
        return askObjname("find_explicit_classes[" + Transform.toObjectName(o).toString()
                          + "/objname]");
    }

    /**
     * @return the individuals that are explicitly declared instances of o
     **/
    public ITelosObjectSet getExplicitInstancesOf( TelosObject o ) {
        return askObjname("find_explicit_instances[" + Transform.toObjectName(o).toString()
                          + "/class]");
    }

    /**
     * @return the individuals that are explicitly declared superclasses of o
     **/
    public ITelosObjectSet getExplicitSuperclassesOf( TelosObject o ) {
        return askObjname("find_generalizations[" + Transform.toObjectName(o).toString()
                          + "/class,FALSE/ded]");
    }


    /**
     * @return the individuals that are direct (or explicit) subclasses of o
     **/
    public ITelosObjectSet getExplicitSubclassesOf( TelosObject o ) {
        return askObjname("find_specializations[" + Transform.toObjectName(o).toString()
                          + "/class,FALSE/ded]");
    }


    /////////////////////////////////////////////////////////////////////////////
    // implicit relationships (that respect the transitivity of 'isA'):
    /////////////////////////////////////////////////////////////////////////////

    /**
     * This function returns the transitive closure of (o isA x).
     * @return the individuals that are superclasses of o, even those which are
     *    indirect (or implicit) superclasses.
     **/
    public ITelosObjectSet getAllSuperclassesOf( TelosObject o ) {
        return askObjname("find_generalizations[" + Transform.toObjectName(o).toString()
                          + "/class,TRUE/ded]");
    }

    /**
     * This function returns the transitive closure of (x isA o).
     * @return the individuals that are subclasses of o, even those which are
     *    indirect (or implicit) subclasses.
     **/
    public ITelosObjectSet getAllSubclassesOf( TelosObject o ) {
        return askObjname("find_specializations[" + Transform.toObjectName(o).toString()
                          + "/class,TRUE/ded]");
    }

    /**
     * @return the transitive closure of (result in o)
     **/
    public ITelosObjectSet getAllInstancesOf( TelosObject o ) {
        return askObjname("find_instances[" + Transform.toObjectName(o).toString()
                          + "/class]");
    }

    /**
     * @return the transitive closure of (result in o)
     **/
    public ITelosObjectSet getAllClassesOf( TelosObject o ) {
        return askObjname("find_classes[" + Transform.toObjectName(o).toString()
                          + "/objname]");
    }


    /////////////////////////////////////////////////////////////////////////////
    // predicates:
    /////////////////////////////////////////////////////////////////////////////

    /**
     * o1 is an explicit class of o2, i.e. In_e(o2,o1) is true.
     * */
    public boolean isExplicitClassOf( TelosObject o1, TelosObject o2 ) {
        String res=ask("IS_EXPLICIT_INSTANCE[" + Transform.toObjectName(o2).toString() +
                       "/obj," + Transform.toObjectName(o1).toString() + "/class]","LABEL");
        if(res!=null && res.startsWith("TRUE"))
          return true;
        else
          return false;
    }

    /**
     * o1 is an explicit instance of o2, i.e. In_e(o1,o2) is true.
     * */
    public boolean isExplicitInstanceOf( TelosObject o1, TelosObject o2 ) {
        String res=ask("IS_EXPLICIT_INSTANCE[" + Transform.toObjectName(o1).toString() +
                       "/obj," + Transform.toObjectName(o2).toString() + "/class]","LABEL");
        if(res!=null && res.startsWith("TRUE"))
          return true;
        else
          return false;
    }

    /**
     * o1 is an explicit super class of o2, i.e. Isa_e(o2,o1) is true.
     * */
    public boolean isExplicitSuperclassOf( TelosObject o1, TelosObject o2 ) {
        String res=ask("IS_EXPLICIT_SUBCLASS[" + Transform.toObjectName(o2).toString() +
                       "/sub," + Transform.toObjectName(o1).toString() + "/super]","LABEL");
        if(res!=null && res.startsWith("TRUE"))
          return true;
        else
          return false;
    }


    /**
     * o1 is an explicit sub class of o2, i.e. Isa_e(o1,o2) is true.
     * */
    public boolean isExplicitSubclassOf( TelosObject o1, TelosObject o2 ) {
        String res=ask("IS_EXPLICIT_SUBCLASS[" + Transform.toObjectName(o1).toString() +
                       "/sub," + Transform.toObjectName(o2).toString() + "/super]","LABEL");
        if(res!=null && res.startsWith("TRUE"))
          return true;
        else
          return false;
    }

    /**
     * @return o1 isA o2 ?
     **/
    public boolean isA( TelosObject o1, TelosObject o2 ) {
        String res=ask("ISSUBCLASS[" + Transform.toObjectName(o1).toString() +
                       "/sub," + Transform.toObjectName(o2).toString() + "/super]","LABEL");
        if(res!=null && res.startsWith("TRUE"))
          return true;
        else
          return false;
    }

    /**
     * @return o1 in o2 ?
     **/
    public boolean in( TelosObject o1, TelosObject o2 ) {
        assert (o1 !=null) && (o2 != null) : "ObjectBaseInterface.in: Neither o1 nor o2 may be null!";
        String res=ask("ISINSTANCE[" + Transform.toObjectName(o1).toString() +
                       "/obj," + Transform.toObjectName(o2).toString() + "/class]","LABEL");
        if(res!=null && res.startsWith("TRUE"))
          return true;
        else
          return false;
    }

    /**
     * Not useful for this implementation.
     * @return enumeration of all contained objects
     **/
    public java.util.Enumeration elements() {
        return null;
    }

    /**
     * Not useful for this implementation.
     * @return enumeration of all contained objects
     **/
    public java.util.Enumeration sortedElements() {
        return null;
    }


    /**
     * Not useful for this implementation.
     * @return proposition representation, like "P(oid,src,label,dest)"
     **/
    public String asPropositions() {
        return null;
    }
    /**
     * returns the CBClient of this Interface
     * @return The CBClient of this Interface
     **/
    public ICBclient getCBClient()
    {
        return cb;
    }
}



