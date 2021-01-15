{*
The ConceptBase.cc Copyright

Copyright 1987-2021 The ConceptBase Team. All rights reserved.

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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*}
#MODULE(QO_costBase)
#ENDMODDECL()



#IMPORT(save_plus/3,QO_utils)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_rerecord/2,PrologCompatibility)
#IMPORT(pc_rerecord/3,PrologCompatibility)
#IMPORT(pc_recorded/2,PrologCompatibility)
#IMPORT(pc_recorded/3,PrologCompatibility)
#IMPORT(pc_erase/1,PrologCompatibility)
#IMPORT(pc_erase/2,PrologCompatibility)
#IMPORT(pc_current_key/1,PrologCompatibility)
#IMPORT(pc_current_key/2,PrologCompatibility)
#IMPORT(pc_atomtolist/2,PrologCompatibility)
#IMPORT(pc_fopen/3,PrologCompatibility)
#IMPORT(pc_fclose/1,PrologCompatibility)
#IMPORT(pc_exists/1,PrologCompatibility)


{*--------------------------------------------------------------------*}
{*								      *}
{* Das Modul QO_costBase dient der Verwaltung der intensionalen Kosten*}
{* eines Literals. Den Literalen, die als Kopf einer Datalog-Regel    *}
{* auftreten, werden zwei verschiedene Kosten zugewiesen:	      *}
{*								      *}
{*	* der intensionale fan-out				      *}
{*	* die Kosten der Regelauswertung 			      *}
{*								      *}
{* Der intensionale fan-out eines Literals gibt an, wieviele          *}
{* Loesungen fuer ein Literal mit gegebenem Belegungsmuster durch     *}
{* die Anwednung der deduktiven Regeln fuer dieses Literal produziert *}
{* werden. Die Kosten der Regelauswertung beschreiben den Aufwand zur *}
{* Produktion dieser Loesungen.					      *}
{*								      *}
{* Fuer ein Literal werden dabei die Gesamtkosten abgespeichert, die  *}
{* sich unter Beruecksichtigung aller deduktiven Regeln ergeben.      *}
{* Beide Kosten ergeben sich dabei als Summe der Einzelkosten 	      *}
{* fuer jede deduktive Regel.					      *}
{*								      *}
{* Die Kostenterme werden zu einer Applikation persistent in der      *}
{* Datei OBlit.pro gespeichert.					      *}
{*								      *}
{*--------------------------------------------------------------------*}

#IMPORT(fanOutInt/3,OBlit)

#IMPORT(compCostInt/3,OBlit)


#IMPORT(memberchk/2,GeneralUtilities)



getCost(not(_lit),_ad,_fanOutInt,_compCostInt) :-
	!,
	getCost(_lit,_ad,_fanOutInt,_compCostInt).
getCost(_lit,_ad,_fanOutInt,_compCostInt) :-
	buildKey(_lit,_ad,_id),
	pc_current_key(QO_fanOutInt,_id),!,
	pc_recorded(QO_fanOutInt,_id,_fanOutInt),
	pc_recorded(QO_compCostInt,_id,_compCostInt).
getCost(_lit,_ad,0.0,0.0).

getCostsSum(_lit,_ad,_costSum) :-
	getCost(_lit,_ad,_fanOutInt,_compCostInt),
	save_plus(_fanOutInt,_compCostInt,_costSum).


storeCost(_lit,_ad,_fanOutInt,_compCostInt) :-
	buildKey(_lit,_ad,_id),
	storeLitCost(_id,_fanOutInt),
	storeTotalCost(_id,_compCostInt),!.

existsCost(_func) :-
	pc_atomconcat(_func,AD,_test),
	pc_current_key(QO_fanOutInt,_id),
	pc_atomconcat(_test,_,_id).


clearLitCosts :-
	pc_current_key(QO_fanOutInt,_id),
	pc_erase(QO_fanOutInt,_id),
	fail.
clearLitCosts :-
	pc_current_key(QO_compCostInt,_id),
	pc_erase(QO_compCostInt,_id),
	fail.
clearLitCosts.



cToBList([],[]).
cToBList([_ad|_ads],[_newAd|_newAds]) :-
	cToB(_ad,_newAd),
	cToBList(_ads,_newAds).

cToB(c,b).
cToB(b,b).
cToB(f,f).


{*
buildMaskForVars(_head,_vars,_realVars) :-
	buildMaskKey(_head,_key),
	buildMask(_vars,_realVars,_mask),
	pc_rerecord(QO_costMask,_key,_mask).


buildMaskKey(Adot(_p,_x,_l,_y),_key) :-
	pc_atomconcat(Adot,_p,_key),!.
buildMaskKey(In(_x,_c),_key) :-
	pc_atomconcat(In,_c,_key),!.
buildMaskKey(_lit,_key) :-
	functor(_lit,_key,_).

buildMask([],_,[]).
buildMask([_v|_vs],_rv,[1|_m]) :-
	memberchk(_v,_rv),!,
	buildMask(_vs,_rv,_m).
buildMask([_v|_vs],_rv,[0|_m]) :-
	buildMask(_vs,_rv,_m).


useMaskOnAd(_lit,_ad,_adOut) :-
	buildMaskKey(_lit,_key),
	pc_recorded(QO_costMask,_key,_mask),
	useMask(_ad,_mask,_adOut).


useMask([],[],[]).
useMask([_ad|_adIn],[0|_m],_relevant) :-
	useMask(_adIn,_m,_relevant).
useMask([_ad|_adIn],[1|_m],[_ad|_relevant]) :-
	useMask(_adIn,_m,_relevant).


*}



buildKey(Adot(_p,_x,_l,_y),[c,_ad1In,c,_ad2In],_id) :-
	cToB(_ad1In,_ad1),
	cToB(_ad2In,_ad2),
	pc_atomtolist(_adAtom,[_ad1,_ad2]),
	pc_atomconcat([Adot,_p,AD,_adAtom],_id),!.

buildKey(Adot(_p,_x,_l,_y),[_ad1In,_ad2In],_id) :-
	cToB(_ad1In,_ad1),
	cToB(_ad2In,_ad2),
	pc_atomtolist(_adAtom,[_ad1,_ad2]),
	pc_atomconcat([Adot,_p,AD,_adAtom],_id),!.

buildKey(In(_x,_c),[_adIn,c],_id) :-
	cToB(_adIn,_ad),
	pc_atomtolist(_adAtom,[_ad]),
	pc_atomconcat([In,_c,AD,_adAtom],_id),!.

buildKey(In(_x,_c),[_adIn],_id) :-
	cToB(_adIn,_ad),
	pc_atomtolist(_adAtom,[_ad]),
	pc_atomconcat([In,_c,AD,_adAtom],_id),!.

buildKey(_lit,_adIn,_id) :-
	functor(_lit,_fun,_),
	cToBList(_adIn,_ad),
	pc_atomtolist(_adAtom,_ad),
	pc_atomconcat([_fun,AD,_adAtom],_id).


storeLitCost(_id,_fanOutInt) :-
	(
	  ( pc_current_key(QO_fanOutInt,_id),
	    pc_recorded(QO_fanOutInt,_id,_costOld)
          );
	    _costOld = 0.0
	),!,
	save_plus(_costOld,_fanOutInt,_costNew),
	pc_rerecord(QO_fanOutInt,_id,_costNew).

storeTotalCost(_id,_compCostInt) :-
	(
	  ( pc_current_key(QO_compCostInt,_id),
	    pc_recorded(QO_compCostInt,_id,_costOld)
          );
	    _costOld = 0.0
	),
	save_plus(_costOld,_compCostInt,_costNew),
	pc_rerecord(QO_compCostInt,_id,_costNew).




#MODE( exportLit(i))

exportLit(_appPath) :-
	pc_atomconcat(_appPath,'/OBlit.pro',_file),
	pc_fopen(_litFile,_file,w),
	write(_litFile,'#MODULE(OBlit)
#ENDMODDECL()
'),
	write(_litFile,'\n\n'),
	write(_litFile,'#DYNAMIC(fanOutInt/3)
'),
	write(_litFile,'\n'),
	write(_litFile,'#DYNAMIC(compCostInt/3)
'),
	write(_litFile,'\n\n'),
	exportLitRecords(_litFile,'QO_fanOutInt'),
	exportTotalRecords(_litFile,'QO_compCostInt'),
	pc_fclose(_litFile),!.


#MODE( exportLitRecords(i,i))

exportLitRecords(_file,_prefix) :-
	pc_current_key(_key,_dkey),
	pc_atomconcat(_prefix,_,_key),
	pc_recorded(_key,_dkey,_val),
	write(_file,fanOutInt(_key,_dkey,_val)),
	write(_file,'.'),write(_file,'\n'),
	pc_erase(_key,_dkey),
	exportLitRecords(_file,_prefix).
exportLitRecords(_,_).

#MODE( exportTotalRecords(i,i))

exportTotalRecords(_file,_prefix) :-
	pc_current_key(_key,_dkey),
	pc_atomconcat(_prefix,_,_key),
	pc_recorded(_key,_dkey,_val),
	write(_file,compCostInt(_key,_dkey,_val)),
	write(_file,'.'),write(_file,'\n'),
	pc_erase(_key,_dkey),
	exportTotalRecords(_file,_prefix).
exportTotalRecords(_,_).


#MODE( loadLitCostRecords(i))

loadLitCostRecords(_appPath) :-
	clearLitCosts,
	pc_atomconcat(_appPath,'/OBlit.pro',_litFile),
	write('loading ...'),write(_litFile),nl,
	(
		(	pc_exists(_litFile),
			reconsult(_litFile),
			findall(fanOutInt(_key,_dkey,_val),
				(fanOutInt(_key,_dkey,_val),
		 		pc_rerecord(_key,_dkey,_val)),
			_),
			findall(compCostInt(_key,_dkey,_val),
				(compCostInt(_key,_dkey,_val),
		 		pc_rerecord(_key,_dkey,_val)),
			_)

		);
		(true)
	),!.