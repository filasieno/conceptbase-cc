#set document(title: "ConceptBase HOW-TO Guide", author: "The ConceptBase Team")
#set page(paper: "a4", margin: (x: 2cm, y: 2.5cm))
#set text(font: "New Computer Modern", size: 11pt)
#set heading(numbering: "1.1.")

#align(center)[
  #text(size: 24pt, weight: "bold")[ConceptBase HOW-TO Guide]

  #v(1em)
  #text(size: 14pt)[A collection of tutorials, workflows, and examples]
]

#outline(indent: auto, depth: 2)

#pagebreak()

= Analyze document flows

_(No README provided for this tutorial.)_

== Associated Files
- `USU-Dokument.zip`
- `usu.gel`
- `usu-agentflows.gel`
- `usu-projektabrechnung.gel`
- `usu-spesenbeleg.gel`

#pagebreak()

= Analyze graphs

_(No README provided for this tutorial.)_

== Associated Files
- `organigraph.gel`
- `ConnectedComponents.sml.txt`
- `GraphCycle.smĺ.txt`
- `Organigraph.sml.txt`
- `CyclicGraphs.gel`
- `bigcity-queries.sml.txt`
- `Clique.sml.txt`
- `shortestpathdemo.gel`

#pagebreak()

= Associate CBGraph to graph files _.gel

_(No README provided for this tutorial.)_

== Associated Files
- `application-x-cbgraphfile.svg`
- `HTACCESS.txt`
- `cbgraph-mime.xml`
- `cbgraph.desktop`

#pagebreak()

= Avoid traps with aggregation functions in constraints

_(No README provided for this tutorial.)_

== Associated Files
- `ClassLimit1.sml.txt`
- `ClassLimitMeta.sml.txt`
- `ClassLimit2.sml.txt`

#pagebreak()

= Batch load multiple files in ConceptBase

_(No README provided for this tutorial.)_

== Associated Files
- `demoloader.cbs.txt`

#pagebreak()

= Capture some semantics of Petri Nets

_(No README provided for this tutorial.)_

#pagebreak()

= Create DeepTelos models

_(No README provided for this tutorial.)_

== Associated Files
- `deeptelos-simpleexample.png`
- `deeptelos-simpleexample.gel`
- `deeptelos-productexample.gel`
- `deeptelos-productexample.png`

#pagebreak()

= Create large test models

_(No README provided for this tutorial.)_

== Associated Files
- `MyClass.sml.txt`
- `city_1_1000.sml.txt`

#pagebreak()

= Deal with OCL-style invariants

_(No README provided for this tutorial.)_

== Associated Files
- `ClubMemberDomainModel.sml.txt`
- `ClubMemberDesignModel.sml.txt`

#pagebreak()

= Deal with multi-sets

_(No README provided for this tutorial.)_

== Associated Files
- `SALARYSUM.cbs.txt`
- `MULTISET.cbs.txt`
- `SALARYCONSTR.cbs.txt`

#pagebreak()

= Define active rules

_(No README provided for this tutorial.)_

== Associated Files
- `ECA-DivByZero.sml.txt`
- `ECA-ExistentialVariables.sml.txt`
- `ECA-ManyFriends.sml.txt`
- `ECA-Raise.cbs.txt`
- `ECA-lastmodified3.cbs.txt`
- `EmployeeCount.sml.txt`
- `ECA-CreateIndividual.sml.txt`
- `ECA-with-Constraints.sml.txt`
- `ECA-twoRules.cbs.txt`
- `ECA-Priority.cbs.txt`
- `ECA-MakeIntegers.sml.txt`
- `ack-safe.cbs.txt`
- `ECA-MakePowers.sml.txt`
- `ECA-lastmodified.sml.txt`
- `ECA-lastmodified2.cbs.txt`
- `ECA-ON-Ask.sml.txt`

#pagebreak()

= Define and use functions

_(No README provided for this tutorial.)_

== Associated Files
- `newton.sml.txt`
- `Peano.sml.txt`
- `sin.swi.lpi.txt`
- `math.swi.lpi.txt`
- `log2.cbs.txt`
- `SeqNestMetric.gel`
- `selectfirst.swi.lpi.txt`
- `HierMetric.sml.txt`
- `fib.cbs.txt`
- `sp.cbs.txt`
- `Functions.sml.txt`
- `BuiltinFunctions.sml.txt`
- `selectrnd.swi.lpi.txt`
- `recursion.swi.lpi.txt`
- `currentContext.swi.lpi.txt`
- `fibfast.cbs.txt`
- `FunctionShortcuts.cbs.txt`
- `Primes.sml.txt`
- `ackermann.cbs.txt`
- `SeqNestMetric.sml.txt`

#pagebreak()

= Define basic properties of relations

_(No README provided for this tutorial.)_

== Associated Files
- `InverseOf.sml.txt`
- `knows.gel`
- `SingleNecessary.sml.txt`
- `LinkSemantics3.sml.txt`
- `hasancestor.gel`
- `Immutable.sml.txt`
- `TransitiveClosureOf.sml.txt`
- `Contains.sml.txt`
- `LinkSemantics2.sml.txt`
- `LinkSemantics.sml.txt`

#pagebreak()

= Define co-variant specialization

```text
Some experiments on covariant specialization with UML, Java, and Telos/ConceptBase

Manfred Jeusfeld, 2024-11-04





(1) UML model


See slides 2 & 3 of UML-Telos-Java-2024.pdf
It should be noted that UML does allow co-variant specialization of associations.
Apparently, the Java compiler also allows it, see variable project of Employee and Manager in the Java source code




(2) Java Implementation

The Java implementation of the Employee model is constrained by Java's strict type safety,
which forbids co-variant refinement of operations. 

In particular look at the operation
  void assignProject(Project p)
of Employee and its extension for Manager.

The operation assignDefaultProject() of Employees shows that a programmer may get a runtime error
when executing the operation. The runtime error is triggered by the assertion
     assert (p instanceof HighLevelProject)
for assignProject(...) of Manager.

So, while the program is technically type-safe, the use of assertions can still trigger runtime errors.

An option could be to not extend the operation assignProject(...) and rather use the operation defined
at Employee.

The operations setMinimumSalary() and printEmployee() of Employee are extended for Manager.
They have a different behavior but there is not type-safety issue since the operations have no parameters.

Source: Employees.java

  

compile: javac Employees.java

run: java Employees


With enabled assertions (parameter -ea):

run: java -ea Employees
--> An assertion error exception is raised if an attempt is made to assign a non-HighLevelProject to a Manager


========================================================================================================

(3) Telos/ConceptBase model

Co-variant specialization is baked into Telos. 

Source: Employees.sml.txt

Note that the first part of the source file is only there to facilitate a UML-style rendering of the model
in the ConceptBase graph editor. The source can be loaded to ConceptBase using the CBIva user interface.


Graph file: employees.gel
This file can be directly called with
  cbgraph employees.gel
if you have installed ConceptBase from https://conceptbase.sourceforge.net/CB-Download.html





```

== Associated Files
- `README-Employees.txt`
- `Employees.sml.txt`
- `UML-Telos-Java-2024.pdf`
- `Nixon.gel`
- `employees.gel`
- `Employees.java`
- `Nixon.sml.txt`

#pagebreak()

= Define customized error messages for integrity constraints

_(No README provided for this tutorial.)_

== Associated Files
- `GeneratedHint.sml.txt`
- `Max1Test.sml.txt`
- `SalaryBoundWithHint.sml.txt`

#pagebreak()

= Define formulas at the meta-class level

_(No README provided for this tutorial.)_

== Associated Files
- `AbstractClass.sml.txt`
- `MacroFormulas.sml.txt`
- `erdmm.gel`
- `ModElem.sml.txt`
- `EmptyNonEmpty.sml.txt`
- `SharedKeyDemo.gel`
- `Meta-In2.sml.txt`
- `UsedMetaFormula.sml.txt`
- `exists-metaformula.sml.txt`
- `Meta-In.sml.txt`
- `mp-ISA-complete.sml.txt`

#pagebreak()

= Define object-specific graphical properties

_(No README provided for this tutorial.)_

== Associated Files
- `ticket397.gel`
- `movtokens.gel`

#pagebreak()

= Define recursive queries on cyclic structures

_(No README provided for this tutorial.)_

== Associated Files
- `winnim-complete-highlight.gel`
- `WinNim.sml.txt`
- `Barber.sml.txt`
- `SameGenRule.sml.txt`
- `links.sml.txt`
- `WinTicTacToe.sml.txt`
- `samegen.gel`
- `TreeExample.sml.txt`
- `Russel.sml.txt`
- `SameGen.sml`
- `BigFlights.sml.txt`
- `setM.sml.txt`
- `BigFlights2.sml.txt`
- `lrd.sml.txt`
- `EvenOdd.sml.txt`
- `winnim.gel`
- `ObjectDep.sml.txt`
- `Win.sml.txt`
- `EvenOddBasic.sml.txt`

#pagebreak()

= Define set operators

_(No README provided for this tutorial.)_

== Associated Files
- `Intervals.sml.txt`
- `SetOps.sml.txt`

#pagebreak()

= Define simple rules and constraints

_(No README provided for this tutorial.)_

== Associated Files
- `Employee-Formulas.gel`
- `check-rules-constraints.cbs.txt`
- `Empl_woRuleIc.sml.txt`

#pagebreak()

= Define time points

_(No README provided for this tutorial.)_

== Associated Files
- `time-simu.sml.txt`

#pagebreak()

= Define your own axioms

_(No README provided for this tutorial.)_

== Associated Files
- `SelfDefinedAxiom14.sml.txt`
- `AutoType.sml.txt`

#pagebreak()

= Design customized answer formats for queries

_(No README provided for this tutorial.)_

== Associated Files
- `iterations.sml.txt`
- `externalcall.bim.lpi.txt`
- `simple_answerformats1.sml.txt`
- `simple_answerformats2.sml.txt`
- `csv.sml.txt`
- `externalcall.swi.lpi.txt`
- `P-tuple.sml.txt`
- `externalcall.sml.txt`
- `recursive-answers.sml.txt`
- `iterations2.sml.txt`
- `views.sml.txt`
- `recursive-answers-1.sml.txt`
- `FunctionsWithIDs.sml.txt`

#pagebreak()

= Design service networks

```text
These are the ConceptBase models accompanying the paper
  J. Jayasinghe Arachchige, H. Weigand, M. Jeusfeld:
  Business Service Modeling for the Service-Oriented Enterprise,
  To appear in Int J of Information System Modeling and Design, 2011.

The files are licensed under a Creative Commons NC-BY license.

The scripts are written for Linux. They can be adapted to other operating
systems but we only provide the Linux version here.


You need to install ConceptBase from http://conceptbase.cc
and Graphviz via the package manager of your Linux distribution.

You also need to include the path
  <CB_HOME>/bin
into your search path, where <CB_HOME> is the directory
into which you installed ConceptBase.

To excerpt the graphical representation, you need to execute these 
commands:

$ CBshell -f create-DB-SERVICE.cbs

  ==> creates the database DB-SERVICE
  You only need to execute this step once.

$ mkdir VIEWS
$ cp postExport.sh VIEWS
$ chmod u+x VIEWS/postExport.sh

$ CBshell -f startstop.cbs

  ==> excerpts the dot files and converts them to
      PNG grapchis. This is done for all sub-modules,
      so if you extend the database you get also the
      PNG graphics of the new examples




Tilburg, 2011-05-11
Manfred Jeusfeld

```

== Associated Files
- `fig3a.png`
- `03-SERVICE-M1-fig3b.sml.txt`
- `fig3b.png`
- `service-ex.gif`
- `03-SERVICE-M1-fig2.sml.txt`
- `03-SERVICE-M1-fig3a.sml.txt`
- `fig3a.gel`
- `08-SERVICE-ECA.sml.txt`
- `06-SERVICE-ERD.sml.txt`
- `05-SERVICE-graphviz.sml.txt`
- `02-SERVICE-M2.sml.txt`
- `07-SERVICE-MAPRULES.sml.txt`
- `fig2.gel`
- `fig2-both.png`
- `04-SERVICE-GT.sml.txt`
- `create-DB-SERVICE.cbs.txt`
- `postExport.sh`
- `03-SERVICE-M1-example.sml.txt`
- `fig2-cbgraph.png`
- `fig2.png`
- `startstop.cbs.txt`
- `README.txt`
- `01-SERVICE-M3.sml.txt`
- `fig3b.gel`

#pagebreak()

= Export models as Graphviz specifications

_(No README provided for this tutorial.)_

#pagebreak()

= Formalize Process-Data Diagrams

```text
This directory contains the formalization of Process-Data Diagrams (PDDs)
accompanying the paper

M.A. Jeusfeld (2011): A Deductive View on Process-Data Diagrams.
Proceedings ME-2011, IFIP, AICT 351, 2011, (Boston: Springer), pp 123-137.
Postprint available via
  http://conceptbase.sourceforge.net/mjf/ME2011-mj-postprint.pdf

The model files with file type *.sml are all under a Creative Commons
License, see PDD-CC-NCBY-NC-License.txt. You can view/edit them
with a standard text editor.

You need to install ConceptBase 7.3 (or later) to explore the
formalizations. Download it from
  http://sourceforge.net/projects/conceptbase/

There are a few script files that simplify the 
use of the formalization. You can execute them in a command/shell
window. We assume subsequently that the command CBshell is
in the search path. If not you have to prepend the path
  <CB_HOME>/bin/
before the subsequent commands where <CB_HOME> is the directory path
into which you installed ConceptBase.

The file postExport.sh is a Linux/Unix script that can be copied
into the VIEWS directory (or another directory used to maintain
views) as an executable read-only script:

  cp postExport.sh VIEWS/
  chmod u+x VIEWS/postexport.sh
  chmud ugo-w VIEWS/postexport.sh

The script postExport.sh will automatically convert Graphviz dot files
exported from ConceptBase into PNG graphics. You can also adapt this
script to generate other output formats such as EPS.
You need to install Graphviz on your computer to use this
feature. 
Windows users might want to translate postExport.sh into a
batch file postExport.bat. We do not provide it here.


CBshell -f createDataBase.cbs

   This will create a database with name DB-PDD. If that already exists,
   please manually remove it before executing this command.


CBshell -f startstop.cbs

   Start ConceptBase with database DB-PDD and then stop it.
   This will materialize the views in VIEWS, in particular
   the Graphviz files.

CBserver -u nonpersistent -d DB-PDD

   Start a CBserver that you can sub-sequently inspect with
   the CBjavaInterface

CBserver  -u nonpersistent -d DB-PDD -views VIEWS

   Same as before but will export views into the directory
   VIEWS. That directory must be created by hand before
   starting this command. A sample directoty VIEWS-COPY
   is provided showing what content ConceptBase will
   export to the VIEWS directory.

CBjavaInterface

   Start a ConceptBase user interface. See ConceptBase user manual
   on how to use it and connect to the CBserver.



Tilburg, 2011-04-13 (2011-05-18)

Manfred Jeusfeld
(manfred.jeusfeld@acm.org)


```

== Associated Files
- `trace2.png`
- `PDD-overview00-src.gel`
- `postExport.txt`
- `07-PDD-graphviz.sml.txt`
- `08-Trace.sml.txt`
- `PDD-CC-BY-NC-License.txt`
- `WEMGV-ComplexDefinitionPhase.png`
- `06-PDD-Analysis.sml.txt`
- `05-PDD-simple-example.sml.txt`
- `040-PDD-WEM-Lib.sml.txt`
- `createDatabase.cbs.txt`
- `trace1.png`
- `01-PDD.sml.txt`
- `03-PDD-GTs.sml.txt`
- `startstop.cbs.txt`
- `00-M3.sml.txt`
- `README.txt`
- `041-WEM-Combine.sml.txt`
- `02-PDD-Rule.sml.txt`

#pagebreak()

= Formulate query calls with other queries as parameters

_(No README provided for this tutorial.)_

== Associated Files
- `nested.sml.txt`
- `Organigraph.sml.txt`
- `nested2.sml.txt`

#pagebreak()

= Generate Business Models

_(No README provided for this tutorial.)_

== Associated Files
- `egadget-containerized.png`
- `egadget-dark.png`
- `egadget-dark.gel`
- `egadget.gel`
- `egadget-containerized.gel`
- `gbm-license.txt`
- `egadget-white-frames.png`
- `egadget-white.gel`
- `egadget.png`

#pagebreak()

= Handle explicit attribution and default values

_(No README provided for this tutorial.)_

== Associated Files
- `AePredicate.cbs.txt`
- `DerivedAttribute.sml.txt`
- `DefaultValues.sml.txt`

#pagebreak()

= Inspect the object base as a whole

_(No README provided for this tutorial.)_

== Associated Files
- `TimeTrace.sml.txt`
- `lastupdate.cbs.txt`

#pagebreak()

= Install ConceptBase on Raspberry Pi 2

_(No README provided for this tutorial.)_

== Associated Files
- `cb4raspi.png`
- `cb-raspberry.png`

#pagebreak()

= Integrate CBshell with regular scripts

```text
Shell Integration with ConceptBase

Manfred Jeusfeld, 2012-07-12


The example is about retrieving information about files via
a Bourne shell script, to store the information in ConceptBase,
and then to retrieve answers to queries about this information.

The CBshell scripts are

tell    -- tells a frame to a ConceptBase server
ask     -- asks simple queries  to ConceptBase
stopcb  -- just stops a ConceptBase server


The Bourne shell scripts are

startcb      -- starts a CBserver with on a database 
fileSizeDemo -- the main script coordinating the other scripts



To prepare the demo, make all scripts executable.

  chmod u+x tell ask stopcb startcb fileSizeDemo

The scripts run in the current directory. If you want to
use them anywhere, you need to copy them into a directory that
is in your search path!


Running the demo:

  fileSizeDemo

The script will return some answer like 
  Result is 90,752,...
The numbers are the file sizes as stored in ConceptBase.

All information gets stored in the database FILEDB. The command
dumpcb in fileSizeDemo makes sure that the directory FILEDB
also conatins the readable form of the information in the database.
See file FILEDB/System-oHome.sml


The script is a bit slow since it starts up the CBserver. If the
CBserver would already be running, it would be a bit faster.

The demo requires ConceptBase 7.4.05 because the 'tell' script
relies on the -q option for CBshell.






```

== Associated Files
- `ask.txt`
- `startcb.txt`
- `stopcb.txt`
- `dumpcb.txt`
- `fileSizeDemo.txt`
- `README.txt`
- `tell.txt`

#pagebreak()

= Interact with ConceptBase from the command line

_(No README provided for this tutorial.)_

== Associated Files
- `ask.txt`
- `stopcb.txt`
- `testask.txt`
- `tell.txt`

#pagebreak()

= Manage access rights to modules (and other resources)

_(No README provided for this tutorial.)_

== Associated Files
- `RightsExample.sml.txt`

#pagebreak()

= Materialize graphical views

```text
Materialized Graph Views with ConceptBase.cc V7.6.10

Manfred Jeusfeld, 2014-02-03


Create a self-contained graphical view of the database that contains the graph,
all necessary object definitions, and connection details to link to the ConceptBase
database from which the graphical view was extracted



0. Introduction

The ConceptBase graph editor CBGraph visualizes graphical views on a ConceptBase
database module. Nodes and links can have dedicated shapes and can be moved around
in the drawing window (called "internal windows" in the ConceptBase user manual.

This tutorial shows you how to store the graphical view in a self-contained
file that contains all necessary information to work with the view.


1. Prepare the database

We use the Business Model database as example, see
  http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/3594885

Download the files to a directory like BMG and open a terminal to enter

  cd BMG
  cbshell createdb.cbs


Afterwards the database BMGDB is created. Start a CBserver on the database

  cbserver -d BMGDB 

The server will have hostname 'localhost' and port number 4001.


2. Create a graphical view 

Open a new terminal and start 

   cbgraph +r

This will open an unconnected graph editor. The option +r instructs cbgraph that
we plan to extract (read) object definitions from the database.

Select File/Connect to server to open a connection. Make sure that you specify
localhost and 4001 in the first tab of the connection dialog. The 2nd tab 
specifies the start module (oHome), the start object (Class), and the graphical
palette. Leave the settings as they are.

As a result, CBGraph will open a new internal window labelled
   "DefaultJavaPalette:oHome -- localhost:4001"

Change to module "eGadgetCase" using the "Current connection" dialog. Then change
the graphical palette to "BMG_Palette" in the same dialog.
The window now gets a new background (defined by BMG_Palette) and adapts its size.
Select the object Class and hide it using the 4th button in the CBGraph toolbar.
Maximize the CBGraph window and the internal window. 
Then, press the load object icon from the toolbar (6th icon) and type "OEM" as object name.
You can resize the node and place it in the leftmost upper segment.

Right-click on OEM and select 'Outgoing attributes - flowTo - all - Show all"
A new object eGadget_Hardware appears. Place it in the light green segment in
the left half of the window. Expand eGadget_Hardware in a similar way and move 
the result objects to the right. You can resize the nodes as well and also move the links
by finding their "move point". 



3. Materialize the graph


Select the option File/Save and store the graph with a name like egadget-view1.gel.
Then exit CBGraph. The file egadget-view1.gel contains all data needed for
working with the graph including the required object definitions.

Open a CBIva, connect to the CBserver at localhost and port 4001. Stop the CBserver
and exit CBIva.




4. Open the graph file 

Start in a terminal window
   cbgraph -r egadget-view1.gel 
It will warn you that there is no connection to a database. Still you can view
the graph and change the location of nodes. However, we would like to work
with the graph further and expand its view on the database. You may want to maximize
the window again to see the whole graph.
So, close CBGraph again and start a CBserver like before in another terminal
  
  cbserver -d BMGDB 

Then start 
  
  cbgraph +rw egadget-view1.gel 


Now, the same graph opens and is connected to the CBserver on localhost:4001.
This is the typical way to work with a graph. You can store expand further nodes
but we leave it its current state and exit both CBGraph and the CBserver like 
described before.



5. Open the graph on another computer

Assume, you want to demonstrate the graph on another computer and you have no access
to the BMGDB database on that computer. Note that the object definitions are 
included in egadget-view1.gel since we used the -r option.

Start in a terminal a CBserver with an empty (anonymous) database:

  cbserver

Then, in another terminal

   cbgraph +w egadget-view1.gel 


The -w option instructs CBGraph to write the materialized object definitions from
the GEL file to the databasde server, which happens to run on localhost:4001 by default.

You can now work with the graph in the same way as if you were connected to the
original database BMGDB!

Then, stop CBGraph and use CBIva to stop the CBserver as described above.



You also find a file egadget-view2.gel that is a view on the same database module but
with more objects displayed in its window. It has been created using the +r option
on the same database. Hence, you can use it directly with an anonymous CBserver
and the option +w:

   cbserver &
   cbgraph +w egadget-view2.gel 


You can also omit the options +r,+w, and +rw. Then, CBGraph will enable full
synchronization between the graph file and the CBserver.


If you want to disable the synchronization, then call for example

  cbgraph -rw egadget-view2.gel

This is useful when the CBserver always has the latest state and you do not want
to materialize the state of the CBserver in the graph file. In particular, when
objects are deleted from the database after exiting CBGraph, the full synchronization 
would recover them. 















```

== Associated Files
- `egadget-view2.gel`
- `README-MaterializedGraphViews.txt`
- `egadget-view1.gel`

#pagebreak()

= Materialize query results as files

_(No README provided for this tutorial.)_

== Associated Files
- `ERD-export.sml.txt`
- `postExport.txt`
- `SaveViews-simple.sml.txt`
- `SaveModelType.sml.txt`
- `extract-MyModel1.cbs.txt`

#pagebreak()

= Miscellaneous

_(No README provided for this tutorial.)_

== Associated Files
- `cc.sml.txt`

#pagebreak()

= Model Clabjects

_(No README provided for this tutorial.)_

== Associated Files
- `Baum.sml.txt`
- `Trees.sml.txt`
- `baum.png`
- `tree.png`

#pagebreak()

= Model Event-Process-Chains (EPCs)

_(No README provided for this tutorial.)_

== Associated Files
- `epc-erd-layout.gel`
- `01-EPC.sml.txt`
- `05-LinkEPC-ERD.sml.txt`
- `02-EPC-GTs.sml.txt`
- `05-ERD-advanced-GTs.sml.txt`
- `03-ERD-advanced.sml.txt`

#pagebreak()

= Model the Entity-Relationship-Model

_(No README provided for this tutorial.)_

== Associated Files
- `erdcomplete.gel`
- `06-UniversityModel.sml.txt`
- `03-ERD-GTs-UML.sml.txt`
- `04-ERD-Semantics.sml.txt`
- `03-ERD-GTs.sml.txt`
- `umodel.png`
- `cb-image2.png`
- `extractGV.cbs.txt`
- `acrosslevels-frames.png`
- `02-ERD-Syntax.sml.txt`
- `01-ERD-Language.sml.txt`
- `umodel.txt`
- `07-UniversityData.sml.txt`
- `08-AcrossLevels.sml.txt`
- `acrosslevels-proposition.gel`
- `05-ERD-graphviz2.sml.txt`
- `createdb.cbs.txt`
- `acrosslevels.gel`

#pagebreak()

= Optimize conditions in ECA rules

_(No README provided for this tutorial.)_

== Associated Files
- `PN-2.cbs.txt`
- `PN-1.cbs.txt`
- `PN-3.cbs.txt`

#pagebreak()

= Realize cascading UNTELL via ECArules

_(No README provided for this tutorial.)_

== Associated Files
- `CascUntell-Plus.sml.txt`
- `CascUntell.sml.txt`
- `issue44.cbs.txt`

#pagebreak()

= Reason about the existence of Santa Claus

```text
                       The True Story of SINTERKLAAS
                           narrated in O-Telos
                                  by
                  M. Jeusfeld, 1-Dec-2004 (24-Nov-2010)

Sinterklaas (or Santa Claus or Hl. Nikolaus) is visiting all persons
in the world with a gift to make them happy. But: Is there a Sinterklaas?
Maybe there are many! And if he comes, does he always come with a gift!
These centuries-old questions can now be answered with O-Telos and
ConceptBase ...

To play the story with ConceptBase (V6.1.2 or later) you
should follow these steps:

1) make sure that your computer is connected to the Internet; otherwise you miss
   the message

2) Start a ConceptBase user interface CBiva and connect it to a CBserver
   (e.g. by using the option File/Start CBserver)

3) Tell the Telos models sinterklaas.sml amd sc-gts.sml

4) Start a Graph Editor with start object 'Agent' and Palette 'Sinterklaas_Palette'

5) Show the instances of Agent: Sinterklaas and Person.
   Display Sinterklaas in a Telos Editor: you see the three main 
   requirements for a sinterklaas to exist ...

6) Show the attributes between Sinterklaas and Person: sinterklaas_visit
   Show the instances of Sinterklaas: THE_SINTERKLAAS

7) Try to enter another Sinterklaas, e.g. FAKESINTER as instance of Sinterklaas
   --> NO! There is only one!

8) Show the attributes visits of THE_SINTERKLAAS: two happy persons show up.

9) Show the attributes of the visits: both have gifts! Sinterklaas will not
    come with empty hands.

10) Show all instances of Person: Manfred will show up as unhappy person.

11) Tell the model makemehappy.sml and select
    Current connection/Validate shown objects
    --> Now, Manfred is also happy

So, what about Sinterklaas himself? Is he possibly human? Check it out:

12) Hold the shift key and click in THE_SINTERKLAAS and Person. Then press the
    button "In" right to the "Create" bar. This declares THE_SINTERKLAAS
    as instance of Person. Confirm with OK and then press 
    the symbol "->CB" to commit changes to ConceptBase.

Now, THE_SINTERKLAAS becomes an unhappy person because he would
expect himself a gift!
```

== Associated Files
- `sinterklass.png`
- `02-sc-gts.sml.txt`
- `03-makemehappy.sml.txt`
- `README.txt`
- `sinter-new.gel`
- `01-sinterklaas.sml.txt`

#pagebreak()

= Reify query calls

_(No README provided for this tutorial.)_

== Associated Files
- `ticket194.cbs.txt`

#pagebreak()

= Save Telos models

_(No README provided for this tutorial.)_

== Associated Files
- `SaveModel.sml.txt`
- `SaveModule.sml.txt`
- `listmodule.swi.lpi.txt`
- `previousState.cbs.txt`
- `listPs.sml.txt`

#pagebreak()

= Scripts to tests solutions to tickets

_(No README provided for this tutorial.)_

== Associated Files
- `ticket360.cbs.txt`
- `ticket284.cbs.txt`
- `ticket282.cbs.txt`
- `ticket415.cbs.txt`
- `ticket162.cbs.txt`
- `ticket300.cbs.txt`
- `ticket263a.cbs.txt`
- `ticket400.gel`
- `ticket404b.cbs.txt`
- `ticket327.cbs.txt`
- `ticket125.cbs.txt`
- `ticket286.cbs.txt`
- `ticket247.cbs.txt`
- `Ticket168.cbs.txt`
- `ticket397.gel`
- `ticket400.cbs.txt`
- `ticket180.cbs.txt`
- `ticket316.cbs.txt`
- `ticket349.cbs.txt`
- `ticket296.cbs.txt`
- `ticket325.cbs.txt`
- `ticket252.cbs.txt`
- `ticket307.cbs.txt`
- `ticket347.gel`
- `ticket164.cbs.txt`
- `ticket276.cbs.txt`
- `ticket397a.gel`
- `ticket364.cbs.txt`
- `ticket298.cbs.txt`
- `ticket267.cbs.txt`
- `ticket241.cbs.txt`
- `ticket432.cbs.txt`
- `ticket318.cbs.txt`
- `ticket292.cbs.txt`
- `ticket265.cbs.txt`
- `ticket342.cbs.txt`
- `ticket234.cbs.txt`
- `ticket399a.gel`
- `ticket309.cbs.txt`
- `ticket306.cbs.txt`
- `ticket386.gel`
- `ticket317.cbs.txt`
- `ticket330.cbs.txt`
- `ticket248.cbs.txt`
- `ticket279.cbs.txt`
- `ticket404.cbs.txt`
- `ticket277.cbs.txt`
- `ticket255.cbs.txt`
- `ticket404a.cbs.txt`
- `ticket384.gel`
- `ticket272.cbs.txt`
- `ticket294.cbs.txt`
- `ticket203a.cbs.txt`
- `ticket251.cbs.txt`
- `ticket433.cbs.txt`
- `ticket365a.cbs.txt`
- `ticket283.cbs.txt`
- `ticket207.cbs.txt`
- `ticket290.cbs.txt`
- `ticket266.cbs.txt`
- `ticket366.cbs.txt`
- `ticket230.cbs.txt`
- `ticket263.cbs.txt`
- `ticket213.cbs.txt`
- `ticket311.cbs.txt`
- `ticket255a.cbs.txt`
- `issue1.cbs.txt`
- `ticket314.cbs.txt`
- `ticket092b.cbs.txt`
- `ticket365.cbs.txt`
- `ticket092a.cbs.txt`
- `ticket293.cbs.txt`
- `ticket295.cbs.txt`
- `ticket423.cbs.txt`
- `ticket278.cbs.txt`
- `ticket320.cbs.txt`
- `ticket303.cbs.txt`
- `ticket301.cbs.txt`
- `ticket288.cbs.txt`
- `ticket397.cbs.txt`
- `ticket335.cbs.txt`
- `ticket264.cbs.txt`
- `ticket191.cbs.txt`
- `ticket346.cbs.txt`
- `ticket242.cbs.txt`
- `ticket260.cbs.txt`
- `ticket197.cbs.txt`
- `ticket273.cbs.txt`
- `ticket350.cbs.txt`
- `ticket261.cbs.txt`
- `ticket246.cbs.txt`
- `ticket254.cbs.txt`
- `ticket384.cbs.txt`
- `ticket280.cbs.txt`
- `BigFlights.cbs.txt`
- `ticket214.cbs.txt`
- `ticket388.cbs.txt`
- `ticket399b.gel`
- `USU.sml.txt`
- `ticket220.cbs.txt`
- `ticket347.cbs.txt`
- `ticket253.cbs.txt`
- `ticket194.cbs.txt`
- `ticket346-small.cbs.txt`
- `ticket351.cbs.txt`
- `ticket285.cbs.txt`
- `ticket374.cbs.txt`
- `ticket268.cbs.txt`
- `ticket364a.cbs.txt`
- `ticket271.cbs.txt`
- `ticket212.cbs.txt`
- `ticket243.cbs.txt`
- `ticket392.cbs.txt`
- `ticket388a.cbs.txt`
- `ticket202.cbs.txt`
- `ticket245.cbs.txt`
- `ticket222.cbs.txt`
- `ticket203.cbs.txt`
- `ticket343.gel`
- `ticket341.cbs.txt`
- `ticket410.gel`

#pagebreak()

= Send an email via an active rule

```text

*********************************
Sending an email from ConceptBase
*********************************

Manfred Jeusfeld, 21-Aug-2007
last update: 19-Sep-2014


This example show how to send an email by a ConceptBase active rule.
The example require Linux/Unix as host operation system for the ConceptBase server.
The host operating system must have the sendmail utility installed at /usr/sbin.
The example is written for ConceptBase 7.0.

The example is provided as is and without warranty of any type.



Files
*****

01-ecamail.sml
  Definitions of the scenario of the example. The scenerio is taken from conference management
  where some forms are submitted to the ConceptBase server. In this case, we are interested
  in the form type "AbstractSubmission". The active rule is called MailObjectOnFormSubmission.
  Every type a form of type AbstractSubmission is inserted to the ConceptBase database, it will
  mail the content to all 'members' who have subscribed to "AbstractSubmission".
  Edit the email address of the members to a known email address, e.g. your own.

02-trigger.sml
  An example abstract submission. Tell this file to trigger the active rule.

SENDMAIL.swi.lpi
  Plug-in for the ConceptBase server to allow it to call the sendmail utility.
  


Script to test the functionality
********************************

1. Edit the file 01-ecamail and replace the member 'johndoe@erath.universe.org' 
   by an appropriate email address, e.g. your own.

2. Start the cbserver 
     cbserver -d MYDB

3. Start the ConceptBase user interface cbiva, connect to the cbserver and load the model
   01-ecamail.sml

4. Stop the CBserver via cbiva

5. Copy the SENDMAIl plug-in to the database created before
     cp SENDMAIL.swi.lpi MYDB

6. Start the cbserver again
     cbserver -d MYDB

7. Start the ConceptBase user interface, connect to the cbserver and load the model
   02-trigger.sml

==> An email should be sent to the persons subscribed to "AbstractSubmission" (see file 01-ecamail.sml)





```

== Associated Files
- `SENDMAIL.swi.lpi.txt`
- `02-trigger.sml.txt`
- `README.txt`
- `01-ecamail.sml.txt`

#pagebreak()

= Specify resizable shapes

_(No README provided for this tutorial.)_

== Associated Files
- `allshapes.sml.txt`
- `usershapes.png`
- `shapes.png`
- `shapes.gel`
- `userdefinedshapes.sml.txt`
- `usershapes.gel`

#pagebreak()

= Understand MOF vs. Telos

_(No README provided for this tutorial.)_

== Associated Files
- `MOF_Telos.sml.txt`
- `MOF_Telos_Levels.sml.txt`

#pagebreak()

= Use graphical types

_(No README provided for this tutorial.)_

== Associated Files
- `StandardPalette.sml.txt`
- `TelosPalette.sml.txt`

#pagebreak()

= Use query classes in rules and constraints

_(No README provided for this tutorial.)_

== Associated Files
- `QueriesAndConstraints.sml.txt`
- `DynamicSets.sml.txt`

#pagebreak()

= Visualize module structures

```text
Visualize module structures

Manfred Jeusfeld, 2012-09-12


Almost all modern programming languages offer module structures,
in which program sources import and export elements like procedures.

Logically, this induces a dependency network like
   (m1 imports m2)
expressing that module m1 imports from module m2.

The files in this directory show how one can rather easily extract
this network from source files, store them in ConceptBase,
and let ConceptBase generate a graph to be layed out by GraphViz.

As example, we show how to do it from Prolog sources file (as used
by the ConceptBase system). The ConceptBase Prolog sources include
declarations like

#IMPORT(increment/1,GeneralUtilities)

This means that the current module containing this declarations imports
a procedure increment/1 (arity 1) from the the module GeneralUtilities.

Each module can have a number of such declarations and the program system
as a whole can have many modules.


The files in this directory are:

  ImportsModel.sml.txt
     Telos definitions making ConceptBase capable of transforming the module declarations into GraphViz graphs.
     In particular, two queries imports2GV and uses2GV are defined. The first one 
     generates the complete network of imports relations, i.e. two modules can have
     any number of imports relations between each other. The second one aggregates
     all imports relations from a module m1 to a module m2 into a single uses
     relations between m1 and m2.

  ExtractImports.java
     Program to extract imports declarations from Prolog source files (uses ConceptBase syntax);
     compile with 'javac ExtractImports.java'

  genImports
     Unix/Linux shell script to generate all import declarations from all Prolog source files of a given directory.
     Store as file 'genImports' and make in executable.

  Literals.pro
     Example Prolog source file; only the IMPORT declarations are of interest; you can add more
     Prolog sources from the ConceptBase source pool if you want to see how larger graphs are layed out.

  imports.png
     Visualizes the IMPORT dependencies from Literals.pro

  imagedfpd
     Visualizes the IMPORT dependencies of all ConceptBase Prolog sources



Call the visualization in a Unix pipe like, assuming that the Prolog sources are in the 
current directory:

   genImports . imports2GV | cbshell -p | neato -Tpng > imports.png

It will scan all *.pro files in the current directory and produce the graph image.
You can also provide an absolute path to the directory with the Prolog sources:

   genImports /home/me/prj imports2GV | cbshell -p | neato -Tpng > imports.png

If you want to visualize only the 'use' relations between modules, then call:

   genImports /home/me/prj uses2GV | cbshell -p | neato -Tpng > imports.png


You can apply the tools to other programming languages by adapting the program
   ExtractImports.java
and the Telos definitions in ImportsModel.sml.txt, if necessary.







```

== Associated Files
- `allimports.png`
- `ExtractImports.java`
- `imports.png`
- `Literals.pro.txt`
- `README.txt`
- `ImportsModel.sml.txt`
- `genImports.txt`

#pagebreak()

