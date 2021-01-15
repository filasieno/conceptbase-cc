{*
The ConceptBase.cc Copyright

Copyright 1987-2021 The ConceptBase Team. All rights reserved.

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
*
* File:         IpcChannel.pro
* Version:      12.2
* Creation:     23-Jun-1988, Manfred Jeusfeld (UPA)
* Last Change   : 5-Oct-2000, Manfred Jeusfeld (KUB Tilburg)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/SCCS/serverSources/Prolog_Files/s.IpcChannel.pro
* Date retrieved : 98/06/30 (YY/MM/DD)
* ----------------------------------------------------------
*
* The IpcChannel is essentially an ipc server. Most of the code is
* taken from the BIM_Prolog Inter Process Communication Package
*
* 21-Mar-1990: Adaptions according to BIM's instructions (CBNEWS[89])
* 04-04-1990 : error in 2nd clause of solve_goal/3 corrected:
*	       shutdown_service(_fd) as last(!) call
* 10.09.92 RG modifications so that server blocks when selecting
* 18.01.94 RG shutdown_service now also closes the streams if provided
*
* 12-12-94/CQ Fehlerbehandlung fuer IpcParser geaendert
* 5-Oct-2000/MJf: more extensive reporting on 'Client hanging'
*
* Exported predicates:
* --------------------
*
*   + IpcChannel_startup/0
*	Start up the serving of the IPC channel.
*   + IpcChannel_shutdown/0
*
*

}

#MODULE(IpcChannel)
#EXPORT(IpcChannel_startup/0)
#EXPORT(haltCBserverIfRequested/0)
#EXPORT(TermToCharList/2)
#EXPORT(client_db_files/3)
#EXPORT(current_fd/1)
#EXPORT(get_ipcmessage/5)
#EXPORT(output_answer/3)
#EXPORT(serve_goal2/4)
#EXPORT(signal_wrapper/2)
#ENDMODDECL()

#IMPORT(setup_service/2,BimIpc)
#IMPORT(accept_request/4,BimIpc)
#IMPORT(shutdown_service/3,ExternalCodeLoader)
#IMPORT(ipc_write/3,ExternalCodeLoader)
#IMPORT(getPointerFromBuffer/2,ExternalCodeLoader)
#IMPORT(getStringFromBuffer/2,ExternalCodeLoader)
#IMPORT(disposeBuffer/1,GeneralUtilities)
#IMPORT(replaceEmptyBuffer/1,ExternalCodeLoader)
#IMPORT(select_input/2,BimIpc)
#IMPORT(input_pending/2,BimIpc)
#IMPORT(server_id/1,CBserverInterface)
#IMPORT(handle_message/2,CBserverInterface)
#IMPORT(atom2list/2,GeneralUtilities)
#IMPORT(delete/3,GeneralUtilities)
#IMPORT(length/2,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(replaceCString/2,GeneralUtilities)
#IMPORT(operatingSystemIsWindows/0,GeneralUtilities)
#IMPORT(GetIpcMessageFromC/2,IpcParser)
#IMPORT(GetMessageFromIpcParserOutput/2,ExternalCodeLoader)
#IMPORT(GetErrFromIpcParserOutput/2,ExternalCodeLoader)
#IMPORT(IpcParse/2,ExternalCodeLoader)
#IMPORT(deleteIpcMessage/1,GeneralUtilities)
#IMPORT(CharListToCString/3,ExternalCodeLoader)
#IMPORT(memfree/1,ExternalCodeLoader)
#IMPORT(make_ipcanswerstring/5,ExternalCodeLoader)
#IMPORT(ipc_read/3,ExternalCodeLoader)
#IMPORT(knownTool/5,CBserverInterface)
#IMPORT(delete_all_notification_requests/1,ClientNotification)
#IMPORT(get_application/1,ModelConfiguration)
#IMPORT(remove_lock/1,ModelConfiguration)
#IMPORT(handle_error_message_queue/1,ErrorMessages)
#IMPORT(prove_literal/1,Literals)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(multiAppend/2,ScanFormatUtilities)
#IMPORT(do_untell/1,ObjectProcessor)
#IMPORT(do_tell/1,ObjectProcessor)
#IMPORT(ask_objproc/3,ObjectProcessor)
#IMPORT(fragmentatom2list/2,AnswerTransformator)
#IMPORT(thisToolId/1,CBserverInterface)
#IMPORT(portnr/1,GlobalParameters)
#IMPORT(get_cb_feature/2,GlobalParameters)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_record/2,PrologCompatibility)
#IMPORT(pc_record/3,PrologCompatibility)
#IMPORT(pc_rerecord/2,PrologCompatibility)
#IMPORT(pc_rerecord/3,PrologCompatibility)
#IMPORT(pc_recorded/2,PrologCompatibility)
#IMPORT(pc_recorded/3,PrologCompatibility)
#IMPORT(pc_erase/1,PrologCompatibility)
#IMPORT(pc_erase/2,PrologCompatibility)
#IMPORT(pc_update/1,PrologCompatibility)
#IMPORT(pc_inttoatom/2,PrologCompatibility)
#IMPORT(pc_fopen/3,PrologCompatibility)
#IMPORT(pc_fclose/1,PrologCompatibility)
#IMPORT(pc_stringtoatom/2,PrologCompatibility)
#IMPORT(pc_pointer/1,PrologCompatibility)
#IMPORT(pc_isNullPointer/1,PrologCompatibility)
#IMPORT(pc_swriteQuotes/2,PrologCompatibility)
#IMPORT(reportCBserverAsReady/1,GeneralUtilities)
#IMPORT(getFlag/2,GeneralUtilities)
#IMPORT(report_error/3,ErrorMessages)
#IMPORT(handle_error_message_queue/1,ErrorMessages)
#IMPORT(shutDownSlaveIfNoClients/1,CBserverInterface)
#IMPORT(WriteTrace/3,GeneralUtilities)



#DYNAMIC(message_for_log/2)
   { fuer OB.log }
#DYNAMIC(wait_for_answer/1)
   { fuer Skriptdateien }

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


{*** customized functionality }


IpcChannel_startup :-
   service_port(_portnr),
   server_startup( _portnr ) .



IpcChannel_shutdown :-
   server_id(_serv_id),
#IF(BIM)
   shutdown_service( _serv_id, 0x0, 0x0 ).
#ELSE(BIM)
   shutdown_service( _serv_id, _, _ ).
#ENDIF(BIM)

solve_goal( ipcmessage(_s,_r,STOP_SERVER,_args) , _fd , _out ) :-
	!,
	Close_extern,
	handle_message(ipcmessage(_s,_r,STOP_SERVER,_args), _answer),
	output_answer(_fd,_out,_answer),
	stopServerIfAnswerOk(_answer),
	!.


solve_goal( ipcmessage(_s,_r,CANCEL_ME,[]) , _fd , _out ) :-
	!,
	handle_message(ipcmessage(_s,_r,CANCEL_ME,[]), _answer),
	client_db_files( _fd , _inpstream , _outstream ),
	client_db_unregister( _fd ),
	output_answer(_fd,_out,_answer),
	shutdown_service(_fd, _inpstream , _outstream),
        haltCBserverIfRequested,  {* a CANCEL_ME of the last local client can lead to halting the CBserver *}
	!.



solve_goal( _message , _fd , _out ) :-
	{* store_msg_for_log(_message), *}
	pc_update(current_fd(_fd)),
	{ writeMessage(_message), } {write to script file }
	handle_message(_message, _answer),
	output_answer(_fd,_out,_answer),
	!.


Close_extern :-
	knownTool(_toolId,JEBserver,_,_fd,System),
	thisToolId(_receiver),
	client_db_files( _fd , _inp , _out ),
	length([],_charlistlength),
	CharListToCString(_cstring,[],_charlistlength),
{ Hier soll zuerst cancelMe ausfuehren und dann informiert javaserver zu close the connection.}
	write('JEBserver will be closed...'),nl,
	make_ipcanswerstring( _answerstring, _receiver,exit, _cstring, _answerlen ),
	memfree(_cstring),
	!,
	signal_wrapper(SIGPIPE,accept),
	ipc_write(_ok,_fd,_answerstring),
	memfree(_answerstring),
	solve_goal( ipcmessage(_toolId,_receiver,CANCEL_ME,[]) , _fd , _out ).


Close_extern :-
	not(knownTool(_toolId,JEBserver,_,_fd,System)).

#DYNAMIC(current_fd/1)


{*******************************************************************}
{                                                                   }
{ store_msg_for_log(_ipcmsg)                                        }
{                                                                   }
{ Description of arguments:                                         }
{  ipcmsg : die ipcmessage die gespeichert werden soll              }
{                                                                   }
{ Description of predicate:                                         }
{   Speichert die Methode und Argumente einer Ipcmessage in dem     }
{   Praedikat message_for_log/2. Die Information wird fuer OB.log   }
{   benoetigt und spaeter (nach der TA) geschrieben.                }
{*******************************************************************}

#MODE(store_msg_for_log(i))


store_msg_for_log(ipcmessage(_,_,TELL,_args)) :-
	pointer2atom(_args,_newargs),
	pc_update(message_for_log(tell,_newargs)).

store_msg_for_log(ipcmessage(_,_,UNTELL,_args)) :-
	pointer2atom(_args,_newargs),
	pc_update(message_for_log(untell,_newargs)).

store_msg_for_log(ipcmessage(_,_,TELL_MODEL,_args)) :-
	pointer2atom(_args,_newargs),
	pc_update(message_for_log(tell_model,_newargs)).

store_msg_for_log(ipcmessage(_,_,ASK,[OBJNAMES,_cstring,_ansrep,_time])) :-
	pointer2atom([_cstring],_newargs),
	pc_update(message_for_log(ask_objnames,_newargs)).

store_msg_for_log(ipcmessage(_,_,ASK,[FRAMES,_cstring,_ansrep,_time])) :-
	pointer2atom([_cstring],_newargs),
	pc_update(message_for_log(ask_frames,_newargs)).

store_msg_for_log(_) :-
	pc_update(message_for_log(0,0)).



{*******************************************************************}
{                                                                   }
{ pointer2atom(_plist,_atom)                                        }
{                                                                   }
{ Description of arguments:                                         }
{   plist : Liste von Pointern und Atomen                           }
{    atom : Zusammengebautes Atom aus Plist                         }
{                                                                   }
{ Description of predicate:                                         }
{   Konkateniert eine Liste von Pointern (auf Strings) und Atomen   }
{   zusammen zu einer Liste. Sublistenelem. werden durch Komma      }
{   getrennt.                                                       }
{*******************************************************************}

#MODE(pointer2atom(i,o))


pointer2atom([],'') :- !.

pointer2atom([_h|_t],_atom) :-
	pc_pointer(_h),
	!,
	pc_stringtoatom(_h,_a),
	pointer2atom(_t,_newt),
	pc_atomconcat(_a,_newt,_atom).

pointer2atom([_h|_t],_atom) :-
	atom(_h),
	!,
	pointer2atom(_t,_newt),
	pc_atomconcat(_h,_newt,_atom).

pointer2atom([_h|_t],_atom) :-
	_h = [_|_],
	!,
	list2atom_with_commata(_h,_ha),
	pointer2atom(_t,_newt),
	pc_atomconcat(_ha,_newt,_atom).

list2atom_with_commata([_h],_h) :- !.
list2atom_with_commata([_h1,_h2|_r],_a) :-
	pc_atomconcat([_h1,',',_h2],_a1),
	list2atom_with_commata([_a1|_r],_a).




{*******************************************************************}
{                                                                   }
{ writeMessage(_ipcmsg)                                             }
{                                                                   }
{ Description of arguments:                                         }
{  ipcmsg : Ipcmessage die in das Skript geschrieben werden soll    }
{                                                                   }
{ Description of predicate:                                         }
{   Schreibt einen Term in das Skriptfile                           }
{*******************************************************************}

#MODE(writeMessage(i))


writeMessage(ipcmessage(_,_,TELL,_args)) :-
	pc_fopen(casefile,'testcases.new',a),
	pointer2atomlist(_args,_newargs),
	_t =.. [tell|_newargs],
	pc_swriteQuotes(_ta,_t),
	write(casefile,_ta),
	write(casefile,'.'),nl(casefile),
	pc_update(wait_for_answer(1)),
	pc_fclose(casefile).

writeMessage(ipcmessage(_,_,UNTELL,_args)) :-
	pc_fopen(casefile,'testcases.new',a),
	pointer2atomlist(_args,_newargs),
	_t =.. [untell|_newargs],
	pc_swriteQuotes(_ta,_t),
	write(casefile,_ta),
	write(casefile,'.'),nl(casefile),
	pc_update(wait_for_answer(1)),
	pc_fclose(casefile).


writeMessage(ipcmessage(_,_,ASK,_args)) :-
	pc_fopen(casefile,'testcases.new',a),
	pointer2atomlist(_args,_newargs),
	_t =.. [ask|_newargs],
	pc_swriteQuotes(_ta,_t),
	write(casefile,_ta),
	write(casefile,'.'),nl(casefile),
	pc_update(wait_for_answer(1)),
	pc_fclose(casefile).

writeMessage(ipcmessage(_,_,HYPO_ASK,_args)) :-
	pc_fopen(casefile,'testcases.new',a),
	pointer2atomlist(_args,_newargs),
	_t =.. [hypo_ask|_newargs],
	pc_swriteQuotes(_ta,_t),
	write(casefile,_ta),
	write(casefile,'.'),nl(casefile),
	pc_update(wait_for_answer(1)),
	pc_fclose(casefile).

writeMessage(ipcmessage(_,_,TELL_MODEL,_args)) :-
	pc_fopen(casefile,'testcases.new',a),
	pointer2atomlist(_args,_newargs),
	_t =.. [tell_model|_newargs],
	pc_swriteQuotes(_ta,_t),
	write(casefile,_ta),
	write(casefile,'.'),nl(casefile),
	pc_update(wait_for_answer(1)),
	pc_fclose(casefile).

writeMessage(ipcmessage(_,_,LPI_CALL,_args)) :-
	pc_fopen(casefile,'testcases.new',a),
	pointer2atomlist(_args,_newargs),
	_t =.. [lpi_call|_newargs],
	pc_swriteQuotes(_ta,_t),
	write(casefile,_ta),
	write(casefile,'.'),nl(casefile),
	pc_update(wait_for_answer(1)),
	pc_fclose(casefile).

writeMessage(_) :-
	pc_update(wait_for_answer(0)).


pointer2atomlist([],[]).

pointer2atomlist([_h|_t],[_a|_newt]) :-
	pc_pointer(_h),
	pc_stringtoatom(_h,_a),
	pointer2atomlist(_t,_newt).

pointer2atomlist([_h|_t],[_h|_newt]) :-
	pointer2atomlist(_t,_newt).





{----------------------------------------------------------------------}
{   Stop Server                                                        }
{----------------------------------------------------------------------}

stopServerIfAnswerOk(ipcanswer(_r,ok,yes)) :-
	IpcChannel_shutdown,
	halt,  
	!.

stopServerIfAnswerOk(_).


   


{----------------------------------------------------------------------}
{   Halt Server if requested in CBserverInterface                      }
{----------------------------------------------------------------------}

haltCBserverIfRequested :-
        getFlag(requestDownCBserver,lastclient),
	IpcChannel_shutdown,
        getExitStatus(_s),
	halt(_s),  { possibly halt with an error status trapped by cbserver script }
	!.
haltCBserverIfRequested :-
        getFlag(requestDownCBserver,regular),
	IpcChannel_shutdown,
	halt(0),
	!.
haltCBserverIfRequested.


{ if slave mode is set and the -r option is use, we halt with an error status to }
{ send the cbserver shell script to a loop                                       }
getExitStatus(99) :-
   get_cb_feature(repeatLoop,_r),
   _r \== 'off',
   get_cb_feature(servermode,'slave'), { so last client of a slave CBserver exits }
   !.

getExitStatus(0).


{----------------------------------------------------------------------}
{   Parameters                                                         }
{----------------------------------------------------------------------}

service_port( _portnr ) :- portnr(_portnr).


{----------------------------------------------------------------------}
{   Server                                                             }
{----------------------------------------------------------------------}

server_startup( _portnr ) :-
   setup_service( _portnr , _serv_id ),
   pc_update(server_id(_serv_id)),
   client_db_initialize,
   install_signal_handler,
   reportCBserverAsReady('IpcChannel'),
   server_loop .

server_startup( _ ) :-
   get_application( _appname ),
   remove_lock( _appname ),
   fail.

install_signal_handler :-
   operatingSystemIsWindows,
   !.

install_signal_handler :-
#IF(BIM)
   signal(SIGPIPE,accept),  { Signal behandeln, da Server sonst mit Broken Pipe abstuerzt }
	                        { 09-05-96/CQ }
   install_prolog_handler(SIGPIPE,handle_signal$IpcChannel),
#ENDIF(BIM)
   !.

{ Signalhandler fuer SIGPIPE }
{ SIGSEGV kann man leider nicht abfangen }
{ 09-05-96/CQ }
handle_signal(SIGPIPE,_goal) :-
	write('Got signal SIGPIPE. Resuming...'),nl.

#IF(BIM)
signal_wrapper(_,_) :-
   getenv('CB_VARIANT',_var),
   _var == 'windows',
   !.

signal_wrapper(_x,_y) :-
	signal(_x,_y).
#ELSE(BIM)
signal_wrapper(_,_).
#ENDIF(BIM)

server_loop :-
   repeat,
   serve_registered_clients,
   fail .



{----------------------------------------------------------------------}
{   Request Acceptance                                                 }
{----------------------------------------------------------------------}

accept_request( _serv_id ) :-
   accept_request( _serv_id , _fd , _inp , _out ), !,
   client_db_register( _fd , _inp , _out ) .

accept_request( _serv_id ) .


{----------------------------------------------------------------------}
{   Client Serving                                                     }
{----------------------------------------------------------------------}

serve_registered_clients :-
   ipc_fds( _rfds ),
   select_input( _rfds , _client ),
   serve_registered_clients( [_client] ) .


serve_registered_clients( [] ) .

serve_registered_clients( [_fd|_fds] ) :-
   server_id(_serv_id),
   _fd == _serv_id, !,					{ 10.09.92 RG if it is the 'accept'-socket of the server }
   accept_request( _fd ),
   serve_registered_clients( _fds ) .

serve_registered_clients( [_fd|_fds] ) :-
   serve_goal( _fd ),
   serve_registered_clients( _fds ) .



{----------------------------------------------------------------------}
{   Goal Serving                                                       }
{----------------------------------------------------------------------}

serve_goal( _fd ) :-
	client_db_files( _fd , _inp , _out ),
	get_ipcmessage( _inp, _msg, _out, _fd, _inp),
	!,
	IpcParse( _ipo,_msg),
	memfree( _msg ),
	!,
	GetErrFromIpcParserOutput( _err, _ipo ),
	((_err = 0,
 	 serve_goal2( _err, _fd, _out, _ipo ),
	 GetMessageFromIpcParserOutput( _im, _ipo ),
	 pc_pointer(_im),
	 (
		( \+(pc_isNullPointer(_im)),
	  	deleteIpcMessage( _im ),
	  	! )
		;
		true
	 ));
	(serve_goal2( _err, _fd, _out, _ipo ))), { Error }
	!.

{20-Mar-1990/MJf: avoid hanging clients to hang server}
serve_goal( _fd) :-    {error}
	knownTool(_id,_cl,_u,_fd,_mod),
	write( 'Known client hanging --- shutting it down' ),nl,
	client_db_files( _fd , _inpstream , _outstream ),
	client_db_unregister( _fd ),
	delete_all_notification_requests(_id),
	shutdown_service( _fd, _inpstream , _outstream ),
        retract(knownTool(_id,_cl,_u,_fd,_mod)),
	WriteTrace(minimal,IpcChannel,['Client ',_id, ' of user ',_u,' removed by force']),
        shutDownSlaveIfNoClients(_u),
        haltCBserverIfRequested,
        !.

serve_goal( _fd) :-    {error}
	write( 'Unknown Client hanging --- shutting it down' ),nl,
	client_db_files( _fd , _inpstream , _outstream ),
	client_db_unregister( _fd ),
	shutdown_service( _fd, _inpstream , _outstream ),
        shutDownSlaveIfNoClients(_u),
        haltCBserverIfRequested,
        !.

serve_goal2( 0, _fd, _out, _parserOutput ) :-
	GetIpcMessageFromC( _parserOutput, _ipcmessage ),
	solve_goal( _ipcmessage, _fd, _out ),
{*	WriteTrace(veryhigh,IpcChannel,[_ipcmessage]),  *}
	!.

{* ipcmessage is broken; still try to recover sender and receiver *}
serve_goal2( 0, _fd, _out, _parserOutput ) :-
        GetIpcMessageFromC( _parserOutput, ipcmessage(_s,_r,_m,_a) ),
	write('IpcChannel: error in ipcmessage '), write(ipcmessage(_s,_r,_m,_a)),nl,
        report_error( IPC1, IpcChannel, []), 
        solve_goal(ipcmessage(_s,_r,error,error), _fd, _out ),
	handle_error_message_queue(error),
        !.


{* ipcmessage is broken; unable to recover sender and receiver *}
serve_goal2( _err, _fd, _out, _parserOutput ) :-
        report_error( IPC2, IpcChannel, []), 
{*	write('error reading ipcmessage\n'), *}
	solve_goal(ipcmessage(CBserver,'Unknown_Tool',error,error),_fd,_out).


{ ****************************************************************** }
{                                                                    }
{  get_ipcmessage( _fptr, _msg )                                     }
{  	_fptr: pointer: File-Pointer (IPC input)                         }
{  	_msg: free:	contains the read message as C-String (char*) after call}
{                                                                    }
{  The message is supposed to end with a newline character.          }
{  _msg has to be freed by the caller                                }
{ ****************************************************************** }

get_ipcmessage( _fptr, _msg, _out ,_fd,_inp) :-
	pc_pointer(_fptr), var(_msg),
	ipc_read(_msg,_fd,_len), { 14-Mar-95/CQ: New C-function to read the ipcmessage }
	pc_pointer(_msg),
	( \+(pc_isNullPointer(_msg));
	 (pc_isNullPointer(_msg), !, fail)
	),
{* to trace how the original message looked like
	pc_stringtoatom(_msg,_atom),
	write(ipcmsg(_atom)),nl,
*}
	!.




{----------------------------------------------------------------------}
{   Client Data Base Manager                                           }
{----------------------------------------------------------------------}
#DYNAMIC( client_db_client/1 )

client_db_id( _fd , _id ) :-
   pc_inttoatom( _fd , _suffix ),
   pc_atomconcat( ipc_client_ , _suffix , _id1 ),
   pc_atomconcat( _id1 , '@IpcChannel' , _id ) .


client_db_files( _fd , _inp , _out ) :-
   client_db_id( _fd , _id ),
   pc_recorded( _id , files(_inp,_out) ) .


client_db_initialize :-
   pc_erase( client_db_client ),
   ipc_fds_initialize .


client_db_register( _fd , _inp_fp , _out_fp ) :-
   client_db_id( _fd , _id ),
   recordList( client_db_client,_fd ),
   pc_rerecord( _id , files(_inp_fp,_out_fp) ),
   ipc_fds_add( _fd ) .


client_db_unregister( _fd ) :-
   client_db_id( _fd , _id ),
   del_from_recordList(client_db_client,_fd ),
   pc_erase( _id ),
   ipc_fds_remove( _fd ) .

{recordList saves a list of terms, when a new term comes, it will be added at the end of the list.}
recordList(_key,_term):-
	pc_recorded(_key,_term1),
	!,
	pc_rerecord(_key,[_term|_term1]).
recordList(_key,_term):-
	!,
	pc_record(_key,[_term]).

del_from_recordList(_key,_term):-
	pc_recorded(_key,_termlist),
	delete(_term,_termlist,_newlist),
	pc_rerecord(_key,_newlist).

del_from_recordList(_key,_term).
{No term is corresponding this key!!! It should fail.}



{----------------------------------------------------------------------}
{   File Descriptor Masks                                              }
{----------------------------------------------------------------------}

ipc_fds_initialize :-
   server_id(_serv_id),
   pc_rerecord( ipc_fds , [_serv_id]) .

ipc_fds( _fds ) :-
   pc_recorded( ipc_fds , _fds ) .


ipc_fds_add( _fd ) :-
   pc_recorded( ipc_fds , _fds ),
   pc_rerecord( ipc_fds , [_fd|_fds] ) .


ipc_fds_remove( _fd ) :-
   pc_recorded( ipc_fds , _fds ),
   delete(_fd,_fds,_fds1),
   pc_rerecord( ipc_fds , _fds1 ).



{----------------------------------------------------------------------}


{**********************************************************************}
{*                                                                    *}
{* output_answer/2               				      *}
{* schreibt erst die Laenge der Antwort _answer1,                     *}
{* gefolgt von newline, und dann die Antwort selbst, gefolgt von      *}
{* newline, auf den stream _out.                                      *}
{*                                                                    *}
{**********************************************************************}

output_answer( _fd,_out, _answer1 ) :-
	_answer1 = ipcanswer(_receiver,_completion,_arg3),
	pc_pointer(_arg3),
	!,
	atom(_receiver),
	atom(_completion),
	replaceEmptyBuffer(_arg3),
	getPointerFromBuffer(_cstring,_arg3),
	make_ipcanswerstring( _answerstring, _receiver, _completion, _cstring, _answerlen ),
{*	write_msg_to_log(_answer1), *}  { Nachricht ins Logfile schreiben 14-06-96/CQ }
	signal_wrapper(SIGPIPE,accept),  { Signal behandeln, da Server sonst mit Broken Pipe abstuerzt }
	                         { 09-05-96/CQ }
	{ writeAnswer(_answer1), } { write to script file}
	ipc_write(_ok,_fd,_answerstring),
	disposeBuffer(_arg3),  {* here the crash of ticket #263 occurred *}
	memfree(_answerstring),

	!.


output_answer( _fd,_out, _answer1 ) :-
		replace_nil(_answer1,_answer),
	_answer = ipcanswer(_receiver,_completion,_arg3),
	atom(_receiver), atom(_completion),
	_arg3 =.. [_functor|_args],
	(
		( _functor \== char_list, !,
		TermToCharList(_arg3,_charlist))
		;
		( _args = [_charlist] )
	),
	length(_charlist,_charlistlen),
	CharListToCString(_cstring,_charlist,_charlistlen),
	make_ipcanswerstring( _answerstring, _receiver, _completion, _cstring, _answerlen ),
	memfree(_cstring),
	!,
{*	write_msg_to_log(_answer), *} { Nachricht ins Logfile schreiben 14-06-96/CQ }
	signal_wrapper(SIGPIPE,accept),  { Signal behandeln, da Server sonst mit Broken Pipe abstuerzt }
	                         { 09-05-96/CQ }
	{ writeAnswer(_answer1), } { write to script file}
	ipc_write(_ok,_fd,_answerstring),
	memfree(_answerstring),
	!.


writeAnswer(ipcanswer(_rec,_comp,_text)) :-
	pc_pointer(_text),
	wait_for_answer(1),
	pc_update(wait_for_answer(0)),
	!,
	getStringFromBuffer(_newtext,_text),
	pc_fopen(casefile,'testcases.new',a),
	pc_swriteQuotes(_ta,answer(_comp,_newtext)),
	write(casefile,_ta),
	write(casefile,'.'),nl(casefile),
	write(casefile,'{*******************************************************}'),nl(casefile),
	pc_fclose(casefile).

writeAnswer(ipcanswer(_rec,_comp,_text)) :-
	wait_for_answer(1),
	pc_update(wait_for_answer(0)),
	charlist2atom(_text,_newtext),
	pc_fopen(casefile,'testcases.new',a),
	pc_swriteQuotes(_ta,answer(_comp,_newtext)),
	write(casefile,_ta),
	write(casefile,'.'),nl(casefile),
	write(casefile,'{*******************************************************}'),nl(casefile),
	pc_fclose(casefile).

writeAnswer(_).

charlist2atom(char_list(_list),_atom) :-
	pc_atomconcat(_list,_atom).

charlist2atom(_x,_x).


{*******************************************************************}
{                                                                   }
{ write_msg_to_log(_ipcanswer)   14-06-96/CQ                        }
{                                                                   }
{ Description of arguments:                                         }
{ipcanswer : Antwort der Form ipcanser(_rec,_comp,_text)            }
{                                                                   }
{ Description of predicate:                                         }
{   Schreibt die aktuelle Methode in OB.log.                        }
{   Das Format von OB.log ist <method> NULL <arg> NULL              }
{   <method> ist dabei tell,untell oder tell_model (also nur die    }
{   Methoden, die fuer den Inhalt der DB verantwortlich sind)       }
{   <arg> ist das Argument der Methode (Frames oder Filenamen)      }
{   NULL ist genau ein Null-Byte.                                   }
{                                                                   }
{   Das OB.log-File kann von dem LogClient in examples/Clients/     }
{   LogClient gelesen werden. Das ist gleichzeitig auch ein gutes   }
{   Beispiel fuer die Verwendung der libCB.                         }
{                                                                   }
{*******************************************************************}

#MODE(write_msg_to_log(i))


write_msg_to_log(ipcanswer(_rec,_comp,_text)) :-
	message_for_log(_method,_arg),
	_method \== 0,
	_comp == ok,
	!,
	pc_update(message_for_log(0,0)),
	get_application(_appname),
	pc_atomconcat(_appname,'/OB.log',_fname),
	pc_fopen(logfile,_fname,a),
	write(logfile,_method),
    put(logfile,0),
	write(logfile,_arg),
    put(logfile,0),
	pc_fclose(logfile).

write_msg_to_log(_) :-
	pc_update(message_for_log(0,0)).


{****************************************************************
*								*
*	TermToCharList( _term, _charlist )			*
*								*
*		_term : ground					*
*		_charlist : free				*
*								*
*	converts a term _term to a list of characters 		*
*	(atoms with length 1) _charlist so that _charlist 	*
*	contains the flow of characters that would appear 	*
*	by calling write(_term).				*
*								*
*****************************************************************}


TermToCharList( _term, _charlist ) :-
	TermToAtomList( _term, _atomlist ),
	AtomListToCharList( _atomlist, _charlist ).


#LOCAL(TermToAtomList/2)
#LOCAL(ListToAtomList/2)
#LOCAL(TermArgsToAtomList/2)
#LOCAL(AtomListToCharList/2)



TermToAtomList( _term, [_term] ) :-
	atomic(_term),  { gilt auch fuer [] }
	!.

TermToAtomList( _term, _atomlist ) :-
	_term =.. [_func|_arglist],
	_arglist \== [],
	(
		( _func == '.', !,
		  {ArgList(_term,_atomlist1),}
		  ListToAtomList( _term, _atomlist1 ),
		  _atomlist2 = [ '[' | _atomlist1 ],
		  append( _atomlist2, [']'], _atomlist )
		)
		;
		( TermArgsToAtomList( _arglist, _atomlist1 ),
		  _atomlist2 = [_func, '(' | _atomlist1],
		  append( _atomlist2, [')'], _atomlist )
		)
	).


ListToAtomList( [_a], _b ) :-
	TermToAtomList(_a,_b),
	!.

ListToAtomList( [_a|_b], _atomlist ) :-
	TermToAtomList(_a,_c),
	ListToAtomList(_b,_d),
	append( _c, [ ',' | _d ], _atomlist ),
	!.


TermArgsToAtomList( [_arg], _atomlist ) :-
	TermToAtomList( _arg, _atomlist ),
	!.

TermArgsToAtomList( [_arg|_args], _atomlist ) :-
	TermToAtomList( _arg, _atomlist1 ),
	TermArgsToAtomList( _args, _atomlist2 ),
	append( _atomlist1, [ ',' | _atomlist2 ], _atomlist ).


AtomListToCharList( [], [] ) :- !.

AtomListToCharList( [_a|_b], _charlist ) :-
	atomic(_a),
	atom2list(_a,_c),
	AtomListToCharList(_b,_d),
	append(_c,_d,_charlist).



replace_nil(ipcanswer(_recv,_compl,[]),ipcanswer(_recv,_compl,nil)).

replace_nil(ipcanswer(_recv,_compl,''),ipcanswer(_recv,_compl,nil)).

replace_nil(ipcanswer(_recv,_compl,char_list([])),ipcanswer(_recv,_compl,nil)).

replace_nil(ipcanswer(_recv,_compl,_res),ipcanswer(_recv,_compl,_res)).



