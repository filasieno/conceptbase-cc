= Generate Business Models

Verified independently via:

```bash
nix build .#checks.x86_64-linux.generate-business-models
```

== Input

=== `sources/00-XPalette.sml.txt`

```telos
{
*
* File: 00-XPalette.sml
* Author: Manfred Jeusfeld
* Creation: 3-May-2013
* ----------------------------------------------------------------------
* 
* Extensible graphical Palette; makes life easier in dealing with ConceptBase
* graphical types
* Define additional graphical types by definining a subclass of XPalette and
* then add the new graphical types. XPalette will then make sure that 
* required builtin graphical types are automatically added.
}



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
    inheritGTs: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette contains gt)
                  ==> (pal contains gt) $;
    inheritDef1: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette defaultIndividual gt)
                  ==> (pal defaultIndividual gt) $;
    inheritDef2: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette defaultLink gt)
                  ==> (pal defaultLink gt) $;
    inheritDef3: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitIsA gt)
                  ==> (pal implicitIsA gt) $;
    inheritDef4: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitInstanceOf gt)
                  ==> (pal implicitInstanceOf gt) $;
    inheritDef5: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitattributee gt)
                  ==> (pal implicitattributee gt) $
end 



```

=== `sources/01-bmg.sml.txt`

```telos
{
*
* File: 01-bmg.sml.txt
* Author: Manfred Jeusfeld
* Creation: 28-Nov-2013 (11-Feb-2014/M.Jeusfeld)
* ----------------------------------------------------------------------
* 
* Follows the canvas of A. Osterwalder, Y. Pigneur (2010): Business Model Generation. Wiley, 2010.
}


BMG_Object with
  attribute
    link: BMG_Object;      {* general link *}
    flowTo: BMG_Object;    {* for product flows *}
    paysTo: BMG_Object;    {* for money flows*}
    causes: BMG_Object;    {* for causal links *}
    influences: BMG_Object  {* for influences *}
end

BMG_Object!flowTo isA BMG_Object!link end
BMG_Object!paysTo isA BMG_Object!link end
BMG_Object!causes isA BMG_Object!link end
BMG_Object!influences isA BMG_Object!link end


Customer isA BMG_Object end

Revenue isA BMG_Object end

CustomerRelationship isA BMG_Object end

Channel isA BMG_Object end

ValueProposition isA BMG_Object end

KeyActivity isA BMG_Object end

KeyResource isA BMG_Object end

Cost isA BMG_Object end

KeyPartner isA BMG_Object end

Balance isA BMG_Object end

```

=== `sources/02a-bmg-gts.sml.txt`

```telos
{
*
* File: 02a-bmg-gts.sml.txt
* Author: Manfred Jeusfeld
* Creation: 28-Nov-2013 (12-Feb-2014/M.Jeusfeld)
* ----------------------------------------------------------------------
* 
* Graphical types for business model objects
}

{* dark variant of the palette *}



DarkBMG_Palette in JavaGraphicalPalette isA XPalette with
  palproperty
    bgimage: "http://conceptbase.sourceforge.net/CBICONS/bgimages/bmgdark1.png"; 
    longtitle: "Business Model (dark)"
  contains
    dbmg1: Customer_GTdark;
    dbmg2: Revenue_GTdark;
    dbmg3: CustomerRelationship_GTdark;
    dbmg4: Channel_GTdark;
    dbmg5: ValueProposition_GTdark;
    dbmg6: KeyActivity_GTdark;
    dbmg7: KeyResource_GTdark;
    dbmg8: KeyPartner_GTdark;
    dbmg9: Cost_GTdark;
    dbmg10: Link_GTdark;
    dbmg11: FlowTo_GTdark;
    dbmg12: Causal_GTdark;
    dbmg13: Payment_GTdark;
    dbmg14: Influence_GTdark;
    dbmg15: PaymentRed_GTdark;
    dbmg16: Balance_GTdark
end


JavaGraphicalType isA Class end

Balance with
  graphtype gtd: Balance_GTdark
end
Balance_GTdark in JavaGraphicalType with
  property
	bgcolor : "60,60,60";
	textcolor : "240,255,255";
	linecolor : "240,255,255";
	size : "resizable";
	shape : "i5.cb.graph.shapes.Circle"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall x/Balance (x graphtype Balance_GTdark) $
end


Customer with
  graphtype gtd: Customer_GTdark
end
Customer_GTdark in JavaGraphicalType with
  property
	bgcolor : "60,60,60";
	textcolor : "240,255,255";
	linecolor : "240,255,255";
	size : "resizable";
	shape : "i5.cb.graph.shapes.Pentagon"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall C/Customer (C graphtype Customer_GTdark) $
end

Revenue with
  graphtype gtd: Revenue_GTdark
end
Revenue_GTdark in JavaGraphicalType with
  property
	bgcolor : "60,60,60";
	textcolor : "240,255,255";
	linecolor : "240,255,255";
	size : "resizable";
	shape : "i5.cb.graph.shapes.Rect"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall C/Revenue (C graphtype Revenue_GTdark) $
end

CustomerRelationship with
  graphtype gtd: CustomerRelationship_GTdark
end
CustomerRelationship_GTdark in JavaGraphicalType with
  property
	bgcolor : "60,60,60";
	textcolor : "240,255,255";
	linecolor : "240,255,255";
	size : "resizable";
	shape : "i5.cb.graph.shapes.Banner"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall C/CustomerRelationship (C graphtype CustomerRelationship_GTdark) $
end


Channel with
  graphtype gtd: Channel_GTdark
end
Channel_GTdark in JavaGraphicalType with
  property
	bgcolor : "60,60,60";
	textcolor : "240,255,255";
	linecolor : "240,255,255";
	size : "resizable";
	shape : "i5.cb.graph.shapes.House"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall C/Channel (C graphtype Channel_GTdark) $
end


ValueProposition with
  graphtype gtd: ValueProposition_GTdark
end
ValueProposition_GTdark in JavaGraphicalType with
  property
	bgcolor : "60,60,60";
	textcolor : "240,255,255";
	linecolor : "240,255,255";
	size : "resizable";
	shape : "i5.cb.graph.shapes.RoundRectangle"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall C/ValueProposition (C graphtype ValueProposition_GTdark) $
end


KeyActivity with
  graphtype gtd: KeyActivity_GTdark
end
KeyActivity_GTdark in JavaGraphicalType with
  property
	bgcolor : "60,60,60";
	textcolor : "240,255,255";
	linecolor : "240,255,255";
	size : "resizable";
	shape : "i5.cb.graph.shapes.DiRect"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall C/KeyActivity (C graphtype KeyActivity_GTdark) $
end


KeyResource with
  graphtype gtd: KeyResource_GTdark
end
KeyResource_GTdark in JavaGraphicalType with
  property
	bgcolor : "60,60,60";
	textcolor : "240,255,255";
	linecolor : "240,255,255";
	size : "resizable";
	shape : "i5.cb.graph.shapes.Hexagon"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall C/KeyResource (C graphtype KeyResource_GTdark) $
end


Cost with
  graphtype gtd: Cost_GTdark
end
Cost_GTdark in JavaGraphicalType with
  property
	bgcolor : "60,60,60";
	textcolor : "240,255,255";
	linecolor : "240,255,255";
	size : "resizable";
	shape : "i5.cb.graph.shapes.Rect"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall C/Cost (C graphtype Cost_GTdark) $
end


KeyPartner with
  graphtype gtd: KeyPartner_GTdark
end
KeyPartner_GTdark in JavaGraphicalType with
  property
	bgcolor : "60,60,60";
	textcolor : "240,255,255";
	linecolor : "240,255,255";
	size : "resizable";
	shape : "i5.cb.graph.shapes.Ellipse"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall C/KeyPartner (C graphtype KeyPartner_GTdark) $
end


Link_GTdark in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "255,255,255";
     edgecolor : "240,255,255";
     linecolor : "120,200,200";
     edgewidth : "3";
     edgestyle : "ldashed";
     bgcolor : "120,120,120";
     label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 18
  rule
     gtrule1: $ forall a/BMG_Object!link (a graphtype Link_GTdark) $
end  

Causal_GTdark in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "255,255,255";
     edgecolor : "240,255,255";
     linecolor : "120,200,200";
     edgewidth : "3";
     edgestyle : "ldashed";
     bgcolor : "200,100,100";
     label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 20
  rule
     gtrule1: $ forall a/BMG_Object!causes (a graphtype Causal_GTdark) $
end 


Influence_GTdark in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "255,255,255";
     edgecolor : "240,255,255";
     linecolor : "120,200,200";
     edgewidth : "2";
     edgestyle : "dotted";
     bgcolor : "200,100,100";
     label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 21
  rule
     gtrule1: $ forall a/BMG_Object!influences (a graphtype Influence_GTdark) $
end 


PaymentRed_GTdark in JavaGraphicalType,Class with 
  comment c: "A payment from one of our cost accounts"
  attribute,property
     textcolor : "255,255,255";
     edgecolor : "255,240,240";
     linecolor : "120,200,200";
     edgewidth : "3";
     label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 25
  rule
     gtrule1: $ forall a/BMG_Object!paysTo o/Cost From(a,o) ==> (a graphtype PaymentRed_GTdark) $
end 


Payment_GTdark in JavaGraphicalType,Class with 
  comment c: "A payment from or to somebody else"
  attribute,property
     textcolor : "255,255,255";
     edgecolor : "255,240,240";
     linecolor : "120,200,200";
     edgewidth : "3";
     label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 22
  rule
     gtrule1: $ forall a/BMG_Object!paysTo (a graphtype Payment_GTdark) $
end


FlowTo_GTdark in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "225,255,220";
     edgecolor : "240,255,255";
     linecolor : "120,200,200";
     edgewidth : "4";
     bgcolor : "140,100,210";
     label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 22
  rule
     gtrule1: $ forall a/BMG_Object!flowTo (a graphtype FlowTo_GTdark) $
end  



```

=== `sources/02-bmg-gts.sml.txt`

```telos
{
*
* File: 02-bmg-gts.sml.txt
* Author: Manfred Jeusfeld
* Creation: 28-Nov-2013 (11-Feb-2014/M.Jeusfeld)
* ----------------------------------------------------------------------
* 
* Graphical types for business model objects
}

BMG_Palette in JavaGraphicalPalette isA XPalette with
  palproperty
    bgimage: "http://conceptbase.sourceforge.net/CBICONS/bgimages/bmgcolor1.png"; 
    longtitle: "Business Model"
  contains
    bmg1: Customer_GT;
    bmg2: Revenue_GT;
    bmg3: CustomerRelationship_GT;
    bmg4: Channel_GT;
    bmg5: ValueProposition_GT;
    bmg6: KeyActivity_GT;
    bmg7: KeyResource_GT;
    bmg8: KeyPartner_GT;
    bmg9: Cost_GT;
    bmg10: Link_GT;
    bmg11: FlowTo_GT;
    bmg12: Causal_GT;
    bmg13: Payment_GT;
    bmg14: Influence_GT;
    bmg15: PaymentRed_GT;
    bmg16: Balance_GT
end


JavaGraphicalType isA Class end

Balance with
  graphtype gt: Balance_GT
end
Balance_GT in JavaGraphicalType with
  property
	bgcolor : "80,80,80";
	textcolor : "240,255,255";
	linecolor : "0,0,0";
	size : "resizable";
	shape : "i5.cb.graph.shapes.Circle"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall x/Balance (x graphtype Balance_GT) $
end


Customer with
  graphtype gt: Customer_GT
end
Customer_GT in JavaGraphicalType with
  property
	bgcolor : "243,239,130";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	size : "resizable";
	shape : "i5.cb.graph.shapes.Pentagon"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall C/Customer (C graphtype Customer_GT) $
end

Revenue with
  graphtype gt: Revenue_GT
end
Revenue_GT in JavaGraphicalType with
  property
	bgcolor : "178,184,221";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	size : "resizable";
	shape : "i5.cb.graph.shapes.Rect"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall C/Revenue (C graphtype Revenue_GT) $
end

CustomerRelationship with
  graphtype gt: CustomerRelationship_GT
end
CustomerRelationship_GT in JavaGraphicalType with
  property
	bgcolor : "150,204,153";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	size : "resizable";
	shape : "i5.cb.graph.shapes.Banner"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall C/CustomerRelationship (C graphtype CustomerRelationship_GT) $
end


Channel with
  graphtype gt: Channel_GT
end
Channel_GT in JavaGraphicalType with
  property
	bgcolor : "214,206,213";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	size : "resizable";
	shape : "i5.cb.graph.shapes.House"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall C/Channel (C graphtype Channel_GT) $
end


ValueProposition with
  graphtype gt: ValueProposition_GT
end
ValueProposition_GT in JavaGraphicalType with
  property
	bgcolor : "223,184,221";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	size : "resizable";
	shape : "i5.cb.graph.shapes.RoundRectangle"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall C/ValueProposition (C graphtype ValueProposition_GT) $
end


KeyActivity with
  graphtype gt: KeyActivity_GT
end
KeyActivity_GT in JavaGraphicalType with
  property
	bgcolor : "217,191,161";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	size : "resizable";
	shape : "i5.cb.graph.shapes.DiRect"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall C/KeyActivity (C graphtype KeyActivity_GT) $
end


KeyResource with
  graphtype gt: KeyResource_GT
end
KeyResource_GT in JavaGraphicalType with
  property
	bgcolor : "180,212,196";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	size : "resizable";
	shape : "i5.cb.graph.shapes.Hexagon"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall C/KeyResource (C graphtype KeyResource_GT) $
end


Cost with
  graphtype gt: Cost_GT
end
Cost_GT in JavaGraphicalType with
  property
	bgcolor : "214,134,134";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	size : "resizable";
	shape : "i5.cb.graph.shapes.Rect"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall C/Cost (C graphtype Cost_GT) $
end


KeyPartner with
  graphtype gt: KeyPartner_GT
end
KeyPartner_GT in JavaGraphicalType with
  property
	bgcolor : "226,185,183";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	size : "resizable";
	shape : "i5.cb.graph.shapes.Ellipse"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
  rule
     gtrule: $ forall C/KeyPartner (C graphtype KeyPartner_GT) $
end


Link_GT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "255,255,255";
     linecolor : "150,150,150";
     edgecolor : "120,120,120";
     edgewidth : "3";
     edgestyle : "ldashed";
     bgcolor : "120,120,120";
     label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 18
  rule
     gtrule1: $ forall a/BMG_Object!link (a graphtype Link_GT) $
end  

Causal_GT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "255,255,255";
     edgecolor : "200,100,100";
     edgewidth : "3";
     edgestyle : "ldashed";
     bgcolor : "200,100,100";
     label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 20
  rule
     gtrule1: $ forall a/BMG_Object!causes (a graphtype Causal_GT) $
end 


Influence_GT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "255,255,255";
     edgecolor : "180,80,80";
     edgewidth : "2";
     edgestyle : "dotted";
     bgcolor : "200,100,100";
     label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 21
  rule
     gtrule1: $ forall a/BMG_Object!influences (a graphtype Influence_GT) $
end 


PaymentRed_GT in JavaGraphicalType,Class with 
  comment c: "A payment from one of our cost accounts"
  attribute,property
     textcolor : "255,255,255";
     edgecolor : "255,50,100";
     edgewidth : "3";
     label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 25
  rule
     gtrule1: $ forall a/BMG_Object!paysTo o/Cost From(a,o) ==> (a graphtype PaymentRed_GT) $
end 


Payment_GT in JavaGraphicalType,Class with 
  comment c: "A payment from or to somebody else"
  attribute,property
     textcolor : "255,255,255";
     edgecolor : "100,50,255";
     edgewidth : "3";
     label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 22
  rule
     gtrule1: $ forall a/BMG_Object!paysTo (a graphtype Payment_GT) $
end


FlowTo_GT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "225,255,220";
     edgecolor : "80,50,140";
     edgewidth : "4";
     bgcolor : "140,100,210";
     label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 22
  rule
     gtrule1: $ forall a/BMG_Object!flowTo (a graphtype FlowTo_GT) $
end  


```

=== `sources/03-egadget.sml.txt`

```telos
{
*
* File: 03-egadget.sml.txt
* Author: Manfred Jeusfeld
* Creation: 29-Nov-2013 (11-Feb-2014/M.Jeusfeld)
* ----------------------------------------------------------------------
* 
* Adapted from A. Osterwalder, Y. Pigneur (2010): Business Model Generation. Wiley, 2010,
* p 46;
* the example is used here to highlight some features of the ConceptBase representation of
* a business model; it is not meant as a statement about some real companies
* The difference to the original model is that we add links for information and resource flows
* 
}



MassMarket in Customer end

OnlineMusicStore in Channel 
end



egadget_com in Channel with
  flowTo sale: MassMarket
end

RetailStore in Channel with
  flowTo sale: MassMarket
end

LoveMark in CustomerRelationship with
  influences mm: MassMarket
end

Advertisements in CustomerRelationship with
  influences mm: MassMarket
end

SeamlessMusicExperience in ValueProposition with
  link neededFor: Advertisements
end

largeHardewareRevenues in Revenue end
someMusicRevenues in Revenue end

HardwareDesign in KeyActivity with
  link suppliedTo: OEM
end
Marketing in KeyActivity 
end


Employee in KeyResource end

MyCompBrand in KeyResource end

eGadget_Hardware in KeyResource with
  flowTo shop: RetailStore
  flowTo eshop: egadget_com
end

ContentAgreements in KeyResource with
  influences neededFor1: SeamlessMusicExperience
  link neededFor2 : OnlineMusicStore
end

EmployeeSalary in Cost end
ManufacturingCost in Cost end
MarketingCost in Cost end
SalesCost in Cost end

balance in Balance with
  paysTo c1: EmployeeSalary
  paysTo c2: ManufacturingCost
  paysTo c3: MarketingCost
  paysTo c4: SalesCost
end


RecordCompanies in KeyPartner with
  link sign: ContentAgreements
end
OEM in KeyPartner with
 flowTo inventory: eGadget_Hardware
end

OnlineMusicStore with
  link musicfile: MassMarket
end

ManufacturingCost with
  paysTo p: OEM
end

SalesCost with
  paysTo p: OnlineMusicStore
end




MarketingCost with
  paysTo p: Marketing
end

EmployeeSalary with
  paysTo p: Employee
end


MassMarket with
  paysTo buyMusic: someMusicRevenues
  paysTo buyiPod:  largeHardewareRevenues
end

someMusicRevenues with
  paysTo bal: balance
end

largeHardewareRevenues with
  paysTo bal: balance
end



HardwareDesign with
  influences neededFor: SeamlessMusicExperience
end

MyCompBrand with
  link neededFor: LoveMark
end

Marketing with
  link neededFor: LoveMark
end






```

=== `sources/createBMGDB2.cbs.txt`

```telos
# create a database for the BusinessModelGeneration (two alternative palettes)
#
# Call: cbshell createBMGDB2.cbs


cbserver -new BMGDB2

tell 'oHome with
comment
  author: "Manfred Jeusfeld";
  title: "Business Model Canvas a la Osterwalder/Pigneur";
  date: "2014-02-12"
end
'

tellModel 01-bmg.sml.txt
tellModel 00-XPalette.sml.txt
tellModel 02-bmg-gts.sml.txt
# also load the "dark" palette
tellModel 02a-bmg-gts.sml.txt
tell "eGadgetCase in Module end"
cd eGadgetCase
tell 'eGadgetCase with
comment
  author: "Manfred Jeusfeld";
  title: "EGadget Example for the Business Model Canvas";
  date: "2014-02-11"
end
'
tellModel 03-egadget.sml.txt

```

=== `sources/createBMGDB.cbs.txt`

```telos
# create a database for the BusinessModelGeneration
#
# Call: cbshell createBMGDB.cbs


cbserver -new BMGDB

tell 'oHome with
comment
  author: "Manfred Jeusfeld";
  title: "Business Model Canvas a la Osterwalder/Pigneur";
  date: "2014-02-11"
end
'

tellModel 01-bmg.sml.txt
tellModel 00-XPalette.sml.txt
tellModel 02-bmg-gts.sml.txt
#tellModel 02a-bmg-gts.sml.txt
tell "eGadgetCase in Module end"
cd eGadgetCase
tell 'eGadgetCase with
comment
  author: "Manfred Jeusfeld";
  title: "EGadget Example for the Business Model Canvas";
  date: "2014-02-11"
end
'
tellModel 03-egadget.sml.txt

```

== Graph files

- `egadget-containerized.gel`
- `egadget-dark.gel`
- `egadget.gel`
- `egadget-white.gel`

== Shell output

```text
=== HOW-TO: generate-business-models ===

>>> Running ./sources/createBMGDB.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>no
no
[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>eGadgetCase
[localhost:4001]>eGadgetCase
[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>no
no
[localhost:4001]>[localhost:4001]>
>>> Running ./sources/createBMGDB2.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>eGadgetCase
[localhost:4001]>eGadgetCase
[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./sources/00-XPalette.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./sources/01-bmg.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./sources/02-bmg-gts.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./sources/02a-bmg-gts.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./sources/03-egadget.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
