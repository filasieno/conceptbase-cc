= Handle Explicit Attribution And Default Values

Verified independently via:

```bash
nix build .#checks.x86_64-linux.handle-explicit-attribution-and-default-values
```

== Input

=== `AePredicate.cbs.txt`

```telos
#
# File: AePredicate.cbs
# Author: Manfred Jeusfeld
# Creation: 9-Dec-2008 (9-Dec-2008)
# ----------------------------------------------------------------------
# This file demonstrate some of the capabilities of the A_e predicate (explicit attribution).
#
# Requires ConceptBase 7.1 released Deecember 2008
#

startServer -u nonpersistent 

# Test 1: demonstrate inheritance of attribute categories
# The bonus attribute of Manager is declared as a specialization of
# the salary attribute of Employee. Hence, any bonus is also regarded as a salary.
tell "
 Employee with
     attribute
       salary: Integer
  end
  Manager isA Employee with
     attribute
        bonus: Integer
  end
  Manager!bonus isA Employee!salary end
"

# Some test data
tell "
john in Employee with
  salary sal1: 500
end
mary in Manager with
  bonus bon1: 10000
end
"

# employees with high salary; EmployeeWithHighSal1 uses the A predicate; 
# EmployeeWithHighSal2 uses the A_e predicate; in this case they return the same answer
tell "
EmployeeWithHighSal1 in QueryClass isA Employee with
   constraint
      c1: $ exists s/Integer (this salary s) and (s > 1000) $
end
EmployeeWithHighSal2 in QueryClass isA Employee with
   constraint
      c1: $ exists s/Integer A_e(this,salary,s) and (s > 1000) $
end
"



# Query for Test 1
ask "EmployeeWithHighSal1" OBJNAMES  FRAME  Now
ask "EmployeeWithHighSal2" OBJNAMES  FRAME  Now



# Test 2: demonstrate deduction of attribute categories
# The attribute itself is explicit but its attribute category is derived
# In this case, The A_e predicate still finds the solutions

tell "
Country end
NL in Country end
UK in Country end
Taxpayer in Class with
     attribute
       income: Integer;
       premium: Integer;
       country: Country
     rule
       premrule: $ forall t/Taxpayer prem/Taxpayer!premium 
                      (t country NL) and Ai(t,premium,prem)
                    ==> (prem in Taxpayer!income) $
end  
"

tell "
marijke in Taxpayer with
  income sal: 50000
  premium pr: 3000
  country ctr: NL
end
jeff in Taxpayer with
  income sal: 20000
  premium pr: 7000
  country ctr: UK
end
"

tell "
TaxpayerWithIncome in QueryClass isA Taxpayer with
  computed_attribute
     allincome: Integer
  constraint
     c1: $ A_e(this,income,allincome) $
end
"

ask "TaxpayerWithIncome" OBJNAMES  FRAME  Now

tell "
TaxpayerWithTotalIncome in QueryClass isA Taxpayer with
  computed_attribute
     totalincome: Integer
  constraint
     c1: $ (totalincome=SUM_attributee(Taxpayer!income,this)) $
end
"

ask "TaxpayerWithTotalIncome" OBJNAMES  FRAME  Now






```

=== `DefaultValues.sml.txt`

```telos
{
*
* File: DefaultValues.sml
* Author: Manfred Jeusfeld
* Creation: 25-Jan-2008 (25-Jan-2008/MJf)
* ----------------------------------------------------------------------
*
* Default values are attributes of objects that can be overridden
* by other values.
*
* This example requires ConceptBase 7.1 released after 25-Jan-2008.
}


BankCustomer in Class with
  attribute
   accountno: Integer;
   credit: Integer;
   defaultcredit: 0
  rule
   defaultrule: $ forall b/BankCustomer dcr/Integer 
                      (BankCustomer attribute/defaultcredit dcr) and
                      (not exists cr/Integer A_e(b,credit,cr))
                   ==> (b credit dcr) $
end


{* Note: The rule

                $ forall b/BankCustomer cr,dcr/Integer   
                      (BankCustomer attribute/defaultcredit dcr) and
                      (not A_e(b,credit,cr))
                   ==> (b credit dcr) $

is not equivalent to the proper rule. It would express that any bank customer
for which some arbitrary number cr is not the explicit credit would get
the default credit.

So: not exists cr/Integer A_e(b,credit,cr) is not the same as
    exists cr/Integer not A_e(b,credit,cr)

*}





ZeroCreditCustomer in QueryClass isA BankCustomer with
  constraint
    c1: $ (~this credit 0) $
end


mary in BankCustomer with
  accountno
   a1: 1001
  credit
   mcredit: 20000
end


bill in BankCustomer with
  accountno
   a1: 2002
end


{* bill should have 0 as credit via the default rule and is thus *}
{* the only instance of ZeroCreditCustomer.                      *}







```

=== `DerivedAttribute.sml.txt`

```telos
This file is governed by the Creative Commons license
   attributeion 4.0 International
   http://creativecommons.org/licenses/by/4.0/

Extended licenses, in particular commercial licenses, can be obtained from the
author of the source code.
Any re-distribution as source code must acknowledge the original author of this file.
*}


{*
* File: Derivedattributee.sml.txt
* Author: Manfred Jeusfeld
* Created: 2024-05-22
* -------------------------------------------------------
* This example shows that Proposition!attribute can be used as for defininig derived
* attributes, i.e. without using a class-level attribute category 
*
*}




Node in Class with
   rule
    conrule: $ forall n1,n2/Node (n1 attribute/conto n2) ==> (n2 attribute/conto n1) $
end

N1 in Node with
  attribute conto: N2
end

N2 in Node end



```

== Shell output

```text
=== HOW-TO: handle-explicit-attribution-and-default-values ===

>>> Running ./AePredicate.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>mary in EmployeeWithHighSal1  end 


[localhost:4001]>mary in EmployeeWithHighSal1  end 


[localhost:4001]>mary in EmployeeWithHighSal2  end 


[localhost:4001]>mary in EmployeeWithHighSal2  end 


[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>marijke in TaxpayerWithIncome with 
   allincome
    COMPUTED_allincome_id_2440 : 50000;
    COMPUTED_allincome_id_2444 : 3000
end 

jeff in TaxpayerWithIncome with 
   allincome
    COMPUTED_allincome_id_2452 : 20000
end 


[localhost:4001]>marijke in TaxpayerWithIncome with 
   allincome
    COMPUTED_allincome_id_2440 : 50000;
    COMPUTED_allincome_id_2444 : 3000
end 

jeff in TaxpayerWithIncome with 
   allincome
    COMPUTED_allincome_id_2452 : 20000
end 


[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>
>>> Telling ./DefaultValues.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./DerivedAttribute.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
