= Introduction
<introduction>
The models in a ConceptBase database can be exported in user-defined
formats. This tutorial shows how to employ the ConceptBase answer
formats and the CBShell to realize the export.

The tutorial uses petri nets as an example to be exported to the format
that the GraphViz package required to automatically layout a graph. The
GraphViz layout is textual but does not use XML. You can also export to
XML but using appropriate answer formats.

We select the CBShell utility for this tutorial. It can be used both
interactively and in batch mode. You can thus automate the export via a
suitable CBShell script.

=  The Scenario 
<the-scenario>
We consider the case of petri nets. The goal to to export them in a
format that can be further processed by the GraphViz layout tool
#link("http://graphviz.org/");. We assume familiarity with the
ConceptBase user interface and with the query language of ConceptBase,
in particular with the answer formatting system at
#link("http://conceptbase.sourceforge.net/userManual75/cbm004.html");.

The tutorial includes the following steps:

+ Create a notation for petri nets: this allows to store petri nets in
  ConceptBase

+ Define the PNModel: the PNModel is a container for the petri net
  elements

+ Define an example petri net model: the TrafficLights example

+ Define answer format for the classes to be exported: specifies to
  which output strings the elements shall be exported

+ Define the export task: the overall answer format that governs the
  exportation

== Create a notation for petri nets
<create-a-notation-for-petri-nets>
Petri nets consist of places (displayed as circles) and transitions
(displayed as rectangles). Places can have tokens on them (the marking
of a place). Directed links exist between places and transitions, and
between transition and places.

Start a CBShell

cbshell

and then a CBserver within the CBShell (all subsequent commands are
within the CBShell command window):

cbserver -db PETRINETS

We use a database PETRINETS here. It persistently stores the subsequent
definitions. As next step, tell in the CBShell the definitions for petri
nets:

#text(raw("tell '\n    Place with\n      attribute sendsToken: Transition;\n      marks: Integer {* defines markings *}\n    end\n\n    Transition with \n      attribute producesToken : Place \n    end\n'"))
The two classes allow to represent all features of a classical petri
net.

== Define the PNModel
<define-the-pnmodel>
Now, we want to be able to maintain several petri nets in ConceptBase
next to each other. They should not interfer with each other. PNModel
shall include rules that define which elements of the petri net model
are of interest for the visualization that we aim for. In this case, we
are not interested in the marking but in all other elements:

#text(raw("tell '\n    PNElement end\n    Place isA PNElement end\n    Transition isA PNElement end\n    Place!sendsToken isA PNElement end\n    Transition!producesToken isA PNElement end\n\n    PNModel in Class with\n      attribute\n        contains: PNElement\n      rule\n        r1: \\$ forall p/Place m/PNModel a/Place!sendsToken\n            (m contains p) and Ai(p,sendsToken,a)\n            ==> (m contains a) \\$;\n        r2: \\$ forall t/Transition m/PNModel a/Transition!producesToken\n            (m contains t) and Ai(t,producesToken,a) \n            ==> (m contains a) \\$\n    end\n'"))
The class PNElement subsumes all elements of a petri net model that we
are interested in. The class PNModel then aggregates such elements to a
model. The two rules allow will add all links between places and
transitions that are declared as part of the model.

== Define an example petri net model
<define-an-example-petri-net-model>
Let's define the classical Dutch traffic light example as a petri net
model:

#text(raw("tell '\n    red1 in Place with\n      sendsToken\n        t1: rg1\n    end\n\n    yellow1 in Place with\n      sendsToken\n        t1: yr1\n    end\n\n    green1 in Place with\n      sendsToken\n        t1: gy1\n    end\n\n    safe1 in Place with\n      sendsToken\n        t1: rg1\n    end\n\n    yr1 in Transition with\n      producesToken\n        p1: red1;\n        p2: safe2\n    end\n\n    rg1 in Transition with\n      producesToken\n        p1: green1\n    end\n\n    gy1 in Transition with\n      producesToken\n        p1: yellow1\n    end\n\n    red2 in Place with\n      sendsToken\n        t1: rg2\n    end\n\n    yellow2 in Place with\n      sendsToken\n        t1: yr2\n    end\n\n    green2 in Place with\n      sendsToken\n        t1: gy2\n    end\n\n    safe2 in Place with\n      sendsToken\n        t1: rg2\n    end\n\n    yr2 in Transition with\n      producesToken\n        p1: red2;\n        p2: safe1\n    end\n\n    rg2 in Transition with\n      producesToken\n        p1: green2\n    end\n\n    gy2 in Transition with\n      producesToken\n        p1: yellow2\n    end\n\n    TrafficLights in PNModel with\n      contains\n       e1: red1;\n       e2: yellow1;\n       e3: green1;\n       e4: safe1;\n       e5: red2;\n       e6: yellow2;\n       e7: green2;\n       e8: safe2;\n       e9: yr1;\n       e10: rg1;\n       e11: gy1;\n       e12: yr2;\n       e13: rg2;\n       e14: gy2\n    end\n'"))
The last object #raw("TrafficLights") lists the places and transitions that
are supposed to be part of the model. The rules r1 and r2 of #raw("PNModel")
will automatically add the links as well to the model #raw("TrafficLights").

== Define answer format for the classes to be exported
<define-answer-format-for-the-classes-to-be-exported>
We want to export transitions (as boxes), places (as circles), and the
two link types as directed links:

#text(raw("tell '\n    BOXNODE_FORMAT in AnswerFormat with\n       pattern p:\n         \"node [shape=box]; {Foreach( ({this.elem}), (n), {n};)}\"\n    end\n\n    CIRCLENODE_FORMAT in AnswerFormat with\n       pattern p: \n        \"node [shape=circle,fixedsize=true,width=0.9]; {Foreach( ({this.elem}), (n), {n};)}\"\n    end\n\n    LINK_FORMAT in AnswerFormat with\n       pattern p: \n         \"{Foreach( ({this.elem}),(l),{From({l})}->{To({l})};\\\\n)}\"\n    end\n'"))
The answer format shall iterate over all elements that match the
corresponding export class (Foreach this.elem). The following query
computes the elements for a given export class. The textual elements
like \"node\" and \"shape\" are specific to the GraphViz format.

#text(raw("tell '\n    GenericQueryClass ShowElement isA PNModel with\n      required,parameter\n         pn: PNModel;\n         type: Proposition\n      computed_attribute\n         elem: PNElement\n     constraint\n         c1: $ (pn = this) and\n               (this contains elem) and\n               (elem in type) $\n    end\n'"))
So, when we ask the query #raw("ShowElement") for the model #raw("TrafficLights")
and the export type #raw("Place"), we get as answer in this.elem all those
elements of the petri net that are places.

ask ShowElement[TrafficLights/pn,Place/type] OBJNAMES FRAME

If you call the same query with the #raw("CIRCLENODE_FORMAT"), the answer
shall be the export string for those petri net elements:

ask ShowElement[TrafficLights/pn,Place/type] OBJNAMES CIRCLENODE_FORMAT

== Define the export task
<define-the-export-task>
As a last step we define a query #raw("ShowPN") with a special answer format
that takes care that all elements of the petri net are exproted using
the right answer format, and that puts some additional Graphviz
statements around it required by the GraphViz tool.

#text(raw("tell '\n    GenericQueryClass ShowPN isA PNModel with\n      required,parameter\n         pn: PNModel\n      constraint\n         c1: $ (pn = this) $\n    end\n\n    GraphVizPN in AnswerFormat with\n      forQuery q: ShowPN\n      head h: \"\n# Generated by ConceptBase {cb_version} at {transactiontime}\n# Process this file by Graphviz, e.g. \n#    neato -Tpng thisfile.txt > thisfile.png\n\n\"\n      pattern p: \"\ndigraph {this} \\{\n{ASKquery(ShowElement[{this}/pn,Transition/type],BOXNODE_FORMAT)}\n{ASKquery(ShowElement[{this}/pn,Place/type],CIRCLENODE_FORMAT)}\n{ASKquery(ShowElement[{this}/pn,Place!sendsToken/type],LINK_FORMAT)}\n{ASKquery(ShowElement[{this}/pn,Transition!producesToken/type],LINK_FORMAT)}\noverlap=false\nlabel=\\\"PetriNet Model {this}\\\\\\n\n        Extracted from ConceptBase and layed out by Graphviz \\\"\nfontsize=12;\n\\}\n\"\n    end\n'"))
The tag digraph instructs GraphViz to regard the exported text as the
specification of a directed graph. The complete documentation of the
GraphViz format is at #link("http://graphviz.org/Documentation.php");.

The query #raw("ShowPN") is used to trigger the creation of the answer
accoring to the answer format #raw("GraphVizPN"). The anser format has a head
that creates some header for the output. In this case, it generates some
comment lines. The pattern is applied to all answer objects of query
#raw("ShowPN"): this is exactly one, namely the #raw("PNModel") supplied with the
parameter pn. This answer object matches the expression #raw("{this}") in the
pattern.

Certain special character of the pattern need to be escaped. The clause
starting with label is to be followed by a double quote. Since this
double quote is inside the pattern string, which is double-quoted, the
internal double quote needs to be espacef by a backslash.

The other example is the sequence with three backslashes followed by an
n. The purpose is to pass just a backslash-n to the output. To do so,
the answer formatting tool of ConceptBase must be instructed to produce
the blackslash character rather than interpreting the backslash itself.

Try out the query call

ask ShowPN[TrafficLights/pn] OBJNAMES GraphVizPN

in the CBShell window. It will bind variable #raw("this") to the object
#raw("TrafficLights"). This string is printed by the answer format after the
string #raw("digraph"). Then an opening curly bracket follows that needed to
be escaped since curly brackets have a special meaning in answer
formats. Afterwards, three queries are called from within the answer
format. The first one will generate the GraphViz commands for specifying
the box nodes. The next one is replaced by the GraphViz commands for the
circle nodes, followed by the commands for the links.

Afterwards three more text lines are added to the output.

The definitions are stored in the database PETRINETS. To retrieve only
the desired output from it, first stop the CBserver via the CBShell

stopServer

Then, start it again with tracing disabled:

cbserver -t no -db PETRINETS

Then, call the query and show the answer:

ask ShowPN[TrafficLights/pn] OBJNAMES GraphVizPN
showAnswer

The output of the command is formed by the #raw("GraphVizPN") answer format.
Its text for the #raw("TrafficLights") example is:

#text(raw("# Generated by ConceptBase 7.5.02 at 2013-06-24 10:26:41\n# Process this file by Graphviz, e.g. \n#    neato -Tpng thisfile.txt > thisfile.png\n\ndigraph TrafficLights {\nnode [shape=box];  gy2; yr2; rg2; gy1; yr1; rg1;\nnode [shape=circle,fixedsize=true,width=0.9];  green2; yellow2; red2;\n           safe2; safe1; green1; yellow1; red1;\nsafe2->rg2;\ngreen2->gy2;\nyellow2->yr2;\nred2->rg2;\nsafe1->rg1;\ngreen1->gy1;\nyellow1->yr1;\nred1->rg1;\n\ngy2->yellow2;\nrg2->green2;\nyr2->safe1;\nyr2->red2;\ngy1->yellow1;\nrg1->green1;\nyr1->safe2;\nyr1->red1;\n\noverlap=false\nlabel=\"PetriNet Model TrafficLights\\n\n       Extracted from ConceptBase and layed out by Graphviz \"\nfontsize=12;"))
#figure(image("../assets/export1.png", width: 9cm),
  caption: [
    TrafficLights model layed out by GraphViz
  ]
)
<fig:export1>

You can store the file and convert it to a diagram with GraphViz. With
the #raw("neato") layouter the output looks as shown in figure #raw("fig:export1")

All commands of this tutorial are also available from the CB-Forum at
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/3504020");.
