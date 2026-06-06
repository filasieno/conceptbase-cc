{*
The ConceptBase.cc Copyright
Copyright 1988-2009 The ConceptBase Team. All rights reserved.
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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Manfred Jeusfeld, Tilburg University, Warandelaan 2, 5037 AB Tilburg, The Netherlands
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*}
{
*
* File:        	%M%
* Version:     	%I%
* Creation:    28-Jun-1989, Manfred Jeusfeld (UPA)
* Last change: %G%, L. Bauer (RWTH)
* Release:     %R%
* ----------------------------------------------------------
*
* Most of the code is
* taken from the BIM_Prolog Inter Process Communication Package
*
*
*
* Exported predicates:
* --------------------
*
*   + IpcChannel_call/3
*   + connectCBserver/2
*   + disconnectCBserver/0
*   
*	
*
}
{----------------------------------------------------------------------}
{                                                                      }
{   BIM_Prolog Inter Process Communication Package - Client            }
{                                                                      }
{   Author :  Alain Callebaut                                          }
{             Katholieke Universiteit Leuven                           }
{             Department of Computer Science                           }
{             Celestijnenlaan 200A                                     }
{             B-3030 HEVERLEE                                          }
{                                                                      }
{   Date :     5-Jun-1987                                              }
{   Changed : 19-Jul-1988                                              }
{                                                                      }
{----------------------------------------------------------------------}
:- module(IpcChannelAccess) .
:- import connect_service/5 from ipc .
:- import input_pending/2 from ipc .
:- import init_timeout/1 from IpcParameters .
:- import service_timeout/1 from IpcParameters .
:- import service_retry/1 from IpcParameters .
:- import client_report/1 from IpcParameters .
:- import thisToolClass/1 from IpcParameters .
:- import server_id/1 from IpcParameters.
:- import thisToolId/1 from IpcParameters .
:- import IpcChannel_call/3 from IpcChannelAccess.
:- import whatCBserverId/1 from IpcParameters .
:- import user_name/1 from IpcParameters .
{ =================== }
{ Exported predicates }
{ =================== }
:- dynamic whatIpcServer/2 .
{ ***************** c o n n e c t C B s e r v e r **************************** }
{                                                                              }
{	connectCBserver ( _host , _port )                                      }
{                         _host : ground                                       }
{			  _port : ground                                       }
{                                                                              }
{	connects CB usage environment to CB server running on _host with       }
{	port number _port. An already existing connection to another server    }
{	is cancelled.                                                          }
{                                                                              }
{ **************************************************************************** }
connectCBserver(_host,_port) :-
   update(whatIpcServer(_host,_port)),
   thisToolClass(_toolclass),
   user_name(_user),
   IpcChannel_call(_,ipcmessage("","",ENROLL_ME,
                                       [_toolclass,_user]),
                            ipcanswer(_,ok,_)).
{ ***************** d i s c o n n e c t C B s e r v e r *********************** }
{										}
{	disconnectCBserver                                                      }
{                                                                               }
{	disconnects CB usage environement from CBserver                         }
{                                                                               }
{ ***************************************************************************** }
disconnectCBserver :-
   update(whatIpcServer(unknown,unknown)),
   server_id(_id),
   _id \== unknown,
   thisToolId(_tid),
   whatCBserverId(_sid),
   IpcChannel_call(_id,ipcmessage(_tid,_sid,CANCEL_ME,[]),
                        ipcanswer(_,_ok,_rt)), 
   _rt == yes.       
{ ********************* I p c C h a n n e l _ c a l l ********************** }
{                                                                            }
{	IpcChannel_call ( _servid , _ipcmessage , _ipcanswer )               }
{			_servid : ground                                     }
{			_ipcmessage : ground                                 }
{			_ipcanswer : ground                                  }
{                                                                            }
{	performs sending of message _ipcmessage ( ipc format ) to CB server  }
{	with internal id _servid and receives answer _ipcanswer.             }
{	Special case : message with method ENROLL_ME                         }
{                      used for establishing connection to 'unknown server'  }
{		       using client_startup/3                                }
{       An already existing connection to another server is cancelled.       }
{                                                                            }
{ ************************************************************************** }
IpcChannel_call(_servid, ipcmessage(_,_,ENROLL_ME,[_toolclass,_user]),
                         ipcanswer(_cbserver_id,_comp,_toolid)) :-
   server_id(_id),
   _id \== unknown,
   thisToolId(_tid),
   IpcChannel_call(_id,ipcmessage(_tid,_,CANCEL_ME,[]),
                        ipcanswer(_,_ok,_rt)),
   _rt == yes,
   whatIpcServer(_host,_port),
   client_startup(_port,_host,_servid),      
   update(server_id(_servid)),
   service_db_files( _servid , _inp , _out ), 
   initialize_call( _inp ),
   send_request( _servid , _out ,ipcmessage('','',ENROLL_ME,
                                            [_toolclass, _user ])),!,
   receive_init( _inp ),
   receive_solutions( _inp , ipcanswer(_cbserver_id,_comp,_toolid) ),
   _comp == ok,
   update(thisToolId(_toolid)),
   update(whatCBserverId(_cbserver_id)),
   report(ipcanswer(_cbserver_id,_comp,_toolid)),!.
IpcChannel_call(_servid, ipcmessage(_,_,ENROLL_ME,[_toolclass,_user]),
                         ipcanswer(_cbserver_id,_comp,_toolid)) :-
   whatIpcServer(_host,_portnr),
   client_startup(_portnr,_host,_servid),
   update(server_id(_servid)),
   service_db_files( _servid , _inp , _out ),
   initialize_call( _inp ),
 send_request( _servid , _out ,ipcmessage('','',ENROLL_ME,
                                            [_toolclass, _user ])),!,
    receive_init( _inp ),
   receive_solutions( _inp , ipcanswer(_cbserver_id,_comp,_toolid) ),
   _comp == ok,
   update(thisToolId(_toolid)),
   update(whatCBserverId(_cbserver_id)),
   report(ipcanswer(_cbserver_id,_comp,_toolid)),!.
IpcChannel_call(_servid, ipcmessage('','',ENROLL_ME,[_toolclass,_user]),
                         ipcanswer(_,error,no)) :-
   nl,report('Client cannot be enrolled.'),nl,!.
IpcChannel_call(_id,ipcmessage(_tid,_s,CANCEL_ME,[]),ipcanswer(_s,_ok,_rt)) :-
   service_db_files(_id,_inp,_out),
   send_request(_id,_out,ipcmessage(_tid,_s,CANCEL_ME,[])),!,
   receive_init( _inp ),
   receive_solutions( _inp , ipcanswer(_,_ok,_rt)),
   _rt == yes,
   send_request(_id,_out,stop),
   update(server_id(unknown)),
   update(thisToolId(unknown)),
   update(whatCBserverId(unknown)),!.
IpcChannel_call(_id,ipcmessage(_tid,_s,CANCEL_ME,[]),ipcanswer(_s,error,no)):- 
  nl,report('Client '),report(_tid),report(' cannot be cancelled.'),nl,!.
IpcChannel_call(_id,ipcmessage(_tid,_s,STOP_SERVER,[_password]),
                  ipcanswer(_s,_compl,_rt)) :-
  service_db_files(_id,_inp,_out),
  send_request(_id,_out,ipcmessage(_tid,_s,STOP_SERVER,[_password])),
  receive_init( _inp ),
  receive_solutions( _inp , ipcanswer(_,_compl,_rt)),
  _rt == yes,
  send_request(_id,_out,stop),
  update(server_id(unknown)),
  update(thisToolId(unknown)),
  update(whatCBserverId(unknown)),!.
IpcChannel_call(_id,ipcmessage(_tid,_s,STOP_SERVER,[]),
                  ipcanswer(_s,_compl,_rt)) :-
  service_db_files(_id,_inp,_out),
  send_request(_id,_out,ipcmessage(_tid,_s,STOP_SERVER,[])),
  receive_init( _inp ),
  receive_solutions( _inp , ipcanswer(_,_compl,_rt)),
  _rt == yes,
  send_request(_id,_out,stop),
  update(server_id(unknown)),
  update(thisToolId(unknown)),
  update(whatCBserverId(unknown)),!.
IpcChannel_call(_id,ipcmessage(_tid,_s,STOP_SERVER,[_password]),
                  ipcanswer(_s,error,no)) :-
  nl,report('CBServer cannot be stopped. Maybe you are not the owner.'),nl,!.
{ 8-Mar-1990/MJf: allow so-called "lazy" IPC messages. See module }
{ MessageHandler of the server on the meaning of them.            }
IpcChannel_call( _servid , _message, _answer ) :-
     ordinaryMessage(_message),
     service_db_files( _servid , _inp , _out ), 
     initialize_call( _inp ),
     send_request(_servid, _out, _message), !,
     receive_init( _inp ),
     receive_solutions( _inp , _answer ).
IpcChannel_call( _servid , _message, _answer ) :-
   report( 'Not connected to service '(_servid) ),!,fail .

ordinaryMessage(ipcmessage(_s,_r,_method,_arg)) :-
   _method \== ENROLL_ME,
   _method \== CANCEL_ME,
   _method \== STOP_SERVER.
ordinaryMessage(lazy_ipcmessage(_s,_r,_method,_arg)).
{======================}
{ private predicates   }
{======================}
{----------------------------------------------------------------------}
{   Reporting                                                          }
{----------------------------------------------------------------------}
    report( _x ) :-
   client_report( on ), !,
   write( _x ) , nl .

report( _x ) .
{----------------------------------------------------------------------}
{   Client connection                                                  }
{----------------------------------------------------------------------}
client_startup( _portnr , _host , _id ) :-
   service_db_id( _portnr , _host , _id ),
   (
      service_db_files( _id , _inp , _out ), !,
      report( 'Already connected to service '(_id) ),!,fail
   ;
      connect_service( _portnr , _host , _fd , _inp , _out ),
      service_db_register( _id , _inp , _out ),
      report( 'Connected to service '(_id) )
   ) .
{----------------------------------------------------------------------}
{   Request Treatment                                                  }
{----------------------------------------------------------------------}
initialize_call( _inp ) :-
   init_timeout( _timeout ),
   (
      input_pending( _inp , _timeout ), !,
      read( _inp , _ ),
      initialize_call( _inp )
   ;
      true
   ) .
{  Append double colons  before each element in a Prolog list }
{  Do not appen colons to keywords of the IPC protocol }
{  quote_args( Src_list, Dst_list).  }
append_top( _atom, _list, [ _atom | _list ]).

append_back( _atom, [], [ _atom ] ).
append_back( _atom,  [ _H | _T] ,  [ _H | _newlist ]  ) :-
	append_back( _atom,  _T,  _newlist ).

keyword( _atom ) :-
	_atom == 'TELL';
	_atom == 'TELL_MODEL';
	_atom == 'UNTELL';
	_atom == 'ASK';
	_atom == 'FRAMES';
	_atom == 'OBJNAMES';
	_atom == 'HYPO_ASK';
	_atom == 'ENROLL_ME';
	_atom == 'CANCEL_ME';
	_atom == 'NEXT_MESSAGE';
	_atom == 'STOP_SERVER';
	_atom == 'REPORT_CLIENTS';
	_atom == 'ERROR_REPORT';
	_atom == 'PROLOG_CALL'.

quote_args([], []).
quote_args([ [ _List | _Tail ] ], _Result ) :-
		quote_args( [ _List  ],  _t1 ),
		_Result = [ _t1 ].	
quote_args ( [ _Head  |  _Tail1 ], [ _NewHead | _Tail2 ]) :-
		\+keyword( _Head),
		name( _Head , _t1 ),
	              append_top(  34, _t1, _t2),
		append_back( 34, _t2, _t3 ),
		name( _NewHead, _t3 ),
		quote_args( _Tail1, _Tail2 ).
quote_args ( [ _Head  |  _Tail1 ], [ _Head | _Tail2 ]) :-	{ do not quote keywords }
		quote_args( _Tail1, _Tail2 ).

send_request( _serv_id , _out , stop ) :- !,
   	write( _out , stop ), write( _out , '.\n' ), flush( _out ),
   	service_db_unregister( _serv_id ) .
send_request( _serv_id , _out ,  ipcmessage( _sender, _receiver, _method, _args )  ) :-
{7-7-93/FL printf instead of write ==>blocking runtime version}  
	atomconcat( ['"', _sender,'"'], _t1 ),
    	atomconcat( ['"', _receiver, '"'], _t2),
    	quote_args ( _args, _t3),				{ LB - 25.Nov.94 }
	{write( ipcmessage( _t1, _t2, _method, _t3 )), nl,}
   	swrite( _atom ,  ipcmessage( _t1, _t2, _method, _t3 ) ),
   	printf(_out,'%s .\n',_atom),
   	flush( _out ) .

receive_init( _inp ) :-
   service_retry( _try ),
   receive_init( _inp , _try ).
receive_init( _inp , _try ) :-
   _try1 is _try - 1,
   service_timeout( _timeout ),
   (
      input_pending( _inp , _timeout ), !
   ;
      _try1 > 0, !,
      report( 'Server not responding. Still trying.' ),
      receive_init( _inp , _try1 )
   ;
      report( 'Server not responding. Aborting.' ),
      fail
   ) .
{ read message length until newline symbol }
receive_length(_inp) :-
	readc(_inp,_t1),
	((_t1 == '\n',!
	 );
	 (receive_length(_inp),!
	)).
receive_length(_inp) :-
	write('Connection to server broken'),nl,
	halt.

receive_solutions( _inp , ipcanswer( _a,  _b,  _c)  ) :-
	receive_length(_inp),!,
	read(_inp,  ipcanswer( _t3,  _b , _t4 ) ),
	asciilist( _a, _t3 ),
	asciilist( _c, _t4 ).
{----------------------------------------------------------------------}
{   Service Data Base Manager                                          }
{----------------------------------------------------------------------}
service_db_id( _portnr , _host , _id ) :-
   inttoatom( _portnr , _portname ),
   atomconcat( _host , _portname , _id ) .

service_db_id_internal( _id , _id_int ) :-
   module( _id_int , IpcChannelAccess , _id ).

service_db_files( _id , _inp , _out ) :-
   service_db_id_internal( _id , _id_int ),
   recorded( _id_int , files(_inp,_out) ) .

service_db_register( _id , _inp_fp , _out_fp ) :-
   service_db_id_internal( _id , _id_int ),
   rerecord( _id_int , files(_inp_fp,_out_fp) ) .

service_db_unregister( _id ) :-
   service_db_id_internal( _id , _id_int ),
   erase( _id_int ) .
{----------------------------------------------------------------------}
