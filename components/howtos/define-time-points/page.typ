= define time points

== Run

```bash
nix build .#checks.x86_64-linux.define-time-points
cd components/howtos/define-time-points && ./run
```

== Input

Example files in this directory (see `*.cbs.txt`, `*.sml.txt`, `*.gel`).

== Output

Successful CBShell session without server errors.
