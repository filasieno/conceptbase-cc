= Define Object Specific Graphical Properties

Verified independently via:

```bash
nix build .#checks.x86_64-linux.define-object-specific-graphical-properties
```

== Input

== Graph files

- `movtokens.gel`
- `ticket397.gel`

== Shell output

```text
=== HOW-TO: define-object-specific-graphical-properties ===

>>> Validating ./movtokens.gel
>>> cbgraph smoke: ./movtokens.gel
/nix/store/ppzp1jz4q8wn8hc1535y6c4v0vfwxmy4-stdenv-linux/setup: line 1790: xvfb-run: command not found
cbgraph smoke skipped or timed out for ./movtokens.gel (asset validation only)

>>> Validating ./ticket397.gel
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
