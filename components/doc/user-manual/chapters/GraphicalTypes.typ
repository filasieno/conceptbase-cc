= Graphical Types
<cha:graph-typen>
The concept of a _graphical type_ enables the specification of an
external graphical presentation for ConceptBase objects. The graphical
type is declared using a special pre-defined attribute category. An
application program then uses this information to determine the
graphical presentation of an object.

The next subsection introduces the basic concepts behind graphical
types, while section @GTsforGB presents the standard graphical type
definitions for the ConceptBase Graph Editor. Section @GTsCust describes
the definition of application-specific types.

== The graphical type model
<the-graphical-type-model>
A specific graphical type is defined as an instance of the object
`GraphicalType`. CBGraph uses the subclass `JavaGraphicalType`.
Instances of this class specify a graphical representation of an object
by defining graphical attributes such as shape, color, line thickness,
font etc. Since the actual attributes and their admissible value depend
on the used visualization tool, the definition of `GraphicalType` looks
very simple.

```
GraphicalType in Class
end
JavaGraphicalType isA GraphicalType 
end
```

The declaration of a graphical type for a concrete object is done by
using the attribute `graphtype` which is defined for `Proposition` and
therefore available for all objects:

```
Proposition with
  attribute
     graphtype : GraphicalType
end
```

The attribute can be defined explicitely for an object or can be
specified by using a deductive rule (see section @GTsforGB for an
example). One can attach a priority value to each graphical type. If
there multiple graphtype attributes defined for one object, the
graphical type with the highest priority value will be used by CBGraph.

Many modeling applications require multiple notations to provide
different perspectives on the same set of objects. Each perspective
emphasizes a specific aspect of the world, such as the data-oriented,
the process-oriented and the behavior-oriented viewpoint, and uses an
aspect-specific notation. A graphical notation (as e.g. the
Entity-Relationship diagram) typically consists of a set of different
graphical symbols (as e.g. diamonds, rectangles, and lines). A
_graphical palette_ is used to combine the set of graphical types
that together form a notation. Note that CBGraph uses
`JavaGraphicalPalette` instead of the less expressive
`GraphicalPalette`.

```
Individual GraphicalPalette in Class with
  attribute
     contains : GraphicalType;
     default : GraphicalType
end
JavaGraphicalPalette in Class isA GraphicalPalette 
end 
```

In such a setting the same object may participate in different
perspectives. ConceptBase offers the possibility to specify multiple
graphical types for the same object. A tool can then provide different
graphical views on the same object. To get the desired graphical type of
an object under a specific palette, an application program specifies the
name of the actual graphical palette as answer format when querying the
ConceptBase server. Although this mechanism is available for arbitrary
application programs we restrict our description to the CBGraph Editor.

The `default` specification serves as a catch all: an answer object, for
which none of the graphical types of the current palette is specified,
is presented using the default graphical type of that palette.

== The standard graphical types
<GTsforGB>
CBGraph is implemented using the Java Programming Language. It is
entirely based on the Swing toolkit (package javax.swing). The graphical
objects shown in CBGraph are all instances of the class JComponent in
the javax.swing package. User-defined representations of objects can be
provided by overwriting a specific class of CBGraph (details are given
below).

=== The extended graphical type model
<the-extended-graphical-type-model>
Based on our experience with a legacy graph browser for X11, we have
extended the graphical type model for the CBGraph Editor. First, the
class `GraphicalType` has been specialized by a class
`JavaGraphicalType`:

```
Class JavaGraphicalType isA GraphicalType with
 attribute
   implementedBy : String;
   property : String;
   priority : Integer
 rule
   rPriority : $ forall jgt/JavaGraphicalType (not (exists i/Integer
                 A_e(jgt,priority,i))) ==> A(jgt,priority,0) $
end

Individual DefaultIndividualGT in JavaGraphicalType with
  property
     bgcolor : "210,210,210";
     textcolor : "0,0,0";
     linecolor : "0,0,0";
     shape : "i5.cb.graph.shapes.Rect"
  implementedBy
     implBy : "i5.cb.graph.cbeditor.CBIndividual"
end
```

The object `DefaultIndividualGT` is an example for the instantiation of
a graphical type. The attribute `implementedBy` specifies the full name
of the Java class that provides the implementation for this graphical
type. This class has to be a sub class of
`"i5.cb.graph.cbeditor.CBUserObject"`. The `property` attribute
specifies name-value pairs which will be used by the Java implementation
to set certain properties, e.g. color, shape, font#footnote[Colors are
given as RGB color value, e.g.~210,210,210 is light grey and 0,0,0 is
black.];. The priority value is used to resolve ambiguity if multiple
graphical types apply to one object. The graphical type with the highest
priority will be used. The rule specifies a default value of 0 for the
priority.

The graphical palette has also been extended. There are now defaults for
different types of objects, and graphical types for implicit links can
be defined. Thus, the `default` attribute defined in `GraphicalPalette`
will not be used anymore. The `contains` attribute has still to be used,
i.e.~a graphical type will only be used if it is also contained in the
current graphical palette. Although the attributes are not declared as
`single` and `necessary`, each graphical palette should have exactly one
value for the each of the default and implicit attributes.

```
Class JavaGraphicalPalette isA GraphicalPalette with
  attribute
     defaultIndividual : JavaGraphicalType;
     defaultLink : JavaGraphicalType;
     implicitIsA : JavaGraphicalType;
     implicitInstanceOf : JavaGraphicalType;
     implicitAttribute : JavaGraphicalType;
     palproperty : String
end
```

`JavaGraphicalPalette` offer categories for the `defaultIndividual`
graphical type (specifies how nodes are displayed by default) and
`defaultLink` (default graphical type for links). The four implicit
graphical types are for specifying how derived attributes (derived
specializations, derived instantiations) are visualized in CBGraph. The
attribute `palproperty` is used for declaring any number of properties
of a palette. The properties are passed to the CBGraph Editor when it
loads the palette at startup time. CBGraph supports the following
properties for palettes:

/ bgcolor\:: #block[
sets the background color of the windows that displays the graph; format
should be `"r,g,b"`, e.g. `"255,255,255"` for white
]

/ bgimage\:: #block[
sets the background image for the graph windows; the image shall be
specified by the URL to a PNG, GIF, or JPG image; it is scaled by the
CBGraph editor to fit into the internal window showing a graph of this
palette
]

/ longtitle\:: #block[
used for setting the title of the graph windows employing this palette;
if no long title is specified, then CBGraph uses the name of the palette
itself for forming the window title; if the longtitle is set to the
empty string \"\", then it will cause CBGraph not to include it in the
title of the graph windows
]

The purpose of the background image is to highlight regions of a graph,
e.g. regions for instances, classes, and meta classes. Another typical
use is to support canvasses like the business model canvas
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/d3595098/bmg-egadget.png")
used in the Telos models described in the CB-Forum at
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/d3595098/");.
Only \"http\" URLs are supported.

If a background image is specified for a palette shown in an internal
window of CBGraph, then CBGraph links it with the size and zoom factor
of the internal window. Initially, the zoom factor is set to 100% and
the internal window size is set to display the image in its original
resulution, provided that it fits well to the screen size. You can then
resize the internal window and the background image shall be resized
accordingly. Analogously, the image is resized when the zoom factor
changes. The background image is also stored in the GEL file, see
section `sec:cbgraphcmd`.

=== Default graphical types
<sec:defaultgraphtypes>
For the standard objects, there are a number of predefined graphical
types. There are contained in the graphical palette `DefaultJavaPalette`
which is used by default by the CBGraph Editor.

#block[
#block[
ll *type of object* & *graphical type* & *style* \
Individuals & DefaultIndividualGT & gray box \
Links & DefaultLinkGT & thin black line with label \
InstanceOf & DefaultInstanceOfGT & green line without label \
IsA & DefaultIsAGT & blue line without label; white edge heads \
Attribute & DefaultAttributeGT & black line with label \
Class & ClassGT & turquoise box \
SimpleClass & SimpleClassGT & pink oval \
MetaClass & MetaClassGT & light blue oval \
MetametaClass & MetametaGT & bright green oval \
QueryClass & QueryClassGT & red oval \
Derived In & ImplicitInstanceOfGT & dashed green line \
Derived IsA & ImplicitIsAGT & dashed blue line; white edge heads \
Derived Attribute & ImplicitAttributeGT & dashed black line \

]
]
The object `DefaultJavaPalette` has also some rules which define the
default relationship between objects and graphical types, e.g.~all
instances of `Class` have the graphical type `ClassGT`.

If you want to customize the graphical types for your model, then you
must define the new graphical types (see below) and then add them to a
new graphical palette as instance of `JavaGraphicalPalette`. Take the
default graphical palette as a starting point since you may want to
reuse some of the existing graphical types. See file `03-ERD-GTs.sml` at
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/188651") for
an example.

Starting from ConceptBase 8.2, we provide an alternative graphical
palette `TelosPalette`, which is closer to the style of UML class
diagrams and allows for easy specialization when creating user-defined
palettes. See section `telospalette` for more information.

```
BMG_Palette in JavaGraphicalPalette isA TelosPalette with
  palproperty
    bgimage: "http://conceptbase.sourceforge.net/CBICONS/bgimages/bmgcolor.png"; 
    longtitle: "Business Model"
  contains
    bmg1: Customer_GT;
    bmg2: Revenue_GT;
    bmg3: CustomerRelationship_GT;
    bmg4: Channel_GT;
    ...
end
```

== Customizing the graphical types
<GTsCust>
To support the user in defining his own graphical types we provide some
examples and documentation of the properties.

There are two ways to customize the graphical types:

- Defining new graphical types with dedicated graphical properties
  properties using the provided implementations \
  i5.cb.graph.cbeditor.CBIndividual (for nodes) and
  i5.cb.graph.cbeditor.CBLink (for links)

- Defining new graphical types with a different implementation class
  which extends \
  i5.cb.graph.cbeditor.CBUserObject (or CBIndividual or CBLink); this
  option requires changes to the Java source code of CBGraph

Both possibilities will presented in the next two subsections.

=== Graphical properties of nodes and links
<sec:graph-props>
The easiest way to modify the representation of an object in the CBGraph
Editor is to load an existing graphical type, modify its properties and
store it as a new graphical type.

The properties available and there meaning are given in the following.
Note that colors have to be given as RGB color value, e.g. \"0,0,0\" is
black, \"255,0,0\" is red, \"255,255,255\" is white, etc. Furthermore,
all attributes have to be strings, even if they are just numbers,
e.g.~use \"1\" instead of 1 as attribute value.

/ bgcolor\:: #block[
Background color of the shape (default: invisible).
]

/ textcolor\:: #block[
Foreground color of the shape (i.e. text color) (default: black
\"0,0,0\").
]

/ linecolor\:: #block[
Color of the border of the shape (default: invisible).
]

/ linewidth\:: #block[
Width of the border of the shape (default: \"1\").
]

/ edgecolor\:: #block[
Color of the edge (default: black \"0,0,0\"); for CBLink only.
]

/ edgeheadcolor\:: #block[
Color of the edge head; the edge head is drawn in edge color if no edge
head color is defined; for CBLink only.
]

/ edgeheadshape\:: #block[
Shape of the edge head at the destination side. If set to \"none\", then
the edge head has no shape. Possible other values are listed in the
table below; for CBLink only.
]

/ edgewidth\:: #block[
Width of the edge (default: \"1\"); for CBLink only.
]

/ edgestyle\:: #block[
possible values are: \"continuous\", \"dashed\", \"dotted\",
\"dashdotted\", \"ldashed\" (dashed with longer intervals), \"ldotted\"
(default: \"continuous\"); for CBLink only.
]

/ shape\:: #block[
The name of the class representing the shape and implementing the
interface `i5.cb.graph.shape.IGraphShape` (default: no shape). The
package `i5.cb.graph.shape` defines some useful default shapes, see
below for details. The shape will be drawn in the background of the
small component. In the default implementation, the small component is a
transparent JLabel, thus the shape is completely visible. Note, that
this might not be the case if you are going to change the implementation
of a graphical type (see subsection `sec:shapes` below).
]

/ image\:: #block[
The location (URL) of an image icon file that shall be used to display a
node (CBIndividual) The image tag is a replacement for the shape
attribute but can also be combined with a shape. The image icon can be
in PNG, GIF, or JPG format. See subsection `sec:icons` for more details.
]

/ textposition\:: #block[
Relative position of the node's text label to the image icon. This
property is only evaluated if a graphical type defines an image icon.
Possible values are \"center\", \"left\", \"right\", \"top\", and
\"bottom\" (default).
]

/ label\:: #block[
The label to be used for this object instead of the object name.
]

/ labellength\:: #block[
The maximum number of characters displayed as label of an object in
CBGraph (default: \"40\"). A label that exceeds the length is truncated
to the maximum length and the last four characters are replaced by \"
...\" in the display in CBGraph.
]

/ align\:: #block[
Alignment of the label; possible values are \"center\", \"left\",
\"right\", \"top\", \"bottom\", \"topleft\", \"topright\",
\"bottomleft\", and \"bottomright\"; default is \"center\".
]

/ size\:: #block[
Initial size of the node in pixels, e.g. \"20x20\"; the non-numeric
values \"resizable\" (node size can be resized) and \"wrap\" (node size
can be resized and label will be wrapped) are allowed as well. The value
\"wrap\_\" works like \"wrap\" but shall also replace \"\_\" in the node
label by a blank. If the value is \"wrap\", then each uppercase
character except the first character will have an extra preceding blank.
This allows to handle very long labels in combinantion with the
labellength property. If the size property is set, the user can also
resize the element via mouse actions (default: undefined, then the size
is set by CBGraph).
]

/ location\:: #block[
Designate the initial location of a node or the label of an edge. The
value shall be in the format \"x,y\". For example, the value \"10,100\"
has the x coordinate 10 and the y coordinate 100. This property may be
useful when certain nodes should have a given initial location, e.g. for
canvas nodes that contain other nodes. (default: undefined, then the
location is set by CBGraph).
]

/ freeze\:: #block[
The value \"yes\" indicates that the node (or the edge label) is fixed
to its current location in the graph editor. The value \"no\" (default)
indicates that the node can be freely moved. You can set this flag also
via the \"gproperty\" attribute individually for each object (see
section `gproperty`).
]

/ nodelevel\:: #block[
The level of the node relative to the standard node layer (=200) in the
graph's diagram. Negative values put the node more in the background,
positive values more in the foreground. Use this feature if you want to
put certain nodes on top of each other (default: \"0\").
]

/ font\:: #block[
Name of the font to be used for the shape (e.g., \"Arial\", default:
Default font of Java).
]

/ fontsize\:: #block[
Size of the font in pixels (default: default font size of Java).
]

/ fontstyle\:: #block[
The style of the font (e.g., \"bold\", \"italic\", \"underlined\",
\"bold,italic\", ... ).
]

/ clickaction\:: #block[
The name of a query class that shall be called directly when an object
with this graphical type is clicked. See section `sec:clickactions` for
details.
]

Edges with empty label (_anonymous_ edge) are displayed with a
square dot in the middle of the edge #footnote[An empty label is a label
equal to `""`. Such labels only work for edges. If you want to display
an node with an empty label, then set the label to `" "` (one blank
character).];. The color of the square dot is by default the edgecolor
and its size is set to 6 pixels. If the graphical type of an anonymous
edge has bgcolor defined, then the square dot is adjusted to the
edgewidth and displayed in bgcolor. If you set an explicit bgcolor for
an edge, then the bounding box around the edge label shall be painted in
that color. If you choose as bgcolor the same value as for the bgcolor
of the palette, then edge labels appear more readable.

Do not forget to include the new graphical type into the graphical
palette. It is not necessary to define a new graphical palette, you can
extend the default palette. Furthermore, you have to define the
`graphtype` attribute of some object in such a way that it refers to the
new graphical type. Make sure, that the new graphical type has a higher
priority than other graphical type which might apply (10 is the highest
priority of the default graphical types).

The color strings in bgcolor, textcolor, linecolor, and edgecolor are
encoded in the format `"r,g,b"`, where r, b and g represent the red,
green, and blue share of the color. All values must be from 0 to 255.
The color string `"0,0,0"` results in black and `"255,255,255"` results
in white. You can also add a so-called alpha value for the transparency
of the color as fourth component of a color string. The value \"255\"
stands for opaque (not transparent) colors. This is also the default.
The smallest value \"0\" stands for maximal transparency, i.e. the color
is not visible at all. Any value in between is a relative transparency.
For example, `"255,0,0,127"` represents a red color that is about 50%
transparent with respect to objects below such as the background.

An example of user-defined graphical types can be found in
`sec:ER-diagrams`, see also the CB-Forum at
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/188651") for
a complete specification of ER diagrams including graphical types.

Below are the supported edge head shape (property `edgeheadshape`).
Theoretically, you can also use the node shapes like `Rect` but they are
not configured specifically for edge heads and would be rendered in tiny
sizes.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([*edge head shape*;], [*description*;],),
    table.hline(),
    [Arrow], [triangular arrow head (default for thicker edges)],
    [ArrowVee], [vee-shaped arrow head (default for thin edges)],
    [SmallArrow], [small arrow head with straight base],
    [RevArrow], [reversed arrow (base pointing to the object))],
    [HalfArrow], [half arrow head],
    [Karo], [diamond-shaped arrow head],
    [Square], [square arrow head],
    [Circular], [circular arrow head (approximated)],
    [Caret], [caret shaped arrow head],
    [Bar], [small bar orthogonal to the edge line],
    [Dot], [small square arrow head],
    [none], [no arrow head],
  )]
  , kind: table
  )

=== Node levels
<sec:nodelevel>
CBGraph paints the nodes and edges of a graph in a so-called layered
pane. This helps to separate nodes from edges and from interactive
elements such as pop-up menus. The default absolute level for a node is
200 and the default absolute level for an edge is 100. That means that
nodes are by default painted on top of edges, i.e. the node's shape is
painted over an edge if they overlap. In some modeling languages, one
may want to have certain elements always painted over some other
elements. For example, the process elements of a BPMN process model
should be painted on top of the pool, in which they are defined. Or
consider a traffic light element that is composed of red, yellow and
green lights. Then the symbol for the traffic light element should be
painted below the symbol for the three part lights.

This ordering can be achieved by the _nodelevel_ property for the
graphical types. The nodelevel property is a relative increment to the
default absolute node level 200. For example, by setting the node level
to \"-1\", the resulting absolute node level shall be 199. By setting
the relative node level to \"-101\", the resulting absolute node level
would be 99, i.e. even below the level of edges.

As an example consider the traffic light scenario. The node level is set
to \"-1\", hence it shall be painted behind the other node elements. The
example is taken from the CB-Forum at
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/3762781");.

```
TrafficLight_GT in Class,JavaGraphicalType with
property
    textcolor : "255,255,255";
    linecolor : "0,0,0";
    linewidth: "3";
    bgcolor : "60,60,60";
    shape : "i5.cb.graph.shapes.RoundRectangle";
    size: "resizable";
    align : "bottom";
    nodelevel: "-1"
implementedBy
    implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 22
rule
    gtrule: $ forall x/TrafficLight (x graphtype TrafficLight_GT) $
end
```

You can also use positive node levels to explicitly specify that the
nodes are painted in the foreground of other nodes. The default relative
node level is \"0\". If nodes have the same level, then they are painted
in the order in which they are added to the diagram.

The node selection in CBGraph is adapted to take the node level into
account. It a node with a negative level is selected by a left mouse
click, then all nodes with a higher level whose center point is
contained in the bounds of the first node also get selected. Nodes with
negative levels are interpreted as a kind of a container. So, selecting
and moving them is simplified by this behavior. You can also disable
this behavior by the configuration variable \"NodeLevelAware\", see
section `sec:config`.

=== Click actions
<sec:clickactions>
A click action is a property of a graphical type and contains the name
of a query class as a string. A simple example is:

```
    clickaction: "fireTransition";
```

If an object has a graph type with a click action, then the
corresponding query class is called using the object name as single
parameter. For example, if `t1` is the object name, then a click on the
object in CBGraph will result in calling the query `fireTransition[t1]`.
It is assumed that the ConceptBase server includes an active rule that
is triggered by the query call. Hence, such calls can result in an
update to the database. CBGraph shall refresh its graph after performing
the query call to show the effect of the database update to the graph.
You can also specify a click action with arity zero:

```
    clickaction: "fire/0";
```

In this case the name of the clicked object is not included as a
parameter of the query call. A click action like `"fireTransition"` is
equivalent to `"fireTransition/1"`.

Click actions let a graph directly interact with the ConceptBase server.
Each click on a node whose graphical type has a click action will result
in a corresponding query call that triggers active rules -- assuming
that there are active rules matching the query call. The active rule in
the CBserver can change the database state, but it can also trigger
calls to external programs.

You can also specify clickactions with two arguments like in

```
    clickaction: "playMove/2";
```

In such cases, CBGraph will prepend the username before the object name
of the node that has been clicked. The generated query call would look
like `playMove[jonny,m1]` Note that the query must have two arguments in
this case, e.g.

```
GenericQueryClass playMove isA Position with
  parameter
    arg1: CB_User;
    arg2: Move
  ...
end
```

Note that the first argument for the username must have a label (arg1)
that is lexicographically ordered before the label of the second
argument (arg2). The username is the same that is used by the CBGraph
tool to register to the CBserver. That user is then stored as instance
of the predefined class `CB_User`.

Another option with click actions is to limit the scope of nodes and
links in the current diagram that are refreshed after calling the click
action. The click action can invoke an active rule which changes the
database state. Consequently, certain objects in the diagram may get a
new graphical type. By default, CBGraph shall refresh all nodes and
links in the diagram after executing a click action. This can be rather
slow when the displayed graph is large. The option \"-n\" allows to
limit the refresh to the neighborhood of the selected object. The
neighborbood is defined as the set consisting of the selected object,
the direct neighbors object of the selected object, the direct neighbors
of those neighbors, and all the links in between. Note that this only
refers to the objects displayed in the graph!

You can enable the \"neighbor\" refresh by adding the string \"-n\" to a
click action like in

```
    clickaction: "fireTransition -n";
```

The \"-n\" option is not guaranteed to work correctly since some objects
outside the neighborhood may be affected by the click action. Hence,
only use this when you know that the effect is bound to the neighborhood
and when the displayed diagram has all the required links displayed to
compute the neighborhood.

You can enable and disable click actions by a checkbox in the options
menu of CBGraph. The setting is also stored in the configuration file
.CBjavaInterface. The entry is called \"ClickActions\" there.

See
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/3762781")
for examples.

=== Shapes
<sec:shapes>
The package i5.cb.graph.shapes contains several shapes which might be
useful for the ConceptBase CBGraph Editor. To use these shapes, you can
either specify the full path, e.g. `"i5.cb.graph.shapes.Cloud"`, or just
the last part like `"Cloud"` as value of the property `shape` of a
graphical type.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([*class name*;], [*graphical
      representation*;],),
    table.hline(),
    [Arrow2, ArrowL, ArrowR, DoubleArrow, DownArrow], [various arrows],
    [Banner], [a banner],
    [Circle], [a circle],
    [Cloud], [a cloud shape],
    [Cross], [a cross (like the red cross)],
    [Diamond], [a diamond/rhombus],
    [DiRect, DiRectL, DiRectR], [direction signs],
    [DownPentagon], [like Pentagon but rotated 180 degrees],
    [Ellipse], [an ellipse],
    [FolderL, FolderR], [folder shapes],
    [House], [a house shape],
    [Pentagon, Hexagon, Septagon, Octagon], [as the name says],
    [Rect], [a rectangle],
    [RoundRectangle], [a rectangle with round corners],
    [Page], [a page shape],
    [Star], [a star],
    [Triangle, TriangleL, TriangleR, DownTriangle], [various triangles],
    [Tube], [a tube shape],
    [UpHexagon], [hexagon with pointed vertex on top/bottom],
    [StadionCurve], [variant of a round rectangle resembling a stadion
    curve],
    [UpStadionCurve], [variant of StadionCurve],
    [XCross], [a cross in the form of an X],
    [PolygonShape], [user-definable polygon],
  )]
  , kind: table
  )

The user-defined polygon-curve shape allows you to specify any shape
consisting of a set of points. The start point must be the same as the
end point. Assume, you want to triangle pointing to the right, but the
right extreme point being at the same height 0 as the upper left point.
Then, the following graphical type would do the job:

```
MyTriangle_GT in JavaGraphicalType with  
  property
    ...
    shape : "PolygonShape; 0,3,0,0; 0,0,4,0"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end 
```

In the shape string, the first part `"PolygonShape"` indicates that it
is a user-defined polygon shape, the second part `"0,3,0,0"` are the
x-coordinates of the polygon points, and the third part `"0,0,4,0"` are
its y-coordinates. Note that the number of x-coordinates must be the
same as the number of y-coordinates and that the polygon line ends in
its starting point, here (0,0). The size of the bounding rectangle in
the above example is 4x5 pixels. If your shape is more complicated, e.g.
a curved shape, then you should embed it into a bigger rectangle. The
polygon lines may not intersect each other.

#figure(image("../assets/shapes.png", width: 14.5cm),
  caption: [
    Some of the standard shapes
  ]
)
<fig:shapes>

Figure `fig:shapes` visualizes the pre-defined graph shapes. Note that by
default the dimensions of a shape are adjusted from the area that the
object label occupies. This is fine for the shapes that are close to a
rectangle. The other shapes should be used in combination with the size
\"resizable\".

A variant of the \"resizable\" option is the \"wrap\"/\"wrap\_\" option.
It will additionally wrap the node label text according to the current
node size. The \"wrap\"/\"wrap\_\" option renders the node label with
the HTML implementation of Java.

Examples for the use of resizable shapes graphical types can be found in
the CB-Forum at
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/3596768");.

You can extend the shapes by using the parameterized graph type
`PologonShape` as shown in the previous subsection. Use the \"align\"
property to specify at which position the node's label should be
displayed. Default is \"center\". The above link also contains examples
of user-defined shapes.

=== Icons
<sec:icons>
You can specify an image icon that is displayed instead of a shape to be
drawn for the small compoment of a node (CBIndividual). The syntax for
specifying an image icon is

```
  image: "<image file location>"
```

You can specify either the URL of the image file or the local path of
the file in the URL syntax. For example

```
Class AgentGT in JavaGraphicalType with
  rule
   gtrule : $ forall a/Agent (a graphtype AgentGT) $
  property
   textcolor : "0,0,0";
   linecolor : "0,0,0";
   image: "https://myserver.comp.eu/images/AgentIcon.png"
  implementedBy
   implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 20
end
```

associates the graphical type `AgentGT` to the image icon
`AgentIcon.png`. Both `http` and `https addresses` are supported if you
use Java 11 or later. You can also point to local files via the `file`
protocol:

```
Class AgentGT in JavaGraphicalType with
  rule
    gtrule : $ forall a/Agent (a graphtype AgentGT) $
  property
    textcolor : "0,0,0";
    linecolor : "0,0,0";
    image: "file:///home/jonny/images/AgentIcon.png"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 20
end
```

Note that the image icon is looked up by CBGraph. Hence, the location
must be in the file system of the computer on which CBGraph runs. If you
place the image icon on a web server, then CBGraph will be able to fetch
it from any computer provided that the access rights are set properly.
Note that the URL must use the \"http\" protocol. CBGraph does not
support \"https\" links for image files.

If you specify an image icon for a graphical type, then you can also set
its textposition, for example:

```
    ...
    image: "file:///home/jonny/images/AgentIcon.png";
    textposition: "top";
    ...
```

By default, the node's text label is placed at the bottom of the image.
In this case it shall be placed on top of it. Other possible values are
\"center\", \"left\", and \"right\". Note that the property
`textposition` is only evaluated in combination with an icon image. If a
graphical type has no image ocon, then any text position specified for
it would be ignored. In most cases, the default value \"bottom\" is just
fine.

You can also combine shapes with image icons. In such cases, the image
icon plus the label are the \"inner content\" and the shape is drawn
around it. In the example below, the label is placed left of the image
icon. Both are aligned in the center of a circular shape with gray
background and black line color. CBGraph shall compute the required size
of the surrounding shape from the dimensions of the image icon and its
label. An exception holds when the \"size\" property is set to a fixed
dimension like \"50x40\".

```
    ...
    image: "file:///home/jonny/images/AgentIcon.png";
    textposition: "left";
    shape : "i5.cb.graph.shapes.Circle";
    align : "center";
    bgcolor : "200,200,200";
    linecolor : "0,0,0";
    ...
```

The location specified in the \"image\" and \"bgimage\" property can
either be a URL to an image file (starting with \"http:\/\/\" or
\"file:\/\/\", not \"https:\/\/\") or a relative file location such as
\"diaicons/icon1.png\". In the latter case, CBGraph shall first check if
a local directory \"CBICONS\" exists in the ConceptBase installation
directory (environment variable CB\_HOME). If that exits, it shall
expand the relative path to and absolute path using the location of
CB\_HOME. If the local directory does not exist, CBGraph shall expand
the relative path to a URL starting with
\"http:\/\/conceptbase.sourceforge.net/CBICONS/\". You can add your own
icons to the local directory CBICONS in your ConceptBase installation
directory. Below is an example of a relative image location.

```
    ...
    image: "images/AgentIcon.png";
    ...
```

Further examples on using image icons are provided in the CB-Forum at
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/3506150");.

== TelosPalette: A modern graphical palette for ConceptBase
<telospalette>
`TelosPalette` is a new graphical palette introduced in ConceptBase 8.2
to replace the original `DefaultJavaPalette` (which continues to be
supported for backward compatibility). The main difference is that most
objects are now displayed as white rectangles, whose size can be
extended. The link layout for instantiation and specialization are now
closer to the style used in UML class diagrams to allow easier
recognition. The definition of `TelosPalette` is as follows:

```
TelosPalette in Class,JavaGraphicalPalette isA XBridgePalette with 
  contains,defaultIndividual
    tp1 : INDIVIDUAL_TP_GT
  contains,defaultLink
    tp2 : ATTR_TP_GT
  contains,implicitIsA
    tp3 : ISADEDUCED_TP_GT
  contains,implicitInstanceOf
    tp4 : INSTOFDEDUCED_TP_GT
  contains,implicitAttribute
    tp5 : ATTRDEDUCED_TP_GT
  contains
    tp6 : CLASS_TP_GT;
    tp7 : QUERYCLASS_TP_GT;
    tp8 : INSTOF_TP_GT;
    tp9 : ISA_TP_GT;
    tp10 : STRING_TP_GT;
    tp11 : VALUE_TP_GT;
    tp12 : ASSERTION_TP_GT
end 
```

The superclass `XBridgePalette` serves to bridge the default graphical
types of `DefaultJavaPalette` to `TelosPalette` and its subclasses.
These default graphical types are required to be included by CBGraph.
`XBridgePalette` makes this inclusion transparent to the user via a set
of deductive rules. The overriding graphical types of `TelosPalette`
listed in the table:

#block[
#block[
ll *type of object* & *graphical type* & *style* \
Individuals & INDIVIDUAL\_TP\_GT & white rectangle \
Attribute & ATTR\_TP\_GT & thin black line with label in smaller font \
InstanceOf & INSTOF\_TP\_GT & green broken line without label and caret
arrow head \
IsA & ISA\_TP\_GT & blue line without label; white edge heads \
Class & CLASS\_TP\_GT & almost white rectangle \
QueryClass & QUERYCLASS\_TP\_GT & white-pink rectangle \
Derived In & INSTOFDEDUCED\_TP\_GT & like for InstanceOf but thinner
line \
Derived IsA & ISADEDUCED\_TP\_GT & like for IsA but thinner line \
Derived Attribute & ATTRDEDUCED\_TP\_GT & dashed black line \
String & STRING\_TP\_GT & light grey rectangle with text wrapping \
Integer,Real & VALUE\_TP\_GT & light grey rectangle \
MSFOLassertion & ASSERTION\_TP\_GT & light pink rectangle with text
wrapping \

]
]
A particular advantage of `TelosPalette` is its extensibility via
specialization. Consider for example the case, where a class `Employee`
is defined. Employees shall be displayed as yellow rectangles. All one
has to do is to define the new graphical type like `EMPLOYEE_TP_GT` and
add this to `EmployeePalette`, which specializes `TelosPalette`.

```

Employee in Class end

EMPLOYEE_TP_GT in Class,JavaGraphicalType with 
   property
    bgcolor : "255,255,0";
    textcolor : "0,0,0";
    linecolor : "0,0,0";
    shape : "Rect";
    size : "resizable";
    linewidth : "1"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 10
  rule
    gtrule1 : $ forall x/Employee (x graphtype EMPLOYEE_TP_GT) $
end 

EmployeePalette in Class,JavaGraphicalPalette isA TelosPalette with 
   contains
    ep1 : EMPLOYEE_TP_GT
end 
```

The shape \"Rect\" is a shortcut for the shape string
\"i5.cb.graph.shapes.Rect\". CBGraph works with both values. Note that
the added graphical type `EMPLOYEE_TP_GT` needs to have a higher value
for priority than the default graphical type for so-called individual
objects. All pre-defined graphical types have priorities lower than 10.
Hence the values of 10 is sufficient to make sure that employees get the
dedicated graphical type.

== Object-specific graphical properties
<gproperty>
Nodes and links get their graphical properties from the graphical type
assigned to them. The assignment is typically defined by deductive rules
deriving a fact `(x graphtype gt)`. In general, several such facts may
be true for a given object `x`. Then, the priority of the graphical type
is used to pick a unique solution. As a result, all objects with the
same graphical types are also rendered in the same way, except of the
name of the object.

In some situations, one may want to assign specific graphical properties
to objects depending on the object state. The graphical type provides
the general properties and specific graphical properties are derived
from the object. For example, all employees could be displayed by a
rectangular node with white background, but employees with a high salary
are displayed in yellow color. Further, employees that are assigned to
departments get a thicker line width.

In principal, the different cases can be realized by dedicated graphical
types. In the example above, one would need at least four different
graphical types (regular employees without department, high salary
employees without department, regular employees with department, and
high salary employees without department). The different cases thus lead
to an explosion of graphical types.

ConceptBase thus provides a second mechanism to directly assign
graphical properties to objects. The graphical properties are defined
for any proposition:

```
    Proposition with
      attribute 
         gproperty: Proposition
    end
```

Note that the target class is `Proposition` rather than `String`, as
used for the attribute `property` of graphical types. The reason is to
add more flexibility, e.g. to assign integers as values for certain
`gproperty` attributes like line width.

Any object#footnote[Due to technical limitations, only node objects
(=instances of `Individual`) get their `gproperty` feature scanned by
CBGraph. Hence, you can only use it for node objects, not for edges.]
may have (derived or explicit) `gproperty` attributes. The values of
these attributes overrule the corresponding values of the graphical type
of the object:

```
    bill in Employee with
      ...
      gproperty
        bgcolor: "240,240,0";
        linecolor: "0,0,220"
    end
```

The properties may also be derived by rules, e.g.~

```
    Employee in Class with
       attribute
         salary: Integer
       rule
         re1: $ forall e/Employee s/Integer (e salary s) and (s > 1000) 
                 ==> (e gproperty/bgcolor "255,255,200") $
    end
```

The labels of the `gproperty` attributes shall be taken from the list in
section `sec:graph-props`. The object-specific graphical properties are
not assigned to any palette. They are global and overrule the properties
from the graphical type. It could be that there are multiple rules that
derive the same `gproperty` attribute, e.g.

```
    Individual in Class with
       rule
         rx1: $ forall x/Individual (x gproperty/bgcolor "255,255,255") $
    end
```

This rule may collide with rule `re1`. In such cases, both
`"255,255,200"` and `"255,255,255"` as values of `bgcolor`. CBGraph will
then pick any of them (actually the last one transmitted overrules any
previous ones). Since the order is subject to the CBserver rule engine,
one can hardly predict, which value prevails. Hence, write design the
rules in such a way that such collisions are avoided.

The `gproperty` attribute `label` adds a new functionality to the
system: you can overrule the node and link name displayed in CBGraph.
For example, it may be useful to replace the name of a shelf with its
current fill level. Another example are 'places' of petri nets. Instead
of the place name, one can display the number of tokens of that place as
the label of the place node.

Another interesting `gproperty` attribute is '`labellength`'. By
default, CBGraph assumes a maximum label length of 40 characters. If the
node label length exceeds this threshold, it will be truncated and the
last four characters are set to \" ...\". If you need to have longer
labels, then use the '`labellength`' property. An example shows how to
use it:

```
    Employee in Class with  
      attribute
        name : String
      rule
        r1 : $ forall e/Employee n/String (e name n) ==> (e gproperty/label n)$;
        r2 : $ forall e/Employee  (e gproperty/labellength 50)$
    end 

    bill in Employee with  
      name
        n : "William the Conquerer from Abessinia della Cruz"
    end
```

You can easily check, which object-specific properties are currently
assigned to objects by the following query:

```
    ObjectProperty in QueryClass isA Proposition with  
      retrieved_attribute
        gproperty : Proposition
    end 
```

You can retrieve the objects with colliding `gproperty` attributes via
the query

```
    ObjectWithMultipleProperties in QueryClass isA Proposition with  
      retrieved_attribute
        gproperty : Proposition
      constraint
        clash : $ exists L/Label p1,p2/Proposition (this gproperty/L p1) and
              (this gproperty/L p2) and (p1 <> p2) $
    end 
```

We advise to use the `gproperty` feature in combination with graphical
types. The graphical type of an object provides the graphical properties
that apply to all objects that fall into the class covered by the
graphical type. The object-specific properties then overrule certain
properties of that graphical type or add properties that were not
defined by the more general graphical type. Use the `gproperty` feature
with great care. For example, assigning object-specific properties to
all instances of the class `Individual` is not wise since `Individual`
is a generic class: all node-like objects are instances of `Individual`.

=== HTML node labels
<htmllabels>
The gproperty \"label\" can be used to assign long node labels to
specific objects, see object \"bill\" above. ConceptBase also supports
to specify a node label that shall be HTML-formatted, more precisely in
the subset of HTML that the Java Swing supports. There are however some
caveats. Since ConceptBase uses XML to pass information between the
CBGraph client and the server, the HTML code may not include the
characters \"$<$\" and \"$>$\". Instead, you have to use square
brackets. The square brackets are replaced within CBGraph to render the
HTML code. As a simple example, consider

```
    anna with  
      gproperty label: "[center]Anna[/center][hr][/hr]
        Anna Catharina III Regina de Abessinia della Cruz"
      gproperty labellength: 200
      gproperty size: "wrap"
    end
```

CBGraph will render the node with a first centered line containing the
Strring \"Anna\", followed by a horizontal rule, then followwed by the
rest of the label. You have to make sure to extend the labellength
property to a sufficiently large value. Further, the size property must
be set to \"wrap\".

You can also set labellength and size via the graphical type that is
applicable to the object. With help of the \"resultOf\" function (see
section `stringmanu`) in combination with answer formats, you can also
derive the HTML code for objects of a class. See CB-Forum at
#link("https://bscw.dbis.rwth-aachen.de/pub/bscw.cgi/4696707") for an
extended example. Be careful with the implementation of the answer
format since it generates new hidden objects for the HTML labels.

== Graphical types for derived links
<gtypederived>
Derived links (and attributes) are displayed by default with the
graphical type `ImplicitAttributeGT`, i.e.~a dashed line with the
attribute label defined at the class level. Derived links have no object
identity. Thus, one cannot attach a `graphtype` or `gproperty` attribute
to them.

ConceptBase uses another method to allow user-definable graphical types
for such links. Assume, there is a class definition as follows:

```
    Person in Class with  
      attribute
        knows : Person
      rule
       trrule : $ forall x,y,z/Person
                  (x knows y) and (y knows z)
                 ==> (x knows z) $
    end
```

Let the attribute `knows` be derived by some rules.

Then, one can define a graphical type `ImplicitGT_knows` that shall be
applied to all derived using the class label `knows`, e.g.

```
    ImplicitGT_knows in JavaGraphicalType with  
      property
        textcolor : "20,20,220";
        edgecolor : "250,20,20";
        bgcolor : "255,255,255,100";
        edgestyle : "dashdotted";
        edgewidth : "3"
      implementedBy
        implBy : "i5.cb.graph.cbeditor.CBLink"
      priority
         p : 10
    end 
```

This graphical type then has to be added to the right graphical palette:

```
    PersonPalette in JavaGraphicalPalette isA TelosPalette with  
      ...
      contains
        xx14 : ImplicitGT_knows
    end
```

Note that the label of the graphical type starts with the prefix
`ImplicitGT_`, which is then followed by the label of the derived link.
CBGraph shall assign this graphical type for derived links if the
current graphical palette contains such a graphical type. Otherwise, the
default (usually `ImplicitAttributeGT` or the graphical type listed as
implicitAttribute in the graphical palette) is used.

The user-defined graphical types for derived links allows to create
domain-specific visualizations of derived information. It is rather
common to have multiple derived link types such as `knows`. It thus
makes sense to distinguish them also in the graphical visualization.

Derived instantiations (\"in\") and derived specializations (\"isA\")
are handled differently. Their dedicated graphical type can be specified
in the graphical palette as follows:

```
    contains,implicitIsA
      c3 : MyImplicitIsAGT
    contains,implicitInstanceOf
      c4 : MyImplicitInstanceOfGT
```

where `MyImplicitInstanceOfGT` and `MyImplicitIsAGT` are user-defined
names of graphical types.

== Palette-specific methods to expand related objects
<palette-expand>
Nodes and links in the graph editor CBGraph can be expanded to show
their instances/classes, subclasses/superclasses, and
attributes/relations. For the latter, the default behavior of CBGraph is
to determine which attribute/relation categories are actually used by
the selected object and then create the suitable popup-menu for the
object by only shows those categories that are actually used. The
queries to compute these categories are:

```
   find_used_attribute_categories 
      in GenericQueryClass isA Proposition!attribute with 
      parameter,required
       objname : Proposition
     constraint
       r : $  exists x/Proposition AD(this,~objname,x)  $
   end 

   find_used_incoming_attribute_categories
      in GenericQueryClass isA Proposition!attribute with 
      parameter,required
       objname : Proposition
     constraint
       r : $  exists x/Proposition AD(this,x,~objname)  $ 
   end 
```

This is convenient but can also be a very costly operation in case that
the object is occuring in many derived facts (derived relations, derived
attributes).

A way out of this dilemma are dedicated queries that computes the
eligible categories of the derived outgoing and incoming
attributes/relations. Consider the example below:

```
   MyPalette in Class,JavaGraphicalPalette isA TelosPalette with 
      contains
       gt1: THING_GT;
       ...
     palproperty
       outcatquery : "alt_used_attribute_categories";
       incatquery  : "alt_used_incoming_attribute_categories"
   end
```

The two new palette properties `outcatquery` and `incatquery` specify
the replacement queries for the default queries. Next, define two new
categories for graphical types:

```
   JavaGraphicalType with 
      attribute
       forOutgoing : Proposition!attribute;
       forIncoming : Proposition!attribute
   end
```

These allow to define dedicated query classes such as the following:

```
   alt_used_attribute_categories
     in GenericQueryClass isA Proposition!attribute with 
     parameter,required
        objname : Proposition
     constraint
        r : $ exists gt/JavaGraphicalType 
               (~objname graphtype gt) and (gt forOutgoing ~this)  $
   end 
```

In this case, the applicable attribute categories are attached to the
graphical types of objects:

```
   THING_GT in Class,JavaGraphicalType with 
     property
      ...
     rule
       gtrule : $ forall x/Thing (x graphtype THING_GT) $
     forOutgoing
       out1 : Thing!aproperty
   end 
```

The new feature allows to hide certain attribute/relation properties
from the pop-up menu. The method works for incoming attributes in a
simular fashion. Just use `forIncoming` and define a query class for
`alt_used_incoming_attribute_categories`. An elaborate example is in the
CB-Forum at
#link("https://bscw.dbis.rwth-aachen.de/pub/bscw.cgi/4789459");. The
palette `USU_Palette_outcat` customizes the types of outgoing links of
instances of `Akteur` to just the link types `braucht` and `beliefert`.
