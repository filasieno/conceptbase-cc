= Inspect The Object Base As A Whole

Verified independently via:

```bash
nix build .#checks.x86_64-linux.inspect-the-object-base-as-a-whole
```

== Input

=== `lastupdate.cbs.txt`

```telos
#
# File: lastupdate.cbs
# Author: Manfred Jeusfeld
# Creation: 4-Mar-2021 (4-Mar-2021)
# -----------------------------------
# Use a deductive rule to compute the time of the last attribute/relationship update of an object
# (c) 2021 by M. Jeusfeld. 
# This CBShell script file is licensed under CC-BY 4.0
# https://creativecommons.org/licenses/by/4.0/
#
# Run: cbshell -v lastupdate.cbs


startServer -u nonpersistent 

tell "
Proposition with
  attribute
    lastupdate: TransactionTime;
    updatetime: TransactionTime
end
"

tell "
firstUpdateTime in Function isA TransactionTime with
  required,parameter
     object: Proposition
  constraint
     mintime: $ (this = MIN_attributee(Proposition!updatetime,object)) $
end

lastUpdateTime in Function isA TransactionTime with
  required,parameter
     object: Proposition
  constraint
     maxtime: $ (this = MAX_attributee(Proposition!updatetime,object)) $
end

allUpdateTimes in GenericQueryClass isA TransactionTime with
  parameter
     object: Proposition
  constraint
     alltimes: $ (object updatetime this) $
end
"


tell "
UpdateTimeRules in Class with
  rule
   anyupdaterule: $ forall o/Proposition a/attributee n/Label y/Proposition tt/TransactionTime Pa(a,o,n,y) and Known(a,tt) ==> (o updatetime tt) $;
   lastupdaterule: $ forall o/Proposition tt/TransactionTime (tt = lastUpdateTime(o)) ==> (o lastupdate tt) $ 
end
"

# We use here 'Proposition' as test object since it is defined/updated by several transactions
ask "allUpdateTimes[Proposition/object]" OBJNAMES LABEL Now
ask "firstUpdateTime[Proposition/object]" OBJNAMES LABEL Now
ask "lastUpdateTime[Proposition/object]" OBJNAMES LABEL Now



```

=== `TimeTrace.sml.txt`

```telos
{*
* File: TimeTrace.sml
* Author: Manfred A. Jeusfeld, Tilburg University
* Date: 11-May-2006 (8-May-2008/M.Jeusfeld)
* --------------------------------------------------------
* Produces a time trace of all objects created in the object base.
* Any object in ConceptBase carries its 'transaction time', i.e. the
* time when it was told and (if applicable) the time when it was 
* untold.
* The query class TimeTrace will output all transaction times at which 
* objects were told. Each transaction time is accompanied by the list of objects
* that were created at that time. Sounds complicated? Well, this is what
* the Known predicate does!
*
* Note that ConceptBase regards transactions times to instances of
* TransactionTime.
*
* (c) 2003-2008 by M. Jeusfeld. 
* This model file is licensed under the CC-GNU GPL 
* http://creativecommons.org/licenses/GPL/2.0/
*
* Requires ConceptBase 7.1 released April 2008 or later.
* 
*}


TimeTrace in QueryClass isA TransactionTime with  
  computed_attribute
    obj : Proposition
  constraint
    con1 : $ Known(obj,this) $
end 


{* StartTimeOf returns the start time of a given object ~obj, i.e. *}
{* the time when it was told to the object base.                   *}
{* The object ~obj must be known in the object base. Note that you *}
{* can set the rollback time back to some past time in order to    *}
{* see also objects that have already been untold.                 *}


StartTimeOf in GenericQueryClass isA TransactionTime with
  parameter
    obj: Proposition
  constraint
    con1: $ Known(obj,this) $
end


{* EndTimeOf returns the "tt(infinity)" if the object still exists.  *}
{* If the object has been untold, EndTimeOf reports the time of      *}
{* untelling. Note that you need to set the rollback time to a time  *}
{* point at which the object ~obj still existed.                     *}

EndTimeOf in GenericQueryClass isA TransactionTime with
  parameter
    obj: Proposition
  constraint
    con1: $ Terminated(obj,this) $
end




```

== Shell output

```text
=== HOW-TO: inspect-the-object-base-as-a-whole ===

>>> Running ./lastupdate.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>
>>> Telling ./TimeTrace.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
