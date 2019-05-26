{*
The ConceptBase.cc Copyright

Copyright 1987-2019 The ConceptBase Team. All rights reserved.

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
* File:         ModelConfiguration.pro
* Version:      11.3
*
*
* Date released : 97/01/20  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.ModelConfiguration.pro
* Date retrieved : 97/05/13 (YY/MM/DD)
 -----------------------------------------------------------------------------
*
*  Exported predicates:
*  --------------------
*
*   + load_model(_modelname)
*   + load_application/2
*   + remove_models/0
*   + get_application(_appname)
*   + application_active/0
*
*   04-Aug-1989 MSt : adaptions for new CB architecture
*   24-Aug-1989 AM : '*NoMetaLabel' instead of property in clear_knowledgebase
*   30-Oct-1989 MSt : clear_knowledgebase implies deletion of asserted PROLOG
*                     clauses (generated from rules)
*   02-Mar-1990 MSt : SearchSpace is set before loading models possibly
*                     direct from prop - files and before removing models
*
* 21.08.1990 RG :       clear_knowledgebase adapted to be independent from
*                       proposition form.
*                       Bug fixing: remove_models no longer uses LoadSC !
*
*   31-Aug-1990 AM : relicts of LiteralProcessor removed
*
*   21-Jan-1991 AM : model loading and removing facilities adapted for
*                       persistency.
*
* 17.07.92 RG: lots of changes to the treatments of persistent Applications
*  22-Sep-1992 kvt : conversion of database to version 0.2
*  06-Oct-1992 HWN : the rules of the SYSTEM application are now included
*                    in old applications,
*
*   15-Nov-1992/MSt: kommaToListTerm/2 now defined locally insteadof
*                                           imported from new_utilities
*
*
* 16-Dec-1992:kvt: erased unused predicates load_models/2,
              loop_loading/2, kommaToListTerm/2
              new error message if loading of model fails
*
* Metaformel-Aenderungen (10.1.1996):
* neues Praedikat modus, um in MetaBDMEvaluation festzustellen
* ob man sich in einer TELL oder ASK
* Operation befindet.
* Beim ASK brauchen die Prozedurtrigger nicht
* gestestet zu werden, da sich an den betrachteten
* Extensionen nichts aendern kann
*
* 9-Dez-1996/LWEB : Lade zusaetzlich das ECA-Rulefile   SYSTEM.ecarule
}


#MODULE(ModelConfiguration)
#EXPORT(ClearAndClean/0)
#EXPORT(appFilename/3)
#EXPORT(application_active/0)
#EXPORT(check_nonpersistent/2)
#EXPORT(check_nonpersistentDefault/1)
#EXPORT(get_application/1)
#EXPORT(load_application/1)
#EXPORT(load_model/1)
#EXPORT(remove_lock/1)
#EXPORT(getModuleName/1)
#EXPORT(getModulePath/1)
#EXPORT(getModulePath/2)
#EXPORT(setModule/1)
#EXPORT(getModule/1)
#EXPORT(saveFramesToFile/3)
#EXPORT(buildAbsoluteFilePath/3)
#EXPORT(saveQueryResultsToFile/5)
#EXPORT(makeDirIfNotExists/1)
#EXPORT(removeDBifExists/1)
#EXPORT(dirExists/1)
#EXPORT(dirSeparator/1)
#EXPORT(createViewDir/2)
#EXPORT(removeLastSlash/2)
#EXPORT(executePostExportCommand/0)
#ENDMODDECL()

#IMPORT(load_appfiles/1,ConfigurationUtilities)
#IMPORT(load_sml/1,ConfigurationUtilities)
#IMPORT(set_KBsearchSpace/2,SearchSpace)
#IMPORT(report_error/3,ErrorMessages)
#IMPORT(cleanup/0,WeakPersistency)
#IMPORT(WriteTrace/3,GeneralUtilities)
#IMPORT(username/1,ExternalCodeLoader)
#IMPORT(hostname/1,ExternalCodeLoader)
#IMPORT(getpid/1,ExternalCodeLoader)
#IMPORT(get_cb_feature/2,GlobalParameters)
#IMPORT(unlink/1,ExternalCodeLoader)
#IMPORT(reportOptionErrorAndStop/1,startCBserver)
#IMPORT(operatingSystemIsWindows/0,GeneralUtilities)
#IMPORT(pc_readln/2,PrologCompatibility)
#IMPORT(pc_atomtolist/2,PrologCompatibility)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_update/1,PrologCompatibility)
#IMPORT(pc_fopen/3,PrologCompatibility)
#IMPORT(pc_fclose/1,PrologCompatibility)
#IMPORT(pc_exists/1,PrologCompatibility)
#IMPORT(pc_exists_directory/1,PrologCompatibility)
#IMPORT(pc_expand_path/2,PrologCompatibility)
#IMPORT(uniqueAtom/1,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(retrieve_proposition_noimport/2,PropositionProcessor)
#IMPORT(id2name/2,GeneralUtilities)
#IMPORT(getFlag/2,GeneralUtilities)
#IMPORT(set_cbmodule/1,BIM2C)
#IMPORT(set_persistency_level_bim2c/1,BIM2C)
#IMPORT(makeAlphanumeric/2,GeneralUtilities)
#IMPORT(prove_literal/1,Literals)

{
Aenderung Metaformeln
mit modus$TellAndAsk wird in MetaBDMEvaluation geprueft,
ob man sich in einer Tell oder Ask
Operation befindet.
Beim Ask brauchen die Prozedurtrigger
fuer Metaformeln nicht geprueft zu werden.
}
#IMPORT(SetUpdateMode/1,TellAndAsk)
#IMPORT(RemoveUpdateMode/1,TellAndAsk)
#IMPORT(makeName/2,cbserver)



#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)



{ =================== }
{ Exported predicates }
{ =================== }


{***********************  l o a d _ m o d e l  ******************************}
{                                                                            }
{ load_model (_complModelName)                                               }
{             _complModelName : ground : atom                                }
{                                                                            }
{ This predicate loads a model, which is specified by the name of the direc- }
{ tory and the name of the file (concated : _complModelName). Such a model   }
{ can be stored in files with the same name and one of the following         }
{ extensions : .pro .prop, .sfg, .sml                                        }
{ The predicate gets the dates of the last modifications of the files,       }
{ compares them and selects that which finally was modified.                 }
{                                                                            }
{ AM: Since the persistenmcy change only .sfg and .sml files are considered. }
{****************************************************************************}

load_model(_complModelName) :-
        SetUpdateMode(UPDATE),
        set_KBsearchSpace(newOB,Now),
        load_result('sml',_complModelName),
        RemoveUpdateMode(_),
        !.

load_model(_complModelName) :-
        write('Error during loading of '),
        write(_complModelName),nl,
	report_error(MCIOERR, ModelConfiguration,[_complModelName]),
        RemoveUpdateMode(_),
        !,fail.


{ ******************** l o a d _ a p p l i c a t i o n ******************** }
{                                                                           }
{ load_application(_appname)                                                }
{   _appname: atom                                                          }
{                                                                           }
{ load_application prepares loading of files with name _appname and         }
{ extensions .prop, .hprop, .rule ,if                                       }
{ such a .prop file exists. Otherwise only the current application will     }
{ be changed. If necessary an old application will be removed.              }
{                                                                           }
{ ************************************************************************* }

check_application(_appname) :-
   appFilename('prop',_appname,_target),
   not(pc_exists(_target)).

check_application(_appname) :-
   nl,
   ClearAndClean,
   reportOptionErrorAndStop('An incompatible application file was found!\nDelete the old application!').

check_lock(_appname) :-
   appFilename('lock',_appname,_target),
   not(pc_exists(_target)),
   !,
   hostname(_hname),
   getpid(_pid),
   pc_atomconcat([_hname,', PID ',_pid,'\n'],_namepid),
   pc_fopen(_fp,_target,w),
   write(_fp,_namepid),
   pc_fclose(_fp),
   !.

check_lock(_appname) :-
   appFilename('lock',_appname,_target),
   pc_fopen(_fp,_target,r),
   pc_readln(_fp,_who),
   pc_fclose(_fp),
   pc_atomconcat(['Database is locked by ',_who],_target2),
   reportOptionErrorAndStop(_target2).

remove_lock(_appname) :-
   appFilename('lock',_appname,_target),
   pc_exists(_target),
   unlink(_target).

remove_lock(_appname).


load_application(_appname) :-
   appFilename('telos',_appname,_target),
   pc_exists(_target),
   !,
   open_application(_appname).

load_application(_appname) :-
   create_application(_appname),
   !,
   open_application(_appname).

create_application(_appname) :-
   check_application(_appname),
   WriteTrace(low,ModelConfiguration,
              ['Creating new database ',_appname,' ...']),
   copy_sysapp(_appname).

open_application(_appname) :-
   pc_update(CurrentApplication(_appname)),
   check_lock(_appname),
   check_application(_appname),
   load_result(app,_appname),
   set_persistency,  {* ticket #319 *}
   !.

set_persistency :-
  get_cb_feature('UpdateMode',nonpersistent),
  set_persistency_level_bim2c(0),  {* level 0: set the object store libCos3/TDB.cc to non-persistent mode *}
  !.
set_persistency.



application_active :-
   CurrentApplication(_n),
   _n\==noapp,
   !.

copy_sysapp(_appname) :-
    makeDirIfNotExists(_appname),
    getCopyCommand(_copycmd),
    { Make directory }

    exists_or_abort(_appname),
    { Copy SYSTEM.telos }
    appFilename('telos',_appname,_telos2),
    addQuotes(_telos2,_telosq),
    sysFilename(telos,_telos1),
    append(_copycmd,[_telos1,_telosq],_cptelos),
    execCommand(_cptelos),
    exists_or_abort(_telos2),
    { Copy SYSTEM.symbol }
    appFilename('symbol',_appname,_symbol2),
    addQuotes(_symbol2,_symbolq),
    sysFilename(symbol,_symbol1),
    append(_copycmd,[_symbol1,_symbolq],_cpsymbol),
    execCommand(_cpsymbol),
    exists_or_abort(_symbol2),
    { Copy SYSTEM.rule }
    appFilename('rule',_appname,_rule2),
    addQuotes(_rule2,_ruleq),
    sysFilename(rule,_rule1),
    append(_copycmd,[_rule1,_ruleq],_cprule),
    execCommand(_cprule),
    exists_or_abort(_rule2),

    { SYSTEM.builtin is now longer needed; ticket #256 }

    { Copy SYSTEM.ecarule }
    appFilename('ecarule',_appname,_ecarule2),
    addQuotes(_ecarule2,_ecaruleq),
    sysFilename(ecarule,_ecarule1),
    append(_copycmd,[_ecarule1,_ecaruleq],_cpecarule),
    execCommand(_cpecarule),
    exists_or_abort(_ecarule2),
    { Copy SYSTEM.ruleinfo }
    appFilename('ruleinfo',_appname,_ruleinfo2),
    addQuotes(_ruleinfo2,_ruleinfoq),
    sysFilename(ruleinfo,_ruleinfo1),
    append(_copycmd,[_ruleinfo1,_ruleinfoq],_cpruleinfo),
    execCommand(_cpruleinfo),
    exists_or_abort(_ruleinfo2),
    doChmod(_appname,[rule,ecarule,ruleinfo,symbol,telos]),  {* take care of write permissions *}
    { Copy *.lpi }
    copyLpiFiles('$CBL_DIR',_appname).



{* If ConceptBase is started from Unix/Linux via a read-only medium (CD-ROM), *}
{* then the files OB.rule,OB.symbol,etc. copied from lib/system have          *}
{* read-only permissions. This causes ConceptBase to crash since it needs to  *}
{* update the database, even when it is in the temporary directory /tmp.      *}
{* We thus execute a 'chmod u+w ' if the OS is not Windows.                   *}
{* Windows has no problems with write permissions on the files.               *}

doChmod(_,_) :-
   {* do nothing if ... *}
   (
      operatingSystemIsWindows               {* ... OS=windows *}
   ),
   !.


{* now, the OS is Linux, Solaris, or Mac-OS X. So, the chmod command should be known *}
doChmod(_,[]) :- !.

doChmod(_appname,[_filetype|_rest]) :-
  doSingleChmod(_appname,_filetype),
  doChmod(_appname,_rest).

doSingleChmod(_appname,_filetype) :-
   pc_atomconcat([_appname,'/OB.',_filetype],_OBfile),
   addQuotes(_OBfile,_OBfileq),
   _chmodOB=['/bin/chmod', 'u+w', _OBfile],   {* set write permission on OBfile *}
   execCommand(_chmodOB),
   !.
doSingleChmod(_,_).



makeDirIfNotExists(_dir) :-
    pc_exists(_dir),
    !.
makeDirIfNotExists(_dir) :-
    getMkdirCommand(_mkdircmd),
    addQuotes(_dir,_dirq),
    append(_mkdircmd,[_dirq],_mkdir),
    execCommand(_mkdir),
    !.


{* remove a database directory *}
removeDBifExists(_dir) :-
    pc_exists(_dir),
    WriteTrace(low,ModelConfiguration,
              ['Removing old database ',_dir,' ...']),
    getRemoveCommand(_remcmd),
    append(_remcmd,[_dir],_rmdir),
    execCommand(_rmdir),
    removeDir(_appname),
    !.
removeDBifExists(_).


execCommand(_commandAndArgs) :-
    buildCommandString(_commandAndArgs,_cmdstr),
#IF(BIM)
    shell(_status,_cmdstr),
#ELSE(BIM)
   shell(_cmdstr,_status),
#ENDIF(BIM)
   reportShellStatus(_status,_cmdstr),
   !.

reportShellStatus(0,_cmdstr) :-
   WriteTrace(high,ModelConfiguration,
                   ['Executed ',_cmdstr]),
   !.
reportShellStatus(_status,_cmdstr) :-
   WriteTrace(high,ModelConfiguration,
                   ['Error ',_status,' in ',_cmdstr]),
   !.
reportshellStatus(_,_).  {* never fail *}


buildCommandString([],'').
buildCommandString([_c|_r],_a) :-
    buildCommandString(_r,_a1),
    pc_atomconcat([_c,' ',_a1],_a).


getMkdirCommand([_comspec,'/C','md']) :-
   operatingSystemIsWindows,
   !,
   getenv('ComSpec',_comspec).

getMkdirCommand(['/bin/mkdir']).



getCopyCommand([_comspec,'/C','copy']) :-
   operatingSystemIsWindows,
   !,
   getenv('ComSpec',_comspec).

getCopyCommand(['/bin/cp']).

getFindCommand(['/usr/bin/find']) :-
  \+ operatingSystemIsWindows.

getRemoveCommand([_comspec,'/C','del','/Q','/S']) :-
   operatingSystemIsWindows,
   !,
   getenv('ComSpec',_comspec).

getRemoveCommand(['/bin/rm','-rf']).

getRmdirCommand([_comspec,'/C','rd']) :-
   operatingSystemIsWindows,
   !,
   getenv('ComSpec',_comspec).

getRmdirCommand(['/bin/rmdir']).

exists_or_abort(_path) :-
  (pc_exists(_path);
    (WriteTrace(low,ModelConfiguration,
       ['File or directory ', _path, ' not accessible or unable to create.']),
     halt)
  ),
  !.

appFilename(_suffix,_path_app,_appfile) :-
   pc_atomconcat([_path_app,'/OB.',_suffix],_appfile1),
   replaceSlash(_appfile1,_appfile),
   !.



{* a pre-configured plain database exists: take system files form there *}
sysFilename(_suffix,_sysfile) :-
   pc_expand_path('$CB_HOME/lib/SystemDB',_systemDB),
   pc_exists(_systemDB),  
   pc_atomconcat(['$CB_HOME/lib/SystemDB/OB.',_suffix],_sysfile1),
   pc_expand_path(_sysfile1,_sysfile2),
   replaceSlash(_sysfile2,_sysfile3),
   addQuotes(_sysfile3,_sysfile),
   !.


{* otherwise: take the library SYSTEM.* files *}
sysFilename(_suffix,_sysfile) :-
#IF(BIM)
    _prologvar = '',
#ENDIF(BIM)
#IF(SWI)
    _prologvar = 'SWI.',
#ENDIF(SWI)
   pc_atomconcat(['$CBL_DIR/SYSTEM.',_prologvar,_suffix],_sysfile1),
   pc_expand_path(_sysfile1,_sysfile2),
   replaceSlash(_sysfile2,_sysfile3),
   addQuotes(_sysfile3,_sysfile),
   !.


{* for database path: if it ends with '/' or '\', then this (back-)slash can be removed *}
removeLastSlash(_path,_newpath) :-
  operatingSystemIsWindows,
  name(_bs,[92]),   {* this is the backslash; avoid escaped usage here *}
  pc_atomconcat(_newpath,_bs,_path),
  !.
{* Unix/Linux: *}
removeLastSlash(_path,_newpath) :-
  \+ operatingSystemIsWindows,
  pc_atomconcat(_newpath,'/',_path),
  !.

{* else: leave as is *}
removeLastSlash(_path,_path).




replaceSlash(_file1,_file2) :-
    operatingSystemIsWindows,
    !,
    pc_atomtolist(_file1,_list1),
    replaceSlash2(_list1,_list2),
    pc_atomtolist(_file2,_list2).

replaceSlash(_f,_f).

replaceSlash2([],[]).
replaceSlash2(['/'|_r],['\\'|_r2]) :-
    !,
    replaceSlash2(_r,_r2).

replaceSlash2([_h|_r],[_h|_r2]) :-
    replaceSlash2(_r,_r2).


{* put file paths in quotes to allow for blanks in the path *}
{* This is necessary when ConceptBase is installed in a     *}
{* directory path that contains special characters such as  *}
{* blanks. See also ticket #109.                            *}
addQuotes(_f,_qf) :-
    \+ pc_atomconcat('"',_,_f),
    \+ pc_atomconcat(_,'"',_f),
    pc_atomconcat(['"',_f,'"'],_qf),
    !.

addQuotes(_f,_f).

check_allowedness(_passwd) :-   {* currently no real check *}
  _passwd == System, !.

check_allowedness(_passwd) :-
  report_error( MCSYSPWD, ModelConfiguration, []),
  fail.


check_nonpersistentDefault(_appname) :-
	_appname \== '<none>',
	get_cb_feature('UpdateMode',unknown),
	set_cb_feature('UpdateMode',persistent),  {* open database in persistent mode if parameter -U is not specified *}
	!.

check_nonpersistentDefault(_appname) :-
	_appname == '<none>',
	get_cb_feature('UpdateMode',unknown),
	set_cb_feature('UpdateMode',nonpersistent),  {* open database in nonpersistent mode if parameter -U is not specified *}
	                                             {* and the parameter -d is not specified                                *}
        !.

check_nonpersistentDefault(_appname).  {* otherwise: do nothing *}


check_nonpersistent(_appname,_appname):-
	get_cb_feature('UpdateMode',persistent),
	!.

check_nonpersistent(_appname,_tmpname):-
	get_cb_feature('UpdateMode',nonpersistent),
	operatingSystemIsWindows,
	!,
	getTempDir(_tempdir),
	username(_uname),
	uniqueAtom(_uat),
	getpid(_pid),
	pc_atomconcat([_tempdir,'\\',_uname,'_',_uat,'_',_pid],_tmpname),
	copy_for_nonpersistent(_appname,_tmpname).

check_nonpersistent(_appname,_tmpname):-
	get_cb_feature('UpdateMode',nonpersistent),!,
	getTempDir(_tempdir),
	username(_uname),
	uniqueAtom(_uat),
	getpid(_pid),
	pc_atomconcat([_tempdir,'/',_uname,'_',_uat,'_',_pid],_tmpname),
	copy_for_nonpersistent(_appname,_tmpname).



{* if the update mode is nonpersistent then the specified database directory might *}
{* not exist; if we have started the CBserver with the -db parameter, then we need *}
{* to use the specified db as directory for maintaining the module sources and     *}
{* views. So we need to create the directory then.                                 *}

createViewDir(_db,_db) :- !.  {* nothing to be done because the real db is not temporary *}

createViewDir(_db,_realdb) :-
        get_cb_feature(viewDir,_db),
        get_cb_feature(importDir,_db),
        get_cb_feature(exportDir,_db),
        makeDirIfNotExists(_db),
        !.

createViewDir(_,_).


getTempDir(_tempdir) :-
	getenv(TEMP,_tempdir),
	!.

getTempDir(_tempdir) :-
	getenv(TMPDIR,_tempdir),
	!.

getTempDir(_tempdir) :-
	getenv(TEMPDIR,_tempdir),
	!.

getTempDir(_tempdir) :-
	getenv(TMP,_tempdir),
	!.

getTempDir('c:\\temp') :-
    operatingSystemIsWindows,
    !.

getTempDir('/tmp').


remove_nonpersistent(_appname):-
    getRemoveCommand(_remcmd),
    { Remove the whole directory }
    append(_remcmd,[_appname],_rmapp),
    execCommand(_rmapp),
    removeDir(_appname).

removeDir(_appname) :-
    operatingSystemIsWindows,
    !,
    getRmdirCommand(_rdcmd),
    append(_rdcmd,[_appname],_rmapp),
    execCommand(_rmapp).

removeDir(_appname).  { on Unix already removed by rm -rf }

copy_for_nonpersistent(_appname,_tmpdir) :-
   \+(pc_exists(_appname)),
   !.

copy_for_nonpersistent(_appname,_tmpdir) :-
    getMkdirCommand(_mkdircmd),
    getCopyCommand(_copycmd),
    { Make directory }
    append(_mkdircmd,[_tmpdir],_mkdir),
    execCommand(_mkdir),
    exists_or_abort(_appname),
    { Copy SYSTEM.telos }
    appFilename('telos',_appname,_telos1),
    appFilename('telos',_tmpdir,_telos2),
    append(_copycmd,[_telos1,_telos2],_cptelos),
    execCommand(_cptelos),
    exists_or_abort(_telos2),
    { Copy SYSTEM.symbol }
    appFilename('symbol',_appname,_symbol1),
    appFilename('symbol',_tmpdir,_symbol2),
    append(_copycmd,[_symbol1,_symbol2],_cpsymbol),
    execCommand(_cpsymbol),
    exists_or_abort(_symbol2),
    { Copy SYSTEM.rule }
    appFilename('rule',_appname,_rule1),
    appFilename('rule',_tmpdir,_rule2),
    append(_copycmd,[_rule1,_rule2],_cprule),
    execCommand(_cprule),
    exists_or_abort(_rule2),

    { Copy SYSTEM.builtin is no longer needed; ticket #256 }
   
    { Copy SYSTEM.ecarule }
    appFilename('ecarule',_appname,_ecarule1),
    appFilename('ecarule',_tmpdir,_ecarule2),
    append(_copycmd,[_ecarule1,_ecarule2],_cpecarule),
    execCommand(_cpecarule),
    exists_or_abort(_ecarule2),
    { Copy SYSTEM.ruleinfo }
    appFilename('ruleinfo',_appname,_ruleinfo1),
    appFilename('ruleinfo',_tmpdir,_ruleinfo2),
    append(_copycmd,[_ruleinfo1,_ruleinfo2],_cpruleinfo),
    execCommand(_cpruleinfo),
    exists_or_abort(_ruleinfo2),
    copyLpiFiles(_appname,_tmpdir).




{* hook for copying initial LPI files from SystemDB rather $CBL_DIR *}
copyLpiFiles('$CBL_DIR',_tmpdir) :-
   pc_expand_path('$CB_HOME/lib/SystemDB',_systemDB),
   pc_exists(_systemDB),  
   doCopyLpiFile(_systemDB,_tmpdir),
   !.

{* otherwise: like before *}
copyLpiFiles(_appname,_tmpdir) :-
   doCopyLpiFile(_appname,_tmpdir),
   !.



doCopyLpiFile(_appname,_tmpdir) :-
    getFlag(devOption,'nolpi'),   {* do not copy lpi plugins wgen option -g nolpi has been set by startCBserver  *}
    !.                            {* this is mostly useful for developer purposes, in particula CB_Create_SYSTEM *}

doCopyLpiFile(_appname,_tmpdir) :-
    operatingSystemIsWindows,
    !,
    getCopyCommand(_copycmd),
    pc_expand_path(_appname,_appname1),
    pc_atomconcat(_appname1,'/*.lpi',_wildcard1),
    replaceSlash(_wildcard1,_wildcard2),              {* ticket #262: deal with environment variables *}
    addQuotes(_wildcard2,_wildcard3),   
    addQuotes(_tmpdir,_tmpdir1),
    append(_copycmd,[_wildcard3,_tmpdir1],_copylpi),
    execCommand(_copylpi).


{* The Unix/Linux version of copyLpiFiles could be similar to the Windows version but *}
{* if no lpi file exists, the command /bin/cp would create an error message. Hence,   *}
{* we use the somewhat complex find command to avoid the error message.               *}

doCopyLpiFile(_appname,_tmpdir) :-
    getFindCommand(_findcmd),
    getCopyCommand([_copycmd]),
    append(_findcmd,[_appname,'-name','\'*.lpi\'','-exec',_copycmd,'{}',_tmpdir,'\\;'],_copylpi),
    execCommand(_copylpi).

  

{****************** g e t _ a p p l i c a t i o n ***************************}
{                                                                            }
{ get_application(_appname)                                                  }
{       _appname : any : atom                                                }
{                                                                            }
{ gets name of the current application.                                      }
{****************************************************************************}

get_application(_appname) :-
        CurrentApplication(_appname).


{****************************************************************************}

#DYNAMIC(CurrentApplication/1)

CurrentApplication(noapp).


ClearAndClean :-
	get_application(_appname),
	remove_lock(_appname),
	cleanup,
	remove_nonpersistent_dir.

remove_nonpersistent_dir:-
	get_cb_feature('UpdateMode',persistent),
	!.

remove_nonpersistent_dir:-
	get_cb_feature('UpdateMode',nonpersistent),
	!,
	get_application(_appname),
	remove_nonpersistent(_appname).


{* Determine the module path of the current module *}
{* by tracing it back to the root module System.   *}
{* Module paths are displays with '-' or '/'       *}
{* as separator.                                   *}


getModuleName(System) :-
   System(_mid),
   getModule(_mid),
   !.

getModuleName(_modname) :-
  getModule(_mid),
  id2name(_mid,_modname).

getModulePath(_mpath)  :-
  getModule(_mid),
  getModulePath(_mid,_mpath).

getModulePath(_mid,System) :-
   System(_mid),
   getModule(_mid),
   !.

getModulePath(_mid,_prefix/_current) :-
   get_cb_feature(moduleSeparator,'/'),
   id2name(_mid,_current),
   getPrefixPath(_mid,_prefix),
   !.

getModulePath(_mid,_prefix-_current) :-
   id2name(_mid,_current),
   getPrefixPath(_mid,_prefix),
   !.

getModulePath(_mid,undefinedModule).





getPrefixPath(_mid,System) :-
   System(_sid),
   moduleDefinedIn(_mid,_sid),
   !.

getPrefixPath(_mid,_prefix/_fathername) :-
   get_cb_feature(moduleSeparator,'/'),
   moduleDefinedIn(_mid,_father),
   id2name(_father,_fathername),
   getPrefixPath(_father,_prefix).

getPrefixPath(_mid,_prefix-_fathername) :-
   moduleDefinedIn(_mid,_father),
   id2name(_father,_fathername),
   getPrefixPath(_father,_prefix).


{* ticket #365: instances of subclasses of 'Module' should also be considered *}
moduleDefinedIn(_mid,_father) :-
   Module(_ModuleId),
   retrieve_proposition_noimport(_father,P(_,_mid,'*instanceof',_ModuleId)),
   !.

moduleDefinedIn(_mid,_father) :-
   Module(_ModuleId),
   prove_literal(Isa(_SubOfModule,_ModuleId)),
   _SubOfModule \= _ModuleId,
   retrieve_proposition_noimport(_father,P(_,_mid,'*instanceof',_SubOfModule)),
   !.





{ =================== }
{ Private predicates  }
{ =================== }


{*********************     l o a d - r e s u l t    ************************}
{                                                                           }
{ load_result(_ext,_intfilename)                                           }
{              _ext : atom                                                  }
{              _intfilename : atom                                          }
{                                                                           }
{ This predicate loads a file which is specified by the directory and the   }
{ name of the file (_intfilename) and by the extension (_ext) of the file.  }
{ If the extension is error then file doesn't exist and a warning is given. }
{***************************************************************************}

load_result(app,_intfilename) :-
        WriteTrace(high,ModelConfiguration,
                   ['Loading database ',_intfilename,' ...']),
        load_appfiles(_intfilename),
        set_KBsearchSpace(newOB,Now),         {AM}
        !.


{*** 3-Jun-1993/MJf: loading of several SML files in one step}

load_result(sml,_intfilenames) :-
        listatomconcat(_intfilenames,'.sml',_smlfilenames),
        WriteTrace(low,ModelConfiguration,
                   ['Loading Telos frames from files ',_smlfilenames,' ...']),
        load_sml(_smlfilenames),
        !.


{*** append the default suffix _suff to all filenames in the list}

listatomconcat([],_suff,[]) :- !.
listatomconcat([_x|_rest],_suff,[_xsuff|_restsuff]) :-
  concatIfNoExtension(_x,_suff,_xsuff),
  listatomconcat(_rest,_suff,_restsuff).



{* Concat suffic to filename if the filename does not have the right suffix. *}
{* Allowed suffixes are .sml and .txt                                        *}
concatIfNoExtension(_filename,_suff,_filename) :-
   (pc_atomconcat(_pref,'.sml',_filename);
    pc_atomconcat(_pref,'.txt',_filename)
   ),
   !.
concatIfNoExtension(_filename,_suff,_newfilename) :-
  pc_atomconcat(_filename,_suff,_newfilename).




{* getModule/1 and setModule/1 consolidate the parallel implementations *}
{* set_cbmodule/M_SearchSpace.                                          *}
{* They serve to manage the access to object base modules.              *}
{* The parameter _m is the object identifier of the module.             *}

setModule(_m) :-
  pc_update(M_SearchSpace(_m)),
  set_cbmodule(_m),
  !.

getModule(_m) :-
  M_SearchSpace(_m).




{* save a string consisting of Telos frames of a module to a file in the Export-Directory *}
{* called by ConfigurationUtilities:saveModuleTree                                        *}

saveFramesToFile(_exportdir,_frames,_modpath) :-
  _exportdir \= none,
  dirExists(_exportdir),
  buildAbsoluteFilePath(_exportdir,_modpath,_absfilename),
  WriteTrace(high,ModelConfiguration, ['Writing ',_absfilename]),
  pc_fopen(smlfile,_absfilename,w),
  write(smlfile,_frames),
  pc_fclose(smlfile),
  !.
saveFramesToFile(_,_frames,_modpath). 


dirExists(_dir) :-
  pc_exists_directory(_dir).

fileExists(_dir) :-
  dirOrFileExists(_dir).


dirOrFileExists(_dir) :-
  pc_exists(_dir),
  !.

dirOrFileExists(_dir) :-
  write(' !!! ALARM: Directory does not exist: '),write(_dir),nl,
  !,
  fail.


buildAbsoluteFilePath(_dir,_modpath,_absfilename) :-
   buildAbsoluteFilePath(_dir,_modpath,sml,_absfilename).

buildAbsoluteFilePath(_dir,_modpath,_filetype,_absfilename) :-
  operatingSystemIsWindows,
  get_cb_feature(moduleSeparator,'-'),
  !,
  pc_atomconcat([_dir,'\\',_modpath,'.',_filetype],_absfilename),
  !.


buildAbsoluteFilePath(_dir,_modpath,_filetype,_absfilename) :-
  get_cb_feature(moduleSeparator,'-'),
  !,
  pc_atomconcat([_dir,'/',_modpath,'.',_filetype],_absfilename).


buildAbsoluteFilePath(_dir,_modpath,_filetype,_absfilename) :-
  get_cb_feature(moduleSeparator,'/'),
  createDirPath(_dir,_modpath,_absdir,_filename),
  pc_atomconcat([_absdir,'/',_filename,'.',_filetype],_absfilename).



{* ticket #372: module sources are stored in sub-directories *}
createDirPath(_dir,_modpathatom,_superdir,_modname) :-
  pc_save_atom_to_term(_modpathatom,_modpathexpr),
  do_createDirPath(_dir,_modpathexpr,_superdir,_modname).

{* for materialized views *}
do_createDirPath(_dir,(_path+_filename),_superdir,_filename) :-
  do_createDirPath(_dir,_path,_superdir,_),
  makeDirIfNotExists(_superdir),
  !.

do_createDirPath(_dir,(_path/_modname),_superdir,_modname) :-
  do_createDirPath(_dir,_path,_dir1,_),
  dirSeparator(_sep),
  pc_atomconcat([_dir1,_sep,_modname],_superdir),
  makeDirIfNotExists(_superdir),
  !.

do_createDirPath(_dir,_modname,_superdir,_modname) :-
  atom(_modname),
  dirSeparator(_sep),
  pc_atomconcat([_dir,_sep,_modname],_superdir),
  makeDirIfNotExists(_superdir),
  !.


{* separator used for creating directory paths *}
dirSeparator('\\') :-
  operatingSystemIsWindows,
  !.
dirSeparator('/').



{* nothing to be done for empty answer *}
saveQueryResultsToFile(_modid,_querycall,_viewdir,_filetype,'') :- !.


saveQueryResultsToFile(_modid,_querycall,_viewdir,_filetype,_text) :-
  _viewdir \= none,
  dirExists(_viewdir),
  buildViewFilename(_modid,_querycall,_filename),
  buildAbsoluteFilePath(_viewdir,_filename,_filetype,_absfilename),
  WriteTrace(high,ModelConfiguration, ['Writing ',_absfilename]),
  pc_fopen(viewfile,_absfilename,w),
  write(viewfile,_text),
  pc_fclose(viewfile),
  !.
saveQueryResultsToFile(_modid,_querycall,_viewdir,_filetype,_text).


buildViewFilename(_modid,_querycall,_filename) :-
  _querycall = ask([derive(_q, [substitute(_x, _param)])], _),
  makeName(_x,_filename0),   {* may not contain special characters! *}
  makeAlphanumeric(_filename0,_filename1),
  addModulePrefix(_modid,_filename1,_filename),
  !.

buildViewFilename(_modid,_querycall,_filename) :-
  _querycall = ask([_q], _),
  makeName(_q,_filename0),
  makeAlphanumeric(_filename0,_filename1),
  addModulePrefix(_modid,_filename1,_filename),
  !.

buildViewFilename(_modid,_querycall,_filename) :-
  _querycall = ask([derive(_q, [])], _),
  makeName(_q,_filename0),
  makeAlphanumeric(_filename0,_filename1),
  addModulePrefix(_modid,_filename1,_filename),
  !.

buildViewFilename(_modid,_querycall,_filename) :-
  _querycall = ask([derive(_q, _subst)], _),
  report_error(FNILL,ModelConfiguration,[objectName(derive(_q, _subst))]),
  !,
  fail.


executePostExportCommand :-
  get_cb_feature(viewDir,_viewdir),
  _viewdir \= none,
  buildPostExportCommand(_viewdir,_postExportCmd),
  WriteTrace(low,ModelConfiguration,
                   ['Executing post-export command ',_postExportCmd]),
  execCommand([_postExportCmd]),
  !.
executePostExportCommand.


buildPostExportCommand(_viewdir,_postExportCmd) :-
  operatingSystemIsWindows,
  !,
  pc_atomconcat([_viewdir,'\\','postExport.bat'],_postExportCmd),
  pc_exists(_postExportCmd).   {* no error message if it does not exist *}

buildPostExportCommand(_viewdir,_postExportCmd) :-
  pc_atomconcat([_viewdir,'/','postExport.sh'],_postExportSh),
  pc_exists(_postExportSh),
  pc_atomconcat(['sh ',_postExportSh],_postExportCmd).



{* prepend the module name to the filename if appropriate *}
{* --> modname is not oHome                               *}
{* --> modname is not the same as suggested filename1     *}
addModulePrefix(_modid,_filename1,_filename) :-
  get_cb_feature(moduleSeparator,'-'),
  id2name(_modid,_modname),
  _modname \= 'oHome',
  _modname \= _filename1, 
  pc_atomconcat([_modname,'-',_filename1],_filename),
  !.

{* ticket #372: if module separator is '/' then store views in module subdirectories *}
addModulePrefix(_modid,_filename1,_filename) :-
  get_cb_feature(moduleSeparator,'/'),
  getModulePath(_modid,_modpath),
  pc_save_atom_to_term(_modpathatom,_modpath),
  pc_atomconcat([_modpathatom,'+',_filename1],_filename),
  !.

addModulePrefix(_modid,_filename,_filename).





