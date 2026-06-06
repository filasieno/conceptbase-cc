// section conversion failed
\chapter{Answer Formats for Queries}
\label{sec:answerformat}

The ConceptBase server provides an ASK command in its interface, which
allows to specify in which text-based format the answer should be returned. There
are two pre-defined formats: one for returning a list of object names,
and one for returning a list of object frames. These two formats can
be extended by user-defined answer formats.


Examples for answer formats are available from GitLab,
see \url{https://gitlab.com/mjeu/conceptbas


= Basic definitions
<basic-definitions>
By default, ConceptBase displays answers to queries in the FRAME format
(see 'A' and 'B' below). For many applications, other answer
representations are more useful. For example, relational data is more
readable in a table structure. Another important example are XML data.
If ConceptBase is integrated into a Web-based information system, then
answers in HTML format are quite useful. For this reason, answer format
definitions are provided.

Answer formats in ConceptBase are based on term substitutions where
terms are evaluated against substitution rules defined by the answers to
a query. A substitution rule has the form $L arrow.r R$ with the
intended meaning that a substring $L$ in a string is replaced by the
substring $R$. The object of a term substitution is a string in which
terms may occur, for example:

#quote(block: true)[
this is a string called `{a}` with a term `{b}`
]

Assume the substitution rules:

- `{a}` $arrow.r$ string no. `{x}`

- `{b}` $arrow.r$ that was subject to substitution

- `{x}` $arrow.r$ 123

The derivation of a string with terms proceeds from left to right.
First, the term occurence `{a}` is dealt with. The next term in the
string is then `{x}` which is evaluated to `123`. Finally, `{b}` is
substituted and the result string is

We denote a single derivation step of a string $S_1$ to a string $S_2$
by $S_1 arrow.r.double S_2$. It is defined when there occurs a substring
$L$ in $S_1$, i.e. $S_1 = V + L + W$ and a substitution rule
$L arrow.r R$ and $S_2 = V + R + W$. The substrings $V$ and $W$ may be
empty. A string $S$ is called ground when no substition rule can be
applied. A sequence
$S arrow.r.double S_1 arrow.r.double dots.h arrow.r.double S_n$ is
called a derivation of S. A complete derivation of S ends with a ground
string. In our example, the complete derivation is:

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [], [`this is a string called ``{a}`` with a term ``{b}``.`],
    [$arrow.r.double$], [`this is a string called string no. ``{x}`` with a term ``{b}``.`],
    [$arrow.r.double$], [`this is a string called string no. 123 with a term that was`],
    [], [`subject to substitution.`],
  )]
  , kind: table
  )

An exception to the left-to-right rule are complex terms like
`{do({y})}`. Here, the inner term `{y}` is first evaluated (e.g. to 20)
and then the result `{do(20)}` is evaluated.

In general, term substitution can result in infinite loops. This looping
can be prevented either by restricting the structure of the substitution
rule or by terminating the substitution process after a finite number of
steps. The end result of a substitution process of a string is called
its derivation. In ConceptBase, the substitution rules are guaranteeing
termination except for the case of external procedures. The problem with
the exception is solved by prohibiting cyclic calls of the same external
procedure during the substitution of a call. A cyclic call is a call
that has the same function name (e.w. query class) and the same
arguments (expressed as parameter substitutions).

In ConceptBase, an answer format is an instance of the new pre-defined
class 'AnswerFormat'.

```
Individual AnswerFormat in Class with
  attribute
     forQuery : QueryClass;
     order : Order;
     orderBy : String;
     head : String;
     pattern : String;
     tail : String;
     fileType: String
end
```

The first attribute assigns an answer format to a query class (a query
may have at most one answer format). The second and third attribute
specify the sorting order of the answer, i.e. one can specify by which
field an answer is sorted, and whether the answer objects are sorted
'ascending' or 'descending' (much like in SQL). The 'orderBy' attribute
specifies the property by which the answer shall be sorted. The most
common value is the expression \"this\", i.e.~sort the answer by the
name of the objects in the answer. You can also specify an attribute
expression such as \"this.name\" referring to an answer variable. If you
specify \"none\" for 'orderBy', then the answer is not sorted. If the
number of objects in an answer exceeds 5000, then no sorting is applied
due to memory limitations.

The 'head', 'pattern', and 'tail' arguments are strings that define the
substring substitution when the answer is formatted. They contain
substrings of type expr that are replaced. The head and tail strings are
evaluated once, independent form the answer to the query. Usually, they
do not contain expressions but only text. The response to a query is a
set of answer objects A1,A2,.... The pattern string is evaluated against
each answer object. For each answer object, the derivation of the
pattern is put into the answer text. Hence, the complete answer consists
of

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [], [derivation of head string],
    [\+], [derivation of pattern string for answer object A1],
    [\+], [derivation of pattern string for answer object A2],
    [], [$dots.h$],
    [\+], [derivation of tail string],
  )]
  , kind: table
  )

The `fileType` attribute is explained in section `sec:af_filetype`.

In the next sections, we will explain more details about answer formats
using the following example: An answer object A to a query class QC has
by default a 'frame' structure

```
   A in QC with
     cat1
        label11: v11;
        label12: v12
        [...]
     cat2
        label21: v21
     [...]
   end
```

In case of a complex view definition VC, the values vij can be answer
objects themselves, e.g.

```
   B in VC with
     cat1
        label11: v11;
        label12: v12
        [...]
     cat2
        label21: v21 with
                   cat21
                     label211: v211
                 [...]
                 end
     [...]
   end
```


// section conversion failed
\section{Constructs in answer formats}

\subsection{Simple expressions in patterns}

We first concentrate on the pattern attribute, i.e. they are not applicable in the head or tail attribute
of an answer format. The pattern of an answer format is applied to {\em each\/} answer object 
of a given query call, effectively transforming it according to the pattern.
The following expressions are allowed. Capital letters in the list below indicate that the 
term is a placeholder for some label occuring


= Parameterized answer formats
<parameterized-answer-formats>
The general way to use an answer format for a query is to define the
attribute `forQuery`. Another possibility is to specify the answer
format for a query is to use the answer representation field of the ASK
method in the IPC interface.

The following code is an example for specifying a user-defined answer in
the ASK method. This example is written in Java and uses the standard
Java API of ConceptBase (see the Programmer's Manual for details).

```
import i5.cb.api.*;

public class CBAnswerFormat {

    public static void main(String[] argv) throws Exception {

        CBclient cb=new CBclient("localhost",4001,null,null);

        CBanswer ans=cb.ask("find_specializations[Class/class,TRUE/ded]",
                        "OBJNAMES","AFParameter[bla/somevar]","Now");
        System.out.println(ans.getResult());
        cb.cancelMe();
```

In the example, a connection is made to a ConceptBase server on
localhost listening on port 4001. The `ask`-method of the CBclient class
sends a query to the server. The first argument is the query, the second
argument is the format of the query (in this example, it is just one
object name), the third argument is the answer representation, and the
last argument is the rollback time.

The third argument, is the the answer representation. There are four
predefined answer representations. `FRAME` returns the answers as Telos
frames, including retrieved and computed attributes. `LABEL` returns
only the names of the answer objects as a comma-separated list. Thirdly,
the format `JSONIC` returns the answer in JSON-like frames. Finally,
`default` lets the CBserver choose between `LABEL` (for function calls),
the explicit answer format assigned for a query (attribute `forQuery`),
and `FRAME` (otherwise). Besides these pre-defined answer
representations, one can specify user-defined answer formats. This is
also the preferred way. In our case, it is a parameterized answer
format: `AFParameter[somevalue/somevar]`. This means that the result of
the query will be formatted according to the answer format `AFParameter`
and the variable `somevar` will be replaced with `somevalue`. The
variable can be used like any other expression, i.e.~it must be enclosed
in `{}`.

The following definition of `AFParameter` is an example, how the
parameter can be used in the pattern. If the parameter is not specified,
the string `{somevar}` will not be replaced.

```
Individual AFParameter in AnswerFormat with
  head hd : "<result>"
  tail tl : "</result>"
  pattern
     p : "
<object>
  <type>{somevar}</type>
  <name>{this}</name>
</object>"
end
```

Note, that you can use any answer format (with or without parameters) as
answer representation in the ASK method.


= File type of answer formats
<sec:af_filetype>
The optional `fileType` attribute of answer formats is used by the
server-side materialization of query results (section
`sec:module_views`). ConceptBase will use the specified file type when
storing the query results in the file system. The default value is
\"txt\". The attribute is single-valued though single-valuedness is not
enforced.


= Bulk query calls
<sec:bulkqueries>
It is sometimes useful to call the same query class with multiple
arguments in a single call rather than in a sequence of calls. Each
individual call from a ConceptBase client to the server comes with a
certain latency time. Thus, if one would have to call the same query for
dozens of arguments in a sequence, most of the answer time would
actually be the latency time.

To address this problem, the CBserver offers a query call pattern for
bulk queries:

```
bulk[q,x1,x2,x3,...]
```

The query `q` stands for a query class with a single parameter. The bulk
query is converted by the CBserver into the following sequence of query
calls:

```
q[x1],q[x2],q[x3],...
```

The answers to the query call are collected into a single answer set and
then transformed with the answer format of the query call. Hence, the
answer format is applied to the whole answer and not to the part
answers.

Example:

```
   ask bulk[Q,abc,def] OBJNAMES MyFormatA Now
```

Sorting of answers is disabled for bulk queries in order to return the
answers in the sequence indicated by the arguments of the bulk query
call. Here, the answer to the argument `abc` shall precede the answer to
argument `def`. Arguments that do not reference an existing object are
removed from the argument list by the CBserver before answering the
query. Bulk queries are only supported for generic query classes with a
single parameter. The query class may not be a builtin query class.

The main purpose of bulk queries is to speed up the interaction between
the ConceptBase clients, such as CBGraph, and the CBserver. You can
however use them with the CBShell.
