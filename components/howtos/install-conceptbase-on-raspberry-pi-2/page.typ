= install conceptbase on raspberry pi 2

== Run

```bash
nix build .#checks.x86_64-linux.install-conceptbase-on-raspberry-pi-2
cd components/howtos/install-conceptbase-on-raspberry-pi-2 && ./run
```

== Input

Example files in this directory (see `*.cbs.txt`, `*.sml.txt`, `*.gel`).

== Output

Successful CBShell session without server errors.
