/**
The ConceptBase.cc Copyright

Derived from ConceptBase.cc, originally created by the ConceptBase Team under a FreeBSD-style license.

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
*
* File:         startCBserver.pro
* Version:      12.7
*
*
* Date released    : 99/01/28  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/SCCS/serverSources/Prolog_Files/s.startCBserver.pro
* Date retrieved   : 99/02/05 (YY/MM/DD)
-----------------------------------------------------------------------------
*
* This Prolog module is part of the ConceptBase system which is a run-time
* system for the System Modelling Language (SML).
* This module loads all modules of the ConceptBase kernel.
*
* 17.07.92 RG multiple changes so that the server can run in the lokal directory
*        CBstate no longer from a file (now the seconds since 00:00:00 GMT,
*           Jan.  1,  1970)
*
* 30-Nov-1992/MJf: Modules of the time calculus are no longer loaded (CBNEWS[147])
* 16-Feb-1993/kvt: only portnumbers between 2000 and 65535 are allowed (the interface checks this)
*
* 10-1-96 (RS)
* Metaformel Module und AToAdot werden geladen
*
* 12-Dez-1996/LWEB:   Die Module Rep_fast, Rep_temp, Rep_h und PropositionBase
*      werden nicht mehr geladen. (Funktionalitaet ist jetzt im PropositionProcessor enthalten)
*    ECA-Module ECA* werden geladen.
*
*/




:- module('startCBserver',[
'reportOptionErrorAndStop'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


/* 'Spezielle' 'Fehlerbehandlung' fuer 'SWI', da ansonsten bei 'Syntax'-'Fehlern' im 'Prolog'-'Code' die
   'Kompilierung' nicht abgebrochen wird. 'Wenn' ein 'Syntax'-'Error' im 'Prolog'-'Code' auftritt,
   wird message_hook aufgerufen. 'Dann' muessen wir uns merken, das der 'Fehler' aufgetreten ist.
   'Weiter' unten (nach ?- loadCBkernel) wird dann der ueberprueft, ob ein 'Fehler' aufgetreten ist.
   'Wenn' ja dann exit mit 'Status' 1. */
:- dynamic cb_compile_error/1 .
/* do not output singleton warnings (see also http://gollem.science.uva.nl/'SWI'-'Prolog'/'Manual'/syntax.html */
:- style_check(-singleton).
?- user:assert((message_hook(_a,error,_c) :-
        write('CB error compile'),nl,
        write(_a),nl,
	write(_c),nl,
        message_to_string(_a,_s),
        string_to_atom(_s,_sa),
        write('\033[31m '),
        write('***** ERROR:'),
        write(_sa),
        assert(startCBserver:cb_compile_error(yes)),
        write('\033[30m '),nl,nl)).

/* preload some 'packs' from 'SWI'-'Prolog' 6.6 onwards 
?- current_prolog_flag(version,_v),_v >= 60600, use_module(library(clpfd)). 
*/



:- use_module('GeneralUtilities.swi.pl').
:- use_module('ExternalCodeLoader.swi.pl').
:- use_module('IpcChannel.swi.pl').
:- use_module('CBserverInterface.swi.pl').





:- use_module('ModelConfiguration.swi.pl').


:- use_module('GlobalParameters.swi.pl').




:- use_module('CBprofiler.swi.pl').

:- use_module('PrologCompatibility.swi.pl').










:- use_module('Literals.swi.pl').









:- use_module('AnswerTransform.swi.pl').
:- use_module('ConfigurationUtilities.swi.pl').




:- use_module('stopCBserver.swi.pl').


:- use_module('TellAndAsk.swi.pl').




:- style_check(-singleton).




:- dynamic 'dataBase'/1 .
dataBase('<none>').


/***************  S t a r t C B s e r v e r  *****************/
/**                                                         **/
/** This predicate starts up the ConceptBase kernel. First  **/
/** of all it consults some global parameters, then it      **/
/** loads all files for the ConceptBase system. Afterwards  **/
/** some preparing tasks are performed.                     **/
/**                                                         **/
/*************************************************************/


startCBserver :-
    warnings_off,

    set_prolog_flag(float_format, '%.12g'),  /** see ticket #178 **/
    require([swritef/3]),autoload,

    setDefaultPortnumber,!,
    setOptions,
    'WriteListOnTrace'(minimal,['>>> Upstarting new ConceptBase.cc server ... ']),
    loadWinSock,
    loadSessionCounter,
    initializeCBstate,
    setUserName,
    loadDB,
    enroll,
    loadModuleTree(_compl),
    precompute_DEDUCABLE,   /** initialize some pre-computed facts for Literals.pro **/
    tellDelayedFrames,      /** from LPI files; see PROLOGruleProcessor.pro         **/
    checkCorrectIDs,   /** ticket #195 **/
    startServerOrExit.


startServerOrExit :-
    getFlag(devOption,'exit'),   /** user has requested to stop the CBserver directly after startup **/
    copyright_notice,
    getoutofConceptBase,
    !.

startServerOrExit :-
    getFlag(devOption,'public'),   /** user has requested to start a 'public' CBserver **/
    set_cb_feature(servermode,'slave'),
    tellAutoHome,
    copyright_notice,
    !,
    'IpcChannel_startup'.


startServerOrExit :-
    copyright_notice,
    'IpcChannel_startup'.


/** make oHome an AutoHomeModule **/
tellAutoHome :-
    pc_stringtoatom(_frame,'oHome in AutoHomeModule end'),
    enactModuleContext('oHome',_compl1),
    'TELL'(_frame,_compl2),
    checkCompletion(_compl1,_compl2),
    !.
tellAutoHome.

checkCompletion(ok,noerror) :- !.

checkCompletion(_,_) :-
    write('### oHome could not be configured as AutoHomeModule!'),nl,nl,
    !.


loadDB :-
  dataBase(_db),
  check_nonpersistentDefault(_db),  /** set UpdateMode default depending on _db parameter **/
  check_nonpersistent(_db,_realDB),
  createViewDir(_db,_realDB),
  my_update(dataBase(_realDB)),
  _realDB \= '<none>',
  load_application(_realDB),
  addAnswerParameters('PersistentAnswerParameter', [_db/database]),
  !.

loadDB :-
    reportOptionErrorAndStop(['Specify a database (parameter -d <db>) or start CBserver with parameter -u nonpersistent']).


/***************** loadSessionCounter ************************/
/**                                                         **/
/** loadSessionCounter reads and updates session id which   **/
/** is used as part of oids generated during the session    **/
/**                                                         **/
/*************************************************************/

loadSessionCounter :-
    sec_time(_sec),
    /* check whether _sec is lower than 0 (which should never occur,
      but it causes serious damage) and fix it if necessary. */
    ((_sec < 0, _nsec is _sec * (-1));
     _nsec = _sec),
     setFlag('Session_counter',_nsec),
     !.


/****************** l o a d C B k e r n e l  *****************/
/**                                                         **/
/** The predicate 'loadCBkernel' consults all modules       **/
/** belonging to the ConceptBase run time system.           **/
/**                                                         **/
/*************************************************************/


loadCBkernel :-

    set_prolog_flag(allow_variable_name_as_functor,true),
    set_prolog_flag(autoload,true),  /** needed for SWI-Prolog 6.x **/
    set_prolog_flag(verbose_autoload,true),
    set_prolog_flag(verbose_load,true),
    set_prolog_flag(trace_gc,true),

    my_expand_path('$CB_POOL/$CB_VARIANT',_cbpool),
    atom_concat(_cbpool,'/serverSources/Prolog_Files/',_cbprologdir),

/** Starting ConceptBase Server **/
    'CBconsult'(['Prolog_Files/',_cbprologdir],[
    (_profile,'CBprofiler'),
    (_profile,'GlobalParameters'),
    (_profile,'GlobalPredicates'),
    (_profile,'SystemBuiltin'),  /** ticket #256 **/
    (_profile,'PrologCompatibility'),

    (_profile,'ExternalCodeLoader'),

    (_profile,stopCBserver),
    (_profile,cbserver),

/** Loading Object Processor **/
    (_profile,'ObjectProcessor'),
    (_profile,'ObjectTransformer'),
    (_profile,'FragmentToPropositions'),
    (_profile,'ViewToPropositions'),
    (_profile,'VMruleGenerator'),
    (_profile,'ViewMonitor'),
    (_profile,'PropositionsToLiterals'),
    (_profile,'ViewEvaluator'),
/*    (_profile,ViewCodeGenerator), */
    (_profile,'ClientNotification'),
    (_profile,'PropositionsToFragment'),
    (_profile,'Literals'),
    (_profile,'PROLOGruleProcessor'),
    (_profile,'AssertionCompiler'),

/** Loading Assertion Transformer **/
    (_profile,'AssertionTransformer'),
    (_profile,'MSFOLpreProcessor'),
    (_profile,'MSFOLassertionParser'),
    (_profile,'MSFOLassertionSimplifier'),
    (_profile,'MSFOLassertionTransformer'),
    (_profile,'VarTabHandling'),
    (_profile,'MSFOLassertionUtilities'),
    (_profile,'MSFOLassertionParserUtilities'),
    (_profile,parseAss_dcg),
    (_profile,'AToAdot'),

/** Loading MetaFormulaHandler **/
    (_profile,'MetaSimplifier'),
    (_profile,'MetaFormulas'),
    (_profile,'MetaRFormulas'),
    (_profile,'MetaBindingPath'),
    (_profile,'MetaLiterals'),
    (_profile,'MetaUtilities'),
    (_profile,'MetaRFormToAssText'),
    (_profile,'MetaTriggerGen'),
    (_profile,'MetaBDMEvaluation'),
    (_profile,'RangeformSimplifier'),



/** Loading Proposition Processor **/
    (_profile,'PropositionProcessor'),
    (_profile,validProposition),
    (_profile,'SearchSpace'),

/** Loading Integrity Processor **/
    (_profile,'BDMIntegrityChecker'),
    (_profile,'BDMCompile'),
    (_profile,'BDMForget'),
    (_profile,'BDMEvaluation'),
    (_profile,'BDMKBMS'),
    (_profile,'BDMTransFormula'),
    (_profile,'BDMLiteralDeps'),
    (_profile,'SMLaxioms'),
    (_profile,'SemanticOptimizer'),
    (_profile,'SemanticIntegrity'),

/** Loading Query Processor **/
    (_profile,'QueryProcessor'),
    (_profile,'QueryEvaluator'),
    (_profile,'QueryCompiler'),
    (_profile,'SubQueryCompiler'),
    (_profile,'ViewCompiler'),
    (_profile,'QueryCompilerUtilities'),
    (_profile,'RuleOptimizer'),
    (_profile,'RuleSpecializer'),
    (_profile,cfixpoint),
    (_profile,'AnswerTransformator'),
    (_profile,'AnswerTransform'),
    (_profile,'AnswerTransformUtilities'),
    (_profile,'ExternalConnection'),
    (_profile,'QAmanager'),
    (_profile,'Datalog2Algebra'),

/** Loading Query Optimizer **/
       (_profile,'QO_costs'),
       (_profile,'QO_heaps'),
       (_profile,'QO_literals'),
       (_profile,'QO_preproc'),
       (_profile,'QO_profile'),
       (_profile,'QO_search'),
       (_profile,'QO_utils'),
       (_profile,'QO_vartab'),
       (_profile,'QO_heur'),
       (_profile,'QO_optimize'),
       (_profile,'QO_costBase'),
       (_profile,'RuleBase'),

/** Loading Deduction Processor **/
    (_profile,'LTcompiler'),
    (_profile,'LTstubs'),

/** Loading Modules that handle Code for evaluators **/
    (_profile,'CodeCompiler'),
    (_profile,'CodeStorage'),

/** Loading History Component (previously Time Calculus) **/
    (_profile,'Calendar'),
    (_profile,'FragmentToHistoryPropositions'),
    (_profile,'TransactionTime'),

/** Loading SML Language Facilities **/
    (_profile,tokens_dcg),
    (_profile,'LanguageInterface'),
    (_profile,'SelectExpressions'),
    (_profile,'ScanFormatUtilities'),

/** Loading Model Configuration **/
    (_profile,'ModelConfiguration'),
    (_profile,'ConfigurationUtilities'),
    (_profile,'WeakPersistency'),

/** Loading  Unix-Interface **/
    (_profile,prologToUnixSUN4),

/** Loading Utilities **/
    (_profile,'GeneralUtilities'),
    (_profile,'ErrorMessages'),

/** Loading IPC - Interface **/
    (_profile,'IpcParser'),
    (_profile,'BimIpc'),
    (_profile,'IpcChannel'),
    (_profile,'CBserverInterface'),
        (_profile,'TellAndAsk'),
/** Loading extern C-database **/
              (_profile,'BIM2C'),


/*the eca rule files */
    (_profile,'ECAruleManager'),
    (_profile,'ECAruleCompiler'),
    (_profile,'ECAqueryEvaluator'),
    (_profile,'ECAactionManager'),
    (_profile,'ECAutilities'),
    (_profile,'ECAruleProcessor'),
    (_profile,'ECAeventManager'),
    (_profile,debug)
    ]),
/*** end of CBconsult ***/

     list_undefined,  /** to see what is missing *)
     autoload,
#ENDIF(SWI)
    { Store the date of the link time */
    ((getenv('CB_DATE',_date),
      my_update(cb_date_of_release(_date)),
      getenv('CB_LOCATION',_loc),
      my_update(cb_location(_loc))
     );
     true
    ),
    !.

/******************** setDefaultPortnumber *******************/
/**                                                         **/
/** If the environment variable $CB_PORTNR is set use it as **/
/** the default portnumber                                  **/
/**                                                         **/
/*************************************************************/

setDefaultPortnumber :-
    getenv('CB_PORTNR',_port),
    !,
    setOption('-p',_port).

setDefaultPortnumber.


/********************** S e t O p t i o n s ******************/
/**                                                         **/
/** performs setting of options given as command line       **/
/** parameters by the user when starting CBserver           **/
/**                                                         **/
/*************************************************************/


setOptions :-

        set_prolog_flag(allow_variable_name_as_functor,true),
        set_prolog_flag(autoload,false),
        set_prolog_flag(verbose_autoload,true),
        set_prolog_flag(verbose_load,true),
        set_prolog_flag(trace_gc,false),
        set_prolog_flag(generate_debug_info,false),   /** runtime version: no debug menu on fatal errors **/
        current_prolog_flag(argv,[_prog|_args]),
        length(_args,_x),
        setSlaveModeIfNoArg(_x),
        assert_argv(_args,_y),!,
        setOption(_y).

:- dynamic argv/2 .

assert_argv(_l,-1) :-
    my_member('-version',_l),
    set_cb_feature('TraceMode','no'),
    !.

assert_argv(_l,-2) :-
    my_member('-help',_l),
    !.

assert_argv(_l,-3) :-
    my_member('-license',_l),
    !.


assert_argv(_l,-4) :-
    my_member('-team',_l),
    !.

assert_argv(_l,_x) :-
    my_member('--',_l),
    !,
    skipArgs(_l,_l2),
    assert_argv2(_l2,0,_x).

assert_argv(_l,_x) :-
    assert_argv2(_l,0,_x).

assert_argv2([],_x,_x).
assert_argv2([_h|_t],_n,_x) :-
    _n1 is _n + 1,
    assert(argv(_n1,_h)),
    assert_argv2(_t,_n1,_x).

skipArgs(['--'|_r],_r) :- !.
skipArgs([_|_r],_nr) :-
    skipArgs(_r,_nr).


setSlaveModeIfNoArg(0) :-
    set_cb_feature(servermode,slave),
    set_cb_feature('TraceMode',no),
    setTraceGarbadgeCollection(no),
    set_cb_feature(multiuser,disabled),
    !.
setSlaveModeIfNoArg(_).
       







setOption(-1) :-
  writeConceptBaseVersionMessage,
  !,
  fail.


setOption(-2) :-
  writeHelpMessage,
  !,
  fail.

setOption(-3) :-
  writeLicense,
  !,
  fail.

setOption(-4) :-
write('ConceptBase developers:'),nl,
  listCBdevelopers,
  !,
  fail.

setOption(0) :- ! .

setOption(1) :- write('unable to read command line parameters'),nl,nl,
    writeHelpMessage,
    !,fail.

setOption(_n) :-
        _n1 is _n - 1,
        _nn is _n1 - 1,
        argv(_n,_narg),
        argv(_n1,_n1arg),
        setOption(_nn),  /** to make sure that the arguments are processed in the original order 1,2,3... **/
        setOption(_n1arg,_narg).



setOption(_optId,_parameter) :-

    /** hole Spezifikation der Option und setze _parameter ein **/
    'Option'(_optId,_parameter,_method,_condition,_errormessage),

    /** wenn der Parameter korrekt ist, update die Option, ansonsten gebe eine Fehlermeldung aus und wuerge den Server ab
    **/
    ((call(_condition),
      !,
      call(_method))
    ;
      reportOptionErrorAndStop(_errormessage)
    ).

writeLicense :-
nl,
write('The ConceptBase.cc Copyright'),nl,
nl,
write('Copyright 1987-2025 The ConceptBase Team. All rights reserved.'),nl,
nl,
write('Redistribution and use in source and binary forms, with or without modification, are permitted'),nl,
write('provided that the following conditions are met:'),nl,
nl,
write('   1. Redistributions of source code must retain the above copyright notice, this list of'),nl,
write('      conditions and the following disclaimer.'),nl,
write('   2. Redistributions in binary form must reproduce the above copyright notice, this list of'),nl,
write('      conditions and the following disclaimer in the documentation and/or other materials'),nl,
write('      provided with the distribution.'),nl,
nl,
write('THIS SOFTWARE IS PROVIDED BY THE CONCEPTBASE TEAM ``AS IS\'\' AND ANY EXPRESS OR IMPLIED WARRANTIES,'),nl,
write('INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A'),nl,
write('PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONCEPTBASE TEAM OR CONTRIBUTORS BE'),nl,
write('LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES'),nl,
write('(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,'),nl,
write('OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN'),nl,
write('CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT'),nl,
write('OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.'),nl,
nl,
write('The views and conclusions contained in the software and documentation are those of the authors'),nl,
write('and should not be interpreted as representing official policies, either expressed or implied,'),nl,
write('of the ConceptBase Team.'),nl,
  nl.



/*************************************************************/
/** writeHelpMessage (by special request of M. Baumeister)  **/
/**                                                         **/
/** displays a help message for CBserver options            **/
/*************************************************************/

writeHelpMessage :-
    nl,
    default_cb_feature(maxCostLevel,_mc),
    default_cb_feature(bindingPathLen,_pl),
    default_cb_feature(iterMax,_imax),
    default_cb_feature(inactivityInterval,_tmax),
    default_cb_feature('TraceMode',_t),
    default_cb_feature('RangeFormOptimizing',_o),
    write('Usage: cbserver <params>'),nl,nl,
        write('<params>:'),nl,
    write('-i <install>    : may be used by ConceptBase developers only'),nl,
    write('-d <db>         : set database to be loaded'),nl,
    write('-db <db>        : set database to be loaded; views and module sources'),nl,
    write('                  materialized in directory <db> as well'),nl,
    write('-new <db>       : like -d but will erase any old database at location <db> before'),nl,
    write('-p <portnr>     : set portnumber for client connections'),nl,
    write('                  <portnr> must be between 2000 and 65535'),nl,
    write('-port <portnr>  : same as -p <portnr>'),nl,
    write('-version        : display version info and exit'),nl,
    write('-help           : display this text and exit'),nl,
    write('-license        : display license and exit'),nl,
    write('-team           : display ConceptBase developers and exit'),nl,
    write('-t <tracemode>  : set tracemode'),nl,
    write('                  <tracemode> is one of \'silent\', \'no\',  \'minimal\', \'low\', \'high\', \'veryhigh\''),nl,
    write('                  default: '),write(_t),nl,
    write('-u <updatemode> : controls the way interactive updates of the current KB are treated'),nl,
    write('                  <updatemode> is either \'persistent\' or \'nonpersistent\''),nl,
    write('-U <untellmode> : controls the way how UNTELL is executed by the server'),nl,
    write('                  <untellmode> is either \'verbatim\' or \'cleanup\''),nl,
    write('-c <cachemode>  : turn on the query cache to allow recursive query evaluation'),nl,
    write('                  <cachemode> is one of \'off\', \'transient\', \'keep\' (=default)'),nl,
    write('-cs <size>      : specifies the maximum number of derived facts retained between two transactions'),nl,
    write('-o <optmode>    : controls the optimizer for rangeform formulas'),nl,
    write('                  <optmode> is one of \'0\' (none), \'1\' (structural), \'2\' (order), \'3\' (struct.+order), or'),nl,
    write('                  \'4\' (struct.+order+trigger pruning); default: '),write(_o),nl,
    write('-v on|off       : Turn on/off generation of view maintenance rules (default: off)'),nl,
    write('-r <repdelay>   : automatically restart the server after crash'),nl,
    write('                  <repdelay> specifies how many seconds to wait before restart'),nl,
    write('-s <seclevel>   : sets the security level of ConceptBase (0=disabled, 1=local untell, 2=enabled, 3=readonly)'),nl,
    write('                  default: 1'),nl,
    write('-e <maxerr>     : sets the maximum number of error messages to be displayed (default: 20)'),nl,
    write('-a <user>       : sets the admin user of the CBserver (default: user who started the CBserver)'),nl, 
    write('-mu <mumode>    : enabled: multi-user mode is enabled (default), disabled: single-user mode'),nl,
    write('-ms <sep>       : sets the module separator for saving sources and views (values \'-\' or \'/\')'),nl,
    write('-mg split|whole|minsplit|replay : controls how module sources are generated; default: split'),nl,
    write('-cc strict|off|extended  : controls the predicate typing; default: strict '),nl,
    write('-mc <cost>      : specifies the maximum allowed cost for a binding predicate in meta formulas'),nl,
    write('                  default: '),write(_mc),write(' (approx. 2 free variables in binding predicate)'),nl,
    write('-pl <len>       : specifies the maximum length of a binding path in meta formulas'),nl,
    write('                  default: '),write(_pl),nl,
    write('-im <imax>      : specifies the maximum number of iterations to find a better order of'),nl,
    write('                  attribution predicates, default: '),write(_imax),nl,
    write('-eca <emode>    : possible values \'unsafe\' (ECArules enabled without recursion guard),'),nl,
    write('                  \'off\' (ECArules are disabled), \'safe\' (default: ECArules enabled with'),nl,
    write('                  recursion guard) '),nl,
    write('-eo on|off       : specifies whether conditions of ECA rules are optimized; default: on'),nl,
    write('-load <dir>     : specifies the directory from which to load module sources at CBserver startup'),nl,
    write('                  (default: none, i.e. module loading is disabled)'),nl,
    write('-save <dir>     : specifies the directory into which to save module sources'),nl,
    write('                  (default: none, i.e. saving module sources is disabled)'),nl,
    write('-views <dir>    : specifies the directory into which to save views of a module'),nl,
    write('                  (default: none, i.e. view saving is disabled)'),nl,
    write('-rl on|off      : possible values \'on\' (default) and \'off\''),nl,
    write('                  if set to \'on\', the system tries to assign readable labels to generated formulas'),nl,
    write('-ia <tmax>      : specifies the number of hours tmax in which an interaction of a client'),nl,
    write('                  should occur to keep it considered alive, default: '),write(_tmax),nl,
    write('-sm master|slave : a slave CBserver will shutdown when the last local client leaves; default: master'),nl,
    write('-st on|off      : enables or disables the rule stratification tests; default: on'),nl,
    write('-g <cmd>        : provides a special command to the CBserver; possible values \'public\', \'nolpi\' and \'exit\''),nl,
    write('                  the command \'public\' starts the CBserver in public mode; '),nl,
    write('                  the command \'nolpi\' disables the loading of CBserver plugins; '),nl,
    write('                  the command \'exit\' stops the CBserver directly after start-up'),nl,
    !.


 

/************************* e n r o l l ***********************/
/**                                                         **/
/*************************************************************/



enroll :-
    thisToolClass(_toolclass),
    user_name(_user),
    handle_message( ipcmessage('','','ENROLL_ME',[_toolclass,_user]),
            ipcanswer(_,ok,_toolid)),
    my_update(thisToolId(_toolid)),
    (get_cb_feature(adminUser,_admin),_admin \= '';  /** already set by -a option **/
     set_cb_feature(adminUser,_user)
    ),
    !.

enroll :-
    write('startCBserver: unable to enroll'),
    !,
    fail.



/************* c o p y r i g h t _ n o t i c e ***************/
/**                                                         **/
/** This predicate prints a copyright notice to standard    **/
/** output.                                                 **/
/**                                                         **/
/*************************************************************/


copyright_notice :-
    thisToolClass(_name),
    copyright_notice(_name).




/********************** C B c o n s u l t ********************/
/**                                                         **/
/** CBconsult(_CBPath,[(_UserPath,_File)|_RFiles])          **/
/** CBconsult(_CBPath,[(_UserPath,_Cond -> _File)|_RFiles]) **/
/**                                                         **/
/** CBconsult consults a list of prolog files. There exists **/
/** different modes to load a file:                         **/
/** If _UserPath is a free variable then CBconsult takes    **/
/** the file from the directory _CBPath, which is a default **/
/** value for the directory that contains the ConceptBase   **/
/** source files. In the case, where _UserPath is ground,   **/
/** CBconsult loads the file from the directory _UserPath.  **/
/** The user is able to give a condition _Cond, which must  **/
/** be satisfied for loading a concrete file. This is must  **/
/** be written in the following form:                       **/
/** _Cond -> _File.                                         **/
/**                                                         **/
/** 17.07.92 RG before consulting from _CBPath try to find  **/
/**          _File in the local directory                   **/
/**                                                         **/
/*************************************************************/


'CBconsult'(_,[]) :- !.

'CBconsult'(_defPathList,[ (_mode,_File)|_RFiles]) :-
    _mode == profile,
    !,
        'CBconsult_profile'(_defPathList,_File),
        'CBconsult'(_defPathList,_RFiles).

'CBconsult'(_defPathList,[ (_,_File)|_RFiles]) :-
        'CBconsult_normal'(_defPathList,_File),
        'CBconsult'(_defPathList,_RFiles).

'CBconsult_normal'(_CBPathList,_fnam) :-
    my_member(_path,_CBPathList),

        pc_atomconcat([_path,_fnam,'.swi.pl'],_fwic),
        pc_error_message(600,off),
        pc_exists(_fwic),
        pc_error_message(600,on),
        !,
        load_files([_fwic],[]).


'CBconsult_profile'(_,_fnam) :-
    (getenv('CB_WORK',_cbwork);
     _cbwork = '/home/cbase/CB_NewStruct/ProductPOOL/src'),

    concat_atom([_cbwork,'/serverSources/Prolog_Files/',_fnam,'.pro'],_fpro),
    write('Profiling '),write(_fpro),nl,
    pc_error_message(600,off),
    pc_exists(_fpro),
    pc_error_message(600,on),

        !,
        profile_all(_fpro,_fnam).

/*************************************************************/
/** reportOptionError(_errormessage)                        **/
/**                                                         **/
/** _errormessage: list                                     **/
/**                                                         **/
/** returns an errormessage                                 **/
/*************************************************************/

reportOptionError(_errormessage) :-
    put(7),nl,
    write('### OPTION ERROR: '),nl,
    writeListLn(_errormessage),nl.

reportOptionErrorAndStop(_errormessage) :-
    reportOptionError(_errormessage),
    write('### CBserver aborted.'),nl,nl,
    halt.

/*************************************************************/
/** Option(_titel,_param,_method,_condition,_errormsg)      **/
/**                                                         **/
/** _titel:     the identifier of the option                **/
/** _param:     a variable to insert the parameter into     **/
/**             _method  _condition and _errormessage       **/
/** _method:    prolog code, that says what has to be done  **/
/** _condition: prolog code, checks wether the parameter is **/
/**             allowed                                     **/
/** _errormsg : list, specifies an errormessage to be       **/
/**             returned if _condition fails                **/
/**                                                         **/
/** Option/5 specifies what must be done for command line   **/
/** options                                                 **/
/*************************************************************/
'Option'('-i',
    _x,
    ( pc_please(w,on),  /* Interaktiver Server funktioniert nicht mehr CQ/Dec-2002
                        Wird nun durch Shell-Skript behandelt */

  /**    statistics,  not supported by SWI-Prolog 6.x **/
      set_prolog_flag(generate_debug_info,true),   /** interactive version: debug menu on fatal errors **/

      my_update(cb_installation(interactive))
    ),
    atom(_x),
    ['You have specified \'',_x,'\' as parameter for option \'-i\'.\nThe parameter must be an atom.']
).

'Option'('-g',
    _x,
    (
       setFlag(devOption,_x)
    ),
    atom(_x),
    ['Developer option -g must be an atom.']
).

'Option'('-p',
    _x,
    (
      pc_inttoatom(_portnr,_x),
      my_update(portnr(_portnr)),
      !
    ),
    (
      atom(_x),
      pc_inttoatom(_portnr,_x),
      _portnr >= 2000,
      _portnr =< 65535
    ),
    ['You have specified \'',_x,'\' as portnumber (option \'-p\').\nThe portnumber must be an integer between 2000 and 65535.']
).

/** the tag -port is just an alias for -p; may be useful to avoid a warning by SWI-Prolog **/
/** which claims that -p is one of its own parameter tags.                                **/
'Option'('-port',_param,_method,_condition,_errormsg) :-
  'Option'('-p',_param,_method,_condition,_errormsg),
  !.

'Option'('-u',
    _x,
    (
      set_cb_feature('UpdateMode',_x),
      !
    ),
    my_member(_x,[nonpersistent,persistent]),
    ['You have specified \'',_x,'\' as update mode (option \'-u\').\nThe update mode must be either \'persistent\' or \'nonpersistent\'']
).

'Option'('-U',
    _x,
    (
      set_cb_feature('UntellMode',_x),
      !
    ),
    my_member(_x,[verbatim,cleanup]),
    ['You have specified \'',_x,'\' as untell mode (option -U).\nThe untell mode must be either \'verbatim\' or \'cleanup\'']
).



'Option'('-t',
    _x,
    (
      set_cb_feature('TraceMode',_x),
      setTraceGarbadgeCollection(_x),
      !
    ),
    my_member(_x,[silent,no,minimal,low,high,veryhigh]),
    ['You have specified \'',_x,'\' as tracemode (option \'-t\').\nThe tracemode must be one of \'silent\', \'no\', \'low\', \'minimal\', \'high\', \'veryhigh\'']
).


'Option'('-c',
    _x,
    (
      set_cb_feature(defaultCacheMode,_x),
      !
    ),
    my_member(_x,[off,transient,keep]),
    ['You have specified \'',_x,'\' as the cache mode (option \'-c\').\nThis parameter must be \'off\', \'transient\' or \'keep\'']
).


'Option'('-s',
        _x,
        (
          set_cb_feature(securityLevel,_x),
          !
        ),
        my_member(_x,['0','1','2','3']),
        ['You have specified \'',_x,'\' as the security level (option \'-s\').\nThis parameter must be 0,1,2, or 3.']
).

'Option'('-st',
        _x,
        (
          set_cb_feature(stratificationTest,_x),
          !
        ),
        my_member(_x,[on,off]),
        ['You have specified \'',_x,'\' for the stratification test (option \'-st\').\nThis parameter must be on or off.']
).


'Option'('-e',
    _x,
    (
      pc_inttoatom(_maxe,_x),
      set_cb_feature(maximalErrors,_maxe),
      !
    ),
    (
      atom(_x),
      pc_inttoatom(_maxe,_x),
      _maxe >= -1
    ),
    ['You have specified \'',_x,'\' as maximal error number (option \'-e\').\n. It must be either -1, 0, or a positive integer.']
).


/** the adminUser is the user who has more priviledges to stop a CBserver **/
'Option'('-a',
    _x,
    (
       set_cb_feature(adminUser,_x),
      !
    ),
    atom(_x),
    ['The administrator user must be an alphanumerical string']
).





'Option'('-cc',
        _x,
        (
          set_cb_feature(forceConcernedClass,_x),
          !
        ),
        my_member(_x,['strict','off','extended']),
        ['The parameter -cc must be strict, extended or off.']
).

'Option'('-mu',
        _x,
        (
          set_cb_feature(multiuser,_x),
          !
        ),
        my_member(_x,['enabled','disabled']),
        ['The parameter -mu must be \'enabled\' or \'disabled\'.']
).

'Option'('-ms',
        _x,
        (
          set_cb_feature(moduleSeparator,_x),
          !
        ),
        my_member(_x,['-','/']),
        ['The parameter -ms must be \'-\' or \'/\'.']
).


'Option'('-mc',
        _x,
        (
          pc_inttoatom(_maxe,_x),
          set_cb_feature(maxCostLevel,_maxe),
          !
        ),
        (
          atom(_x),
          pc_inttoatom(_maxe,_x),
          _maxe >= 0
        ),
        ['The parameter -mc must be a number greater or equal 0.']
).

'Option'('-cs',
        _x,
        (
          pc_inttoatom(_maxe,_x),
          set_cb_feature(maxCacheSize,_maxe),
          !
        ),
        (
          atom(_x),
          pc_inttoatom(_maxe,_x),
          _maxe >= 0
        ),
        ['The parameter -cs must be a number greater or equal 0.']
).


'Option'('-pl',
        _x,
        (
          pc_inttoatom(_maxe,_x),
          set_cb_feature(bindingPathLen,_maxe),
          !
        ),
        (
          atom(_x),
          pc_inttoatom(_maxe,_x),
          _maxe >= 0
        ),
        ['The parameter -pl must be a number greater or equal 0.']
).

'Option'('-im',
        _x,
        (
          pc_inttoatom(_imax,_x),
          set_cb_feature(iterMax,_imax),
          !
        ),
        (
          atom(_x),
          pc_inttoatom(_imax,_x),
          _imax >= 0
        ),
        ['The parameter -im must be a number greater or equal 0.']
).

'Option'('-ia',
        _x,
        (
          pc_floattoatom(_tmax,_x),
          set_cb_feature(inactivityInterval,_tmax),
          !
        ),
        (
          atom(_x),
          pc_floattoatom(_tmax,_x)
        ),
        ['The parameter -ia must be a number.']
).

'Option'('-rl',
        _x,
        (
          set_cb_feature(readableFormulaLabel,_x),
          !
        ),
        my_member(_x,['on','off']),
        ['The parameter -rl must be \'on\'  or \'off\', .']
).

'Option'('-mg',
        _x,
        (
          set_cb_feature(moduleGeneration,_x),
          !
        ),
        my_member(_x,['split','minsplit','whole','replay']),
        ['The parameter -mg must be \'split\', \'minsplit\', or \'whole\', .']
).


'Option'('-eca',
        _x,
        (
          set_cb_feature(ecaControl,_x),
          !
        ),
        my_member(_x,['off','safe', 'unsafe']),
        ['The parameter -eca must be \'off\', \'safe\', or \'unsafe\', .']
).

'Option'('-eo',
        _x,
        (
          set_cb_feature(ecaOptimize,_x),
          !
        ),
        my_member(_x,['on', 'off']),
        ['The parameter -eo must be \'on\' or \'off\', .']
).

'Option'('-save',
        _x,
        (
          makeDirIfNotExists(_x),
          set_cb_feature(exportDir,_x),
          !
        ),
        (_x\='none'),
        ['The parameter -save may not be set explicitly to none.']
).

'Option'('-load',
        _x,
        (
          makeDirIfNotExists(_x),
          set_cb_feature(importDir,_x),
          !
        ),
        (_x\='none'),
        ['The parameter -load may not be set explicitly to none.']
).

'Option'('-views',
        _x,
        (
          makeDirIfNotExists(_x),
          set_cb_feature(viewDir,_x),
          !
        ),
        (_x\='none'),
        ['The parameter -views may not be set explicitly to none.']
).

'Option'('-db',
        _x,
        (
          removeLastSlash(_x,_x1),
          my_update(dataBase(_x1)),  /** will create directory _x if not existent **/
          set_cb_feature(viewDir,_x1),
          set_cb_feature(importDir,_x1),
          set_cb_feature(exportDir,_x1),
          !
        ),
        (_x\='none'),
        ['The parameter -db may not be set explicitly to none.']
).



'Option'('-o',
    _a,
    (
      set_cb_feature('RangeFormOptimizing',_a),
      !
    ),
    my_member(_a,['0','1','2','3','4']),
    ['You have specified \'',_i,'\' as mode for the optimizer (option \'-o\').\nThe mode must be 0 (none), 1 (structural), 2 (order), 3 (struct+order), or 4 (struct+order+trigger pruning).']
).

'Option'('-v',
    _v,
    (set_cb_feature('ViewMaintenanceRules',_v),
     !
    ),
    my_member(_v,[on,off]),
    ['You have specified an invalid for option -v (generation of view maintenance rules), allowed are only \'on\' or \'off\'.']).


'Option'('-d',
    _x,
    (
      removeLastSlash(_x,_x1),
      my_update(dataBase(_x1)),
      !
    ),
    true,
    ['E01: this message should never appear']
).


'Option'('-new',
    _x,
    (
      removeLastSlash(_x,_x1),
      removeDBifExists(_x1),  /** remove an existing database **/
      my_update(dataBase(_x1)),
      !
    ),
    true,
    ['E02: this message should never appear']
).

'Option'('-sm',
    _x,
    (
      set_cb_feature(servermode,_x),
      !
    ),
     my_member(_x,[master,slave]),
    ['E02: this message should never appear']
).


'Option'('-r',
    _x,
    (
      set_cb_feature(repeatLoop,_x),
      !
    ),
    true,
    ['E03: this message should never appear']
).


'Option'(_opt,
    _param,
    fail,
    (
      writeHelpMessage,
      fail
    ),
    ['I do not know the option "',_opt,'".']
).



my_member(_x,[_x|_]).
my_member(_x,[_y|_r]) :- _x \== _y,my_member(_x,_r).


/**************************************************************/
/** In der gelinkten Version werden die Warnings 800 und 806 **/
/** abgeschaltet  (8.11.1995/TL)                             **/
/**************************************************************/

warnings_on:-
    'ObjektSpeicherWarnings'(on).

warnings_off:-
/*      pc_please(w,off),*/
    'ObjektSpeicherWarnings'(off).

'ObjektSpeicherWarnings'(_switch):-

    !.

/**************************************************************/
/** Definition einiger Praedikate zum Laden des CBservers    **/
/**************************************************************/


/* Update the predicate (i.e. retract the a fact from the KB
with the same factor and assert _pred */
:- module_transparent my_update/1 .
my_update(_pred) :-
    functor(_pred,_fun,_ar),
    functor(_vpred,_fun,_ar),
    retract(_vpred),
    !,
    asserta(_pred).

my_update(_pred) :-
    asserta(_pred).

/* Expand a path name, including environment variables */
my_expand_path(_path,_exp) :-
    expand_file_name(_path,[_exp|_]).






setTraceGarbadgeCollection(_cb_trace_mode) :-
    (_cb_trace_mode=no;_cb_trace_mode=minimal;_cb_trace_mode=low),
    set_prolog_flag(trace_gc,false),   /** do not trace garbadge collection if ConceptBase trace mode=no,minimal under SWI **/
    !.
setTraceGarbadgeCollection(_cb_trace_mode) :-
    (_cb_trace_mode=high;_cb_trace_mode=veryhigh),
    set_prolog_flag(generate_debug_info,true),   /** show debug menu on fatal errors **/
    !.

/** else: **/
setTraceGarbadgeCollection(_).  /** leave as is. **/


/*************************************************************/
/** This call loads all files of the kernel system          **/
/*************************************************************/

?- loadCBkernel.


/* 'Teste', ob 'Fehler' beim 'Kompilieren' aufgetreten ist. */
?- (cb_compile_error(yes),halt(1));true .

/* ?-  debug, spy('QO_profile':updateGlobalCounters/0) , spy('QO_optimize':storeCostsAllAds/5). */


/*************************************************************/
/**  This call starts the ConceptBase server.               **/
/*************************************************************/


