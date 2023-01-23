{*
The ConceptBase.cc Copyright

Copyright 1987-2023 The ConceptBase Team. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted
provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of
      conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE CONCEPTBASE TEAM ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONCEPTBASE TEAM OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the authors
and should not be interpreted as representing official policies, either expressed or implied,
of the ConceptBase Team.


The ConceptBase Team is represented by

Manfred Jeusfeld, University of Skovde, 54128 Skovde, Sweden


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*}
{
* File: PetriNetSimu.sml
* Author: Manfred Jeusfeld
* Created: 26-Oct-2005/M.Jeusfeld (5-Jan-2006/M.Jeusfeld)
* ------------------------------------------------------
* Executable variant for petri nets. Allows to fire specified
* transactions. An example on how to fire a transition is at the end of this
* file. You can inspect the current state of the petri net by the query
* ReportState.
* This file also contains a petri net example for 'safe traffic lights'
* taken from course material of Wil van der Aalst. 
* 
* This requires ConceptBase 6.2 released after 20-Dec-2005!
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


{* just outputs the current state of a place (= number of tokens) *}
TokenNr in Function isA Integer with
  parameter
    place: Place
  constraint
    c1: $ (~place tokenFill ~this) $
end

{* A transition is enabled if the number of Tokens *}
{* at all its input places is greater than zero.   *}

EnabledTransition in QueryClass isA Transition with
  constraint
    c1: $ forall pl/Place (pl sendsToken ~this) 
                 ==> (TokenNr[pl/place] > 0)
         $
end

{* A connected place is a place that is linked to a given transition *}
{* either by sending a token to it or receiving a token from it.     *}
{* A connected place is affected by firing a transition.             *}

ConnectedPlace in GenericQueryClass isA Place with
  parameter
    trans: Transition
  constraint
    isConnected: $ (~this sendsToken ~trans) or (~trans producesToken ~this) $
end

{* A link from a transition to a place (will produce tokens) *}
TransToPlace in GenericQueryClass isA Transition!producesToken with
  parameter
    trans: Transition;
    place: Place
  constraint
    c1: $ From(~this,~trans) and To(~this,~place) $
end

{* A link from a place to a transition (will consume tokens) *}
PlaceToTrans in GenericQueryClass isA Place!sendsToken with
  parameter
    trans: Transition;
    place: Place
  constraint
    c1: $ From(~this,~place) and To(~this,~trans) $
end


{* This function computes the net effect of firing the transition xt *}
{* upon the place xp. This is the difference between the number of   *}
{* links from xt to xp and the number of links from xp to xt.        *}

NetEffectOfTransition in Function isA Integer with
  parameter
    xt: Transition;
    xp: Place
  constraint
    c1: $ (~this in IMINUS[COUNT[TransToPlace[~xt/trans,~xp/place]/class]/i1,
                           COUNT[PlaceToTrans[~xt/trans,~xp/place]/class]/i2]) $
end


{* Artificial class to store firings of transitions. Needed to simulate *}
{* the execution of a petri net.                                        *}

FireTransition with
  attribute
    transition: Transition
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
        ON Tell( (fire transition tr) )
        IF (tr in EnabledTransition) and
           (pl in ConnectedPlace[tr/trans]) and
           (pl tokenFill n) and
           (n1 in IPLUS[n/i1,
                        NetEffectOfTransition[pl/xp,tr/xt]/i2])
        DO Untell( (pl tokenFill n) ),
           Tell( (pl tokenFill n1) )
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

{* You can fire a specified transition by telling instances of
   FireTransition. You have to tell the objects one by one
   since multiple concurrent firings are not yet supported
   by ConceptBase's transaction mechanism. 

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


