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


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
/*
 * Created on 24.11.2004
 */
package i5.cb.graph.layout;

import i5.cb.graph.cbeditor.CBUserObject;
import i5.cb.graph.diagram.DiagramObject;

import java.util.List;

import att.grappa.*;

/**
 * This class is a graph that supports layout algorithm. It adds several
 * attributes setter/getter methods to set and get attribute values for layout
 * algorithm. It also contains a so called "Configuration" graph that provides
 * median structure for the algorithm.
 * 
 * @author Li, Yong
 * 
 * @version 1.0
 */
public class LayoutGraph extends Graph {
    /**
     * Handle DiagramNode/Edge attribute
     * 
     * @author Li, Yong
     * 
     * @version 1.0
     * @see att.grappa.AttributeHandler
     */
    protected static class AttrHandler implements AttributeHandler {

        /*
         * (non-Javadoc)
         * 
         * @see att.grappa.AttributeHandler#convertValue(int, java.lang.String,
         *      java.lang.Object, int)
         */
        public String convertValue(int elemType, String name, Object value,
                int convType) {
            if (convType == DIAGRAMOBJECT_TYPE) {
                // DiagramObject value
                String label = ((CBUserObject) ((DiagramObject) value)
                        .getUserObject()).getTelosObject().getLabel();
                return "node: " + label;
            } else if (convType == BOOLEAN_TYPE) {
                // Boolean value
                return value.toString();
            } else if (convType == LIST_TYPE) {
                // List value
                return String.valueOf(((List) value).size());
            }
            return null;
        }

        /*
         * (non-Javadoc)
         * 
         * @see att.grappa.AttributeHandler#convertStringValue(int,
         *      java.lang.String, java.lang.String, int)
         */
        public Object convertStringValue(int elemType, String name,
                String stringValue, int convType) {
            // need not support this function
            return null;
        }

        /*
         * (non-Javadoc)
         * 
         * @see att.grappa.AttributeHandler#copyValue(int, java.lang.String,
         *      java.lang.Object, int)
         */
        public Object copyValue(int elemType, String name, Object value,
                int convType) {
            return value;
        }

    }

    /**
     * attribute key for bind diagramNode/Edge to the grappa Node
     */
    public static final String DIAGRAM_OBJECT = "object";

    /**
     * attribute key for node's rank
     */
    public static final String NODE_RANK = "noderank";

    /**
     * attribute key for node's previous rank
     */
    public static final String NODE_PRERANK = "nodeprerank";

    /**
     * attribute key for node's sequence within the rank
     */
    public static final String NODE_ORDER = "nodeorder";

    /**
     * attribute key for node's width
     */
    public static final String NODE_WIDTH = GrappaConstants.WIDTH_ATTR;

    /**
     * attribute key for node's height
     */
    public static final String NODE_HEIGHT = GrappaConstants.HEIGHT_ATTR;

    /**
     * attribute key for node's position
     */
    public static final String NODE_POSITION = GrappaConstants.POS_ATTR;

    /**
     * attribute key for specifing whether the node is fixed
     */
    public static final String NODE_FIXED = "nodefixed";

    /**
     * attribute key for specifing whether the node is dummy
     */
    public static final String NODE_DUMMY = "nodedummy";

    /**
     * attribute key for specifing whether the node is new
     */
    public static final String NODE_NEW = "nodenew";

    /**
     * attribute key for edge's path
     */
    public static final String EDGE_PATH = "edgepath";

    /**
     * attribute key for "dummy node chain" of edge
     */
    public static final String EDGE_CHAIN = "edgechain";

    /**
     * attribute key for specifing whether the edge is new
     */
    public static final String EDGE_NEW = "edgenew";

    /**
     * attribute key for specifing whether the edge is in the dummy chain
     */
    public static final String EDGE_DUMMY = "edgedummy";
    
    /**
     * attribute key for new node state
     */
    public static final String IS_NODE_SHOWN = "isnewnode";

    /**
     * conversion key for DiagramObject value
     */
    public static final int DIAGRAMOBJECT_TYPE = -1;

    /**
     * conversion key for Boolean value
     */
    public static final int BOOLEAN_TYPE = -2;

    /**
     * conversion key for List value
     */
    public static final int LIST_TYPE = -3;
    
    

    /**
     * @param graphName
     */
    public LayoutGraph(String graphName) {
        this(graphName, true, false);
    }

    /**
     * @param graphName
     * @param directed
     * @param strict
     */
    public LayoutGraph(String graphName, boolean directed, boolean strict) {
        super(graphName, directed, strict);
        Element.setUserAttributeType(NODE_RANK, GrappaConstants.INTEGER_TYPE);
        Element
                .setUserAttributeType(NODE_PRERANK,
                        GrappaConstants.INTEGER_TYPE);
        Element.setUserAttributeType(NODE_ORDER, GrappaConstants.INTEGER_TYPE);
        Element.setUserAttributeType(NODE_FIXED, BOOLEAN_TYPE);
        Element.setUserAttributeType(NODE_DUMMY, BOOLEAN_TYPE);
        Element.setUserAttributeType(NODE_NEW, BOOLEAN_TYPE);
        Element.setUserAttributeType(EDGE_NEW, BOOLEAN_TYPE);
        Element.setUserAttributeType(EDGE_DUMMY, BOOLEAN_TYPE);
        Element.setUserAttributeType(DIAGRAM_OBJECT, DIAGRAMOBJECT_TYPE);
        Element.setUserAttributeType(EDGE_CHAIN, LIST_TYPE);
        Element.setUserAttributeType(EDGE_PATH, LIST_TYPE);
        Element.setUserAttributeType(IS_NODE_SHOWN,BOOLEAN_TYPE);
        att.grappa.Attribute.setAttributeHandler(new AttrHandler());
    }

}
