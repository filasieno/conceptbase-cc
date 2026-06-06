= Programming Interface for a C++ Client: libCBview
<cha:libcbview>
The libCBview provides a C++ encapsulation of libCB. It provides only an
object-oriented API for ConceptBase and does not provide any additional
methods in contrast to libCB.

Compilation and linking has to be done in the same way as for libCB.
Note that you have to link both libraries libCB and libCBview if you
want to use the C++ classes.

The documentation in the following sections has been generated with
DOC++ (#link("http://docpp.sourceforge.net");).

#quote(block: true)[
*Description:* Constructs an \"empty\" client which is not
connected
]

#quote(block: true)[
*Description:*

Constructs a new CBclient object and connect to the specified host
]

#quote(block: true)[
*Description:*

Disconnects from the CBserver and deallocates the memory
]

*Parameters:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`char`], [\*frames the frames],
  )]
  , kind: table
  )

*Returns:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`a`], [CBanswer object containing the result and the completion],
  )]
  , kind: table
  )

#quote(block: true)[
*Description:*

Tells frames to the server
]

*Parameters:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`char`], [\*frames the frames],
  )]
  , kind: table
  )

*Returns:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`a`], [CBanswer object containing the result and the completion],
  )]
  , kind: table
  )

#quote(block: true)[
*Description:*

Untells frames to the server
]

*Parameters:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`char**`], [files an array of filenames],
  )]
  , kind: table
  )

*Returns:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`a`], [CBanswer object containing the result and the completion],
  )]
  , kind: table
  )

#quote(block: true)[
*Description:*

Tells files containing frames to the server
]

*Parameters:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`char`], [\*query the query],
    [`char*`], [format the format of the query (FRAMES or OBJNAMES)],
    [`char*`], [answerrep the format of the answer (FRAME)],
    [`char*`], [rollbacktime Rollback Time (e.g.~\"Now\")],
  )]
  , kind: table
  )

*Returns:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`a`], [CBanswer object containing the result and the completion],
  )]
  , kind: table
  )

#quote(block: true)[
*Description:*

Sends a query to the ConceptBase server
]

*Parameters:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`char`], [\*frames frames to be told],
    [`char`], [\*query the query],
    [`char*`], [format the format of the query (FRAMES or OBJNAMES)],
    [`char*`], [answerrep the format of the answer (FRAME)],
    [`char*`], [rollbacktime Rollback Time (e.g.~\"Now\")],
  )]
  , kind: table
  )

*Returns:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`a`], [CBanswer object containing the result and the completion],
  )]
  , kind: table
  )

#quote(block: true)[
*Description:*

Sends frames and a query to the ConceptBase server. The frames are told
temporarely, the query is evaluated, and the temporarely objects are
removed.
]

*Parameters:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`char`], [\*query the query],
    [`char*`], [answerrep the format of the answer (FRAME)],
    [`char*`], [rollbacktime Rollback Time (e.g.~\"Now\")],
  )]
  , kind: table
  )

*Returns:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`a`], [CBanswer object containing the result and the completion],
  )]
  , kind: table
  )

#quote(block: true)[
*Description:*

Sends a query to the ConceptBase server. Same as ask but with fixed
query format (OBJNAMES).
]

*Parameters:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`char`], [\*query the query],
    [`char*`], [answerrep the format of the answer (FRAME)],
    [`char*`], [rollbacktime Rollback Time (e.g.~\"Now\")],
  )]
  , kind: table
  )

*Returns:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`a`], [CBanswer object containing the result and the completion],
  )]
  , kind: table
  )

#quote(block: true)[
*Description:*

Sends a query to the ConceptBase server. Same as ask but with fixed
query format (FRAMES).
]

*Parameters:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`host`], [hostname of the machine where the server runs],
    [`port`], [port number of server],
    [`user`], [the name of the tool],
    [`tool`], [the name of the user],
  )]
  , kind: table
  )

#quote(block: true)[
*Description:*

Connects to a ConceptBase Server Return the return value of
connect\_CB\_server (see CBinterfaceh): -1: if socket to specified can
not be openend 0: ok other: a completion value (see CBinterfaceh)
]

#quote(block: true)[
*Description:*

Disconnects from a ConceptBase Server

Return the return value of disconnect\_CB\_server (see CBinterface.h):
\-1: error, not connected 0: ok other: a completion value (see
CBinterface.h)
]

*Returns:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`a`], [CBanswer object containing the result and the completion],
  )]
  , kind: table
  )

#quote(block: true)[
*Description:*

Stops the ConceptBase server. Note that a server may be stopped only by
the user who has started it.
]

#quote(block: true)[
*Description:*

Return a list of clients connected to the CB server. The result will be
a list of Client objects as defined in libCB.
]

*Parameters:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`char*`], [method the type of the message to be retrieved],
  )]
  , kind: table
  )

*Returns:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`a`], [CBanswer object containing the result and the completion],
  )]
  , kind: table
  )

#quote(block: true)[
*Description:*

Gets a message from the server
]

*Returns:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`a`], [string containing all error messages],
  )]
  , kind: table
  )

#quote(block: true)[
*Description:*

Gets the error messages from the server
]

#quote(block: true)[
*Description:*

Perform a LPI call on the server. A LPI call is a call of
Prolog-predicate of the CBserver. This is mostly used for debugging.
]

#quote(block: true)[
*Description:*

Check whether this client is connected
]

#quote(block: true)[
*Description:*

The operator int checks also if the client is connected.
]

#quote(block: true)[
*Description:*

Return the name of the server
]

#quote(block: true)[
*Description:*

Return the name of the client
]

*Parameters:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`ans`], [pointer to the Answer struct],
  )]
  , kind: table
  )

#quote(block: true)[
*Description:* Constructs a CBanswer object from a Answer struct
]

#quote(block: true)[
*Description:* Deallocate the memory of the object
]

#quote(block: true)[
*Description:* Get the completion value of the answer
]

#quote(block: true)[
*Description:* Get the result string of the answer
]

#quote(block: true)[
*Description:* Get the ID of the responding tool of the answer.
This usually the CBserver
]

*Parameters:*

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [`e`], [pointer to the Error\_Messages],
  )]
  , kind: table
  )

#quote(block: true)[
*Description:* Construct a CBerror object from a list of
Error\_Messages
]

#quote(block: true)[
*Description:*

Deallocate the memory of a CBerror object
]

#quote(block: true)[
*Description:*

Get the error message of this object. This will return only the first
error message of the list.
]

#quote(block: true)[
*Description:*

This method will return all error messages of the list. The method will
allocate a new string, thus the resulting string has to be freed by the
calller.
]

#quote(block: true)[
*Description:*

Get the next error message in the list
]
