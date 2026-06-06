= Avoid Traps With Aggregation Functions in Constraints

Nix check: `#checks.x86_64-linux.avoid-traps-with-aggregation-functions-in-constraints`

== Input

=== `ClassLimit1.sml.txt`

Incorrect example of using the COUNT function in a constraint.

- Step 1: tell this file
- Step 2: tell `x3 in MyContainer end`
- ConceptBase reports no violation though the constraint is violated.
- The problem is not the constraint logic but that ConceptBase does not recognize that step 2 changes the solution of the COUNT function `#`.

=== `ClassLimit2.sml.txt`

Correct example of using the COUNT function `#` in a constraint.

- Step 1: tell this file
- Step 2: tell `x3 in MyContainer end`
- ConceptBase reports a constraint violation.
- Include predicate `(x in MyContainer)` so the constraint is evaluated when a new instance is inserted.
- A second constraint shows lower boundaries on COUNT; test by untelling `x1` or `x2`.

=== `ClassLimitMeta.sml.txt`

Two meta formulas for assigning minimum and maximum cardinalities to classes.

- Uses AL literal `(x m/n y)` for min/max cardinalities.
- `#c` is shorthand for `COUNT[c/class]`.
- Requires ConceptBase 7.1 or later.

== Shell output

```text
=== HOW-TO: avoid-traps-with-aggregation-functions-in-constraints ===

>>> Telling ./ClassLimit1.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./ClassLimit2.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./ClassLimitMeta.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
```
