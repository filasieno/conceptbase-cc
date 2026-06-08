= Reify Query Calls

Verified independently via:

```bash
nix build .#checks.x86_64-linux.reify-query-calls
```

== Input

=== `ticket194.cbs.txt`

```telos
#
# File: ticket194.cbs
# Author: Manfred Jeusfeld
# Created: 15-Oct-2008
# -----------------------------------
# This CBshell script tests the capabilities of reified query calls and derive expressions.
# See also ticket 194.

startServer -u nonpersistent
#enrollMe localhost 4001

tellModel $CB_HOME/examples/QUERIES/Employee_Classes
tellModel $CB_HOME/examples/QUERIES/Employee_Instances
tellModel $CB_HOME/examples/QUERIES/Employee_Queries

ask "Well_off_SI_led_Department" OBJNAMES  LABEL  Now 
ask "Well_off_SI_Manager5[100000/salary]" OBJNAMES  FRAME  Now 
ask "find_instances[GeneratedObject/class]" OBJNAMES  FRAME  Now 

#This returns objects that are instances of a derive expression
#To do so, the derive expression must be explicitly told as instance of QueryCall
#(see below)
tell "
DexpInstance in QueryClass isA Proposition with
  computed_attribute
    dexp: DeriveExpression
  constraint
    c1: $ (~this in ~dexp) $
end
"

# This first call returns 'nil': there are no derive expressions declared as
# instance of QueryCall
ask "DexpInstance" OBJNAMES  FRAME  Now

# This one is the first one
tell "Well_off_SI_Manager5[100000/salary] in QueryCall end"
# This one is rejected since there is no parameter with label sala
tell "Well_off_SI_Manager5[100000/sala] in QueryCall end"

# This one returns now Lloyd
ask "DexpInstance" OBJNAMES  FRAME  Now

# This one as well
ask "find_instances[Well_off_SI_Manager5[100000/salary]/class]" OBJNAMES  FRAME  Now

tell "
Phil in UnionMember with
  union
    PhUnion : IGM
end"

# Now, Phil is an instance of this query call
ask "find_instances[Well_off_SI_Manager5[120000/salary]/class]" OBJNAMES  FRAME  Now

# Let us memorize this query call object
tell "Well_off_SI_Manager5[120000/salary] in QueryCall end"

# Now, Phil is also returned as DexpInstance
ask "DexpInstance" OBJNAMES  FRAME  Now

# .. and of course of the respective query call
ask "find_instances[Well_off_SI_Manager5[120000/salary]/class]" OBJNAMES  FRAME  Now

# ... another sutpid query call object with an attached attribute that has
# no further effect on the evaluation
tell "IPLUS[1/i1,1/i2] in QueryCall with
  attribute
    level: SimpleClass
end"
ask "find_instances[QueryCall/class]" OBJNAMES  FRAME  Now 

# Now, '2' is also a DexpInstance
ask "DexpInstance" OBJNAMES  FRAME  Now

# ... another query call object
tell "COUNT[Class/class] in QueryCall end"

# ... that also changes the answer to DexpInstance
ask "DexpInstance" OBJNAMES  FRAME  Now




```

== Shell output

```text
=== HOW-TO: reify-query-calls ===

>>> Running ./ticket194.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>IPLUS[1/i1,1/i2] in find_instances[QueryCall/class]  end 


[localhost:4001]>IPLUS[1/i1,1/i2] in find_instances[QueryCall/class]  end 


[localhost:4001]>[localhost:4001]>[localhost:4001]>2 in DexpInstance with 
   dexp
    COMPUTED_dexp_id_2387 : IPLUS[1/i1,1/i2]
end 


[localhost:4001]>2 in DexpInstance with 
   dexp
    COMPUTED_dexp_id_2387 : IPLUS[1/i1,1/i2]
end 


[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>2 in DexpInstance with 
   dexp
    COMPUTED_dexp_id_2387 : IPLUS[1/i1,1/i2]
end 

138 in DexpInstance with 
   dexp
    COMPUTED_dexp_id_2396 : COUNT[Class/class]
end 


[localhost:4001]>2 in DexpInstance with 
   dexp
    COMPUTED_dexp_id_2387 : IPLUS[1/i1,1/i2]
end 

138 in DexpInstance with 
   dexp
    COMPUTED_dexp_id_2396 : COUNT[Class/class]
end 


[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
