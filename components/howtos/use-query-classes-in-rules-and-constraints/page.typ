= Use Query Classes In Rules And Constraints

Verified independently via:

```bash
nix build .#checks.x86_64-linux.use-query-classes-in-rules-and-constraints
```

== Input

=== `DynamicSets.sml.txt`

```telos
{
*
* File: DynamicSets.sml
* Author: Manfred Jeusfeld
* Creation: 28-Nov-2005 (5-Sep-2006/M.Jeusfeld)
* ----------------------------------------------------------------------
* 28-Nov-2005: doesn't detect integrity violation!
* Steps:
* 1. Start CBserver with option -cc (forceConcernedClass) set to off
* 2. Tell this file 
* 3. Tell the two frames in comments at the end of this file
* ==> Step 3 is accepted though the constraint of Manager is violated
* 
* Hence, it is advisable not to use generic query classes in rules/constraints.
* If you set the CBserver option -cc to 'strict', ConceptBase will prevent you
* from doing so. Still, there might be applications where this feature is useful.
* 
*  
}


Employee in Class with
  attribute
    salary: Integer
end

Manager in Class isA Employee with
  attribute
    supervises: Employee
end


GenericQueryClass EmployeeSalary in MSFOLrule isA Integer with
  parameter
    manager: Manager
  constraint
    c1: $ exists e/Employee (~manager supervises e) and (e salary ~this) $
end


Manager with
  constraint
    c1: $ forall m/Manager s1/Integer
            (m salary s1) ==> forall s2/EmployeeSalary[m/manager] (s1 > s2) $
end
    

bill in Employee with
  salary s: 900
end

john in Employee with
  salary s: 800
end

mary in Manager with
  supervises e1: bill; e2: john
  salary s: 1100
end

{* 

diana in Employee with
  salary s: 1200
end

mary with
  supervises e3: diana
end

*}

```

=== `QueriesAndConstraints.sml.txt`

```telos
{
* File: QueriesAndConstraints.sml
* Author: Manfred Jeusfeld
* Created: 5-Sep-2006/M.Jeusfeld (5-Sep-2006/M.Jeusfeld)
* ------------------------------------------------------
* 
* Example of the correct use of simple query classes in rules/constraints.
* See also section 'Query classes and constraints' in the ConceptBase User
* Manual.
*
}


Unit in Class with
 attribute
   sub: Unit
end

BaseUnit in QueryClass,MSFOLrule isA Unit with
 constraint
   c1: $ not exists s/Unit!sub From(s,~this) $
end

SimpleUnit in Class isA Unit with
 constraint
   c: $ forall s/SimpleUnit (s in BaseUnit) $
end

{* some instances to check the correct behavior *}


u1 in Unit with 
  sub s1: u2
end

u2 in SimpleUnit end

{* this frame shall violate the constraint :

u1 in SimpleUnit end

*}


```

== Shell output

```text
=== HOW-TO: use-query-classes-in-rules-and-constraints ===

>>> Telling ./DynamicSets.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./QueriesAndConstraints.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
