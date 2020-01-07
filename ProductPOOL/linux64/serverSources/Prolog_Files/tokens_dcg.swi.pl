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

buildTokens(_G534, _G561, _G564)  :-
 blanksorcomment(_G561, _G586),
 buildTokens2(_G534, _G586, _G564),
 ! .

buildTokens2([_G620|_G621], _G655, _G658)  :-
 token(_G620, _G655, _G683),
 blanksorcomment(_G683, _G705),
 buildTokens(_G621, _G705, _G658),
 ! .

buildTokens2([], _G758, _G758)  :-
 ! .

token(ident(_G774), _G819, _G822)  :-
 identifier(_G778, _G819, _G822),
 'WriteTrace'(low, tokens, [transformIdentifier(_G778, _G774)]),
 transformIdentifier(_G778, _G774),
 ! .

token(ident(_G866), _G898, _G901)  :-
 implicit_var(_G870, _G898, _G901),
 pc_atomconcat(_G870, _G866),
 ! .

token(ident(_G942), ['\''|_G997], _G983)  :-
 specialIdentifier(_G949, _G997, _G983),
 pc_atomconcat(_G949, _G942),
 ! .

token(realNumber(_G1027), _G1059, _G1062)  :-
 realNumber(_G1031, _G1059, _G1062),
 pc_atomconcat(_G1031, _G1027),
 ! .

token(intNumber(_G1103), _G1135, _G1138)  :-
 intNumber(_G1107, _G1135, _G1138),
 pc_atomconcat(_G1107, _G1103),
 ! .

token(select(_G1179), _G1205, _G1208)  :-
 select(_G1179, _G1205, _G1208),
 ! .

token(select2(_G1246), _G1272, _G1275)  :-
 select2(_G1246, _G1272, _G1275),
 ! .

token(assertion(_G1313), [$|_G1371], _G1357)  :-
 assertionString(_G1320, _G1371, _G1357),
 pc_atomconcat([$|_G1320], _G1313),
 ! .

token(string(_G1401), ['"'|_G1459], _G1445)  :-
 string(_G1408, _G1459, _G1445),
 pc_atomconcat(['"'|_G1408], _G1401),
 ! .

token(_G1489, _G1519, _G1522)  :-
 delimiter(_G1491, _G1519, _G1522),
 pc_atomconcat(_G1491, _G1489),
 ! .

token(_G1563, [_G1565|_G1604], _G1604)  :-
 report_error(tokensSYNERR2, tokens_dcg, [_G1565]),
 !,
 fail .

identifier([_G1626|_G1627], _G1650, _G1653)  :-
 character(_G1626, _G1650, _G1678),
 alphanumeric(_G1627, _G1678, _G1653) .

identifier([_G1713], _G1732, _G1735)  :-
 character(_G1713, _G1732, _G1735) .

identifier([_G1770|_G1771], _G1794, _G1797)  :-
 digit(_G1770, _G1794, _G1822),
 nonInteger(_G1771, _G1822, _G1797) .

nonInteger([_G1857|_G1858], _G1881, _G1884)  :-
 digit(_G1857, _G1881, _G1909),
 nonInteger(_G1858, _G1909, _G1884) .

nonInteger([_G1944|_G1945], _G1968, _G1971)  :-
 character(_G1944, _G1968, _G1996),
 alphanumeric(_G1945, _G1996, _G1971) .

nonInteger([_G2031], _G2050, _G2053)  :-
 character(_G2031, _G2050, _G2053) .

specialIdentifier([], ['\''|_G2108], _G2108)  :-
 true .

specialIdentifier([_G2124|_G2125], _G2148, _G2151)  :-
 printableChar(_G2124, _G2148, _G2176),
 specialIdentifier(_G2125, _G2176, _G2151) .

implicit_var([~|_G2212], [~|_G2253], _G2239)  :-
 identifier(_G2212, _G2253, _G2239) .

implicit_var([~|_G2278], [~, '"'|_G2342], _G2325)  :-
 string(_G2288, _G2342, _G2325),
 pc_atomconcat(['"'|_G2288], _G2278),
 ! .

realNumber(_G2372, _G2405, _G2408)  :-
 realNumber2(_G2374, _G2405, _G2433),
 realExponent(_G2376, _G2433, _G2408),
 append(_G2374, _G2376, _G2372) .

realNumber2(_G2471, _G2513, _G2516)  :-
 digits(_G2473, _G2513, ['.'|_G2555]),
 digits(_G2478, _G2555, _G2516),
 append(_G2473, ['.'|_G2478], _G2471) .

realNumber2(['.'|_G2583], ['.'|_G2624], _G2610)  :-
 digits(_G2583, _G2624, _G2610) .

realNumber2([-, _G2651|_G2652], [-|_G2698], _G2684)  :-
 digit(_G2651, _G2698, _G2712),
 realNumber2(_G2652, _G2712, _G2684) .

realExponent([_G2747, _G2750|_G2751], [_G2747, _G2750|_G2830], _G2813)  :-
 memberchk(_G2747, ['E', e]),
 memberchk(_G2750, [+, -]),
 digits(_G2751, _G2830, _G2813) .

realExponent([], _G2882, _G2882)  :-
 true .

select(_G2898, [_G2898|_G2938], _G2938)  :-
 memberchk(_G2898, [!, ^, @]) .

select(_G2954, [=, >|_G2989], _G2989)  :-
 pc_atomconcat(=, >, _G2954) .

select(_G3008, [-, >|_G3043], _G3043)  :-
 pc_atomconcat(-, >, _G3008) .

select2(dot, ['.'|_G3082], _G3082)  :-
 true .

select2(bar, [ ('|')|_G3118], _G3118)  :-
 true .

intNumber(_G3134, _G3150, _G3153)  :-
 digits(_G3134, _G3150, _G3153) .

intNumber([-|_G3189], [-|_G3230], _G3216)  :-
 digits(_G3189, _G3230, _G3216) .

assertionString([$], [$|_G3277], _G3277)  :-
 true .

assertionString([_G3293|_G3294], [_G3293|_G3335], _G3321)  :-
 assertionString(_G3294, _G3335, _G3321) .

string(['"'], ['"'|_G3382], _G3382)  :-
 true .

string([\, '"'|_G3402], [\, '"'|_G3452], _G3435)  :-
 string(_G3402, _G3452, _G3435) .

string([_G3476|_G3477], [\, _G3476|_G3544], _G3527)  :-
 memberchk(_G3476, [$, \]),
 string(_G3477, _G3544, _G3527) .

string([_G3571|_G3572], [_G3571|_G3613], _G3599)  :-
 string(_G3572, _G3613, _G3599) .

comment(['(', *|_G3671], _G3658)  :-
 ignoreChar1(_G3671, _G3658) .

comment(['{'|_G3716], _G3706)  :-
 ignoreChar2(_G3716, _G3706) .

ignoreChar1([*, ')'|_G3759], _G3759)  :-
 ! .

ignoreChar1([_G3774|_G3802], _G3792)  :-
 ignoreChar1(_G3802, _G3792) .

ignoreChar2(['}'|_G3842], _G3842)  :-
 ! .

ignoreChar2([_G3854|_G3882], _G3872)  :-
 ignoreChar2(_G3882, _G3872) .

alphanumeric([_G3899|_G3900], _G3923, _G3926)  :-
 alphachar(_G3899, _G3923, _G3951),
 alphanumeric(_G3900, _G3951, _G3926) .

alphanumeric([_G3986], _G4005, _G4008)  :-
 alphachar(_G3986, _G4005, _G4008) .

alphachar(_G4043, _G4059, _G4062)  :-
 character(_G4043, _G4059, _G4062) .

alphachar(_G4097, _G4113, _G4116)  :-
 digit(_G4097, _G4113, _G4116) .

digits([_G4151|_G4152], _G4175, _G4178)  :-
 digit(_G4151, _G4175, _G4203),
 digits(_G4152, _G4203, _G4178) .

digits([_G4238], _G4257, _G4260)  :-
 digit(_G4238, _G4257, _G4260) .

digit(_G4295, [_G4295|_G4332], _G4332)  :-
 '0'@=<_G4295,
 _G4295@=<'9' .

character(_G4351, [_G4351|_G4388], _G4388)  :-
 'A'@=<_G4351,
 _G4351@=<'Z' .

character(_G4407, [_G4407|_G4444], _G4444)  :-
 a@=<_G4407,
 _G4407@=<z .

character(_G4463, [_G4463|_G4575], _G4575)  :-
 pc_ascii(_G4463, _G4469),
 memberchk(_G4469, [228, 246, 252, 223, 196, 214, 220, 225, 233, 243, 250, 224, 232, 242, 249, 226, 234, 244, 251, 235, 239, 238, 236, 241, 209]) .

character(_G4594, [_G4594|_G4643], _G4643)  :-
 pc_ascii(_G4594, _G4600),
 memberchk(_G4600, [128, 134, 135, 143]) .

character(_G4662, [_G4662|_G4711], _G4711)  :-
 pc_ascii(_G4662, _G4668),
 memberchk(_G4668, [95, 185, 178, 179]) .

printableChar(_G4730, [_G4730|_G4773], _G4773)  :-
 pc_ascii(_G4730, _G4736),
 _G4736>30,
 _G4736=<254 .

delimiter([\, =, =], [\, =, =|_G4830], _G4830)  :-
 true .

delimiter([\, =], [\, =|_G4881], _G4881)  :-
 true .

delimiter([=, '.', '.'], [=, '.', '.'|_G4935], _G4935)  :-
 true .

delimiter([=, =, >], [=, =, >|_G4992], _G4992)  :-
 true .

delimiter([<, =, =, >], [<, =, =, >|_G5055], _G5055)  :-
 true .

delimiter([=, =], [=, =|_G5109], _G5109)  :-
 true .

delimiter([=, >], [=, >|_G5157], _G5157)  :-
 true .

delimiter([=, <], [=, <|_G5205], _G5205)  :-
 true .

delimiter([>, =], [>, =|_G5253], _G5253)  :-
 true .

delimiter([<, =], [<, =|_G5301], _G5301)  :-
 true .

delimiter([<, >], [<, >|_G5349], _G5349)  :-
 true .

delimiter([_G5368], [_G5368|_G5420], _G5420)  :-
 memberchk(_G5368, ['(', ')', '[', ']', '{', '}']) .

delimiter([_G5436], [_G5436|_G5494], _G5494)  :-
 memberchk(_G5436, [ (','), (;), :, =, &, '_', >, <]) .

delimiter([_G5510], [_G5510|_G5544], _G5544)  :-
 pc_ascii(_G5510, 96) .

delimiter([_G5560], [_G5560|_G5606], _G5606)  :-
 memberchk(_G5560, [+, -, *, /]) .

delimiter([#], [#|_G5645], _G5645)  :-
 true .

blanksorcomment(_G5681, _G5684)  :-
 comment(_G5681, _G5702),
 !,
 blanksorcomment(_G5702, _G5684) .

blanksorcomment(_G5749, _G5752)  :-
 blanks(_G5749, _G5770),
 !,
 blanksorcomment(_G5770, _G5752) .

blanksorcomment(_G5811, _G5811)  :-
 ! .

blanks(_G5835, _G5838)  :-
 blankchar(_G5835, _G5856),
 blanks(_G5856, _G5838) .

blanks(_G5889, _G5892)  :-
 blankchar(_G5889, _G5892) .

blankchar([_G5916|_G5960], _G5960)  :-
 pc_ascii(_G5916, _G5920),
 memberchk(_G5920, [32, 9, 10, 13]) .
