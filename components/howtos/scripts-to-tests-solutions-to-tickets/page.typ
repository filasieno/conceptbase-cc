= scripts to tests solutions to tickets

== Run

```bash
nix build .#checks.x86_64-linux.scripts-to-tests-solutions-to-tickets
cd components/howtos/scripts-to-tests-solutions-to-tickets && ./run
```

== Input

Example files in this directory (see `*.cbs.txt`, `*.sml.txt`, `*.gel`).

== Output

Successful CBShell session without server errors.
