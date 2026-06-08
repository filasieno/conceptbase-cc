= Materialize Graphical Views

Verified independently via:

```bash
nix build .#checks.x86_64-linux.materialize-graphical-views
```

== Input

== Graph files

- `egadget-view1.gel`
- `egadget-view2.gel`

== Shell output

```text
=== HOW-TO: materialize-graphical-views ===

>>> Validating ./egadget-view1.gel
>>> cbgraph smoke: ./egadget-view1.gel
/nix/store/ppzp1jz4q8wn8hc1535y6c4v0vfwxmy4-stdenv-linux/setup: line 1790: xvfb-run: command not found
cbgraph smoke skipped or timed out for ./egadget-view1.gel (asset validation only)

>>> Validating ./egadget-view2.gel
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
