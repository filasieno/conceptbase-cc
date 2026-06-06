= Introduction
<introduction>
This tutorial gives a beginners introduction into Telos and ConceptBase.
Telos is a formal language for representing knowledge in a wide area of
applications, e.g. requirements and process-modelling. It integrates
object-oriented and deductive features into a logical framework.
ConceptBase is an experimental deductive database management system,
based on the Telos data model. It is designed to store and manipulate a
database of Telos objects. The tutorial is organized as follows: The
next section gives a short introduction into the architectural
organization of the ConceptBase system and describes the necessary steps
to start the system. Section three explains some basic features of Telos
and ConceptBase using a simple example. The last chapter contains
solutions to the exercises.

Please note: \
The objective of this tutorial is to give a novice user a first
intuitive feeling on how to work with CB and how to build own models,
not to mention all the features of Telos and ConceptBase or describe the
semantics of Telos.

=  First Steps
<first-steps>

== Overview of the Architecture of the ConceptBase-System
<overview-of-the-architecture-of-the-conceptbase-system>
ConceptBase is organized in a client/server architecture. The server
manages the database while the client may be any user-defined
application program. A graphical client _CBIva_ and a command-line
client _CBShell_ are distributed with the ConceptBase system. We
use in this tutorial the grahical client. The communication between
server and client is realized via Internet protocols, i.e. client and
server can run on different computers in your local network or even ob
the global Internet. They can also run on the same computer, which is
the most frequent way of use. The connection is offered by the
ConceptBase server via a so-called _port number_. Every database
is stored in a seperate directory with the name of the database as
directory name.

Before working with this tutorial ConceptBase has to be installed
properly. This is documented in the installation guide which is
available from the site where you downloaded the system, typically
#link("http://conceptbase.sourceforge.net/CB-Download.html");.

== Starting the ConceptBase Server
<starting-the-conceptbase-server>
Get a description of all possible command-line parameters by entering
the following commands in a command window. The commands are:

  cd #raw("CB_HOME")
  cbserver -help

The string CB_HOME has to be replaced by the directory path, into
which ConceptBase was installed on your local computer. You may want to
include this directory path into the search path of your command shell.

Start a ConceptBase server loading the database _TutDB_ on port
number _5544_ A server will start running immediately. If the
database _TutDB_ doesn't exist, a new database will be created
before loading. Then the copyright notice and parameter settings are
displayed, followed by a message which contains hostname and port number
of the ConceptBase server you have just started. These two informations
are used to identify a server. The host is the one, you are currently
logged on to and the port number is set by the #raw("-port") parameter. The
port number must be free on the host where ConceptBase shall run. If
this number is already in use by another server, the error message \
#raw("IPC Error: Unable to bind socket to name ") \
appears and the server stops. In this case restart the server with
another port number.

== Starting the ConceptBase User Interface
<starting-the-conceptbase-user-interface>
Clients can communicate with a server through the ConceptBase Usage
Environment. The interface contains several tools which can be invoked
from the _CBIva_ (ConceptBase User Interface in Java). Start CBIva
by entering the following commands in a new command window:

    cd #raw("CB_HOME")
    cbiva

You may also double-click the file cbiva (or cbiva.bat) in the
ConceptBase installation directory. After a few seconds a window will
appear which is titled "CBIva - ConceptBase User Interface in Java". It
consists of a main window, statusline at the left buttom, and offers
several function keys and menu-items. A complete description of these
menus is given in the User Manual. Depending on your operating system,
you can also double-click the file 'cbiva' (resp.~'cbiva.bat') in the
installation directory of ConceptBase. \
*Exercise 2.2: \
Establish a connection between CBIva and the server you have started
under 2.1 \
After the connection is established the first field of the
_statusline_ contains the status \"connected\".*

= The Example Model
<the-example-model>
In this section the use of basic tools and concepts will be illustrated
by modelling the following simple scenario:

#quote(block: true)[
A company has employees, some of them being managers. Employees have a
name and a salary which may change from time to time. They are assigned
to departments which are headed by managers. The boss of an employee can
be derived from his department and the manager of that department. No
employee is allowed to earn more money than his boss.
]

The model we want to create contains two levels: the _class level_
containing the classes _Employee_, _Manager_ and
_Department_ and the _token level_ which contains instances of
these 3 classes.

== Editing Telos Objects
<editing-telos-objects>
=== The Class Level
<the-class-level>
The first step is to create the three classes used: _Employee_,
_Manager_ and _Department_. Enter the following definition
into the CBIva's top window labelled _Telos Editor_:

Employee in Class
end

This is the declaration of the class _Employee_, which will
contain every employee as instance. _Employee_ is declared as
instance of the system class _Class_, because it is on the class
level of our example, i.e. it is intended to have instances.

To add this object to the database, press the _Tell_ button. If no
syntax error occurs and the semantic integrity of the database isn't
violated by this new object it will be added to the database. The next
class to ad is the class _Manager_. Managers are also employees,
so the class _Manager_ is declared as a specialization of
_Employee_ using the keyword _isA_:

Manager in Class isA Employee
end

Press the _Clear_ button to clear the editor field. Enter the telos
frame given above and add it to the database by telling it. The final
class to be added is the class _Department_. \
*Exercise 3.1: \
Define a class _Department_ and add it to the database. \
At this point we have added some new classes to the object base, but
have told nothing about the so called _attributes_ of these
classes. The modification of the classes we have just entered is the
next task.*

=== Defining Attributes of Classes
<defining-attributes-of-classes>
As mentioned in the description of the example-model, the employee-class
has several attributes. To add them, we need to modify the Telos frame
describing the class _Employee_.

*Exercise 3.2: \
Load the object _Employee_ via the _load frame_ button and
modify it as follows:*

Employee in Class with
attribute
        name: String;
        salary: Integer;
        dept: Department;
        boss: Manager
end

Tell the modified Employee frame to the database. Now you have added
attributes to the class _Employee_. They are of the category
_attribute_ and their labels are: _name_, _salary_,
_dept_, and _boss_. They establish "links" between the class
_Employee_ and the classes mentioned as "targets".
_Department_ and _Manager_ are user-defined classes, while
_String_ and _Integer_ are builtin classes of ConceptBase.

Notice that these attributes are also available for the class
_Manager_, because this class is a subclass of Employee (i.e.
Telos offers attribute inheritance, see also chapter 2.1 of the User
manual, _Specialization axiom_). \
*Exercise 3.3: \
The class Department has only one attribute: the manager, who leads the
department. Add this attribute to the class Department. The label of
this attribute shall be _head_. \
Now we have completed the class-level of our example. The next step is
to add instances of our classes to the database.*

=== The Token Level
<the-token-level>
The company we are modelling consists of the 4 departments
_Production_, _Marketing_, _Administration_ and
_Research_. Every employee working in the company belongs to a
department. The employees will be listed later, apart from the managers
of the departments: \

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [|l|l| department], [head],
    [Production], [Lloyd],
    [Marketing], [Phil],
    [Administration], [Eleonore],
    [Research], [Albert],
  )]
  , kind: table
  )

\

=== Defining Attributes of Tokens
<defining-attributes-of-tokens>
At first let's have a look at the department class, defined in exercise
3.3:

Department in Class with
         attribute
               head: Manager
end

There is a link between _Department_ and _Manager_ of category
_attribute_ with label _head_ at the class-level. Now we have
to establish a link between _Production_ and _Lloyd_ of
category _head_ at the token-level. The _label_ of this link
must be a unique name for all links with the source object
\"Production\". We choose _head\_of\_Production_ as name.

The resulting Telos frame is:

Production in Department with
  head
    head_of_Production : Lloyd
end

*Exercise 3.4:*

- Add the frames for Lloyd, Phil, Eleonore and Albert to the database.

- Add the Telos frames for Production, Marketing, Administration, and
  Research and the links between the departments and their manager to
  the database.

- The four managers have the following salaries: \

  #figure(
    align(center)[#table(
      columns: 2,
      align: (left,left,),
      [|l|l| manager], [salary],
      [Lloyd], [100000],
      [Phil], [120000],
      [Eleonore], [20000],
      [Albert], [110000],
    )]
    , kind: table
    )

Add this information to the database. Use \"LloydsSalary\",
\"PhilsSalary\", etc. as labels. (Remember that you can load an existing
object from the database into the Telos Editor by using \"Load frame\".)
\
The destination objects of attribute instantiations must be existing
objects in the database or instances of the system builtin classes
_Integer_, _Real_ or _String_. Objects which
instantiate these classes are generated automatically when referenced in
a Telos-frame. At this point it is important to recognize, that
attributes specified at the class level do not need to be instantiated
at the instance level. On the other hand an instance of a class
containing an attribute may contain several instances of this attribute.

Example: \

George in Employee with
        name
                GeorgesName: "George D. Smith"
        salary
                GeogesBaseSalary : 30000;
                GeorgesBonusSalary : 3000
end

The attribute _dept_ and _boss_ have no instances, while
_salary_ is instantiated twice.

To complete the token level, we have to add more employees to the
database. \
*Exercise 3.5: \
Add the following employees to the database. Use
_MichaelsDepartment_ etc. as labels for the attributes. \
*

#block[
ll |l|l|l| employee & department & salary \
Michael & Production & 30000 \
Herbert & Marketing & 60000 \
Maria & Administration & 10000 \
Edward & Research & 50000 \

]
\
Now the first step in building the example database is completed. The
next chapter describes a basic tool of the usage environment which can
be used for inspecting the database: the _GraphBrowser_.

== The Graph Editor
<the-graph-editor>
To start the Graph Editor, choose the menu item _Browse_ from the
Workbench and select _Graph Editor_. The Graph Editor will start
up and establish a connection to the same server as the workbench, if
the workbench is currently connected. You can establish additional
connections from within the Graph Editor application. If the Graph
Editor has established the connection and loaded the initial data (note:
this takes about 10 seconds), you can add an object to the editor window
by clicking on the "Load object" button. An interaction window appears,
asking for an object name. After entering a valid name (e.g.
_Employee_) the _Graph Browser_ displays the corresponding
object. By clicking the left mouse-button, every displayed object can be
selected. A selected object can be moved by dragging the object with the
left mouse-button pressed. By clicking on the right mouse-button, a
popup-menu will be shown with the following operations:

- *Toggle component view* \
  switches the view of this object. In the detailed component view, you
  can either see the frame of this object or tree-like representation of
  super- and subclasses, instances, classes, and attributes of this
  object.

- *Super classes, sub classes, classes, instances* \
  for each menu item you can select whether you want to see only the
  explicitly defined super classes (or sub classes, etc.) or all super
  classes including all implicit relationships. The query to the
  ConceptBase server to retrieve this information will be done when you
  select the menu item. So, the construction of the corresponding
  submenu might take a few seconds.

- *Incoming and outgoing attributes* \
  The Graph Editor will ask the ConceptBase server for the attribute
  classes that apply to this object. For each attribute class, it is
  possible to display only explicit attributes or all attributes as
  above. The attribute class "Attribute" applies for every object and
  all attributes are in this class. Therefore, all explicit attributes
  of an object will be visible in this category.

- *Add Instance, Class, SuperClass, SubClass, Attribute,
  Individual* \
  These menu items will open the "Create Object" dialog where you can
  specify new objects that should be created in the database. Note, that
  these modifications are not performed directly on the database. The
  editor will collect all modifications and send them to the ConceptBase
  server when you click on the "Commit" button.

- *Delete object from database* \
  This operation will delete the object from the database. As for the
  insertion of objects before, the modification will be send to the
  server when you click on the "Commit" button. Note that this operation
  has an effect on the database in contrast to the next operation.

- *Remove object from view* \
  The object will be removed from the current view. This operation has
  no effect on the database, i.e.~the object will not be deleted from
  the database.

- *Display in Workbench* \
  This operation will load the frame of the object into the Telos
  editor.

- *Show in new Frame* \
  A new internal window (within the Graph Editor) will be shown and the
  selected object will be shown in the new window.

*Exercise 3.6: \
Start a GraphBrowser, and load \"Employee\" as initial object and
experiment with the menu options available.*

== Adding Deductive Rules
<adding-deductive-rules>
At this point you should have made some experiences with the editing-
and browsing-facilities of the ConceptBase Usage Environment and the
Telos language. This chapter gives an introduction into the use of
_rules_ and _integrity constraints_.

Until now we have never instantiated the boss-attribute of an employee.
The boss can be derived from the department the employee is assigned to
and the head of this department. So its obvious to define the instances
of the boss-attribute by adding a rule to the Employee-Frame.

At first we'll give a short introduction into the syntax of the
assertion language. The exact syntax is given in the appendix of the
user manual.

A _deductive rule_ has the following format: \

#raw(" forall x1/c1 x2/c2 ... xn/cn ")$< R u l e >$#raw(" ==> lit(a1,...,am)")

where $< R u l e >$ is a formula and the xi's are variables bound to the
class ci, lit is a literal of type 1 or 3 (see below) and the variables
among the ai's are included in x1,..,xn.

To compose the formula defining a _deductive rule_ or
_integrity constraint_ the following literals may be used:

+ #raw("(x in c)") \
  The object x is an instance of class c.

+ #raw("(c isA d)") \
  The object c is a specialization (subclass) of d

+ #raw("(x l y)") \
  The object x has an attribute to object y and this relationship is an
  instance of an attribute category with label l. Structural integrity
  demands that the label l belongs to an attribute of a class of x.

In order to avoid ambiguity, neither \"in\" and \"isA\" nor the logical
connectives \"and\" and \"or\" are allowed as attribute labels.

The next literals are second class citizens in formulas. In contrast to
the above literals they cannot be assigned to classes of the Telos
database. Consequently, they may only be used for testing, i.e. in a
legal formula their parameters must be bound by one of the literals 1 -
3.

+ #raw("(x < y), (x > y), (x <= y), (x >= y), (x = y), (x <> y)") \
  Note that x and y must be instances of Integer or Real.

+ #raw("(x == y)") \
  The objects x and y are the same. You can also use #raw("(x = y)").

\"and\" and \"or\" are allowed as infix operators to connect
subformulas. Variables in formulas can be quantified by #raw("forall x/c") or
#raw("exists x/c"), where c is a class, i.e. the range of x is the set of all
instances of the class c.

The constants appearing in formulas must be names of existing objects in
the database or of type Integer, Real or String. Also for the attribute
predicates #raw("(x l y)") occuring in the formulas there must be a unique
attribute labelled #raw("l") of one class #raw("c") of #raw("x") in the database. For the
exact syntax refer to the appendix of the user manual.

We'll give a first example of a deductive rule by defining the boss of
an employee:

Employee with
   rule
      BossRule : \$ forall e/Employee m/Manager
                   (exists d/Department
                     (e dept d) and (d head m))
                   ==> (e boss m) \$
end

Please note that the text of the formula must be enclosed in \"\$\" and
that this deductive rule is legal, because all variables appearing in
the conlusion literal (#raw("e,m")) are universally (forall) quantified. The
logically equivalent formula

   forall e/Employee m/Manager d/Department
        (e dept d) and (d head m)
        ==> (e boss m)

can also be used. \
*Exercise 3.7: \
Add the _BossRule_ to the database.*

== Adding Integrity Constraints
<adding-integrity-constraints>
The following integrity constraint specifies that no Manager should earn
less than 50000:

Manager with
   constraint
      earnEnough: \$ forall m/Manager x/Integer
                        (m salary x) ==> (x >= 50000) \$
end

Please note that our example model doesn't satisfy this constraint,
because Eleonore earns only 20000. If you use 20000 instead of 50000,
the model satisfies this constraint and adding it will be successfull.

#figure(image("../assets/telos3.png", width: 12cm),
  caption: [
    Telos Editor after the attempt to tell the integrity constraint
  ]
)
<fig:telos3>

Figure #raw("fig:telos3") shows the Telos editor after the attempt to tell the
above integrity constraint. The error message is shown in the error
window. \
*Exercise 3.8: \
Define an integrity constraint stating that no employee is allowed to
earn more money than any of her/his bosses. (The constraint should work
on each individual salary, not on the sum). \
In the subdirectory RULES-AND-CONSTRAINTS of the example directory there is
a more extensive example concerning deductive rules and integrity
constraints. It should be used in addition to this section of the
tutorial.*

== Defining Queries
<defining-queries>
In ConceptBase queries are represented as classes, whose instances are
the answer objects to the query. The system-internal object
\"QueryClass\" may have so-called _query classes_ as instances,
which contain necessary and sufficient membership conditions for their
instances.

*Exercise 3.9: \
Load the object \"QueryClass\" into the Telos Editor window.*

The syntax of query classes is a class definition with superclasses,
attributes, and a membership condition. The set of possible answers to a
query is restricted to the set of common instances of all its
superclasses.

The following query computes all managers, which are bosses of an
employee:

```
QueryClass AllBosses isA Manager with
     constraint
         all_bosse_srule:
             \$ exists e/Employee (e boss this) \$
end

The predefined variable _this_ in the constraint is identified with
all solutions of the query class.

Enter this query into the editor-window and press _Ask_ (not
_Tell_). The query will be evaluated by the server and after a few
seconds the answer will appear both in the protocoll- and in the
editor-window. If an error has occured and the query was typed
correctly, load the Employee-frame and check if the frame contains the
_BossRule_, defined in chapter 3.3.

If the answer was correct we add the query class _AllBosses_ to the
database. The next query uses this query class to restrict the range of
the answer set:

QueryClass BossesWithSalaries isA AllBosses with
   retrieved_attribute
         salary : Integer
end

Before this Query can be evaluated _AllBosses_ must be told,
because it is referenced in _BossesWithSalaries_.

This query returns the instances of AllBosses together with their
salaries. Attributes of the category _retrieved\_attribute_ must be
attributes of one of the superclasses of the query class. In this
example _BossesWithSalaries_ is a subclass of _AllBosses_,
which is subclass of _Manager_, which is subclass of
_Employee_. The _Employee_ class contains the declaration of
the attribute _salary_. So the retrieved\_attribute is permitted
for _BossesWithSalaries_. \
*Exercise 3.10: \
Add the query class \"BossesWithSalaries\" to the database. \
Query classes can also define _computed\_attributes_. These
attributes are defined for the query class itself, but unlike as for
retrieved attributes they do not occur in the definition of the
superclasses of the query class. They are called _computed_,
because their computation is done during evaluating the constraint at
runtime. Computed\_attributes don't exist persistently in the database,
that's why they don't get a persistent attribute label. Instead, the
labels of the computed attributes of the answer objects are
system-generated.*

#figure(image("../assets/telos4.png", width: 12cm),
  caption: [
    Result of asking the query BossesWithSalaries
  ]
)
<fig:telos4>

Figure #raw("fig:telos4") shows the Telos editor after asking the query
BossesWithSalaries. \
The following query class computes for every manager the department that
he or she leads:

QueryClass BossesAndDepartments isA Manager with
   computed_attribute
      head_of : Department
   constraint
      head_of_rule:
          \$ (~head_of head this) \$
end

*Exercise 3.11: \
Define a query class BossesAndEmployees, which is a subclass of Manager
and will return all leaders of departments with their department and the
employees who work there.*

More information about query classes can be found in the User manual,
chapter 2.3 and in the example directory QUERIES.

*Exercise 3.12: \
Stop the ConceptBase server and the user interface.*

This last step completes the tutorial. We hope that it provided a first
impression on _ConceptBase_ and _Telos_. Refer to the other
examples, especially to RULES-AND-CONSTRAINTS and QUERIES and of course to
the user manual to learn more about the features of ConceptBase. There
is also a more advanced tutorial available on metamodeling.

Any comments and suggestions concerning this tutorial or ConceptBase are
welcome. Contact us via #link("http://conceptbase.cc");.

= Solutions to the Exercises
<solutions-to-the-exercises>



- The port number could be changed to 5544 but you can also leave it to
  4001.

- Enter the path of the database TutDB; it is sufficient to replace the
  last two characters #raw("db") by #raw("TutDB"). But remember the whole directory
  path.

- Change source mode to #raw("on"). This is equivalent to the #raw("-db") option
  above.

- Change update mode to #raw("persistent"). Then press \"OK\" to let CBIva
  start a ConceptBase server with the specified parameters and connect
  to it.

  #figure(image("../assets/telos6.png", width: 6cm),
    caption: [
      Start CBserver from CBIva
    ]
  )
  <fig:telos6>



- 
  Department in Class
  end
  

- To load an object from the database into the editor-window, select the
  _frame_ button with tooltip \"Load an object from CBserver\" of
  the button panel or the option _Load Object_ from the _Edit_
  menu. You should have a similar view as displayed in figure
  #raw("fig:telos1").

  #figure(image("../assets/telos1.png", width: 12cm),
    caption: [
      CBIva Telos Editor
    ]
  )
  <fig:telos1>

- 
  Department in Class with
       attribute
              head: Manager
  end
  

- 
  Lloyd in Manager end
  Phil in Manager end
  Eleonore in Manager end
  Albert in Manager end

  Production in Department with
    head
      head_of_Production : Lloyd
  end

  Administration in Department with
    head
      head_of_Administration : Eleonore
  end

  Marketing in Department with
    head
      head_of_Marketing : Phil
  end

  Research in Department with
    head
      head_of_Research : Albert
  end

  Lloyd in Manager with
    salary
        LloydsSalary : 100000
  end

  Phil in Manager with
    salary
        PhilsSalary : 120000
  end

  Eleonore in Manager with
    salary
      EleonoresSalary : 20000
  end

  Albert in Manager with
    salary
      AlbertsSalary : 110000
  end
  

- 
  Michael in Employee with
    dept
      MichaelsDepartment : Production
    salary
      MichaelsSalary : 30000
  end

  Maria in Employee with
    dept
      MariasDepartment : Administration
    salary
      MariasSalary : 10000
  end

  Herbert in Employee with
    dept
      HerbertsDepartment : Marketing
    salary
      HerbertsSalary : 60000
  end

  Edward in Employee with
    dept
      EdwardsDepartment : Research
    salary
      EdwardsSalary : 50000
  end
  

- Figure #raw("fig:telos2") shows the ConceptBase graph editor on object
  Employee. The attributes of Employee and its instances are expanded
  using the menu of the right mouse button clicked on Employee.

  #figure(image("../assets/telos2.png", width: 9cm),
    caption: [
      CB Graph Editor on object Employee
    ]
  )
  <fig:telos2>

- 
- 
  Employee with
  constraint
      salaryIC: \$ forall e/Employee m/Manager x,y/Integer
      (e boss m) and (e salary x) and (m salary y) ==> (x <= y) \$
  end
  

- 
- 
  QueryClass BossesAndEmployees isA Manager with
  computed_attribute
      emps : Employee;
      head_of : Department
  constraint
      employee_rule:
         \$ (~head_of head this) and (~emps dept ~head_of) \$
  end
  

  Figure #raw("fig:telos5") shows parts of the answer to the query
  BossesAndEmployees.

  #figure(image("../assets/telos5.png", width: 10cm),
    caption: [
      Display of answers of BossesAndEmployees
    ]
  )
  <fig:telos5>

- Select the option \"Stop CBserver\" from the \"File\" menu of CBIva.
  Afterwards, stop CBIva via the \"Exit\" option in the same menu. If
  you started the ConceptBase server with the -db option (or with source
  mode set to 'on'), then you find the sources of your definitions also
  in the directory TutDB, see file #raw("System-oHome.sml"). Open this file
  with a text editor such as WordPad.
```
