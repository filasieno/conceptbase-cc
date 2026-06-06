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
* Creation:    17.07.92 Rainer Gallersdoerfer (RWTH)
* Last change: %G%,  L. Bauer (RWTH)
* Release:     	%R%
* -----------------------------------------------------------------------------
*
* This file contains all extern directives.
* So calling the incremental linker during loading of ConceptBase is necessary only once.
* It also helps when linking the runtime version !
*
*
*
}
:- module(ExternalCode).
:- extern_load( 
[
{*** previously from module ipc ***}
	setup_service,
	accept_request,
	connect_service,
	shutdown_service,
	select_input_0,
	select_input_1,
	input_pending
],
[
	'$CBS_DIR/BimIpc.o',
	'/opt/gnu/lib/gcc-lib/sparc-sun-solaris2/2.4.5/libgcc.a' 
] ).
{*** previously from module ipc ***}
:- extern_predicate( setup_service( integer:r , integer:i , integer:o ) ) .
:- extern_predicate( accept_request( integer:r,integer:i,integer:o,pointer:o,pointer:o ) ) .
:- extern_predicate( connect_service( integer:r,integer:i,string:i,integer:o,pointer:o,pointer:o ) ) .
:- extern_predicate( shutdown_service( integer:i, pointer:i,pointer:i ) ) .
:- extern_predicate( select_input_0, select_input_0( integer:r , integer:i , integer:o ) ) .
:- extern_predicate( select_input_1, select_input_1( integer:r , integer:i , integer:o , integer:i ) ) .
:- extern_predicate( input_pending( integer:r , pointer:i , integer:i ) ) .
