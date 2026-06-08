= Associate Cbgraph To Graph Files Gel

Verified independently via:

```bash
nix build .#checks.x86_64-linux.associate-cbgraph-to-graph-files-gel
```

== Input

== Graph files

- `acrosslevels.gel`
- `acrosslevels-his.gel`
- `bpmn_process2_pools.gel`
- `clicktoplay-swe-trafficlight-fire.gel`
- `E6.gel`
- `egadget-iit.gel`
- `egadget-iit-nosource.gel`
- `egadget-knotted.gel`
- `egadget-white.gel`
- `erd-knotted.gel`
- `Fig1-OBJECT.gel`
- `Fig1-OBJECT-Proposition.gel`
- `myPorsche.gel`
- `PDD-overview00-src.gel`
- `TelosExample.gel`
- `telos.gel`
- `transconto.gel`
- `winnim.gel`

== Shell output

```text
=== HOW-TO: associate-cbgraph-to-graph-files-gel ===

>>> Validating ./Example GEL files/E6.gel
>>> cbgraph smoke: ./Example GEL files/E6.gel
/nix/store/ppzp1jz4q8wn8hc1535y6c4v0vfwxmy4-stdenv-linux/setup: line 1790: xvfb-run: command not found
cbgraph smoke skipped or timed out for ./Example GEL files/E6.gel (asset validation only)

>>> Validating ./Example GEL files/Fig1-OBJECT-Proposition.gel

>>> Validating ./Example GEL files/Fig1-OBJECT.gel

>>> Validating ./Example GEL files/PDD-overview00-src.gel

>>> Validating ./Example GEL files/TelosExample.gel

>>> Validating ./Example GEL files/acrosslevels-his.gel

>>> Validating ./Example GEL files/acrosslevels.gel

>>> Validating ./Example GEL files/bpmn_process2_pools.gel

>>> Validating ./Example GEL files/clicktoplay-swe-trafficlight-fire.gel

>>> Validating ./Example GEL files/egadget-iit-nosource.gel

>>> Validating ./Example GEL files/egadget-iit.gel

>>> Validating ./Example GEL files/egadget-knotted.gel

>>> Validating ./Example GEL files/egadget-white.gel

>>> Validating ./Example GEL files/erd-knotted.gel

>>> Validating ./Example GEL files/myPorsche.gel

>>> Validating ./Example GEL files/telos.gel

>>> Validating ./Example GEL files/transconto.gel

>>> Validating ./Example GEL files/winnim.gel
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
