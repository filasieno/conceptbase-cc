% client demo

:- use_module(cb_ipc).
	
monad_call(Goal, Result1, Result2) :-
	cb_is_ok(Result1),
	call(Goal, Result2), !.

monad_call(_, Result1, Result1).

demo1(Result4) :- 
	cb_is_ok(Result0),
	monad_call(cb_init_ipc, Result0, Result1),
	monad_call(cb_enroll_me("Daniel"), Result1, Result2),
	monad_call(cb_tell("Employee in Class with attribute empno: Integer; name: String end"), Result2, Result3),
	monad_call(cb_tell("bill in Employee with empno billsempno: b123 end"), Result3, Result4).	
	
demo2(Result3) :- 
	cb_is_ok(Result0),
	monad_call(cb_tell("bill in Employee with empno billsempno: 123 end"), Result0, Result1),
	monad_call(cb_tell("bill in Employee with name billsname: \"William\" end"), Result1, Result2),
	monad_call(cb_ask("get_object[bill/objname]"), Result2, Result3).
	
demo3(Result4) :-
	cb_is_ok(Result0),
	monad_call(cb_tell("jack in Employee with empno billsempno: 123 end"), Result0, Result1),	
	monad_call(cb_tell("gwendoline in Employee with empno billsempno: 123 end"), Result1, Result2),	
	monad_call(cb_tell("UnnamedEmployee in QueryClass isA Employee with constraint c: $ not exists n/String (this name n) $ end"), Result2, Result3),
	monad_call(cb_ask("UnnamedEmployee", "LABEL"), Result3, Result4).
	
demo4(Result2) :-
	cb_is_ok(Result0),
	monad_call(cb_untell("jack in Employee with empno billsempno: 123 end"), Result0, Result1),	
	monad_call(cb_ask("UnnamedEmployee", "LABEL"), Result1, Result2).
	

% with DCG

d1(L1, L2) :-
	phrase(dcg_demo1, L1, L2).
	
d2(L1, L2) :-
	phrase(dcg_demo2, L1, L2).
			
dcg_demo1 -->
	cb_mon_init_ipc,
	cb_mon_enroll_me("Daniel"),
	cb_mon_tell("Employee in Class with attribute empno: Integer; name: String end"),
	cb_mon_tell("bill in Employee with empno billsempno: b123 end").						% error
	
dcg_demo2 -->
	cb_mon_init_ipc,
	cb_mon_enroll_me("Daniel"),
	cb_mon_tell("bill in Employee with empno billsempno: b123 end"),						% error
	cb_mon_tell("Employee in Class with attribute empno: Integer; name: String end").
