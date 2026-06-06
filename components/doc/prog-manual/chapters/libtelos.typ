= Processing of Telos Frames: libtelos
<cha:libtelos>
This chapter explains the library `libtelos`, which contains the Telos
parser. The Telos parser is able to parse the answers in FRAME or LABEL
format from ConceptBase.

To call the Telos parser, you must link your program with the library
`libtelos.a/libtelos.dll` which can be found in the directory
``CB_HOME`/<arch>/lib` where `<arch>` is either sun4, i86pc, linux, or
windows.

In your source files, you must include the header files `fragment.h`,
te\_access.h, `te_callparser.h`, `te_cursor.h`, and/or `te_smlutil.h`.
All header files are located in the directory ``CB_HOME`/include`.

The following sections explain several functions to call the parser and
to handle the data structures. In principle, there are three different
ways to parse and to access Telos frames:

- Using the functions and data structures defined in `fragment.h`,
  `te_callparser.h`, and `te_smlutil.h`: The Telos parser is invoked
  directly and the contents of the Telos frames is retrieved by
  navigating over a list of fragments (a fragment is a data structure
  for a Telos frame). See section `sec:fragmenth` for details.

- Using the functions and data structures defined in te\_access.h: Telos
  frames are represented in vectorized structure. One can use functions
  to create, destroy or apply to filters to the structure. See section
  `sec:accessh` for details.

- Using the functions and data structures defined in te\_cursor.h:
  Iterating over a set of Telos frames is done by using a cursor. See
  section `sec:cursorh` for details.

The documentation in the following sections has been generated with
DOC++ (#link("http://docpp.sourceforge.net");).

== fragment.h and te\_callparser.h
<sec:fragmenth>
#quote(block: true)[
*Description:* A binding list represents the list of parameters
in a derive expression
]

#quote(block: true)[
*Description:* An object identifier represents a Telos object
name. It may be a simple object name, a derive expression, or a select
expression.
]

#quote(block: true)[
*Description:* A class list is a list of object identifiers
]

#quote(block: true)[
*Description:* An AttrClassList is a list of attribute
categories. Attribute categories or simple labels.
]

#quote(block: true)[
*Description:* Used only internally for extended syntax
]

#quote(block: true)[
*Description:* Used only internally for extended syntax
]

#quote(block: true)[
*Description:* Used only internally for extended syntax
]

#quote(block: true)[
*Description:* Used only internally for extended syntax
]

#quote(block: true)[
*Description:* A property list is a list of attributes.
Attributes have a label and a value. The member objectSet is used only
in an extended syntax.
]

#quote(block: true)[
*Description:* An AttrDeclList is a list of attribute
declarations. It represents everthing between \"with\" and \"end\" in a
Telos frame. One attribute declaration has a list of attribute
categories and a list of properties (attribute definitions).
]

#quote(block: true)[
*Description:* A SMLfragmentList is a list of Telos frames. Each
Telos frame has an object identifier (id). It may have in addition an
inOmega class, a list of in-Classes, a list of isA-Classes, and an
attribute declaration. Except id, all members may be NULL.
]

#quote(block: true)[
*Description:*

FrameParseOutput is the structure returned by the function
te\_frame\_parser. It contains either a list of fragments or information
about the parse error.
]

#quote(block: true)[
*Description:*

ClassListParseOutput is the structure returned by the function
te\_classlist\_parser. It contains either a list of classes or
information about the parse error.
]

*Parameters:*



*[parameter table omitted — see archive libtelos.tex]*



*Returns:*



*[parameter table omitted — see archive libtelos.tex]*



#quote(block: true)[
*Description:* Calls the Telos Parser to parse frames.
]

*Parameters:*



*[parameter table omitted — see archive libtelos.tex]*



*Returns:*



*[parameter table omitted — see archive libtelos.tex]*



#quote(block: true)[
*Description:* Calls the Telos Parser to parse a list of object
names.
]

#quote(block: true)[
*Description:*

Unparse a fragment list into a string
]

#quote(block: true)[
*Description:*

Destroy a fragment list
]

#quote(block: true)[
*Description:*

Destroy a class list
]

== te\_access.h
<sec:accessh>
#quote(block: true)[
*Description:* This structure represents an attribute
declaration. An attribute declaration is a list of attribute categories
with a list of properties (label and values) that belong to these
attribute categories.
]

#quote(block: true)[
*Description:* The pointer for TAttrDecl
]

#quote(block: true)[
*Description:* The type for te\_VectorizedTelosframe
]

#quote(block: true)[
*Description:* A pointer to VTelos
]

#quote(block: true)[
*Description:* An array of VTelos pointers
]

#quote(block: true)[
*Description:* A te\_TelosReport is a projection on certain
attributes of a frame
]

*Parameters:*



*[parameter table omitted — see archive libtelos.tex]*



*Returns:*



*[parameter table omitted — see archive libtelos.tex]*



#quote(block: true)[
*Description:*

Maps the given fragmentlist fl into a vector of frames.
]

*Parameters:*



*[parameter table omitted — see archive libtelos.tex]*



*Returns:*



*[parameter table omitted — see archive libtelos.tex]*



#quote(block: true)[
*Description:*

Maps the given Telos text szTelos into a vector of frames.
]

*Parameters:*



*[parameter table omitted — see archive libtelos.tex]*



#quote(block: true)[
*Description:*

Disposes the given vector tree.
]

*Parameters:*



*[parameter table omitted — see archive libtelos.tex]*



*Returns:*



*[parameter table omitted — see archive libtelos.tex]*



#quote(block: true)[
*Description:*

Filters all attributes to those properties which belong to all given
categories at the same time. Note: If there is a category wrong typed,
it has the effect that result will always be an empty vector with NULL
at index 0.
]

*Parameters:*



*[parameter table omitted — see archive libtelos.tex]*



#quote(block: true)[
*Description:*

Disposes the given report structure. Should be called to free the result
of rep\_create.
]

*Parameters:*



*[parameter table omitted — see archive libtelos.tex]*



*Returns:*



*[parameter table omitted — see archive libtelos.tex]*



#quote(block: true)[
*Description:*

A simple service routine, which support the access on frames.
]

*Parameters:*



*[parameter table omitted — see archive libtelos.tex]*



*Returns:*



*[parameter table omitted — see archive libtelos.tex]*



#quote(block: true)[
*Description:*

Lists the categories as flat list, each elemant appears only once. The
categories will be ordered by their appearance.
]

*Parameters:*



*[parameter table omitted — see archive libtelos.tex]*



#quote(block: true)[
*Description:*

Disposes an asz (array of strings) structure.
]

== te\_cursor.h
<sec:cursorh>
#quote(block: true)[
*Description:*

A cursor for a Telos frame
]

#quote(block: true)[
*Description:*

Creates and initializes a cursor structure for the given
smlfragmentlist. and returns a pointer to it.
]

#quote(block: true)[
*Description:*

Deallocates a cursor structure
]

#quote(block: true)[
*Description:*

Sets the frame cursor to the first frame and resets all sub cursors
]

*Returns:*



*[parameter table omitted — see archive libtelos.tex]*



#quote(block: true)[
*Description:*

Sets the frame cursor to the next frame in the list and resets the
Omega, IsA, In, AttrDecl, Category and Property cursors.
]

#quote(block: true)[
*Description:*

Returns the OID of a frame as plain string, even if it is a select
expression. Memory for this string has to be deallocated by the caller.
]

#quote(block: true)[
*Description:*

Resets the Omega cursor
]

*Returns:*



*[parameter table omitted — see archive libtelos.tex]*



#quote(block: true)[
*Description:*

Sets the omega cursor to the next element.
]

#quote(block: true)[
*Description:*

Returns the omega object as string
]

#quote(block: true)[
*Description:*

Resets the Isa cursor
]

*Returns:*



*[parameter table omitted — see archive libtelos.tex]*



#quote(block: true)[
*Description:*

Sets the IsA cursor to the next element.
]

#quote(block: true)[
*Description:*

Returns the IsA object as string
]

#quote(block: true)[
*Description:*

Resets the In cursor
]

*Returns:*



*[parameter table omitted — see archive libtelos.tex]*



#quote(block: true)[
*Description:*

Sets the In cursor to the next element.
]

#quote(block: true)[
*Description:*

Returns the In object as string
]

#quote(block: true)[
*Description:*

Sets the attr decl block cursor to the first attr decl block in the
current frame and resets the sub-cursors Category and Property
]

*Returns:*



*[parameter table omitted — see archive libtelos.tex]*



#quote(block: true)[
*Description:*

Sets the Property cursor to the next Property class in the attr decl
block frame and resets the Category and Property cursors.
]

#quote(block: true)[
*Description:*

Resets the category cursor
]

*Returns:*



*[parameter table omitted — see archive libtelos.tex]*



#quote(block: true)[
*Description:*

Sets the category cursor to the next element.
]

#quote(block: true)[
*Description:*

Returns the category as string
]

#quote(block: true)[
*Description:*

Resets the property cursor
]

*Returns:*



*[parameter table omitted — see archive libtelos.tex]*



#quote(block: true)[
*Description:*

Sets the category cursor to the next element.
]

#quote(block: true)[
*Description:*

Lists all properties that are of the type \"category\". The usage of
this function is similar to the function te\_filterPropertyByCategories.
The only diffrence is the simplicity of the second parameter for the
case that you only need to filter with one category.
]

#quote(block: true)[
*Description:*

Lists all properties that matches all types of categories If the
categories are empty then any category matches. In difference to the
nextXXX functions, these function should be called before the first
access via te\_retLabel or te\_retValue, because it must search the
first valid AttrDecl. This means at the beginning you should call:
\"te\_resetAttrDecl( ... );\" AND \"te\_filterPropertyByCategories( ...
);\"
]

#quote(block: true)[
*Description:*

Lists the value of the property with label of the current frame. This
results only one value which is a new created string. Note that the
caller has to dispose the return value !
]

#quote(block: true)[
*Description:*

Returns the current label of the current property in the current decl
block or NULL
]

#quote(block: true)[
*Description:*

Returns the current value of the current property in the current decl
block or NULL
]
