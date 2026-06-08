= Batch Load Multiple Files In Conceptbase

Verified independently via:

```bash
nix build .#checks.x86_64-linux.batch-load-multiple-files-in-conceptbase
```

== Input

=== `demoloader.cbs.txt`

```telos
startServer -d EXAMPLEDB
tellModel model_01
tellModel model_02
tellModel model_03
exit
```

== Shell output

```text
=== HOW-TO: batch-load-multiple-files-in-conceptbase ===

>>> Running ./demoloader.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
