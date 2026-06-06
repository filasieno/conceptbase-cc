= Introduction
<introduction>
This tutorial extends the first tutorial by examples on metamodeling,
i.e. to scenarios where you define objects, classes, and meta classes.
Metamodeling is particularily useful in situations where you need to
define your own modeling languages (domain-specific languages). You will
see that you can use the ConceptBase query language to analyze the
models created in your dedicated modeling languages and that it is
rather easy to define simple modeling languages. Solutions to the
exercises are at the end of this tutorial.

==  The Scenario 
<the-scenario>
We start with a simple version of entity-relationship diagrams. First,
we will define entity types and relationship types (meta classes). Then,
define an example entity-relationship diagram (classes) plus some
example data (objects).

In the next part, we add a simple process language to the existing
entity-relationship language. We are interested in analyzing process
models. In particular, we want to check whether one agent is responsible
for two tasks t1 and t2, and there is a task t on the path between t1
and t2 that is assigned to another agent.

== Start ConceptBase
<start-conceptbase>
There are several methods to start the ConceptBase server and its user
interface CBIva. We decide for the simplest way: start the ConceptBase
server from within CBIva. So, switch to the directory to which
ConceptBase is installed on your computer and start the ConceptBase.cc
user interface CBiva:

   cbiva

On Windows and Mac OS-X you can also start CBIva by double-clicking on
the command file cbiva\[.bat\] in the directory where you installed
ConceptBase.

#figure(image("../assets/cbiva1.png", width: 10cm),
  caption: [
    CBIva just after starting it
  ]
)
<fig:cbiva1>

Figure #raw("fig:cbiva1") shows the CBIva window just after starting it. If the
indicator on the buttom left corner is green and has the label
\"Connected\", then your CBIva client is auto-connected to a ConceptBase
server. If it is red and displays \"Disconnected\", then the CBIva is
not yet connected to a ConceptBase server. Press the \"connect\" icon
just below the \"File\" menu in such cases to start/connect to a local
ConceptBase server.

= Define a simple Entity-Relationship notation
<define-a-simple-entity-relationship-notation>
#quote(block: true)[
*Exercise 1:* The task is to define two classes #raw("EntityType") and
#raw("RelationshipType"). The class #raw("RelationshipType") shall have an attribute
#raw("role") with value #raw("EntityType").
]

EntityType end

RelationshipType with
  attribute
     role: EntityType
end

Enter the definitions into the _Telos Editor_ window and store them
to the ConceptBase server with the \"Tell\" function.

#quote(block: true)[
*Exercise 2:* Add to #raw("EntityType") an attribute #raw("attr") with value
#raw("Domain"). Also define #raw("Domain") as an object without attributes.
]

EntityType with
  attribute
    attr: Domain
end

Domain end

This provides us with a very simple entity-relationship language. It
just allows to define entity types with attributes, and relationship
types with role links. Entity attributes are restristed to domains. So
we need to specify the allowed domains.

#quote(block: true)[
*Exercise 3:* Specify #raw("Integer") and #raw("String") as domains, i.e. as
instances of the class #raw("Domain").
]

```
Integer in Domain end
String in Domain end

The classes #raw("Integer") and #raw("String") are predefined in ConceptBase. Any
integer number occurring in an object definition will automatically be
an instance of #raw("Integer"). Likewise any double-quoted string will be
regarded as an instance of #raw("String").

#quote(block: true)[
*Exercise 4:* Specify a new domain #raw("Date"). Include \"2009-05-19\"
and \"2001-01-01\" as two possible values for dates.
]

Date in Domain end
"2009-05-19" in Date end
"2001-01-01" in Date end

The object #raw("Date") is not predefined in ConceptBase. Hence, we need to
take care ourselves about the set of possible values (=instances of
#raw("Date")).

After these exercises, you can visualize the current state with the
graph editor. User #raw("RelationshipType") as start object. The graph editor
is started from CBIva via the menu item \"Browse / Graph Editor\".
Expand the outgoing attributes of #raw("RelationshipType") (right mouse
button) and select \"Show all\". Do the same with #raw("EntityType"). For
#raw("Domain"), show the instances. For #raw("Date"), show the instances as well.

#figure(image("../assets/cbiva3.png", width: 10cm),
  caption: [
    Graphical display of the ER language
  ]
)
<fig:cbiva3>

The graph window shows already three abstraction levels: the objects
\"2009-05-19\" and \"2001-01-01\" are at the lowest abstraction level
(data level). The objects #raw("Date"), #raw("Integer"), and #raw("String") are classes
(model level), and the objects #raw("RelationshipType"), #raw("EntityType"), and
#raw("Domain") are meta classes (notation level).

= Define an Entity-Relationship model
<define-an-entity-relationship-model>
#quote(block: true)[
*Exercise 5:* Specify an example ER diagram for an insurance
scenario. An insurance policy has a customer, a premium, a start date,
and an end date. Customers have names and addresses. A claim has a
description and is referring to an insurance policy.
]

Customer in EntityType with
  attr
    name: String;
    address: String
end

Policy in EntityType with
  attr
   startdate: Date;
   enddate: Date;
   premium: Integer
end

holds in RelationshipType with
  role
    customer: Customer;
    policy: Policy
end

Claim in EntityType with
  attr
    description: String
end

claim_policy in RelationshipType with
  role
    claim: Claim;
    policy: Policy
end

Figure #raw("fig:cbiva4") graphically displays the insurance model. ConceptBase
can also assign dedicated graphical symbols to certain objects, e.g.
diamond shapes to relationship types. We skip this feature in this
tutorial and refer you to the user manual for more details on this.

The green links are instantiations. Hence the insurance model is one
abstraction level below the ER language.

#figure(image("../assets/cbiva4.png", width: 10cm),
  caption: [
    The insurance model as instantiation of the ER language
  ]
)
<fig:cbiva4>

= Enter data for the insurance model
<enter-data-for-the-insurance-model>
#quote(block: true)[
*Exercise 6:* Enter data objects for the following facts.
Customer #raw("mary") signed an insurance policy with start date
\"2009-05-19\" (no end date). The premium is 1000.
]

mary in Customer end
policy1 in Policy with
  startdate d: "2009-05-19"
  premium p: 1000
end

holds1 in holds with
  customer c: mary
  policy p: policy1
end

#figure(image("../assets/cbiva5.png", width: 10cm),
  caption: [
    Sample data for the insurance model
  ]
)
<fig:cbiva5>

The display of the data objects in figure #raw("fig:cbiva5") completes all
three abstraction levels (meta classes, classes, data objects).

= Define a process modeling notation
<define-a-process-modeling-notation>
Process models can be used to denote workflows, business processes, and
algorithms. We are in particular interested in a process modeling
notation that allows us to analyze process models for certain patterns.
Before we start defining the notation, we define the

that shall be useful subsequently for defining the pattern.

Proposition in Class with
  attribute
    transitive: Proposition
  rule
    trans_R: \$ forall x,y,z,R/VAR
                      AC/Proposition!transitive C/Proposition
                     P(AC,C,R,C) and (x in C) and (y in C) and (z in C) and
                     A_e(x,R,y) and (y R z) ==> (x R z) \$
end

The predicate #raw("A_e(x,R,y)") is true if there is an explicit attribute
between objects #raw("x") and #raw("y") that has the category #raw("R").

#quote(block: true)[
*Exercise 7:* Define a process notation that allows tasks to be
defined. Tasks can have successor tasks. Agents execute tasks. The
successor relation shall be transitive.
]

Task with
  attribute,transitive
     successor: Task
end

Agent with
   attribute
     executes: Task
end 

The process modeling notation is very simple but it has the ability to
represent very complex workflows. Let now distinguish start statements
and predicate statements.

#quote(block: true)[
*Exercise 8:* A start statement is a task that has no predecessor
(no task has a start statement as sucessor). A predicate statement is a
task that has more than one successor. Define these concepts as query
classes.
]

StartStatement in QueryClass isA Task with
  constraint
    c1: $ not exists t/Task (t successor this) $
end

PredicateTask in QueryClass isA Task with
  constraint
    c1: $ exists s1,s2/Task A_e(this,successor,s1) and
          A_e(this,successor,s2) and (s1 \= s2) $
end

You can define end statements in a similar way. A more tricky concept is
the following.

#quote(block: true)[
*Exercise 9 (difficult):* Define the concept of a loop task, i.e.
a task that is part of a loop. The name of the query shall be
#raw("LoopTask").
]

LoopTaskOf in GenericQueryClass isA Task with
  parameter
    rep: Task 
  constraint
    c: $ (this successor rep) and (rep successor this) and
         (exists s/Task A_e(rep,successor,s) and (s successor rep)) $
end

LoopTask in QueryClass isA LoopTaskOf 
end

The parameter #raw("rep") in the first query stands a representative of a
loop. Note that there may be many loops inside a process model and we
would like to be able to query, which tasks belong to the same loop. The
second query just returns all loop statements regardless of the
representative. It is sufficient to leave out a value for parameter
#raw("rep") in this case.

There can be several loops inside a process model. Loops can also be
nested, i.e. a task can be member of several loops. Note that the
regular attribution predicate #raw("(t1 successor t2)") is closed under
transitivity!

Now that we have defined loops, let us tackle the pattern \"agent with
split responsibility\".

#quote(block: true)[
*Exercise 10 (difficult):* Assume that an agent A is responsible
for tasks t1 and t2 in a process model but there is a task t between t1
and t2 that is executed by another agent. This matches situations where
an agent does some work, then passes control to another agent, and
afterwards resumes control. Define this patterns as a query class named
#raw("AgentWithSplitResponsibility") that returns agents with split
responsibility.
]

AgentWithSplitResponsibility in QueryClass isA Agent with
   constraint
     c1: $ exists t1,t2,t/Task a/Agent (this executes t1) and
              (this executes t2) and (t1 successor t) and
              (t successor t2) and (a executes t) and (a \= this)$
end

The condition #raw("(a ")$without$#raw("= this)") makes sure that the middle task
#raw("t") is executed by a different agent.

= Define an example process model
<define-an-example-process-model>
Recall the insurance scenario. Now we need to represent a workflow in
this domain with our newly defined process modeing notation.

#quote(block: true)[
*Exercise 11:* Claim handling starts with an insurance agent
receiving the claim. Afterwards, the policy is checked. Afterwards,
either a payment is proposed or an assessor is assigned. The assessor
assesses the damage. On that basis, the insurance agent proposes a
payment. After proposing the payment, we either can continue with
processing the payment (customers accepts the proposal), or we need to
iterate i.e. check again the policy and possibly repropose a new
payment. The workflow is finished after processing the payment.
]

start in Task with
  successor
     n: receiveClaim
end

receiveClaim in Task with
   successor
     n: checkPolicy
end

checkPolicy in Task with
    successor
      n1: assignAssessor;
      n2: proposePayment
end

assignAssessor in Task with
     successor
       n: assessDamage
end

assessDamage in Task with
   successor
     n: proposePayment
end

proposePayment in Task with
    successor
      accept: processPayment;
      reject: checkPolicy
end

processPayment in Task with
   successor
     n: finish
end

finish in Task end

Assessor in Agent with
  executes
    t1: assessDamage
end

InsuranceAgent in Agent with
   executes
     t1: receiveClaim;
     t2: proposePayment
end

#quote(block: true)[
*Exercise 12:* Ask the two queries #raw("LoopTask") and
#raw("AgentWithSplitResponsibility").
]

The answer to #raw("LoopTask") is #raw("checkPolicy"), #raw("assignAssessor"),
#raw("assessDamage"), #raw("proposePayment"). The answer to
#raw("AgentWithSplitResponsibility") is #raw("InsuranceAgent"), #raw("Assessor"). Note
that the task #raw("assessDamage") is in a loop with #raw("proposePayment"). Hence,
a sequence
#raw("assessDamage")-#raw("proposePayment")-#raw("checkPolicy")-#raw("assignAssessor")-#raw("assessDamage")
is possible and is the reason to classify both agents into the query
class #raw("AgentWithSplitResponsibility").

You can also visualize the results of the queries by the graph editor.
The example process model together with the classification to the two
query classes is shown in figure #raw("fig:cbiva6").

#figure(image("../assets/cbiva6.png", width: 10cm),
  caption: [
    Classifying a process model via query classes
  ]
)
<fig:cbiva6>

The dotted green links are derived instantiations. So, an object that is
in the answer set of a query class is regarded as a derived instance of
that query class. Indeed, query classes are classes where the instances
are derived via the membership condition of the query class.

= Link the two notations
<link-the-two-notations>
We have created two simple notations, one for data modeling and the
scond for process modeling. Now let us combine these two. The most
natural way appears to regard object types (entity types and
relationship types) as possible inputs and outputs of tasks in a process
model.

#quote(block: true)[
*Exercise 13:* Define a new construct #raw("ObjectType") that
generalizes #raw("EntityType") and #raw("RelationshipType").
]

ObjectType end
EntityType isA ObjectType end
RelationshipType isA ObjectType end

So, this was easy. We now can link the two notations via #raw("ObjectType").

#quote(block: true)[
*Exercise 14:* Define object type as possible input/output of
tasks in process models.
]

Task with
 attribute
    input: ObjectType;
    output: ObjectType
end

Attributes in ConceptBase are by default multi-valued, ie.~they can have
zero, one or many values. This is exaclty what we want in this case.

We finalize this tutorial by attaching some objects types as
input/output of tasks.

#quote(block: true)[
*Exercise 15:* Define some of the object types of exercise 5 as
input/output of the process model of exercise 11.
]

receiveClaim with
  output o1: Claim
end

checkPolicy with
  input i1: claim_policy
end

= Conclusions
<conclusions>
In this tutorial, we defined two simple notations, one for data
modeling, another for process modeling. We defined queries to analyze
process models for non-trivial patterns, building on a newly defined
construct for transitivity. We created example models for both
notations. Finally, we linked the two notations to form an integrated
method for data and process modeling.

The two notations were both very simple. For example, the ER notation
lacks cardinalities of role links. The process modeling notation cannot
represent parallel splits. Adding the missing construct would not
require too much effort. The interested reader is referred to the
CB-Forum (#link("http://conceptbase.sourceforge.net/CB-Forum.html");)
for extended examples.
```
