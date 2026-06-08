= Design Service Networks

Verified independently via:

```bash
nix build .#checks.x86_64-linux.design-service-networks
```

== Input

=== `01-SERVICE-M3.sml.txt`

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

{ 
*
* File: SERVICE-M3.sml
* Author: Manfred Jeusfeld
* Creation: 06-Mar-2010 (06-Mar-2010/M.Jeusfeld)
* ----------------------------------------------------------------------
* M3 level for the SERVICE meta model; we take our standard features for the M3 level
* Included: link semantics; semantics of single,necessary; transitive closure
*
* Copyright (C) 2010 by Manfred Jeusfeld

*
}

{* ** M3 ** *}

{* M3: our standard M3 constructs *}
NodeOrLink with
  attribute
    connectedTo: NodeOrLink
end 
Node isA NodeOrLink end
NodeOrLink!connectedTo isA NodeOrLink end

Concept isA Node end


Model isA Node with
   attribute
      contains: NodeOrLink
end



Proposition with
  attribute
    disjointTo: Proposition;   {* expresses that some classes (or attribute categories) do not share any instance *}
    reflexive:  Proposition;  {* any object is related to itself       *}
    transitive: Proposition;  {* relation is closed under transitivity *}
    symmetric: Proposition;   {* if x rel y then also y rel x          *}
    asymmetric: Proposition   {* if x rel y then not y rel x     *}
end


{* A_e(x,m,y) is like (x m y) except that it only considers explicit  *}
{* attributions between x,y. This yields much faster executable code. *}

MetaConstraints in Class with
  constraint

   disjoint_IC: $ forall pair/Proposition!disjointTo x,f,t/Proposition From(pair,f) and To(pair,t)
                    and (x in f) ==> not (x in t) $;

   asym_IC: $ forall AC/Proposition!asymmetric C/Proposition x,y/VAR M/VAR
                     P(AC,C,M,C) and (x in C) and (y in C) and
                     (x M y)  ==> not (y M x) $
  rule
   trans_R: $ forall x,z,y,M/VAR 
                     AC/Proposition!transitive C/Proposition
                     P(AC,C,M,C) and (x in C) and (y in C) and (z in C) and
                     A_e(x,M,y) and (y M z) ==> (x M z) $;
   refl_R: $ forall x,M/VAR 
                    AC/Proposition!reflexive C/Proposition
                    P(AC,C,M,C) and (x in C)
                      ==> (x M x) $;
   symm_R: $ forall x,y,M/VAR 
                    AC/Proposition!symmetric C/Proposition
                    P(AC,C,M,C) and (x in C) and (y in C) and
                    A_e(x,M,y)  ==> (y M x) $
end


{* Define a hint for the asym_IC constraint. This will be used by ConceptBase       *}
{* to generate a customized error message in case of a violation of the constraint. *}
 
MetaConstraints!asym_IC with
  comment
    hint: "The {M} relation of {C} is declared asymmetric. Hence, if (x {M} y) holds, then (y {M} x) may not hold."
end



MetaConstraints in Class with
   constraint
      singleConstraint :
          $ forall c,d/Proposition p/Proposition!single x,m/VAR
              P(p,c,m,d) and (x in c) ==>
                (
                  forall a1,a2/VAR
                    (a1 in p) and (a2 in p) and Ai(x,m,a1) and Ai(x,m,a2) ==>
                   (a1=a2)
                ) $;
      necConstraint:
          $ forall c,d/Proposition p/Proposition!necessary x,m/VAR
            P(p,c,m,d) and (x in c) ==>
             exists y/VAR (y in d) and (x m y) $
end


MetaConstraints!singleConstraint with
 comment
   hint:
"The attribute {m} of {c} is single-valued. Any instance of {c} may have at most one attribute of category {m}!"
end


MetaConstraints!necConstraint with
 comment
   hint:
"The attribute {m} of {c} is defined necessary. Any instance of {c} must have at least one instance of {d} for the attribute {m}!"
end


Proposition!attribute with
  attribute
    isTransitiveClosureOf: Proposition!attribute
end

MetaConstraints in Class with
  rule
   transR1: $ forall x,y,MA,MB/VAR 
                     A,B/Proposition!attribute C/Proposition

                     (B isTransitiveClosureOf A) and
                     P(A,C,MA,C) and P(B,C,MB,C) and 
                     (x in C) and (y in C) and 
                     (x MA y) ==> (x MB y) $;

   transR2: $ forall x,y,z,MA,MB/VAR
                     A,B/Proposition!attribute C/Proposition

                     (B isTransitiveClosureOf A) and
                     P(A,C,MA,C) and P(B,C,MB,C) and
                     (x in C) and (y in C)  and (z in C) and 
                     (x MA z) and (z MB y) ==> (x MB y) $
end


SimpleQueryClass in QueryClass isA QueryClass with
  constraint
    csup: $ forall c1,c2/Proposition :(this isA c1): and :(this isA c2): ==> (c1 = c2) $
end

complement in GenericQueryClass isA Proposition with
  parameter
    query: SimpleQueryClass
  constraint
    cc: $ exists C/Proposition :(query isA C): and (this in C) and not (this in query) $
end





```

=== `02-SERVICE-M2.sml.txt`

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

{ 
*
* File: SERVICE-M2.sml
* Author: Jeewanie Jayasinghe Arachchig, Hans Weigand, Manfred Jeusfeld
* Creation: 06-Mar-2010 (25-Mar-2010/M.Jeusfeld)
* ----------------------------------------------------------------------
* M2 level for the SERVICE meta model
*
* Copyright (C) 2010 by Jeewanie Jayasinghe Arachchig, Hans Weigand, Manfred Jeusfeld

*
}

{* ** M2 ** *}

EconomicResourceType in Concept with
  connectedTo
     stockflow: EconomicResourceType;
     flowToService: ServiceType;  
     flowToSingleService: ServiceType;
     flowToMultiService: ServiceType
end



ServiceType in Concept isA EconomicResourceType with
  connectedTo
     coordinate: ServiceType;
     flowToResource: EconomicResourceType;
     enhance: ServiceType;
     partOf: ServiceType
end


PhysicalResourceType in Concept isA EconomicResourceType end

IndividualizedResourceType in Concept isA PhysicalResourceType end
NonIndividualizedResourceType in Concept isA PhysicalResourceType end  {* for example Money *}

MoneyType in Concept isA NonIndividualizedResourceType end

ProperEconomicResourceType in QueryClass isA EconomicResourceType with
  constraint 
     unused: $ not (this in ServiceType) $
end

GoodsType in QueryClass isA EconomicResourceType with
end

IntentionalResourceType in Concept isA EconomicResourceType end



  

EconomicResourceType!flowToService isA EconomicResourceType!stockflow end
ServiceType!flowToResource isA EconomicResourceType!stockflow end
EconomicResourceType!flowToSingleService isA EconomicResourceType!flowToService end
EconomicResourceType!flowToMultiService isA EconomicResourceType!flowToService end


{* FlowServiceTypes are those service types that have at least one input and one output flow *}
{* This is used to distinguish exchange & conversion services from enhancing & coordinating  *}
{* services.                                                                                 *}

FlowServiceType in QueryClass isA ServiceType with
   constraint
     hasInOut: $ exists r1,r2/EconomicResourceType (this stockflow r1) and (r2 stockflow this) $
end


{* a sell service is a flow service that generates money from goods (all non-money resources) *}

SellServiceType in QueryClass isA FlowServiceType with
   constraint
     isSell: $ (forall rout/EconomicResourceType (this stockflow rout) ==> (rout in MoneyType) ) and
               (forall rin/EconomicResourceType (rin stockflow this) ==> (rin in GoodsType) )
             $
end

{* a buy service is a flow service that uses money to obtain goods  *}

BuyServiceType in QueryClass isA FlowServiceType with
   constraint
     exchange: $ (forall rout/EconomicResourceType (this stockflow rout) ==> (rout in GoodsType) ) and
               (forall rin/EconomicResourceType (rin stockflow this) ==> (rin in MoneyType) )
               $
end


{* an exchange service is a buy or a sell service *}

ExchangeServiceType in QueryClass isA FlowServiceType with
   constraint
     isexchange: $ (this in SellServiceType) or (this in BuyServiceType) $
end

{* a conversion service is a flow service where all inputs and outputs are goods (not money) *}

ConversionServiceType in QueryClass isA FlowServiceType with
   constraint
     allconversion: $ forall r/EconomicResourceType (this flowToResource r) or (r flowToService this) ==> (r in GoodsType) $
end


{* a coordination service is simply a service that coordinates another service *}

CoordinationServiceType in QueryClass isA ServiceType with
   constraint
     csupp: $ exists s/ServiceType (this coordinate s) $
end

{* an enhancing service is a service that enhances another service *}

EnhancingServiceType in QueryClass isA ServiceType with
   constraint
     csupp: $ exists s/ServiceType (this enhance s) $
end

{* the rest is called an "other" service *}

OtherServiceType in QueryClass isA ServiceType with
   constraint
     csupp: $ not (this in CoordinationServiceType) and not (this in EnhancingServiceType) and
              not (this in ConversionServiceType) and not (this in ExchangeServiceType) $
end


{* atomic services do not have part services *}

AtomicServiceType in QueryClass isA ServiceType with
  constraint 
     isAtomic: $ not exists s/ServiceType (s partOf this) $
end


ServiceModelElement in NodeOrLink end

EconomicResourceType isA ServiceModelElement end
EconomicResourceType!stockflow isA ServiceModelElement end
ServiceType!coordinate isA ServiceModelElement end
ServiceType!enhance isA ServiceModelElement end
ServiceType!partOf isA ServiceModelElement end

ServiceDiagram in Model,Class with   {* synonym for ComplexActivity *}
  contains
     elem: ServiceModelElement
  rule
     addflow: $ forall a/EconomicResourceType sd/ServiceDiagram link/EconomicResourceType!stockflow
                        (sd elem a) and From(link,a) ==> (sd elem link) $;
     addsupport: $ forall a/CoordinationServiceType sd/ServiceDiagram link/ServiceType!coordinate
                        (sd elem a) and From(link,a) ==> (sd elem link) $;
     addenhances: $ forall a/EnhancingServiceType sd/ServiceDiagram link/ServiceType!enhance
                        (sd elem a) and From(link,a) ==> (sd elem link) $;
     addpartof: $ forall a/EnhancingServiceType sd/ServiceDiagram link/ServiceType!partOf
                        (sd elem a) and From(link,a) ==> (sd elem link) $
end




{* some derived constructs *}

{* resource not used for any service and not refilled *}
UnusedEconomicResourceType in QueryClass isA ProperEconomicResourceType with
  constraint 
     unused: $ not exists st/ServiceType (this flowToService st) or (st flowToResource this) $
end

{* resource used but not refilled *}
EconomicResourceTypeNotRefilled in QueryClass isA ProperEconomicResourceType with
  constraint 
     unused: $ (exists st1/ServiceType (this flowToService st1)) and 
               (not exists st2/ServiceType (st2 flowToResource this)) $
end

{* resource used only refilled but not used  *}
EconomicResourceTypeOnlyRefilled in QueryClass isA ProperEconomicResourceType with
  constraint 
     unused: $ (not exists st1/ServiceType (this flowToService st1)) and 
               (exists st2/ServiceType (st2 flowToResource this)) $
end


{* Atomic service types are either 
     - enhancing
     - coordinating
     - exchanging money for goods (or vice versa)
     - converting (goods to goods)
   So, this query returns the malformed atomic service types.
*}

UnclassifiableAtomicServiceType in QueryClass isA AtomicServiceType with
  constraint
     noclass: $ not (this in CoordinationServiceType) and
                not (this in EnhancingServiceType) and
                not (this in ConversionServiceType) and
                not (this in ExchangeServiceType) 
               $
end














```

=== `03-SERVICE-M1-example.sml.txt`

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

{ 
*
* File: SERVICE-M1-example.sml
* Author: Jeewanie Jayasinghe Arachchig, Hans Weigand, Manfred Jeusfeld
* Creation: 06-Mar-2010 (06-Mar-2010/M.Jeusfeld)
* ----------------------------------------------------------------------
* M1 level: example service specification using the SERVICE notation SERVICE-M2
*
* Copyright (C) 2010 by Jeewanie Jayasinghe Arachchig, Hans Weigand, Manfred Jeusfeld

*
}

{* ** M1 ** *}

YellowPageService in ServiceType with
  enhances
    service1: ExchangeService
end

PurchaseOrderService in ServiceType with
  supports
     service1: ExchangeService 
end

Product in GoodsType with
  flowToService
     flow1: ExchangeService
end

ProduceService in ConversionServiceType with
  flowToResource
    flow2: Product
end

Parts in GoodsType with
  flowToService
    flow3: ProduceService
end


ProcurementService in ExchangeServiceType with
  flowToResource
    flow4: Product
end

ExchangeService in ExchangeServiceType with
  flowToResource
     flow5: Money
end

Money in NonIndividualGoodsType with
  flowToService
     flow6: ProcurementService
end

ProduceOrderService in ServiceType with
  supports
    service1: ProduceService
end


ProduceExchangeDiagram in ServiceDiagram with
  elem
   e1: Money;
   e2: Parts;
   e3: Product;
   e4: ExchangeService;
   e5: ProduceService;
   e6: PurchaseOrderService;
   e7: YellowPageService;
   e8: ProcurementService;
   e9: ProduceOrderService
end





```

=== `03-SERVICE-M1-fig2.sml.txt`

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

{ 
*
* File: SERVICE-M1-fig2.sml
* Author: Jeewanie Jayasinghe Arachchig, Hans Weigand, Manfred Jeusfeld
* Creation: 06-Mar-2010 (24-Mar-2010/M.Jeusfeld & J. Jayasinghe Arachchig)
* ----------------------------------------------------------------------
* M1 level: example service specification using the SERVICE notation SERVICE-M2
*
* Copyright (C) 2010 by Jeewanie Jayasinghe Arachchig, Hans Weigand, Manfred Jeusfeld

*
}

{* ** M1 ** *}

YellowPage in ServiceType with
  enhance
    service1: Exchange
end

PurchaseOrder in ServiceType with
  coordinate
     service1: Exchange
end

Product in IndividualizedResourceType with
  flowToService
     flow1: Exchange
end

Produce in ServiceType with
  flowToResource
    flow2: Product
end

Parts in IndividualizedResourceType with
  flowToService
    flow3: Produce
end


Procurement in ServiceType with
  flowToResource
    flow4: Product
end

Exchange in ServiceType with
  flowToResource
     flow5: Money
end



Money in MoneyType with
  flowToService
     flow6: Procurement
end

ProduceOrder in ServiceType with
  coordinate
    service1: Produce
end


fig2 in ServiceDiagram with
  elem
   e1: Money;
   e2: Parts;
   e3: Product;
   e4: Exchange;
   e5: Produce;
   e6: PurchaseOrder;
   e7: YellowPage;
   e8: Procurement;
   e9: ProduceOrder
end







```

=== `03-SERVICE-M1-fig3a.sml.txt`

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

{ 
*
* File: SERVICE-M1-fig3a.sml
* Author: Jeewanie Jayasinghe Arachchig, Hans Weigand, Manfred Jeusfeld
* Creation: 06-Mar-2010 (25-Mar-2010/M.Jeusfeld)
* ----------------------------------------------------------------------
* M1 level: example service specification using the SERVICE notation SERVICE-M2
*
* Copyright (C) 2010 by Jeewanie Jayasinghe Arachchig, Hans Weigand, Manfred Jeusfeld

*
}

{* ** M1 ** *}

YellowPage in ServiceType with
  enhance
    service1: TransportExchange
end

Reservation in ServiceType with
  coordinate
     service1: TransportExchange 
end


TransportExchange in ServiceType with
  flowToResource
    flow2: Money
end

Truck in PhysicalResourceType with
  flowToMultiService
    flow3: Transport
end

Transport in ServiceType with
   flowToService
     flow1: TransportExchange
end


Money in MoneyType with
end

ResourceAllocation in ServiceType with
  coordinate
    service1: Transport
end


fig3a in ServiceDiagram with
  elem
   e1: Money;
   e2: Truck;
   e4: YellowPage;
   e5: Reservation;
   e6: TransportExchange;
   e7: Transport;
   e8: ResourceAllocation
end







```

=== `03-SERVICE-M1-fig3b.sml.txt`

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


{ 
*
* File: SERVICE-M1-fig3b.sml
* Author: Jeewanie Jayasinghe Arachchig, Hans Weigand, Manfred Jeusfeld
* Creation: 06-Mar-2010 (25-Mar-2010/M.Jeusfeld)
* ----------------------------------------------------------------------
* M1 level: example service specification using the SERVICE notation SERVICE-M2
*
* Copyright (C) 2010 by Jeewanie Jayasinghe Arachchig, Hans Weigand, Manfred Jeusfeld

*
}

{* ** M1 ** *}

YellowPage in ServiceType with
  enhance
    service1: TransportExchange
end


Reservation in ServiceType with
  coordinate
     service1: TransportExchange 
end


TransportExchange in ServiceType with
  flowToResource
    flow2: Money
end

Truck in PhysicalResourceType with
  flowToService
    flow3: PackageHandling
end

Transport in ServiceType with
   flowToService
     flow1: TransportExchange
end

Package in IndividualizedResourceType with
  flowToSingleService
    flow3: Transport
end

PackageHandling in ServiceType with
   flowToResource
     flow1: Package
end

Money in MoneyType with
end

ResourceAllocation in ServiceType with
  coordinate
    service1: Transport
end


fig3b in ServiceDiagram with
  elem
   e1: Money;
   e2: Truck;
   e3: PackageHandling;
   e4: YellowPage;
   e5: Reservation;
   e6: TransportExchange;
   e7: Transport;
   e8: ResourceAllocation;
   e9: Package
end







```

=== `04-SERVICE-GT.sml.txt`

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

{ 
*
* File: SERVICE-GT.sml
* Author: Manfred Jeusfeld
* Creation: 06-Mar-2010 (10-Dec-2010/M.Jeusfeld)
* ----------------------------------------------------------------------
* Graphical types for the SERVICE notation
*
* Copyright (C) 2010 by Manfred Jeusfeld

*
}

Class SERVICE_Palette in JavaGraphicalPalette with
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
    c7: SimpleService_GT;
    c8: CoordinationService_GT;
    c10: ExchangeService_GT;
    c11: EnhancingService_GT;
    c23: ConversionService_GT;
    c25: ProperResource_GT;
    c31: Inflow_GT;
    c32: Outflow_GT;
    c33: Supports_GT;
    c34: Enhances_GT;
    d1: DefaultattributeeGT;
    d2: DefaultIsAGT;
    d3: DefaultInstanceOfGT;
    d4: QueryClassGT
rule
    rIsaGT : $ forall p/IsA (p graphtype DefaultIsAGT) $;
    rInstGT : $ forall p/InstanceOf (p graphtype DefaultInstanceOfGT) $;
    rAttrGT : $ forall p/attributee (p graphtype DefaultattributeeGT) $;
    rIndGT : $ forall p/Individual (p graphtype DefaultIndividualGT) $;
    rQueryClass : $ forall c/QueryClass (c graphtype QueryClassGT) $
end


SimpleService_GT in Class,JavaGraphicalType with
property
	bgcolor : "255,248,220";   {* cornsilk *}
	textcolor : "0,0,0";
      linecolor : "100,100,100";
	shape : "i5.cb.graph.shapes.RoundRectangle";
      linewidth : "1"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 22
rule
     gtrule: $ forall x/ServiceType In_e(x,ServiceType) ==> (x graphtype SimpleService_GT) $
end

CoordinationService_GT in Class,JavaGraphicalType with
property
	bgcolor : "244,215,0";   {* gold *}
	textcolor : "0,0,0";
      linecolor : "100,100,100";
	shape : "i5.cb.graph.shapes.RoundRectangle";
      linewidth : "1"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 24
rule
     gtrule: $ forall x/CoordinationServiceType (x graphtype CoordinationService_GT) $
end

ExchangeService_GT in Class,JavaGraphicalType with
property
	bgcolor : "218,165,32";   {* goldenrod *}
	textcolor : "0,0,0";
      linecolor : "100,100,100";
	shape : "i5.cb.graph.shapes.RoundRectangle";
      linewidth : "1"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 23
rule
     gtrule: $ forall x/ExchangeServiceType (x graphtype ExchangeService_GT) $
end

EnhancingService_GT in Class,JavaGraphicalType with
property
	bgcolor : "255,255,0";   {* yellow *}
	textcolor : "0,0,0";
      linecolor : "100,100,100";
	shape : "i5.cb.graph.shapes.RoundRectangle";
      linewidth : "1"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 23
rule
     gtrule: $ forall x/EnhancingServiceType (x graphtype EnhancingService_GT) $
end


ConversionService_GT in Class,JavaGraphicalType with
property
	bgcolor : "222,184,135";   {* burlywood *}
	textcolor : "0,0,0";
      linecolor : "100,100,100";
	shape : "i5.cb.graph.shapes.RoundRectangle";
      linewidth : "1"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 23
rule
     gtrule: $ forall x/ConversionServiceType  (x graphtype ConversionService_GT) $
end


ProperResource_GT in Class,JavaGraphicalType with
property
	bgcolor : "250,250,250";   {*  *}
	textcolor : "0,0,0";
      linecolor : "100,100,100";
	shape : "i5.cb.graph.shapes.Rect";
      linewidth : "1"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 20
rule
     gtrule: $ forall x/EconomicResourceType not (x in ServiceType) ==> (x graphtype ProperResource_GT) $
end


Inflow_GT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "100,100,200";
     edgewidth : "2";
     label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 20
  rule
     gtrule: $ forall a/EconomicResourceType!flowToService (a graphtype Inflow_GT) $
end   


Outflow_GT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "100,100,200";
     edgewidth : "2";
     label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 21
  rule
     gtrule: $ forall a/ServiceType!flowToResource (a graphtype Outflow_GT) $
end  


Supports_GT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "165,42,42";
     edgewidth : "2";
     edgestyle : "dashed";
     label : "  +"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 21
  rule
     gtrule: $ forall a/ServiceType!coordinate (a graphtype Supports_GT) $
end  

Enhances_GT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "0,100,0";
     edgewidth : "2";
     edgestyle : "dashed";
     label : "  ++"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 22
  rule
     gtrule: $ forall a/ServiceType!enhance (a graphtype Enhances_GT) $
end  




```

=== `05-SERVICE-graphviz.sml.txt`

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

{ 
*
* File: SERVICE-graphviz.sml
* Author: Manfred Jeusfeld
* Creation: 07-Mar-2010 (08-Mar-2011/M.Jeusfeld)
* ----------------------------------------------------------------------
*
* Translates a services diagram into a graph speciofication that can
* be processed by Graphviz.
*
* Copyright (C) 2010 by Manfred Jeusfeld
*
}



GraphVizType end

Dashedboxnode in GraphVizType,Class with
  rule
    r1: $ forall n/IntentionalResourceType (n in Dashedboxnode) $
end

Boxnode in GraphVizType,Class with
  rule
    r1: $ forall n/ProperEconomicResourceType not (n in IntentionalResourceType) ==> (n in Boxnode) $
end

Rboxnode in GraphVizType,Class with
  rule
    r1: $ forall n/ServiceType (n in Rboxnode) $
end


Link end

Inputlink in GraphVizType,Class isA Link with
  rule
    r1: $ forall l/EconomicResourceType!flowToService not (l in EconomicResourceType!flowToSingleService) and
                    not (l in EconomicResourceType!flowToMultiService)   ==>  (l in Inputlink) $
end

Inputlink1 in GraphVizType,Class isA Link with
  rule
    r1: $ forall l/EconomicResourceType!flowToSingleService (l in Inputlink1) $
end

Inputlink2 in GraphVizType,Class isA Link with
  rule
    r1: $ forall l/EconomicResourceType!flowToMultiService (l in Inputlink2) $
end

Outputlink in GraphVizType,Class isA Link with
  rule
    r1: $ forall l/ServiceType!flowToResource (l in Outputlink) $
end

Supportslink in GraphVizType,Class isA Link with
  rule
    r1: $ forall l/ServiceType!coordinate (l in Supportslink) $
end

Enhanceslink in GraphVizType,Class isA Link with
  rule
    r1: $ forall l/ServiceType!enhance (l in Enhanceslink) $
end


X11color end

cornsilk in X11color end
gold in X11color end
goldenrod in X11color end
darkkhaki in X11color end
burlywood in X11color end
yellow in X11color end
white in X11color end



findcolor in Function isA X11color with
  parameter
    object: EconomicResourceType
  constraint
    ccol: $ (object in OtherServiceType) and (this=goldenrod) or
            (object in EnhancingServiceType) and (this=yellow) or
            (object in ExchangeServiceType) and (this=white) or
            (object in CoordinationServiceType) and (this=white) or
            (object in ConversionServiceType) and (this=burlywood)
          $
end

findstyle in Function isA String with
  parameter
    object: EconomicResourceType
  constraint
    ccol: $ (object in OtherServiceType) and (this="rounded,solid,filled") or
            (object in MoneyType) and (this="solid") or
            (object in IntentionalResourceType) and (this="dashed") or
            (object in EnhancingServiceType) and (this="rounded,dotted") or
            (object in ExchangeServiceType) and (this="rounded,solid") or
            (object in CoordinationServiceType) and (this="rounded,dashed") or
            (object in ConversionServiceType) and (this="rounded,solid")
          $
end

findperipheries in Function isA Integer with
  parameter
    object: EconomicResourceType
  constraint
    ccol: $ (object in OtherServiceType) and (this=1) or
            (object in EnhancingServiceType) and (this=1) or
            (object in ExchangeServiceType) and (this=2) or
            (object in CoordinationServiceType) and (this=1) or
            (object in MoneyType) and (this=2) or
            (object in GoodsType) and not (object in ServiceType) and (this=1) or
            (object in ConversionServiceType) and (this=1)
          $
end


GenericQueryClass ShowServiceDiagram isA ServiceDiagram with
  required,parameter
     diagram: ServiceDiagram
  constraint
     c1: $ (diagram = this)  $
end


SERVICEDIAGRAM_FORMAT in AnswerFormat with
  forQuery q: ShowServiceDiagram
  fileType ft: "dot"
  pattern p:
"# This is the service diagram for {this}
# Graphviz code generated by {user} using ConceptBase {cb_version} at {transactiontime} 
# Process this file by Graphviz, e.g. 
#    dot -Tpng -o thisfile.png thisfile.dot

digraph {this} \{

{ASKquery(ShowElements[{this}/container,Dashedboxnode/type],DASHEDBOXNODE_FORMAT)}
{ASKquery(ShowElements[{this}/container,Boxnode/type],BOXNODE_FORMAT)}
{ASKquery(ShowElements[{this}/container,Rboxnode/type],RBOXNODE_FORMAT)}
{ASKquery(ShowElements[{this}/container,Inputlink/type],INPUTLINK_FORMAT)}
{ASKquery(ShowElements[{this}/container,Inputlink1/type],INPUTLINK1_FORMAT)}
{ASKquery(ShowElements[{this}/container,Inputlink2/type],INPUTLINK2_FORMAT)}
{ASKquery(ShowElements[{this}/container,Outputlink/type],OUTPUTLINK_FORMAT)}
{ASKquery(ShowElements[{this}/container,Supportslink/type],SUPPORTSLINK_FORMAT)}
{ASKquery(ShowElements[{this}/container,Enhanceslink/type],ENHANCESLINK_FORMAT)}

overlap=false;
rankdir=BT;
remincross=true;
fontsize=12;
fontname=Helvetica;
#splines=false;
#label=\"\\\nService diagram for {this} \"
\}
"
end




GenericQueryClass ShowElements isA ServiceDiagram with
  required,parameter
     container: ServiceDiagram;
     type: GraphVizType
  computed_attribute
     showelem: ServiceModelElement
  constraint
     c1: $ (container = this)  and
           (this elem showelem) and
           (showelem in type) $
end




DASHEDBOXNODE_FORMAT in AnswerFormat with
pattern p: "node [shape=box,style=dashed,fillcolor=white]; {Foreach( ({this.showelem}), (n), {n};)}"
end

BOXNODE_FORMAT1 in AnswerFormat with
pattern p: "node [shape=box,style=solid,fillcolor=white,peripheries={ASKquery(findperipheries[{}/object],LABEL)}]; {Foreach( ({this.showelem}), (n), {n};)}"
end

BOXNODE_FORMAT in AnswerFormat with
pattern p: "{Foreach( ({this.showelem}), (n), node [shape=box,style=solid,fillcolor=white,peripheries={ASKquery(findperipheries[{n}/object],LABEL)}]; {n};)}"
end


RBOXNODE_FORMAT in AnswerFormat with
pattern p: "{Foreach( ({this.showelem}), (n),node [shape=box,fillcolor={ASKquery(findcolor[{n}/object],LABEL)}\,style={ASKquery(findstyle[{n}/object],LABEL)}\,peripheries={ASKquery(findperipheries[{n}/object],LABEL)}];  {n};\\n)}"
end

RBOXNODE_FORMAT1 in AnswerFormat with
pattern p: "{Foreach( ({this.showelem}), (n),node [shape=box,fillcolor={ASKquery(findcolor[{n}/object],LABEL)},style={ASKquery(findstyle[{n}/object],LABEL)},peripheries={ASKquery(findperipheries[{n}/object],LABEL)}];  {n};\\n)}"
end

INPUTLINK_FORMAT in AnswerFormat with
pattern p: "{Foreach( ({this.showelem}),(l),{From({l})}->{To({l})} [color=blue,len=1.21,label=\"\"];\\n)}"
end

INPUTLINK1_FORMAT in AnswerFormat with
pattern p: "{Foreach( ({this.showelem}),(l),{From({l})}->{To({l})} [labelangle=-35,labeldistance=1.5,labelfloat=true,color=blue,len=1.21,label=\"\",headlabel=1,taillabel=N];\\n)}"
end

INPUTLINK2_FORMAT in AnswerFormat with
pattern p: "{Foreach( ({this.showelem}),(l),{From({l})}->{To({l})} [labelangle=-35,labeldistance=1.5,labelfloat=true,color=blue,len=1.21,label=\"\",headlabel=N,taillabel=M];\\n)}"
end

OUTPUTLINK_FORMAT in AnswerFormat with
pattern p: "{Foreach( ({this.showelem}),(l),{From({l})}->{To({l})} [color=blue,len=1.21,label=\"\"];\\n)}"
end

SUPPORTSLINK_FORMAT in AnswerFormat with
pattern p: "{Foreach( ({this.showelem}),(l),{From({l})}->{To({l})} [style=dashed,color=brown,len=1.20,label=\"\"];\\n)}"
end

ENHANCESLINK_FORMAT in AnswerFormat with
pattern p: "{Foreach( ({this.showelem}),(l),{From({l})}->{To({l})} [style=dashed,color=darkgreen,len=1.20,label=\"+\"];\\n)}"
end






```

== Graph files

- `fig2.gel`
- `fig3a.gel`
- `fig3b.gel`

== Shell output

```text
=== HOW-TO: design-service-networks ===

>>> Running ./startstop.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>
>>> cbgraph smoke: ./fig2.gel
>>> cbgraph smoke: ./fig2.gel
/nix/store/ppzp1jz4q8wn8hc1535y6c4v0vfwxmy4-stdenv-linux/setup: line 1948: xvfb-run: command not found
cbgraph smoke skipped (asset validation only)
cbgraph smoke skipped (asset validation only)
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
