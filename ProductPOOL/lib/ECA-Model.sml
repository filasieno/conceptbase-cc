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
{*
* File:         %M%
* Version:      %I%
* Creation:    27-June-1996, Farshad Lashgari (RWTH)
* Last Change   : %E%, Christoph Quix (RWTH), Manfred Jeusfeld (UvT)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
*
* -----------------------------------------------------------------------------
*
*	This is the Model for ECA-Rules in ConceptBase.
*}


Class ECArule with
attribute
	ecarule : ECAassertion;
	priority_after: ECArule;
	priority_before : ECArule;
	mode : ECAmode;
	active : Boolean;
	depth : Integer;
	rejectMsg : String
constraint
	ecarule_single : 
		$ forall r/ECArule e1,e2/ECAassertion
		(r ecarule e1) and (r ecarule e2) ==> (e1 == e2) $;
	eca_necessary :
		$ forall r/ECArule exists e/ECAassertion
		(r ecarule e) $;
	mode_single :
		$ forall r/ECArule m1,m2/ECAmode
		(r mode m1) and (r mode m2) ==> (m1 == m2) $;
	active_single :
		$ forall r/ECArule a1,a2/Boolean
		(r active a1) and (r active a2) ==> (a1 == a2) $;
	depth_single : 
		$ forall r/ECArule i,j/Integer
		(r depth i) and (r depth j) ==> (i == j) $
end


Class ECAassertion in Assertions end

Class ECAmode end

Immediate in ECAmode end
ImmediateDeferred in ECAmode end
Deferred in ECAmode end


{* This is for queries that are used only for triggering ECArules. *}
{* YesClass serves as a superclass and only one result 'yes' is    *}
{* returned.                                                       *}

YesClass end

yes in YesClass  end 


	
