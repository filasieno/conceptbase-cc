= create large test models

== Run

```bash
nix build .#checks.x86_64-linux.create-large-test-models
cd components/howtos/create-large-test-models && ./run
```

== Input

Example files in this directory (see `*.cbs.txt`, `*.sml.txt`, `*.gel`).

== Output

Successful CBShell session without server errors.
