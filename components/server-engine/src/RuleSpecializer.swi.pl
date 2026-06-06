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
%
%
% File :       RuleSpecializer.pro
% Version :    1.2
% Creation:    July-24-1990 Martin Staudt (UPA)
% Last change: 8/13/90 Martin Staudt (UPA)
% Release :    1
%
%
% This file contains predicates for specializing DATALOG(neg) rules
% with respect to the binding of arguments
%
%
%
% ----------------------------------------------------------------------------
%
% Exported predicates:
% ---------------------
%
%   + specialize_rule/2
%   + specialize_rule/3
%
%
%

:- module('RuleSpecializer',[
'specialize_goal'/4
,'specialize_rule'/2
,'specialize_rule'/3
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- style_check(-singleton).
%  ******************* s p e c i a l i z e _ r u l e/2/3 ********************
%
% 	Implementation of an algorithm generating RULE ADORNMENTS i.e.
% 	rule specializations concerning bound/unbound arguments of input
% 	rule heads. The implementation follows
% 	Ullman, J.D., Principles of Database and Knowledge base systems,
% 	12.8. Rule Adornments, p.795 f.
%
%  **************************************************************************
%  ******************* s p e c i a l i z e _ r u l e / 2 ********************
%
% 	specialize_rule ( _rule, _specialized_rules )
% 			_rule : ground
% 			_specialized_rules : free
%
% 	specialize rule _rule with all possible instantiation patterns for
% 	the rule head. _specialized_rules is a list of the specialization
% 	results. The instantiation pattern for each goal of the specialized
% 	rules is concatenated with the goal name e.g. goal 'hallo' and
% 	instantiation pattern 'bbffb' leads to 'hallo_bbffb'.
%
% 	Rule _rule is assumed to have the format of a usual PROLOG rule
% 	        _head :- _body
% 	where _body is a conjunction of goals e.g.
% 	_body = (_goal1,(_goal2,(_goal3,_.......)
% 	The variables in _rule must be atoms (!) preceded by underscore e.g.
% 	variable '_hallo'. _rule must be a ground PROLOG term (!).
%
%  **************************************************************************

specialize_rule((_head :- _body),_) :-
	instantiation_pattern(_head,_patternlist),
	specialize_rule_head(_head,_patternlist,_newhead),
	specialize_rule_body(_body,_patternlist,_newbody),
	assert(sr((_newhead :- _newbody))),
	fail.
specialize_rule(_,_result) :-
	setof(_r,sr(_r),_result),
	retractall(sr(_)),
	!.
%  ******************* s p e c i a l i z e _ r u l e / 3 ********************
%
% 	specialize_rule ( _pattern,_rule, _specialized_rule )
% 			_pattern : ground
% 		 	_rule : ground
% 			_specialized_rule : free
%
% 	same as above but only one specialized rule is generated which
% 	belongs to the special instantiation patterm _pattern.
% 	_pattern must be an atom consisting only of 'b's and 'f's and
% 	must represent a correct pattern for the head of _rule.
%
%  **************************************************************************

specialize_rule(_pattern,(_head :- _body),(_newhead :- _newbody)) :-
	check_pattern(_head,_pattern,_patternlist),
	specialize_rule_head(_head,_patternlist,_newhead),
	specialize_rule_body(_body,_patternlist,_newbody),!.
%  ===================
%  Private predicates
%  ===================
%  *************** i n s t a n t i a t i o n _ p a t t e r n ****************
%
% 	instantiation_pattern ( _goal , _pattern )
% 			_goal : ground
% 			_pattern : free
%
% 	generates any possible instantiation pattern for goal _goal.
% 	_pattern as result consists of a list of tuples p(_arg,_stat) for
% 	each argument _arg in _goal where _stat is 'b' (bound) or 'f' (free)
% 	predicate backtracks.
%
%  **************************************************************************

instantiation_pattern(_t,_argPatternList) :-
	_t =.. [_f|_args],
	gen_pattern(_args,[],_argPatternList).

gen_pattern([],_l,_l).
gen_pattern([_f|_r],_l,_nl) :-
	occurs_in(p(_f,_p),_l),
	append(_l,[p(_f,_p)],_l2),
	gen_pattern(_r,_l2,_nl).
gen_pattern([_f|_r],_l,_nl) :-
	not_occurs_in(p(_f,_),_l),
	pattern(_p),
	append(_l,[p(_f,_p)],_l2),
	gen_pattern(_r,_l2,_nl).
%  ********************** c h e c k _ p a t t e r n *************************
%
% 	check_pattern ( _goal , _pattern , _patternlist )
% 			_goal : ground
% 			_pattern : ground : atom
% 			_patternlist : free
%
% 	checks wether _pattern as atom (consisting of f's and b's)
% 	represents a correct instantiation pattern for goal _goals and
% 	generates corresponding pattern list (consisting of tuples p(_a,_s)
% 	for each argument _a and status _s (b or f)).
%
%  **************************************************************************

check_pattern(_head,_pattern,_patternlist) :-
	pc_atomtolist(_pattern,_lpattern),
	_head =..[_|_args],
	build_pattern_list(_args,_lpattern,_patternlist),
	instantiation_pattern(_head,_patternlist).

build_pattern_list([],[],[]).
build_pattern_list([_arg|_rargs],[_p|_rp],[p(_arg,_p)|_rest]) :-
	build_pattern_list(_rargs,_rp,_rest).
%  *************** s p e c i a l i z e _ r u l e _ h e a d ******************
%
% 	specialize_rule_head ( _goal , _patternlist , _specializedgoal )
% 				_goal : ground
% 				_patternlist : ground
% 				_specializedgoal : free
%
% 	_specializedgoal is specialized form of _goal according to
% 	pattern list _patternlist.
%
%  **************************************************************************

specialize_rule_head(_l,_pl,_nl) :-
	specialize_literal(_l,_pl,_nl).
%  ****************** s p e c i a l i z e _ r u l e _ b o d y ***************
%
% 	specialize_rule_body ( _goals , _patternlist, _specializedgoals )
% 				_goals : ground
% 				_patternlist : ground
% 				_specializedgoals : free
%
% 	_specializedgoals is conjunction of specialized goals generated
% 	from conjunction _goals according pattern list _patternlist.
%
%  **************************************************************************

specialize_rule_body(_body,_patternlist,_nbody) :-
	specialize_body(_body,_patternlist,_nbody).

specialize_body((_l,_r),_patternlist,(_nl,_nr)) :-
	specialize_goal(_l,_patternlist,_nl,_npatternlist),
	specialize_body(_r,_npatternlist,_nr).
specialize_body(_l,_patternlist,_nl) :-
	_l \= (_,_),
	specialize_goal(_l,_patternlist,_nl,_).
%  ********************** s p e c i a l i z e _ g o a l *********************
%
% 	specialize_goal ( _goal, _patternlist, _ngoal, _npatternlist )
% 			_goal : ground
% 			_patternlist : ground
% 			_ngoal : free
% 			_npatternlist : free
%
% 	goal _goal is specialized to _ngoal. _patternlist contains 'known'
% 	arguments with binding status 'b' or 'f'  The new arguments occuring
% 	in _goal are inserted in this list with binding status 'b'.
% 	Arguments in _goal which have binding status 'f' in _patternlist
% 	get new status 'b'. _npatternlist is modified _patternlist.
%
%  **************************************************************************

specialize_goal(_l,_plist,_nl,_nplist) :-
	_l \= (not(_)),
	_l =.. [_f|_args],
	gen_goal_pattern(_args,_plist,_pattern,_nplist),
	specialize_literal(_l,_pattern,_nl).
specialize_goal(not(_l),_plist,not(_nl),_nplist) :-
	_l =.. [_f|_args],
	gen_goal_pattern(_args,_plist,_pattern,_nplist),
	specialize_literal(_l,_pattern,_nl).
%  ********************* g e n _ g o a l _ p a t t e r n ********************
%
% 	gen_goal_pattern ( _args, _patternlist, _pattern, _npatternlist )
% 			_args : ground
% 			_patternlist : ground
% 			_pattern : free
% 			_npatternlist : free
%
% 	arguments in _args are checked wether they are variables (i.e. pre-
% 	ceded by underscore) or constants. If an argument _a is a variable
% 	which occurs in _patternlist with binding status 'b' a tuple p(_a,b)
% 	is inserted in list _pattern. If an argument _a is a variable which
% 	occurs in _patternlist with binding status 'f' a tuple p(_a,f)
% 	is inserted in list _pattern and binding status of _a in _patternlist
% 	is changed to 'b' ( in _npatternlist) because this variable is now
% 	(!) bound.
% 	If an argument _a is a variable not occuring in _patternlist it is
% 	inserted as p(_a,f) in _pattern and as p(_a,b) in _npatternlist.
% 	As a result _pattern contains the arguments in _args with binding
% 	status and _npatternlist all elements of _patternlist possibly with
% 	changed binding status and 'new' (variable) arguments in _args.
%
%  **************************************************************************

gen_goal_pattern([],_plist,[],_plist).
gen_goal_pattern(['_'|_r],_plist,[p('_',f)|_pattern],_nplist) :-
	!,
	gen_goal_pattern(_r,_plist,_pattern,_nplist).
gen_goal_pattern([_f|_r],_plist,[p(_f,f)|_pattern],_nplist) :-
	variable(_f),
	occurs_in(p(_f,_p),_plist),
	_p == f,
	gen_goal_pattern(_r,_plist,_pattern,_plist2),
	update_pattern_list(_plist2,_nplist,p(_f,b)).
gen_goal_pattern([_f|_r],_plist,[p(_f,b)|_pattern],_nplist) :-
	variable(_f),
	occurs_in(p(_f,_p),_plist),
	_p == b,
	gen_goal_pattern(_r,_plist,_pattern,_nplist).
gen_goal_pattern([_f|_r],_plist,[p(_f,f)|_pattern],[p(_f,b)|_nplist]) :-
	variable(_f),
	not_occurs_in(p(_f,_),_plist),
	gen_goal_pattern(_r,_plist,_pattern,_nplist).
gen_goal_pattern([_f|_r],_plist,[p(_f,b)|_pattern],_nplist) :-
	constant(_f),
	gen_goal_pattern(_r,_plist,_pattern,_nplist).

update_pattern_list([],[],_).
update_pattern_list([p(_f,_)|_r],[p(_f,_p)|_nr],p(_f,_p)) :-
	update_pattern_list(_r,_nr,p(_f,_p)).
update_pattern_list([p(_f,_p1)|_r],[p(_f,_p1)|_nr],p(_g,_p)) :-
	_g \== _f,
	update_pattern_list(_r,_nr,p(_g,_p)).
%  ****************** s p e c i a l i z e _ l i t e r a l *******************
%
% 	specialize_literal ( _goal, _patternlist, _newgoal )
% 			_goal : ground
% 			_patternlist : ground
% 			_newgoal : free
%
% 	_goal is specialized to _newgoal according to pattern specification
% 	in _patternlist. The instantiation pattern is concatenated with the
% 	goals functor separated by an underscore.
%
%  **************************************************************************

specialize_literal(_head,_patternlist,_newhead) :-
	_head =.. [_functor|_args],
	specialization_suffix(_patternlist,_suffix1),
	pc_atomconcat('_',_suffix1,_suffix),
	pc_atomconcat(_functor,_suffix,_nfunctor),
	_newhead =.. [_nfunctor|_args].

specialization_suffix([],'').
specialization_suffix([p(_,_p)|_r],_s) :-
	specialization_suffix(_r,_s1),
	pc_atomconcat(_p,_s1,_s).
%  **************************** p a t t e r n *******************************
%
% 	pattern ( _p )
% 		_p : free
%
% 	_p is instantiation pattern for one argument: 'b' or 'f'
%
%  **************************************************************************

pattern(b).
pattern(f).
%  *********************** v a r i a b l e / c o n s t a n t ***************
%
% 	variable ( _x )
% 		_x : ground
% 	succeeds is _x is an atom preceded by '_'.
%
% 	constant( _x )
% 		_x : ground
% 	succeeds is _x is not (!) an atom preceded by '_'.
%
%  *************************************************************************
%  already defined in GeneralUtilities
%
% variable(_x) :-
% 	atom(_x),
% 	pc_atomconcat('_',_,_x).
%

constant(_x) :-
	not(variable(_x)).

occurs_in(p(_f,_p),_l) :-
	member(p(_f,_p),_l).

not_occurs_in(p(_f,_p),[]).
not_occurs_in(p(_f,_),[p(_f1,_)|_r]) :-
	_f \== _f1,
	not_occurs_in(p(_f,_),_r).
