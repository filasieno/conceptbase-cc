= O-Telos Axioms
<cha:otelos-axioms>
O-Telos is the variant of Telos (originally defined by John Mylopoulos,
Alex Borgida, Manolis Koubarakis and others) that is used by the
ConceptBase system. This list is the complete set of pre-defined axioms
of O-Telos and thus defines the semantics of a O-Telos database (without
user-defined rules and constraints). The subsequent axioms are written
in a first-order logic syntax but all can be converted to Datalog with
negation (though there is some choice in the conversion wrt. mapping to
rules or constraints).

- Axiom 1: Object identifiers are unique. \
  $forall med o \, x_1 \, n_1 \, y_1 \, x_2 \, n_2 \, y_2 med P \( o \, x_1 \, n_1 \, y_1 \) and P \( o \, x_2 \, n_2 \, y_2 \) arrow.r.double$
  \
  $\( x_1 = x_2 \) and \( n_1 = n_2 \) and \( y_1 = y_2 \)$

- Axiom 2: The name of individual objects is unique. \
  $forall med o_1 \, o_2 \, n med P \( o_1 \, o_1 \, n \, o_1 \) and P \( o_2 \, o_2 \, n \, o_2 \) arrow.r.double \( o_1 = o_2 \)$

- Axiom 3: Names of attributes are unique in conjunction with the source
  object. \
  $forall med o_1 \, x \, n \, y_1 \, o_2 \, y_2 med P \( o_1 \, x \, n \, y_1 \) and P \( o_2 \, x \, n \, y_2 \) arrow.r.double \( o_1 = o_2 \) or \( n = i n \) or \( n = i s a \)$

- Axiom 4: The name of instantiation and specialization objects
  (_in, isa_;) is unique in conjunction with source and destination
  objects. \
  $forall med o_1 \, x \, n \, y \, o_2 med P \( o_1 \, x \, n \, y \) and P \( o_2 \, x \, n \, y \) and \( \( n = i n \) or \( n = i s a \) \) arrow.r.double \( o_1 = o_2 \)$

- Axioms 5,6,7,8: Solutions for the predicates _In_;, _Isa_;,
  and A are derived from the object base. \
  $forall med o \, x \, c med P \( o \, x \, i n \, c \) arrow.r.double italic("In") \( x \, c \)$
  \
  $forall med o \, c \, d med P \( o \, c \, i s a \, d \) arrow.r.double italic("Isa") \( c \, d \)$
  \
  $forall med o \, x \, n \, y \, p \, c \, m \, d med P \( o \, x \, n \, y \) and P \( p \, c \, m \, d \) and italic("In") \( o \, p \) arrow.r.double A L \( x \, m \, n \, y \)$
  \
  $forall med x \, m \, n \, y med A L \( x \, m \, n \, y \) arrow.r.double A \( x \, m \, y \)$

- Axiom 9: An object $x$ may not neglect an attribute definition in one
  of its classes. \
  $forall med x \, y \, p \, c \, m \, d med italic("In") \( x \, c \) and A \( x \, m \, y \) and P \( p \, c \, m \, d \) arrow.r.double$
  \
  $exists med o \, n med P \( o \, x \, n \, y \) and italic("In") \( o \, p \)$

- Axioms 10,11,12: The _isa_ relation is a partial order on the
  object identifiers. \
  \$\\forall \~c \~\\textit{In}(c,\\hbox{\\\#Obj}) \\Rightarrow \\textit{Isa}(c,c)\$
  \
  $forall med c \, d \, e med italic("Isa") \( c \, d \) and italic("Isa") \( d \, e \) arrow.r.double italic("Isa") \( c \, e \)$
  \
  $forall med c \, d med italic("Isa") \( c \, d \) and italic("Isa") \( d \, c \) arrow.r.double \( c = d \)$

- Axiom 13: Class membership of objects is inherited upwardly to the
  superclasses. \
  $forall med p \, x \, c \, d med italic("In") \( x \, d \) and P \( p \, d \, i s a \, c \) arrow.r.double italic("In") \( x \, c \)$

- Axiom 14: Attributes are \"typed\" by their attribute classes. \
  $forall med o \, x \, n \, y \, p med P \( o \, x \, n \, y \) and italic("In") \( o \, p \) arrow.r.double exists med c \, m \, d med P \( p \, c \, m \, d \) and italic("In") \( x \, c \) and italic("In") \( y \, d \)$

- Axiom 15: Subclasses which define attributes with the same name as
  attributes of their superclasses must refine these attributes. \
  $forall med c \, d \, a_1 \, a_2 \, m \, e \, f$ \
  $italic("Isa") \( d \, c \) and P \( a_1 \, c \, m \, e \) and P \( a_2 \, d \, m \, f \) arrow.r.double italic("Isa") \( f \, e \) and italic("Isa") \( a_2 \, a_1 \)$

- Axiom 16: If an attribute is a refinement (subclass) of another
  attribute then it must also refine the source and destination
  components. \
  $forall med c \, d \, a_1 \, a_2 \, m_1 \, m_2 \, e \, f$ \
  $I s a \( a_2 \, a_1 \) and P \( a_1 \, c \, m_1 \, e \) and P \( a_2 \, d \, m_2 \, f \) arrow.r.double italic("Isa") \( d \, c \) and italic("Isa") \( f \, e \)$

- Axiom 17: For any object there is always a unique \"smallest\"
  attribute class with a given label _m_;. \
  $forall med x \, m \, y \, c \, d \, a_1 \, a_2 \, e \, f med \( italic("In") \( x \, c \) and italic("In") \( x \, d \) and P \( a_1 \, c \, m \, e \) and P \( a_2 \, d \, m \, f \)$
  \
  $arrow.r.double exists med g \, a_3 \, h med italic("In") \( x \, g \) and P \( a_3 \, g \, m \, h \) and italic("Isa") \( g \, c \) and italic("Isa") \( g \, d \) \)$

- Axioms 18-22: Membership to the builtin classes is determined by the
  object's format. \
  \$\\forall \~o,x,n,y \~(P(o,x,n,y) \\Leftrightarrow
                     \\textit{In}(o,\\hbox{\\\#Obj}))\$ \
  \$\\forall \~o,n \~(P(o,o,n,o) \\land (n \\ne in) \\land (n \\ne isa) \\Leftrightarrow
                     \\textit{In}(o,\\hbox{\\\#Indiv}))\$ \
  \$\\forall \~o,x,c \~(P(o,x,in,c) \\land (o \\ne x) \\land (o \\ne c) \\Leftrightarrow
                     \\textit{In}(o,\\hbox{\\\#Inst}))\$ \
  \$\\forall \~o,c,d \~(P(o,c,isa,d) \\land (o \\ne c) \\land (o \\ne d) \\Leftrightarrow
                     \\textit{In}(o,\\hbox{\\\#Spec}))\$ \

  \$\\forall \~o,x,n,y \~(P(o,x,n,y) \\land (o \\ne x) \\land (o \\ne y) \\land
                    (n \\ne in) \\land (n \\ne isa)
  \\Leftrightarrow \\textit{In}(o,\\hbox{\\\#Attr}))\$

- Axiom 23: Any object falls into one of the four builtin classes. \
  \$\\forall \~o \~\\textit{In}(o,\\hbox{\\\#Obj}) \\Rightarrow
                      \\textit{In}(o,\\hbox{\\\#Indiv}) \\lor
                      \\textit{In}(o,\\hbox{\\\#Inst}) \\lor
  \\textit{In}(o,\\hbox{\\\#Spec}) \\lor
                          \\textit{In}(o,\\hbox{\\\#Attr})\$

- Axioms 24-28: There are five builtin classes. \
  \$P(\\\#Obj,\\\#Obj,\\hbox{Proposition},\\\#Obj)\$ \
  \$P(\\\#Indiv,\\\#Indiv,\\hbox{Individual},\\\#Indiv)\$ \
  \$P(\\\#Attr,\\\#Obj,\\hbox{attribute},\\\#Obj)\$ \
  \$P(\\\#Inst,\\\#Obj,\\hbox{InstanceOf},\\\#Obj)\$ \
  \$P(\\\#Spec,\\\#Obj,\\hbox{IsA},\\\#Obj)\$

- Axiom 29: Objects must be known before they are referenced. The
  operator $prec.curly.eq$ is a (predefined) total order on the set of
  identifiers. \
  $forall med o \, x \, n \, y med P \( o \, x \, n \, y \) arrow.r.double \( x prec.curly.eq o \) and \( y prec.curly.eq o \)$

- Axioms 30,31 (axiom schemas): For any object
  $P \( p \, c \, m \, d \)$ in the extensional object base we have two
  formulas for \"rewriting\" the $italic("In")$ and $A$ predicates. The
  $italic("In")$ is mapped to a unary predicate where the class name is
  forming part of the predicate name and the $A$ predicates is mapped to
  a binary predicate that carries the identifier of the class of the
  attribute in its predicate name. Internally, user-defined deductive
  rules that derive $italic("In")$ and $A$ predicates will also be
  rewritten accordingly. This extends the choices for static
  stratification. \
  $forall med o med italic("In") \( o \, p \) arrow.r.double italic("In") . p \( o \)$
  \
  $forall med o \, x \, n \, y med P \( o \, x \, n \, y \) and italic("In") \( o \, p \) arrow.r.double A . p \( x \, y \)$

The following axioms are taken from papers on Telos (i.e.~formulated by
Mylopoulos, Borgida, Koubarakis, Stanley and Greenspan): axioms 2, 3, 4,
10, 12, 13, 14. Axiom 1 is probably also in an earlier Telos paper
though we could not immediately find it there. The axioms 15 and 16 are
similar to the structural ISA constraint of Taxis @Taxis80 for
attributes. In O-Telos, we do however not inherit attributes downward to
subclasses but rather constrain refined attributes at subclasses in the
sense of co-variance. Moreover, attributes in O-Telos are objects as
well, hence the notion of specialization is more complicated than for
the Taxis case. Axiom 17 is needed to be able to uniquely match an
attribution predicate to a most specific attribute. This is utilized in
the compilation of logical expressions, in particular for generating
triggers that only evaluate the affected logical expressions when an
update occurs. The remaining axioms 18-28 are also specific to O-Telos.
They define the five predefined objects in O-Telos. Axiom 29 takes care
that objects cannot refer via its source/destination parts to objects
that were defined later than the object itself. This virtually forbids
to define an link between two objects when one of the objects is not yet
defined. While this sounds natural, we need to posutlate it. Otherwise,
we can't guarantee that we can refer to any object by a name. Axioms 30
and 31 are used to transfer instantiation and attribution facts from the
extensional databases to the intensional database. They have more a
technical purpose in the mapping of logical expressions to Datalog.

While O-Telos has just five predefined objects and 31 predefined axioms,
the ConceptBase system has many more pre-defined objects to provide a
better modeling experience and for representing concepts like query
classes, active rules, functions etc. They are in a way also predefined
but are less essential in understanding the foundations. So, O-Telos is
the foundation of ConceptBase but ConceptBase has more pre-defined
constructs than those mentioned in the axioms of O-Telos.

Axiom 15 is only applicable to attribute classes, i.e.~where the
attribute value is an object that potentially can have instances. If the
attribute value is for example a number, then ConceptBase will not
enforce the axiom. We leave the formula unchanged, since classes for
numbers such as `Integer`, are not part of the axiomatization.

ConceptBase allows to add user-defined rules and constraints. The
semantics of an O-Telos database including such rules and constraints is
the perfect model of the deductive database with the
$P \( o \, x \, n \, y \)$ as the only extensional predicate and all
axioms and user-defined rules/constraints as deductive rules. Note that
integrity constraints can be rewritten to deductive rules deriving the
predicate _inconsistent_;.

This list of axioms is excerpted from M.A.~Jeusfeld: Änderungskontrolle
in deduktiven Objektbanken. Dissertation Universität Passau, Germany,
1992. Available as Volume DISKI-19 from INFIX-Verlag, St. Augustin,
Germany or via
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/d340216/diski19.pdf")
(in German).

Axioms 19-21 have been corrected after Christoph Radig found an example
that led to the undesired instantiation of an individual object to
\#Inst or \#Spec, respectively.
