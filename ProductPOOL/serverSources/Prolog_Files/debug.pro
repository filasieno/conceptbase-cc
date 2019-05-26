{*
The ConceptBase.cc Copyright

Copyright 1987-2019 The ConceptBase Team. All rights reserved.

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

#IF(SWI)
#MODULE(debug)
#EXPORT(black/0)
#EXPORT(red/0)
#EXPORT(green/0)
#EXPORT(brown/0)
#EXPORT(blue/0)
#EXPORT(magenta/0)
#EXPORT(cyan/0)
#EXPORT(white/0)
#EXPORT(writedb/2)
#EXPORT(writedb/1)
#EXPORT(deb/1)
#EXPORT(deb_time/1)
#ENDMODDECL()
#ENDIF(SWI)

black :-
	write('\033[30m ').

red :-
	write('\033[31m ').

green :-
	write('\033[32m ').

brown :-
	write('\033[33m ').

blue :-
	write('\033[34m ').

magenta :-
	write('\033[35m ').

cyan :-
	write('\033[36m ').

white :-
	write('\033[37m ').

{ NODEBUG }
{ writedb(_,_).
writedb(_).
}

{ DEBUG }
writedb(_c,_x) :-
   	call(_c),
	writedb(_x),
	black.


writedb(_c) :-
	write(_c),nl.

#IF(SWI)
:- module_transparent deb/1 .
:- module_transparent deb_time/1 .
#ENDIF(SWI)

deb(_c) :-
	writedb(blue,call(_c)),nl,
	call(_c),
	writedb(green,succ(_c)),nl.


deb(_c) :-
    writedb(red,fail(_c)),nl,
{	writedb(magenta,['Aufruf von ',_c,'ist fehlgeschlagen']),}
	fail.

deb_time(_c) :-
#IF(BIM)
	time(_c,_t),
	blue,write(_c),
	printf('\n  Time used: %.2f\n',_t),black.
#ELSE(BIM)
    statistics(cputime,_t1),
	call(_c),
	_t is cputime - _t1,
	blue,write(_c),
	write('\n  Time used: '),write(_t),nl,black.
#ENDIF(BIM)
