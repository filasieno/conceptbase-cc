= Define Co Variant Specialization

Verified independently via:

```bash
nix build .#checks.x86_64-linux.define-co-variant-specialization
```

== Input

=== `Employees.sml.txt`

```telos
{
* File: Employees.sml.txt
* Author: Manfred Jeusfeld
* Created: 2024-11-02/M.Jeusfeld (2024-11-04/M.Jeusfeld)
* ------------------------------------------------------
* FTelos specification for the Employees example in the MMM Seminar
*
* License: Creative Commons license
   attributeion-ShareAlike 4.0 International
   http://creativecommons.org/licenses/by-sa/4.0/
   http://creativecommons.org/licenses/by-sa/4.0/legalcode
*
}

{* --------------------------- *}
{* Some definitions to support *}
{* a UML-style visualization.  *}
{* Not essential, just useful. *}
{* --------------------------- *}


Element end  {* to subsume objects and classes *}


{* to distinguish values/value types from objects/classes *}
DataType end 

Value end 

Integer in DataType isA Value  end 

String in DataType isA Value  end 

Real in DataType isA Value  end 

Boolean in DataType isA Value  end 

ValueOrDataType in QueryClass isA Individual with 
   constraint
    c1d : $ (this in Value) or (this in DataType) $
end 

ProperElement in QueryClass,MSFOLrule isA Element with 
   constraint
    c1a : $ not (this in QueryClass) and not (this in MSFOLassertion) and exists a/attributee y/ValueOrDataType From(a,this) and To(a,y) $
end 


{* classical attribute definitions as opposed to associations *}

Elementattributee in QueryClass,MSFOLrule isA attributee with
   constraint
     c2a: $ exists o/Element t/DataType From(this,o) and To(this,t) $
end


ElementWithattributees in GenericQueryClass isA ProperElement with 
   parameter,computed_attribute
    class : ProperElement
  computed_attribute
    attrs : Proposition!attribute
  constraint
    c3 : $ exists n/Label b/ValueOrDataType Pa(~attrs,this,n,b) and (this = ~class) $
end 

{---} { 2023-03-01,19:41:48.704 }

ElementFormat in AnswerFormat with 
   forQuery
    q : ElementWithattributees
  order
    o : ascending
  orderBy
    ob : "this"
  pattern
    p : "[b]{UQ({this})}[/b][hr][/hr]{Foreach( ({this.attrs}),(p), {LabelAC({p})}: {UQ({To({p})})}[br][/br] )}"
end 

LabelRules in Class with 
   rule
    lr1 : $ forall x/ProperElement lab/Label (lab = resultOf(ElementWithattributees,x,ElementFormat)) ==> (x gproperty/label lab) $;
    lr2 : $ forall x/ProperElement lab/Label (x gproperty/size "wrap") $;
    lr3 : $ forall x/ProperElement lab/Label (x gproperty/labellength 800) $;
    lr4 : $ forall x/ProperElement (x gproperty/font "Arial") $
end 


{* to make life easier below *}
Object isA Element end
M1_Class in Class isA Element,Class with
  rule
    objectrule : $ forall c/M1_Class x/Proposition (x in c) ==> (x in Object) $
end


{---}




{* ------------------------------ *}
{* now starts the Employees model *}
{* ------------------------------ *}


Project in M1_Class with
  attribute
    projid: String;
    budget: Integer
end


HighLevelProject in M1_Class isA Project with
  constraint
    highbudjetconstraint: $ forall p/HighLevelProject x/Integer (p budget x) ==> (x >= 1000000) $
end

Employee in M1_Class with
  attribute
    name: String;
    salary: Integer;
    project: Project
end

Manager in M1_Class isA Employee with
  attribute
    position: String;
    project: HighLevelProject
end

Employees in M1_Class with
  attribute
    member: Employee
end

{---}

p1 in Project with
  projid projid: "P1001"
  budget budget: 100000
end

p2 in Project with
  projid projid: "P2001"
  budget budget: 500000
end

{---}

bill in Employee with
  name name: "William"
  project project: p1
end

mary in Manager with
  name name: "Mary"
  position position: "CEO"
end

{* this one fails:

mary in Manager with
  project project: p2
end
*}

p3 in HighLevelProject with
  projid projid: "P3001"
  budget budget: 1500000
end

mary in Manager with
  project project: p3
end






```

=== `Nixon.sml.txt`

```telos
{
* File: Nixon.sml.txt
* Author: Manfred Jeusfeld
* Created: 2025-07-13/M.Jeusfeld (2025-07-13/M.Jeusfeld)
* ------------------------------------------------------
* Telos specification for the Employees example using multiple specialization
*
* License: Creative Commons license
   attributeion-ShareAlike 4.0 International
   http://creativecommons.org/licenses/by-sa/4.0/
   http://creativecommons.org/licenses/by-sa/4.0/legalcode
*
}


{ 2025-07-13,11:05:23.862 }

Employee in Class with 
   attribute
    salary : Integer;
    project : Project
end 

Project in Class with 
   attribute
    budget : Integer
end 

{---} { 2025-07-13,11:05:23.950 }

HighLevelProject in Class isA Project with 
   constraint
    minimumbudget : $ forall p/HighLevelProject b/Integer
    (p budget b) ==> (b > 1000000) $
end 

Manager in Class isA Employee with 
   attribute
    project : HighLevelProject
end 

Manager!project isA Employee!project  end 

{---} { 2025-07-13,11:05:24.039 }

Researcher in Class isA Employee with 
   attribute
    project : ResearchProject
end 

ResearchProject in Class  end 

Researcher!project isA Employee!project  end 

ResearchProject in Class isA Project  end 

{---} { 2025-07-13,11:05:24.126 }

ResearchManager in Class isA Researcher,Manager with 
   attribute
    project : HighLevelResearchProject
end 

HighLevelResearchProject in Class  end 

ResearchManager!project isA Employee!project  end 

ResearchManager!project isA Manager!project  end 

ResearchManager!project isA Researcher!project  end 

HighLevelResearchProject in Class isA HighLevelProject,ResearchProject  end 

{---} { 2025-07-13,11:05:24.219 }

mary in ResearchManager with 
   project
    p1 : LLMExtraDry
end 

LLMExtraDry in HighLevelResearchProject with 
   budget
    b1 : 2000000
end 

{ -/- }


```

== Graph files

- `employees.gel`
- `Nixon.gel`

== Shell output

```text
=== HOW-TO: define-co-variant-specialization ===

>>> Telling ./Employees.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./Nixon.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
