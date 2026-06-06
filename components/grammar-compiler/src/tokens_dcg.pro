% This module named "tokens_dcg" was automatically generated from the DCG-grammar file "tokens.dcg".
%
% 	DO NOT EDIT MANUALLY
%

#MODULE(tokens_dcg)
#EXPORT(buildTokens/3)
#EXPORT(alphanumeric/3)
#ENDMODDECL()
#IMPORT(member/2,GeneralUtilities)
#IMPORT(memberchk/2,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(report_error/3,ErrorMessages)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_ascii/2,PrologCompatibility)
#IMPORT(transformIdentifier/2,MSFOLassertionParserUtilities)
'IMPORT'('WriteTrace'/3,'GeneralUtilities')  :-
 style_check(-singleton) .

buildTokens(_3880,_3924,_3926)  :-
 blanksorcomment(_3924,_3980),
 buildTokens2(_3880,_3980,_3926),
 ! .

buildTokens2([_4074|_4076],_4134,_4136)  :-
 token(_4074,_4134,_4190),
 blanksorcomment(_4190,_4244),
 buildTokens(_4076,_4244,_4136),
 ! .
buildTokens2([],_4364,_4364)  :-
 ! .

token(ident(_4418),_4472,_4474)  :-
 identifier(_4426,_4472,_4474),
 transformIdentifier(_4426,_4418),
 ! .
token(ident(_4586),_4640,_4642)  :-
 implicit_var(_4594,_4640,_4642),
 pc_atomconcat(_4594,_4586),
 ! .