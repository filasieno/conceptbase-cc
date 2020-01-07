{*
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
*}
{*
* File:         SubQueryCompiler.pro
* Version:      11.3
* Creation:     31-Jan-1996, Christoph Quix (RWTH)
* Last Change   : 96/10/28, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.SubQueryCompiler.pro
* Date retrieved : 97/01/21 (YY/MM/DD)

* --------------------------------------------------------------------------
*
* Dieses Modul uebersetzt die SubQueries einer QueryClass bzw. Views.
* compile_subqueries in Teil 1 erstellt den Datalog-Code.
* get_subquery_info in Teil 2 generiert die notwendigen Informationen
* fuer die Datalog-Regeln. Den Kern bildet handle_subquery, dass
* auch die Joinbedingungen speichert fuer den NF2-Ausdruck speichert.

* Changes: Prologcode-Erzeugung wird nach der Optimierung in RuleBase gemacht, hier macht nach der Compilierung nur
* die Initialisierung von den Ruleinfos.(vgl. QueryCompiler.)
*}

#MODULE(SubQueryCompiler)
#EXPORT(compile_subqueries/3)
#EXPORT(get_subquery_infos/2)
#ENDMODDECL()


#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(createNewVarname/1,QueryCompiler)
#IMPORT(buildQueryHead/3,QueryCompiler)
#IMPORT(buildQueryArgExp/3,QueryCompiler)
#IMPORT(create_IDS/2,QueryCompiler)
#IMPORT(store_tmp_QueryStruct/1,QueryCompiler)
#IMPORT(QCsubquery/4,QueryCompiler)
#IMPORT(generateRangeform/4,AssertionTransformer)
#IMPORT(generateDatalog/5,LTcompiler)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(convert_label/3,GeneralUtilities)
#IMPORT(IsView/1,FragmentToPropositions)
#IMPORT(build_param/4,QueryCompilerUtilities)
#IMPORT(check_if_param/4,QueryCompilerUtilities)
#IMPORT(insert_this_par_join/3,QueryCompilerUtilities)
#IMPORT(store_QCjoincond/1,QueryCompilerUtilities)
#IMPORT(get_main_query/2,ViewCompiler)
#IMPORT(initDatalogRulesInfo/5,RuleBase)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(QCisa/2,QueryCompiler)
#IMPORT(pc_atom_to_term/2,PrologCompatibility)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)




{** TEIL 1 **}
{*******************************************************************}
{                                                                   }
{ compile_subqueries(_mode,_query,_subqueries)                      }
{                                                                   }
{ Description of arguments:                                         }
{    mode : query oder mquery (hier wohl immer query)               }
{   query : ID der Query                                            }
{subqueries : Liste der SubQueries                                  }
{                                                                   }
{ Description of predicate:                                         }
{ compile_subqueries geht bereits davon aus, dass alle relevante    }
{ Information zur Erzeugung des Datalog-Codes gesammelt wurde,      }
{ entspricht genau der Uebersetzung der Hauptquery                  }
{                                                                   }
{*******************************************************************}

#MODE(compile_subqueries(i,i,i))


compile_subqueries(_,_,[]).

compile_subqueries(_mode,_q,[_subquery|_rest]) :-
	compile_subquery(_mode,_subquery),
	compile_subqueries(_mode,_q,_rest).



{*******************************************************************}
{                                                                   }
{ compile_subquery(_mode,_querystruct)                              }
{                                                                   }
{ Description of arguments:                                         }
{    mode : wie oben query oder mquery                              }
{querystruct : ein Term, der die Infos fuer die SQ enthaelt         }
{                                                                   }
{ Description of predicate:                                         }
{  SubQueries werden auf aehnliche Weise wie HauptQueries uebersetzt}
{  auch QueryStructs werden abgespeichert                           }
{*******************************************************************}

#MODE(compile_subquery(i,i))


compile_subquery(_mode,subquery(_subqname,QS(_queryHead,_vts,_lits),_subQAE)) :-
	create_IDS(_subqname,_qIDS),
	store_tmp_QueryStruct(_subQAE),
	generateRangeform(QS(_queryHead,_vts,_lits), '$ TRUE $', _queryRF, _vartab),
	get_main_query(_subqname,_qID),
	generateDatalog(_qID,_qIDS,_queryRF,_vartab,_ruleDLs),
	initDatalogRulesInfo(_ruleDLs,_mode,_qID,_qIDS,_vartab).



{** TEIL 2 **}
{*******************************************************************}
{                                                                   }
{ get_subquery_infos(_query,_info)                                  }
{                                                                   }
{ Description of arguments:                                         }
{   query : ID der HauptQuery                                       }
{    info : Liste von SubQuery-Termen                               }
{                                                                   }
{ Description of predicate:                                         }
{ sammelt die Information fuer die Subqueries auf und               }
{ erzeugt als Seiteneffekt (Join-)Information fuer die              }
{ NF2-Ausdruecke									                }
{ ( wird von get_all_infos der Hauptquery aufgerufen,               }
{   die Subviews sind zu diesem Zeitpunkt schon                     }
{   compiliert und NF2-Ausdruck liegt vor.)                         }
{*******************************************************************}

#MODE(get_subquery_infos(i,o))


get_subquery_infos(_q,_info) :-
	findall(subquery(_subqname,_subQS,_subQAE),
			get_sub_info(_q,_subqname,_subQS,_subQAE),
			_info),
	{ Nicht mehr benoetigte Infos entfernen }
	retractall(QCisa(_q,_)),
	retractall(QCparam(_q,_p,_C)).


{*******************************************************************}
{                                                                   }
{ get_sub_info(_query,_subquery,_subQS,_subQAE)                     }
{                                                                   }
{ Description of arguments:                                         }
{   query : ID der HauptQuery                                       }
{subquery : Bezeichnung der Subquery (id_1234_label)                }
{   subQS : QueryStruct der SubQuery                                }
{  subQAE : QueryArgExp der SubQuery                                }
{                                                                   }
{ Description of predicate:                                         }
{  Holt die Infos fuer eine SubQuery fuer eine geg. Hauptquery.     }
{*******************************************************************}

#MODE(get_sub_info(i,o,o,o))


get_sub_info(_q,_subqname,_subQS,_subQAE):-
	QCsubquery(_q,_l,_destID,_type),
	handle_subquery(_q,_l,_destID,_type,_subQS,_subQAE),
	pc_atomconcat(_q,'_',_h1),
	convert_label(_q,_l,_l1),
	pc_atomconcat(_h1,_l1,_subqname).


{*******************************************************************}
{                                                                   }
{ handle_subquery(_q,_l,_dest,_type,_qs,_qae)                       }
{                                                                   }
{ Description of arguments:                                         }
{       q : ID der Hauptquery                                       }
{       l : Label des Subquery-Attributs                            }
{    dest : ID der Zielklasse des SQ-Attributs                      }
{    type : 'c' oder 'r' fuer computed/retrieved-attribute          }
{      qs : QueryStruct der SubQuery                                }
{     qae : QueryArgExp der SubQuery                                }
{                                                                   }
{ Description of predicate:                                         }
{ Je nach dem, ob die Zielkomponente des Attributes ein Ableitungs- }
{ ausdruck ist, muss man auf Parameter der Hauptquery achten, die   }
{ auftreten koennen. In jedem Fall muss man sich bei Ableitungsaus- }
{ druecken die Joinbedingung 'attributlabel'='this' fuer den Join   }
{ zwischen Subquery und Subview merken. Dies gilt jedoch nur,       }
{ wenn der Ableitungsausdruck tatsaechlich fuer einen Subview steht }
{und nicht fuer eine ganz normale Anfrageklasse.                    }
{                                                                   }
{*******************************************************************}

#MODE(handle_subquery(i,i,i,i,o,o))



{******}
{FALL 1}
{******}
{Fall 1: _destID ist derive-exp, d.h. beachte ggf. auch Parameter   }
{ nur erforderlich, wenn derive-Ausdruck fuer eine Subview steht !! }
{ Falls ein Parameter der Hauptquery an einen Parameter des Subviews}
{ uebergeben wird (z.B. S(p/q), wird erstens der Parameter p auch   }
{ ein Argument des Subquery und beim spaeteren Join mit dem Subview }
{ benoetigt man die Joinbedingung eq(p,q).                          }

handle_subquery(_q,_l,_destID,_type,QS(_queryHead,[('~this',_isalist)|_vts],_lits),_subQAE) :-
	retrieve_proposition(P(_destID,_ ,_label,_)),
#IF(SWI)
    sub_atom(_label,_,_,_,'derive('),
#ENDIF(SWI)
	pc_atom_to_term(_label,_term),
	_term = derive(_s,_dl),
	!,
	{Falls kein Parameter der Hauptquery im derive-Ausdruck (Zielkomponente }
	{ des Attributs) auftritt, braucht man auch keine Joinbedingung, d.h. _joins=[] }
	check_if_param(_dl,_q,_res,_parjoins1),
	insert_this_par_join(_dl,_parjoins1,_parjoins),

	{_res enthaelt die Parameterbeschreibung fuer die betroffenen }
	{ Parameter der Hauptquery, die ebenfalls in der Subquery auftreten}
	{ Diese Parameter muessen deshalb auch im Kopf der Subquery auftauchen }
	build_subquery_info(_q,_l,_destID,_type,_res,_lits,_vts,_args),
	QCisa(_q,_isalist),
	convert_label(_q,_l,_l1),
	pc_atomconcat([_q,'_',_l1],_subqueryID),

	{Ausser der Joinbedingung fuer Parameter, braucht man auf jeden Fall }
	{ die Bedingung, dass 'this' im Subview, 'l' in der Subquery entspricht; also }
	{ mit abspeichern; NICHT, wenn _destID bzw. der Derive-Ausdruck}
	{ nur auf eine normale generische Anfrageklasse verweist }

	{ Fuer den Join mit dem Subview: }
	{  falls _s ein View ist, zusaetzlich label und this joinen}
	((IsView(_s),
	  _njoins=[equal(_l,this)|_parjoins],
	  store_QCjoincond(QCjoincond(_subqueryID,_s,_njoins)),
	  !
	 );
	 { sonst reicht es, die Parameter zu joinen, das }
	 { wird aber durch den PROLOG-Code erledigt (es ist kein SubView!) }
	 (_njoins = _parjoins
	 )
	),
	{ fuer den Join zwischen Hauptquery und SubQuery, muss man }
	{ die Parameter und das this vergleichen }
	store_QCjoincond(QCjoincond(_q,_subqueryID,[equal(this,this)|_parjoins1])),
	buildQueryHead(_subqueryID,[('~this',_isalist)|_vts],_queryHead),
	buildQueryArgExp(_subqueryID,[this|_args],_subQAE).



{******}
{FALL 2}
{******}
{ Fall 2: Normalfall, Parameter der urspruenglichen Anfrage sind uninteressant, }
{ d.h destID ist keine DeriveExpression, dann muss man nur zwischen dem         }
{ this der Hauptquery und dem this der Subquery joinen!                         }

handle_subquery(_q,_l,_destID,_type,QS(_queryHead,[('~this',_isalist)|_vts],_lits),_subQAE) :-
	build_subquery_info(_q,_l,_destID,_type,[],_lits,_vts,_args),
	{5. Argument (_res) leer, da keine Parameter der Hauptquery relevant}
	QCisa(_q,_isalist),
	convert_label(_q,_l,_l1),
	pc_atomconcat([_q,'_',_l1],_subqueryID),

	{ Die Join-Bedingung fuer Haupt- und Subquery }
	store_QCjoincond(QCjoincond(_q,_subqueryID,[equal(this,this)])),

	{ Falls destID ein View ist, dann zusaetzlich Join zwischen }
	{ Subquery und SubView destID merken }
	((IsView(_destID),
	  store_QCjoincond(QCjoincond(_subqueryID,_destID,[equal(_l,this)]))
	 );
	 true
	),
	!,
	buildQueryHead(_subqueryID,[('~this',_isalist)|_vts],_queryHead),
	buildQueryArgExp(_subqueryID,[this|_args],_subQAE).




{*******************************************************************}
{                                                                   }
{ build_subquery_info(_q,_l,_dest,_type,_p,_lits,_vts,_args)        }
{                                                                   }
{ Description of arguments:                                         }
{       q : ID der HauptQuery                                       }
{       l : Label des SQ-Attributs                                  }
{    dest : ID der Zielklasse des SQ-Attributs                      }
{    type : c oder r, fuer computed/retrieved attribute             }
{       p : Liste von p(_p,_C) Termen fuer Parameter                }
{    lits : Literale fuer Param.-Var., this, und Attribut           }
{     vts : VarTabRange: Liste von Termen (_var,_type)              }
{    args : Liste fuer die QueryArgExp (c(_),r(_),p(_)-Terme)       }
{                                                                   }
{ Description of predicate:                                         }
{  erzeugt die notwendigen Angaben fuer subquery:                   }
{     a) Argument fuer den Attributwert und                         }
{     b) ggfs. fuer Parameter der Hauptquery                        }
{                                                                   }
{*******************************************************************}

#MODE(build_subquery_info(i,i,i,i,i,o,o,o))


build_subquery_info(_q,_l,_destID,c,_p,
		[lit(In(_pl,_destID))|_lits],
		[(_pl,_destID)|_pvt],
		[c(_l)|_args]) :-
	{fuer computed_attributes, die nicht necessary sind, also nicht in constraint auftauchen }
	{hier wird noch neue Var kreiert, da sowieso keine Bezuege moeglich sind}
	createNewVarname(_pl),
	build_param(_p,_lits,_pvt,_args).

build_subquery_info(_q,_l,_destID,r,_p,
		[lit(A_label('~this',_l,_pl,_label)),lit(In(_pl,_destID))],
		[(_label,_labid),(_pl,_destID)|_pvt],
		[r(_l)|_args]):-
	{fuer retrieved attributes}
	createNewVarname(_pl),
	createNewVarname(_label),
	name2id(Proposition,_propid),
	name2id(Label,_labid),
	build_param(_p,_lits,_pvt,_args).

