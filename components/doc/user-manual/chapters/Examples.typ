= Examples
<cap:examples>


= Example model: the employee model
<sec:employee-model>
The Employee model can be found in the directory
``CB_HOME`/examples/QUERIES/`. It consists out of the following files:

/ Employee\_Classes.sml\:: #block[
The class definition
]

/ Employee\_Instances.sml\:: #block[
Some instances for this model
]

/ Employee\_Queries.sml\:: #block[
Queries for this model
]

Note, that the files must be loaded in this order into the server.


// section conversion failed
\section{A Telos modeling example - ER diagrams}
\label{sec:ER-diagrams}

\subsection{The basic model}
\label{subsec:ER-basic-model}
This example gives a first introduction into some features introduced in
ConceptBase version 4.0. It demonstrates the use of {\em meta formulas} and
{\em graphical types} while building a Telos model describing
Entity-Relationship-Diagrams. The following model forms the basis:\\



\begin{verbatim}
Class Domain
end

Class EntityType with attribute
     eAttr : Doma
