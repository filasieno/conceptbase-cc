= The ConceptBase.cc Usage Environment
<cha:workbench>
The ConceptBase.cc User Interface consists of two main applications:

/ CBIva: #block[
is the ConceptBase.cc Interface in Java that supports the editing of
Telos frames, displays instances of Telos objects, etc.
]

/ CBGraph: #block[
is a graphical editor for Telos models (or modules). Telos models can be
represented by differented graphical types. Insertion and deletion of
Telos objects is also supported.
]

The interface is based entirely on Java, so it should be usable on all
platforms with a compatible Java runtime environment. The Java interface
includes a graphical browser and editor. Both CBIva and CBGraph can be
used as stand-alone Java application.

== The workbench CBIva
<the-workbench-cbiva>
CBIva is a textual interface to a CBserver, which emphasizes the use of
the frame syntax of Telos. You can start the CBIva workbench by the
command

```
  cbiva
```

The command will start a script file with the same name. We assume that
the installation directory of ConceptBase.cc is added to the search path
of executable programs. After a few seconds, the CBIva main window
should pop up. CBIva will attempt to connect to a CBserver on localhost
or to a public CBserver (if configured, see `sec:pubcbserver`). Figure
`fig:cbivamain` shows the main window connected to a CBserver and gives a
short description of the buttons in the tool bar.

#figure(image("../assets/cbivamain.png", width: 100.0%),
  caption: [
    Main Window of CBIva
  ]
)
<fig:cbivamain>

The main window consists of a menu bar, a tool bar with a button panel,
the area for subwindows and a status bar. The first sub window (Telos
editor) contains the history window, which records all operations for
later reuse. In the following, each component of the user interface is
explained.

=== The tool bar
<the-tool-bar>
The tool bar is the button panel below the menu bar. All buttons have
tool tips, i.e. small messages that show the meaning of these buttons.
The tool tips appear, if you move your mouse pointer over the button and
do not move your mouse for about one second. The buttons are shortcuts
for some operations that are frequently used and are also available in
the menu. The operations apply to the Telos Editor which has currently
the focus.

- *Quick Connect*;: if connected to a CBserver then disconnect;
  otherwise try to connect either to the public CBserver (if configured)
  or to a running local CBserver; if the connection to a running local
  CBserver fails, then attempt to start one in the background.

- *Clear*;: Clear the text of the Telos Editor window

- *Cut, Copy, Paste*;: operations on selected portions of the
  Telos Editor text

- *Tell, Untell*;: The objects specified in the active Telos
  Editor will be added or removed from the object base.

- *Retell*;: A new window will popup and ask you to enter the
  frames that should be untold and told. The contents of the current
  Telos Editor will be inserted as default into the two text
  areas#footnote[The use of the Retell window is a bit cumbersome since
  you need to specify separetely the objects to be untold and the
  objects to be told. If you frequently change only certain attributes
  of objects, then you can use ECArules to instruct the CBserver to
  untell the old attributes and tell the new attributes, see also
  section `sec:cascuntell`.];.

- *Ask*;: Evaluate the query specified in the Telos
  Editor#footnote[The query can either be a query call referring to an
  existing query or a frame representing a new or existing query
  definition.];. If you specify the name of an ordinary class (i.e.~not
  a query class), then ConceptBase.cc will interpret this as a query
  call to find all instances of that class. You can also enter an
  arithmetic expression like \

  #block[
  `100*COUNT(QueryClass)/COUNT(Class)`

  ]

- *List module*;: List the content of the current module as Telos
  frames

- *Exit*;: Disconnect from the CBserver and exit CBIva.

=== The menu bar
<sec:menubar>
The toolbar has button for the most frequent operations of CBIva. The
menu bar offers the complete set of operations including options to open
other windows such as CBGraph (see section `sec:graphed`).

/ File\:: #block[
/ Connect\:: #block[
Connect to a ConceptBase.cc server (CBserver) started in another
shell/command window (see section `cha:cbserver`).
]

/ Disconnect\:: #block[
Disconnect from a CBserver.
]

/ Load & Save Telos Editor\:: #block[
Load or Save the contents of the current Telos Editor.
]

/ Load Model\:: #block[
Load a source model file (\*.sml, \*.sml.txt) to the server. As client
and server are not supposed to share the same file system, this method
is now implemented as a normal Tell method. The client reads the
contents of the file into a string and sends the string to the server.
]

/ Start CBserver\:: #block[
Opens a dialog and asks for the parameters to start a CBserver. If the
information has been entered, the server will be started and its output
will be captured in a separate window. The workbench will be
automatically connected to that server #footnote[This is _not_ the
standard way to start the CBserver. Normally, the CBserver is started in
a separate shell/command window as explained in section `cha:cbserver`.
The standard way offers more options and control over the CBserver. See
also the installation guide for a discussion on the various ways to
start ConceptBase.];.
]

/ Stop CBserver\:: #block[
Stops the CBserver, only allowed for the user who started the server or
who has been designated as administrator user (see option \"-a\" in
section `sec:cbsparams`).
]

/ Close\:: #block[
Same as Exit if CBIva was not started from CBGraph. If it was started
from CBGraph and CBGraph is still running, then the Close option only
hides the CBIva window.
]

/ Exit\:: #block[
Exit CBIva, if a CBGraph windows was opened via CBIva, it shall be
closed as well. Likewise, a CBserver started via CBIva will be closed.
]
]

/ Edit\:: #block[
/ Clear\:: #block[
Clears the text area of the currently activated Telos editor.
]

/ Cut,Copy,Paste\:: #block[
Cut, copy or paste text to/from clipboard.
]

/ Replace all\:: #block[
Replaces all occurences of a given string in the Telos editor by a new
string.
]

/ Tell,Untell\:: #block[
(Un-)Tells the text in the currently activated Telos editor
]

/ Retell\:: #block[
A new window will popup and ask you to enter the frames that should be
untold and told. The contents of the current Telos Editor will be
inserted as default into the two text areas.
]

/ Ask Frame\:: #block[
Temporarily tells the content of the Telos editor, extracts the query
names from the frames, asks them as query calls without parameters, and
returns the result in the Telos editor window
]

/ Ask Query Call\:: #block[
The query calls #footnote[Usually, one only asks a single query call
like `Q[v1/p1]`. However, ConceptBase.cc also supports comma-separated
lists of query calls like `Q1[v1/p1],Q2[c1:p2]`. Such lists of query
calls are evaluated one after the other. The results is merged into a
single answer. For technical reasons, calls to builtin query classes
like `get_object[Class/objname]` may only occur as a singleton.] (see
section `sec:qdefvscalls`) listed in the Telos editor are asked and the
result is returned in the Telos editor window.
]

/ Load Object\:: #block[
Load the Telos frame of an object into the Telos editor.
]
]

/ Browse\:: #block[
/ New Telos Editor\:: #block[
Opens a new Telos editor (see section `sec:telos_ed`).
]

/ Display Instances\:: #block[
Opens the display instances dialog (see section `sec:display_instances`).
]

/ Frame Browser\:: #block[
Opens the frame browser window (see section `sec:frame_browser`).
]

/ Display Queries\:: #block[
Shows the 'visible' (user-defined) queries stored in the current
database and provides a facility to call these queries (see section
`sec:display_queries`).
]

/ Display All Queries\:: #block[
Like above but includes the many built-in queries of ConceptBase.
]

/ Display Functions\:: #block[
Shows all functions stored in the current database (see section
`sec:display_functions`).
]

/ Query Editor\:: #block[
Opens the query editor (see section `sec:query_editor`).
]

/ Graph Editor\:: #block[
Opens the CB Editor (graphical browser, see section `sec:graphed`). If
the interface is connected to a server, CBGraph will also establish a
connection to this server and ask for the graphical palette, the initial
object to be shown, and the module context (see section `sec:module`).
Otherwise, CBGraph will start with no connection.
]
]

/ Options\:: #block[
/ Set Timeout\:: #block[
Set the number of milliseconds the user interface waits for a response
of the server.
]

/ Select Module\:: #block[
Select the current module (see section `sec:module`).
]

/ Select Version\:: #block[
Select or create a new version. A version is a special object that
represents the state of an object base at a specific time. By default,
all queries are evaluated on the current state of the object base
(version \"Now\"). By selecting another version, queries are evaluated
wrt. to a previous state of the object base.
]

/ Pre-Parse Telos Frames\:: #block[
If enabled, the user interface parses the contents of a Telos editor
before it is send to the server. Thus, syntax errors might be already
detected at the client side.
]

/ Show Line Numbers\:: #block[
Enables the display of line numbers in the Telos Editor window. Use
'Save Options' to memorize this setting for the next session of CBIva.
]

/ Use Query Result Window\:: #block[
If enabled, the result of a query is shown in a separate window in a
table view.
]

/ Look and Feel\:: #block[
You can switch the look and feel to an other style. Default is 'FlatLaf
Light'#footnote[Most of the screenshots in this manual were created with
the older 'Metal' look and feel of Java. FlatLaf is a much more modern
look and feel with better font rendition.];.
]

/ Edit Options\:: #block[
Complete and editable list of options for CBIva. The new options are
stored in a file '.CBjavaInterface' of the user home directory.
]
]

/ Help\:: #block[
/ ConceptBase.cc Manual\:: #block[
Opens a window#footnote[A Java window is used to display the manual and
HTML content. The user manual is also provided as a PDF file on the
ConceptBase.cc installation directory.] with the online-version of the
manual.
]

/ ConceptBase Tutorial I/II\:: #block[
Opens a window with the online-version of the respective tutorial.
]

/ CB-Forum\:: #block[
Opens a window to the public version of the ConceptBase Forum with lots
of examples.
]

/ About\:: #block[
Shows a dialog with information about this program.
]

/ License\:: #block[
Displays the license of ConceptBase.cc in a new window.
]

/ CB-Team\:: #block[
Displays a page about the ConceptBase Team.
]
]

/ History\:: #block[
/ Load History\:: #block[
Load previously saved contents of the history window.
]

/ Save History\:: #block[
Save contents of the history window to a file.
]

/ Redo History\:: #block[
Redos certain operations which are currently in the history. The
operations can be selected from a list.
]

/ Set History Options\:: #block[
Select the type of operations that should be displayed in the history
window.
]
]

The preferred way to start a CBserver from CBIva is to use the 'Start
CBserver' from the File menu. It provides an output window for the trace
messages of the CBserver, but this window is only visible if the trace
mode is set to 'minimal' or higher. Disconnecting from the CBserver will
not stop it. It has to be stopped explictly or CBIva will stop it if it
is shut down itself. The 'Quick Connect' button of the toolbar provides
a simplified way to start a local CBserver. It does not ask for CBserver
parameters. Instead, the default values are used for all parameters
except that the server mode is set to 'slave' and multi-user mode is
disabled. This causes the CBserver to shutdown whenever the last
connected client disconnects from it.

You can move the tool bar outside the main window or display it in
vertical form, if you click on the leftmost area of the tool bar and
drag it to another place.

=== The status bar
<the-status-bar>
The status bar contains some fields that display general information
about the status of the application.

- Connection status, either connected or disconnected from serve, or a
  pending action

- Short message, usually about the result of the last action

- Current version, i.e. the rollback time (see section
  `sec:representation`) specified for queries (default: Now)

- Current module, the database module to which TELL/ASK operations are
  applied

- Linked tool, either empty or \"CBGraph\" if CBIva is linked to a
  CBGraph window.

The field for the current version shall display the current time if the
version is set to 'Now'. If set to a rollback time in the past, it
displays both the version name and the time associated to the version.
It will then also hight the background of the text field to make the
user aware that queries are evaluated against a past state of the
database.

The linked tool flag is by default empty. It shall show the toolname
\"CBGraph\" if CBIva started a CBGraph window, or CBGraph has started
the CBIva window. In both cases, the two winodws can interact with each
other, e.g. by selecting an object name in the Telos Editor and adding
it to the CBGraph window, or by selecting a node or link in CBGraph and
displaying it in the CBIva Telos Editor.

=== Telos editor
<sec:telos_ed>
The Telos Editor is an editable text area, where you can edit Telos
frames. The operations can be executed from the menu bar or the buttons
in the tool bar. Furthermore, the text area has a popup menu on the
right mouse button with the following items.

/ Display Instances\:: #block[
Displays the instances of the currently marked object
]

/ Load Object\:: #block[
Loads the Telos frame of the currently marked object into the Telos
editor
]

/ Display in Graph Editor\:: #block[
Shows the currently marked object in CBGraph.
]

/ Change Module\:: #block[
Changes the module context to the module path defined by the currently
marked text
]

/ Clear,Cut,Copy,Paste\:: #block[
same as in the menu bar
]

/ Small,Large\:: #block[
sets the text font size to either small (12 point) or large (18 point)
]

If the Telos editor window is empty, then you can drag and drop Telos
text files (file type \*.sml or \*.sml.txt) into it. CBIva will open the
file and paste the content into the Telos editor window. This function
requires that the option 'Show Line Numbers' is enabled (see section
`sec:menubar`). You can also drag and drop URLs pointing to publicly
accessible Telos text files.

==== Tell transactions
<tell-transactions>
The text in the Telos editor window is typically a sequence of Telos
frames. When you press the 'Tell' button, the text is sent to the
CBserver and processed there by the 'TELL' method of the CBserver. This
is a single transaction which may fail or succeed.

You can use the string \"`{—}`\" in the text window to indicate that the
frames should be told in multiple transactions. Consider the example:

```
Shop in Class end
Guest in Class with
      attribute
            dept: Shop
end

GuestEmployee in Class isA Guest,Employee end
```

Activating the 'Tell' button instructs CBIva to split the text into two
parts and tell them in two separate transactions to the CBserver. This
feature is useful when some parts contain meta formulas (see section
`sec:CCmeta`) that first need to be compiled before they are used in
subsequent parts of the whole text. If you do not use meta formulas,
then you can omit this feature.

=== History window
<sec:history_window>
The history window is part of the main Telos editor. It stores all
operations and their results, so that they can later be used again. The
buttons scroll the history back or forward, copy the text into the Telos
editor or redo the operation in the history window (see figure
`fig:historybuttons`). If the current operation is an "ASK", then a
single click on the copy-button will copy the query to the Telos Editor,
and a double click will copy the result of the query. The size of the
history window can be reduced by using the slider bar between the Telos
editor and the history window.

#figure(image("../assets/historybuttons.pdf", width: 60.0%),
  caption: [
    Buttons of the History Window
  ]
)
<fig:historybuttons>

=== Display instances
<sec:display_instances>
This dialog displays the instances of a class. The class is entered in
the text field. When you hit return or press the "OK" button, the
instances of this class will displayed in the listbox.

If you double click on an item in the listbox, the instances of this
item will be displayed. The frame of a selected item can be loaded into
the Telos editor by clicking the "Telos Editor" button. A history of
already displayed classes is stored in the upper right selection list
box. The "Cancel" button closes the dialog.

=== Frame browser
<sec:frame_browser>
The Frame Browser (see figure `fig:framebrowser`) shows all information
relevant to one object in one window. The window contains several
subwindows with list boxes that show super- and subclasses, the classes,
the instances, attributes and objects refering this object. In the
center of the window, a small window with the object itself is shown. To
view the attributes of the object, you must first select the attribute
category in the subwindow "Attribute Classes".

#figure(image("../assets/framebrowser.png", width: 11cm),
  caption: [
    Frame Browser
  ]
)
<fig:framebrowser>

The Frame Browser can be used with and without a connection to a
CBserver. If it is not connected, it retrieves the information out of a
local cache, which can be loaded from a file by using the "Load" button.
The file has to be plain text file with Telos frames. All objects in the
cache can be saved into a text file as Telos frames with the "Save"
button. The contents of the cache can be viewed with the "Cache" button.
The result of a query can be added to the cache by using the "Add query
result" button.

The button "Telos Editor" inserts the Telos frame of the current object
into the Telos Editor.

=== Display queries
<sec:display_queries>
This dialog displays all visible queries #footnote[Visible queries are
those queries that are not instantiated to the class `HiddenObject`.
Functions and certain system queries are excluded from the display.]
stored in the current object base (see figure `fig:displayqueries`). From
the list box, you can select a query and "ask" it or load its definition
into the Telos editor.

#figure(image("../assets/displayqueries.png", width: 11cm),
  caption: [
    Display queries dialog
  ]
)
<fig:displayqueries>

If you "ask" a generic query class with parameter, another dialog will
ask you to specify the parameters. For each parameter, you can specify
whether the value entered should be used as "substitute" for the
parameter or as a "specialization" of the parameter class (see section
`sec:CBQL`). You can select a value for the parameter from the drop-down
list if you have clicked on the "Show Values" button. Note that this
list might be very long. Especially for the predefined queries it
usually returns all objects in the database as any object can be used as
a parameter for these queries.

=== Display functions
<sec:display_functions>
This dialog is similar to the previous dialog but displays instances of
`Function`. Note that functions are formally special queries.
Consequently, the dialogs for functions and queries are pretty much the
same. The separation into two dialogs serves quicker handling.

=== Query editor
<sec:query_editor>
The Query Editor (see figure `fig:queryeditor`) allows the interactive
definition of queries. The name of the query is entered in the upper
left text field, the super class in the upper right field. After you
have entered this information, the list box "Retrieved Attributes" will
be filled with all available attributes.

Now, you can select the attributes you want to have in the result. For
selection of more than one attribute, you must press the CTRL key and
select the attribute with a mouse click at the same time. All attributes
can be deselected by the popup menu.

#figure(image("../assets/queryeditor.pdf", width: 11cm),
  caption: [
    Query Editor
  ]
)
<fig:queryeditor>

In the right listbox you can add computed attributes. The right mouse
button brings up a popup menu, which lets you add or delete an
attribute.

In the text area below the two list boxes, you can add a constraint in
the usual CBQL syntax. The constraint must be enclosed in \$ signs.

The text area below, shows the Telos definition of the query and is
updated after every change you have made. If your query is finished, you
can press the "Ask query" to test the query, i.e. it is told temporarely
and the results are shown in separate window. If you are satisfied with
the result you can press the Tell button to store the query in the
object base.

=== Tree browser
<sec:tree_browser>
The Tree browser (see figure `fig:frametree`) displays the super classes,
classes and attributes of an object in a tree. To start the tree
browser, you must mark an object in the Telos editor and select the item
"View Object as Tree" from the popup menu or the Edit menu.

#figure(image("../assets/frametree.pdf", width: 9cm),
  caption: [
    Tree Browser
  ]
)
<fig:frametree>

To expand an item, just double click on the icon. If you mark an object
name in the tree, you can load into the Telos editor with the "Telos
Editor" button or open a new tree browser with the button "View Object
as Tree".

== The graph editor CBGraph
<sec:graphed>
The CBGraph Editor is an advanced graphical modelling tool that supports
the browsing and editing of Telos models. It supports user-definable
graphical types, i.e.~objects may be visualized by dedicated graphical
layouts. In addition to predefined graphical types, the user can add
his/her own graphical types by modifying and adding certain objects in
the knowledge base. Furthermore, the standard components can be replaced
by own classes implementing specific application-dependent behaviour.

In the following, we first give an overview of CBGraph application and
then present the main components and functions of CBGraph. Details about
the use of graphical types can be found in Appendix `cha:graph-typen`. An
example for the definition of graphical types of the Entity-Relationship
model is given in Appendix `sec:ER-diagrams`.

=== Overview
<overview>
The CBGraph Editor is entirely written in Java. It can therefore be used
on any platform with Java 1.4 or compatible successors of Java 1.4.
CBGraph is integrated with CBIva, i.e.~Telos frames of objects shown in
CBGraph can be loaded directly into a Telos editor and vice versa.
CBGraph allows to open several 'internal windows' in its main window.
Each internal window has a separate connection to a CBserver. Thus,
within a CBGraph you can establish multiple connections to the same
CBserver or even to different servers.

The communication with the CBserver is done using pre-defined
ConceptBase.cc queries and a special XML-based answer format. CBGraph
requests information about the objects (names, attributes, etc.) but
also about their graphical type.

#figure(image("../assets/overview.png", width: 90.0%),
  caption: [
    CBGraph with three internal windows
  ]
)
<fig:overview>

Figure `fig:overview` gives an overview of the CBGraph Editor. Three
internal windows have been opened, the two windows on the left have been
connected with the same server running on "localhost", port 4001. The
small window in the upper right corner is not connected to a server, but
a few objects have been created. The title of the internal windows
displays the graphical palette and the current module (if connected to a
ConceptBase server) plus the connection status (either 'offline' or the
hostname and portnumber of the ConceptBase server). The content of an
internal window is a graphical view on the database module of the
ConceptBase server it is connected to. It is possible that different
internal windows connect to different ConceptBase servers, though this
is not a typical use of CBGraph. If you start CBGraph from CBIva, then
you can only start a single instance of it. However, you can start any
number of CBGraph instances via the 'cbgraph' command (see below).

The two left internal windows of figure `fig:overview` are connected to
the same server and show the same model but in different
representations. This is caused by the fact, that for the upper window,
the default graphical palette has been chosen, and for the lower window,
a customized graphical palette specifically designed for the ER model
has been selected (see appendix `sec:ER-diagrams` and `cha:graph-typen`).

Furthermore, you can notice that the object "QueryClass" is represented
by two different components. In the upper view, the detailed
_component view_ has been activated by a double-click on the
object. It shows the Telos frame of the object. By a double-click on the
title bar of this component, one can switch back to the default view of
this object. Thus, each object can be shown by a small component (the
default view) and a large component which gives more detailed
information. Components are in this context specific Java objects,
namely instances of javax.swing.JComponent. Thus, different components
can be provided to represent an object (e.g., tables, buttons, text
fields). You can implement your own component and integrate into CBGraph
by extending a specific Java class. Details about the customization of
CBGraph using graphical types and other components can be found in
appendix `cha:graph-typen`.

CBGraph can be used to edit Telos models (see section `sec:graph_edit`).
It can also display implicit relationships between objects, which have
been derived by rules or Telos axioms. For each type of relationship
(instanstation, specializations, and attributes), one can choose to see
only the explicit relationships or to see all relationships.

=== Starting CBGraph via CBIva
<starting-cbgraph-via-cbiva>
CBGraph can be invoked from CBIva via the menu item _Browse_
$arrow.r$ _Graph Editor_;. If CBIva is connected with a CBserver,
CBGraph will be connected to the same server and you will be prompted to
enter the object name you want to start with, the name of a graphical
palette, and the database module. The graphical palette is a Telos
object which represents a set of graphical types which will be used to
visualize Telos objects (see Appendix `cha:graph-typen`). On startup,
CBGraph retrieves all information about the graphical types from the
CBserver. If CBIva has no connection with a server, CBGraph will be
started without a connection and no internal window will be opened
within CBGraph.

The connection to a CBserver can also be established via the File /
Connect menu. The dialog box has two tabs. The first is for providing
the host and port number number of the CBserver. The second is for
providing the start object (default \"Class\") to be displayed, the
graphical palette (pick from a list), and the database module (default
\"oHome\").

The most comfortable way to start CBGraph is to double-click the graph
file. It is equivalent to starting it via the command

```
  cbgraph graph.gel
```

To do so, you need to configure your desktop according to the
instructions at
#link("http://conceptbase.sourceforge.net/CB-Mime.html");.

=== The `cbgraph` command
<sec:cbgraphcmd>
You can also start CBGraph as a stand-alone utility. The command

```
  cbgraph [options]
```

will start an unconnected graph editor. You can interactively connect it
to a running CBserver and open new windows to display graphs. More
interesting is the use with a stored graph file, or several graph files,
resp.:

```
  cbgraph [options] filename [filename ...]
```

The format of the graph file is called Graph Editor Layout (GEL). It
stores not only the layout of nodes and links but all other data
necessary to edit the graph objects. In particular, it contains
connection details of the CBserver module from which the graph was
created. You can open more than one GEL file. Each will be loaded in its
own frame.

The are a few options for the 'cbgraph' command synchronizing the data
stored in the graph file with the CBserver:

/ +r: #block[
With this option CBGraph will be instructed to load the module sources
on its current module path from the CBserver and save it to the graph
file when the 'save' function is enacted. The 'System' module will not
be saved since it is (typically) not changed. For example, if CBGraph
displays objects of module \"System-oHome-M1\", then the save function
will store the module sources of 'oHome' and 'M1' to the graph file. We
say \"CBGraph reads the sources from the CBserver and saves them to the
graph file\". This option disables writing the module sources from the
graph file to the CBserver when CBGraph is started. An exception is
applied when CBGraph needs to start a local CBserver on the fly. Such a
CBserver has an empty database (except system objects) and the module
sources are told to such a fresh CBserver as if the \"+rw\" flag had
been applied.
]

/ +w: #block[
This option enables the reverse direction. It will instruct CBGraph to
extract module sources from the given graph file (or any graph file that
is loaded via CBGraph) and tell them to the CBserver that it is
connected to. You have to start a CBserver as a separate process using
the hostname and port number that is stored in the graph file. This
option disables by default including the module sources to the graph
file when saving the graph file. The CBserver can well have an empty
database because all required user-defined objects are stored as sources
in the graph file. If the database is not empty, the definitions from
the sources are added to the current database. It may well be that the
operation causes an integrity violation or fails because the current
user has no write permission on a given module. In case of success we
say \"CBGraph loads the module sources from the graph file and writes
them to the CBserver\".
]

/ +rw: #block[
Enable bidirectional synchronization (default).
]

/ -rw: #block[
No synchronization.
]

/ +f: #block[
Enable bidirectional synchronization and also write the module sources
to text files in the directory where your started CBGraph; useful for
debugging.
]

If you supply these options when calling CBGraph, it will also store
them in the graph file when you store it. If you later call CBGraph with
such a graph file, it will apply the stored options unless you specify
new options in the command line. Hence, the options stored in the graph
file (file type \".gel\") serve as new defaults for synchronizing the
graph file with the CBserver.

Consider the two calls of CBGraph below. The first call sets the
synchronization option to \"+r\", i.e.~stores the module sources from
the CBserver in the graph file when it is saved. The second call has no
such option. Hence, it shall adopt the \"+r\" that was stored earlier in
the graph file `example.gel`.

```
  cbgraph +r example.gel
  cbgraph example.gel
```

This behavior is useful if you keep the models in a persistent CBserver
and want to use the module sources in the graph file only as a backup
storage. It will then not tell the module sources from the graph file to
the CBserver. The TELL operation can be very costly and is redundant if
the CBserver anyway has all definitions already stored.

If you provide a filename (or several), then it must have been
previously created by another graph editor, e.g.~a graph editor started
via CBIva. The above command will then display the graph stored in the
graph file in an internal window and attempt to connect to the same
CBserver that was active when the graph file was created. Hence, the
graph file is a materialized view on the CBserver database that is
visualized with 'cbgraph'. You edit a graph file with 'cbgraph' like you
are editing a drawing with a drawing tool. The only difference is that
the graph is linked to the database.

If the CBserver module specified in the graph file is not accessible,
the graph is still opened and you can edit it. You can then however not
commit changes to the database or add new objects from the database. The
CBGraph editor displays the connection status in the title of its
internal window containing the graph. The hostname of a CBserver in a
graph file is by default 'localhost'. Consequently, the graph editor
will try to establish a connection to a CBserver running on localhost.
If you want to connect to a remote CBserver, then you should specify in
CBIva the full domain name of the CBserver, e.g. 'myhost.acme.com'. This
long name will then be stored in the graph file that is created from a
graph editor started via CBIva. Such graph files can then be copied to
other computers and can be loaded with CBGraph to auto-connect to the
remote CBserver specified in the graph file, provided that CBserver is
running and accessible.

If no CBserver is accessible, CBGraph will attempt to start a local
CBserver in the background provided that the graph file specifies
\"localhost\" as hostname and the graph file contains module sources. In
other cases, CBGraph switches to the offline mode. You can still change
location and size of the graphical elements and store it back to the
graph file. But you cannot delete objects and you cannot add objects to
the database. The menus to show attributes, instances, and subclasses
shall also not work.

An example on how to create and use graph files containing materialized
database views is available in the CB-Forum at
#link("http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/3613919");.

There are further command line options to control the bahavior of
CBGraph:

/ -demo: #block[
Disables certain menu items such as File/Save to make CBGraph more
stable in demonstration scenarios.
]

/ -resync: #block[
Loads the graph file, connects to the CBserver, then saves the graph
file using the sources from the CBserver, and exits CBGraph. This option
can be used to refresh the sources of a graph file with the module
contents of a running CBserver. In particular, this is useful in
combination with the option +r.
]

/ -revalidate: #block[
Instructs CBGraph to validate the nodes and links of the graph file upon
start of CBGraph. Note that invalid nodes and links may be marked and
may have to be removed/corrected manually. The validation procedure is
the same as the \"validate and update shown objects\" option in the
\"Current connection\" menu of CBGraph, see section
`sec:currentconnection`.
]

/ -savepng: #block[
Will instruct CBGraph to save the current graph as PNG file in the same
directory as the graph file when closing CBGraph.
]

/ -savesvg: #block[
Similar to \"savepng\" but rather stores the current graph as SVG file.
]

The options can be combined to achieve the desired bahavior, e.g.~

```
cbgraph -resync -savepng -revalidate +r myfile.gel
```

The \"resync\" option together with \"+r\" will make sure that the
module sources to be stored in the graph file are taken from the
CBserver. It will also terminate CBGraph after execiting the
synchronization in order to allow bulk synchronizations of many graph
files that are all views of the same database. Note that you should
start the CBserver before executing the above cbgraph command.

The \"savepng\" option will store the PNG image of the current graph
when exiting CBGraph. The \"revalidate\" option will check whether the
nodes and links in the graph file are still in the database and may
update their graphical type, if the database assigns a new graphical
type to them.

=== Redirecting the CBserver location
<redirecting-the-cbserver-location>
You can use the command line argument '-host' to override the hostname
and portnumber encoded in the graph file. Assume a graph file
'graph1.gel' was created from a a CBserver connection at
'localhost:4001'. Then, loading this graph file in a subsequent call
will also connect to 'localhost:4001'. If you want to use another
CBserver, e.g.~running on 'myhost.acme.com:4002', then call CBGraph from
the command line as follows:

```
  cbgraph +rw -host myhost.acme.com:4002 graph1.gel
```

Note that the CBserver must be running at the remote location before you
enter the above command. When you subsequently save the graph file, it
will have 'myhost.acme.com:4002' encoded as its connection. The
redirection also works in the reverse direction. So, assume that the
graph file 'graph2.gel' was created for a connection at
'myhost.acme.com:4002'. Then, the following command will redirect the
connection to localhost:

```
  cbgraph +rw -host localhost graph2.gel
```

The default port number is 4001. If no CBserver is running at
'localhost:4001', then CBGraph shall start it in the background. Note
that local CBservers can currently only be started on Linux hosts.

=== Moving objects
<sec:moveobj>
All explicit information is a proposition in ConceptBase (see section
`sec:representation`), including attributes, specializations and
instantiations. You can move objects in the graph editor by pointing the
cursor to the object's label and then dragging it while keeping the left
mouse button pressed. If a graph has many nodes and edges, then it is
recommended to first click once on the node or edge to be dragged and
then to drag it. This will switch off the anti-aliasing while dragging
and thus be faster.

You may also want to select a group of objects and then move it as a
whole. To do so either span a selection box with the left mouse button
around the object to be selected, or press the \"shift\" key and select
multiple objects individually. After a move, CBGraph shall redraw
dependent edges that might be misplaced.

Some edges like instantiation links have no label in CBGraph, depending
on the graphical type associated to it (see appendix `cha:graph-typen`).
In such cases, a small square dot is displayed on the edge. Click on
this square dot to select the edge and to drag it. If the edge has a
background color (see appendix `cha:graph-typen`) different from the edge
color, then the square dot is drawn in the background color.

Moving nodes and edges can sometimes lead to quite messy edge curves
where the edge middle point is distant from the middle of the straight
line between the source and destination of the edge. You can clean up
such graphs by pressing the \"shift\" and \"control\" keys together and
then click on a node whose edges shall be straightened.

=== Menu bar
<menu-bar>
The menu bar provides access to the most important functions of CBGraph.

==== File menu
<file-menu>
/ Connect to server\:: #block[
Connect to a new server. You can have multiple connections to one server
or different servers at the same time. Each connection will be
represented in one internal window with the graphical palette, database
module, host name and port number in the title bar of the window. The
connection dialog consists of two tabbed panes. In the first one
(Address), you can enter the host address (name or IP number) and the
port number. In the second pane (Initial Object), you can specify the
initial object to start the browsing process, the graphical palette, and
the database module.
]

/ Start CBIva Workbench\:: #block[
Start a CB workbench (aka CBIva). If you started CBGraph directly or if
you have already closed the workbench window, you can (re-)start the
workbench by this menu item. If connected to a CBserver, the new CBIva
will list the content of the current module in its Telos editor window.
]

/ Save\:: #block[
Save the current graph into a file. The current nodes, their location
and the links will be saved into a file which can be reloaded later. The
graphical types will also be saved into the file. The file will get the
extension "gel" (Graph Editor Layout). A checkbox lets to select whether
you want to save the module sources into the graph file. It overrides
the '+/-rw' options of the cbgraph command#footnote[If the original
module path came from a graph file, then ConceptBase will check whether
the current module path of CBGraph contains the original module path. If
not, you cannot save the graph file since it would be corrupted
otherwise.];.
]

/ Load\:: #block[
Load a graph that has been saved with the previous menu item. Existing
nodes and links in the current window will be erased. If the graph file
was previously created to include module sources, then the module
sources are told to the CBserver before the graph is
displayed#footnote[If you load a graph file that was created with
different graphical types than the ones defined in the CBserver module
that CBGraph might be connected to, then the graph file is inconsistent
with the current CBserver module. You may be able to repair the
inconsistency via the menu option Current connection / change graphical
palette. Likewise, some objects displayed in the graph could be
undefined in the database. You can validate them by one of the
validation tabs in the menu \"Current connection\".];. A checkbox lets
to select whether you want to load the module sources from the graph
file and tell them to the CBserver.
]

/ Print\:: #block[
Print the current graph. If the graph is larger than the page size, it
will be automatically reduced to fit into the page. Thus, all printouts
will be on one page.
]

/ Export image of graph\:: #block[
Exports an image of the current graph as bitmap (e.g. PNG) or vector
graphics (SVG) file. The PNG file type is the default. You can choose
wether whole diagram (=the rectangle containing all nodes and edges) is
exported or only the visible part of the diagram canvas. The export
function can also be applied to zoomed graphs.
]

/ Close\:: #block[
Closes CBGraph. A CBIva window will be still available if it has not
been closed before.
]

/ Exit\:: #block[
Exit CBGraph and CBIva. This operation will close both windows of the
ConceptBase.cc User Interface (CBIva), if they were started in
combination, and exit the program.
]

If the graph was loaded from a GEL file and it was edited in the
session, CBGraph shall ask the user whether to save the edited graph to
the file when the user terminates CBGraph.

==== Edit menu
<edit-menu>
The operations in this menu have an effect on the selected objects. You
can select an object by clicking on it with the left mouse button.
Multiple selection is possible dragging a rectangular area while holding
down the left mouse button or by holding the Shift-key and clicking on
objects.

/ Erase Selected\:: #block[
This option will remove the currently selected nodes and edges from the
view. This operation has no effect on the database.
]

/ Selection\:: #block[
With this submenu, you can either select all objects, all nodes or all
edges in the current frame. Furthermore, you can clear your current
selection.
]

==== Options menu
<sec:optionsmenu>
The options will be stored in a configuration file (see section
`sec:config`) when you exit CBGraph.

/ Language\:: #block[
The text for menu items and buttons is available in two languages
(German and English). With this option you can switch between the
languages. This option is currently without function. All menu labels
are set to English.
]

/ Background Color\:: #block[
Here you can change the background color of the graph to your favorite
color.
]

/ Component View\:: #block[
With this option, you can configure the view of an object if the
component view is activated by a double click or by the popup menu. By
default, a tree-like representation of the object with its classes,
instances, super classes, subclasses, outgoing and incoming attributes
is used. If you select "Frame", then the Telos frame of the object will
be shown in a text area, (see figure `fig:componentview`).
]

/ Invalid Telos Objects\:: #block[
CBGraph can validate objects that are currently shown in the graph,
i.e.~it checks whether the object is still valid in the database or it
is has already been removed (see Current Connection menu). If you select
"Mark" here, then the objects will be marked with a red cross as
invalid. "Remove from display instantly" will remove the objects
directly from the view.
]

/ Popup Menu\:: #block[
These options control the behaviour of the Popup Menu (see section
`sec:graphed`:PopupMenu). The delay is the time (in milliseconds) an item
of the popup menu has to be selected before the submenu is shown. Note
that the construction of a submenu might require a query to the
CBserver. If the option _"Popup Menu blocks while waiting for
server"_ is activated, then the editor will block the UI while it waits
for an answer of the CBserver. Otherwise, the query to the server will
be executed in a separate thread, and interaction with the UI will be
possible. If you have the problem that some submenus are still shown
after you have used the popup menu, set the delay to 0 and activate the
option _"Popup Menu blocks while waiting for server"_;.
]

/ Look & Feel\:: #block[
This option allows you to adapt the look and feel of CBGraph windows to
your desktop environment. By default, the 'FlatLaf Light' look and feel
is enabled. CBGraph is not yet compatible with all Java look and feels.
We thus recommend to stick to the default.
]

/ Enable Click Actions\:: #block[
Click actions automatically trigger an active rule (see section
`sec:eca`) when nodes with a certain graph type are pressed (see section
`sec:clickactions`). You can enable and disable this feature. If you want
to move nodes inside a graph that has nodes with click actions, then you
may want to disable click actions until you have fnished the
re-arrangement of nodes.
]

/ Enable Derived Links\:: #block[
By default, CBGraph can display derived links/relations to and from a
given object. If the database is large and the rules are complex, this
feature becomes almost unusable due to long delays. In such case,
disable the display of derived links. The behavior of CBGraph is then
different wrt.~the pop menu displayed when right-clicking on a node or
link. It would show all possible attribute categories rather than only
the used ones. For technical reasons, a change in this flag becomes only
effective after re-starting CBGraph.
]

/ Set Link Category\:: #block[
Allows to set a category to be used for the toolbar button \"Show links
between marked objects\". The default category is taken from the
Configuration file variable \"ShowLinkCategory\". This is normally set
to \"Proposition\". You can set the category to \"Attribute\", if you
only want to show links that are attributes or relations. Use
\"InstanceOf\" for displaying only instantiation relations, and \"IsA\"
for specialization relations. You can also select a model-specific
category such as \"Product!partOf\".
]

#figure(image("../assets/componentview.png", width: 9cm),
  caption: [
    Component view (frame) of Telos objects frame
  ]
)
<fig:componentview>

If an object is displayed in component view, one can switch back to the
node view by double-clicking its title section. Note that the component
view can be disabled via the configuration file entry \"ComponentView\".
See also section `sec:config`.

==== View menu
<view-menu>
CBGraph has an experimental layout algorithm that may be useful to
reorganize the layout of a complex graph. The heuristic of the layout
algorithm is rather simple and does not minimize link crossings.

/ Enable automatic layout\:: #block[
Call a layout algorithm everytime the graph is changed, e.g. by
expanding the attributes. Disabled by default. Enabling it is not
recommended.
]

/ Undo last layout operation\:: #block[
Undo the last change of the graphical layout. This option is only
available when automatic layout is enabled.
]

/ Layout graph\:: #block[
Call the layout algorithm.
]

/ Zoom\:: #block[
Set the zoom factor of the graph, e.g. 120 (20 percent enlarged).
]

/ 400,200,125,100,75,50,25\:: #block[
Set the zoom factor accordingly. Note that resizing diagram nodes is
only possible at zoom factor 100 percent.
]

==== Current connection menu
<sec:currentconnection>
These operations have effect on the current connection, i.e. the
connection of currently activated internal window.

/ Query to server\:: #block[
This operation will open a dialog which prompts you to enter the name of
a query (see figure `fig:querytoserver`). The query can also be
parameterized. If you click on the "Submit Query" button, the query will
be sent to the server and the result will be displayed in the listbox.
You can select the objects that should be added to the graph. Selection
of multiple objects is possible.
]

/ Validate and update shown objects\:: #block[
This operation will check for every object, if it is still valid (i.e.
if it still exists in the database), update the graphical type of the
object, and the internal cache of the object is deleted (see below,
section `sec:graphed_cache`). Depending on the option "Invalid Telos
Objects" (see above), the objects will be either marked or removed from
the current view.
]

/ Validate and update selected objects\:: #block[
Similar to the previous option but is only applied to objects in the
graphical view that have been selected.
]

/ Change graphical palette\:: #block[
The current graphical palette (=assignment of graphical types to nodes
and links) is replaced by another one.
]

/ Change module\:: #block[
Change the database module for the currently active internal window.
]

#figure(image("../assets/querytoserver.png", width: 6cm),
  caption: [
    Query dialog
  ]
)
<fig:querytoserver>

=== Tool bar
<tool-bar>
The tool bar (see figure `fig:graphed_toolbar`) consists of a set of
buttons that are mainly short cuts for some menu items. The right half
of the tool bar provides buttons for the creation of Telos objects.

#figure(image("../assets/graphed_toolbar.png"),
  caption: [
    Tool Bar of CBGraph
  ]
)
<fig:graphed_toolbar>

/ Open a new frame (without connection)\:: #block[
Opens a new internal window without a connection to a server. Within
this internal window, you can create new Telos objects, load existing
layouts and save new layouts. Information about the graphical types is
loaded from an XML file included in the JAR file \
(``CB_HOME`/lib/classes/cb.jar`).
]

/ Load graph\:: #block[
see _File Menu_ $arrow.r$ _Load_
]

/ Save graph\:: #block[
see _File Menu_ $arrow.r$ _Save_
]

/ Hide selected objects\:: #block[
Hides the selected objects from the current view. This operation has no
effect on the current database, i.e.~the objects will be not deleted
from the database.
]

/ Open connection\:: #block[
Opens a new internal window with a new connection to a server. See
_File menu_ $arrow.r$ _Connect to server_;.
]

/ Show object\:: #block[
This operation adds an object defined in the database to the graph. You
will be prompted to enter the object name of the object you want to add
to the graph.
]

/ Show links between marked objects\:: #block[
This operation will search for relationships between the selected
objects. Do not select too many objects for this operation, $n^2$
queries have to be evaluated for $n$ objects. The option \"Set Link
Category\" in the menu bar allows to constrain the link type, e.g.
\"InstanceOf\" for just showing instantiation relations.
]

/ Creation of objects\:: #block[
The following four buttons open the "Create Object" dialog to create new
individual objects, attributes, instantiations, and specializations. See
section `sec:graph_edit` for more details.
]

/ Show added/removed objects\:: #block[
Shows the objects that have been added or removed since the last commit
(or since the window has been opened). Here, you can also select objects
to undo the change, i.e. remove added objects or re-insert removed
objects.
]

/ Commit\:: #block[
Sends the changes to the server. The list of objects to be added or
removed is transformed into a set of Telos frames and transferred to the
server. This button is highlighted when some change (added or removed
object) can be committed.
]

=== Popup menu
<sec:graphed:PopupMenu>
The popup menu is activated by a click on the right mouse while the
cursor is located over an object.

- *Toggle component view:* \
  switches the view of this object. In the detailed component view, you
  can either see the frame of this object or tree-like representation of
  super- and subclasses, instances, classes, and attributes of this
  object (see figure `fig:componentview`).

- *Display in Telos Editor:* \
  This operation will load the frame of the object into the Telos
  editor. If the Telos editor contains already some text, then the frame
  is appended to the existing text.

- *Super classes, sub classes, classes, instances:* \
  for each menu item you can select whether you want to see only the
  explicitly defined super classes (or sub classes, etc.) or all super
  classes including all implicit relationships. The query to the
  CBserver to retrieve this information will be done when you select the
  menu item. So, the construction of the corresponding submenu might
  take a few seconds.

- *Incoming and outgoing attributes:* \
  CBGraph will ask the CBserver for the attribute classes that apply to
  this object. For each attribute class, it is possible to display only
  explicit attributes or all attributes as above. The attribute class
  "Attribute" applies for every object and all attributes are in this
  class. Therefore, all explicit attributes of an object will be visible
  in this category. However, there will be no attributes shown in the
  "All" submenu, as it would take too much time to compute the extension
  of all implicit attributes.

- *Add Instance, Class, SuperClass, SubClass, Attribute,
  Individual:* \
  These menu items will open the "Create Object" dialog where you can
  specify new objects that should be created in the database. Note, that
  these modifications are not performed directly on the database. The
  editor will collect all modifications and send them to the CBserver
  when you click on the "Commit" button. See section `sec:graph_edit` for
  more details.

- *Delete object from database:* \
  This operation will delete the object from the database. As for the
  insertion of objects before, the modification will be send to the
  server when you click on the "Commit" button. Note that this operation
  has an effect on the database in contrast to the next operation.

- *Hide object from view:* \
  The object will be removed from the current view. This operation has
  no effect on the database, i.e.~the object will not be deleted from
  the database.

- *Show in new Frame:* \
  A new internal window (within CBGraph) will be shown and the selected
  object will be shown in the new window.

- *Straighten attached edges:* \
  All edges starting from and ending in the selected node are made
  straight and the edge labels move to the middle of the edge. This is
  the same function as described in section `sec:moveobj`.

- *Freeze / Unfreeze:* \
  The position of the selected object is frozen (if not yet frozen). A
  \"frozen\" object cannot be moved or double-clicked. To unfreeze,
  select this menu option again on the frozen object. The function is
  useful when certain objects should not be moved, e.g.~when they are
  serving as regions, in which other objects are positioned.

=== Editing of Telos objects
<sec:graph_edit>
CBGraph supports also the creation and deletion of Telos objects. A
Telos object in the context of CBGraph is a _proposition_ as
described in chapter `cap:language`. As described there, there are four
types of Telos objects:

- Individuals,

- Instantiations (InstanceOf),

- Specializations (IsA), and

- Attributes.

#figure(image("../assets/createobject.png", width: 80.0%),
  caption: [
    Create Object dialogs for Individuals, Attributes, Instantiations,
    and Specializations
  ]
)
<fig:createobject>

For each object type, we provide a dialog to create this object type as
shown in figure `fig:createobject`. This dialog is opened by clicking on
one of the "Create" buttons in the tool bar, or by selecting an "Add
..." item from the popup menu (e.g, "Add instance" or "Add subclass").
If there are some objects selected in the current internal window, then
the object names of these objects will be inserted into the text fields
of the dialog in the order they have been selected (i.e., the first text
field will contain the name of the object which has been selected
first). Furthermore, if you move the cursor into a text field in the
"Create Object" dialog and select an object in the graph, then the name
of this object will be inserted into the text field.

As changes might lead to a temporary inconsistent state of the database,
we do not execute the changes directly on the database. They are stored
in an internal buffer in CBGraph and executed when you hit the "Commit"
button in the tool bar.

/ Creating Individuals\:: #block[
If you want to create a new individual object, you just have to specify
the object name. You have to enter a valid Telos object name, for
example it must not contain spaces. In addition, you can select a
graphical type for the object. Note that the selection of the graphical
type has no effect in the database, e.g. by selecting the graphical type
of a class (`ClassGT`) the object will not declared as an instance of
`Class`. If you have performed the commit operation, the object will get
the "correct" graphical type from the server.
]

/ Creating Instantiations\:: #block[
In the dialog for instantiations, you have to enter the name of the
instance and the name of the class in the two text fields. If the object
entered does not yet exist, it will be created and represented in the
default graphical type.
]

/ Creating Specializations\:: #block[
This dialog is similar to the one before except that you specify here
the name of the subclass and the name of the superclass. Objects that do
not exist yet, will be created and represented in the default graphical
type.
]

/ Creating Attributes\:: #block[
This is the most complex dialog as you have to specify the source, the
label, the value, and the category of the attribute. The source and the
value (or destination) of the attribute are normal object names. The
label may be any valid Telos label. The attribute category has to be a
select expression specifying an attribute category (e.g.,
`Employee!salary`, see chapter `cap:language`). The attribute category
can be selected from a listbox by clicking on the "Select" button next
to the text field of the attribute category. All attribute categories
that apply to the current source of the attribute will be shown. Note
that the list will be empty if the source object does not yet exist in
the database.

If you have specified the attribute category, you can also select the
attribute value from a listbox by clicking on the "Select" button next
to the text field for the attribute value. The listbox will show all
instances of the destination of the attribute category (e.g. all
instances of `Department` for the category `Employee!dept`).

If you select the radio button "Show Attribute Instantiation" then
CBGraph will also show the instantiation link for the attribute. For
example, if you create a new attribute for `John` with the label
`JohnsDept` in the attribute category `Employee!dept`, then the
instantiation link between `John!JohnsDept` and `Employee!dept` will
also be shown. As the graph gets quite confusing with too many links,
this radio button is not selected by default.
]

Deletion of objects is also possible. As this operation should not be
mixed up with the removal of an object from the current view, this
operation is just available from the popup menu (item "Delete Object
from Database").

As you might make mistakes while editing the model, there is the
possibility of undoing changes. The button "Show added/removed objects"
list all objects that have been added or removed (since the last
succesful commit or since the connection has been established). A
screenshot of the dialog is shown in figure `fig:graphed_addremove`. The
left list shows the objects that have been added, the right list shows
the objects that have been removed. By clicking on the button
"Re-Insert/Delete" object, the selected objects will be re-inserted in
or deleted from the graph #footnote[You can unselect an object by
holding down the Control key and clicking on the object.];.

#figure(image("../assets/graphed_addremove.png", width: 7cm),
  caption: [
    List of objects which have been added or removed
  ]
)
<fig:graphed_addremove>

If you are satisfied with the changes you have done, you can click on
the "Commit" button. Then, CBGraph will transform the objects to be
added or removed into a list of Telos frames and send them to the server
using the TELL, UNTELL, or RETELL operation. If the operation was
successful, all _explicit_ objects will be checked if they are
still valid and if their graphical type has changed (as in the "Validate
and update" operation from the "Current Connection" menu). If there is
an error, the error messages of the server will be displayed in a
message box. The internal buffer with the objects to add or remove will
be not changed in this case.

=== Caching of query results within CBGraph
<sec:graphed_cache>
To improve the performance of CBGraph, several caches are used. On the
other hand, the use of a cache causes several problems which will be
addressed in this section. In particular, the caches of CBGraph are not
updated automatically if the corresponding data in the server is
updated.

/ Graphical Palette and Graphical Types\:: #block[
When a connection to a server is established, CBGraph loads the
graphical palette and all its graphical types including their properties
and other information. If an object has to be shown, the server sends
only the name of the graphical type, the information about the
properties are taken from the cache. Thus, if you change the graphical
palette or a graphical type after CBGraph has established the
connection, this change will not be visible in CBGraph. There is
currently no method implemented to update the cache manually.
]

/ Graphical Types of Objects\:: #block[
When an object is loaded from the server also the graphical type for
this object is retrieved. The graphical type of the object is updated
when you invoke the "Validate and Update" operation from the "Current
Connection" menu.
]

/ Lists of super/sub classes, classes/instances, attributes\:: #block[
The lists in the popup menu or in the tree-like view of an object are
produced by evaluating queries. To reduce the communication between
client and server, each query will only be evaluated once (when the
corresponding popup menu should be shown or when the part of the tree
should be shown). The result will be stored in a cache for each object.
This cache is emptied when you invoke the "Validate and Update"
operation from the "Current Connection" menu.
]

=== Graph files
<sec:gel>
Graph files (extension 'gel') are binary files that store the current
state of a graph displayed in CBGraph. Since they are constructed from a
ConceptBase database, they are a (materialized) view on the database.
The view consists of the nodes and links displayed in the window, their
positions, their graphical types, the hostname, portnumber and module
from which the graph was created, the size of the window, its background
color and image, and the window's zoom factor. You can thus save the
current state of your graphical view in the _gel_ file and load it
in a subsequent session with CBGraph to continue editing it, much like
with a drawing tool.

The graph file stores serialized Java objects in the following sequence

```
   String title of the internal frame
   Dimension size of the graph editor
   Dimension size of the internal window
   Dimension size of the drawing area of the internal window
   Integer number of nodes (incl. edge objects)

Since edges are also objects in Telos, the nodes stored in the graph file 
include the edge node that represents the edge itself.
The graph file stores complex information about the nodes including
the graphical types of the nodes, their dimension and location.
By default, the graph files stores the Telos module sources needed to manipulate
the graph. The graph file stores the sources of all modules that are on the path
from the root module {\tt System} to the current module (the module that is active when
the graph file is saved). The module {\tt System} is not saved since it is typically
not updated. Note that ConceptBase database can include a tree of module
(see section \ref{sec:nested_modules}).
Hence, a graph file does in general not store the Telos sources of the complete
database. If you create graph files for all leave modules of a database, then
the combination of the graph files is completely containing the database as sources models.
The extraction of Telos sources uses the builtin query {\tt listModule}
(see section \ref{sec:module_content}). This is in most cases a faithful listing. However,
there are rare cases when the extracted cannot be told to a CBserver.
For example, if a module contains deductive rules that are essential for
satisfying integrity constraints for objects defined in the same module, then
a single TELL operation could fail bacause ConceptBase requires the deductive rules to
be compiled. See section \ref{sec:listmod} for more details.

If you specified command line parameters like "+r", "-r", "+rw", or "-rw" at the start of CBGraph,
then these parameters are stored in the GEL file.

The background image is not stored as a serializable Java object but as a PNG
image using the ImageIO class of Java. It is always stored as the last element since
the input routines shall read it until the end of the file.
Note that some strings can be just null.


\section{An example session with ConceptBase}
\label{sec:session}


In this section we demonstrate the usage of the {\em ConceptBase.cc User Interface}, by involving an example model. It consists of a few classes
including {\tt Employee, Department, Manager}. The class {\tt
Employee} has the attributes {\tt name, salary, dept, and boss}. In
order to create an instance of {\tt Employee} one may specify the
attributes {\tt salary, name,  and dept}. The attribute {\tt boss}
will be computed by the system using the {\tt bossrule}. There is also a
constraint which must be satisfied by all instances of the class {\tt
Employee} which specifies that no employee may earn more money than its
boss. The Telos notation for this model is given in Appendix
\ref{sec:employee-model}.


\subsection{Starting ConceptBase}


To start a {\em ConceptBase} session, we use two terminal windows, one for the {\em ConceptBase.cc}
server and one for the usage environment. We start the {\em ConceptBase.cc} server
by typing the command 
\begin{verbatim}
   cbserver -port 4001 -d test  
```

in a terminal window of, let us say machine alpha #footnote[A full list
of all parameters is described in section `cha:cbserver`. Note that the
script `CBserver` must be in the search path. It is available in the
subdirectory `bin` of your ConceptBase.cc installation directory.] . The
parameter -port sets the port number under which the CBserver
communicates to clients and the parameter -d specifies the name of the
directory into which the CBserver internally stores objects
persistently. Then, we start the usage environment with the command
`cbiva` in the other window.

It is also possible to start the CBserver from the user interface. To do
so, choose "Start CBserver" from the "File Menu" of CBIva (see section
`sec:menubar`) and specify the parameters in the dialog which will be
shown (see figure `fig:startserver`). The option `Source Mode` controls
whether the CBserver accessing the database via the `-d` parameter
(database maintained in binary files), or via the `-db` parameter
(database maintained both in binary files and in source files). See
section `cha:cbserver` for more details. Once the information has been
entered via the OK button, the server process will be started and its
output will be captured in a window. This output window provides also a
button stop the server. If you started the server this way then you can
skip the next section, as the user interface will be connected to the
server automatically.

#figure(image("../assets/startserver.png", width: 90.0%),
  caption: [
    Start CBserver dialog and CBserver output window
  ]
)
<fig:startserver>

=== Connecting CBIva to another CBserver
<connecting-cbiva-to-another-cbserver>
By default, CBIva will automatically connect to a local or public
CBserver when started. If you want to start a CBserver with dedicated
parameters from CBNIva, then first select *File/Disconnect* and
then establish a new connection between the _ConceptBase.cc_ server
and the user client CBIva. This is done by choosing the option
*Connect* from the File menu of CBIva. An interaction window
appears (see Figure `fig:connectserver`) querying for the host name and
the port number of the server (i.e. the number we have specified within
the command `cbserver -port 4001 -d test`).

#figure(image("../assets/connectserver.png", width: 3cm),
  caption: [
    The connect-to-server dialog
  ]
)
<fig:connectserver>

=== Loading objects from external files
<loading-objects-from-external-files>
The objects manipulated by _ConceptBase.cc_ are persistently stored
in a collection of external files, which reside in a directory called
*application* or *database* #footnote[Historically, we
used the terms 'application' or 'object base' instead 'database'. We now
believe that 'database' is a much better term.] . The actual directory
name of the database is supplied as the -d parameter of the command
` CBserver`.

The -u parameter of the `CBserver` specifies whether updates are made
persistent or are just kept in system memory temporarily. Use
`-u persistent` for a update persistence or `-u nonpersistent` for a non
persistent update mode #footnote[In nonpersistent update mode, the
database is actually copied to a temporary directory. This copy will be
removed when you shutdown the server.];.

The database can be modified interactively using the editor commands
TELL/UNTELL. Another way of extending ConceptBase.cc databases is to
load Telos objects (expressed in frame syntax) stored in plain text
files with the extension \*.sml. Call the menu item *Load Model*
from the *File Menu* to add these objects to the database. In our
example the database (directory) Employee was built interactively and
can be found together with files containing the frames constituting the
example in the directory

#block[
_CB\_HOME_;`/examples/QUERIES`

]
where you have to replace _CB\_HOME_ with the _ConceptBase_
installation directory. The following files contain the objects of the
Employee example expressed in frame syntax:
`Employee_Classes.sml, Employee_Instances.sml, Employee_Queries.sml`. An
alternative to interactively building a database is to start the server
with an empty database (`-d `$angle.l$`newfile`$angle.r$) and then add
the objects in these files by using *Load Model*;. Note, that the
\*.sml extension may be omitted. During the load operation of external
models, _ConceptBase_ checks for syntactical and semantical
correctness and reports all errors to the history window as it is done
when updating the object base interactively using the editor. This
protocol field collects all operations and errors reported since the
beginning of the session.

=== Displaying objects
<displaying-objects>
To display all instances of an object, e.g. the class `Employee`, we
invoke the Display Instance facility by selecting the item
*Display Instances* from the menu bar. In the interaction window
we specify `Employee` as object name. The instances of the class
`Employee` are then displayed (see Figure `fig:session_display`).

#figure(image("../assets/session_display.png", width: 7cm),
  caption: [
    Display of `Employee` instances
  ]
)
<fig:session_display>

After selecting a displayed instance we can load the frame
representation of an instance to the Telos Editor or display further
instances.

=== Browsing objects
<browsing-objects>
The _Graph Editor_ is the preferred tool for browsing the objects
managed by a CBserver. CBGraph is started by using the menu item "Graph
Editor" from the "Browse" menu of CBIva. Select `Employee` as the
initial object to be shown in CBGraph. After starting CBGraph, it will
open an internal frame, connect it with the current server, and load the
`Employee` object.

The _CBGraph Editor_ (described in detail in section `sec:graphed`)
allows you to display arbitrary objects from the current onceptBase
server. Then, we select the `Employee` object and choose the *Sub
classes* option from the context menu available via the right
mouse-button. We choose to only display explicit subclasses from the
submenu and select the `Manager` object. The displayed graph is now
expanded (figure `fig:graph_empl`).

#figure(image("../assets/graph_empl.png", width: 30.0%),
  caption: [
    The resulting graph after expanding the node `Employee` with
    subclasses
  ]
)
<fig:graph_empl>

Now we expand the node `Manager`, a subclass of `Employee`, by choosing
the menu item *Instances* from the popup menu for Manager. We
select the menu item "Show all" to display all instances of `Manager`.
The resulting graph is shown in figure `fig:graph_man`.

#figure(image("../assets/graph_man.png", width: 90.0%),
  caption: [
    The resulting graph after expanding with the instances of `Manager`
  ]
)
<fig:graph_man>

Note that different object types are represented by different graphical
objects. The instances of `Manager` are shown only as grey rectangles,
because they are normal individual objects. The nodes
`Manager, Salesman, Employee` etc. are shown as ovals, since these nodes
are instances of the system class `SimpleClass` (see for a full
description of graphical object semantics: Appendix `cha:graph-typen`).

One can move nodes and links by selecting a node or a link and then
holding down the left mouse button while moving the cursor to a
different position. When the button is released the selected object will
be located at the current position and the related links are
redisplayed. Selection and movement of multiple nodes and links is also
possible. Nodes and linkes are selected by clicking on its label, e.g.
`Manager` in figure `fig:graph_man`. Some links like the blue
specialization link in the figure have no label. Then one can select the
link by clicking on the small square dot in the middle of the link. This
square dot is by default invisible. It becomes visible when you click on
any other node or link label in the graph, e.g. on `Manager`.

We can further experiment with CBGraph by showing the classes and
attributes of Employee. The classes of Employee are shown by selecting
"Instance of" from the popup menu. Attributes of an object can be shown
by selecting "Outgoing attributes" from the menu. The next submenu will
show all attribute classes that apply for the current object. In our
example, `Employee` is an instance of `Class`. Therefore, it has the
attribute classes `constraint`, `rule`, and `mrule` (see figure
`fig:graph_super`). The attribute class `Attribute` applies to all
objects as in Telos any kind of object can have an attribute.
Furthermore, all attributes of an object are member of the attribute
class `Attribute`. As we want to see all attributes, we select this
attribute class and select "Show all" from the next submenu. All
attributes and their values will be shown in CBGraph.

#figure(image("../assets/graph_super.png", width: 90.0%),
  caption: [
    The graph after expanding it with the classes and the attributes of
    the class `Employee`
  ]
)
<fig:graph_super>

CBGraph can also show implicit relationships between objects, e.g.
relationships deduced by rules or the Telos axioms. For example, if we
select the object `John` and select "Instance of" from the popup menu,
we can display the implicit classes of `John` by selecting "All" from
the next submenu. As `John` is an instance of `Manager` and `Manager` is
a subclass of `Employee`, `John` is also an instance of `Employee`. As
there is no explicit object `John->Employee`, the instantiation link
between `John` and `Employee` will be represented as an implicit link,
i.e. a dashed line (see figure `fig:graph_impl`).

The same applies also to attribute links. For example, the employee
`Herbert` has an implicit `boss`-attribute to `Phil`. This can be shown
by selecting "Outgoing attributes" $arrow.r$ "boss" $arrow.r$ "All"
$arrow.r$ "Phil" from the popup menu. Note, that the submenu "All" for
the attribute class `Attribute` will be always empty as only explicit
attributes can be displayed in this category.

#figure(image("../assets/graph_impl.png", width: 90.0%),
  caption: [
    The graph showing implicit instantiation and attribute links
  ]
)
<fig:graph_impl>

=== Editing Telos objects
<editing-telos-objects>
==== Editing Telos objects with the Telos editor
<editing-telos-objects-with-the-telos-editor>
Before we are able to edit a Telos object, we have to load its frame
representation in to the Telos Editor field first. For loading a Telos
object to the Editor field, we choose the *Telos Editor* Button
from either the Display Queries oder Display Instances Browsing
facilities or the Load Frame button from the
_ConceptBaseWorkbench_;~window (see Figure `fig:telos_ed`).

#figure(image("../assets/telos_ed.png", width: 80.0%),
  caption: [
    The TelosEditor Field with the object `Employee`
  ]
)
<fig:telos_ed>

Now we add an additional attribute, e.g. `education`, to the class
`Employee` (for the description of the Telos syntax see Appendix
`cha:syntax`). We have added the line `education : String` as shown in
figure `fig:telos_ed_error`. To demonstrate error reports from the
_ConceptBase.cc_ user interface and how to correct them, we have
made mistakes in the syntax notation of the added attribute.

#figure(image("../assets/telos_ed_error.png", width: 13cm),
  caption: [
    Trying to add an attribute to the class `Employee` with the
    resulting error report
  ]
)
<fig:telos_ed_error>

By clicking the left mouse button on the *Tell* icon, the content
of the editor is told to the _ConceptBase_ server. Syntactical and
semantical correctness is checked and the detected errors are reported
to the Protocol field. The report resulting from our mistakes by
specifying the new attribute is also shown in figure
`fig:telos_ed_error`. Note, that this syntax error would have been
already detected at the client side without interaction with the server
if we would have enabled the option "Pre-parse Telos Frames" in the
options menu.

We correct the error by adding a semicolon to the previous line and
choose the *Tell* symbol again. This time, since there are no
further mistakes, the additional attribute is added to the class
`Employee`.

Now we can choose again the item *Outgoing Attributes* from the
popup of the _Graph Editor_ window for the node Employee. If we
select "Show all" attributes of the attribute class "Attribute" the new
attribute will NOT be shown. CBGraph uses an internal cache which will
only be updated on request. Therefore, we select the object `Employee`
and select "Validate and update selected objects" from the menu "Current
connection". The cache for the object `Employee` will be emptied. Now,
showing all attributes should add the new attribute `education` to the
graph.

==== Editing Telos objects using CBGraph
<editing-telos-objects-using-cbgraph>
Telos objects can also be edited graphically in CBGraph. In our example,
we want to add another attribute named `address` to the class
`Employee`. The attribute destination of this attribute should be a new
class called `Address`.

First, we select the object Employee and click on the "Create Attribute"
button in the tool bar or select "Add Attribute" operation from the tool
bar. As we have selected the Employee object, it should be already
inserted as source of the attribute. We have to type the label (address)
and the destination of the attribute in the text fields (see figure
`fig:graph_add_attr`). As this attribute does not belong to a specific
attribute category (it is just an attribute), we do not have to specify
an attribute class.

By clicking on the Ok button, CBGraph will create a new object for
`Address` represented by the default graphical type (a gray box). Then,
it will create the attribute link from `Employee` to `Address` with the
label `address`. The result is shown in figure `fig:graph_add_inst`.

Now, we want to declare `Address` as an instance of `Class`. Therefore,
we select `Address`, hold down the Shift-key and select `Class`. Both
objects should be selected now. We click on the "Create Instantiation"
button and a dialog as shown in figure `fig:graph_add_inst` should
appear.

#figure(image("../assets/graph_add_attr.png", width: 80.0%),
  caption: [
    Adding an attribute to `Employee`
  ]
)
<fig:graph_add_attr>

#figure(image("../assets/graph_add_inst.png", width: 80.0%),
  caption: [
    Adding an instantiation link between `Address` and `Class`
  ]
)
<fig:graph_add_inst>

As we have selected the objects in the correct way, the dialog already
specifies the object we want to create (`Address` in `Class`) and we can
click directly on Ok. The new instantiation link will be added to the
graph.

#figure(image("../assets/graph_commit.png", width: 80.0%),
  caption: [
    The resulting graph after commit
  ]
)
<fig:graph_commit>

Now, we are satisfied with our changes and want to commit them in the
server. So far, the changes have been stored in an internal buffer of
CBGraph and have not been sent to the server. Note that the "Commit"
button in the upper right corner gets a green color if there are changes
in the graph to be commited. We click on the "Commit" button. CBGraph
generates now Telos frames for the added objects and sends them to the
server. If we did not make an error, all changes should be consistent
and accepted by the server. This is shown by the appearing message box
"Changes committed". If an error occurs, an error message will displayed
instead. The graphical editing is an alternative to the textual editing
via the Telos Editor. It is appropriate for incremental changes to a
model. Larger changes should better be made via the Telos Editor or even
to an external text file that is loaded via the _File / Load Model_
facility of CBIva. If the changes were successfully told to the
CBserver, CBGraph reloads the information of every visible object. In
particular, the graphical types of the objects will be updated. As the
object `Address` is declared as instance of `Class`, it will get the
graphical type of a class, i.e. a turquoise box. The result is shown in
figure `fig:graph_commit`. The object `Employee` is shown in the detailed
component view, in this case the frame representation of the object is
shown. As you can see, the attribute `address` is now also visible in
the frame representation.

=== Using the query facility
<using-the-query-facility>
Lets assume that we need to ask the server for all `Employees` working
for `Angus`. We open a new Telos Editor (see menu item Browse). Then, we
define a new query class (`AngusEmployees`) as follows:

```
AngusEmployees in QueryClass isA Employee with
constraint
    c: $ (this boss Angus) $
end
```

We can tell this query, so that it is stored in ConceptBase.cc and we
can reuse it later, or we can just _ask_ the query, i.e.~the query
will told temporarily and evaluated. If we ask the query, the answer is
displayed in the Telos Editor field as well as in the history window.
Figure `fig:query_answer` shows the CBIva with the query class and the
answer.

#figure(image("../assets/query_answer.png", width: 80.0%),
  caption: [
    Query class and its answer
  ]
)
<fig:query_answer>

We can also execute this query from CBGraph. From the menu "Current
connection" we select "Query to server". A dialog we ask for the name of
query class. If we have told the example query, we can type
`AngusEmployees` in the text field and hit on the "Submit Query". The
query will be evaluated and the objects in the result will be shown in
the list box. We can select the objects which should be added to the
graph (multiple selection with the Shift-key is possible) and click on
the "Show objects" button. The selected objects will be added to the
graph, however with no connection to existing objects.

== Configuration file
<sec:config>
The configuration options are stored in a file ".CBjavaInterface" in the
home directory of the user. The settings are stored automatically on
exit. You can edit the file manually with a normal text editor. It
contains name-value pairs in the format `variable=value`. All variables
can also be modified CBIva via the \"Options\" menu.

- Variables related to CBIva

  / PathForLoadModel\:: #block[
  Path used by the load model dialog (contains the most recent directory
  selected in a dialog).
  ]

  / RecentConnections\:: #block[
  Comma-separated list of recent connections in the format host/port,
  applies also to CBGraph.
  ]

  / PreParseTelosFrames\:: #block[
  Frames are be parsed on client-side before sent to the server
  (true/false).
  ]

  / UseQueryResultWindow\:: #block[
  Use the query result window to display results of a query
  (true/false).
  ]

  / ConnectionTimeout\:: #block[
  Number of milliseconds the interface waits for a response of the
  server
  ]

  / LPICall\:: #block[
  Enable LPI-Call (internal use only; currently without function).
  ]

  / ShowLineNumbers\:: #block[
  If set to `true`, the Telos editor of CBIva shall display line
  numbers.
  ]

  / CBIvaSmallfont\:: #block[
  The font size of the TelosEditor text and log area as regular (small)
  font, default `12f`.
  ]

  / CBIvaLargefont\:: #block[
  The font size of the TelosEditor text and log area as large font,
  default `18f`.
  ]

  / PublicCBserver\:: #block[
  Either `none` (=disabled) or the domain name of a computer that hosts
  a publicly accessible ConceptBase server. A port number can be
  appended as well like in 'cbserver.acme.com/4002'. Default port number
  is `4001`. The variable PublicCBserver also applies to CBGraph and
  CBShell. See section `sec:pubcbserver` for more details. If the value
  is different from 'none', then CBIva shall attempt to connect to the
  public CBserver at startup.
  ]

  / CBIvaBrowserWindows\:: #block[
  Set to `true` if CBIva shall display windows for the currently defined
  queries and the visible modules nect to the TelosEditor window.
  Default is `false`.
  ]

  / DarkMode (experimental)\:: #block[
  Set to `true` if CBIva/CBGraph shall use the dark mode of the UI
  Look-and-Feel if supported. Default is `false`.
  ]

- Variables related to CBGraph

  / PathForLayout\:: #block[
  Path used by the dialog to store and load graphs (contains the most
  recent directory selected in a dialog).
  ]

  / ComponentView\:: #block[
  Default view for the detailed representation in CBGraph (can be
  "`frame`" or "`tree`" or "`none`").
  ]

  / SaveLayoutWithGraphType\:: #block[
  Layouts of CBGraph are stored with all information about graphical
  types (true/false).
  ]

  / InvalidObjectsMethod\:: #block[
  Specifies whether objects that have been identified as invalid should
  be marked or deleted (mark/delete).
  ]

  / DiagramDesktopBackgroundColor\:: #block[
  Background color of the desktop of CBGraph (comma-separated
  representation of an RGB-value).
  ]

  / DebugLevel\:: #block[
  Level for debug messages. Possible values are SEVERE, WARNING, INFO,
  CONFIG, FINE, FINER, FINEST (according to the java.util.logging
  package). Default is WARNING.
  ]

  / ModuleSeparator\:: #block[
  Can be either '-' or '/'.
  ]

  / NodeLevelAware\:: #block[
  Enables or disables the special behavior of nodes with negative level
  in CBGraph. See also section `sec:nodelevel`. Default is \"true\".
  ]

  / ShowLinkCategory\:: #block[
  Allows to limit the default type of links expanded when using the tool
  bar button \"Show links between marked objects\".
  ]

  / GuardModulePath\:: #block[
  If set to \"true\" (default), then you cannot save the graph file if
  you change the module to s supermodule or a sibling module of the
  original module path stored in the graph file. This prevents
  accidental inconsistencies of the stored module sources and the
  displayed nodes and links of the graph. Experienced users can set this
  option to \"false\" for beining able to force saving the graph.
  ]
