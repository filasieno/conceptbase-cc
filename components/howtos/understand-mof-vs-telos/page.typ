= Understand Mof Vs Telos

Verified independently via:

```bash
nix build .#checks.x86_64-linux.understand-mof-vs-telos
```

== Input

=== `MOF_Telos_Levels.sml.txt`

```telos
{*
This file is governed by the Creative Commons license
   attributeion-NonCommercial 3.0 Unported
   http://creativecommons.org/licenses/by-nc/3.0/
   http://creativecommons.org/licenses/by-nc/3.0/legalcode

Extended licenses, in particular commercial licenses, can be obtained from the
author of the source code.
Any re-distribution as source code must acknowledge the original author of this file.
*}

{*
* File MOF_Telos_Levels.sml
* Author: Manfred Jeusfeld
* Date: 2012-02-16 (2012-02-23)
*----------------------------------------------------------------
* This model computes the "MOF Level" of Telos statements.
* Telos does not enforce the MOF levels (M0,M1,M2,M3,..) but
* one can superimpose them on Telos. Here, we define two queries
* NoMOF and MultiMOF to return those Telos statements that do not
* have a MOF level or that have multiple levels according to some
* axiomatization of MOF levels.
* The query OneMOF returns all statements that have exactly one MOF level.
*
*}

{* The class STATEMENT provides the capabilities to represent all 4 MOF levels         *}
{* M0,..,M3. The moflevel is attached to designate the MOF level. The attribute mofrel *}
{* is used for associations/links between statements at the same MOF level.            *}
{* The attribute mofinstanceOf is for declaring one statement to be the instance of    *}
{* another statement. We do not use the Telos 'in' here to avoid inheriting its        *}
{* semantics. *}

STATEMENT in Class with
  attribute
    moflevel: Integer;    {* 3=M3, 2=M2, 1=M1, 0 =M0 *}
    mofrel: STATEMENT;
    mofinstanceOf: STATEMENT
  rule
    levelOfInstance: $ forall x,c/STATEMENT m,n/Integer (x mofinstanceOf c) and (c moflevel m) and (n = m-1) 
                          and (n >= 0) ==> (x moflevel n) $;
    levelOfDestination: $ forall x,y/STATEMENT m/Integer (x mofrel y) and (x moflevel m) ==> (y moflevel m) $;
    levelOfSource: $ forall x,y/STATEMENT m/Integer (x mofrel y) and (y moflevel m) ==> (x moflevel m) $
end


NoMOF in QueryClass isA STATEMENT with
  constraint
    nomof: $ not exists n/Integer (this moflevel n) $
end

MultiMOF in QueryClass isA STATEMENT with
  constraint
    multimof: $ exists n1,n2/Integer (this moflevel n1) and (this moflevel n2) 
                and (n1 <> n2) $
end

OneMOF in QueryClass isA STATEMENT with
  constraint
    multimof: $ not (this in NoMOF) and not (this in MultiMOF) $
end



{* Micro MOF example *}

{* M3 *}
MOF_Class in STATEMENT with
  moflevel l: 3
end


{* M2 *}
UML_Class in STATEMENT with
  mofinstanceOf c: MOF_Class
end

UML_Association in STATEMENT with
  mofinstanceOf c: MOF_Class
  mofrel
    roleLink: UML_Class
end


{* M1 *}
Employee in STATEMENT with
  mofinstanceOf c: UML_Class
end

Project in STATEMENT with
  mofinstanceOf c: UML_Class
end

worksFor in STATEMENT with
  mofinstanceOf c: UML_Association
  mofrel
     r1: Employee;
     r2: Project
end


{* M0 *}
bill in STATEMENT with
  mofinstanceOf c: Employee
end



{* illegal mofrel between different levels;
   this frame causes UM__Association to have
   multiple MOF levels
     M2: because it is an instance of MOF_Class
     M1: because it relates to worksFor, which is at M1
*}

UML_Association with
  mofrel
    example: worksFor
end







```

=== `MOF_Telos.sml.txt`

```telos
{*
This file is governed by the Creative Commons license
   attributeion-NonCommercial 3.0 Unported
   http://creativecommons.org/licenses/by-nc/3.0/
   http://creativecommons.org/licenses/by-nc/3.0/legalcode

Extended licenses, in particular commercial licenses, can be obtained from the
author of the source code.
Any re-distribution as source code must acknowledge the original author of this file.
*}

{*
* File MOF_Telos.sml
* Author: Manfred Jeusfeld
* Date: 2012-02-16 (2012-02-17)
*----------------------------------------------------------------
* This models shows how the strict instantiation of MOF
* can be enforced by integrity constraints of Telos.
* Not telling the MOFconstraints enables you to
* link objects from different MOF levels. 
* The example also shows, that Telos has no problem to
* represent statements at any abstraction level in a single
* model.
*
*}

{* The class STATEMENT provides the capabilities to represent all 4 MOF levels         *}
{* M0,..,M3. The moflevel is attached to designate the MOF level. The attribute mofrel *}
{* is used for associations/links between statements at the same MOF level.            *}
{* The attribute mofinstanceOf is for declaring one statement to be the instance of    *}
{* another statement. We do not use the Telos 'in' here to avoid inheriting its        *}
{* semantics. *}

STATEMENT in Class with
  attribute
    moflevel: Integer;    {* 3=M3, 2=M2, 1=M1, 0 =M0 *}
    mofrel: STATEMENT;
    mofinstanceOf: STATEMENT
end

MOFconstraints in Class with
  constraint
     strictInstantiation: $ forall x,c/STATEMENT m,n/Integer 
                              (x mofinstanceOf c) and (c moflevel m) and (n = m-1) ==> (x moflevel n) $;
     strictRelations: $ forall x,y/STATEMENT m/Integer 
                              (x mofrel y) and (x moflevel m) ==> (y moflevel m) $
end



{* Micro MOF example *}

{* M3 *}
MOF_Class in STATEMENT with
  moflevel l: 3
end


{* M2 *}
UML_Class in STATEMENT with
  mofinstanceOf c: MOF_Class
  moflevel l: 2
end

UML_Association in STATEMENT with
  mofinstanceOf c: MOF_Class
  moflevel l: 2
  mofrel
    roleLink: UML_Class
end


{* M1 *}
Employee in STATEMENT with
  mofinstanceOf c: UML_Class
  moflevel l: 1
end

Project in STATEMENT with
  mofinstanceOf c: UML_Class
  moflevel l: 1
end

worksFor in STATEMENT with
  mofinstanceOf c: UML_Association
  moflevel l: 1
  mofrel
     r1: Employee;
     r2: Project
end


{* M0 *}
bill in STATEMENT with
  mofinstanceOf c: Employee
  moflevel l: 0
end



{* illegal mofrel between different levels;
   tell this frame to see that the strict instantiation
   is violated

UML_Association with
  mofrel
    example: worksFor
end
*}







```

== Shell output

```text
=== HOW-TO: understand-mof-vs-telos ===

>>> Telling ./MOF_Telos.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./MOF_Telos_Levels.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
