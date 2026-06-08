= Formulate Query Calls With Other Queries As Parameters

Verified independently via:

```bash
nix build .#checks.x86_64-linux.formulate-query-calls-with-other-queries-as-parameters
```

== Input

=== `nested2.sml.txt`

```telos
{
*
* File: nested2.sml
* Author: Manfred Jeusfeld
* Creation: 30-Jun-2004 (11-Jul-2008)
* ----------------------------------------------------------------------
* A variant of nested.sml which shows that complex query expressions
* can also be used in formulas. Quite useful for cardinality checks!
* Ask query EmployeeWith2RichCoworkers. It should return 'bill'.
* The query EmployeeWithXRichCoworkers allows to retrieve employees
* with a specfied number of rich co-workers.
*
* Requires ConceptBase 6.1 or later. The shorter query versions 
* supported by ConceptBase 7.1 are included as comments. 
}


Employee in Class with
  attribute
    salary: Integer;
    worksWith: Employee
end

GenericQueryClass EmployeewithSalaryAbove isA Employee with
  parameter
    minsal: Integer
  constraint
    c1: $ exists s/Integer (~this salary s) and (s >= ~minsal) $
end

GenericQueryClass RichCoworker isA EmployeewithSalaryAbove[1000/minsal] with
  parameter
    worker: Employee
  constraint
    c2: $ (~worker worksWith ~this) $
end


QueryClass EmployeeWith2RichCoworkers isA Employee with
  constraint
    c2: $ exists i/Integer (i in COUNT[RichCoworker[~this/worker]/class]) and (i = 2)$
end

{* shorter form in ConceptBase 7.1:
QueryClass EmployeeWith2RichCoworkers isA Employee with
  constraint
    c2: $ (#RichCoworker[this] = 2)$
end
*}

GenericQueryClass EmployeeWithXRichCoworkers isA Employee with
  parameter,computed_attribute
    no_coworkers: Integer
  constraint
    c2: $ (~no_coworkers in COUNT[RichCoworker[~this/worker]/class]) $
end

{* shorter form in ConceptBase 7.1:
GenericQueryClass EmployeeWithXRichCoworkers isA Employee with
  parameter,computed_attribute
    no_coworkers: Integer
  constraint
    c2: $ (no_coworkers = #RichCoworker[~this]) $
end
*}


mary in Employee with
  salary s: 1100
end

joan in Employee with
  salary s: 5100
end


bill in Employee with
  salary s: 500
  worksWith e1: mary;
            e2: joan
end

john in Employee with
  salary s: 800
  worksWith e1: mary
end
  


```

=== `nested.sml.txt`

```telos
{
*
* File: nested.sml
* Author: Manfred Jeusfeld
* Creation: 28-Jun-2004 (28-Jun-2004)
* ----------------------------------------------------------------------
* This example shows how to use complex query expressions,  i.e. queries
* with parameters that are themselves query calls witd parameters.
* 
}


Employee in Class with
  attribute
    salary: Integer;
    worksWith: Employee
end

GenericQueryClass EmployeewithSalaryAbove isA Employee with
  parameter
    minsal: Integer
  constraint
    c1: $ exists s/Integer (~this salary s) and (s >= ~minsal) $
end

QueryClass EmployeeWithRichCoworkers isA Employee with
  constraint
    c2: $ exists i/Integer e/EmployeewithSalaryAbove[1000/minsal] (~this worksWith e) $
end

mary in Employee with
  salary s: 1100
end

joan  in Employee with
  salary s: 5100
end


bill in Employee with
  salary s: 500
  worksWith m: mary
end
  

{*
Ask these queries with the method 'Ask Objname':
COUNT[EmployeewithSalaryAbove[1000/minsal]/class]
PLUS[COUNT[EmployeewithSalaryAbove[1000/minsal]/class]/r1,2/r2]
*}

```

=== `Organigraph.sml.txt`

```telos
{
*
* File: Organigraph.sml
* Author: Manfred Jeusfeld
* Creation: 29-Jun-2004 (27-Jan-2005)
* ----------------------------------------------------------------------
* This is the O-Telos representation organigraphs
* Some definitions like SetUnit2 are shorter realizations
* using complex functional expressions supported by ConceptBase 6.2.
* Since they are creating intermediate results of COUNT as
* objects, performance is significantly lower than for the
* originals. Another reason is that the predicates with functional
* expressions do not fully utilize the cache-based literal
* evaluator of ConceptBase.
*
* Requires ConceptBase 6.2 released 27-Jan-2005 or later.
*
}


Class Unit with
  attribute
    pushes: Unit;
    pushesTrans: Unit
end


{* Unit with a link to ~this unit *}
ToUnit in GenericQueryClass isA Unit with
  parameter
    unit: Unit
  constraint
    c1: $ (~unit pushes ~this) $
end

{* Unit with a link from ~this unit *}
FromUnit in GenericQueryClass isA Unit with
  parameter
    unit: Unit
  constraint
    c1: $ (~this pushes ~unit) $
end


SetUnit in QueryClass isA Unit with
  constraint
     c1: $ (
            exists s1,s2,s3/Unit (~this pushes s1) and (~this pushes s2) and
            (~this pushes s3) and not (s1 == s2) and not (s1 == s3) and
            not (s2 == s3)
            ) and
            ( 
             forall t1,t2/Unit (t1 pushes ~this) and (t2 pushes ~this)
              ==> (t1 == t2)
             ) and
            (exists t/Unit (t pushes ~this))
          $
end



SetUnit2 in QueryClass isA Unit with
  constraint
     c1: $ (COUNT[ToUnit[~this/unit]/class] >= 2) and
           (COUNT[FromUnit[~this/unit]/class] = 1)
         $
end



HubUnit in QueryClass isA Unit with
  constraint
     c1: $ (
            exists s1,s2/Unit (~this pushes s1) and (~this pushes s2) 
            and not (s1 == s2) 
            ) and
            ( 
           exists t1,t2/Unit (t1 pushes ~this) and (t2 pushes ~this) 
            and not (t1 == t2) 
             ) $
end

HubUnit2 in QueryClass isA Unit with
  constraint
     c1: $ (COUNT[ToUnit[~this/unit]/class] >= 2) and
           (COUNT[FromUnit[~this/unit]/class] >= 2)
         $
end


ChainUnit in QueryClass isA Unit with
  constraint
     c1: $ (
            exists s/Unit (s pushes ~this) 
            ) and
            (
            exists t/Unit (~this pushes t) 
            ) and
            ( forall s1,s2/Unit (s1 pushes ~this) and (s2 pushes ~this) ==> (s1 == s2) ) and
            ( forall t1,t2/Unit (~this pushes t1) and (~this pushes t2) ==> (t1 == t2) ) 
          $
end

ChainUnit2 in QueryClass isA Unit with
  constraint
     c1: $ (COUNT[ToUnit[~this/unit]/class] = 1) and
           (COUNT[FromUnit[~this/unit]/class] = 1)
         $

end

ChainStartUnit in QueryClass isA Unit with
  constraint
     c1: $ not (~this in ChainUnit) and
           exists s/ChainUnit (~this pushes s) $
end

ChainEndUnit in QueryClass isA Unit with
  constraint
     c1: $ not (~this in ChainUnit) and
           exists s/ChainUnit (s pushes ~this) $
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




                       

                       









```

== Shell output

```text
=== HOW-TO: formulate-query-calls-with-other-queries-as-parameters ===

>>> Telling ./Organigraph.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./nested.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./nested2.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
