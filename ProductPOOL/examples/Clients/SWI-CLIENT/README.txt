Use of the SWI-Prolog client for interfacing to ConceptBase

Daniel Gross

2020-02-25

---------------------------------------------------------------------------------------

Preconditions:
==============

(1) ConceptBase V8.0 or later including the ability to run the ConceptBase server (CBserver).
See also 
http://conceptbase.sourceforge.net/CB-Download.html

(2) SWI-Prolog 7.2 or later


Step 1: Start a CBserver in a command window on your localhost
==============================================================

% cbserver -t low -sm slave
You can change the parameters according to your needs, see
http://conceptbase.sourceforge.net/userManual81/cbm007.html



Step 2: Start SWI-Prolog in another command window
=================================================


% swipl
Welcome to SWI-Prolog (Multi-threaded, 64 bits, Version 7.2.3)
Copyright (c) 1990-2015 University of Amsterdam, VU Amsterdam
SWI-Prolog comes with ABSOLUTELY NO WARRANTY. This is free software,
and you are welcome to redistribute it under certain conditions.
Please visit http://www.swi-prolog.org for details.

For help, use ?- help(Topic). or ?- apropos(Word).

?- [cb_ipc, cb_client_demo].
true.

?- demo1(Result).
Result = (error, ["Object bill!billsempno is declared as instance of Employee!empno. Then, Telos requires that bill is an instance of Employee AND b123 is an instance of Integer.\n\n", "Object bill!billsempno refers to a nonexisting object b123.\n\n"]).

?- demo2(Result).
[]
Result = (ok, "bill in Employee with \n   empno\n    billsempno : 123\n  name\n    billsname : \"William\"\nend \n").

?- demo3(Result).
[]
Result = (ok, "jack,gwendoline").

?- demo4(Result).
[]
Result = (ok, "gwendoline").

?- cb_cancel_me(_Result).
_Result = (ok, ok).


----
README file written by Manfred Jeusfeld




