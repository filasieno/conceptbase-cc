= Avoid Traps With Aggregation Functions in Constraints

ConceptBase aggregation functions such as `#` (COUNT) inside constraints can behave
counter-intuitively: a constraint may look correct but is not re-evaluated when new
instances change the count. This tutorial shows the trap and the fix.

== Prerequisites

- `cbserver` and `cbshell` from the Nix flake
- ConceptBase 7.1+ for the meta-level cardinality example

== Verify

```bash
nix build .#checks.x86_64-linux.avoid-traps-with-aggregation-functions-in-constraints
```

== Procedure

1. *Scenario 1 (trap):* Tell `ClassLimit1.sml.txt`, then insert `x3`. CBShell returns `yes` for both steps — no violation is reported although the upper bound is exceeded.
2. *Scenario 2 (fix):* On a fresh server, tell `ClassLimit2.sml.txt`, then insert `x3`. The second tell returns `no` (constraint violation).
3. *Scenario 3 (meta):* On a fresh server, tell `ClassLimitMeta.sml.txt` with min/max cardinalities via meta formulas.

== Input: `ClassLimit1.sml.txt`

Incorrect example: COUNT in a constraint without an instance trigger.

```telos
{
* File: ClassLimit1.sml
* Author: Manfred Jeusfeld
* Created: 21-Apr-2005/M.Jeusfeld (6-May-2008/M.Jeusfeld)
* ------------------------------------------------------
* Incorrect example of using the COUNT function in a constraint
* Step 1 : tell this file
* Step 2:  tell "x3 in  MyContainer end"
* ==> ConceptBase reports no violation though the constraint is violated.
* The problem doesn't lie in the logic of the constraint but in the fact that
* ConceptBase does not recognize that step 2 changes the solution of 
* the COUNT function '#'.
*
}

Class MyContainer with
  constraint
    c1: $ (#MyContainer < 3) $;
    c2: $ (#MyContainer > 1) $
end

x1 in MyContainer end
x2 in MyContainer end
```

== Input: `ClassLimit2.sml.txt`

Correct example: include `(x in MyContainer)` so constraints fire on insert.

```telos
{
* File: ClassLimit2.sml
* Author: Manfred Jeusfeld
* Created: 21-Apr-2005/M.Jeusfeld (6-May-2008/M.Jeusfeld)
* ------------------------------------------------------
* Correct example of using the COUNT function '#' in a constraint
* Step 1 : tell this file
* Step 2:  tell "x3 in  MyContainer end"
* ==> ConceptBase reports a constraint violation!
* The trick is to include the predicate (x in MyContainer) which
* instructs ConceptBase to evaluate the constraint whenever a new
* instance of MyContainer is inserted.
*
* A second constraint is included to show that also lower boundaries
* on COUNT can be checked incrementally. To test it, untell the object x1 or x2.
*
}

Class MyContainer with
  constraint
    c1: $ forall x/MyContainer (#MyContainer < 3) $;
    c2: $ exists x/MyContainer (#MyContainer > 1) $
end

x1 in MyContainer end
x2 in MyContainer end
```

== Input: `ClassLimitMeta.sml.txt`

Meta formulas for min/max cardinalities using AL literals `(x m/n y)`.

```telos
{
* File: ClassLimitMeta.sml
* Author: Manfred Jeusfeld
* Created: 27-Apr-2005/M.Jeusfeld (13-Nov-2012)
* ------------------------------------------------------
*
* Two meta formulas for assigning minimum and maximum cardinalities
* to classes. Uses the AL literal (x m/n y) for easy definition of min/max
* cardinalities. The expression #c is a shortcut for COUNT[c/class], i.e.
* the COUNT function counting the number of instances of a class c.
* Requires ConceptBase 7.1 or later.
*
}

MinMaxClass in Class with  
  attribute
    card : Integer
  constraint
    c1 : $ forall c/MinMaxClass m/Integer x/VAR
          (x in c) and (c card/max m)
         ==> (#c =< m) $;
    c2 : $ forall c/MinMaxClass m/Integer 
           (c card/min m)
         ==> (m = 0) or (exists x/VAR (x in c) and (#c >= m)) $;
    correctUse : $ forall c/MinMaxClass exists n,m/Integer 
                              (c card/min n) and (c card/max m) and (n <= m) $
end 

MyContainer in Class,MinMaxClass with
  card
    min: 2;
    max: 3
end

x1 in MyContainer end
x2 in MyContainer end
x3 in MyContainer end
```

== Shell output

```text
=== HOW-TO: avoid-traps-with-aggregation-functions-in-constraints ===

=== Scenario 1: incorrect COUNT constraint (trap) ===
>>> Telling ./ClassLimit1.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling x3 in MyContainer end
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>

=== Scenario 2: correct COUNT constraint ===
>>> Telling ./ClassLimit2.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling x3 in MyContainer end
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>

=== Scenario 3: meta-level cardinality formulas ===
>>> Telling ./ClassLimitMeta.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
```

== Interpretation

- *Scenario 1:* Both tells return `yes`. After inserting `x3` the instance count is 3, violating `#MyContainer < 3`, but ConceptBase does not re-check because the constraint lacks an instance trigger.
- *Scenario 2:* Loading the model succeeds (`yes`). Inserting `x3` would make the count 3 and fails the `forall` constraint — CBShell returns `no`.
- *Scenario 3:* The meta-level `MinMaxClass` constraints accept a valid model with three instances within min 2 and max 3 (`yes`).
