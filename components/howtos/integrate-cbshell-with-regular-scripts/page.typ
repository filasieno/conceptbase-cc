= integrate cbshell with regular scripts

== Run

```bash
nix build .#checks.x86_64-linux.integrate-cbshell-with-regular-scripts
cd components/howtos/integrate-cbshell-with-regular-scripts && ./run
```

== Input

Example files in this directory (see `*.cbs.txt`, `*.sml.txt`, `*.gel`).

== Output

Successful CBShell session without server errors.
