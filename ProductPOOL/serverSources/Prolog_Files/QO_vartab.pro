{*
The ConceptBase.cc Copyright

Copyright 1987-2025 The ConceptBase Team. All rights reserved.

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

#MODULE(QO_vartab)
#EXPORT(bindVarsInVartab/3)
#EXPORT(cleanVT/0)
#EXPORT(countInstancesRFVartab/3)
#EXPORT(getClassFromRFVT/2)
#EXPORT(getClassesFromRFVT/2)
#EXPORT(getSmallestClassFromVarInfo/2)
#EXPORT(getSmallestSuperClass/4)
#EXPORT(getVarInfo/3)
#EXPORT(getVarsBoundExtern/1)
#EXPORT(getVarsBoundFromVartab/2)
#EXPORT(initVT/2)
#EXPORT(removeRFVartab/0)
#EXPORT(setExternBound/1)
#EXPORT(storeRFVartab/1)
#EXPORT(updateVTFromLit/3)
#ENDMODDECL()



#IMPORT(filterSuperClassesWithSize/3,QO_literals)
#IMPORT(getVarsList/2,QO_literals)
#IMPORT(getVars/2,QO_literals)
#IMPORT(getSource/2,QO_literals)
#IMPORT(getDest/2,QO_literals)
#IMPORT(isConst/1,QO_literals)
#IMPORT(isVar/1,QO_literals)
#IMPORT(listContainsRealSuperClass/2,QO_literals)
#IMPORT(listContainsSubClass/2,QO_literals)
#IMPORT(convert_label/2,GeneralUtilities)
#IMPORT(countInstances/2,QO_profile)
#IMPORT(clearRecords/1,QO_utils)
#IMPORT(max/2,QO_utils)
#IMPORT(member/2,GeneralUtilities)
#IMPORT(select/3,QO_utils)
#IMPORT(undefined/1,QO_utils)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_rerecord/2,PrologCompatibility)
#IMPORT(pc_rerecord/3,PrologCompatibility)
#IMPORT(pc_recorded/2,PrologCompatibility)
#IMPORT(pc_recorded/3,PrologCompatibility)
#IMPORT(pc_erase/1,PrologCompatibility)
#IMPORT(pc_erase/2,PrologCompatibility)
#IMPORT(pc_is_a_key/1,PrologCompatibility)
#IMPORT(pc_is_a_key/2,PrologCompatibility)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)




#MODE( getVarsBoundExtern(o))

getVarsBoundExtern(_vars) :-
	pc_recorded(QOTemp_ExtBound,_vars),!.
getVarsBoundExtern([]).


setExternBound(_vars) :-
	pc_rerecord(QOTemp_ExtBound,_vars).


{*------------------------------------------

Beim Parsen des Assertion-Textes wird bereits
eine Variablentabelle angelegt, in der zu
jeder Variablen die Klassenbindung vermerkt ist.
Diese Information wird zwischengespeichert.

  -----------------------------------------*}

{*------------------------------------------
storeRFVartab(_rangeList)

_rangeList ist eine Liste von Termen der Form
range(var,classList). Fuer jede Variable wird
ein Eintrag mit den Klassen in der Record-Database
zwischengespeichert.


  -----------------------------------------*}
#MODE( storeRFVartab(i))

storeRFVartab([]).
storeRFVartab([range(_v,_classList)|_ranges]) :-
	pc_atomconcat('~',_newV1,_v),!,
	convert_label(_newV1,_newV2),
	pc_atomconcat('_at_',_newV2,_newV),
	pc_rerecord(QOTransTemp_rfvt,_newV,_classList),
	storeRFVartab(_ranges).
storeRFVartab([range(_v,_classList)|_ranges]) :-
	convert_label(_v,_v1),
	pc_atomconcat('_',_v1,_newV),
	pc_rerecord(QOTransTemp_rfvt,_newV,_classList),
	storeRFVartab(_ranges).

removeRFVartab :-
	clearRecords(QOTransTemp_vartab),
	clearRecords(QOTransTemp_rfvt),!.


#MODE( getClassesFromRFVT(i,o))

getClassesFromRFVT(_var,_classes) :-
	pc_recorded(QOTransTemp_rfvt,_var,_classes).

#MODE( getClassFromRFVT(i,o))

getClassFromRFVT(_var,_class) :-
	pc_recorded(QOTransTemp_rfvt,_var,[_class|_]).



countInstancesRFVartab(_v,_vartab,_count) :-
	pc_atomconcat('_at_',_newV1,_v),!,
	pc_atomconcat('~',_newV1,_newV),
	member(range(_newV,_classList),_vartab),!,
	countInstancesList(_classList,_instList),
	max(_instList,_count).
countInstancesRFVartab(_v,_vartab,_count) :-
	pc_atomconcat('_',_var,_v),
	member(range(_var,_classList),_vartab),!,
	countInstancesList(_classList,_instList),
	max(_instList,_count).


countInstancesList([],[]).
countInstancesList([_class|_classList],[_inst|_instList]) :-
	countInstances(_class,_inst),
	countInstancesList(_classList,_instList).


{*------------------------------------------


  -----------------------------------------*}


#MODE( initVT(i,o))

{* ist die Variablentabelle bereits angelegt, dann
   wird diese zurueckgegeben *}
initVT(_lits,_vartab) :-
	pc_recorded(QOTransTemp_vartab,vtBuffer,_vartab),!.

{* existiert noch keine Variablentabelle, dann wird
   diese angelegt *}
initVT(_lits,_vartab) :-
	initializeVT(_lits,_vartab),
	pc_rerecord(QOTransTemp_vartab,vtBuffer,_vartab),!.


cleanVT :-
	((pc_is_a_key(QOTransTemp_vartab,vtBuffer),
	  pc_erase(QOTransTemp_vartab,vtBuffer));
	 true
	),!,
	((pc_is_a_key(QOTemp_ExtBound),
	  pc_erase(QOTemp_ExtBound));
	 true
	),!.



{* initialisieren der Variablentabelle *}
#MODE( initializeVT(i,o))

initializeVT(_lits,_vartab) :-
	getVarsList(_lits,_vars),
	initVT1(_vars,_vartab),!.



{* Fuer jede Variable wird ein leerer Eintrag erzeugt *}
#MODE( initVT1(i,o))

initVT1([],[]).
initVT1([_x|_vars],[_x-_entry|_othersVT]) :-
	initVarInfo(_x,_entry),
	initVT1(_vars,_othersVT).


#MODE( getVarsBoundFromVartab(i,o))

getVarsBoundFromVartab([],[]).
getVarsBoundFromVartab([_v-_entry|_vartab],[_v|_varsBound]) :-
	testAdInVarInfo(b,_entry),!,
	getVarsBoundFromVartab(_vartab,_varsBound).
getVarsBoundFromVartab([_|_vartab],_varsBound) :-
	getVarsBoundFromVartab(_vartab,_varsBound).


{* ------------------------------------------------------------------

   updateVTFromLit:
   die durch das aktuelle Literal gewonnenen Klassenbindungen werden
   in die Variablentabelle aufgenommen und die Variablen gebunden.

   ------------------------------------------------------------------*}

#MODE( updateVTFromLit(i,i,o))

updateVTFromLit(_vt,_lit,_newVt) :-
	updateClassesInVTFromLit(_vt,_lit,_newVt1),
	updateAdsInVTFromLit(_newVt1,_lit,_newVt).


{* ------------------------------------------------------------------

   updateClassesInVTFromLit:
   die durch das aktuelle Literal gewonnenen Klassenbindungen werden
   in die Variablentabelle aufgenommen

   ------------------------------------------------------------------*}

#MODE( updateClassesInVTFromLit(i,i,o))

updateClassesInVTFromLit(_oldVT,Adot(_p,_s,_d),_oldVT) :-
    isVar(_p),
    !.

{* Fall 1: Adot: Source und Destination-Klasse eintragen *}
updateClassesInVTFromLit(_oldVT,Adot(_p,_s,_d),_newVT) :-
	{* Source-Klasse eintragen *}
	(
	 (
		isConst(_s),
	   	_remVT2 = _oldVT
	 );
	 (
	 	getSource(_p,_src),
	 	selectVTEntry(_s,_oldVT,_sInfo,_remVT1),
	 	updateClassInVarInfo(_sInfo,_src,_newSInfo),
	 	_remVT2 = [_s - _newSInfo|_remVT1]
	 )
	),!,


	{* Destination-Klasse eintragen *}
	(
	 (
		isConst(_d),
	   	_newVT = _remVT2
	 );
	 (
	 	getDest(_p,_dest),
	 	selectVTEntry(_d,_remVT2,_dInfo,_remVT3),
	 	updateClassInVarInfo(_dInfo,_dest,_newDInfo),
	 	_newVT = [_d - _newDInfo|_remVT3]
	 )
	),!.

{* Fall 2: In: Klasse fuer Variable eintragen *}
updateClassesInVTFromLit(_oldVT,In(_x,_c),_newVT) :-
	isConst(_c),
	selectVTEntry(_x,_oldVT,_xInfo,_remVT),!,
	updateClassInVarInfo(_xInfo,_c,_newXInfo),
	_newVT = [_x-_newXInfo|_remVT],!.

{* Catchall *}
updateClassesInVTFromLit(_oldVT,_,_oldVT).

{* ------------------------------------------------------------------

   updatAdsInVTFromLit:
   Die Variablen des aktuellen Literals werden gebunden.

   ------------------------------------------------------------------*}

#MODE( updateAdsInVTFromLit(i,i,o))

updateAdsInVTFromLit(_oldVartab,_lit,_newVartab) :-
	getVars(_lit,_vars),
	bindVarsInVartab(_vars,_oldVartab,_newVartab).


removeVT :-
	clearRecords(QOTransTemp_vartab).


#MODE( selectVTEntry(i,i,o,o))

selectVTEntry(_var,_vt,_varInfo,_remVT) :-
	select(_var-_varInfo,_vt,_remVT).



#MODE((i,i,o))

getVarInfo(_var,_vt,_varInfo) :-
	selectVTEntry(_var,_vt,_varInfo,_).


#MODE( updateAdsInVartab(i,i,i,o))

updateAdsInVartab([],[],_vartab,_vartab).
updateAdsInVartab([_v|_vars],[_ad|_ads],_vartabIn,_vartab) :-
	updateAdInVartab(_v,_ad,_vartabIn,_newVT),
	updateAdsInVartab(_vars,_ads,_newVT,_vartab).


#MODE( updateAdInVartab(i,i,i,o))


{* 22-Sep-2005/M.Jeusfeld: function calls like COUNT[..] are translated to *}
{* literals like id_x(_,...) where the first argument is an anymymous      *}
{* variable. This variable is only used as a placeholder for later         *}
{* evaluation of the function by evalFunctionArg in Literals.pro.          *}
{* We need to exclude this variable from updateAdInVartab because it will  *}
{* not occur in any other literals inside the same formula.                *}
{* By this change, expressions like (TokenNr[~state/state,pl/place] > 0)   *}
{* become possible where TokenNr is a user-defined instance of Function.   *}
{* See also example HOW-TO / Capture some semantics of Petri Nets          *}
{* in the CB-Forum.                                                        *}

{* this is the case with the anonymous variable: leave vartab unchanged    *}
updateAdInVartab('_',_,_vt,_vt) :- !.

{* this is the regular case *}
updateAdInVartab(_v,_ad,_vartabIn,[_v-_newVEntry|_remVT]) :-
	selectVTEntry(_v,_vartabIn,_vEntry,_remVT),
	updateAdInVarInfo(_vEntry,_ad,_newVEntry).

#MODE( bindVarsInVartab(i,i,o))

bindVarsInVartab([],_vt,_vt).
bindVarsInVartab([_v|_vs],_oldvt,_vt) :-
	updateAdInVartab(_v,b,_oldvt,_newvt),
	bindVarsInVartab(_vs,_newvt,_vt).




#MODE( initVarInfo(i,o))

initVarInfo(_var,info(_ad,_smallestClass,_classes,_views,_distrib)) :-
	_ad = f,_classes = [],_views = [],undefined(_distrib),undefined(_smallestClass).




{*----------------------------------------------------------
   updateClassesInVarInfo(_vtEntry,_classList,_newVTEntry)

   In _vtEntry werden die Klassen aus _classList hinzugefuegt

  -----------------------------------------------------------*}
#MODE( updateClassesInVarInfo(i,i,o))

updateClassesInVarInfo(_info,[],_info).
updateClassesInVarInfo(_infoIn,[_c|_classes],_infoOut) :-
	updateClassInVarInfo(_infoIn,_c,_infoNew),
	updateClassesInVarInfo(_infoNew,_classes,_infoOut).

{*----------------------------------------------------------
   updateClassInVarInfo(_vtEntry,_classList,_newVTEntry)

   In _vtEntry wird die Klasse _class hinzugefuegt

  -----------------------------------------------------------*}

#MODE( updateClassInVarInfo(i,i,o))

{* Fall a: noch keine Klasse eingetragen -> kleinste Klasse undefiniert *}
updateClassInVarInfo(info(_ad,_smallestClass,_classes,_views,_distrib),
		     _class,
                     info(_ad,_class,[_class|_classes],_views,_distrib)) :-
	undefined(_smallestClass),!.

{* Fall b: Klasse hinzufuegen, testen, ob kleinste Klasse geandert *}
{* Fall b1: neue Klasse ist Subklasse der bisher kleinsten Klasse *}
updateClassInVarInfo(info(_ad,_smallestClass,_classes,_views,_distrib),
		     _class,
                     info(_ad,_newSmallestClass,[_class|_classes],_views,_distrib)) :-

	listContainsRealSuperClass(_class,[_smallestClass]),!,
	_newSmallestClass = _class.

{* Fall b2: neue Klasse ist kleiner als bisher kleinste Klasse *}
updateClassInVarInfo(info(_ad,_smallestClass,_classes,_views,_distrib),
		     _class,
                     info(_ad,_newSmallestClass,[_class|_classes],_views,_distrib)) :-

	{* spaeter hinzufuegen ...
	countAllInstances(_smallestClass,_cSmall),
	countAllInstances(_class,_cClass), *}
	countInstances(_smallestClass,_cSmall),
	countInstances(_class,_cClass),
	((_cClass < _cSmall,_newSmallestClass = _class);
	 (_cClass >= _cSmall,_newSmallestClass = _smallestClass)),!.

#MODE( getSmallestClassFromVarInfo(i,o))

getSmallestClassFromVarInfo(info(_,_smallestClass,_,_,_),_) :-
	undefined(_smallestClass),
	!,
	fail.
getSmallestClassFromVarInfo(info(_,_smallestClass,_,_,_),_smallestClass).


#MODE( getClassesFromVarInfo(i,o))

getClassesFromVarInfo(info(_,_,_classes,_,_),_classes).



{*----------------------------------------------------------
   updateAdInVarInfo(_vtEntry,_ad,_newVTEntry)

   In _vtEntry wird das Belegungsmuster auf _ad hinzugefuegt

  -----------------------------------------------------------*}

#MODE( updateAdInVarInfo(i,i,o))

updateAdInVarInfo(info(_,_smallestClass,_classes,_views,_distrib),
                  _ad,
	          info(_ad,_smallestClass,_classes,_views,_distrib)).



#MODE( testAdInVarInfo(i,i))

testAdInVarInfo(_ad,info(_ad,_smallestClass,_classes,_views,_distrib)).



{*----------------------------------------------------------
   getSmallestSuperClass(_x,_c,_vartab,_ssc)

   Wenn sich unter den Klassen fuer _x Oberklassen von
   _c befinden, so wird die kleinste dieser Klassen
   zurueckgegeben

  -----------------------------------------------------------*}
#MODE( getSmallestSuperClass(i,i,i,o))

getSmallestSuperClass(_x,_c,_vartab,_ssc) :-
	selectVTEntry(_x,_vartab,_varInfo,_),
	getSmallestSuperClassFromVarInfo(_x,_c,_varInfo,_ssc).

getSmallestSuperClassFromVarInfo(_x,_c,_varInfo,_ssc) :-
	getSmallestClassFromVarInfo(_varInfo,_ssc),
	listContainsSubClass(_ssc,[_c]),!.
getSmallestSuperClassFromVarInfo(_x,_c,_varInfo,_ssc) :-
	getClassesFromVarInfo(_varInfo,_classes),
	filterSuperClassesWithSize(_c,_classes,_superClasses),
	_superClasses = [_-_ssc|_],!.




