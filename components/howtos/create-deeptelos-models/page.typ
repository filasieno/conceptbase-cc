= Create Deeptelos Models

Verified independently via:

```bash
nix build .#checks.x86_64-linux.create-deeptelos-models
```

== Input

=== `SOURCES/System-oHome-ProductExample.sml.txt`

```telos
{
* module: System-oHome-ProductExample
* -------------------------------------------------------
* This file has been extracted from a ConceptBase database.
* Copyright is with the respective authors!

* Time extracted: 2019-05-21T11:04:32,980Z (UTC) 
* Active user: jeusfeld@myon_amd64_Linux
* CBserver version: 8.0.31 (2019-05-16) 
}

{$set module=System-oHome-ProductExample}

{ 2019-05-21 11:04:29.543 }

ProductCategory  
end 

ProductModel with  
  IN
    class : ProductCategory
end 

Product with  
  IN
    class : ProductModel
end 

ProductCategory in Class  
end 

ProductModel in Class  
end 


{---} { 2019-05-21 11:04:29.929 }

ProductModel with  
  attribute
    eancode : String
end 

Product with  
  attribute
    serialnumber : String
end 


{---} { 2019-05-21 11:04:30.051 }

SmartPhoneModel in ProductCategory  
end 

CarModel in ProductCategory  
end 

iPhone8S in SmartPhoneModel  
end 

Porsche911TurboGS in CarModel  
end 


{---} { 2019-05-21 11:04:30.317 }

Product in Class  
end 


{---} { 2019-05-21 11:04:30.525 }

myPorsche911 in Porsche911TurboGS with  
  serialnumber
    sn : "sjhikdf58824358"
end 

Porsche911TurboGS with  
  eancode
    ean : "1237-3214-324-90"
end 



{ -/- }

```

=== `SOURCES/System-oHome-SimpleExample-MODEL-DATA.sml.txt`

```telos
{
* module: System-oHome-SimpleExample-MODEL-DATA
* -------------------------------------------------------
* This file has been extracted from a ConceptBase database.
* Copyright is with the respective authors!

* Time extracted: 2019-05-21T11:04:14,466Z (UTC) 
* Active user: jeusfeld@myon_amd64_Linux
* CBserver version: 8.0.31 (2019-05-16) 
}

{$set module=System-oHome-SimpleExample-MODEL-DATA}

{ 2019-05-21 11:04:11.102 }

x1 in c1 with  
  a
    a : v1
end 

v1 in d  
end 

x2 in c1  
end 

x3 in c1  
end 

y1 in c2  
end 

y2 in c2  
end 

y3 in c2  
end 



{ -/- }

```

=== `SOURCES/System-oHome-SimpleExample-MODEL.sml.txt`

```telos
{
* module: System-oHome-SimpleExample-MODEL
* -------------------------------------------------------
* This file has been extracted from a ConceptBase database.
* Copyright is with the respective authors!

* Time extracted: 2019-05-21T11:04:11,003Z (UTC) 
* Active user: jeusfeld@myon_amd64_Linux
* CBserver version: 8.0.31 (2019-05-16) 
}

{$set module=System-oHome-SimpleExample-MODEL}

{ 2019-05-21 11:04:10.686 }

c1 in C  
end 

c2 in C  
end 

M in Class  
end 

DATA in Module  
end 



{ -/- }

```

=== `SOURCES/System-oHome-SimpleExample.sml.txt`

```telos
{
* module: System-oHome-SimpleExample
* -------------------------------------------------------
* This file has been extracted from a ConceptBase database.
* Copyright is with the respective authors!

* Time extracted: 2019-05-21T11:04:10,595Z (UTC) 
* Active user: jeusfeld@myon_amd64_Linux
* CBserver version: 8.0.31 (2019-05-16) 
}

{$set module=System-oHome-SimpleExample}

{ 2019-05-21 11:04:10.302 }

C  
end 

M with  
  IN
    class : C
  attribute
    a : d
end 

d  
end 

C in Class  
end 

MODEL in Module  
end 



{ -/- }

```

=== `SOURCES/System-oHome.sml.txt`

```telos
{
* module: System-oHome
* -------------------------------------------------------
* This file has been extracted from a ConceptBase database.
* Copyright is with the respective authors!

* Time extracted: 2019-05-21T11:04:29,380Z (UTC) 
* Active user: jeusfeld@myon_amd64_Linux
* CBserver version: 8.0.31 (2019-05-16) 
}

{$set module=System-oHome}

{ 2018-10-30 12:53:56.361 }

jeusfeld in CB_User  
end 


{---} { 2019-05-21 11:04:09.735 }

Proposition with  
  attribute
    ISA : Proposition;
    IN : Proposition
end 

DeepTelosRules in Class with  
  rule
    mrule1 : $ forall m,x,c/Proposition (x in c) and (m IN c) and not (x isA m) ==> (x ISA m) $;
    mrule2 : $ forall x,c,d/Proposition (c ISA d) and (x in c)  ==> (x in d) $;
    mrule3 : $ forall c,d,m,n/Proposition (m IN c) and (n IN d) and (c ISA d)  ==> (m ISA n) $;
    mrule4 : $ forall m,x,c/Proposition (m IN c) and (x isA m) ==> (x in c) $;
    mrule5 : $ forall m,mx,x,c/Proposition (m IN c) and :(x isA mx): and (mx ISA m)  ==> (x in c) $
  constraint
    mconstr1 : $ forall x,m,c/Proposition (m IN c) and (x in c) ==> not (x in m) $
end 

XPalette in Class,JavaGraphicalPalette with  
  contains,defaultIndividual
    xx1 : DefaultIndividualGT
  contains,defaultLink
    xx2 : DefaultLinkGT
  contains,implicitIsA
    xx3 : ImplicitIsAGT
  contains,implicitInstanceOf
    xx4 : ImplicitInstanceOfGT
  contains,implicitattributee
    xx5 : ImplicitattributeeGT
  contains
    xx6 : DefaultIsAGT;
    xx7 : DefaultInstanceOfGT;
    xx8 : DefaultattributeeGT;
    xx9 : MetametaGT;
    xx10 : SimpleClassGT;
    xx11 : MetaClassGT;
    xx12 : ClassGT;
    xx13 : QueryClassGT
  rule
    inheritGTs : $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette contains gt)
                  ==> (pal contains gt) $;
    inheritDef1 : $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette defaultIndividual gt)
                  ==> (pal defaultIndividual gt) $;
    inheritDef2 : $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette defaultLink gt)
                  ==> (pal defaultLink gt) $;
    inheritDef3 : $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitIsA gt)
                  ==> (pal implicitIsA gt) $;
    inheritDef4 : $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitInstanceOf gt)
                  ==> (pal implicitInstanceOf gt) $;
    inheritDef5 : $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitattributee gt)
                  ==> (pal implicitattributee gt) $
end 

DefaultattributeeGT with  
  property
    bgcolor : "255,255,255,120"
end 

DeepTelosPalette in Class,JavaGraphicalPalette isA XPalette with  
  palproperty
    bgcolor : "255,255,255";
    longtitle : "DeepTelos rev2"
  contains,implicitInstanceOf
    sp4 : INSTOFDEDUCED_GT
end 

INSTOFDEDUCED_GT  
end 

ATTRDEDUCED_GT  
end 

DeepTelosPalette with  
  contains,implicitattributee
    sp5 : ATTRDEDUCED_GT
  contains,implicitIsA
    sp6 : ISADEDUCED_GT
end 

ISADEDUCED_GT  
end 

ISA_GT  
end 

DeepTelosPalette with  
  contains
    sp7 : ISA_GT;
    sp1 : INDIVIDUAL_GT
end 

INDIVIDUAL_GT  
end 

INSTOF_GT  
end 

DeepTelosPalette with  
  contains
    sp2 : INSTOF_GT;
    sp3 : ATTR_GT
end 

ATTR_GT  
end 

IN_Link_GT  
end 

DeepTelosPalette with  
  contains
    dt15 : IN_Link_GT;
    dt16 : SPEC_Link_GT
end 

SPEC_Link_GT  
end 

ImplicitGT_ISA  
end 

DeepTelosPalette with  
  contains
    dt17 : ImplicitGT_ISA
end 

IN_Link_GT in JavaGraphicalType,Class with  
  property
    textcolor : "0,0,0";
    edgecolor : "240,50,50";
    edgewidth : "2";
    bgcolor : "255,255,255";
    label : "IN"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBLink"
  priority
    p : 22
  rule
    gtrule : $ forall a/Proposition!IN (a graphtype IN_Link_GT) $
end 

SPEC_Link_GT in JavaGraphicalType,Class with  
  property
    bgcolor : "0,205,255";
    textcolor : "0,0,0";
    linecolor : "0,205,255";
    edgecolor : "0,205,255";
    edgewidth : "3";
    label : "ISA"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBLink"
  priority
    p : 23
  rule
    gtrule : $ forall a/Proposition!ISA (a graphtype SPEC_Link_GT) $
end 

INSTOF_GT in JavaGraphicalType,Class with  
  property
    bgcolor : "0,180,0";
    textcolor : "0,0,0";
    linecolor : "0,180,0";
    edgecolor : "0,180,0";
    edgewidth : "2";
    edgeheadshape : "Caret";
    edgestyle : "ldashed";
    label : ""
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBLink"
  priority
    p : 6
  rule
    gtrule : $ forall a/InstanceOf (a graphtype INSTOF_GT) $
end 

INSTOFDEDUCED_GT in JavaGraphicalType,Class with  
  property
    bgcolor : "0,180,0";
    textcolor : "0,0,0";
    linecolor : "0,180,0";
    edgecolor : "0,180,0";
    edgewidth : "2";
    edgeheadshape : "Caret";
    edgestyle : "dashed";
    label : ""
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBLink"
  priority
    p : 7
end 

ISA_GT in JavaGraphicalType,Class with  
  property
    bgcolor : "0,50,200";
    textcolor : "0,0,0";
    edgecolor : "50,50,240";
    edgeheadcolor : "255,255,255";
    edgeheadshape : "Arrow";
    edgewidth : "2";
    label : ""
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBLink"
  priority
    p : 6
  rule
    gtrule : $ forall a/IsA (a graphtype ISA_GT) $
end 

ISADEDUCED_GT in JavaGraphicalType,Class with  
  property
    bgcolor : "0,50,200";
    textcolor : "0,0,0";
    edgecolor : "50,50,240";
    edgewidth : "2";
    edgestyle : "dashdotted";
    label : "";
    edgeheadcolor : "255,255,255";
    edgeheadshape : "Arrow"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBLink"
  priority
    p : 7
end 

ATTR_GT in Class,JavaGraphicalType with  
  property
    textcolor : "0,0,0";
    edgecolor : "0,0,0";
    edgewidth : "2";
    fontsize : "10";
    bgcolor : "255,255,255,240"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBLink"
  priority
    p : 5
  rule
    gtrule : $ forall x/Proposition!attribute (x graphtype ATTR_GT) $
end 

ATTRDEDUCED_GT in JavaGraphicalType with  
  property
    textcolor : "0,0,0";
    edgecolor : "0,0,0";
    edgewidth : "2";
    edgestyle : "dashed";
    fontsize : "10";
    bgcolor : "255,255,255,240"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBLink"
  priority
    p : 7
end 

INDIVIDUAL_GT in Class,JavaGraphicalType with  
  property
    bgcolor : "255,255,255";
    textcolor : "0,0,0";
    linecolor : "0,0,0";
    shape : "i5.cb.graph.shapes.Rect";
    size : "resizable";
    linewidth : "1"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 5
  rule
    gtrule : $ forall x/Individual (x graphtype INDIVIDUAL_GT) $
end 

ImplicitGT_ISA in Class,JavaGraphicalType with  
  property
    bgcolor : "0,255,150";
    textcolor : "0,0,0";
    linecolor : "0,0,0";
    edgecolor : "50,50,240";
    edgewidth : "2";
    edgestyle : "dashdotted";
    label : "";
    edgeheadcolor : "255,255,255";
    edgeheadshape : "Arrow"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBLink"
  priority
    p : 20
end 

Class with  
  rule
    levelrule1 : $ forall x,c/Proposition (x IN c) ==> (c gproperty/nodelevel "-10") $;
    levelrule2 : $ forall x,c/Proposition (x IN c) ==> (x gproperty/nodelevel "-10") $;
    levelrule3 : $ forall x,c/Proposition (x IN c) ==> (c gproperty/align "top") $;
    levelrule4 : $ forall x,c/Proposition (x IN c) ==> (x gproperty/align "top") $
end 

SimpleExample in Module  
end 


{---} { 2019-05-21 11:04:29.181 }

ProductExample in Module  
end 



{ -/- }

```

== Graph files

- `deeptelos-productexample.gel`
- `deeptelos-simpleexample.gel`

== Shell output

```text
=== HOW-TO: create-deeptelos-models ===

>>> Telling ./SOURCES/System-oHome-ProductExample.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./SOURCES/System-oHome-SimpleExample-MODEL-DATA.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./SOURCES/System-oHome-SimpleExample-MODEL.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./SOURCES/System-oHome-SimpleExample.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./SOURCES/System-oHome.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
