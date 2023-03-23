/**
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
**/
/*
*
* File:         %M%
* Version:      %I%
* Creation:    25-Nov-1988, Hans Nissen (UPA)
* Last Change: %G%, Lutz Bauer (RWTH)
* Date released : %E%  (YY/MM/DD)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
* -----------------------------------------------------------------------------
*
*  This File includes all the predicates used to transform a SML Fragment
*  stored in a file into a list of characters.
*  It also includes the predicates to transform the internal representation
*  of a SML Fragment used by the object processor into the representation
*  used by the object editor.
*
*
*  09-Nov-1989 MSt : new predicate nread_SMLtext/2 corresponding to
*                    read_SMLtext/2 but not reading from files but from
*                    charlist (same with nreadEnd/3,nreadObjChars/4)
*                    these n* preds shall replace the old versions (later);
*                    then a new pred is needed for only reading a file into
*                    a charlist
*  19-Dec-1989 TW : predicate outTimeOption/3 now supports valid time.
*
*  05-Jan-1990 MSt : new pred. lineListToBIMstring/2
*                    error in outClassOption/3 corrected
*
*  25-Jan-1990 HWN : the translation of a string (BINProlog - string) into
*		     an atom is now also correct, if the string represents
*		     a real or an integer.
*
*  12-Mar-1990 HWN : A CML-string is no longer represented as a BIMPrologString,
*		     but as a list of characters. So the conversion to an atom
*		     has been changed.
*
*  13-Mar-1990 MSt : derive expressions are retransformed to source
*                    representation
*
* 9-Dec-1992/kvt: format of smlfragment changed cf. CBNEWS[],
*     predicates predefined/1 and outTimeOption/3 deleted
*/

:- module('ScanFormatUtilities',[
'build_frame'/2
,'listToAtomWithCommata'/2
,'listToCharListwithCommata'/2
,'multiAppend'/2
,'outFormula'/2
,'outFragmentObjectName'/2
,'outIdentifier'/2
,'outObjectName'/2
,'outTelosStatement'/2
,'outSelectIdent'/2
,'convertLit'/2
,'convertArgs'/3
,'keyCommentChars'/2
,'keyFrameListStart'/1
,'keyFrameListEnd'/1
,'keyFrameSep'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('GeneralUtilities.swi.pl').

:- use_module('PrologCompatibility.swi.pl').





:- use_module('ExternalCodeLoader.swi.pl').


:- use_module('SelectExpressions.swi.pl').
:- use_module('validProposition.swi.pl').

:- use_module('tokens_dcg.swi.pl').








:- use_module('MetaUtilities.swi.pl').
:- use_module('QO_preproc.swi.pl').
:- use_module('cbserver.swi.pl').





:- style_check(-singleton).






/******************************************************************************
 *****************************************************************************
 The following predicates define the way the keywords will be written
 in the editor.
 *****************************************************************************
 *****************************************************************************
*/


/** ticket #422: support the JSONIC frame format **/
keyWith(_,'{ ') :- getFlag(currentAnswerFormat,'JSONIC'),!.
keyWith(with([]),'') :- !.
keyWith(_,'with \n').

keyEnd('}') :- getFlag(currentAnswerFormat,'JSONIC'),!.
keyEnd('end ').


keyIn('  "type" : ') :- getFlag(currentAnswerFormat,'JSONIC'),!.
keyIn('in ').

keyIsa('  "super" : ') :- getFlag(currentAnswerFormat,'JSONIC'),!.
keyIsa('isA ').


keyInEnd('') :- getFlag(currentAnswerFormat,'JSONIC'),!.
keyInEnd(' ').

keyIsaEnd('') :- getFlag(currentAnswerFormat,'JSONIC'),!.
keyIsaEnd(' ').

keyCommentChars('/*','*/') :- getFlag(currentAnswerFormat,'JSONIC'),!.
keyCommentChars('{','}').

keyPropertySep(',') :- getFlag(currentAnswerFormat,'JSONIC'),!.
keyPropertySep(';').

keyFrameListStart('[\n') :- getFlag(currentAnswerFormat,'JSONIC'),!.
keyFrameListStart('').

keyFrameListEnd(']\n') :- getFlag(currentAnswerFormat,'JSONIC'),!.
keyFrameListEnd('').

keyFrameSep(',\n\n') :- getFlag(currentAnswerFormat,'JSONIC'),!.
keyFrameSep('\n\n').


/******************************************************************************
 *****************************************************************************
 The following predicates transform a SML-Fragment given by the Object Processor
 into a form used by the Object Editor.
 *****************************************************************************
 *****************************************************************************
*/




/* ****************************************************************************
  formatSMLObject formats a SML object presented as a SML fragment of the
  object processor to a text object in SML syntax. The text object is
  presented as a list of lines. Each single line is represented by a list of
  atoms ( or char lists resulting from occuring assertions ).

  ************************************************************************** */


build_frame('SMLfragment'(what(_x), _inOmega, _in, _isa, _with), _buf):-
	keyWith(_with,_withsymbol),
	buildObjectHeader(what(_x), _inOmega, _in, _isa,_with,_withsymbol, _buf),
/**	appendBuffer(_buf,'\n'), **/
	buildObjectBody(0,_with, _buf),
	keyEnd(_end),
	appendBuffer(_buf,_end),
	!.



/** for JSONIC: append _atom if more elements need to be printed **/
appendIfNeeded(_buf,[],_atom) :- !.

appendIfNeeded(_buf,[_list|_rest],_atom) :- 
	_list = [_x|_], 
	appendBuffer(_buf,_atom),
	!.
appendIfNeeded(_buf,[_list|_rest],_atom) :- 
	appendIfNeeded(_buf,_rest,_atom),
	!.





/* ****************************************************************************

  buildObjectHeader builds the header of the SML object

  ************************************************************************** */

buildObjectHeader(what(_x), in_omega(_classList1), in(_classList2), isa(_classList3), with(_attrList), _withsymbol, _buf):-
        getFlag(currentAnswerFormat,'JSONIC'),!,
	appendBuffer(_buf,_withsymbol),
	appendBuffer(_buf,'"id" : '),
        objIdBuild(what(_x), _buf),
        appendIfNeeded(_buf,[_classList1,_classList2,_classList3,_attrList],',\n'),
        append(_classList1, _classList2, _classList),
	inBuild(in(_classList), _buf),
        ( _classList=[],!;
          appendIfNeeded(_buf,[_classList3,_attrList],',\n')),
	isaBuild(isa(_classList3), _buf),
        ( _classList3=[],!;
          appendIfNeeded(_buf,[_attrList],',\n')),
        !.



buildObjectHeader(_what, _inOmega, _in, _isa,_with,_withsymbol, _buf):-
	omegaBuild(_inOmega, _buf),
	objIdBuild(_what, _buf),
	appendBuffer(_buf,' '),
	inBuild(_in, _buf),
	isaBuild(_isa, _buf),
	appendBuffer(_buf,_withsymbol),
	appendBuffer(_buf,' ').


omegaBuild(in_omega([]),_buf) :- !.

omegaBuild(in_omega(_classList), _buf):-
	outClassOption(_classList,'', _buf),
	appendBuffer(_buf,' '),
        !.

objIdBuild(what(_x), _buf) :-
	outIdentifier(_x, _xAtom), 
	appendBuffer(_buf,_xAtom).

inBuild(in([]), _buf) :- !.

inBuild(in(_classList), _buf):-
	keyIn(_in),
	outClassOption(_classList,_in, _buf),
	keyInEnd(_end),
	appendBuffer(_buf,_end).

isaBuild(isa([]), _buf) :- !.
isaBuild(isa(_classList), _buf):-
	keyIsa(_isa),
	outClassOption(_classList,_isa, _buf),
	keyIsaEnd(_end),
	appendBuffer(_buf,_end).


/* ****************************************************************************
  buildObjectBody builds the body of the current SML object. The body consists
  of a (possibly empty) set of attribute declaration blocks - processed by
  outAttrBlocks. In turn, each attribute declaration block consists of a
  (possibly empty) set of properties.

  ************************************************************************** */

buildObjectBody(_indentLevel, with(_attrList),_buf):-
	outAttrBlocks(_indentLevel,_attrList, _buf),
	!.

outAttrBlocks(_indentLevel,[], _buf).

outAttrBlocks(_indentLevel,[attrdecl(_catList, _propList)| _attrTail], _buf):-
	outIndentLabel(_indentLevel,_buf),
	outLabelList( _catList, _buf),
	( getFlag(currentAnswerFormat,'JSONIC'),!;
	  appendBuffer(_buf,'\n')),
	getLabelPrefix(_catList,_prefix),
	outPropBlock(_prefix,_indentLevel,_propList, _buf),
	( getFlag(currentAnswerFormat,'JSONIC'),_attrTail\=[],appendBuffer(_buf,',\n'),!;
	  appendBuffer(_buf,'\n')),
	outAttrBlocks(_indentLevel,_attrTail, _buf).



/** for JSONIC: get a prefix to be added to a property label, e.g. single__name **/
/** getLabelPrefix([attribute],'') :- !.  surpress attribute as prefix also in JSONIC **/

getLabelPrefix([_categorylabel],_prefix) :-
        getFlag(currentAnswerFormat,'JSONIC'),!,
	pc_atomconcat(_categorylabel,'/',_prefix),
        !.

getLabelPrefix(_catList,_prefix) :-
	_catList = [_c1,_c2|_rest],
        getFlag(currentAnswerFormat,'JSONIC'),!,
        concatCatList(_catList,_catatom),
	pc_atomconcat(_catatom,'/',_prefix),
        !.

getLabelPrefix(_catList,'').  /** no prefix for FRAME format */

concatCatList([],'') :- !.
concatCatList([_cat|_rest],_catatom) :-
   concatCatList(_rest,_postfix),
   pc_atomconcat([_cat,'_',_postfix],_catatom).



getOutputLabel(_prefix,_label,_olabel) :-
   getFlag(currentAnswerFormat,'JSONIC'),!,
   pc_atomconcat(['"',_prefix,_label,'"'],_olabel).
getOutputLabel(_prefix,_label,_label).


/* ******************************************************************************
  outLabelList prints the category labels of a property block; it is assumed,
  that only atoms are allowed as category identifiers

  **************************************************************************** */

outLabelList(_labels, _buf) :-
   getFlag(currentAnswerFormat,'JSONIC'),!.

outLabelList([_singleLabel], _buf) :-
    !,
    appendBuffer(_buf,_singleLabel).

outLabelList([_labelHeader | _labelTail], _buf):-
    appendBuffer(_buf,_labelHeader),
    appendBuffer(_buf,','),
	outLabelList(_labelTail, _buf).

/* *****************************************************************************
  labels of properties are allowed to be SML identifiers, i.e. there is no
  restriction.

  **************************************************************************** */
outPropBlock(_prefix,_indentLevel,[property(_label, 'SMLfragment'(what(_x),_inOmega,_in,_isa,_with))],_buf):-
    !,
	outIndent(_indentLevel,_buf),
	getOutputLabel(_prefix,_label,_olabel),
	appendBuffer(_buf,_olabel),
	appendBuffer(_buf,' : '),
	keyWith(_with,_withsymbol),
	buildObjectHeader(what(_x), _inOmega, _in, _isa, _with ,_withsymbol, _buf),
	_indentLevel1 is _indentLevel + 1,
	buildObjectBody(_indentLevel1,_with, _buf),
	keyEnd(_end),
	outIndent(_indentLevel,_buf),
	appendBuffer(_buf,_end),
	appendBuffer(_buf,'\n'),
	!.

outPropBlock(_prefix,_indentLevel,[property(_label, _id)],_buf):-
	outIndent(_indentLevel,_buf),
	getOutputLabel(_prefix,_label,_olabel),
	appendBuffer(_buf,_olabel),
	appendBuffer(_buf,' : '),
	outIdentifier(_id, _idAtom),
	appendBuffer(_buf,_idAtom).

outPropBlock(_prefix,_indentLevel,[property(_label, 'SMLfragment'(what(_x),_inOmega,_in,_isa,_with)) | _propTail],_buf) :-
	!,
	outIndent(_indentLevel,_buf),
	getOutputLabel(_prefix,_label,_olabel),
	appendBuffer(_buf,_olabel),
	appendBuffer(_buf,' : '),
	keyWith(_with,_withsymbol),
	buildObjectHeader(what(_x), _inOmega, _in, _isa, _with, _withsymbol, _buf),
	_indentLevel1 is _indentLevel + 1,
	buildObjectBody(_indentLevel1,_with, _buf),
	keyEnd(_end),
	outIndent(_indentLevel,_buf),
	appendBuffer(_buf,_end),
	keyPropertySep(_sep),
	appendBuffer(_buf,_sep),
	appendBuffer(_buf,'\n'),
	outPropBlock(_prefix,_indentLevel,_propTail, _buf).

outPropBlock(_prefix,_indentLevel,[property(_label, _id) | _propTail],_buf) :-
	outIndent(_indentLevel,_buf),
	getOutputLabel(_prefix,_label,_olabel),
	appendBuffer(_buf,_olabel),
	appendBuffer(_buf,' : '),
	outIdentifier(_id, _idAtom),
	appendBuffer(_buf,_idAtom),
	keyPropertySep(_sep),
	appendBuffer(_buf,_sep),
	appendBuffer(_buf,'\n'),
	outPropBlock(_prefix,_indentLevel,_propTail, _buf).


outIndent(0,_buf) :-
    !,
    appendBuffer(_buf,'    ').

outIndent(_i,_buf) :-
    _i1 is _i - 1,
    appendBuffer(_buf,'    '),
    outIndent(_i1,_buf).

/** indentation for JSON name/value pairs **/
outIndentLabel(0,_buf) :-
    getFlag(currentAnswerFormat,'JSONIC'),
    !.

outIndentLabel(0,_buf) :- appendBuffer(_buf,'  '),!.

outIndentLabel(_i,_buf) :-
    _i1 is _i - 1,
    appendBuffer(_buf,'   '),
    outIndentLabel(_i1,_buf).


/* ****************************************************************************
  outClassOption is called to format the omega-, in-, and isa-class lists. For
  each class list a certain keyword is prefixed. The class list - to each
  class identifier a temporal specification could be attached - is formatted
  by outClassList.

  ************************************************************************** */

outClassOption([], _, _buf) :- !.


outClassOption(_classList,_prefix,_buf) :-
    getFlag(currentAnswerFormat,'JSONIC'),!,
    appendBuffer(_buf,_prefix),
    appendBuffer(_buf,'['),
    outClassList(_classList,_buf),
    appendBuffer(_buf,']').

outClassOption(_classList,_prefix,_buf) :-
    appendBuffer(_buf,_prefix),
    outClassList(_classList,_buf).

outClassList([class(_c)], _buf):-
    outIdentifier(_c,_cAtom),
    appendBuffer(_buf,_cAtom).

outClassList([class(_c) |_classTail],_buf):-
	outIdentifier(_c, _cAtom),
    appendBuffer(_buf,_cAtom),
    appendBuffer(_buf,','),
	outClassList(_classTail, _buf).


/*************************************************************************/
/*  outObjectName(_id,_oname)
   _id   atom
   _oname   free atom
   outObjectName transforms an object identifier (_id) into the Telos
   name of this object.
*************************************************************************/


outObjectName(_v,_vname) :-
  var(_v),!,
  pc_atom_to_term(_vname,_v).

outObjectName(_v,_v2) :-
	system_generated(_v),
	!,
	pc_atomconcat(['"',_v,'"'],_v2).

outObjectName(derive(_q,_slist), _outderiveexp) :-
    !,
    deriveExprToAtom(derive(_q,_slist),_outderiveexp),
    !.

outObjectName(_id,_oname) :-
  is_id(_id),
  eval(_id,insertSelectExpression,_sexpr),
  outIdentifier(_sexpr,_oname),
  !.

/** ticket #158 **/
outObjectName(_lit,_oname) :-
  isQlit(_lit),
  _lit =..[_id|[_|_args]],
  is_id(_id),
  outObjectName(_id,_idname),
  'QueryArgExp'(_id,_qargexps),  /** retrieves the query arg expressions of query _id **/
  convertArgs(_qargexps,_args,_argsname),
  pc_atomconcat(_idname,_argsname,_oname),
  !.

outObjectName(_id,_id) :-
  atom(_id).


outObjectName(_list,_listname) :-
 is_list(_list),
 convertObjectNameList(_list,_listname1),
 pc_atomconcat(['[',_listname1,']'],_listname),
 !.

convertObjectNameList([],'') :- !.

convertObjectNameList([_a],_aname) :-
  outObjectName(_a,_aname),
  !.

convertObjectNameList([_a|_rest],_lname) :-
  outObjectName(_a,_aname),
  convertRestObjectNameList(_rest,_rname),
  pc_atomconcat(_aname,_rname,_lname),
  !.

convertObjectNameList(_x,_x).

convertRestObjectNameList([],'').

convertRestObjectNameList([_a|_rest],_lname) :-
  outObjectName(_a,_aname),
  convertRestObjectNameList(_rest,_rname),
  pc_atomconcat([_aname,',',_rname],_lname),
  !.



/* outTelosStatement attempts to create a more readable external representation */
/* of instantiations and specializations using the predicate clauses */

outTelosStatement(_id,_telosstmnt) :-
  is_id(_id),
  eval(_id,insertSelectExpression,_sexpr),
  sexprToPredExpr(_sexpr,_telosstmnt),
  !.

outTelosStatement(_id,_telosstmnt) :-
  outObjectName(_id,_objname),
  pc_atomconcat(['Object ',_objname],_telosstmnt),
  !.

sexprToPredExpr(select(_x,'->',_c),_telosstmnt) :-
  outObjectName(_x,_xname),
  outObjectName(_c,_cname),
  pc_atomconcat(['Statement (',_xname,' in ', _cname,')'],_telosstmnt),
  !.

sexprToPredExpr(select(_x,'=>',_c),_telosstmnt) :-
  outObjectName(_x,_xname),
  outObjectName(_c,_cname),
  pc_atomconcat(['Statement (',_xname,' isA ', _cname,')'],_telosstmnt),
  !.







/* outFragmentObjectName, wie outObjectName, */
/* ausser dass select-Expressions als Term stehen bleiben */
/* wie es auch in Fragmenten sein muss. */



outFragmentObjectName(_v,_vname) :-
  var(_v),!,
  pc_atom_to_term(_vname,_v).

outFragmentObjectName(_v,_v2) :-
	system_generated(_v),
	!,
	pc_atomconcat(['"',_v,'"'],_v2).


outFragmentObjectName(_id,_sexpr) :-
  id2name(_id,_),
  eval(_id,insertSelectExpression,_sexpr),
  !.

outFragmentObjectName(_id,_id) :-
  atom(_id).







/*************************************************************************/
/*  outFormula(_f,_fname)
   _f   term
   _oname   free atom
   outFormula transforms a formula (evaform, see BDMEvaluation.pro) into
   a readable external form (close to assertions)
*************************************************************************/


outFormula(_action,_oname) :-
  _action =.. [_a,_lit],
  pc_member(_a,['Tell','Untell','Retell']),
  convertLit(_lit,_lname),
  pc_atomconcat([_a,' ',_lname],_oname),
  !.

outFormula(_f,_oname) :-
  convertAssertion(0,_f,_frep),
  pc_atomconcat(['$',_frep,'$'],_oname),
  !.


/** 27-Sep-2006/M.Jeusfeld: use _level to make sure that different variables get different **/
/** names. For example, in $ forall x P(x) ==> exists y Q(x,y) $ the variable list after   **/
/** the first forall has level 0 and the variables list in the nested formula 'exists ...' **/
/** has level 1. This helps in creating readable variable names in a consistent manner.    **/
/** Note that outFormula has the only purpose to create readable formulas out of           **/
/** ConceptBase internal format for integrity constraints and rules (BDM format).          **/

convertAssertion(_level,forall(_litlist,'FALSE'),_frep) :-
  !,
  assignSymbolicVars(_level,_litlist,_symvars),
  makeVarlist(_symvars,_vars),
  convertLitList(_litlist,_s1),
  pc_atomconcat(['not exists ',_vars,' ',_s1],_frep).

convertAssertion(_level,forall(_litlist,_f),_frep) :-
  assignSymbolicVars(_level,_litlist,_symvars),
  makeVarlist(_symvars,_vars),
  convertLitList(_litlist,_s1),
  _level1 is _level + 1,
  convertAssertion(_level1,_f,_s2),
  pc_atomconcat(['forall ',_vars,' ',_s1,' ==> ',_s2],_frep).


convertAssertion(_level,exists(_litlist,'TRUE'),_frep) :-
  !,
  assignSymbolicVars(_level,_litlist,_symvars),
  makeVarlist(_symvars,_vars),
  convertLitList(_litlist,_s1),
  pc_atomconcat(['exists ',_vars,' ',_s1],_frep).


convertAssertion(_level,exists(_litlist,_f),_frep) :-
  assignSymbolicVars(_level,_litlist,_symvars),
  makeVarlist(_symvars,_vars),
  convertLitList(_litlist,_s1),
  _level1 is _level + 1,
  convertAssertion(_level1,_f,_s2),
  pc_atomconcat(['exists ',_vars,' ',_s1,' and ',_s2],_frep).

convertAssertion(_level,implies(_litlist,_f),_frep) :-
  convertLitList(_litlist,_s1),
  convertAssertion(_level,_f,_s2),
  pc_atomconcat(['(',_s1,' ==> ',_s2,')'],_frep).

convertAssertion(_level,and(_f1,_f2),_frep) :-
  convertAssertion(_level,_f1,_s1),
  convertAssertion(_level,_f2,_s2),
  pc_atomconcat(['(',_s1,' and ',_s2,')'],_frep).

convertAssertion(_level,or(_f1,_f2),_frep) :-
  convertAssertion(_level,_f1,_s1),
  convertAssertion(_level,_f2,_s2),
  pc_atomconcat(['(',_s1,' or ',_s2,')'],_frep).

convertAssertion(_level,not(_lit),_frep) :-
  convertLit(_lit,_s1),
  pc_atomconcat(['not ',_s1],_frep).


convertAssertion(_level,_litlist,_frep) :-
  convertLitList(_litlist,_frep),
  !.


/** some arguments of report_error of ECA messages have this type **/
convertAssertion(_level,_op,_s) :-
  _op =..[_op,_lit],
  pc_member(_op,['Tell','Untell','Retell','Ask']),
  convertLit(_lit,_s1),
  pc_atomconcat([_op,'(',_s1,')'],_s),
  !.


/**** otherwise:*/
convertAssertion(_level,_f,_s) :-
  convertLit(_f,_s).


convertLitList([],'') :- !.

convertLitList([_l],_s) :-
  convertLit(_l,_s).

convertLitList([_l|_rest],_s) :-
  convertLit(_l,_s1),
  convertLitList(_rest,_s2),
  pc_atomconcat([_s1,' and ',_s2],_s).


convertLit('Adot'(_cc,_x,_y),_s) :-
  outObjectName(_x,_xname),
  outObjectName(_y,_yname),
  id2name(_cc,_m),
  pc_atomconcat(['(',_xname,' ',_m,' ',_yname,')'],_s),
  !.

convertLit('Aidot'(_cc,_x,_id),_s) :-
  outObjectName(_x,_xname),
  outObjectName(_id,_idname),
  id2name(_cc,_m),
  pc_atomconcat(['Ai(',_xname,',',_m,',',_idname,')'],_s),
  !.

/** infix version of the AL literal  **/
/** we require _l to be an atom here **/
convertLit('Adot_label'(_cc,_x,_y,_l),_s) :-
  outObjectName(_x,_xname),
  outObjectName(_y,_yname),
  id2name(_cc,_m),
  pc_atomconcat(['(',_xname,' ',_m,'/',_l,' ',_yname,')'],_s),
  !.

convertLit('A'(_x,_m,_y),_s) :-
  outObjectName(_x,_xname),
  outObjectName(_y,_yname),
  pc_atomconcat(['(',_xname,' ',_m,' ',_yname,')'],_s),
  !.

convertLit('A_label'(_x,_m,_y,_l),_s) :-
  outObjectName(_x,_xname),
  outObjectName(_y,_yname),
  pc_atomconcat(['(',_xname,' ',_m,'/',_l,' ',_yname,')'],_s),
  !.

convertLit('Isa_e'(_c,_d),_s) :-
  outObjectName(_c,_cname),
  outObjectName(_d,_dname),
  pc_atomconcat(['Isa_e(',_cname,',',_dname,')'],_s),
  !.

convertLit('In_e'(_x,_c),_s) :-
  outObjectName(_x,_xname),
  outObjectName(_c,_cname),
  pc_atomconcat(['In_e(',_xname,',',_cname,')'],_s),
  !.

convertLit('In_s'(_x,_c),_s) :-
  outObjectName(_x,_xname),
  outObjectName(_c,_cname),
  pc_atomconcat(['In_s(',_xname,',',_cname,')'],_s),
  !.



convertLit(_lit,_s) :-
  _lit =.. [_lname,_x,_y],
  infixName(_lname,_iname),
  outObjectName(_x,_xname),
  outObjectName(_y,_yname),
  pc_atomconcat(['(',_xname,' ',_iname,' ',_yname,')'],_s),
  !.

convertLit('From'(_x,_y),_s) :-
  outObjectName(_x,_xname),
  outObjectName(_y,_yname),
  pc_atomconcat(['From(',_xname,',',_yname,')'],_s),
  !.

convertLit('To'(_x,_y),_s) :-
  outObjectName(_x,_xname),
  outObjectName(_y,_yname),
  pc_atomconcat(['To(',_xname,',',_yname,')'],_s),
  !.

convertLit('Label'(_id,_l),_s) :-
  outObjectName(_id,_idname),
  pc_atomconcat(['Label(',_idname,',',_l,')'],_s),
  !.


convertLit('P'(_id,_x,_l,_y),_s) :-
  outObjectName(_id,_idname),
  outObjectName(_x,_xname),
  outObjectName(_y,_yname),
  pc_atomconcat(['P(',_idname,',',_xname,',',_l,',',_yname,')'],_s),
  !.

convertLit('Pa'(_id,_x,_l,_y),_s) :-
  outObjectName(_id,_idname),
  outObjectName(_x,_xname),
  outObjectName(_y,_yname),
  pc_atomconcat(['Pa(',_idname,',',_xname,',',_l,',',_yname,')'],_s),
  !.


/** for query calls: **/
convertLit(_lit,_s) :-
  _lit =..[_id|[_x|_args]],
  is_id(_id),
  outObjectName(_id,_idname),
  outObjectName(_x,_xname),
  'QueryArgExp'(_id,_qargexps),  /** retrieves the query arg expressions of query _id **/
  convertArgs(_qargexps,_args,_argsname),
  pc_atomconcat(['(',_xname,' in ',_idname,_argsname,')'],_s),
  !.

/** for calls of builtin functions: **/
convertLit(_lit,_s) :-
  _lit =..[_function|[_x|_args]],
  pc_atomconcat('compute_',_idname,_function),
  name2id(_idname,_id),
  outObjectName(_x,_xname),
  'QueryArgExp'(_id,_qargexps),  /** retrieves the query arg expressions of query _id **/
  convertArgs(_qargexps,_args,_argsname),
  pc_atomconcat(['(',_xname,' = ',_idname,_argsname,')'],_s),
  !.


/**** otherwise:*/
convertLit(_lit,_s) :-
  pc_atom_to_term(_s,_lit).


/** makeVarlist creates for a list of atoms a comma-separated list **/
/** encoded as a single atom.                                      **/
/** For example, [x,y,z] is returned as 'x,y,z'.                   **/

makeVarlist([],'') :- !.
makeVarlist([_v],'_') :- var(_v),!.
makeVarlist([_x],_x) :- !.
makeVarlist([_x|_rest],_vars) :-
  makeVarlist(_rest,_vars1),
  pc_atomconcat([_x,',',_vars1],_vars).


/** assignSymbolicVars replaces all Prolog variables in _litlist by **/
/** symbolic variable names. The parameter _symvars contains all    **/
/** generated symbol variable names.                                **/

assignSymbolicVars(_level,_litlist,_symvars) :-
  do_assignSymbolicVars(_level,1,_litlist,[],_symvars).

do_assignSymbolicVars(_level,_counter,[],_sofar,_sofar) :- !.

do_assignSymbolicVars(_level,_counter,[_lit|_rest],_sofar,_sofar1) :-
  extractLitVars(_level,_counter,_lit,_newsymbolicvars),
  append(_sofar,_newsymbolicvars,_sofar2),
  length(_newsymbolicvars,_len),
  _newcounter is _counter+_len,
  do_assignSymbolicVars(_level,_newcounter,_rest,_sofar2,_sofar1).

extractLitVars(_level,_counter,_lit,_newsymbolicvars) :-
  _lit =.. [_fun|_args],
  do_extractLitVars(_level,_counter,_args,_newsymbolicvars),
  !.

do_extractLitVars(_level,_counter,[],[]) :- !.

do_extractLitVars(_level,_counter,[_x|_rest],[_xname|_restvarnames]) :-
  var(_x),!,
  fetchNewVarName(_level,_counter,_xname),
  _newcounter is _counter + 1,
  _x = _xname,
  do_extractLitVars(_level,_newcounter,_rest,_restvarnames).

do_extractLitVars(_level,_counter,[_x|_rest],_restvarnames) :-
  do_extractLitVars(_level,_counter,_rest,_restvarnames).

/** use readable variable name prefixes for the some frequent combinations  **/
fetchNewVarName(0,1,'x') :- !.
fetchNewVarName(1,1,'y') :- !.
fetchNewVarName(2,1,'z') :- !.
fetchNewVarName(0,2,'u') :- !.
fetchNewVarName(1,2,'v') :- !.
fetchNewVarName(2,2,'w') :- !.
fetchNewVarName(2,3,'k') :- !.
fetchNewVarName(3,1,'s') :- !.
fetchNewVarName(4,1,'t') :- !.

/** afterwards all variables get names starting with x followed by two or more digits like x32 **/
fetchNewVarName(_level,_counter,_varname) :-
  pc_inttoatom(_level,_lv),
  pc_inttoatom(_counter,_nr),
  pc_atomconcat(['x',_lv,_nr],_varname),
  !.





/** ************************************************************************************ **/
/** convertArgs(_queryArgExps,_args,_s)                          21-Apr-2005/M.Jeusfeld  **/
/**    _queryArgExps: _list (i)                                                          **/
/**    _args: list (i)                                                                   **/
/**    _s: free: atom (o)                                                                **/
/**                                                                                      **/
/** Convert an argument list of a query call to its external format like x/param,param:D **/
/** The parameter _queryArgExps has the form ['this',_qaexp1,_qaexp2,...] where 'this'   **/
/** is the placeholder for the answer object, and _qaexp1 etc. are so-called query arg   **/
/** expressions. They define the parameters, computed attributes, and retrieved          **/
/** attributes of a generic query class.                                                 **/
/** Possible values:                                                                     **/
/**    r(_lab): the attribute with label _lab is regarded as a retrieved attribute       **/
/**             ==> two arguments are reserved for it in _args but there is              **/
/**                 no parameter to be inserted                                          **/
/**    p(_lab,_d): there is a parameter called _lab with value class _c                  **/
/**             ==> two arguments _x,_c are reserved in _args. If _c=_d, then            **/
/**                 we represent this as a parameter substitution _x/_lab in _s;         **/
/**                 otherwise the parameter is specialized _lab:_c                       **/
/**    cp(_lab,_d): like p(_lab) but _lab is additionally a computed attribute           **/
/**    rp(_lab,_d): _lab is a parameter but also a retrieved attribute                   **/
/**             ==> three arguments _,_x,_c are reserved for this case in _args,         **/
/**                 otherwise same treatment as p(_lab,_d)                               **/
/**    c(_lab): _lab is a computed attribute                                             **/
/**             ==> only one argument is reserved in _args; no parameter to be inserted  **/
/**                 into _s                                                              **/
/**                                                                                      **/
/** Currently, only generic query classes are supported. Arguments must be object ids.   **/
/** Complex query calls as arguments are not yet supported. Moreover, query calls that   **/
/** are created from View definitions (inherited attribute,...) are not supported.       **/
/** If a case is not supported, convertLit will use its 'otherwise' case to display the  **/
/** query call.                                                                          **/
/** ************************************************************************************ **/

convertArgs(_,[],'') :- !.  /** query call has no arguments at all **/

convertArgs([_this|_restqargexps],_args,_s) :-
  doConvertArgs(_restqargexps,_args,'',_s1),
  pc_atomconcat(['[',_s1,']'],_s).


doConvertArgs([],[],_sofar,_sofar) :- !.  /** converted all arguments; nothing left over **/


doConvertArgs([_qargdef|_restqargexps],[_x,_c|_restargs],_sofar,_s) :-
  _qargdef = r(_lab),
  !,
  doConvertArgs(_restqargexps,_restargs,_sofar,_s).

doConvertArgs([_qargdef|_restqargexps],[_x|_restargs],_sofar,_s) :-
  _qargdef = c(_lab),
  !,
  doConvertArgs(_restqargexps,_restargs,_sofar,_s).


doConvertArgs([_qargdef|_restqargexps],[_xx,_cc|_restargs],_sofar,_s) :-
  makeId(_xx,_x),
  makeId(_cc,_c),
  (_qargdef = p(_lab,_c);
   _qargdef = cp(_lab,_c)),  /** must be a substitute **/
  !,
  outObjectName(_x,_xname),
  concatParts(_sofar,_xname,'/',_lab,_sofar1),
  doConvertArgs(_restqargexps,_restargs,_sofar1,_s).

doConvertArgs([_qargdef|_restqargexps],[_xx,_cc|_restargs],_sofar,_s) :-
  makeId(_xx,_x),
  makeId(_cc,_c),
  (_qargdef = p(_lab,_d);
   _qargdef = cp(_lab,_d)),
  _d \== _c,  /** must be a specialize **/
  !,
  outObjectName(_c,_cname),
  concatParts(_sofar,_lab,':',_cname,_sofar1),
  doConvertArgs(_restqargexps,_restargs,_sofar1,_s).

doConvertArgs([_qargdef|_restqargexps],[_,_xx,_cc|_restargs],_sofar,_s) :-
  makeId(_xx,_x),
  makeId(_cc,_c),
  _qargdef = rp(_lab,_c),
  !,
  outObjectName(_x,_xname),
  concatParts(_sofar,_xname,'/',_lab,_sofar1),
  doConvertArgs(_restqargexps,_restargs,_sofar1,_s).

doConvertArgs([_qargdef|_restqargexps],[_,_xx,_cc|_restargs],_sofar,_s) :-
  makeId(_xx,_x),
  makeId(_cc,_c),
  _qargdef = rp(_lab,_d),
  _d \== _c,  /** must be a specialize **/
  !,
  outObjectName(_c,_cname),
  concatParts(_sofar,_lab,':',_cname,_sofar1),
  doConvertArgs(_restqargexps,_restargs,_sofar1,_s).


concatParts('',_a,_o,_b,_s) :-
  pc_atomconcat([_a,_o,_b],_s),
  !.

concatParts(_sofar,_a,_o,_b,_s) :-
  pc_atomconcat([_sofar,',',_a,_o,_b],_s).








infixName('In','in').
infixName('Isa','isa').
infixName('LE','<=').
infixName('GE','>=').
infixName('EQ','=').
infixName('UNIFIES','=').
infixName('IDENTICAL','==').
infixName('NE','<>').
infixName('LT','<').
infixName('GT','>').



/*************************************************************************/
/*  outIdentifier(_smlName,_editorName)
   _smlName   ground atom list
   _editorName   free atom
   outIdentifier transforms the form of the identifier used in the
   SMLfragment to the form the editor uses the identifier .
   For example: the identifier select(select(ident1,!,ident2),^,ident3)
                becomes  ident1!ident2^ident3
*************************************************************************/

outIdentifier(_x,_xAtom) :-
	(_x = select( _inSelect, _selectSymbol, _ident);
         _x = derive(_q,_slist)),
        getFlag(currentAnswerFormat,'JSONIC'),!,
        setFlag(currentAnswerFormat,'FRAME'),
        do_outIdentifier(_x, _xAtom1),
	pc_atomconcat(['"',_xAtom1,'"'],_xAtom),
        setFlag(currentAnswerFormat,'JSONIC'),
        !.

outIdentifier(_x,_xAtom) :-
        getFlag(currentAnswerFormat,'JSONIC'),!,
	esapeQuotes(_x,_x1),
	do_outIdentifier(_x1, _xAtom1),
	pc_atomconcat(['"',_xAtom1,'"'],_xAtom).

outIdentifier(_x,_xAtom) :-
	do_outIdentifier(_x, _xAtom).

esapeQuotes(_x,_x1) :-
	atom(_x),
	pc_atomtolist(_x,['"'|_atomlistq]),
	skipLastQuote(_atomlistq,_atomlist),
	pc_atomtolist(_xbody,_atomlist),
	pc_atomconcat(['\\"',_xbody,'\\"'],_x1),
	!.
esapeQuotes(_x,_x).

skipLastQuote(['"'],[]) :- !.
skipLastQuote([_a|_rest],[_a|_newrest]) :-
   skipLastQuote(_rest,_newrest).


/* ***   for a select expression  *** */
do_outIdentifier(select( _inSelect, _selectSymbol, _ident), _editorName) :-
    !,
	outSelectIdent(select( _inSelect, _selectSymbol, _ident), _editorName),
	!.

do_outIdentifier(derive(_q,_slist), _outderiveexp) :-
    !,
    deriveExprToAtom(derive(_q,_slist),_outderiveexp),
    !.

do_outIdentifier(_systemid,_name) :-
    atom(_systemid),
    is_id(_systemid),   /** pc_atomconcat('id_',_,_systemid),  **/
    id2name(_systemid,_name),!.

/* Manchmal ist eine derive-Expression ein Atom, das noch in ein
* Prolog-Term umgewandelt werden muss.*/
do_outIdentifier(_id,_newid) :-
    atom(_id),
	pc_atomconcat('derive(',_x,_id),
   	pc_save_atom_to_term(_id,_idterm),   /** ticket #214: components of _id can be uppercase labels **/
   	!,
	do_outIdentifier(_idterm,_newid),!.


do_outIdentifier(_name,_name) :-!.




/* ************ d e r i v e E x p r T o P r o l o g T e r m ************ */
/*                                                       8-Feb-1991/MJf  */
/* deriveExprToAtom(_d,_QQ)                                        */
/*   _d: term (i,o)                                                      */
/*   _QQ: term (o,i)                                                     */
/*                                                                       */
/* The derive expression _d (= syntax tree of e.g. Q[x/c,y:d]) is trans- */
/* formed to a Prolog atom, e.g. 'Q[x/c,y:d]'.                            */
/* See also deriveExpression in parseAss.dcg and sml_gramm.dcg.          */
/*                                                                       */
/* ********************************************************************* */

deriveExprToAtom(derive(_q,_slist),_qatom) :-
  (id2name(_q,_qname);_qname=_q),
  transformSlist(_slist,_subatom),
  !,
  pc_atomconcat([_qname,'[',_subatom],_qatom).

deriveExprToAtom(_QQ,_QQ).



transformSlist([],']') :- !.

transformSlist([substitute(_x1,_x2)|_r], _atom) :-
	outIdentifier(_x1,_outx1),
	outIdentifier(_x2,_outx2),
	(( _r \== [], !,
	   transformSlist(_r,_nr),
	   pc_atomconcat([_outx1,'/',_outx2,',',_nr],_atom)
	  );
	 ( _r == [], ! ,
	   pc_atomconcat([_outx1,'/',_outx2,']'],_atom)
	)).


transformSlist([specialize(_x1,_x2)|_r], _atom) :-
	outIdentifier(_x1,_outx1),
	outIdentifier(_x2,_outx2),
	(( _r \== [], !,
	   transformSlist(_r,_nr),
	   pc_atomconcat([_outx1,':',_outx2,',',_nr],_atom)
	  );
	 ( _r == [], ! ,
	   pc_atomconcat([_outx1,':',_outx2,']'],_atom)
	)).



/****************************************************************************
   outSelectIdent(_select,_Name)
   _select ground atom
   _Name free atom
  outSelectIdent is a help-predicate for outIdentifier/2. It gets the
  name of an selct expression into an expression for the editor.

  In select(x,op,y) is y also replaced with a select expression    6-Jul-1994/CQ
  2009-10-29/MJf: always enclose select expressions with ->/=> in parantheses; ticket #227 
******************************************************************************/


outSelectIdent(select(_inSelect,_selectSymbol,_ident),_newName) :-
	outSelectIdent(_inSelect,_helpName),
	outSelectIdent(_ident,_newident),
	((pc_member(_selectSymbol,['->','=>']),
	  pc_atomconcat(['(',_helpName,_selectSymbol,_newident,')'],_newName)
	 );
	 (pc_atomconcat([_helpName,_selectSymbol,_newident],_newName)
	)),
	!.

outSelectIdent(_x,_ex) :-
	outIdentifier(_x,_ex),            /*29-Jul-1988/MJf*/
	!.







/* ******************** l i n e L i s t T o B I M s t r i n g ***************** */
/*                                                                              */
/*	lineListToBIMstring( _linelist , _asciilist )                         */
/*		_linelist : ground : list of lists                             */
/*		_asciilist : free                                              */
/*                                                                              */
/*	_linelist is assumed to be a list of lists of atoms,integers,charlists */
/*	or strings. This list is flattened first to a simple list and then to  */
/*	a list of characters which is transformed to a BIMstring               */
/*                                                                              */
/* Changes :                                                                    */
/*                                                                              */
/* The 3rd clause of atomToList/2 is added. Otherwise, real numbers wouldn't  be*/
/* considered.       05-07-1991 / Andre Klemann (UPA)                           */
/*                                                                              */
/* **************************************************************************** */

lineListToBIMstring(_i,_o) :-
	flatLineList(_i,_o1),
	listToCharList(_o1,_o).

lineListToAtom(_i,_o) :-
	flatLineList(_i,_fl),
	pc_atomconcat(_fl,_o).

flatLineList([_r],_r) :-!.
flatLineList([_f|_r],_res) :-
	flatLineList(_r,_res1),
	append(_f,['\n'|_res1],_res).

listToCharList([],[]).
listToCharList([_f|_r],_res) :-
	atomToList(_f,_fl),
	listToCharList(_r,_rl),
	append(_fl,_rl,_res).

/*MART*/ /*same as listToCharLit but with keeping commata
between charlists generated from different atoms*/

listToCharListwithCommata([],[]).
listToCharListwithCommata([_f|_r],_res) :-
	atomToList(_f,_fl),
	listToCharListwithCommata(_r,_rl),
	((_rl ==[],!,_res=_fl);
               append(_fl,[','|_rl],_res)
              ).

listToAtomWithCommata([],_res).

listToAtomWithCommata([_f],_res) :-
	listToAtomWithCommata([],_res),
	prependBuffer(_res,_f).

listToAtomWithCommata([_f|_r],_res) :-
	listToAtomWithCommata(_r,_res),
	pc_atomconcat(_f,',',_fk),
	prependBuffer(_res,_fk).


atomToList(_atom,_list) :-
	atom(_atom),!,
	atom2list(_atom,_list).

atomToList(_int,_list) :-
	integer(_int),!,
	pc_inttoatom(_int,_at),
	atom2list(_at,_list).

atomToList(_real,_list) :-   /* 05-07-1991 / AK (UPA) */
	float(_real),!,
	pc_floattoatom(_real,_at),
	atom2list(_at,_list).

/*
atomToList(_str,_list) :-
	string(_str),!,
	name(_at,_str),
	atom2list(_at,_list).
*/
atomToList(_l,_l).

/* THE FOLLOWING PREDS WERE ORIGINALLY IN NEW_UTILITIES */



multiAppend([_x], _x).

multiAppend([_x,_y | _tailListOfList], _result) :-
	append(_x, _y, _temp),
	multiAppend([_temp|_tailListOfList], _result).
