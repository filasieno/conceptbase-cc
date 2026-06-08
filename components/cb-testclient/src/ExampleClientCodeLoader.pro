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
	input_pending,
	time,
	difftime,
	read_text_file

],

[
	'$CBS_DIR/BimIpc.o',
	'$LIB_GCC' 
] ).

{*** previously from module ipc ***}

:- extern_predicate( setup_service( integer:r , integer:i , integer:o ) ) .
:- extern_predicate( accept_request( integer:r,integer:i,integer:o,pointer:o,pointer:o ) ) .
:- extern_predicate( connect_service( integer:r,integer:i,string:i,integer:o,pointer:o,pointer:o ) ) .
:- extern_predicate( shutdown_service( integer:i, pointer:i,pointer:i ) ) .
:- extern_predicate( select_input_0, select_input_0( integer:r , integer:i , integer:o ) ) .
:- extern_predicate( select_input_1, select_input_1( integer:r , integer:i , integer:o , integer:i ) ) .
:- extern_predicate( input_pending( integer:r , pointer:i , integer:i ) ) .
:- extern_predicate( time, my_time( long:r , pointer:i)).
:- extern_predicate( difftime( double:r , long:i , long:i )) .
:- extern_predicate( read_text_file( string:r , string:i )) .



