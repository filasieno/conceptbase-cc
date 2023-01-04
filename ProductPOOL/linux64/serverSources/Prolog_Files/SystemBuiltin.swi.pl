/**
The ConceptBase.cc Copyright

Copyright 1987-2022 The ConceptBase Team. All rights reserved.

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


/*
*
* File:        SystemBuiltin.pro
* Creation:    1988, Manfred Jeusfeld et al.
* Last Change:  15-Jun-2010, Manfred Jeusfeld (UNITILB)
* ---------------------------------------------------------------------------
* 
* This file defines the implementation of the builtin queries and functions of ConceptBase.
**/



:- module('SystemBuiltin',[
'processBuiltin'/3
,'computeFunction'/3
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').





:- use_module('SelectExpressions.swi.pl').
:- use_module('PrologCompatibility.swi.pl').

:- use_module('GeneralUtilities.swi.pl').


:- use_module('Literals.swi.pl').
:- use_module('ErrorMessages.swi.pl').
:- use_module('ObjectTransformer.swi.pl').
:- use_module('PropositionsToFragment.swi.pl').

:- use_module('PropositionProcessor.swi.pl').
:- use_module('BIM2C.swi.pl').



:- use_module('FragmentToPropositions.swi.pl').
:- use_module('QO_utils.swi.pl').









:- use_module('ExternalCodeLoader.swi.pl').


:- use_module('TellAndAsk.swi.pl').


:- use_module('ScanFormatUtilities.swi.pl').
:- use_module('CBserverInterface.swi.pl').
:- use_module('ModelConfiguration.swi.pl').

:- use_module('ConfigurationUtilities.swi.pl').





:- use_module('cbserver.swi.pl').


:- use_module('MetaUtilities.swi.pl').

:- use_module('QueryProcessor.swi.pl').



:- use_module('AnswerTransformUtilities.swi.pl').





:- style_check(-singleton).





/**
*
* This module contains the code for the execution of builtin queries.
* It still uses many SWI-Prolog builtins like term_to_atom; they have to
* be replaced by their counterparts from PrologCompatibility.pro.
*
**/

processBuiltin(_qname,_result,_substlist) :-
  nonvar(_qname),
  do_processBuiltin(_qname,_result,_substlist).
  


/** ***************************************************************************** **/
/**                                                                               **/
/**    get_object(_x):                                                            **/
/**    gives the definition of _x as a frame                                      **/
/**                                                                               **/
/** get_object mit 4 Parametern um implizite Objektbeziehungen herzuleiten.       **/
/** Das Flag ded_get_object wird zuerst auf die Werte der Parameter gesetzt und   **/
/** nachher wieder auf den Standardwert FALSE. 7-6-95/CQ                          **/
/**                                                                               **/
/** ***************************************************************************** **/

do_processBuiltin(get_object,_result,_substlist) :-
	pc_member(substitute(_x,objname),_substlist),
	pc_member(substitute(_dedIn,dedIn),_substlist),
	pc_member(substitute(_dedIsa,dedIsa),_substlist),
	pc_member(substitute(_dedWith,dedWith),_substlist),
	eval(_x, replaceSelectExpression, _objID),
	name2id(_objID,_),
	pc_update(ded_get_object(f(_dedIn,_dedIsa,_dedWith))),
  	compose_storedObject(_objID, _result),
	pc_update(ded_get_object(f('FALSE','FALSE','FALSE'))),
  	!.

/** Normalfall von get_object: nur explizite Beziehungen beachten. **/
/** Flag ded_get_object wird vorher auf FALSE gesetzt, da compose_storedObject **/
/** oben auch fehlschlagen kann, und die Flags auf irgendwelche Werte gestellt **/
/** worden sind. 7-6-95/CQ **/
do_processBuiltin(get_object,_result,[substitute(_x,objname)]) :-
        /** name(_x,_a),write('objname: '),write(_x),nl,write('asciis : '),write(_a),nl,**/
	eval(_x, replaceSelectExpression, _objID),
	name2id(_objID,_),
	pc_update(ded_get_object(f('FALSE','FALSE','FALSE'))),
  	compose_storedObject(_objID, _result),
  	!.

do_processBuiltin(get_object,_result,[substitute(_x,objname)]) :-
	eval(_x, replaceSelectExpression, _objID),
	report_error('PFNFE',get_object,[_objID]),!,fail.



/** ***************************************************************************** **/
/**                                                                               **/
/**    get_object_star(_x):                                                       **/
/**    gives the definition of the objects that match the wildcard expression _x  **/
/**                                                                               **/
/** ***************************************************************************** **/

do_processBuiltin(get_object_star,_result,[substitute(_x,objname)]) :-
	findall(_composed,
		(
			star_name2id(_x,_objID),
			compose_storedObject(_objID, _composed)
		),
	        _result),
	!.

/** ***************************************************************************** **/
/**                                                                               **/
/**    exists(_x): gives 'yes' if _x exists                                       **/
/**                                                                               **/
/** ***************************************************************************** **/

do_processBuiltin(exists,yes,[substitute(_x,objname)]) :-
	eval(_x, replaceSelectExpression, _objid),
	name2id(_objid,_newobjid),
	retrieve_proposition('P'(_newobjid,_,_,_)),
	!.

do_processBuiltin(exists,no,[substitute(_x,objname)]).


/** ***************************************************************************** **/
/**                                                                               **/
/**    rename(_newname,_oldname):  renames an object                              **/
/**                                                                               **/
/** ***************************************************************************** **/


do_processBuiltin(rename,yes,_substlist):-
	pc_member(substitute(_a,newname),_substlist),
	pc_member(substitute(_b,oldname),_substlist),
	rename_object(_a,_b),
	!.


/** ***************************************************************************** **/
/**                                                                               **/
/**  changeAttributeValue(_attr,_newvalue):  sets destination of attr to newvalue **/
/**                                                                               **/
/** ***************************************************************************** **/

do_processBuiltin(changeAttributeValue,_res,_substlist) :-
    pc_member(substitute(_a,attribute),_substlist),
    pc_member(substitute(_o,newvalue),_substlist),
     eval(_a, replaceSelectExpression, _aid),
     eval(_o, replaceSelectExpression, _oid),
     changeAttributeValue(_aid,_oid),
     _res = yes,
     !.



/** ***************************************************************************** **/
/**                                                                               **/
/**    listModule(_mod):  lists the content of module _mod                        **/
/**                                                                               **/
/** ***************************************************************************** **/


do_processBuiltin(listModule,_result,[]) :-
   getModule(_mod),
   listModuleContent(_result,_mod),
   !.

do_processBuiltin(listModule,_result,[substitute(_modname,module)]) :-
   getModule(_oldmod),
   listModuleContent(_result,_modname),
   setModule(_oldmod),
   !.

/** in case of missing access rights or other errors **/
do_processBuiltin(listModule,'{* no *}',_) :-
   !.

do_processBuiltin(listModuleReloadable,_result,[]) :-
   getModule(_mod),
   listModuleContentReloadable(_result,_mod),
   !.

do_processBuiltin(listModuleReloadable,_result,[substitute(_modname,module)]) :-
   getModule(_oldmod),
   listModuleContentReloadable(_result,_modname),
   setModule(_oldmod),
   !.

/** in case of missing access rights or other errors **/
do_processBuiltin(listModuleReloadable,'{* no *}',_) :-
   !.


/** ***************************************************************************** **/
/**                                                                               **/
/**    purgeModule(_mod):  purge the content of module _mod                        **/
/**                                                                               **/
/** ***************************************************************************** **/


do_processBuiltin(purgeModule,_result,[]) :-
   getModule(_mod),
   purgeModuleContent(_result,_mod),
   !.

do_processBuiltin(purgeModule,_result,[substitute(_modname,module)]) :-
   getModule(_oldmod),
   purgeModuleContent(_result,_modname),
   setModule(_oldmod),
   !.

/** in case of missing access rights or other errors **/
do_processBuiltin(purgeModule,'no',_) :-
   !.


/** ********************************* **/
/** for user-defined builtin queries: **/
/** ********************************* **/

do_processBuiltin(_qname,_res,_substlist) :-
	pc_atomconcat('process_',_qname,_cp),
	_c =..[_cp,_res,_substlist],
	pc_has_a_definition(_c),
	call(_c).


/**-------------**/
/**  Functions  **/
/**-------------**/


/**************************************************************************/
/***  COUNT                                                             ***/
/***  counts the elements of a class (arg2)                             ***/
/**************************************************************************/


computeFunction('COUNT',_res,[_class,_classid]) :-
	nonvar(_class),
	_class =.. [_fun|_args],
	term_variables(_args,_vars),
	save_setof(_x,_vars^(prove_literal('In'(_x,_class))),_xs),
	length(_xs,_ilen),
	pc_inttoatom(_ilen,_len),
	create_if_builtin_object(_len,'Integer',_res),
	!.


/**************************************************************************/
/***  COUNT_Attribute                                                   ***/
/***  counts the attributes of an object of one specified attribute cat.***/
/**************************************************************************/

computeFunction('COUNT_Attribute',_res,[_attrcat,_propid,_oid,_propid]) :-
	ground(_attrcat),
	ground(_oid),
	save_setof(_l,[_x]^(prove_literal('Adot_label'(_attrcat,_oid,_x,_l))),_attrlabels),
	length(_attrlabels,_ilen),
	pc_inttoatom(_ilen,_len),
	create_if_builtin_object(_len,'Integer',_res),
        !.

/**************************************************************************/
/***  SUM                                                               ***/
/***  sums the instance of a class if they are numbers                  ***/
/**************************************************************************/

computeFunction('SUM',_res,[_class,_classid]) :-
	nonvar(_class),
	findall(_x,(prove_literal('In'(_xid,_class)),
				id2name(_xid,_xatom),
				term_to_atom(_x,_xatom)),
			_xs),
        allNumbers(_xs),
	sumlist(_xs,_sum),
	pc_floattoatom(_sum,_sumatom),
	create_if_builtin_object(_sumatom,'Real',_res),
	!.

/**************************************************************************/
/***  SUM_Attribute                                                     ***/
/***  sums the attribute value of one object and attribute category     ***/
/**************************************************************************/

computeFunction('SUM_Attribute',_res,[_attrcat,_,_class,_]) :-
	ground(_class),
	ground(_attrcat),
	findall(_x,(prove_literal('Adot'(_attrcat,_class,_xid)),
				id2name(_xid,_xatom),
				term_to_atom(_x,_xatom)),
			_xs),
        allNumbers(_xs),
	sumlist(_xs,_sum),
	pc_floattoatom(_sum,_sumatom),
	create_if_builtin_object(_sumatom,'Real',_res),
	!.

/**************************************************************************/
/***  AVG                                                               ***/
/***  computes average of the instances of a class if they are numbers  ***/
/**************************************************************************/

computeFunction('AVG',_res,[_class,_classid]) :-
	nonvar(_class),
	findall(_x,(prove_literal('In'(_xid,_class)),
				id2name(_xid,_xatom),
				term_to_atom(_x,_xatom)),
			_xs),
        allNumbers(_xs),
	sumlist(_xs,_sum),
	length(_xs,_ilen),
	_ilen > 0,
	_avg is _sum / _ilen,
	pc_floattoatom(_avg,_avgatom),
	create_if_builtin_object(_avgatom,'Real',_res),
	!.

/**************************************************************************/
/***  AVG_Attribute                                                     ***/
/***  computes the average of attr. value of an object and attr. categor***/
/**************************************************************************/

computeFunction('AVG_Attribute',_res,[_attrcat,_,_class,_]) :-
	ground(_class),
	ground(_attrcat),
	findall(_x,(prove_literal('Adot'(_attrcat,_class,_xid)),
				id2name(_xid,_xatom),
				term_to_atom(_x,_xatom)),
			_xs),
        allNumbers(_xs),
	sumlist(_xs,_sum),
	length(_xs,_ilen),
	_ilen > 0,
	_avg is _sum / _ilen,
	pc_floattoatom(_avg,_avgatom),
	create_if_builtin_object(_avgatom,'Real',_res),
	!.

/**************************************************************************/
/***  MAX                                                               ***/
/***  returns the instance of the class with the highest value          ***/
/**************************************************************************/

computeFunction('MAX',_res,[_class,_classid]) :-
	nonvar(_class),
	findall(_xid,prove_literal('In'(_xid,_class)),_xs),
	find_max(_xs,_res),
	!.

/**************************************************************************/
/***  MAX_Attribute                                                     ***/
/***  returns the maximum attr. value of an object and attr. category   ***/
/**************************************************************************/

computeFunction('MAX_Attribute',_res,[_attrcat,_,_class,_]) :-
	ground(_class),
	ground(_attrcat),
	findall(_xid,prove_literal('Adot'(_attrcat,_class,_xid)),_xs),
	find_max(_xs,_res),
	!.

/**************************************************************************/
/***  MIN                                                               ***/
/***  returns the instance of the class with the  lowest value          ***/
/**************************************************************************/

computeFunction('MIN',_res,[_class,_classid]) :-
	nonvar(_class),
	findall(_xid,prove_literal('In'(_xid,_class)),_xs),
	find_min(_xs,_res),
	!.

/**************************************************************************/
/***  MIN_Attribute                                                     ***/
/***  returns the minimum attr. value of an object and attr. category   ***/
/**************************************************************************/

computeFunction('MIN_Attribute',_res,[_attrcat,_,_class,_]) :-
	ground(_class),
	ground(_attrcat),
	findall(_xid,prove_literal('Adot'(_attrcat,_class,_xid)),_xs),
	find_min(_xs,_res),
	!.


/**************************************************************************/
/***  PLUS                                                              ***/
/***  computes r1 + r2                                                  ***/
/**************************************************************************/

computeFunction('PLUS',_res,[_r1expr,_,_r2expr,_]) :-
	evalFunctionArg(_r1expr,_r1id),  /*** r1,r2 can be query calls ! ***/
	evalFunctionArg(_r2expr,_r2id),
	ground(_r1id),
	ground(_r2id),
	id2name(_r1id,_r1atom),
	id2name(_r2id,_r2atom),
	term_to_atom(_r1,_r1atom),
	term_to_atom(_r2,_r2atom),
	number(_r1),number(_r2),
	_rres is _r1 + _r2,
	term_to_atom(_rres,_resatom),
	create_if_builtin_object(_resatom,'Real',_res),
	!.


/**************************************************************************/
/***  IPLUS (INTEGER PLUS)                                              ***/
/***  computes r1 + r2                                                  ***/
/**************************************************************************/

computeFunction('IPLUS',_res,[_r1expr,_,_r2expr,_]) :-
        evalFunctionArg(_r1expr,_r1id),  /*** r1,r2 can be query calls ! ***/
        evalFunctionArg(_r2expr,_r2id),
        ground(_r1id),
        ground(_r2id),
        id2name(_r1id,_r1atom),
        id2name(_r2id,_r2atom),
        term_to_atom(_r1,_r1atom),
        term_to_atom(_r2,_r2atom),
	number(_r1),number(_r2),
        _rres is _r1 + _r2,
        term_to_atom(_rres,_resatom),
        create_if_builtin_object(_resatom,'Integer',_res),
	!.




/**************************************************************************/
/***  MINUS                                                             ***/
/***  computes r1 - r2                                                  ***/
/**************************************************************************/

computeFunction('MINUS',_res,[_r1expr,_,_r2expr,_]) :-
	evalFunctionArg(_r1expr,_r1id),  /*** r1,r2 can be query calls ! ***/
	evalFunctionArg(_r2expr,_r2id),
	ground(_r1id),
	ground(_r2id),
	id2name(_r1id,_r1atom),
	id2name(_r2id,_r2atom),
	term_to_atom(_r1,_r1atom),
	term_to_atom(_r2,_r2atom),
	number(_r1),number(_r2),
	_rres is _r1 - _r2,
	term_to_atom(_rres,_resatom),
	create_if_builtin_object(_resatom,'Real',_res),
	!.


/**************************************************************************/
/***  IMINUS (INTEGER MINUS)                                            ***/
/***  computes r1 - r2                                                  ***/
/**************************************************************************/

computeFunction('IMINUS',_res,[_r1expr,_,_r2expr,_]) :-
        evalFunctionArg(_r1expr,_r1id),  /*** r1,r2 can be query calls ! ***/
        evalFunctionArg(_r2expr,_r2id),
        ground(_r1id),
        ground(_r2id),
        id2name(_r1id,_r1atom),
        id2name(_r2id,_r2atom),
        term_to_atom(_r1,_r1atom),
        term_to_atom(_r2,_r2atom),
	number(_r1),number(_r2),
        _rres is _r1 - _r2,
        term_to_atom(_rres,_resatom),
        create_if_builtin_object(_resatom,'Integer',_res),
	!.




/**************************************************************************/
/***  MULT                                                              ***/
/***  computes r1 * r2                                                  ***/
/**************************************************************************/

computeFunction('MULT',_res,[_r1expr,_,_r2expr,_]) :-
	evalFunctionArg(_r1expr,_r1id),  /*** r1,r2 can be query calls ! ***/
	evalFunctionArg(_r2expr,_r2id),
	ground(_r1id),
	ground(_r2id),
	id2name(_r1id,_r1atom),
	id2name(_r2id,_r2atom),
	term_to_atom(_r1,_r1atom),
	term_to_atom(_r2,_r2atom),
	number(_r1),number(_r2),
	_rres is _r1 * _r2,
	term_to_atom(_rres,_resatom),
	create_if_builtin_object(_resatom,'Real',_res),
	!.



/**************************************************************************/
/***  IMULT (INTEGER MULT)                                              ***/
/***  computes r1 * r2                                                  ***/
/**************************************************************************/

computeFunction('IMULT',_res,[_r1expr,_,_r2expr,_]) :-
        evalFunctionArg(_r1expr,_r1id),  /*** r1,r2 can be query calls ! ***/
        evalFunctionArg(_r2expr,_r2id),
        ground(_r1id),
        ground(_r2id),
        id2name(_r1id,_r1atom),
        id2name(_r2id,_r2atom),
        term_to_atom(_r1,_r1atom),
        term_to_atom(_r2,_r2atom),
	number(_r1),number(_r2),
        _rres is _r1 * _r2,
        term_to_atom(_rres,_resatom),
        create_if_builtin_object(_resatom,'Integer',_res),
	!.



/**************************************************************************/
/***  DIV                                                               ***/
/***  computes r1 / r2                                                  ***/
/**************************************************************************/

computeFunction('DIV',_res,[_r1expr,_,_r2expr,_]) :-
	evalFunctionArg(_r1expr,_r1id),  /*** r1,r2 can be query calls ! ***/
	evalFunctionArg(_r2expr,_r2id),
	ground(_r1id),
	ground(_r2id),
	id2name(_r1id,_r1atom),
	id2name(_r2id,_r2atom),
        term_to_atom(_r1,_r1atom),
        term_to_atom(_r2,_r2atom),
	number(_r1),number(_r2),
        saveDIV(_rres,_r1,_r2),
	term_to_atom(_rres,_resatom),
	create_if_builtin_object(_resatom,'Real',_res),
	!.


/**************************************************************************/
/***  IDIV (INTEGER DIVISION)                                           ***/
/***  computes truncate(r1 / r2)                                        ***/
/**************************************************************************/

computeFunction('IDIV',_res,[_r1expr,_,_r2expr,_]) :-
        evalFunctionArg(_r1expr,_r1id),  /*** r1,r2 can be query calls ! ***/
        evalFunctionArg(_r2expr,_r2id),
        ground(_r1id),
        ground(_r2id),
        id2name(_r1id,_r1atom),
        id2name(_r2id,_r2atom),
        term_to_atom(_r1,_r1atom),
        term_to_atom(_r2,_r2atom),
	number(_r1),number(_r2),
        saveIDIV(_rres,_r1,_r2),
        term_to_atom(_rres,_resatom),
        create_if_builtin_object(_resatom,'Integer',_res),
	!.


/**************************************************************************/
/***  ConcatenateStrings                                                ***/
/***  appends string s2 to the end of string s1                         ***/
/**************************************************************************/

computeFunction('ConcatenateStrings',_res,[_s1,_,_s2,_]) :-
        evalFunctionArg(_s1,_sid1),
        evalFunctionArg(_s2,_sid2),
	ground(_sid1),
	ground(_sid2),
	makeName(_sid1,_s1atom),
	makeName(_sid2,_s2atom),
        unquoteAtom(_s1atom,_ps1),
        unquoteAtom(_s2atom,_ps2),
	pc_atomconcat(['"',_ps1,_ps2,'"'],_satom),
	create_if_builtin_object(_satom,'String',_res),
	!.


computeFunction('ConcatenateStrings3',_res,[_s1,_,_s2,_,_s3,_]) :-
	ground(_s1),
	ground(_s2),
	ground(_s3),
	id2name(_s1,_s1atom),
	id2name(_s2,_s2atom),
	id2name(_s3,_s3atom),
        unquoteAtom(_s1atom,_ps1),
        unquoteAtom(_s2atom,_ps2),
        unquoteAtom(_s3atom,_ps3),
	pc_atomconcat(['"',_ps1,_ps2,_ps3,'"'],_satom),
	create_if_builtin_object(_satom,'String',_res),
	!.

computeFunction('ConcatenateStrings4',_res,[_s1,_,_s2,_,_s3,_,_s4,_]) :-
	ground(_s1),
	ground(_s2),
	ground(_s3),
	ground(_s4),
	id2name(_s1,_s1atom),
	id2name(_s2,_s2atom),
	id2name(_s3,_s3atom),
	id2name(_s4,_s4atom),
        unquoteAtom(_s1atom,_ps1),
        unquoteAtom(_s2atom,_ps2),
        unquoteAtom(_s3atom,_ps3),
        unquoteAtom(_s4atom,_ps4),
	pc_atomconcat(['"',_ps1,_ps2,_ps3,_ps4,'"'],_satom),
	create_if_builtin_object(_satom,'String',_res),
	!.

/**************************************************************************/
/***  StringToLabel                                                     ***/
/***  removes the quotes of the string and returns it as label (no oid) ***/
/**************************************************************************/
computeFunction('StringToLabel',_res,[_s,_]) :-
        evalFunctionArg(_s,_sid),
	ground(_sid),
	id2name(_sid,_satom),
        unquoteAtom(_satom,_res),
	!.

computeFunction(toLabel,_res,[_s,_]) :-
        evalFunctionArg(_s,_sid),
	ground(_sid),
	id2name(_sid,_satom),
        unquoteAtom(_satom,_uatom),
        makeAlphanumeric(_uatom,_alpha),
        create_as_individual(_alpha,_res),
	!.


/** this is doing the same as ConcatenateStrings **/
computeFunction(concat,_res,[_s1,_,_s2,_]) :-
        computeFunction('ConcatenateStrings',_res,[_s1,_,_s2,_]),
	!.


/** concatenate the labels of s1 and s2, quotes are removed from arguments **/
computeFunction(concatl,_res,[_s1,_,_s2,_]) :-
        evalToLabel(_s1,_l1),
        evalToLabel(_s2,_l2),
        unquoteAtom(_l1,_ps1),
        unquoteAtom(_l2,_ps2),
	pc_atomconcat(_ps1,_ps2,_alpha),
        toTelosName(_alpha,_telosname),
        create_as_individual(_telosname,_res),
	!.

computeFunction(concatl4,_res,[_s1,_,_s2,_,_s3,_,_s4,_]) :-
        evalToLabel(_s1,_l1),
        evalToLabel(_s2,_l2),
        evalToLabel(_s3,_l3),
        evalToLabel(_s4,_l4),
        unquoteAtom(_l1,_ps1),
        unquoteAtom(_l2,_ps2),
        unquoteAtom(_l3,_ps3),
        unquoteAtom(_l4,_ps4),
	pc_atomconcat([_ps1,_ps2,_ps3,_ps4],_alpha),
        toTelosName(_alpha,_telosname),
        create_as_individual(_telosname,_res),
	!.

computeFunction(concatl6,_res,[_s1,_,_s2,_,_s3,_,_s4,_,_s5,_,_s6,_]) :-
        evalToLabel(_s1,_l1),
        evalToLabel(_s2,_l2),
        evalToLabel(_s3,_l3),
        evalToLabel(_s4,_l4),
        evalToLabel(_s5,_l5),
        evalToLabel(_s6,_l6),
        unquoteAtom(_l1,_ps1),
        unquoteAtom(_l2,_ps2),
        unquoteAtom(_l3,_ps3),
        unquoteAtom(_l4,_ps4),
        unquoteAtom(_l5,_ps5),
        unquoteAtom(_l6,_ps6),
	pc_atomconcat([_ps1,_ps2,_ps3,_ps4,_ps5,_ps6],_alpha),
        toTelosName(_alpha,_telosname),
        create_as_individual(_telosname,_res),
	!.



/** Issue #39: Function "resultOf" to get query answers as a single value **/
/** resultOf(Q,x,ansrep) applies the query Q to argument x and converts to to a string according to answerformat ansrep **/
computeFunction(resultOf,_res,[_q,_,_x,_,_ansrepid,_]) :-
	ground(_q),
        ground(_x),
        ground(_ansrepid),
        id2name(_ansrepid,_ansrep),
        createBuffer(_ret,large), 
        process_query(ask([bulkquery([plainarg(_q),plainarg(_x)])],_ansrep),_ret),
        getStringFromBuffer(_answer,_ret),
        encodeLabel(_answer,_ansrepid,_satom),
	create_if_builtin_object(_satom,'HiddenLabel',_res),
/** id2name(_res,_out), write('resultOf: '),write(_out),nl, write('resultOf pointer: '),write(_res),nl, **/
	!.


/** ======== **/
/** toString **/
/** ======== **/

/** convert an object _x to a string **/

computeFunction(toString,_res,[_x,_C]) :-
        nonvar(_x), 
        makeName(_x,_label),
        quoteAtom(_label,_string),
        val2arg(_string,_res),
        !.


/** ====== **/
/** length **/
/** ====== **/

/** compute the length of an object label **/

computeFunction(length,_res,[_x,_C]) :-
        nonvar(_x), 
        makeName(_x,_label),
        unquoteAtom(_label,_ua),
        atom_length(_ua,_len),
        val2arg(_len,_res),
        !.


/** ====== **/
/** isLike **/
/** ====== **/

/** check whether a label matches a pattern **/

computeFunction(isLike,_result,[_label,_C1,_pattern,_C2]) :-
   nonvar(_label), 
   nonvar(_pattern), 
   makeName(_pattern,_p),
   makeName(_label,_l),
   unquoteAtom(_p,_pa),
   unquoteAtom(_l,_la),
   (wildcard_match(_pa,_la),_resa='TRUE',!;   /** wildcard_match is a builtin predicate of SWI-Prolog **/
    _resa= 'FALSE'),
   makeId(_resa,_result),
   !.



/** *********************************** **/
/** for user-defined builtin functions: **/
/** *********************************** **/

computeFunction(_fname,_res,_args) :-
	pc_atomconcat('compute_',_fname,_functor),
	_pred =.. [_functor,_res|_args],
	!,
	(pc_has_a_definition(_pred);  
	 (report_error('NOFUNCTIONBODY', 'SystemBuiltin',[formula(_pred)]),
	  !,
	  fail
	 )
	),
	!,  /** to prevent backtracking on the preceding OR-clause **/
	call(_pred),
        !.



/** ------------------------------------------------ **/




allNumbers(_s) :-
  is_allNumbers(_s),
  !.

allNumbers(_s) :-
  report_error('NOTALLNUMBERS', 'SystemBuiltin',[]),
  !,
  fail.




evalToLabel(_x,_n) :-
  is_id(_x),
  id2name(_x,_n),
  !.

evalToLabel(_x,_x) :-
  atom(_x),
  !.


evalToLabel(_x,_n) :-
  evalFunctionArg(_x,_y),
  makeName(_y,_n),
  !.



