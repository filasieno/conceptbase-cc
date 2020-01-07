/**
The ConceptBase.cc Copyright

Copyright 1987-2020 The ConceptBase Team. All rights reserved.

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
**/
/**
* File:         ViewCompiler.pro
* Version:      12.1
* Creation:     31-Jan-1996, Christoph Quix (RWTH)
* Last Change   : 98/04/03, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/SCCS/serverSources/Prolog_Files/s.ViewCompiler.pro
* Date retrieved : 98/04/22 (YY/MM/DD)

* --------------------------------------------------------------------------
*
* Dieses Modul generiert aus einer Sichtendefinition den NF2-Ausdruck.  (Teil 1)
* Dieser Ausdruck wird zusammen mit der Information ueber die Argumente
* (vgl. QueryStruct) als ViewArgExp abgespeichert. (Teil 2)
* Im dritten Abschnitt werden die fuer die Sichtenwartung noetigen
* Datalog-Regeln generiert. Das sind nicht (!) die Regeln mit del/ins-Literalen,
* sondern reine Datalog-Regeln, die die Joinbedingungen zwischen
* den einzelnen Teilanfragen darstellen, so wie sie bei buildNF2Exp
* berechnet worden sind.
**/

:- module('ViewCompiler',[
'buildNF2exp'/3
,'generate_additional_vm_rules'/0
,'get_ViewArgExp'/3
,'get_main_query'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


/* Teil 1 */
:- use_module('QueryCompilerUtilities.swi.pl').












:- use_module('QueryCompiler.swi.pl').

:- use_module('GeneralUtilities.swi.pl').

:- use_module('PropositionProcessor.swi.pl').

/* Teil 2 */
:- use_module('PROLOGruleProcessor.swi.pl').



/* Teil 3 */






:- use_module('Literals.swi.pl').
:- use_module('VMruleGenerator.swi.pl').
:- use_module('CodeCompiler.swi.pl').
:- use_module('CodeStorage.swi.pl').




:- use_module('RuleBase.swi.pl').

:- use_module('GlobalParameters.swi.pl').

:- use_module('PrologCompatibility.swi.pl').





:- style_check(-singleton).




/*********************************************************************/
/*********************************************************************/
/*** Teil 1                                                        ***/
/*** Aufbau der NF2-Ausdruecke                                     ***/
/*********************************************************************/
/*********************************************************************/

/*********************************************************************/
/*                                                                   */
/* buildNF2exp(_q,_argexp,_nfexp)                                    */
/*                                                                   */
/* Description of arguments:                                         */
/*       q : ID des Views                                            */
/*  argexp : Ausdruck der die Argumente eines Antwortterms beschreibt*/
/*            (vgl. QueryStruct)                                     */
/*   nfexp : Ausdruck mit NF2-Algebra aehnlichen Operationen, die aus*/
/*           den Datalog-Regeln einen komplexen Term zusammenbauen.  */
/*                                                                   */
/* Description of predicate:                                         */
/*   Zunaechst muessen die NF2-Ausdruecke fuer die Teilanfragen      */
/*   berechnet und anschliessend zu einem grossen Gesamtausdruck mit */
/*   Left-Outerjoins verbunden.                                      */
/*                                                                   */
/*********************************************************************/




/* 1. Ausdruck ist schon gespeichert */
buildNF2exp(_q,_argexp,_nfexp) :-
	get_ViewArgExp(_q,_argexp,_nfexp),
	!.

/* 2. Ausdruck muss errechnet werden */
buildNF2exp(_q,_finalargexp,_finalnfexp) :-
	/*suche zunaechst alle Subviews, die in subqueries auftauchen*/
	findall(sub_vq(_q,_dest,_label),
			(partofQuery(_q,_dest,_label),subquery(_q,_dest,_label)),
			_l1),

	/*und generiere sowohl NF2- als auch ArgExp's dafuer und zwar */
	/* * bereits unter Einschluss der zugehoerigen subquery */
	buildNF2_vq(_l1,_explist1,_argexplist1,_joincondlist1),

	/*dann betrachte alle Subqqueries, die NICHT gleichzeitig auch auf Subviews */
	/* gerichtet sind*/
	findall(sub_q(_q,_dest,_label),
			(subquery(_q,_dest,_label),not(partofQuery(_q,_dest,_label))),
			_l2),

	/*und baue fuer diese ebenfalls NF2-Ausdruck und Argexp*/
	buildNF2_q(_l2,_explist2,_argexplist2,_joincondlist2),

	/*fuege beide Listen aus NF2-Ausdruecken und Argexp zusammen*/
	append(_explist1,_explist2,_explist),
	append(_argexplist1,_argexplist2,_argexplist),
	append(_joincondlist1,_joincondlist2,_joincondlist),

	/*jetzt suche alle subviews, die direkt an der Hauptquery haengen*/
	findall(sub_v(_q,_dest,_label),
			(partofQuery(_q,_dest,_label),not(subquery(_q,_dest,_label))),
			_l3),
	buildNF2_v(_q,_l3,_nfexp31,_argexp31),

	/* hier muss man erstmal die retrieved_attributes mit ihren Labeln zusammen nesten*/
	/* genauso wie es in den Subqueries schon geschehen ist */
	build_nest_rattr(_nfexp31,_argexp31,_nfexp3,_argexp3),

	/* dann Nest' um Ergebnis herum und zwar auf alle Argumente ausser Parametern und */
	/* this*/
	build_xnest(_nfexp3,_argexp3,_nfexp4,_argexp4),

	/*Der Join von Hauptquery und subqueries erfolgt von links nach rechts, */
	/* Joinbedingungen (Gleichheiten) sind nur gleiche Bezeichner in den Argexp's, */
	/* keine zusaetzlichen Bedingungen */
	build_leftouterjoins(_joincondlist,[_nfexp4|_explist],[_argexp4|_argexplist],_finalnfexp,_finalargexp),
	store_tmp_ViewArgExp(_q,_finalargexp,_finalnfexp).


/* Die jeweils neu gewonnene Struktur spiegelt sich auch im argexp wieder !!, */
/* das heisst dieser  erhaelt jeweils zusaetzliche Argumente durch die dazugejointen */
/* Spalten. Joinspalten werden an ihrer Position im  linken Joinpartner beibehalten. */



/*********************************************************************/
/*                                                                   */
/* buildNF2_vq(_subvqlist,_nfexplist,_argexplist,_joincondlist)      */
/* buildNF2_vq_Exp(_subvq,_nfexp,_argexp,_joincond)                  */
/*                                                                   */
/* Description of arguments:                                         */
/* subvqlist : Liste von sub_vq-Termen mit HauptQuery,SubView,Label  */
/* nfexplist : Liste der NF2-Ausdruecke fuer obige sub_vqs           */
/*argexplist : Liste der ArgExpression fuer obige sub_vqs            */
/*joincondlist : Liste der Joinbedingungen zw. Hauptq. und Subquery  */
/*                                                                   */
/* Description of predicate:                                         */
/* Baue den NF2-Ausdruck zu einem Subview, der in einer subquery     */
/* auftritt und joine mit dieser Subquery.                           */
/* Zunaechst muessen die im Subview die Klassen der Parameter weg-   */
/* projeziert werden, da diese schon in der SubQuery auftauchen.     */
/* Dann joine den reduzierten SubView mit der Subquery und erstelle  */
/* dafuer auch eine ViewArgExp                                       */
/*                                                                   */
/*********************************************************************/




buildNF2_vq([],[],[],[]).

buildNF2_vq([_first|_rest],[_firstexp|_restexp],[_firstargexp|_restargexp],[_firstjoin|_rjoin]):-
	buildNF2_vq_Exp(_first,_firstexp,_firstargexp,_firstjoin),
	buildNF2_vq(_rest,_restexp,_restargexp,_rjoin).





buildNF2_vq_Exp(sub_vq(_q,_subv,_label),_nestexp,_nestjoinargexp,_mainjoincond) :-
	/*baue zunaechst unabhaengig Join-ausdruck und Argexp fuer den Subview zusammen*/
	buildNF2exp(_subv,_subvargexp,_subvnfexp),

	/* SubQuery ist Hauptquery+Label */
	convert_label(_q,_label,_label1),
	pc_atomconcat([_q,'_',_label1],_subq),

	/* Die Subquery muss dann mit dem Subview gejoint werden:*/
	/* da der Subview in einer Subquery auftritt, gibt es fuer ihn auch einen */
    /* QueryArgExp*/
	get_QueryStruct(_subq,_subqargexp),
	/* get_QueryStruct(_subv,_subvargexp), */

	/* Hole die Infos fuer den Join zwischen Subquery und SubView */
	((get_QCjoincond('QCjoincond'(_subq,_subv,_joincond)),
	  !
	 );
	 _joincond=[]
	),

	((get_QCjoincond('QCjoincond'(_q,_subq,_mainjoincond)),
	  !
	 );
	 _mainjoincond=[]
	),

	/* bearbeite zuerst joincond und Anhaengsel, d.h.
	  labels in joincond muessen durch Integer ersetzt werden,
	  ViewArgExp zur Subquery aufbauen (QueryArgExp der Subquery,
	  sollte schon da sein), und speicher alles zusammen ab. */

	/* Die Parameter-Klassen des SubViews brauchen wir nicht mehr,*/
	/* die wuerden nachdem Join als nutzlose Attribute stoeren */
	/* Deshalb werden die hier weg  projiziert! */
	project_out_parclasses(_subvargexp,_subvnfexp,_joincond,_redsubvargexp,_projexp),

	/* Joine reduzierten SubView mit der Subquery */
	build_xjoin(_subq,_subqargexp,_projexp,_redsubvargexp,_joincond,_joinexp),
	build_xjoin_argexp(_subqargexp,_redsubvargexp,_joincond,_joinargexp),

	/* Neste das Ergebnis ueber die Parameter und this */
	build_xnest(_joinexp,_joinargexp,_nestexp,_nestjoinargexp),
	store_tmp_ViewArgExp(_subq,_nestjoinargexp,_nestexp).




/*********************************************************************/
/*                                                                   */
/* buildNF2_q(_subqlist,_nfexplist,_argexplist,_joincondlist)        */
/* buildNF2_q_Exp(_subq,_nfexp,_argexp,_joincond)                    */
/*                                                                   */
/* Description of arguments:                                         */
/*    subq : subq-Term mit HauptQuery,Zielklasse und AttrLabel       */
/*   nfexp : NF2-Ausdruck dazu                                       */
/*  argexp : Argexpression                                           */
/*joincond : Joinbedingungen zwischen Hauptquery und Subquery        */
/*                                                                   */
/* Description of predicate:                                         */
/*   Behandlung von Subqueries, die nicht zu Subview fuehren         */
/*   Hier muss man eine Nest-Operation fuer die Subquery machen,     */
/*   bei der die Attributwerte zusammengenestet werden, und die      */
/*   Joinbedingungen fuer den Leftouterjoin mit der Hauptquery holen */
/*********************************************************************/




buildNF2_q([],[],[],[]).

buildNF2_q([_first|_rest],[_firstexp|_restexp],[_firstargexp|_restargexp],[_firstjoin|_rjoin]):-
	buildNF2_q_Exp(_first,_firstexp,_firstargexp,_firstjoin),
	buildNF2_q(_rest,_restexp,_restargexp,_rjoin).





buildNF2_q_Exp(sub_q(_q,_dest,_label),_nestexp,_argexp,_joincond) :-
	convert_label(_q,_label,_label1),
	pc_atomconcat([_q,'_',_label1],_sq),
    	get_QueryStruct(_sq,_oldargexp),
	((get_QCjoincond('QCjoincond'(_q,_sq,_joincond))
	 );
	 _joincond=[]
	),
	!,
	build_nest(_sq,_oldargexp,_nestexp,_argexp),
	/*auf alle Argumente, die nicht this, oder Parameter*/
	store_tmp_ViewArgExp(_sq,_argexp,_nestexp).





/*********************************************************************/
/*                                                                   */
/* buildNF2_v(_query,_subv,_nfexp,_argexp)                           */
/*                                                                   */
/* Description of arguments:                                         */
/*   query : ID der HauptQuery                                       */
/*    subv : Liste von subv-Termen mit Hauptquery,SubView,Label      */
/*   nfexp : NF2-Ausdruck dazu                                       */
/*  argexp : ArgExpression dazu                                      */
/*                                                                   */
/* Description of predicate:                                         */
/*   Behandlung der SubViews, die direkt an einer Hauptquery haengen */
/*   d.h. deren Attribut necessary ist.                              */
/*   Hier muessen mehrere Faelle unterschieden werden, z.B. ob es    */
/*   solche SubViews ueberhaupt gibt, ob die SubViews Parameter haben*/
/*   die beim Join zwischen HauptQuery und SubView beruecksichtigt   */
/*   werden muessen.                                                 */
/*********************************************************************/



/* 1. Fall: Es gibt keine sub_v's, dann gib die Werte der Hauptquery */
/*          als Ergebnis zurueck!*/
buildNF2_v(_q,[],_q,_qae) :-
	get_QueryStruct(_q,_qae).

/* 2. Fall: Es gibt welche, also baue die NF2-Exp und ArgExp */
/*          fuer den ersten und verwende das Ergebnis bei den*/
/*          folgenden SubViews.                              */
buildNF2_v(_q,[sub_v(_q,_sv,_label)|_rest],_nfexp,_argexp) :-
	get_QueryStruct(_q,_qae),
	buildNF2_v_Exp(sub_v(_q,_sv,_label),_q,_qae,_nfexp1,_argexp1),
	buildNF2_v(_rest,_nfexp1,_argexp1,_nfexp,_argexp).




/* Keine weiteren SubViews -> in=out */
buildNF2_v([],_nfexp,_argexp,_nfexp,_argexp).

/* Es gibt noch SubViews: Ergebnis fuer einen berechnen und */
/* fuer die Berechnung des naechsten SVs benutzen.          */
buildNF2_v([_h|_t],_nfexp1,_argexp1,_nfexp,_argexp) :-
	buildNF2_v_Exp(_h,_nfexp1,_argexp1,_nfexp2,_argexp2),
	buildNF2_v(_t,_nfexp2,_argexp2,_nfexp,_argexp).




/* 1. Fall: Baue die NF2-Expression und ArgExp, wenn der SubView    */
/*          Parameter hat, die in der Joinbedingung beruecksichtigt */
/*          werden muessen.                                         */
buildNF2_v_Exp(sub_v(_q,_sv,_label),_oldnfexp,_qae,_xjoinexp,_joinargexp) :-
	'View'(_sv,_),
	retrieve_proposition('P'(_id,_q,_label,_deriveID)),
	retrieve_proposition('P'(_deriveID,_,_deriveatom,_)),

    pc_atomconcat('derive(',_,_deriveatom),

	pc_atom_to_term(_deriveatom,_deriveterm),
	_deriveterm = derive(_sv,_dl),
	!,
	/* Baue die Joinbedingung aus den Parameterangaben */
	check_if_param(_dl,_q,_res,_parjoins1),
	insert_this_par_join(_dl,_parjoins1,_parjoins),
	_joins=[equal(_label,this)|_parjoins],
	/* und speichere das ganze ab */
	store_QCjoincond('QCjoincond'(_q,_sv,_joins)),
	/* Hole die ViewArgExp des SubViews */
	get_ViewArgExp(_sv,_svae1,_svnfexp1),
	/* projeziiere die Klassen der Parameter weg (braucht man nicht und stoeren nur) */
	project_out_parclasses(_svae1,_svnfexp1,_joins,_svae,_svnfexp),
	/* Baue den xJoin zwischen dem bisherigen Ergebnis und dem reduziertem SubView */
	build_xjoin(_oldnfexp,_qae,_svnfexp,_svae,_joins,_xjoinexp),
	build_xjoin_argexp(_qae,_svae,_joins,_joinargexp).

/* 2. Fall: SubView hat keine Parameter */
buildNF2_v_Exp(sub_v(_q,_sv,_label),_oldnfexp,_qae,_xjoinexp,_joinargexp) :-
	'View'(_sv,_),
	!,
	/* Joinbedingung nur fuer this */
	_joins=[equal(_label,this)],
	store_QCjoincond('QCjoincond'(_q,_sv,_joins)),
	get_ViewArgExp(_sv,_svae,_svnfexp),
	/* Baue den xjoin zwischen dem bisherigen Ergebnis und dem SubView wie oben */
	build_xjoin(_oldnfexp,_qae,_svnfexp,_svae,_joins,_xjoinexp),
	build_xjoin_argexp(_qae,_svae,_joins,_joinargexp).




/*********************************************************************/
/*********************************************************************/
/*** Teil 2                                                        ***/
/*** Speichern der oben berechneten ViewArgExpressions             ***/
/*********************************************************************/
/*********************************************************************/

/*********************************************************************/
/*                                                                   */
/* store_tmp_ViewArgExp(_q,_s,_nf)                                   */
/* get_ViewArgExp(_q,_s,_nf)                                         */
/* get_tmp_ViewArgExp(_q,_s,_nf)                                     */
/*                                                                   */
/* Description of arguments:                                         */
/*       q : ID des Views                                            */
/*       s : QueryStruct                                             */
/*      nf : NF2-Ausdruck zur Berechnung des Views                   */
/*                                                                   */
/*********************************************************************/



store_tmp_ViewArgExp(_q,_s,_nf) :-
	store_tmp_PROLOGrules(['ViewArgExp'(_q,_s,_nf)]).



get_ViewArgExp(_q,_s,_nf) :-
	pc_has_a_definition('ViewArgExp'(_,_,_)),
	'ViewArgExp'(_q,_s,_nf),
	!.

get_ViewArgExp(_q,_s,_nf) :-
	get_tmp_ViewArgExp(_q,_s,_nf).



get_tmp_ViewArgExp(_q,_s,_nf) :-
	get_tmp_PROLOGrules(['ViewArgExp'(_q,_s,_nf)]).





/*********************************************************************/
/*********************************************************************/
/*** Teil 3                                                        ***/
/*** Generieren der zusaetzlichen Regeln fuer die Sichtenwartung   ***/
/*********************************************************************/
/*********************************************************************/

/*********************************************************************/
/*                                                                   */
/* generate_additional_vm_rules/0                                    */
/*                                                                   */
/* Description of predicate:                                         */
/*   Generiert die Regeln, die die Joinbedingungen zwischen den Teil-*/
/*   anfragen darstellen. Die normale Auswertung benutzt diese Regeln*/
/*   nicht, sondern nur den NF2-Ausdruck. Bei der Sichtenwartung     */
/*   sind die komplexen NF2-Terme nur hinderlich, weshalb man hier   */
/*   diese Joins schon auf Datalog-Ebene durchfuehrt.                */
/*								    */
/*                                                                   */
/* Change: Hier werden auch ruleInfos bzgl die Regeln generiert,	    */
/* HW/6.98 und die Abspeicherung der Regel ist von		    */
/*	  genPrologCodeFromInfos uebergenommen. Deshalb faellt      */
/*	  generatePROLOGCode,handleCode in alle Submodule weg.      */
/*	  dazu wird genPrologCodeFromInfos in Hauptmodul 	    */
/*	  generate_additional_vm_rules	aufgerufen.                 */
/*  Bem:    normalerweise wird genPrologCodeFromInfos in             */
/*	  ObjectTransformator aufgerufen, und der erledigt die      */
/*	  PrologCode Erzeugung fuer alle generierten Regeln.        */
/*	  Aber hier die zusaetzlich Vmrules werden sehr spaeter     */
/*	  erzeugt,(nach der Integritycheck) so muss fuer alle hier  */
/*	  zusaetzlichen generierten VMRegeln noch seperate 	    */
/*	  Ruleinfos  erzeugen,optimieren und PrologCode erzeugen.   */

generate_additional_vm_rules :-
	get_cb_feature('ViewMaintenanceRules',off),!.

generate_additional_vm_rules :-
	get_cb_feature('ViewMaintenanceRules',on),
	save_setof('QueryArgExp'(_q,_s),get_tmp_QueryStruct('QueryArgExp'(_q,_s)),_qaelist),
	generate_additional_vm_rules(_qaelist),
	genPrologCodeFromInfos.




generate_additional_vm_rules([]).

/* fuer _q wurde schon eine Regel erzeugt */
generate_additional_vm_rules(['QueryArgExp'(_q,_qs)|_rqaes]) :-
	get_vm_query_name(_q,_vmq),
	get_QueryStruct(_vmq,_vmqs),
	!,
	generate_additional_vm_rules(_rqaes).

/* _q ist eine DatalogQueryClass */
generate_additional_vm_rules(['QueryArgExp'(_q,_qs)|_rqaes]) :-
    name2id('DatalogQueryClass',_dqid),
    prove_literal('In'(_q,_dqid)),
	!,
	generate_additional_vm_rules(_rqaes).


/* Subquery */
generate_additional_vm_rules(['QueryArgExp'(_sq,_sqs)|_rqaes]) :-
	'SubQuery'(_sq,_),
	!,
	get_main_query(_sq,_mq),
	get_QueryStruct(_mq,_mqs),
	/*Sicherstellen, dass es fuer mq eine VM-Regel gibt*/
	generate_additional_vm_rules(['QueryArgExp'(_mq,_mqs)]),
	get_vm_query_name(_mq,_vmq),
	get_QueryStruct(_vmq,_vmqs),
	get_QCjoincond('QCjoincond'(_mq,_sq,_joincond)),
	generate_additional_subquery_rule(_sq,_sqs,_vmq,_vmqs,_joincond),
	generate_additional_vm_rules(_rqaes).

generate_additional_vm_rules(['QueryArgExp'(_sv,_svs)|_rqaes]) :-
	name2id('SubView',_svid),
	prove_literal('In_s'(_sv,_svid)),
	!,
	/* mq kann auch eine SubQuery sein, aber wird genauso wie Query behandelt */
	get_QCjoincond('QCjoincond'(_mq,_sv,_joincond)),
	get_QueryStruct(_mq,_mqs),
	/*Sicherstellen, dass es fuer mq eine VM-Regel gibt*/
	generate_additional_vm_rules(['QueryArgExp'(_mq,_mqs)]),
	get_vm_query_name(_mq,_vmq),
	get_QueryStruct(_vmq,_vmqs),
	generate_additional_subview_rule(_sv,_svs,_vmq,_vmqs,_joincond),
	generate_additional_vm_rules(_rqaes).

/* alles ausser SubView */
generate_additional_vm_rules(['QueryArgExp'(_v,_vs)|_rqaes]) :-
	!,
	/* ein richtiger View/Query/ steht nicht rechts in einem Join -> keine Bedingungen */
	generate_additional_view_rule(_v,_vs),
	generate_additional_vm_rules(_rqaes).


/*********************************************************************/
/*                                                                   */
/* generate_additional_subquery_rule(_sq,_sqae,_mq,_mqae,_joincond)  */
/*                                                                   */
/* Description of arguments:                                         */
/*      sq : Bezeichnung der Subquery                                */
/*    sqae : QueryArgExp der Subquery                                */
/*      mq : HauptQuery                                              */
/*    mqae : QueryArgExp der HauptQuery                              */
/*joincond : Joinbedingung fuer den Join zwischen den beiden Queries */
/*                                                                   */
/* Description of predicate:                                         */
/*   hier muss man jetzt in den SubQuery Kopf alle Parameter der MQ  */
/*   eintragen, und im Rumpf einmal die normale SubQuery und das MQ- */
/*   Literal eintragen. Dabei Joinbedingungen zwischen Argumenten der*/
/*   MQ und SQ beachten!                                             */
/*                                                                   */
/*********************************************************************/



generate_additional_subquery_rule(_sq,_sqae,_mq,_mqae,_joincond) :-
	get_vm_query_name(_sq,_vmsq),
	buildQueryHead_with_QueryStruct(_sq,_sqae,_sqhead),
	replace_joinargs_in_QueryStruct(_mqae,_joincond,_newmqae),
	buildQueryHead_with_QueryStruct(_mq,_newmqae,_mqhead),
	add_parameter_to_SubQueryStruct(_newmqae,_sqae,_vmsqae), /* newmqae ist mit den join-args schon verunstaltet */
	add_parameter_to_SubQueryStruct(_mqae,_sqae,_goodqae), /* deshalb Parameter zur alte QAE hinzufuegen und ...*/
	buildQueryHead_with_QueryStruct(_vmsq,_vmsqae,_vmhead),
	_rule = (( _vmhead :- _sqhead , _mqhead)),
	current_view(_OID,_IDS,_Vartab),
	store_vm_rules(view(_OID,_IDS,_Vartab),[_rule]),        /** man merkt hier werden die vmrules gespeichert und */
								/*die Ruleinfos mit Cat: vmrule in VMruleGenerator erzeugt.*/
	initDatalogRulesInfo([_rule],query,_OID,_IDS,_Vartab),	/** Hier werden die Ruleinfos fuer die viewrules mit*/
								/*Cat: query erzeugt. */
	store_tmp_QueryStruct('QueryArgExp'(_vmsq,_goodqae)). 	/* ... hier abspeichern */



/*********************************************************************/
/*                                                                   */
/* generate_additional_subview_rule(_sv,_svae,_mq,_mqae,_joincond)   */
/*                                                                   */
/* Description of arguments:                                         */
/*      sv : SubView                                                 */
/*    svae : QueryArgExp des SubViews                                */
/*      mq : Query, die mit sv gejoint wird (Query oder SubQuery)    */
/*    mqae : QueryArgExp dazu                                        */
/*joincond : die Joinbedingungen                                     */
/*                                                                   */
/* Description of predicate:                                         */
/*   hier muss man nur im Rumpf einmal die normale SubView und das   */
/*   MQ-Literal eintragen. Dabei Joinbedingungen zwischen Argumenten */
/*   der MQ und SQ beachten! Im Kopf braucht man keine Parameter     */
/*   ergaenzen, die stehen beim SubView schon alle drin!             */
/*                                                                   */
/*********************************************************************/



generate_additional_subview_rule(_sv,_svae,_mq,_mqae,_joincond) :-
	get_vm_query_name(_sv,_vmsv),
	get_necessary_attributes(_svae,_necattrs,_mainsvae),
	generate_additional_necessary_attribute_rule(_sv,_svae,_mainsvae,_necattrs),
	buildQueryHead_with_QueryStruct(_sv,_svae,_svhead),
	replace_joinargs_in_QueryStruct(_mqae,_joincond,_newmqae),
	buildQueryHead_with_QueryStruct(_mq,_newmqae,_mqhead),
	buildQueryHead_with_QueryStruct(_vmsv,_mainsvae,_vmhead),
	_rule = (( _vmhead :- _svhead , _mqhead)),
	current_view(_OID,_IDS,_Vartab),
	store_vm_rules(view(_OID,_IDS,_Vartab),[_rule]),
	initDatalogRulesInfo([_rule],query,_OID,_IDS,_Vartab),
	store_tmp_QueryStruct('QueryArgExp'(_vmsv,_mainsvae)).



/*********************************************************************/
/*                                                                   */
/* generate_additional_view_rule(_v,_vae)                            */
/*                                                                   */
/* Description of arguments:                                         */
/*       v : View                                                    */
/*     vae : QueryArgExp des Views                                   */
/*                                                                   */
/* Description of predicate:                                         */
/*  hier muss man fast nichts machen, Hauptviews werden nicht auf der*/
/*  rechten Seite von irgendwelchen Joins benutzt. Deshalb nur Kopf- */
/*  literal und Rumpfliteral bauen, so wie es in der ArgExp steht.   */
/*                                                                   */
/*********************************************************************/



generate_additional_view_rule(_v,_vae) :-
	get_vm_query_name(_v,_vm),
	get_necessary_attributes(_vae,_necattrs,_mainvae),
	generate_additional_necessary_attribute_rule(_v,_vae,_mainvae,_necattrs),
	buildQueryHead_with_QueryStruct(_v,_vae,_vhead),
	buildQueryHead_with_QueryStruct(_vm,_mainvae,_vmhead),
	_rule = (( _vmhead :-  _vhead )),
	current_view(_OID,_IDS,_Vartab),
	store_vm_rules(view(_OID,_IDS,_Vartab),[_rule]),
	initDatalogRulesInfo([_rule],query,_OID,_IDS,_Vartab),
	store_tmp_QueryStruct('QueryArgExp'(_vm,_mainvae)).



/*********************************************************************/
/*                                                                   */
/* generate_additional_necessary_attribute_rule(_q,_qae,_mqae,_attrs)*/
/*                                                                   */
/* Description of arguments:                                         */
/*       q : Query der Attribute                                     */
/*     qae : ArgExp dazu                                             */
/*    mqae : ArgExp fuer das Hauptobjekt (this und Parameter)        */
/*    attr : Liste der Attribute in Argexp-Form (r,c,cp,rp-Terme)    */
/*                                                                   */
/* Description of predicate:                                         */
/*   Generiert zusaetzliche Regeln fuer die Necessary-Attribute einer*/
/*   Query. Die Necessary-Attribute sind normalerweise im Kopf der   */
/*   Hauptquery enthalten. Beim Loeschen eines Attributes kann man   */
/*   am Kopf der Hauptquery nicht erkennen welches Attribut geloescht*/
/*   wurde (falls es mehrere gibt) und ob das Hauptelement auch      */
/*   geloescht werden soll. Die zusaetzlichen Regeln bilden daher    */
/*   eine Projektion auf das Objekt (mit Parametern) und einem       */
/*   Attribut. In generate_(sub)view_rule wird eine Regel fuer die   */
/*   Projektion nur auf das Hauptobjekt gebildet. Bei der Loeschung  */
/*   eines Attributs sollte es daher einen Minus-Term fuer das       */
/*   Attribut geben und fuer die anderen Regeln gibt es eventuell    */
/*   alternative Ableitungen (rederive).                             */
/*********************************************************************/




generate_additional_necessary_attribute_rule(_q,_qae,_mqae,[]).

generate_additional_necessary_attribute_rule(_q,_qae,_mqae,[_attr|_rest]) :-
	buildQueryHead_with_QueryStruct(_q,_qae,_qhead),
	append(_mqae,[_attr],_vmqae),
	arg(1,_attr,_attrlabel),
        convert_label(_q,_attrlabel,_attrlabel1),
	pc_atomconcat(['vm_',_q,'_',_attrlabel1],_vmq),
	buildQueryHead_with_QueryStruct(_vmq,_vmqae,_vmhead),
	_rule = (( _vmhead :-  _qhead )),
	current_view(_OID,_IDS,_Vartab),
	store_vm_rules(view(_OID,_IDS,_Vartab),[_rule]),
	initDatalogRulesInfo([_rule],query,_OID,_IDS,_Vartab),
	store_tmp_QueryStruct('QueryArgExp'(_vmq,_vmqae)),
	generate_additional_necessary_attribute_rule(_q,_qae,_mqae,_rest).


/*********************************************************************/
/*                                                                   */
/* buildQueryHead_with_QueryStruct(_q,_qs,_head)                     */
/*                                                                   */
/* Description of arguments:                                         */
/*       q : Query                                                   */
/*      qs : QueryStruct                                             */
/*    head : Kopf der Query                                          */
/*                                                                   */
/* Description of predicate:                                         */
/*   Baut aus einem QueryStruct einen Regelkopf der in Datalog       */
/*   benutzt werden kann.                                            */
/*********************************************************************/



buildQueryHead_with_QueryStruct(_q,_qs,_head) :-
	get_args_from_QueryStruct(_qs,_arglist),
	_head =.. [_q|_arglist].


/*********************************************************************/
/*                                                                   */
/* get_args_from_QueryStruct(_qs,_arglist)                           */
/*                                                                   */
/* Description of arguments:                                         */
/*      qs : QueryStruct                                             */
/* arglist : Argumentliste mit Variablen als Atome,die mit _ beginnen*/
/*                                                                   */
/* Description of predicate:                                         */
/*   Gibt zu einem QueryStruct die Argumentliste zurueck             */
/*********************************************************************/



get_args_from_QueryStruct([],[]) :- !.
get_args_from_QueryStruct([_atom|_r],[_atomvar|_rarg]) :-
	atom(_atom),
	convert_label(_atom,_atom1),		/*  "..." wird durch HK...HK ersetzt.*/
	!,
	pc_atomconcat('_qvar_',_atom1,_atomvar),
	get_args_from_QueryStruct(_r,_rarg).

get_args_from_QueryStruct([p(_p,_c)|_r],[_pvar,_c|_rarg]) :-
	!,
	convert_label(_p,_p1),
	pc_atomconcat('_qvar_',_p1,_pvar),
	get_args_from_QueryStruct(_r,_rarg).

get_args_from_QueryStruct([cp(_p,_c)|_r],[_pvar,_c|_rarg]) :-
	!,
	convert_label(_p,_p1),
	pc_atomconcat('_qvar_',_p1,_pvar),
	get_args_from_QueryStruct(_r,_rarg).

get_args_from_QueryStruct([rp(_p,_c)|_r],[_plabel,_pvar,_c|_rarg]) :-
	!,
	convert_label(_p,_p1),
	pc_atomconcat('_qvar_',_p1,_pvar),
	pc_atomconcat(['_qvar_',_p1,'_label'],_plabel),
	get_args_from_QueryStruct(_r,_rarg).

get_args_from_QueryStruct([c(_c)|_r],[_cvar|_rarg]) :-
	!,
	convert_label(_c,_c1),
	pc_atomconcat('_qvar_',_c1,_cvar),
	get_args_from_QueryStruct(_r,_rarg).

get_args_from_QueryStruct([r(_c)|_r],[_clabel,_cvar|_rarg]) :-
	!,
	convert_label(_c,_c1),
	pc_atomconcat('_qvar_',_c1,_cvar),
	pc_atomconcat(['_qvar_',_c1,'_label'],_clabel),
	get_args_from_QueryStruct(_r,_rarg).




/*********************************************************************/
/*                                                                   */
/* replace_joinargs_in_QueryStruct(_qs,_joincond,_newqs)             */
/*                                                                   */
/* Description of arguments:                                         */
/*      qs : QueryStruct                                             */
/*joincond : Joinbedingung (Liste von equal-Termen)                  */
/*   newqs : neuer QueryStruct mit ersetzten Argumentnamen           */
/*                                                                   */
/* Description of predicate:                                         */
/*   Bei der Generierung der zusaetzlichen Regel wird zunaechst      */
/*   fuer die beiden Queries aus einem QueryStruct ein Regelkopf     */
/*   generiert. Damit in den Regelkoepfen auch gemeinsame Variablen  */
/*   benutzt werden, muessen in einem QS die Bezeichner der Argumente*/
/*   durch die entsprechende Bezeichner des anderen QS ersetzt werden*/
/*   Den passenden Bezeichner findet man in der Joinbedingung.       */
/*********************************************************************/



replace_joinargs_in_QueryStruct([],_,[]) :- !.

replace_joinargs_in_QueryStruct([this|_r],_joincond,[_np|_nr]) :-
	member(equal(this,_np),_joincond), /*_np muesste eigentlich immer this sein */
	!,
	replace_joinargs_in_QueryStruct(_r,_joincond,_nr).

replace_joinargs_in_QueryStruct([p(_p,_c)|_r],_joincond,[p(_np,_c)|_nr]) :-
	member(equal(_p,_np),_joincond),
	!,
	replace_joinargs_in_QueryStruct(_r,_joincond,_nr).

replace_joinargs_in_QueryStruct([cp(_p,_c)|_r],_joincond,[cp(_np,_c)|_nr]) :-
	member(equal(_p,_np),_joincond),
	!,
	replace_joinargs_in_QueryStruct(_r,_joincond,_nr).

replace_joinargs_in_QueryStruct([rp(_p,_c)|_r],_joincond,[rp(_np,_c)|_nr]) :-
	member(equal(_p,_np),_joincond),
	!,
	replace_joinargs_in_QueryStruct(_r,_joincond,_nr).

replace_joinargs_in_QueryStruct([c(_p)|_r],_joincond,[c(_np)|_nr]) :-
	member(equal(_p,_np),_joincond),
	!,
	replace_joinargs_in_QueryStruct(_r,_joincond,_nr).

replace_joinargs_in_QueryStruct([r(_p)|_r],_joincond,[r(_np)|_nr]) :-
	member(equal(_p,_np),_joincond),
	!,
	replace_joinargs_in_QueryStruct(_r,_joincond,_nr).

replace_joinargs_in_QueryStruct([this|_r],_joincond,[non_relevant_this|_nr]) :-
	!,
	replace_joinargs_in_QueryStruct(_r,_joincond,_nr).

replace_joinargs_in_QueryStruct([_t|_r],_joincond,[_nt|_nr]) :-
	functor(_t,_op,2),
	!,
	functor(_nt,_op,2),
	arg(1,_t,_arg),
	pc_atomconcat('non_relevant_',_arg,_narg),
	arg(1,_nt,_narg),
	arg(2,_t,_arg2),
	arg(2,_nt,_arg2),
	replace_joinargs_in_QueryStruct(_r,_joincond,_nr).

replace_joinargs_in_QueryStruct([_t|_r],_joincond,[_nt|_nr]) :-
	functor(_t,_op,1),
	!,
	functor(_nt,_op,1),
	arg(1,_t,_arg),
	pc_atomconcat('non_relevant_',_arg,_narg),
	arg(1,_nt,_narg),
	replace_joinargs_in_QueryStruct(_r,_joincond,_nr).



/*********************************************************************/
/*                                                                   */
/* add_parameter_to_SubQueryStruct(_qs,_subqs,_newsubqs)             */
/*                                                                   */
/* Description of arguments:                                         */
/*      qs : QueryStruct der HauptQuery                              */
/*   subqs : QueryStruct einer SubQuery                              */
/*newsubqs : Ergebnis                                                */
/*                                                                   */
/* Description of predicate:                                         */
/*   Fuegt die Parameter der Hauptquery in die SubQuery ein.         */
/*   Damit tauchen die Parameter der HQ auch in dem neuen generierten*/
/*   Kopf der SubQuery auf. Das ist noetig, weil man einer Aenderung */
/*   an der SubQuery auch den "ganzen" Objektnamen haben muss, zu dem*/
/*   auch die Parameter einer Query gehoeren.                        */
/*                                                                   */
/*********************************************************************/



add_parameter_to_SubQueryStruct([],_sq,_sq) :-!.

add_parameter_to_SubQueryStruct([p(_p,_c)|_r],_sq,_nsq) :-
	\+(member(p(_p,_c),_sq)),
	!,
	add_parameter_to_SubQueryStruct(_r,_sq,_nsq1),
	append(_nsq1,[p(_p,_c)],_nsq).

add_parameter_to_SubQueryStruct([cp(_p,_c)|_r],_sq,_nsq) :-
	\+(member(cp(_p,_c),_sq)),
	!,
	add_parameter_to_SubQueryStruct(_r,_sq,_nsq1),
	append(_nsq1,[cp(_p,_c)],_nsq).

add_parameter_to_SubQueryStruct([rp(_p,_c)|_r],_sq,_nsq) :-
	\+(member(rp(_p,_c),_sq)),
	!,
	add_parameter_to_SubQueryStruct(_r,_sq,_nsq1),
	append(_nsq1,[rp(_p,_c)],_nsq).

add_parameter_to_SubQueryStruct([_x|_r],_sq,_nsq) :-
	!,
	add_parameter_to_SubQueryStruct(_r,_sq,_nsq).



/* Erzeuge einen Namen fuer die generierten Zusatz-Queries */


get_vm_query_name(_q,_vmq) :-
	pc_atomconcat('vm_',_q,_vmq).

/* Hole den ID der Hauptquery zu einer SubQuery */


get_main_query(_id,_qID) :-
	pc_atomconcat('id_',_r1,_id),
	split_atom(_r1,'_',_num,_attr),
	\+(pc_atompart(_num,'_',_,_)),
	pc_atomconcat(['id_',_num],_qID),
	'Query'(_qID).




/*********************************************************************/
/*                                                                   */
/* get_necessary_attributes(_qae,_necattr,_mainqae)                  */
/*                                                                   */
/* Description of arguments:                                         */
/*     qae : QueryArgExp                                             */
/* necattr : ArgExp fuer Attribute                                   */
/* mainqae : ArgExp ohne Attribute (nur this und Parameter)          */
/*                                                                   */
/* Description of predicate:                                         */
/*   Filtert aus einer Argexp die Attribute heraus, das sind die     */
/*   Attribute die fuer die Query necessary sind.                    */
/*   Ist ein Attribut Parameter und retrieved/computed (cp+rp)       */
/*   dann taucht es sowohl in necattr als auch mainqae auf.          */
/*                                                                   */
/*********************************************************************/




get_necessary_attributes([],[],[]).

get_necessary_attributes([this|_rqae],_necattr,[this|_mainqae]) :-
	get_necessary_attributes(_rqae,_necattr,_mainqae).

get_necessary_attributes([p(_p,_c)|_rqae],_necattr,[p(_p,_c)|_mainqae]) :-
	get_necessary_attributes(_rqae,_necattr,_mainqae).

get_necessary_attributes([cp(_p,_c)|_rqae],_necattr,[cp(_p,_c)|_mainqae]) :-
	get_necessary_attributes(_rqae,_necattr,_mainqae).

get_necessary_attributes([rp(_p,_c)|_rqae],_necattr,[rp(_p,_c)|_mainqae]) :-
	get_necessary_attributes(_rqae,_necattr,_mainqae).

get_necessary_attributes([c(_c)|_rqae],[c(_c)|_necattr],_mainqae) :-
	get_necessary_attributes(_rqae,_necattr,_mainqae).

get_necessary_attributes([r(_c)|_rqae],[r(_c)|_necattr],_mainqae) :-
	get_necessary_attributes(_rqae,_necattr,_mainqae).





