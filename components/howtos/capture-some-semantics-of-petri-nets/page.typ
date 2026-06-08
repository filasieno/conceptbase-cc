= Capture Some Semantics Of Petri Nets

Verified independently via:

```bash
nix build .#checks.x86_64-linux.capture-some-semantics-of-petri-nets
```

== Input

=== `Petri Net Analysis/01-PetriNets.sml.txt`

```telos
{
* File: 01-PetriNets.sml
* Author: Manfred Jeusfeld, Students of MethEng 2004 course
* Created: 2-Nov-2004/M.Jeusfeld (1-Apr-2008/M.Jeusfeld)
* ------------------------------------------------------
* Notation for petri nets plus definition of enabled transition,
* dead state, and next state.
* Requires ConceptBase 7.1 (released April 2008 or later)!!
* Defines TokenNr as a function to allow simpler definition of
* EnabledTransition.
*
}


{* ------------------------------------------------------------------ *}

{* **** Notation Definition Level **** *}
{* defines extensions to O-Telos to be *}
{* more capable for defining notations *}
{* ****      ---------------      **** *}


Node with
  attribute   
    connectedTo: Node
end

Model isA Node with
   attribute
      contains: Node
end


{* Define single/necessary (adapted from ConceptBase user manual) *}

Class with constraint, attribute
  necConstraint:
    $ forall p/Proposition!necessary c,d/Proposition x,m/VAR 
      P(p,c,m,d) and In(x,c) ==> 
         exists y/VAR  In(y,d) and A(x,m,y) $;
  singleConstraint : 
   $ forall p/Proposition!single c,d/Proposition x,m/ VAR 
     In(p,Proposition!single) and P(p,c,m,d) and In(x,c)  ==> 
        forall y1,y2/VAR 
        In(y1,d) and In(y2,d) and A(x,m,y1) and A(x,m,y2) ==>  
                 IDENTICAL(y1, y2) $
end 

{* The link 'isTransitiveClosureOf' shall be used to     *}
{* declare some attribute B to be the transitive closure *}
{* of some attribute A.                                  *}

Proposition!attribute with
  attribute
    isTransitiveClosureOf: Proposition!attribute
end


MakeTransitiveSemantics1 in Class with
  rule
   transR1: $ forall x,y/VAR 
                     (exists A,B/Proposition!attribute C/Proposition MA,MB/VAR
                      (B isTransitiveClosureOf A) and
                      P(A,C,MA,C) and P(B,C,MB,C) and 
                     (x in C) and (y in C) and 
                     (x MA y) ) ==> (x MB y) $;
   transR2: $ forall x,y/VAR
                     (exists A,B/Proposition!attribute C/Proposition MA,MB/VAR z/VAR 
                      (B isTransitiveClosureOf A) and
                      P(A,C,MA,C) and P(B,C,MB,C) and
                     (x in C) and (y in C)  and (z in C) and 
                     (x MA z) and (z MB y) ) ==> (x MB y) $
end



{* ------------------------------------------------------------------ *}

{* ****       Notation Level      **** *}
{* defines the Petri Net Notation      *}
{* ****      ---------------      **** *}


Place in Node with
  connectedTo
    sendsToken: Transition
  attribute
    tokenFill: Integer  {* needed to define states *}
end

Transition in Node with 
  connectedTo
     producesToken : Place
end 


{* A petri net consists of transitions and *}
{* places, and implicitely their links.    *}

Petrinet in Model with 
  contains
     containsTransition : Transition;
     containsPlace : Place
end 


{* A petri net state is a configuration of tokens *}
{* on places.                                     *}

PetrinetState with 
  attribute
     placeFill : Place!tokenFill;
     ofPetrinet: Petrinet
end 


{* compute the number of tokens in a place *}
{* at a given state.                       *}

TokenNr in Function isA Integer with
  parameter
    state: PetrinetState;
    place: Place
  constraint
    c1: $ exists tf/Place!tokenFill
             (state placeFill tf) and
             From(tf,place) and To(tf,this) 
        $
end

{* A transition is enabled if the number of Tokens *}
{* at all its input places is greater than zero.   *}

EnabledTransition in GenericQueryClass isA Transition with
  parameter,computed_attribute
    state: PetrinetState
  constraint
    c1: $ exists pn/Petrinet 
             (state ofPetrinet pn) and
             (pn containsTransition this) and
             (forall pl/Place (pl sendsToken this) 
                 ==> (TokenNr(pl,state) > 0)
             )
         $
end


{* A state is dead if no transition is enabled *}

DeadState in QueryClass isA PetrinetState with
  constraint
     c1: $ exists pn/Petrinet (this ofPetrinet pn) and
            ( forall tr/Transition (pn containsTransition tr)
                  ==> not (tr in EnabledTransition[this/state])
            )
         $
end


{* InputLink is a link from a place to a transition *}

InputLink in GenericQueryClass isA Place!sendsToken with
  parameter
     trans: Transition;
     place: Place
  constraint
     c1: $ From(this,place) and To(this,trans) $
end

{* Output link as a  link from a transition to a place *}

OutputLink in GenericQueryClass isA Transition!producesToken with
  parameter
     trans: Transition;
     place: Place
  constraint
     c1: $ From(this,trans) and To(this,place) $
end


{* A next state from some old state is determined by *}
{* executing a transition tr. It will compute the    *}
{* new token numbers for any related place pl by     *}
{*    new=old+plus-min                               *}
{* where old is the old number of tokens, plus is    *}
{* the number of ouput links from tr to the place pl,*}
{* and min is the number of inputplinks from pl to   *}
{* tr.                                               *}

NextState in GenericQueryClass isA PetrinetState with
  parameter,computed_attribute
     oldstate: PetrinetState;
     tr: Transition
  constraint
     c1: $ exists pn/Petrinet
             (this ofPetrinet pn) and (pn containsTransition tr) and
              forall pl/Place (pn containsPlace pl)
              ==>
              (TokenNr(pl,this) = TokenNr(pl,oldstate)+#OutputLink[pl,tr]-#InputLink[pl,tr])
         $
end

{* Here we define the relation 'nextState' between two states *}

PetrinetState in Class with
  attribute
    nextState: PetrinetState;
    reachableState: PetrinetState
  rule
   r1: $ forall s1,s2/PetrinetState
            (s2 in NextState[s1/oldstate]) ==> (s1 nextState s2) $
end


{* If we have an expandable state, then our list of states *}
{* (=instances of PetrinetState) is not yet complete       *}

ExpandableState in QueryClass isA PetrinetState with
  computed_attribute
    enabled_tr: Transition
  constraint
    c1: $
         (enabled_tr in EnabledTransition[this/state]) and
         ( not exists s/PetrinetState
             (s in NextState[this/oldstate,enabled_tr/tr])
         )
        $
end
  

{* here we define 'reachableState' to be the transitive *}
{* closure of 'nextState'.                              *}

PetrinetState!reachableState with
  isTransitiveClosureOf
    base: PetrinetState!nextState
end



{* ------------------------------------------------------------------ *}

{* ****         Model Level       **** *}
{* defines an example Petri Net        *}
{* ****      ---------------      **** *}


PN123 in Petrinet with 
  containsTransition
     t1 : trans1
  containsPlace
     p1 : place1;
     p2 : place2;
     p3 : place3
end 

trans1 in Transition with 
  producesToken
     pl1 : place2;
     pl2 : place3
end 

{* the tokenFill attribute lists POSSIBLE fill states *}
{* of places with tokens. Note that we can only deal  *}
{* with finite numbers of fillers in ConceptBase.     *}

place1 in Place with
  sendsToken
     t1: trans1
  tokenFill
     tf0: 0;
     tf1: 1;
     tf2: 2
end


place2 in Place with 
  tokenFill
     tf0: 0;
     tf1: 1;
     tf2: 2
end

place3 in Place with
  sendsToken
     t1: trans1
  tokenFill
     tf0: 0;
     tf1: 1;
     tf2: 2
end


{* ------------------------------------------------------------------ *}

{* ****         Data Level        **** *}
{* trace of some execution of the      *}
{* petri net PN123                     *}
{* ****      ---------------      **** *}

{* just a few states listed here ... *}


2_0_1 in PetrinetState with
  ofPetrinet
     pnet: PN123
  placeFill
     p1: place1!tf2;
     p2: place2!tf0;
     p3: place3!tf1
end

1_1_1 in PetrinetState with
  ofPetrinet
     pnet: PN123
  placeFill
     p1: place1!tf1;
     p2: place2!tf1;
     p3: place3!tf1
end


0_2_1 in PetrinetState with
  ofPetrinet
     pnet: PN123
  placeFill
     p1: place1!tf0;
     p2: place2!tf2;
     p3: place3!tf1
end

1_1_2 in PetrinetState with
  ofPetrinet
     pnet: PN123
  placeFill
     p1: place1!tf1;
     p2: place2!tf1;
     p3: place3!tf2
end








```

=== `Petri Net Analysis/02-PN-GTs.sml.txt`

```telos
{
*
* File: PN-GTs.sml
* Author: Manfred Jeusfeld
* Creation: 4-Nov-2004 (4-Nov-2004)
* ----------------------------------------------------------------------
* Graphical types for Petri nets
*
}



Class Petrinet_Palette in JavaGraphicalPalette with
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
    c7: Transition_GT;
    c10: Place_GT;
    c19: DefaultattributeeGT;
    c20: DefaultIsAGT;
    c21: DefaultInstanceOfGT;
    c22: QueryClassGT
rule
    rIsaGT : $ forall p/IsA (p graphtype DefaultIsAGT) $;
    rInstGT : $ forall p/InstanceOf (p graphtype DefaultInstanceOfGT) $;
    rAttrGT : $ forall p/attributee (p graphtype DefaultattributeeGT) $;
    rIndGT : $ forall p/Individual (p graphtype DefaultIndividualGT) $;
    rQueryClass : $ forall c/QueryClass (c graphtype QueryClassGT) $
end




Transition_GT in Class,JavaGraphicalType with
property
	bgcolor : "255,150,150";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Rect";
	fontstyle : "italic";
      edgewidth : "3"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 22
rule
     gtrule: $ forall x/Transition (x graphtype Transition_GT) $
end

                  
                  
Place_GT in Class,JavaGraphicalType with
property
	bgcolor : "255,150,150";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse";
	fontstyle : "italic";
      linewidth : "3"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 27
rule
     gtrule: $ forall x/Place (x graphtype Place_GT) $

end

                        

```

=== `Petri Net Simulation/01-PetriNetSimu.sml.txt`

```telos
{
* File: PetriNetSimu.sml
* Author: Manfred Jeusfeld
* Created: 26-Oct-2005/M.Jeusfeld (29-Nov-2012/M.Jeusfeld)
* ------------------------------------------------------
* Executable variant for petri nets. Allows to fire specified
* transactions. An example on how to fire a transition is at the end of this
* file. You can inspect the current state of the petri net by the query
* ReportState.
* This file also contains a petri net example for 'safe traffic lights'
* taken from course material of Wil van der Aalst. 
* Graphical palette is already included in this file!
* 
* This requires ConceptBase 7.4 released after July 2012!
}


Place with
  attribute
   sendsToken: Transition;
   marks: Integer {* defines markings *}
end

Transition with
  attribute
    producesToken : Place
end

M in Function isA Integer with
  parameter p: Place
  constraint c1: $ (p marks this) $
end

Input in GenericQueryClass isA Place with
  parameter t: Transition
  constraint ci: $ (this sendsToken t) $
end


{* A transition is enabled if the number of Tokens *}
{* at all its input places is greater than zero.   *}

Enabled in QueryClass isA Transition with
  constraint c: $ forall p/Input[this] (M(p) > 0) $
end


{* A connected place is a place that is linked to a given transition *}
{* either by sending a token to it or receiving a token from it.     *}
{* A connected place is affected by firing a transition.             *}

ConnectedPlace in GenericQueryClass isA Place with
  parameter trans: Transition
  constraint c: $ (this sendsToken trans) or (trans producesToken this) $
end

inFlow in GenericQueryClass isA Transition!producesToken with
  parameter place: Place; trans: Transition
  constraint c1: $ From(this,trans) and To(this,place) $
end

outFlow in GenericQueryClass isA Place!sendsToken with
  parameter place: Place; trans: Transition
  constraint c1: $ From(this,place) and To(this,trans) $
end

{* Net effect of a transition t on a place p = incidence matrix.   *}
{* = number of links from t to p minus number of links from p to t *}
IM in Function isA Integer with
  parameter p: Place; t: Transition
  constraint c1: $ (this = #inFlow[p,t] - #outFlow[p,t]) $
end


{* Artificial class to store firings of transitions. Needed to simulate *}
{* the execution of a petri net.                                        *}

FireTransition with
  attribute transition: Transition
end

{* This active rules encodes the semantics of firing a transition. *}
{* When firing a transition tr, the IF part of the ECArule         *}
{* determines for any connected place pl the new token fill.       *}
{* The DO part will then update the token fill of the place pl     *}
{* accordingly. The IF part will be evaluated for all connected    *}
{* places.                                                         *}
{* Note that the net effect can be negative or zero or positive.   *}
{* The IFNEW clause indicates that the condition is                *}
{* evaluated against the newest database state, in contrast to     *}
{* being evaluated against the database state immediately before   *}
{* the current transaction. This allow to model multiple           *}
{* of UpdateConnectedPlaces in the same TELL transaction.          *}

ECArule UpdateConnectedPlaces with
  mode m: Deferred
  ecarule
    er : $ fire/FireTransition t/Transition p/Place m/Integer
           ON Tell (fire transition t)
           IFNEW (t in Enabled) and (p in ConnectedPlace[t]) and
           (m = M(p)+IM(p,t))
           DO Retell (p marks m) $
end




{* This query reports the current state of a petri net. *}

ReportState in QueryClass isA Place with
  retrieved_attribute
    marks: Integer
end

AnswerFormat StateFormat with
   forQuery q: ReportState
   order o: ascending
   orderBy ob: "this"
   head h: 
"Place   #Tokens
-----------------
"
  pattern p:
"{this}   {this.marks}
"
  tail t:
"-----------------
"
end



{* -------------------------------------------------- *}

{* Petri net for traffic lights. Taken from slides of *}
{* Wil van der Aalst.                                 *}

red1 in Place with
  sendsToken
    t1: rg1
  marks
    tf: 1
end

yellow1 in Place with
  sendsToken
    t1: yr1
  marks
    tf: 0
end

green1 in Place with
  sendsToken
    t1: gy1
  marks
    tf: 0
end

safe1 in Place with
  sendsToken
    t1: rg1
  marks
    tf: 1
end

yr1 in Transition with
  producesToken
    p1: red1;
    p2: safe2
end

rg1 in Transition with
  producesToken
    p1: green1
end

gy1 in Transition with
  producesToken
    p1: yellow1
end



red2 in Place with
  sendsToken
    t1: rg2
  marks
    tf: 1
end

yellow2 in Place with
  sendsToken
    t1: yr2
  marks
    tf: 0
end

green2 in Place with
  sendsToken
    t1: gy2
  marks
    tf: 0
end

safe2 in Place with
  sendsToken
    t1: rg2
  marks
    tf: 0
end

yr2 in Transition with
  producesToken
    p1: red2;
    p2: safe1
end

rg2 in Transition with
  producesToken
    p1: green2
end

gy2 in Transition with
  producesToken
    p1: yellow2
end




{* -------------------------------------------------------- *}

{* You can fire a specified transition by telling instances of
   FireTransition. You can either tell the individual firings
   one by one or several consecutive firings in the same 
   TELL transaction. You can even tell all of them in a single
   TELL transaction.

fire1 in FireTransition with
  transition t1: rg1
end

fire2 in FireTransition with
  transition t1: gy1
end

fire3 in FireTransition with
  transition t1: yr1
end

fire4 in FireTransition with
  transition t1: rg2
end


*}




{* graphical types that take care that the petri net is displayed *}
{* in the usual notation in the graph editor of ConceptBase.      *}


Class Petrinet_Palette in JavaGraphicalPalette with
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
    c7: Transition_GT;
    c8: Enabled_GT;
    c10: Place0_GT;
    c11: Place1_GT;
    c12: Place2_GT;
    c13: Place3_GT;
    c14: PlaceN_GT;
    c19: DefaultattributeeGT;
    c20: DefaultIsAGT;
    c21: DefaultInstanceOfGT;
    c22: QueryClassGT;
    c23: TokenPassageGT;
    c24: marksGT
end




Transition_GT in Class,JavaGraphicalType with
property
	textcolor : "0,0,0";
        linecolor : "204,120,120";
	fontstyle : "italic";
        image: "http://conceptbase.sourceforge.net/CBICONS/pn_transition.png"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 22
rule
     gtrule: $ forall x/Transition (x graphtype Transition_GT) $
end

Enabled_GT in Class,JavaGraphicalType with
property
	textcolor : "0,0,0";
      linecolor : "204,120,120";
	fontstyle : "italic";
        image: "http://conceptbase.sourceforge.net/CBICONS/pn_transitionenabled.png"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 23
rule
     gtrule: $ forall x/Enabled (x graphtype Enabled_GT) $
end         
                  
Place0_GT in Class,JavaGraphicalType with
property
	textcolor : "0,0,0";
	linecolor : "204,120,120";
	fontstyle : "italic";
        image: "http://conceptbase.sourceforge.net/CBICONS/pn_place0.png"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 27
rule
     gtrule: $ forall x/Place (x graphtype Place0_GT) $
end


Place1_GT in Class,JavaGraphicalType with
property
        textcolor : "0,0,0";
        linecolor : "204,120,120";
        fontstyle : "italic";
        image: "http://conceptbase.sourceforge.net/CBICONS/pn_place1.png"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 28
rule
     gtrule: $ forall x/Place n/Integer (x marks n) and (n = 1) ==> 
               (x graphtype Place1_GT) $
end

Place2_GT in Class,JavaGraphicalType with
property
        textcolor : "0,0,0";
        linecolor : "204,120,120";
        fontstyle : "italic";
        image: "http://conceptbase.sourceforge.net/CBICONS/pn_place2.png"
implementedBy
        implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 28
rule
     gtrule: $ forall x/Place n/Integer (x marks n) and (n = 2) ==>
               (x graphtype Place2_GT) $
end

Place3_GT in Class,JavaGraphicalType with
property
        textcolor : "0,0,0";
        linecolor : "204,120,120";
        fontstyle : "italic";
        image: "http://conceptbase.sourceforge.net/CBICONS/pn_place3.png"
implementedBy
        implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 28
rule
     gtrule: $ forall x/Place n/Integer (x marks n) and (n = 3) ==>
               (x graphtype Place3_GT) $
end


PlaceN_GT in Class,JavaGraphicalType with
property
        textcolor : "0,0,0";
        linecolor : "204,120,120";
        fontstyle : "italic";
        image: "http://conceptbase.sourceforge.net/CBICONS/pn_placen.png"
implementedBy
        implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 28
rule
     gtrule: $ forall x/Place n/Integer (x marks n) and (n > 3) ==>
               (x graphtype PlaceN_GT) $
end


TokenPassageGT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "120,120,120";
     edgewidth : "2";
     label : "";
     bgcolor : "220,120,120" 
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 3
  rule
     gtrule1: $ forall a/Place!sendsToken (a graphtype TokenPassageGT) $;
     gtrule2: $ forall a/Transition!producesToken (a graphtype TokenPassageGT) $
end   

marksGT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     linecolor : "210,210,210";
     edgecolor : "210,210,210";
     edgewidth : "3";
     label : "";
     bgcolor : "255,150,150"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 3
  rule
     gtrule1: $ forall a/Place!marks (a graphtype marksGT) $
end                       



```

=== `Petri Net Simulation/Ask variant/01-PetriNetSimu-Ask.sml.txt`

```telos
{
* File: PetriNetSimu-Ask.sml
* Author: Manfred Jeusfeld
* Created: 18-May-2006/M.Jeusfeld (23-Apr-2008/M.Jeusfeld)
* ------------------------------------------------------
* 
* This variant allows to trigger enabled transitions by just calling
* the query FireTransition.
* 
* This requires ConceptBase 7.1 released April 2008 or later!
}


Place with
  attribute
    sendsToken: Transition;
    tokenFill: Integer  {* needed to define states *}
end

Transition with 
  attribute
     producesToken : Place
end 


{* A transition is enabled if the number of Tokens *}
{* at all its input places is greater than zero.   *}

EnabledTransition in QueryClass isA Transition with
  constraint
    c1: $ forall pl/Place n/Integer
            (pl sendsToken this) and (pl tokenFill n)
                 ==> (n > 0)
         $
end

{* A connected place is a place that is linked to a given transition *}
{* either by sending a token to it or receiving a token from it.     *}
{* A connected place is affected by firing a transition.             *}

ConnectedPlace in GenericQueryClass isA Place with
  parameter
    trans: Transition
  constraint
    isConnected: $ (this sendsToken trans) or (trans producesToken this) $
end

{* A link from a transition to a place (will produce tokens) *}
TransToPlace in GenericQueryClass isA Transition!producesToken with
  parameter
    place: Place;
    trans: Transition
  constraint
    c1: $ From(this,trans) and To(this,place) $
end

{* A link from a place to a transition (will consume tokens) *}
PlaceToTrans in GenericQueryClass isA Place!sendsToken with
  parameter
    place: Place;
    trans: Transition
  constraint
    c1: $ From(this,place) and To(this,trans) $
end


{* This function computes the net effect of firing the transition xt *}
{* upon the place xp. This is the difference between the number of   *}
{* links from xt to xp and the number of links from xp to xt.        *}

NetEffectOfTransition in Function isA Integer with
  parameter
    xp: Place;
    xt: Transition
  constraint
    c1: $ (~this = #TransToPlace[xp,xt] - #PlaceToTrans[xp,xt]) $
end


{* Query to call the firings of transitions. Will trigger the ECA rule  *}

FireTransition in GenericQueryClass isA Transition with
 parameter
    transition: EnabledTransition
 constraint
    c1: $ (this=transition) $
end


{* This active rules encodes the semantics of firing a transition. *}
{* When firing a transition tr, the IF part of the ECArule         *}
{* determines for any connected place pl the new token fill.       *}
{* The DO part will then update the token fill of the place pl     *}
{* accordingly. The IF part will be evaluated for all connected    *}
{* places.                                                         *}
{* Note that the net effect can be negative or zero or positive.   *}

ECArule UpdateConnectedPlaces with
  mode m: Deferred
  rejectMsg rm:
"The last firing of a transition failed.
Check whether the transition was enabled!"
  ecarule
    er : $  fire/FireTransition tr/Transition pl/Place 
                n,n1/Integer
        ON Ask FireTransition[tr]
        IF `(tr in EnabledTransition) and
           (pl in ConnectedPlace[tr]) and
           `(pl tokenFill n) and
           (n1 = n+NetEffectOfTransition(pl,tr))
        DO Retell (pl tokenFill n1) 
        ELSE
           reject
        $
end


{* This query reports the current state of a petri net. *}

ReportState in QueryClass isA Place with
  retrieved_attribute
    tokenFill: Integer
end

AnswerFormat StateFormat with
   forQuery q: ReportState
   order o: ascending
   orderBy ob: "this"
   head h: 
"Place   #Tokens
-----------------
"
  pattern p:
"{this}   {this.tokenFill}
"
  tail t:
"-----------------
"
end



{* -------------------------------------------------- *}

{* Petri net for traffic lights. Taken from slides of *}
{* Wil van der Aalst.                                 *}

red1 in Place with
  sendsToken
    t1: rg1
  tokenFill
    tf: 1
end

yellow1 in Place with
  sendsToken
    t1: yr1
  tokenFill
    tf: 0
end

green1 in Place with
  sendsToken
    t1: gy1
  tokenFill
    tf: 0
end

safe1 in Place with
  sendsToken
    t1: rg1
  tokenFill
    tf: 1
end

yr1 in Transition with
  producesToken
    p1: red1;
    p2: safe2
end

rg1 in Transition with
  producesToken
    p1: green1
end

gy1 in Transition with
  producesToken
    p1: yellow1
end



red2 in Place with
  sendsToken
    t1: rg2
  tokenFill
    tf: 1
end

yellow2 in Place with
  sendsToken
    t1: yr2
  tokenFill
    tf: 0
end

green2 in Place with
  sendsToken
    t1: gy2
  tokenFill
    tf: 0
end

safe2 in Place with
  sendsToken
    t1: rg2
  tokenFill
    tf: 0
end

yr2 in Transition with
  producesToken
    p1: red2;
    p2: safe1
end

rg2 in Transition with
  producesToken
    p1: green2
end

gy2 in Transition with
  producesToken
    p1: yellow2
end




{* -------------------------------------------------------- *}

{* You can fire a specified transition by asking FireTransition,
   e.g. in this order:
   

FireTransition[rg1/transition]
FireTransition[gy1/transition]
FireTransition[yr1/transition]
FireTransition[rg2/transition]

*}

```

=== `Petri Net Simulation/OLD/02-PNS-GTs-extended.sml.txt`

```telos
{
*
* File: PNS-GTs.sml
* Author: Manfred Jeusfeld
* Creation: 4-Nov-2004 (5-Jan-2012)
* ----------------------------------------------------------------------
* Graphical types for Petri nets (simulation variant)
*
}



Class Petrinet_Palette in JavaGraphicalPalette with
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
    c7: Transition_GT;
    c8: EnabledTransition_GT;
    c10: Place0_GT;
    c11: Place1_GT;
    c12: Place2_GT;
    c13: Place3_GT;
    c14: PlaceN_GT;
    c19: DefaultattributeeGT;
    c20: DefaultIsAGT;
    c21: DefaultInstanceOfGT;
    c22: QueryClassGT;
    c23: TokenPassageGT;
    c24: TokenFillGT
end




Transition_GT in Class,JavaGraphicalType with
property
	textcolor : "0,0,0";
        linecolor : "204,120,120";
	fontstyle : "italic";
        image: "http://conceptbase.sourceforge.net/CBICONS/transition.gif"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 22
rule
     gtrule: $ forall x/Transition (x graphtype Transition_GT) $
end

EnabledTransition_GT in Class,JavaGraphicalType with
property
	textcolor : "0,0,0";
      linecolor : "204,120,120";
	fontstyle : "italic";
        image: "http://conceptbase.sourceforge.net/CBICONS/transitionenabled.gif"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 23
rule
     gtrule: $ forall x/EnabledTransition (x graphtype EnabledTransition_GT) $
end         
                  
Place0_GT in Class,JavaGraphicalType with
property
	textcolor : "0,0,0";
	linecolor : "204,120,120";
	fontstyle : "italic";
        image: "http://conceptbase.sourceforge.net/CBICONS/place0.gif"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 27
rule
     gtrule: $ forall x/Place (x graphtype Place0_GT) $
end


Place1_GT in Class,JavaGraphicalType with
property
        textcolor : "0,0,0";
        linecolor : "204,120,120";
        fontstyle : "italic";
        image: "http://conceptbase.sourceforge.net/CBICONS/place1.gif"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 28
rule
     gtrule: $ forall x/Place n/Integer (x tokenFill n) and (n = 1) ==> 
               (x graphtype Place1_GT) $
end

Place2_GT in Class,JavaGraphicalType with
property
        textcolor : "0,0,0";
        linecolor : "204,120,120";
        fontstyle : "italic";
        image: "http://conceptbase.sourceforge.net/CBICONS/place2.gif"
implementedBy
        implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 28
rule
     gtrule: $ forall x/Place n/Integer (x tokenFill n) and (n = 2) ==>
               (x graphtype Place2_GT) $
end

Place3_GT in Class,JavaGraphicalType with
property
        textcolor : "0,0,0";
        linecolor : "204,120,120";
        fontstyle : "italic";
        image: "http://conceptbase.sourceforge.net/CBICONS/place3.gif"
implementedBy
        implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 28
rule
     gtrule: $ forall x/Place n/Integer (x tokenFill n) and (n = 3) ==>
               (x graphtype Place3_GT) $
end


PlaceN_GT in Class,JavaGraphicalType with
property
        textcolor : "0,0,0";
        linecolor : "204,120,120";
        fontstyle : "italic";
        image: "http://conceptbase.sourceforge.net/CBICONS/placen.gif"
implementedBy
        implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 28
rule
     gtrule: $ forall x/Place n/Integer (x tokenFill n) and (n > 3) ==>
               (x graphtype PlaceN_GT) $
end


TokenPassageGT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "155,150,150";
     edgewidth : "1";
     label : "";
     bgcolor : "255,150,150"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 3
  rule
     gtrule1: $ forall a/Place!sendsToken (a graphtype TokenPassageGT) $;
     gtrule2: $ forall a/Transition!producesToken (a graphtype TokenPassageGT) $
end   

TokenFillGT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     linecolor : "210,210,210";
     edgecolor : "210,210,210";
     edgewidth : "3";
     label : "";
     bgcolor : "255,150,150"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 3
  rule
     gtrule1: $ forall a/Place!tokenFill (a graphtype TokenFillGT) $
end                       

                    

```

=== `Petri Net Simulation/OLD/02-PNS-GTs.sml.txt`

```telos
{
*
* File: PNS-GTs.sml
* Author: Manfred Jeusfeld
* Creation: 4-Nov-2004 (10-Nov-2005)
* ----------------------------------------------------------------------
* Graphical types for Petri nets (simulation variant)
*
}



Class Petrinet_Palette in JavaGraphicalPalette with
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
    c7: Transition_GT;
    c8: EnabledTransition_GT;
    c10: Place_GT;
    c11: PlaceWithToken_GT;
    c19: DefaultattributeeGT;
    c20: DefaultIsAGT;
    c21: DefaultInstanceOfGT;
    c22: QueryClassGT;
    c23: TokenPassageGT;
    c24: TokenFillGT
rule
    rIsaGT : $ forall p/IsA (p graphtype DefaultIsAGT) $;
    rInstGT : $ forall p/InstanceOf (p graphtype DefaultInstanceOfGT) $;
    rAttrGT : $ forall p/attributee (p graphtype DefaultattributeeGT) $;
    rIndGT : $ forall p/Individual (p graphtype DefaultIndividualGT) $;
    rQueryClass : $ forall c/QueryClass (c graphtype QueryClassGT) $
end




Transition_GT in Class,JavaGraphicalType with
property
	bgcolor : "255,120,120";   {* red = not enabled (default) *}
	textcolor : "0,0,0";
      linecolor : "204,120,120";
	shape : "i5.cb.graph.shapes.Rect";
	fontstyle : "italic";
      linewidth : "2"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 22
rule
     gtrule: $ forall x/Transition (x graphtype Transition_GT) $
end

EnabledTransition_GT in Class,JavaGraphicalType with
property
	bgcolor : "110,255,110";   {* green = enabled *}
	textcolor : "0,0,0";
      linecolor : "204,120,120";
	shape : "i5.cb.graph.shapes.Rect";
	fontstyle : "italic";
      linewidth : "2"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 23
rule
     gtrule: $ forall x/EnabledTransition (x graphtype EnabledTransition_GT) $
end         
                  
Place_GT in Class,JavaGraphicalType with
property
	bgcolor : "240,240,240";  {* light grey for places without tokens *}
	textcolor : "0,0,0";
	linecolor : "204,120,120";
	shape : "i5.cb.graph.shapes.Ellipse";
	fontstyle : "italic";
      linewidth : "2"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 27
rule
     gtrule: $ forall x/Place (x graphtype Place_GT) $
end


PlaceWithToken_GT in Class,JavaGraphicalType with
property
	bgcolor : "50,50,50";  {* black for places with tokens *}
	textcolor : "250,250,250";
	linecolor : "204,120,120";
	shape : "i5.cb.graph.shapes.Ellipse";
	fontstyle : "italic";
      linewidth : "2"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 28
rule
     gtrule: $ forall x/Place n/Integer (x tokenFill n) and (n > 0) ==> 
               (x graphtype PlaceWithToken_GT) $
end


TokenPassageGT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     linecolor : "255,150,150";
     edgecolor : "255,150,150";
     edgewidth : "4";
     label : "";
     bgcolor : "255,150,150"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 3
  rule
     gtrule1: $ forall a/Place!sendsToken (a graphtype TokenPassageGT) $;
     gtrule2: $ forall a/Transition!producesToken (a graphtype TokenPassageGT) $
end   

TokenFillGT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     linecolor : "210,210,210";
     edgecolor : "210,210,210";
     edgewidth : "3";
     label : "";
     bgcolor : "255,150,150"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 3
  rule
     gtrule1: $ forall a/Place!tokenFill (a graphtype TokenFillGT) $
end                       

                    

```

=== `Petri Net Simulation/Self-triggering variant/01-PetriNetAutoSimu.sml.txt`

```telos
{
* File: PetriNetAutoSimu.sml
* Author: Manfred Jeusfeld
* Created: 18-Jan-2006/M.Jeusfeld (24-Apr-2008/M.Jeusfeld)
* ------------------------------------------------------
* Executable variant for petri nets. This variant will
* trigger the petri net whenever the state of some place is
* updated. Note that this may lead to infinite loops.
* 
* This requires ConceptBase 7.1 released April 2008 or later!
}


{*  Some definitions for the attribute categories single/necessary;
    taken from SingleNecessary.sml
*}

AdditionalConstraints in Class with
   constraint
      singleConstraint :
         $ forall c,d/Proposition p/Proposition!single x,m/VAR
              P(p,c,m,d) and (x in c) ==>
                (
                  forall y1,y2/VAR
                    (y1 in d) and (y2 in d) and (x m y1) and (x m y2) ==>
                   (y1==y2)
                ) $;
      necConstraint:
          $ forall c,d/Proposition p/Proposition!necessary x,m/VAR
            P(p,c,m,d) and (x in c) ==>
             exists y/VAR (y in d) and (x m y) $
end


AdditionalConstraints!singleConstraint with
 comment
   hint:
"The attribute {m} of {c} is single-valued. Any instance of {c} may have at most one instance of {d} for  the attribute {m}!"
end


AdditionalConstraints!necConstraint with
 comment
   hint:
"The attribute {m} of {c} is defined necessary. Any instance of {c} must have at least one instance of {d} for the attribute {m}!"
end


{*  Here begins the definition of petri nets and their semantics: *}
   


Place with
  attribute
    sendsToken: Transition
  single
    tokenFill: Integer  {* needed to define states *}
end

Transition with 
  attribute
     producesToken : Place
end 


{* just outputs the current state of a place (= number of tokens) *}
TokenNr in Function isA Integer with
  parameter
    place: Place
  constraint
    c1: $ (place tokenFill this) $
end

{* A transition is enabled if the number of Tokens *}
{* at all its input places is greater than zero.   *}

EnabledTransition in QueryClass isA Transition with
  constraint
    c1: $ forall pl/Place (pl sendsToken this) 
                 ==> (TokenNr(pl) > 0)
         $
end

{* A connected place is a place that is linked to a given transition *}
{* either by sending a token to it or receiving a token from it.     *}
{* A connected place is affected by firing a transition.             *}

ConnectedPlace in GenericQueryClass isA Place with
  parameter
    trans: Transition
  constraint
    isConnected: $ (this sendsToken trans) or (trans producesToken this) $
end

{* A link from a transition to a place (will produce tokens) *}
TransToPlace in GenericQueryClass isA Transition!producesToken with
  parameter
    place: Place;
    trans: Transition
  constraint
    c1: $ From(this,trans) and To(this,place) $
end

{* A link from a place to a transition (will consume tokens) *}
PlaceToTrans in GenericQueryClass isA Place!sendsToken with
  parameter
    place: Place;
    trans: Transition
  constraint
    c1: $ From(this,place) and To(this,trans) $
end


{* This function computes the net effect of firing the transition xt *}
{* upon the place xp. This is the difference between the number of   *}
{* links from xt to xp and the number of links from xp to xt.        *}

NetEffectOfTransition in Function isA Integer with
  parameter
    xp: Place;
    xt: Transition
  constraint
    c1: $ (~this = #TransToPlace[xp,xt] - #PlaceToTrans[xp,xt]) $
end


{* Whenever we change the number of tokens on a place, we shall *}
{* check which of the transitions connected to this place is    *}
{* enabled. For these transitions, we will fire them one after  *}
{* the other. Note that one firing may disable another          *}
{* transition that may have been enabled before the firing      *}
{* The backquote '`' before a predicate indicates that it is    *}
{* evaluated against the newest database state, in contrast to  *}
{* being evaluated against the database state immediately before*}
{* the current transaction. This allow to model multiple        *}
{* executions of fireOnTell in the same TELL transaction.       *}

ECArule fireOnTell with
  mode m: Deferred
  depth d: 2000
  ecarule
        er : $  tr/Transition pl,pl1/Place n,n1,n2/Integer
        ON Tell( (pl tokenFill n) )
        IF (pl sendsToken tr) and
           `(tr in EnabledTransition) and
           (pl1 in ConnectedPlace[tr]) and
           `(pl1 tokenFill n1) and
           `(n2 = n1+NetEffectOfTransition(pl1,tr))
        DO Retell( (pl1 tokenFill n2) )
        $
end



{* This query reports the current state of a petri net. *}

ReportState in QueryClass isA Place with
  retrieved_attribute
    tokenFill: Integer
end

AnswerFormat StateFormat with
   forQuery q: ReportState
   order o: ascending
   orderBy ob: "this"
   head h: 
"Place   #Tokens
-----------------
"
  pattern p:
"{this}   {this.tokenFill}
"
  tail t:
"-----------------
"
end



{* -------------------------------------------------- *}

Place START with
  sendsToken
    t1: SIDE_A;
    t2: SIDE_B
end

Transition SIDE_A with
  producesToken
     p1: RESOURCE_B;
     p2: OUTPUT_A
end

Place RESOURCE_B with
  sendsToken
    t1: SIDE_B
end

Place RESOURCE_A with
  sendsToken
    t1: SIDE_A
end

Transition SIDE_B with
  producesToken
     p1: RESOURCE_A;
     p2: OUTPUT_B
end

Place OUTPUT_A end
Place OUTPUT_B end



{* ---- start state *}

{*
START with
  tokenFill
    tf: 10
end
*}


RESOURCE_A with
  tokenFill
    tf: 1
end

RESOURCE_B with
  tokenFill
    tf: 0
end

OUTPUT_A with
  tokenFill
    tf: 0
end


OUTPUT_B with
  tokenFill
    tf: 0
end



```

=== `Petri Net Simulation/Self-triggering variant/AutoExecutePetrinet.cbs.txt`

```telos
#
# File: AutoExecutePetrinet.cbs
# Author: Manfred Jeusfeld
# Created: 8-Feb-2006/M.Jeusfeld (19-Jan-2010/M.Jeusfeld)
# ------------------------------------------------------
# This script will tell the petri net notation together with
# its dynamic execution semantics encoded by the ECArule.
# It also tell a small petri net example that is executed as
# soon as a state for the petri net is told that makes at least one
# transition enabled.
#
# Start: CBshell -f AutoExecutePetrinet.cbs
# 
# This script requires ConceptBase 7.0 or later.
#

startServer -u nonpersistent -p 4411 -t low
tell "
Place with
  attribute
    sendsToken: Transition;
    tokenFill: Integer  
end

Transition with 
  attribute
     producesToken : Place
end 

TokenNr in Function isA Integer with
  parameter
    place: Place
  constraint
    c1: $ (~place tokenFill ~this) $
end

EnabledTransition in QueryClass isA Transition with
  constraint
    c1: $ forall pl/Place (pl sendsToken ~this) 
                 ==> (TokenNr[pl/place] > 0)
         $
end


ConnectedPlace in GenericQueryClass isA Place with
  parameter
    trans: Transition
  constraint
    isConnected: $ (~this sendsToken ~trans) or (~trans producesToken ~this) $
end

TransToPlace in GenericQueryClass isA Transition!producesToken with
  required,parameter
    trans: Transition;
    place: Place
  constraint
    c1: $ From(~this,~trans) and To(~this,~place) $
end

PlaceToTrans in GenericQueryClass isA Place!sendsToken with
  required,parameter
    trans: Transition;
    place: Place
  constraint
    c1: $ From(~this,~place) and To(~this,~trans) $
end


NetEffectOfTransition in Function isA Integer with
  parameter
    xt: Transition;
    xp: Place
  constraint
    c1: $ (~this in IMINUS[COUNT[TransToPlace[~xt/trans,~xp/place]/class]/i1,
                           COUNT[PlaceToTrans[~xt/trans,~xp/place]/class]/i2]) $
end


ECArule fireOnTell with
  mode m: Deferred
  depth d: 10000
  ecarule
        er : $  tr/Transition pl,pl1/Place n,n1,n2,delta/Integer
        ON Tell( (pl tokenFill n) )
        IF (pl sendsToken tr) and
           new( (tr in EnabledTransition) ) and
           (pl1 in ConnectedPlace[tr/trans]) and
           new( (pl1 tokenFill n1) ) and
           (delta in NetEffectOfTransition[pl1/xp,tr/xt]) and
           new( (n2 in IPLUS[n1/i1, delta/i2]) )

        DO Untell( (pl1 tokenFill n1) ),
           Tell( (pl1 tokenFill n2) )
        $
end


ReportState in QueryClass isA Place with
  retrieved_attribute
    tokenFill: Integer
end

AnswerFormat StateFormat with
   forQuery q: ReportState
   order o: ascending
   orderBy ob: \"this\"
   head h: 
\"Place   #Tokens
-----------------
\"
  pattern p:
\"{this}   {this.tokenFill}
\"
  tail t:
\"-----------------
\"
end
"
result OK "yes"
tell "
Place START with
  sendsToken
    t1: SIDE_A;
    t2: SIDE_B
end

Transition SIDE_A with
  producesToken
     p1: RESOURCE_B;
     p2: OUTPUT_A
end

Place RESOURCE_B with
  sendsToken
    t1: SIDE_B
end

Place RESOURCE_A with
  sendsToken
    t1: SIDE_A
end

Transition SIDE_B with
  producesToken
     p1: RESOURCE_A;
     p2: OUTPUT_B
end

Place OUTPUT_A end
Place OUTPUT_B end
"
result OK "yes"
tell "
START with
  tokenFill
    tf: 400
end

RESOURCE_A with
  tokenFill
    tf: 1
end

RESOURCE_B with
  tokenFill
    tf: 0
end

OUTPUT_A with
  tokenFill
    tf: 0
end

OUTPUT_B with
  tokenFill
    tf: 0
end
"
result OK "yes"
ask "ReportState" OBJNAMES  FRAME  Now



```

== Graph files

- `trafficlights.gel`
- `trafficlights-knotted.gel`

== Shell output

```text
=== HOW-TO: capture-some-semantics-of-petri-nets (asset validation + smoke) ===

./Petri Net Analysis/01-PetriNets.sml.txt
./Petri Net Analysis/02-PN-GTs.sml.txt
./Petri Net Simulation/01-PetriNetSimu.sml.txt
./Petri Net Simulation/Ask variant/01-PetriNetSimu-Ask.sml.txt
./Petri Net Simulation/OLD/02-PNS-GTs-extended.sml.txt
./Petri Net Simulation/OLD/02-PNS-GTs.sml.txt
./Petri Net Simulation/Self-triggering variant/01-PetriNetAutoSimu.sml.txt
./Petri Net Simulation/Self-triggering variant/AutoExecutePetrinet.cbs.txt
./Petri Net Simulation/trafficlights-knotted.gel
./Petri Net Simulation/trafficlights.gel

This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>Proposition,MetaClass,"</graphtype>","
  <name>{this}</name>{Foreach(({this.property},{this|property}),(v,l),
  <property>
    <name>{l}</name>
    <value>{v}</value>
  </property>)}
  <implementedBy>{this.implementedBy}</implementedBy>
",GeneratedObject,0,$Rule(Condition(exists([In(_G48691, id_881)], forall([Aedot(id_886, _G48691, _G48697)], FALSE))), Conclusion(Adot(id_886, _G48691, id_1011)))$,DefaultJavaPalette,DeriveExpression,DefaultIndividualGT,DefaultLinkGT,ImplicitIsAGT,ImplicitInstanceOfGT,ImplicitAttributeGT,QueryCall,DefaultIsAGT,DefaultInstanceOfGT,DefaultAttributeGT,HiddenObject,MetametaGT,SimpleClassGT,MetaClassGT,Function,ClassGT,QueryClassGT,$ forall p/IsA (p graphtype DefaultIsAGT) $,$ forall p/InstanceOf (p graphtype DefaultInstanceOfGT) $,$ forall p/Attribute (p graphtype DefaultAttributeGT) $,$ forall p/Individual (p graphtype DefaultIndividualGT) $,$ forall c/MetametaClass (c graphtype MetametaGT) $,$ forall t/SimpleClass  (t graphtype SimpleClassGT) $,vQueryClass,$ forall t/MetaClass  (t graphtype MetaClassGT) $,$ forall c/Individual (c in Class) ==> (c graphtype ClassGT) $,$ forall c/QueryClass (c graphtype QueryClassGT) $,MetametaClass,"210,210,210","0,0,0","i5.cb.graph.shapes.Rect","i5.cb.graph.cbeditor.CBIndividual","2",$ not (this in HiddenObject) and not (this in Function) $,"i5.cb.graph.cbeditor.CBLink","0,205,255","3",1,"0,150,255",Version,"dashed","0,210,0",T_0,Module,"0,180,0",TransactionTime,Label,"20,20,20","127,255,212",Boolean,"32,178,170","i5.cb.graph.shapes.Ellipse","bold",10,FALSE,"255,192,203","255,0,0",TRUE,"135,206,235","65,105,225",System,ViewMaintenanceStrategy,"0,206,209",5,"255,255,255",BottomUpVM,"0,0,255","italic",7,$Rule(Condition(exists([In(_G23372, id_15)], TRUE)), Conclusion(Adot(id_876, _G23372, id_1042)))$,$Rule(Condition(exists([In(_G26016, id_1)], TRUE)), Conclusion(Adot(id_876, _G26016, id_1045)))$,TopDownVM,$Rule(Condition(exists([In(_G28635, id_6)], TRUE)), Conclusion(Adot(id_876, _G28635, id_1048)))$,$Rule(Condition(exists([In(_G31281, id_7)], TRUE)), Conclusion(Adot(id_876, _G31281, id_1022)))$,$Rule(Condition(exists([In(_G2266, id_11)], TRUE)), Conclusion(Adot(id_876, _G2266, id_1051)))$,$Rule(Condition(exists([In(_G4891, id_9)], TRUE)), Conclusion(Adot(id_876, _G4891, id_1054)))$,$Rule(Condition(exists([In(_G7498, id_10)], TRUE)), Conclusion(Adot(id_876, _G7498, id_1057)))$,NaiveVM,$Rule(Condition(exists([In(_G10493, id_7), In(_G10493, id_2)], TRUE)), Conclusion(Adot(id_876, _G10493, id_1060)))$,$Rule(Condition(exists([In(_G13216, id_65)], TRUE)), Conclusion(Adot(id_876, _G13216, id_1063)))$,ECArule,ECAassertion,ECAmode,$ forall r/ECArule e1,e2/ECAassertion
		(r ecarule e1) and (r ecarule e2) ==> (e1 == e2) $,$ forall r/ECArule exists e/ECAassertion
		(r ecarule e) $,$ forall r/ECArule m1,m2/ECAmode
		(r mode m1) and (r mode m2) ==> (m1 == m2) $,$ forall r/ECArule a1,a2/Boolean
		(r active a1) and (r active a2) ==> (a1 == a2) $,$ forall r/ECArule i,j/Integer
		(r depth i) and (r depth j) ==> (i == j) $,Immediate,ImmediateDeferred,Deferred,YesClass,yes,$forall([Adot(id_1406, _G7936, _G7942), Adot(id_1406, _G7936, _G7948)], IDENTICAL(_G7942, _G7948))$,Order,$Insert(Adot(id_1406, _G8372, _G8378), forall([e2], [Adot(_G8372, r, e2)], IDENTICAL(_G8378, e2)), [range(e2, [id_1405]), range(e1, [id_1405]), range(r, [id_1403])])$,$Insert(Adot(id_1406, _G9319, _G9331), forall([e1], [Adot(_G9319, r, e1)], IDENTICAL(e1, _G9331)), [range(e2, [id_1405]), range(e1, [id_1405]), range(r, [id_1403])])$,$forall([In(_G12295, id_1403)], exists([Adot(id_1406, _G12295, _G12301)], TRUE))$,$Insert(In(_G12658, id_1403), forall([], [], exists([e], [Adot(id_1406, _G12658, e)], TRUE)), [range(e, [id_1405]), range(r, [id_1403])])$,ascending,$Delete(Adot(id_1406, _G13321, _G13456), forall([], [In(r, id_1403)], exists([_G13456], [Adot(_G13321, r, _G13456)], TRUE)), [range(e, [id_1405]), range(r, [id_1403])])$,$forall([Adot(id_1410, _G17573, _G17579), Adot(id_1410, _G17573, _G17585)], IDENTICAL(_G17579, _G17585))$,$Insert(Adot(id_1410, _G18010, _G18016), forall([m2], [Adot(_G18010, r, m2)], IDENTICAL(_G18016, m2)), [range(m2, [id_1409]), range(m1, [id_1409]), range(r, [id_1403])])$,$Insert(Adot(id_1410, _G18958, _G18970), forall([m1], [Adot(_G18958, r, m1)], IDENTICAL(m1, _G18970)), [range(m2, [id_1409]), range(m1, [id_1409]), range(r, [id_1403])])$,descending,$forall([Adot(id_1411, _G23229, _G23235), Adot(id_1411, _G23229, _G23241)], IDENTICAL(_G23235, _G23241))$,$Insert(Adot(id_1411, _G23666, _G23672), forall([a2], [Adot(_G23666, r, a2)], IDENTICAL(_G23672, a2)), [range(a2, [id_125]), range(a1, [id_125]), range(r, [id_1403])])$,$Insert(Adot(id_1411, _G24613, _G24625), forall([a1], [Adot(_G24613, r, a1)], IDENTICAL(a1, _G24625)), [range(a2, [id_125]), range(a1, [id_125]), range(r, [id_1403])])$,AnswerFormat,$forall([Adot(id_1412, _G28832, _G28838), Adot(id_1412, _G28832, _G28844)], IDENTICAL(_G28838, _G28844))$,$Insert(Adot(id_1412, _G29269, _G29275), forall([j], [Adot(_G29269, r, j)], IDENTICAL(_G29275, j)), [range(j, [id_18]), range(i, [id_18]), range(r, [id_1403])])$,$Insert(Adot(id_1412, _G30216, _G30228), forall([i], [Adot(_G30216, r, i)], IDENTICAL(i, _G30228)), [range(j, [id_18]), range(i, [id_18]), range(r, [id_1403])])$,oHome,CB_User,AutoHomeModule,Resource,CB_Operation,CB_ReadOperation,CB_WriteOperation,TELL,TELL_MODEL,UNTELL,RETELL,LPI_CALL,ASK,HYPO_ASK,listModule,IsolatedValue,$ 
              (:(~this in ~type): and
                      not (exists y/Proposition (~this attribute y)) and 
                      not (exists c/Proposition In_s(~this,c) and (c <> ~type) and
                                                (c <> Proposition) and (c <> Individual) ))
          $,DoNotSave_LM,$ (~this in HiddenObject) or
                      ((~this in MSFOLassertion) and not (~this in QueryClass)) or
                      (~this in BDMRuleCheck) or
                      (~this in BDMConstraintCheck) or (~this in Proposition!deducedBy) or
                      (~this in Proposition!applyConstraintIfInsert) or (~this in Proposition!applyConstraintIfDelete) or
                      (~this in ECAassertion) or ( not (~this in Individual) and
                      (forall x/Proposition ((~this attribute x) ==> (x in DoNotSave_LM)) and not Isa_e(~this,x))) or
                      ( (~this in IsA) and exists a/Attribute From(~this,a) and 
                        ((a in QueryClass!retrieved_attribute) or (a in View!inherited_attribute))) or
                      (~this in IsolatedValue[String/type]) or
                      (~this in IsolatedValue[Integer/type]) or
                      (~this in IsolatedValue[Real/type]) or

                      :(~this in TransactionTime): and not (exists z/Proposition (~this attribute z))
                      $,toLabel,"returns s as a label without quotes and special character and creates it as individual object",concat,"Appends string s2 to the end of string s1; same as ConcatenateStrings",BuiltinClass,COUNT,DoNotSave_1,$ (~this in HiddenObject) or
             ((~this in MSFOLassertion) and not (~this in QueryClass)) or
             (~this in BDMRuleCheck) or
             (~this in BDMConstraintCheck) or (~this in Proposition!deducedBy) or
             (~this in Proposition!applyConstraintIfInsert) or (~this in Proposition!applyConstraintIfDelete) or
             (~this in ECAassertion) or
             ( (~this in IsA) and exists a/Attribute From(~this,a) and 
             ((a in QueryClass!retrieved_attribute) or (a in View!inherited_attribute))) or
             (~this in IsolatedValue[String/type]) or
             (~this in IsolatedValue[Integer/type]) or
             (~this in IsolatedValue[Real/type]) or
             :(~this in TransactionTime): and not (exists z/Proposition (~this attribute z))
             $,purgeModule,listModuleReloadable,"(C) 1987 ConceptBase Team, in particular Manfred Jeusfeld, Martin Staudt, Hans Nissen, Christoph Quix, Eva Krueger; all rights reserved.","Use permitted under FreeBSD style license, see http://conceptbase.sourceforge.net/CB-FreeBSD-License.txt.","The System module is the root module of ConceptBase. It contains the pre-defined objects and classes for ConceptBase.",XBridgePalette,"counts the instances of class",$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal contains gt)
                  ==> (pal contains gt) $,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal defaultIndividual gt)
                  ==> (pal defaultIndividual gt) $,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal defaultLink gt)
                  ==> (pal defaultLink gt) $,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal implicitIsA gt)
                  ==> (pal implicitIsA gt) $,COUNT_Attribute,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal implicitInstanceOf gt)
                  ==> (pal implicitInstanceOf gt) $,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal implicitAttribute gt)
                  ==> (pal implicitAttribute gt) $,TelosPalette,"This is the preferred default graphical palette for ConceptBase 8.2 (released 2021). The previous DefaultJavaPalette is still supported. TelosPalette is closer to the symbols used in UML class diagrams and has better support for long strings.",INDIVIDUAL_TP_GT,ATTR_TP_GT,ISADEDUCED_TP_GT,INSTOFDEDUCED_TP_GT,ATTRDEDUCED_TP_GT,CLASS_TP_GT,QUERYCLASS_TP_GT,INSTOF_TP_GT,ISA_TP_GT,STRING_TP_GT,VALUE_TP_GT,ASSERTION_TP_GT,"Caret","counts the attributes in category <attrcat> of object <objname>","ldashed",6,$ forall a/InstanceOf (a graphtype INSTOF_TP_GT) $,"1",Integer,SUM,"0,50,255","Arrow",$ forall a/IsA (a graphtype ISA_TP_GT) $,"computes the sum of the instances of class (must be reals or integers)","10","255,255,255,240",$ forall x/Proposition!attribute (x graphtype ATTR_TP_GT) $,AVG,"Rect","resizable",$ forall x/Individual (x graphtype INDIVIDUAL_TP_GT) $,"250,250,250",$ forall x/Class (x graphtype CLASS_TP_GT) $,"computes the average of the instances of class (must be reals or integers)","100,100,100","11","wrap","1000","0.3",$ forall x/String (x graphtype STRING_TP_GT) $,MAX,$ forall x/Integer (x graphtype VALUE_TP_GT) $,Class,$ forall x/Real (x graphtype VALUE_TP_GT) $,8,"gives the maximum of the instances of class (must be reals or integers)",$ forall x/MSFOLassertion (x graphtype ASSERTION_TP_GT) $,"255,245,245",$ forall x/QueryClass (x graphtype QUERYCLASS_TP_GT) $,concatl,"Appends the labels2 to the label s1; result is a Label, i.e. not necessarily an object name",MIN,concatl4,"Concats the labels s1,s2,s3,s4",concatl6,Real,"Concats the labels s1,s2,s3,s4,s5,s6",HiddenLabel,resultOf,toString,"gives the minimum of the instances of class (must be reals or integers)","convert the label of obj into a string with double quotes around it",length,"compute the number of characters of the label of obj. The double quotes of strings are not counted.",isLike,"check wether the label (first parameter) is matching a pattern (2nd parameter); Use wildcard * in the pattern",GlobalVariable,currentPalette,valueOf,IsolatedCB_User,SUM_Attribute,$ not exists a/Attribute From(a,this) or To(a,this) $,DoNotSave_2,$ (~this in HiddenObject) or
             ((~this in MSFOLassertion) and not (~this in QueryClass)) or
             (~this in BDMRuleCheck) or
             (~this in BDMConstraintCheck) or (~this in Proposition!deducedBy) or
             (~this in Proposition!applyConstraintIfInsert) or (~this in Proposition!applyConstraintIfDelete) or
             (~this in ECAassertion) or
             ( (~this in IsA) and exists a/Attribute From(~this,a) and 
             ((a in QueryClass!retrieved_attribute) or (a in View!inherited_attribute))) or
             (~this in IsolatedValue[String/type]) or
             (~this in IsolatedValue[Integer/type]) or
             (~this in IsolatedValue[Real/type]) or
             (~this in IsolatedCB_User) or
             :(~this in TransactionTime): and not (exists z/Proposition (~this attribute z))
             $,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette contains gt)) ==> (pal contains gt) $,$Rule(Condition(exists([In(_G33706, id_881), In(_G33712, id_891), Isa(_G33712, id_1698), NE(_G33712, id_1640)], exists([Adot(id_879, id_1698, _G33706)], TRUE))), Conclusion(Adot(id_879, _G33712, _G33706)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette contains gt)) ==> (pal contains gt) $,$Rule(Condition(exists([In(_G40259, id_881), In(_G40265, id_891), Isa(_G40265, id_1640), NE(_G40265, id_1640)], exists([Adot(id_879, id_1640, _G40259)], TRUE))), Conclusion(Adot(id_879, _G40265, _G40259)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette defaultIndividual gt)) ==> (pal defaultIndividual gt) $,$Rule(Condition(exists([In(_G28653, id_891), Isa(_G28653, id_1698), NE(_G28653, id_1640), In(_G28647, id_881)], exists([Adot(id_894, id_1698, _G28647)], TRUE))), Conclusion(Adot(id_894, _G28653, _G28647)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette defaultIndividual gt)) ==> (pal defaultIndividual gt) $,$Rule(Condition(exists([In(_G35135, id_891), Isa(_G35135, id_1640), NE(_G35135, id_1640), In(_G35129, id_881)], exists([Adot(id_894, id_1640, _G35129)], TRUE))), Conclusion(Adot(id_894, _G35135, _G35129)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette defaultLink gt)) ==> (pal defaultLink gt) $,$Rule(Condition(exists([In(_G22851, id_891), Isa(_G22851, id_1698), NE(_G22851, id_1640), In(_G22845, id_881)], exists([Adot(id_895, id_1698, _G22845)], TRUE))), Conclusion(Adot(id_895, _G22851, _G22845)))$,"computes the sum of the attributes in category <attrcat> of object <objname> (must be reals or integers)",$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette defaultLink gt)) ==> (pal defaultLink gt) $,$Rule(Condition(exists([In(_G29261, id_891), Isa(_G29261, id_1640), NE(_G29261, id_1640), In(_G29255, id_881)], exists([Adot(id_895, id_1640, _G29255)], TRUE))), Conclusion(Adot(id_895, _G29261, _G29255)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette implicitIsA gt)) ==> (pal implicitIsA gt) $,$Rule(Condition(exists([In(_G17286, id_891), Isa(_G17286, id_1698), NE(_G17286, id_1640), In(_G17280, id_881)], exists([Adot(id_896, id_1698, _G17280)], TRUE))), Conclusion(Adot(id_896, _G17286, _G17280)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette implicitIsA gt)) ==> (pal implicitIsA gt) $,$Rule(Condition(exists([In(_G23696, id_891), Isa(_G23696, id_1640), NE(_G23696, id_1640), In(_G23690, id_881)], exists([Adot(id_896, id_1640, _G23690)], TRUE))), Conclusion(Adot(id_896, _G23696, _G23690)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette implicitInstanceOf gt)) ==> (pal implicitInstanceOf gt) $,AVG_Attribute,$Rule(Condition(exists([In(_G12072, id_891), Isa(_G12072, id_1698), NE(_G12072, id_1640), In(_G12066, id_881)], exists([Adot(id_897, id_1698, _G12066)], TRUE))), Conclusion(Adot(id_897, _G12072, _G12066)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette implicitInstanceOf gt)) ==> (pal implicitInstanceOf gt) $,$Rule(Condition(exists([In(_G18566, id_891), Isa(_G18566, id_1640), NE(_G18566, id_1640), In(_G18560, id_881)], exists([Adot(id_897, id_1640, _G18560)], TRUE))), Conclusion(Adot(id_897, _G18566, _G18560)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette implicitAttribute gt)) ==> (pal implicitAttribute gt) $,$Rule(Condition(exists([In(_G7142, id_891), Isa(_G7142, id_1698), NE(_G7142, id_1640), In(_G7136, id_881)], exists([Adot(id_898, id_1698, _G7136)], TRUE))), Conclusion(Adot(id_898, _G7142, _G7136)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette implicitAttribute gt)) ==> (pal implicitAttribute gt) $,$Rule(Condition(exists([In(_G13623, id_891), Isa(_G13623, id_1640), NE(_G13623, id_1640), In(_G13617, id_881)], exists([Adot(id_898, id_1640, _G13617)], TRUE))), Conclusion(Adot(id_898, _G13623, _G13617)))$,$Rule(Condition(exists([In(_G17334, id_1)], TRUE)), Conclusion(Adot(id_876, _G17334, id_1732)))$,$Rule(Condition(exists([In(_G19893, id_15)], TRUE)), Conclusion(Adot(id_876, _G19893, id_1735)))$,$Rule(Condition(exists([In(_G22775, id_6)], TRUE)), Conclusion(Adot(id_876, _G22775, id_1710)))$,$Rule(Condition(exists([In(_G25430, id_7)], TRUE)), Conclusion(Adot(id_876, _G25430, id_1706)))$,$Rule(Condition(exists([In(_G28022, id_2)], TRUE)), Conclusion(Adot(id_876, _G28022, id_1726)))$,"computes the average of the attributes in category <attrcat> of object <objname> (must be reals or integers)",$Rule(Condition(exists([In(_G30623, id_24)], TRUE)), Conclusion(Adot(id_876, _G30623, id_1738)))$,$Rule(Condition(exists([In(_G33222, id_18)], TRUE)), Conclusion(Adot(id_876, _G33222, id_1741)))$,$Rule(Condition(exists([In(_G35800, id_21)], TRUE)), Conclusion(Adot(id_876, _G35800, id_1741)))$,$Rule(Condition(exists([In(_G38459, id_33)], TRUE)), Conclusion(Adot(id_876, _G38459, id_1744)))$,$Rule(Condition(exists([In(_G41097, id_65)], TRUE)), Conclusion(Adot(id_876, _G41097, id_1729)))$,jeusfeld,nixbld,MAX_Attribute,String,"gives the maximum of the attributes in category <attrcat> of object <objname> (must be reals or integers)",MIN_Attribute,"gives the minimum of the attributes in category <attrcat> of object <objname> (must be reals or integers)",PLUS,"computes r1 + r2",IPLUS,"computes i1 + i2",AssertionEvaluators,MINUS,"computes r1 - r2",IMINUS,Assertions,"computes i1 - i2",MULT,"computes r1 * r2",IMULT,"computes i1 * i2",DIV,MSFOLassertion,"computes r1 / r2",IDIV,"computes truncate(i1/i2)",ConcatenateStrings,"Appends string s2 to the end of string s1",ConcatenateStrings3,MAssertion,"Append strings s1 + s2 + s3",ConcatenateStrings4,"Append strings s1 + s2 + s3 + s4",StringToLabel,"returns s as a label (without quotes)",BDMConstraintCheck,BDMRuleCheck,MRule,get_object,exists,rename,get_object_star,Magic,changeAttributeValue,find_instances,$ (this in ~class) $,find_storeframes_instances,MSFOLrule,$ (this in ~class) and (not
(this in MSFOLassertion)) and
(not (this in BDMConstraintCheck)) and
(not (this in BDMRuleCheck))$,ISINSTANCE,$ ((~obj in ~class)==>(this == TRUE))and
    (not (~obj in ~class)==>(this == FALSE)) $,ISSUBCLASS,$ ((~sub isA ~super)==>(this == TRUE))and
    (not (~sub isA ~super)==>(this == FALSE)) $,find_iattributes,metaMSFOLrule,$ To(this,~class) $,find_specializations,$    (~ded == TRUE) and (this isA ~class)
           or (~ded == FALSE) and Isa_e(this,~class) $,MSFOLconstraint,AvailableVersions,$ exists x/Proposition P(x,~this,'*instanceof',Version) and Known(x,~time) $,find_incoming_links,$ To(this,~objname) and In(this,~category) $,find_incoming_links_simple,$ To(this,~objname) $,find_outgoing_links,metaMSFOLconstraint,$ From(this,~objname) and In(this,~category) $,find_outgoing_links_simple,$ From(this,~objname) $,find_classes,$ In(~objname,this) or
              (In_s(~this,QueryClass) and In(~objname,~this)) or
              (In_s(~this,QueryCall) and In(~objname,~this))$,find_explicit_classes,$ In_s(~objname,this) $,find_explicit_instances,MSFOLquery,$ In_s(this,~class) $,find_generalizations,$    (~ded == TRUE) and (~class isA this)
           or (~ded == FALSE) and Isa_e(~class,this) $,IS_EXPLICIT_INSTANCE,$ (In_s(~obj,~class)==>(this == TRUE)) and
    (not In_s(~obj,~class)==>(this == FALSE)) $,IS_EXPLICIT_SUBCLASS,QueryClass,$ (Isa_e(~sub,~super)==>(this == TRUE)) and
    (not Isa_e(~sub,~super)==>(this == FALSE)) $,find_referring_objects,$ exists a/Attribute l/Label Pa(a,this,l,~class) $,AF_find_referring_objects_obi,"","{ASKquery(get_object[{this}/objname],FRAME)}",IS_ATTRIBUTE_OF,$ exists l/Label Label(~attrCat,l) and A(~src,l,~dst) and UNIFIES(this,TRUE) $,Individual,IS_EXPLICIT_ATTRIBUTE_OF,$ exists l/Label Label(~attrCat,l) and A_e(~src,l,~dst) and UNIFIES(this,TRUE) $,get_links2,GenericQueryClass,$ exists l/Label P(this,~src,l,~dst) $,get_links3,$ exists l/Label P(this,~src,l,~dst) and (this in ~cat) $,find_all_explicit_attribute_values,$ exists x/Attribute l/Label Pa(x,~objname,l,this) $,find_referring_objects2,$ AeD(~cat,this,~objname) $,BuiltinQueryClass,find_all_referring_objects2,$ AD(~cat,this,~objname) $,find_attribute_categories,$ (exists c,d/Proposition l/Label In(~objname,c) and Pa(this,c,l,d) and not(UNIFIES(c,Proposition)) and
 not (In(d,MSFOLassertion) or In(d,BDMRuleCheck) or In(d,BDMConstraintCheck))) or UNIFIES(this,Attribute) $,find_used_attribute_categories,Token,View,$  exists x/Proposition AD(this,~objname,x) and 
                (this <> Class!rule) and (this <> Class!constraint) and 
                (this <> Proposition!applyConstraintIfInsert) and (this <> Proposition!applyConstraintIfDelete) and 
                (this <> Proposition!applyRuleIfInsert) and (this <> Proposition!applyRuleIfDelete) and 
                (this <> Proposition!deducedBy) $,find_attribute_values,$ AD(~cat,~objname,this) and not In(this,BDMRuleCheck) and not In(this,BDMConstraintCheck) $,find_explicit_attribute_values,$ AeD(~cat,~objname,this) and not In(this,BDMRuleCheck) and not In(this,BDMConstraintCheck) $,find_incoming_attribute_categories,$ (exists c,d/Proposition l/Label In(~objname,c) and Pa(this,d,l,c) and not(UNIFIES(c,Proposition))) or UNIFIES(this,Attribute) $,find_used_incoming_attribute_categories,SubView,$  exists x/Proposition AD(this,x,~objname)  $,find_object,$ UNIFIES(this,~objname) $,DatalogQueryClass,"Similar to get_object, but just returns the object (used by JavaGraphBrowser)",GraphicalType,GraphicalPalette,JavaGraphicalType,$ forall jgt/JavaGraphicalType (not (exists i/Integer A_e(jgt,priority,i))) ==> A(jgt,priority,0) $,JavaGraphicalPalette,SimpleClass,CBGraphEditorResult,"This answer format has four parameters: 'obj' is the object
   which is related to the result objects, 'cat' is the category of the link
   between 'obj' and 'this', 'pal' is the graphical palette, and 'objtype'
   specifies whether 'obj' should be considered as source (src) or destination (dst)
   in the set of edges to be included in answer.","<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>
<result>",DatalogRule,"</result>","
{buildCBEditorResult({this},{obj},{cat},{pal},{objtype})}
",CBGraphEditorResultWithoutEdges,"This answer format is like CBGraphEditorResult but it
   will not output any edges. Therefore, it has only the parameter
   'pal' to indicate the graphical palette.","
{buildCBEditorResultWithoutEdges({this},{pal})}
",GetJavaGraphicalPalette,DatalogInRule,$ UNIFIES(this,~pal) $,XML_JavaGraphicalPalette,"<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>
<palette>","</palette>","
<contains>
{Foreach(({this.contains}),(gt),
{ASKquery(GetJavaGraphicalType[{gt}/gt],XML_JavaGraphicalType)})}
</contains>
  <defaultIndividual>{this.defaultIndividual}</defaultIndividual>
  <defaultLink>{this.defaultLink}</defaultLink>
  <implicitIsA>{this.implicitIsA}</implicitIsA>
  <implicitInstanceOf>{this.implicitInstanceOf}</implicitInstanceOf>
  <implicitAttribute>{this.implicitAttribute}</implicitAttribute>
{Foreach(({this.palproperty},{this|palproperty}),(v,l),
  <palproperty>
    <name>{l}</name>
    <value>{v}</value>
  </palproperty>)}
",GetJavaGraphicalType,DatalogAttrRule,$ UNIFIES(~gt,this)  $,XML_JavaGraphicalType,"<graphtype>"
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
