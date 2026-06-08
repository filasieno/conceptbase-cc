= Define Set Operators

Verified independently via:

```bash
nix build .#checks.x86_64-linux.define-set-operators
```

== Input

=== `Intervals.sml.txt`

```telos
{
*
* File: Intervals.sml
* Author: Manfred Jeusfeld
* Creation: 28-Nov-2005 (14-Oct-2008)
* ----------------------------------------------------------------------
* This shows how to define and use intervals on integers numbers.
* Note that membership of a value like 900 to Interval[1/a,1000/b] is
* only checked when the salary of bill is told to the system.
*
* Requires ConceptBase 7.1.4 released 14-Oct-2008 or later.
*  
}


GenericQueryClass Interval isA Integer with
  parameter
     a: Integer;   
     b: Integer
  constraint
    c1: $ (~a <= ~this) and (~this <= ~b) $
end

{* Note that Integer stands for all stored instances of the class Integer. *}
{* This is always a finite subset of all integer numbers.                  *}


1 in Integer end
10 in Integer end
1000 in Integer end

Interval[1/a,10/b] in QueryCall end
Interval[1/a,1000/b] in QueryCall end


Employee in Class with
  attribute
    salary: Interval[1/a,1000/b]
end

{* this should be equivalent to

Employee in Class with
  attribute
    salary: Integer
  constraint
    cs: $ forall e/Employee s/Integer (e salary s) ==> ( (1 <= s) and (s <= 1000) ) $
end

with the exception that the interval-version is not re-checked when its
extension changes.

*}



bill in Employee with
  salary s: 900
end

{* this one fails:
mary in Employee with
  salary s: 1100
end
*}

```

=== `SetOps.sml.txt`

```telos
{
*
* File: SetOps2.sml
* Author: Manfred Jeusfeld
* Creation: 26-Apr-2002 (7-Apr-2008/M.Jeusfeld)
* ----------------------------------------------------------------------
*
* Extension of SetOps.sml where arguments of the generic set
* operations can themselves be parameterized queries.
* Requires ConceptBase 7.1 released 6-Apr-2008 or later!
*
* Example query calls (use Ask Objname):
*    Intersec[EmpMinSal[800/minsal]/X,EmpMaxSal[1400/maxsal]/Y]
*    Union[Intersec[EmpMinSal[800/minsal]/X,EmpMaxSal[1400/maxsal]/Y]/X,Manager/Y]
*
* Note that the generic queries Intersec, Union and Difference require
* their parameters to be instances of class. This is OK for the parameters
* like EmpMinSal[800/minsal since their core class EmpMinSal is an instance
* of Class. 
*
}


Class Employee with 
  attribute
    salary: Integer
end

Class Manager isA Employee end

Employee bill with
  salary s: 500
end
Employee mary with
  salary s: 1000
end
Employee charly with
  salary s: 1500
end

lisa in Manager end


GenericQueryClass EmpMinSal isA Employee with
  parameter
    minsal: Integer
  constraint
    c1: $ exists s/Integer (this salary s) and (s >= minsal) $
end

GenericQueryClass EmpMaxSal isA Employee with
  parameter
    maxsal: Integer
  constraint
    c1: $ exists s/Integer (this salary s) and (s =< maxsal) $
end



GenericQueryClass Intersec isA Individual with
 parameter
   X: Class; Y: Class
 constraint
   c: $ (this in X) and (this in Y) $
end

GenericQueryClass Union isA Individual with
 parameter
   X: Class; Y: Class
 constraint
   c: $ (this in X) or (this in Y) $
end

GenericQueryClass Difference isA Individual with        
 parameter
   X: Class; Y: Class
 constraint
   c: $ (this in X) and not (this in Y) $
end


{* Example to count number of instances of a nested query call:
   Note that the user interface CBiva requires the full syntax for
   "Ask Query Call" rather than the shortcut. Shortcuts are
   currently only supported in logical formulas.

COUNT[Union[Intersec[EmpMinSal[800/minsal]/X,EmpMaxSal[1400/maxsal]/Y]/X,Manager/Y]/class]

*}


{* Same expression but now using the shortcut syntax *}
Function CountSet1 isA Integer with
  constraint
    c1: $ (this = #Union[Intersec[EmpMinSal[800],EmpMaxSal[1400]],Manager]) $
end



```

== Shell output

```text
=== HOW-TO: define-set-operators ===

>>> Telling ./Intervals.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./SetOps.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
