= Integrate Cbshell With Regular Scripts

Verified independently via:

```bash
nix build .#checks.x86_64-linux.integrate-cbshell-with-regular-scripts
```

== Input

=== `CBshell in a pipe/FileModel.sml.txt`

```telos
{
* File: FileModel.sml
* Author: Manfred Jeusfeld
* Created: 13-Jul-2012/M.Jeusfeld (16-Jul-2012/M.Jeusfeld)
* ------------------------------------------------------
* Basic definitions for storing file info in ConceptBase
* Also defines some simple queries on files.
* 
* This requires ConceptBase 7.4
}


Directory in Class with
  attribute
    hasFileSize: Integer
end
currDir in Directory end

File in Class with
  attribute
    size: Integer
end



Directory in Class with
  rule
    fsRule: $ forall f/File fn/Label s/Integer  (f size s) and Label(f,fn)
                  ==> (currDir hasFileSize/fn s) $
end


dirSize in Function isA Integer with
  constraint
    c: $ (this = SUM_attributee(Directory!hasFileSize,currDir)) $
end
    

```

=== `CBshell in a pipe/generatedscript.cbs.txt`

```telos
startServer -port 4001 -t no
tellModel FileModel
tell "
\"FileModel.sml\" in File with size s: 742 end
\"FileModel.sml~\" in File with size s: 742 end
\"README.txt\" in File with size s: 690 end
\"README.txt~\" in File with size s: 689 end
\"dirsize\" in File with size s: 961 end
\"dirsize~\" in File with size s: 955 end
\"generatedscript.cbs\" in File with size s: 323 end
\"printfiles4cbshell\" in File with size s: 922 end
\"printfiles4cbshell~\" in File with size s: 923 end
"
ask "dirSize" OBJNAMES LABEL Now
showAnswer

```

== Shell output

```text
=== HOW-TO: integrate-cbshell-with-regular-scripts ===

>>> Running ./CBshell in a pipe/generatedscript.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>
>>> Telling ./CBshell in a pipe/FileModel.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
