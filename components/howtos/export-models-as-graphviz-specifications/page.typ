= export models as graphviz specifications

== Run

```bash
nix build .#checks.x86_64-linux.export-models-as-graphviz-specifications
cd components/howtos/export-models-as-graphviz-specifications && ./run
```

== Input

Example files in this directory (see `*.cbs.txt`, `*.sml.txt`, `*.gel`).

== Output

Successful CBShell session without server errors.
