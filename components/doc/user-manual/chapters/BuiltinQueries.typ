= Predefined Query Classes
<cap:builtin-queries>
This chapter gives an overview of the query classes which are predefined
in a standard ConceptBase installation. The names of parameters of the
queries are set in typewriter font. Most of the queries listed here are
used by the ConceptBase user interface CBIva to interaction with the
CBserver. A normal user typically formulates queries herself. In fact,
most queries listed below are very simple and directly representation as
query class. An exception are the functions for computation and
counting. They cannot be expressed by simple query classes but extend
the expressiveness of the system.

== Query classes and generic query classes
<query-classes-and-generic-query-classes>
These queries can also be used in the constraints of other queries.

=== Instances and classes
<instances-and-classes>
/ ISINSTANCE\:: #block[
Checks whether obj is instance of class. The result is either TRUE or
FALSE.
]

/ IS\_EXPLICIT\_INSTANCE\:: #block[
Same as before, but returns TRUE only if obj is an _explicit_
instance of class.
]

/ find\_classes\:: #block[
Lists all objects of which objname is an instance.
]

/ find\_instances\:: #block[
Lists all instances (implicit and explicit) of class.
]

/ find\_explicit\_instances\:: #block[
Same as before, but only explicit instances are returned.
]

=== Specializations and generalizations
<specializations-and-generalizations>
/ ISSUBCLASS\:: #block[
Checks whether sub is subclass of super. The result is either TRUE or
FALSE.
]

/ IS\_EXPLICIT\_SUBCLASS\:: #block[
Same as before, but returns TRUE only if sub is an _explicit_
subclass of super.
]

/ find\_specializations\:: #block[
Lists the subclasses of class. If ded is TRUE, then the result will also
include implicit subclasses, if ded is FALSE only explicit information
will be included.
]

/ find\_specializations\:: #block[
Same as before, but for super classes.
]

=== Attributes
<attributes>
/ IS\_ATTRIBUTE\_OF\:: #block[
Returns TRUE if src has an attribute of the category attrCat which has
the value dst.
]

/ IS\_EXPLICIT\_ATTRIBUTE\_OF\:: #block[
Same as before, but only for explicit attributes.
]

/ find\_all\_explicit\_attribute\_values\:: #block[
Lists all attribute values of objname that are explicitely defined.
]

/ find\_iattributes\:: #block[
Lists the attributes that _go into_ class.
]

/ find\_referring\_objects\:: #block[
Lists the objects that have an explicit attribute link to class.
]

/ find\_referring\_objects2\:: #block[
Lists the objects that have an explicit attribute link to objname and
for which the attribute link is an instance of cat.
]

/ find\_all\_referring\_objects2\:: #block[
Same as before, but including implicit attributes.
]

/ find\_attribute\_categories\:: #block[
Lists all the attribute categories that may be used for objname. This is
a lookup of all attributes of all classes of objname.
]

/ find\_incoming\_attribute\_categories\:: #block[
In contrast to the previous query, this query returns all attribute
categories that go into objname (i.e.~attribute categories for which
objname can be used as an attribute value).
]

/ find\_attribute\_values\:: #block[
Lists all objects that are attribute values of objname in the attribute
category cat.
]

/ find\_explicit\_attribute\_values\:: #block[
Same as before, but only for explicit attributes.
]

=== Links between objects
<links-between-objects>
/ find\_incoming\_links\:: #block[
Lists the links that _go into_ objname and are instance of
category. Note that all types of links are returned, including
attributes, instance-of-links and specialization links.
]

/ find\_incoming\_links\_simple\:: #block[
Same as before, but without the parameter category.
]

/ find\_outgoing\_links\:: #block[
Lists the links that _come out of_ objname and are instance of
category. Note that all types of links are returned, including
attributes, instance-of-links and specialization links.
]

/ find\_outgoing\_links\_simple\:: #block[
Same as before, but without the parameter category.
]

/ get\_links2\:: #block[
Return the links between src and dst.
]

/ get\_links3\:: #block[
Return the links between src and dst that are instance of cat.
]

=== Other queries
<other-queries>
/ find\_object\:: #block[
This query just returns the object given as parameter objname, if it
exists. Thus it can be used to check whether objname exists, but there
is a builtin query exists which does the same. The query is mainly
useful in combination with a user-defined answer format (e.g.~the Graph
Editor is using this query to retrieve the graphical representation of
the object).
]

/ AvailableVersions\:: #block[
Lists the instances of Version with the time since when they are know.
This query is used by the user interface to use a different rollback
time (Options $arrow.r$ Select Version).
]

/ listModule\:: #block[
Lists the the content of a module as Telos frames, see also section
`sec:module_content`.
]

/ listModuleReloadable\:: #block[
Like listModule but adding a flag to set the module context to the right
module context when the frames need to be loaded again into a CBserver.
]

== Functions
<cap:builtin-queries:functions>
Functions may also be used within other queries. You may define your own
functions (see section `sec:functions`).

=== Computation and counting
<computation-and-counting>
/ COUNT\:: #block[
counts the instances of a class, this may be also a query class
]

/ SUM\:: #block[
computes the sum of the instances of a class (must be reals or integers)
]

/ AVG\:: #block[
computes the average of the instances of a class (must be reals or
integers)
]

/ MAX\:: #block[
gives the maximum of the instances of a class (wrt. the order of $<$ and
$>$, see section `sec:CBL`)
]

/ MIN\:: #block[
gives the minimum of the instances of a class (wrt. the order of $<$ and
$>$, see section `sec:CBL`)
]

/ COUNT\_Attribute\:: #block[
counts the attributes in the specified category of an object
]

/ SUM\_Attribute\:: #block[
computes the sum of the attributes in the specified category of an
object (must be reals or integers)
]

/ AVG\_Attribute\:: #block[
computes the average of the attributes in the specified category of an
object (must be reals or integers)
]

/ MAX\_Attribute\:: #block[
gives the maximum of the attributes in the specified category of an
object (wrt. the order of $<$ and $>$, see section `sec:CBL`)
]

/ MIN\_Attribute\:: #block[
gives the minimum of the attributes in the specified category of an
object (wrt. the order of $<$ and $>$, see section `sec:CBL`)
]

/ PLUS\:: #block[
computes the sum of two reals or integers
]

/ MINUS\:: #block[
computes the difference of two reals or integers
]

/ MULT\:: #block[
computes the product of two reals or integers
]

/ DIV\:: #block[
computes the quotient of two reals or integers
]

/ IPLUS\:: #block[
computes the sum of two integers; result is an integer number
]

/ IMINUS\:: #block[
computes the difference of two integers; result is an integer number
]

/ IMULT\:: #block[
computes the product of two integers; result is an integer number
]

/ IDIV\:: #block[
computes the quotient of two integers and then truncates the quotient to
the largest integer number smaller than or equal to the quotient
]

ConceptBase realizes the arithmetic functions via its host Prolog system
SWI-Prolog. Integer numbers on Linux are represented as 64-bit numbers,
yielding a maximum range from $- 2^64 - 1$ to $2^64 - 1$. SWI-Prolog
supports by default under Windows and Linux64 arbitrarily long integers.
Real numbers are implemented by SWI-Prolog as 64-bit double precision
floating point numbers. ConceptBase uses 12 decimal digits.

=== String manipulation functions
<stringmanu>
/ ConcatenateStrings\:: #block[
concatenates two labels, typically strings; the two arguments can be
expressions that are concatenated after their evaluation; the result is
a string in double quotes
]

/ ConcatenateStrings3\:: #block[
concatenates three labels; arguments may not be expressions
]

/ ConcatenateStrings4\:: #block[
concatenates four labels; arguments may not be expressions
]

/ concat\:: #block[
same as ConcatenateStrings
]

/ StringToLabel\:: #block[
removes the quotes of a string and returns it as a label (not an
object), useful if labels should be passed as a parameter of a query
]

/ toLabel\:: #block[
evaluates the argument and that creates an individual object with the
canonical representation of the argument result; the canonical
representation is an alphanumeric where special characters are replaces
by substrings like `"C30_"` for special characters
]

/ concatl\:: #block[
concatenates the two labels (being the names of any object); the result
is stored as an individual with the concatenated labels; the result is
shown as a label, double quotes are added when the label is not
alphanumeric
]

/ concatl4\:: #block[
like concatl but with the four arguments (being the names of any
object); the result is stored as an individual with the concatenated
labels
]

/ concatl6\:: #block[
like concatl but with concatenates the six arguments; the result is
stored as an individual with the concatenated labels
]

/ resultOf\:: #block[
The function `resultOf(q,x,a)` computes the text answer of calling the
query `q[x]` using the answer format `a` to create the textual answer.
This allows for example to specify complex gproperty labels on the fly
(see also section `htmllabels`) The result of the function call is stored
as an instance of the class `HiddenLabel`. This hides the label from
being displayed by the listModule query
]

/ toString\:: #block[
returns a string for the label of an object,
e.g.~`toString(Class)="Class"`.
]

/ length\:: #block[
returns the number of characters of an object label, excluding the
double quotes when the object is a string,
e.g.~`length("Class")=length(Class)=5`
]

/ isLike\:: #block[
returns TRUE of the object label (first parameter) matches the wildcard
pattern (second parameter), otherwise FALSE,
e.g.~`isLike(Class,"Cla*")=TRUE`
]

/ valueOf\:: #block[
takes as parameter the name of an instance of the class `GlobalVariable`
and returns its value. Currently, we support the global variable
`currentPalette`. It holds the instance of JavaGraphicalPalette, which
is currenty used by the current CBGraph client connected to the
CBserver. Example: `valueOf(currentPalette)=TelosPalette`.
]

Example 1: the expression `toLabel(concat("*",1+2))` will return
`C42_3`. The substring `"C42_"` is the canonical representation (ASCII
number) of `"*"`. The subexpression `1+2` is evaluated to 3.

Example 2: the expression `concatl("alfa",concatl(1+1,"beta"))` returns
`alfa2beta`. Note that the arguments \"alfa\" and \"beta\" are string
constants created as objects on the fly. You can also have attributes
like `bill!earns` as arguments of `concatl`. Then, their labels are used
for the concatenation, here \"earns\". Expressions like
`concatl("alfa"," **")` are also evaluated but are enclosed in double
quotes like `"alfa**"`. Note that all arguments shall be objects.
Strings and integers are automatically recognized by ConceptBase as
objects.

== Builtin query classes
<builtin-query-classes>
These queries must not be used within other queries as they do not
return a list of objects. They may only be used directly from client
programs.

/ exists\:: #block[
Checks whether objname exists and returns yes or no.
]

/ get\_object\:: #block[
Returns the frame representation of objname. This query may be either
called with just one parameter (objname) or with four parameters
(objname, dedIn, dedIsa, dedWith). The ded\*-parameters are boolean
flags that indicate whether implicit (deduced) information should also
be included in the frame representation. Note that the order of the
parameters hast to be the same as listed above.
]

/ get\_object\_star\:: #block[
Returns the frame representation for all objects with a label that match
the given wildcard expression. Only simple wildcards with a star (\*) at
the end are allowed.
]

/ rename\:: #block[
Renames an object from oldname to newname. This is a low-level operation
directly on the symbol table that works directly on the symbol table. It
only checks whether _newname_ is not already used as label for a
different object, no other consistency checks are performed. The
parameters have to be given in the order newname, oldname.
]

= CBserver Plug-Ins
<cap:lpi>
An LPI plug-in (\"logic plug-in\") is a small Prolog program that is
attached to the CBserver (which is implemented in Prolog) at
startup-time. It extends the functionality of the CBserver, for example
for user-defined builtin queries. A plug-in can also interface to the
services of the operating system #footnote[Since we currently supply the
CBserver for Linux only, you need to run the CBserver on a local Linux
computer in your network if you want to use the plug-ins. Note that we
supply a ready-to-use virtual appliance that includes Linux and
ConceptBase and that can be executed via a virtualization engine, see
#link("http://conceptbase.sourceforge.net/import-cb-appliance.html") for
details.];.

You can create a file like `myplugin.swi.lpi` to provide the
implementation for user-defined builtin queries or for call actions in
active rules (see section `sec:eca`). You can use the full range of
functions provided by the underlying Prolog system (here: SWI-Prolog,
#link("http://www.swi-prolog.org");) and the functions of the CBserver
to realize your implementation. You can consult the the CB-Forum for
some examples at
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/2768063");.
You find there examples for sending emails from active rules, and for
extending the set of builtin queries and functions.

== Defining the plug-in
<defining-the-plug-in>
Once you have coded your file `myplugin.swi.lpi`, there are two methods
to attach it to the CBserver. The first method is to copy the file into
an existing database directory created by the CBserver:

```
  cbserver -g exit -d MYDB 
  cp myplugin.swi.lpi MYDB
```

The first command creates the database directory MYDB if not already
existing and initializes it with the pre-defined system classes and
objects. The second command copies the LPI file to the database
directory. This method makes the definitions only visible to a CBserver
that loads the database MYDB.

The second method instructs ConceptBase to load your LPI code to
_any_ new database created by the CBserver. To do so, copy the LPI
file into the system database directory that holds the definitions of
predefined ConceptBase objects:

```
  cp myplugin.swi.lpi <CB_HOME>/lib/SystemDB
```

where `CB_HOME` is the directory into which you installed ConceptBase.
The number of LPI files is not limited. You may define zero, one or any
number of plug-in files.

A couple of useful LPI plug-ins are published via the CB-Forum, see
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/2768063");.
Note that these plug-ins are copyrighted and typically come with their
own license conditions that may be different to the license conditions
of ConceptBase. If you plan to use the plugins for commercial purposes,
you may have to acquire appropriate licenses from the plug-in's authors.

== Calling the plug-in
<calling-the-plug-in>
There are two ways to trigger the call of a procedure implemented by an
LPI plugin.

+ By explicitely calling a builtin query class (or function) whose code
  has been implemented by the LPI plugin. The LPI code would then look
  similar to the code in SYSTEM.SWI.builtin and you must have defined an
  instance of `BuiltinQueryClass` that matches the signature of the LPI
  code. The call to the builtin query class may be enacted from the user
  interface, or it may be included as an `ASKquery` call in an instance
  of `AnswerFormat`. Refer for more information to section
  `subsec`:externalproc and to the directory `Examples/BuiltinQueries` in
  your ConceptBase installation directory.

+ By calling the implemented function as a CALL action of an active
  rule. See section `subsec`:counter for an example. In that case, there
  does not need to be a definition of a builtin query class (or
  function) to declare the signature of the procedure.

If the code of an LPI plugin realizes a ConceptBase function, e.g.
selecting the first instance of a class, then you can use that function
whereever functions are allowed. As an example, consider the definition
of the LPI plugin `selectfirst.swi.lpi` from
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/d2984654/selectfirst.swi.lpi.txt");:

```
  compute_selectfirst(_res,_class,_c1) :-
        nonvar(_class),                              
        cbserver:ask([In(_res,_class)]),             
        !.

  tell: 'selectfirst in Function isA Proposition with
  parameter class: Proposition end'.
```

The first clause is the Prolog code. The predicate must start with the
prefix `compute_` followed by the name of the function. The first
argument is for the result of the function. Subsequently, each input
parameter is represented by two arguments, one for the input parameter
itself and a second as a placeholder of the type of the input parameter.
The second clause tells the new function as ConceptBase object so that
it can be used like any other ConceptBase function. For technical
reasons, the 'tell' clause may not span over more than 5 lines. Use long
lines if the object to be defined is large. The function object (here:
`selectfirst`) is stored in the `System` module of the database. This is
the root module of the module hierarchy, thus functions defined in this
way are visible and executable in all sub-modules. If you omit the
'tell' clause in the LPI file, then you need to tell it manually to the
database. This can also be done in a module different to `System`. In
this case, the function can only be called in those modules where the
function object is visible.

If you just want to invoke the procedure defined in an LPI plugin via
the CALL clause of an active rule, you do not need to include a 'tell'
clause. Consider for example the SENDMAIL plugin from
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/2269675");.

You need to be very careful with testing your code. Only use this
feature for functions that cannot be realized by a regular query class
or by active rules. LPI code has the full expressiveness of a
programming language. Program errors may lead to crashes of the CBserver
or to infinite loops or to harmful behavior such as deletion of files.
Query classes, deductive rules and integrity constraints can never loop
infinitely and can (to the best of our knowledge) only produce answer,
not changes to your file system or interact with the operating system.
Active rules could loop infinitely but also shall not change your file
system and shall not interact with the operating system unless you call
such code explicitely in the active rule.

You can disable the loading of LPI plugins with the CBserver option
`-g nolpi`. The CBserver will then not load LPI plugins upon startup.
This option might be useful for debugging or for disabling loading LPI
plugins that are configured in the `lib/SystemDB` sub-directory of your
ConceptBase installation.

== Programming interface for the plug-ins
<sec:cbserver-extensions>
The CBserver plug-ins need to interface to the functionalities of the
CBserver, the Prolog runtime, and possibly the operating system. To
simplify the programming of the CBserver plug-ins, we document here the
interface of the module `cbserver`. We assume that the code for the
plug-ins is written in SWI-Prolog and the user is familiar with the
SWI-Prolog system.

/ cbserver\:ask(Q,Params,A): #block[
asks the query `Q` with parameters `Params` to the CBserver. The answer
is returned as a Prolog atom in `A`. The atom holds the answer
represented in the answer format of `Q`, see also chapter
`sec:answerformat`. \
Example: `cbserver:ask(find_classes,[bill/objname],A)`
]

/ cbserver\:ask(Preds): #block[
evaluates the predicates in list `Preds`. The predicate can backtrack
and will bind in case of success the free variables in `Preds`. We
currently support only the following predicates: `In`, `A`, `AL`, and
`Isa`. \
Example: `cbserver:ask([In(X,Employee),A(X,salary,1000)])`
]

/ cbserver\:askAll(X,Preds,Set): #block[
finds all objects `X` that satisfy the condition in `Preds` and puts the
result into the list `Set`. Supported predicates in `Preds` are: `In`,
`A`, `AL`, and `Isa`. \
Example: `cbserver:askAll(X,[In(X,Employee),A(X,salary,1000],S)`
]

/ cbserver\:tellFrames(F): #block[
tells all frames contained in the atom `F`. The call will fail if there
is any error in `F`. \
Example: `cbserver:tellFrames(’bill in Employee end’)`
]

/ cbserver\:makeName(Id,A): #block[
converts an object identifier to a readable object name.
]

/ cbserver\:makeId(A,Id): #block[
converts an object name (Prolog atom) into an object identifier used by
the CBserver to identify Telos objects. If `A` is already an object
identifier, it is returned as well in `Id`.
]

/ cbserver\:arg2val(E,V): #block[
transforms an argument (either an object identifier or a functional
expression) to a value (a number or a string). The value can then be
used in Prolog style computations such as arithmetic expressions.
]

/ cbserver\:val2arg(V,I): #block[
transforms a Prolog value (number, string) to an object identifier,
possibly by creating a new object for the value.
]

/ cbserver\:concat(X,Y): #block[
concats the strings (Prolog atoms) contained in the list `X`. The result
is returned in `Y`.
]

Note that ConceptBase internally manages concepts by their object
identifier. The programming interface instead addresses concepts (and
objects) by their name, i.e.~the label of the object or the Prolog value
corresponding to the label. You may have to use the procedure `makeName`
and `makeId` to switch between the two representations. The two
procedures `arg2val` and `val2arg` are useful for defining new builtin
functions on the basis of Prolog's arithmetic functions. Assume for
example, that the object identifier `id123` has been created to
correspond to the real number `1.5`. Then, the following relations hold:
`makeName(id123,’1.5’)`, `arg2val(id123,`$1.5$`)`. Hence, `makeName`
returns the label `’1.5’` whereas `arg2val` returns the number $1.5$.

The interface shall be extended in the future to provide more
functionality. Be sure that you only use this feature if user-defined
query classes cannot realize your requirements!
