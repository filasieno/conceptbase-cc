= Server Interface
<serverinterface>
<cap:Server-Interface>

This chapter provides basic information necessary for communication with
the ConceptBase server. It is possible that the CBserver and the clients
'live' on different machines because communication with the CBserver is
realized through a message protocol using inter-process communication
(IPC) based on standard Internet sockets. It is even possible (but not
recommended :-) ) to use a standard telnet program for the communication
with a CBserver. The following chapter describes this protocol as it is
necessary to know for a specialized client which wants to request
services from the CBserver. Readers who intend only to use one of the
programming interfaces for C, C++ or Java may skip this chapter, but it
contains some useful basic information.

From a client's point of view the CBserver can be seen as an abstract
data type exporting several parameterized operations. These operations
comprise methods for storing/retrieving information into/from the KB,
methods for establishing and closing the connection to a CBserver and
methods for testing the KB. Since the client and CBserver are two
different processes a client cannot directly call these methods like
procedures but must access them using a message protocol. However, the
use of one of the application programming interfaces (API) for C, C++
and Java simplifies the communication and interaction with the CBserver
from the viewpoint of an application programmer.

This chapter is organized as follows: Section `sec:MessageFormat`
describes the message protocol which is used to communicate with other
processes. Section `sec:methods` describes the interface to the CBserver,
i.e. the data structures and operations which the ConceptBase kernel
offers and the message protocol which makes these operations accessible
to other processes.

== Message Format
<sec:MessageFormat>
As already mentioned, any client that wants to use the methods of a
CBserver has to communicate with CBserver according to a message
protocol. So called ipcmessages can be sent via IPC to the port reserved
for this CBserver. The CBserver handles such a message and reports back
an answer: the ipcanswer.

=== ipcmessage
<ipcmessage>
*ipcmessage ( sender, receiver, method, args ).* where

/ sender: #block[
is the identifier for the sender of the message,
]

/ receiver: #block[
is the identifier for the receiver of the message (usually the CBserver
itself, but could be any other client connected to CBserver as well),
]

/ method: #block[
is one of the methods exported by the CBserver (or a method known to
another client which is adressed by the message),
]

/ args: #block[
are the arguments for method.
]

Note, that it is necessary to "encode" the parameters of an ipcmessage.
This means, that the strings must begin and end with `"`. If the string
contains the characters `"` or `\`, they must be escaped with a
backslash (`\`). Please refer to the grammar definition in appendix
`cha:SyntaxSpec` for full details.

Messages can also be directed to other clients of the CBserver by using
a different ID than the server ID as a receiver of message. If messages
are sent from client to client, clients have to poll for messages using
the method NEXT\_MESSAGE. This function has not been tested recently.

A message can be prefixed by the length of the message, which is
specified in five bytes. The first byte is always the character 'X', the
next bytes are computed by the following formulas (len is the length of
the message without this prefix):

+ (len /$256^3$) modulo 256

+ (len /$256^2$) modulo 256

+ (len /$256$) modulo 256

+ len modulo 256

e.g., the first byte is the highest byte and the last byte is the lowest
byte of an unsigned integer. Note, that specifying the length of an
IPC-message is optional. IPC-messages without the length information
should also be accepted by the server but communication problems might
occur in rare circumstances.

=== ipcanswer
<ipcanswer>
*ipcanswer ( sender, completion, return ).* where

/ sender: #block[
is the identifier of the answering program (usually the CBserver since
other programs cannot answer directly but only receive the message and
send back another message via the CBserver). This is sent as an encoded
string.
]

/ completion: #block[
signals success (=ok) or failure (=error) or unability (=not\_handled)
of handling the message
]

/ return: #block[
contains the return value(s) of the handled message. This is sent as an
encoded string.
]

Additionally the CBserver administrates message queues for all connected
clients. Whenever a client X sends a message to another client Y (which
is not CBserver) the CBserver stores this message into the message queue
of the client Y and gives it back to X.

If clients are likely to exchange messages they should periodically poll
their message queue.

== Methods Exported by the CBserver
<sec:methods>
The CBserver offers the following methods (list is incomplete):

/ general methods\:: #block[
`TELL`, `UNTELL`, `TELL_MODEL`, `ASK`, `HYPO_ASK`, `NEXT_MESSAGE`,
`ENROLL_ME`, `CANCEL_ME`,
]

/ privileged methods\:: #block[
`STOP_SERVER`, `REPORT_CLIENTS`
]

/ internal methods\:: #block[
`LPI_CALL`
]

Privileged methods affect other clients connected to CBserver as well
and should only be executed by an authorized client. That means, that
only the _owner_ of the ConceptBase server process may execute this
methods.

The internal method `LPI_CALL` gives a client the possibility to call
internal procedures of the ConceptBase server. This method is mainly
useful for ConceptBase developers for debugging and analysing.

In the following description of the methods `return` refers to the
respective parameter of `ipcanswer(sender, completion, return)`.

For each error occuring during the execution of a method an error
message is stored by the CBserver `receiver` in the message queue of the
client `sender`. This error message can be fetched via a call of method
`NEXT_MESSAGE`, see below.

=== TELL
<tell>
#quote(block: true)[
/ objects: #block[
encoded string containing object descriptions in Telos represented as
frames
]

/ return: #block[
`"yes"` in case of success, `"no"` otherwise
]

The CBserver receiver checks the syntax of `objects` creating a parse
tree for each object description, called _SMLfragment_;. If no
syntax error occurs the SMLfragments are transformed into an internal
network representation with specialized rules and constraints. Those
facts which are not already retrievable are temporarily added to the KB.
A check is then performed to determine whether the updated KB still
satisfies the integrity constraints. In the case of satisfaction the new
information is made permanent, otherwise it is deleted.
]

=== UNTELL
<untell>
#quote(block: true)[
/ objects: #block[
encoded string containing object descriptions in Telos represented as
frames
]

/ return: #block[
`"yes"` in case of success, `"no"` otherwise
]

The `objects` will be untold, i.e. the upper bound of their transaction
time interval is set to the time the UNTELL operation takes place. That
means from this time on the system does not believe this information
anymore. Questions about the current state of the knowledge base yield
the same answer as if the objects were never inserted into the system.
However questions about earlier states will regard all information (even
untold) the transaction time of which contains the time in question (=
rollback time). Like in the TELL method, if the UNTELL operation would
result in an inconsistent KB state it is rejected by the integrity
checker.
]

=== TELL\_MODEL
<tell_model>
#quote(block: true)[
/ filelist: #block[
A list of comma-separeted ipc strings, which contain the full filenames
of files to be loaded by ConceptBase server.
]

This method is similar to the `TELL` method, except that the frames
which are told to ConceptBase are loaded from the given files and not
passed directly to ConceptBase.

*Remark:* The files to be loaded by ConceptBase must be
accessible for the server. This is not always the case, when server and
client are running on different machines with different filesystems
mounted on. Another problem may occur, due to access protections,
because the user running the ConceptBase server is not allowed to read
the specified files.
]

=== ASK
<ask>
#quote(block: true)[
/ Format: #block[
is either `FRAMES` or `OBJNAMES`, depending of the format of `Query`. If
in `Query` only the object name of a query is given
(e.g.~`AllEmployees`) then the format must be `OBJNAMES`. If the query
is specified as frame
(e.g.~`"QueryClass AllEmployees isA Employee end"`) then the format must
be `FRAMES`.
]

/ Query: #block[
depending on the `Format` this may be simple object names or frames
representing queries. In the later case, the query is temporarily told
to the object base and after evaluating deleted from the object base, if
it does not already exist in the object base before the transaction.
]

/ AnswerRep: #block[
answer format specification, possible values are: `FRAGMENT`, `FRAME`,
`LABEL` or an instance of `AnswerFormat`#footnote[See the
_ConceptBase User Manual_ for details about user-defined answer
formats];. The syntax of the `FRAGMENT` and `FRAME` formats are
explained in the appendix of the _ConceptBase User Manual_;. If the
answer representation is `LABEL` a comma-separated list of object names
is returned.
]

/ RollbackTime: #block[
rollback time specification
]

/ return: #block[
list of answers in case of success, `"no"` otherwise
]

The values of the `Format` argument (`FRAMES` and `OBJNAMES`) are ipc
message keywords and must not be encoded as the other arguments `Query`,
`AnswerRep` and `RollbackTime`.
]

#quote(block: true)[
The following two queries are predefined builtin queries and available
after booting the _ConceptBase_ server. These queries additionally
give good examples for derived expressions by instantiating parameters
of generic query classes.

- `exists[x/objname]`

  The answer return is `"yes"` if there is an object named `x`,
  otherwise `"no"`.

- `get_object[x/objname]`

  The answer is the frame representing the object `x` if there is an
  object `x`. Otherwise, the answer is `"no"`. Only information that is
  explicitly stored (i.e. not inherited or deduced) is considered. If
  you want deduced information, you must specify additional parameters.
  For example, the answer of the following query is the `Class` object
  with stored and deduced attributes:

  #block[
  `get_object[Class/objname,FALSE/dedIn,FALSE/dedIsa,TRUE/dedWith]`

  ]
]

=== HYPO\_ASK
<hypo_ask>
#quote(block: true)[
/ ObjList: #block[
string of objects in frame syntax
]

/ Format: #block[
see ASK
]

/ Query: #block[
see ASK
]

/ AnswerRep: #block[
see ASK
]

/ RollbackTime: #block[
see ASK
]

/ return: #block[
list of answers in case of success, no otherwise
]

This method allows to process so called 'hypothetical' queries against
the KB. The objects in objList are temporarily told. This list may
contain query objects which may in turn be referred to by names
contained in Query. Then the queries in queryList are evaluated as if
the temporary information would belong to the KB. Afterwards the
temporary information will be removed.
]

=== NEXT\_MESSAGE
<next_message>
#quote(block: true)[
/ type: #block[
identifier describing the type of the message (e.g.~`ERROR_REPORT`).
This argument may not be encoded as other string, but may be
_empty_;.
]

/ return: #block[
contains the next message for the client if its message queue contains
at least one message, `empty_queue` if no message exists
]

Client sender requests a message from the CBserver receiver stored in
its message queue. Usually, this method is called after the CBserver
returns error for a previous method. The client program must then get
all error messages until it gets `"empty_queue"` as answer.
]

=== STOP\_SERVER
<stop_server>
#quote(block: true)[
/ password: #block[
password allowing a client to stop a CBserver (may be _empty_;)
]

/ return: #block[
`"yes"` in case of success, `"no"` otherwise
]

The CBserver receiver is terminated if the password is correct and the
user running the client is also the owner of the CBserver to be stopped.
To the requesting client `STOP_SERVER` has the same effect as
`CANCEL_ME`. It is recommended to terminate the CBserver by using the
respective menu choice from the "Server Menu" of ConceptBase Workbench
if you want to stop the CBserver process.
]

=== REPORT\_CLIENTS
<report_clients>
#quote(block: true)[
/ return: #block[
list of all clients currently connected to CBserver receiver
]

CBserver receiver reports back the identifier, toolclass and owner name
of all currently connected clients including itself.
]

=== ENROLL\_ME
<enroll_me>
#quote(block: true)[
/ toolclass: #block[
'class' the client belongs to
]

/ username: #block[
name of the user running the client
]

/ return: #block[
identifier assigned to the client by CBserver
]

`sender` and `receiver` have value `""` since they are not known. The
sending client will be registered as a new client of the CBserver with
its own identifier and message queue. This message must be sent to the
CBserver before any other message can be sent, since all other messages
require valid identifiers to be assigned to sender and receiver. If the
user specified by `username` is stored as an instance of the class
`CB_User` of the CBserver, then the value of the attribute `homeModule`
of that user is taken as the initial module context of the client.
Otherwise, the default module context `System` is assigned to the
client. In a variant of ENROLL\_ME, one can specify a third parameter
`module` which will set the module context explicitely.
]

=== CANCEL\_ME
<cancel_me>
#quote(block: true)[
/ return: #block[
`"yes"` in case of successful disconnection, `"no"` otherwise
]

Client sender will be disconnected from CBserver. This means that from
now on the sender is no longer known to the CBserver (no further
messages can be sent) and its message queue is deleted. After
successfully canceling the connection, the ipc sockets to the server
must be closed by the client program.
]

=== GET\_MODULE\_CONTEXT
<get_module_context>
#quote(block: true)[
/ return: #block[
name of the module currently assigned to client `sender`
]

This service allows clients to interrogate the CBserver about the
currently active module context in which they operate.
]

=== LPI\_CALL
<lpi_call>
#quote(block: true)[
/ call: #block[
an internal routine
]

/ return: #block[
`"yes"` if call succeeded, `"no"` otherwise
]

This is for debugging and testing purposes only.
]
