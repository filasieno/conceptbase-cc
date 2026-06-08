= Materialize Query Results As Files

Verified independently via:

```bash
nix build .#checks.x86_64-linux.materialize-query-results-as-files
```

== Input

=== `ERD-export.sml.txt`

```telos
{*
This file is governed by the Creative Commons license
   attributeion-NonCommercial 3.0 Unported
   http://creativecommons.org/licenses/by-nc/3.0/
   http://creativecommons.org/licenses/by-nc/3.0/legalcode

Extended licenses, in particular commercial licenses, can be obtained from the
author of the source code.
Any re-distribution as source code must acknowledge the original author of this file.
*}


{*
* File ERD-export.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 2011-02-23 (2011-02-23)
*----------------------------------------------------------------
* This file specifies the ERD notation and provides an
* export filter for graphviz. You need to install the GraphViz package.
* GraphViz contains several layout routines such as dot and neato.
* Use the manual pages of dot to learn more about options of GraphViz.
* GraphViz is available from 
*   http://graphviz.org/
*
* You can automate the generation of the dot files by starting the
* CBserver with the option -views <dir>, e.g.
*     CBserver -d ERDDB -views ERDEXPORT
* Afterwards, load this file and then shutdown the CBserver.
* The directory ERDEXPORT must exist and will then contain
* contain files <Model>.dot for each instance of ERDModel. 
*
* Translate the dot files via Graphviz, e.g.
*    dot -Tpng -o MyModel1.png MyModel1.dot
* 
* Requires ConceptBase 7.3.06 released 2011-02-21 or later.
*}



{*** NOTATION LEVEL       *}
{*** ER notation with cardinalities *}

EntityType with
  attribute
    attr: Domain;
    key: Domain;   {* some attributes are key attributes *}
    superType: EntityType  {* only used for defining the semaantics of the IsaType *}
end


RelationshipType with
  attribute
     role: EntityType
end

Domain with
end

RelationshipType!role with
  attribute
     card: Cardinality
end

IsaType in Class with
  attribute 
    sub: EntityType;
    super: EntityType
end

Cardinality  end

{* we support here just three cardinalities *}
"1..1" in Cardinality end
"0..1" in Cardinality end
"1..*" in Cardinality end

ERDElement end

EntityType isA ERDElement end
RelationshipType isA ERDElement end
IsaType isA ERDElement end
RelationshipType!role isA ERDElement end
IsaType!sub isA ERDElement end
IsaType!super isA ERDElement end

ERDModel in Class with
  attribute
    contains: ERDElement
  rule
    r1: $ forall e/EntityType m/ERDModel a/EntityType!attr
             (m contains e) and Ai(e,attr,a) ==> (m contains a) $;
    r2: $ forall e/IsaType m/ERDModel a/IsaType!sub
             (m contains e) and Ai(e,sub,a) ==> (m contains a) $;
    r3: $ forall e/IsaType m/ERDModel a/IsaType!super
             (m contains e) and Ai(e,super,a) ==> (m contains a) $;
    r4: $ forall e/RelationshipType m/ERDModel a/RelationshipType!role
             (m contains e) and Ai(e,role,a) ==> (m contains a) $
end




{*** MODEL LEVEL *}
{*** this defines an example ER diagram using the above ER notation *}



Employee in EntityType with   {* shall match variable ET1 *}
end

Project in EntityType with   {* ET2 *}
end

worksFor in RelationshipType with   {* RT *}
  role
   toEmp: Employee;
   toProj: Project
end

worksFor!toEmp with   {* R1 *}
  card
    card1: "1..*"  {* each project has at least 1 employee who works for it *}
end

worksFor!toProj with  {* R2 *}
  card
    card1: "0..1"   {* each employee works in at most 1 project *}
end

MyModel1 in ERDModel with
  contains
    e1: Employee;
    e2: Project;
    e3: worksFor
end




{* another ERD model *}

EntityType Staff with
  attr
    name: String;
    hired: Date;
    salary: Integer
  attr,key
   staffno: Integer
end

EntityType Faculty with
  attr
    since: Date;
    post: String
end

EntityType Technician with
  attr
    since: Date;
    post: String
end



EntityType Student with
  attr
    since: Date
  attr,key
    studentid: Integer
end


EntityType University with
  attr, key
   name: String;
   location: String
end

EntityType Course with
  attr,key
    courseno: Integer;
    semester: String
  attr
    title: String
end

RelationshipType employs with
  role
    employee: Staff
  role
    employer: University
end

IsaType ISA_1 with 
  sub
    sub1: Faculty
  super
     super1: Staff
end

IsaType ISA_2 with
  sub
    sub1: Technician
  super
    super1: Staff
end

RelationshipType teaches with
  role
    teacher: Faculty
  role
    subject: Course
end


RelationshipType attends with
  role
    stud: Student;
    course: Course
end



Domain Date
end

Domain String
end

Domain Integer
end

Domain Real
end

UniversityModel in ERDModel with
  contains
    e1: Staff;
    e2: Faculty;
    e3: Technician;
    e4: Student;
    e5: University;
    e6: Course;
    e7: employs;
    e8: teaches;
    e9: attends;
    e10: ISA_1;
    e11: ISA_2
end





{* Graphviz conversion *}

Boxnode in QueryClass isA EntityType end
Diamondnode in QueryClass isA ERDElement with
  constraint
     cd: $ (this in RelationshipType) or (this in IsaType) $
end
Link in QueryClass isA ERDElement with
  constraint
     cd: $ (this in RelationshipType!role) or (this in IsaType!sub) or (this in IsaType!super) $
end


GenericQueryClass FromNode isA Individual with
  parameter
     lnk: attributee
  constraint
     cfn: $ From(lnk,this) $
end

GenericQueryClass ToNode isA Individual with
  parameter
     lnk: attributee
  constraint
     cfn: $ To(lnk,this) $
end


GenericQueryClass ShowERD isA ERDModel with
  required,parameter
     erd: ERDModel
  computed_attribute
     boxnode: Boxnode;
     diamondnode: Diamondnode;
     link: Link
  constraint
     c1: $ (erd = this) and
           (this contains boxnode) and
           (this contains diamondnode) and
           (this contains link) $
end

GraphVizErd in AnswerFormat with
  forQuery q: ShowERD

  head h:
"graph ER \{
"

  pattern p:
"node [shape=box]; {Foreach( ({this.boxnode}), (n), {n};)}
node [shape=diamond]; {Foreach( ({this.diamondnode}), (d), {d};)}
{Foreach( ({this.link}),(l), {ASKquery(FromNode[{l}/lnk],LABEL)}--{ASKquery(ToNode[{l}/lnk],LABEL)};\\n)}
#label=\"ERD Model {this}\"
fontsize=10;
"

  tail t: "\}"

  fileType ty: "dot"
end



{* save ShowERD in this and all other (sub-)modules *}
Module in Class with
  rule
    rsaveView: $ forall m/Module (m saveView ShowERD) $
end
 




```

=== `extract-MyModel1.cbs.txt`

```telos
#
# File: extract-MyModel1.cbs
# Author: Manfred Jeusfeld, 23-Feb-2011
# Creative-Commons-License: attributeion-NonCommercial 3.0 Unported
# ------------------------------------------------------------
# Example for client side materialization of query results
# Usage:  CBshell -f extract-MyModel1.cbs > MyModel1.dot
#
startServer -u nonpersistent -t no
tellModel ERD-export
ask "ShowERD[MyModel1/erd]" OBJNAMES FRAME Now
showAnswer
exit


```

=== `SaveModelType.sml.txt`

```telos
{*
This file is governed by the Creative Commons license
   attributeion-NonCommercial 3.0 Unported
   http://creativecommons.org/licenses/by-nc/3.0/
   http://creativecommons.org/licenses/by-nc/3.0/legalcode

Extended licenses, in particular commercial licenses, can be obtained from the
author of the source code.
Any re-distribution as source code must acknowledge the original author of this file.
*}



{*
* File SaveModelType.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 2004-12-13 (2011-02-24)
*----------------------------------------------------------------
* Note, the option 'Use Query Result Window' must be disabled
* in CBiva to use SaveModel from within CBiva! The reason is that
* the resulting frames do not necessarily have the same structure.
* Comfort edition: provide a 'model' object that lists all
* the classes to be dumped.
* Example on how to use SaveModelSpecific:
*
* 1) Tell a container object that lists all classes to be dumped
*        MyModelClasses in Model with
*          attribute
*            c1: EntityType;
*            c2: RelationshipType
*            c3: RelationshipType!role
*        end
*
* 2) Ask SaveModelType[MyModelClasses/modeltype]
* ==> all instances of the three classes will be dumped and can then
* be saved.
*
* 3) Remove by hand generated attributes :
*   applyRuleIf*, applyConstraintIf*, *generated
*
* This is derived from SaveModel.sml which is more generic by allowing to
* dump the instances of any proposition.
* 
*
*}

Model end  {* instances are actually model types such as ERD, DFD etc. *}

NotToSave in QueryClass isA Proposition with 
  constraint
    cnts: $ 
            (~this in MSFOLassertion) or (~this in BDMRuleCheck) or
            (~this in BDMConstraintCheck) or
            ( not (~this in Individual) and
                 (forall x/Proposition ((~this attribute x) ==> (x in NotToSave)) 
                                       and not Isa_e(~this,x)
                 )
            )
          $
end


SaveModelType in GenericQueryClass isA Proposition with 
  attribute,parameter
     modeltype : Model
  computed_attribute
     memberclass: Proposition
  attribute,constraint
     r : $ UNIFIES(~this,~modeltype) and 
               ( (~modeltype attribute ~memberclass) or
                 UNIFIES(~modeltype,~memberclass)
               ) $
end 



SaveTelosFrames in GenericQueryClass isA Proposition with 
  attribute,parameter
     class : Proposition
  attribute,constraint
     r : $ (~this in ~class) and not (~this in NotToSave) $ 
end 


AnswerFormat SaveModelTypeLayout with
  forQuery fq: SaveModelType
  head h: "\{* 
"
  pattern pt:
"* Telos frames for model type {this}
*\}

\{* Definition of the classes to be dumped *\}
{Foreach(({this.memberclass}),(a),{ASKquery(get_object[{a}/objname],FRAME)})}


\{* Advance definition of all instances (without attribute listing) *\}

{Foreach(({this.memberclass}),(a),{ASKquery(SaveTelosFrames[{a}/class],FrameSaveOnlyObject)})} 


\{* Instances with all their properties *\}

{Foreach(({this.memberclass}),(a),{ASKquery(SaveTelosFrames[{a}/class],FrameSaveComplete)})} 

"
  tail t: "\{* ======== end ========= *\}"
  fileType ty: "sml"
end


AnswerFormat FrameSaveComplete with
  pattern pt:"\{* {this.oid}: *\}
{ASKquery(get_object[{this}/objname],FRAME)} "
end

AnswerFormat FrameSaveOnlyObject with
  pattern pt:"{this} end
"
end


{* activate model saving for any module *}

Module in Class with
  rule
    rsameModelType: $ forall m/Module (m saveView SaveModelType) $
end
 




```

=== `SaveViews-simple.sml.txt`

```telos
{*
This file is governed by the Creative Commons license
   attributeion-NonCommercial 3.0 Unported
   http://creativecommons.org/licenses/by-nc/3.0/
   http://creativecommons.org/licenses/by-nc/3.0/legalcode

Extended licenses, in particular commercial licenses, can be obtained from the
author of the source code.
Any re-distribution as source code must acknowledge the original author of this file.
*}


{*
* File: SaveViews-simple.sml
* Author: Manfred Jeusfeld, Tilburg University
* Date: 21-Feb-2011
* ---------------------------------------------------------------------
* shows how to save views of queries that have no parameter
*}

Class Employee with
  attribute
    name: String;
    dept: Department;
    salary: Integer
end

Class Manager isA Employee end

Class Department with
  attribute
     head: Manager;
     name: String;
     budget: Integer
end


View EmpDept isA Employee with
  inherited_attribute
     salary: Integer
  retrieved_attribute,partof
     dept: Department with
              retrieved_attribute
                  head: Manager;
                  name: String
           end
  constraint
     ce: $ exists s/Integer (~this salary s) and (s < 10000) $
end

AnswerFormat EmpDeptFormat with
   forQuery q: EmpDept
   head h: "This is a list of employees who earn very little.

employee  |  dept      | head of dept
"
   pattern p:
"{this} | {UQ({this.dept.name})} | {this.dept.head}
"
end

Employee E1 with 
  name n: "Willi S"
  dept d: D1
  salary s: 5000
end

Employee E2 with 
  name n: "Peter S"
  dept d: D1
  salary s: 35000
end

Employee E3 with 
  name n: "Carl S"
  dept d: D2
  salary s: 8000
end

Manager M1 end
Manager M2 end

Department D1 with
  head h: M1
  name n: "Sales and Service"
  budget bg: 560
end

Department D2 with
  head h1: M1; h2: M2
  name n: "Production"
  budget bg: 560
end


{* save these query results in this and all other (sub-)modules *}
Module in Class with
  rule
    rsaveView: $ forall m/Module (m saveView EmpDept) $
end






```

== Shell output

```text
=== HOW-TO: materialize-query-results-as-files ===

>>> Running ./extract-MyModel1.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>
>>> Telling ./ERD-export.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./SaveModelType.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./SaveViews-simple.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
