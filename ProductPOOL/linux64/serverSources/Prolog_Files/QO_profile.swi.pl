/**
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
**/

:- module('QO_profile',[
'countInstances'/2
,'freq'/3
,'getGlobal'/2
,'instDest'/2
,'instSrc'/2
,'sol'/2
,'sol_withClass'/3
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('BIM2C.swi.pl').

:- use_module('QO_utils.swi.pl').
:- use_module('GeneralUtilities.swi.pl').

:- use_module('QO_literals.swi.pl').






:- use_module('PrologCompatibility.swi.pl').







:- style_check(-singleton).








/** sol gibt zu einen Literal die Gesamtzahl der
   Loesungen an **/
sol(_lit,_count) :-
	_lit =.. [_func|_],
	memberchk(_func,['From','To','Label']),!,
	getGlobal(prop,_count).


sol('In'(_,_),_count) :-
	getGlobal(inh,_count),!.
sol('Isa'(_,_),_count) :-
	getGlobal(isah,_count),!.


sol('A'(_,_m,_),_count) :-
	atom(_m),!,
	name2id('Attribute',_attrId),
	findall(_c,(
			qo_prove_literal('Label'(_p,_m)),
			qo_inSysClass(_p,_attrId),
			sol('Adot'(_p,_,_),_c)),
		_cList),

	sumlistReal(_cList,_count),!.

sol('Adot'(_p,_,_),_count) :-
	count(_p,in_i,h,_count).


sol('Ai'(_,_m,_),_count) :-
	atom(_m),!,
	name2id('Attribute',_attrId),
	findall(_c,(
			qo_prove_literal('Label'(_p,_m)),
			qo_inSysClass(_p,_attrId),
			sol('Aidot'(_p,_,_),_c)
 		   ),
		_cList),
	sumlistReal(_cList,_count),!.

sol('Aidot'(_p,_,_),_count) :-
	count(_p,in_i,h,_count).



sol_withClass('To'(_,_),_destClass,_sum) :-
	findall(_count,
		          (
		    		qo_prove_literal('In_s'(_i,_destClass)),
            		getBoxes('To',d,_boxes),
					getBoxesEntry(_i,_boxes,_count)
				  ),
			_countList),
	sumlist(_countList,_sum).

sol_withClass('From'(_,_),_destClass,_sum) :-
	findall(_count,
		          (
		    		qo_prove_literal('In_s'(_i,_destClass)),
            		getBoxes('From',d,_boxes),
					getBoxesEntry(_i,_boxes,_count)
				  ),
			_countList),
	sumlist(_countList,_sum).



/** instSrc gibt zu einem Literal die Anzahl der moeglichen
   Belegungen der Source Komponente an **/

instSrc('Adot'(_p,_,_),_count) :-
	getSource(_p,_class),
	count(_class,in_i,h,_count),!.
instSrc('A'(_,_m,_),_count) :-
	atom(_m),!,
	name2id('Attribute',_attrId),
	findall(_c,(
			qo_prove_literal('Label'(_p,_m)),
			qo_inSysClass(_p,_attrId),
			instSrc('Aidot'(_p,_,_),_c)),
		_cList),
	sumlistReal(_cList,_count),!.

instSrc('Ai'(_x,_m,_y),_count) :-
	instSrc('A'(_x,_m,_y),_count),!.
instSrc('Aidot'(_p,_x,_y),_count) :-
	instSrc('Adot'(_p,_x,_y),_count),!.
instSrc(_lit,_count) :-
	getGlobal(prop,_count).




/** instDest gibt zu einem Literal die Anzahl der moeglichen
   Belegungen der Destination Komponente an **/

instDest('Adot'(_p,_,_),_count) :-
	getDest(_p,_class),
	count(_class,in_i,h,_count),!.
instDest('A'(_,_m,_),_count) :-
	atom(_m),!,
	name2id('Attribute',_attrId),
	findall(_c,(
			qo_prove_literal('Label'(_p,_m)),
			qo_inSysClass(_p,_attrId),
			instDest('Aidot'(_p,_,_),_c)
		   ),
		_cList),
	sumlistReal(_cList,_count),!.

instDest('Ai'(_x,_m,_y),_count) :-
	sol('A'(_x,_m,_y),_count),!.
instDest('Aidot'(_p,_x,_y),_count) :-
	sol('Adot'(_p,_x,_y),_count),!.

instDest('Label'(_,_),_count) :-
	getGlobal(a,_count1),
	_count is _count1 + 2.0,!.


instDest(_lit,_count) :-
	getGlobal(prop,_count).





/** Freq gibt zu einem Objekt die Haeufigkeit seines
   Auftretens als Quell- oder Zielobjekt eines gegebenen
   Literals an
**/
freq('From'(_id,_x),s,1.0) :- !.
freq('To'(_id,_x),s,1.0) :- !.
freq('Label'(_id,_x),s,1.0) :- !.


freq('Label'(_x,'*instanceof'),d,_count) :-
	getGlobal(in,_count),!.
freq('Label'(_x,'*isa'),d,_count) :-
	getGlobal(isa,_count),!.
freq('Label'(_x,_),d,1.0).


freq('Adot'(_p,_,_),s,_count) :-
        getSource(_p,_sc),
        countInstances(_p,_ia),
        countInstances(_sc,_is),
        ((_is > 0, _count is _ia / _is);
         (_count = 0.0)),!.

freq('Adot'(_p,_,_),d,_count) :-
        getDest(_p,_dc),
        countInstances(_p,_ia),
        countInstances(_dc,_id),
        ((_id > 0,_count is _ia / _id);
         (_count = 0.0)),!.

freq('A'(_id,_m,_),s,_count) :-
	!,
	name2id('Attribute',_attrId),
	findall(_c,(
			qo_prove_literal('Label'(_p,_m)),
			qo_inSysClass(_p,_attrId),
			freq('Adot'(_p,_id,_),s,_c)),
		_cList),
	sumlistReal(_cList,_count).

freq('A'(_,_m,_id),d,_count) :-
	!,
	name2id('Attribute',_attrId),
	findall(_c,(
			qo_prove_literal('Label'(_p,_m)),
			qo_inSysClass(_p,_attrId),
			freq('Adot'(_p,_,_id),d,_c)
		   ),
		_cList),
	sumlistReal(_cList,_count).


freq('Ai'(_id,_m,_x),s,_count) :-
	!,
	freq('A'(_id,_m,_x),s,_count).

freq('Ai'(_,_m,_id),d,_count) :-
	!,
	name2id('Attribute',_attrId),
	findall(_c,(
			qo_prove_literal('Label'(_p,_m)),
			qo_inSysClass(_p,_attrId),
			count(_p,in_i,h,_c)
		   ),
		_cList),
	sumlistReal(_cList,_cAttr),
	getGlobal(prop,_c),
	_count is _cAttr / _c.

freq('Aidot'(_p,_id,_y),s,_count) :-
	!,
	freq('Adot'(_p,_id,_y),s,_count).
freq('Aidot'(_p,_,_id),d,_count) :-
	!,
	name2id('Attribute',_attrId),
	count(_p,in_i,h,_cAttr),
	getGlobal(prop,_c),
	_count is _cAttr / _c.


freq(_lit,d,_count) :-
	_lit =.. [_func|_args],
	memberchk(_func,['From','To']),!,
	_args = [_,_id],
	getBoxes(_func,d,_boxes),
	getBoxesEntry(_id,_boxes,_count).


freq(_lit,_dir,_count) :-
	_lit =.. [_func|_args],
	((_dir = s,_args = [_id,_]);
	 (_dir = d,_args = [_,_id])),
	memberchk(_func,['In','Isa']),!,
	getBoxes(_func,_dir,_boxes),
	getBoxesEntry(_id,_boxes,_count).




getBoxes('From',d,[d_in_o,d_isa_o,d_a_o]).
getBoxes('To',d,[d_in_i,d_isa_i,d_a_i]).
getBoxes('In',d,[in_i]).
getBoxes('In',s,[in_o]).
getBoxes('Isa',d,[isa_i]).
getBoxes('Isa',s,[isa_o]).




getBoxesEntry(_id,_boxes,_count) :-
	getBoxesEntry(_id,_boxes,0,_count).


	getBoxesEntry(_id,[],_count,_count) :- !.
	getBoxesEntry(_id,[_b|_bs],_oldCount,_count) :-
	 	getOrCreateExtNew(_id,_b,_tmpCount),
	 	_newCount is _oldCount + _tmpCount,
	 	getBoxesEntry(_id,_bs,_newCount,_count),!.





/** count gibt zu einem Objekt die Anzahl der Eintraege
   in der entsprechenden Box an
   Bei hullFlag = 'h' wird die entsprechende Huelle gebildet,
   bei hullFlag = 'd' werden nur die direkt gegebenen Boxen beruecksichtigt.
**/
count(_id,_box0,_hullFlag,_count) :-
	((_hullFlag == 'd',pc_atomconcat('d_',_box0,_box));
	 (_hullFlag == 'h',_box = _box0)),!,
	getOrCreateExtNew(_id,_box,_count),!.




/**==================================================================**/
/** Statistisches Profil der Objektbank:
   globale Zaehler und Boxenzaehler
**/




getGlobal(_what,_c) :-
	pc_atomconcat('c',_what,_key),
	pc_recorded(_key,'QO_prof',_c),!.

getGlobal(_what,_c) :-
	updateGlobalCounters,
	pc_atomconcat('c',_what,_key),
	pc_recorded(_key,'QO_prof',_c),!.

/** Verwaltung der globalen Zaehler
	* Gesamtzahl der Objekte
	* Gesamtzahl der Instanzenbeziehungen
	* Gesamtzahl der Spezialisierungsbeziehungen
	* Gesamtzahl der Attributsbeziehungen
**/


updateGlobalCounters :-
	/** Gesamtzahl der Objekte **/
	countOB_AllProp(_count1),
	try_countOB_All(_count1,_count2,_count3,_count4,_count5,_count6),

	/** Instanzenbeziehung zu den Systemklassen (s.o.)
	   hinzuzaehlen **/
	_tmp is 2 * _count1,
	_inst is _count2 + _tmp,
	_instH is _count5 + _tmp,

	pc_rerecord(cprop,'QO_prof',_count1),
	pc_rerecord(cin,'QO_prof',_inst),
	pc_rerecord(cisa,'QO_prof',_count3),
	pc_rerecord(ca,'QO_prof',_count4),
	pc_rerecord(cinh,'QO_prof',_instH),
	pc_rerecord(cisah,'QO_prof',_count6).




countOB_AllProp(_count) :-
	matchbox(in_i,_box),update_zaehler(id_0,_box,_c),   /** id_0=Proposition **/
	intToReal(_c,_count).


/** The operation countOB_All/5 builds a data structure that has about the size **/
/** of the object base. For huge object base, this will break the local stack   **/
/** or heap. Hence, we call the original countOB_All/5 only when the object     **/
/** base size is below a certain threshold. It is currently set to 10000 which  **/
/** covers medim sized object bases.                                            **/
/** When the object base size is beyound the threshold, we estimate the values  **/
/** for cs1,.._cs5. The estimate is based on some test runs with some example   **/
/** models.                                                                     **/
/** Part of solution to ticket #68.                                             **/

try_countOB_All(_allprop,_cs1,_cs2,_cs3,_cs4,_cs5) :-
  _allprop > 10000,
  fake_countOB_All(_allprop,_cs1,_cs2,_cs3,_cs4,_cs5),
  !.

/* 'Removed' this case of try_countOB_All as it causes stackoverflow, fake solution should be ok. 'CQ'/2008 */
try_countOB_All(_allprop,_cs1,_cs2,_cs3,_cs4,_cs5) :-
  countOB_All(_cs1,_cs2,_cs3,_cs4,_cs5).

/** This is the estimate for cs1,...,cs5 based on the value for allprop **/
fake_countOB_All(_allprop,_cs1,_cs2,_cs3,_cs4,_cs5) :-
  _cs1 is round(0.47*_allprop),
  _cs2 is 100,
  _cs3 is round(0.35*_allprop),
  _cs4 is round(0.60*_allprop),
  _cs5 is round(1.04*_allprop),
  !.

/** This is the original counting for cs1,...,cs5 **/
countOB_All(_cs1,_cs2,_cs3,_cs4,_cs5) :-
	findall(c(_c1,_c2,_c3,_c4,_c5),
			(prove_C_sys_class(_p,id_0),     /** id_0=Proposition **/
			 matchbox(in_o,_box1),
			 update_zaehler_ohne_huelle(_p,_box1,_c1),
			 matchbox(isa_o,_box2),
			 update_zaehler_ohne_huelle(_p,_box2,_c2),
			 matchbox(a_o,_box3),
			 update_zaehler_ohne_huelle(_p,_box3,_c3),
			 matchbox(in_o,_box4),
			 update_zaehler(_p,_box4,_c4),
			 matchbox(isa_o,_box5),
			 update_zaehler(_p,_box5,_c5)
			),
			_cList),
	sumCs(_cList,c(_cs1,_cs2,_cs3,_cs4,_cs5)).


sumCs([],c(0.0,0.0,0.0,0.0,0.0)).
sumCs([c(_c1,_c2,_c3,_c4,_c5)|_cs],c(_cs1,_cs2,_cs3,_cs4,_cs5)) :-
	sumCs(_cs,c(_s1,_s2,_s3,_s4,_s5)),
	_cs1 is _s1 + _c1,
	_cs2 is _s2 + _c2,
	_cs3 is _s3 + _c3,
	_cs4 is _s4 + _c4,
	_cs5 is _s5 + _c5 .


/* ALTE METHODE fuer updateGlobalCounters!!!!*/
/*
updateGlobalCounters :-
        * Gesamtzahl der Objekte *
        countOB_AllProp(_count1),

        * Gesamtzahl der direkten Instanzenbeziehung ohne
           Beziehungen zu Systemklassen Proposition
           und eine aus [Individual, Attribute, InstanceOf, Isa] *
        countOB_AllInst(_count2),

        * Gesamtzahl der direkten Isa-Beziehungen ohne reflexive
           Beziehungen, ohne Huelle *
        countOB_AllIsa(_count3),

        * Gesamtzahl der Attributsbeziehungen *
        countOB_AllA(_count4),

        * Gesamtzahl aller extensionalen Instanzenbeziehungen
           incl. der durch Isa ableitbaren *
        countOB_AllInH(_count5),

        * Gesamtzahl der Isa-Beziehungen *
        countOB_AllIsaH(_count6),
*/






/** Zaehle die Instanzen eines Objekts **/
countInstances(_oid,_count) :-
	getOrCreateExtNew(_oid,in_i,_count).



/** Zaehle die Klassen eines Objekts **/
countClasses(_oid,_count) :-
	getOrCreateExtNew(_oid,in_o,_count).



/** Zaehle die Oberklassen eines Objekts **/
countSuperClasses(_oid,_count) :-
	getOrCreateExtNew(_oid,isa_o,_count).



/** Zaehle die Unterklassen eines Objekts **/
countSubClasses(_oid,_count) :-
	getOrCreateExtNew(_oid,isa_i,_count).





/** Fall 1: Zaehler wurde bereits initialisiert **/
getOrCreateExtNew(_oid,_boxName,_count) :-
	pc_atomconcat('QO_prof',_oid,_idProf),
	pc_recorded(_boxName,_idProf,_count),!.

/** Fall 2: Zaehler wurde noch nicht initialisiert:
	2.1: nur direkte links werden gezaehlt **/
getOrCreateExtNew(_oid,_boxName,_count) :-
	pc_atomconcat(d,_,_boxName),!,
	pc_atomconcat('QO_prof',_oid,_idProf),
	get_OS_count_Direct(_oid,_boxName,_count),
	pc_rerecord(_boxName,_idProf,_count),!.


/** Fall 2: Zaehler wurde noch nicht initialisiert:
	2.2: die Isa-Huelle wird beruecksichtigt **/
getOrCreateExtNew(_oid,_boxName,_count) :-
	pc_atomconcat('QO_prof',_oid,_idProf),
	get_OS_count(_oid,_boxName,_count),
	pc_rerecord(_boxName,_idProf,_count),!.



/** Zu der Anzahl der Klassen eines Objekts werden
   die 2 Systemklassen jedes Objekts hinzugezaehlt **/
get_OS_count_Direct(_id,in_o,_count) :-
	!,matchbox(in_o,_box),
	update_zaehler_ohne_huelle(_id,_box,_count0),
	_count1 is _count0 + 2,
	intToReal(_count1,_count).

get_OS_count_Direct(_id,_box0,_count) :-
	matchbox(_box0,_box),
	update_zaehler_ohne_huelle(_id,_box,_count0),
	intToReal(_count0,_count).





/** Zu der Anzahl der Klassen eines Objekts werden
   die 2 Systemklassen jedes Objekts hinzugezaehlt **/
get_OS_count(_id,in_o,_count) :-
	!,matchbox(in_o,_box),
	update_zaehler(_id,_box,_count0),
	_count1 is _count0 + 2,
	intToReal(_count1,_count).

get_OS_count(_id,_box0,_count) :-
	matchbox(_box0,_box),
	update_zaehler(_id,_box,_count0),
	intToReal(_count0,_count).







matchbox(in_i,0).
matchbox(in_o,1).
matchbox(isa_i,2).
matchbox(isa_o,3).
matchbox(a_i,4).
matchbox(a_o,5).
matchbox(d_in_i,0).
matchbox(d_in_o,1).
matchbox(d_isa_i,2).
matchbox(d_isa_o,3).
matchbox(d_a_i,4).
matchbox(d_a_o,5).


