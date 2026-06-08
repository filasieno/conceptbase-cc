{
*
* File:        	IpcChannel.pro
* Version:     	7.6
* Creation:    22-Jun-1989, Manfred Jeusfeld (UPA)
* Last Change: 	22 Mar 1995, Christoph Quix (RWTH)
* Release:     	7
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

{----------------------------------------------------------------------}
{                                                                      }
{   BIM_Prolog Inter Process Communication Package - Server            }
{                                                                      }
{   Author :  Alain Callebaut                                          }
{             Katholieke Universiteit Leuven                           }
{             Department of Computer Science                           }
{             Celestijnenlaan 200A                                     }
{             B-3030 HEVERLEE                                          }
{                                                                      }
{   Date :     5-Jun-1987                                              }
{   Changed : 21-Jun-1989/MJf                                          }
{                                                                      }
{----------------------------------------------------------------------}

:- module(IpcChannel).


:- import setup_service/2 from ipc .
:- import accept_request/4 from ipc .
:- import shutdown_service/3 from ExternalCode .
:- import select_input/2 from ipc .
:- import input_pending/2 from ipc .

:- import server_id/1 from CBserverInterface.
:- import handle_message/2 from CBserverInterface.

:- import atom2term/2 from GeneralUtilities.
:- import atom2list/2 from GeneralUtilities.
:- import length/2 from GeneralUtilities .
:- import append/3 from GeneralUtilities.

:- import IpcParserTypeDefs/0 from IpcParser .
:- import GetIpcMessageFromC/2 from IpcParser .
:- import IpcParse/2 from ExternalCode .
:- import DeleteIpcMessage/1 from ExternalCode .
:- import CharListToCString/3 from ExternalCode .
:- import memfree/1 from ExternalCode .
:- import make_ipcanswerstring/5 from ExternalCode .
:- import fputs/3 from ExternalCode .
:- import ipc_read/3 from ExternalCode .

:- local get_ipcmessage/2 .
:- local getLength/2 .
:- local serve_goal2/2 .


{*** customized functionality }


IpcChannel_startup :-
   service_port(_portnr),
   server_startup( _portnr ) .



IpcChannel_shutdown :-
   server_id(_serv_id),
   shutdown_service( _serv_id, 0x0, 0x0 ).




solve_goal( ipcmessage(_s,_r,STOP_SERVER,_args) , _fd , _out ) :-
	!,
	report( 'Stopping server requested' ),
	handle_message(ipcmessage(_s,_r,STOP_SERVER,_args), _answer),
	report(_answer),
	output_answer(_out,_answer),
	stopServerIfAnswerOk(_answer),
	!.


solve_goal( ipcmessage(_s,_r,CANCEL_ME,[]) , _fd , _out ) :-
	!,
	report( 'Unregistering client.' ),
	handle_message(ipcmessage(_s,_r,CANCEL_ME,[]), _answer),
	client_db_files( _fd , _inpstream , _outstream ),
	client_db_unregister( _fd ),
	report(_answer),
	output_answer(_out,_answer),
	shutdown_service(_fd, _inpstream , _outstream),
	!.


solve_goal( _message , _fd , _out ) :-
	write_msg(_message),
	handle_message(_message, _answer),
	report(_answer),
	output_answer(_out,_answer),
	!.

:- dynamic wait_for_answer/1 .

write_msg(ipcmessage(_,_,TELL,_args)) :-
	fopen(casefile,'testcases.new',a),
	pointer2atom(_args,_newargs),
	_t =.. [tell|_newargs],
	please(wq,on),
	write(casefile,_t),
	please(wq,off),
	write(casefile,'.'),nl(casefile),
	update(wait_for_answer(1)),
	fclose(casefile).
	
write_msg(ipcmessage(_,_,UNTELL,_args)) :-
	fopen(casefile,'testcases.new',a),
	pointer2atom(_args,_newargs),
	_t =.. [untell|_newargs],
	please(wq,on),
	write(casefile,_t),
	please(wq,off),
	write(casefile,'.'),nl(casefile),
	update(wait_for_answer(1)),
	fclose(casefile).
	
	
write_msg(ipcmessage(_,_,ASK,_args)) :-
	fopen(casefile,'testcases.new',a),
	pointer2atom(_args,_newargs),
	_t =.. [ask|_newargs],
	please(wq,on),
	write(casefile,_t),
	please(wq,off),
	write(casefile,'.'),nl(casefile),
	update(wait_for_answer(1)),
	fclose(casefile).
	
write_msg(ipcmessage(_,_,HYPO_ASK,_args)) :-
	fopen(casefile,'testcases.new',a),
	pointer2atom(_args,_newargs),
	_t =.. [hypo_ask|_newargs],
	please(wq,on),
	write(casefile,_t),
	please(wq,off),
	write(casefile,'.'),nl(casefile),
	update(wait_for_answer(1)),
	fclose(casefile).
	
write_msg(ipcmessage(_,_,TELL_MODEL,_args)) :-
	fopen(casefile,'testcases.new',a),
	pointer2atom(_args,_newargs),
	_t =.. [tell_model|_newargs],
	please(wq,on),
	write(casefile,_t),
	please(wq,off),
	write(casefile,'.'),nl(casefile),
	update(wait_for_answer(1)),
	fclose(casefile).
	
write_msg(ipcmessage(_,_,LPI_CALL,_args)) :-
	fopen(casefile,'testcases.new',a),
	pointer2atom(_args,_newargs),
	_t =.. [lpi_call|_newargs],
	please(wq,on),
	write(casefile,_t),
	please(wq,off),
	write(casefile,'.'),nl(casefile),
	update(wait_for_answer(1)),
	fclose(casefile).

write_msg(_) :-
	update(wait_for_answer(0)).


pointer2atom([],[]).

pointer2atom([_h|_t],[_a|_newt]) :-
	pointer(_h),
	stringtoatom(_h,_a),
	pointer2atom(_t,_newt).
	
pointer2atom([_h|_t],[_h|_newt]) :-
	pointer2atom(_t,_newt).


stopServerIfAnswerOk(ipcanswer(_r,ok,yes)) :-
	IpcChannel_shutdown, 
	report('Stopping server'),
	stop,
	!.

stopServerIfAnswerOk(_).



{----------------------------------------------------------------------}
{   Parameters                                                         }
{----------------------------------------------------------------------}

service_port( _portnr ) :- portnr(_portnr).   

server_report( off ) .   {on/off}


{----------------------------------------------------------------------}
{   Reporting                                                          }
{----------------------------------------------------------------------}

report( _x ) :-
   server_report( on ), !,
   write( _x ) , nl .

report( _x ) .


{----------------------------------------------------------------------}
{   Server                                                             }
{----------------------------------------------------------------------}

server_startup( _portnr ) :-
   setup_service( _portnr , _serv_id ),
   update(server_id(_serv_id)),
   client_db_initialize,
   IpcParserTypeDefs,
   server_loop .


server_loop :-
   repeat,
   serve_registered_clients,
   fail .



{----------------------------------------------------------------------}
{   Request Acceptance                                                 }
{----------------------------------------------------------------------}

accept_request( _serv_id ) :-
   accept_request( _serv_id , _fd , _inp , _out ), !,
   report( 'Registering new client.' ),
   client_db_register( _fd , _inp , _out ) .

accept_request( _serv_id ) .


{----------------------------------------------------------------------}
{   Client Serving                                                     }
{----------------------------------------------------------------------}

serve_registered_clients :-
   ipc_fds( _rfds ),
   select_input( _rfds , _sfds ),			{ 10.09.92 RG removed the timeout ==> blocking }
   ipc_fds_list( _sfds , _clients ),
   serve_registered_clients( _clients ) .


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
	extern_allocate( _ipo, IpcParserOutput ),
	client_db_files( _fd , _inp , _out ),
	{read( _inp , _goal ), !,  {21-Mar-1990/MJf: '!' added}}
	get_ipcmessage( _inp, _msg),
	!,
	IpcParse( _msg, _ipo ),
	memfree( _msg ),
	!,
	extern_get( _ipo^err, _err ),
	((_err = 0, 
 	 serve_goal2( _err, _fd, _out, _ipo ),
	 extern_address( _ipo^im^0, _im ),
	 pointer(_im),
	 (
		( _im \= 0x0000,
	  	DeleteIpcMessage( _im ) )
		;
		true
	 ),
	 extern_deallocate( _ipo ));
	(serve_goal2( _err, _fd, _out, _ipo ), { Error }
	 extern_deallocate( _ipo ))),
	!.

{20-Mar-1990/MJf: avoid hanging clients to hang server}
serve_goal( _fd) :-    {error}
	write( 'Client hanging --- shutting it down' ),nl,
	client_db_files( _fd , _inpstream , _outstream ),
	client_db_unregister( _fd ),
	shutdown_service( _fd, _inpstream , _outstream ).

serve_goal2( 0, _fd, _out, _parserOutput ) :-
	GetIpcMessageFromC( _parserOutput, _ipcmessage ),
	report( Solving(_ipcmessage) ),
	solve_goal( _ipcmessage, _fd, _out ).

serve_goal2( _err, _fd, _out, _parserOutput ) :-
	write('error reading ipcmessage\n'),
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

get_ipcmessage( _fptr, _msg ) :-
	pointer(_fptr), var(_msg),
	ipc_read(_msg,_fptr,_len), { 14-Mar-95/CQ: New C-function to read the ipcmessage }
	pointer(_msg),
	(_msg \== 0x0;
	 (_msg == 0x0, !, fail)).



{----------------------------------------------------------------------}
{   Client Data Base Manager                                           }
{----------------------------------------------------------------------}

:- dynamic( client_db_client/1 ) .


client_db_id( _fd , _id ) :-
   inttoatom( _fd , _suffix ),
   atomconcat( ipc_client_ , _suffix , _id1 ),
   module( _id , ipc_server , _id1 ) .


client_db_files( _fd , _inp , _out ) :-
   client_db_id( _fd , _id ),
   recorded( _id , files(_inp,_out) ) .


client_db_initialize :-
   retractall( client_db_client(_) ),
   ipc_fds_initialize .


client_db_register( _fd , _inp_fp , _out_fp ) :-
   client_db_id( _fd , _id ),
   assert( client_db_client(_fd) ),
   rerecord( _id , files(_inp_fp,_out_fp) ),
   ipc_fds_add( _fd ) .


client_db_unregister( _fd ) :-
   client_db_id( _fd , _id ),
   retract( client_db_client(_fd) ),
   erase( _id ),
   ipc_fds_remove( _fd ) .


{----------------------------------------------------------------------}
{   File Descriptor Masks                                              }
{----------------------------------------------------------------------}

:- local ipc_fds/0 .


ipc_fds_initialize :-
   server_id(_serv_id),
   _fds is 1 << _serv_id ,
   rerecord( ipc_fds , _fds ) .		{ 10.09.92 RG socket-fd of server }


ipc_fds( _fds ) :-
   recorded( ipc_fds , _fds ) .


ipc_fds_add( _fd ) :-
   recorded( ipc_fds , _fds ),
   _fds1 is _fds \/ ( 1 << _fd ),
   rerecord( ipc_fds , _fds1 ) .


ipc_fds_remove( _fd ) :-
   recorded( ipc_fds , _fds ),
   _fds1 is _fds /\  ( \ ( 1 << _fd ) ),
   rerecord( ipc_fds , _fds1 ) .


ipc_fds_list( _fds , _list ) :-
   ipc_fds_list( _fds , 0 , _list ) .


ipc_fds_list( 0 , _n , [] ) :- ! .

ipc_fds_list( _fds , _n , [_n|_l0] ) :-
   1 is _fds /\ 1, !,
   _fds1 is _fds >> 1,
   _n1 is _n + 1,
   ipc_fds_list( _fds1 , _n1 , _l0 ) .

ipc_fds_list( _fds , _n , _l0 ) :-
   _fds1 is _fds >> 1,
   _n1 is _n + 1,
   ipc_fds_list( _fds1 , _n1 , _l0 ) .


{----------------------------------------------------------------------}


{**********************************************************************}
{*                                                                    *}
{* output_answer/2               				      *}
{* schreibt erst die Laenge der Antwort _answer1,                     *}
{* gefolgt von newline, und dann die Antwort selbst, gefolgt von      *}
{* newline, auf den stream _out.                                      *}
{*                                                                    *}
{**********************************************************************}

output_answer( _out, _answer1 ) :-
	replace_all(_answer1,[],nil,_answer),
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
	writeAnswer(_answer),
	write(_out,_answerlen),
	nl(_out),
	fputs( _nWrote, _answerstring, _out ),
	nl(_out),
	flush( _out ),
	memfree(_answerstring).

writeAnswer(ipcanswer(_rec,_comp,_text)) :-
	wait_for_answer(1),
	update(wait_for_answer(0)),
	charlist2atom(_text,_newtext),
	fopen(casefile,'testcases.new',a),
	please(wq,on),
	write(casefile,answer(_comp,_newtext)),
	please(wq,off),
	write(casefile,'.'),nl(casefile),
	write(casefile,'{*******************************************************}'),nl(casefile),
	fclose(casefile).

writeAnswer(_).


charlist2atom(char_list(_list),_atom) :-
	atomconcat(_list,_atom).

charlist2atom(_x,_x).


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


:- local TermToAtomList/2 .
:- local ListToAtomList/2 .
:- local TermArgsToAtomList/2 .
:- local AtomListToCharList/2 .


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


{*-----------------------------------------------------
* Die folgende Konvertierungspraedikate sind notwendig, 
* solange das Interface nil und leere Liste als aequivalent 
* betrachte, inclusive von OCCURS.pl von Richard A. O. Keefe
*
*}


replace_all(_term,_x,_x,_term):- !.
replace_all(_term,_oldsubterm,_,_term) :-
	not( position(_oldsubterm,_term,_) ),
	!.

{* 	Sonderfall [] bei Listen *}
{* 	die am tiefsten geschachtelte leere Liste darf nicht *}
{*	ersetzt werden.					     *}
		
replace_all(_term,[],_newsubterm,_newterm) :-
	position([],_term,_pos),
	test_if_brackets_needed(_term,_pos),!,
	replace(_pos,_term,_newsubterm,_newterm1),
	replace_all(_newterm1,[],_newsubterm,_newterm2),
	replace(_pos,_newterm2,[],_newterm).

replace_all(_oldterm,_oldsubterm,_newsubterm,_newterm) :-
	position(_oldsubterm,_oldterm,_pos),
	replace(_pos,_oldterm,_newsubterm,_term2),
	replace_all(_term2,_oldsubterm,_newsubterm,_newterm),
	!.

{
"[]" soll nicht ersetzt werden, wenn es als terminierendes
Element einer Liste verwendet wird. 
Achtung: [] kommt in allen Listen vor, denn position arbeitet 
hier mit dem "." functor. Deswegen wird [] nicht ersetzt, wenn
es so verwendet wird.
}

test_if_brackets_needed(_term,_pos) :-
	find_functor(_pos,_functorpath),
	patharg(_functorpath,_term,.(_x,[])).
	
	

find_functor([_x],[]) :- integer(_x),!.
find_functor([_x|_xs],[_x|_ys]) :- !,
	find_functor(_xs,_ys).

test_if_needed(_term,[2]).
test_if_needed(_term,[_x|_l]) :-
	test_if_needed(_l).

{*****************************************************************}
{*    File   : OCCUR.PL                                          *}
{*    Author : R.A.O'Keefe                                       *}
{*    Updated: 22 May 1983                                       *}
{*    Purpose: routines for checking number/place of occurrence  *}
{*****************************************************************}

{* Some of the things in METUTL.PL may also be relevant, particularly *}
{* subterm/2.  Maybe that should go here?  occ/3 in STRUCT.PL too.    *}

:- mode contains(i, i) .
:- mode copy_all_but_one_arg(i, i, i, i) .
:- mode freeof(i, i) .
:- mode freeof(i, i, o) .
:- mode patharg(i, i, ?) .
:- mode position(?, i, ?) .
:- mode position(i, ?, i, ?) .
:- mode replace(i, i, i, o) .

{*    contains(Kernel, Expression)                                      *}
{*    is true when the given Kernel occurs somewhere in the Expression. *}
{*    It be only be used as a test; to generate subterms use subterm/2. *}

contains(_Kernel, _Expression) :-
	\+ freeof(_Kernel, _Expression).

{*    freeof(Kernel, Expression)                                        *}
{*    is true when the given Kernel does not occur anywhere in the      *}
{*    Expression.  NB: if the Expression contains an unbound variable,  *}
{*    this must fail, as the Kernel might occur there.  Since there are *}
{*    infinitely many Kernels not contained in any Expression, and als  *}
{*    infinitely many Expressions not containing any Kernel, it doesn't *}
{*    make sense to use this except as a test.                          *}

freeof(_Kernel, _Kernel) :- !,
	fail.
freeof(_Kernel, _Expression) :-
	functor(_Expression, _, _Arity),	{*   can't be a variable! *}
	freeof(_Arity, _Kernel, _Expression).

freeof(0, _Kernel, _Expression) :- !.
freeof(_N, _Kernel, _Expression) :-
	arg(_N, _Expression, _Argument),
	freeof(_Kernel, _Argument),
	_M is _N-1, !,
	freeof(_M, _Kernel, _Expression).

{*    patharg(Path, Exp, Term)                                          *}
{*    unifies Term with the subterm of Exp found by following Path.     *}
{*    It may be viewed as a generalisation of arg/3.  It cannot be      *}
{*    used to discover a path to a known Term; use position/3 for that. *}

patharg([_Head|_Tail], _Exp, _Term) :-
	arg(_Head, _Exp, _Arg),
	patharg(_Tail, _Arg, _Term).
patharg([], _Term, _Term).

{*    position(Term, Exp, Path)                                             *}
{*    is true when Term occurs in Exp at the position defined by Path.      *}
{*    It may be at other places too, so the predicate is prepared to        *}
{*    generate them all.  The path is a generalised Dewey number, as usual. *}
{*    position(x, 2*x^2+2*x+1=0, [1, 1, 2, 2]) {*2*x} and                   *}
{*    position(x, 2*x^2+2*x+1=0, [1, 1, 1, 2, 1]) {*x^2} are both examples. *}

position(_Term, _Term, []).
position(_Term, _Exp, _Path) :-
	nonvar(_Exp),
	functor(_Exp, _, _N),
	position(_N, _Term, _Exp, _Path).

position(0, _Term, _Exp, _Path) :- !, fail.
position(_N, _Term, _Exp, [_N|_Path]) :-
	arg(_N, _Exp, _Arg),
	position(_Term, _Arg, _Path).
position(_N, _Term, _Exp, _Path) :-
	_M is _N-1, !,
	position(_M, _Term, _Exp, _Path).

{* replace(Path, OldExpr, SubTerm, NewExpr)                                 *}
{* is true when OldExpr and NewExpr are identical except at the position    *}
{* identified by Path, where NewExpr has SubTerm.  There is a bug in the    *}
{* Dec-10 compiler, which is why the second 'arg' call follows the replace  *}
{* recursion.  If it weren't for that bug, replace would be tail recursive. *}
{* replace([1,1,2,2], 2*x^2+2*x+1=0, y, 2*x^2+2*y+1=0) is an example.       *}
 
replace([_M|_Path], _OldExpr, _SubTerm, _NewExpr) :- !,
	arg(_M, _OldExpr, _OldArg),
	functor(_OldExpr, _F, _N),
	functor(_NewExpr, _F, _N),
	copy_all_but_one_arg(_N, _M, _OldExpr, _NewExpr),
	replace(_Path, _OldArg, _SubTerm, _NewArg),
	arg(_M, _NewExpr, _NewArg).
replace([], _, _SubTerm, _SubTerm).

copy_all_but_one_arg(0, _, _, _) :- !.
copy_all_but_one_arg(_M, _M, _OldExpr, _NewExpr) :- !,
	_L is _M-1,
	copy_all_but_one_arg(_L, _M, _OldExpr, _NewExpr).
copy_all_but_one_arg(_N, _M, _OldExpr, _NewExpr) :-
	arg(_N, _OldExpr, _Arg),
	arg(_N, _NewExpr, _Arg),
	_L is _N-1,
	copy_all_but_one_arg(_L, _M, _OldExpr, _NewExpr).

{****************************************************************}
{* Suppose you have a set of rewrite rules Lhs -> Rhs which you *}
{* want exhaustively applied to a term.  You would write        *}
{*                                                              *}
{* 	waterfall(Expr, Final) :-                               *}
{* 		Lhs -> Rhs,                                     *}
{* 		position(Expr, Lhs, Path),                      *}
{* 		replace(Path, Expr, Rhs, Modified),             *}
{* 		!,                                              *}
{* 		waterfall(Modified, Final).                     *}
{* 	waterfall(Expr, Expr).                                  *}
{****************************************************************}

{*
* bis hier gehoert alles zu replace_all und kann weg, weil das Interface 
* kein nil mehr erwartet
* 22.3.94, R. Soiron
*
*
*---------------------------------------------------------------------
}

