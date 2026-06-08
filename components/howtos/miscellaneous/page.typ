= Miscellaneous

Verified independently via:

```bash
nix build .#checks.x86_64-linux.miscellaneous
```

== Input

=== `cc.sml.txt`

```telos
{
*
* File: cc.sml
* Author: Manfred Jeusfeld
* Creation: 28-Jun-2004 (4-Nov-2008)
* ----------------------------------------------------------------------
* This example shows a model that can be told to ConceptBase when
* the flag -cc (predicate typing) is set to 'off'. It does violate
* the formula assignment restriction since the predicate (this friend p)
* is not linked to an attribute of Person.
* The violation is not a big problem since this and p still must be
* instances of Person. However, the 'strict' setting for predicate typing
* still disallows it to avoid semantic misinterpretations.
* In fact, when referring to 'friend' in the query PersonWithFriend, one
* should assume that this attribute stems from 'Person' since this is the only 
* class that we have specified as superclass of the query. The strict mode 
* enables ConceptBase to bind the predicates statically to the class
* definitions and to generate error messages when a violation is found.
}



Person end

QueryClass PersonWithFriend isA Person with
  constraint
    c1: $ exists p/Person (~this friend p) $
end

Alien with
  attribute
   friend: Alien
end

R2D2 in Alien,Person with
  friend
    f1: E_T
end

E_T in Alien,Person end

BlueMonster in Alien with
  friend
    f1: R2D2
end






```

== Shell output

```text
=== HOW-TO: miscellaneous ===

>>> Telling ./cc.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
