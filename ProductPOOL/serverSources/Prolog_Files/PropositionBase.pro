{*
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

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
*
*		DIESE MODUL WIRD IN DER AKTUELLEN VERSION VON CONCEPTBASE
*		NICHT MEHR GELADEN.	 9-Dez-1996 LWEB
*
* File:        PropositionBase.pro
* Version:     7.2
* Creation:    12-Oct-1987, Manfred Jeusfeld (UPA)
* Last Change: 08 Jun 1994, Kai v. Thadden (RWTH)
* Release:     7
* -----------------------------------------------------------------------------
*
* This Prolog module is part of the ConceptBase system which is a run-time
* system for the System Modelling Language (SML).
* The PropositionBase module is responsible for the managing of explicit
* (not inherited, not derived) propositions of objects. Its exported predi-
* cates mirror those of the PropositionProcessor except that there is the
* infix "PB" which stands for PropositionBase.
*
*
*
* Exported predicates:
* --------------------
*
*   + retrieve_PB_proposition/1
*      Succeeds if there is a matching propval for the proposition
*      description in arg1. The propval must be explicitly stored
*      in the KernelRepresentation module, i.e. there must have
*      been an appropriate 'create_PB_proposition'
*      call before the retrieval call.
*      In the case of success the free variables of arg1 are instantiated
*      with the appropriate components of the stored propval.
*      'retrieve_PB_proposition' performs no checks on arg1 (this has to
*      be done at higher level), it will backtrack if there are more than
*      one solutions.
*   + create_PB_proposition/1
*      Stores the proposition description in arg1.
*   + delete_PB_proposition/1
*      Deletes the proposition description in arg1.
*
* 02-Mar-1990 MSt : retrieve_PB_proposition/1 suceeds only for
*                   those propositions which belong to the
*                   specified searchspace (get_KBsearchSpace)
*
* 13-Jul-1990/MJf: Rep_static no longer in use, CBNEWS[98]
*
* 31-Aug-1990/AM:  literal forms of propositions are no longer supported.
*
* 30-Nov-1992/MJf: changed propval(id,x,l,y,t) and proposition(id,x,l,y,t,tt) to
* P(id,x,l,y) and hP(id,x,l,y,tt), i.e. the valid time component t is now
* eliminated (details in CBNEWS[147]).
*
*
* 9-Dez-1996/LWEB: alle Funktionen des Moduls PropositionBase.pro wurden in das
* Modul PropositionProcessor integriert.
}

{:- setdebug.}

#MODULE(PropositionBase)
#ENDMODDECL()

