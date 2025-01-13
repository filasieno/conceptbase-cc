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
* File:         %M%
* Version:      %I%
* Creation:    17.07.92 Rainer Gallersdoerfer (RWTH)
* Last Change   : %E%, Thomas List (RWTH)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.ExternalCodeLoader.pro
* Date retrieved : 96/04/18 (YY/MM/DD)
-----------------------------------------------------------------------------
*
* This file contains all extern directives.
* So calling the incremental linker during loading of ConceptBase is necessary only once.
* It also helps when linking the runtime version !
*
*
*
}

#MODULE(ExternalCodeLoader)
#EXPORT(A_query/2)
#EXPORT(Adot_query/2)
#EXPORT(Aidot_query/2)
#EXPORT(CharListToCString/3)
#EXPORT(ClassListCToProlog/2)
#EXPORT(DeleteIpcMessage/1)
#EXPORT(DestroySMLfrag/1)
#EXPORT(Destroy_ClassList/1)
#EXPORT(FragmentListCToProlog/2)
#EXPORT(GetMessageFromIpcParserOutput/2)
#EXPORT(GetErrFromIpcParserOutput/2)
#EXPORT(GetIpcMessageAsTerm/3)
#EXPORT(In_i_query/2)
#EXPORT(Attr_s_query/2)
#EXPORT(In_s_query/2)
#EXPORT(IpcParse/2)
#EXPORT(Isa_query/2)
#EXPORT(Win_FindClose/1)
#EXPORT(Win_FindFirstFile/4)
#EXPORT(Win_FindNextFile/3)
#EXPORT(accept_request/5)
#EXPORT(appendBuffer/2)
#EXPORT(appendBufferP/2)
#EXPORT(replaceCharacterInBuffer/3)
#EXPORT(changeAttrValue/2)
#EXPORT(check_implicit/2)
#EXPORT(closedir/1)
#EXPORT(concat_sml_string/3)
#EXPORT(connect_service/6)
#EXPORT(create_implicit_node/3)
#EXPORT(create_link/5)
#EXPORT(create_name2id/3)
#EXPORT(create_node/3)
#EXPORT(deleteBuffer/1)
#EXPORT(delete_export/2)
#EXPORT(delete_import/2)
#EXPORT(displayAnswerOnTrace/2)
#EXPORT(done/0)
#EXPORT(encodeIpcString/2)
#EXPORT(getClassListFromClassListParseOutput/2)
#EXPORT(getClassListParseErrNo/2)
#EXPORT(getFileNameFromDirEntry/2)
#EXPORT(getFileNameFromFindData/2)
#EXPORT(getFragmentListFromFrameParseOutput/2)
#EXPORT(getFragmentListSpace/2)
#EXPORT(getFrameParseErrLine/2)
#EXPORT(getFrameParseErrNo/2)
#EXPORT(getFrameParseErrToken/2)
#EXPORT(getPointerFromBuffer/2)
#EXPORT(getStringFromBuffer/2)
#EXPORT(getLengthFromBuffer/2)
#EXPORT(get_mod_context/1)
#EXPORT(get_one_histogramm/3)
#EXPORT(get_prop_id/2)
#EXPORT(get_sys_class/3)
#EXPORT(get_term_space/2)
#EXPORT(get_zaehler/4)
#EXPORT(getpid/1)
#EXPORT(hostname/1)
#EXPORT(id2name/3)
#EXPORT(id2select/3)
#EXPORT(id2starttime/9)
#EXPORT(id2endtime/9)
#EXPORT(init/2)
#EXPORT(initBuffer/2)
#EXPORT(initialize_module/2)
#EXPORT(input_pending/3)
#EXPORT(insert_abort/0)
#EXPORT(insert_commit/0)
#EXPORT(ipc_read/3)
#EXPORT(ipc_write/3)
#EXPORT(stringBufferCompare/3)
#EXPORT(make_ipcanswerstring/5)
#EXPORT(memfree/1)
#EXPORT(name2id/3)
#EXPORT(new_export/2)
#EXPORT(new_import/2)
#EXPORT(opendir/2)
#EXPORT(prependBuffer/2)
#EXPORT(read_text_file/2)
#EXPORT(readdir/2)
#EXPORT(remove/2)
#EXPORT(removetmp/2)   {* see ticket #92 *}
#EXPORT(remove_abort/0)
#EXPORT(remove_end/0)
#EXPORT(rename/3)
#EXPORT(replaceEmptyBuffer/1)
#EXPORT(retrieve_prop_query/2)
#EXPORT(retrieve_prop_module_query/2)
#EXPORT(sec_time/1)
#EXPORT(select2id/3)
#EXPORT(select_input_n/4)
#EXPORT(set_act/0)
#EXPORT(set_act_temp/0)
#EXPORT(set_act_hist/0)
#EXPORT(set_current_OB/0)
#EXPORT(set_old_OB/0)
#EXPORT(set_new_OB/0)
#EXPORT(set_hist/0)
#EXPORT(set_module/2)
#EXPORT(set_overrule_module/2)
#EXPORT(set_temp/0)
#EXPORT(set_search_point/7)
#EXPORT(set_time_point/7)
#EXPORT(set_overrule_temp/0)
#EXPORT(set_overrule_temp_tell/0)
#EXPORT(set_overrule_temp_untell/0)
#EXPORT(set_overrule_act/0)
#EXPORT(set_persistency_level/1)
#EXPORT(setup_service/3)
#EXPORT(loadWinSock/0)
#EXPORT(shutdown_service/3)
#EXPORT(sleepsec/1)
#EXPORT(star_query/2)
#EXPORT(start_get_histogramm/3)
#EXPORT(strdup/2)
#EXPORT(sys_class_query/2)
#EXPORT(system_module/2)
#EXPORT(systemclock/7)
#EXPORT(te_classlist_parser/2)
#EXPORT(te_frame_parser/2)
#EXPORT(unlink/1)
#EXPORT(update_histogramm/3)
#EXPORT(update_histogramm/5)
#EXPORT(update_zaehler/4)
#EXPORT(update_zaehler_ohne_huelle/4)
#EXPORT(username/1)
#IF(SWI)
#EXPORT(swi_stringtoatom/2)
#EXPORT(swi_pointer/1)
#EXPORT(swi_isNullPointer/1)
#EXPORT(pc_record_ext/3)
#EXPORT(pc_rerecord_ext/3)
#EXPORT(pc_recorded_ext/3)
#EXPORT(pc_is_a_key_ext/2)
#EXPORT(pc_erase_ext/2)
#EXPORT(pc_erase_all_ext/1)
#EXPORT(pc_current_key_ext/3)
#EXPORT(swi_checkStacks/1)

#EXPORT(delete_history_db/7)
#EXPORT(test/0)

#ENDIF(SWI)
#ENDMODDECL()

#IMPORT(pc_isNullPointer/1,PrologCompatibility)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)

#IF(BIM)
:- extern_load( [

{*** from module libIpc.a ***}

	IpcParse,
	GetMessageFromIpcParserOutput,
	GetErrFromIpcParserOutput,
	DeleteIpcMessage,
	encodeIpcString,
	make_ipcanswerstring,
	GetIpcMessageAsTerm,

{*** from module libtelosServer.a ***}

	{ Telos-Frame Parser: }
	te_frame_parser,
	get_mod_context,
	DestroySMLfrag,
	getFrameParseErrNo,
	getFrameParseErrToken,
	getFrameParseErrLine,
	getFragmentListFromFrameParseOutput,
	FragmentListCToProlog,
	getFragmentListSpace,
	get_term_space,

	{ Classlist Parser: }
	te_classlist_parser,
	Destroy_ClassList,
	getClassListFromClassListParseOutput,
	getClassListParseErrNo,
	ClassListCToProlog,

	{ CharListToCString.c }
	CharListToCString,

{*** from module libGeneral.a ***}
	{ FileIO.c }
	ipc_read,
	ipc_write,
	read_text_file,
	concat_sml_string,

	{ BimIpc.c }
	loadWinSock,
	setup_service,
	accept_request,
	connect_service,
	shutdown_service,
	select_input_n,
	input_pending,

	{ unixToProlog.c }
  	systemclock,
	username,
	sleepsec,
	hostname,
	memfree,
	sec_time,

	{StringBuffer.c }
	initBuffer,
	appendBuffer,
	prependBuffer,
	deleteBuffer,
	getStringFromBuffer,
	stringBufferCompare,
	displayAnswerOnTrace,
	replaceEmptyBuffer,
	replaceCharacterInBuffer,
	getLengthFromBuffer,

{*** from module UnixFileSys.o***}
	UF_opendir,
	UF_readdir,
	UF_closedir,
	UF_unlink,
	getFileNameFromDirEntry,

{*** from module WinFileSys.o***}
	Win_FindFirstFile,
	Win_FindNextFile,
	Win_FindClose,
	getFileNameFromFindData,

{*** from libc.a ***}

	getpid,
	strdup,


{*** from libCos.a ***}
	c_init,
	c_done,
	c_test,
    c_retrieve_prop_query,
    c_retrieve_prop_module_query,
	c_Attr_s_query,
	c_In_s_query,
	c_In_i_query,
    c_Isa_query,
	c_sys_class_query,
	c_Adot_query,
	c_Aidot_query,
	c_A_query,
	c_star_query,
	c_name2id,
	c_create_name2id,
	c_id2name,
	c_select2id,
	c_id2select,
	c_id2starttime,
	c_id2endtime,
	c_check_implicit,
	c_create_node,
	c_create_implicit_node,
	c_create_link,
	c_insert_commit,
	c_insert_abort,
	c_remove,
	c_removetmp, 
	c_remove_abort,
	c_remove_end,
	c_rename,
	c_changeAttrValue,
	c_set_act,
	c_set_temp,
	c_set_hist,
	c_set_act_temp,
	c_set_overrule_temp,
	c_set_overrule_temp_tell,
	c_set_overrule_temp_untell,
	c_set_overrule_act,
	c_set_act_hist,
	c_set_old_DB,
	c_set_new_DB,
	c_set_current_DB,
	c_set_persistency_level,
	c_get_sys_class,
	c_get_prop_id,
	c_set_time_point,
	c_set_search_point,
	c_delete_history_db,
	c_update_zaehler,
	c_update_zaehler_ohne_huelle,
	c_get_zaehler,
	c_update_histogramm,
	c_update_histogramm_with_restr,
	c_start_get_histogramm,
	c_get_histogramm,
	c_set_module,
	c_set_overrule_module,
	c_initialize_module,
	c_system_module,
	c_new_export,
	c_delete_export,
	c_new_import,
	c_delete_import
	],[
	'$LIB_COS',
	'$LIB_TELOS',
	'$LIB_TELOSSERVER',
	'$LIB_IPC',
	'$LIB_GENERAL' {,
    '$LIB_GPP',
    '$LIB_STDCPP',
	'$LIB_GCC' }
	] ).




{*** from module libIpc.a  ***}

:- extern_predicate( IpcParse( pointer:r, pointer:i ) ).
:- extern_predicate( GetMessageFromIpcParserOutput( pointer:r, pointer:i ) ).
:- extern_predicate( GetErrFromIpcParserOutput( integer:r, pointer:i ) ).
:- extern_predicate( DeleteIpcMessage( pointer:i ) ).
:- extern_predicate( encodeIpcString( pointer:r, pointer:i ) ).
:- extern_predicate( make_ipcanswerstring( pointer:r, string:i, string:i, pointer:i, integer:o ) ).
:- extern_predicate( GetIpcMessageAsTerm(integer:r, pointer:i, bpterm)).

{*** from module libtelos.a ***}

:- extern_predicate( te_frame_parser( pointer:r, pointer:i ) ).
:- extern_predicate( get_mod_context( string:r ) ).
:- extern_predicate( DestroySMLfrag( pointer:i ) ).
:- extern_predicate( te_classlist_parser( pointer:r, pointer:i ) ).
:- extern_predicate( Destroy_ClassList( pointer:i ) ).

{*** from module libtelosServer.a ***}
:- extern_predicate( getFrameParseErrNo( integer:r, pointer:i ) ).
:- extern_predicate( getFrameParseErrToken( string:r, pointer:i ) ).
:- extern_predicate( getFrameParseErrLine( integer:r, pointer:i ) ).
:- extern_predicate( getFragmentListFromFrameParseOutput( pointer:r, pointer:i ) ).
:- extern_predicate( FragmentListCToProlog( pointer:i, bpterm ) ).
:- extern_predicate( getFragmentListSpace( integer:r, pointer:i ) ).
:- extern_predicate( get_term_space( integer:r, integer:i ) ).
:- extern_predicate( getClassListFromClassListParseOutput( pointer:r, pointer:i ) ).
:- extern_predicate( getClassListParseErrNo( integer:r, pointer:i ) ).
:- extern_predicate( ClassListCToProlog( pointer:i, bpterm ) ).
:- extern_predicate( CharListToCString( pointer:r, bpterm:i, integer:i ) ).

{***from libCos.a ***}
:-extern_predicate(c_init, init( integer:r, string:i ) ).
{:-extern_predicate(c_init).}
:-extern_predicate(c_test,test).
:-extern_predicate(c_done,done).
{******************************************************************}
:-extern_predicate(c_retrieve_prop_query,retrieve_prop_query(string:array:i,bpterm)).
:-extern_predicate(c_retrieve_prop_module_query,retrieve_prop_module_query(string:array:i,bpterm)).
:-extern_predicate(c_Attr_s_query,Attr_s_query(string:array:i, bpterm)).
:-extern_predicate(c_In_s_query,In_s_query(string:array:i, bpterm)).
:-extern_predicate(c_In_i_query,In_i_query(string:array:i, bpterm)).
:-extern_predicate(c_Isa_query,Isa_query(string:array:i, bpterm)).
:-extern_predicate(c_sys_class_query,sys_class_query(string:array:i,bpterm)).
:-extern_predicate(c_Adot_query,Adot_query(string:array:i, bpterm)).
:-extern_predicate(c_Aidot_query,Aidot_query(string:array:i, bpterm)).
:-extern_predicate(c_A_query,A_query(string:array:i, bpterm)).
:-extern_predicate(c_star_query,star_query(string:i,bpterm)).
:-extern_predicate(c_create_name2id,create_name2id(integer:r,string:i,string:o)).
:-extern_predicate(c_name2id,name2id(integer:r,string:i,string:o)).
:-extern_predicate(c_id2name,id2name(integer:r,string:i,string:o)).
:-extern_predicate(c_select2id,select2id(integer:r,string:i,string:o)).
:-extern_predicate(c_id2select,id2select(integer:r,string:i,string:o)).
:-extern_predicate(c_id2starttime,id2starttime(integer:r,string:i,integer:o,integer:o,integer:o,integer:o,integer:o,integer:o,integer:o)).
:-extern_predicate(c_id2endtime,id2endtime(integer:r,string:i,integer:o,integer:o,integer:o,integer:o,integer:o,integer:o,integer:o)).
:-extern_predicate(c_check_implicit,check_implicit(integer:r,string:i)).
:-extern_predicate(c_create_node,create_node(integer:r,string:i,string:o)).
:-extern_predicate(c_create_implicit_node,create_implicit_node(integer:r,string:i,string:o)).
:-extern_predicate(c_create_link,create_link(integer:r,string:o,string:i,string:i,string:i)).
:-extern_predicate(c_insert_commit,insert_commit).
:-extern_predicate(c_insert_abort,insert_abort).
:-extern_predicate(c_remove,remove(integer:r,string:i)).
:-extern_predicate(c_removetmp,removetmp(integer:r,string:i)).   
:-extern_predicate(c_remove_abort,remove_abort).
:-extern_predicate(c_remove_end,remove_end).
:-extern_predicate(c_rename,rename(integer:r,string:i,string:i)).
:-extern_predicate(c_changeAttrValue,changeAttrValue(string:i,string:i)).
:-extern_predicate(c_set_act,set_act).
:-extern_predicate(c_set_temp,set_temp).
:-extern_predicate(c_set_hist,set_hist).
:-extern_predicate(c_set_act_temp,set_act_temp).
:-extern_predicate(c_set_overrule_temp,set_overrule_temp).
:-extern_predicate(c_set_overrule_temp_tell,set_overrule_temp_tell).
:-extern_predicate(c_set_overrule_temp_untell,set_overrule_temp_untell).
:-extern_predicate(c_set_overrule_act,set_overrule_act).
:-extern_predicate(c_set_act_hist,set_act_hist).
:-extern_predicate(c_set_old_DB,set_old_OB).
:-extern_predicate(c_set_new_DB,set_new_OB).
:-extern_predicate(c_set_current_DB,set_current_OB).
:-extern_predicate(c_get_sys_class,get_sys_class(integer:r,string:i,string:o)).
:-extern_predicate(c_get_prop_id,get_prop_id(integer:r,string:o)).
:-extern_predicate(c_set_time_point,set_time_point(integer:i,integer:i,integer:i,integer:i,integer:i,integer:i,integer:i)).
:-extern_predicate(c_set_search_point,set_search_point(integer:i,integer:i,integer:i,integer:i,integer:i,integer:i,integer:i)).
:-extern_predicate(c_delete_history_db,delete_history_db(integer:i,integer:i,integer:i,integer:i,integer:i,integer:i,integer:i)).
:-extern_predicate(c_update_zaehler,update_zaehler(integer:r,string:i,integer:i,integer:o)).
:-extern_predicate(c_update_zaehler_ohne_huelle,update_zaehler_ohne_huelle(integer:r,string:i,integer:i,integer:o)).
:-extern_predicate(c_get_zaehler,get_zaehler(integer:r,string:i,integer:i,integer:o)).
:-extern_predicate(c_update_histogramm,update_histogramm(integer:r,string:i,integer:i)).
:-extern_predicate(c_update_histogramm_with_restr,update_histogramm(integer:r,string:i,integer:i,string:i,string:i)).
:-extern_predicate(c_get_histogramm,get_one_histogramm(integer:r,string:o,integer:o)).
:-extern_predicate(c_start_get_histogramm,start_get_histogramm(integer:r,string:i,integer:i)).
:-extern_predicate(c_set_module,set_module(integer:r,string:i)).
:-extern_predicate(c_set_overrule_module,set_overrule_module(integer:r,string:i)).
:-extern_predicate(c_initialize_module,initialize_module(integer:r,string:i)).
:-extern_predicate(c_system_module,system_module(integer:r,string:i)).
:-extern_predicate(c_new_export,new_export(integer:r,string:i)).
:-extern_predicate(c_delete_export,delete_export(integer:r,string:i)).
:-extern_predicate(c_new_import,new_import(integer:r,string:i)).
:-extern_predicate(c_delete_import,delete_import(integer:r,string:i)).
:-extern_predicate(c_set_persistency_level,set_persistency_level(integer:i)).

{*** BimIpc in libGeneral.a ***}
:- extern_predicate( loadWinSock ) .
:- extern_predicate( setup_service( integer:r , integer:i , integer:o ) ) .
:- extern_predicate( accept_request( integer:r,integer:i,integer:o,pointer:o,pointer:o ) ) .
:- extern_predicate( connect_service( integer:r,integer:i,string:i,integer:o,pointer:o,pointer:o ) ) .
:- extern_predicate( shutdown_service( integer:i, pointer:i,pointer:i ) ) .
:- extern_predicate( select_input_n, select_input_n( integer:r , integer:array:i , integer:i, integer:o ) ) .
:- extern_predicate( input_pending( integer:r , integer:i , integer:i ) ) .

{*** FileIO in libGeneral.a ***}
:- extern_predicate( read_text_file(pointer:r, string:i) ).
:- extern_predicate( concat_sml_string( pointer:r, pointer:i, pointer:i) ).
:- extern_predicate( ipc_read( pointer:r, integer:i, integer:o ) ).
:- extern_predicate( ipc_write( integer:r, integer:i, pointer:i ) ).

{*** from libc.a ***}

:- extern_predicate( getpid( integer:r )).
:- extern_predicate( strdup(pointer:r, pointer:i)) .

{*** from module libGeneral.a ***}
:-extern_predicate( systemclock(integer:o, integer:o, integer:o, integer:o, integer:o, integer:o, integer:o)).
:-extern_predicate(sleepsec(integer:i)).
:-extern_predicate(username(string:o)).
:-extern_predicate(hostname(string:o)).
:-extern_predicate(memfree(pointer:i)).
:-extern_predicate(sec_time( integer:r ) ).

:-extern_predicate(initBuffer(pointer:r,integer:i)).
:-extern_predicate(appendBuffer(pointer:i,string:i)).
:-extern_predicate(prependBuffer(pointer:i,string:i)).
:-extern_predicate(appendBuffer,appendBufferP(pointer:i,pointer:i)).
:-extern_predicate(prependBuffer,prependBufferP(pointer:i,pointer:i)).
:-extern_predicate(deleteBuffer(pointer:i)).
:-extern_predicate(getStringFromBuffer(string:r,pointer:i)).
:-extern_predicate(getStringFromBuffer,getPointerFromBuffer(pointer:r,pointer:i)).
:-extern_predicate(stringBufferCompare(integer:r,pointer:i,string:i)).
:-extern_predicate(displayAnswerOnTrace(pointer:i,integer:i)).
:-extern_predicate(replaceEmptyBuffer(pointer:i)).
:-extern_predicate(replaceCharacterInBuffer(pointer:i,string:i,string:i)).
:-extern_predicate(getLengthFromBuffer(integer:r,pointer:i)).

{*** from module UnixFileSys ***}

:- extern_predicate( UF_opendir(pointer:r,string:i) ) .
:- extern_predicate( UF_readdir(pointer:r,pointer:i) ) .
:- extern_predicate( UF_closedir(pointer:i) ) .
:- extern_predicate( UF_unlink(integer:r,string:i) ) .
:- extern_predicate( getFileNameFromDirEntry(string:r,pointer:i) ).


{*** from module WinFileSys *** }

:- extern_predicate(Win_FindFirstFile(integer:r,string:i,pointer:o,pointer:o)).
:- extern_predicate(Win_FindNextFile(integer:r,pointer:i,pointer:o)).
:- extern_predicate(Win_FindClose(pointer:i)).
:- extern_predicate(getFileNameFromFindData(string:r,pointer:i)).
#ENDIF(BIM)


#IF(SWI)
{ :- load_foreign_library('/usr/lib/libnsl.so').
:- load_foreign_library('/usr/lib/libsocket.so').
:- load_foreign_library('/opt/info5/gnu/gcc-3.2.3-sol9/lib/libstdc++.so').
:- load_foreign_library('/home/quix/CB/CB_Work.swi/ProductPOOL/sun4/serverSources/C_Files/libCos3/objects.SWI/libCos.so',install_libCos).
:- load_foreign_library('/home/quix/CB/CB_Work.swi/ProductPOOL/sun4/serverSources/C_Files/libGeneral/objects.SWI/libGeneral.so',install_libGeneral).
:- load_foreign_library('/home/quix/CB/CB_Work.swi/ProductPOOL/sun4/serverSources/C_Files/libIpc/objects.SWI/libIpc.so',install_libIpc).
:- load_foreign_library('/home/quix/CB/CB_Work.swi/ProductPOOL/sun4/serverSources/C_Files/libtelos/objects.SWI/libtelos.so',install_libtelos).
:- load_foreign_library('/home/quix/CB/CB_Work.swi/ProductPOOL/sun4/serverSources/C_Files/libtelosServer/objects.SWI/libtelosServer.so',install_libtelosServer).
}
#ENDIF(SWI)



opendir( _dir , _path ) :-
   UF_opendir( _dir , _path ),
   \+(pc_isNullPointer(_dir)).

readdir( _dir_ent , _dir ) :-
   UF_readdir( _dir_ent , _dir ),
   \+(pc_isNullPointer(_dir_ent)).

closedir( _dir ) :-
   UF_closedir( _dir ) .

unlink( _path ) :-
   UF_unlink( _ret , _path ), _ret == 0 .

