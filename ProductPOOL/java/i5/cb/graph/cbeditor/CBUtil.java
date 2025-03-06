/*
The ConceptBase.cc Copyright

Derived from ConceptBase.cc, originally created by the ConceptBase Team under a FreeBSD-style license.

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
package i5.cb.graph.cbeditor;

import i5.cb.graph.GEConstants;
import i5.cb.graph.GEUtil;
import i5.cb.graph.diagram.*;
import i5.cb.telos.frame.*;
import i5.cb.telos.object.*;
import i5.cb.telos.object.Specialization;

import java.awt.Color;
import java.io.StringReader;
import java.util.*;
import javax.swing.JOptionPane;
import i5.cb.CBConfiguration;

/** Contains static methods for the CBEditor
 *
 *
 * @author schoeneb
 * @created 07 March 2002
 */
public class CBUtil extends GEUtil {

    /**
     * Positions for new diagram objects, relative to current diagram object
     */



    /** Creates several new {@link i5.cb.graph.diagram.DiagramObject} from sTelosObjects
     *
     * @param sTelosFrames The string containing several Telos object names
     * @param cbFrame the CBFrame which handles the connection to the ConceptBase server the new node will belong to
     */

    public static void addNewDiagramObjectsFromTelosEditor(String sTelosFrames, CBFrame cbFrame) {

        if (sTelosFrames != null) {
           String[] parts0 = sTelosFrames.split("}");

           for (String frames1: parts0) {
              String[] parts1 = frames1.split("}");
              for (String frames2: parts1) {
                 String[] parts2 = frames2.split("end");
                 for (String frames3: parts2) {
                    String[] parts3 = frames3.split(" in ");
                    for (String frames4: parts3) {
                      String[] parts4 = frames4.split(" with ");
                      for (String frames5: parts4) {
                         String sTelosObject = frames5.trim();
                         if (sTelosObject != null && !sTelosObject.contains(" ") && !sTelosObject.contains(":") && !sTelosObject.equals("")) {
                           // System.out.println("To display: " + sTelosObject);
                           boolean success = createAndAddNewDiagramObject(sTelosObject,cbFrame,null);
                         }
                      }
                    }
                 }
              }
           }
        } else {
           JOptionPane.showMessageDialog(cbFrame,"No object selected to be added to graph");
        }

    } // addNewDiagramObjectsFromTelosEditor


    /** Creates a new {@link i5.cb.graph.diagram.DiagramObject} which represents a {@link i5.cb.telos.object.TelosObject} and adds it to the {@link i5.cb.graph.DiagramDesktop}.
     *
     * @param sTelosObject The label of the Telosobject that shall be represented by the new node
     * @param cbFrame the CBFrame which handles the connection to the ConceptBase server the new node will belong to
     * @param initialObj the diagramObject the new node will initially be linked to und the DiagramDesktop (may be <CODE>null</CODE>)
     * @return true iff the new node was successfully added to the DiagramDesktop
     */
    public static boolean createAndAddNewDiagramObject(
        String sTelosObject,
        CBFrame cbFrame,
        DiagramNode initialNode) {

        CBQuery query =
            new CBQuery("find_object[" + sTelosObject + "/objname]", cbFrame);
        Collection IndColl = query.ask();
        Iterator it = IndColl.iterator();
                if(IndColl.isEmpty()){
                    return false;
                }
        CBUserObject uo = (CBUserObject) it.next();
                //if Object is Link, create source and destination if needed and add it to the DiagramDesktop
                if(uo instanceof CBLink){
                    //search for source and destination, if they are not found searchDiagramObject, will create them
                    DiagramObject doSrc=searchDiagramObject(uo.getTelosObject().getSource(),cbFrame);
                    DiagramObject doDst=searchDiagramObject(uo.getTelosObject().getDestination(),cbFrame);
                    //create new Diagramnode and Edge
                    DiagramNode dnOnEdge =
                            new DiagramNode(uo, cbFrame.getDiagramClass());
                    DiagramEdge deNew =
                            new DiagramEdge(dnOnEdge, doSrc, doDst, cbFrame.getDiagramClass());

                    Vector vTmp = new Vector(1);
                    vTmp.add(deNew);
                    //add to DiagramDesktop
                    cbFrame.getDiagramDesktop().addDiagramEdges(
                            vTmp,
                            doDst.getNode(),
                            i5.cb.graph.GEConstants.S_POSITION,
                            true);
                }
                // else add individual
                else{
                      createAndAddNewDiagramObject(uo, cbFrame, initialNode);
                }
                return true;
    }
    //createAndAddNewDiagramNode

    /** Creates a new {@link i5.cb.graph.diagram.DiagramObject} which represents a {@link i5.cb.telos.object.TelosObject} and adds it to the {@link i5.cb.graph.DiagramDesktop}.
     *
     * @param to the telosObject to be represented by the new node
     * @param cbFrame the CBFrame which handles the connection to the ConceptBase server the new node will belong to
     * @param initialObj the diagramObject the new node will initially be linked to und the DiagramDesktop (may be <CODE>null</CODE>)
     */
    public static void createAndAddNewDiagramObject(
        CBUserObject uo,
        CBFrame cbFrame,
        DiagramNode initialNode) {

        if (initialNode == null) {
            DiagramNode newDNode = cbFrame.getDiagramClass().getDiagramNode(uo);

            if (newDNode == null) {
                newDNode = new DiagramNode(uo, cbFrame.getDiagramClass());
            }

            cbFrame.getDiagramDesktop().addDiagramNode(newDNode);
            // newly added nodes are marked as selected to facilitate easier relocation by the user:
            cbFrame.getDiagramDesktop().setNodeSelected(newDNode,true,false);


        } else {
            HashSet set = new HashSet();
            set.add(uo);
            createAndAddNewDiagramObjects(set, cbFrame, initialNode);
        }
    }
    //createAndAddNewDiagramNode

    /** Creates new {@link i5.cb.graph.diagram.DiagramObject}s for the CBUserObjects and adds them to the {@link i5.cb.graph.DiagramDesktop}.
     *
     * @param uoColl the collection containing the CBUserObjects to be represented
     * @param cbFrame the CBFrame which handles the connection to the ConceptBase server the new nodes will belong to
     * @param initialNode the diagramNode the new nodes will initially be adjacent to on the DiagramDesktop
     */
    public static void createAndAddNewDiagramObjects(Collection uoColl,CBFrame cbFrame,DiagramNode initialNode) {
        // Create a separate thread for adding
        AddThread th = new AddThread(uoColl, cbFrame, initialNode);

        th.start();

    }

    public static void createAndAddNewDiagramObjects2(
        Collection uos,
        CBFrame cbFrame,
        DiagramNode parentNode) {

        assert(uos.size() > 0);

        Iterator itUO = uos.iterator();
                CBDiagramClass cbDClass = (CBDiagramClass) cbFrame.getDiagramClass();

        //will contain diagramEdges whose source or dest is an element of 'uos'
        Vector vDiagEdges = new Vector(uos.size() * 2);

        //will contain cbUserObjects from 'uos' that are CBLinks as these need a special treatment
        Vector vDiagEdgesWithEdgeAsEndpoint = new Vector();

        CBUserObject currentUO;
        DiagramNode newDNode = null;

        while (itUO.hasNext()) {

            //first we create a DiagramNode if it isn't already present
            currentUO = (CBUserObject) itUO.next();
            newDNode = cbDClass.getDiagramNode(currentUO);

            if (newDNode == null) {
                newDNode = new DiagramNode(currentUO, cbDClass);
            }

            //Now we create the edges between the new Node and the parentnode and add the to the vector
            if (currentUO instanceof CBIndividual) {
                vDiagEdges.addAll(
                    createNewDiagramEdges(newDNode, parentNode, cbFrame, false));
            } else {
                vDiagEdgesWithEdgeAsEndpoint.addAll(
                    createNewDiagramEdges(newDNode, parentNode, cbFrame, false));
            }

        } //while


        int iPos=GEConstants.E_POSITION;
        if(vDiagEdges.size()>0) {
           iPos=findNodePosition((DiagramEdge) vDiagEdges.get(0),parentNode);
        }

        //This adds the diagramEdges as well as all the nodes
        cbFrame.getDiagramDesktop().addDiagramEdges(
            vDiagEdges,
            parentNode,
            iPos,
            true);
        cbFrame.getDiagramDesktop().addDiagramEdges(
            vDiagEdgesWithEdgeAsEndpoint,
            parentNode,
            iPos,
            false);

        Iterator it = vDiagEdgesWithEdgeAsEndpoint.iterator();
        DiagramEdge currentEdge;
        TelosLink tlAtEndOfCurrentTelosLink = null;
        DiagramNode nodeAtEndOfCurrentEdge;
        DiagramNode newSourceNode, newDestNode;
        CBUserObject newSourceUO, newDestUO;
        while (it.hasNext()) {
            currentEdge = (DiagramEdge) it.next();

            nodeAtEndOfCurrentEdge = currentEdge.getPeer(parentNode).getNode();
            TelosObject to =
                ((CBLink) nodeAtEndOfCurrentEdge.getUserObject())
                    .getTelosObject();
            if (to instanceof TelosLink) {
                tlAtEndOfCurrentTelosLink = (TelosLink) to;

                //get SourceUO
                CBQuery query =
                    new CBQuery(
                        "find_object["
                            + tlAtEndOfCurrentTelosLink.getSource().toString()
                            + "/objname]",
                        cbFrame);
                Collection srcDestColl = query.ask();
                Iterator srcDestIt = srcDestColl.iterator();
                newSourceUO = (CBUserObject) srcDestIt.next();
                newSourceNode = cbDClass.getDiagramNode(newSourceUO);
                if (newSourceNode == null) {
                    newSourceNode = new DiagramNode(newSourceUO, cbDClass);
                    cbFrame.getDiagramDesktop().addDiagramNode(
                        newSourceNode,
                        currentEdge.getPeer(parentNode).getNode(),
                        GEUtil.shiftPos(iPos));
                }
                //get DestUO
                query =
                    new CBQuery(
                        "find_object["
                            + tlAtEndOfCurrentTelosLink
                                .getDestination()
                                .toString()
                            + "/objname]",
                        cbFrame);
                srcDestColl = query.ask();
                srcDestIt = srcDestColl.iterator();
                newDestUO = (CBUserObject) srcDestIt.next();
                newDestNode = cbDClass.getDiagramNode(newDestUO);
                if (newDestNode == null) {
                    newDestNode = new DiagramNode(newDestUO, cbDClass);
                    cbFrame.getDiagramDesktop().addDiagramNode(
                        newDestNode,
                        currentEdge.getPeer(parentNode).getNode(),
                        GEUtil.switchPos(GEUtil.shiftPos(iPos)));
                }

                //this adds the new edge that is shown as instance or extension of the edge 'parentNode' lies on
                currentEdge.getPeer(parentNode).getNode().setDiagramEdge(
                    new DiagramEdge(
                        currentEdge.getPeer(parentNode).getNode(),
                        newSourceNode,
                        newDestNode,
                        cbDClass));
            } else {
                //get SourceUO
                CBQuery query =
                    new CBQuery(
                        "find_object[" + to.toString() + "/objname]",
                        cbFrame);
                Collection collObj = query.ask();
                Iterator itObj = collObj.iterator();
                CBUserObject newUO = (CBUserObject) itObj.next();
                DiagramNode newNode = cbDClass.getDiagramNode(newUO);
                if (newNode == null) {
                    newNode = new DiagramNode(newUO, cbDClass);
                    cbFrame.getDiagramDesktop().addDiagramNode(
                        newNode,
                        currentEdge.getPeer(parentNode).getNode(),
                        GEUtil.shiftPos(iPos));
                }
            }
        }
    } //createAndAddNewDiagramObjects2

    private static Vector createNewDiagramEdges(DiagramObject initialDObject,DiagramObject newDObject,CBFrame cbFrame,boolean bBothDirections) {

        assert(initialDObject != null);
        assert(newDObject != null);
        assert(cbFrame != null);

        CBUserObject initialUO = (CBUserObject) initialDObject.getUserObject();
        CBDiagramClass dc = (CBDiagramClass) initialDObject.getDiagramClass();
        HashSet links = initialUO.getEdges();

        //initialUO.getObi().getLinks(initialUO.getTelosObject(), newUO.getTelosObject() );
        Vector vEdges = new Vector();
        if (links == null) {
            return vEdges;
        }
        Iterator itLinks = links.iterator();

        CBUserObject linkObject;
        DiagramEdge newDEdge;
        DiagramNode newDNode;
        while (itLinks.hasNext()) {
            linkObject = (CBUserObject) itLinks.next();
            //It might happen that enLinks contains Individuals, so we check it first
            if (linkObject.getTelosObject() instanceof TelosLink) {
                //linkObject = CBUserObject.getCBUserObject(currentLink, cbFrame,null);

                if (dc.getDiagramNode(linkObject) == null) {
                    newDNode = new DiagramNode(linkObject, dc);
                    //check for reflexive edges
                    if (linkObject.getTelosObject().getSource()
                        != linkObject.getTelosObject().getDestination()) {
                        // check direction of edge: initial object is source
                        if (initialUO.getTelosObject()==linkObject.getTelosObject().getSource())
                            newDEdge =new DiagramEdge(newDNode,initialDObject,newDObject, dc);
                        else // initial object is destination
                            newDEdge =new DiagramEdge(newDNode,newDObject,initialDObject,dc);
                    } else {
                        newDEdge =new DiagramEdge(newDNode,initialDObject, initialDObject,dc);
                    }
                    newDEdge.setPaintShapePolicy(
                        DiagramNode.PAINT_SHAPE_SMALLCOMPONENT);
                    vEdges.add(newDEdge);
                } else {
                    newDEdge = dc.getDiagramNode(linkObject).getDiagramEdge();
                }
            }
        }
        //the new node is reflexive we don't have to run twice
        if (!newDObject.equals(initialDObject)) {
            if (bBothDirections) {
                vEdges.addAll(
                    createNewDiagramEdges(
                        newDObject,
                        initialDObject,
                        cbFrame,
                        false));
            }
        }
        return vEdges;
    } //createNewDiagramEdges

    /** Returns a vector containing all Edges between the two DiagramNodes
     *  @param sourceObject Source of the Edges
     *  @param destObject Destination of the Edges
     *  @return Vector containing the DiagramEdges between the Nodes
     */
    public static Vector createAndAddAllDiagramEdges(
        DiagramObject sourceObject,
        DiagramObject destObject,
        CBFrame cbFrame) {
        Vector vEdges = new Vector();
        CBDiagramClass dc = (CBDiagramClass) sourceObject.getDiagramClass();
        CBUserObject initialUO = (CBUserObject) sourceObject.getUserObject();
        CBUserObject source = (CBUserObject) sourceObject.getUserObject();
        CBUserObject dest = (CBUserObject) destObject.getUserObject();
        //generate Query
        CBQuery query =
            new CBQuery(
                "get_links3["
                    + source.getTelosObject().toString() + "/src,"
                    + dest.getTelosObject().toString() + "/dst,"
                    + cbFrame.getCBEditor().getSessionLinkCategory() + "/cat]",
                cbFrame);
        //ask CB
        Collection edgeColl = query.ask();
        Iterator itLinks = edgeColl.iterator();
        DiagramEdge newDEdge;
        DiagramNode newDNode;
        //loop over all returned Objects
        while (itLinks.hasNext()) {
            CBUserObject linkObject = (CBUserObject) itLinks.next();
            //It might happen that enLinks contains Individuals, so we check it first
            if (linkObject.getTelosObject() instanceof TelosLink) {
                if (dc.getDiagramNode(linkObject) == null) {
                    newDNode = new DiagramNode(linkObject, dc);
                    //check for reflexive edges
                    if (linkObject.getTelosObject().getSource()
                        != linkObject.getTelosObject().getDestination()) {
                        // check direction of edge: initial object is source
                        if (initialUO.getTelosObject()
                            == linkObject.getTelosObject().getSource())
                            newDEdge =
                                new DiagramEdge(
                                    newDNode,
                                    sourceObject,
                                    destObject,
                                    dc);
                        else // initial object is destination
                            newDEdge =
                                new DiagramEdge(
                                    newDNode,
                                    destObject,
                                    sourceObject,
                                    dc);
                    } else {
                        //Edge is reflexive
                        newDEdge =
                            new DiagramEdge(
                                newDNode,
                                sourceObject,
                                sourceObject,
                                dc);
                    }
                    newDEdge.setPaintShapePolicy(
                        DiagramNode.PAINT_SHAPE_SMALLCOMPONENT);
                    vEdges.add(newDEdge);
                } else {
                    newDEdge = dc.getDiagramNode(linkObject).getDiagramEdge();
                }
            }
        }
        return vEdges;
    } //createAndAddAllDiagramEdges



    private static int saveRange(int min, int max, int v) {
       if (v < min)
         return min;
       else if (v > max)
         return max;
       else
         return v;
    }


    public static Color stringToColor(String val) {
        assert(val != null);
        String sLabel = i5.cb.api.CButil.decodeStringIfPossible(val);
        int r = 255;  // to alert that something has gone wrong
        int g = 0;
        int b = 0;
        int alpha = 255;  // default transparency: opaque=not transparent
        try {
          String[] parts = sLabel.split(",");
          r = saveRange(0,255,Integer.parseInt(parts[0]));
          g = saveRange(0,255,Integer.parseInt(parts[1]));
          b = saveRange(0,255,Integer.parseInt(parts[2]));
          if (parts.length == 4)
            alpha = saveRange(0,255,Integer.parseInt(parts[3]));
        }
        catch (Exception e) {
            // Parser with specified options can't be built
            System.out.println("Color string malformed: "+val);
        }
        return new Color(r, g, b, alpha);
    }

    /**
     * Tells if a node shall be placed in the north, south, west or east
     * of an existing "initialObject" depending of its type
     *
     * @param newDiagNode the node we want to place
     * @param initialObject the diagramObject we want to set 'newDiagNode' relative to
     * @return One of N_POSITION, E_POSITION, S_POSITION and W_POSITON as defined in {@link i5.cb.graph.GEConstants}
     */
    public static int findNodePosition(DiagramEdge de, DiagramNode parentNode) {
        TelosObject toLink=((CBUserObject) de.getUserObject()).getTelosObject();
        TelosObject toParent=((CBUserObject) parentNode.getUserObject()).getTelosObject();
        if ((toLink instanceof Instantiation || toLink instanceof Specialization) && toLink.getDestination()==toParent) {
            return GEConstants.S_POSITION;
        }
        else if ((toLink instanceof Instantiation || toLink instanceof Specialization) && toLink.getSource()==toParent) {
            return GEConstants.N_POSITION;
        }
        else if (toLink instanceof Attribute && toLink.getDestination()==toParent)
            return GEConstants.W_POSITION;
        else
            return GEConstants.E_POSITION;
    }

    public static ObjectName parseObjectName(String sName) {
        try {
            TelosParser tp=new TelosParser(new StringReader(sName));
            return tp.objectName();
        } catch (i5.cb.telos.frame.ParseException e) {
            java.util.logging.Logger.getLogger("global").severe(e.getMessage());
        }
        return null;
    }

    public static ObjectNames parseObjectNames(String sNames) {
        try {
            TelosParser tp =
                new TelosParser(new StringReader(sNames));
            return tp.objectNames();
        } catch (i5.cb.telos.frame.ParseException e) {
            java.util.logging.Logger.getLogger("global").severe(e.getMessage());
        }
        return null;
    }

    public static DiagramObject searchDiagramObject(TelosObject to,CBFrame cbFrame){
        Vector diagNodes = cbFrame.getDiagramDesktop().getDiagramNodes();
        Iterator it = diagNodes.iterator();
        //search for the userobject on the DiagramDesktop
        while (it.hasNext()) {
            DiagramNode currentDiagNode = (DiagramNode) it.next();
            if (((CBUserObject)currentDiagNode.getUserObject()).getTelosObject() == to) {
                return currentDiagNode;
            }
        }
        //if object is not on the diagramDesktop ask the CBserver for it and create
        CBQuery query=new CBQuery("find_object[" + to.getLabel() + "/objname]", cbFrame);
        Collection IndColl = query.ask();
        if(!IndColl.isEmpty()){
            it = IndColl.iterator();
            CBUserObject uo = (CBUserObject) it.next();
            DiagramObject dObj = new DiagramNode(uo, cbFrame.getDiagramClass());
            cbFrame.getDiagramDesktop().addDiagramNode((DiagramNode) dObj);
            return dObj;
        }
        return null;
    }

} //CBUtil

class AddThread extends Thread {

    Collection uoObjects;
    CBFrame cbFrame;
    DiagramNode diagNode;

    public AddThread(Collection uoColl, CBFrame cbf, DiagramNode initialNode) {

        uoObjects = uoColl;
        cbFrame = cbf;
        diagNode = initialNode;
        setName("AddThread");
    }

    public void run() {
        CBUtil.createAndAddNewDiagramObjects2(uoObjects, cbFrame, diagNode);
    }

}
