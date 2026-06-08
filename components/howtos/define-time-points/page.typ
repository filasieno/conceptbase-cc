= Define Time Points

Verified independently via:

```bash
nix build .#checks.x86_64-linux.define-time-points
```

== Input

=== `time-simu.sml.txt`

```telos
{
*
* File: time-simu.sml
* Author: Manfred Jeusfeld
* Creation: 2-Dec-2002 (3-Dec-2002/M.Jeusfeld)
* ----------------------------------------------------------------------
* Small example for user-defined time attributes.
* You can interpret the values for starttime/endtime as the number of time
* units (e.g. days) that have passed since an arbiratry zero time.
* Thereby, the standard comparison attributes '<', '>' etc. become applicable.
* COPYRIGHT NOTICE: Copying and non-commercial use permitted for licencees of
* ConceptBase. When used, a citation of this document is required.
}


{* We define starttime/endtime as properties of the most
   general class 'Proposition'. That allows us to attach
   starttime/endtime to any object in the database.
   Use Integer instead of Real when discrete time points are
   more appropriate in your application.
*}

Proposition with
  attribute,single
    starttime: Real;
    endtime: Real
end


{* If you require to have the single-valuedness of starttime/endtime
   checked by the system, then include the following definition taken from the
   ConceptBase User Manual

Class with
  constraint 
   singleConstraint :  $ forall p/Proposition!single c,d/Class x,m/VAR 
        In(p,Proposition!single) and P(p,c,m,d) and In(x,c)  ==> 
        forall y1,y2/VAR 
        In(y1,d) and In(y2,d) and A(x,m,y1) and A(x,m,y2) ==>  
                 IDENTICAL(y1, y2) $
end

*}



{* Example usage for the time attributes.
   Note that the instances of COMPONENT can use starttime/endtime
   because they are also instances of Proposition via a builtin
   O-Telos axiom.
*}

COMPONENT in Class with
  attribute
    subcomp: COMPONENT
end


comp1 in COMPONENT with
  subcomp c1: comp11; c2: comp12
  starttime st: 3.88
end

comp11 in COMPONENT with
  starttime st: 10.23
  endtime  et: 45.67
end

comp12 in COMPONENT with
  starttime st: 21.02
end

DeadComponent in QueryClass isA COMPONENT with
  constraint
     c: $ exists t/Real (~this endtime t) $
end


OlderComponent in GenericQueryClass isA COMPONENT with
  parameter
    than: COMPONENT
  constraint
     c: $ exists t1,t2/Real (~this starttime t1) and (~than starttime t2) and
             (t1 < t2) $
end


{* It should be easy to define further generic query classes to check
   basically any possible relationship between intervals starttime/endtime.
*}

```

== Shell output

```text
=== HOW-TO: define-time-points ===

>>> Telling ./time-simu.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
