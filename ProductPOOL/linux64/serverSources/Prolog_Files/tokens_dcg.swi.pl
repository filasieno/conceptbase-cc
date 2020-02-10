/** 'This' module named "tokens_dcg" was automatically generated from the 'DCG'-grammar file "tokens.dcg".

	'DO' 'NOT' 'EDIT' 'MANUALLY'
**/

:- module('tokens_dcg',[

'buildTokens'/3
,'alphanumeric'/3
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('GeneralUtilities.swi.pl').


:- use_module('ErrorMessages.swi.pl').
:- use_module('PrologCompatibility.swi.pl').


:- use_module('MSFOLassertionParserUtilities.swi.pl').


'IMPORT'('WriteTrace'/3, 'GeneralUtilities')  :-
 style_check(-singleton) .

buildTokens(_G473, _G500, _G503)  :-
 blanksorcomment(_G500, _G525),
 buildTokens2(_G473, _G525, _G503),
 ! .

buildTokens2([_G559|_G560], _G594, _G597)  :-
 token(_G559, _G594, _G622),
 blanksorcomment(_G622, _G644),
 buildTokens(_G560, _G644, _G597),
 ! .

buildTokens2([], _G697, _G697)  :-
 ! .

token(ident(_G713), _G745, _G748)  :-
 identifier(_G717, _G745, _G748),
 transformIdentifier(_G717, _G713),
 ! .

token(ident(_G789), _G821, _G824)  :-
 implicit_var(_G793, _G821, _G824),
 pc_atomconcat(_G793, _G789),
 ! .

token(ident(_G865), ['\''|_G920], _G906)  :-
 specialIdentifier(_G872, _G920, _G906),
 pc_atomconcat(_G872, _G865),
 ! .

token(realNumber(_G950), _G982, _G985)  :-
 realNumber(_G954, _G982, _G985),
 pc_atomconcat(_G954, _G950),
 ! .

token(intNumber(_G1026), _G1058, _G1061)  :-
 intNumber(_G1030, _G1058, _G1061),
 pc_atomconcat(_G1030, _G1026),
 ! .

token(select(_G1102), _G1128, _G1131)  :-
 select(_G1102, _G1128, _G1131),
 ! .

token(select2(_G1169), _G1195, _G1198)  :-
 select2(_G1169, _G1195, _G1198),
 ! .

token(assertion(_G1236), [$|_G1294], _G1280)  :-
 assertionString(_G1243, _G1294, _G1280),
 pc_atomconcat([$|_G1243], _G1236),
 ! .

token(string(_G1324), ['"'|_G1382], _G1368)  :-
 string(_G1331, _G1382, _G1368),
 pc_atomconcat(['"'|_G1331], _G1324),
 ! .

token(_G1412, _G1442, _G1445)  :-
 delimiter(_G1414, _G1442, _G1445),
 pc_atomconcat(_G1414, _G1412),
 ! .

token(_G1486, [_G1488|_G1527], _G1527)  :-
 report_error(tokensSYNERR2, tokens_dcg, [_G1488]),
 !,
 fail .

identifier([_G1549|_G1550], _G1573, _G1576)  :-
 character(_G1549, _G1573, _G1601),
 alphanumeric(_G1550, _G1601, _G1576) .

identifier([_G1636], _G1655, _G1658)  :-
 character(_G1636, _G1655, _G1658) .

identifier([_G1693|_G1694], _G1717, _G1720)  :-
 digit(_G1693, _G1717, _G1745),
 nonInteger(_G1694, _G1745, _G1720) .

nonInteger([_G1780|_G1781], _G1804, _G1807)  :-
 digit(_G1780, _G1804, _G1832),
 nonInteger(_G1781, _G1832, _G1807) .

nonInteger([_G1867|_G1868], _G1891, _G1894)  :-
 character(_G1867, _G1891, _G1919),
 alphanumeric(_G1868, _G1919, _G1894) .

nonInteger([_G1954], _G1973, _G1976)  :-
 character(_G1954, _G1973, _G1976) .

specialIdentifier([], ['\''|_G2031], _G2031)  :-
 true .

specialIdentifier([_G2047|_G2048], _G2071, _G2074)  :-
 printableChar(_G2047, _G2071, _G2099),
 specialIdentifier(_G2048, _G2099, _G2074) .

implicit_var([~|_G2135], [~|_G2176], _G2162)  :-
 identifier(_G2135, _G2176, _G2162) .

implicit_var([~|_G2201], [~, '"'|_G2265], _G2248)  :-
 string(_G2211, _G2265, _G2248),
 pc_atomconcat(['"'|_G2211], _G2201),
 ! .

realNumber(_G2295, _G2328, _G2331)  :-
 realNumber2(_G2297, _G2328, _G2356),
 realExponent(_G2299, _G2356, _G2331),
 append(_G2297, _G2299, _G2295) .

realNumber2(_G2394, _G2436, _G2439)  :-
 digits(_G2396, _G2436, ['.'|_G2478]),
 digits(_G2401, _G2478, _G2439),
 append(_G2396, ['.'|_G2401], _G2394) .

realNumber2(['.'|_G2506], ['.'|_G2547], _G2533)  :-
 digits(_G2506, _G2547, _G2533) .

realNumber2([-, _G2574|_G2575], [-|_G2621], _G2607)  :-
 digit(_G2574, _G2621, _G2635),
 realNumber2(_G2575, _G2635, _G2607) .

realExponent([_G2670, _G2673|_G2674], [_G2670, _G2673|_G2753], _G2736)  :-
 memberchk(_G2670, ['E', e]),
 memberchk(_G2673, [+, -]),
 digits(_G2674, _G2753, _G2736) .

realExponent([], _G2805, _G2805)  :-
 true .

select(_G2821, [_G2821|_G2861], _G2861)  :-
 memberchk(_G2821, [!, ^, @]) .

select(_G2877, [=, >|_G2912], _G2912)  :-
 pc_atomconcat(=, >, _G2877) .

select(_G2931, [-, >|_G2966], _G2966)  :-
 pc_atomconcat(-, >, _G2931) .

select2(dot, ['.'|_G3005], _G3005)  :-
 true .

select2(bar, [ ('|')|_G3041], _G3041)  :-
 true .

intNumber(_G3057, _G3073, _G3076)  :-
 digits(_G3057, _G3073, _G3076) .

intNumber([-|_G3112], [-|_G3153], _G3139)  :-
 digits(_G3112, _G3153, _G3139) .

assertionString([$], [$|_G3200], _G3200)  :-
 true .

assertionString([_G3216|_G3217], [_G3216|_G3258], _G3244)  :-
 assertionString(_G3217, _G3258, _G3244) .

string(['"'], ['"'|_G3305], _G3305)  :-
 true .

string([\, '"'|_G3325], [\, '"'|_G3375], _G3358)  :-
 string(_G3325, _G3375, _G3358) .

string([_G3399|_G3400], [\, _G3399|_G3467], _G3450)  :-
 memberchk(_G3399, [$, \]),
 string(_G3400, _G3467, _G3450) .

string([_G3494|_G3495], [_G3494|_G3536], _G3522)  :-
 string(_G3495, _G3536, _G3522) .

comment(['(', *|_G3594], _G3581)  :-
 ignoreChar1(_G3594, _G3581) .

comment(['{'|_G3639], _G3629)  :-
 ignoreChar2(_G3639, _G3629) .

ignoreChar1([*, ')'|_G3682], _G3682)  :-
 ! .

ignoreChar1([_G3697|_G3725], _G3715)  :-
 ignoreChar1(_G3725, _G3715) .

ignoreChar2(['}'|_G3765], _G3765)  :-
 ! .

ignoreChar2([_G3777|_G3805], _G3795)  :-
 ignoreChar2(_G3805, _G3795) .

alphanumeric([_G3822|_G3823], _G3846, _G3849)  :-
 alphachar(_G3822, _G3846, _G3874),
 alphanumeric(_G3823, _G3874, _G3849) .

alphanumeric([_G3909], _G3928, _G3931)  :-
 alphachar(_G3909, _G3928, _G3931) .

alphachar(_G3966, _G3982, _G3985)  :-
 character(_G3966, _G3982, _G3985) .

alphachar(_G4020, _G4036, _G4039)  :-
 digit(_G4020, _G4036, _G4039) .

digits([_G4074|_G4075], _G4098, _G4101)  :-
 digit(_G4074, _G4098, _G4126),
 digits(_G4075, _G4126, _G4101) .

digits([_G4161], _G4180, _G4183)  :-
 digit(_G4161, _G4180, _G4183) .

digit(_G4218, [_G4218|_G4255], _G4255)  :-
 '0'@=<_G4218,
 _G4218@=<'9' .

character(_G4274, [_G4274|_G4311], _G4311)  :-
 'A'@=<_G4274,
 _G4274@=<'Z' .

character(_G4330, [_G4330|_G4367], _G4367)  :-
 a@=<_G4330,
 _G4330@=<z .

character(_G4386, [_G4386|_G4498], _G4498)  :-
 pc_ascii(_G4386, _G4392),
 memberchk(_G4392, [228, 246, 252, 223, 196, 214, 220, 225, 233, 243, 250, 224, 232, 242, 249, 226, 234, 244, 251, 235, 239, 238, 236, 241, 209]) .

character(_G4517, [_G4517|_G4566], _G4566)  :-
 pc_ascii(_G4517, _G4523),
 memberchk(_G4523, [128, 134, 135, 143]) .

character(_G4585, [_G4585|_G4634], _G4634)  :-
 pc_ascii(_G4585, _G4591),
 memberchk(_G4591, [95, 185, 178, 179]) .

printableChar(_G4653, [_G4653|_G4696], _G4696)  :-
 pc_ascii(_G4653, _G4659),
 _G4659>30,
 _G4659=<254 .

delimiter([\, =, =], [\, =, =|_G4753], _G4753)  :-
 true .

delimiter([\, =], [\, =|_G4804], _G4804)  :-
 true .

delimiter([=, '.', '.'], [=, '.', '.'|_G4858], _G4858)  :-
 true .

delimiter([=, =, >], [=, =, >|_G4915], _G4915)  :-
 true .

delimiter([<, =, =, >], [<, =, =, >|_G4978], _G4978)  :-
 true .

delimiter([=, =], [=, =|_G5032], _G5032)  :-
 true .

delimiter([=, >], [=, >|_G5080], _G5080)  :-
 true .

delimiter([=, <], [=, <|_G5128], _G5128)  :-
 true .

delimiter([>, =], [>, =|_G5176], _G5176)  :-
 true .

delimiter([<, =], [<, =|_G5224], _G5224)  :-
 true .

delimiter([<, >], [<, >|_G5272], _G5272)  :-
 true .

delimiter([_G5291], [_G5291|_G5343], _G5343)  :-
 memberchk(_G5291, ['(', ')', '[', ']', '{', '}']) .

delimiter([_G5359], [_G5359|_G5417], _G5417)  :-
 memberchk(_G5359, [ (','), (;), :, =, &, '_', >, <]) .

delimiter([_G5433], [_G5433|_G5467], _G5467)  :-
 pc_ascii(_G5433, 96) .

delimiter([_G5483], [_G5483|_G5529], _G5529)  :-
 memberchk(_G5483, [+, -, *, /]) .

delimiter([#], [#|_G5568], _G5568)  :-
 true .

blanksorcomment(_G5604, _G5607)  :-
 comment(_G5604, _G5625),
 !,
 blanksorcomment(_G5625, _G5607) .

blanksorcomment(_G5672, _G5675)  :-
 blanks(_G5672, _G5693),
 !,
 blanksorcomment(_G5693, _G5675) .

blanksorcomment(_G5734, _G5734)  :-
 ! .

blanks(_G5758, _G5761)  :-
 blankchar(_G5758, _G5779),
 blanks(_G5779, _G5761) .

blanks(_G5812, _G5815)  :-
 blankchar(_G5812, _G5815) .

blankchar([_G5839|_G5883], _G5883)  :-
 pc_ascii(_G5839, _G5843),
 memberchk(_G5843, [32, 9, 10, 13]) .
