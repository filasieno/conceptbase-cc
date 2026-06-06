= Syntax Specifications
<cha:syntax>
== Syntax specifications for Telos frames

```
<object>        --> <objectname> <objectname> <inspec> <isaspec> 
                      <withspec> <endspec>
                 |  <objectname> <inspec> <isaspec> <withspec> <endspec>

<objectname>    --> ( <objectname>  )
                 |   <label> <bindings>
                 |   <objectname>  SELECTOR1 <label>
                 |   <objectname>  SELECTOR2 <objectname>

<bindings>      -->  <empty>
                 |   [ <bindinglist>  ]

<bindinglist>   -->  <singlebinding>
                 |   <bindinglist>  , <singlebinding>

<singlebinding> -->  <objectname> / <label>
                 |   <label> : <objectname>

<inspec>        -->  <empty>
                 |   in <classlist>

<isaspec>       -->  <empty>
                 |   isA <classlist>

<classlist>     -->  <objectname>
                 |   <objectname>  , <classlist>

<withspec>      -->  <empty>
                 |   with <decllist>

<decllist>      -->  <empty>
                 |   <declaration>
                 |   <decllist> <declaration>

<declaration>   -->  <attrcatlist> <proplist>

<attrcatlist>   -->  <label>
                 |   <attrcatlist>  , <label>

<proplist>      -->  <property>
                 |   <proplist>  ; <property>

<property>      -->  <label>  : <objectname>
                 |   <label>  : <complexref>
                 |   <label>  : <enumeration>
                 |   <label>  : <pathexpression>

<complexref>    -->  <objectname> <withspec> <endspec>

<enumeration>   -->  [ <classlist>  ]

<pathexpression>-->  <objectname>  SELECTORB <pathargument>

<pathargument>  -->  <label>
                 |   <label>  SELECTORB <pathargument>
                 |   <restriction>
                 |   <restriction>  SELECTORB <pathargument>

<restriction>   -->  ( <label>  : <enumeration>  )
                 |   ( <label>  : <pathexpression>  )
                 |   ( <label>  : <objectname>  )

<endspec>       -->  end

<label>         -->  ALPHANUM
                 |   LABEL
                 |   NUMBER
```

Note: ConceptBase represents internally object identifiers as
_id\_NUMBER_ where _NUMBER_ is a sequence of digits. For this
reason, labels matching this pattern are forbidden in the Telos frame
syntax.

== Syntax of the rule and constraint language

In the definitions below the term `literal` is a synonym for predicate.

```
<assertion>     --> <rule>
                 |  <constraint>

<rule>          --> forall <variableBindList> ( <formula> ) ==> <literal>
                 |  <formula> ==> <literal>
                 |  <literal>

<constraint>    --> <formula>

<formula>       --> exists <variableBindList> <formula>
                 |  forall <variableBindList> <formula>
                 |  not <formula>
                 |  <formula> <==> <formula>
                 |  <formula> ==> <formula>
                 |  <formula> and <formula>
                 |  <formula> or <formula>
                 |  ( <formula> )
                 |  <literal>
                 |  <literal2>

<variableBindList>--> <variableBind> <variableBindList>
                   |  <variableBind>

<variableBind>  --> <varList> / <objectname>
                 |  <varList> / [ <objList> ]
                 |  ALPHANUM / <selectExpB>

<varList>       --> ALPHANUM , <varList>
                 |  ALPHANUM

<objectname>    --> <label>
                 |  <selectExpA>
                 |  <deriveExp>

<label>         --> ALPHANUM
                 |  LABEL
                 |  NUMBER

<literal>       --> FUNCTOR ( <literalArgList> )
                 |  ( <literalArg> <infixSymbol> <literalArg> )
                 |  ( <arExpr> COMPSYMBOL <arExpr> )
                 |  ( <literalArg> <label>/<label> <literalArg> )
                 |  BOOLEAN

<literal2>      --> ( <label> in <selectExpB> )
                 |  ( <selectExpA> in <selectExpB> )
                 |  ( <selectExpB> isA <selectExpB> )
                 |  ( <selectExpB> = <selectExpB> )

<infixSymbol>   --> INFIXSYMBOL
                 |  <label>

<literalArgList>--> <literalArg> , <literalArgList>
                 |  <literalArg>

<literalArg>    --> <objectname>

<arExpr>        --> <arExpr> + <arTerm> 
                 |  <arExpr> - <arTerm> 
                 |  <arTerm>

<arTerm>         --> <arTerm> * <arFactor>
                 | <arTerm> / <arFactor>
                 | <arFactor>

<arFactor>       --> ( <arExpr> )
                 | <objectname>
                 | <funExpr>

<selectExpA>    --> <selectExpA> <selector> <selectExpA>
                 |  ( <selectExpA> )
                 |  <label>

<selector>      --> SELECTOR1
                 |  SELECTOR2

<deriveExp>     --> <label> [ <deriveExpList> ]
                 | <label [ <literalArgList> ]
                 |  <funExpr>

<funExpr>        --> <label>()
                 |  <label>(<literalArgList>)

<deriveExpList> --> <singleExp> , <deriveExpList>
                 |  <singleExp>

<singleExp>     --> <literalArg> / <label>
                 |  <label> : <label>

<selectExpB>    --> <label> SELECTORB <label>
                 |  <label> SELECTORB <selectExpB2>
                 |  <label> SELECTORB <restriction>

<selectExpB2>   --> <selectExpB>
                 |  <restriction> SELECTORB <label>
                 |  <restriction> SELECTORB <selectExpB2>
                 |  <restriction> SELECTORB <restriction>

<restriction>   --> ( <label> : <label> )
                 |  ( <label> : <selectExpA> )
                 |  ( <label> : <selectExpB> )
                 |  ( <label> : [ <objList> ] )

<objList>       --> <objectname> , <objList>
                 |  <objectname>
```

== Syntax of active rules
<sec:ecasyntax>
The event, condition and actions of an ECArule are specified as a
special assertion. Therefore, the syntax is an extension of the
_normal_ assertion language, shown in the section before.

```
<ecarule>       --> <variableBindList>
                    ON [TRANSACTIONAL] <ecaevent> [FOR ALPHANUM]
                    <ifclause> <ecacondition>
                    DO <actionlist>
                    <optelseaction>

<ifclause>      --> IF
                 |  IFNEW

<ecaevent>      --> <eventop>(<literal>)
                 |  <eventop> <literal>
                 |  <askop>(<literalArg>)
                 |  <askop> <literalArg> 

<eventop>       --> Tell | tell
                 |  Untell | untell

<askop>         --> Ask | ask

<ecacondition>  --> <condformula>
                 |  true
                 |  false

<condformula>   --> <literal>
                |   not <condformula>
                |   <condformula> and <condformula>
                |   <condformula> or <condformula>
                |   ( <condformula> )

<actionlist>    --> <action> , <actionlist>
                 |  <action>

<action>        --> <actionop>(<literal>)
                 |  <actionop> <literal>
                 |  noop
                 |  reject

<actionop>      --> Tell | tell
                 |  Untell | untell
                 |  Retell | retell
                 |  Ask | ask
                 |  Call | call | CALL
                 |  Raise | raise

<optelseaction> --> ELSE <actionlist>
                 |  <empty>
```

== Terminal symbols

```
 ALPHANUM       --> [a-z|A-Z|0-9|ACCENTCHAR]+

 ACCENTCHAR     --> umlauts and accents that are included in the 8bit ASCII code

 LABEL          --> sequences of characters excluding .|'"$:;!^->=,()[]{}/ and
                    special characters like newlines, tabs, backspace, blanks
                |   any sequence of characters enclosed in double quotes ("), 
                    a double quote  must be escaped by \ which must be escaped by \
                |   any sequence of characters enclosed in $ except $, 
                    which must be escaped by \

 NUMBER         --> REAL | INTEGER

 REAL           --> [-]?([0-9]+\.[0-9]*|[0-9]*\.[0-9]+)([Ee][-+]?[0-9]+)?

 INTEGER        --> [-]?[0-9]+

 BOOLEAN        --> TRUE | FALSE

 FUNCTOR        --> From | To | A | Ai | AL | In
                | Isa | Label | P |  LT | GT | LE | GE | EQ | NE | IDENTICAL
                | UNIFIES | Known

 COMPSYMBOL    --> < | > | <= | >= | = | <> | == | \= 
 
 INFIXSYMBOL    --> COMPSYMBOL | in | isA

 SELECTOR1      -->  "!" | "^"

 SELECTOR2      -->  "->"| "=>"

 SELECTORB      -->  "." | "|"
```

== Syntax specifications for SML fragments
<sec:fragments>
This format is only internally used to represent Telos frames as Prolog
terms. It is included only for historical reasons.

```
 <SMLfragment>  --> SMLfragment(<what> , <in_omega> , <in> , <isa> , <with> )

 <what>         --> what(<object> )

 <in_omega>     --> in_omega(nil)
                 |  in_omega([<classlist> ])

 <in>           --> in(nil)
                 |  in([<classlist> ])

 <isa>          --> isa(nil)
                 |  isa([<classlist> ])

 <with>         --> with(nil)
                 |  with([<attrdecllist> ])

 <classlist>    --> class(<object> )
                 |  <classlist> , class(<object> )

 <attrdecllist> --> attrdecl(<attrcategorylist> , <propertylist> )
         |  <attrdecllist> , attrdecl(<attrcategorylist> , <propertylist> )

 <attrcategorylist>--> nil
                 |  [ <labellist> ]

 <propertylist> --> nil
                 |  [ <propertylist2> ]

 <propertylist2>--> property(<label> , <propertyvalue> )
                 |  <propertylist2> , property(<label> , <propertyvalue> )

 <propertyvalue>--> <object>
                 |  <selectExpB>
                 |  enumeration( [ <classlist> ] )
                 |  [ <SMLfragment> ]

 <selectExpB>   --> selectExpB( <restriction> , <selectOperator> , <selectExpB> )
                 |  selectExpB( <restriction> , <selectOperator> , <object> )
                 |  selectExpB( <object> , <selectOperator> , <selectExpB> )
                 |  selectExpB( <object> , <selectOperator> , <object> )

 <restriction>  --> restriction( <label> , <selectExpB> )
                 |  restriction( <label> , enumeration( [ <classlist> ] ) )
                 |  restriction( <label> , <object> )

 <selectOperator> --> dot
                 | bar

 <labellist>    --> <label>
                 |  <labellist> , <label>

 <label>        --> ALPHANUM
                 |  LABEL
                 |  NUMBER

 <object>       --> derive([ <substlist> ])
                 |  <selectexp>

 <substlist>    --> <singlesubst>
                 |  <substlist> , <singlesubst>

 <singlesubst>  --> substitute(<object> , <label> )
                 |  specialize(<label> , <label> )

 <selectexp>    --> <label>
                 |  select(<selectexp> , SELECTOR1, <label> )
                 |  select(<selectexp> , SELECTOR2, <selectexp> )
```
