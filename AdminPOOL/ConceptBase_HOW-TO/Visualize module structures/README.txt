Visualize module structures

Manfred Jeusfeld, 2012-09-12


Almost all modern programming languages offer module structures,
in which program sources import and export elements like procedures.

Logically, this induces a dependency network like
   (m1 imports m2)
expressing that module m1 imports from module m2.

The files in this directory show how one can rather easily extract
this network from source files, store them in ConceptBase,
and let ConceptBase generate a graph to be layed out by GraphViz.

As example, we show how to do it from Prolog sources file (as used
by the ConceptBase system). The ConceptBase Prolog sources include
declarations like

#IMPORT(increment/1,GeneralUtilities)

This means that the current module containing this declarations imports
a procedure increment/1 (arity 1) from the the module GeneralUtilities.

Each module can have a number of such declarations and the program system
as a whole can have many modules.


The files in this directory are:

  ImportsModel.sml.txt
     Telos definitions making ConceptBase capable of transforming the module declarations into GraphViz graphs.
     In particular, two queries imports2GV and uses2GV are defined. The first one 
     generates the complete network of imports relations, i.e. two modules can have
     any number of imports relations between each other. The second one aggregates
     all imports relations from a module m1 to a module m2 into a single uses
     relations between m1 and m2.

  ExtractImports.java
     Program to extract imports declarations from Prolog source files (uses ConceptBase syntax);
     compile with 'javac ExtractImports.java'

  genImports
     Unix/Linux shell script to generate all import declarations from all Prolog source files of a given directory.
     Store as file 'genImports' and make in executable.

  Literals.pro
     Example Prolog source file; only the IMPORT declarations are of interest; you can add more
     Prolog sources from the ConceptBase source pool if you want to see how larger graphs are layed out.

  imports.png
     Visualizes the IMPORT dependencies from Literals.pro

  imagedfpd
     Visualizes the IMPORT dependencies of all ConceptBase Prolog sources



Call the visualization in a Unix pipe like, assuming that the Prolog sources are in the 
current directory:

   genImports . imports2GV | cbshell -p | neato -Tpng > imports.png

It will scan all *.pro files in the current directory and produce the graph image.
You can also provide an absolute path to the directory with the Prolog sources:

   genImports /home/me/prj imports2GV | cbshell -p | neato -Tpng > imports.png

If you want to visualize only the 'use' relations between modules, then call:

   genImports /home/me/prj uses2GV | cbshell -p | neato -Tpng > imports.png


You can apply the tools to other programming languages by adapting the program
   ExtractImports.java
and the Telos definitions in ImportsModel.sml.txt, if necessary.






