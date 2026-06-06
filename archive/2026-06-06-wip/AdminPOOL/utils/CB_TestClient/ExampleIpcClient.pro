{
*
* File:        	ExampleIpcClient.pro
* Version:     	1.3
* Creation:    28-Aug-1992, Hans W. Nissen (RWTH)
* Last change: 16 Dec 1994, L. Bauer (RWTH)
* Release:     	1
* ----------------------------------------------------------

}
main :- runExClient.


:- global trace_mode/1 .
:- global stop_server/1 .
:- global tell_file/1 .

:- dynamic trace_mode/1 .
:- dynamic stop_server/1 .
:- dynamic tell_file/1 .

 :- module(ExampleIpcClient) .

 :-  import IpcChannel_call / 3 from IpcChannelAccess .

 :-  import connectCBserver / 2 from IpcChannelAccess .

 :-  import disconnectCBserver / 0 from IpcChannelAccess .

 :-  import thisToolClass / 1 from IpcParameters .

 :-  import thisToolId / 1 from IpcParameters .

 :-  import whatCBserverId / 1 from IpcParameters .

 :-  import server_id / 1 from IpcParameters .

 :-  import whatIpcServer / 2 from IpcParameters .

 :-  import init_timeout / 1 from IpcParameters .

 :-  import service_timeout / 1 from IpcParameters .

 :-  import service_retry / 1 from IpcParameters .

 :-  import user_name / 1 from IpcParameters .

 :-  import client_report / 1 from IpcParameters .
 :- import read_text_file/2 from ExternalCode. 

:-import my_time/2 from ExternalCode.
:-import difftime/3 from ExternalCode .

runExClient  :-go,halt.


go :-
	see('startup'),
	init_connection,!,
	write('Read from file... '),read(_fname),nl,
	write(_fname),nl,
	((read(_stop),write(_stop),nl,assert(_stop));true),
	((read(_tracemode),write(_tracemode),nl,assert(_tracemode));true),
	((read(_tell),write(_tell),nl,assert(_tell));true),
	seen,
	fopen(newcasefile,'result.log',w),
	fopen(casefile,_fname,r),
	fopen(errors,'error.log',w),
	fopen(ok,'ok.log',w),
	read_test_cases,
	fclose(errors),
	fclose(newcasefile),
	fclose(ok),
	close_connection.

read_test_cases :-
	read(casefile,_term),
	read(casefile,_answer),
	handle_term(_term,_ans,_err),
	please(wq,on),
	write(newcasefile,_term),
	please(wq,off),
	write(newcasefile,' . \n'),
	please(wq,on),
	write(newcasefile,_ans),
	please(wq,off),
	write(newcasefile,' . \n'),
	handle_answer(_term,_ans,_answer,_err),
	!,
	((trace_mode(yes),
	  write('\n\nWaiting for RETURN'),nl,
	  readln(_));
	 (true)
	),
	read_test_cases.
	
read_test_cases :-
	write(Ende),nl,
	fclose(casefile).
	


init_connection :-
		read(_host), 
		read(_port), 
		write('connecting host '),write(_host), write(' on port '),write(_port),nl,
		connectCBserver(_host,_port ) , ! .

close_connection :- 
	stop_server(yes),
	handle_term(stop(server),answer(_comp,_text),_err).

close_connection :-
	disconnectCBserver.
	
loop :- read( _method ) , 
	read(_arguments) ,
	handleIt( _method , _arguments ) , ! , loop .

handleIt(exit, _ ) :- stop .

handleIt(connect, _ ) :- close_connection , manual_connect , ! .

handleIt(param, _ ) :- GetAndDisplayParam , ! .

handleIt(_method,_argument) :- handleIt(_method,_argument,_,_,_).

handleIt( _method , _args,_comp,_val,_errormsgs ) :- 			{ process CBserver method call }
	server_id( _serverID ) ,
	thisToolId( _toolId ) , 
	ipc_encode(_args,_arguments),
	whatCBserverId( _whatServerID ) ,
	write('Method:          '),write(_method),nl,
	write('Arguments:       '),write(_arguments),nl,
	my_time(_t1,0x0),
	IpcChannel_call( _serverID ,
	ipcmessage( _toolId , _whatServerID , _method , _arguments ),
	ipcanswer( _tool , _comp , _val )) , 
	my_time(_t2,0x0),
	difftime(_t3,_t2,_t1),
	printf('Response Time:   %.2f secs',_t3),nl,
        get_errors(_comp,_errormsgs),
	write('Responding tool: ') , 
	write( _tool ) , nl , write('Completion:      ') , 
	write( _comp ) , nl , 
	write('Return value:    ') , write( _val ) , nl ,nl, ! .

get_errors(error,_newmsg) :-
	server_id(_sid),
	 thisToolId( _tid ) , 
	whatCBserverId( _cbid ) , 
	IpcChannel_call( _sid ,
	ipcmessage( _tid , _cbid , NEXT_MESSAGE , [ERROR_REPORT] ),
	ipcanswer( _tool , _comp , _errormsg )) , 
	handle_error(_comp,_errormsg,_newmsg).

handle_error(ok,_msg,[_errmsg|_restmsg]) :-
	_msg \== 'empty_queue',
	_msg =.. _list,
	split_atom(_msg,'[',_,_msg1),
	split_atom(_msg1,']',_errmsg1,_),
	atomconcat('\"',_errmsg2,_errmsg1),
	atomconcat(_errmsg,'\"',_errmsg2),
	get_errors(error,_restmsg).
	
handle_error(ok,empty_queue,[]).


get_errors(_,['Es wurde kein Fehler vom Server gemeldet.']).


GetAndDisplayParam :- 
	whatIpcServer( _458 , _459 ) , 
	server_id( _464 ) , 
	thisToolId( _469 ) , 
	whatCBserverId( _474 ) , 
	thisToolClass( _479 ) ,
	 init_timeout( _484 ) , 
	service_timeout( _489 ) , 
	service_retry( _494 ) , 
	user_name( _499 ) , 
	client_report( _504 ) ,
	 write('host: ') , write( _458 ) , nl , write('port: ') , write( _459 ) , nl , write('serverID: ') , 
	write( _464 ) , nl , write('ToolID: ') , write( _469 ) , nl , write('whatCBserverId: ') , 
	write( _474 ) , nl , write('thisToolClass: ') , write( _479 ) , nl , write('init_timeout: ') , 
	write( _484 ) , nl , write('service_timeout: ') , write( _489 ) , nl , 
	write('service_retry: ') , write( _494 ) , nl , write('user_name: ') , 
	write( _499 ) , nl , write('client_report: ') , write( _504 ) , nl .


{********************* C B c o n s u l t *******************}
{*                                                         *}
{* CBconsult(_CBPath,[(_UserPath,_File)|_RFiles])          *}
{* CBconsult(_CBPath,[(_UserPath,_Cond -> _File)|_RFiles]) *}
{*                                                         *}
{* CBconsult consults a list of prolog files. There exists *}
{* different modes to load a file:                         *}
{* If _UserPath is a free variable then CBconsult takes    *}
{* the file from the directory _CBPath, which is a default *}
{* value for the directory that contains the ConceptBase   *}
{* source files. In the case, where _UserPath is ground,   *}
{* CBconsult loads the file from the directory _UserPath.  *}
{* The user is able to give a condition _Cond, which must  *}
{* be satisfied for loading a concrete file. This is must  *}
{* be written in the following form:                       *}
{* _Cond -> _File.                                         *}
{*                                                         *}
{* 17.07.92 RG before consulting from _CBPath try to find  *}
{*          _File in the local directory                   *}
{*                                                         *}
{***********************************************************}


CBconsult (_,[]) :- !.

CBconsult (_defPath,[ _FileSpec|_RFiles]) :-
        CBconsult(_defPath,_FileSpec),
        CBconsult(_defPath,_RFiles).


CBconsult (_CBPath,(_UserPath,_Cond -> _File)) :-
        _Cond,
        !,
        CBconsult(_CBPath,(_UserPath,_File)).


CBconsult (_CBPath,(_UserPath,_File)) :-
        var(_UserPath),
        !,
        CBconsult(_CBPath,_File).

CBconsult (_,(_UserPath,_File)) :-
        !,
        CBconsult(_UserPath,_File).

CBconsult(_,_fnam) :-
        atomconcat(_fnam,'.pro',_fpro),
        error_message(600,off),
        exists(_fpro),
        error_message(600,on),
        !,
        consult(_fnam).

CBconsult(_Path,_fnam) :-
        error_message(600,on),
        atomconcat(_Path,_fnam,_absNam),
        !,
        consult(_absNam).


consult_IpcModules :-
	expand_path('$CBS_DIR', _cbh),
	atomconcat( [ _cbh, '/' ], _cbhnew ),
	CBconsult( _cbhnew, [
	( _, IpcParameters) , 
	( _, IpcChannelAccess) ,
	( _, BimIpc)]), 
	consult_external,
	!.
	
consult_external :-
	argc(1),
	argv(1,'-i'),
	expand_path('$CBS_DIR', _cbh),
	atomconcat( [ _cbh, '/' ], _cbhnew ),
	CBconsult( _cbhnew, [(_,ExampleClientCodeLoader)]),
	!.

consult_external :-
	!.


ipc_encode([],[]).
ipc_encode([_arg|_args],[_narg|_nargs]) :-
	ipc_encode2(_arg,_narg),
	ipc_encode(_args,_nargs).

ipc_encode2(_arg,_narg) :-
	atom(_arg),
	atomtolist(_arg,_charlist),
	ipc_encode_chars(_charlist,_nlist),
	atomconcat(_nlist,_narg).

ipc_encode2(_arg,_narg) :-
	_arg =[_|_],
	ipc_encode(_arg,_narg).

ipc_encode2(_a,_a).

ipc_encode_chars([],[]).
ipc_encode_chars(['"'|_cs],['\\','"'|_ncs]) :-
	ipc_encode_chars(_cs,_ncs).

ipc_encode_chars(['\\'|_cs],['\\','\\'|_ncs]) :-
	ipc_encode_chars(_cs,_ncs).

ipc_encode_chars([_c|_cs],[_c|_ncs]) :-
	ipc_encode_chars(_cs,_ncs).



handle_term(tell(_frames),answer(_comp,_text),_err) :-
	handleIt(TELL,[_frames],_comp,_text,_err).
	
handle_term(untell(_frames),answer(_comp,_text),_err) :-
	handleIt(UNTELL,[_frames],_comp,_text,_err).
	
handle_term(ask(_askformat,_query,_ansrep,_time),answer(_comp,_text),_err) :-
	handleIt(ASK,[_askformat,_query,_ansrep,_time],_comp,_text,_err).
   
handle_term(hypo_ask(_frames,_askformat,_query,_ansrep,_time),answer(_comp,_text),_err) :-
	handleIt(HYPO_ASK,[_frames,_askformat,_query,_ansrep,_time],_comp,_text,_err).
   
handle_term(tell_model([_file]),answer(_comp,_text),_err) :-
	tell_file(no),
	read_smlfile(_file,_frames),
	handleIt(TELL,[_frames],_comp,_text,_err).

handle_term(tell_model(_files),answer(_comp,_text),_err) :-
	not tell_file(no),
        handleIt(TELL_MODEL,[_files],_comp,_text,_err).

handle_term(lpi_call(_arglist),answer(_comp,_text),_err) :-
	handleIt(LPI_CALL,_arglist,_comp,_text,_err).
 
handle_term(stop(server),answer(_comp,_text),_err) :-
	handleIt(STOP_SERVER,[],_comp,_text,_err).
 
 
 
handle_answer(_term,answer(_comp,_text),answer(_comp,_text2),_err) :-
	((_text2 == egal);(var(_text));(charlist2atom(_text,_atom),same_words(_atom,_text2))),!,
	write(ok,'Antwort richtig: '),
	write(ok,_term),
	nl(ok),
	write(ok,'Error_Reports:   '),
	writeList(ok,_err),nl(ok),
	write(ok,'{*******************************************************}'),nl(ok),
	nl(ok).
	
handle_answer(_term,answer(_comp,_text),_expans,_err) :-
	charlist2atom(_text,_atom),
	write(errors,'Antwort nicht korrekt: '),
	write(errors,_term),nl(errors),
	write(errors,'Erwartet wurde:        '),
	write(errors,_expans),nl(errors),
	write(errors,'Die Antwort war aber:  '),
	write(errors,answer(_comp,_atom)),nl(errors),
	write(errors,'Error_Reports:         '),
	writeList(errors,_err),nl(errors),
	write(errors,'{*******************************************************}'),nl(errors),
	nl(errors).





split_atom(_atom,_split,_part1,_part2) :-
	atompartsall(_atom,_split,_pos),
	atomlength(_atom,_atomlen),
	atomlength(_split,_splitlen),
	_rlen is _atomlen + _splitlen - _pos - 1 ,
	_pos1 is _pos + _splitlen,
	atompart(_atom,_part2,_pos1,_rlen),
	atomconcat(_a,_part2,_atom),
	atomconcat(_part1,_split,_a).


charlist2atom(char_list(_list),_atom) :-
	write(char_list(_list)),nl,
	atomconcat(_list,_atom).

charlist2atom(_x,_x).


writeList(_f,[_h|_t]) :-
	write(_f,_h),
	nl(_f),
	writeList(_f,_t).
	
writeList(_f,[]) :-
	nl(_f).

same_words(_a,_a).
same_words(_a,_b) :-
	not atomic(_a),swrite(_aa,_a),
	same_words(_aa,_b).
same_words(_a,_b) :-
	not atomic(_b),swrite(_ba,_b),
	same_words(_a,_ba).

same_words(_a,_b) :-
	atomic(_a),atomic(_b),!,
	atomtolist(_a,_al),
	atomtolist(_b,_bl),
	same_words2(_al,_bl).
same_words(_a,_b) :-
	_a \= [_|_],
	_b \= [_|_],
	_a =.. _l1,
	_b =.. _l2,
	same_words(_l1,_l2).
same_words([_x|_t1],[_y|_t2]) :- 
	same_words(_x,_y),
	same_words(_t1,t2).

	
same_words2([],[]) :- !.

same_words2([_h|_t1],[_h|_t2]) :-
	!,
	same_words2(_t1,_t2).
	
same_words2([' '|_t],_l) :-
	same_words2(_t,_l).
	
same_words2(_l,[' '|_t]) :-
	same_words2(_l,_t).

same_words2(['\n'|_t],_l) :-
	same_words2(_t,_l).
	
same_words2(_l,['\n'|_t]) :-
	same_words2(_l,_t).

same_words2(['\t'|_t],_l) :-
	same_words2(_t,_l).
	
same_words2(_l,['\t'|_t]) :-
	same_words2(_l,_t).

same_words2(['\r'|_t],_l) :-
	same_words2(_t,_l).
	
same_words2(_l,['\r'|_t]) :-
	same_words2(_l,_t).

same_words2(_l,['\\'|_t]) :-
	same_words2(_l,_t).
same_words2(['\\'|_t],_l) :-
	same_words2(_t,_l).

	
read_smlfile(_fname,_atom) :-
    atomconcat(_fname,'.sml',_smlname),
    read_text_file(_atom,_smlname).

{
read_smlfile(_fname,_atom) :-
	atomconcat(_fname,'.sml',_smlname),
	fopen(smlfile,_smlname,r),
	read_text_from_file(_atom),
	fclose(smlfile).

read_text_from_file(_atom) :-
        readc(smlfile,_c),
        read_text_from_file(_rest),
	atomconcat(_c,_rest,_atom).
 
read_text_from_file('') :-
        eof(smlfile).
} 

?- consult_IpcModules.
?- runExClient.
