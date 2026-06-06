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

#MODULE(FragmentToHtml)
#ENDMODDECL()


#IMPORT(append/3,GeneralUtilities)
#IMPORT(output_html/1,html)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_atomtolist/2,PrologCompatibility)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


fragmentToHtml(_out,SMLfragment(_what,_in_omega,_in,_isa,_with)) :-
	whatToHtml(_what,_whathtml),
	inToHtml(_in_omega,_in,_inhtml),
	isaToHtml(_isa,_isahtml),
	withToHtml(_what,_with,_withhtml),
	tell(_out),
	output_html([
		start,
		comment('Converting a Telos Fragment/Frame to HTML'),
		title('Simple ConceptBase WWW Interface'),
		_whathtml,
		h2('In'),
		_inhtml,
		h2('Isa'),
		_isahtml,
		h2('With'),
		_withhtml,
		end]),
	told.


whatToHtml(what(_x),h1(ref(_x2,_x2))) :-
	selectToHtml(_x,_x2).

selectToHtml(select(_x,_o,_y),_atom) :-
	!,
	selectToHtml(_x,_x2),
	selectToHtml(_y,_y2),
	pc_atomconcat([_x2,_o,_y2],_atom).

selectToHtml(_x,_x).

inToHtml(in_omega(_cl1),in(_cl2),itemize(_inhtml)) :-
	append(_cl1,_cl2,_classlist),
	classlistToHtml(_classlist,_inhtml).

classlistToHtml([],[]).
classlistToHtml([class(_x)|_r],[ref(_x2,_x2)|_rs]) :-
	selectToHtml(_x,_x2),
	classlistToHtml(_r,_rs).

isaToHtml(isa(_cl),itemize(_html)) :-
	classlistToHtml(_cl,_html).


withToHtml(what(_what),with(_attrdecl),itemize(_html)) :-
	attrdeclToHtml(_what,_attrdecl,_html).


attrdeclToHtml(_,[],[]).
attrdeclToHtml(_what,[attrdecl(_ac,_proplist)|_rest],[[h3(_acatom),itemize(_prophtml)]|_resthtml]) :-
	listToHtml(_ac,_acatom),
	proplistToHtml(_what,_proplist,_prophtml),
	attrdeclToHtml(_what,_rest,_resthtml).

listToHtml([_x],_x):-!.
listToHtml([_x|_r],_atom) :-
	listToHtml(_r,_ra),
	pc_atomconcat([_x,', ',_ra],_atom).

proplistToHtml(_,[],[]).
proplistToHtml(_what,[property(_label,_value)|_proplist],[[ref(_ref,_label), ' : ' ,ref(_value2,_value2)]|_prophtml]) :-
	selectToHtml(_what,_what2),
	pc_atomconcat([_what2,'!',_label],_ref),
	selectToHtml(_value,_value2),
	proplistToHtml(_what,_proplist,_prophtml).


main :-
	fragmentToHtml(SMLfragment(what(select(Class,'!',rule)),
	in_omega([class(Individual)]),
	in([class(Class)]),
	isa([class(Haribo)]),
	with([attrdecl([attribute],
		[property(constraint,MSFOLconstraint),
		property(rule,MSFOLrule),
		property(single,Class),
		property(necessary,Class)]),
		attrdecl([attribute],
		[property(constraint,MSFOLconstraint),
		property(rule,MSFOLrule),
		property(single,Class),
		property(necessary,Class)])]))).




answerlistToHtml(_anslist,_out):-
	pc_atomtolist(_ans,_anslist),
	tell(_out),
	output_html([
	_ans]),
	told.


