= reify query calls

== Run

```bash
nix build .#checks.x86_64-linux.reify-query-calls
cd components/howtos/reify-query-calls && ./run
```

== Input

Example files in this directory (see `*.cbs.txt`, `*.sml.txt`, `*.gel`).

== Output

Successful CBShell session without server errors.
