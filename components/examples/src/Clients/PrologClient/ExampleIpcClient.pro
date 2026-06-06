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
* Creation:    28-Aug-1992, Hans W. Nissen (RWTH)
* Last change: %G%, L. Bauer (RWTH)
* Release:     	%R%
* ----------------------------------------------------------
}
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
init_connection :-
	nl , repeat , 
		write('host: ') , read( _269 ) , 	
		write('port: ') , read( _279 ) , 
		connectCBserver( _269 , _279 ) , ! .

close_connection :- disconnectCBserver .

loop :- nl , write('Method: ') , read( _310 ) , 
	write('Arguments ([a1,..,an]): ') , read( _320 ) , nl , 
	handleIt( _310 , _320 ) , ! , loop .

handleIt(exit, _341 ) :- stop .
handleIt(connect, _350 ) :- close_connection , manual_connect , ! .
handleIt(param, _365 ) :- GetAndDisplayParam , ! .
handleIt( _376 , _377 ) :- 			{ process CBserver method call }
	server_id( _382 ) ,
	 thisToolId( _387 ) , 
	whatCBserverId( _392 ) , 
	IpcChannel_call( _382 ,
	ipcmessage( _387 , _392 , _376 , _377 ),
	ipcanswer( _406 , _407 , _408 )) , 
	write('Responding tool: ') , 
	write( _406 ) , nl , write('Completion:      ') , 
	write( _407 ) , nl , 
	write('Return value:    ') , write( _408 ) , nl , ! .

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
	( _, BimIpc) , 
	( _, ExampleClientCodeLoader) 
	]), !.

go :- consult_IpcModules , init_connection , loop , close_connection .
  ?- go . 
