= Programming Interface for a C Client: libCB
<cha:c-client>
This chapter describes the programming interface for ConceptBase. The
programming interface consists of a number of data structures and C
functions which are defined in the header file CBinterface.h. Make sure
that this header file is included in each of source files that use
functions of libCB. The data structures are explained in section
`sec:data-structures`. The C library `libCB` contains all functions
described in section `sec:Functions`.

The libraries can be found in the following directories:

/ Solaris/SPARC\:: #block[
The directory ``CB_HOME`/sun4/lib` contains the libraries for static
linking of your application.
]

/ Solaris/PC\:: #block[
The directory ``CB_HOME`/i86pc/lib` contains the libraries for static
linking of your application.
]

/ Linux\:: #block[
The directory ``CB_HOME`/linux/lib` contains the libraries for static
linking of your application.
]

/ Windows\:: #block[
The directory ``CB_HOME`/windows/lib` contains the dynamic libraries for
dynamic linking of your application.
]

There are currently no plans to build dynamic libraries for the
Unix-based platforms.

The directories ``CB_HOME`/examples/Clients/LogClient` and \
``CB_HOME`/examples/Clients/C_Client` contain example programs, which
uses the programming interface `libCB` to communicate with the
ConceptBase server. The LogClient program is explained in appendix
`cha:logclient`. Information on you how to compile and link your source
code with the ConceptBase libraries can be found either in the
directories of the example clients or in section `sec:compileandlink`.

== Data Structures
<sec:data-structures>
This section describes the data structures used by the API, in
particular structures which are passed to and returned by the interface
procedures.

The following C-types are defined in the file `CBinterface.h` which is
located in the directory ``CB_HOME`/include`.

=== Completion
<completion>
```
typedef enum {CB_OK=0, CB_ERROR, CB_NOT_HANDLED,
              CB_TIMEOUT, CB_CONN_BROKEN} Completion;
```

The different return values have to be interpreted as follows:

/ CB\_OK: #block[
the message has been handled successfully.
]

/ CB\_ERROR: #block[
an error occurred during the execution of the message; the ConceptBase
server stores some error reports for you on your message queue which may
be read calling `em = get_errormessages()` (see below).
]

/ CB\_NOTIFICATION: #block[
indicates that the message is a notification message. Notification
messages are sent by the server if the client has requested notification
on updates on certain views.
]

/ CB\_NOT\_HANDLED: #block[
the server was not able to manage your message at all. This may be due
to an invalid format of input parameters (e.g. wrong Telos syntax) or
missing parameters.
]

/ CB\_TIMEOUT: #block[
the message has been sent successfully to the server, but there has been
no answer from the server after a specific amount of time (depends on
the type of message sent). This may be due to the number of clients
which are active or due to the kind of message you sent (some queries
may last longer than others). The client is responsible for the correct
handling of answers returned after CB\_TIMEOUT occured.
]

/ CB\_CONN\_BROKEN: #block[
the sending of the last message failed (the connection to the server is
no longer accessible). Again, the client is responsible to handle this
return value (e.g. stopping the client).
]

=== Answer
<answer>
```
struct answer { char *sender;
                 Completion completion;
                 char *return_data;
               };
typedef struct answer Answer;
```

The Answer structure is returned by most library functions. The first
field sender contains the name of the sender as it is maintained by the
ConceptBase server. The second one specifies the status of the message
processing (see section `completion`) while the third one contains return
values of the message called.

=== Server
<server>
```
struct server { char *serverName;
                 char *client;
                 int connected_to_CB_server;
                 SOCKET socket;
               };
typedef struct server Server;
```

This structure is allocated and filled by the ` connect_CB_server()`
call and used as an anchor by all the other routines to get the right
server. The field connected\_to\_CB\_server should usually be true, as
it indicates that the client is connected to the server (or not). The
socket field represents the socket which is used for the communication
with the CB server and should be used only internally.

=== Clients
<clients>
```
struct clients { char *client;
                 char *toolclass;
                 char *username;
                 struct clients *next;
                  };
typedef struct clients Clients;
```

This structure represents a simply linked list of clients. A pointer to
this structure is returned as result of the `report_clients` call.

=== Error\_Messsages
<errormessages>
```
struct errormessages { char *errormessage;
                       struct errormessages *next;
                     };
typedef struct errormessages Error_Messages;
```

List of error messages given by the ConceptBase server every time a
communication event can not be processed correctly. This list may be
obtained calling `get_errormessages()`.

== Functions
<sec:Functions>
=== connect\_CB\_server
<connect_cb_server>
```
int connect_CB_server(int      portnr,
                      char    *hostname,
                      char    *clientname,
                      char    *username,
                      Server **server)
```

*Description:*

#quote(block: true)[
Sets up a connection to a given ConceptBase server. This routine has to
be called once before calling one of the following routines.
]

*Input parameters:*

#quote(block: true)[
/ portnumber: #block[
number of the port of the server (this port number is unique per server
as may be defined at the server's start up time).
]

/ hostname: #block[
name of the machine on which you started the server
]

/ clientname: #block[
name of the client to be connected (e.g. _TelosEditor_;)
]

/ username: #block[
name of the user who started the client
]

/ server: #block[
pointerpointer to a struct server; on a succesfull connection the
structure will be allocated and filled
]
]

*Result:*

#quote(block: true)[
/ 0: #block[
Connection established
]

/ -1: #block[
There is no such server (probably wrong portnumber and/or host)
]

/ $>$0: #block[
a completion value (see section `completion`)
]
]

=== disconnect\_CB\_server
<disconnect_cb_server>
```
int disconnect_CB_server(Server *server)
```

*Description:*

#quote(block: true)[
Closes a previous connection to a ConceptBase server. This procedure has
to be called every time a client is stopped (but usually the CBserver is
not affected by clients that crash or do not disconnect correctly).
]

*Input parameters:*

#quote(block: true)[
/ sever: #block[
pointer to the structure discribing the current ConceptBase server
]
]

*Result:*

#quote(block: true)[
/ 0: #block[
Connection correctly terminated
]

/ -1: #block[
error, not connected
]

/ $>$0: #block[
a Completion value
]
]

=== tellCB
<tellcb>
```
Answer* tellCB(Server *server, char *objects)
```

*Description:*

#quote(block: true)[
Inserts a set of objects into the ConceptBase server. This function has
been renamed from previous releases as tell is a operating system
function on some systems.
]

*Input parameters:*

#quote(block: true)[
/ server: #block[
pointer to the structure discribing the actual server
]

/ objects: #block[
pointer to a list of objects, which should be inserted into the
knowledge base. This should be a normal NULL-terminated C-string.
]
]

*Result:*

#quote(block: true)[
An answer struct where return\_data is either yes or no and where the
completion value indicates the result of the operation:

/ CB\_OK: #block[
operation sucessfull
]

/ CB\_ERROR: #block[
There was an error while inserting, get the errormessages by calling
`get_errormessages()`
]

/ other: #block[
see the description in section `completion`
]
]

=== untell
<untell>
```
Answer* untell(Server *server, char *objects)
```

*Description:*

#quote(block: true)[
Removes a list of objects from the knowledge base. Note the specific
semantics of the untell method as described in chapter `serverinterface`
of this Manual.
]

*Input parameters:*

#quote(block: true)[
/ server: #block[
pointer to the structure discribing the actual server
]

/ objects: #block[
pointer to a list of objects, which should be deleted. This should be a
normal NULL-terminated C-string.
]
]

*Result:*

#quote(block: true)[
An answer struct where return\_data is either yes or no and where the
completion value indicates the result of the operation:

/ CB\_OK: #block[
operation sucessfull
]

/ CB\_ERROR: #block[
There was an error while removing, get the errormessages calling
`get_errormessages()`
]

/ other: #block[
see the description in section `completion`
]
]

=== tell\_model
<tell_model>
```
Answer* tell_model(Server* server, char** models);
```

*Description:*

#quote(block: true)[
Tells the given files to the server. Note that the server must be able
to find these files in its file system.
]

*Input parameters:*

#quote(block: true)[
/ server: #block[
pointer to the structure discribing the actual server
]

/ objects: #block[
pointer to a NULL-terminated array of C-strings, containing the file
names which should be loaded by the server.
]
]

*Result:*

#quote(block: true)[
An answer struct where return\_data is either yes or no and where the
completion value indicates the result of the operation:

/ CB\_OK: #block[
operation sucessfull
]

/ CB\_ERROR: #block[
There was an error while removing, get the errormessages calling
`get_errormessages()`
]

/ other: #block[
see the description in section `completion`
]
]

=== get\_errormessages
<get_errormessages>
```
Error_Messages *get_errormessages(Server *server)
```

*Description:*

#quote(block: true)[
Gets the errormessages corresponding to the last error. This procedure
has to be called every time CB\_ERROR has been returned by a given
procedure. Otherwise, further messages may be disturbed by the error
messages which are returned first by the server.
]

*Input parameters:*

#quote(block: true)[
/ server: #block[
pointer to the structure discribing the actual server
]
]

*Result:*

#quote(block: true)[
list of errormessages (see section `errormessages`)
]

=== ask
<ask>
```
Answer* ask(Server* pServer,
          char* szQuery,
          char* szAskFormat,
          char* szAnsFormat,
          char* szRBTime);
```

*Description:*

#quote(block: true)[
Sends the query in the specified format (szAskFormat) to the server and
returns the result of the server, which will be represented in the
format given in szAnsFormat. The rollback time (szRBTime) is usually
Now.
]

*Input parameters:*

#quote(block: true)[
/ pServer: #block[
a pointer to a server structure
]

/ szQuery: #block[
the query
]

/ szAskFormat: #block[
the format of the query (FRAMES or OBJNAMES)
]

/ szAnsFormat: #block[
the format of the answer (e.g. FRAME, LABEL,...)
]

/ szRBTime: #block[
rollback time (e.g. Now)
]
]

*Result:*

#quote(block: true)[
an answer struct:

/ sender: #block[
the tool that has provided the answer, usually the ID of the server
]

/ completion: #block[
Completion value indicating the success of the method, e.g. CB\_OK,
CB\_ERROR
]

/ return\_data: #block[
the result of the query in the specified format, or the string \"nil\"
if there are no results or if there was an error during query processing
]
]

=== ask\_frames
<ask_frames>
```
Answer* ask_frames(Server *pSserver,
                 char *szQuery,
                 char* szAnsFormat,
                 char *szRBTime)
```

*Description:*

#quote(block: true)[
As ask, but szAskFormat is fixed to be FRAMES, i.e. queries have to be
given as frames.
]

=== ask\_objnames
<ask_objnames>
```
Answer* ask_objnames(Server *pSserver,
                   char *szQuery,
                   char* szAnsFormat,
                   char *cbfoGet,
                   char *szRBTime)
```

*Description:*

#quote(block: true)[
As ask, but szAskFormat is fixed to be OBJNAMES, i.e. queries have to be
given as object names (or derive expressions).
]

=== hypo\_ask
<hypo_ask>
```
Answer* hypo_ask(Server* pServer,
          char* szFrames,
          char* szQuery,
          char* szAskFormat,
          char* szAnsFormat,
          char* szRBTime);
```

*Description:*

#quote(block: true)[
As ask, but first tells the frames given in szFrames to the server, then
performs the query and finally deletes the told frames from the object
base.
]

=== report\_clients
<report_clients>
```
Clients* report_clients(Server *server)
```

*Description:*

#quote(block: true)[
Returnes a list of all clients connected to the server.
]

*Input parameters:*

#quote(block: true)[
/ server: #block[
pointer to the structure describing the actual server
]
]

*Result:*

#quote(block: true)[
list of clients or NULL on error
]

=== get\_servermessage
<get_servermessage>
```
Answer* get_servermessage(Server* server, char* type);
```

*Description:*

#quote(block: true)[
Gets a message from the server for the client. This function is called
by get\_errormessages().
]

*Input parameters:*

#quote(block: true)[
/ server: #block[
a pointer to a server structure
]

/ type: #block[
type of the message to be retrieved (e.g. ERROR\_REPORT)
]
]

*Result:*

#quote(block: true)[
an answer object with the message or EMPTY\_QUEUE in return\_data
]

.

=== get\_notification
<get_notification>
```
Answer* get_notification(Server* server, int timeout);
```

*Description:*

#quote(block: true)[
Looks for a notification message. Notification messages are sent by the
server if the client has requested notification on updates on certain
views. The method will wait for a message from the server for the
specified time.
]

*Input parameters:*

#quote(block: true)[
/ server: #block[
a pointer to a server structure
]

/ timeout: #block[
time to wait for a message
]
]

*Result:*

#quote(block: true)[
an answer object with completion CB\_NOTIFICATION when a message was
received, otherwise a completion value, usually CB\_TIMEOUT.
]

=== stopServer
<stopserver>
```
Answer* stopServer(Server* server, char* password);
```

*Description:*

#quote(block: true)[
Stops the server. Note, that only the user who has started the server
may stop it.
]

*Input parameters:*

#quote(block: true)[
/ server: #block[
a pointer to a server structure
]

/ password: #block[
a password (not used, may be empty)
]
]

*Result:*

#quote(block: true)[
the result of the method
]

=== LPICall
<lpicall>
```
Answer* LPICall(Server* server, char* lpicall);
```

*Description:*

#quote(block: true)[
Performs a LPI-Call at the server. With LPI (Logic Programming
Interface) one can call ProLog predicates defined in an LPI-Module.
]

*Input parameters:*

#quote(block: true)[
/ server: #block[
a pointer to a server structure
]

/ lpicall: #block[
the predicate to be called
]
]

*Result:*

#quote(block: true)[
the result of the method
]

=== free\*
<free>
```
void freeAnswer(Answer* ans);
void freeServer(Server* srv);
void freeClients(Clients* c);
void freeErrorMessages(Error_Messages* err);
```

*Description:*

#quote(block: true)[
These functions free the allocated memory by the corresponding
structures. Note that memory of all results which are returned by the
library methods have to be freed by the caller.
]

=== send\_message
<send_message>
```
Answer send_message(Server *server,
                    char   *method,
                    char   *data)
```

*Description:*

#quote(block: true)[
This procedure is the most general one and used by most functions
mentioned before. It sends a message of type `method` to the (already
connected) CBserver server. `data` is a string containing data expected
by the method `method`#footnote[See chapter `serverinterface` and
appendix `cha:SyntaxSpec` of this manual for a complete description of
the available methods and their expected data];. For normal usage of the
client library, this function is not necessary. The more specific
functions (e.g. `tellCB, untell, ...`) are more useful.
]

*Input parameters:*

#quote(block: true)[
/ server: #block[
pointer to the structure describing the actual server
]

/ method: #block[
string which defines the type of the message (e.g.~`TELL`)
]

/ data: #block[
the arguments for the given message type
(e.g.~`["Class Employee with ... end"]``) `
]
]

*Result:*

#quote(block: true)[
an `Answer` structure containing `sender`, `completion` and
`return_data`
]

=== CBdecodeString
<cbdecodestring>
```
char* CBdecodeString(const char* s);
```

*Description:*

#quote(block: true)[
Decode a string. ConceptBase encodes all strings with '\"' and \
. To get the plain string, use this function.
]

*Input parameters:*

#quote(block: true)[
The string to decode.
]

*Result:*

#quote(block: true)[
The decoded string, it is a duplicate of the input if the input string
is not encoded. The memory allocated by the result has to be freed by
the caller.
]

=== CBencodeString
<cbencodestring>
```
char* CBencodeString(const char* s);
```

*Description:*

#quote(block: true)[
Encode a String. ConceptBase encodes all strings with '\"' and \
. Use this function if you want to use Strings in Telos frames.
]

*Input parameters:*

#quote(block: true)[
The string to encode.
]

*Result:*

#quote(block: true)[
The encoded string. The memory allocated by the result has to be freed
by the caller.
]

=== CBgetEncodeLength
<cbgetencodelength>
```
unsigned CBgetEncodedLength(const char* s);
```

*Description:*

#quote(block: true)[
Return the length of an encoded string. This function is called by
CBencodeString to allocate the memory of the encoded string.
]

=== CBgetLabels
<cbgetlabels>
```
char** CBgetLabels(const char* labelList);
```

*Description:*

#quote(block: true)[
Parse a comma-separated list of labels. ConceptBase returns sometimes
comma-separated list of labels (e.g., for the answer format LABEL). This
function makes an array of strings out of one plain string. This is a
lazy function that will fail to produce a correct result if the object
names contain commata (e.g., \"This, is, a, Telos, object, name, with,
commata.\").
]

*Input parameters:*

#quote(block: true)[
A string with comma-separated-list.
]

*Result:*

#quote(block: true)[
A NULL-terminated array of strings.
]

== Compiling and Linking
<sec:compileandlink>
If you want to _compile_ your source that uses libCB, you have
basically to make sure two things:

- the header files of ConceptBase are found, and

- the correct system header files are included in CBinterface.h

The first item is usually achieved by adding a parameter -I with the
include-directory of your ConceptBase installation to the list of
compiler options. For the second point, you have to define the symbol
LINUX, WIN32 or SOLARIS (usually done with the -D option of the
compiler), depending on the operating system of your client application.

We have used the following compiler flags (with gcc 3.2 on the
UNIX-based systems, and MS Visual C++ 6.0 on Windows):

/ Solaris: #block[
`-I$(CB_HOME)/include -DSOLARIS`
]

/ Linux: #block[
`-I$(CB_HOME)/include -DLINUX`
]

/ Windows: #block[
`-nologo -MT -W3 -GX -O2 -I$(CB_HOME)/include -D "WIN32"` \
`-D "NDEBUG" -D "_CONSOLE" -D "_MBCS" -Fo".\\" /Fd".\\" -c `
]

If you want to _link_ your application, you have to make sure that
libraries are found by the system (-L option of gcc) and that the
library libCB is indeed linked to your application (-l option). We have
used the following linker options:

/ Solaris: #block[
`-L$(CB_HOME)/sun4/lib -lCB -lnsl -lsocket`
]

/ Linux: #block[
`-L$(CB_HOME)/linux/lib -lCB`
]

/ Windows: #block[
`kernel32.lib user32.lib wsock32.lib $(CB_HOME)/windows/lib/libCB.lib` \
`-nologo -subsystem:console -incremental:no -machine:I386`
]
