{*
The ConceptBase.cc Copyright

Copyright 1987-2026 The ConceptBase Team. All rights reserved.

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


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*}
{
*
* File:        	BimIpc.pro
* Version:     	4.2
* Creation:    5-Apr-1990, Manfred Jeusfeld (UPA)
* Last Change: 	8/5/92, Rainer Gallersdoerfer (RWTH)
* Release:     	4
* -----------------------------------------------------------------------------
*
* This Prolog module is part of the ConceptBase system which is a run-time
* system for the System Modelling Language (SML).
* Actually, it is a copy of ..Bprolog/lib/ipc.pro with the exception that
* the path to 'ipc.o' is now absolute.
*
*
* Exported predicates:
* --------------------
*
* ... see below
*
*
*
*
* 06-Feb-91: C-library -lc added in predicate extern_load/2. No more loaded
*	     automatically since BIM version 3.0  (UBo)
* 17.07.92 RG Transfered extern directives into a new file ExternalCodeLoader.pro
*
}

{----------------------------------------------------------------------}
{                                                                      }
{   BIM_Prolog Inter Process Communication Package                     }
{                                                                      }
{   Author :  Alain Callebaut                                          }
{             Katholieke Universiteit Leuven                           }
{             Department of Computer Science                           }
{             Celestijnenlaan 200A                                     }
{             B-3030 HEVERLEE                                          }
{                                                                      }
{   Date :     1-Jun-1987                                              }
{   Changed : 17-Jul-1988                                              }
{                                                                      }
{----------------------------------------------------------------------}

#MODULE(BimIpc)
#EXPORT(accept_request/4)
#EXPORT(input_pending/2)
#EXPORT(select_input/2)
#EXPORT(setup_service/2)
#ENDMODDECL()


#IMPORT(setup_service/3,ExternalCodeLoader)
#IMPORT(accept_request/5,ExternalCodeLoader)
#IMPORT(connect_service/6,ExternalCodeLoader)
#IMPORT(select_input_n/4,ExternalCodeLoader)
#IMPORT(input_pending/3,ExternalCodeLoader)
#IMPORT(length/2,GeneralUtilities)
#IMPORT(pc_update/1,PrologCompatibility)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


{----------------------------------------------------------------------}
{
   setup_service/2
      arg1 : ground : integer : service port number
      arg2 : free : integer : service descriptor
      A service is set up at port number arg1.  The resulting service
      descriptor is given as arg2.
      Fails if the setup failed.
}

setup_service( _portnr , _servid ) :-
   setup_service( _ret , _portnr , _servid ), _ret = 0 .


{----------------------------------------------------------------------}
{
   accept_request
      arg1 : ground : integer : service descriptor
      arg2 : free : integer : communication channel file descriptor
      arg3 : free : pointer : input file pointer
      arg4 : free : pointer : output file pointer
      If a client request is pending for service arg1, it is accepted.
      The communication channel file descriptor is returned in arg2
      and the input and output file pointers for the communication channel
      are given as arg3 and arg4.
      If no requests were pending, the predicate fails and the status
      accept_request_status/1 is set to -1.
      The status is set to a positive number and the predicate fails if
      an error occurred.
}

#DYNAMIC(accept_request_status/1)

accept_request( _servid , _fd , _inp , _out ) :-
   accept_request( _ret , _servid , _fd , _inp , _out ),
   pc_update( accept_request_status(_ret) ), _ret = 0 .


{----------------------------------------------------------------------}
{
   connect_service
      arg1 : ground : integer : service port number
      arg2 : ground : atom : hostname providing the server
      arg3 : free : integer : communication channel file descriptor
      arg4 : free : pointer : input file pointer
      arg5 : free : pointer : output file pointer
      A connection to the service on host arg2, port arg1 is established.
      The input and output file pointers for the communication channel
      are given as arg3 and arg4.
      If the service is not available, or another error occurred, the
      predicate fails.
}

connect_service( _portnr , _hostname , _fd , _inp , _out ) :-
   connect_service( _ret , _portnr , _hostname , _fd , _inp , _out ), _ret = 0 .


{----------------------------------------------------------------------}
{
   shutdown_service
      arg1 : ground : integer : service descriptor
      The service arg1 is shut down.
}


{----------------------------------------------------------------------}
{
   select_input/2
      arg1 : ground : integer list : file descriptors
      arg2 : free : integer : file descriptor ready for reading
      The files described in arg1 are selected for input.  Files that
      have input pending, are returned in arg2.
      If no input is pending on any file, the call blocks.
}

select_input( _request_fds , _select_fd ) :-
   length(_request_fds,_len),
   select_input_n( _ret , _request_fds , _len, _select_fd ), _ret = 0 .



{----------------------------------------------------------------------}
{
   input_pending/2
      arg1 : ground : pointer : file pointer
      arg2 : ground : integer : timeout
      Succeeds if there is input pending on file arg1.
      If not, the predicate waits for at most arg2 seconds, before failing.
      During that period, it succeeds immediately when input arrives.
}

input_pending( _fptr , _timeout ) :-
   input_pending( _ret , _fptr , _timeout ), _ret = 0 .


{----------------------------------------------------------------------}
