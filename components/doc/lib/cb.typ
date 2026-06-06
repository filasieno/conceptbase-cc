// Shared ConceptBase.cc documentation helpers for Typst manuals.

#let cb-blue = rgb("#2563eb")

#let title-page(
  document-title: "",
  version: "",
  date: "",
  author: "",
  affiliation: "",
  logo: none,
  abstract: none,
) = {
  set page(numbering: none)
  if logo != none {
    align(center)[
      #image(logo, width: 12cm)
    ]
    v(1.5em)
  }
  align(center)[
    #text(size: 22pt, weight: "bold")[#document-title]
    #if version != "" [
      #v(0.5em)
      #text(size: 14pt)[Version #version]
    ]
    #if date != "" [
      #v(0.3em)
      #text(size: 11pt)[#date]
    ]
    #v(1.5em)
    #text(size: 13pt)[#author]
    #if affiliation != "" [
      #v(0.3em)
      #text(size: 11pt)[#affiliation]
    ]
  ]
  v(2em)
  if abstract != none {
    par(justify: true)[
      #text(weight: "bold")[Abstract.]
      #abstract
    ]
  }
  pagebreak()
}

#let cb-doc(
  title: "",
  bibliography: none,
  body,
) = {
  set document(title: title)
  set page(
    paper: "a4",
    margin: (x: 2.5cm, y: 2.5cm),
    numbering: "1",
  )
  set text(size: 10pt)
  set heading(numbering: "1.1")
  show link: set text(fill: cb-blue)
  show raw: set text(size: 9pt)
  show figure: set align(center)

  outline(title: "Table of Contents", depth: 2)
  pagebreak()

  body
}

#let cbfigure(path, width: 80%, caption, label: none) = {
  figure(
    image(path, width: width),
    caption: caption,
  )
}
