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
