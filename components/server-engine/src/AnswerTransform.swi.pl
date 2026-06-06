%
% The ConceptBase.cc Copyright
%
% Copyright 1987-2020 The ConceptBase Team. All rights reserved.
%
% Redistribution and use in source and binary forms, with or without modification, are permitted
% provided that the following conditions are met:
%
%    1. Redistributions of source code must retain the above copyright notice, this list of
%       conditions and the following disclaimer.
%    2. Redistributions in binary form must reproduce the above copyright notice, this list of
%       conditions and the following disclaimer in the documentation and/or other materials
%       provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE CONCEPTBASE TEAM ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONCEPTBASE TEAM OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
% OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
% OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
% The views and conclusions contained in the software and documentation are those of the authors
% and should not be interpreted as representing official policies, either expressed or implied,
% of the ConceptBase Team.
%
%
% The ConceptBase Team is represented by
%
% Manfred Jeusfeld, University of Skovde, 54128 Skovde, Sweden
% Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
% Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
%
%
% This license is a FreeBSD-style copyright license.
% Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
%
%  ***********************************************************
%             A T T E N T I O N
%  In this file, curly braces in comments were generally
%  replaced by square brackets because the Prolog preprocessor
%  cannot handle them.
%  ***********************************************************
%
% File:        AnswerTransform.pro
% Creation:    1998, Wang Hua(RWTH)
%
%
%
% Definition of an answer format:
% 1. forQuery:
% This specifies which queries are bound to this format. A query may have at most one
% format.
% Representing queries as an attribute of AnswerFormat has the advantage that the
% associated format of a query can be changed arbitrarily.
%
% 2.order:
% Specifies in which order the solutions are to be sorted.
% Currently ascending and descending are possible.
%
% 3.orderBy:
% Specifies what the solutions should be sorted by.
% The following possibilities exist, for example:
%      "this" sorts by the name of the solution object.
%      "this.attribute_name" sorts by the value of the corresponding attribute.
%         For multi-valued attributes, the first element of the set is taken.
%
% 4.head:
% Specifies what appears before the actual solution, e.g. a heading. Predicates can be called here.
% The solution content cannot be specified here.
%
% 5.tail:
% Specifies what appears after the answer. Structure as in case 4.
%
% 6.split:
% For multi-valued attributes, split is returned.
% if split is TRUE, then one solution has been split into multiple solutions according to its attribute values.
% (This is not yet implemented.)
%
% 7.pattern:
% Pattern specifies how the answers should look.
%     Syntax:
%     * A pattern is a string enclosed in " ". What appears inside should be output as-is.
%     * What is to be replaced later is enclosed in curly braces (as in Prolog comments,
%       therefore they cannot be used here; square brackets are used in the examples).
%       The terms inside the brackets are the replaceable content,
%       e.g. a term like [this], [this.salary] is replaced by the name of a solution object
%       and the attribute value of salary. Predicates can also be called, e.g. [ASKquery(...)]
%
%       The following specifications and predicate calls can occur:
%           this, this.inOmega, this.in, this.isa, this.attribute, this|attribute, this.attrCategory
%           this.salary, this|salary, this^wangssalary, or
%       variables, or
%       predicates such as
%         Foreach((list of value set), ( list of variables), outputpattern)
%             Foreach(([this.attribute],[this|attribute]),(x,y),Label:[y]; Value: [x] \\n))
%         IFTHENELSE(Condition,outputpattern1,outputpattern2)
%         AND/2,OR/2,EQUAL/2,GREATER/2,LOWER/2, ASKquery(QueryName,Format), STRINGENCODING/1, STRINGDECODING/1
%
%     See substituteBrackets() for a detailed description.
%
%
%
%     * special symbols:
%       In a pattern definition, '"', '[', ']', and '\' all have special meanings. '"' marks the
%       beginning or end of a pattern definition. '[' and ']' indicate that the content inside
%       is to be replaced. '\' indicates a special symbol. If the symbols explained above occur
%       in a pattern with other meanings, they must be escaped with '\'.
%
%       Furthermore, within the brackets '[' and ']', '(', ')', and ',' also have special meanings.
%       '(' indicates a predicate call. ')' marks the end of argument parsing. ',' separates the
%       arguments of a predicate.
%
%     See substituteBrackets() and parseArgumentList() for detailed descriptions.
%
%       There could still be some special symbols in the pattern to control output.
%       '\n': NEW LINE, '\t' : TAB , '\b': BACKSPACE, the last character is deleted.
%
%
%
%
%
%
% Example:
% Suppose a QueryClass object test is given that should return all employees with name and salary.
%
%    QueryClass test isA Employee with
%     retrieved_attribute
%       salary:Integer;
%       name:String
%    end
%
% Here a format is defined for the query test, with which the query results are to be delivered as an unordered list.
%
%   Individual Listfortest in AnswerFormat with
%     attribute,forQuery
%      fq : test
%     attribute,order
%      od : ascending
%     attribute,orderBy
%      oby : "this.salary"
%     attribute,head
%      h : "Here is the answer:"
%     attribute,tail
%      t : "that's all!"
%     attribute,pattern
%      p : "OBJ([this])\\tName([this.name])\\tSalary([this.salary])"
%     attribute,split
%      s : TRUE
%   end
%
%
% Here a format is defined and according to this format all employee data should be
% transformed into corresponding HTML code.
%
%   Individual HTMLfortest in AnswerFormat with
%     attribute,forQuery
%      fq : test
%     attribute,order
%      od : descending
%     attribute,orderBy
%      oby : "this.salary"
%     attribute,head
%      h :"<html>
%     <head><title>conceptbase www interface </title></head>
%     <body>
%     <h2>Here is the answer:</h2>
%     <ul>"
%     attribute,tail
%      t:"</ul>
%     <h2>That is all!!!</h2>
%     </body>
%     </html>"
%     attribute,pattern
%      p :"<li>object([this]) salary([this.salary])"
%     attribute,split
%      s : TRUE
%   end
%
%
%
% With our pattern definition language, general formats can also be defined, so that one format can
% serve several queries at once, e.g. a frame representation:
%
%   Individual FrameFormat in AnswerFormat with
%     attribute,head
%      h : "Here is the answer:"
%     attribute,tail
%      t : "that's all!"
%     attribute,split
%      s : TRUE
%     attribute,pattern
%      p : "[this]\\n[Foreach(([this.attrCategory]),(x),\\t[x]\\n[Foreach(([this|[x]]),(z),\\t\\t[z]:\\t[this^[z]];\\n)]\\b\\b\\n)]\\nend"
%   end
%
%
% A table representation:
%
% Individual Table in AnswerFormat with
%   attribute,head
%      th : "<html>
%     <head>
%     <title>The answer in table form</title>
%     </head>
%     <body>
%     <h1>Here is the Answer: </h1>
%     <table border=6>"
%   attribute,pattern
%      tp : "<tr>[Foreach(([this.attrCategory]),(x),<td>[x]\([this.[x]]\)</td>)]</tr>"
%   attribute,tail
%      tt : "</table>
%     </body>
%     </html>"
% end
%
%
% *****Complex path expressions with respect to views:******
%
% View EmpDeptSalary isA Employee with
%    retrieved_attribute, partof
%      dept : Department with
%                retrieved_attribute, partof
%                     head : Manager with retrieved_attribute
%                      salary: Integer
%                 end
%             end
% end
%
% Individual testFormatforView in AnswerFormat with
%   attribute,forQuery
%      fq : EmpDeptSalary
%   attribute,head
%      h : "Here is the answer:"
%   attribute,tail
%      t : "that's all!"
%   attribute,split
%      s : TRUE
%   attribute,pattern
%      p : "
% Object([this])
% attribute_value([this.attribute])
% attribute_label([this|attribute])
% attribute_category([this.attrCategory])
% Dept([this.dept.this])
% Dept_Head([this.dept.head.this])
% Dept_Head_salary([this.dept.head.salary])"
% end
%
%
% **************** Web queries *******************************************
% To query from the web, only the appropriate URL must be entered.
% For example, to invoke the query test, the following URL should be used:
% http://moers:4001/Query(test)
% where moers indicates where the CB server runs, and 4001 is the port.
%
%
% When order or orderBy is not given, solutions are sorted by default values:
% order is ascending and orderBy is "this".
% When split is not given, the default is "FALSE".
% If the pattern is not given, return the answers as before in Frame, Label, or Fragment.
% If any attribute name is entered incorrectly in the pattern, ERROR is substituted.
%

:- module('AnswerTransform',[
'delete_first_and_last'/2
,'eraseParameters'/1
,'parse'/2
,'recordParameters'/1
,'recordValue'/2
,'remove_initialed_values'/1
,'transform_answer_in_Updateformat'/3
,'transform_answer_in_format'/4
,'IsLastFrame'/1
,'IsFirstFrame'/1
,'eraseAnswerParameters'/1
,'addAnswerParameters'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('PropositionProcessor.swi.pl').
:- use_module('IpcChannel.swi.pl').
:- use_module('AnswerTransformator.swi.pl').
:- use_module('ScanFormatUtilities.swi.pl').
:- use_module('SelectExpressions.swi.pl').
:- use_module('ExternalCodeLoader.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- use_module('AnswerTransformUtilities.swi.pl').
:- use_module('GlobalParameters.swi.pl').
:- use_module('MetaUtilities.swi.pl').
:- dynamic 'Frag'/1 .
%  this two flags are for solving ticket #30

:- dynamic 'IsLastFrame'/1 .
:- dynamic 'IsFirstFrame'/1 .
:- style_check(-singleton).
transform_answer_in_format(solution(_q,_sol),_fid,_ansrep,_answerlist):-
    transform(solution(_q,_sol),_fragmentlist),
    get_all_formatinfos(_fid,_orderID,_orderByID,_headID,_tailID,_patternID,_splitID),
    !,
    order_answer(_fragmentlist,_orderID,_orderByID,_fraglist_ordered),
    !,
    pc_update('IsLastFrame'(no)),  % #30
    pc_update('IsFirstFrame'(yes)),  % #30
    build_answer(_fraglist_ordered,_patternID,_ansrep,_splitID,_answerlist),
    build_headtail(_fraglist_ordered,_answerlist,_headID,_tailID,_answerlist).
transform_answer_in_format(_fragmentlist,_fid,_ansrep,_answerlist):-
    get_all_formatinfos(_fid,_orderID,_orderByID,_headID,_tailID,_patternID,_splitID),
    !,
    order_answer(_fragmentlist,_orderID,_orderByID,_fraglist_ordered),
    !,
    pc_update('IsLastFrame'(no)),  % #30
    pc_update('IsFirstFrame'(yes)),  % #30
    build_answer(_fraglist_ordered,_patternID,_ansrep,_splitID,_answerlist),
    build_headtail(_fraglist_ordered,_answerlist,_headID,_tailID,_answerlist).
transform_answer_in_format(_fa,_fid,_ansrep,''):-
    write('Error while transforming answer!!!'),nl.

transform_answer_in_Updateformat(_fa,_fid,_UpdatePattern):-
    transform(_fa,_fragmentlist),
    get_all_formatinfos(_fid,_orderID,_orderByID,_headID,_tailID,_patternID,_splitID),
    !,
    build_UpdatePattern(_fragmentlist,_patternID,_UpdatePattern).

get_all_formatinfos(_id,_orderID,_orderByID,_headID,_tailID,_patternID,_splitID):-
    get_order(_id,_orderID),
    get_orderBy(_id,_orderByID),
    get_head(_id,_headID),
    get_tail(_id,_tailID),
    get_pattern(_id,_patternID),
    get_split(_id,_splitID).
%  no sorting done for bulk queries

order_answer(_fragmentlist,_orderID,_orderByID,_fragmentlist) :-
   getFlag(bulkQuery,on),
   !.
%  ticket #416: no sorting when 'orderBy' attribute of answer format is set to "none"

order_answer(_fragmentlist,_orderID,_orderByID,_fragmentlist) :-     
    is_id(_orderByID),
    retrieve_proposition('P'(_orderByID,_orderByID,_o,_orderByID)),
    _o=='"none"',
    !.
order_answer(_fragmentlist,_orderID,_orderByID,_fragmentlist):-
    (    var(_orderID);var(_orderByID)    ),
    tooBigList(_fragmentlist),
    !.
order_answer(_fragmentlist,_orderID,_orderByID,_fraglist_ordered):-
    (    var(_orderID);var(_orderByID)    ),
    !,
    convertlist(_fragmentlist,what(_),_list),
    quicksort(_list,_fraglist_ordered1),
    unconvertlist(_fraglist_ordered1,_fraglist_ordered).
order_answer(_fragmentlist,_orderID,_orderByID,_fraglist_ordered):-  % order by obj, obj.attr_cat
    retrieve_proposition('P'(_orderByID,_orderByID,_o,_orderByID)),
    _o=='"this"',
    !,
    convertlist(_fragmentlist,what(_),_list),
    sort(_list,_orderID,_fraglist_ordered1),
    unconvertlist(_fraglist_ordered1,_fraglist_ordered).
%  18-Jul-2006/M.Jeusfeld: explicitely cover the case when the orderBy tag of the answer format
%  is set to "this.oid"  (= order by object identifier). See also ticket #108

order_answer(_fragmentlist,_orderID,_orderByID,_fraglist_ordered):-   
    retrieve_proposition('P'(_orderByID,_orderByID,_o,_orderByID)),
    _o=='"this.oid"',
    !,
    convertlist(_fragmentlist,oid,_list),
    sort(_list,_orderID,_fraglist_ordered1),
    unconvertlist(_fraglist_ordered1,_fraglist_ordered).
order_answer(_fragmentlist,_orderID,_orderByID,_fraglist_ordered):-
    retrieve_proposition('P'(_orderByID,_orderByID,_a,_orderByID)),
    pc_atomconcat('"this.',_attr_cat1,_a),
    !,
    pc_atomconcat(_attr_cat,'"',_attr_cat1),
    convertlist(_fragmentlist,attr_value(_attr_cat),_list),
    sort(_list,_orderID,_fraglist_ordered1),
    unconvertlist(_fraglist_ordered1,_fraglist_ordered).
order_answer(_fragmentlist,_orderID,_orderByID,_fraglist_ordered):-
    retrieve_proposition('P'(_orderByID,_orderByID,_l,_orderByID)),
    pc_atomconcat('"this|',_attr_cat1,_l),
    !,
    pc_atomconcat(_attr_cat,'"',_attr_cat1),
    convertlist(_fragmentlist,attr_label(_attr_cat),_list),
    sort(_list,_orderID,_fraglist_ordered1),
    unconvertlist(_fraglist_ordered1,_fraglist_ordered).
order_answer(_fragmentlist,_orderID,_orderByID,_fraglist_ordered):-
    write('Error while ordering answer! Maybe syntax error with order or orderBy?'),nl,!,fail.

sort(_list,_orderID,_list):-
   tooBigList(_list),
   !.
sort(_list,_orderID,_list_sorted):-
    retrieve_proposition('P'(_orderID,_orderID,ascending,_orderID)),  % can later be replaced by keysort or quicksort
    !,
    quicksort(_list,_list_sorted).
sort(_list,_orderID,_list_sorted):-
    retrieve_proposition('P'(_orderID,_orderID,descending,_orderID)),
    !,
    quicksort(_list,_list1),
    reverse(_list1,_list_sorted).
sort(_,_,_):-
    write('AnswerTransform: sort failed!'),nl.
%  we do not sort very large lists since it can cause stack overflows

tooBigList(_list) :-
  get_cb_feature(sortLimit,_max),
  checkTooBig(_max,_list),
  'WriteTrace'(minimal,'AnswerTransform',['Answer not sorted because it exceeds ', _max, ' elements.']),
  !.

checkTooBig(_nr,[]) :- 
  _nr > 0,
  !,
  fail.
checkTooBig(0,[_x|_rest]) :- !.
checkTooBig(_nr,[_x|_rest]) :-
  _nr > 0,
  _nr1 is _nr - 1,
  checkTooBig(_nr1,_rest).
%  when the pattern is not specified, the query result is transformed as Frame, Label, or SML fragment.

build_answer(_fraglist_ordered,_patternID,_ansrep,_splitID,_anslist_with_format):-
    var(_patternID),
    !,
    build_answer1(_fraglist_ordered,_ansrep,_anslist_with_format).
%  Otherwise the solutions are transformed according to the given pattern.

build_answer(_fraglist_ordered,_patternID,_ansrep,_splitID,_anslist_with_format):-
    ground(_patternID),
    var(_splitID),
    retrieve_proposition('P'(_patternID,_patternID,_pattern,_patternID)),
    !,
    build_answer2(_fraglist_ordered,_pattern,_anslist_with_format).
build_answer(_fraglist_ordered,_patternID,_ansrep,_splitID,_anslist_with_format):-
    ground(_patternID),
    ground(_splitID),
    retrieve_proposition('P'(_splitID,_splitID,'FALSE',_splitID)),
    retrieve_proposition('P'(_patternID,_patternID,_pattern,_patternID)),
    !,
    build_answer2(_fraglist_ordered,_pattern,_anslist_with_format).
build_answer(_fraglist_ordered,_patternID,_ansrep,_splitID,_anslist_with_format):-
    ground(_patternID),
    ground(_splitID),
    retrieve_proposition('P'(_splitID,_splitID,'TRUE',_splitID)),
    retrieve_proposition('P'(_patternID,_patternID,_pattern,_patternID)),
    !,
    split_answer(_fraglist_ordered,_fraglist_splited),
    build_answer2(_fraglist_splited,_pattern,_anslist_with_format).

build_answer1([],_,_res).
build_answer1(_fraglist_ordered,'LABEL',_res):-
	!,
    collect_frame_labels(_fraglist_ordered,_labels),
    listToAtomWithCommata(_labels,_res),
    appendBuffer(_res,'\n').
build_answer1(_fraglist_ordered,'FRAGMENT',_res):-
    !,
    pc_atom_to_term(_atom,_fraglist_ordered),
    appendBuffer(_res,_atom),
    appendBuffer(_res,'\n').
build_answer1(_fraglist_ordered,'FRAME',_res):-
    !,
    fragments_to_frames(_fraglist_ordered,_res),
    appendBuffer(_res,'\n').
build_answer1(_fraglist_ordered,'JSONIC',_res):-
    !,
    fragments_to_frames(_fraglist_ordered,_res),
    appendBuffer(_res,'\n').
%  the character \001 is temporarily inserted in _anslist_with_format
%  as placeholder for ','. We need the replace it accordingly before
%  we return the answer.

build_answer2([],_,_anslist_with_format) :-
    replaceCharacterInBuffer(_anslist_with_format,'\001',',').   
%  distinguish this case to be able to raise the flag IsLastFrame

build_answer2([_frag],_pattern,_anslist_with_format):-
    pc_update('IsLastFrame'(yes)),  % #30
    build_answer_with_format(_frag,_pattern,_anslist_with_format),
    replaceCharacterInBuffer(_anslist_with_format,'\001',','),
    !.
build_answer2([_frag|_rfraglist_ordered],_pattern,_anslist_with_format):-
    build_answer_with_format(_frag,_pattern,_anslist_with_format),
    pc_update('IsFirstFrame'(no)),  % #30
    build_answer2(_rfraglist_ordered,_pattern,_anslist_with_format).
% TODO: STILL TO CHANGE to StringBuffer (or remove entirely)

build_UpdatePattern([],_,''):-!.
build_UpdatePattern([_fragment|_rfragmentlist],_patternID,_UpdatePattern):-
    retrieve_proposition('P'(_patternID,_patternID,_pattern,_patternID)),
    pc_atomconcat('"',_rpattern,_pattern),
    'TermToCharList'(_rpattern,_rpatternlist),
    asserta('Frag'(_fragment)),
    !,
    parse(_rpatternlist,_p),
    pc_atomconcat(_p,_patom),
    retract('Frag'(_fragment)),
    build_UpdatePattern(_rfragmentlist,_patternID,_rUpdatePattern),
    pc_atomconcat(_patom,_rUpdatePattern,_UpdatePattern).

build_answer_with_format(_fragment,_pattern,_anslist):-
    pc_atomconcat('"',_rpattern,_pattern),
    'TermToCharList'(_rpattern,_rpatternlist),
    asserta('Frag'(_fragment)),
    !,
    parse(_rpatternlist,_anslist),  % originally an '\n' was appended to _ans, 2-Nov-2000/MJf  % parse replaces strings like this ... with the actual values at call time and formats the pattern list with line breaks
    retract('Frag'(_fragment)).
% *********************** helper functions ****************************

get_order(_id,_orderID):-
    prove_literal('A'(_id,'AnswerFormat',order,_orderID)).
get_order(_id,_).

get_orderBy(_id,_orderByID):-
    prove_literal('A'(_id,'AnswerFormat',orderBy,_orderByID)).
get_orderBy(_id,_).

get_head(_id,_headID):-
    prove_literal('A'(_id,'AnswerFormat',head,_headID)).
get_head(_id,_).

get_tail(_id,_tailID):-
    prove_literal('A'(_id,'AnswerFormat',tail,_tailID)).
get_tail(_id,_).

get_pattern(_id,_patternID):-
    prove_literal('A'(_id,'AnswerFormat',pattern,_patternID)).
get_pattern(_id,_).

get_split(_id,_splitID):-
    prove_literal('A'(_id,'AnswerFormat',split,_splitID)).
get_split(_id,_).
%  In the head or tail block it is also possible to access the solutions, but only the first solution!

build_headtail([_fragment|_rfragment],_ansatom,_headID,_tailID,_answer):-
    asserta('Frag'(_fragment)),
    !,
    createBuffer(_hlist),
    createBuffer(_tlist),
    !,
    build_head(_headID,_hlist),
    build_tail(_tailID,_tlist),
    retract('Frag'(_fragment)),
    getStringFromBuffer(_hatom,_hlist),
    getStringFromBuffer(_tatom,_tlist),
    prependBuffer(_ansatom,_hatom),
    appendBuffer(_ansatom,_tatom),
    disposeBuffer(_hlist),
    disposeBuffer(_tlist),
    !.

build_head(_headID,_hlist):-
    ground(_headID),
    retrieve_proposition('P'(_headID,_headID,_head,_headID)),
    pc_atomconcat('"',_rhead,_head),
    'TermToCharList'(_rhead,_hlist1),
    parse(_hlist1,_hlist).  % originally, an '\n' was appended to _hlist *, 2-Nov-2000/MJf
build_head(_headID,_):-
    var(_headID).

build_tail(_tailID,_tlist):-
    ground(_tailID),
    retrieve_proposition('P'(_tailID,_tailID,_tail,_tailID)),
    pc_atomconcat('"',_rtail,_tail),
    'TermToCharList'(_rtail,_tlist1),
    parse(_tlist1,_tlist).
build_tail(_tailID,_):-
    var(_tailID).
%  here builds a list with single elements as: (_value,SML(_)),
%  extract the value to be sorted

convertlist([],_,[]):-!.
convertlist([_fragment|_rest],_crit,[(_v,_fragment)|_rlist]):-
    getOrderValue(_fragment,_crit,_v),
    convertlist(_rest,_crit,_rlist).
%  getOrderValue(_fragment,_crit,_v) computes an order value for _fragment according
%  to _criterion.

getOrderValue(_fragment,what(_),_v) :-
    'Out_Object'([_fragment],[_v|_]),
    !.
%  18-Jul-2006/M.Jeusfeld: this case supports the answer formatting for
%  being sorted according to the object identifier. See ticket #108.

getOrderValue(_fragment,oid,_v) :-
    _fragment = 'SMLfragment'(what(_objname),_,_,_,_),
    eval(_objname,replaceSelectExpression,_o),
    pc_atomconcat('id_',_v,_o),
    !.
getOrderValue(_fragment,attr_value(_attr_cat),_v) :-
   'Out_attribute_value'([_fragment],_attr_cat,[_v|_]),  % will take the first attribute value
   !.
getOrderValue(_fragment,attr_label(_attr_cat),_v) :-
  'Out_attribute_label'([_fragment],_attr_cat,[_v|_]),  % will take the first attribute label
  !.
%  catchall

getOrderValue(_fragment,_crit,'0').

unconvertlist([],[]):-!.
unconvertlist([(_,_fragment)|_r],[_fragment|_res]):-
    unconvertlist(_r,_res).
% Here the ... is first and last element (namely  "  ) deleted from the list.

delete_first_and_last([],[]).
delete_first_and_last(['"'|_rest],_outlist) :-
  delete_last(_rest,[],_outlist),
  !.
delete_first_and_last(_,_):-
    write('Error!  "  missed!'),nl,!,fail.

delete_last(['"'],_sofar,_sofar) :-
 !.
delete_last([_a|_rest],_sofar,_outlist) :-
  _rest \= [],
  append(_sofar,[_a],_sofar1),
  delete_last(_rest,_sofar1,_outlist).
% ***************************************** Out_XXX  ***************************************************
%  Out_XXX delivers from a list of SML fragments the requested value with respect to XXX;
%  the value is delivered as a list of atoms/terms.
% ******************************************************************************************************

'Out_Object'([],[]):-!.
'Out_Object'(['SMLfragment'(what(_o),_,_,_,_)|_rest],[_on|_rObjlist]) :-
    outIdentifier(_o,_on),
    'Out_Object'(_rest,_rObjlist).

'Out_ObjectId'([],[]):-!.
'Out_ObjectId'(['SMLfragment'(what(_o),_,_,_,_)|_rest],[_oid|_rObjlist]) :-
    eval(_o,replaceSelectExpression,_oid),
    'Out_ObjectId'(_rest,_rObjlist).
%  if the argument _o is an atom, then it is the result of the evaluation of
%  some path expression. The result may be a simple objectname or an atom
%  like Object!attr. Out_ObjectId has to use select2id to convert this back
%  to an oid.                                        26-Jul-2006/M.Jeusfeld

'Out_ObjectId'([_o|_rest],[_oid|_rObjlist]) :-
    atom(_o), 
    select2id(_o,_oid),
    'Out_ObjectId'(_rest,_rObjlist).

'Out_SystemClass'([],[]):-!.
'Out_SystemClass'(['SMLfragment'(_,in_omega(_classlist),_,_,_)|_rest],_slist):-
    getObjectFromClasslist(_classlist,_sl1),
    'Out_SystemClass'(_rest,_sl2),
    append(_sl1,_sl2,_slist).

'Out_Class'([],[]):-!.
'Out_Class'(['SMLfragment'(_,_,in(_classlist),_,_)|_rest],_clist):-
    getObjectFromClasslist(_classlist,_cl1),
    'Out_Class'(_rest,_cl2),
    append(_cl1,_cl2,_clist).

'Out_SuperClass'([],[]):-!.
'Out_SuperClass'(['SMLfragment'(_,_,_,isa(_classlist),_)|_rest],_clist):-
    getObjectFromClasslist(_classlist,_cl1),
    'Out_SuperClass'(_rest,_cl2),
    append(_cl1,_cl2,_clist).

getObjectFromClasslist([],[]):-!.
getObjectFromClasslist([class(_c)|_rest],[_cn|_r]):-
    outIdentifier(_c,_cn),
    getObjectFromClasslist(_rest,_r).

'Out_attribute_label'([],_,[]):-!.
'Out_attribute_label'(['SMLfragment'(_,_,_,_,with(_attrdecl_list))|_rest],_attr_cat,_labels):-
    search_label(_attrdecl_list,_attr_cat,_labels1),
    'Out_attribute_label'(_rest,_attr_cat,_labels2),
    append(_labels1,_labels2,_labels).

'Out_attribute_value'([],_,[]):-!.
'Out_attribute_value'(['SMLfragment'(_,_,_,_,with(_attrdecl_list))|_rest],_attr_cat,_values):-
    search_value(_attrdecl_list,_attr_cat,_values1),
    'Out_attribute_value'(_rest,_attr_cat,_values2),
    append(_values1,_values2,_values).

search_label([],_,['NULL']):-!.
search_label([attrdecl(_catlist,_propertylist)|_restlist],_attr_cat,_label):-
    member(_attr_cat,_catlist),
    !,
    'Out_label'(_propertylist,_label).
search_label([attrdecl(_catlist,_propertylist)|_restlist],_attr_cat,_label):-
    search_label(_restlist,_attr_cat,_label).

search_value([],_,['NULL']):-!.
search_value([attrdecl(_catlist,_propertylist)|_restlist],_attr_cat,_value):-
    member(_attr_cat,_catlist),
    !,
    'Out_value'(_propertylist,_value).
search_value([attrdecl(_catlist,_propertylist)|_restlist],_attr_cat,_value):-
    search_value(_restlist,_attr_cat,_value).

'Out_label'([],[]):-!.
'Out_label'([property(_l,_)|_res],[_l|_r]):-
    'Out_label'(_res,_r).

'Out_value'([],[]):-!.
'Out_value'([property(_,_v)|_res],[_vn|_r]):-
    outIdentifier(_v,_vn),
    'Out_value'(_res,_r).

'Out_label_value'([],_,[]):-!.
'Out_label_value'(['SMLfragment'(_,_,_,_,with(_attrdecl_list))|_rest],_label,_values):-
    find_label_value(_attrdecl_list,_label,_values1),
    'Out_label_value'(_rest,_label,_values2),
    append(_values1,_values2,_values).

find_label_value([],_,['NULL']):-!.
find_label_value([attrdecl(_catlist,_propertylist)|_restlist],_label,_values):-
    'Out_label'(_propertylist,_labels),
    (
    (member(_label,_labels),
    get_label_value(_propertylist,_label,_values));
    find_label_value(_restlist,_label,_values)
    ).

get_label_value([],_,['NULL']):- !.
get_label_value([property(_l,_v)|_rest],_label,_value):-
    (
    (_l==_label,_value=[_v]);
    (get_label_value(_rest,_label,_value))
    ).

'Out_all_attribute_labels'([],[]):-!.
'Out_all_attribute_labels'(['SMLfragment'(_,_,_,_,with(_attrdecl_list))|_rest],_labels):-
    get_all_labels(_attrdecl_list,_labels1),
    'Out_all_attribute_labels'(_rest,_labels2),
    append(_labels1,_labels2,_labels).

get_all_labels([],[]):-!.
get_all_labels([attrdecl(_catlist,_propertylist)|_restlist],_labels):-
    'Out_label'(_propertylist,_label),
    get_all_labels(_restlist,_rlabels),
    append(_label,_rlabels,_labels).

'Out_all_attribute_values'([],[]):-!.
'Out_all_attribute_values'(['SMLfragment'(_,_,_,_,with(_attrdecl_list))|_rest],_values):-
    get_all_values(_attrdecl_list,_values1),
    'Out_all_attribute_values'(_rest,_values2),
    append(_values1,_values2,_values).

get_all_values([],[]):-!.
get_all_values([attrdecl(_catlist,_propertylist)|_restlist],_values):-
    'Out_value'(_propertylist,_value),
    get_all_values(_restlist,_rvalues),
    append(_value,_rvalues,_values).
%  note: in this list of attribute categories,
%  'attribute' should not occur as a list element.

'Out_all_attribute_Categories'([],[]):-!.
'Out_all_attribute_Categories'(['SMLfragment'(_,_,_,_,with(_attrdecl_list))|_rest],_Catlist):-
    get_all_Cats(_attrdecl_list,_Catlist1),
    'Out_all_attribute_Categories'(_rest,_Catlist2),
    append(_Catlist1,_Catlist2,_Catlist).

get_all_Cats([],[]):-!.
get_all_Cats([attrdecl(_catlist,_propertylist)|_restlist],_cats):-
    'Out_Cat'(_catlist,_cat),
    get_all_Cats(_restlist,_rcats),
    append(_cat,_rcats,_cats).
%  output attribute if list contains nothing else

'Out_Cat'([attribute],[attribute]):-!.
'Out_Cat'(_i,_o) :-
    'Out_Cat2'(_i,_o).
%  do not output attribute if there is something else in the list

'Out_Cat2'([],[]):-!.
'Out_Cat2'([_c|_res],[_c|_r]):-
    _c \== 'attribute',
    'Out_Cat2'(_res,_r).
'Out_Cat2'([_c|_res],_r):-
    'Out_Cat2'(_res,_r).
%  sorting now also works when values are integers or reals

quicksort([_pilot|_res],_listsorted):-
    partition(_res,_pilot,_less,_bigger),
    quicksort(_less,_ls),
    quicksort(_bigger,_bs),
    append(_ls,[_pilot|_bs],_listsorted).
quicksort([],[]):-!.

partition([_x|_xs],_y,_ls,[_x|_bs]):-
    _x=(_xx,_),_y=(_yy,_),
    greater(_xx,_yy),
    partition(_xs,_y,_ls,_bs).
partition([_x|_xs],_y,[_x|_ls],_bs):-
    partition(_xs,_y,_ls,_bs).
partition([],_,[],[]):-!.
%  when comparing, first check whether _xx and _yy could be integers.

greater(_xx,_yy):-
    (pc_inttoatom(_x,_xx);pc_floattoatom(_x,_xx)),
    (pc_inttoatom(_y,_yy);pc_floattoatom(_y,_yy)),
    _x > _y.
greater(_xx,_yy):-
    \+((
        (pc_inttoatom(_x,_xx);pc_floattoatom(_x,_xx)),
        (pc_inttoatom(_y,_yy);pc_floattoatom(_y,_yy))
    )),
_xx @> _yy.

split_answer(_fragmentlist_ordered,_fragmentlist_ordered).
% ****************************************** PARSE **************************************************
%  Parse(Pattern,Output)
%  Pattern: the pattern definition as a char list. The first '"' is already gone and the last '"' must be present.
%  Output: parsed pattern, at the same time this is the answer output for a single solution.
%  pattern definition language:
%  a pattern is defined by a string; everything in this string is to be displayed as-is,
%  except terms enclosed in [ ]. The terms in brackets are the replaceable contents.
%  this can be a term like [this],[this.salary] (object name and salary values are replaced), or
%  a predicate call like [ASKquery()]... (the content in [] is then replaced by the output of
%  the predicate call, usually the last argument), or variables like [x] may appear in brackets;
%  variables are currently only possible within the Foreach() predicate.
%  see substituteBrackets() for more details.
%
%  special symbols:
%  in a pattern definition, '"', '[', ']', and '\' all have special meanings. '"' marks the
%  beginning or end of a pattern definition. '[' and ']' indicate that the content inside
%  is to be replaced. '\' indicates a special symbol. If such symbols occur in a pattern
%  without these meanings, they must be escaped with '\'!!
%  furthermore, within [] the characters '(', ')', and ',' also have special meanings. '(' indicates
%  the start of a functor or predicate call. ')' marks the end of argument parsing. ',' separates
%  the arguments of a predicate. See substituteBrackets() and parseArgumentList() for detailed descriptions.
%
%  There could still be some special symbols occurring in the pattern to control output.
%  '\n': new line, '\t' : TAB ,  '\b': BACKSPACE, last character is deleted.
%
% Note on predicate calls:
% 1. predicate names must not already exist in CB, like and, or!! otherwise they cannot be made global.
% 2. argument names and functor names that contain (,) [,] must be escaped!
% note that [ASKquery(find_instances[[this]/class],LABEL)] and [ASKquery(find_instances[\[this\]/class],LABEL)] are different!!!
% 3. in a pattern, when [,] or " occurs, it must be escaped!
% 4. when a predicate call is faulty, the content is simply output unchanged.
% Predicate definition:
% Predicate(_Output,_arg1,_arg2,...)
% _argi are the actual parameters! _output is the return parameter!
% write predicates into AnswerTransformUtilities and then make them global!
%

parse([],_anslist):-!.
parse(['"'|_rpatternlist],_anslist):-
    !.
parse(['\\'|_rpatternlist],_anslist):-
    !,
    sonderZeichen(_rpatternlist,_restpatternlist,_f),
    appendBuffer(_anslist,_f),
    parse(_restpatternlist,_anslist),
    !.
parse(['{'|_rpatternlist],_anslist):-
    !,
    substituteBrackets(_rpatternlist,_anslist,_rlist),
    parse(_rlist,_anslist),
    !.
parse([_x|_rpatternlist],_anslist):-
    appendBuffer(_anslist,_x),
    parse(_rpatternlist,_anslist).
%  Here the predicates are found, functor as an atom and argument as a list of atoms.

findnextpraedikat(_rpatternlist1,_functor,_argumentlist,_restpatternlist):-
    'Ignore_blank'(_rpatternlist1,_rpatternlist),
        findfunctor(_rpatternlist,_functor1,_restpatternlist1),
        !,
        atom2list(_functor,_functor1),
        argsparsen(_restpatternlist1,_argumentlist,_restpatternlist).
% Find the functor if it exists, returns as a atom.

findfunctor([_x|_patternlist],[],_patternlist):-
    (_x=='}';_x=='{';_x=='"';_x==','),
       !,
       fail.
findfunctor(['('|_patternlist],[],_patternlist):-
    !.
findfunctor(['\\'|_patternlist],[_f|_rfunctor],_restpatternlist):-
    sonderZeichen(_patternlist,_rlist,_f),
    findfunctor(_rlist,_rfunctor,_restpatternlist).
findfunctor([_x|_patternlist],[_x|_rfunctor],_restpatternlist):-
    findfunctor(_patternlist,_rfunctor,_restpatternlist).
% *********************argsparsen*************************
%  parse the arguments; returns a list of atoms.

argsparsen([],_,_):-
    write('ERROR with argument parsing'),
    !,
    fail.
argsparsen([')'|_rpatternlist],[],_rlist):-
    !,
    _rpatternlist=['}'|_rlist].
argsparsen(_rpatternlist1,[_arg|_rargumentlist],_restpatternlist):-
    'Ignore_blank'(_rpatternlist1,_rpatternlist),
    createBuffer(_argBuffer),
    !,
    setFlag(listOn,false),  % indicates that we are currently parsing a list like [x1,x2]
    parseArgumentList(_rpatternlist,_argBuffer,_rlist),
    getPointerFromBuffer(_resultString,_argBuffer),
    save_stringtoatom(_resultString,_arg),
    disposeBuffer(_argBuffer),
    !,
    argsparsen(_rlist,_rargumentlist,_restpatternlist).
%  Here a serialized argument is parsed and a list of Char is returned.
%  note: within an argument, replaceable content can also occur;
%  as the last argument of a predicate call, it is usually
%  output pattern in which everything is possible!
%  note: '[', ']', '(', ')', ',', and '\' have special meanings; if they
%  occur in an argument without these meanings, they must
%  be escaped with '\'!!!

parseArgumentList(['\\'|_rpatternlist],_outPutBuffer,_rlist):-
    !,
    sonderZeichen(_rpatternlist,_restpatternlist,_f),
    appendBuffer(_outPutBuffer,_f),
    parseArgumentList(_restpatternlist,_outPutBuffer,_rlist).
%  a comma within a list is not terminating an argument

parseArgumentList([','|_rpatternlist],_outPutBuffer,_rlist):-
    getFlag(listOn,true),
    !,
    appendBuffer(_outPutBuffer,','),
    parseArgumentList(_rpatternlist,_outPutBuffer,_rlist).
%  other commas do terminate the argument

parseArgumentList([','|_rpatternlist],_outPutBuffer,_rpatternlist):-
    !.
parseArgumentList([')'|_rpatternlist],_outPutBuffer,[')'|_rpatternlist]):-
    !.
%  within an argument, a replaceable object can also occur!

parseArgumentList(['{'|_rpatternlist],_outPutBuffer,_restlist):-
    !,
    substituteBrackets(_rpatternlist,_outPutBuffer,_rlist),
    parseArgumentList(_rlist,_outPutBuffer,_restlist).
%  characters '[' and ']' indicate that we are processing a list; in this
%  case, the comma ',' is not indicating that an argument is completed
%  see ticket #182

parseArgumentList(['['|_rpatternlist],_outPutBuffer,_rlist):-
    setFlag(listOn,true),
    appendBuffer(_outPutBuffer,'['),
    parseArgumentList(_rpatternlist,_outPutBuffer,_rlist).
parseArgumentList([']'|_rpatternlist],_outPutBuffer,_rlist):-
    setFlag(listOn,false),
    appendBuffer(_outPutBuffer,']'),
    parseArgumentList(_rpatternlist,_outPutBuffer,_rlist).
parseArgumentList([_x|_rpatternlist],_outPutBuffer,_rlist):-
    appendBuffer(_outPutBuffer,_x),
    parseArgumentList(_rpatternlist,_outPutBuffer,_rlist).
% ***********************************  replace (substituteBrackets)  ***************************************************
%  replace/substituteBrackets replaces everything in [ ]; returns a list of atoms/terms; on error,
%  content is replaced by 'ERROR'; replace() does not fail, because partial results are sometimes useful...
% ************************************************************************************************************
%
% Replaceable expressions are structured as follows:
% 1) a term like:
% this-->
%     solution object name, e.g. replaced by ["Wang Hua"].
%
% this.inOmega, this.in, this.isa-->
%     return the solution object's system class, class, and superclass.
%
% this.attribute, this|attribute-->
%     all attribute values or all labels of the solution object,
%     e.g. this|attribute is replaced by [Wangssalary1,Wangssalary2,Wangsname,Wangsdept].
%
% this.attrCategory-->
%     all attribute categories of the solution object,
%     e.g. replaced by [salary,name,dept].
%
% this.salary-->
%     values of attribute category salary, e.g. [10000,5000]; note that this can be multi-valued!!!
%
% this|salary-->
%     labels of attribute category salary can also be multi-valued, e.g. [Wangssalary1,Wangssalary2]
%
% this^Wangssalary-->
%     value of attribute label Wangssalary, e.g. [100000]; here a value is uniquely determined!!!
% x-->
%     a variable
%     e.g. replaced by [salary]! variables can currently only occur within Foreach() calls;
%     they usually represent a set of values and are replaced in Foreach each time by one value.
%
% 2) a predicate like Foreach()
%     Foreach is treated as a special case because variables occur here.
%
% 3) normal predicates: EQUAL()... e.g. returns [TRUE].
%
% 4) complex and nested expressions like this.[x].head; here the inner part is replaced first, then the whole.
%
%
% NOTE:
%
% \ , ( ) [] " , all have special meanings!
% \--> escape character
% ( )--> for predicate calls, e.g. Foreach(...)
% [ ]--> signals replaceable parts
% , --> separator for the argument list of a predicate
% "--> beginning or end of a pattern
%
% if such symbols are still to be used with another meaning, they must be combined with escape characters,
% e.g. [IFTHENELSE([GREATER([this.salary],10000)],SALARY\(High\),SALARY\(Low\))]
%
%

substituteBrackets(_patternlist1,_substitutedContent,_rlist):-
    'Ignore_blank'(_patternlist1,_patternlist),
    _patternlist = ['F','o','r','e','a','c','h'|_],
 %    append(['F','o','r','e','a','c','h'],_,_patternlist),

    !,
        (
        parsen_foreach(_patternlist,_substitutedContent,_rlist);
        (
        write('Error with Parsing Foreach in:        '),
        atom2list(_errorpattern,_patternlist),
        write(_errorpattern),nl,
        appendBuffer(_substitutedContent,'SYNTAX-ERROR-Foreach \n')
        )
    ).
substituteBrackets(_patternlist,_substitutedContent,_rlist):-
    findObj(_patternlist,_object,_rlist),
    !,
    substituteBrackets2(_object,_substitutedContent),
    !.
substituteBrackets(_patternlist1,_substitutedContent,_rlist):-
    'Ignore_blank'(_patternlist1,_patternlist),
    findnextpraedikat(_patternlist,_functor,_argumentlist,_rlist),
    !,
    (
         callpraed(_functor,_argumentlist,_substitutedContent);
         (pc_atomconcat(['ERROR calling predicate ',_functor,'\n'],_atom),
          appendBuffer(_substitutedContent,_atom)
         )
    ),
    !.

substituteBrackets2(_object,_substitutedContent) :-
    atom2list('this',_object),
    !,
    'Frag'(_fragment),
    (
    'Out_Object'([_fragment],[_substitutedContentAtom]),appendBuffer(_substitutedContent,_substitutedContentAtom);
    appendBuffer(_substitutedContent,'NOOBJECT \n')  % was 'ERROR' before; now to be checked in foreach(), MJf, 1-Nov-2000, CBNEWS[201]
    ),
    !.
substituteBrackets2(_object,_substitutedContent) :-
    atom2list(_o,_object),
    pc_atomconcat('this',_path1,_o),  % _path1 is e.g. .x|y^z.attrCategory
    !,
    atom2list(_path1,_path),
    'Frag'(_fragment),
    (
    (parsen_PathExp([_fragment],_path,_substitutedContent));
    appendBuffer(_substitutedContent,'NOOBJECT \n')  % was 'ERROR' before; now to be checked in foreach(), MJf, 1-Nov-2000, CBNEWS[201]
    ),
    !.
substituteBrackets2(_object,_substitutedContent) :-
    atom2list(_o,_object),
    pc_recorded(_o,'AnswerFormatVariable',_value1),
    !,
    atom2list(_value,_value1),
    appendBuffer(_substitutedContent,_value).
%  take care of expressions like [param] where [param] is a parameter of a
%  query call like Q[value/param]. This is set in QAmanager.pro and reset
%  in CBserverInterface.pro.

substituteBrackets2(_object,_substitutedContent) :-
    atom2list(_o,_object),
    (pc_recorded(_o,'AuxAnswerParameter',_value);
     pc_recorded(_o,'PersistentAnswerParameter',_value)),
    !,
    appendBuffer(_substitutedContent,_value).
%  expressions that are not replacable are included with 'not replaced' tag
%  to allow debugging.

substituteBrackets2(_object,_substitutedContent) :-
    !,
    atom2list(_o,_object),
    pc_atomconcat(['{',_o,': ///not replaced///}'],_value),
    appendBuffer(_substitutedContent,_value).
% **************************************************************************************************************
% FindObj returns an object to be substituted as a char list, however it shall not be a predicate.
%  e.g. 'this.attribute', 'this.dept.head', '[x].salary', etc. note that variables can also occur...
% **************************************************************************************************************

findObj(['}'|_rpatternlist],[],_rpatternlist):-
    !.
%  if the replaceable part contains ( or ), it is a predicate...

findObj(['('|_rpatternlist],[],_rpatternlist):-
    !,
    fail.
findObj([')'|_rpatternlist],[],_rpatternlist):-
    !,
    fail.
% TODO: StringBuffer

findObj(['{'|_rpatternlist],_objectlist,_rlist):-
    !,  % only a variable can occur here!!
    createBuffer(_buf),
    !,
    substituteBrackets(_rpatternlist,_buf,_rlist1),
    findObj(_rlist1,_restobjectlist,_rlist),
    atom2list(_restobject,_restobjectlist),
    appendBuffer(_buf,_restobject),
    getStringFromBuffer(_object,_buf),
    atom2list(_object,_objectlist),
    disposeBuffer(_buf),
    !.
findObj(['\\'|_rpatternlist],[_s|_rObjlist],_r):-
    !,
    sonderZeichen(_rpatternlist,_restpatternlist,_s),
    findObj(_restpatternlist,_rObjlist,_r).
findObj([_x|_rpatternlist],[_x|_rObjlist],_r):-
    findObj(_rpatternlist,_rObjlist,_r).
% ***********************************************************************************************************************
%  here a path expression is parsed and processed one segment at a time, e.g. '.dept.head'.
%  this expression represents a value with respect to the SML fragment side, e.g. '.dept'
%  represents the value under attribute category dept with respect to the given
%  SML fragment. SML fragments can be nested, hence complex expressions like '.dept.head'
%  occur, where the attribute value of dept is again an SML fragment. parse_PathExp() returns a list of atoms/terms.
% ***********************************************************************************************************************

addAtomListToBuffer(_buffer,[_f]):-
      appendBuffer(_buffer,_f).
addAtomListToBuffer(_buffer,[_f|_rlist]):-
      appendBuffer(_buffer,_f),
      appendBuffer(_buffer,'\001'),  % Ascii char \001 is placeholder for ','
      addAtomListToBuffer(_buffer,_rlist).

parsen_PathExp(_eValue,[],_ersetzt_Value):-
      addAtomListToBuffer(_ersetzt_Value,_eValue),!.
parsen_PathExp(_fraglist,_pathExp,_ersetzt_Value):-
     getHead(_pathExp,_h,_t),
        (
            (
        _h=='.this',
        !,
        'Out_Object'(_fraglist,_valuelist)
        );
          (
        _h=='.oid',
        !,
        'Out_ObjectId'(_fraglist,_valuelist)
        );
        (
        _h=='.inOmega',
        !,
        'Out_SystemClass'(_fraglist,_valuelist)
        );
        (
        _h=='.in',
        !,
        'Out_Class'(_fraglist,_valuelist)
        );
        (
        _h=='.isa',
        !,
        'Out_SuperClass'(_fraglist,_valuelist)
        );
            (
        _h=='.attribute',
        !,
        'Out_all_attribute_values'(_fraglist,_valuelist)
        );
            (
        _h=='|attribute',
        !,
        'Out_all_attribute_labels'(_fraglist,_valuelist)
        );
        (
        _h=='.attrCategory',
        !,
        'Out_all_attribute_Categories'(_fraglist,_valuelist)
        );
            (
        pc_atomconcat('.',_attr_cat,_h),
        !,
        'Out_attribute_value'(_fraglist,_attr_cat,_valuelist)
        );
            (
        pc_atomconcat('^',_attr_label,_h),
        !,
        'Out_label_value'(_fraglist,_attr_label,_valuelist)
        );
            (
        pc_atomconcat('|',_attr_cat,_h),
        !,
        'Out_attribute_label'(_fraglist,_attr_cat,_valuelist)
        )
        ),
    parsen_PathExp(_valuelist,_t,_ersetzt_Value).
% *************************************************************
%  a path like '.dept.head' is processed one segment after another,
%  getHead first returns the first part; in this case it is '.dept'.
% *************************************************************

getHead([_f|_rest_pathExp],_h,_t):-
    member(_f,['.','!','|','^']),
    findNextTeilPath(_rest_pathExp,_nextTeilPath,_t),
    append([_f],_nextTeilPath,_h1),
    atom2list(_h,_h1).

findNextTeilPath([],[],[]).
findNextTeilPath([_f|_rest],[],[_f|_rest]):-
    member(_f,['.','!','|','^']).
findNextTeilPath([_f|_rest],[_f|_r],_rpath):-
    findNextTeilPath(_rest,_r,_rpath).
% **************************************************************************************************************
%  First check whether there is a character with special meaning after \; currently \n, \t, \b.
%  if not, it is a normal special symbol and is simply taken over, e.g. '"','[',']','(',')',',', etc.
% **************************************************************************************************************

sonderZeichen(['\\','n'|_restpatternlist],_restpatternlist,'\n'):-
    !.
sonderZeichen(['\\','t'|_restpatternlist],_restpatternlist,'\t'):-
    !.
sonderZeichen(['\\','b'|_restpatternlist],_restpatternlist,'\b'):-
    !.
%  empty atom denoted as '\0' in answer formats

sonderZeichen(['0'|_restpatternlist],_restpatternlist,''):-
    !.
%  Here handles the case _s == ",[,],(,)...

sonderZeichen([_s|_restpatternlist],_restpatternlist,_s):-
    !.

callpraed(_functor,_arglist,_outputBuffer):-
    _p=..[_functor|[_outputBuffer|_arglist]],
    pc_has_a_definition(_p),  % to prevent crashes when _p is undefined
    call(_p),
    !.
callpraed(_functor,_arglist,_):-
    _p=..[_functor|[_out|_arglist]],
    'WriteTrace'(low,'AnswerTransform',['Call to predicate  ',_p,' failed!']),
    !,
    fail.

parsen_foreach(['F','o','r','e','a','c','h','('|_rpatternlist11],_substitutedContent,_rlist):-
    'Ignore_blank'(_rpatternlist11,_rpatternlist1),
    parsen_var_value(_rpatternlist1,_rpatternlist21,_varValueList),  % varValueList==[ [[w,a,n,g],[q,u,i,x]],[[1,0,0,0],[3,0,0,0]]]
    'Ignore_blank'(_rpatternlist21,_rpatternlist2),
    parsen_var(_rpatternlist2,_rpatternlist3,_varlist),  % varlist == [ wh, qu ]
    (
     (foreach(_varValueList,_varlist,_rpatternlist3,_rlist1,_substitutedContent),!);
     (remove_initialed_values(_varlist),!,fail)
    ),
    _rlist1 = [')','}'|_rlist].
% Here for the case that initial_variable failed, i.e. forward loop finished!

foreach([[]|_rvarValueList],_varlist,_patternlist,_rpatternlist,_substitutedContent):-
    !.
%  initial_variable acts like a counter; when all values have been used once, Foreach is finished.

foreach(_varValueList,_varlist,_patternlist,_rpatternlist,_substitutedContent):-
    initial_variable(_varValueList,_varlist,_restvarValueList),
    expandInnerPattern(_varValueList,_varlist,_patternlist,_rpatternlist,_substitutedContent, _restvarValueList).
%  for the current loop, all variables are bound to NULL; just ignore this binding and proceed with next.
%  We have to call 'parseArgumentList' for this case to get the correct setting for _rpatternlist, i.e. the
%  remaining pattern to be processed subsequently. We don't use its outout however here!

expandInnerPattern(_varValueList,_varlist,_patternlist,_rpatternlist,_substitutedContent, _restvarValueList) :-
    allNULL(_varlist),
    createBuffer(_outputBuffer),
    !,
    parseArgumentList(_patternlist,_outputBuffer,_rpatternlist),  % we need to do this to instantiate _rpatternlist
    disposeBuffer(_outputBuffer),
    !,
    remove_initialed_values(_varlist),
    foreach(_restvarValueList,_varlist,_patternlist,_rpatternlist,_substitutedContent),
    !.
%  not all variable are bound to NULL: do normal expansion
%  this sets __rpatternlist anyway

expandInnerPattern(_varValueList,_varlist,_patternlist,_rpatternlist,_substitutedContent, _restvarValueList) :-
    createBuffer(_outputBuffer),
    !,
    parseArgumentList(_patternlist,_outputBuffer,_rpatternlist),
    getStringFromBuffer(_output,_outputBuffer),
    disposeBuffer(_outputBuffer),
    !,
    remove_initialed_values(_varlist),
    foreach(_restvarValueList,_varlist,_patternlist,_rpatternlist,_substitutedContent),
    appendBuffer(_substitutedContent,_output).
%  allNULL(_vars) is true when all variables in _vars are bound to [N,U,L,L]

allNULL([]) :- !.
allNULL([_var|_rest]) :-
    (pc_recorded(_var,'AnswerFormatVariable',['N','U','L','L']);
     pc_recorded(_var,'AnswerFormatVariable',['N','O','O','B','J','E','C','T'])),  % 1-Nov-2000/MJf: NOOBJECT indicates that no solution is found, CBNEWS[201]
    allNULL(_rest).

initial_variable(_varValueList,_varlist,_restvarValueList):-
    getfirstValue(_varValueList,_fvalues,_restvarValueList),
    recordValue(_fvalues,_varlist).
% get the firstvalue for each variable

getfirstValue([],[],[]):-!.
getfirstValue([_varValues|_rvarValueList],[_fvalue|_rfvalues],[_restValues|_restvarValueList]):-
    _varValues \== [],  % [] means there are no more values for the variable; fail => Foreach finished
    _varValues = [_fvalue|_restValues],
    getfirstValue(_rvarValueList,_rfvalues,_restvarValueList).
%  note: for simplicity, only unique variable definitions are allowed here.
%    variables are not connected to a domain!!!
%  that is, different variables in a pattern definition must also be designated differently.

recordValue([],_).
recordValue([_value|_rvalues],[_var|_rvar]):-
        pc_record(_var,'AnswerFormatVariable',_value),
        recordValue(_rvalues,_rvar).

recordParameters([]).
recordParameters([substitute(_val1,_name)|_r]) :-
    eval(_val1,replaceSelectExpression,_val),  % value of a parameter may be a select expression
    atom2list(_val,_vallist),
    pc_record(_name,'AnswerFormatVariable',_vallist),
    recordParameters(_r).

eraseParameters([]).
eraseParameters([substitute(_val,_name)|_r]) :-
    pc_erase(_name,'AnswerFormatVariable'),
    eraseParameters(_r).

eraseAnswerParameters(_key) :-
  pc_erase_all(key).

addAnswerParameters(_key,[]) :- !.
addAnswerParameters(_key,[_val/_param|_rest]) :-
  ((pc_recorded(_param,_key,_),pc_rerecord(_param,_key,_val));
   pc_record(_param,_key,_val)),
  addAnswerParameters(_key,_rest).

remove_initialed_values([]).
remove_initialed_values([_var|_rvarlist]):-
        pc_erase(_var,'AnswerFormatVariable'),
        remove_initialed_values(_rvarlist).

parsen_var_value(['('|_rlist],_rpatternlist,_varValueList):-
    !,
    parsen_var_value(_rlist,_rpatternlist,_varValueList).
parsen_var_value([')'|_rlist1],_rlist,[]):-
    !,
    _rlist1=[_|_rlist].  % comma should also be removed
parsen_var_value([','|_rlist],_rpatternlist,_varValueList):-
    !,
    parsen_var_value(_rlist,_rpatternlist,_varValueList).
parsen_var_value(['{'|_rlist],_rpatternlist,[_varValues|_rvarValueList]):-
    !,
    createBuffer(_varValuesBuffer),
    !,
    substituteBrackets(_rlist,_varValuesBuffer,_rpatternlist1),
    getPointerFromBuffer(_resultString,_varValuesBuffer),
    save_stringtoatom(_resultString,_varValues1),
    disposeBuffer(_varValuesBuffer),
    !,
    'TermToListOfStrings'(_varValues1,_varValues2),
    convertValuelist(_varValues2,_varValues),
    !,
    parsen_var_value(_rpatternlist1,_rpatternlist,_rvarValueList).

'TermToListOfStrings'([],[]):-!.
'TermToListOfStrings'(_term,_stringlist):-
    atom2list( _term, _atomlist ),
    atomListToStringList(_atomlist,_stringlist).

atomListToStringList([_a],[_a]).
atomListToStringList([_a|_b],[_h|_t]):-
    _b = [_c|_d],
    ( _c == '\001',_h = _a,atomListToStringList(_d,_t);
      pc_atomconcat(_a,_c,_atom),atomListToStringList([_atom|_d],[_h|_t])
    ).
% Here a list of Atom/Term is converted into a list of Charlist.
% [800]-->[[8,0,0]] and [800,1000]-->[[8,0,0],[1,0,0,0]]

convertValuelist([],[]):-!.
convertValuelist([_f|_r],[_el|_rest]):-
    'TermToCharList'(_f,_el),
    !,
    convertValuelist(_r,_rest).
%  note: here _varList is a list of atoms!!!

parsen_var(['('|_rlist],_rpatternlist,_varList):-
    !,
    parsen_var(_rlist,_rpatternlist,_varList).
parsen_var([')'|_rlist1],_rlist,[]):-
    !,
    _rlist1=[_|_rlist].
parsen_var(_patternlist,_rpatternlist,[_var|_rvarList]):-
    createBuffer(_vlistBuffer),
    !,
    parseArgumentList(_patternlist,_vlistBuffer,_rest),
    getPointerFromBuffer(_resultString,_vlistBuffer),
    save_stringtoatom(_resultString,_var),
    disposeBuffer(_vlistBuffer),
    !,
    parsen_var(_rest,_rpatternlist,_rvarList).
% ************************************************************************************************************************************
%  blanks before each functor and function argument are currently ignored in principle...
%  i.e. we can write [Functor( arg1, arg2,   arg3)]; this is equivalent to [Functor( arg1,arg2,arg3)]
%  for Foreach(x,y,z), however, blanks before the last argument are counted!!!

'Ignore_blank'([' '|_rlist],_restlist):-
    !,
    'Ignore_blank'(_rlist,_restlist).
'Ignore_blank'(_rlist,_rlist) :- !.
% ********************************************************************************************************************
%  if replace() delivers a list of atoms/terms, this list must be converted into a char list. TermListToCharList
%  converts a list of atoms/terms into a char list; note that commas must not be forgotten.
%  example: [100,200]==>[1,0,0,,,2,0,0]
% ********************************************************************************************************************

'TermListToCharList'([],[]).
'TermListToCharList'([_term|_rest],_charlist):-
    (
    ('TermToCharList'(_term,_clist1),_rest==[]);
    ('TermToCharList'(_term,_clist11),append(_clist11,[','],_clist1))
    ),
    'TermListToCharList'(_rest,_clist2),
    append(_clist1,_clist2,_charlist).
