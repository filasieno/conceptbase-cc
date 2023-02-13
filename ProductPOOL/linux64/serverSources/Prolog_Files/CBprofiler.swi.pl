/**
The ConceptBase.cc Copyright

Copyright 1987-2023 The ConceptBase Team. All rights reserved.

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
**/
/*
*
* File:         %M%
* Version:      %I%
* Creation:     20-Aug-1998, Christoph Quix (RWTH)
* Last Change   : %E%, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
--------

Dieses Modul dient zur Performance-Analyse von CB Prolog Modulen.
Der Profiler liest ein Prolog-Modul im Source ein, baut in jedem
Praedikatrumpf einen Aufruf von start_call und finalize_call
und consulted danach das veraenderte Prolog-Modul.
(Fehler durch die Umschreibung der Regeln sind nicht ausgeschlossen)

Damit ein Prolog-Modul vom Profiler bearbeitet wird, muss man
in startCBserver.pro 'profile' als Option bei CBconsult fuer
dieses Modul angegeben, also z.B.
(_,Literals) durch (profile,Literals) ersetzen.

Mit einem Prolog-Call dump_profile_results$CBprofiler kann man
dann nach einige Operationen (TELL/UNTELL/ASK) sich die Ergebnisse
in eine Datei schreiben lassen und diese in Excel laden (Spalten
sind durch Semikolon getrennt).

Spaltenformat:
ID ; Bezeichnung des Praedikats ; Zeit ; Aufrufe ; Fails ; Succeeds ; Kopf

Es gibt einen Eintrag fuer jede Klausel, also Praedikate koennen mehrfach
auftreten.

Die Zeit ist nur eine ungefaehre Angabe der verbrauchten CPU-Zeit fuer
die Auswertung der Klausel. Besonders bei rekursiven Praedikaten ist
die Zeit dort t^2/2 statt t.
*/


:- module('CBprofiler',[
'profile_all'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').

:- use_module('PrologCompatibility.swi.pl').
















:- dynamic 'CBprofiler_rule'/2 .
:- dynamic 'cb_current_module'/1 .
:- dynamic 'clause_counter'/1 .


:- style_check(-singleton).


clause_counter(0).
cb_current_module('global').


profile_all(_file,_fname) :-
	pc_fopen(prologfile,_file,r),
	pc_atomconcat(_fname,'.tmp.pro',_tmpfname),
	pc_fopen(tmpfile,_tmpfname,w),
	profile_file,
	pc_fclose(prologfile),
	pc_fclose(tmpfile),
	consult(_tmpfname).

profile_file :-
	read(prologfile,_term),
	_term \= end_of_file,
	!,
	profile_term(_term),
	profile_file.


profile_file.



profile_term(_term) :-
	_term = (_head :- _body),
	!,
	clause_counter(_i),
	_i1 is _i + 1,
	pc_update(clause_counter(_i1)),
	functor(_head,_func,_arity),
	pc_inttoatom(_arity,_atom),
	cb_current_module(_module),
	pc_atomconcat([_func,'$',_module,'/',_atom],_funckey),
	assert('CBprofiler_rule'(_i1,_term)),
	_head =.. [_|_args],
	pc_record(_i1,'CBprofile',info(_funckey,0.0,0,0,0,[])),
	writeq(tmpfile,_head),
	write(tmpfile,' :-\n'),

    write(tmpfile,'\'CBprofiler\':start_call'),

	write(tmpfile,'('),writeq(tmpfile,(_funckey,_i1,_time,_args)),write(tmpfile,'),\n'),
	write(tmpfile,'( '),writeq(tmpfile,_body),write(tmpfile,' ),\n'),

    write(tmpfile,'\'CBprofiler\':finalize_call'),

	write(tmpfile,'('),writeq(tmpfile,(_funckey,_i1,_time)),write(tmpfile,') .\n\n').

profile_term(':-'(module(_mod))) :-
	!,
	pc_update(cb_current_module(_mod)),
	writeq(tmpfile,':-'(module(_mod))),
        write(tmpfile,' .\n\n').

profile_term(_term) :-
	writeq(tmpfile,_term),
	write(tmpfile,' .\n\n').


start_call(_funckey,_id,_t,_args) :-
	write('start '),blue,write((_funckey,_id)),black,write(_args),nl,
	callExactlyOnce((
		pc_recorded(_id,'CBprofile',info(_funckey,_time,_calls,_fail,_succeed,_arginfo)),
		_calls1 is _calls + 1 ,
		pc_cputime(_t),
		pc_rerecord(_id,'CBprofile',info(_funckey,_time,_calls1,_fail,_succeed,_arginfo))
	)).


/* FAIL */
start_call(_funckey,_id,_,_args) :-
	write('failed '),red,write((_funckey,_id)),black,write(_args),nl,
	pc_recorded(_id,'CBprofile',info(_funckey,_time,_calls,_fail,_succeed,_arginfo)),
	_fail1 is _fail + 1 ,
	pc_rerecord(_id,'CBprofile',info(_funckey,_time,_calls,_fail1,_succeed,_arginfo)),
	!,
	fail.

finalize_call(_funckey,_id,_t1) :-
	write('finished '),green,write((_funckey,_id)),black,nl,
	callExactlyOnce((
		pc_recorded(_id,'CBprofile',info(_funckey,_time,_calls,_fail,_succeed,_arginfo)),
		pc_cputime(_t2),
		_succeed1 is _succeed + 1 ,
		_time1 is _time + _t2 - _t1 ,
		pc_rerecord(_id,'CBprofile',info(_funckey,_time1,_calls,_fail,_succeed1,_arginfo))
	)).


dump_profile_results :-
	pc_fopen(resfile,'results.txt',w),
	dump_clause_results,
	pc_fclose(resfile).


dump_clause_results :-
	pc_current_key(_id,'CBprofile'),
	'CBprofiler_rule'(_id,(_head :- _body )),
	pc_recorded(_id,'CBprofile',info(_funckey,_time,_calls,_fail,_succeed,_arginfo)),
	write(resfile,_id),write(resfile,';'),
	write(resfile,_funckey),write(resfile,';'),

    write(resfile,_time),
    write(resfile,';'),

	write(resfile,_calls),write(resfile,';'),
	write(resfile,_fail),write(resfile,';'),
	write(resfile,_succeed),write(resfile,';'),
	write(resfile,_head),/*write(resfile,';'),
	write(resfile,_body),*/
	write(resfile,'\n'),
	fail.

dump_clause_results.

