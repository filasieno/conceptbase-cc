#import "../lib/cb.typ": *

#show: cb-doc.with(
  title: "ConceptBase.cc User Manual",
  bibliography: "../references.yml",
)

#include "title.typ"
#include "chapters/Introduction.typ"
#include "chapters/Language.typ"
#include "chapters/DatalogQuery.typ"
#include "chapters/AnswerFormat.typ"
#include "chapters/ECArules.typ"
#include "chapters/Moduleserver.typ"
#include "chapters/CBserver.typ"
#include "chapters/CBiva.typ"
#include "chapters/SyntaxDef.typ"
#include "chapters/O-Telos-Axioms.typ"
#include "chapters/GraphicalTypes.typ"
#include "chapters/Examples.typ"
#include "chapters/BuiltinQueries.typ"

#pagebreak()
#bibliography("../references.yml", title: "References", style: "ieee")
