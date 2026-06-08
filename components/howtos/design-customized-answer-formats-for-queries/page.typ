= Design Customized Answer Formats For Queries

Verified independently via:

```bash
nix build .#checks.x86_64-linux.design-customized-answer-formats-for-queries
```

== Input

=== `csv.sml.txt`

```telos
{*
* File: csv.sml
* Author: Manfred A. Jeusfeld, Tilburg University
* Date: 16-Mar-2006 (11-Nov-2010/M.Jeusfeld)
* --------------------------------------------------------
* Comma-separated values with answer formats. Shows how to
* check whether the first or last frame is currently processed
* in the answer format. Depending on the outcome, different
* strings are inserted to the output stream.
*
* Requires ConceptBase 6.2 released 21-Mar-2006 or later.
*}


Class Person with 
  attribute
    parent: Person;
    age: Integer
end

{* a simple query class *}

QueryClass PersonQuery isA Person with
  retrieved_attribute
     parent: Person;
     age: Integer
   constraint
     c1: $ exists a/Integer (~this age a) and (a > 10) $
end

{* Special characters used in this answer format:   *}
{*   \( = left parenthesis                          *}
{*   \) = right parenthesis                         *}
{*   \, = a comma like in ','                       *}
{*   \0 = empty string ''                           *}
{* Note that the boolean predicates ISFIRSTFRAME()  *}
{* and ISLASTFRAME() are called with empty argument *}
{* list. Also note that IFTHENELSE has three        *}
{* arguments: the boolean predicate, the THEN       *}
{* string (to be printed when the boolean predicate *}
{* is true), and the ELSE string.                   *}

AnswerFormat PersonFormat3 with
   forQuery q: PersonQuery
   order o: descending
   orderBy ob: "this.age"
   pattern p: 
"{IFTHENELSE({ISFIRSTFRAME()},\(,\0)}{this} is aged {this.age}{IFTHENELSE({ISLASTFRAME()},\),\, )}"
end



{* even simpler query: retrieve all ages of persons *}
QueryClass AgeList isA Integer with
   constraint
     c1: $ exists p/Person (p age ~this) $
end

{* format the answer to AgeList as a comma-separated list *}
AnswerFormat AgeCSVFormat with
   forQuery q: AgeList
   order o: ascending
   orderBy ob: "this"
   pattern p: 
"{this}{IFTHENELSE({ISLASTFRAME()},\0,\, )}"
end



{* a database for the example *}

Person Mary with
  age a: 14
  parent mother: Charlotte; 
         father: Frederic
end

Person Charlotte with
  age a: 34
  parent father: Albert
end

Person Frederic end

Person Albert end

Person Bill with 
  age a: 16
  parent mother: Charlotte;
         stepfather: John;
         father: Albert
end

Person John with
 age a: 43
end


```

=== `externalcall.sml.txt`

```telos
{*
* File: externalcall.sml
* Author: Manfred Jeusfeld, Tilburg University
* Date: 7-Aug-2001
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

AnswerFormat EmpDeptFormatWithExternalCall with
   forQuery q: EmpDept
   head h: "The current time is {CURRENTTIME()}.
This is a list of employees who earn very little.

employee  |  dept      | head of dept
"
   pattern p:
"{this} | {STRINGDECODING({this.dept.name})} | {this.dept.head}
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






```

=== `FunctionsWithIDs.sml.txt`

```telos

QueryClass FunctionwithID isA Function end

AnswerFormat FID_Format with
   forQuery q: FunctionwithID
   order o: ascending
   orderBy ob: "this"
   head h: 
"Name   ID
-------------------------------------------------
"
  pattern p:
"{this}   {this.oid}
"
  tail t:
"-- end of answer"
end

```

=== `iterations2.sml.txt`

```telos
{*
* File: iterations2.sml
* Author: Manfred A. Jeusfeld, Tilburg University
* Date: 30-Sep-2004
* --------------------------------------------------------
* A variant for iterations.sml that shows how to construct
* comma-separated lists like a,b,c.
* Note that the last element in a commaseparated list is NOT
* followed by a comma. This is technically achieved by a 
* 'backspace' character, denoted as \\b in the answer format.
* The Telos editor displays this as a special character
* but if you copy & paste the text into a text editor (like vi),
* the last comma should disappear.
* Not a totally satisfactory solution but it kinda works.
*}


Class Person with 
  attribute
    parent: Person;
    age: Integer
end

{* a simple query class *}

QueryClass PersonWithParents3 isA Person with
  retrieved_attribute
     parent: Person;
     age: Integer
   constraint
     c1: $ exists a/Integer (~this age a) and (a > 10) $
end


{* answer format using Foreach *}

AnswerFormat PersonFormat3 with
   forQuery q: PersonWithParents3
   order o: ascending
   orderBy ob: "this"
   head h: 
"<html>These are the persons together with their parents:
<OL>
"
  pattern p:
"<LI> {this} is {this.age} years old. Parents: {Foreach( ({this.parent}),(p), {p}\,)}\\b.
"
  tail t: "</OL>"
end



{* a database for the example *}

Person Mary with
  age a: 14
  parent mother: Charlotte; 
         father: Frederic
end

Person Charlotte with
  age a: 34
  parent father: Albert
end

Person Frederic end

Person Albert end

Person Bill with 
  age a: 16
  parent mother: Charlotte;
         stepfather: John;
         father: Albert
end

Person John with
 age a: 43
end
```

=== `iterations.sml.txt`

```telos
{*
* File: iterations.sml
* Author: Manfred A. Jeusfeld, Tilburg University
* Date: 2-Aug-2001
* --------------------------------------------------------
* here: use of Foreach
*}


Class Person with 
  attribute
    parent: Person;
    age: Integer
end

{* a simple query class *}

QueryClass PersonWithParents3 isA Person with
  retrieved_attribute
     parent: Person;
     age: Integer
   constraint
     c1: $ exists a/Integer (~this age a) and (a > 10) $
end


{* answer format using Foreach *}

AnswerFormat PersonFormat3 with
   forQuery q: PersonWithParents3
   order o: ascending
   orderBy ob: "this"
   head h: 
"<html>These are the persons together with their parents:
<OL>
"
  pattern p:
"<LI> {this} is {this.age} years old {Foreach( ({this.parent},{this|parent}),(p,r), and {p} is {r} of {this})}.
"
  tail t: "</OL>"
end



{* a database for the example *}

Person Mary with
  age a: 14
  parent mother: Charlotte; 
         father: Frederic
end

Person Charlotte with
  age a: 34
  parent father: Albert
end

Person Frederic end

Person Albert end

Person Bill with 
  age a: 16
  parent mother: Charlotte;
         stepfather: John;
         father: Albert
end

Person John with
 age a: 43
end




  

```

=== `P-tuple.sml.txt`

```telos
{*
* File P-Tuple.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 7-Sep-2005 (7-Sep-2005)
*----------------------------------------------------------------
* Prints the P-tuple for a given object name.
* Source and destinations are displayed as object names (not id's).
* P-tuples are writted here as
*    id=<source,label,destination>
* instead of P(id,source,label,destination)
*
*}



GenericQueryClass ObjectAsPTuple isA Proposition with
  parameter
     object: Proposition
   computed_attribute
     source: Proposition;
     label: Label;
     destination: Proposition
  constraint
    c: $ UNIFIES(~this,~object) and P(~this,~source,~label,~destination) $
end

AnswerFormat Ptuple_Format with
   forQuery q: ObjectAsPTuple
   order o: ascending
   orderBy ob: "this"

  pattern p:
"{this.oid}=<{this.source},{this.label},{this.destination}>
"

end
```

=== `recursive-answers-1.sml.txt`

```telos
{* 
* File: recursive-answers-1.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 16-Mar-2005
* Purpose: Shows how to have answers that contain recursively composed objects;
* assigns layout dynamically depending on the structure of an object
* Note: the query PersonQ has two answer formats assigned to it. When
* calling the query, ConceptBase has to select one for the top level
* object ~p. Since PersonLayoutChildren is defined first, it will be
* selected but that is purely incidental. A query around PersonQ which calls
* PersonQ would avoid this.
*}


Class Person with
  attribute
    hasChild: Person
end



Person Adam with
  hasChild
    c1: Kain;
    c2: Abel;
    c3: Seth
end


Person Abel with
  hasChild
    c1: Abraham;
    c2: Lea
end

Person Abraham with
  hasChild
    c1: Isaak;
    c2: Ismael
end

Person Seth with
  hasChild
    c1: Lot
end

Person Kain with
end

Person Lea with
end

Person Isaak with
end

Person Ismael with
end

Person Lot with
end


View PersonQ isA Person with
  parameter
    p: Person
  inherited_attribute
    hasChild: Person
  constraint
    c: $ UNIFIES(~p,~this) $
end


{* answer format for persons that have a child *}
{* the ASKquery of WhatLayout computed the     *}
{* answer format to be applied to the query    *}
{* ASKquery(PersonQ...).                       *}

AnswerFormat PersonLayoutChildren with
  forQuery fq: PersonQ
  order o: ascending
  orderBy ob: "this"

  pattern pt:
    "<person>{this}
<children>
{Foreach(({this.hasChild}),(s),{ASKquery(PersonQ[{s}/p],{ASKquery(WhatLayout[{s}/pers],LABEL)})})}</children>
</person> /* {this} */"
end

{* answer format for persons without children *}
AnswerFormat PersonLayoutNoChildren with
  forQuery fq: PersonQ
  order o: ascending
  orderBy ob: "this"

  pattern pt:
    "<person>{this}</person>"
end

GenericQueryClass WhatLayout isA AnswerFormat with
  parameter
    pers: Person
  constraint
     c1: $ (exists ch/Person (~pers hasChild ch) and UNIFIES(~this,PersonLayoutChildren)) or
               ( (not exists chx/Person (~pers hasChild chx) ) and UNIFIES(~this,PersonLayoutNoChildren)) 
           $
end



```

=== `recursive-answers.sml.txt`

```telos
{* 
* File: recursive-answers.sml
* Author: Manfred Jeusfeld, jeusfeld@kub.nl
* Date: 2-Aug-2001
* Purpose: Shows how to have answers that contain recursively composed objects
*}


Class Person with
  attribute
    hasChild: Person
end



Person Adam with
  hasChild
    c1: Kain;
    c2: Abel;
    c3: Seth
end


Person Abel with
  hasChild
    c1: Abraham;
    c2: Lea
end

Person Abraham with
  hasChild
    c1: Isaak;
    c2: Ismael
end

Person Seth with
  hasChild
    c1: Lot
end

Person Kain with
end

Person Lea with
end

Person Isaak with
end

Person Ismael with
end

Person Lot with
end



View PersonQ isA Person with
  parameter
    p: Person
  inherited_attribute
    hasChild: Person
  constraint
    c: $ UNIFIES(~p,~this) $
end


AnswerFormat PersonLayout with
  forQuery fq: PersonQ
  order o: ascending
  orderBy ob: "this"

  pattern pt:
    "
    <person>{this}
      <children>
      {Foreach(({this.hasChild}),(s),{ASKquery(PersonQ[{s}/p],PersonLayout)})}
      </children>
    </person>
     "
end



```

== Shell output

```text
=== HOW-TO: design-customized-answer-formats-for-queries ===

>>> Telling ./FunctionsWithIDs.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./P-tuple.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./csv.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./externalcall.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./iterations.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./iterations2.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./recursive-answers-1.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./recursive-answers.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./simple_answerformats1.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./simple_answerformats2.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./views.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
