= Model Clabjects

Verified independently via:

```bash
nix build .#checks.x86_64-linux.model-clabjects
```

== Input

=== `Baum.sml.txt`

```telos
{*
* module path: System-oHome
* -------------------------------------------------------
* Time: 2012-11-07 09:11:47 (UTC) 
* listd for: jeusfeld@EG0090
* CBserver version: 7.4.07 (2012-10-23) 
*
*}


{* for class attributes *}

BaumArt with  
  attribute
    relativeHäufigkeit : Real;
    katalogisiert : Integer;
    blattForm : String
end 


{* for instance attributes *}
Baum with  
  attribute
    standort : String;
    gepflanztDurch : Förster
end 

Förster  
end 


{* Eine class with its eigenen attributes *}
Eiche in BaumArt isA Baum with  
  relativeHäufigkeit
    anteil : 0.13
  katalogisiert
    jahr : 1762
  blattForm
    form : "gerundet"
end 

Willi in Förster  
end 

{* An instance der class Eiche, die die Instanzenattribute belegt *}
Eiche672133 in Eiche with  
  standort
    gps : "+52° 31' 16.45, +13° 21' 13.15"
  gepflanztDurch
    förster : Willi
end 


{* -/- *}

```

=== `Trees.sml.txt`

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
* File: Trees.sml.txt
* Author: Manfred Jeusfeld
* Created: 2012-11-26
* -------------------------------------------------------
* An example showing that ConceptBase does not force to
* assign a class to one of the OMG MOF levels. A class like
* Oak has instances but it is itself an instance with its
* own instance attributes. 
*
*}


{* class attributes *}

TreeType with  
  attribute
    relativeFrequency : Real;
    cataloged : Integer;
    leafForm : String
end 


{* instance attributes *}
Tree with  
  attribute
    location : String;
    plantedBy : Forester
end 

Forester  
end 


{* Oak: a class instantiating the class attributes *}
Oak in TreeType isA Tree with  
  relativeFrequency
    share: 0.13
  cataloged
    year : 1762
  leafForm
    form : "rounded"
end 

Bill in Forester  
end 

{* instance of Oak, that instantiates the instance attributes of Oak resp. TreeType *}
Oak672133 in Oak with  
  location
    gps : "+52° 31' 16.45, +13° 21' 13.15"
  plantedBy
    forester : Bill
end 


{* -/- *}

```

== Shell output

```text
=== HOW-TO: model-clabjects ===

>>> Telling ./Baum.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./Trees.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
