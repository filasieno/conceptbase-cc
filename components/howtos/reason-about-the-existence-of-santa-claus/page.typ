= Reason About The Existence Of Santa Claus

Verified independently via:

```bash
nix build .#checks.x86_64-linux.reason-about-the-existence-of-santa-claus
```

== Input

=== `01-sinterklaas.sml.txt`

```telos
{
*
* File: 01-sinterklaas.sml
* Author: Manfred Jeusfeld
* Creation: 2-Dec-2002 (1-Dec-2004/M.Jeusfeld)
* ----------------------------------------------------------------------
* This is a story that relates sinterklaas to meta modeling. See file
* README.txt for some more explanation.
* COPYRIGHT NOTICE: Copying and non-commercial use permitted for licencees of
* ConceptBase. When used, a citation of this document is required.
}


{* a small meta model for delivery of things *}

Class Agent with
 attribute
   delivers: Agent
end

Class Thing end

attributee Agent!delivers with
  attribute
    object: Thing
end


{* a small model using the meta model to represent what sinterklaas does *}
{* for persons.                                                          *}


Agent Sinterklaas with
  delivers
    sinterklaas_visit: Person
end

Sinterklaas!sinterklaas_visit with
  object
    withGift: Gift
end
    

Agent Person with
end

Thing Gift with end

{* now some constraints for sinterklaas *}

Class Sinterklaas with
  constraint
    {* there is a sinterklaas *}
    c1: $ exists s/Proposition (s in Sinterklaas) $;

    {* there are no two sinterklaas *}
    c2: $ forall s1,s2/Sinterklaas IDENTICAL(s1,s2) $; 

    {* when sinterklaas comes then not with empty hands *}
    c3: $ forall visit/Sinterklaas!sinterklaas_visit
              exists g/Gift (visit withGift g) $

end

HappyPerson in QueryClass isA Person with
  constraint
    c: $ exists visit/Sinterklaas!sinterklaas_visit g/Gift 
          To(visit,~this) and (visit withGift g) $
end


{* instance level data for the sinterklaas model *}

Sinterklaas THE_SINTERKLAAS with
  sinterklaas_visit
    toP1: Mary;
    toP2: Tommy
end

Mary in Person end
Tommy in Person end  
Manfred in Person end

Gift TeddyBear with end
Gift BabyKitchen with end

THE_SINTERKLAAS!toP1 with
  withGift gift1: TeddyBear
end

THE_SINTERKLAAS!toP2 with
  withGift gift1: BabyKitchen
end


```

=== `02-sc-gts.sml.txt`

```telos
{
*
* File: 02-sc-gts.sml
* Author: Manfred Jeusfeld
* Creation: 1-Dec-2004 (22-Oct-2014/M.Jeusfeld)
* ----------------------------------------------------------------------
* Graph types for the sinterklaas story.
* COPYRIGHT NOTICE: Copying and non-commercial use permitted for licencees of
* ConceptBase. When used, a citation of this document is required.
}


Class Sinterklaas_Palette in JavaGraphicalPalette with
palproperty
	bgcolor: "250,235,235"
contains,defaultIndividual
	c1 : DefaultIndividualGT
contains,defaultLink
	c2 : DefaultLinkGT
implicitIsA, contains
    c3 : ImplicitIsAGT
implicitInstanceOf, contains
    c4 : ImplicitInstanceOfGT
implicitattributee, contains
    c5 : ImplicitattributeeGT
contains
      c6: SinterGT;
      c7: HappyPersonGT;
      c8: UnhappyPersonGT;
      c9: GiftGT;
      c10: visitsGT;
      c11: withGT;
      c14: DefaultIsAGT;
      c15: DefaultInstanceOfGT;
      c16: DefaultattributeeGT;
      c17: QueryClassGT
rule
    rIsaGT : $ forall p/IsA (p graphtype DefaultIsAGT) $;
    rInstGT : $ forall p/InstanceOf (p graphtype DefaultInstanceOfGT) $;
    rAttrGT : $ forall p/attributee (p graphtype DefaultattributeeGT) $;
    rIndGT : $ forall p/Individual (p graphtype DefaultIndividualGT) $;
    rQueryClass : $ forall c/QueryClass (c graphtype QueryClassGT) $
end

DefaultattributeeGT with
  property
    bgcolor: "250,235,235,200"
end


Class SinterGT in JavaGraphicalType with
rule
        gtrule : $ forall p/Sinterklaas
                      (p graphtype SinterGT) $
property
   textcolor : "0,0,0";
   linecolor : "0,0,0";
   size: "resizable";
   image : "http://conceptbase.sourceforge.net/CBICONS/RealSinterklaas.png" 
{*   image : "http://infolab.uvt.nl/~jeusfeld/conceptbase.cc/CBICONS/sinterklaas.png" *}
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 26
end

Class HappyPersonGT in JavaGraphicalType with
rule
        gtrule : $ forall p/HappyPerson
                      (p graphtype HappyPersonGT) $
property
   textcolor : "0,0,0";
   bgcolor : "240,240,240";
   linecolor : "0,0,0";
   size: "resizable";
   image : "http://conceptbase.sourceforge.net/CBICONS/happy.png"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 27
end

Class UnhappyPersonGT in JavaGraphicalType with
rule
        gtrule : $ forall p/Person not (p in HappyPerson) ==>
                      (p graphtype UnhappyPersonGT) $
property
   textcolor : "0,0,0";
   bgcolor : "240,240,240";
   linecolor : "0,0,0";
   size: "resizable";
   image : "http://conceptbase.sourceforge.net/CBICONS/frust.png"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 28
end


Class GiftGT in JavaGraphicalType with
rule
        gtrule : $ forall g/Gift
                      (g graphtype GiftGT) $
property
   textcolor : "0,0,0";
   bgcolor : "240,240,240";
   linecolor : "0,0,0";
   size: "resizable";
   image : "http://conceptbase.sourceforge.net/CBICONS/gift.png"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 29
end


visitsGT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "250,80,80";
     edgewidth : "6";
     label : "";
     bgcolor : "180,40,40"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 8
  rule
     gtrule1: $ forall s/Sinterklaas!sinterklaas_visit (s graphtype visitsGT) $
end 

withGT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "250,80,80";
     edgewidth : "4";
     label : "";
     bgcolor : "180,40,40";
     edgestyle : "dashdotted"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 8
  rule
     gtrule1: $ forall s/Sinterklaas!sinterklaas_visit!withGift (s graphtype withGT) $
end 




```

=== `03-makemehappy.sml.txt`

```telos
{* this will make Manfred happy *}

THE_SINTERKLAAS in Sinterklaas with 
 sinterklaas_visit
     toP3 : Manfred
end 

THE_SINTERKLAAS!toP3 with
  withGift g1: WidescreenColorMobilePhone
end

WidescreenColorMobilePhone in Gift end 

```

== Graph files

- `sinter-new.gel`

== Shell output

```text
=== HOW-TO: reason-about-the-existence-of-santa-claus ===

>>> Telling ./01-sinterklaas.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./02-sc-gts.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./03-makemehappy.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
