Materialized Graph Views with ConceptBase.cc V7.6.10

Manfred Jeusfeld, 2014-03-20


Create a self-contained graphical view of the database that contains the graph,
all necessary object definitions, and connection details to link to the ConceptBase
database from which the graphical view was extracted



0. Introduction

The ConceptBase graph editor CBGraph visualizes graphical views on a ConceptBase
database module. Nodes and links can have dedicated shapes and can be moved around
in the drawing window (called "internal windows" in the ConceptBase user manual.

This tutorial shows you how to store the graphical view in a self-contained
file that contains all necessary information to work with the view.


1. Prepare the database

We use the Business Model database as example, see
  http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/3618112

Download the files *.sml.txt and *.cbs to a directory named
BMG and open a terminal to enter

  cd BMG
  cbshell createBMGDB.cbs


Afterwards the database BMGDB is created. Start a CBserver on the database

  cbserver -d BMGDB -sm slave

The server will have hostname 'localhost' and port number 4001. The
option -sm slave will stop the CBserver when its last client disconnects
from it. So, it makes it easier to employ a CBserver just for one session
of CBGraph. When CBGraph exists, CBserver will also stop.



2. Create a graphical view 

Open a new terminal and start 

   cbgraph +r

This will open an unconnected graph editor. The option +r instructs CBGraph that
we plan to extract (read) object definitions from the database.

Select File/Connect to server to open a connection. Make sure that you specify
localhost and 4001 in the first tab of the connection dialog. The 2nd tab 
specifies the start module (oHome), the start object (Class), and the graphical
palette. Leave the settings as they are.

As a result, CBGraph will open a new internal window labelled
   "DefaultJavaPalette:oHome -- localhost:4001"

Change to module "eGadgetCase" using the "Current connection" dialog. Then change
the graphical palette to "BMG_Palette" in the same dialog.
The window now gets a new background (defined by BMG_Palette) and adapts its size.
Select the object Class and hide it using the 4th button in the CBGraph toolbar.
Maximize the CBGraph window and the internal window. 
Then, press the load object icon from the toolbar (6th icon) and type "OEM" as object name.
You can resize the node and place it in the leftmost upper segment.

Right-click on OEM and select 'Outgoing attributes - flowTo - all - Show all"
A new object eGadget_Hardware appears. Place it in the light green segment in
the left half of the window. Expand eGadget_Hardware in a similar way and move 
the result objects to the right. You can resize the nodes as well and also move the links
by finding their "move point". 



3. Materialize the graph


Select the option File/Save and store the graph with a name like egadget-view1.gel.
Then exit CBGraph. The file egadget-view1.gel contains all data needed for
working with the graph including the required object definitions.

Open a CBIva, connect to the CBserver at localhost and port 4001. Stop the CBserver
and exit CBIva.




4. Open the graph file 

Start in a terminal window
   cbgraph -rw egadget-view1.gel 
It will warn you that there is no connection to a database. Still you can view
the graph and change the location of nodes. However, we would like to work
with the graph further and expand its view on the database. You may want to maximize
the window again to see the whole graph.
So, close CBGraph again and start a CBserver like before in another terminal
  
  cbserver -d BMGDB -sm slave

Then start 
  
  cbgraph +rw egadget-view1.gel 


Now, the same graph opens and is connected to the CBserver on localhost:4001.
This is the typical way to work with a graph. You can store expand further nodes
but we leave it its current state and exit CBGraph and its slave CBserver.




5. Open the graph on another computer

Assume, you want to demonstrate the graph on another computer and you have no access
to the BMGDB database on that computer. Note that the object definitions are 
included in egadget-view1.gel since we used the +r option.

Start in a terminal 

   cbgraph +w egadget-view1.gel 


Since egadget-view1.gel contains module sources and the +w option is active, CBGraph
shall start a local CBserver to which the module sources are written ahen the file
is opened.

You can now work with the graph in the same way as if you were connected to the
original database BMGDB!

Then, stop CBGraph.



You also find a file egadget-view2.gel that is a view on the same database module but
with more objects displayed in its window. It has been created using the +r option
on the same database. Hence, you can use it directly like with


   cbgraph +w egadget-view2.gel 


You can also omit the options +r,+w, and +rw. Then, CBGraph will enable full
synchronization between the graph file and the CBserver.


If you want to disable the synchronization, then call for example

  cbgraph -rw egadget-view2.gel

This is useful when a running CBserver always has the latest state and you do not want
to materialize the state of the CBserver in the graph file. In particular, when
objects are deleted from the database after exiting CBGraph, the full synchronization 
would recover them. 











