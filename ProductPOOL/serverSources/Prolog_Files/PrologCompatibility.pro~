{*
The ConceptBase.cc Copyright

Copyright 1987-2020 The ConceptBase Team. All rights reserved.

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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*}


#MODULE(PrologCompatibility)
#EXPORT(callExactlyOnce/1)
#EXPORT(createModTerm/4)
#EXPORT(pc_unifiable/2)
#EXPORT(pc_update/1)
#EXPORT(pc_has_a_definition/1)
#EXPORT(pc_atomconcat/2)
#EXPORT(pc_atomconcat/3)
#EXPORT(pc_atompart/4)
#EXPORT(pc_atompartsall/3)
#EXPORT(pc_atomconstruct/3)
#EXPORT(pc_record/3)
#EXPORT(pc_record/2)
#EXPORT(pc_store/2)
#EXPORT(pc_rerecord/3)
#EXPORT(pc_rerecord/2)
#EXPORT(pc_recorded/3)
#EXPORT(pc_recorded/2)
#EXPORT(pc_erase/2)
#EXPORT(pc_erase/1)
#EXPORT(pc_erase_all/1)
#EXPORT(pc_erase_all/0)
#EXPORT(pc_is_a_key/2)
#EXPORT(pc_is_a_key/1)
#EXPORT(pc_current_key/2)
#EXPORT(pc_current_key/1)
#EXPORT(pc_inttoatom/2)
#EXPORT(pc_floattoatom/2)
#EXPORT(pc_atom_to_term/2)
#EXPORT(pc_save_atom_to_term/2)
#EXPORT(pc_swriteQuotes/2)
#EXPORT(pc_swriteQuotesAndModule/2)
#EXPORT(pc_atomtolist/2)
#EXPORT(pc_stringtoatom/2)
#EXPORT(pc_ascii/2)
#EXPORT(pc_pointer/1)
#EXPORT(pc_isNullPointer/1)
#EXPORT(pc_fopen/3)
#EXPORT(pc_fclose/1)
#EXPORT(pc_exists/1)
#EXPORT(pc_exists_directory/1)
#EXPORT(pc_readln/2)
#EXPORT(pc_expand_path/2)
#EXPORT(pc_time/2)
#EXPORT(pc_please/2)
#EXPORT(pc_error_message/2)
#EXPORT(pc_atomprefix/2)
#EXPORT(pc_atomprefix/3)
#EXPORT(pc_member/2)
#EXPORT(pc_cputime/1)
#EXPORT(pc_gettime/1)
#ENDMODDECL()

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)






{************************************************}
{                BIM/Master Prolog               }
{************************************************}

#IF(BIM)
{ call the predicate _x exactly once }
callExactlyOnce(_x)	:- _x,!.

{ Create a predicate with module qualifier }
{ 1. Module is given }
createModTerm(_pred,_mod,_arglist,_term) :-
    ground(_mod),
    nonvar(_arglist),
    !,
    _term1 =.. [_pred|_arglist],
    module(_term,_mod,_term1).

{ 2. Term is given }
createModTerm(_pred,_mod,_arglist,_term) :-
    nonvar(_term),
    module(_term,_mod,_term1),
    _term1 =.. [_pred | _arglist] .

{ Test if x and y are unifiable, but do not unify them }
pc_unifiable(_x,_y) :-
    _x ?= _y .


{ Update the predicate (i.e. retract the a fact from the KB
with the same factor and assert _pred }
pc_update(_pred) :-
    update(_pred).

{ checks whether _pred is defined in the current knowledge base }
pc_has_a_definition(_pred) :-
    has_a_definition(_pred).

{ concat a list of atoms (arg1), result is arg2 }
pc_atomconcat(_list,_atom) :-
    atomconcat(_list,_atom).

{ atom3 is the concatenation of atom1 and atom2 }
pc_atomconcat(_atom1,_atom2,_atom3) :-
    atomconcat(_atom1,_atom2,_atom3).

pc_atompart(_atom,_part,_start,_len) :-
    atompart(_atom,_part,_start,_len).

pc_atompartsall(_atom,_part,_start) :-
    atompartsall(_atom,_part,_start).

pc_atomconstruct(_atom,_n,_natom) :-
    atomconstruct(_atom,_n,_natom).

{ Record Database}
pc_record(_k1,_k2,_t) :-
    record(_k1,_k2,_t).

pc_record(_k1,_t) :-
    record(_k1,_t).

pc_rerecord(_k1,_k2,_t) :-
    rerecord(_k1,_k2,_t).

pc_rerecord(_k1,_t) :-
    rerecord(_k1,_t).

pc_recorded(_k1,_k2,_t) :-
    recorded(_k1,_k2,_t).

pc_recorded(_k1,_t) :-
    recorded(_k1,_t).

pc_erase(_k1,_k2) :-
    erase(_k1,_k2).

pc_erase(_k1) :-
    erase(_k1).

pc_erase_all(_k2) :-
    erase_all(_k2).

pc_erase_all :-
    erase_all.

pc_is_a_key(_k1,_k2) :-
    is_a_key(_k1,_k2).

pc_is_a_key(_k1) :-
    is_a_key(_k1).

pc_current_key(_k1,_k2) :-
    current_key(_k1,_k2).

pc_current_key(_k1) :-
    current_key(_k1).

{ Term conversion }
pc_inttoatom(_int,_atom) :-
    inttoatom(_int,_atom).


{* first clause: try to generate shortest decimal representation of _f *}
{* if _f is not a variable.                                            *}

pc_floattoatom(_f,_atom) :-
    float(_f),
    sprintf(_atom,'%g',_f),
    !.

pc_floattoatom(_f,_atom) :-
    realtoatom(_f,_atom),
    float(_f),
    !.

{* pc_atom_to_term is 'save' under BIM *}
pc_save_atom_to_term(_atom,_term) :-
  pc_atom_to_term(_atom,_term).

pc_atom_to_term(_atom,_term) :-
    atom(_atom),
    !,
    sread(_atom,_term).

pc_atom_to_term(_atom,_term) :-
    swrite(_atom,_term).

pc_swriteQuotes(_atom,_term) :-
  please(writequotes,_old),
  please(writequotes,on),
  swrite(_atom,_term),
  please(writequotes,_old).

pc_swriteQuotesAndModule(_atom,_term) :-
  please(writequotes,_old),
  please(writemodule,_old2),
  please(writequotes,on),
  please(writemodule,on),
  swrite(_atom,_term),
  please(writequotes,_old),
  please(writemodule,_old2).

pc_atomtolist(_a,_l) :-
    atomtolist(_a,_l).

pc_stringtoatom(_s,_a) :-
    stringtoatom(_s,_a).

pc_ascii(_char,_num) :-
    ascii(_char,_num).

pc_pointer(_p) :-
    pointer(_p).

pc_isNullPointer(_p) :-
    _p = 0x0 .

{ File handling }
pc_fopen(_stream,_fname,_mode) :-
    fopen(_stream,_fname,_mode).

pc_fclose(_stream) :-
    fclose(_stream).

pc_exists(_file) :-
    exists(_file).

pc_exists_directory(_dir) :-
    exists(_dir).   {* BIM-Prolog: would need to check that _dir is actually a directory! *}

{ Read a line from a file }
pc_readln(_file,_atom) :-
    readln(_file,_atom).


{ Expand a path name, including environment variables }
pc_expand_path(_path,_exp) :-
    expand_path(_path,_exp).


{ t is the cputime (as float) used to evaluate goal }
pc_time(_goal,_t) :-
    time( _goal,_t).

pc_please(_a,_b) :-
    please(_a,_b).

pc_error_message(_a,_b) :-
    error_message(_a,_b).

pc_atomprefix(_prefix,_atom) :-
  pc_atomconcat(_prefix,_,_atom).

{* _len indicates the length of _prefix *}
pc_atomprefix(_prefix,_len,_atom) :-
  pc_atomconcat(_prefix,_,_atom).

pc_member(_x,[_x|_]).
pc_member(_x,[_|_r]) :- pc_member(_x,_r).

pc_cputime(_t) :-
  cputime(_t).

pc_gettime(_t) :- get_time(_t).  {* not sure whether BIM-Prolog supported this ... *} 

#ENDIF(BIM)

{************************************************}
{                    SWI                         }
{************************************************}

#IF(SWI)
:- use_module('ExternalCodeLoader.swi.pl',[swi_stringtoatom/2,swi_pointer/1,swi_isNullPointer/1,pc_record_ext/3,pc_rerecord_ext/3,pc_recorded_ext/3,pc_is_a_key_ext/2,pc_erase_ext/2,pc_erase_all_ext/1,pc_current_key_ext/3]) .
%:- use_module('ExternalCodeLoader.swi.pl',[swi_stringtoatom/2,swi_pointer/1,swi_isNullPointer/1]) .


{ call the predicate _x exactly once }
:- module_transparent callExactlyOnce/1 .
callExactlyOnce(_x)	:- once(_x).

{ Create a predicate with module qualifier }
:- module_transparent createModTerm/4 .
createModTerm(_pred,_mod,_arglist,_mod : _term) :-
    _term =.. [_pred|_arglist].

{ Test if x and y are unifiable, but do not unify them }
pc_unifiable(_x,_y) :-
    not(not(_x = _y)).


{ Update the predicate (i.e. retract the a fact from the KB
with the same factor and assert _pred }
:- module_transparent pc_update/1 .
pc_update((_mod : _pred)) :-
    functor(_pred,_fun,_ar),
    functor(_vpred,_fun,_ar),
    retract(_mod:_vpred),
    !,
    asserta(_mod:_pred).

pc_update(_pred) :-
    _pred \= ( _ : _),
    functor(_pred,_fun,_ar),
    functor(_vpred,_fun,_ar),
    retract(_vpred),
    !,
    asserta(_pred).

pc_update(_pred) :-
    asserta(_pred).

{ checks whether _pred is defined in the current knowledge base }
:- module_transparent pc_has_a_definition/1 .
pc_has_a_definition(_pred) :-
    current_predicate(_,_pred),
    !.

{ concat a list of atoms (arg1), result is arg2 }
pc_atomconcat([_atom],_atom) :- !.

pc_atomconcat([_atom1,_atom2],_atom) :-
   !,
   atom_concat(_atom1,_atom2,_atom).

pc_atomconcat([_atom1|_rest],_atom) :-
  pc_atomconcat(_rest,_atom2),
  atom_concat(_atom1,_atom2,_atom).



{ atom3 is the concatenation of atom1 and atom2 }
pc_atomconcat(_atom1,_atom2,_atom3) :-
    atom_concat(_atom1,_atom2,_atom3).


pc_atompart(_atom,_part,_start,_len) :-
    ground(_start),
    !,
    _start1 is _start - 1,
    sub_atom(_atom,_start1,_len,_,_part),
    !.

pc_atompart(_atom,_part,_start,_len) :-
    var(_start),
    sub_atom(_atom,_start1,_len,_,_part),
    _start is _start1 + 1,
    !.

pc_atompartsall(_atom,_part,_start) :-
    ground(_start),
    !,
    _start1 is _start - 1,
    sub_atom(_atom,_start1,_,_,_part).

pc_atompartsall(_atom,_part,_start) :-
    var(_start),
    !,
    sub_atom(_atom,_start1,_,_,_part),
    _start is _start1 + 1 .

pc_atomconstruct(_atom,0,'') :- !.
pc_atomconstruct(_atom,1,_atom) :- !.
pc_atomconstruct(_atom,_n,_natom) :-
    _n1 is _n-1 ,
    pc_atomconstruct(_atom,_n1,_natom1),
    atom_concat(_natom1,_atom,_natom).




{ Record Database}


{****** The following implementation makes use of external c++ implementations in libGeneral/TermCache.cc. ******}

pc_record(_k1,_k2,_t) :-
    nonvar(_t),
    pc_record_ext(_k1, _k2, _t).

pc_record(_k1,_t) :-
    pc_record(_k1,'0',_t).

pc_rerecord(_k1,_k2,_t) :-
    nonvar(_t),
    pc_rerecord_ext(_k1, _k2, _t).

pc_rerecord(_k1,_t) :-
    pc_rerecord(_k1,'0',_t).

pc_recorded(_k1,_k2,_t) :-
    pc_recorded_ext(_k1, _k2, _t).

pc_recorded(_k1,_t) :-
    pc_recorded(_k1,'0',_t).


pc_erase(_k1,_k2) :-
    pc_erase_ext(_k1, _k2),
    !.

pc_erase(_k1,_k2) :- !.

pc_erase(_k1) :-
    pc_erase(_k1,'0').

pc_erase_all(_k2) :-
    pc_erase_all_ext(_k2).

pc_erase_all(_k2) :- !.

pc_erase_all :-
    pc_erase_all('0').

pc_is_a_key(_k1,_k2) :-
    pc_is_a_key_ext(_k1, _k2).

pc_is_a_key(_k1) :-
    pc_is_a_key(_k1,'0').

pc_current_key(_k1,_k2) :-
    pc_current_key_ext(_k1, _k2, _ResultList),
    !,
    pc_member(double_key(_k1, _k2), _ResultList).

pc_current_key(_k1) :-
    pc_current_key(_k1,'0').

{ END OF NEW VERSION OF RECORD DB ***************}

{ Term conversion }
pc_inttoatom(_int,_atom) :-
    catch(term_to_atom(_int,_atom),_ex,warn_and_fail(_ex,_int,_atom)),
    integer(_int),
    !.

pc_floattoatom(_f,_atom) :-
    catch(term_to_atom(_f,_atom),_ex,warn_and_fail(_ex,_f,_atom)),
    (float(_f);integer(_f)),
    !.

pc_atom_to_term(_atom,_term) :-
    atom(_atom),
    !,
    catch(term_to_atom(_term,_atom),_ex,warn_and_fail(_ex,_term,_atom)).

pc_atom_to_term(_atom,_term) :-
    { use swritef here, as term_to_atom inserts quotes by default }
    swritef(_s,'%w',[_term]),
    string_to_atom(_s,_atom).


{* this version of pc_atom_to_term behaves like under BIM-Prolog, i.e. *}
{* uppercase names are transformed to atoms, not to variables.         *}
pc_save_atom_to_term(_atom,_term) :-
    atom(_atom),
    !,
    catch(swi_save_atom_to_term(_atom,_term),_,(_atom=_term)).

pc_save_atom_to_term(_atom,_term) :-
    var(_atom),
      { use swritef here, as term_to_atom inserts quotes by default }
    swritef(_s,'%w',[_term]),
    string_to_atom(_s,_atom).


swi_save_atom_to_term(_atom,_term) :-
  atom_to_term(_atom,_term,_bindings),
  swi_process_bindings(_bindings).

swi_process_bindings([]) :- !.

swi_process_bindings([_x=_y|_rest]) :-
  _x=_y,
  swi_process_bindings(_rest).






warn_and_fail(_ex,_t,_a) :-
{    write('**** Exception:'),write(_ex),nl,  }
{    write('**** Syntax error in '),write(term_to_atom(_t,_a)),nl, }
    fail.

:- module_transparent pc_swriteQuotes/2 .
pc_swriteQuotes(_atom,_term) :-
    format(atom(_atom),'~q',[_term]).
{*    sformat(_str,'~q',[_term]), 
    string_to_atom(_str,_atom). *}

:- module_transparent pc_swriteQuotesAndModule/2 .
pc_swriteQuotesAndModule(_atom,_term) :-
    { TODO: module qualifier not written, might be not necessary in SWI-Prolog, if
      predicates are imported into context module of read-predicate }
    { PROBLEM: _term is not a simple predicate, but a compound term (e.g. a rule) }
    format(atom(_str),'~q',[_term]),  {* use format instead sformat *}
    string_to_atom(_str,_atom).

pc_atomtolist(_a,_l) :-
    atom_chars(_a,_l).

pc_stringtoatom(_s,_a) :-
    swi_stringtoatom(_s,_a).

pc_ascii(_char,_num) :-
    char_code(_char,_num).

pc_pointer(_p) :-
    swi_pointer(_p).  { TODO: correct check for pointers in SWI, not all integers are pointers }
                    { not possible, according to Jan W., pointer has to be wrapped in Prolog term }

pc_isNullPointer(_p) :-
    swi_isNullPointer(_p) .

{ File handling }
pc_fopen(_stream,_fname,_mode) :-
    translate_fopen_mode(_mode,_swimode),
    pc_expand_path(_fname,_expfname),
    ((var(_stream),
      !,
      open(_expfname,_swimode,_stream,[eof_action(eof_code)])
     );
     (atom(_stream),
      open(_expfname,_swimode,_fd,[eof_action(eof_code),alias(_stream),encoding(text),representation_errors(prolog)])
     )
    ),
    !.

translate_fopen_mode(r,read).
translate_fopen_mode(w,write).
translate_fopen_mode(a,append).

pc_fclose(_stream) :-
    close(_stream).

pc_exists(_file) :-
    exists_file(_file).

pc_exists(_dir) :-
    exists_directory(_dir).

pc_exists_directory(_dir) :-
    exists_directory(_dir).

{ Read a line from a file }
pc_readln(_file,_atom) :-
    pc_readln2(_file,'',_atom).

pc_readln2(_file,_read,_res) :-
    get_char(_file,_ch),
    (( _ch == '\n',_res = _read);
     ( _ch == 'end_of_file',_res = _read);
     (atom_concat(_read,_ch,_read2),
      pc_readln2(_file,_read2,_res)
     )
    ),
    !.

pc_readln2(_file,_res,_res) :- !.


{ Expand a path name, including environment variables }
pc_expand_path(_path,_exp) :-
    expand_file_name(_path,[_exp|_]).


{ t in sec is the cputime (as float) used to evaluate goal }
:- module_transparent pc_time/2 .
pc_time(_goal,_t) :-
    statistics(cputime,_t1), 
    call(_goal),
    statistics(cputime,_t2), 
    _t is (_t2 - _t1).

pc_please(_a,_b).
pc_error_message(_a,_b).

pc_atomprefix(_prefix,_atom) :-
  sub_atom(_atom, 0, _, _, _prefix).

{* _len indicates the length of _prefix *}
pc_atomprefix(_prefix,_len,_atom) :-
  sub_atom(_atom, 0, _len, _, _prefix).

{* x is member is list s *}
{* pc_member(_x,_s) :- member(_x,_s). *}

pc_member(_x,[_x|_]).
pc_member(_x,[_|_r]) :- pc_member(_x,_r).

pc_cputime(_t) :-
  _t is cputime.

pc_gettime(_t) :- get_time(_t).  {* time in seconds as floating point number passed since 1970-01-01 *} 


#ENDIF(SWI)


{* pc_store is for overwriting values in the record database *}
pc_store(_k1,_t) :-
    pc_recorded(_k1,_),
    pc_rerecord(_k1,_t),
    !.

pc_store(_k1,_t) :-
    pc_record(_k1,_t),
    !.
