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

token(ident(_G774), _G806, _G809)  :-
 identifier(_G778, _G806, _G809),
 transformIdentifier(_G778, _G774),
 ! .

token(ident(_G850), _G882, _G885)  :-
 implicit_var(_G854, _G882, _G885),
 pc_atomconcat(_G854, _G850),
 ! .

token(ident(_G926), ['\''|_G981], _G967)  :-
 specialIdentifier(_G933, _G981, _G967),
 pc_atomconcat(_G933, _G926),
 ! .

token(realNumber(_G1011), _G1043, _G1046)  :-
 realNumber(_G1015, _G1043, _G1046),
 pc_atomconcat(_G1015, _G1011),
 ! .

token(intNumber(_G1087), _G1119, _G1122)  :-
 intNumber(_G1091, _G1119, _G1122),
 pc_atomconcat(_G1091, _G1087),
 ! .

token(select(_G1163), _G1189, _G1192)  :-
 select(_G1163, _G1189, _G1192),
 ! .

token(select2(_G1230), _G1256, _G1259)  :-
 select2(_G1230, _G1256, _G1259),
 ! .

token(assertion(_G1297), [$|_G1355], _G1341)  :-
 assertionString(_G1304, _G1355, _G1341),
 pc_atomconcat([$|_G1304], _G1297),
 ! .

token(string(_G1385), ['"'|_G1443], _G1429)  :-
 string(_G1392, _G1443, _G1429),
 pc_atomconcat(['"'|_G1392], _G1385),
 ! .

token(_G1473, _G1503, _G1506)  :-
 delimiter(_G1475, _G1503, _G1506),
 pc_atomconcat(_G1475, _G1473),
 ! .

token(_G1547, [_G1549|_G1588], _G1588)  :-
 report_error(tokensSYNERR2, tokens_dcg, [_G1549]),
 !,
 fail .

identifier([_G1610|_G1611], _G1634, _G1637)  :-
 character(_G1610, _G1634, _G1662),
 alphanumeric(_G1611, _G1662, _G1637) .

identifier([_G1697], _G1716, _G1719)  :-
 character(_G1697, _G1716, _G1719) .

identifier([_G1754|_G1755], _G1778, _G1781)  :-
 digit(_G1754, _G1778, _G1806),
 nonInteger(_G1755, _G1806, _G1781) .

nonInteger([_G1841|_G1842], _G1865, _G1868)  :-
 digit(_G1841, _G1865, _G1893),
 nonInteger(_G1842, _G1893, _G1868) .

nonInteger([_G1928|_G1929], _G1952, _G1955)  :-
 character(_G1928, _G1952, _G1980),
 alphanumeric(_G1929, _G1980, _G1955) .

nonInteger([_G2015], _G2034, _G2037)  :-
 character(_G2015, _G2034, _G2037) .

specialIdentifier([], ['\''|_G2092], _G2092)  :-
 true .

specialIdentifier([_G2108|_G2109], _G2132, _G2135)  :-
 printableChar(_G2108, _G2132, _G2160),
 specialIdentifier(_G2109, _G2160, _G2135) .

implicit_var([~|_G2196], [~|_G2237], _G2223)  :-
 identifier(_G2196, _G2237, _G2223) .

implicit_var([~|_G2262], [~, '"'|_G2326], _G2309)  :-
 string(_G2272, _G2326, _G2309),
 pc_atomconcat(['"'|_G2272], _G2262),
 ! .

realNumber(_G2356, _G2389, _G2392)  :-
 realNumber2(_G2358, _G2389, _G2417),
 realExponent(_G2360, _G2417, _G2392),
 append(_G2358, _G2360, _G2356) .

realNumber2(_G2455, _G2497, _G2500)  :-
 digits(_G2457, _G2497, ['.'|_G2539]),
 digits(_G2462, _G2539, _G2500),
 append(_G2457, ['.'|_G2462], _G2455) .

realNumber2(['.'|_G2567], ['.'|_G2608], _G2594)  :-
 digits(_G2567, _G2608, _G2594) .

realNumber2([-, _G2635|_G2636], [-|_G2682], _G2668)  :-
 digit(_G2635, _G2682, _G2696),
 realNumber2(_G2636, _G2696, _G2668) .

realExponent([_G2731, _G2734|_G2735], [_G2731, _G2734|_G2814], _G2797)  :-
 memberchk(_G2731, ['E', e]),
 memberchk(_G2734, [+, -]),
 digits(_G2735, _G2814, _G2797) .

realExponent([], _G2866, _G2866)  :-
 true .

select(_G2882, [_G2882|_G2922], _G2922)  :-
 memberchk(_G2882, [!, ^, @]) .

select(_G2938, [=, >|_G2973], _G2973)  :-
 pc_atomconcat(=, >, _G2938) .

select(_G2992, [-, >|_G3027], _G3027)  :-
 pc_atomconcat(-, >, _G2992) .

select2(dot, ['.'|_G3066], _G3066)  :-
 true .

select2(bar, [ ('|')|_G3102], _G3102)  :-
 true .

intNumber(_G3118, _G3134, _G3137)  :-
 digits(_G3118, _G3134, _G3137) .

intNumber([-|_G3173], [-|_G3214], _G3200)  :-
 digits(_G3173, _G3214, _G3200) .

assertionString([$], [$|_G3261], _G3261)  :-
 true .

assertionString([_G3277|_G3278], [_G3277|_G3319], _G3305)  :-
 assertionString(_G3278, _G3319, _G3305) .

string(['"'], ['"'|_G3366], _G3366)  :-
 true .

string([\, '"'|_G3386], [\, '"'|_G3436], _G3419)  :-
 string(_G3386, _G3436, _G3419) .

string([_G3460|_G3461], [\, _G3460|_G3528], _G3511)  :-
 memberchk(_G3460, [$, \]),
 string(_G3461, _G3528, _G3511) .

string([_G3555|_G3556], [_G3555|_G3597], _G3583)  :-
 string(_G3556, _G3597, _G3583) .

comment(['(', *|_G3655], _G3642)  :-
 ignoreChar1(_G3655, _G3642) .

comment(['{'|_G3700], _G3690)  :-
 ignoreChar2(_G3700, _G3690) .

ignoreChar1([*, ')'|_G3743], _G3743)  :-
 ! .

ignoreChar1([_G3758|_G3786], _G3776)  :-
 ignoreChar1(_G3786, _G3776) .

ignoreChar2(['}'|_G3826], _G3826)  :-
 ! .

ignoreChar2([_G3838|_G3866], _G3856)  :-
 ignoreChar2(_G3866, _G3856) .

alphanumeric([_G3883|_G3884], _G3907, _G3910)  :-
 alphachar(_G3883, _G3907, _G3935),
 alphanumeric(_G3884, _G3935, _G3910) .

alphanumeric([_G3970], _G3989, _G3992)  :-
 alphachar(_G3970, _G3989, _G3992) .

alphachar(_G4027, _G4043, _G4046)  :-
 character(_G4027, _G4043, _G4046) .

alphachar(_G4081, _G4097, _G4100)  :-
 digit(_G4081, _G4097, _G4100) .

digits([_G4135|_G4136], _G4159, _G4162)  :-
 digit(_G4135, _G4159, _G4187),
 digits(_G4136, _G4187, _G4162) .

digits([_G4222], _G4241, _G4244)  :-
 digit(_G4222, _G4241, _G4244) .

digit(_G4279, [_G4279|_G4316], _G4316)  :-
 '0'@=<_G4279,
 _G4279@=<'9' .

character(_G4335, [_G4335|_G4372], _G4372)  :-
 'A'@=<_G4335,
 _G4335@=<'Z' .

character(_G4391, [_G4391|_G4428], _G4428)  :-
 a@=<_G4391,
 _G4391@=<z .

character(_G4447, [_G4447|_G4559], _G4559)  :-
 pc_ascii(_G4447, _G4453),
 memberchk(_G4453, [228, 246, 252, 223, 196, 214, 220, 225, 233, 243, 250, 224, 232, 242, 249, 226, 234, 244, 251, 235, 239, 238, 236, 241, 209]) .

character(_G4578, [_G4578|_G4627], _G4627)  :-
 pc_ascii(_G4578, _G4584),
 memberchk(_G4584, [128, 134, 135, 143]) .

character(_G4646, [_G4646|_G4695], _G4695)  :-
 pc_ascii(_G4646, _G4652),
 memberchk(_G4652, [95, 185, 178, 179]) .

printableChar(_G4714, [_G4714|_G4757], _G4757)  :-
 pc_ascii(_G4714, _G4720),
 _G4720>30,
 _G4720=<254 .

delimiter([\, =, =], [\, =, =|_G4814], _G4814)  :-
 true .

delimiter([\, =], [\, =|_G4865], _G4865)  :-
 true .

delimiter([=, '.', '.'], [=, '.', '.'|_G4919], _G4919)  :-
 true .

delimiter([=, =, >], [=, =, >|_G4976], _G4976)  :-
 true .

delimiter([<, =, =, >], [<, =, =, >|_G5039], _G5039)  :-
 true .

delimiter([=, =], [=, =|_G5093], _G5093)  :-
 true .

delimiter([=, >], [=, >|_G5141], _G5141)  :-
 true .

delimiter([=, <], [=, <|_G5189], _G5189)  :-
 true .

delimiter([>, =], [>, =|_G5237], _G5237)  :-
 true .

delimiter([<, =], [<, =|_G5285], _G5285)  :-
 true .

delimiter([<, >], [<, >|_G5333], _G5333)  :-
 true .

delimiter([_G5352], [_G5352|_G5404], _G5404)  :-
 memberchk(_G5352, ['(', ')', '[', ']', '{', '}']) .

delimiter([_G5420], [_G5420|_G5478], _G5478)  :-
 memberchk(_G5420, [ (','), (;), :, =, &, '_', >, <]) .

delimiter([_G5494], [_G5494|_G5528], _G5528)  :-
 pc_ascii(_G5494, 96) .

delimiter([_G5544], [_G5544|_G5590], _G5590)  :-
 memberchk(_G5544, [+, -, *, /]) .

delimiter([#], [#|_G5629], _G5629)  :-
 true .

blanksorcomment(_G5665, _G5668)  :-
 comment(_G5665, _G5686),
 !,
 blanksorcomment(_G5686, _G5668) .

blanksorcomment(_G5733, _G5736)  :-
 blanks(_G5733, _G5754),
 !,
 blanksorcomment(_G5754, _G5736) .

blanksorcomment(_G5795, _G5795)  :-
 ! .

blanks(_G5819, _G5822)  :-
 blankchar(_G5819, _G5840),
 blanks(_G5840, _G5822) .

blanks(_G5873, _G5876)  :-
 blankchar(_G5873, _G5876) .

blankchar([_G5900|_G5944], _G5944)  :-
 pc_ascii(_G5900, _G5904),
 memberchk(_G5904, [32, 9, 10, 13]) .
