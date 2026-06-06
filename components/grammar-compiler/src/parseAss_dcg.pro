% This module named "parseAss_dcg" was automatically generated from the DCG-grammar file "parseAss.dcg".
%
% 	DO NOT EDIT MANUALLY
%

#MODULE(parseAss_dcg)
#EXPORT(buildECArule/3)
#EXPORT(buildMSFOLconstraint/3)
#EXPORT(buildAssertionRule/3)
#EXPORT(buildQuerycall/3)
#EXPORT(convertSelectExpression/3)
#ENDMODDECL()
#IMPORT(reverse/2,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(t_name2id/3,GeneralUtilities)
#IMPORT(member/2,GeneralUtilities)
#IMPORT(memberchk/2,GeneralUtilities)
#IMPORT(eval/4,SelectExpressions)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(VarTabInsert/2,VarTabHandling)
#IMPORT(VarTabVariable/1,VarTabHandling)
#IMPORT(VarTabLookup_vars/1,VarTabHandling)
#IMPORT(metaInfixToLiteral/4,MSFOLassertionParserUtilities)
#IMPORT(infixToLiteral/4,MSFOLassertionParserUtilities)
#IMPORT(explicatedToLiteral/4,MSFOLassertionParserUtilities)
#IMPORT(expandQuantifier/4, MSFOLassertionParserUtilities)
#IMPORT(validConclusion/2,MSFOLassertionParserUtilities)
#IMPORT(resolveDeriveExpression/2,MSFOLassertionParserUtilities)
#IMPORT(resolveDeriveExpression/3,MSFOLassertionParserUtilities)
#IMPORT(createNewVarname/1,QueryCompiler)
#IMPORT(replaceSelectExpB/4,MSFOLassertionParserUtilities)
#IMPORT(replaceSelectExpBList/4,MSFOLassertionParserUtilities)
#IMPORT(report_error/3,ErrorMessages)
#IMPORT(prove_literal/1,Literals)
#IMPORT(create_if_builtin_object/3,FragmentToPropositions)
#IMPORT(makeECAevent/3,ECAruleCompiler)
#IMPORT(makeECAcondition/3,ECAruleCompiler)
#IMPORT(makeECAaction/3,ECAruleCompiler)
#IMPORT(pc_update/1,PrologCompatibility)
#IMPORT(temp_msp/1,MSFOLassertionParserUtilities)
#IMPORT(t_msp/1,MSFOLassertionParserUtilities)
#IMPORT(plainToSubsts/3,MSFOLassertionParserUtilities)
#IMPORT(isFunction/1,validProposition)
#IMPORT(makeAddition/4,MSFOLassertionParserUtilities)
#IMPORT(makeMultiplication/4,MSFOLassertionParserUtilities)
#IMPORT(isVariable/2,MSFOLassertionParserUtilities)
#IMPORT(splitRule/3,MSFOLassertionParserUtilities)
#IMPORT(containsNoReservedWord/1,MSFOLassertionParserUtilities)
#IMPORT(pc_ascii/2,PrologCompatibility)
:- style_check(-singleton) .
buildMSFOLconstraint('MSFOLconstraint'(_5014),_5056,_5058)  :-
 parseDecl(_5014,_5056,_5058),
 ! .

buildAssertionRule('MSFOLrule'(_5164,_5166,_5168),_5332,_5334)  :-
 foralls(_5176,_5178,_5332,_5388),
 'VarTabLookup_vars'(_5164),
 buildAssertionRule2(_5198,_5168,_5388,_5334),
 !,
 (
 _5178==[],
 _5166=_5198;
 _5178\==[],
 append(_5178,[_5198],_5248),
 _5166=and(_5248)),
 validConclusion(_5168,_5164) .

buildAssertionRule2(_5544,_5546,_5598,_5600)  :-
 exp(_5550,_5598,_5600),
 !,
 splitRule(_5550,_5544,_5546) .

buildAssertionTerm('MSFOLassertion'(_5726),_5768,_5770)  :-
 parseDecl(_5726,_5768,_5770),
 ! .
buildAssertionTerm('MSFOLassertion'(_5876),_5918,_5920)  :-
 exp(_5876,_5918,_5920),
 ! .

shortConclusion(lit(_6026),_6050,_6052)  :-
 lit(_6026,_6050,_6052) .
shortConclusion(lit(_6150),['('|_6252],_6204)  :-
 lit(_6150,_6252,[')'|_6204]),
 true .

parseDecl(_6324,_6362,_6364)  :-
 exp(_6324,_6362,_6364),
 ! .

exp(_6470,_6556,_6558)  :-
 elemexp(_6474,_6556,_6612),
 andexp(_6474,_6480,_6612,_6666),
 orexp(_6480,_6486,_6666,_6734),
 implexp(_6486,_6492,_6734,_6802),
 equivexp(_6492,_6470,_6802,_6558),
 ! .

elemexp(_6936,[ident(forall)|_7130],_7082)  :-
 vartypelist(_6952,_6954,_7130,_7144),
 (
 _6954==[],
 expandQuantifier(forall,_6952,_6970,_6936);
 _6954\==[],
 append(_6954,[_6970],_7000),
 expandQuantifier(forall,_6952,and(_7000),_6936)),
 exp(_6970,_7144,_7082) .
elemexp(_7266,[ident(exists)|_7460],_7412)  :-
 vartypelist(_7282,_7284,_7460,_7474),
 (
 _7284==[],
 expandQuantifier(exists,_7282,_7300,_7266);
 _7284\==[],
 append(_7284,[_7300],_7330),
 expandQuantifier(exists,_7282,and(_7330),_7266)),
 exp(_7300,_7474,_7412) .
elemexp(not(_7596),[ident(not)|_7688],_7640)  :-
 elemexp(_7596,_7688,_7640) .
elemexp(_7746,['('|_7844],_7796)  :-
 exp(_7746,_7844,[')'|_7796]),
 true .
elemexp(lit(_7916),_7940,_7942)  :-
 lit(_7916,_7940,_7942) .
elemexp(_8040,_8060,_8062)  :-
 elemSelectExpB(_8040,_8060,_8062) .

vartypelist([_8162|_8164],_8170,_8236,_8238)  :-
 vartype(_8162,_8176,_8236,_8306),
 optvartypelist(_8164,_8182,_8306,_8238),
 !,
 append(_8176,_8182,_8170) .

optvartypelist(_8446,_8448,_8470,_8472)  :-
 vartypelist(_8446,_8448,_8470,_8472) .
optvartypelist([],[],_8634,_8634)  :-
 true,
 ! .

vartype(vtype(_8708,_8710),_8716,_8808,_8810)  :-
 varlist(_8708,_8808,[/|_8926]),
 selectexpb(_8732,_8926,_8810),
 replaceSelectExpBList(_8732,_8708,_8710,_8716),
 'VarTabInsert'(_8708,[_8710]) .
vartype(vtype(_8998,_9000),[],_9118,_9120)  :-
 varlist(_8998,_9118,[/,'['|_9244]),
 typelist(_9000,_9244,[']'|_9120]),
 'VarTabInsert'(_8998,_9000),
 !,
 containsNoReservedWord(_8998) .
vartype(vtype(_9330,_9332),[],_9430,_9432)  :-
 varlist(_9330,_9430,[/|_9548]),
 type(_9332,_9548,_9432),
 'VarTabInsert'(_9330,[_9332]),
 !,
 containsNoReservedWord(_9330) .

varlist([_9628|_9630],[ident(_9628),','|_9774],_9718)  :-
 varlist(_9630,_9774,_9718),
 !,
 _9628\=='~this' .
varlist([_9848],[ident(_9848)|_9914],_9914)  :-
 !,
 _9848\=='~this' .

andexp(and_h(_9980),_9986,[ident(and)|_10112],_10050)  :-
 elemexp(_10002,_10112,_10126),
 andexp(and_h([_10002|_9980]),_9986,_10126,_10050) .
andexp(_10238,_10240,[ident(and)|_10372],_10310)  :-
 elemexp(_10256,_10372,_10386),
 andexp(and_h([_10256,_10238]),_10240,_10386,_10310) .
andexp(and_h(_10498),and(_10502),_10542,_10542)  :-
 reverse(_10498,_10502) .
andexp(_10610,_10612,_10646,_10646)  :-
 _10612=_10610 .

orexp(or_h(_10714),_10720,[ident(or)|_10858],_10796)  :-
 elemexp(_10736,_10858,_10872),
 andexp(_10736,_10742,_10872,_10926),
 orexp(or_h([_10742|_10714]),_10720,_10926,_10796) .
orexp(_11052,_11054,[ident(or)|_11198],_11136)  :-
 elemexp(_11070,_11198,_11212),
 andexp(_11070,_11076,_11212,_11266),
 orexp(or_h([_11076,_11052]),_11054,_11266,_11136) .
orexp(or_h(_11392),or(_11396),_11436,_11436)  :-
 reverse(_11392,_11396) .
orexp(_11504,_11506,_11540,_11540)  :-
 _11506=_11504 .

implexp(_11608,_11610,[==>|_11750],_11688)  :-
 elemexp(_11622,_11750,_11764),
 andexp(_11622,_11628,_11764,_11818),
 orexp(_11628,_11634,_11818,_11886),
 implexp(impl(_11608,_11634),_11610,_11886,_11688) .
implexp(_12012,_12014,_12048,_12048)  :-
 _12014=_12012 .

equivexp(_12116,_12118,[<==>|_12294],_12232)  :-
 elemexp(_12130,_12294,_12308),
 andexp(_12130,_12136,_12308,_12362),
 orexp(_12136,_12142,_12362,_12430),
 implexp(_12142,_12148,_12430,_12498),
 equivexp(and([impl(_12116,_12148),impl(_12148,_12116)]),_12118,_12498,_12232) .
equivexp(_12624,_12626,_12660,_12660)  :-
 _12626=_12624 .

lit('Mod'(_12728,_12730),[ident(_12740),select(@),ident(_12808),'('|_13122],_13036)  :-
 memberchk(_12740,['A','A_e','Ai','A2']),
 name2id(_12808,_12730),
 pc_update(t_msp(_12730)),
 litarg(_12858,_13122,[','|_13184]),
 label(_12870,_13184,[','|_13246]),
 litarg(_12882,_13246,[')'|_13036]),
 _12728=..[_12740,_12858,_12870,_12882],
 abolish(t_msp,1) .
lit(_13344,[ident(_13350),'('|_13668],_13596)  :-
 memberchk(_13350,['A','A_e','Ai','A2']),
 'M_SearchSpace'(_13400),
 pc_update(t_msp(_13400)),
 litarg(_13436,_13668,[','|_13730]),
 label(_13448,_13730,[','|_13792]),
 litarg(_13460,_13792,[')'|_13596]),
 _13344=..[_13350,_13436,_13448,_13460],
 abolish(t_msp,1) .
lit('Mod'(_13890,_13892),[ident('AL'),select(@),ident(_13926),'('|_14238],_14156)  :-
 name2id(_13926,_13892),
 pc_update(t_msp(_13892)),
 litarg(_13976,_14238,[','|_14300]),
 label(_13988,_14300,[','|_14362]),
 simplelabel(_14000,_14362,[','|_14424]),
 litarg(_14012,_14424,[')'|_14156]),
 _13890='A_label'(_13976,_13988,_14012,_14000),
 abolish(t_msp,1) .
lit(_14516,[ident('AL'),'('|_14804],_14738)  :-
 'M_SearchSpace'(_14534),
 pc_update(t_msp(_14534)),
 litarg(_14570,_14804,[','|_14866]),
 label(_14582,_14866,[','|_14928]),
 simplelabel(_14594,_14928,[','|_14990]),
 litarg(_14606,_14990,[')'|_14738]),
 _14516='A_label'(_14570,_14582,_14606,_14594),
 abolish(t_msp,1) .
lit(_15082,['('|_15316],_15258)  :-
 'M_SearchSpace'(_15088),
 pc_update(t_msp(_15088)),
 litarg(_15124,_15316,_15330),
 label(_15128,_15330,[/|_15432]),
 simplelabel(_15140,_15432,_15446),
 litarg(_15144,_15446,[')'|_15258]),
 _15082='A_label'(_15124,_15128,_15144,_15140),
 abolish(t_msp,1) .
lit('Mod'(_15578,_15580),[ident(_15590),select(@),ident(_15646),'('|_15908],_15822)  :-
 memberchk(_15590,['In','In2']),
 name2id(_15646,_15580),
 pc_update(t_msp(_15580)),
 litarglist(_15696,_15908,[')'|_15822]),
 _15718=..[_15590|_15696],
 resolveDeriveExpression(_15646,_15718,_15578),
 abolish(t_msp,1) .
lit(_16012,[ident(_16018),'('|_16280],_16210)  :-
 memberchk(_16018,['In','In2']),
 'M_SearchSpace'(_16062),
 pc_update(t_msp(_16062)),
 litarglist(_16098,_16280,[')'|_16210]),
 _16120=..[_16018|_16098],
 resolveDeriveExpression(_16120,_16012),
 abolish(t_msp,1) .
lit('Mod'(_16384,_16386),[ident('Label'),select(@),ident(_16420),'('|_16694],_16612)  :-
 name2id(_16420,_16386),
 pc_update(t_msp(_16386)),
 litarg(_16470,_16694,[','|_16756]),
 label(_16482,_16756,[')'|_16612]),
 _16384=..['Label',_16470,_16482],
 abolish(t_msp,1) .
lit(_16848,[ident('Label'),'('|_17086],_17020)  :-
 'M_SearchSpace'(_16866),
 pc_update(t_msp(_16866)),
 litarg(_16902,_17086,[','|_17148]),
 label(_16914,_17148,[')'|_17020]),
 _16848=..['Label',_16902,_16914] .
lit('Mod'(_17234,_17236),[ident('P'),select(@),ident(_17270),'('|_17604],_17522)  :-
 name2id(_17270,_17236),
 pc_update(t_msp(_17236)),
 litarg(_17320,_17604,[','|_17666]),
 litarg(_17332,_17666,[','|_17728]),
 label(_17344,_17728,[','|_17790]),
 litarg(_17356,_17790,[')'|_17522]),
 _17234=..['P',_17320,_17332,_17344,_17356],
 abolish(t_msp,1) .
lit('Mod'(_17882,_17884),[ident('Pa'),select(@),ident(_17918),'('|_18252],_18170)  :-
 name2id(_17918,_17884),
 pc_update(t_msp(_17884)),
 litarg(_17968,_18252,[','|_18314]),
 litarg(_17980,_18314,[','|_18376]),
 label(_17992,_18376,[','|_18438]),
 litarg(_18004,_18438,[')'|_18170]),
 _17882=..['Pa',_17968,_17980,_17992,_18004],
 abolish(t_msp,1) .
lit(_18530,[ident('P'),'('|_18840],_18774)  :-
 'M_SearchSpace'(_18548),
 pc_update(t_msp(_18548)),
 litarg(_18584,_18840,[','|_18902]),
 litarg(_18596,_18902,[','|_18964]),
 variableOrLabel(_18608,_18964,[','|_19026]),
 litarg(_18620,_19026,[')'|_18774]),
 _18530=..['P',_18584,_18596,_18608,_18620],
 abolish(t_msp,1) .
lit(_19118,[ident('Pa'),'('|_19428],_19362)  :-
 'M_SearchSpace'(_19136),
 pc_update(t_msp(_19136)),
 litarg(_19172,_19428,[','|_19490]),
 litarg(_19184,_19490,[','|_19552]),
 variableOrLabel(_19196,_19552,[','|_19614]),
 litarg(_19208,_19614,[')'|_19362]),
 _19118=..['Pa',_19172,_19184,_19196,_19208],
 abolish(t_msp,1) .
lit('Mod'(_19706,_19708),[ident(_19718),select(@),ident(_19742),'('|_19980],_19898)  :-
 name2id(_19742,_19708),
 pc_update(t_msp(_19708)),
 litarglist(_19792,_19980,[')'|_19898]),
 _19706=..[_19718|_19792],
 abolish(t_msp,1) .
lit(_20072,[ident(_20078),'('|_20344],_20274)  :-
 \+memberchk(_20078,[new,not,forall,exists]),
 'M_SearchSpace'(_20138),
 pc_update(t_msp(_20138)),
 litarglist(_20174,_20344,[')'|_20274]),
 _20072=..[_20078|_20174],
 abolish(t_msp,1) .
lit(_20442,['('|_20736],_20678)  :-
 'M_SearchSpace'(_20448),
 pc_update(t_msp(_20448)),
 litarg1(_20484,_20736,[_20490|_20798]),
 memberchk(_20490,[=,<,>,=<,<=,>=,<>,\=]),
 !,
 litarg1(_20570,_20798,[')'|_20678]),
 infixToLiteral(_20442,_20484,_20490,_20570),
 !,
 abolish(t_msp,1) .
lit(_20918,['('|_21132],_21074)  :-
 'M_SearchSpace'(_20924),
 pc_update(t_msp(_20924)),
 litarg(_20960,_21132,[_20966|_21194]),
 litarg(_20972,_21194,[')'|_21074]),
 infixToLiteral(_20918,_20960,_20966,_20972),
 !,
 abolish(t_msp,1) .
lit(_21292,['('|_21534],_21476)  :-
 'M_SearchSpace'(_21298),
 pc_update(t_msp(_21298)),
 litarg(_21334,_21534,['[',_21348,']'|_21612]),
 litarg(_21362,_21612,[')'|_21476]),
 metaInfixToLiteral(_21292,_21334,_21348,_21362),
 !,
 abolish(t_msp,1) .
lit(_21710,[:,'('|_21960],_21894)  :-
 'M_SearchSpace'(_21716),
 pc_update(t_msp(_21716)),
 litarg(_21760,_21960,[_21766|_22022]),
 litarg(_21772,_22022,[')',:|_21894]),
 explicatedToLiteral(_21710,_21760,_21766,_21772),
 !,
 abolish(t_msp,1) .
lit(_22128,[:,'('|_22420],_22354)  :-
 'M_SearchSpace'(_22134),
 pc_update(t_msp(_22134)),
 litarg(_22178,_22420,[_22184,/,_22200|_22498]),
 litarg(_22206,_22498,[')',:|_22354]),
 explicatedToLiteral(_22128,_22178,[_22184,_22200],_22206),
 !,
 abolish(t_msp,1) .
lit('TRUE',[ident('TRUE')|_22634],_22634)  :-
 true .
lit('FALSE',[ident('FALSE')|_22722],_22722)  :-
 true .

litarglist([_22782|_22784],_22818,_22820)  :-
 litarg(_22782,_22818,_22874),
 litarglist_rest(_22784,_22874,_22820) .

litarglist_rest(_22972,[','|_23074],_23026)  :-
 !,
 litarglist(_22972,_23074,_23026) .
litarglist_rest([],_23170,_23170)  :-
 ! .

litarg(_23224,_23244,_23246)  :-
 constantval(_23224,_23244,_23246) .
litarg(_23344,_23364,_23366)  :-
 deriveExpression(_23344,_23364,_23366) .
litarg(_23464,_23484,_23486)  :-
 selectExpression(_23464,_23484,_23486) .
litarg(_23584,_23604,_23606)  :-
 variableOrObject(_23584,_23604,_23606) .

litarg1(_23704,_23724,_23726)  :-
 constantval(_23704,_23724,_23726) .
litarg1(_23824,_23844,_23846)  :-
 arExpr(_23824,_23844,_23846) .
litarg1(_23944,_23964,_23966)  :-
 deriveExpression(_23944,_23964,_23966) .
litarg1(_24064,_24084,_24086)  :-
 selectExpression(_24064,_24084,_24086) .
litarg1(_24184,_24204,_24206)  :-
 variableOrObject(_24184,_24204,_24206) .

typeExpr(_24304,_24324,_24326)  :-
 constantval(_24304,_24324,_24326) .
typeExpr(_24424,_24444,_24446)  :-
 regularDeriveExpression(_24424,_24444,_24446) .
typeExpr(_24544,_24564,_24566)  :-
 shortQueryCall(_24544,_24564,_24566) .
typeExpr(_24664,_24684,_24686)  :-
 selectExpression(_24664,_24684,_24686) .
typeExpr(_24784,_24804,_24806)  :-
 typename(_24784,_24804,_24806) .

variableOrObject(_24904,[ident(_24910)|_25132],_25132)  :-
 \+memberchk(_24910,['Known',new,'UNIFIES',in,isA,not,'In',forall,exists,'IDENTICAL','Ai']),
 (
 isVariable(_24910,_24904),
 !;
 (
 temp_msp(_25024),
 t_name2id(_25024,_24910,_24904),
 !;
 report_error('PFNFE',parseAss_dcg,[_24910]),
 pc_atomconcat('%%UNKNOWN--',_24910,_24904),
 !)) .

objectname(_25202,[ident(_25208)|_25358],_25358)  :-
 \+memberchk(_25208,['Known',new,'UNIFIES',in,isA,not,'In',forall,exists,'IDENTICAL','Ai']),
 temp_msp(_25304),
 t_name2id(_25304,_25208,_25202),
 ! .

typename(_25436,[ident(_25442)|_25626],_25626)  :-
 (
 \+memberchk(_25442,['Known',new,'UNIFIES',in,isA,not,'In',forall,exists,'IDENTICAL','Ai']),
 temp_msp(_25532),
 t_name2id(_25532,_25442,_25436),
 !;
 report_error('PFNFE',parseAss_dcg,[_25442]),
 !,
 fail) .

constantval(_25686,[realNumber(_25692)|_25742],_25742)  :-
 create_if_builtin_object(_25692,'Real',_25686) .
constantval(_25802,[intNumber(_25808)|_25858],_25858)  :-
 create_if_builtin_object(_25808,'Integer',_25802) .
constantval(_25918,[string(_25924)|_25974],_25974)  :-
 create_if_builtin_object(_25924,'String',_25918) .

assertionval(_26034,[assertion(_26040)|_26100],_26100)  :-
 temp_msp(_26052),
 t_name2id(_26052,_26040,_26034) .

label(_26166,[ident(_26166)|_26250],_26250)  :-
 temp_msp(_26184),
 prove_literal('Mod'('P'(_26194,_26196,_26166,_26200),_26184)),
 ! .
label(_26322,[string(_26322)|_26406],_26406)  :-
 temp_msp(_26340),
 prove_literal('Mod'('P'(_26350,_26352,_26322,_26356),_26340)),
 ! .

variableOrLabel(_26478,[ident(_26484)|_26550],_26550)  :-
 (
 isVariable(_26484,_26478),
 !;
 _26478=_26484) .

simplelabel(_26610,[ident(_26610)|_26640],_26640)  :-
 true .

typelist([_26700|_26702],_26750,_26752)  :-
 type(_26700,_26750,[','|_26854]),
 typelist(_26702,_26854,_26752) .
typelist([_26914],_26940,_26942)  :-
 type(_26914,_26940,_26942) .

type('VAR',[ident('VAR')|_27088],_27088)  :-
 ! .
type(_27148,_27204,_27206)  :-
 'M_SearchSpace'(_27154),
 pc_update(t_msp(_27154)),
 typeExpr(_27148,_27204,_27206) .

deriveExpression(_27326,_27346,_27348)  :-
 listModExpression(_27326,_27346,_27348) .
deriveExpression(_27446,_27466,_27468)  :-
 countExpr(_27446,_27466,_27468) .
deriveExpression(_27566,_27586,_27588)  :-
 shortFunctionCall(_27566,_27586,_27588) .
deriveExpression(_27686,_27706,_27708)  :-
 shortQueryCall(_27686,_27706,_27708) .
deriveExpression(_27806,_27826,_27828)  :-
 regularDeriveExpression(_27806,_27826,_27828) .

regularDeriveExpression(derive(_27926,_27928),[ident(_27938),'['|_28092],_28036)  :-
 dExpList(_27928,_28092,[']'|_28036]),
 temp_msp(_27970),
 t_name2id(_27970,_27938,_27926) .

listModExpression(derive(_28172,_28174),[ident(listModule),'['|_28344],_28288)  :-
 modExpr(_28174,_28344,[']'|_28288]),
 !,
 temp_msp(_28222),
 t_name2id(_28222,listModule,_28172) .

modExpr([substitute(_28432,module)],_28514,_28516)  :-
 modPath(_28432,_28514,[/,ident(module)|_28516]),
 ! .
modExpr([substitute(_28640,module)],_28672,_28674)  :-
 modPath(_28640,_28672,_28674) .

modPath(_28772,_28810,_28812)  :-
 modPathMin(_28772,_28810,_28812),
 ! .
modPath(_28918,_28956,_28958)  :-
 modPathSlash(_28918,_28956,_28958),
 ! .

modPathMin(_29064,[ident(_29070),-|_29224],_29168)  :-
 modPathMin(_29088,_29224,_29168),
 !,
 pc_atomconcat([_29070,-,_29088],_29064) .
modPathMin(_29296,[ident(_29296)|_29326],_29326)  :-
 true .

modPathSlash(_29384,[ident(_29384),/,ident(module)|_29464],_29464)  :-
 ! .
modPathSlash(_29540,[ident(_29546),/|_29700],_29644)  :-
 modPathSlash(_29564,_29700,_29644),
 !,
 pc_atomconcat([_29546,/,_29564],_29540) .
modPathSlash(_29772,[ident(_29772)|_29826],_29826)  :-
 _29772\=module .

countExpr(derive(_29900,[substitute(_29888,class)]),[#|_30026],_29978)  :-
 litarg(_29888,_30026,_29978),
 temp_msp(_29924),
 t_name2id(_29924,'COUNT',_29900) .

shortFunctionCall(derive(_30098,[]),[ident(_30110),'(',')'|_30198],_30198)  :-
 temp_msp(_30138),
 t_name2id(_30138,_30110,_30098) .
shortFunctionCall(derive(_30280,_30282),[ident(_30292),'('|_30470],_30414)  :-
 shortdExpList(_30310,_30470,[')'|_30414]),
 temp_msp(_30324),
 t_name2id(_30324,_30292,_30280),
 isFunction(_30280),
 plainToSubsts(_30280,_30310,_30282) .

shortQueryCall(derive(_30562,_30564),[ident(_30574),'['|_30742],_30686)  :-
 shortdExpList(_30592,_30742,[']'|_30686]),
 temp_msp(_30606),
 t_name2id(_30606,_30574,_30562),
 plainToSubsts(_30562,_30592,_30564) .

arExpr(_30828,_30898,_30900)  :-
 arTerm(_30832,_30898,_30954),
 arAddExpr(add(_30836,_30838),_30954,_30900),
 makeAddition(_30832,_30836,_30838,_30828),
 ! .
arExpr(_31066,_31166,_31168)  :-
 arTerm(_31070,_31166,[intNumber(_31076)|_31168]),
 pc_atomconcat(-,_31090,_31076),
 create_if_builtin_object(_31090,'Integer',_31106),
 makeAddition(_31070,-,_31106,_31066),
 ! .
arExpr(_31300,_31320,_31322)  :-
 arTerm(_31300,_31320,_31322) .

arAddExpr(add(_31420,_31422),_31506,_31508)  :-
 arAddOp(_31420,_31506,_31562),
 arTerm(_31434,_31562,_31616),
 arAddExpr(add(_31438,_31440),_31616,_31508),
 makeAddition(_31434,_31438,_31440,_31422),
 ! .
arAddExpr(add(_31728,_31730),_31764,_31766)  :-
 arAddOp(_31728,_31764,_31820),
 arTerm(_31730,_31820,_31766) .

arTerm(_31918,_31988,_31990)  :-
 arFactor(_31922,_31988,_32044),
 arMultTerm(mult(_31926,_31928),_32044,_31990),
 makeMultiplication(_31922,_31926,_31928,_31918),
 ! .
arTerm(_32156,_32176,_32178)  :-
 arFactor(_32156,_32176,_32178) .

arMultTerm(mult(_32276,_32278),_32362,_32364)  :-
 arMulOp(_32276,_32362,_32418),
 arFactor(_32290,_32418,_32472),
 arMultTerm(mult(_32294,_32296),_32472,_32364),
 makeMultiplication(_32290,_32294,_32296,_32278),
 ! .
arMultTerm(mult(_98,_100),_134,_136)  :-
 arMulOp(_98,_134,_152),
 arFactor(_100,_152,_136) .

arFactor(_208,_246,_248)  :-
 funcExpr(_208,_246,_248),
 ! .
arFactor(_354,_392,_394)  :-
 constantval(_354,_392,_394),
 ! .
arFactor(_500,_520,_522)  :-
 variableOrObject(_500,_520,_522) .
arFactor(_620,['('|_736],_688)  :-
 arExpr(_620,_736,[')'|_688]),
 ! .

arAddOp(+,[+|_836],_836)  :-
 true .
arAddOp(-,[-|_920],_920)  :-
 true .

arMulOp(*,[*|_1004],_1004)  :-
 true .
arMulOp(/,[/|_1088],_1088)  :-
 true .

dExpList([_1148],_1174,_1176)  :-
 dExp(_1148,_1174,_1176) .
dExpList([_1276|_1278],_1326,_1328)  :-
 dExp(_1276,_1326,[','|_1430]),
 dExpList(_1278,_1430,_1328) .

dExp(substitute(_1488,_1490),_1546,_1548)  :-
 litarg(_1488,_1546,[/,ident(_1490)|_1548]),
 true .
dExp(specialize(_1668,_1670),_1726,_1728)  :-
 litarg(_1668,_1726,[:,ident(_1670)|_1728]),
 true .

shortdExpList([_1850],_1876,_1878)  :-
 shortdExp(_1850,_1876,_1878) .
shortdExpList([_1978|_1980],_2028,_2030)  :-
 shortdExp(_1978,_2028,[','|_2132]),
 shortdExpList(_1980,_2132,_2030) .

shortdExp(plainarg(_2190),_2214,_2216)  :-
 litarg(_2190,_2214,_2216) .

funcExpr(derive(_2314,_2316),[ident(_2326),'('|_2504],_2448)  :-
 funcArgList(_2344,_2504,[')'|_2448]),
 temp_msp(_2358),
 t_name2id(_2358,_2326,_2314),
 isFunction(_2314),
 plainToSubsts(_2314,_2344,_2316) .
funcExpr(_2596,_2616,_2618)  :-
 countExpr(_2596,_2616,_2618) .
funcExpr(_2716,_2736,_2738)  :-
 shortFunctionCall(_2716,_2736,_2738) .

funcArgList([_2838],_2864,_2866)  :-
 funcArg(_2838,_2864,_2866) .
funcArgList([_2966|_2968],_3016,_3018)  :-
 funcArg(_2966,_3016,[','|_3120]),
 funcArgList(_2968,_3120,_3018) .

funcArg(plainarg(_3178),_3202,_3204)  :-
 arExpr(_3178,_3202,_3204) .
funcArg(plainarg(_3302),_3326,_3328)  :-
 arFactor(_3302,_3326,_3328) .

selectExpression(_3426,_3538,_3540)  :-
 idorexp(_3430,_3538,[select(_3436)|_3642]),
 idorexp(_3446,_3642,_3656),
 memberchk(_3436,[->,=>]),
 !,
 selectExpression2(_3426,select(_3430,_3436,_3446),_3656,_3540) .
selectExpression(_3790,_3896,_3898)  :-
 idorexp(_3794,_3896,[select(_3800)|_4000]),
 idorexp(_3810,_4000,_4014),
 temp_msp(_3816),
 eval(_3816,select(_3794,_3800,_3810),replaceSelectExpression,_3840),
 selectExpression2(_3790,_3840,_4014,_3898) .
selectExpression(_4148,['('|_4246],_4198)  :-
 selectExpression(_4148,_4246,[')'|_4198]),
 true .

selectExpression2(_4326,select(_4318,_4320,_4322),[select(_4334)|_4572],_4510)  :-
 idorexp(_4344,_4572,_4586),
 memberchk(_4320,[->,=>]),
 memberchk(_4334,[!,^,@]),
 !,
 temp_msp(_4420),
 eval(_4420,select(_4322,_4334,_4344),replaceSelectExpression,_4444),
 selectExpression2(_4326,select(_4318,_4320,_4444),_4586,_4510) .
selectExpression2(_4762,select(_4754,_4756,_4758),[select(_4770)|_5002],_4940)  :-
 idorexp(_4780,_5002,_5016),
 memberchk(_4756,[->,=>]),
 memberchk(_4770,[->,=>]),
 !,
 temp_msp(_4850),
 eval(_4850,select(_4754,_4756,_4758),replaceSelectExpression,_4874),
 selectExpression2(_4762,select(_4874,_4770,_4780),_5016,_4940) .
selectExpression2(_5184,_5186,[select(_5192)|_5352],_5290)  :-
 memberchk(_5192,[->,=>]),
 !,
 idorexp(_5240,_5352,_5376),
 selectExpression2(_5184,select(_5186,_5192,_5240),_5376,_5290) .
selectExpression2(_5500,_5502,[select(_5508)|_5662],_5600)  :-
 idorexp(_5518,_5662,_5676),
 temp_msp(_5524),
 eval(_5524,select(_5502,_5508,_5518),replaceSelectExpression,_5548),
 selectExpression2(_5500,_5548,_5676,_5600) .
selectExpression2(_5818,select(_5810,_5812,_5814),_5882,_5882)  :-
 !,
 temp_msp(_5832),
 eval(_5832,select(_5810,_5812,_5814),replaceSelectExpression,_5818) .
selectExpression2(_5962,_5964,_5998,_5998)  :-
 _5962=_5964 .

idorexp(_6066,_6086,_6088)  :-
 label(_6066,_6086,_6088) .
idorexp(_6186,[intNumber(_6186)|_6216],_6216)  :-
 true .
idorexp(_6274,[realNumber(_6274)|_6304],_6304)  :-
 true .
idorexp(_6362,[string(_6362)|_6392],_6392)  :-
 true .
idorexp(_6450,[assertion(_6450)|_6480],_6480)  :-
 true .
idorexp(_6538,['('|_6636],_6588)  :-
 selectExpression(_6538,_6636,[')'|_6588]),
 true .

elemSelectExpB(_6708,_6830,_6832)  :-
 litarg(_6712,_6830,[ident(in)|_6934]),
 selectexpb(_6728,_6934,_6832),
 !,
 replaceSelectExpB(_6728,_6712,_6744,_6746),
 _6708=and([lit('In'(_6712,_6744)),_6746]) .
elemSelectExpB(_7012,_7192,_7194)  :-
 selectexpb(_7016,_7192,[ident(isA)|_7296]),
 selectexpb(_7032,_7296,_7194),
 !,
 createNewVarname(_7044),
 replaceSelectExpB(_7016,_7044,_7058,_7060),
 replaceSelectExpB(_7032,_7044,_7074,_7076),
 'VarTabInsert'([_7044],[_7058]),
 expandQuantifier(forall,vtype([_7044],[_7058]),impl(_7060,_7076),_7012) .
elemSelectExpB(_7392,_7592,_7594)  :-
 selectexpb(_7396,_7592,[=|_7696]),
 selectexpb(_7408,_7696,_7594),
 !,
 createNewVarname(_7420),
 replaceSelectExpB(_7396,_7420,_7434,_7436),
 replaceSelectExpB(_7408,_7420,_7450,_7452),
 'VarTabInsert'([_7420],[_7434]),
 expandQuantifier(forall,vtype([_7420],[_7434]),and([impl(_7436,_7452),impl(_7452,_7436)]),_7392) .

selectexpb(selectExpB(_7792,_7794,_7796),[ident(_7792),select2(_7794)|_7914],_7858)  :-
 selectexpb2(_7796,_7914,_7858) .
selectexpb(selectExpB(_7972,_7974,_7976),[ident(_7972),select2(_7974)|_8094],_8038)  :-
 restriction(_7976,_8094,_8038) .
selectexpb(selectExpB(_8152,_8154,_8156),[ident(_8152),select2(_8154),ident(_8156)|_8226],_8226)  :-
 true .

selectexpb2(_8300,_8320,_8322)  :-
 selectexpb(_8300,_8320,_8322) .
selectexpb2(selectExpB(_8420,_8422,_8424),_8476,_8478)  :-
 restriction(_8420,_8476,[select2(_8422)|_8580]),
 selectexpb2(_8424,_8580,_8478) .
selectexpb2(selectExpB(_8638,_8640,_8642),_8694,_8696)  :-
 restriction(_8638,_8694,[select2(_8640)|_8798]),
 restriction(_8642,_8798,_8696) .
selectexpb2(selectExpB(_8856,_8858,_8860),_8920,_8922)  :-
 restriction(_8856,_8920,[select2(_8858),ident(_8860)|_8922]),
 true .

restriction(restriction(_9042,_9044),['(',ident(_9042),:,ident(_9044),')'|_9138],_9138)  :-
 true .
restriction(restriction(_9228,_9230),['(',ident(_9228),:|_9380],_9316)  :-
 selectExpression(_9230,_9380,[')'|_9316]),
 true .
restriction(restriction(_9452,_9454),['(',ident(_9452),:|_9604],_9540)  :-
 selectexpb(_9454,_9604,[')'|_9540]),
 true .
restriction(restriction(_9680,enumeration(_9676)),['(',ident(_9680),:,'['|_9868],_9796)  :-
 enumeration(_9676,_9868,[']',')'|_9796]),
 true .

enumeration([class(_9950)],_9980,_9982)  :-
 litarg(_9950,_9980,_9982) .
enumeration([class(_10082)],_10112,_10114)  :-
 selectExpression(_10082,_10112,_10114) .
enumeration(_10212,_10294,_10296)  :-
 litarg(_10216,_10294,[','|_10398]),
 enumeration(_10228,_10398,_10296),
 append([class(_10216)],_10228,_10212) .
enumeration(_10464,_10546,_10548)  :-
 selectExpression(_10468,_10546,[','|_10650]),
 enumeration(_10480,_10650,_10548),
 append([class(_10468)],_10480,_10464) .

foralls(_10716,_10718,_10792,_10794)  :-
 forall(_10722,_10724,_10792,_10862),
 foralls(_10728,_10730,_10862,_10794),
 append(_10722,_10728,_10716),
 append(_10724,_10730,_10718) .
foralls([],[],_11032,_11032)  :-
 true .

forall(_11100,_11102,[ident(forall)|_11206],_11144)  :-
 vartypelist(_11100,_11102,_11206,_11144) .

buildECArule(ecarule(_11278,_11280,_11282,_11284,_11286),_11352,_11354)  :-
 optvartypelist(_11294,[],_11352,[ident('ON')|_11470]),
 buildECAruleHelper(ecarule(_11278,_11280,_11282,_11284,_11286),_11470,_11354) .

buildECAruleHelper(ecarule(_11536,true,_11540,[noop],currentqueue),_11596,_11598)  :-
 buildECAevent(_11536,_11596,[ident('DO')|_11700]),
 buildECAactionList(_11540,_11700,_11598) .
buildECAruleHelper(ecarule(_11758,_11760,_11762,_11764,currentqueue),_11850,_11852)  :-
 buildECAevent(_11758,_11850,_11906),
 ifClause(_11778,_11906,_11960),
 buildECAcondition(_11778,_11760,_11960,[ident('DO')|_12076]),
 buildECAactionList(_11762,_12076,_12090),
 optELSEactionList(_11764,_12090,_11852) .
buildECAruleHelper(ecarule(_12196,true,_12200,[noop],q1),[ident('TRANSACTIONAL')|_12324],_12276)  :-
 buildECAevent(_12196,_12324,[ident('DO')|_12386]),
 buildECAactionList(_12200,_12386,_12276) .
buildECAruleHelper(ecarule(_12444,_12446,_12448,_12450,q1),[ident('TRANSACTIONAL')|_12604],_12556)  :-
 buildECAevent(_12444,_12604,_12618),
 ifClause(_12476,_12618,_12672),
 buildECAcondition(_12476,_12446,_12672,[ident('DO')|_12788]),
 buildECAactionList(_12448,_12788,_12802),
 optELSEactionList(_12450,_12802,_12556) .
buildECAruleHelper(ecarule(_12908,true,_12912,[noop],_12916),_13014,_13016)  :-
 buildECAevent(_12908,_13014,[ident('FOR'),ident(_12916),ident('DO')|_13134]),
 buildECAactionList(_12912,_13134,_13148),
 optELSEactionList(_12968,_13148,_13016) .
buildECAruleHelper(ecarule(_13246,_13248,_13250,_13252,_13254),_13374,_13376)  :-
 buildECAevent(_13246,_13374,[ident('FOR'),ident(_13254)|_13486]),
 ifClause(_13290,_13486,_13500),
 buildECAcondition(_13290,_13248,_13500,[ident('DO')|_13616]),
 buildECAactionList(_13250,_13616,_13630),
 optELSEactionList(_13252,_13630,_13376) .

ifClause('IFNEW',[ident('IFNEW')|_13758],_13758)  :-
 true .
ifClause('IFNEW',[ident('IF'),ident('NEW')|_13882],_13882)  :-
 ! .
ifClause('IF',[ident('IF')|_13980],_13980)  :-
 true .

optELSEactionList(_14038,[ident('ELSE')|_14126],_14078)  :-
 buildECAactionList(_14038,_14126,_14078) .
optELSEactionList([noop],_14220,_14220)  :-
 true .

buildECAevent(_14274,_14364,_14366)  :-
 'ECAeventOperation'(_14278,_14364,['('|_14468]),
 lit(_14290,_14468,[')'|_14366]),
 makeECAevent(_14278,_14290,_14274),
 ! .
buildECAevent(_14548,_14610,_14612)  :-
 'ECAeventOperation'(_14552,_14610,_14666),
 lit(_14556,_14666,_14612),
 makeECAevent(_14552,_14556,_14548),
 ! .
buildECAevent(_14778,[ident(_14784),'('|_14994],_14934)  :-
 memberchk(_14784,['Ask',ask]),
 litarg(_14834,_14994,[')'|_14934]),
 resolveDeriveExpression('In'('_tempvarxyz',_14834),_14856),
 makeECAevent('Ask',_14856,_14778),
 ! .
buildECAevent(_15086,[ident(_15092)|_15262],_15214)  :-
 memberchk(_15092,['Ask',ask]),
 litarg(_15134,_15262,_15214),
 resolveDeriveExpression('In'('_tempvarxyz',_15134),_15148),
 makeECAevent('Ask',_15148,_15086),
 ! .

buildECAcondition(_15350,_15352,[ident(_15352)|_15426],_15426)  :-
 memberchk(_15352,[true,false]),
 ! .
buildECAcondition(_15506,_15508,_15560,_15562)  :-
 'ECAconditionFormula'(_15512,_15560,_15562),
 makeECAcondition(_15506,_15512,_15508),
 ! .

'ECAconditionFormula'(_15688,['('|_15786],_15738)  :-
 'ECAconditionFormula'(_15688,_15786,[')'|_15738]),
 true .
'ECAconditionFormula'(_15858,_15890,_15892)  :-
 'ECAconditionFormula1'(_15862,_15890,_15946),
 'ECAconditionFormula2'(_15862,_15858,_15946,_15892) .

'ECAconditionFormula1'(_16058,_16078,_16080)  :-
 ecalit(_16058,_16078,_16080) .
'ECAconditionFormula1'(not(_16178),[ident(not)|_16288],_16240)  :-
 ecalit(_16178,_16288,_16240),
 ! .
'ECAconditionFormula1'(not(_16354),[ident(not),'('|_16482],_16426)  :-
 'ECAconditionFormula'(_16354,_16482,[')'|_16426]),
 true .

'ECAconditionFormula2'(_16554,and(_16554,_16556),[ident(and)|_16664],_16602)  :-
 'ECAconditionFormula'(_16556,_16664,_16602) .
'ECAconditionFormula2'(_16722,or(_16722,_16724),[ident(or)|_16832],_16770)  :-
 'ECAconditionFormula'(_16724,_16832,_16770) .
'ECAconditionFormula2'(_16890,_16890,_16920,_16920)  :-
 true .

buildECAactionList([_16990|_16992],_17026,_17028)  :-
 'ECAaction'(_16990,_17026,_17082),
 buildECAactionList_rest(_16992,_17082,_17028) .

buildECAactionList_rest(_17180,[','|_17282],_17234)  :-
 !,
 buildECAactionList(_17180,_17282,_17234) .
buildECAactionList_rest([],_17378,_17378)  :-
 ! .

'ECAaction'(noop,[ident(noop)|_17480],_17480)  :-
 ! .
'ECAaction'(noop,[ident(commit)|_17588],_17588)  :-
 ! .
'ECAaction'(reject,[ident(reject)|_17696],_17696)  :-
 ! .
'ECAaction'(tBegin,[ident(tBegin)|_17804],_17804)  :-
 ! .
'ECAaction'(tEnd,[ident(tEnd)|_17912],_17912)  :-
 ! .
'ECAaction'(_17972,_18062,_18064)  :-
 'ECAactionOperation'(_17976,_18062,['('|_18166]),
 ecalit(_17988,_18166,[')'|_18064]),
 makeECAaction(_17976,_17988,_17972),
 ! .
'ECAaction'(_18246,_18308,_18310)  :-
 'ECAactionOperation'(_18250,_18308,_18364),
 ecalit(_18254,_18364,_18310),
 makeECAaction(_18250,_18254,_18246),
 ! .
'ECAaction'(_18476,[ident(_18482),'('|_18674],_18614)  :-
 memberchk(_18482,['Raise',raise]),
 deriveExpression(_18532,_18674,[')'|_18614]),
 makeECAaction('Raise',_18532,_18476),
 ! .
'ECAaction'(_18760,[ident(_18766)|_18918],_18870)  :-
 memberchk(_18766,['Raise',raise]),
 deriveExpression(_18808,_18918,_18870),
 makeECAaction('Raise',_18808,_18760),
 ! .
'ECAaction'(_19000,[ident(_19006),ident(_19050)|_19118],_19118)  :-
 memberchk(_19006,['Raise',raise]),
 makeECAaction(_19006,_19050,_19000),
 ! .

'ECAeventOperation'(_19202,[ident(_19202)|_19288],_19288)  :-
 memberchk(_19202,['Tell','Untell',tell,untell]),
 ! .

'ECAactionOperation'(_19354,[ident(_19354)|_19482],_19482)  :-
 memberchk(_19354,['Tell','Untell','Retell','Ask','Call','CALL',tell,untell,retell,ask,call]),
 ! .

ecalit(new(_19548),[ident(new),'('|_19676],_19620)  :-
 lit(_19548,_19676,[')'|_19620]),
 true .
ecalit(new(_19748),[_19758|_19860],_19812)  :-
 pc_ascii(_19758,96),
 lit(_19748,_19860,_19812) .
ecalit(_19928,_19948,_19950)  :-
 lit(_19928,_19948,_19950) .

bulkQueryCall(bulkquery(_20048),[ident(bulk),'['|_20184],_20128)  :-
 bulkArgList(_20048,_20184,_20128),
 temp_msp(_20082) .

bulkArgList([_20252],_20292,_20294)  :-
 bulkArg(_20252,_20292,[']'|_20294]),
 true .
bulkArgList([_20408|_20410],_20458,_20460)  :-
 bulkArg(_20408,_20458,[','|_20562]),
 bulkArgList(_20410,_20562,_20460) .

bulkArg(plainarg(_20620),_20662,_20664)  :-
 constantval(_20620,_20662,_20664),
 ! .
bulkArg(plainarg(_20770),_20812,_20814)  :-
 assertionval(_20770,_20812,_20814),
 ! .
bulkArg(plainarg(_20920),_20962,_20964)  :-
 selectExpression(_20920,_20962,_20964),
 ! .
bulkArg(plainarg(_21070),_21112,_21114)  :-
 objectname(_21070,_21112,_21114),
 ! .
bulkArg(unknown(_21220),_21262,_21264)  :-
 falseSelectExpression(_21220,_21262,_21264),
 ! .
bulkArg(unknown(_21370),_21412,_21414)  :-
 simplelabel(_21370,_21412,_21414),
 ! .

falseSelectExpression(select(_21520,_21522,_21524),_21638,_21640)  :-
 anyArg(_21520,_21638,[select(_21522)|_21742]),
 anyArg(_21524,_21742,_21640),
 memberchk(_21522,[->,=>,!,^,@]),
 ! .
falseSelectExpression(_21814,['('|_21912],_21864)  :-
 falseSelectExpression(_21814,_21912,[')'|_21864]),
 true .

anyArg(_21984,_22004,_22006)  :-
 simplelabel(_21984,_22004,_22006) .
anyArg(_22104,[string(_22104)|_22134],_22134)  :-
 true .
anyArg(_22192,[assertion(_22192)|_22222],_22222)  :-
 true .
anyArg(_22280,[intNumber(_22280)|_22310],_22310)  :-
 true .
anyArg(_22368,[realNumber(_22368)|_22398],_22398)  :-
 true .
anyArg(_22456,[falseSelectExpression(_22456)|_22486],_22486)  :-
 true .

buildQuerycall(class(_22544),_22586,_22588)  :-
 bulkQueryCall(_22544,_22586,_22588),
 ! .
buildQuerycall(class(_22694),_22718,_22720)  :-
 arExpr(_22694,_22718,_22720) .
buildQuerycall(class(_22818),_22842,_22844)  :-
 deriveExpression(_22818,_22842,_22844) .

convertSelectExpression(_22942,_22962,_22964)  :-
 selectExpression(_22942,_22962,_22964) .
convertSelectExpression(_23062,_23082,_23084)  :-
 objectname(_23062,_23082,_23084) .
