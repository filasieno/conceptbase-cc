= materialize query results as files

== Run

```bash
nix build .#checks.x86_64-linux.materialize-query-results-as-files
cd components/howtos/materialize-query-results-as-files && ./run
```

== Input

Example files in this directory (see `*.cbs.txt`, `*.sml.txt`, `*.gel`).

== Output

Successful CBShell session without server errors.
