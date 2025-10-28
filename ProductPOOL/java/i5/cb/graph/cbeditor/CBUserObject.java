/*
The ConceptBase.cc Copyright

Copyright 1987-2025 The ConceptBase Team. All rights reserved.

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

import i5.cb.graph.cbeditor.components.CBComponent;
import i5.cb.graph.cbeditor.components.CBTree;
import i5.cb.graph.diagram.DiagramLabel;
import i5.cb.graph.diagram.DiagramNode;
import i5.cb.graph.shapes.IGraphShape;
import i5.cb.graph.shapes.GraphShapePolygon;
import i5.cb.graph.shapes.PolygonShape;
import i5.cb.telos.object.ObjectBaseInterface;
import i5.cb.telos.object.*;
import i5.cb.graph.DiagramDesktop;

import java.awt.*;
import java.util.*;

import javax.swing.*;

/** This is the basic class of the {@link i5.cb.graph.diagram.DiagramObject}'s userobjects in the CBEditor-application
 *
 *
 * @author Schoeneb
 */
abstract public class CBUserObject {

    private CBFrame m_cbFrame;
    private TelosObject toObject;

    private CBTree m_queryTree;

    private HashSet m_edges;

    /** True if this CBUserObject can still be retrieved from conceptBase.
     * This memeber is to be set be reValidate() only
     */
    private boolean m_bValid;

    protected Map mapProperties=new HashMap();

    /** Utility field used by bound properties. */
    private java.beans.PropertyChangeSupport propertyChangeSupport =  new java.beans.PropertyChangeSupport(this);

    /** Returns a the object name of the telos object
     * @return a String representing this object
     */
    public String toString() {
        return toObject.toString();
    }

    /** Returns this userobject's telosobject
     * @return returns the telosobject this userobject wraps around
     */
    public TelosObject getTelosObject() {
        return toObject;
    }

    /**
     * Set the telos object of this user object
     */
    void setTelosObject(TelosObject to) {
        toObject=to;
    }

    /** Returns this object's CBFrame
     * @return the CBFrame handling the connection to the ConceptBase server the telosobject-member comes from
     */
    public CBFrame getCBFrame() {
        return m_cbFrame;
    }

    /**
     * Set the CBFrame where this object is shown
     */
    void setCBFrame(CBFrame cbf) {
        m_cbFrame=cbf;
    }

    /**
     * Returns the DiagramObject for this user object
     */
    public DiagramNode getDiagramNode() {
        return getCBFrame().getDiagramClass().getDiagramNode(this);
    }

    /** Returns this objects {@link i5.cb.telos.object.ObjectBaseInterface}.
     * The obi is actually a member of the CBFrame
     * @return the objectbaseinterface handling this object's connection
     */
    public ObjectBaseInterface getObi() {
        return m_cbFrame.getObi();
    }

    /** This method tells if this object and the object 'o' are equal.
     * If o is also a CBUserObject it compares the both telosobject members and the graphtypes of the objects,
     * i.e. two CBUserObjects are identical if they represent the same TelosObject and have the same graphical type.
     * This method is necessary to prevent the application from creating more than one userobject (and therefore more than one diagramObject)
     * for one telosobject.
     *
     * @param o an <code>Object</code> value telling which object is to be compared with us
     * @return a <code>boolean</code> value. true if our to member is equal to o, false otherwise
     */
    public boolean equals(Object o) {
        if(this == o)
            return true;
        if (o instanceof CBUserObject) {
            CBUserObject other=(CBUserObject)o;
            if(getTelosObject().equals(other.getTelosObject())) {
                String sKey = "**" + this.toString();
                if (m_cbFrame.getPropertiesOfGraphicalTypes().containsKey(sKey))
                    return false;  // ticket #397: if there are some gproperties, then the two objects are regarded not equal
                if(getProperty("GraphType") == null && other.getProperty("GraphType") == null)
                    return true;
                if(getProperty("GraphType") != null && other.getProperty("GraphType") != null &&
                   getProperty("GraphType").equals(other.getProperty("GraphType")))
                    return true;
            }
        }
        return false;
    }

    /** Returns the hashcode of our {@link #toObject} member.
     *  Therefore two different CBUserObjects having the same telosObject are seen as the same
     *
     * @return the telosObject's (<B>not</B> the cbUserObject's) hashcode)
     */
    public int hashCode() {
        if (toObject != null)
            return toObject.hashCode();
        else
            return super.hashCode();
    }

    /**
     * Set a property of this user object. Properties can be defined in
     * ConceptBase by attaching attributes of the category "property" to
     * the JavaGraphicalType. The properties will be stored in a Map (@see java.util.Map)
     * and can be retrieved by using getProperty.
     */
    public void setProperty(String property, String value) {
        mapProperties.put(property,value);
    }

    /**
     * Get a property of this graphical type.
     */
    public String getProperty(String property) {
        return (String) mapProperties.get(property);
    }

    /**
     * Return true if the property is defined for this object
     */
    public boolean hasProperty(String property) {
        return mapProperties.containsKey(property);
    }

    // for debugging purposes
    private void printProperties() {
        System.out.println("\nProperties of " + this.toString() + ":");
        Set<String> keys = mapProperties.keySet();
        for (String key: keys) {
            System.out.println(key + "=" + getProperty(key) ); 
        }
    }

    /** Get the CB User object for the given TelosObject that will be shown
     * in the CBFrame. This method will set GraphicalType for the telos object,
     * and create an instantiation of the specified class.
     * The GraphicalType depends also on a the GraphicalPalette which is defined
     * in the CBFrame. This method will also initialise the properties-map, so
     * that the properties of this object can be retrieved by "getProperty".
     * This method will not ask ConceptBase, it retrieves the implementation and
     * graphical types from the HashMaps in CBFrame containing these informations.
     * To make this functioning one must call loadGraphicalPaletteAndImplementation()
     * in CBFrame and CBQuery.ask() to retrieve the graphicalTypes of the objects.
     * @param to The TelosObject for which the CBUserObject should be created
     * @param cbf The CBFrame in which the Object will be displayed
     * @param graphTypesOfObjects The graphicalTypes of Objects returned in the
     * CBQuery which returned the set containing the TelosObject.
     */
    public static CBUserObject getCBUserObject(TelosObject to,CBFrame cbf,HashMap graphTypesOfObjects) {
        CBDiagramClass dc = (CBDiagramClass)cbf.getDiagramClass();
        HashMap graphTypeProperties;
        HashMap implementation;
        String currentType=null;
        CBGraphTypePropertySet gtProperties=null;
        String implby;
        java.util.HashSet en;
        // Check whether we have already created a user object for this telos object
        CBUserObject cbuo=dc.getCBUserObject(to);
        String objname = to.toString();  // name of the TelosOject to
// System.out.println("CBUO: handling: "+objname);
        if(cbuo!=null) {
            java.util.logging.Logger.getLogger("global").fine("Found UserObject for " + objname);
            return cbuo;
        }
        //collect neccessary information to build the userobject
        graphTypeProperties=cbf.getPropertiesOfGraphicalTypes();
        implementation=cbf.getImplementingClasses();

        if(graphTypesOfObjects==null) {
            //TODO
            implby=null;
            cbuo=null;
        }
        else {
            //get the graphtype of the current TelosObject, this was read in from xml and is just a String
            //the complete information is encapsuled in graphTypeProperties
            currentType=(String) graphTypesOfObjects.get(objname);
            //get the sets of all Properties and the implementing classe of currentType
            gtProperties=(CBGraphTypePropertySet) graphTypeProperties.get(currentType);
            implby=(String) implementation.get(currentType);
        }

        // ticket #410: support user-defined graphical types for deduced/derived/implicit links
        boolean isDerived = false;
        if (to instanceof Attribute) {
         Attribute attr = (Attribute) to;
         isDerived = attr.isImplicit();
        }
        if (implby==null && isDerived) {
          String candType = "ImplicitGT_"+to.getLabel();
          CBGraphTypePropertySet cGtProperties = (CBGraphTypePropertySet) cbf.getPropertiesOfGraphicalTypes().get(candType);
          if (cGtProperties != null) {
             gtProperties=cGtProperties;
             currentType = candType;
             implby=(String) implementation.get(currentType);
          }
        }


        // Now, set the properties of the CBUserObject
        if(implby!=null) {
            if (!implby.contains(".cbeditor."))
               implby = "i5.cb.graph.cbeditor." + implby;
            try {
                Class cls=Class.forName(implby);
                Object obj=cls.newInstance();
                if(obj instanceof CBUserObject) {
                    cbuo=(CBUserObject) obj;
                    cbuo.setTelosObject(to);
                    cbuo.setCBFrame(cbf);
                }
                else {
                    java.util.logging.Logger.getLogger("global").warning("The class " + implby + " is not an extension of i5.cb.graph.cbeditor.CBUserObject\n" +
                    "Therefore, the default graphical type will be used");
                }
            }
            catch(Exception e) {
                java.util.logging.Logger.getLogger("global").fine("Exception while creating user object: " + e.getMessage());
            }
        }
        // Something with the query did not work (i.e. there is no graphical type for the object)
        // return the default graphical type
        if(cbuo==null) {
            HashMap defaultTypes=cbf.getDefaultGraphTypes();
//            java.util.logging.Logger.getLogger("global").warning("GraphicalType for " + objname + " not found, using default!");
            try{
                currentType=(String)defaultTypes.get(to.getSystemClassName());
                //get the default implementing class for individuals
                implby=(String) implementation.get(currentType);
                Class cls=Class.forName(implby);
                Object obj=cls.newInstance();
                if(obj instanceof CBUserObject) {
                    cbuo=(CBUserObject) obj;
                    cbuo.setTelosObject(to);
                    cbuo.setCBFrame(cbf);
                    gtProperties=(CBGraphTypePropertySet) graphTypeProperties.get(currentType);
                }
                else {
                    java.util.logging.Logger.getLogger("global").severe("The default class " + implby + " is not an extension of i5.cb.graph.cbeditor.CBUserObject");
                    return null;
                }
            }
            catch(Exception e) {
                java.util.logging.Logger.getLogger("global").fine("Exception while creating user object: " + e.getMessage());
                return null;
            }
        }
        //Save GraphType for saving
        cbuo.setProperty("GraphType",currentType);

 // System.out.println("CBUO: graphtype("+cbuo.toString()+")="+currentType);

        // Set properties of cbuo from its graphtype properties
        if(gtProperties!=null) {
            en=gtProperties.getProperties();
            java.util.Iterator iterator=en.iterator();
            while(iterator.hasNext()) {
                CBGraphTypeProperty prCurrent=(CBGraphTypeProperty) iterator.next();
                String sLabel=prCurrent.getName();
                cbuo.setProperty(sLabel,prCurrent.getValue());
            }
        }

        // Ticket #397
        // Set properties of cbuo from its object-specific graphical properties
        // these setting then overrule/augment the settings via the graphtype properties
        // The "**" is prepended to the objname to avoid collusions with entries for regular graphtypes
        gtProperties=(CBGraphTypePropertySet) graphTypeProperties.get("**"+objname);  // set in CBQuery, "gproperty" tag
 //System.out.println("CBUO getGTproperties of "+objname+"="+gtProperties);
        if(gtProperties!=null) {
            en=gtProperties.getProperties();
            java.util.Iterator iterator=en.iterator();
            while(iterator.hasNext()) {
                CBGraphTypeProperty prCurrent=(CBGraphTypeProperty) iterator.next();
                String sLabel=prCurrent.getName();
                cbuo.setProperty(sLabel,prCurrent.getValue());
//System.out.println(cbuo.toString() + ": " + sLabel+"="+prCurrent.getValue());
            }
        }


        cbuo.setQueryTree(new CBTree(cbuo) );
        cbuo.setValid(true);
        dc.putCBUserObject(to,cbuo);
        cbuo.setEdges(new HashSet());
        return cbuo;
    }

    public CBTree getQueryTree() {
        return m_queryTree;
    }

    public void setQueryTree(CBTree queryTree) {
        m_queryTree = queryTree;
    }


    public void setEdges(HashSet edges) {
        m_edges=edges;
        //java.util.logging.Logger.getLogger("global").fine(this.toString()+edges.toString());
    }

    public HashSet getEdges() {
        return m_edges;
    }


    // insert blanks before uppercase for better rendering of labels like DesignObjectType
    private static String insertBlanksBeforeUpperCase(String str) {
        if (str.length()>0) 
          return str;
        if (str.charAt(0)=='"' || str.charAt(0)=='$')  // leave Telos strings and assertions unchanged
          return str;

        StringBuilder sb = new StringBuilder();
        sb.append(str.charAt(0));

        char lastchar = '-'; 
        for (int i=1; i<str.length(); i++) {  // ignore the first char
           char c = str.charAt(i);
           if (Character.isUpperCase(c) && Character.isLowerCase(lastchar) && lastchar != ' ') {
              sb.append(' ');
           }
           sb.append(c);
           lastchar = c;
        }
        return sb.toString();
    }
    /**
     * Return the small component for this user object.
     */
    public Component getSmallComponent() {
        boolean fixedsizeset = false;  // when "size" is set to a fixed dimension like 80x20
        Font fontSC = null;
        DiagramLabel smallComponent;

        // ticket #399: labellength can be defined as gproperty
        int labellength = 40;
        if(hasProperty("labellength") ) {
          try {
            labellength = Integer.parseInt(getProperty("labellength"));
          } catch (NumberFormatException e) {}
        }

        String sLabel = toObject.getLabel();
        if(hasProperty("label") ) {
            sLabel = getProperty("label");
        }

        boolean wrapLabel = false;
        boolean replaceUnderScore = false;
        if (hasProperty("size")) {
           wrapLabel =  getProperty("size").equals("wrap") || getProperty("size").equals("wrap_");
           replaceUnderScore = getProperty("size").equals("wrap_");
        }
        if (sLabel.length()>labellength) {
           sLabel=sLabel.substring(0,labellength-4) + " ...";
        }
        if (replaceUnderScore) {
          sLabel = sLabel.replaceAll("_"," ");
        } else if (wrapLabel) {
          sLabel = insertBlanksBeforeUpperCase(sLabel);
        }
        if (wrapLabel) {
           sLabel="<html><p>" + sLabel.replaceAll("<","&lt;").replaceAll("\\[","<").replaceAll("\\]",">") + "</p></html>";
        }
        smallComponent = new DiagramLabel( sLabel );


        String fontName = smallComponent.getFont().getName();
        int fontSize = smallComponent.getFont().getSize();
        int fontStyle = smallComponent.getFont().getStyle();

        if(hasProperty("font")) {
            fontName = getProperty("font");
        }
        if(hasProperty("fontsize") ) {
            fontSize = Integer.parseInt(getProperty("fontsize") );
        }
        if(hasProperty("fontstyle") ) {
            String sFontStyle = getProperty("fontstyle");
            if(sFontStyle.equals("italic")) {
                fontStyle = Font.ITALIC;
            }
            if(sFontStyle.equals("bold")) {
                fontStyle = Font.BOLD;
            }
            if(sFontStyle.equals("bold,italic")) {
                fontStyle = Font.BOLD + Font.ITALIC;
            }
        }

        fontSC = new Font(fontName, fontStyle, fontSize);
        smallComponent.setFont(fontSC);


        Dimension dSC = smallComponent.getMinimumSize(); 
        String shapeName = "noShape";
        if ( hasProperty("shape") ) {
          shapeName = getProperty("shape");
        }

        // nodes that have special shapes need adapted dimensions for the label
        dSC = adaptSmallComponentSize(dSC,shapeName);

        smallComponent.setMinimumSize(dSC);
        smallComponent.setPreferredSize(dSC);
        smallComponent.setSize(dSC);
        smallComponent.setHorizontalAlignment(SwingConstants.CENTER);
        smallComponent.setVerticalAlignment(SwingConstants.CENTER);

        // for nodes on edges that have an empty label:
        // a little dot is used to represent the small component for the node on the edge
        if(smallComponent.getText().length()==0) {
            int dotSize;
            String dotColorString; 
            String edgeColorString = getProperty("edgecolor"); 
            if (hasProperty("bgcolor") && hasProperty("edgewidth")) {  // define the dot depending on edgewidth and bgcolor
              dotColorString = getProperty("bgcolor");
              if (dotColorString.equals(edgeColorString)) 
                dotSize = Math.round(Float.parseFloat(getProperty("edgewidth"))) + 4;
              else // a little smaller if the color of the dot is different from the edge color
                dotSize = Math.round(Float.parseFloat(getProperty("edgewidth"))) + 3; 
            } else { // default
              dotSize = 6;
              dotColorString = edgeColorString;
            }
            smallComponent.setMinimumSize(new Dimension(dotSize,dotSize));
            smallComponent.setSize(new Dimension(dotSize,dotSize));
            smallComponent.setPreferredSize(new Dimension(dotSize,dotSize));
            smallComponent.setBackground(CBUtil.stringToColor(dotColorString));
            smallComponent.setOpaque(false);   // will be set to true by DiagramNode.setSquareDot
        }
        else {
            // set background color of Label to have a correct printout
            // setOpaque for label is done in DiagramDesktop.print
            if(hasProperty("bgcolor"))
                smallComponent.setBackground(CBUtil.stringToColor(getProperty("bgcolor")));
            else
                smallComponent.setBackground(Color.white);

            // Set labels opaque which have a background color but no shape
            if(hasProperty("bgcolor") && !hasProperty("shape"))
                smallComponent.setOpaque(true);
        }


        if(hasProperty("align")) {
            String property = getProperty("align");
            if(property.equals("center") ) {
                smallComponent.setHorizontalAlignment(SwingConstants.CENTER);
                smallComponent.setVerticalAlignment(SwingConstants.CENTER);
            }
            if(property.equals("left") ) {
                smallComponent.setHorizontalAlignment(SwingConstants.LEFT);
                smallComponent.setVerticalAlignment(SwingConstants.CENTER);
            }
            if(property.equals("right") ) {
                smallComponent.setHorizontalAlignment(SwingConstants.RIGHT);
                smallComponent.setVerticalAlignment(SwingConstants.CENTER);
            }

            if(property.equals("top") ) {
                smallComponent.setHorizontalAlignment(SwingConstants.CENTER);
                smallComponent.setVerticalAlignment(SwingConstants.TOP);
                // some additional margin between smallComponent text and the shape around it
                smallComponent.setBorder(BorderFactory.createEmptyBorder(2 /*top margin*/,0 /*left margin*/,0,0));
            }
            if(property.equals("bottom") ) {
                smallComponent.setHorizontalAlignment(SwingConstants.CENTER);
                smallComponent.setVerticalAlignment(SwingConstants.BOTTOM );
            }

            if(property.equals("topleft") ) {
                smallComponent.setHorizontalAlignment(SwingConstants.LEFT);
                smallComponent.setVerticalAlignment(SwingConstants.TOP);
                // some additional margin between smallComponent text and the shape around it
                smallComponent.setBorder(BorderFactory.createEmptyBorder(4 /*top margin*/,4 /*left margin*/,0,0));
            }
            if(property.equals("topright") ) {
                smallComponent.setHorizontalAlignment(SwingConstants.RIGHT);
                smallComponent.setVerticalAlignment(SwingConstants.TOP );
            }
            if(property.equals("bottomleft") ) {
                smallComponent.setHorizontalAlignment(SwingConstants.LEFT);
                smallComponent.setVerticalAlignment(SwingConstants.BOTTOM);
            }
            if(property.equals("bottomright") ) {
                smallComponent.setHorizontalAlignment(SwingConstants.RIGHT);
                smallComponent.setVerticalAlignment(SwingConstants.BOTTOM);
            }
        }


        if(hasProperty("textcolor") ) {
            smallComponent.setForeground(CBUtil.stringToColor(getProperty("textcolor") ) );
        }

        if(hasProperty("size") ) {
            String size = getProperty("size");
            int width = 0;
            int height = 0;
            try{
              width = Integer.parseInt(size.split("x")[0]);
              height = Integer.parseInt(size.split("x")[1]);
              fixedsizeset = true;
            } catch (Exception e) {
              if (!size.equals("resizable") && !size.startsWith("wrap"))
                 System.err.println("Value for size property should be a dimension like \"20x30\" or \"resizable\"");
              // nothing to be done here; we allow also values like "resizable", see DiagramNode
            }

            if (size.equals("wrap")) {
               dSC = getHTMLPreferredSize(sLabel,true,200,fontSC);  // true: width preset, 200: preferred width
               smallComponent.setSize(dSC);
               smallComponent.setPreferredSize(dSC);
            } else if (!size.equals("resizable")) {
               if(width==0)
                   width=80;
               if(height==0)
                   height=25;
               dSC = new Dimension(width,height);
               smallComponent.setMinimumSize(dSC);
               smallComponent.setSize(dSC);
               smallComponent.setPreferredSize(dSC);
            }
        }

        // allow to set nodes (and nodes on edges) to frozen status via graphtype property "freeze"; ticket #426
        if(hasProperty("freeze") ) {
            String freeze = getProperty("freeze");
            DiagramNode dn = getDiagramNode();
            if (dn != null) {
               if (freeze.equals("yes")) {
                  dn.setFrozen(true);
               } else if (freeze.equals("yes")) {
                  dn.setFrozen(false);
               }
            }
        }

        // allow to set node's designated location; ticket #426
        if(hasProperty("location") ) {
            String location = getProperty("location");
            Point p = new Point(60,60);
            boolean designated = false;
            try{
              p.x = Integer.parseInt(location.split(",")[0]);
              p.y = Integer.parseInt(location.split(",")[1]);
              designated = true;
            } catch (Exception e) {
                System.err.println("Value for location should be like \"50,80\"");
            }
            DiagramNode dn = getDiagramNode();
            if (dn != null && designated) {
              dn.designateLocation(p);
            }
        }


        if(hasProperty("image") ){
            int iconwidth = 0;
            int iconheight = 0;
            int icongap = 2;  // gap between the image icon an the label text
            Dimension d = smallComponent.getPreferredSize();

            String imageFilename = getProperty("image");
            imageFilename = DiagramDesktop.getImageUrl(imageFilename);  // expand relative image filename to a URL

            try {
                java.net.URL url = new java.net.URL(imageFilename);
                Image image = Toolkit.getDefaultToolkit().getImage( url);
                ImageIcon iicon =  new ImageIcon(image);
                smallComponent.setIcon(iicon);
                smallComponent.setIconTextGap(icongap); // default 4
                iconwidth = iicon.getIconWidth();
                iconheight = iicon.getIconHeight();
            } catch (java.net.MalformedURLException urlE) {
                java.util.logging.Logger.getLogger("global").warning("The URL provided by property 'image' is malformed or could not be opened");
                java.util.logging.Logger.getLogger("global").fine(urlE.getMessage() );
                if (m_cbFrame != null)
                   m_cbFrame.setStatusString("Failed to load image from "+imageFilename);
            }
            smallComponent.setHorizontalAlignment(SwingConstants.CENTER);

            // the relative position of the label text to the image icon has an influence of the size of the 
            // small component
            if(hasProperty("textposition")) {
                String property = getProperty("textposition");
                if(property.equals("center") ) {
                    smallComponent.setVerticalTextPosition(SwingConstants.CENTER);
                    smallComponent.setHorizontalTextPosition(SwingConstants.CENTER);
                    if (!fixedsizeset)
                      smallComponent.setPreferredSize(new Dimension(Math.max(iconwidth,d.width),Math.max(d.height,iconheight)));
                }
                if(property.equals("left") ) {
                    smallComponent.setVerticalTextPosition(SwingConstants.CENTER);
                    smallComponent.setHorizontalTextPosition(SwingConstants.LEFT);
                    if (!fixedsizeset) {
                       if (d.height >= iconheight)
                         smallComponent.setPreferredSize(new Dimension(d.width+iconwidth+icongap,d.height));
                       else
                         smallComponent.setPreferredSize(new Dimension(d.width+iconwidth+icongap,iconheight));
                    }
                }
                if(property.equals("right") ) {
                    smallComponent.setVerticalTextPosition(SwingConstants.CENTER);
                    smallComponent.setHorizontalTextPosition(SwingConstants.RIGHT);
                    if (!fixedsizeset) {
                       if (d.height >= iconheight)
                         smallComponent.setPreferredSize(new Dimension(d.width+iconwidth+icongap,d.height));
                       else
                         smallComponent.setPreferredSize(new Dimension(d.width+iconwidth+icongap,iconheight));
                    }
                }
                if(property.equals("top") ) {
                    smallComponent.setVerticalTextPosition(SwingConstants.TOP);
                    smallComponent.setHorizontalTextPosition(SwingConstants.CENTER);
                    if (!fixedsizeset) {
                       if (d.width >= iconwidth)
                         smallComponent.setPreferredSize(new Dimension(d.width,d.height+iconheight+icongap));
                       else
                         smallComponent.setPreferredSize(new Dimension(iconwidth,d.height+iconheight+icongap));
                    }
                }
                if(property.equals("bottom") ) {
                    smallComponent.setVerticalTextPosition(SwingConstants.BOTTOM);
                    smallComponent.setHorizontalTextPosition(SwingConstants.CENTER);
                    if (!fixedsizeset) {
                       if (d.width >= iconwidth)
                         smallComponent.setPreferredSize(new Dimension(d.width,d.height+iconheight+icongap));
                       else
                         smallComponent.setPreferredSize(new Dimension(iconwidth,d.height+iconheight+icongap));
                    }
                }

            } else { // default position of the small components text to the icon image
                smallComponent.setVerticalTextPosition(SwingConstants.BOTTOM);
                smallComponent.setHorizontalTextPosition(SwingConstants.CENTER);
                if (!fixedsizeset) {
                   if (d.width >= iconwidth)
                     smallComponent.setPreferredSize(new Dimension(d.width,d.height+iconheight+icongap));
                   else
                     smallComponent.setPreferredSize(new Dimension(iconwidth,d.height+iconheight+icongap));
                }
            }
            smallComponent.setAlignmentX(0.5f);
            smallComponent.setAlignmentY(0.5f);

        }  // if(hasProperty("image") ) 

       // make a circle shape if requested
        if ( !fixedsizeset &&
             hasProperty("shape") &&
             getProperty("shape").equals("i5.cb.graph.shapes.Circle") ) {
          Dimension d = smallComponent.getPreferredSize();
          if (d.width > d.height)
            smallComponent.setPreferredSize(new Dimension(d.width,d.width));
          else
            smallComponent.setPreferredSize(new Dimension(d.height,d.height));
        }


        return smallComponent;
    }


    /** Compute the location to place the small component inside the diagram node of this CBUserObject
     * depending on its "align" property. We also consider the "align" property for 
     * getSmallComponent by that is aligning the text labels position inside the small component.
     * Since the small component typically is much smaller than the containing node, we
     * have to consider the "align property also for setting the location of the small component
     * inside the node's dimension.
     * This method is used by DiagramNode.resizeComponents().
     *
     * @param nodeSize the dimension of the node that contains the small component for this CBUserObject
     * @param componentSize the dimension of the (small= component for this CBUserObject
     * @return the proposed start location of the small component inside the node
     */

    public Point getAlignedLocation(Dimension nodeSize, Dimension componentSize) {
    
        int x = 0;
        int y = 0;
        final int borderDist = 2; // preferred distance to the node border

        if (nodeSize == null || componentSize == null ||
            nodeSize.width <= componentSize.width+2*borderDist ||
            nodeSize.height <= componentSize.height+2*borderDist)
          return new Point(x,y);

        // aligned to center by default
        if (!hasProperty("align"))
          return new Point(nodeSize.width/2 - componentSize.width/2,
                           nodeSize.height/2 - componentSize.height/2);

        if (hasProperty("align")) {
            String property = getProperty("align");
            if (property.equals("center") ) {
               x = nodeSize.width/2 - componentSize.width/2;
               y = nodeSize.height/2 - componentSize.height/2;
            }
            if (property.equals("left") ) {
               x = borderDist;
               y = nodeSize.height/2 - componentSize.height/2;

            }
            if (property.equals("right") ) {
               x = nodeSize.width - componentSize.width - 2 * borderDist;
               y = nodeSize.height/2 - componentSize.height/2;
            }
            if (property.equals("top") ) {
               x = nodeSize.width/2 - componentSize.width/2;
               y = borderDist;
            }
            if (property.equals("bottom") ) {
               x = nodeSize.width/2 - componentSize.width/2;
               y = nodeSize.height - componentSize.height - 2 * borderDist;
            }
            if (property.equals("topleft") ) {
               x = borderDist;
               y = borderDist;
            }
            if (property.equals("topright") ) {
               x = nodeSize.width - componentSize.width - 2 * borderDist;
               y = borderDist;

            }
            if(property.equals("bottomleft") ) {
               x = borderDist;
               y = nodeSize.height - componentSize.height - 2 * borderDist;
            }
            if(property.equals("bottomright") ) {
               x = nodeSize.width - componentSize.width - 2 * borderDist;
               y = nodeSize.height - componentSize.height - 2 * borderDist;
            }
        }
        return new Point(x,y);
    }





    /**
     * Return the main component for this user object. This component
     * is used when the small component is not shown. To be compatible
     * with the graph editor which is implemented in JFC/Swing, the component
     * should be a subclass of JComponent.
     * This method may return null, but then getSmallComponent must return a value.
     */
    public Component getComponent() {
        return new CBComponent( m_cbFrame.getDiagramClass().getDiagramNode(this), this);
    }

    /**
     * Return the shape for this user object.
     */
    public Shape getShape() {
        Shape s = null;
        if(!hasProperty("shape"))
            return null;

        try {
            String shapestring = getProperty("shape");
            if (shapestring.startsWith("PolygonShape;")) {
             String[] parts = shapestring.split(";");
             s = (Shape)createPolygonShape(parts);
            } else {
              if (!shapestring.contains(".shapes."))
                shapestring = "i5.cb.graph.shapes." + shapestring;
              Class shapeClass = Class.forName(shapestring);
              s = (Shape)shapeClass.newInstance();
            }

            if(hasProperty("bgcolor")) {
                ((IGraphShape) s).setFillColor(CBUtil.stringToColor(getProperty("bgcolor")));
            }
            if(hasProperty("linecolor")) {
                ((IGraphShape) s).setOutlineColor(CBUtil.stringToColor(getProperty("linecolor")));
            }
            if(hasProperty("linewidth")) {
                ((IGraphShape) s).setLineWidth(Float.parseFloat(getProperty("linewidth")));
            }
        }
        catch(ClassNotFoundException ce) {
            java.util.logging.Logger.getLogger("global").fine("CBDiagramClass.getShape: while trying to get shape '"+getProperty("shape")+"' ClassNotFoundException: "+ce.getMessage());
            return null;
        }
        catch( InstantiationException ie) {
            java.util.logging.Logger.getLogger("global").fine("CBDiagramClass.getShape: InstantiationException: "+ie.getMessage());
        }
        catch( IllegalAccessException iae) {
            java.util.logging.Logger.getLogger("global").fine("CBDiagramClass.getShape: IllegalAccessException: "+iae.getMessage());
        }
        return s;
    }


    private PolygonShape createPolygonShape(String[] parts) {
      if (parts.length != 3)
        return null;
      if (!parts[0].equals("PolygonShape"))
        return null;
      String[] xstrings = parts[1].split(",");
      String[] ystrings = parts[2].split(",");
      if (xstrings.length != ystrings.length)
        return null;
      int[] xpoints = new int[xstrings.length];
      int[] ypoints = new int[ystrings.length];
      for (int i=0; i < xpoints.length; i++) {
        try {
          xpoints[i] = Integer.parseInt(xstrings[i].trim());
        } catch (NumberFormatException e) {
          xpoints[i] = 0;
        }
        try {
          ypoints[i] = Integer.parseInt(ystrings[i].trim());
        } catch (NumberFormatException e) {
          ypoints[i] = 0;
        }
      }
      return new PolygonShape(xpoints,ypoints);
    }


    /**
     * Return the popup menu for this user object.
     */
    public JPopupMenu getPopupMenu() {
        return new CBPopup( getDiagramNode() );
    }

    public void addEdge(CBUserObject newEdge){
        m_edges.add(newEdge);
    }


/*
    static Set getAllTelosObjects(){
    return mapUserObjects.keySet();
    }
  */

     /** Adds a PropertyChangeListener to the listener list.
      * @param l The listener to add.
      */
     public void addPropertyChangeListener(java.beans.PropertyChangeListener l) {
         propertyChangeSupport.addPropertyChangeListener(l);
     }

     /** Removes a PropertyChangeListener from the listener list.
      * @param l The listener to remove.
      */
     public void removePropertyChangeListener(java.beans.PropertyChangeListener l) {
         propertyChangeSupport.removePropertyChangeListener(l);
     }

     /** Getter for property valid.
      * @return Value of property valid.
      */
     public boolean isValid() {
        return m_bValid;
     }


     /** Check whether this user object is defined as resizable by its graphical type.
      *  It is sufficient that the siye property is defined. An object with a defined size like "20x20"
      *  is also treated as resizable.
      * @return true if the user object is resizable, else false
      */
     public boolean isResizable() {
        if ( this.hasProperty("size") ) 
           return true;
        else
           return false;
     }



     /** Setter for property valid. Also sets the valid properties of its diagramNode.
      *
      * @param valid New value of property valid.
      */
     public void setValid(boolean valid) {
         boolean oldValid = m_bValid;

         //If this cbUSerObject belongs to an DiagramNode, the node is also set valid or invalid
         if( (m_cbFrame != null) && (m_cbFrame.getDiagramClass().getDiagramNode(this) != null) ){
            java.util.logging.Logger.getLogger("global").fine("In CBUSerObject '"+getTelosObject().toString()+"': setting my diagnode valid: "+valid);
             m_cbFrame.getDiagramClass().getDiagramNode(this).setValid(valid);
         }
         m_bValid = valid;

         //java.util.logging.Logger.getLogger("global").fine("In CBUSerObject '"+getTelosObject().getLabel()+"': setting me valid: "+valid);
         CBDiagramClass dc = (CBDiagramClass)m_cbFrame.getDiagramClass();
         if (!valid){
               dc.removeCBUserObject(this.getTelosObject() );

               // issue #57: getDiagramNode() could be null when executing DiagramDesktop.removeInvalidNodes()
               if (this.getDiagramNode() != null)
                 m_cbFrame.addObjectToAdd(this.getDiagramNode().getDiagramClass().getHashtableEntry(this) );

         }else if(!dc.containsCBUserObject(this) ){
            dc.putCBUserObject(this.getTelosObject(), this);
         }
         propertyChangeSupport.firePropertyChange("valid", new Boolean(oldValid), new Boolean(m_bValid));
     }


     /**
      * This method is called when the user has clicked on the "Commit" button.
      * Changes that have been made within this component (e.g. within a form) can
      * then be added to the list of objects to be removed/added from the database.
      */
     public boolean doCommit() {
         return true;
     }


     /**
      * This method is called when a diagram node is clicked once; if the corresponding CBUserObject
      * has a "clickaction" value, then this shall be asked a query to the CBserver using the object's
      * name as single argument.
      *  @param dd
      *     the DiagramDesktop that contains the node with this CBUserObject
      *  @param dn
      *     the DiagramNode that received the click
      *  @return true if a click action was performed
      */
     public boolean clickAction(DiagramDesktop dd, DiagramNode dn) {

         if (toObject == null)
            return false;  // no Telos object for this CBUserObject
         if(!hasProperty("clickaction"))
            return false;  // this CBUserObject has no clickaction from its graph type
         if (!(dd.getGraphInternalFrame() instanceof CBFrame))
            return false;  // we are not linked to a CBserver



         String clickactionString = getProperty("clickaction");

         boolean checkAllNodes = true;
         if (clickactionString.contains("-")) {
           String[] parts = clickactionString.split("-");
           clickactionString = parts[0];
           if (parts.length==2 && parts[1].equals("n"))
             checkAllNodes = false;  // if a '-n' is used in the clickaction string, then we check only neighborhood of dn
         }

         String clickaction = clickactionString;
         int argnr = 1;  // number of arguments of the clickaction query
         if (clickactionString.contains("/")) {
           String[] parts = clickactionString.split("/");
           clickaction = parts[0];
           if (parts.length==2 && parts[1].equals("0"))
              argnr = 0;
           else if (parts.length==2 && parts[1].equals("2"))
              argnr = 2;
         }

         CBFrame cbf = (CBFrame) dd.getGraphInternalFrame();
         // System.out.println("calling " + clickactionString + " on " + toObject.toString());
         String ans;
         clickaction = clickaction.trim();
         if (argnr == 0)
            ans = cbf.getObi().ask(clickaction,"LABEL");
         else if (argnr == 1)
            ans = cbf.getObi().ask(clickaction+"["+toObject.toString()+"]","LABEL");
         else if (argnr == 2) {
            String username = System.getProperty("user.name");
            ans = cbf.getObi().ask(clickaction+"["+username+","+toObject.toString()+"]","LABEL");
         }
         //System.out.println("Answer is: "+ans);
         if (checkAllNodes)
           cbf.validateNodes();
         else
           cbf.validateNodes(dd.getNeighborhood(dn));
         dd.repaint();
         return true;
     }





     /*
      CBUserObject getCBUserObject(TelosObject key){

    return ((CBDiagramClass)m_cbFrame.getDiagramClass() ).getCBUserObject(key);
     }

     public void removeCBUserObject(CBUserObject cbUO) {
        ((CBDiagramClass)m_cbFrame.getDiagramClass() ).removeCBUserObject(cbUO.getTelosObject());

     }
     */



     /** enlarge the dimension for a small component depending on its shape. 
         For example, a Diamond shape is very narrow left and right so that the
         label of the small component overlaps with the border of the diamond. By making it larger,
         we take care for more readable nopde layouts
      * @param dim The old dimension of the component
      * @param shapeName The name of the shape, e.g. "i5.cb.graph.shapes.Ellipse"
      */

    protected Dimension adaptSmallComponentSize(Dimension dim, String shapeName) {
      int nwidth;
      int nheight;


// printProperties();   // for debugging, to show the graph properties of this user object

      if (shapeName.endsWith("Rect") ||
          shapeName.endsWith("Circle")) {
         nwidth = dim.width;
         nheight = dim.height;
      }
      else if (shapeName.endsWith("ArrowL") ||
               shapeName.endsWith("ArrowR")) {
         nwidth = dim.width + 2 ;
         nheight = dim.height + 4;
      }
      else if (shapeName.endsWith("Star")) {
         nwidth = dim.width + 2 ;
         nheight = dim.height + 4;
      }
      else if (shapeName.endsWith("TriangleL") ||
               shapeName.endsWith("TriangleR")) {
         nwidth = dim.width + 2 ;
         nheight = dim.height + 2;
      }
      else if (shapeName.endsWith("Cross")) {
         nwidth = dim.width + 4 ;
         nheight = dim.height + 4;
      } if (shapeName.endsWith("noShape")) {   // for diagram labels that have no shape at all, e.g. edge labels
         nwidth = dim.width - 2 ;
         nheight = dim.height - 4;
      }
      else {
         nwidth = dim.width + 4 ;
         nheight = dim.height + 2;
      }

      // thick linewidth requires to increase the small components size as well
      // 2023-02-08: gproperty linewidth is not assigned yet to 'this'  CBUserObject when adaptSmallComponentSize is called

      if (this.hasProperty("linewidth")) {
        int sc_linewidth = (int) Float.parseFloat(getProperty("linewidth"));
        if (sc_linewidth>2) {
          nwidth = nwidth + sc_linewidth; // line sits centered on the border (?)
          nheight = nheight + sc_linewidth;
        }
      }


     return new Dimension(nwidth,nheight);
    }



    // Code adapted from code by Morten Nobel-Jorgensen (IT Univ. of Copenhagen)
    /**Returns the preferred size to set a component at in order to render
     * an html string.  You can specify the size of one dimension.*/
    public static java.awt.Dimension getHTMLPreferredSize(String html,
                                                      boolean width, int prefSize, Font font) {

        JLabel resizer = new JLabel();
 
        resizer.setText(html);  // non-default font size not taken into account here
        if (font != null)
           resizer.setFont(font);
 
        javax.swing.text.View view = (javax.swing.text.View) resizer.getClientProperty(
                javax.swing.plaf.basic.BasicHTML.propertyKey);
 
        view.setSize(width?prefSize:0,width?0:prefSize);
 
        float w = view.getPreferredSpan(javax.swing.text.View.X_AXIS);
        float h = view.getPreferredSpan(javax.swing.text.View.Y_AXIS);
 
        return new java.awt.Dimension((int) Math.ceil(w),
                (int) Math.ceil(h));
    }




}//CBUserObject

