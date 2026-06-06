= batch load multiple files in conceptbase

== Run

```bash
nix build .#checks.x86_64-linux.batch-load-multiple-files-in-conceptbase
cd components/howtos/batch-load-multiple-files-in-conceptbase && ./run
```

== Input

Example files in this directory (see `*.cbs.txt`, `*.sml.txt`, `*.gel`).

== Output

Successful CBShell session without server errors.
