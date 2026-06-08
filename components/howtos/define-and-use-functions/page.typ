= Define And Use Functions

Verified independently via:

```bash
nix build .#checks.x86_64-linux.define-and-use-functions
```

== Input

=== `ackermann.cbs.txt`

```telos
#
# File: ackermann.cbs
# Author: Manfred Jeusfeld
# Creation: 7-Mar-2008 (29-May-2016)
# ----------------------------------------------------------------------
# Compute the Ackermann function (see also http://en.wikipedia.org/wiki/Ackermann_function)
# This script requires ConceptBase 7.8 released after 28-Mar-2016


cbserver  -u nonpersistent -t no


tell "
a in Function isA Integer with
  parameter
    m: Integer;
    n: Integer
  constraint
    cack: $ (m=0) and (this=n+1) or
            (m>0) and (n=0) and (this=a(m-1,1)) or
            (m>0) and (n>0) and (this=a(m-1,a(m,n-1)) ) 
        $
end
"

# a(2,0)=3
ask a(2,0)
echo -n "a(2,0)="
showAnswer


# a(2,1)=5
ask a(2,1)
echo -n "a(2,1)="
showAnswer

# a(2,2)=7
ask a(2,2)
echo -n "a(2,2)="
showAnswer


# a(3,3)=61
ask a(3,3)
echo -n "a(3,3)="
showAnswer


# Note that a[4/m,4/m] is a number greater than all atoms in the universe and is intractable to compute


```

=== `BuiltinFunctions.sml.txt`

```telos
{
*
* File: BuiltinFunctions.sml
* Author: Manfred Jeusfeld
* Creation: 28-Sep-2005 (9-May-2008)
* ----------------------------------------------------------------------
* Some examples on using builtin functions like SUM, COUNT, MAX, PLUS
*
* (c) by M. Jeusfeld. 
* This model file is licensed under the CC-GNU GPL 
* http://creativecommons.org/licenses/GPL/2.0/
*
* Requires ConceptBase 7.1 released April 2008 or later.
*
}


Employee in Class with
  attribute
    salary: Real;
    worksfor: Project
end

Project in Class end


{* this computes the sum of all salaries of an employee *}
EmployeeWithSalary in QueryClass isA Employee with
  computed_attribute
     sum_salary: Real
  constraint
     csum: $ (sum_salary = SUM_attributee(Employee!salary,this)) $
end

{* this one includes a test on the sum of the salary *}
EmployeeWithMuchSalary in QueryClass isA Employee with
  constraint
     csum: $ (SUM_attributee(Employee!salary,this) > 10000.0) $
end

{* this is equivalent to the above query but uses an intermediate variable *}
{* and the long form for the function                                      *}
EmployeeWithMuchSalaryEquiv in QueryClass isA Employee with
  constraint
     csum: $ exists s/Real (s = SUM_attributee[this/objname,Employee!salary/attrcat]) and
                    (s > 10000.0) 
                 $
end


{* this query counts the number of projects that an employee works for *}
EmployeeWithManyProjects in QueryClass isA Employee with
  constraint
    cmany: $ (COUNT_attributee(Employee!worksfor,this) > 2) $
end

  


{* some instances *}

bill in Employee end  {* no properties at all *}

mary in Employee with
  salary s1: 500.0
end

jane in Employee with
  salary s1: 800.0; s2: 9500.0
end

kuno in Employee with
  salary s1: 50.0; s2: 80.0; s3: 3000.0
  worksfor p1: Proj1; p2: Proj2
end

yet in Employee with
  worksfor p1: Proj1; p2: Proj2; p3: Proj3
end

Proj1 in Project end
Proj2 in Project end
Proj3 in Project end




```

=== `fib.cbs.txt`

```telos
#
# File: fib.cbs
# Author: Manfred Jeusfeld
# Creation: 5-Mar-2008 (1-Jul-2011)
# ----------------------------------------------------------------------
# Compute the Fibonacci numbers (see also http://en.wikipedia.org/wiki/Fibonacci_number)
# This script requires ConceptBase 7.1 released after 28-Mar-2008
# The example also highlights the utility of the cache-based query evaluation of
# ConceptBase. With the cache enabled (default), the call fib[20/n] takes around
# 0.02 sec on a contemporary CPU. With the cache disable (option -c off), the same
# call takes more than 3 seconds. It is basically the difference between a naive
# evaluation with O(2^n) performance and the semi-naive evaluation with O(n) performance.
# In this case (and many other cases), ConceptBase approximates the semi-naive algorithm.
#
# We strongly recommend NOT to use the option -c off in regular applications of ConceptBase.
# It not only is much slower. It also even traps some recursive rule evaluations into
# infinite loops.
#


#startServer -u nonpersistent -c off 
startServer -u nonpersistent 


# This is the definition of fib; note that the whole
#  definition has to be read as follows:
#   forall n,this/Integer cfib(n,this) ==> (this in fib(n))
#  This is equivalent to the three formulas
#
#    forall n,this/Integer (n=0) and (this=0) ==> (this in fib(n))
#    forall n,this/Integer (n=1) and (this=1) ==> (this in fib(n))
#    forall n,this/Integer (n>1) and (this = fib(n-1)+fib(n-2)) ==> (this in fib(n))
#

tell "
fib in Function isA Integer with
  parameter
    n: Integer
  constraint
    cfib: $ (n=0) and (this=0) or
            (n=1) and (this=1) or
            (n>1) and (this=fib(n-1)+fib(n-2)) 
        $
end
"

# fib[10/n] should return 55
ask "fib[10/n]" OBJNAMES  FRAME  Now
# fib[12/n] should return 144
ask "fib[12/n]" OBJNAMES  FRAME  Now
# fib[20/n] should return 6765
ask "fib[20/n]" OBJNAMES  FRAME  Now
# fib[200/n] should return 280571172992510140037611932413038677189525 on a 64-bit operating system
ask "fib[200/n]" OBJNAMES  FRAME  Now



```

=== `fibfast.cbs.txt`

```telos
#
# File: fibfast.cbs
# Author: Manfred Jeusfeld
# Creation: 9-Jul-2018 (10-Jul-2018)
# ----------------------------------------------------------------------
# Compute the Fibonacci numbers (see also http://en.wikipedia.org/wiki/Fibonacci_number)
# Uses the 'fast doubling' method of https://www.nayuki.io/page/fast-fibonacci-algorithms
#
# The complexity of fibfast(n) is O(log(n)). Note that the Datalog engine of ConceptBase computes
# intermediate results only once. A second call fetches the result from a cache. The access to
# that cache is hash-based. Hence, the real time complexity of this implementation may be a bit
# worse than O(log(n)).

# connect to a CBserver
connect


tell "

Even in QueryClass isA Integer with
  constraint
    iseven: $ (this = 2*IDIV(this,2)) $
end

Odd in QueryClass isA Integer with
  constraint
    isodd: $ (this = 2*IDIV(this,2)+1) $
end

fibfast in Function isA Integer with  
  parameter
    n : Integer
  constraint
    cfib : $ (n=0) and (this=0) or
            (n=1) and (this=1) or
            (n=2) and (this=1) or
            (n>2) and (n in Even) and (this=fibfast(IDIV(n,2)) * ( 2 * fibfast(IDIV(n,2)+1) - fibfast(IDIV(n,2)) )) or 
            (n>2) and (n in Odd) and (this=fibfast(IDIV(n,2)+1)*fibfast(IDIV(n,2)+1) + fibfast(IDIV(n,2))*fibfast(IDIV(n,2)) )
        $
end 


"

# fibfast[10/n] should return 55
ask fibfast(10)
echo -n "fibfast(10)="
showAnswer

ask fibfast(100)
echo -n "fibfast(100)="
showAnswer

ask fibfast(1000)
echo -n "fibfast(1000)="
showAnswer



```

=== `FunctionShortcuts.cbs.txt`

```telos
#
# File: FunctionShortcuts.cbs
# Author: Manfred Jeusfeld
# Creation: 20-Feb-2008 (31-Mar-2008)
# ----------------------------------------------------------------------
# Example that shows how to deal with shortcuts of function calls.
# Call:  CBshell -f FunctionCall.cbs
#
# This script requires ConceptBase 7.1 released after 31-Mar-2008



startServer -u nonpersistent -t low

# Test 1: Check a self-defined function TokenNr
tell "
Place with
  attribute
    sendsToken: Transition;
    tokenFill: Integer
end
Transition with 
  attribute
     producesToken : Place
end 
TokenNr in Function isA Integer with
  parameter
    place: Place
  constraint
    c1: $ (place tokenFill this) $
end
"

# Some example data
tell "
trans1 in Transition with 
  producesToken
     pl1 : place2;
     pl2 : place3
end 
place1 in Place with
  sendsToken
     t1: trans1
  tokenFill
     tf1: 5
end
place2 in Place with 
  tokenFill
     tf1: 0
end
place3 in Place with
  sendsToken
     t1: trans1;
     t2: trans1   {* consumes 2 tokens per firing *}
  tokenFill tf: 3    
end"


# Call TokenNr(pl) as shortcut for TokenNr[pl/place] and
# IPLUS(x,y) as shortcut of IPLUS[x/i1,y/i2]; note that 
# nesting can be applied. The mapping of the shortcut 
# uses the lexicographic order of the parameter labels.
# IPLUS has two parameters i1,i2. So, the first parameter x
# replaces the placeholder i1 and the 2nd parameter y the
# placeholder i2.

tell "
EnabledTransition in QueryClass isA Transition with
  constraint
    c1: $ forall pl/Place (pl sendsToken this) 
                 ==> (TokenNr(pl)+1 > 0)
         $
end
" 
# This query should return trans1
ask "EnabledTransition"  OBJNAMES  FRAME  Now



# Test 2: functions with more than 2 parameters
tell "
F in Function isA Integer with  
  parameter
    i1 : Integer;
    i2 : Integer;
    i3 : Integer
  constraint
    c1 : $ (this = i1+i2*i3) ) $
end 

G in Function isA Integer with  
  parameter
    i1 : Integer
  constraint
    c1 : $ (this = F(i1,2,3) )$
end 
" 

# This query should return 16
ask "G[10/i1]" OBJNAMES  FRAME  Now


# Test 3: Functions with zero parameters
tell "
ClassCount in Function isA Integer with  
   constraint
    c1 : $ (this = #Class) $
end 

ClassCountTest in Function isA Integer with  
   parameter
    i1 : Integer
   constraint
    c1 : $ (this = IDIV(ClassCount(),i1) )$
end 
" 

# This query shall return the number of classes 
ask "ClassCount" OBJNAMES  FRAME  Now
# This query shall return the number of classes divided by 10
ask "ClassCountTest[10/i1]" OBJNAMES  FRAME  Now



# Test 4: Pythagoras

tell "
ISQUARE in Function isA Integer with
  parameter
    x : Integer
  constraint
    squareformula: $ (this = x*x) $
end
Pythagoras in Function isA Integer with
  parameter
    a : Integer;
    b : Integer
  constraint
    squares: $ (~this = ISQUARE(a)+ISQUARE(b) ) $
end
" 

# This should return 25
ask "Pythagoras[3/a,4/b]" OBJNAMES  FRAME  Now




# Test 5: Real-valued functions
tell "
PercentageOfQueryClassesLong in Function isA Real with
constraint
    c: $ (this = MULT[100/r1,
                       DIV[COUNT[QueryClass/class]/r1,
                           COUNT[Class/class]/r2]/r2]) $
end
PercentageOfQueryClassesShort in Function isA Real with  
  constraint
    c : $ (this = MULT(100,DIV(COUNT(QueryClass),COUNT(Class))) ) $
end 
PercentageOfQueryClassesVeryShort in Function isA Real with  
  constraint
    c : $ (this = 100 * #QueryClass / #Class ) $
end
"

# The three query calls should yield the same result
ask "PercentageOfQueryClassesLong" OBJNAMES  FRAME  Now
ask "PercentageOfQueryClassesShort" OBJNAMES  FRAME  Now
ask "PercentageOfQueryClassesVeryShort" OBJNAMES  FRAME  Now


```

=== `Functions.sml.txt`

```telos
{
*
* File: Functions.sml
* Author: Manfred Jeusfeld
* Creation: 28-Sep-2005 (22-May-2014)
* ----------------------------------------------------------------------
* Example on user-defined functions
* Requires ConceptBase 7.1 released after 31-Mar-2008.
* Look in particular at the definition of the function ProjectNr.
* It is a user-defined function that can be used directly in
* other queries.
* You also find some of the example of the user manual included here.
*
}


Employee in Class with
  attribute
    salary: Real;
    worksfor: Project
end

Project in Class end


{* this is a user-defined function that determines the number of *}
{* projects of an employee                                       *}

ProjectNr in Function isA Integer with
  parameter
    emp: Employee
  constraint
     ccount: $ (this = COUNT_attributee(Employee!worksfor,emp)) $
end

{* this query uses the function defined above                    *}
EmployeeWithMostProjects in QueryClass isA Employee with
  constraint
    cmost: $ forall e/Employee not (this = e) ==>
               (ProjectNr(e) < ProjectNr(this)) $
end
  


{* some instances *}

bill in Employee end  {* no properties at all *}

mary in Employee with
  salary s1: 500.0
end

jane in Employee with
  salary s1: 800.0; s2: 9500.0
end

kuno in Employee with
  salary s1: 50.0; s2: 80.0; s3: 3000.0
  worksfor p1: Proj1; p2: Proj2
end

yet in Employee with
  worksfor p1: Proj1; p2: Proj2; p3: Proj3
end

Proj1 in Project end
Proj2 in Project end
Proj3 in Project end


{* from ConceptBase User Manual, section 'Computation by Functions' *}

Function PercentageOfQueryClasses isA Real with
constraint
    c: $ (this = 100 * #QueryClass / #Class) $
end


{* generalization of the above query;
     PercentageOf(QueryClass) = PercentageOfQueryClasses
*}

PercentageOf in Function isA Real with  
  parameter
    class : Proposition
  constraint
    c : $ (this = 100 * #class / #Class) $
end 





```

=== `HierMetric.sml.txt`

```telos
{*
This file is governed by the Creative Commons license
   attributeion-NonCommercial 3.0 Unported
   http://creativecommons.org/licenses/by-nc/3.0/
   http://creativecommons.org/licenses/by-nc/3.0/legalcode

Extended licenses, in particular commercial licenses, can be obtained from the
author of the source code.
Any re-distribution as source code must acknowledge the original author of this file.
*}

{
* File: HierMetric.sml 
* Author: (c) 2010 Manfred Jeusfeld
* Created: 17-Nov-2010/M.Jeusfeld (18-Nov-2010/M.Jeusfeld)
* ------------------------------------------------------
* Example of evaluating hierachical metrics
* N1 is  construct with two arguments; N3 is a construct with one argument
* N2 and N4 are constructs with no arguments. So, this is used to create
* some graphs (trees) to represent terms where N1,N2,N3,N4 are the operators.
*
* The xWeight an N2-type construct shall be 2. The xWeight of an N4-type construct is 4.
* The xWeight of an N3-type construct is 2 times the xWeight of its argument plus 1.
* Finally the xWeight of an N1-type construct shall be the xWeight of its first argument
* multiplied by the xWeight of its second argument.
* 
}

Construct with
  attribute
    part: Construct
end

N1 isA Construct end    {* has two parts *}
N2 isA Construct end    {* has no part   *}
N3 isA Construct end    {* has one part  *}
N4 isA Construct end    {* has no part   *}



{* hierarchical metric xWeight *}
Function xWeight isA Integer with
  parameter
    x: Construct
  constraint 
     cval: $ (x in N2) and (this = 2) or
             (x in N4) and (this = 4) or
             (exists n4/Construct (x in N3) and (x part/p1 n4) and (this = 2*xWeight(n4)+1)) or
             (exists n2,n3/Construct (x in N1) and (x part/p1 n2) and (x part/p2 n3) and (this = xWeight(n2)*xWeight(n3))) 
           $
end






{* A derived attribute like 'xval' can be used to display the metric values in the graph editor.
   Take this code out of comment lines to activate it.

Construct in Class with  
  attribute
    xval: Integer
  rule
    rval : $ forall n/Construct i/Integer (i = xWeight(n)) ==> (n xval i) $
end 
*}



{* The subsequent terms are put in comments. So tell them individually to
   test them.
*}


{* example term; the xWeights of the nodes are displayed in brackets

    [18=2*9]
    node1 ---> node2 [2]
      |
      -------> node3 -----> node4  [4]
               [2=2*4+1]

node1 in N1 with
  part p1: node2
  part p2: node3
end

node2 in N2 end

node3 in N3 with
  part p1: node4
end

node4 in N4 end

*}



{* another slightly larger example term 
   the top node m1 should have the value 704


m1 in N1 with
  part p1:m11; p2:m12
end

m11 in N1 with
  part p1:m3; p2: m4
end

m3 in N3 with
  part p1: m31 
end

m31 in N3 with
  part p1: m21
end

m21 in N2 end

*}


m12 in N1 with
  part p1: m41; p2: m42
end

m4 in N4 end

m41 in N4 end

m42 in N4 end




{* yet another example; this time a cyclic graph 
   results in undefined (nil) as value of the 
   constructs in the cycle

c1 in N1 with
  part p1: c2
  part p2: c3
end

c2 in N2 end

c3 in N3 with
  part p1: c1
end

*}
    

```

=== `log2.cbs.txt`

```telos
#
# File: log2.cbs
# Author: Manfred Jeusfeld
# Creation: 2012-03-12 (2012-03-12)
# ----------------------------------------------------------------------
# Compute the log with basis 2 of an integer number recursively;
# works also for large input numbers; returns empty answer if log2 is
# undefined
# Also defines log10 in a similar way.
#


#startServer -u nonpersistent -c off 
startServer -u nonpersistent -t low



tell "
log2 in Function isA Integer with
  parameter
    n: Integer
  constraint
    con: $  (n=1) and (this=0) or
            (n=2) and (this=1) or
            (n>2) and (this=log2(IDIV(n,2))+1) 
        $
end


log10 in Function isA Integer with
  parameter
    n: Integer
  constraint
    con: $  (n>=1) and (n < 10) and (this=0) or
            (n=10) and (this=1) or
            (n>2) and (this=log10(IDIV(n,10))+1) 
        $
end

power in Function isA Integer with
  parameter
    a: Integer;
    n: Integer
  constraint
    con: $  (n=0) and (this=1) or
            (n=1) and (this=a) or
            (n>1) and (this=a*power(a,n-1))
        $
end
"


ask "log2[10/n]" OBJNAMES  LABEL  Now

ask "log2[16/n]" OBJNAMES  LABEL  Now

ask "log2[1024/n]" OBJNAMES  LABEL  Now

ask "log2[0/n]" OBJNAMES  LABEL  Now

ask "log10[512/n]" OBJNAMES  LABEL  Now

ask "log10[10000000000000000/n]" OBJNAMES  LABEL  Now

ask "power(2,12)" OBJNAMES  LABEL  Now

ask "log2(power(2,12))" OBJNAMES  LABEL  Now




```

== Graph files

- `SeqNestMetric.gel`

== Shell output

```text
=== HOW-TO: define-and-use-functions ===

>>> Running ./FunctionShortcuts.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>[offline]>[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>trans1 in EnabledTransition  end 


[localhost:4001]>trans1 in EnabledTransition  end 


[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>141 in ClassCount  end 


[localhost:4001]>141 in ClassCount  end 


[localhost:4001]>14 in ClassCountTest[10/i1]  end 


[localhost:4001]>14 in ClassCountTest[10/i1]  end 


[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>25 in Pythagoras[3/a,4/b]  end 


[localhost:4001]>25 in Pythagoras[3/a,4/b]  end 


[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>60.95890410958904 in PercentageOfQueryClassesLong  end 


[localhost:4001]>60.95890410958904 in PercentageOfQueryClassesLong  end 


[localhost:4001]>60.95890410958904 in PercentageOfQueryClassesShort  end 


[localhost:4001]>60.95890410958904 in PercentageOfQueryClassesShort  end 


[localhost:4001]>60.95890410958904 in PercentageOfQueryClassesVeryShort  end 


60.95890410958904 in PercentageOfQueryClassesVeryShort  end 


[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>
>>> Running ./ackermann.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>yes
[localhost:4002]>yes
[localhost:4002]>[localhost:4002]>[localhost:4002]>3
[localhost:4002]>3
[localhost:4002]>a(2,0)=a(2,0)=[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>5
[localhost:4002]>5
[localhost:4002]>a(2,1)=a(2,1)=[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>7
[localhost:4002]>7
[localhost:4002]>a(2,2)a(2,2)==[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>61
[localhost:4002]>61
[localhost:4002]>a(3,3)=a(3,3)=[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>
>>> Running ./fib.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4003]>[localhost:4003]>Successfully connected to server
[localhost:4003]>Successfully connected to server
[localhost:4003]>[localhost:4003]>[localhost:4003]>[localhost:4003]>[localhost:4003]>[localhost:4003]>[localhost:4003]>yes
[localhost:4003]>yes
[localhost:4003]>[localhost:4003]>[localhost:4003]>55 in fib[10/n]  end 


[localhost:4003]>55 in fib[10/n]  end 


[localhost:4003]>144 in fib[12/n]  end 


[localhost:4003]>144 in fib[12/n]  end 


[localhost:4003]>6765 in fib[20/n]  end 


[localhost:4003]>6765 in fib[20/n]  end 


[localhost:4003]>280571172992510140037611932413038677189525 in fib[200/n]  end 


[localhost:4003]>280571172992510140037611932413038677189525 in fib[200/n]  end 


[localhost:4003]>[localhost:4003]>[localhost:4003]>[localhost:4003]>[localhost:4003]>
>>> Running ./fibfast.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>55
55
[localhost:4001]>[localhost:4001]>fibfast(1fibfast(10)=[localhost:4001]>0)=[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>354224848179261915075
[localhost:4001]>354224848179261915075
[localhost:4001]>fibfast(100)=[localhost:4001]>fibfast(100)=[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>43466557686937456435688527675040625802564660517371780402481729089536555417949051890403879840079255169295922593080322634775209689623239873322471161642996440906533187938298969649928516003704476137795166849228875
[localhost:4001]>43466557686937456435688527675040625802564660517371780402481729089536555417949051890403879840079255169295922593080322634775209689623239873322471161642996440906533187938298969649928516003704476137795166849228875
[localhost:4001]>fibfast(1000fibfast(1000)=[localhost:4001]>)=[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>
>>> Running ./log2.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4005]>[localhost:4005]>Successfully connected to server
[localhost:4005]>Successfully connected to server
[localhost:4005]>[localhost:4005]>[localhost:4005]>[localhost:4005]>[localhost:4005]>[localhost:4005]>[localhost:4005]>yes
[localhost:4005]>yes
[localhost:4005]>[localhost:4005]>[localhost:4005]>[localhost:4005]>[localhost:4005]>3
[localhost:4005]>3
[localhost:4005]>[localhost:4005]>[localhost:4005]>4
[localhost:4005]>4
[localhost:4005]>[localhost:4005]>[localhost:4005]>10
[localhost:4005]>10
[localhost:4005]>[localhost:4005]>[localhost:4005]>nil
[localhost:4005]>nil
[localhost:4005]>[localhost:4005]>[localhost:4005]>2
[localhost:4005]>2
[localhost:4005]>[localhost:4005]>[localhost:4005]>16
[localhost:4005]>16
[localhost:4005]>[localhost:4005]>[localhost:4005]>4096
[localhost:4005]>4096
[localhost:4005]>[localhost:4005]>[localhost:4005]>12
[localhost:4005]>12
[localhost:4005]>[localhost:4005]>[localhost:4005]>[localhost:4005]>[localhost:4005]>[localhost:4005]>[localhost:4005]>
>>> Running ./sp.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4006]>[localhost:4006]>[localhost:4006]>[localhost:4006]>yes
[localhost:4006]>yes
[localhost:4006]>[localhost:4006]>[localhost:4006]>[localhost:4006]>[localhost:4006]>yes
[localhost:4006]>yes
[localhost:4006]>[localhost:4006]>[localhost:4006]>[localhost:4006]>[localhost:4006]>yes
[localhost:4006]>yes
[localhost:4006]>[localhost:4006]>[localhost:4006]>[localhost:4006]>[localhost:4006]>yes
[localhost:4006]>yes
[localhost:4006]>[localhost:4006]>[localhost:4006]>3
[localhost:4006]>3
[localhost:4006]>[localhost:4006]>[localhost:4006]>2,3
[localhost:4006]>2,3
[localhost:4006]>[localhost:4006]>[localhost:4006]>a2
[localhost:4006]>a2
[localhost:4006]>[localhost:4006]>[localhost:4006]>a2,z,a21
[localhost:4006]>a2,z,a21
[localhost:4006]>[localhost:4006]>[localhost:4006]>yes
[localhost:4006]>yes
[localhost:4006]>[localhost:4006]>[localhost:4006]>a2,z,a21
[localhost:4006]>a2,z,a21
[localhost:4006]>[localhost:4006]>[localhost:4006]>[localhost:4006]>[localhost:4006]>
>>> cbgraph smoke: ./SeqNestMetric.gel
>>> cbgraph smoke: ./SeqNestMetric.gel
/nix/store/ppzp1jz4q8wn8hc1535y6c4v0vfwxmy4-stdenv-linux/setup: line 1947: xvfb-run: command not found
cbgraph smoke skipped (asset validation only)
cbgraph smoke skipped (asset validation only)
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
