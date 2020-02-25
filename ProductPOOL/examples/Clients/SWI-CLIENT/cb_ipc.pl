%=============================================*
% File: cb_ipc.pl
% Author: Daniel Gross
% Created: 2020-02-24 (2020-02-25)
% -----------------------------------------
% swi prolog ipc access to cb
% (c) 2020 Daniel Gross 
% grossd18@gmail.com 
%=============================================*

/**
* Copyright 2020 Daniel Gross. All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without modification, are permitted
* provided that the following conditions are met:
* 
*    1. Redistributions of source code must retain the above copyright notice, this list of
*       conditions and the following disclaimer.
*    2. Redistributions in binary form must reproduce the above copyright notice, this list of
*       conditions and the following disclaimer in the documentation and/or other materials
*       provided with the distribution.
* 
* THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
* INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
* PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONCEPTBASE TEAM OR CONTRIBUTORS BE
* LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
* OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
* CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
* OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* 
* ----
* 
* 
* This license is a FreeBSD-style copyright license.
* Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/


:- module(cb_ipc,[
	
	cb_init_ipc/1,
	cb_init_ipc/2,
	cb_init_ipc/3,
	cb_enroll_me/2, 
	cb_cancel_me/1, 
	cb_tell/2,
	cb_untell/2,
	cb_ask/2,
	cb_ask/3,
	cb_ask/5,
	
	cb_is_ok/1,
	cb_mon_init_ipc/2,		
	cb_mon_enroll_me/3,
	cb_mon_cancel_me/2,
	cb_mon_tell/3,
	cb_mon_untell/3,
	cb_mon_ask/3,
	cb_mon_ask/4,
	cb_mon_ask/5

	]).

% ------------------------------------------------------------------------------------	

cb_is_ok((ok, _)). % for monad

% ------------------------------------------------------------------------------------	

get_error_messages(Msgs) :-
	aux_get_error_messages([], Msgs).
		
aux_get_error_messages(Msgs, New_Msgs) :-
	next_message('ERROR_REPORT', M),
	(M = [] ->
		New_Msgs = Msgs
		;
	aux_get_error_messages( [M | Msgs], New_Msgs)).
	
next_message(Type, M) :-
	cb_client(Server_str, Client_str),
	format(string(Msg), 'ipcmessage(~q, ~q, NEXT_MESSAGE, [~w]).', [Client_str, Server_str, Type]),
	aux_send_message(Msg),
	aux_read_message_result(M).	
	
aux_read_message_result(Result) :-
	connectedReadStream(IStream), 	
	read_line_to_codes(IStream,S1),			% read length, has nl
	atom_string(A, S1),
	atom_number(A, N1),
	N2 is N1 + 1, 							% len is one minus real len
	read_string(IStream, N2, S2),
%	read_line_to_codes(IStream,S12),		% read away last nl	
%	write(S12),
%	read_string(IStream, "\n", "\r", _End1, _Result1),
%	read_string(IStream, ".", "\r", _End, S2),
	read_term_from_atom(S2, X2, []),
	X2 = ipcanswer(_Server_str, _, Message),
	read_term_from_atom(Message, X3, []),
	(X3 = empty_queue ->
		Result = []
		;
	 X3 = ipcmessage(_, _, _, [Result])).
	
	
	
% ------------------------------------------------------------------------------------	

aux_send_message(Msg) :-
	connectedWriteStream(OStream),	
	string_length(Msg, Len),
	B1 is 88,									% letter X in ascii, by convention
	B2 is (Len div 16777216) mod 256,			% encoding of length in 4 bytes
	B3 is (Len div 65536) mod 256,
	B4 is (Len div 256) mod 256,
	B5 is (Len mod 256),
	write(OStream, B1),
	write(OStream, B2),
	write(OStream, B3),
	write(OStream, B4),
	write(OStream, B5),							% no nl for CB, before msg
	write(OStream, Msg),
	nl(OStream),								% only at end of stream
	flush_output(OStream).

% ------------------------------------------------------------------------------------	

aux_read_result(Result) :-
	connectedReadStream(IStream), 
	read_line_to_codes(IStream,_S),			% read first two chars / is ignored
	read_line_to_codes(IStream,S2),			% read result	
	read_term_from_atom(S2, X2, []),
	X2 = ipcanswer(_Server_str, Result0, _Client_str),
	(Result0 = error ->
		Result = error
		;
		Result = (ok, Result0)), !.

aux_read_result((error, 'unexpected_error in aux_read_result')).
	
	
% ------------------------------------------------------------------------------------	

aux_query_read_result(Result) :-
%	trace,
	connectedReadStream(IStream), 
	read_line_to_codes(IStream,S1),			% read length, has nl
	atom_string(A, S1),
	atom_number(A, N1),
	read_string(IStream, N1, S2),
	read_line_to_codes(IStream,S12),		% read away last nl	
	write(S12),
%	read_string(IStream, "\n", "\r", _End1, _Result1),
%	read_string(IStream, ".", "\r", _End, S2),
	read_term_from_atom(S2, X2, []),
	X2 = ipcanswer(_Server_str, _, Result0),
	Result = (ok, Result0), !.
	
aux_query_read_result((error, 'unexpected_error in aux_query_read_result')) :-
	
% ------------------------------------------------------------------------------------	

recov_1(X, (error, X)).

% ------------------------------------------------------------------------------------	

cb_mon_init_ipc(R1, R2) :-
	cb_is_ok(R1),
	cb_init_ipc(4001, R2).
	
	
cb_init_ipc(Result) :-
	cb_init_ipc(4001, Result).
	
cb_init_ipc(Port, Result) :-
	retractall(cb_client(_, _)),
	retractall(connectedWriteStream(_)),
	retractall(connectedReadStream(_)),
	catch(
		(aux_connect(Port),
		 Result = (ok, connected)),
		Xs,
		recov_1(Xs, Result)), !.
	
cb_init_ipc(_, (error, 'unexpected_error in cb_init_ipc')).

cb_init_ipc(Host, Port, Result) :-
	retractall(cb_client(_, _)),
	retractall(connectedWriteStream(_)),
	retractall(connectedReadStream(_)),
	catch(
		(aux_connect(Host, Port),
		 Result = (ok, connected)),
		Xs,
		recov_1(Xs, Result)), !.
	
cb_init_ipc(_, _, (error, 'unexpected_error in cb_init_ipc')).


aux_connect(Port) :-
	tcp_socket(Socket),
	gethostname(Host), % local host
	tcp_connect(Socket, Host:Port),
	tcp_open_socket(Socket, INs, OUTs),
	assert(connectedReadStream(INs)),
	assert(connectedWriteStream(OUTs)).

aux_connect(Host, Port) :-
	tcp_socket(Socket),
	tcp_connect(Socket, Host:Port),
	tcp_open_socket(Socket, INs, OUTs),
	assert(connectedReadStream(INs)),
	assert(connectedWriteStream(OUTs)).

% ------------------------------------------------------------------------------------	

cb_mon_enroll_me(User, Result_in, Result_out) :-
	cb_is_ok(Result_in) ->
		cb_enroll_me(User, Result_out)
		;
		Result_out = Result_in.
	
cb_enroll_me(User, Result) :-
	catch(
		(aux_enroll(User),
		 aux_read_enroll_result(Result)),
		Xs,
		recov_1(Xs, Result)).

aux_enroll(User) :- 
	format(string(Msg), 'ipcmessage(~q, ~q, ENROLL_ME, [~q, ~q]).', ["", "","swi_ipc", User]),
	aux_send_message(Msg).

aux_read_enroll_result(Result) :-
	connectedReadStream(IStream), 
	read_line_to_codes(IStream,_S),			% read first two chars line / length
	read_line_to_codes(IStream,S2),			% read result of enroll line
	read_term_from_atom(S2, X2, []),
	X2 = ipcanswer(Server_str, Result0, Client_str),
	Result = (ok, Result0),
	assert(cb_client(Server_str, Client_str)), !.

aux_read_enroll_result((error, 'unexpected_error in aux_read_enroll_result')).

% ------------------------------------------------------------------------------------	
cb_mon_cancel_me(Result_in, Result_out) :-
	cb_is_ok(Result_in) ->
		cb_cancel_me(Result_out)
		;
		Result_out = Result_in.
		
cb_cancel_me(Result) :-
	catch(
		(aux_cancel_me,
		 aux_read_result(Result)),
		Xs,
		recov_1(Xs, Result)),
		connectedWriteStream(OStream),		
		connectedReadStream(IStream),		
        close(IStream, [force(true)]),
        close(OStream, [force(true)]),
		retractall(cb_client(_, _)),
		retractall(connectedWriteStream(_)),
		retractall(connectedReadStream(_)), !.

cb_cancel_me((error, 'unexpected_error in cb_cancel_me')).
		
aux_cancel_me :-
	cb_client(Server_str, Client_str),
	format(string(Msg), 'ipcmessage(~q, ~q, CANCEL_ME, []).', [Client_str, Server_str]),
	aux_send_message(Msg).

% ------------------------------------------------------------------------------------	
cb_mon_tell(Frame, Result_in, Result_out) :-
	cb_is_ok(Result_in) ->
		cb_tell(Frame, Result_out)
		;
		Result_out = Result_in.

cb_tell(Frame, Result) :-
	catch(
		aux_tell_untell('TELL', Frame, Result),
		Xs,
		recov_1(Xs, Result)).

cb_mon_untell(Frame, Result_in, Result_out) :-
	cb_is_ok(Result_in) ->
		cb_untell(Frame, Result_out)
		;
		Result_out = Result_in.

cb_untell(Frame, Result) :-
	catch(
		aux_tell_untell('UNTELL', Frame, Result),
		Xs,
		recov_1(Xs, Result)).

aux_tell_untell(X, Frame, Result) :-
	cb_client(Server_str, Client_str),
	format(string(Msg), 'ipcmessage(~q, ~q, ~w, [~q]).', [Client_str, Server_str, X, Frame]),
	aux_send_message(Msg),
	aux_read_result(Result0),
		(Result0 = error ->
			(get_error_messages(Result1),
			Result = (error, Result1))
		;
		Result = Result0).

% ------------------------------------------------------------------------------------	

cb_mon_ask(Query, Result_in, Result_out) :-
	cb_is_ok(Result_in) ->
		cb_ask(Query, Result_out)
		;
		Result_out = Result_in.

cb_ask(Query, Result) :-
	cb_ask('OBJNAMES', Query, "default", "Now", Result).

cb_mon_ask(Query, AnswerRep, Result_in, Result_out) :-
	cb_is_ok(Result_in) ->
		cb_ask(Query, AnswerRep, Result_out)
		;
		Result_out = Result_in.
		
cb_ask(Query, AnswerRep, Result) :-
	cb_ask('OBJNAMES', Query, AnswerRep, "Now", Result).

cb_mon_ask(Query, AnswerRep, Rollbacktime, Result_in, Result_out) :-
	cb_is_ok(Result_in) ->
		cb_ask(Query, AnswerRep, Rollbacktime, Result_out)
		;
		Result_out = Result_in.
			
cb_ask(Format, Query, AnswerRep, Rollbacktime, Result) :-
	catch(
		aux_ask(Format, Query, AnswerRep, Rollbacktime, Result),
		Xs,
		recov_1(Xs, Result)).
				
aux_ask(Format, Query, AnswerRep, Rollbacktime, Result) :-
	cb_client(Server_str, Client_str),
	format(string(Msg), 'ipcmessage(~q, ~q, ASK, [~w, ~q, ~q, ~q]).', [Client_str, Server_str,Format, Query, AnswerRep, Rollbacktime]),
	aux_send_message(Msg),
	aux_query_read_result(Result0),
		(Result0 = error ->
			(get_error_messages(Result1),
			Result = (error, Result1))			
		;
		Result = Result0).
	
