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
{
* File:		AnswerTransformUtilities.pro
* Creation:	1999, Wang Hua(RWTH)
* Last Change:  18-Dec-2001, Manfred Jeusfeld (Tilburg Univ.)
*
}

{ SWI/Sicstus: export predicates that should be visible in other modules }
#MODULE(AnswerTransformUtilities)
#EXPORT(IFTHENELSE/4)
#EXPORT(AND/3)
#EXPORT(OR/3)
#EXPORT(EQUAL/3)
#EXPORT(GREATER/3)
#EXPORT(LOWER/3)
#EXPORT(ASKquery/3)
#EXPORT(From/2)
#EXPORT(To/2)
#EXPORT(Label/2)
#EXPORT(Oid/2)
#EXPORT(STRINGENCODING/2)
#EXPORT(STRINGDECODING/2)
#EXPORT(QT/2) {* alias to STRINGENCODING }
#EXPORT(UQ/2) {* alias to STRINGDECODING }
#EXPORT(deleteAskQueryBuffers/0)
#EXPORT(deleteAskQueryBuffers_success/0)
#EXPORT(ISLASTFRAME/1)
#EXPORT(ISFIRSTFRAME/1)
#EXPORT(ALPHANUM/2)
#ENDMODDECL()

{ BIM/MasterProlog: declare predicates as global if they should be visible in other modules }
#GLOBAL(IFTHENELSE/4)
#GLOBAL(ISLASTFRAME/1)
#GLOBAL(ISFIRSTFRAME/1)
#GLOBAL(AND/3)
#GLOBAL(OR/3)
#GLOBAL(EQUAL/3)
#GLOBAL(GREATER/3)
#GLOBAL(LOWER/3)
#GLOBAL(ASKquery/3)
#GLOBAL(From/2)
#GLOBAL(To/2)
#GLOBAL(Label/2)
#GLOBAL(Oid/2)
#GLOBAL(STRINGENCODING/2)
#GLOBAL(STRINGDECODING/2)
#GLOBAL(QT/2)
#GLOBAL(UQ/2)
#GLOBAL(ALPHANUM/2)


#IMPORT(atom2list/2,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(member/2,GeneralUtilities)
#IMPORT(last/2,GeneralUtilities)
#IMPORT(delete/3,GeneralUtilities)
#IMPORT(reverse/2,GeneralUtilities)
#IMPORT(prove_literal/1,Literals)
#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(TermToCharList/2,IpcChannel)
#IMPORT(transform/2,AnswerTransformator)
#IMPORT(collect_frame_labels/2 ,AnswerTransformator)
#IMPORT(delete_first_and_last/2,AnswerTransform)
#IMPORT(outIdentifier/2,ScanFormatUtilities)
#IMPORT(outObjectName/2,ScanFormatUtilities)
#IMPORT(multiAppend/2,ScanFormatUtilities)
#IMPORT(listToCharListwithCommata/2,ScanFormatUtilities)
#IMPORT(quotedAtom/1,GeneralUtilities)
#IMPORT(ObjNameStringToList/2,TellAndAsk)
#IMPORT(EliminateClassInList/2,TellAndAsk)
#IMPORT(process_query/2,QueryProcessor)
#IMPORT(WriteTrace/3,GeneralUtilities)
#IMPORT(createBuffer/1,GeneralUtilities)
#IMPORT(createBuffer/2,GeneralUtilities)
#IMPORT(disposeBuffer/1,GeneralUtilities)
#IMPORT(getStringFromBuffer/2,ExternalCodeLoader)
#IMPORT(getPointerFromBuffer/2,ExternalCodeLoader)
#IMPORT(appendBuffer/2,ExternalCodeLoader)
#IMPORT(appendBufferP/2,ExternalCodeLoader)
#IMPORT(pc_record/2,PrologCompatibility)
#IMPORT(pc_record/3,PrologCompatibility)
#IMPORT(pc_rerecord/2,PrologCompatibility)
#IMPORT(pc_rerecord/3,PrologCompatibility)
#IMPORT(pc_recorded/2,PrologCompatibility)
#IMPORT(pc_recorded/3,PrologCompatibility)
#IMPORT(pc_erase_all/0,PrologCompatibility)
#IMPORT(pc_erase_all/1,PrologCompatibility)
#IMPORT(pc_erase/2,PrologCompatibility)
#IMPORT(pc_current_key/1,PrologCompatibility)
#IMPORT(pc_current_key/2,PrologCompatibility)
#IMPORT(pc_inttoatom/2,PrologCompatibility)
#IMPORT(pc_floattoatom/2,PrologCompatibility)
#IMPORT(pc_atom_to_term/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_stringtoatom/2,PrologCompatibility)
#IMPORT(SetUpdateMode/1,TellAndAsk)
#IMPORT(RemoveUpdateMode/1,TellAndAsk)
#IMPORT(IsLastFrame/1,AnswerTransform)
#IMPORT(IsFirstFrame/1,AnswerTransform)
#IMPORT(makeAlphanumeric/2,GeneralUtilities)


#DYNAMIC(askedQuery/1)
       {* see also TellAndAsk.pro for initialization }

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


{**************************************************Praedikate********************************************************************* }
{ Hier sind die Praedikaten, die als zu ersetzende Inhalte vorkommen koennen, jedoch ohne das erste Argument, das fuer die Ausgabe }
{ zustaendig ist. Alle Praedikaten muessen vorher global machen, somit sie in dem Modul AnswerTransform durch call(p(Argumentlist))}
{ aufgeruft werdeen koennen.												           }
{********************************************************************************************************************************* }


IFTHENELSE(_buf,'TRUE',_act1,_act2):-
  appendBuffer(_buf,_act1),
  !.

IFTHENELSE(_buf,'FALSE',_act1,_act2):-
  appendBuffer(_buf,_act2),
  !.

{* Predicates for IFTHENELSE *}
{* The first argument _buf is the output buffer.      *}

ISLASTFRAME(_buf) :-
  IsLastFrame(yes),
  appendBuffer(_buf,'TRUE'),
  !.

{* else: *}
ISLASTFRAME(_buf) :-
  appendBuffer(_buf,'FALSE'),
  !.

ISFIRSTFRAME(_buf) :-
  IsFirstFrame(yes),
  appendBuffer(_buf,'TRUE'),
  !.

{* else: *}
ISFIRSTFRAME(_buf) :-
  appendBuffer(_buf,'FALSE'),
  !.



AND(_buf,'TRUE','TRUE'):-!,
    appendBuffer(_buf,'TRUE').

AND(_buf,_con1,_con2) :-
	appendBuffer(_buf,'FALSE').

OR(_buf,_con1,_con2):-
	(_con1=='TRUE';
	_con2=='TRUE'),
	appendBuffer(_buf,'TRUE').

OR(_buf,_con1,_con2) :-
	appendBuffer(_buf,'FALSE').

EQUAL(_buf,_xx,_yy):-
	(pc_inttoatom(_x,_xx);pc_floattoatom(_x,_xx)),
	(pc_inttoatom(_y,_yy);pc_floattoatom(_y,_yy)),
	_x>=_y,
	_x=<_y,
	appendBuffer(_buf,'TRUE').

EQUAL(_buf,_xx,_yy):-
	_xx==_yy,!,
	appendBuffer(_buf,'TRUE').

EQUAL(_buf,_xx,_yy) :-
    appendBuffer(_buf,'FALSE').


GREATER(_buf,_xx,_yy):-
	(pc_inttoatom(_x,_xx);pc_floattoatom(_x,_xx)),
	(pc_inttoatom(_y,_yy);pc_floattoatom(_y,_yy)),
	_x>_y,!,
	appendBuffer(_buf,'TRUE').

GREATER(_buf,_xx,_yy):-
	_xx @> _yy,
	appendBuffer(_buf,'TRUE').


GREATER(_buf,_xx,_yy) :-
	appendBuffer(_buf,'FALSE').


LOWER(_buf,_xx,_yy):-
	(pc_inttoatom(_x,_xx);pc_floattoatom(_x,_xx)),
	(pc_inttoatom(_y,_yy);pc_floattoatom(_y,_yy)),
	_x<_y,!,
	appendBuffer(_buf,'TRUE').

LOWER(_buf,_xx,_yy):-
	_xx @< _yy,!,
	appendBuffer(_buf,'TRUE').

LOWER(_buf,_xx,_yy) :-
	appendBuffer(_buf,'FALSE').


STRINGENCODING(_buf,_s) :-
        quotedAtom(_s),  {* nothing to encode if already a ConceptBase "string" *}
	appendBuffer(_buf,_s),
	!.
STRINGENCODING(_buf,_s) :-
	atom2list(_s,_s1),
	multiAppend([['"'],_s1,['"']],_output1),
	atom2list(_output,_output1),
	appendBuffer(_buf,_output),
        !.

STRINGDECODING(_buf,_s) :-
	quotedAtom(_s), {* only done for quoted atoms *}
	atom2list(_s,_s1),
	delete_first_and_last(_s1,_output1),  
	atom2list(_output,_output1),
	appendBuffer(_buf,_output),
        !.
STRINGDECODING(_buf,_s) :- {* if it is not quoted, then just output it as is *}
	appendBuffer(_buf,_s).

QT(_b,_s):- STRINGENCODING(_b,_s).  {* just an alias! *}
UQ(_b,_s):- STRINGDECODING(_b,_s).  {* just an alias! *}


{* print an aplhanumeric transcription of _x; useful  if _x contains *}
{* special characters e.g. _x="abc*^s"                               *}
{* The special character are replaced by their ASCII Code plus 'C'   *}
{* Example: "Application**Modeling"                                  *}
{*     ---> C34_Application_C42__C42_Modeling_C34                    *}

ALPHANUM(_buf,_x) :-
   atom(_x),
   makeAlphanumeric(_x,_xa),
   appendBuffer(_buf,_xa).



{* From and To are returning the source resp. destination of a given object *}
{* Analogously, Label returns the object's label and Oid its identifier.    *}
{* Solves ticket #184.                                                      *}

From(_buf,_objname) :- 
  atom(_objname),
  select2id(_objname,_oid),   {* ticket #281 *}
  prove_literal(From(_oid,_from)),
  outObjectName(_from,_src),
  appendBuffer(_buf,_src),
  !.


To(_buf,_objname) :-
  atom(_objname),
  select2id(_objname,_oid),
  prove_literal(To(_oid,_from)),
  outObjectName(_from,_src),
  appendBuffer(_buf,_src),
  !.

Label(_buf,_objname) :-
  atom(_objname),
  select2id(_objname,_oid),
  prove_literal(Label(_oid,_x)),
  appendBuffer(_buf,_x),
  !.

Oid(_buf,_objname) :-
  atom(_objname),
  select2id(_objname,_oid),
  appendBuffer(_buf,_oid),
  !.




{ASKquery ruft eine Anfrage durch ihren Namen. Man bemerkt wenn ein Format fuer diese Anfrage existiert, wird das Ergebniss
gemaess dieses Format ausgegeben. Hier denke ich, der Aufruf ist nur fuer die genetische Anfragen sinnvoller...
_Objname ist der Anfragename und _Format ist der default Format wie FRAME, LABEL, etc.}


{* 3-Apr-2000/MJf: ASKquery is now fit for being embedded in a pattern of an   }
{* answer format. To do so, one has to remove the variable settings made by    }
{* AnswerTransform before calling ASKquery. The evaluation of ASKquery can     }
{* lead to another embedded evaluation of AnswerTransform which needs a fresh  }
{* set of variables. The old variables are restored after the query evaluation.}
{* The query evaluation is made secure to avoid infinite loops and calls with  }
{* NULL parameters inserted by AnswerTransform.                                }

ASKquery(_Output,_Objname,_Format):-
        SetUpdateMode(QUERY),
    	WriteTrace(veryhigh,AnswerTransformUtilities,['ASKquery: Calling Query ',_Objname]),
	remove_variables(_varlist),    {* remove all variables that were set in AnswerTransform *}
	pc_stringtoatom(_Objstring,_Objname),
	ObjNameStringToList(_Objstring,_sml_objnamelist),
	EliminateClassInList(_sml_objnamelist,_objnamelist),
        makeCacheKey(_objnamelist,_Format,_qkey), {* _qkey is used to index the cached facts *}
        secure_process_query(_qkey,ask(_objnamelist,_Format),_buf),
        getPointerFromBuffer(_p,_buf),
        appendBufferP(_Output,_p),
        remove_variables(_),           {* the variables set during the process_query have to be forgotten *}
	record_variables(_varlist),    {* set the removed variables again  *}
        RemoveUpdateMode(QUERY).

{* the format also determines the answer! *}
makeCacheKey(_objnamelist,_Format,_qkey) :-
  pc_atom_to_term(_qkey1,_objnamelist),
  pc_atom_to_term(_qkey2,_Format),
  pc_atomconcat(_qkey1,_qkey2,_qkey),
  !.



{* remove_variables just removes the variable settings (domain 'AnswerFormatVariable')  }
{* done within the current call context of AnswerTransform. Note that the   }
{* current state is memorized in _varlist.                                  }

remove_variables(_varlist) :-
  findall( pair(_var,_val), (pc_current_key(_var,'AnswerFormatVariable'),pc_recorded(_var,'AnswerFormatVariable',_val)), _varlist),
  !,
  pc_erase_all('AnswerFormatVariable').

remove_variables([]).

{* record_variables re-establishes the old state for variable setting }

record_variables([]) :- !.

record_variables( [pair(_var,_val)|_rest]) :-
  record_variable(pair(_var,_val)),
  record_variables(_rest).


record_variable(pair(_var,_val)) :-
  pc_record(_var,'AnswerFormatVariable',_val),  {* record the var/val pair *}
  !.




{*****************************************3-Apr-2000/MJf****}
{ secure_process_query(_key,_q,_a)                          }
{                                                           }
{ This is just a prefix for the process_query in order to   }
{ prevent unsafe callsdue to NULL parameters or recursive   }
{ calls. A recursive call inside an answer transformation   }
{ leads to infinite answer representations. This must be    }
{ prevented.                                                }
{ 18-Dec-2001: use pc_record/pc_recorded similar to ded_In in     }
{ Literals.pro.                                             }
{ The recorded facts 'askQuery' are also erased in          }
{ TellAndAsk.pro to be on the save side.                    }
{****************************************30-Sep-2004/MJf****}

{* Case 1: The query expression contains a NULL value for a parameter.      }
{* Then, the query is not evaluated and an empty answer string is returned. }

secure_process_query(_key,ask(_objnamelist,_Format),_buf) :-
  _objnamelist=[derive(_query,_paramSubstitutes)],
  contains_NullParameter(_paramSubstitutes),
  WriteTrace(low,AnswerTransformUtilities,['Query ',_objnamelist,' contains a NULL parameter']),
  createBuffer(_buf,mini),
  !.

{* Case 2: The query has already been called during the expansion of the    }
{* current answer format pattern. Then, the query is not evaluated again to }
{* avoid infinite loops. The answer is the string '~' (denoting infinite).  }

secure_process_query(_key,ask(_objnamelist,_Format),_buf) :-
  pc_recorded(_key,askQuery,pending),   {* a recursive call of the same query *}
  !,
  WriteTrace(low,AnswerTransformUtilities,['Query ',_objnamelist,' called recursively -- computation tree cut']),
  createBuffer(_buf,mini),
  appendBuffer(_buf,'~'),
  !.

{* Case 3: The query has been successfully evaluated before.      }
{* Take the result from cache!                                    }

secure_process_query(_key,ask(_objnamelist,_Format),_buf) :-
  pc_recorded(_key,askQuery,success(_buf)),
  WriteTrace(veryhigh,AnswerTransformUtilities,['Cache hit for query ',_objnamelist]),
  !.

{* Case 4: The query can be regarded as save. It is evaluated and the       }
{* answer is returned. The result is cached in in records askQuery.         }

secure_process_query(_key,ask(_objnamelist,_Format),_buf) :-
  pc_record(_key,askQuery,pending),       {* we call it for the first time *}
  createBuffer(_buf),  {* with default size *}
  !,
  process_query(ask(_objnamelist,_Format),_buf),
  pc_rerecord(_key,askQuery,success(_buf)),
  !.


contains_NullParameter([substitute(NULL,_var)|_]) :- !.

contains_NullParameter([_|_rest]) :-
  contains_NullParameter(_rest).



{* deleteAskQueryBuffers_success disposes those cached AskQuery buffers *}
{* that have been previously computed in the same ASK transaction. The  *}
{* procedure is called when and ASK transaction triggers a TELL, e.g.   *}
{* by computing the result of an arithmetic expression, or by           *}
{* triggering an active rule. Only the successfully completed buffers   *}
{* are cleared. We need to keep the 'pending' call(s) intact, because   *}
{* pending calls are still being evaluated. Their evaluation is guided  *}
{* by the call state (pending,success).                                 *}

deleteAskQueryBuffers_success :-
  findall( (_key,_buf), (pc_current_key(_key,'askQuery'),pc_recorded(_key,'askQuery',success(_buf))), _keybuflist),
  deleteAskQueryBuffers(_keybuflist),
  !.
deleteAskQueryBuffers_success. {* never fail *}


{* deleteAskQueryBuffers completely removes all AskQuery buffers. This   *}
{* is done whenever the cache of Literals.pro is emptied.                *}

deleteAskQueryBuffers :-
  findall( (_key,_buf), (pc_current_key(_key,'askQuery'),pc_recorded(_key,'askQuery',success(_buf))), _keybuflist),
  deleteAskQueryBuffers(_keybuflist),
  pc_erase_all('askQuery'),   {* pending facts are also erased *}
  !.
deleteAskQueryBuffers. {* never fail *}



deleteAskQueryBuffers([]).

deleteAskQueryBuffers([(_k,_b)|_t]) :-
    disposeBuffer(_b),
    !,
    pc_erase(_k,'askQuery'),
    deleteAskQueryBuffers(_t).



