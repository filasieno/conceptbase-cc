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


:- style_check(-singleton) .

buildTokens(_3910,_3954,_3956)  :-
 blanksorcomment(_3954,_4010),
 buildTokens2(_3910,_4010,_3956),
 ! .

buildTokens2([_4104|_4106],_4164,_4166)  :-
 token(_4104,_4164,_4220),
 blanksorcomment(_4220,_4274),
 buildTokens(_4106,_4274,_4166),
 ! .

buildTokens2([],_4394,_4394)  :-
 ! .

token(ident(_4448),_4502,_4504)  :-
 identifier(_4456,_4502,_4504),
 transformIdentifier(_4456,_4448),
 ! .

token(ident(_4616),_4670,_4672)  :-
 implicit_var(_4624,_4670,_4672),
 pc_atomconcat(_4624,_4616),
 ! .

token(ident(_4784),['\''|_4902],_4854)  :-
 specialIdentifier(_4800,_4902,_4854),
 pc_atomconcat(_4800,_4784),
 ! .

token(realNumber(_4974),_5028,_5030)  :-
 realNumber(_4982,_5028,_5030),
 pc_atomconcat(_4982,_4974),
 ! .

token(intNumber(_5142),_5196,_5198)  :-
 intNumber(_5150,_5196,_5198),
 pc_atomconcat(_5150,_5142),
 ! .

token(select(_5310),_5352,_5354)  :-
 select(_5310,_5352,_5354),
 ! .

token(select2(_5460),_5502,_5504)  :-
 select2(_5460,_5502,_5504),
 ! .

token(assertion(_5610),[$|_5736],_5688)  :-
 assertionString(_5626,_5736,_5688),
 pc_atomconcat([$|_5626],_5610),
 ! .

token(string(_5808),['"'|_5934],_5886)  :-
 string(_5824,_5934,_5886),
 pc_atomconcat(['"'|_5824],_5808),
 ! .

token(_6006,_6056,_6058)  :-
 delimiter(_6010,_6056,_6058),
 pc_atomconcat(_6010,_6006),
 ! .

token(_6170,[_6176|_6242],_6242)  :-
 report_error(tokensSYNERR2,tokens_dcg,[_6176]),
 !,
 fail .

identifier([_6316|_6318],_6352,_6354)  :-
 character(_6316,_6352,_6408),
 alphanumeric(_6318,_6408,_6354) .

identifier([_6508],_6534,_6536)  :-
 character(_6508,_6534,_6536) .

identifier([_6636|_6638],_6672,_6674)  :-
 digit(_6636,_6672,_6728),
 nonInteger(_6638,_6728,_6674) .

nonInteger([_6828|_6830],_6864,_6866)  :-
 digit(_6828,_6864,_6920),
 nonInteger(_6830,_6920,_6866) .

nonInteger([_7020|_7022],_7056,_7058)  :-
 character(_7020,_7056,_7112),
 alphanumeric(_7022,_7112,_7058) .

nonInteger([_7212],_7238,_7240)  :-
 character(_7212,_7238,_7240) .

specialIdentifier([],['\''|_7364],_7364)  :-
 true .

specialIdentifier([_7424|_7426],_7460,_7462)  :-
 printableChar(_7424,_7460,_7516),
 specialIdentifier(_7426,_7516,_7462) .

implicit_var([~|_7618],[~|_7706],_7658)  :-
 identifier(_7618,_7706,_7658) .

implicit_var([~|_7768],[~,'"'|_7900],_7852)  :-
 string(_7790,_7900,_7852),
 pc_atomconcat(['"'|_7790],_7768),
 ! .

realNumber(_7978,_8034,_8036)  :-
 realNumber2(_7982,_8034,_8090),
 realExponent(_7986,_8090,_8036),
 append(_7982,_7986,_7978) .

realNumber2(_8196,_8274,_8276)  :-
 digits(_8200,_8274,['.'|_8378]),
 digits(_8212,_8378,_8276),
 append(_8200,['.'|_8212],_8196) .

realNumber2(['.'|_8448],['.'|_8536],_8488)  :-
 digits(_8448,_8536,_8488) .

realNumber2([-,_8602|_8604],[-|_8702],_8654)  :-
 digit(_8602,_8702,_8716),
 realNumber2(_8604,_8716,_8654) .

realExponent([_8816,_8822|_8824],[_8816,_8822|_8998],_8942)  :-
 memberchk(_8816,['E',e]),
 memberchk(_8822,[+,-]),
 digits(_8824,_8998,_8942) .

realExponent([],_9106,_9106)  :-
 true .

select(_9160,[_9160|_9230],_9230)  :-
 memberchk(_9160,[!,^,@]) .

select(_9290,[=,>|_9348],_9348)  :-
 pc_atomconcat(=,>,_9290) .

select(_9414,[-,>|_9472],_9472)  :-
 pc_atomconcat(-,>,_9414) .

select2(dot,['.'|_9564],_9564)  :-
 true .

select2(bar,['|'|_9648],_9648)  :-
 true .

intNumber(_9706,_9726,_9728)  :-
 digits(_9706,_9726,_9728) .

intNumber([-|_9830],[-|_9918],_9870)  :-
 digits(_9830,_9918,_9870) .

assertionString([$],[$|_10010],_10010)  :-
 true .

assertionString([_10070|_10072],[_10070|_10160],_10112)  :-
 assertionString(_10072,_10160,_10112) .

string(['"'],['"'|_10252],_10252)  :-
 true .

string([\,'"'|_10320],[\,'"'|_10430],_10374)  :-
 string(_10320,_10430,_10374) .

string([_10490|_10492],[\,_10490|_10640],_10584)  :-
 memberchk(_10490,[$,\]),
 string(_10492,_10640,_10584) .

string([_10710|_10712],[_10710|_10800],_10752)  :-
 string(_10712,_10800,_10752) .

comment(['(',*|_10926],_10892)  :-
 ignoreChar1(_10926,_10892) .

comment(['{'|_11038],_11004)  :-
 ignoreChar2(_11038,_11004) .

ignoreChar1([*,')'|_11128],_11128)  :-
 ! .

ignoreChar1([_11182|_11242],_11208)  :-
 ignoreChar1(_11242,_11208) .

ignoreChar2(['}'|_11326],_11326)  :-
 ! .

ignoreChar2([_11374|_11434],_11400)  :-
 ignoreChar2(_11434,_11400) .

alphanumeric([_11480|_11482],_11516,_11518)  :-
 alphachar(_11480,_11516,_11572),
 alphanumeric(_11482,_11572,_11518) .

alphanumeric([_11672],_11698,_11700)  :-
 alphachar(_11672,_11698,_11700) .

alphachar(_11798,_11818,_11820)  :-
 character(_11798,_11818,_11820) .

alphachar(_11918,_11938,_11940)  :-
 digit(_11918,_11938,_11940) .

digits([_12040|_12042],_12076,_12078)  :-
 digit(_12040,_12076,_12132),
 digits(_12042,_12132,_12078) .

digits([_12232],_12258,_12260)  :-
 digit(_12232,_12258,_12260) .

digit(_12358,[_12358|_12420],_12420)  :-
 '0'@=<_12358,
 _12358@=<'9' .

character(_12486,[_12486|_12548],_12548)  :-
 'A'@=<_12486,
 _12486@=<'Z' .

character(_12614,[_12614|_12676],_12676)  :-
 a@=<_12614,
 _12614@=<z .

character(_12742,[_12742|_12956],_12956)  :-
 pc_ascii(_12742,_12758),
 memberchk(_12758,[228,246,252,223,196,214,220,225,233,243,250,224,232,242,249,226,234,244,251,235,239,238,236,241,209]) .

character(_13022,[_13022|_13110],_13110)  :-
 pc_ascii(_13022,_13038),
 memberchk(_13038,[128,134,135,143]) .

character(_13176,[_13176|_13264],_13264)  :-
 pc_ascii(_13176,_13192),
 memberchk(_13192,[95,185,178,179]) .

printableChar(_13330,[_13330|_13404],_13404)  :-
 pc_ascii(_13330,_13346),
 _13346>30,
 _13346=<254 .

delimiter([\,=,=],[\,=,=|_13534],_13534)  :-
 true .

delimiter([\,=],[\,=|_13650],_13650)  :-
 true .

delimiter([=,'.','.'],[=,'.','.'|_13772],_13772)  :-
 true .

delimiter([=,=,>],[=,=,>|_13900],_13900)  :-
 true .

delimiter([<,=,=,>],[<,=,=,>|_14040],_14040)  :-
 true .

delimiter([=,=],[=,=|_14162],_14162)  :-
 true .

delimiter([=,>],[=,>|_14272],_14272)  :-
 true .

delimiter([=,<],[=,<|_14382],_14382)  :-
 true .

delimiter([>,=],[>,=|_14492],_14492)  :-
 true .

delimiter([<,=],[<,=|_14602],_14602)  :-
 true .

delimiter([<,>],[<,>|_14712],_14712)  :-
 true .

delimiter([_14778],[_14778|_14872],_14872)  :-
 memberchk(_14778,['(',')','[',']','{','}']) .

delimiter([_14934],[_14934|_15040],_15040)  :-
 memberchk(_14934,[',',;,:,=,&,'_',>,<]) .

delimiter([_15102],[_15102|_15158],_15158)  :-
 pc_ascii(_15102,96) .

delimiter([_15220],[_15220|_15302],_15302)  :-
 memberchk(_15220,[+,-,*,/]) .

delimiter([#],[#|_15396],_15396)  :-
 true .

blanksorcomment(_15490,_15492)  :-
 comment(_15490,_15532),
 !,
 blanksorcomment(_15532,_15492) .

blanksorcomment(_15648,_15650)  :-
 blanks(_15648,_15690),
 !,
 blanksorcomment(_15690,_15650) .

blanksorcomment(_15794,_15794)  :-
 ! .

blanks(_15852,_15854)  :-
 blankchar(_15852,_15894),
 blanks(_15894,_15854) .

blanks(_15976,_15978)  :-
 blankchar(_15976,_15978) .

blankchar([_16050|_16132],_16132)  :-
 pc_ascii(_16050,_16060),
 memberchk(_16060,[32,9,10,13]) .
