= analyze graphs

== Run

```bash
nix build .#checks.x86_64-linux.analyze-graphs
cd components/howtos/analyze-graphs && ./run
```

== Input

Example files in this directory (see `*.cbs.txt`, `*.sml.txt`, `*.gel`).

== Output

Successful CBShell session without server errors.
