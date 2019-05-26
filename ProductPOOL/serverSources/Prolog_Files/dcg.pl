/*
The ConceptBase Copyright

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


This license is a FreeBSD copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
/* dcg1.pro 14.2.86	*/
/* Definite Clause Grammars.

  Translator from DCG form to BIM Prolog clauses.

  Syntax of DCGs as in Clocksin and Mellish Chapter 9, except,

  (i) symbol ==> used instead of -->
  (ii) Prolog goals are not put between curly brackets,
  since in the following program DCGs are prolog terms;
  curly brackets are comment delimiters in BIM prolog.
  Instead, the Prolog goals are written at the end of the
  rule as "where [...Prolog goals...]"

  JPG, 5.ii.86
  HWN, 26-Jul-1988 (UPA)
  UB,  11-Dec-1990 (UPA)*/

/* operator definitions */
:- op(1110,xfx,'==>').
:- op(800,fx,where).

:- style_check(-singleton).




dcg :-
	write(' Please enter name of inputfile  :'),readAtom(_infile),nl,
/*        write(' Please enter modulename         :'),readAtom(_moduleName),nl,*/
	outfile(_infile,_outfile),
	writeExtension(_infile,_infileExt),
	writeModulName(_outfile,_moduleName),
	pc_fopen(dcgfile,_infileExt,r),
	pc_fopen(profile,_outfile,w),
	write_intro(profile,_infileExt,_moduleName),
	read_rule(dcgfile,_rule),
	translate_rules(_rule,dcgfile,profile),
	pc_fclose(dcgfile),
	pc_fclose(profile),
	!.


/******************************************************************************/
/***  Predicates written by HWN for more usage quality                      ***/
/******************************************************************************/

/*******************************************************************************/
/*  readAtom								      */
/*  This predicate reads an atom from the keyboard.			      */
/*******************************************************************************/

readAtom(_atom) :-
	readInput(_charList),
	atom_chars(_atom,_charList).


/*****************************************************************************/
/*  readInput								    */
/*  This predicate reads characters from the keyboard until end of line.     */
/*  The characters are returned as a list.				    */
/*****************************************************************************/

readInput([_char|_charlist]) :-
	get_char(_char),
	\+ char_type(_char,newline),
	readInput(_charlist),!.

readInput([]) :- !.

/*****************************************************************************/
/* writeExtension(_infile,_infileExt)					    */
/*  _infile :ground :atom						    */
/*  _infileExt :free :atom   						    */
/*									    */
/*  This predicate controls, if the filename given by the user has an        */
/*   extension (=.dcg)  or not. If it has no extension, it gets one. If it   */
/*  has already one, the name will be given back without any changes.        */
/*									    */
/*****************************************************************************/

writeExtension(_infile,_infile) :-
	atom_concat(_,'.dcg',_infile).

writeExtension(_infile,_infileExt) :-
	atom_concat(_infile,'.dcg',_infileExt).


/*****************************************************************************/
/* writeModulName(_outfile,_moduleName)					    */
/*  _outfile :ground :atom						    */
/*  _moduleName :free :atom						    */
/*									    */
/*  This predicate generates the modulename of the computet file. For all    */
/*  files written for ConceptBase the modulename is the same as the filename */
/*  without the extension (=.pro). For example : The modulename for the file */
/*  with the name "testFile.pro" will be "testFile". So the moduleName can   */
/*  easily generatet by remove the extension of _outfile, the name of the    */
/*  computet file.							    */
/*									    */
/*****************************************************************************/

writeModulName(_outfile,_moduleName) :-
	atom_concat(_moduleName,'.pro',_outfile).


/*******************************************************************************/
/*  END of section of predicates defined by HWN (UPA)			      */
/*******************************************************************************/

translate_rules(end_of_file,_infile,_outfile) :-
	/* eof(_infile), */
	nl(_outfile).

translate_rules(_rule,_infile,_outfile) :-
	(_rule = 'IMPORT'(_a,_b); _rule = 'EXPORT'(_a) ; _rule = 'DYNAMIC'(_a); _rule = 'EXPORTEND'(a)),
	writeOpdef(_outfile,_rule),
	!,
	read_rule(_infile,_nextrule),
	translate_rules(_nextrule,_infile,_outfile).

translate_rules(_rule,_infile,_outfile) :-
	dcg_rule(_rule,_clause,_,_),
	write(_rule),nl,
	write_clause(_outfile,_clause),
	!,
	read_rule(_infile,_nextrule),
	translate_rules(_nextrule,_infile,_outfile).

write_clause(_outfile,(_head :- _body)) :-
	nl(_outfile),nl(_outfile),
	writeq(_outfile,_head),
	write(_outfile,'  :-'),
	write_body(_outfile,_body),
	write(_outfile,' .').

write_clause(_outfile, ( :- _opdef)) :-
	nl(_outfile),
	write(_outfile,':- '),
	writeq(_outfile,_opdef),
	write(_outfile,' .').

writeOpdef(_outfile,'IMPORT'(_a,_b)) :-
    write(_outfile,'#IMPORT('),
	write_term(_outfile, _a,[quoted(false)]),
	write(_outfile,','),
	write_term(_outfile,_b,[quoted(false)]),
	write(_outfile,')\n').

writeOpdef(_outfile,'EXPORT'(_a)) :-
    write(_outfile,'#EXPORT('),
	writeq(_outfile, _a),
	write(_outfile,')\n').

writeOpdef(_outfile,'DYNAMIC'(_a)) :-
    write(_outfile,'#DYNAMIC('),
	writeq(_outfile, _a),
	write(_outfile,')\n').

writeOpdef(_outfile,'EXPORTEND'(a)) :-
    write(_outfile,'#ENDMODDECL()\n').

write_body(_outfile,((_g1;_g2),_body)) :-
	!,
	nl(_outfile), tab(_outfile,1),
	write(_outfile,'('),
	write_body(_outfile,_g1),
	write(_outfile,';'),
	write_body(_outfile,_g2),
	write(_outfile,')'),
	write(_outfile,','),
	write_body(_outfile,_body).

write_body(_outfile,(_goal,_body)) :-
	!,
	nl(_outfile), tab(_outfile,1),
	writeq(_outfile,_goal),
	write(_outfile,','),
	write_body(_outfile,_body).

write_body(_outfile,(_g1;_g2)) :-
	!,
	nl(_outfile), tab(_outfile,1),
	write(_outfile,'('),
	write_body(_outfile,_g1),
	write(_outfile,';'),
	write_body(_outfile,_g2),
	write(_outfile,')').

write_body(_outfile,_goal) :-
	nl(_outfile), tab(_outfile,1),
	writeq(_outfile, _goal).

outfile(_in, _out) :-
	atom_chars(_in,_chin),
	remove_ext(_chin,_root),
	append(_root,['_',d,c,g,'.',p,r,o],_chout),
	atom_chars(_out,_chout).

remove_ext(_chin,_root) :-
	append(_root,['.'|_],_chin),
	!.
remove_ext(_chin,_chin).

read_rule(_infile,_rule) :-
	read(_infile, _rule),!.
read_rule(_,_).

/* Translation rules for a single grammar rule */
dcg_rule(( _left ==> _right), (_head :- _body), _s0, _s) :-
	dcg_head( _left, _head, _s0, _s),
	dcg_body( _right, _body, _s0, _s).

dcg_rule((_head :- _body),(_head :- _body),_,_) :-
	!.

dcg_rule(( :- _opdef), ( :- _opdef), _,_) :-
	call(_opdef).

dcg_rule(_unitclause, (_unitclause :- true ),_,_) :-
	! .

dcg_head( _left, _head, _s0, _s) :-
	dcg_non_terminal(_left, _head, _s0,_s,_s).

dcg_body((_r1;_r2),((_s1=_s0,_t1=_s,_b1);(_s2=_s0,_t2=_s,_b2)),_s0,_s) :-
	dcg_body(_r1,_b1,_s1,_t1),
	dcg_body(_r2,_b2,_s2,_t2).

dcg_body((where _g,_gs),_ng1,_s0,_s) :-
	list_conj(_g,_ng),
	dcg_body(_gs,_ngs,_s0,_s),
	append_conj(_ng,_ngs,_ng1).

dcg_body((_terminal,_gs), _bgs, _s0, _last) :-
	terminal_symb(_terminal),
	!,
	dcg_terminal( _terminal, _s0, _last,_s2),
	dcg_body( _gs, _bgs, _s2, _last).

dcg_body((_non_terminal, _gs), (_bim_non_terminal, _bim_gs), _s0,_last) :-
	!,
	dcg_non_terminal( _non_terminal, _bim_non_terminal, _s0,_last,_s2),
	dcg_body( _gs, _bim_gs, _s2, _last).

dcg_body(_terminal, true, _s0, _last) :-
	terminal_symb(_terminal),
	!,
	dcg_terminal( _terminal, _s0, _last, _last).

dcg_body((where _goals), _bim_goals, _last, _last) :-
	!,
	list_conj( _goals, _bim_goals).

dcg_body(_non_terminal, _bim_non_terminal, _s0,_last) :-
	dcg_non_terminal( _non_terminal, _bim_non_terminal, _s0,_last,_last).

dcg_non_terminal( _non_terminal, _bim_non_terminal, _s0,_last,_s2) :-
	_non_terminal =.. [_p|_args],
	append(_args, [_s0,_s2], _newargs),
	_bim_non_terminal =.. [_p|_newargs].

dcg_terminal( [_terminal], [_terminal|_s2],_last,_s2) :-
	!.

dcg_terminal( [_terminal|_ts], [_terminal|_s3],_last,_s2) :-
	dcg_terminal(_ts,_s3,_last,_s2).

list_conj([_x],_x) :-
	!.
list_conj([_x|_l],(_x,_cl)) :-
	list_conj(_l,_cl).

terminal_symb([_|_]).

append([],_x,_x).
append([_x|_l],_m,[_x|_n]) :-
	append(_l,_m,_n).

append_conj((_x,_l),_m,(_x,_n)) :-
	!,
	append_conj(_l,_m,_n).
append_conj(_x,_l,(_x,_l)).

write_intro(profile,_infileExt,_moduleName) :-
	write(profile,'/** This module named "'),
	write(profile,_moduleName),
	write(profile,'" was automatically generated from the DCG-grammar file "'),
	write(profile,_infileExt),
	write(profile,'".\n\n\tDO NOT EDIT MANUALLY\n**/\n\n'),
	write(profile, '#MODULE('),
	write(profile,_moduleName),
	write(profile,')\n\n').



o :- 	op(1110,xfx,'==>'),
	op(800,fx,'where').

?- set_prolog_flag(allow_variable_name_as_functor,true),o.


/*********************************************************/
/* From PrologCompatibility.pro */
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

/* Read a line from a file */
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


/* Expand a path name, including environment variables */
pc_expand_path(_path,_exp) :-
    expand_file_name(_path,[_exp|_]).
