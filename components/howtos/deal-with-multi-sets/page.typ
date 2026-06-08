= Deal With Multi Sets

Verified independently via:

```bash
nix build .#checks.x86_64-linux.deal-with-multi-sets
```

== Input

=== `MULTISET.cbs.txt`

```telos
#
# File: MULTISET.cbs
# Author: Manfred Jeusfeld
# Creation: 13-Nov-2007 (16-Sep-2015)
# ----------------------------------------------------------------------
# Example that shows how to deal with multi-sets in ConceptBase.
# Call:  cbshell MULTISET.cbs
#
# This script requires ConceptBase 7.5 or later

cbserver -u nonpersistent -t low -port 4003 

# In the subsequent frame 'deptsize' is a derived multi-set. It contains all department sizes
# and used the department label 'n' to distinguish multiple occurrences of the same
# value.

tell "
Employee in Class with 
  attribute
    dept: Department;
    deptsize: Integer
  rule
    sizerule: $ forall e/Employee d/Department s/Integer n/Label 
                      (e dept d) and Label(d,n) and (d size s) ==> (e deptsize/n s) $
end

Department with
  attribute
    size: Integer
end
" 

tell "
bill in Employee with
  dept d1: D1; d2: D2; d3: D3
end

mary in Employee with
  dept d1: D1; d2: D2
end

Department D1 with size s: 100 end
Department D2 with size s: 121 end
Department D3 with size s: 100 end
"


ask "EmpWithDeptSizes in QueryClass isA Employee with
  retrieved_attribute
    deptsize:Integer
end " FRAMES FRAME Now
# shall display all three elements 100,121,100; so 100 occurs twice
# Note that the query class definition is removed after evaluating it

tell "
AllDSizes in GenericQueryClass isA Real with
  parameter,computed_attribute
    emp: Employee
  constraint
    c1: $ (~this = SUM_attributee[~emp/objname,Employee!deptsize/attrcat]) $
end
AVG_DSizes in GenericQueryClass isA Real with
  parameter,computed_attribute
    emp: Employee
  constraint
    c1: $ (~this = AVG_attributee[~emp/objname,Employee!deptsize/attrcat]) $
end
"

ask "AllDSizes[bill/emp]" OBJNAMES  LABEL  Now
# shall result in 321, ie. counts 100 twice

ask "AVG_DSizes[bill/emp]" OBJNAMES  FRAME  Now

ask "AVG_DSizes" OBJNAMES  FRAME  Now




```

=== `SALARYCONSTR.cbs.txt`

```telos
#
# File: SALARYCONSTR.cbs
# Author: Manfred Jeusfeld
# Creation: 15-Feb-2008 (2-Apr-2008)
# ----------------------------------------------------------------------
# Example that shows how to deal with multi-sets in ConceptBase.
# Call:  CBshell -f SALARYCONSTR.cbs
#
# This script requires ConceptBase 7.1 released after 2-Apr-2008

startServer -u nonpersistent -t low -p 4002 

# The query class SalarySum sums up all salaries of a given employee emp.
tell "
Employee in Class with 
  attribute
    salary: Integer
end

SalarySum in Function isA Integer with
  parameter
     emp: Employee
  constraint
     sumcond: $ (~this = SUM_attributee[Employee!salary,emp]) $
end
" 

# The salcon constraint makes sure that employees do not earn more than 10000 
# as sum of their salaries. Note the (e salary s) in the condition. It is
# required to trigger constraint testing in cases where the salary is changed
# incrementally.
tell "
Employee in Class with
  constraint
    salcon: $ forall e/Employee s/Integer 
                (e salary s) ==> (SalarySum(e) < 10000) $
end
"


# Some example data

# This update is ok
tell "
bill in Employee with
  salary
    sal1: 5000;
    sal2: 4000
end
" 

# this update should be rejected
tell "
mary in Employee with
  salary
    sal1: 12500
end
"

# This update is ok
tell "
pete in Employee with
  salary
    sal1: 3500;
    sal2: 2000
end
"

# this update should be rejected
tell "
bill in Employee with
  salary
    sal3: 4000
end
"




```

=== `SALARYSUM.cbs.txt`

```telos
#
# File: SALARYSUM.cbs
# Author: Manfred Jeusfeld
# Creation: 14-Feb-2008 (6-May-2008)
# ----------------------------------------------------------------------
# Example that shows how to deal with multi-sets in ConceptBase.
# Call:  CBshell -f SALARYSUM.cbs
#
# This script requires ConceptBase 7.1 released after 21-Apr-2008

startServer -u nonpersistent -t low -p 4005 

# The query class SalarySum sums up all salaries of a given employee emp.
# The query TooRickEmployee lsists employees who earn more than 10000 as sum of their salaries.
tell "
Employee in Class with 
  attribute
    salary: Integer
end

SalarySum in Function isA Integer with
  required,parameter
     emp: Employee
  constraint
     sumcond: $ (this = SUM_attributee(Employee!salary,emp)) $
end

TooRichEmployee in QueryClass isA Employee with
   constraint
     toorich: $ (SalarySum(this) > 10000) $
end
" 

# Some example data
tell "
bill in Employee with
  salary
    sal1: 5000;
    sal2: 4000;
    sal3: 4000
end

mary in Employee with
  salary
    sal1: 12500
end

pete in Employee with
  salary
    sal1: 3500;
    sal2: 2000
end
"


ask "SalarySum[bill/emp]" OBJNAMES FRAME Now
ask "SalarySum[mary/emp]" OBJNAMES FRAME Now

ask "TooRichEmployee" OBJNAMES LABEL  Now
# shall result in bill,mary






```

== Shell output

```text
=== HOW-TO: deal-with-multi-sets ===

>>> Running ./MULTISET.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>bill in EmpWithDeptSizes with 
   deptsize
    D1 : 100;
    D2 : 121;
    D3 : 100
end 

mary in EmpWithDeptSizes with 
   deptsize
    D1 : 100;
    D2 : 121
end 


[localhost:4001]>bill in EmpWithDeptSizes with 
   deptsize
    D1 : 100;
    D2 : 121;
    D3 : 100
end 

mary in EmpWithDeptSizes with 
   deptsize
    D1 : 100;
    D2 : 121
end 


[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>
>>> Running ./SALARYCONSTR.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>
>>> Running ./SALARYSUM.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
