Some experiments on covariant specialization with UML, Java, and Telos/ConceptBase

Manfred Jeusfeld, 2024-11-04





(1) UML model


See slides 2 & 3 of UML-Telos-Java-2024.pdf
It should be noted that UML does allow co-variant specialization of associations.
Apparently, the Java compiler also allows it, see variable project of Employee and Manager in the Java source code




(2) Java Implementation

The Java implementation of the Employee model is constrained by Java's strict type safety,
which forbids co-variant refinement of operations. 

In particular look at the operation
  void assignProject(Project p)
of Employee and its extension for Manager.

The operation assignDefaultProject() of Employees shows that a programmer may get a runtime error
when executing the operation. The runtime error is triggered by the assertion
     assert (p instanceof HighLevelProject)
for assignProject(...) of Manager.

So, while the program is technically type-safe, the use of assertions can still trigger runtime errors.

An option could be to not extend the operation assignProject(...) and rather use the operation defined
at Employee.

The operations setMinimumSalary() and printEmployee() of Employee are extended for Manager.
They have a different behavior but there is not type-safety issue since the operations have no parameters.

Source: Employees.java

  

compile: javac Employees.java

run: java Employees


With enabled assertions (parameter -ea):

run: java -ea Employees
--> An assertion error exception is raised if an attempt is made to assign a non-HighLevelProject to a Manager


========================================================================================================

(3) Telos/ConceptBase model

Co-variant specialization is baked into Telos. 

Source: Employees.sml.txt

Note that the first part of the source file is only there to facilitate a UML-style rendering of the model
in the ConceptBase graph editor. The source can be loaded to ConceptBase using the CBIva user interface.


Graph file: employees.gel
This file can be directly called with
  cbgraph employees.gel
if you have installed ConceptBase from https://conceptbase.sourceforge.net/CB-Download.html




