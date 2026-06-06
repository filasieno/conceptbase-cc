These are the ConceptBase models accompanying the paper
  J. Jayasinghe Arachchige, H. Weigand, M. Jeusfeld:
  Business Service Modeling for the Service-Oriented Enterprise,
  To appear in Int J of Information System Modeling and Design, 2011.

The files are licensed under a Creative Commons NC-BY license.

The scripts are written for Linux. They can be adapted to other operating
systems but we only provide the Linux version here.


You need to install ConceptBase from http://conceptbase.cc
and Graphviz via the package manager of your Linux distribution.

You also need to include the path
  <CB_HOME>/bin
into your search path, where <CB_HOME> is the directory
into which you installed ConceptBase.

To excerpt the graphical representation, you need to execute these 
commands:

$ CBshell -f create-DB-SERVICE.cbs

  ==> creates the database DB-SERVICE
  You only need to execute this step once.

$ mkdir VIEWS
$ cp postExport.sh VIEWS
$ chmod u+x VIEWS/postExport.sh

$ CBshell -f startstop.cbs

  ==> excerpts the dot files and converts them to
      PNG grapchis. This is done for all sub-modules,
      so if you extend the database you get also the
      PNG graphics of the new examples




Tilburg, 2011-05-11
Manfred Jeusfeld
