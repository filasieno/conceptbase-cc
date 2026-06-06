This directory contains the formalization of Process-Data Diagrams (PDDs)
accompanying the paper

M.A. Jeusfeld (2011): A Deductive View on Process-Data Diagrams.
Proceedings ME-2011, IFIP, AICT 351, 2011, (Boston: Springer), pp 123-137.
Postprint available via
  http://conceptbase.sourceforge.net/mjf/ME2011-mj-postprint.pdf

The model files with file type *.sml are all under a Creative Commons
License, see PDD-CC-NCBY-NC-License.txt. You can view/edit them
with a standard text editor.

You need to install ConceptBase 7.3 (or later) to explore the
formalizations. Download it from
  http://sourceforge.net/projects/conceptbase/

There are a few script files that simplify the 
use of the formalization. You can execute them in a command/shell
window. We assume subsequently that the command CBshell is
in the search path. If not you have to prepend the path
  <CB_HOME>/bin/
before the subsequent commands where <CB_HOME> is the directory path
into which you installed ConceptBase.

The file postExport.sh is a Linux/Unix script that can be copied
into the VIEWS directory (or another directory used to maintain
views) as an executable read-only script:

  cp postExport.sh VIEWS/
  chmod u+x VIEWS/postexport.sh
  chmud ugo-w VIEWS/postexport.sh

The script postExport.sh will automatically convert Graphviz dot files
exported from ConceptBase into PNG graphics. You can also adapt this
script to generate other output formats such as EPS.
You need to install Graphviz on your computer to use this
feature. 
Windows users might want to translate postExport.sh into a
batch file postExport.bat. We do not provide it here.


CBshell -f createDataBase.cbs

   This will create a database with name DB-PDD. If that already exists,
   please manually remove it before executing this command.


CBshell -f startstop.cbs

   Start ConceptBase with database DB-PDD and then stop it.
   This will materialize the views in VIEWS, in particular
   the Graphviz files.

CBserver -u nonpersistent -d DB-PDD

   Start a CBserver that you can sub-sequently inspect with
   the CBjavaInterface

CBserver  -u nonpersistent -d DB-PDD -views VIEWS

   Same as before but will export views into the directory
   VIEWS. That directory must be created by hand before
   starting this command. A sample directoty VIEWS-COPY
   is provided showing what content ConceptBase will
   export to the VIEWS directory.

CBjavaInterface

   Start a ConceptBase user interface. See ConceptBase user manual
   on how to use it and connect to the CBserver.



Tilburg, 2011-04-13 (2011-05-18)

Manfred Jeusfeld
(manfred.jeusfeld@acm.org)

