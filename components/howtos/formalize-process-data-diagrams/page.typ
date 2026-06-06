= formalize process data diagrams

== Run

```bash
nix build .#checks.x86_64-linux.formalize-process-data-diagrams
cd components/howtos/formalize-process-data-diagrams && ./run
```

== Input

Example files in this directory (see `*.cbs.txt`, `*.sml.txt`, `*.gel`).

== Output

Successful CBShell session without server errors.
