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
% File:        %M%
% Version:     %I%
%
%
% Date released : %E%  (YY/MM/DD)
%
% SCCS-Source-Pool : %P%
% Date retrieved : %D% (YY/MM/DD)
%
% -----------------------------------------------------------------------------
%
% This Prolog module is part of the ConceptBase system which is a run-time
% system for the O-Telos language.
% The module GlobalParameters provides the a lot of global settings for
% ConceptBase
%
% Exported predicates:
% --------------------
%
% ... many
%
%

:- module('GlobalParameters',[
'CBdeveloper'/1
,'cb_copyright_time'/1
,'cb_date_of_release'/1
,'cb_location'/1
,'get_cb_feature'/2
,'set_cb_feature'/2
,'default_cb_feature'/2
,'cb_installation'/1
,'cb_version'/1
,'portnr'/1
,'cb_feature_longname'/2
,'featureValueName'/3
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
%  ... parameters describing the version of this release:

:- dynamic 'cb_date_of_release'/1 .
:- dynamic 'cb_location'/1 .
:- style_check(-singleton).
cb_version('8.1.17').

cb_date_of_release('2020-01-24').  % set via environment variable CB_DATE in startCBserver; see serverSources/Makefile
cb_location('Skovde').  % place where CBserver is compiled, updated in startCBserver
cb_copyright_time('Copyright 1987-2020').  % keep up to date!
:- dynamic 'cb_installation'/1 .

cb_installation(runtime).
%  ... list of all ConceptBase developers (alphabetically, please update!)
%  Criterion: CB team member for an extended period
% CBdeveloper('Masoud Asady           1994 ... 1995').   student of Hans; no code left in system

'CBdeveloper'('Lutz Bauer             1995 ... 1997').  % module subsystem
%  CBdeveloper('Markus Baumeister      1991 ... 1994'). no code left in system
%  CBdeveloper('Ulrich Bonn            1989 ... 1991').  no code left in system
%  CBdeveloper('Stefan Eherer          1989 ... 1994'). no code left in system

'CBdeveloper'('Rainer Gallersdoerfer  1989 ... 1997').
'CBdeveloper'('Michael Gebhardt       1992 ... 1997').  % design of Java graph editor; TCL interface
%  CBdeveloper('Dagmar Genenger        1992 ... 1992').  no code left in system
%  CBdeveloper('Michael Gocek          1987 ... 1991').  no code left in system

'CBdeveloper'('Rainer Hermanns        1997 ... 1998').
'CBdeveloper'('Matthias Jarke         1987 ... 2011').
'CBdeveloper'('Manfred A. Jeusfeld    1987 ...  now').
'CBdeveloper'('David Kensche          2004 ... 2008').  % libCos: record-db
%  CBdeveloper('Andre Klemann          1989 ... 1991'). Passau student; no code left

'CBdeveloper'('Eva Krueger            1987 ... 1990').  % integrity checker
'CBdeveloper'('Rainer Langohr         1997 ... 1999').  % CBiva
'CBdeveloper'('Farshad Lashgari       1994 ... 1995').  % ECA rules
'CBdeveloper'('Tobias Latzke          2001 ... 2002').  % CBiva
'CBdeveloper'('Xiang Li               2004 ... 2008').  % CBiva
'CBdeveloper'('Yong Li                2004 ... 2008').  % CBiva
'CBdeveloper'('Thomas List            1993 ... 2004').  % libCos and related
% CBdeveloper('Carlos Maltzahn        1988 ... 1991'). - no contribution

'CBdeveloper'('Andreas Miethsam       1989 ... 1991').  % TransactionTime
'CBdeveloper'('Hans W. Nissen         1987 ... 1998').
'CBdeveloper'('Martin Poeschmann      1997 ... 2001').  % libCos
'CBdeveloper'('Christoph Quix         1994 ... 2011').
'CBdeveloper'('Christoph Radig        1993 ... 1998').  % student of Martin S.: CBserver
% CBdeveloper('Thomas Rose            1987 ... 1990').- no contribution

'CBdeveloper'('Achim Schlosser        2002 ... 2004').  % CBiva
'CBdeveloper'('Tobias Schoeneberg     2001 ... 2004').  % CBiva
'CBdeveloper'('Rene Soiron            1992 ... 1997').  % query optimizer
'CBdeveloper'('Martin Staudt          1987 ... 1997').  % query component; CBserver
% CBdeveloper('Gerhard Steinke        1988 ... 1992'). - no contribution
% CBdeveloper('Ralf Stoessel          1996 ... 1996').  contributed to obsolete TCL interface
% CBdeveloper('Klaus Swoboda          1987 ... 1987'). - no contribution

'CBdeveloper'('Kai von Thadden        1992 ... 1995').  % student of Martin S.; CBserver
'CBdeveloper'('Hua Wang               1997 ... 1999').  % student of Christoph Q.; answer formats
%  CBdeveloper('Claudia Welter         1994 ... 1995').  no code left in system

'CBdeveloper'('Thomas Wenig           1988 ... 1989').  % SMLaxioms (UNTELL)
% CBdeveloper('Ji Zhang               2004 ... 2005').- no contribution to CB
% *************************************************************************
%
%  Default portnumber for Client-Connections
%
% *************************************************************************

:- dynamic 'portnr'/1 .

portnr(4001).
% *************************************************************************
%                                                      27-Feb-2002/MJf
%  Default cache mode uses in Literals.pro to manage the evaluation of
%  recursice predicates. Possibile settings are:
%    off: no cache to be used
%    transient: cache used but emptied before each transaction/update
%    keep: cache used until update to object base occurs or cache size
%          exceeds maxCacheSize
%
% *************************************************************************
% *************************************************************************
%
%  TraceMode controls the amount of additional information printed out
%  by ConceptBase. Possible settings are:
%      no:   (nearly) no tracing
%      minimal:  only interface calls
%      low:  only interface calls plus answers
%      high: intermediate steps of transformations
%      veryhigh: many-many-many lines of output
%
% *************************************************************************
% *************************************************************************
%
%  RangeFormOptimizing
%  Controls the SemanticOptimizer for rangeform formulas. Possible
%  settings:
%      0 = noopt: no semantic optimization
%      1 = structural: InstanceOf constraint 1 (see SMLaxioms) is compiled
%                  into BDM rules and constraints.
%      2 = order of Datalog rules is optimized
%      3 = order and structural optimization
%
% *************************************************************************
% *************************************************************************
%
%  securityLevel
%  Controls the way how ConceptBase applies its security policy.
%  Settings:
%      0 = no access control enabled, users can freely tell, ask, untell
%      1 = basic protection, updates only in current module
%      2 = normal access control by query CB_Permitted
%      3 = at most READ access permitted
%
% *************************************************************************
% *************************************************************************
%
%  stratificationTest
%  Controls the way how ConceptBase applies the stratification tests.
%  Settings:
%      on  = stratification tests enabled
%      off = disabled
%
% *************************************************************************
% *************************************************************************
%
%  forceConcernedClass
%  Controls whether any predicate occurrence A(x,m,y) in a query constraint
%  must be assignable to a unique concerned class.
%     strict = enforces strict interpretation of the rule
%     extended = searches also in subclasses
%     off = does not enforce the rule (like in old versions of CB)
%
% *************************************************************************
% *************************************************************************
%
%  ViewMaintenanceRules
%
%  Should View Maintenance rules be generated.
%  Moegliche values: on and off
% *************************************************************************
% *************************************************************************
%
%  UpdateMode
%  Controls the way interactive updates of the current KB are treated.
%  Possible settings:
%      nonpersistent:    updates will not be stored to files
%      persistent :      all facts, rules, Ic's, time relations resulting
%                        from TELL/UNTELL will be stored to files
%      unknown :         parameter is not yet set
%
% *************************************************************************
% *************************************************************************
%
%  UntellMode
%  Controls the way how UNTELL operates on Telos frames.
%  Possible settings:
%      verbatim :   only the propositions contained in the frame are
%                    untold.
%      cleanup :    if after an UNTELL only the object itself would remain
%                   then the object is untold as well. This shall realize
%                   some sort of symmetry to the TELL operation; see also
%                    ticket #98.
%
% *************************************************************************
% *************************************************************************
%
%  maximal number of calls of the predicate insert/3  from
%  SelectExpressions.pro. Limits the complexity of select expressions,
%  e.g.: Person!age!dependson has complexity 2.
%
% *************************************************************************
% *************************************************************************
%
%  maximal number of error messages reported to the user client after
%  a transaction; used in ErrorMessages.pro
%  Set to 0 to display no errors message at all.
%  Set to -1 to display all errors messages.
%  Set to a positive number to limit the number of errors messages.
%
% *************************************************************************
% *************************************************************************
%
%  adminUser specifies the admin user of the CBserver; default: the user
%  who started the CBserver.
%
% *************************************************************************
% *************************************************************************
%
%  maxCostLevel specifies the maximum cost that a predicate in a so-called
%  binding path for a meta predicate may have. Roughly speaking a predicate
%  with one free variable has cost-level 10, and with 2 free variables it
%  has cost level 100.
%
% *************************************************************************
% *************************************************************************
%
%  bindingPathLen specifies the maximum number of predicates in a binding
%  path for a meta predicate. Together with maxCostLevel, it limits the
%  search space of binding path candidates. Setting both parameters high
%  increases the chances for compilability of meta formulas, at the
%  expense of compilation time, and possibly storage space to store the
%  compiled meta formula. While theoretically all meta formulas can be
%  compiled, some compilations are just VERY expensive, i.e. require
%  exponential space in terms of the length of the binding path.
%
% *************************************************************************
% *************************************************************************
%
%  ecaControl controls the ECa sub-system. Possible values are
%   'off':  ECA  rules are not evaluated, even if some are defined),
%  'unsafe': ECA rules are evaluated without safeguarding
%           recursive deductive rules
%   'safe': ECA rules are evaluated with safeguarding recursive rules;
%           this mode is quite slow; this is default
%
% *************************************************************************
% *************************************************************************
%
%  ecaOptimize controls whether conditions of ECArules are optimized
%   'off':  no optimization
%   'on' :  optimization turned on
% *************************************************************************

get_cb_feature(_label,_value) :-
  cb_feature(_label,_value),
  !.
get_cb_feature(_label,_value) :- 
  \+ cb_feature(_label,_),  % _value may be a constant when called; thus, clause 1 of get_cb_feature
  default_cb_feature(_label,_value).  % may have failed even though cb_feature was defined.
:- dynamic 'cb_feature'/2 .

default_cb_feature(persistency,enabled).  % values: enabled,disabled
default_cb_feature(multiuser,enabled).  % values: enabled,disabled
default_cb_feature('UpdateMode',unknown).  % values: persistent,nonpersistent,unknown
default_cb_feature('UntellMode',cleanup).  % values: verbatim,cleanup
default_cb_feature(securityLevel,'1').  % values: 0,1,2,...
default_cb_feature('TraceMode',no).  % values: silent,no,minimal,low,high,veryhigh
default_cb_feature(defaultCacheMode,keep).  % values: off,transient,keep
default_cb_feature('ViewMaintenanceRules',off).  % values: off,on
default_cb_feature('RangeFormOptimizing','4').  % values: 0,1,2,3,4
default_cb_feature(forceConcernedClass,strict).  % values: off,strict,extended
default_cb_feature(adminUser,'').  % values: atom
default_cb_feature(maximalErrors,20).  % values: -1,0,1,2,...; -1 means 'infinite'
default_cb_feature(maximalDepth,50).  % values: 100,... ; for length of select expressions like x!n!m
default_cb_feature(maxCacheSize,20000).  % values: 1000,...
%  we empty the cache when we have more than this number of facts in the cache

default_cb_feature(ecaDefaultMode,immediate).  % values: immediate,immediatedeferred,deferred
%  see also ECAruleCompiler.pro

default_cb_feature(optimisticCostLevel,10).  % values: 1,2,...
default_cb_feature(maxCostLevel,150).  % values: 1,2,...
default_cb_feature(bindingPathLen,5).  % values: 1,2,...
default_cb_feature(iterMax,3).  % values: 1,2,...
default_cb_feature(ecaControl,safe).  % values: off,safe,unsafe
default_cb_feature(ecaOptimize,on).  % values: on,off
default_cb_feature(readableFormulaLabel,on).  % values: on,off
default_cb_feature(exportDir,'none').  % values: directory path to which to export module sources; 'none' disables export
default_cb_feature(importDir,'none').  % values: directory path from which to import module sources; 'none' disables import
default_cb_feature(viewDir,'none').  % values: directory path from which to save views; 'none' disables view save
default_cb_feature(servermode,'master').  % values: master,slave
default_cb_feature(repeatLoop,'off').  % values: 'off'=no repeat loop, else value of -r parameter
default_cb_feature(moduleSeparator,'-').  % values: '-' or '/'
default_cb_feature(inactivityInterval,2.0).  % time in hours that characterize an inactive client
default_cb_feature(moduleGeneration,'split').  % values 'whole'=one module source per module,
                                                %         'split' = separator per transaction (default)

default_cb_feature(stratificationTest,'on').  % values: on or off
default_cb_feature(sortLimit,5000).  % lists with more than this number of elements are not sorted in AnswerTransform
%  Only features with a 'long name' are displayed in the terminal window of the CBserver

cb_feature_longname('TraceMode','Trace mode').
cb_feature_longname('RangeFormOptimizing','Optimization of rules & constraints').
cb_feature_longname('ViewMaintenanceRules','View maintenance rule generation').
cb_feature_longname(defaultCacheMode,'Cache mode').
cb_feature_longname(securityLevel,'Security level').
cb_feature_longname(forceConcernedClass,'Predicate typing').
cb_feature_longname('UpdateMode','Update mode').
cb_feature_longname('UntellMode','Untell mode').
cb_feature_longname(multiuser,'Multiuser mode').
cb_feature_longname(maximalErrors,'Maximal error reports per transaction').
cb_feature_longname(maxCostLevel,'Maximum cost level for meta formulas').
cb_feature_longname(optimisticCostLevel,'Optimistic cost level for meta formulas').
cb_feature_longname(bindingPathLen,'Maximum length of a binding path').
cb_feature_longname(ecaControl,'Control of ECArules').
cb_feature_longname(ecaOptimize,'Opimization of ECArule conditions').
cb_feature_longname(exportDir,'Directory for saving module sources').
cb_feature_longname(importDir,'Directory for loading module sources').
cb_feature_longname(viewDir,'Directory for saving views').
cb_feature_longname(iterMax,'Number of predicate re-order iterations').
cb_feature_longname(servermode,'Server mode').
cb_feature_longname(adminUser,'Administrator user').
cb_feature_longname(repeatLoop,'Restart on error or last client exit').
cb_feature_longname(moduleSeparator,'Module separator').
cb_feature_longname(moduleGeneration,'Module source generation').
cb_feature_longname(stratificationTest,'Rule stratification test').

set_cb_feature(_feature,_value) :-
  cb_feature(_feature,_value),  % already set, nothing to do
  !.
set_cb_feature(_feature,_value) :-
  cb_feature(_feature,_othervalue),
  _othervalue \= value,  % set to another value
  retract(cb_feature(_feature,_othervalue)),
  assert(cb_feature(_feature,_value)),
  !.
%  else (value not yet set), then set it

set_cb_feature(_feature,_value) :-
  assert(cb_feature(_feature,_value)).

featureValueName(securityLevel,'0','modules unprotected').
featureValueName(securityLevel,'1','System module protected').
featureValueName(securityLevel,'2','modules protected').
featureValueName(repeatLoop,_val,'in sec') :-
  _val \='off'.
