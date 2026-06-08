= Analyze Graphs

Verified independently via:

```bash
nix build .#checks.x86_64-linux.analyze-graphs
```

== Input

=== `bigcity-queries.sml.txt`

```telos
{* 
* File: bigcity-queries.sml.txt
* Author: Manfred Jeusfeld
* Date: 2021-05-07
* License: CC-BY-SA 4.0
*}


CityWithConnection in QueryClass isA city with
  constraint
     qc1: $ exists c/city (this con_to c) $
end


CityWithoutConnection in QueryClass isA city with
  constraint
     qc1: $ not exists c/city (this con_to c) $
end


CityToHub in QueryClass isA city with
  constraint
     qc1: $ (this con_to london) and (this con_to paris) $
end


CityFromHub in QueryClass isA city with
  constraint
     qc1: $ (london con_to this) and (paris con_to this) $
end

HubCandidate in QueryClass isA CityToHub,CityFromHub
end


ReachableFromFrankfurt in QueryClass isA city with 
  constraint
    qc1 : $ (frankfurt trans_con_to ~this) $
end 


ReachableFrom in GenericQueryClass isA city with 
   computed_attribute,parameter
    start : city
  constraint
    c : $ (~start trans_con_to ~this) $
end 

DeadEndCity in QueryClass isA city with 
   constraint
    c1 : $ (forall n/city (~this con_to n)
            ==> (n in DeadEndCity)) $
end

```

=== `Clique.sml.txt`

```telos
{
*
* File: Clique.sml
* Author: Manfred Jeusfeld
* Creation: 9-Dec-2005
* ----------------------------------------------------------------------
* Wrong definition of  the concept of a clique. 
* It will not inspect all possible subsets of
* CliqueMemberCandidate for being cliques. It only checks the
* complete set CliqueMemberCandidate. We actually miss a
* subset iterator in the query language of ConceptBase.
* For example, if we ask CliqueMember[c1/rep], then 
* get c1,c2,c3,c4 as clique members of c1. However, if
* we ask CliqueMember[c4/rep], then we get 'nil' as answer
* because the CliqueMemberCandidates of c4 includes c5,
* which is not member of the clique. It would be nice
* if the system could infer that a clique of c4 can be 
* found if one restricts to a subset of CliqueMemberCandidate.
*
* Note that also c1,c2,c3,c4 could have links to nodes like c5
* that are not part of the clique.
*
* Not surprisingly, the clique problem is NP-complete as described in
*   http://en.wikipedia.org/wiki/Clique_problem
* Since deductive query evaluation is polynomial in the size of
* the input (here: the graph), a purely deductive solution to the
* clique problem is impossible (provided P=NP is untrue). 
* So, a subset iterator would firmly kick us out of deductive
* query processing and let us enter other computational class.
*
}

{* simple class level for connected units *}

Class Node with
  attribute
    linkTo: Node
end


{* this defines the candidate nodes for the clique:    *}
{*  all nodes linked from ~rep including ~rep          *}
{* By this, we will not be able to find cliques that   *}
{* are established by subsets of CliqueMemberCandidate *}

CliqueMemberCandidate in GenericQueryClass isA Node with
  parameter
    rep: Node
  constraint
    ccand: $ (~rep linkTo ~this) or (~rep = ~this) $
end

{* find all clique members of ~rep *}

CliqueMember in GenericQueryClass isA Node with
  parameter
    rep: Node
  constraint
    ccliq: $ (~this in CliqueMemberCandidate[~rep/rep]) and
               (forall u1,u2/CliqueMemberCandidate[~rep/rep]
                    not (u1 == u2) ==> (u1 linkTo u2) and (u2 linkTo u1))
            $
end



  
c1 in Node with
  linkTo
   p1: c2;
   p2: c3;
   p3: c4
end

c2 in Node with
  linkTo
   p1: c1;
   p2: c3;
   p3: c4
end

c3 in Node with
  linkTo
   p1: c1;
   p2: c2;
   p3: c4
end

c4 in Node with
  linkTo
   p1: c1;
   p2: c2;
   p3: c3;
   p4: c5
end

c5 in Node end







```

=== `ConnectedComponents.sml.txt`

```telos

{*
* File: ConnectedComponents.sml
* Author: Manfred Jeusfeld
* Created: 2012-04-27/M.Jeusfeld (2013-03-12/M.Jeusfeld)
* ------------------------------------------------------
* Compute the connected components of a graph.
* The graph is made undirected (symmetric) and
* also reflexive to correctly compute the equivalence class
* of connected nodes.
* 
* This model requires the plugin selectfirst.swi.lpi.
* 
* Call by query: ConnectedComponent
*
* After the call the class Representative contains representative
* for all connected components (one for each). the connected nodes
* of a representative can be determined via the linkTo relation.
*
* ConnectedComponent[node] returns all members of the connected component
* of node.
*
* #Representative returns the number of connected components of the graph.
* You need to query computeRepresentatives before.
*
* More at: http://conceptbase.cc; requires ConceptBase 7.4
*
*}


{* Class level: *}

Node in Class with
  attribute
     linkTo: Node  {* attributes in ConceptBase are by default multi-valued *}
  rule
     transitivity: $ forall n1,n2,n3/Node (n1 linkTo n2) and (n2 linkTo n3) ==> (n1 linkTo n3) $;
     symmetry: $ forall n1,n2/Node (n1 linkTo n2) ==> (n2 linkTo n1) $;
     reflexivity: $ forall n/Node (n linkTo n) $
end

{* any node is a representative of the equivalence class of nodes connected to it *}
Representative isA Node with
end

{* this query class is used in the ECArule to build the connected component of an *}
{* unassigned node                                                                *}
UnassignedNode in QueryClass isA Node with
  constraint
    notAssigned: $ not exists r/Representative (r linkTo this) $
end

ConnectedComponent in GenericQueryClass isA Node with
  parameter
    rep: Node
  constraint
    conn: $ (rep linkTo this) $
end


{* This ECArule computes representatives for all         *}
{* connected components of the graph.                    *}
{* It is both an ECArule and a QueryClass; by this trick *}
{* we can just call the ECArule and let it call itself   *}

computeRepresentatives in ECArule,QueryClass isA YesClass with
  mode m: Immediate
  ecarule
        er : $ r,n/Node
        ON Ask computeRepresentatives
        IFNEW (r in selectfirst[UnassignedNode])
        DO  Tell (r in Representative),
            Raise computeRepresentatives
        $
end


{* Whenever we call ConnectedComponent, we will first run *}
{* the computeRepresentatives ECArule                     *}

hookConnectedComponent in ECArule with
  mode m: Immediate
  ecarule
        er : $ r,n/Node
        ON Ask ConnectedComponent
        DO Raise computeRepresentatives
        $
end


{* Data level*}


N1 in Node with
  linkTo
    s1: N2
end

N2 in Node with
  linkTo
    s1: N3;
    s2: N4
end

N3 in Node with
  linkTo
    s1: N5
end

N4 in Node with
  linkTo
    s1: N5
end

N5 in Node with
  linkTo
    s1: N2
end

M1 in Node with
  linkTo
    s1: M2
end

M2 in Node with
 linkTo
    s1: M3;
    s2: M4
end

M3 in Node with
  linkTo
    s1: M5
end

M4 in Node with
  linkTo
    s1: M5
end

M5 in Node 
end









```

=== `Organigraph.sml.txt`

```telos
{
*
* File: Organigraph.sml
* Author: Manfred Jeusfeld
* Creation: 29-Jun-2004 (2-Dec-2012)
* ----------------------------------------------------------------------
* This is the O-Telos representation organigraphs
* Some definitions like SetUnit2 are shorter realizations
* using complex functional expressions supported by ConceptBase 6.2.
* Since they are creating intermediate results of COUNT (#) as
* objects, performance is significantly lower than for the
* originals. Another reason is that the predicates with functional
* expressions do not fully utilize the cache-based literal
* evaluator of ConceptBase.
*
* We omit the tilde ('~') before parameter references and the class
* variable 'this'. This simplified syntax is supported by ConceptBase
* as of 25-Mar-2008.
*
* Requires ConceptBase 7.1 released 25-Mar-2008 or later.
*
}


Class Unit with
  attribute
    pushes: Unit;
    pushesTrans: Unit
end


{* Unit with a link to this unit *}
ToUnit in GenericQueryClass isA Unit with
  parameter
    unit: Unit
  constraint
    c1: $ (unit pushes this) $
end

{* Unit with a link from this unit *}
FromUnit in GenericQueryClass isA Unit with
  parameter
    unit: Unit
  constraint
    c1: $ (this pushes unit) $
end

SetUnit in QueryClass isA Unit with
  constraint
     c1: $ (#ToUnit[this] >= 2) and 
           (#FromUnit[this] = 1) $
end


HubUnit in QueryClass isA Unit with
  constraint
     c1: $ (#ToUnit[this] >= 2) and 
           (#FromUnit[this] >= 2) $
end


ChainUnit in QueryClass isA Unit with
  constraint
     c1: $ (#ToUnit[this] = 1) and 
           (#FromUnit[this] = 1) $

end

ChainStartUnit in QueryClass isA Unit with
  constraint
     c1: $ not (this in ChainUnit) and
           exists s/ChainUnit (this pushes s) $
end

ChainEndUnit in QueryClass isA Unit with
  constraint
     c1: $ not (this in ChainUnit) and
           exists s/ChainUnit (s pushes this) $
end


{* o1 is a set *}

o1 in Unit with 
  pushes
    u1: o2;
    u2: o3;
    u4: o4
end

o2 in Unit end
o3 in Unit end
o4 in Unit end


{* o5 is a hub *}

o5 in Unit with
  pushes
     u1: o6;
     u2: o7;
     u3: o8
end

o6 in Unit end
o7 in Unit end
o8 in Unit end

o9 in Unit with 
  pushes
    u1: o5
end

o10 in Unit with 
  pushes
    u1: o5
end


{* start of a chain: *}
o6 in Unit with
  pushes
    u1: o11
end

o11 in Unit with
  pushes
    u1: o12
end

o12 in Unit with
  pushes
    u1: o13
end

o13 in Unit with
  pushes
    u1: o1
end


{* graphical types *}

Class Organigraph_Palette in JavaGraphicalPalette with
contains,defaultIndividual
	c1 : DefaultIndividualGT
contains,defaultLink
	c2 : DefaultLinkGT
implicitIsA, contains
    c3 : ImplicitIsAGT
implicitInstanceOf, contains
    c4 : ImplicitInstanceOfGT
implicitattributee, contains
    c5 : ImplicitattributeeGT
contains
    c6: Unit_GT;
    c7: Set_GT;
    c9: Chain_GT;
    c10: Hub_GT;
    c12: ChainStart_GT;
    c13: ChainEnd_GT;
    c14: PushesLinkGT;
    c19: DefaultattributeeGT;
    c20: DefaultIsAGT;
    c21: DefaultInstanceOfGT;
    c22: QueryClassGT
rule
    rIsaGT : $ forall p/IsA (p graphtype DefaultIsAGT) $;
    rInstGT : $ forall p/InstanceOf (p graphtype DefaultInstanceOfGT) $;
    rAttrGT : $ forall p/attributee (p graphtype DefaultattributeeGT) $;
    rIndGT : $ forall p/Individual (p graphtype DefaultIndividualGT) $;
    rQueryClass : $ forall c/QueryClass (c graphtype QueryClassGT) $
end


Unit_GT in Class,JavaGraphicalType with
property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 20
rule
     gtrule: $ forall u/Unit (u graphtype Unit_GT) $

end


Set_GT in Class,JavaGraphicalType with
property
	bgcolor : "250,250,100";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 30
rule
     gtrule: $ forall u/SetUnit (u graphtype Set_GT) $

end


Hub_GT in Class,JavaGraphicalType with
property
	bgcolor : "250,100,250";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 31
rule
     gtrule: $ forall u/HubUnit (u graphtype Hub_GT) $

end

Chain_GT in Class,JavaGraphicalType with
property
	bgcolor : "150,250,250";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 32
rule
     gtrule: $ forall u/ChainUnit (u graphtype Chain_GT) $

end

ChainStart_GT in Class,JavaGraphicalType with
property
	bgcolor : "100,200,200";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 21
rule
     gtrule: $ forall u/ChainStartUnit (u graphtype ChainStart_GT) $

end


ChainEnd_GT in Class,JavaGraphicalType with
property
	bgcolor : "100,200,150";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 21
rule
     gtrule: $ forall u/ChainEndUnit (u graphtype ChainEnd_GT) $

end



PushesLinkGT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "120,120,120";
     edgewidth : "2";
     label : "";
     bgcolor : "250,200,100"  {* bgcolor for the square dot on the edge *}
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 8
  rule
     gtrule1: $ forall u/Unit!pushes (u graphtype PushesLinkGT) $
end 




                       

                       









```

== Graph files

- `CyclicGraphs.gel`
- `organigraph.gel`
- `shortestpathdemo.gel`

== Shell output

```text
=== HOW-TO: analyze-graphs ===

>>> Telling ./Organigraph.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> cbgraph smoke: ./CyclicGraphs.gel
>>> cbgraph smoke: ./CyclicGraphs.gel
/nix/store/ppzp1jz4q8wn8hc1535y6c4v0vfwxmy4-stdenv-linux/setup: line 1952: xvfb-run: command not found
cbgraph smoke skipped (asset validation only)
cbgraph smoke skipped (asset validation only)
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
