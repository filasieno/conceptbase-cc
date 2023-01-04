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
*/

:- module('ExternalCodeLoader',[
'A_query'/2
,'Adot_query'/2
,'Aidot_query'/2
,'CharListToCString'/3
,'ClassListCToProlog'/2
,'DeleteIpcMessage'/1
,'DestroySMLfrag'/1
,'Destroy_ClassList'/1
,'FragmentListCToProlog'/2
,'GetMessageFromIpcParserOutput'/2
,'GetErrFromIpcParserOutput'/2
,'GetIpcMessageAsTerm'/3
,'In_i_query'/2
,'Attr_s_query'/2
,'In_s_query'/2
,'IpcParse'/2
,'Isa_query'/2
,'Win_FindClose'/1
,'Win_FindFirstFile'/4
,'Win_FindNextFile'/3
,'accept_request'/5
,'appendBuffer'/2
,'appendBufferP'/2
,'replaceCharacterInBuffer'/3
,'changeAttrValue'/2
,'check_implicit'/2
,'closedir'/1
,'concat_sml_string'/3
,'connect_service'/6
,'create_implicit_node'/3
,'create_link'/5
,'create_name2id'/3
,'create_node'/3
,'deleteBuffer'/1
,'delete_export'/2
,'delete_import'/2
,'displayAnswerOnTrace'/2
,'done'/0
,'encodeIpcString'/2
,'getClassListFromClassListParseOutput'/2
,'getClassListParseErrNo'/2
,'getFileNameFromDirEntry'/2
,'getFileNameFromFindData'/2
,'getFragmentListFromFrameParseOutput'/2
,'getFragmentListSpace'/2
,'getFrameParseErrLine'/2
,'getFrameParseErrNo'/2
,'getFrameParseErrToken'/2
,'getPointerFromBuffer'/2
,'getStringFromBuffer'/2
,'getLengthFromBuffer'/2
,'get_mod_context'/1
,'get_one_histogramm'/3
,'get_prop_id'/2
,'get_sys_class'/3
,'get_term_space'/2
,'get_zaehler'/4
,'getpid'/1
,'hostname'/1
,'id2name'/3
,'id2select'/3
,'id2starttime'/9
,'id2endtime'/9
,'init'/2
,'initBuffer'/2
,'initialize_module'/2
,'input_pending'/3
,'insert_abort'/0
,'insert_commit'/0
,'ipc_read'/3
,'ipc_write'/3
,'stringBufferCompare'/3
,'make_ipcanswerstring'/5
,'memfree'/1
,'name2id'/3
,'new_export'/2
,'new_import'/2
,'opendir'/2
,'prependBuffer'/2
,'read_text_file'/2
,'readdir'/2
,'remove'/2
,'removetmp'/2
,'remove_abort'/0
,'remove_end'/0
,'rename'/3
,'replaceEmptyBuffer'/1
,'retrieve_prop_query'/2
,'retrieve_prop_module_query'/2
,'sec_time'/1
,'select2id'/3
,'select_input_n'/4
,'set_act'/0
,'set_act_temp'/0
,'set_act_hist'/0
,'set_current_OB'/0
,'set_old_OB'/0
,'set_new_OB'/0
,'set_hist'/0
,'set_module'/2
,'set_overrule_module'/2
,'set_temp'/0
,'set_search_point'/7
,'set_time_point'/7
,'set_overrule_temp'/0
,'set_overrule_temp_tell'/0
,'set_overrule_temp_untell'/0
,'set_overrule_act'/0
,'set_persistency_level'/1
,'setup_service'/3
,'loadWinSock'/0
,'shutdown_service'/3
,'sleepsec'/1
,'star_query'/2
,'start_get_histogramm'/3
,'strdup'/2
,'sys_class_query'/2
,'system_module'/2
,'systemclock'/7
,'te_classlist_parser'/2
,'te_frame_parser'/2
,'unlink'/1
,'update_histogramm'/3
,'update_histogramm'/5
,'update_zaehler'/4
,'update_zaehler_ohne_huelle'/4
,'username'/1

,'swi_stringtoatom'/2
,'swi_pointer'/1
,'swi_isNullPointer'/1
,'pc_record_ext'/3
,'pc_rerecord_ext'/3
,'pc_recorded_ext'/3
,'pc_is_a_key_ext'/2
,'pc_erase_ext'/2
,'pc_erase_all_ext'/1
,'pc_current_key_ext'/3
,'swi_checkStacks'/1

,'delete_history_db'/7
,'test'/0


]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').

:- use_module('PrologCompatibility.swi.pl').


:- style_check(-singleton).






/* :- load_foreign_library('/usr/lib/libnsl.so').
:- load_foreign_library('/usr/lib/libsocket.so').
:- load_foreign_library('/opt/info5/gnu/gcc-3.2.3-sol9/lib/libstdc++.so').
:- load_foreign_library('/home/quix/CB/CB_Work.swi/ProductPOOL/sun4/serverSources/C_Files/libCos3/objects.SWI/libCos.so',install_libCos).
:- load_foreign_library('/home/quix/CB/CB_Work.swi/ProductPOOL/sun4/serverSources/C_Files/libGeneral/objects.SWI/libGeneral.so',install_libGeneral).
:- load_foreign_library('/home/quix/CB/CB_Work.swi/ProductPOOL/sun4/serverSources/C_Files/libIpc/objects.SWI/libIpc.so',install_libIpc).
:- load_foreign_library('/home/quix/CB/CB_Work.swi/ProductPOOL/sun4/serverSources/C_Files/libtelos/objects.SWI/libtelos.so',install_libtelos).
:- load_foreign_library('/home/quix/CB/CB_Work.swi/ProductPOOL/sun4/serverSources/C_Files/libtelosServer/objects.SWI/libtelosServer.so',install_libtelosServer).
*/




opendir( _dir , _path ) :-
   'UF_opendir'( _dir , _path ),
   \+(pc_isNullPointer(_dir)).

readdir( _dir_ent , _dir ) :-
   'UF_readdir'( _dir_ent , _dir ),
   \+(pc_isNullPointer(_dir_ent)).

closedir( _dir ) :-
   'UF_closedir'( _dir ) .

unlink( _path ) :-
   'UF_unlink'( _ret , _path ), _ret == 0 .

