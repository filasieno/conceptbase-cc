{*
The ConceptBase.cc Copyright

Copyright 1987-2025 The ConceptBase Team. All rights reserved.

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
*}
{
*
* File:        	ConfigurationUtilities.pro
* Version:     	11.3
* Creation:     23-Jun-1988, Michael Gocek (UPA)
* Last Change: 	05/09/97, Kai v. Thadden (RWTH)
* Release:     	11
* -----------------------------------------------------------------------------
*
*   24-Jan-1989/MSt : loading of *_rule - files corresponding to
*                     .pro and .prop files
*                     saving of *_rule - files containing PROLOGrules
*                     produced from Assertions
*
*   01-08-89/AM     : Loading .lit - files corresponding to .prop - files .
*   30-Oct-1989/MSt : _rule files are re(!)consulted
*   19-Dec-1989/TW  : loading of *_timeRel - files corresponding to
*                     .pro and .prop files
*                     saving of *_timeRel - files containing timerelations
*                     produced by the time calculus
*   09-May-1990/MSt : call of error report and fail in 3rd clause of
*		      compile_SMLtext
*
*   31-Aug-1990/AM  : *.lit files no longer considered
*   24-Sept-90/MSt  : new pred process_rule_file for loading .rule files
*		      containing explicit code for BuiltinQueries in .sml/.sfg
*		      files
*
*   21-Jan-1991/AM  : Adaptations for persistency
*
* 4-Dec-1992/kvt: minor bugfix in load_sml/1: 'smlfile' wasn't closed,
*                 when tell_objproc fails.
*
* 21-Mar-1995/CQ: SML-Dateien werden mit C-Funktion read_text_file eingelesen.
*
*4-Okt-1995/MSt+HWN: ehemaliger lib(dir)-Aufruf (fuer list_dir) durch
*                                                  Praedikate ersetzt (-> ExternalCodeLoader)
*
* 9-Dez-1996/LWEB: Modulaenderungen. Beim Laden der Applikationsfiles wird die
* id des Systemmoduls und die id des Module Objekts im Fakt  Ssytem/1 und Module/1
* zwecks spaeterem effizienten Zugriff (kein retrieve noetig) abgespeichert.
* Der aktuelle Modul Suchraum  (getModule/1) wird auf das System-Modul gesetzt.
*
*  Einige im Zuge der Objektspeicherumstellung jetzt unbenutzte Funktionen wie
*  system_create_log/1 , system_create_h/1 , system_create /1 history_prop/1 wurden rausgeschmissen.
*
*  Exported predicate:
*  -------------------
*   	+ load_appfiles (_appFilename)
*	+ load_sml (_smlFilename)
*
}

#MODULE(ConfigurationUtilities)
#EXPORT(dir_list/2)
#EXPORT(load_appfiles/1)
#EXPORT(load_sml/1)
#EXPORT(loadedLPI/1)
#EXPORT(listModuleContent/2)
#EXPORT(listModuleContentReloadable/2)
#EXPORT(purgeModuleContent/2)
#EXPORT(saveModuleTree/2)
#EXPORT(loadModuleTree/1)
#EXPORT(saveSingleModule/2)
#ENDMODDECL()


#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(save_stringtoatom/2,GeneralUtilities)
#IMPORT(WriteTrace/3,GeneralUtilities)
#IMPORT(operatingSystemIsWindows/0,GeneralUtilities)
#IMPORT(report_error/3,ErrorMessages)
#IMPORT(tell_objproc/2,ObjectProcessor)
#IMPORT(store_PROLOGrulesAndTriggers/1,PROLOGruleProcessor)
#IMPORT(appFilename/3,ModelConfiguration)
#IMPORT(build_fragments_from_cstring/2,LanguageInterface)
#IMPORT(read_text_file/2,ExternalCodeLoader)
#IMPORT(concat_sml_string/3,ExternalCodeLoader)
#IMPORT(memfree/1,ExternalCodeLoader)
#IMPORT(init/1,BIM2C)
#IMPORT(opendir/2,ExternalCodeLoader)
#IMPORT(readdir/2,ExternalCodeLoader)
#IMPORT(closedir/1,ExternalCodeLoader)
#IMPORT(getFileNameFromDirEntry/2,ExternalCodeLoader)
#IMPORT(store_ecarules/1,ECAruleProcessor)
#IMPORT(store_ruleinfos/1,RuleBase)
#IMPORT(load_int_cost/1,QO_costBase)
#IMPORT(Win_FindFirstFile/4,ExternalCodeLoader)
#IMPORT(Win_FindNextFile/3,ExternalCodeLoader)
#IMPORT(Win_FindClose/1,ExternalCodeLoader)
#IMPORT(getFileNameFromFindData/2,ExternalCodeLoader)
#IMPORT(init_KBsearchSpace/2,SearchSpace)
#IMPORT(retrieve_C_proposition_module/1,BIM2C)
#IMPORT(retrieve_C_proposition/1,BIM2C)
#IMPORT(setModule/1,ModelConfiguration)
#IMPORT(getModule/1,ModelConfiguration)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_update/1,PrologCompatibility)
#IMPORT(pc_fopen/3,PrologCompatibility)
#IMPORT(pc_fclose/1,PrologCompatibility)
#IMPORT(pc_exists/1,PrologCompatibility)
#IMPORT(pc_isNullPointer/1,PrologCompatibility)
#IMPORT(pc_expand_path/2,PrologCompatibility)
#IMPORT(pc_time/2,PrologCompatibility)
#IMPORT(pc_atomprefix/3,PrologCompatibility)
#IMPORT(pc_save_atom_to_term/2,PrologCompatibility)
#IMPORT(getFlag/2,GeneralUtilities)



#IMPORT(appendBuffer/2,ExternalCodeLoader)
#IMPORT(getStringFromBuffer/2,ExternalCodeLoader)

#IMPORT(cb_version/1,GlobalParameters)
#IMPORT(cb_date_of_release/1,GlobalParameters)
#IMPORT(pc_recorded/3,PrologCompatibility)
#IMPORT(member/2,GeneralUtilities)
#IMPORT(timetoatom/2,GeneralUtilities)
#IMPORT(timetoatom/3,GeneralUtilities)
#IMPORT(changeIdentifierExp/3,SelectExpressions)
#IMPORT(build_frame/2,ScanFormatUtilities)
#IMPORT(id2name/2,GeneralUtilities)
#IMPORT(pc_atom_to_term/2,PrologCompatibility)
#IMPORT(save_setof/3,GeneralUtilities)
#IMPORT(save_bagof/3,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(setFlag/2,GeneralUtilities)
#IMPORT(attribute/1,validProposition)
#IMPORT(individual/1,validProposition)
#IMPORT(retrieve_proposition_noimport/2,PropositionProcessor)
#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(compose_attrdecllist/2,PropositionsToFragment)
#IMPORT(compose_attrdecllist/2,PropositionsToFragment)
#IMPORT(knownTool/5,CBserverInterface)
#IMPORT(checkPermission/3,CBserverInterface)
#IMPORT(is_id/1,MetaUtilities)
#IMPORT(addAnswerParameters/2,AnswerTransform)
#IMPORT(createBuffer/2,GeneralUtilities)
#IMPORT(disposeBuffer/1,GeneralUtilities)

#IMPORT(pc_erase_all/1,PrologCompatibility)
#IMPORT(pc_erase/1,PrologCompatibility)
#IMPORT(pc_recorded/2,PrologCompatibility)
#IMPORT(pc_rerecord/2,PrologCompatibility)
#IMPORT(pc_record/2,PrologCompatibility)
#IMPORT(prove_literal/1,Literals)
#IMPORT(active_user/1,CBserverInterface)
#IMPORT(getModulePath/1,ModelConfiguration)
#IMPORT(getModulePath/2,ModelConfiguration)
#IMPORT(toId/2,cbserver)
#IMPORT(get_cb_feature/2,GlobalParameters)
#IMPORT(saveFramesToFile/3,ModelConfiguration)
#IMPORT(quicksortLabels/2,GeneralUtilities)
#IMPORT(reverse/2,GeneralUtilities)
#IMPORT(thisToolId/1,CBserverInterface)
#IMPORT(handle_message/2,CBserverInterface)
#IMPORT(buildAbsoluteFilePath/3,ModelConfiguration)

#IMPORT(unquoteAtom/2,GeneralUtilities)
#IMPORT(makeName/2,cbserver)
#IMPORT(process_query/2,QueryProcessor)
#IMPORT(switchModule/1,CBserverInterface)
#IMPORT(write_lcall/1,Literals)
#IMPORT(saveQueryResultsToFile/5,ModelConfiguration)
#IMPORT(executePostExportCommand/0,ModelConfiguration)
#IMPORT(pc_time/2,PrologCompatibility)
#IMPORT(emptyCache/0,Literals)
#IMPORT(pc_exists_directory/1,PrologCompatibility)
#IMPORT(dirSeparator/1,ModelConfiguration)

#IMPORT(id2starttime/2,BIM2C)
#IMPORT(keyCommentChars/2,ScanFormatUtilities)

#IMPORT(DELETE/1,FragmentToHistoryPropositions)
#IMPORT(UNTELL_FRAGMENTS/2,TellAndAsk)

#IMPORT(getCC/3,Literals)
#IMPORT(keyFrameListStart/1,ScanFormatUtilities)
#IMPORT(keyFrameListEnd/1,ScanFormatUtilities)
#IMPORT(keyFrameSep/1,ScanFormatUtilities)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


{ =================== }
{ Exported predicates }
{ =================== }

{**********************       l o a d _ p r o p        **********************}
{									     }
{ load_appfiles(_app)		         				     }
{            _app : ground : atom		        		     }
{									     }
{ This predicate loads a set of propvals from the application _app and       }
{ stores them.                                                               }
{ If a corresponding .rule files exists (containing dynamic code) it is      }
{ loaded too.                                              MSt 24-Jan-89     }
{ If corresponding .hprop,.log, files exist they are loaded too.     }
{									     }
{****************************************************************************}

load_appfiles(_app) :-
	appFilename('',_app,_propfilename),
	init(_propfilename),

	init_KBsearchSpace(currentOB,Now),   {* first setting after CB startup *}

	{ LWEB	: speichere die ID's von System und Module zur spaeteren Optimierung in speziellen Fakten ab }
	retrieve_C_proposition_module(P(_sid,_sid,System,_sid,_)),
	setModule(_sid),
	retrieve_C_proposition(P(_mid,_mid,Module,_mid)),
	pc_update(System(_sid)),
	pc_update(Module(_mid)),

	{ lade Prolog - Regeln }
        appFilename('rule',_app,_rulefilename),
        ((pc_exists(_rulefilename),!,
          load_rule(_rulefilename));
         true),

        {* OB.builtin is now longer loaded; its content is now in SystemBuiltin.pro; ticket #256 *}

	{ load eca_rules from file }
	appFilename('ecarule',_app,_ecarulefilename),
        ((pc_exists(_ecarulefilename),!,
          load_ecarule(_ecarulefilename));
         true),

	appFilename('ruleinfo',_app,_ruleinfofilename),
        ((pc_exists(_ruleinfofilename),!,
          load_ruleinfos(_ruleinfofilename));
         true),




        {* 12-Jul-1994/MJf: load all Prolog files with extension }
        {* '.lpi' (= "logic program interface')                  }
#IF(BIM)
        load_rules(_app,'.bim.lpi').
#ENDIF(BIM)
#IF(SWI)
        load_rules(_app,'.swi.lpi').
#ENDIF(SWI)


{************************  l o a d _ s m l   ********************************}
{									     }
{ load_sml (_smlfilenames)                                                   }
{           _smlfilenames : ground 					     }
{									     }
{ This predicate reads a list of CML - texts from the file _smlfilename and  }
{ compiles them to CML-fragments if possible. Then it tells the list of Telos}
{ fragments to the objectprocessor.                                          }
{ 3-Jun-1993/MJf: The first argument is now a non-empty list of filenames.   }
{ The read_text_from_files/2 treats them as if they were a single input      }
{ stream.                                                                    }
{ 16-Mar-95/CQ: Die Liste der Filename werden nun von der C-Funktion         }
{   read_text_file eingelesen. Die einzelnen eingelesen Strings werden mit   }
{   mit concat_sml_string zusammen kopiert                                   }
{****************************************************************************}

load_sml([_firstfile|_restfiles]) :-
	pc_expand_path(_firstfile,_expfile),
	read_text_file(_cstring, _expfile),!,
	\+(pc_isNullPointer(_cstring)),
	load_sml2(_restfiles,_cstring,_newcstring),
	cont_load(_newcstring).

load_sml2([],_cstring,_cstring) :- ! .

load_sml2([_firstfile|_restfiles],_cstring1,_newcstring) :-
	pc_expand_path(_firstfile,_expfile),
	read_text_file(_cstring2, _expfile),!,
	\+(pc_isNullPointer(_cstring2)),
	concat_sml_string(_cstring3,_cstring1,_cstring2),!,
	load_sml2(_restfiles,_cstring3,_newcstring).

cont_load(_cstring) :-
	build_fragments_from_cstring(_cstring,_fraglist),!,
	memfree(_cstring),
	!,
  	tell_objproc(_fraglist,_res),
	_res = noerror.

cont_load(_cstring) :-
	save_stringtoatom(_cstring,_c),
	memfree(_cstring),
	report_error(SYNERR,ConfigurationUtilities,[_c]),
	!,fail.






{***************************************************************************}

load_rule(_file) :-
        getRuleList(_file,_ruleList),
	store_PROLOGrulesAndTriggers(_ruleList),
	!.
load_rule(_file) :-
        report_error(FILELOADERR,ConfigurationUtilities,[_file]),
        !.


getRuleList(_file,_ruleList) :-
        pc_fopen(rulefile,_file,r),
        WriteTrace(high,ConfigurationUtilities,['Loading rules from file: ',_file]),
        read_rules(rulefile,_ruleList),
        pc_fclose(rulefile),
        !.
  


#IF(SWI)
:- module_transparent read_rules/1 .
#ENDIF(SWI)

read_rules(_file,[_rule|_RuleList]) :-
	read(_file,_rule),
	_rule \== end_of_file,
	read_rules(_file,_RuleList).

read_rules(_file,[]) :- !.



{* 13-Jul-1994/MJf: load_rules loads all files in _dir that have the *}
{* extension _ext.                                                   *}

load_rules(_dir, _ext) :-
   pc_atomconcat(_prefix,'.lpi',_ext),  {* LPI file to be loaded *}
   getFlag(devOption,'nolpi'),          {* user has disabled LPI loading *}
   !.                                   {* load nothing *}


load_rules(_dir, _ext) :-
   dir_list(_dir,_all_files),
   load_rule_list(_dir,_all_files, _ext).

load_rule_list(_dir,[],_) :- !.

load_rule_list(_dir,[_file|_rest],_ext) :-
  pc_atomconcat(_fileprefix,_ext,_file),   {* ==> file has extension _ext }
  !,
  pc_atomconcat([_dir,'/',_file],_absfilename),
  load_rule(_absfilename),
  memorizeLPI(_fileprefix,_ext),
  load_rule_list(_dir,_rest,_ext).

load_rule_list(_dir,[_|_rest],_ext) :-
  load_rule_list(_dir,_rest,_ext).


#DYNAMIC(loadedLPI/1)

loadedLPI('-').

memorizeLPI(_file,'.swi.lpi') :-
  retractIfDefined(loadedLPI('-')),
  assert(loadedLPI(_file)),
  !.
memorizeLPI(_,_).

retractIfDefined(loadedLPI('-')) :-
  retract(loadedLPI('-')),
  !.
retractIfDefined(_).




{**************** Ehemals aus library dir ******************}
#MODE( dir_list(i, o))

#MODE( list_directory(i, o))

#MODE( next_entry(i, i, ?))

#MODE( skip_filename(i))


dir_list(_directory_name, _list ):-
    operatingSystemIsWindows,
    !,
    dir_list_win(_directory_name,_list).


dir_list(_directory_name, _list):-
	atom(_directory_name),
	opendir(_dir, _directory_name),
	list_directory(_dir, _list),
	closedir(_dir),
	!.

{**** Reading directory for windows **** }
dir_list_win(_dir,_list) :-
	pc_atomconcat(_dir,'/*',_dirstar),
	Win_FindFirstFile(_ret,_dirstar,_hdl,_finddata),
	_ret == 0,
	!,
	getFileNameFromFindData(_name,_finddata),
	next_entry_win(_hdl,_name,_list),
	Win_FindClose(_hdl),
	!.

dir_list_win(_dir,[]).

dir_list_win_next(_hdl,_list) :-
	Win_FindNextFile(_ret,_hdl,_finddata),
	_ret == 0,
	!,
	getFileNameFromFindData(_name,_finddata),
	next_entry_win(_hdl,_name,_list).

dir_list_win_next(_hdl,[]).

next_entry_win(_hdl, _name, _list):-
	skip_filename(_name),
	!,
	dir_list_win_next(_hdl, _list).

next_entry_win(_hdl, _name, [_name|_list]):-
	dir_list_win_next(_hdl, _list).

{***** Reading directory for Unix *****}
list_directory(_dir, _list):-
	readdir(_entry, _dir),
	getFileNameFromDirEntry( _name, _entry),
	next_entry(_dir, _name, _list).
list_directory(_, []).

next_entry(_dir, _name, _list):-
	skip_filename(_name),
	!,
	list_directory(_dir, _list).
next_entry(_dir, _name, [_name|_list]):-
	list_directory(_dir, _list).

skip_filename('.').
skip_filename('..').

{ ***************************************************************************}
{                 !@! load eca_rules from file                                }
{****************************************************************************}

load_ecarule(_file) :-

	pc_fopen(ecarulefile,_file,r),
	WriteTrace(high,ConfigurationUtilities,['Loading ECA rules from file:',_file]),
	read_rules(ecarulefile,_ecaruleList),
	pc_fclose(ecarulefile),!,
	store_ecarules(_ecaruleList),!.


{ ********************************!@!***************************************** }

load_ruleinfos(_file):-
	pc_fopen(ruleinfofile,_file,r),
	WriteTrace(high,ConfigurationUtilities,['Loading rule information from file:',_file]),
	read_rules(ruleinfofile,_ruleinfoList),
	pc_fclose(ruleinfofile),
	!,
	load_int_cost(_ruleinfoList),
	store_ruleinfos(_ruleinfoList),
	!.



{* purgeModuleContent attempts to delete all propositions of the module _modname *}



purgeModuleContent('no','System') :-
  WriteTrace(minimal, ConfigurationUtilities, ['Cannot purge System module']),
  report_error(UNTELL15, ConfigurationUtilities, ['System']),
  !.

purgeModuleContent('no',_mod) :-
  System(_mod),
  WriteTrace(minimal, ConfigurationUtilities, ['Cannot purge System module']),
  report_error(UNTELL15, ConfigurationUtilities, ['System']),
  !.

purgeModuleContent('yes',_modname) :-
  emptyCache,  {* ticket #351 *}
  checkAndSwitchPurge(_modname,_mod),
  hasNoSubModule(_mod),

  extractModulePropositions(_mod,_allprops),
  getFragments(_allprops,_transactions),
  purgeTransactions(_transactions,_completion),
  handleLeftOver(_mod), 
  !.

{* catchall *}
purgeModuleContent('no',_modname) :- 
  WriteTrace(minimal, ConfigurationUtilities, ['Error in purging module ',idterm(_modname)]),
  !.



{* make a clean sweep of orphaned propositions *}
handleLeftOver(_mod) :- 
  extractModulePropositions(_mod,_leftover),
  deletePropositions(_leftover), 
  !.


purgeTransactions([],ok) :- !.

purgeTransactions([_transaction1|_resttransactions],_compl1) :-
  purgeTransactions(_resttransactions,_compl),
  _compl = ok,
  purgeTransaction(_transaction1,_compl1),
  !.
purgeTransactions(_,error) :-
  !.


purgeTransaction(fragments(_ttatom,_,_fraglist),_compl) :-
  purgeTransaction(fragments(_ttatom,_fraglist),_compl).  {* cater for the 3-arg version, issue #18 *}

purgeTransaction(fragments(_ttatom,_fraglist),_compl) :-
  UNTELL_FRAGMENTS(_fraglist,_compl),
  !.
purgeTransaction(fragments(_ttatom,_fraglist),error).




hasNoSubModule(_mod) :-
   isSubModuleOf(_sub,_mod),
   modprop(_sub,P(_id,_x,_n,_y)),  {* at least one proposition in _sub *} 
   report_error(UNTELL16, ConfigurationUtilities, [objectName(_sub)]),
   increment('error_number@F2HP'),
   !,
   fail.

hasNoSubModule(_mod).


deletePropositions([]) :- !.

deletePropositions([_p|_rest]) :-
  DELETE(_p),
  deletePropositions(_rest).

{* fail to delete proposition _p *}
deletePropositions([_p|_rest]) :-
  WriteTrace(minimal, ConfigurationUtilities, ['Failed to purge proposition ',_p]),
  report_error(UNTELL17, ConfigurationUtilities, [_p]),
  increment('error_number@F2HP'),
  deletePropositions(_rest).




{* listing the content of module _mod into a string variable _frames *}
{* The code is taken from the LPI listmodule.swi.lpi and re-released *}
{* here under the ConceptBase FreeBSD license.                       *}
{* M. Jeusfeld, 26-Jan-2011                                          *}



listModuleContent(_frames,_modname) :-
  emptyCache,  {* ticket #351 *}
  checkAndSwitch(_modname,_mod),
  createBuffer(_buf,large),  {* see also ticket #263 *}
  pc_time(setNotToSave,_T1),
  WriteListOnTrace(high,['   ... ',_T1, ' sec used for DoNotSave query']),
  initHeader(_buf,_mod),
  extractModulePropositions(_mod,_allprops),
  getFrames(_buf,_allprops,_frames),
  disposeBuffer(_buf),
  !.

listModuleContent('{* no *}',_) :-
  write('!!! ConfigurationUtilities: Error with listModuleContent'),nl,
  !.

listModuleContentReloadable(_frames,_modname) :-
  emptyCache,  {* ticket #351 *}
  checkAndSwitch(_modname,_mod),
  createBuffer(_buf,large),  {* see also ticket #263 *}
  pc_time(setNotToSave,_T1),
  WriteListOnTrace(high,['   ... ',_T1, ' sec used for DoNotSave query']),
  getModulePath(_modpath),
  initHeader_reloadable(_buf,_mod,_modpath),
  extractModulePropositions(_mod,_allprops),
  getFrames(_buf,_allprops,_frames),
  disposeBuffer(_buf),
  !.

listModuleContentReloadable('{* no *}',_) :-
  write('!!! ConfigurationUtilities: Error with listModuleContentReloadable'),nl,
  !.


listModuleContent_internal(_frames,_mod,_modpath) :-
  emptyCache,  {* ticket #351 *}
  getModule(_mod),  {* _mod is id of the current module *}
  createBuffer(_buf,large),  {* see also ticket #263 *}
  pc_time(setNotToSave,_T1),
  WriteListOnTrace(high,['   ... ',_T1, ' sec used for DoNotSave query']),
  initHeader_internal(_buf,_mod,_modpath),
  extractModulePropositions(_mod,_allprops),
  getFrames(_buf,_allprops,_frames),
  disposeBuffer(_buf),
  !.

listModuleContent_internal('{* no *}',_mod,_modpath) :-
  write('!!! ConfigurationUtilities: Error with listModuleContent_internal '),write(_mod),write(', '),write(_modpath),nl,
  !.


{* ticket #384: we split allprops into sublists, one per transaction *}
{* This allows to include a separator comment into the frames string *}
{* which can later be used to devide the frames string into parts,   *}
{* one per transaction.                                              *}
getFrames(_buf,_allprops,_frames) :-
  getFragments(_allprops,_fraglistoflists),
  printFragmentLists(_buf,_fraglistoflists),
  appendEndFramesElement(_buf),
  keyFrameListEnd(_endlist),
  appendBuffer(_buf,_endlist),
  getStringFromBuffer(_frames,_buf),
  !.

appendEndFramesElement(_buf) :-
  getFlag(currentAnswerFormat,'JSONIC'),
  appendBuffer(_buf,'\n'),
  !.

appendEndFramesElement(_buf) :-
  keyCommentChars(_start,_end), 
  appendBuffer(_buf,'\n'),
  appendBuffer(_buf,_start),
  appendBuffer(_buf,' '),
  appendBuffer(_buf,'-/-'),
  appendBuffer(_buf,' '),
  appendBuffer(_buf,_end),
  appendBuffer(_buf,'\n'),
  !.

getFragments(_allprops,_fraglistoflists) :-
  pruneProps(_allprops,_prunedprops),
  convertPropositionsToFragments(_prunedprops,_fraglistoflists),
  !.


checkAndSwitch(_modparam,_modid) :-
  modToModname(_modparam,_modname),
  active_user(_user),   {* this is the name of the currently active user *}
  checkPermission(_user,ASK,_modname),  {* this will switch to _modname if ASK is permitted for _user *}
  getModulePath(_mpath),   {* fetch the path to the current module *}
  pc_atom_to_term(_mpathatom,_mpath),
  addAnswerParameters('AuxAnswerParameter',[_mpathatom/currentpath]),
  getModule(_modid).

checkAndSwitchPurge(_modparam,_modid) :-
  modToModname(_modparam,_modname),
  active_user(_user),   {* this is the name of the currently active user *}
  checkPermission(_user,UNTELL,_modname),  {* this will switch to _modname if ASK is permitted for _user *}
  getModulePath(_mpath),   {* fetch the path to the current module *}
  pc_atom_to_term(_mpathatom,_mpath),
  addAnswerParameters('AuxAnswerParameter',[_mpathatom/currentpath]),
  getModule(_modid).
  


listProps([]) :- nl.

listProps([_p|_rest]) :- 
  write(_p),
  writeTTime(_p),nl,
  listProps(_rest).


writeTTime(P(_id,_x,_l,_y)) :-
  write(': '),
  getTT(P(_id,_x,_l,_y),_tt),
{*  prove_literal(Known(_id,_tt)), *}
  write(_tt),
  !.

writeTTime(_).

getTT(P(_id,_x,_l,_y),_tt) :-
   id2starttime(_id,tt(_tt)).
{*  prove_literal(Known(_id,_tt)). *}



getfirstTT([_p|_rest],_tt) :-
  getTT(_p,_tt).



{* split _props into separate transactions depending on the transaction time *}

splitToTransactions([],[]) :- !.

splitToTransactions(_props,[_props]) :-
  get_cb_feature(moduleGeneration,'whole'),   {* splitting is disabled: treat props as whole *}
  !.


splitToTransactions(_props,_translist) :-
  getfirstTT(_props,_tt),
  doSplitToTransactions(_tt,_props,_translist).

doSplitToTransactions(_tt,_props,[_trans|_resttrans]) :-
  extractTransaction(_tt,_props,_restprops,_trans),
  splitToTransactions(_restprops,_resttrans).

extractTransaction(_tt,[_p|_rest],_otherprops,[_p|_restoftrans]) :-
  getTT(_p,_tt),  {* same transaction time _tt *}
  !,
  extractTransaction(_tt,_rest,_otherprops,_restoftrans).

extractTransaction(_tt,_props,_props,[]).



  
  

  


modToModname(_mod,_modname) :-
  var(_mod),
  getModule(_mod),
  id2name(_mod,_modname),
  !.
modToModname(_mod,_modname) :-
  is_id(_mod),
  id2name(_mod,_modname),
  !.
modToModname(_modname,_modname) :-
  name2id(_modname,_),  {* _modname exists as object *}
  !.
modToModname(_modname,_modname) :-
  atom(_modname),
  pc_save_atom_to_term(_modname,_X-_Y),  {* for example System-M1 *}
  !.
{* ticket #372: allow also module paths built with '/' *}
modToModname(_modname,_modname) :-
  atom(_modname),
  pc_save_atom_to_term(_modname,_X/_Y),  {* for example System/M1 *}
  !.

modToModname(_modname,_) :-
  report_error(MOD1,ConfigurationUtilities,[_modname]),
  !,
  fail.


initHeader(_buf,_mod) :-
  getFlag(currentAnswerFormat,'JSONIC'),!,
  pc_recorded(user,'AuxAnswerParameter',_u),
  pc_recorded(currentpath,'AuxAnswerParameter',_cp),
  pc_recorded(currentmodule,'AuxAnswerParameter',_cm),
  pc_recorded(transactiontime,'AuxAnswerParameter',_tt),
  modToModname(_mod,_modname),
  keyFrameListStart(_start),
  appendBuffer(_buf,_start),
  appendBuffer(_buf, '{ "module" : "'),
  appendBuffer(_buf,_modname),
  appendBuffer(_buf,'",\n'),
  appendBuffer(_buf,'  "modulepath" : "'),
  appendBuffer(_buf,_cp),
  appendBuffer(_buf,'" },\n\n'),
  !.


initHeader(_buf,_mod) :-
  pc_recorded(user,'AuxAnswerParameter',_u),
  pc_recorded(currentpath,'AuxAnswerParameter',_cp),
  pc_recorded(currentmodule,'AuxAnswerParameter',_cm),
  pc_recorded(transactiontime,'AuxAnswerParameter',_tt),
  cb_version(_cbversion),
  cb_date_of_release(_reldate),

  keyCommentChars(_start,_end), 
  appendBuffer(_buf,_start),
  appendBuffer(_buf,'\n'),

  appendBuffer(_buf,'* Module: '),
  appendBuffer(_buf,_cp),
  appendBuffer(_buf,'\n'),

  appendBuffer(_buf,'* ---------------------------------------------------------\n'),

  appendBuffer(_buf,'* Listed for: '),
  appendBuffer(_buf,_u),
  appendBuffer(_buf,' at '),
  appendBuffer(_buf,_tt),
  appendBuffer(_buf,' (UTC) \n'),

  appendBuffer(_buf,'* CBserver version: '),
  appendBuffer(_buf,_cbversion),
  appendBuffer(_buf,' ('),
  appendBuffer(_buf,_reldate),
  appendBuffer(_buf,') \n'),

  appendBuffer(_buf,'*\n'),
  appendModuleComments(_buf,_mod),

  appendBuffer(_buf,_end),
  appendBuffer(_buf,'\n\n'),
  !.

initHeader_reloadable(_buf,_mod,_mpath) :-
  pc_recorded(user,'AuxAnswerParameter',_u),
  pc_recorded(transactiontime,'AuxAnswerParameter',_tt),
  cb_version(_cbversion),
  cb_date_of_release(_reldate),
  pc_atom_to_term(_cp,_mpath),
  keyCommentChars(_start,_end), 
  appendBuffer(_buf,_start),
  appendBuffer(_buf,'\n'),
  appendBuffer(_buf,'* Module: '),
  appendBuffer(_buf,_cp),{* appendBuffer(_buf,'.sml'), *}
  appendBuffer(_buf,'\n'),
  appendBuffer(_buf,'* ---------------------------------------------------------\n'),

  appendBuffer(_buf,'* This file has been extracted from a ConceptBase database.\n'),
  appendBuffer(_buf,'* Copyright is with the respective authors.\n\n'),

  appendBuffer(_buf,'* Time extracted: '),
  appendBuffer(_buf,_tt),
  appendBuffer(_buf,' (UTC) \n'),


  appendBuffer(_buf,'* CBserver version: '),
  appendBuffer(_buf,_cbversion),
  appendBuffer(_buf,' ('),
  appendBuffer(_buf,_reldate),
  appendBuffer(_buf,') \n'),

  appendBuffer(_buf,'*\n'),
  appendModuleComments(_buf,_mod),

  appendBuffer(_buf,_end),
  appendBuffer(_buf,'\n\n'),

  appendBuffer(_buf,_start),
  appendBuffer(_buf,'$set module='),
  appendBuffer(_buf,_cp),
  appendBuffer(_buf,_end),
  appendBuffer(_buf,'\n\n'),
  !.


initHeader_internal(_buf,_mod,_cp) :-
  pc_recorded(user,'AuxAnswerParameter',_u),
  pc_recorded(transactiontime,'AuxAnswerParameter',_tt),
  cb_version(_cbversion),
  cb_date_of_release(_reldate),
  getModulePath(_mpath),
  pc_atom_to_term(_cp,_mpath),
  keyCommentChars(_start,_end), 
  appendBuffer(_buf,_start),
  appendBuffer(_buf,'\n'),
  appendBuffer(_buf,'* Module: '),
  appendBuffer(_buf,_cp),{* appendBuffer(_buf,'.sml'), *}
  appendBuffer(_buf,'\n'),
  appendBuffer(_buf,'* ---------------------------------------------------------\n'),

  appendBuffer(_buf,'* This file has been extracted from a ConceptBase database.\n'),
  appendBuffer(_buf,'* Copyright is with the respective authors!\n\n'),

  appendBuffer(_buf,'* Time extracted: '),
  appendBuffer(_buf,_tt),
  appendBuffer(_buf,' (UTC) \n'),

  appendBuffer(_buf,'* Active user: '),
  appendBuffer(_buf,_u),
  appendBuffer(_buf,'\n'),

  appendBuffer(_buf,'* CBserver version: '),
  appendBuffer(_buf,_cbversion),
  appendBuffer(_buf,' ('),
  appendBuffer(_buf,_reldate),
  appendBuffer(_buf,') \n'),

  appendBuffer(_buf,'*\n'),
  appendModuleComments(_buf,_mod),

  appendBuffer(_buf,_end),
  appendBuffer(_buf,'\n\n'),

  appendBuffer(_buf,_start),
  appendBuffer(_buf,'$set module='),
  appendBuffer(_buf,_cp),
  appendBuffer(_buf,_end),
  appendBuffer(_buf,'\n\n'),
  !.

appendModuleComments(_buf,_mod) :-
  save_setof((_label,_comment),isModuleComment(_mod,_label,_comment),_labelledcomments),
  concatComments(_labelledcomments,_atom),
  appendBuffer(_buf,_atom),
  !.
appendModuleComments(_buf,_mod).



isModuleComment(_mod,_label,_comment) :-
  getCC(Proposition,comment,_cc),
  prove_literal(P(_id,_mod,_label,_comid)),
  prove_literal(In(_id,_cc)),
  id2name(_comid,_commentstring),
  unquoteAtom(_commentstring,_comment).



concatComments([],'') :- !.



concatComments([(_label,_comment)|_rest],_result) :- 
  getFlag(currentAnswerFormat,'JSONIC'),!,
  concatComments(_rest,_result1),
  pc_atomconcat(['"',_label,'" : "',_comment,'",\n'],_line1),
  pc_atomconcat(_line1,_result1,_result),
  !.

concatComments([(_label,_comment)|_rest],_result) :- 
  concatComments(_rest,_result1),
  pc_atomconcat(['* -',_label,': ',_comment,'\n'],_line1),
  pc_atomconcat(_line1,_result1,_result),
  !.

{* never fail *}
concatComments([_|_rest],_result) :- 
  concatComments(_rest,_result).


pruneProps(_all,_pruned) :-
  pruneProps(_all,[],_pruned).

pruneProps([],_dropped,[]) :- 
  !.

pruneProps([_p|_rest],_dropped,_pruned) :-
  _p=P(_id,_x,_l,_y),
  (member(_x,_dropped);
   toBeDropped(_p)
  ),
  pruneProps(_rest,[_id|_dropped],_pruned),
  !.

pruneProps([_p|_rest],_dropped,[_p|_restpruned]) :-
  pruneProps(_rest,_dropped,_restpruned).
  
  



{* Ticket #351: Prolog 5.6 apparently sometimes fails to execute pruneProps correctly;
   Hence, we filter out some unwanted fragments by this dirty trick
*}


pruneFrags([],[]) :-
  !.


pruneFrags([_frag|_restInput],_output) :-
  fragToBeDropped(_frag),
  pruneFrags(_restInput,_output),
  !.

pruneFrags([_frag|_restInput],[_frag|_output]) :-
  pruneFrags(_restInput,_output),
  !.

{* never fail *}
pruneFrags(_x,_x).


fragToBeDropped( SMLfragment(what(_idofrule1), in_omega([]), in([class(_msfolrule)]), isa([class(_idofrule2)]), with([])) ) :-
  name2id(MSFOLrule,_msfolrule),
  id2name(_idofrule1,_name1),
  id2name(_idofrule2,_name2),
  pc_atomprefix('$',1,_name1),
  pc_atomprefix('$',1,_name2),
  !.


fragToBeDropped( SMLfragment(what(_idofrule), in_omega([]), in([class(_bdmrulecheck)]), isa([]), with([])) ) :-
  name2id(BDMRuleCheck,_bdmrulecheck),
  id2name(_idofrule,_name),
  pc_atomprefix('$',1,_name),
  !.

fragToBeDropped( SMLfragment(what(_idofrule), in_omega([]), in([class(_bdmconstraintcheck)]), isa([]), with([])) ) :-
  name2id(BDMConstraintCheck,_bdmconstraintcheck),
  id2name(_idofrule,_name),
  pc_atomprefix('$',1,_name),
  !.





printFragmentLists(_buf,[]) :- 
  appendBuffer(_buf,'\n').


{* compatibility with 2-arg version of fragments *}
printFragmentLists(_buf,[fragments(_tt,_fraglist)]) :-
  printFragmentLists(_buf,[fragments(_tt,'ruleFound',_fraglist)]). 

printFragmentLists(_buf,[fragments(_tt,_rulefound,_fraglist)]) :- 
  printFragmentList(_buf,fragments(_tt,_rulefound,_fraglist)),  {* only one fragment list to be printed *}
  !.

{* compatibility with 2-arg version of fragments *}
printFragmentLists(_buf,[fragments(_tt_fraglist),_x|_rest]) :-
  printFragmentLists(_buf,[fragments(_tt,'ruleFound',_fraglist),_x|_rest]).

printFragmentLists(_buf,[fragments(_tt,_rulefound,_fraglist),_x|_rest]) :- 
  printFragmentList(_buf,fragments(_tt,_rulefound,_fraglist)),
  printSeparator(_buf,_rulefound),
  printFragmentLists(_buf,[_x|_rest]).


printFragmentLists(_buf,[_fraglist1]) :- 
  printFragments(_buf,_fraglist1),
  appendBuffer(_buf,'\n\n').

{* compatibility with 2-arg version of fragments *}
printFragmentList(_buf,fragments(_tt,_fraglist)) :-
   printFragmentList(_buf,fragments(_tt,'ruleFound',_fraglist)).

printFragmentList(_buf,fragments(_tt,_rulefound,_fraglist)) :-
  getFlag(currentAnswerFormat,'JSONIC'),!,
  appendBuffer(_buf,'[\n'),
  printFragments(_buf,_fraglist),
  appendBuffer(_buf,']'),
  !.

printFragmentList(_buf,fragments(_tt,_fraglist)) :-
  printFragmentList(_buf,fragments(_tt,'ruleFound',_fraglist)).

printFragmentList(_buf,fragments(_tt,_rulefound,_fraglist)) :-
  printTTime(_buf,_tt),
  printFragments(_buf,_fraglist),
  !.




printSeparator(_buf,_rulefound) :-
  getFlag(currentAnswerFormat,'JSONIC'),!,
  keyFrameSep(_sep),
  appendBuffer(_buf,_sep).



{* output a transaction separator if the previously printed transaction had a rule *}
printSeparator(_buf,_rulefound) :-
  needToSplitTransaction(_rulefound),
  keyCommentChars(_start,_end),
  appendBuffer(_buf,'\n'),
  appendBuffer(_buf,_start),
  appendBuffer(_buf,'---'),
  appendBuffer(_buf,_end),
  appendBuffer(_buf,' '),
  !.

printSeparator(_buf,_) :-
  appendBuffer(_buf,'\n'),
  !.


{* if CBserver parameter -mg is set to 'split' then we always put a split comment between transactions *}
needToSplitTransaction(_rulefound) :-
  (get_cb_feature(moduleGeneration,'split');
   get_cb_feature(moduleGeneration,'replay')
  ),
  !.

{* if CBserver parameter -g is set to 'minsplit' then we put a split comment between transactions in  *}
{* a rule was found in  the first transaction. Issue #18                                              *}
needToSplitTransaction('ruleFound') :-
  get_cb_feature(moduleGeneration,'minsplit'),
  !.


printTTime(_buf,_tt) :-
  getFlag(currentAnswerFormat,'JSONIC'),!.

printTTime(_buf,_tt) :-
  (get_cb_feature(moduleGeneration,'split');
   get_cb_feature(moduleGeneration,'replay');
   get_cb_feature(moduleGeneration,'minsplit')
  ),
  keyCommentChars(_start,_end), 
  appendBuffer(_buf,_start),
  appendBuffer(_buf,' '),
  appendBuffer(_buf,_tt),
  appendBuffer(_buf,' '),
  appendBuffer(_buf,_end),
  appendBuffer(_buf,'\n\n'),
  !.


printTTime(_buf,_tt) :-
  appendBuffer(_buf,'\n\n'),
  !.




printFragment(_buf,_frag) :- 
  getFlag(currentAnswerFormat,'JSONIC'),
  timeFragment(_frag,_time,_user),
  !.

printFragment(_buf,_frag) :- 
  timeFragment(_frag,_time,_user),
  _user == 'no_user',
  timetoatom('noniso',_time,_at),
  keyCommentChars(_start,_end),
  appendBuffer(_buf,_start),
  appendBuffer(_buf,' '),
  appendBuffer(_buf,_at),
  appendBuffer(_buf,' '),
  appendBuffer(_buf,_end),
  appendBuffer(_buf,'\n'),
  !.

printFragment(_buf,_frag) :- 
  timeFragment(_frag,_time,_user),
  get_cb_feature(moduleGeneration,'replay'),
  timetoatom('list',_time,_at),
  keyCommentChars(_start,_end),
  appendBuffer(_buf,_start),
  appendBuffer(_buf,'$transaction '),
  appendBuffer(_buf,_at),
  appendBuffer(_buf,';'),
  appendBuffer(_buf,_user),
  appendBuffer(_buf,_end),
  appendBuffer(_buf,'\n'),
  !.

printFragment(_buf,_frag) :- 
  timeFragment(_frag,_time,_user),
  !.


printFragment(_buf,_frag) :-
  changeIdentifierExp(_frag,insertSelectExpression,_fragSel),
  build_frame(_fragSel,_buf),
  !.


printFragments(_buf,[]) :- 
  !.


printFragments(_buf,[_frag]) :- 
  printFragment(_buf,_frag),
  appendBuffer(_buf,'\n'),  {* last in a list *}
  !.


printFragments(_buf,[_frag1|[_x|_rest]]) :- 
  printFragment(_buf,_frag1),
  keyFrameSep(_sep),
  appendBuffer(_buf,_sep),!,
  printFragments(_buf,[_x|_rest]).






timeFragment(_frag,_time,_user) :-
  _frag = SMLfragment(what(_tid),
                        in_omega([]),
                        in([class(_tt)]),
                        isa([]),
                        with(_withlist)),
  id2name(_tt,'TransactionTime'),
  id2name(_tid,_tat),
  pc_atomconcat('"',_suffix,_tat),
  pc_atomconcat(_stripped,'"',_suffix),
  pc_atom_to_term(_stripped,_time),
  _time=tt(_),
  getUserFromWithlist(_withlist,_user),
  !.

getUserFromWithlist([],'no_user') :-
  !.

getUserFromWithlist([attrdecl(_attrcatlist,_propertylist)|_rest],_user) :-
  member(property('creator',_userid),_propertylist),
  id2name(_userid,_user),
  !.
getUserFromWithlist([_|_rest],_user) :-
  getUserFromWithlist(_rest,_user).
getUserFromWithlist(_,'no_user').




{* Determine the time of the last transaction that changed the database *}
{* This is the timestamp characterizing the listModule snapshot.        *}
{* The time is represented as floating point number encoding the years  *}
{* For example, 2014.50 is exactly 365.25/2 days after the start of the *}
{* year 2014.                                                           *}
{* The precision of floating point numbers should be enough to          *}
{* distinguish two consecutive database states separated by a single    *}
{* transaction.                                                         *}

getLastTTime(_ttime) :-
  name2id('TransactionTime',_TransactionTime),   {* use versioned query name to allow hotfixes *}
  save_bagof(_x,prove_literal(In(_x,_TransactionTime)),_ttidlist),
  ttidlist2ttimes(_ttidlist,_ttimes),
  getLastTTime(_ttimes,_ttime),
  !.
getLastTTime(0.0).

ttidlist2ttimes([],[]) :- !.

ttidlist2ttimes([_ttid|_restinput],[_tt|_restoutput]) :- 
  id2name(_ttid,_ttname),
  pc_atomconcat('"',_ttatom1,_ttname),
  pc_atomconcat(_ttatom,'"',_ttatom1),
  pc_save_atom_to_term(_ttatom,_milli),
  milli2real(_milli,_tt),
  ttidlist2ttimes(_restinput,_restoutput).


milli2real( tt(millisecond(_y,_m,_d,_h,_mi,_s,_u)),_x) :-
   _totalh is 365.25*24,
   _totalmi is _totalh * 60,
   _totals is _totalmi * 60,
   _totalu is _totals * 1000,
   _x is _y + (_m-1)/12 + _d/365.25 + _h/_totalh + _mi/_totalmi + _s/_totals + _u/_totalu.

milli2real(_,0.0).

getLastTTime([_t|_r],_max) :-
  findmax(_t,_r,_max).

findmax(_current,[],_current).

findmax(_current,[_x|_rest],_max) :-
  _current > _x,
  !,
  findmax(_current,_rest,_max).

findmax(_current,[_x|_rest],_max) :-
  findmax(_x,_rest,_max).






setNotToSave :-
  getDoNotSaveQuery(_NotToSave),
  save_bagof(_x,prove_literal(In(_x,_NotToSave)),_idlist),
{*  write('notToSave='),write(_idlist),nl, *}
  setFlag(notToSave,_idlist),
  !.

{* version as of 2018-09-02 *}
getDoNotSaveQuery(_queryid) :-
  name2id('DoNotSave_1',_queryid),   
  !.

getDoNotSaveQuery(_queryid) :-
  name2id('DoNotSave_LM',_queryid),   {* legacy version *}
  !.


toBeDropped(P(_id,_x,_l,_y)) :-
  getFlag(notToSave,_idlist),
  member(_id,_idlist),
  !.


toBeDropped(P(_id,_x,_l,_y)) :-
  attribute(P(_id,_x,_l,_y)),
  labelGenerated(_l,_y),
{*  write(labelGenerated(_l,_y)),nl, *}
  !.


{* sometimes, orpahned transaction time object are left over such as "tt(millisecond(...))" with no class and *}
{* no attributes. These are then not included in the module listing                                           *}
toBeDropped(P(_x,_x,_ttlabel,_x)) :-
  name(_ttlabel,[34, 116, 116, 40|_]),   {* _ttlabel = "tt(", so this object name is a transaction time *}
  \+ (retrieve_proposition(P(_id,_x,_n,_y)),_id \= _x),
  \+ (retrieve_proposition(P(_id,_y,_n,_x)),_id \= _y),
  !.
  
labelGenerated(_lab,_y) :-
  atom(_lab),
  pc_atomconcat(_prefix,'generated',_lab),
  !.

extractModulePropositions(_mod,_allprops) :-
  save_bagof(_prop,modprop(_mod,_prop),_allprops).


modprop(_mod,P(_id,_x,_n,_y)) :- 
  retrieve_proposition_noimport(_mod,P(_id,_x,_n,_y)).



convertPropositionsToFragments(_allprops,_fraglistoflists) :-
  splitToTransactions(_allprops,_transactions),
  transactionsToFragments(_transactions,_fraglistoflists).



transactionsToFragments([],[]) :- !.

transactionsToFragments([_trans|_resttrans],[fragments(_ttatom,_rulefound,_fraglist)|_restfraglist]) :-
  transactionToFragments(_trans,_fraglist0),
  getfirstTT(_trans,_tt),
  timetoatom(noniso,_tt,_ttatom),
  checkRuleFound(_tt,_trans,_rulefound),
  pruneFrags(_fraglist0,_fraglist),
  transactionsToFragments(_resttrans,_restfraglist).


transactionToFragments(_props,_fraglist) :-
  structureAllprops(_props,_runlist),
  convertRuns(_runlist,_fraglist),
  !.



{* issue #18: at transaction time _t, Prolog code for a rule was stored *}
checkRuleFound(_t,_proplist,'ruleFound') :-
  RuleTTime(_ruleid,tt(_t)),
  !.

checkRuleFound(_t,_proplist,_rulefound) :-
  do_checkRuleFound(_t,_proplist,_rulefound).


do_checkRuleFound(_tt,[],'noRuleFound').

{* issue #18: another indication that a rule was stored *}
do_checkRuleFound(_tt,[P(_id,_x,'*instanceof',_class)|_],'ruleFound') :-
  (_class = id_46;  {* id_46=MSFOLrule *}
   _class = id_59;  {* id_59=Class!rule *}
   _class = id_407  {* id_407=MSFOLrule!specialrule *}
  ),
  !.


do_checkRuleFound(_tt,[_|_rest],_rulefound) :-
  do_checkRuleFound(_tt,_rest,_rulefound).



convertRuns(_allruns,_fraglist) :-
  convertRuns(_allruns,[],_fraglist).

convertRuns([],_sofar,_sofar) :- !.

convertRuns([run(_p,_runprops)|_restrun],_sofar,_fraglist) :-
  convertObjectWithLinks(_p,_runprops,_fraglist1),
  append(_sofar,_fraglist1,_newsofar),
  convertRuns(_restrun,_newsofar,_fraglist).


structureAllprops([],[]) :- !.
structureAllprops(_allprops,[_run|_restruns]) :-
  extractRun(_allprops,_run,_restprops),
  structureAllprops(_restprops,_restruns).


{* orphaned frame: only attributions *}
extractRun([_prop|_rest],run(P(_x,_x1,_n1,_y1),_runprops),_restprops) :-
  _prop=P(_id,_x,_n,_y),
  \+ individual(_prop),
  retrieve_proposition(P(_x,_x,_n1,_x)),  {* we do this only for individuals *}
  doExtractRun(_x,[_prop|_rest],[],_runprops,_restprops),
  !.

extractRun([_prop|_rest],run(_prop,_runprops),_restprops) :-
  _prop=P(_id,_x,_n,_y),
  doExtractRun(_id,_rest,[],_runprops,_restprops).

doExtractRun(_id,[],_sofar,_sofar,[]) :- !.

doExtractRun(_id,[_prop|_rest],_sofar,_runprops,_restprops) :-
  sameFrameLink(_id,_sofar,_prop),
  append(_sofar,[_prop],_newsofar),
  !,
  doExtractRun(_id,_rest,_newsofar,_runprops,_restprops).

doExtractRun(_id,[_prop1,_prop2|_rest],_sofar,_runprops,_restprops) :-
  _prop1 = P(_x1,_x1,_n1,_x1),
  \+ sameFrameLink(_id,_sofar,_prop1),  {* this is a forward declaration of an individual used within the frame of _id *}
  sameFrameLink(_id,_sofar,_prop2),
  append(_sofar,[_prop2],_newsofar),
  !,
  doExtractRun(_id,[_prop1|_rest],_newsofar,_runprops,_restprops).

doExtractRun(_id,[_prop1,_prop2,_prop3|_rest],_sofar,_runprops,_restprops) :-
  _prop1 = P(_x1,_x1,_n1,_x1),
  _prop2 = P(_id1,_x1,'*instanceof',_c1),
  \+ sameFrameLink(_id,_sofar,_prop1),  {* this is a forward declaration of a value used within the frame of _id *}
  \+ sameFrameLink(_id,_sofar,_prop2),  {* and this is the class of te value (e.g. Integer)                      *}
  sameFrameLink(_id,_sofar,_prop3),
  append(_sofar,[_prop3],_newsofar),
  !,
  doExtractRun(_id,[_prop1,_prop2|_rest],_newsofar,_runprops,_restprops).

doExtractRun(_id,[_prop|_rest],_sofar,_sofar,[_prop|_rest]).
  




convertObjectWithLinks(P(_id,_x,_l,_p),_props,[]) :-
  toBeDropped(P(_id,_x,_l,_p)),
  !.

{* orphaned instantiations *}
convertObjectWithLinks(P(_id,_x,'*instanceof',_c),[],[_fragment]) :-
  makeSimpleFragment(P(_id,_x,'*instanceof',_c),_fragment),
  !.

{* orphaned specializations *}
convertObjectWithLinks(P(_id,_c,'*isa',_d),[],[_fragment]) :-
  makeSimpleFragment(P(_id,_c,'*isa',_d),_fragment),
  !.

{* all others *}
convertObjectWithLinks(P(_x,_x1,_n,_x2),_props,_fragments) :-
  makeFragment(_x,_props,_fragment1),
  makeResultFragments(P(_x,_x1,_n,_x2),_fragment1,_fragments),
  !.


{* individuals *}
makeResultFragments(P(_x,_x,_n,_x),_fragment,[_fragment]) :- !.

makeResultFragments(P(_id,_x,_n,_y),_fragment,_fragments) :-
  attribute(P(_id,_x,_n,_y)),
  convertToAttribution(P(_id,_x,_n,_y),_fragment,_fragments),
  !.

makeResultFragments(P(_id,_x,'*instanceof',_c),_fragment,[]) :-
  getFlag(notToSave,_idlist),
  member(_x,_idlist),
  !.

makeResultFragments(P(_id,_x,'*isa',_c),_fragment,[]) :-
    getFlag(notToSave,_idlist),
  member(_x,_idlist),
  !.
  

makeResultFragments(P(_id,_x,_n,_y),_fragment,[_fragment1,_fragment]) :-
  makeSimpleFragment(P(_id,_x,_n,_y),_fragment1),
  !.

makeSimpleFragment(P(_id,_x,_n,_y),_fragment) :-
  attribute(P(_id,_x,_n,_y)),
  _fragment=SMLfragment(what(_x),
                        in_omega([]),
                        in([]),
                        isa([]),
                        with([attrdecl([attribute],[property(_n,_y)])])),
  !.

makeSimpleFragment(P(_id,_x,'*instanceof',_c),_fragment) :-
  _fragment=SMLfragment(what(_x),
                        in_omega([]),
                        in([class(_c)]),
                        isa([]),
                        with([])),
  !.

makeSimpleFragment(P(_id,_c,'*isa',_d),_fragment) :-
  _fragment=SMLfragment(what(_c),
                        in_omega([]),
                        in([]),
                        isa([class(_d)]),
                        with([])),
  !.


convertToAttribution(P(_id,_x,_n,_y),_fragment,[]) :-
  _fragment=SMLfragment(what(_id),
                        in_omega([]),
                        in(_classes),
                        isa([]),
                        with([])),
  labelGenerated(_n,_y), 
  !.


convertToAttribution(P(_id,_x,_n,_y),_fragment,[_afragment]) :-
  _fragment=SMLfragment(what(_id),
                        in_omega([]),
                        in(_classes),
                        isa([]),
                        with([])),
  classesToCategories(_classes,_cats),
  _afragment=SMLfragment(what(_x),
                        in_omega([]),
                        in([]),
                        isa([]),
                        with([attrdecl(_cats,[property(_n,_y)])])),
  !.


classesToCategories([],[attribute]) :-
  !.

classesToCategories(_classes,_cats) :-
  doClassesToCategories(_classes,_cats).

doClassesToCategories([],[]) :- !.

doClassesToCategories([class(_cat)|_restclasses],[_m|_restcats]) :-
  retrieve_proposition(P(_cat,_c,_m,_d)),
  attribute(P(_cat,_c,_m,_d)),
  doClassesToCategories(_restclasses,_restcats).



makeFragment(_x,_props,_fragment) :-
  collectClasses(_x,_props,_classes1),
  augmentClasses(_x,_classes1,_classes), {* issue #25 *}
  collectSuperClasses(_x,_props,_superclasses),
  collectAttrDecls(_x,_props,_attrdecls),
  _fragment=SMLfragment(what(_x),
                        in_omega([]),
                        in(_classes),
                        isa(_superclasses),
                        with(_attrdecls)),
  !.


collectClasses(_x,_props,_classes) :-
  collectClasses('*instanceof',_x,_props,[],_classes).

collectSuperClasses(_x,_props,_classes) :-
  collectClasses('*isa',_x,_props,[],_classes).


collectClasses(_InIsa,_x,[],_classes,_classes) :- !.

collectClasses(_InIsa,_x,[P(_id,_x,_InIsa,_c)|_rest],_sofar,_classes) :-
  append(_sofar,[class(_c)],_new_sofar),
  !,
  collectClasses(_InIsa,_x,_rest,_new_sofar,_classes).

collectClasses(_InIsa,_x,[_|_rest],_sofar,_classes) :-
  collectClasses(_InIsa,_x,_rest,_sofar,_classes).


{* Issue #25: fragments without any class get their stored classes to avoid Telos code  *}
{* that cannot be told again after a RETELL has separated the class definition from the *}
{* definition of an attribute                                                           *}
augmentClasses(_x,[],_classes) :-
  save_setof(class(_c),prove_literal(In_s(_x,_c)),_classes),
  !.
augmentClasses(_x,_classes,_classes).


makeClasslist([],[]).
makeClasslist([_id|_restids],[class(_id)|_restclasses]) :-
  makeClasslist(_restids,_restclasses).



collectAttrDecls(_x,_props,_attrdecls) :-
  getAttributes(_props,_attributes),
  makePropcats(_attributes,_props,_propcats),
  compose_attrdecllist(_propcats,_attrdecls),
  !.


getAttributes([],[]) :- !.

getAttributes([_prop|_restprops],[_prop|_restattrs]) :-
  attribute(_prop),
  !,
  getAttributes(_restprops,_restattrs).

getAttributes([_prop|_restprops],_restattrs) :-
  getAttributes(_restprops,_restattrs).

makePropcats([],_props,[]) :- !.


makePropcats([_attr|_restattr],_props,_restpropcats) :-
  _attr=P(_id,_x,_l,_y),
  labelGenerated(_l,_y),
  !,
  makePropcats(_restattr,_props,_restpropcats).


makePropcats([_attr|_restattr],_props,[propcat(_catlist,_attr)|_restpropcats]) :-
  getCategories(_attr,_props,_catlist),
  makePropcats(_restattr,_props,_restpropcats).


getCategories(_attr,_props,_catlist) :-
  doGetCategories(_attr,_props,_catlist),
  _catlist \= [],
  !.

getCategories(_attr,_props,[attribute]) :-
  !.

doGetCategories(P(_id,_x,_l,_y),[],[]) :- !.

doGetCategories(P(_id,_x,_l,_y),[P(_id2,_id,'*instanceof',_cat)|_restprops],[_m|_restcats]) :-
  retrieve_proposition(P(_cat,_c,_m,_d)),
  attribute(P(_cat,_c,_m,_d)),
  !,
  doGetCategories(P(_id,_x,_l,_y),_restprops,_restcats).

doGetCategories(P(_id,_x,_l,_y),[_|_restprops],_restcats) :-
  doGetCategories(P(_id,_x,_l,_y),_restprops,_restcats).
  


{* ticket #350: attributes of x that have other attributes of x as values shall *}
{* be included in a separate run.                                               *}
sameFrameLink(_x,_sofar,P(_id,_x,_n,_ida)) :-
  member(P(_ida,_x,_n1,_y),_sofar),
  attribute(P(_ida,_x,_n1,_y)),
  !,
  fail.

sameFrameLink(_x,_sofar,P(_id,_x,_n,_y1)) :-
  !.



sameFrameLink(_x,_sofar,P(_id,_ida,'*instanceof',_ac)) :-
  member(P(_ida,_x,_n,_y),_sofar),
  attribute(P(_ida,_x,_n,_y)),
  retrieve_proposition(P(_ac,_c,_m,_d)),
  attribute(P(_ac,_c,_m,_d)),
  !.
  



{* save content of a whole module tree               *}
{* implements part of ticket #274                    *}
{* saveModuleTree is called in CBserverInterface.pro *}

saveModuleTree(yes,_mod) :-
  get_cb_feature(exportDir,_exportdir),
  get_cb_feature(viewDir,_viewdir),
  (_exportdir \= none ; _viewdir \= none),  {* so, something might need to be saved *}
  pc_erase(SAVED_MODULES),
  pc_record(SAVED_MODULES,[]),
  toId(_mod,_modid),
  informTrace(_exportdir,_viewdir),
  pc_time(visitModuleTree(_exportdir,_viewdir,_modid),_tsave),
  informTime(_exportdir,_viewdir,_tsave),
  executePostExportCommand.   {* to further transform exported query results if applicable *}

saveModuleTree(no,_modid).  {* never fail *}

informTrace(_exportdir,_viewdir) :-
  informOnTrace(_exportdir, 'Exporting module sources to directory '),
  informOnTrace(_viewdir, 'Saving views to directory '),
  !.

informOnTrace(none,_) :- !.
informOnTrace(_dir,_text) :-
  WriteTrace(low,ConfigurationUtilities,[_text,_dir, ' ...']),
  !.
informOnTrace(_dir,_text).


informTime(none,none,_tsave) :- !.

informTime(_exportdir,_viewdir,_tsave) :-
  WriteTrace(low,ConfigurationUtilities,[_tsave, ' sec used for saving/exporting module tree']),
  !.



{* single module case: save only a single module *}
saveSingleModule(yes,_mod) :-
  toId(_mod,_modid),
  get_cb_feature(exportDir,_exportdir),
  get_cb_feature(viewDir,_viewdir),
  pc_recorded(_modid,MODULE_UPDATES,_nr),
  _nr \= 0,
  handleSaveModule(_exportdir,_modid),
  handleSaveView(_viewdir,_modid),
  pc_rerecord(_modid,MODULE_UPDATES,0),     {* reset number of updating transactions since last save *}
  !.

saveSingleModule(no,_mod).
  



visitModuleTree(none,none,_modid) :- !.

visitModuleTree(_exportdir,_viewdir,_modid) :-
  pc_recorded(_modid,MODULE_UPDATES,0),   {* 0 updates to this module since last save *}
  pc_recorded(SAVED_MODULES,_visited),
  \+ member(_modid,_visited),
  pc_rerecord(SAVED_MODULES,[_modid,_visited]),
  switchModule(_modid),
  !,
  visitSubModulesOf(_exportdir,_viewdir,_modid).

visitModuleTree(_exportdir,_viewdir,_modid) :-
  pc_recorded(SAVED_MODULES,_visited),
  \+ member(_modid,_visited),
  switchModule(_modid),
  handleSaveModule(_exportdir,_modid),
  handleSaveView(_viewdir,_modid),
  pc_rerecord(SAVED_MODULES,[_modid,_visited]),
  pc_rerecord(_modid,MODULE_UPDATES,0),     {* reset number of updating transactions since last save *}
  visitSubModulesOf(_exportdir,_viewdir,_modid).

visitModuleTree(_exportdir,_viewdir,_modid).


{* save the Telos sources of module _modid to the filesystem at _exportdir *}
handleSaveModule(none,_modid) :- !.  {* nothing to be done *}
handleSaveModule(_exportdir,_modid) :-
  listModuleContent_internal(_frames,_modid,_modpath),
  saveFramesToFile(_exportdir,_frames,_modpath),
  !.
handleSaveModule(_exportdir,_modid). {* never fail *}



{* saving query results in specific answer formats; ticket #275 *}
handleSaveView(none,_modid) :- !.  {* nothing to be done *}

handleSaveView(_viewdir,_modid) :-
  updateCurrentmoduleParameter(_modid),
  save_setof(_q,prove_literal(A(_modid,Module,saveView,_q)),_queries),
  saveQueries(_viewdir,_modid,_queries).

handleSaveView(_viewdir,_modid).  {* never fail *}

{* to provide current values for the module name and path used in AnswerFormats *}
updateCurrentmoduleParameter(_modid) :-
  id2name(_modid,_modname),
  getModulePath(_modid,_modpath),
  pc_save_atom_to_term(_modpathatom,_modpath),
  addAnswerParameters('AuxAnswerParameter',[_modname/currentmodule,_mpathatom/currentpath]),
  !.
updateCurrentmoduleParameter(_modid).



saveQueries(_viewdir,_modid,[]) :- !.

saveQueries(_viewdir,_modid,[_q|_rest]) :-
  saveQuery(_viewdir,_modid,_q),
  saveQueries(_viewdir,_modid,_rest).

{* query q has a single parameter *}
saveQuery(_viewdir,_modid,_q) :-
  getQueryCallInfoWithParam(_q,_param,_class,_format,_filetype),
  !,
  save_setof(_x,prove_literal(In(_x,_class)),_extension),
  loopExtension(_viewdir,_modid,_q,_param,_extension,_format,_filetype).

{* query q has no parameter *}
saveQuery(_viewdir,_modid,_q) :-
  getQueryCallInfoWithoutParam(_q,_format,_filetype),
  createQueryCall(_q,_format,_querycall),
  processSingleQuery(_modid,_viewdir,_filetype, _querycall).


getQueryCallInfoWithParam(_q,_param,_class,_format,_filetype) :-
  prove_literal(A_label(_q,parameter,_class,_param)),  {* a single parameter *}
  prove_literal(A(_format,AnswerFormat,forQuery,_q)),
  getFileType(_format,_filetype).


getQueryCallInfoWithoutParam(_q,_format,_filetype) :-
  \+ prove_literal(A_label(_q,parameter,_class,_param)),  {* query has no paramter parameter *}
  prove_literal(A(_format,AnswerFormat,forQuery,_q)),
  getFileType(_format,_filetype).



getFileType(_format,_filetype) :-
  prove_literal(A(_format,AnswerFormat,fileType,_t)),
  makeName(_t,_quotedfiletype),
  unquoteAtom(_quotedfiletype,_filetype),
  !.
{* use 'txt' if no filetype is specified *}
getFileType(_format,'txt').



loopExtension(_viewdir,_modid,_q,_param,[],_format,_filetype) :- !.

loopExtension(_viewdir,_modid,_q,_param,[_x|_rest],_format,_filetype) :-
  createQueryCall(_q,_x,_param,_format,_querycall),
  processSingleQuery(_modid,_viewdir,_filetype, _querycall),
  loopExtension(_viewdir,_modid,_q,_param,_rest,_format,_filetype).


{* no parameter *}
createQueryCall(_q,_format,_querycall) :-
  _querycall=ask(_objnamelist,_format),
  _objnamelist = [_q].

{* single parameter *}
createQueryCall(_q,_x,_param,_format,_querycall) :-
  _querycall=ask(_objnamelist,_format),
  _objnamelist=[derive(_q,_paramSubstitutes)],
  _paramSubstitutes=[substitute(_x,_param)].


processSingleQuery(_modid,_viewdir,_filetype,_querycall) :-
  createBuffer(_buf),
  WriteTrace(low,ConfigurationUtilities,['Evaluating saveView query ',idterm(_querycall)]),
  process_query(_querycall,_buf),
  getStringFromBuffer(_text,_buf),
  saveQueryResultsToFile(_modid,_querycall,_viewdir,_filetype,_text).
  
  


visitSubModulesOf(_exportdir,_viewdir,_modid) :-
  save_setof(_m,isSubModuleOf(_m,_modid),_submods),
  do_visitSubModules(_exportdir,_viewdir,_submods).


do_visitSubModules(_exportdir,_viewdir,[]).

do_visitSubModules(_exportdir,_viewdir,[_m|_rest]) :-
  visitModuleTree(_exportdir,_viewdir,_m),
  do_visitSubModules(_exportdir,_viewdir,_rest).


isSubModuleOf(_sub,_super) :-
  name2id('Module',_Module),
  prove_literal(In_e(_sub,_Module)),
  prove_literal(A(_super,Module,contains,_sub)).








{* The reverse of saveModuleTree is loadModuleTree. *}
{* It loads a module tree from the importDir        *}

loadModuleTree(yes) :-
  get_cb_feature(moduleSeparator,'-'),
  get_cb_feature(importDir,_importdir),
  _importdir \= 'none',
  dir_list(_importdir,_all),
  extractModuleFiles(_all,_only_sml),
  quicksortLabels(_only_sml,_files_sorted),
{*  reverse(_files_sorted,_files), *}
  prependImportDir(_importdir,_files_sorted,_absfilenames),
  thisToolId(_tid),  {* this is the CBserver itself; the CBserver asks itself to load the SML files *}
  getModule(_origModule),
  processSmlFileImport(_tid,_absfilenames),
  setModule(_origModule),
  !.

{* ticket #372: load variant of module sources are in sub-directories *}
loadModuleTree(yes) :-
  get_cb_feature(moduleSeparator,'/'),
  get_cb_feature(importDir,_importdir),
  _importdir \= 'none',
  getModule(_origModule),
  loadFromDir(0,_importdir),  {* will traverse recursively to sub-directories *}
  setModule(_origModule),
  !.

loadModuleTree(no).


{* load all *.sml files in _dir *}
loadFromDir(_level,_dir) :-
  _level < 10,  {* maximum depths of sub-directories that we traverse to avoid infinite loops with symlinks *}
  dir_list(_dir,_entries),
  extractModuleFiles(_entries,_only_sml),
  quicksortLabels(_only_sml,_files_sorted),
  createAbsFileList(_dir,_files_sorted,_absfilenames),
  thisToolId(_tid),  {* this is the CBserver itself; the CBserver asks itself to load the SML files *}
  processSmlFileImport(_tid,_absfilenames),
  createAbsDirList(_dir,_entries,_absdirs),
  _newlevel is _level + 1,
  loadFromAllDirs(_newlevel,_absdirs).  {* traverse to sub-directories *}

loadFromDir(_level,_dir) :- 
   write('ConfigurationUtilities.pro: ERROR in loadFromDir, maxlevel reached: '),write(_dir),
   !.

loadFromAllDirs(_level,[]).
loadFromAllDirs(_level,[_dir|_rest]) :-
  loadFromDir(_level,_dir),  {* this is the recursive call for the sub-directory *}
  loadFromAllDirs(_level,_rest).



createAbsFileList(_dir,[],[]).

{* concatenate the _dir and the filenames in the list, note that
   extractModuleFile has stripped the .sml from the filename, so we need to
   add it again
*}
createAbsFileList(_dir,[_filename|_rest],[_absfilename|_restabs]) :-
  dirSeparator(_sep),
  pc_atomconcat([_dir,_sep,_filename,'.sml'],_absfilename),
  createAbsFileList(_dir,_rest,_restabs).

createAbsFileList(_dir,[_|_rest],_restabs) :-
  createAbsFileList(_dir,_rest,_restabs).


{* concatenate the _dir and the directory names in the list *}
createAbsDirList(_dir,[],[]).

createAbsDirList(_dir,[_entry|_restentries],[_absdir|_restabsdirs]) :-
  dirSeparator(_sep),
  pc_atomconcat([_dir,_sep,_entry],_absdir),
  pc_exists_directory(_absdir),
  createAbsDirList(_dir,_restentries,_restabsdirs).

createAbsDirList(_dir,[_|_restentries],_restabsdirs) :-
  createAbsDirList(_dir,_restentries,_restabsdirs).






{* produce absolute file names, only used when module separatir is '-' *}
prependImportDir(_importdir,[],[]).

prependImportDir(_importdir,[_name|_rest],[_absname|_restabs]) :-
  buildAbsoluteFilePath(_importdir,_name,_absname),
  prependImportDir(_importdir,_rest,_restabs).



{* extractModuleFile will only return files whose names begin with 'System' and *}
{* end with '.sml'. So, these are the module files.                             *}
extractModuleFiles([],[]).

extractModuleFiles([_filename|_rest],[_stripped_filename|_restPruned]) :-
  isModuleFilename(_filename,_stripped_filename),
  !,
  extractModuleFiles(_rest,_restPruned).


extractModuleFiles([_filename|_rest],_restPruned) :-
  extractModuleFiles(_rest,_restPruned).


isModuleFilename(_filename,_stripped_filename) :-
  get_cb_feature(moduleSeparator,'-'),
  !,
  sourceModelFilename(_filename,_stripped_filename),
  pc_atomconcat('System',_postfix,_filename).  {* starts with 'System' *}

{* ticket #372: if module separator is not '-', then we accept any sml file *}
isModuleFilename(_filename,_stripped_filename) :-
  sourceModelFilename(_filename,_stripped_filename).


{* ends with .sml  *}
sourceModelFilename(_filename,_stripped_filename) :-
  pc_atomconcat(_stripped_filename,'.sml',_filename).


{* do the TELL_MODEL by hooking to the CBserver interface function TELL_MODEL *}
{* This will atart a new transaction for each file in the list.               *}
{* TELL_MODEL could also handle several files but only if they are loaded     *}
{* to the same module. Our module files have a 'set module' directive.        *}
{* Hence, we need to load them one by one. So, the argument of TELL_MODEL is  *}
{* a list with one filename: [_filename]                                      *}

processSmlFileImport(_,[]).

processSmlFileImport(_cbserver,[_filename|_rest]) :-
  processSingleSmlFile(_cbserver,_filename),
  processSmlFileImport(_cbserver,_rest).

processSingleSmlFile(_cbserver,_filename) :-
  handle_message(ipcmessage(_cbserver,_cbserver,TELL_MODEL,[[_filename]]),ipcanswer(_s,_compl,_rt)),
  !.

processSingleSmlFile(_cbserver,_filename).  {* never fail *}



