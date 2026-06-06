= The ConceptBase.cc Server
<cha:cbserver>
The ConceptBase.cc server (CBserver) offers its services via a TCP/IP
port to client programs. The main services are to TELL or UNTELL O-Telos
objects and to ASK queries to the database. The operations are called by
clients (for example, the user interfaces described in section
`cha:workbench`). An arbitrary number of clients can connect to a
CBserver.

The CBserver is started (You can also start the CBserver from within the
ConceptBase.cc user interface CBIva. Details are in the installation
guide distributed with ConceptBase.cc and in section
by a command line

```
   cbserver <params>
```

assuming that the installation directory of ConceptBase.cc is added to
the search path of executable programs. If it is not on the search path,
then simply change the current directory to the installation directory
of ConceptBase.cc or use its absolute path of the cbserver script.


= CBserver parameters
<sec:cbsparams>
The following parameters are available for the 'cbserver' command:

/ -d dbdir: #block[
Set database `dbdir` to be loaded. If the database does not exist, it is
created and initialized with the O-Telos pre-defined objects. The
database is maintained as a directory. Setting the database is mandatory
except when the update mode is set to `nonpersistent` (see below). You
cannot start two concurrent servers which use the same database
directory. To avoid this case, a file `OB.lock` is created in the
database directory when the first server is started. If the server
crashes during its execution, the file `OB.lock` will still exist in the
directory. Before you restart the server, you might have to remove this
file manually.
]

/ -db dbdir: #block[
Like `-d` but also sets the load/save/views directories to `dbdir`, i.e.
the CBserver will automatically maintain the module sources in `dbdir`
and also materialize the selected queries in the same directory. See
section `sec:module_views` for details.
]

/ -new dbdir: #block[
Like `-d` but deletes any existing database at location `dbdir` before
it creates and initializes it.
]

/ -u updatemode: #block[
controls update persistency. The allowed values are `persistent` and
`nonpersistent`. If no database is provided by parameter \"-d\", then
the default update mode is set to nonpersistent. Otherwise, the default
is persistent. In nonpersistent mode, all updates are lost after the
ConceptBase server is stopped. In persistent mode, updates are stored in
the files of the database and will be available for future sessions.
]

/ -U untellmode: #block[
controls the way how UNTELL is executed by the server. The allowed
values are `verbatim` and `cleanup` (default). In verbatim mode, the
UNTELL operation will only untell the facts directly described by the
O-Telos frame being submitted as argument. In cleanup mode, UNTELL will
also try to remove the instantiation to the O-Telos system classes
`Individual`, `Attribute`, `InstanceOf` and `IsA`. By doing so, UNTELL
behaves inverse to the TELL operation. More details are explained in
subsection `sec:untell`.
]

/ -port portnr: #block[
sets the TCP/IP socket portnumber for client connections to the
CBserver. The value `portnr` must be between 2000 and 65535. If there is
already a process using the portnumber, the CBserver will abort. The
default value for the portnumber is 4001.
]

/ -p portnr: #block[
is the same as \"-port portnr\". Deprecated since it conflicts with a
predefined command line parameter of SWI-Prolog.
]

/ -version: #block[
display version info and exit.
]

/ -help: #block[
display list of CBserver options and exit.
]

/ -license: #block[
display license and exit.
]

/ -team: #block[
display the ConceptBase developers who contributed to the current source
code and exit.
]

/ -t tracemode: #block[
sets the tracemode of the CBserver. It is one of `silent`, `no`,
`minimal`, `low`, `high`, `veryhigh`. The tracemode determines the
amount of text displayed by the server during its execution. The
tracemode does not influence the function but is used for debugging. The
default tracemode is set to `no` (only display CBserver interface). The
tracemode `low` will configure the CBserver to trace the CBserver
interface calls plus answers, and the tracemode `no` virtually disables
tracing. The tracemode `silent` is even surpressing the message
'CBserver ready' when starting up the CBserver. The tracemode `high` and
`veryhigh` are useful for debugging the system. In these two modes, an
unlikely fatal signal like division by zero will not directly abort the
CBserver process but start a debug dialog. Enter \"h\" for options to
diagnose the problem in collaboration with the ConceptBase developers.
]

/ -c cachemode: #block[
turns on the query cache to allow recursive query evaluation. The value
`cachemode` is one of `off`, `transient`, and `keep` (default). In
transient mode the cache is emptied before each transaction. In keep
mode, the cache is emptied when the maximum number of entries in the
cache is exceeded or an update has invalidated the cache. Further
details are explained in section `sec:cbcache`.
]

/ -cs size: #block[
specifies maximum number of derived facts retained in a cache between
two transactions. This option may be used in conjunction with the
cachemode `keep`. The default value is 60000 facts.
]

/ -o optmode: #block[
controls the optimizer for rules, constraints and queries. The value
`optmode` is one of `0` (no optimization), `1` (structural optimization
by exploiting builtin O-Telos axioms), `2` (optimizing join order), `3`
(combines 1 and 2), or `4` (combines 1 and 2 with trigger pruning).
Default and recommended is 4.
]

/ -r secs: #block[
automatically restarts the CBserver after a crash, or when it was
started with option -sm slave and the last client exits. The value
`secs` specifies how many seconds to wait before restart. You may want
to use this option in a multi-user setting, where the CBserver runs on a
different machine that the user clients. The -r option must be handled
with great care since it can easily lead to an infinite loop of
restarts, e.g. when a database file is corrupted. In such cases you
might have to reboot the whole computer!
]

/ -s securitylevel: #block[
configures the access control mechanism of ConceptBase. The value `0`
means that no access control is employed. Any user can ask, tell,
untell, retell any object in any module. You can also untell objects
defined in a super-module. Level `1` (default) provides a very basic
protection: one can only untell objects if they are defined in the
current module. This prevents in particular undesired deletions of
objects defined in the `System` module. Level `2` fully enables access
control. First, untelling of objects must happen in the module where the
object has been defined. Second, any transaction submitted by a user to
the CBserver is checked against the permission rules as defined in
section `sec:modaccess`. Level `3` enables at most read access to a
module. In addition, the permission rules must allow read access. This
level makes sense if you want to freeze a database state. Enable access
control when you use ConceptBase in a multi-user setting and you want to
avoid errorneous interferences between different users.
]

/ -e maxerrors: #block[
sets the maximum number of errors to be displayed to a ConceptBase.cc
client within one transaction. The value -1 means that no restriction is
applied. Set to 0 to surpress any errors message and to a positive
number to limit the displayed errors messages to that number. A low
positive number can speed up the communication between ConceptBase
client and server if a lot of error messages are generated. The default
is 20.
]

/ -cc ccmode: #block[
(predicate typing) controls to which extent the CBserver applies strict
typing of attribution predicates `(x m y)` occurring in the membership
constraints of query classes. If the mode is set to `strict` (=default),
attribution predicates without a unique concerned class (The concerned
class is a consequence of the predicate typing condition of section
shall not be accepted. If the mode is set
to `extended`, the search for concerned classes shall include subclasses
(see section `sec:SemFormula`). If the mode is set to `off`,
ConceptBase.cc also accepts queries with unstrictly-typed attribution
predicates. The strict mode is preferable since it avoids certain
semantic errors. Deduction rules and integrity constraints may never
violate the predicate typing condition, even if the mode is set to
`off`. An example for a query using non-strict predicate typing is
available from the CB-Forum, see
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/1270138");.
]

/ -mu mumode: #block[
(multi-user mode) specifies whether the CBerver should run in multi-user
mode (value `enabled`) or in single-user model (value `disabled`). By
default, the multi-user mode is enabled, allowing multiple users with
different user names to connect to the CBserver. In single-user mode,
only clients started by the same user (identified by her name) can
connect to the CBserver. The single-user mode is recommended if you want
to block other users from logging into your CBserver. Since the test is
done only on the user name, a malicious attacker could use your user
name for an account on another computer and then successfully log into
your CBserver. Use Internet firewalls to protect against such attacks.
If you specify an administrator user (option -a), then this user can
always connect to the CBserver.
]

/ -v vmode: #block[
controls whether view maintenance rules are generated (vmode=`on`) or
not (vmode=`off`). View maintenance rules are used to keep a
ConceptBase.cc view up-to-date upon changes to the object base. Default
value for vmode is `off`.
]

/ -mc maxcost: #block[
this parameter defines the maximum cost level for a predicate in a
binding path that is used to compile a meta formula (see section
`sec:CCmeta`). The evaulation of a binding path yields fillers for the
meta variables. Set maxcost to 10 if such a predicate should have about
one free variable. Set it to 100 if if may have two free variables.
Default is 100. The higher the number, the more candidate paths are
generated, increasing the likelihood that a binding path is found. On
the downside, a high value increases the compile time of meta formulas.
]

/ -pl pathlen: #block[
sets a maximum length for binding path candidates. In principle, the
number of candidates can explode with the path length. Like the previous
parameter, the path length influences the ability of ConceptBase.cc to
compile meta formulas. The default value is 5. If you set the value to
0, then no meta formula can be compiled.
]

/ -im imax: #block[
sets the maximum number of iterations used to re-order attribution
predicates with one free variable. Evaluating such predicates first can
lead to faster elimination of free variables and thus lead to better
query and ECA performance. The default value is 3.
]

/ -eca emode: #block[
controls the ECA sub-system. Possible values are `unsafe` (ECArules are
evaluated without safeguarding recursive deductive rules), `off`
(ECArules are not evaluated, even if some are defined), and `safe` (ECA
rules are evaluated with safeguarding recursive rules; this is the
default). Use the mode `unsafe` if none of your ECArules calls recursive
predicates on the newest database state. This may lead to a limited
speed-up.
]

/ -eo eomode: #block[
controls the optimization of conditions of ECArules. Possible values are
`on` (default) and `off`. The optimization is done by a re-ordering of
predicates in the condition. Hence, you only want to turn of
optimization to gain full control over the order of evalution in ECA
conditions.
]

/ -load dir: #block[
specifies the directory from which the CBserver will load module sources
at start-up time. The module sources must have file names starting with
`System` and file type `sml`. Typically, they are generated via the
`-save` flag in the preceding session of the CBserver. The default is
`none`, i.e. no module sources are loaded at CBserver start-up.
]

/ -save dir: #block[
specifies the directory into which to save certain textual excerpts of
the database, in particular module listings. The parameter has the
default value `none`, which disables the saving function. Currently, the
CBserver only saves module listings. Each module is stored in one file
with file type `sml`. The directory `dir` must exist. The module listing
is performed when the CBserver is shut down (complete module tree is
listed), or when a client tool logs out (home directory tree of the
client tool is listed). The module listings uses the `set module`
directive to enable the import of the file to the right module location.
See also section `sec:module_sources` for details.
]

/ -views dir: #block[
specifies the directory into which the results of certain queries are
materialized. See section `sec:module_views` for details.
]

/ -ms sep: #block[
specifies the module separator to be used for saving module listings and
views. If the separator is set to '-' (default), then all module sources
and views are stored at the top level directory. If the module separator
is set to '/', then the files are stored in a deep sub-directory
structure that mirrors the module structure.
]

/ -mg mgmode: #block[
specifies whether module listings are generated with separators
\"`{—}`\" for each transaction occurring in the module (option `split`)
or without such separators (option `whole`). The default is `split`. The
split option better supports cases where metaformulas are defined and
used in the same module. The third option is `minsplit`. It minimizes
the number of separators to those that are essentially needed.
Subsequent loading of such module sources is then faster.
]

/ -rl rlmode: #block[
controls the way how the CBserver creates labels for generated formulas.
The default value is `on`, instructing the CBserver to find a readable
label for the generated formula. It typically consists of the labels of
the participating metaclass attributes occuring in the metaformula. If
set to `off`, the CBserver will just take a system-generated label that
contains a unique identifier. This is slightly less readable (if you
want to inspect the generated formulas) but safe against certain
possibilities of assigning the same label twice.
]

/ -ia tmax: #block[
sets the maximum number of hours during which a client should interact
with the CBserver to be regarded as active. Negative values are
interpreted as 'infinity'. This parameter is only used when a CBserver
uses the -sm slave and -r options, or the -g public option. The default
value for tmax is 2.0 hours.
]

/ -sm servermode: #block[
sets the server mode. Possible values are `master` (default) and
`slave`. In slave mode, the last client that leaves the CBserver will
also shutdown the CBserver, provided that the CBserver and the client
were started by the same user. This option is useful when a CBserver is
only needed while still clients are registered. A master CBserver must
always be stopped explicitly.
]

/ -st stratmode: #block[
enables or disables the rule stratification test. Possible values are
`on` (default) and `off`. If enables, then the query evaluator shall
dynamically test whether stratification violations occur. They shall
then be reported as an error. Disable the test, if you are sure that the
answers are correct even though a stratification violation occurs.
]

/ -g cmd: #block[
provides a special command to the CBserver. There are currently three
such commands. The command `nolpi` instructs the CBserver to ignore any
plug-in file (see section `cap:lpi`). The command `public` configures the
CBserver as a public CBserver (see `sec:pubcbserver`). The command `exit`
instructs the CBserver to exit immediately after start-up. This can be
useful to combination with the option `-views`, `-db` and `-save` to
materialize some excerpts from a stored database.
]

/ -a user: #block[
designates `user` as 'administrator' of this CBserver. For the time
being this just gives the right to shutdown the CBserver. By default,
the user who started the CBserver is its administrator. This user shall
also keep the right to shutdown the server, even when another user is
the designated administrator. If you specify the user name with host,
e.g.~`billy`myhost``, then only the user `billy` on host `myhost` is
recognized as additional administrator.
]

If a CBserver is started without any parameter, then the update mode
shall be set to `nonpersistent`, the trace mode to `no`, multi-user mode
is disabled, and the server mode to `slave`. The other parameters are
set to their defaults. Such a CBserver is useful as companion of tools
that need it only while they are running.

```
   cbserver
```

A ConceptBase client running on the same computer will then connect to
this CBserver, when it uses 'localhost' as host and 4001 as port number.
Since the CBserver runs un slave mode, it will shut down when its client
disconnects.

== Updating the CBserver software
<updating-the-cbserver-software>
You can always update your local installation of ConceptBase downloading
and executing the interactive CBinstaller.jar Java installer from
#link("https://conceptbase.sourceforge.net");. Be sure to terminate the
ConceptBase server and the ConceptBase user interface programs before
updating the software.

An alternative to the interactive update via CBinstaller.jar is the
shell script

```
   updateCB-bin
```

located in the ConceptBase installation directory. We recommend to
update the ConceptBase software at least once per year.


= ConceptBase under Windows 10/11
<sec:win10>
The CBserver is only compiled for Linux architectures. This means that
user of other platforms must rely on a Linux system to utilize
ConceptBase. The traditional way is to start the CBserver on such a
Linux system and then connect to it, possibly using a so-called public
CBserver (see section `sec:pubcbserver`). Since April 2017, this detour
is no longer required for users of Windows 10/11 (64bit). This version
of Windows is capable to let Linux programs run under the 'bash'
utility, which is basically a whole Linux system under Windows that
realizes calls to the Linux API by hooks to the Windows API. Hence, it
is not a virtual machine, it lets you run the Linux (64bit) variant of
the CBserver natively on Windows 10/11.

To enable the Linux capability on Windows 10/11, follow the instructions
at #link("http://conceptbase.sourceforge.net/CB-WinLinux.html");. Note
that you must have installed Java (64bit) on your Windows machine, not
Java (32bit) to take full advantage of this feature. You can check
whether your Java is 64bit by calling the following command in a Windows
command window.

```
   java -version
```

The string \"64bit\" should be in the response. Users of older Windows
versions and of other operating systems can continue to use the public
CBserver (see section `sec:pubcbserver`) to take advantage of
ConceptBase.


= Database format
<database-format>
A ConceptBase database is a directory that contains at least the
following files:

- OB.symbol: a binary file that associates object names (like 'MyClass')
  with object identifiers.

- OB.telos: binary file storing all propositions

- OB.rule: text file containing the generated Prolog code for rules,
  constraints, and queries

- OB.ruleinfo: text file containing argument information about queries
  and some formation for the cost-based formula optimizer

- OB.ecarule: text file containing the generated Prolog code for active
  rules

The database files may only be updated via the ConceptBase server. Their
initial state is bootstrapped from textual Telos frames that define the
pre-defined objects of O-Telos. Since the pre-defined objects can change
from version to version, we cannot guarantee binary compatibility of
ConceptBase databases. You can easily export the textual definitions
from a databases via the -save option. Those definitions can then be
imported to the new ConceptBase version. The database directory may
contain further text files with filetype 'lpi'. These are Prolog plugins
loaded at startup time, see also section `cap:lpi`.


= Modifying the system database
<modifying-the-system-database>
A new database is created from the database lib/SystemDB in your
ConceptBase installation directory. The System database contains exactly
the objects of the root module `System`. They include for example the
definitions of the objects `Proposition`, `Individual`, `Attribute`,
`InstanceOf`, and `IsA`. Further the objects `Class`, `QueryClass`,
`Function`, `ECArule`, `Module` and many more are defined that are
needed to formulate queries and to use the capabilities of the system.

Whenever a new database is created, the files from this System database
are copied into the new database directory. This allows experienced
ConceptBase users to adapt the System database to their needs. Just
start a ConceptBase server with

```
cbserver -d `CB_HOME`/lib/SystemDB -s 0
```

Replace ``CB_HOME`` by the path to your ConceptBase installation
directory. Then start a CBIva user interface, connect to the CBserver
and switch to the module `System`. Assume you want to predefine the
class `Container` and declare a `Model` as subclass of `Container`:

```
Container with
  attribute
     contains: Proposition
end
Model isA Container end
```

You can also add rules and constraints about containers, e.g. that
containers may not contain themselves. A more significant extension
would be to add active rules to the system database. For example, the
active rules in CB-Forum at
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/3260276")
changes the semantics of the UNTELL operation. Such definitions are
subsequently included in any new database that you create. Be careful
with deleting system objects. The code of the CBserver relies on the
existence of certain system objects.


= Tracing and restarting
<tracing-and-restarting>
The trace of the CBserver can be saved by redirecting its output, e.g.

```
cbserver -r 10 -port 4444 -t high -d MYDB >> mylogfile.log
```

The CBserver can also be started directly from the ConceptBase.cc User
Interface (see section `cha:workbench`) and most parameters can be
specified interactively. The command line version is recommended when
one CBserver serves multiple users or when user interface and server
shall run on different machines. The parameter `-r 10` instructs the
CBserver to restart after 10 seconds if a crash has occurred.

A special error message during the startup of the CBserver is the
following:

```
### FATAL ERROR:
Application is locked by hostname, PID 1234 
### CBserver aborted
```

This messsage is printed if there is still a file with the name OB.lock
in the database directory (option -d). The OB.lock file should avoid
that two servers are using the same database directory. The file may be
left over of a previous CBserver if the server was not stopped correctly
(e.g. aborted by Ctrl-C or it crashed). If you get this error message,
make sure that there is no other server running that uses this directory
and then delete the file OB.lock. Then, the CBserver should start
correctly.


= Public CBservers
<sec:pubcbserver>
A public CBserver is a ConceptBase server that is accessible from the
whole network. As such this is a property that any CBserver has, except
when the multi-user capability is disabled, or when your firewall
prevents external access.

If you work with an existing database, you may want to specify some
access rights rules like suggested in section `sec:modaccess`. We neglect
them in this simple example. Now, start the public CBserver with
suitable parameters under Linux/Unix:

```
cbserver -r 2 -a jonny -g public -ia 0.5 -u nonpersistent -d MDB &> log.txt &
```

The option `-g public` enables the slave mode implicitely and tells
`oHome` as an instance of `AutoHomeModule`. The combination of the slave
mode and the option `-r` instructs CBserver to stop and restart when the
last client exits. The update mode is nonpersistent. As a consequence,
the restarted CBserver will use the unchanged state of `MDB`. This is
useful, if you want to provide the service of CBserver to a larger group
of (anonymous) users. They can log in with a client, operate on the
database in nonpersistent mode and eventually leave the CBserver. When
the last active client (An active client is a client whose last
interaction with the CBserver was less than a certain number of hours
ago, specified with the CBserver parameter `-ia).` leaves the CBserver,
then CBserver will freshly start up after 2 seconds. Due to the option
`-u nonpersistent` user-defined objects are only stored at the public
CBserver while there are still active clients enrolled to the public
CBserver.

The parameter `-a` sets the administrator user of the public CBserver.
This user is allowed to shutdown the CBserver from a client. The auto
home feature will assign different users to individual workspaces.
Unless you introduce access rights (and enable them via the CBserver
option `-s 2`) the users can also manipulate the modules of other users.
However, the CBserver is restarted whenever the last client logs off.
Hence, the definitions of different users are not permanently stored on
the CBserver. The parameter `-ia` used here instructs the CBserver to
regard a client as active of it had its last interaction within 0.5
hours. Clients that were inactive for a longer time will not prevent the
CBserver from restarting when another (active) client logs off the
CBserver.

Consider the following alternative command to start a public CBserver:

```
cbserver -t no -r 2 -a jonny -g public -ia -1 -d ALLDB &> /dev/null &
```

Here, the updates are stored persistently in the database ALLDB. Changes
to modules are not lost when the last active client leaves the CBserver.
There is no log file created as well. The option '-ia -1' used here
instructs the CBserver to regard any client as active, regardless of how
long ago its last interaction occurred.

Configure the CBIva interface to use the public CBserver via the
variable `PublicCBserver`. It can be set by the menu item \"Options/Edit
Options\" of CBIva, see section `sec:config`. A value different from
`none` enables the use of the public CBserver by CBGraph. You can
optionally append a port number like \"cbserver.acme.com/4002\". The
default value for the port number is 4001. Installations of ConceptBase
on platforms, for which no binaries of the CBserver exist, may use a
default public CBserver. This is the case OS-X and older versions of
Windows (Windows 10/11 (64bit) has the ability to activate a Linux
sub-system which can then be used to start CBserver transparently. If
you had previously used a public CBserver under Windows 10/11 and now
want to utilize a local CBserver, then reset the variable
`PublicCBserver) to ``none``.`.

The best way to interact with a public CBserver is to use graph files,
see section `sec:cbgraphcmd`. Assume that a public CBserver is running on
host `cbserver.acme.com`. and that `cbserver.acme.com` was configured as
the public CBserver to be used. Then, calling

```
cbgraph graph1.gel 
```

will connect to the public CBserver instead of 'localhost'. The port
number for the connection is taken from the graph file. Do not forget to
save the graph file before exiting CBGraph if the public CBserver was
started in non-persistent mode. If you subsequently open the graph file,
it will attempt to connect to the same host. You can force it to attempt
the connection to localhost instead by

```
cbgraph -host localhost graph1.gel 
```

If you are using ConceptBase under Linux, then the CBserver is running
by default on your local computer (\"localhost\"). The same is true for
Windows 10/11 with an enabled Linux subsystem. Users on Mac computers or
older Windows versions are by default using a public CBserver at the
university where ConceptBase is developed. This public server is meant
for testing the system. *DO NOT USE it for managing confidential
information!* If you plan to use ConceptBase in a serious way, we
recommend that you set up a protected Linux server on your own network
that runs the CBserver. Users can set up the variable \"PublicCBserver\"
in CBIva to the address of the protected Linux server to automatically
connect to that server, see section `sec:config`. You can also connect to
that server manually via the \"Connect\" function of the ConceptBase
clients CBIva, CBGraph, and CBShell.


= The tabling subsystem
<sec:cbcache>
Since version V5.2.4 ConceptBase.cc features a new query evaluation
method, which uses a so-called tabling cache to store intermediate
results of predicates that are called during the top-down (SLDNF) query
evaluation. Assume, for example, that an employee 'bill' has two
projects 'p1' and 'p2'. Then, the result of a predicate '(bill
hasProject x)' with variable x would be the set {(bill hasProject
p1),(bill hasProject p2)} consisting of facts. We call this fact set
also the _extension_ of the predicate.

After a completed predicate evaluation, the tabling cache of the
predicate holds its extension. Tabling speeds up query evaluation and
prevents infinite loops when ConceptBase.cc evaluates recursive queries
and deductive rules. Essentially, the tabled evaluation allows to
compute dynamically stratified semantics of the Datalog database
underlying ConceptBase.cc. Plenty of examples for recursive rules and
queries are provided in the online ConceptBase Forum.

The CBserver provides three tabling cache modes to control the behavior
during query evaluation:

/ -c off: #block[
In this mode, the cache is completely disabled. Use this mode when your
models do not include recursive rules. The mode is only provided for
backward compatibility and has no advantages.
]

/ -c keep: #block[
The cache is only emptied when necessary, in particular when the cache
has been invalidated by an update to the database, or when the maximum
number of facts in the cache is exceeded. The maximum number is
currently set to the default 20000. Exceeding the maximum is not an
error. It only indicates that the cache is marked for being emptied. If
necessary, the cache emptying takes place before a transaction. The keep
mode is on average consuming more main memory than the transient mode
but speeds up response time enormously in case of re-use of query
results. The 'keep' mode is the default mode for tabling. You can change
the maximum cache size by the CBserver command line option \"-cs\".
]

/ -c transient: #block[
The tabling cache is emptied before each transaction (ask, tell, untell,
retell). A subsequent query is always evaluated starting with an empty
cache. This mode is somewhat 'safer' than the 'keep' mode since it
starts each query with an empty cache state. While the answer to a query
is in principal independent from the cache mode, the cache mode has a
certain influence on the persistence of objects created within a
transaction. Specifically, results of arithmetic expressions computed
during one transaction shall be removed after the transaction when the
cache mode is 'transient'. In cache mode 'keep', these objects continue
to exist and are visible to future transactions.
]

ConceptBase will only call tabled evaluation for deductive predicates.
Other predicates are evaluated by the regular SLDNF engine of the
underlying Prolog engine. By default, the tabling cache mode is
activated in mode `keep`. Some statistics on cache usage are written to
the terminal window of the ConceptBase server when the tracemode has
been set to `veryhigh`.

Acknowledgements: The techniques for the tabled query evaluator of
ConceptBase.cc are inspired by the 'tabled evaluation'
`ssw94``chenwarren96`. We do however not delay the evaluation of negated
predicates but rather re-order them at compile time to guarantee that
all variables are bound at call time. Tabled evaluation is also
implemented in XSB \[#link("http://xsb.sourceforge.net/");\] and DES
\[#link("http://www.fdi.ucm.es/profesor/fernan/des/");\].


= Database persistency
<sec:persistency>
The default update mode is 'persistent'. In persistent mode, all changes
to the database are written to the file system at the directory
specified in the parameter '-d'. Persistent mode is suitable when a
CBserver runs for a longer period of time and is directly updated by
application programs. If ConceptBase.cc is used for testing and modeling
purposes, the update mode 'nonpersistent' is an interesting alternative.
We discuss two scenarios for the nonpersistent mode and one for the
persistent mode. \

*Scenario 1: Single-user modeling*;. When a user needs to model a
certain application domain with classes and meta classes, he usually
works with external Telos files (aka source models, file extension
'.sml'). These files can include comments like usual with program source
code. The recommended mode here is '-u nonpersistent' without specifying
a database. The user can load the source models into such a
non-persistent server and make corrections to the source files in case
of errors or design changes. Here, ConceptBase is mostly used to check
and analyze the models. Recommended options:

```
cbserver -u nonpersistent -mu disabled
```

*Scenario 2: Lab assignments*;. Assume that a teacher wants
students to exercise a certain modelling task using ConceptBase.cc.
Then, he would prepare some Telos files with necessary definitions (e.g.
some meta classes) and load them into a persistent ConceptBase server.
After that, he can restart the ConceptBase server in non-persistent mode
on the same database created before. Student can then work on their
extensions while the state of the database can easily be set back to the
original state defined by the teacher. The module system of
ConceptBase.cc can be used to support multiple students to work on the
same server without interfering with each other, see section
`sec:module`. Recommended options:

```
cbserver -d MYDB -s 2 -mu enabled -u nonpersistent
```

The second scenario might also be useful in modeling. If there are some
parts that are regarded as stable, the modeller can decide to make them
persistent and only add/modify those Telos models that are still subject
to change. In particular for large Telos models, this strategy saves
time. Note that the updates by the users are lost when the
non-persistent CBserver is stopped. This might be useful, if you want to
re-use the same initial database MYDB several times, e.g. for different
user groups. \

*Scenario 3: Project work*;. Here the students work for several
days on a given task. Changes shall not be lost. The use of the `-db`
option will not only store the database in binary form but also store
the source code of all modules as text files in directory MYDB.
Recommended options:

```
cbserver -db MYDB -s 2 -mu enabled 
```

If ConceptBase.cc is used in a multi-user setting, then one can combine
the update mode with the module feature (see section `sec:module`). In
this scenario, multiple users access the same CBserver. A common super
module (e.g. the module `oHome`) carries the common objects of the
users. Each user can be assigned to her own hown module (a sub module of
the common super module) and create and update objects in this workspace
without interfering with other users. If several groups of users shall
share their definitions, then they would be assigned to the same home
module. The home module may have sub modules for testing and releasing
definitions. By employing access rights to modules, one can also design
which user has which read/write permissions. The builtin query
`listModule` allows to save the contents of a module to a Telos source
file (see section `sec:module_content`).


// section conversion failed
\section{The UNTELL operation}
\label{sec:untell}

ConceptBase.cc realizes the concept of a historical database. The TELL operation
submits O-Telos frames to the CBserver. The CBserver extracts the 'novelty'
of the submitted frames and translates it into a set of P-facts to be stored
in the object store. Any P-fact has a so-called {\em belief time\/} associated to
it (see section \ref{sec:representation}). The belief time is an interval $(t_1,t_2)$ whose left boundary $t_1$ is the time point whe


= Memory consumption and performance
<sec:restrictions>
ConceptBase.cc stores objects in a dedicated object store maintained in
main memory. A P-fact $P \( o \, x \, n \, y \)$ consumes about 800
bytes of main memory. That means that one can store roughly 1 million
P-facts in 1 GB of main memory. A typical Telos frame is stored with
roughly 10 P-facts. Hence, 1 GB of main memory allows you to store
around 100.000 Telos frames. On 32 bit CPUs, this results in a maximum
of roughly 400.000 frames that can fit into 4 GB of addressable main
memory. This restriction virtually vanishes with 64 bit CPUs.

A single TELL/UNTELL operation submitted to the CBserver should not
contain more than about 2000 frames (at about 5 attributes per frame).
Otherwise, the compiler can run out of stack memory.

The raw performance of the object store, i.e.~the time needed to
reconstruct a frame for a given object identifier, is virtually
independent from the number of P-facts that it stores. However, if you
have defined many rules or integrity constraints, the performance may
well degrade significantly with the number of stored P-facts. The same
holds for queries. We tested the response times for standard queries
such as computing the transitive closure in relation to varying database
sizes. Results indicate that ConceptBase apparently approximates in many
cases the theoretic optimum.

The performance of the active rule evaluator (section `sec:eca`) is
currently rather limited. We measured around 100 rule firings per
second. This can be a performance bottleneck when many active rules are
being processed.


== The Java API to the CBserver
<sec:javaapi>
The application programming interface (API) to the ConceptBase server
(CBserver) is realized by the Java class `LocalCBclient`. Most (Java)
application programmers presumably only need the simple String-based
part of `LocalCBclient` to interact with a CBserver. `LocalCBclient`
uses socket-based data streams to realize the communication. We define
here the methods of this String-based API. If the argument starts with
an \"s\", then the data type is `String`. If it starts with an \"i\",
then the data type is `int`.

```
LocalCBclient cbClient = new LocalCBclient();
```

- This constructor provides the API object `cbClient` to be used for the
  subsequent method calls.

```
sAnswer = cbClient.cbserver();
```

- This method attempts to start a single-user CBserver in \"slave mode\"
  on localhost with port number 4001. The method only works on platforms
  for which the CBserver was compiled. This is currently limited to
  Linux and Windows 10/11 (see also section `sec:win10`). In other cases,
  you need to start a CBserver on a host system that supports the
  CBserver and then use the 'connect' method. If the CBserver was
  successfully started, the method returns \"yes\", otherwise \"no\". If
  the cbClient is already connected to a CBserver, then the method also
  returns \"yes\". The CBserver shall automatically shut-down when the
  last client disconnects from it.

```
sAnswer = cbClient.connect(sHost, iPort, sTool, sUser);
```

- This method connects your Java program to the CBserver specified by
  `sHost` (the domain name of the computer on which your CBserver runs
  on) and `iPort` (the port number is an integer; usually 4001). The
  string sTool shall be a self-selected name of your tool, e.g.
  `"ModelerXY"` and sUser is a string containing a user name (typically
  your user name). If you use `null` as username, then the `cbClient`
  will use the login name of the computer user that started the Java
  program. The return value is `"yes"` if successful and `"no"` else.
  Use the boolean-valued function `cbClient.isConnected()` to check
  whether `cbClient` is currently connected to a CBserver. If the socket
  connection breaks down, then the `cbClient` will set the connection
  status to unconnected.

```
sAnswer = cbClient.connect();
```

- Connects to the public CBserver (see section `sec:pubcbserver`) if
  configured for your installation. Otherwise, attempts to start a
  single-user \"slave\" local CBserver on port 4001 if not started.
  Connects to the local CBserver with the default tool name
  \"LocalCBClient\" and `null` as username. It behaves similar to the
  \"connect\" command of CBShell.

```
sAnswer = cbClient.disconnect();
```

- This method disconnects connects your Java program from the CBserver.
  The return value is `"yes"` if successful and `"no"` else. If the
  CBserver was started in \"slave mode\" and the cbClient is the last
  remaining client of the CBserver, it will shut down.

```
sAnswer = cbClient.pwd();
```

- This method outputs your current working module path, e.g.
  `"System-oHome"`.

```
sAnswer = cbClient.mkdir(sModule);
```

- This method creates a new submodude (e.g. `"MyMod"`) in the current
  module.

```
sAnswer = cbClient.cd(sModule);
```

- This method changes the current module to `sModule`, e.g. `"MyMod"`.

```
sAnswer = cbClient.tells(sFrames);
```

- This method tells (=defines) the objects given by the string sFrames
  to the current module of the CBserver. The return value is `"yes"` if
  successful and a string containing user-readable error messages else.

```
sAnswer = cbClient.untells(sFrames);
```

- This method untells (=removes) the objects given by the string
  `sFrames` from the current module of the CBserver. The return value is
  `"yes"` if successful and a string containing user-readable error
  messages else.

```
sAnswer = cbClient.asks(sQuery,sFormat);
```

- This method asks the query call `sQuery` (given by a String) to the
  CBserver The return value is a string containing the answer to the
  query. The return value is `"no"` in case of errors, e.g.~when the
  query is not defined. The query call can have arguments, e.g.
  `"get_object[Class/objname]"`. The CBserver shall use the answer
  format `sFormat` for the result. Thus, if you want to define your own
  answer format, then use the facilities described in section
  `sec:answerformat`. The query shall be answered in the context of the
  current module and the current time (`"Now"`). The answer `"nil"`
  stands for an empty answer.

```
sAnswer = cbClient.asks(sQuery);
```

- Same as `cbClient.asks(sQuery,"default")`, i.e. the CBserver
  determines the applicable answer format (in most cases: `"FRAME"`).

```
sAnswer = cbClient.clientid();
```

- Return the identifier by which this client is registered to a
  CBserver.

```
sAnswer = cbClient.clearall();
```

- Attempt to delete all objects from the current module. Returns \"yes\"
  if successfull, otherwise \"no\". Calls the 'purgeModule' query
  described in section `sec:module_purge`. Use this method with great
  care since it wipes out the whole module content.

Below is the listing of the Java program `TinyClient.java` that uses the
String-valued API:

```
import i5.cb.api.*;
public class TinyClient {
  private static LocalCBclient cbClient = null;
  public static void main(String argv[])  {
    String sAnswer;
    cbClient=new LocalCBclient();
    sAnswer = cbClient.connect("cbserver.acme.org",4001,"TinyClient",null);
    sAnswer = cbClient.tells("Employee in Class end");
    sAnswer = cbClient.asks("get_object[Employee/objname]");
    System.out.println(sAnswer);
    sAnswer = cbClient.disconnect();
```

You need to compile the Java program with the `cb.jar` library. This is
available from the ConceptBase installation directory (referred here as
CB\_HOME). To compile the Java program call

```
  javac -classpath `CB_HOME`/lib/classes/cb.jar TinyClient.java
```

Before running the client, make sure that the CBserver runs on the
specified Linux computer (here \"cbserver.acme.org\") under the
specified port number (here 4001), and that this port number is
accessible from your client computer. You may want to configure that
CBserver as a public CBserver (see section `sec:pubcbserver`) to have a
save way to connect your Java program to it.

The Java program can then be started under Linux as follows:

```
  java -classpath `CB_HOME`/lib/classes/cb.jar:. TinyClient
```

Under Windows, you should use:

```
  java -classpath c:\conceptbase\lib\classes\cb.jar;. TinyClient
```

The Java source code for `TinyClient.java`, `TinyClient2.java` (uses the
cbserver method), `TinyClient3.java` (uses the connect method), and a
more elaborate example `SimpleClient.java` is included in the directory
`examples/Clients/JavaClient` of your ConceptBase installation
directory.

= The CBShell Utility
<cha:cbshell>
The ConceptBase.cc Shell (CBShell) is a command line client for
ConceptBase.cc. It allows to interact with a CBserver via a text-based
command shell. Moreover, it can process commands from a script file
without further user interaction. The utility can be employed to
automate certain activities such as batch-loading a large number of
Telos models into a CBserver, or to extract certain answers from a
CBserver.


= Syntax
<syntax>
There are two ways to use the CBShell. The first one processes the
commands from a script file (batch mode). The second one prompts the
user for commands (interactive mode).

```
   cbshell [options] scriptFile [params]
   cbshell [options]
```


= Options
<options>
/ -l: #block[
This options instructs CBShell to write errors and some statistic
information to the files error.log and stat.log.
]

/ -f scriptFile: #block[
Execute the commands specified in scriptFile rather that requesting
commands from the command line interface. If the -f option is used and a
scriptFile is specified, the commands of the file will be executed
without user interaction, and CBShell will exit at the end. The prefix
\-f can also be omitted, i.e.~\"cbshell scriptFile\" is equivalent to
\"cbshell -f scriptFile\".
]

/ -t: #block[
This option can only be used in combination with the -f option. It shall
instruct CBShell to confirm each command in the script file before it is
executed.
]

/ -i: #block[
This option modifies the 'cbserver' command by invoking a CBserver
compiled directly from its sources. For developers only.
]

/ -a: #block[
This options instructs CBShell not to directly show the answer to each
command in interactive mode; instead you have to manually call
showAnswer
]

/ -v: #block[
This options enables the verbose mode. In this mode, the command and the
answer are always displayed on standard output
]

/ -p: #block[
Disables the display of the command prompt in interactive mode. This may
be useful when CBShell is used in a Unix pipe where the preceding
program generates the commands and feeds them into CBShell.
]

/ -q: #block[
Instructs CBShell to convert single quotes in positional parameters into
escaped double quotes. This option is useful when a parameter contains
special characters and still shall be regarded as a valid object label
by ConceptBase. Useful when calling CBShell scripts within regular
scripts (e.g. bash) that pass parameters with special characters to the
CBShell scripts. See also section `sec:shellintegration`.
]

/ -un username: #block[
configures CBShell to use \"username\" instead the username as assigned
by the operating system to connect to a ConceptBase server. Only
required in special circumstances, e.g. when your own username shall not
be disclosed.
]

/ params: #block[
At most nine user-defined positional parameters can be supplied. The are
bound to the CBShell variables \$1 to \$9. The CBShell variable \$0 is
bound to the name of the scriptfile.
]


= Commands
<commands>
/ cbserver \[_serveroptions_;\]: #block[
: starts a CBserver with the specified options and connects to it
]

/ connect _host_ _port_;: #block[
: connects to an already running CBserver; if a public CBserver is
configured then it is the default host; otherwise localhost is default
host; 4001 is default port number; if the connections fails and the
local operating system can start a CBserver, then a local CBserver is
started with default settings
]

/ disconnect: #block[
: disconnects from a CBserver
]

/ stop: #block[
: stops the CBserver which is currently connected
]

/ tell _frames_;: #block[
: tells frames to the CBserver; enclose the frames in double quotes
]

/ untell _frames_;: #block[
: untells frames from the CBserver; enclose the frames in double quotes
]

/ retell _untellFrames_ _tellFrames_;: #block[
: untells and tells frames to a CBserver in one transaction; enclose
both arguments in double quotes (There is a small syntactic restriction
for the retell command. You need to avoid a line consisting just of a
double quote to terminate the untellFrames. Instead, start the
tellFrames in the same line that terminates the untellFrames.)
]

/ tellModel _file1_ _file2_ ...: #block[
: tells files to the CBserver; the files can have file types \".sml\"
and \".txt\"; if the first file from the list exists on the the computer
of the CBShell client, then the files will be loaded from the local file
system, otherwise the CBserver is requested to load the files from its
own file system
]

/ ask _Query_ \[_QueryFormat_ \[_AnswerRep_ \[_RollbackTime_;\]\]\]: #block[
: asks a query; possible query formats are `OBJNAMES` and `FRAMES`; the
answer representation can be `LABEL`, `FRAME`, `FRAGMENT`,
`FRAGMENTswi`, `JSONIC`, `default`, or a user-defined answer format; the
rollback time shall normally be set to `Now`. See also subsection
`sec:rollbacktime` for more information. If the query format is
`OBJNAMES`, then _Query_ is a string in double quotes containing a
query call (or a comma-separated list if query calls). It the query
format is `FRAMES`, then _Query_ is a string of Telos frames
including a query definition. The answer representations are discussed
in section `sec:answerformat`.
]

/ hypoAsk _frames_ _Query_ \[_QueryFormat_ \[_AnswerRep_ \[_RollbackTime_;\]\]\]: #block[
: tells frames temporarily and asks a query
]

/ lpicall _lpicall_;: #block[
: executes the LPI call; only for debugging purposes; disabled for
security reasons
]

/ prolog _prologstatement_;: #block[
: executes the Prolog statement; only for debugging purposes; disabled
for security reasons
]

/ why: #block[
: gets error messages for the last transaction and prints them on stdout
]

/ result _completion_ _result_;: #block[
: compares the given result with the last result which has been
received; this command hence can be used to check whether the CBserver
produces the expected completion (ok, error) and result; use this
command in combination with the option `-l`
]

/ cd _mod_;: #block[
: changes the module context of this shell; if the parameter _mod_
is omitted, the module context will set the module to the user's home
module, by default `oHome`; the command \"cd ..\" shall switch to the
super module of the currenbt module, the command \"cd .\" shall leave
the current module unchanged
]

/ pwd: #block[
: display the current absolute module path, e.g.
\"System-oHome-MyModule\"
]

/ lm _mod_;: #block[
: list all frames defined in a module; shortcut for
`ask listModule[`_`mod`_;`/module]`; uses currentmodule if called
without parameter
]

/ ls _class_;: #block[
: display the instances of _class_;; uses `Individual` as default
if called without parameter
]

/ mkdir _module_;: #block[
: creates a new module with the given name within the current module;
implemented by a tell operation \"`mod in Module end`\" ; so we mimick
the navigation within modules by commands known from Unix to manage
directories
]

/ showAnswer: #block[
: print the last result on standard output; this can be useful if you
employ the CBserver as a generator in a shell pipe (see Graphviz case
below)
]

/ showAnswer $>$ _filename_;: #block[
: same as showAnswer but output is redirected to filename
]

/ who: #block[
: show the list of users that have at any time been enrolled to this
database; implemented by a query that displays the instances of the
class `CB_User`
]

/ sub: #block[
: show the list of visible submodules to which the user can branch via
the 'cd' command
]

/ show _name_;: #block[
: show the frame with the given name; shortcut for
`ask get_object[`_`name`_;`/objname]`
]

/ echo _string_;: #block[
: prints the string to standard output; use double quotes if the string
has multiple words; a sequence '$without without$n' within the string is
replaced by a newline character;
]

/ echo -n _string_;: #block[
: like the one-argument variant but no newline is printed after the
string
]

/ nl: #block[
: prints a newline character on standard output
]

/ exit: #block[
: exits the shell (also stops a server which has been started in this
shell)
]

Command arguments with white space characters have to be enclosed in
double quotes ('\"'). Command arguments may span multiple lines. Lines
starting with '\#' are comment lines ( The last line of a CBShell script
file should not be a comment line. Otherwise, CBShell fails to recognize
the end of file correctly.). If an argument contains a string of the
form `$PropName`, it will be replaced with the value of the
corresponding Java property (which may be defined using the -D option of
the Java Virtual Machine), if the property is defined. There are a
couple of legacy commands that we support for backward compatibility:

/ startServer \[_serveroptions_;\]: #block[
: synonym for 'cbserver'
]

/ enrollMe _host_ _port_;: #block[
: synonym for 'connect'
]

/ showUsers: #block[
: synonym for 'who'
]

/ showModules: #block[
: synonym for 'sub'
]

/ listModule _mod_;: #block[
: synonym for 'lm'
]

/ listClass _class_;: #block[
: synonym for 'ls'
]

/ getErrorMessages: #block[
: synonym for 'why'
]

/ getModulePath: #block[
: synonym for 'pwd'
]

/ setModule _mod_;: #block[
: synonym for 'cd'
]

/ stopServer: #block[
: synonym to 'stop'
]

/ cancelMe: #block[
: synonym for 'disconnect'
]

/ newline: #block[
: synonym for 'nl'
]

/ quit: #block[
: synonym for 'exit'
]

The CBShell utility can be used in Unix pipes to extract textual output
The CBserver and pass it to subsequent programs as input. To do so, you
should start the CBserver with tracemode `no` and using the `showAnswer`
command of CBShell to specify the elements to be written to standard
output. The CBShell script below realizes the extraction of Graphviz
\[#link("http://graphviz.org");\] specifications from ConceptBase.cc:

```
   # File: myscript
   connect
   tellModel ERD-graphviz2
   tellModel UniversityModel
   ask ShowERD[UniversityModel/erd] OBJNAMES default Now
   showAnswer
   exit
```

The complete example is available from the CB-Forum at
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/2519759");.
Another resource for CBShell scripts is the list of test scripts at
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/2596438");.

== Rollback time for ASK
<sec:rollbacktime>
The 'ask' and 'hypoAsk' commands allow to specify a so-called rollback
time for the query. Normally the rollback time is set to 'Now', i.e.~the
current database state. You can also specify a precise millisecond
specify the database state on which you want to evaluate the query, e.g.
'millisecond(2020,2,7,12,27,10,230)', that is
2010-02-07T12:27:10.230UTC. Since this is a bit cumbersome, you can also
specify the name of any object as 'rollbacktime' argument. Then, the
CBserver shall take the starttime of that object as the rollback time,
for example

```
   ask get_object[AccountBill/objname] OBJNAMES FRAME transfer1
```

where 'transfer1' is just another object name.

== Argument delimiters
<sec:argdelim>
If an argument to a CBShell command spans multiple lines or contains
several words separated by blanks, then you have to enclose it in double
quotes, being the default argument delimiter. Double quotes are also
used for `String` objects in Telos frames. These have to be escaped like
in the following example:

```
   tell "
   Peter with 
      comment about: \"This is a Telos string\"
   end
   "
```

If many such frames need to be told, the escaping of Telos strings is
cumbersome. You can use the single quote as argument delimiter in such
cases, making the escaping the double quotes for the Telos string
obsolete:

```
   tell '
   Peter with 
      comment about: "This is a Telos string"
   end
   '
```


= Interactive use of CBShell
<sec:cbshellinteractive>
The CBShell can be used to run a script file or in can be used in
interactive mode. In the interactive mode, the CBShell shall directly
display the response to a command, typically the answer of the
ConceptBase server. Some of the shortcuts like 'why' and 'cd' are
specifically defined to make the interactive mode more effective.

Another feature of the interactive mode is that queries that are
represented as a single word can also be asked without the keyword 'ask'
in front of it. CBShell will then ask the query using 'default' as
answer format, i.e.~the ConceptBase server will decide in which answer
format to use. Below is a sample session of CBShell in interactive mode.

```
   cbshell
   This is CBShell, the command line interface to ConceptBase.cc
   [offline]>connect
   [localhost:4001]>mkdir M1
   yes
   [localhost:4001]>cd M1
   M1
   [localhost:4001]>tell "Employee in Class"
   no
   [localhost:4001]>why         
   Syntax error 1 in line 1, parser message:
   syntax error, unexpected ENDOFINPUT, expecting END or ENDMIT
   Syntax error Unable to parse Employee in Class.
   [localhost:4001]>tell "Employee in Class end"
   yes
   [localhost:4001]>tell "bill in Employee end"
   yes
   [localhost:4001]>ls Employee
   bill
   [localhost:4001]>show bill
   bill in Employee  
   end 
   [localhost:4001]>1+2
   3
   [localhost:4001]>stop
   [offline]>exit
```

The term `1+2` is an example of a query that is not preceded by the
'ask' command. Note that such queries may no contain blanks since it
would split it into several words. Use quotes in such cases. The prompt
`[offline]` indicates that the CBShell is not yet connected to a
CBserver. Once connected, it displays the hostname and port number of
the connected CBserver as prompt. The CBserver is started with disabled
tracing. The trace messages of the CBserver would otherwise be displayed
in the output as well.


= Positional parameters
<sec:cbshellvars>
A CBShell script can use variables \$0 ... \$9 inside the script to
refer to the positional parameters supplied via the call of cbshell.
Assume the following content of the script file:

```
   # File: pascript
   cbserver -u nonpersistent -t low -port $1
   tell "$2 in Class end"
   ask find_instances[$2/class] OBJNAMES  LABEL  Now
   ask find_instances[$3/class] OBJNAMES  LABEL  Now
```

and the command line call

```
   cbshell pascript 4321 MyClass Integer
```

The CBShell interpreter will then replace \$1 with `4321`, \$2 with
MyClass, and \$3 with Integer. If you supply less parameters than
required by the script, it will issue an error message and quit. If the
script had started a CBserver, then this CBserver is stopped before
quitting. Likewise, if the script had enrolled to an existing CBserver
process, it will unenroll before quitting.

The variable \$0 is bound to the name of the script file. CBShell uses
the Java tokenizer to separate the positional parameters. The tokenizer
uses white spaces (blanks, tabs) to separate tokens. Use double quotes
if one argument consists of several words, e.g.

```
   cbshell otherscript "MyClass isA Integer end"
```

An example of a script with positional parameters is provided in the
CB-Forum at
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/d3364559/ticket307.cbs.txt");.
You can also call CBShell scripts within scripts/batch files of the host
operating system, see section `sec:shellintegration`.


= Executable CBShell scripts
<sec:execcbshell>
A CBShell script can be made executable under Unix/Linux and can then be
used pretty much like any other shell script. Assume that you have a
CBShell script `myscript` that you want to execute directly from the
command line.

As a first step, create a link to the cbshell at a common directory for
installed programs:

```
   sudo ln -s `CB_HOME`/cbshell /usr/bin/cbshell
```

where ``CB_HOME`` is replaced by the installation directory of
ConceptBase. As a second step include the following comment as the first
line of `myscript`:

```
   #!/usr/bin/cbshell
```

Then, make the script executable:

```
   chmod u+x myscript
```

You can then directly call the script by simply typing its name:

```
   myscript
```

The direct call is equivalent to the call

```
   cbshell ./myscript
```


= CBShell scripts within regular shell scripts
<sec:shellintegration>
CBShell offers the basic commands to interact with a ConceptBase server.
However, it lacks control structures such as loops and conditions. It
also cannot invoke arbitrary programs. Regular shell scripts such as the
Bourne shell of Unix/Linux do provide these capabilities, and thus it is
a natural idea to integrate CBShell scripts within regular scripts to
accomplish more sophisticated automation tasks.

As a first step, you should make the CBShell script executable and
declare in its first line

```
   #!/usr/bin/cbshell -q
```

This allows to pass parameters that include special characters to the
CBShell script. Assume that the CBShell script `ascript` was declared
that way. Then, it can be called in a Bourne shell like:

```
   ascript 'Jet 400' MyClass 
```

The option `-q` prepares the CBShell to treat parameters with single
quotes in a special way. Assume further that `ascript` has the following
content:

```
   #!/usr/bin/cbshell -q
   # File: ascript
   ...
   tell "$1 in $2 end"
   ...
```

CBShell will internally expand the quoted parameter `’Jet 400’` to
`\"Jet 400\"` and then execute

```
   tell "\"Jet 400\" in MyClass end"
```

The resulting frame in ConceptBase shall be

```
   "Jet 400" in MyClass end
```

Essentially, single quotes of CBShell parameters are converted to double
quotes within ConceptBase. An simple example is given in
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/3372687");.
A more elaborate example is available in the CB-Forum at
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/3384265");.
The main example is in the `fileSizeDemo`.


= CBShell in a pipe
<sec:cbshellpipe>
Assume you have a program `generator` that analyzes some input data (e.g
from files) and produces output in the form of CBShell commands (`tell`,
`ask`, etc.). Then, this output can be directly passed to CBShell in a
Unix pipe:

```
   generator | cbshell -p
```

The generator program must take care of generating all required
commands, in particular making sure that CBShell is connected to a
CBserver. Consider as example generator the script file
`printfiles4cbshell` from the CB-Forum at
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/3384578");:

```
   #!/bin/sh
   echo "connect localhost 4001" 
   for file in *
   do
     if [ -f ${file} ] 
       then
        fsize=$( stat -c 
        frame="'${file}' in File with size s: ${fsize} end"
        echo tell \"\\\"${file}\\\" in File with size s: ${fsize} end\"
       fi
   done
```

It first generates a command to enroll to a CBserver on localhost at
port 4001. Then, it forms a frame for each filename in the current
directory to tell the file's size to the CBserver. You can run the
script in a terminal to see the output generated by it.

Now, assume that you have started a CBserver on localhost with port
number 4001. You should tell at least the following frame to the
Cbserver to define the class `File` to which the above script refers to:

```
   File in Class with
     attribute
       size: Integer
   end
```

Then execute in a terminal window:

```
   printfiles4cbshell | cbshell -p
```

It will tell the file size information to the CBserver. At the end, the
end of file detection of the CBShell will trigger the CBShell to exit
from the CBserver.

It is also possible to continue the pipe to a post-processing program.
In this case, the commands sent to CBShell should include `ask` commands
in combination with `showAnswer`. The following pipe shows the main
idea:

```
   generator | cbshell -p | postprocessor
```

An elaborate example of this usage is in the CB-Forum at
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/3421289");.
The example shows how to extract module import statements from program
source files, store them in ConceptBase and let ConceptBase produce a
graph specification, layed out by GraphViz.
