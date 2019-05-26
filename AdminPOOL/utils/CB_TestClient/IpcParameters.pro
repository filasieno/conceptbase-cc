{
*
* File:        	%M%
* Version:     	%I%
* Creation:    28-Jul-1989 Martin Staudt (UPA)
* Last Change: %G%,  L. Bauer (RWTH)
* Release:     	%R%
* -----------------------------------------------------------------------------
*
* This module contains all parameters necessary for a client to communicate
* with an CB server
*
* Exported predicates:
* --------------------
*      all
*
*
}


:- module(IpcParameters).

:- dynamic init_timeout/1 .
:- dynamic service_timeout/1 .
:- dynamic service_retry/1 .
:- dynamic client_report/1 .
:- dynamic thisToolId/1 .
:- dynamic whatCBserverId/1 .
:- dynamic thisToolClass/1 .
:- dynamic server_id/1 .
:- dynamic user_name/1 .


{ ==================== }
{ Exported predicates: }
{ ==================== }


init_timeout(1) .      {previously: 2 sec}

service_timeout(20) .

service_retry(20) .

client_report(on) .   {on/off}

thisToolId(unknown).   {to be requested from the server}

whatCBserverId(unknown).

server_id(unknown).


thisToolClass(Ipc_Example_Client).

user_name(_username) :-
	write('Please enter Username  {user@host}'), 
	read(_username).

