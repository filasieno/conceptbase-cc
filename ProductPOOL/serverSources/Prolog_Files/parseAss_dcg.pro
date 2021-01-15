/** This module named "parseAss_dcg" was automatically generated from the DCG-grammar file "parseAss.dcg".

	DO NOT EDIT MANUALLY
**/

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

buildMSFOLconstraint('MSFOLconstraint'(_G2744),_G2770,_G2773)  :-
 parseDecl(_G2744,_G2770,_G2773),
 ! .

buildAssertionRule('MSFOLrule'(_G2811,_G2812,_G2813),_G2898,_G2901)  :-
 foralls(_G2817,_G2818,_G2898,_G2929),
 'VarTabLookup_vars'(_G2811),
 buildAssertionRule2(_G2827,_G2813,_G2929,_G2901),
 !,
 (
 _G2818==[],
 _G2812=_G2827;
 _G2818\==[],
 append(_G2818,[_G2827],_G2850),
 _G2812=and(_G2850)),
 validConclusion(_G2813,_G2811) .

buildAssertionRule2(_G2987,_G2988,_G3022,_G3025)  :-
 exp(_G2990,_G3022,_G3025),
 !,
 splitRule(_G2990,_G2987,_G2988) .

buildAssertionTerm('MSFOLassertion'(_G3070),_G3096,_G3099)  :-
 parseDecl(_G3070,_G3096,_G3099),
 ! .

buildAssertionTerm('MSFOLassertion'(_G3137),_G3163,_G3166)  :-
 exp(_G3137,_G3163,_G3166),
 ! .

shortConclusion(lit(_G3204),_G3222,_G3225)  :-
 lit(_G3204,_G3222,_G3225) .

shortConclusion(lit(_G3260),['('|_G3307],_G3293)  :-
 lit(_G3260,_G3307,[')'|_G3293]),
 true .

parseDecl(_G3337,_G3361,_G3364)  :-
 exp(_G3337,_G3361,_G3364),
 ! .

exp(_G3402,_G3450,_G3453)  :-
 elemexp(_G3404,_G3450,_G3478),
 andexp(_G3404,_G3407,_G3478,_G3506),
 orexp(_G3407,_G3410,_G3506,_G3538),
 implexp(_G3410,_G3413,_G3538,_G3570),
 equivexp(_G3413,_G3402,_G3570,_G3453),
 ! .

elemexp(_G3619,[ident(forall)|_G3711],_G3697)  :-
 vartypelist(_G3626,_G3627,_G3711,_G3728),
 (
 _G3627==[],
 expandQuantifier(forall,_G3626,_G3634,_G3619);
 _G3627\==[],
 append(_G3627,[_G3634],_G3648),
 expandQuantifier(forall,_G3626,and(_G3648),_G3619)),
 exp(_G3634,_G3728,_G3697) .

elemexp(_G3770,[ident(exists)|_G3862],_G3848)  :-
 vartypelist(_G3777,_G3778,_G3862,_G3879),
 (
 _G3778==[],
 expandQuantifier(exists,_G3777,_G3785,_G3770);
 _G3778\==[],
 append(_G3778,[_G3785],_G3799),
 expandQuantifier(exists,_G3777,and(_G3799),_G3770)),
 exp(_G3785,_G3879,_G3848) .

elemexp(not(_G3921),[ident(not)|_G3964],_G3950)  :-
 elemexp(_G3921,_G3964,_G3950) .

elemexp(_G3988,['('|_G4033],_G4019)  :-
 exp(_G3988,_G4033,[')'|_G4019]),
 true .

elemexp(lit(_G4063),_G4081,_G4084)  :-
 lit(_G4063,_G4081,_G4084) .

elemexp(_G4119,_G4135,_G4138)  :-
 elemSelectExpB(_G4119,_G4135,_G4138) .

vartypelist([_G4173|_G4174],_G4177,_G4218,_G4221)  :-
 vartype(_G4173,_G4180,_G4218,_G4253),
 optvartypelist(_G4174,_G4183,_G4253,_G4221),
 !,
 append(_G4180,_G4183,_G4177) .

optvartypelist(_G4305,_G4306,_G4326,_G4329)  :-
 vartypelist(_G4305,_G4306,_G4326,_G4329) .

optvartypelist([],[],_G4401,_G4401)  :-
 true,
 ! .

vartype(vtype(_G4424,_G4425),_G4428,_G4480,_G4483)  :-
 varlist(_G4424,_G4480,[/|_G4526]),
 selectexpb(_G4435,_G4526,_G4483),
 replaceSelectExpBList(_G4435,_G4424,_G4425,_G4428),
 'VarTabInsert'(_G4424,[_G4425]) .

vartype(vtype(_G4556,_G4557),[],_G4621,_G4624)  :-
 varlist(_G4556,_G4621,[/,'['|_G4670]),
 typelist(_G4557,_G4670,[']'|_G4624]),
 'VarTabInsert'(_G4556,_G4557),
 !,
 containsNoReservedWord(_G4556) .

vartype(vtype(_G4706,_G4707),[],_G4762,_G4765)  :-
 varlist(_G4706,_G4762,[/|_G4808]),
 type(_G4707,_G4808,_G4765),
 'VarTabInsert'(_G4706,[_G4707]),
 !,
 containsNoReservedWord(_G4706) .

varlist([_G4841|_G4842],[ident(_G4841),','|_G4908],_G4891)  :-
 varlist(_G4842,_G4908,_G4891),
 !,
 _G4841\=='~this' .

varlist([_G4938],[ident(_G4938)|_G4977],_G4977)  :-
 !,
 _G4938\=='~this' .

andexp(and_h(_G4996),_G4999,[ident(and)|_G5058],_G5040)  :-
 elemexp(_G5006,_G5058,_G5072),
 andexp(and_h([_G5006|_G4996]),_G4999,_G5072,_G5040) .

andexp(_G5114,_G5115,[ident(and)|_G5177],_G5159)  :-
 elemexp(_G5122,_G5177,_G5191),
 andexp(and_h([_G5122,_G5114]),_G5115,_G5191,_G5159) .

andexp(and_h(_G5233),and(_G5235),_G5263,_G5263)  :-
 reverse(_G5233,_G5235) .

andexp(_G5283,_G5284,_G5309,_G5309)  :-
 _G5284=_G5283 .

orexp(or_h(_G5329),_G5332,[ident(or)|_G5397],_G5379)  :-
 elemexp(_G5339,_G5397,_G5411),
 andexp(_G5339,_G5342,_G5411,_G5439),
 orexp(or_h([_G5342|_G5329]),_G5332,_G5439,_G5379) .

orexp(_G5485,_G5486,[ident(or)|_G5554],_G5536)  :-
 elemexp(_G5493,_G5554,_G5568),
 andexp(_G5493,_G5496,_G5568,_G5596),
 orexp(or_h([_G5496,_G5485]),_G5486,_G5596,_G5536) .

orexp(or_h(_G5642),or(_G5644),_G5672,_G5672)  :-
 reverse(_G5642,_G5644) .

orexp(_G5692,_G5693,_G5718,_G5718)  :-
 _G5693=_G5692 .

implexp(_G5738,_G5739,[==>|_G5806],_G5788)  :-
 elemexp(_G5744,_G5806,_G5820),
 andexp(_G5744,_G5747,_G5820,_G5848),
 orexp(_G5747,_G5750,_G5848,_G5880),
 implexp(impl(_G5738,_G5750),_G5739,_G5880,_G5788) .

implexp(_G5926,_G5927,_G5952,_G5952)  :-
 _G5927=_G5926 .

equivexp(_G5972,_G5973,[<==>|_G6057],_G6039)  :-
 elemexp(_G5978,_G6057,_G6071),
 andexp(_G5978,_G5981,_G6071,_G6099),
 orexp(_G5981,_G5984,_G6099,_G6131),
 implexp(_G5984,_G5987,_G6131,_G6163),
 equivexp(and([impl(_G5972,_G5987),impl(_G5987,_G5972)]),_G5973,_G6163,_G6039) .

equivexp(_G6209,_G6210,_G6235,_G6235)  :-
 _G6210=_G6209 .

lit('Mod'(_G6255,_G6256),[ident(_G6260),select(@),ident(_G6290),'('|_G6431],_G6405)  :-
 memberchk(_G6260,['A','A_e','Ai','A2']),
 name2id(_G6290,_G6256),
 pc_update(t_msp(_G6256)),
 litarg(_G6313,_G6431,[','|_G6459]),
 label(_G6318,_G6459,[','|_G6487]),
 litarg(_G6323,_G6487,[')'|_G6405]),
 _G6255=..[_G6260,_G6313,_G6318,_G6323],
 abolish(t_msp,1) .

lit(_G6529,[ident(_G6531),'('|_G6677],_G6654)  :-
 memberchk(_G6531,['A','A_e','Ai','A2']),
 'M_SearchSpace'(_G6554),
 pc_update(t_msp(_G6554)),
 litarg(_G6571,_G6677,[','|_G6705]),
 label(_G6576,_G6705,[','|_G6733]),
 litarg(_G6581,_G6733,[')'|_G6654]),
 _G6529=..[_G6531,_G6571,_G6576,_G6581],
 abolish(t_msp,1) .

lit('Mod'(_G6775,_G6776),[ident('AL'),select(@),ident(_G6790),'('|_G6932],_G6906)  :-
 name2id(_G6790,_G6776),
 pc_update(t_msp(_G6776)),
 litarg(_G6813,_G6932,[','|_G6960]),
 label(_G6818,_G6960,[','|_G6988]),
 simplelabel(_G6823,_G6988,[','|_G7016]),
 litarg(_G6828,_G7016,[')'|_G6906]),
 _G6775='A_label'(_G6813,_G6818,_G6828,_G6823),
 abolish(t_msp,1) .

lit(_G7055,[ident('AL'),'('|_G7186],_G7166)  :-
 'M_SearchSpace'(_G7062),
 pc_update(t_msp(_G7062)),
 litarg(_G7079,_G7186,[','|_G7214]),
 label(_G7084,_G7214,[','|_G7242]),
 simplelabel(_G7089,_G7242,[','|_G7270]),
 litarg(_G7094,_G7270,[')'|_G7166]),
 _G7055='A_label'(_G7079,_G7084,_G7094,_G7089),
 abolish(t_msp,1) .

lit(_G7309,['('|_G7417],_G7400)  :-
 'M_SearchSpace'(_G7311),
 pc_update(t_msp(_G7311)),
 litarg(_G7328,_G7417,_G7431),
 label(_G7330,_G7431,[/|_G7470]),
 simplelabel(_G7335,_G7470,_G7484),
 litarg(_G7337,_G7484,[')'|_G7400]),
 _G7309='A_label'(_G7328,_G7330,_G7337,_G7335),
 abolish(t_msp,1) .

lit('Mod'(_G3,_G4),[ident(_G8),select(@),ident(_G32),'('|_G133],_G114)  :-
 memberchk(_G8,['In','In2']),
 name2id(_G32,_G4),
 pc_update(t_msp(_G4)),
 litarglist(_G55,_G133,[')'|_G114]),
 _G63=..[_G8|_G55],
 resolveDeriveExpression(_G32,_G63,_G3),
 abolish(t_msp,1) .

lit(_G178,[ident(_G180),'('|_G297],_G277)  :-
 memberchk(_G180,['In','In2']),
 'M_SearchSpace'(_G199),
 pc_update(t_msp(_G199)),
 litarglist(_G216,_G297,[')'|_G277]),
 _G224=..[_G180|_G216],
 resolveDeriveExpression(_G224,_G178),
 abolish(t_msp,1) .

lit('Mod'(_G342,_G343),[ident('Label'),select(@),ident(_G357),'('|_G481],_G455)  :-
 name2id(_G357,_G343),
 pc_update(t_msp(_G343)),
 litarg(_G380,_G481,[','|_G509]),
 label(_G385,_G509,[')'|_G455]),
 _G342=..['Label',_G380,_G385],
 abolish(t_msp,1) .

lit(_G548,[ident('Label'),'('|_G655],_G635)  :-
 'M_SearchSpace'(_G555),
 pc_update(t_msp(_G555)),
 litarg(_G572,_G655,[','|_G683]),
 label(_G577,_G683,[')'|_G635]),
 _G548=..['Label',_G572,_G577] .

lit('Mod'(_G719,_G720),[ident('P'),select(@),ident(_G734),'('|_G886],_G860)  :-
 name2id(_G734,_G720),
 pc_update(t_msp(_G720)),
 litarg(_G757,_G886,[','|_G914]),
 litarg(_G762,_G914,[','|_G942]),
 label(_G767,_G942,[','|_G970]),
 litarg(_G772,_G970,[')'|_G860]),
 _G719=..['P',_G757,_G762,_G767,_G772],
 abolish(t_msp,1) .

lit('Mod'(_G1009,_G1010),[ident('Pa'),select(@),ident(_G1024),'('|_G1176],_G1150)  :-
 name2id(_G1024,_G1010),
 pc_update(t_msp(_G1010)),
 litarg(_G1047,_G1176,[','|_G1204]),
 litarg(_G1052,_G1204,[','|_G1232]),
 label(_G1057,_G1232,[','|_G1260]),
 litarg(_G1062,_G1260,[')'|_G1150]),
 _G1009=..['Pa',_G1047,_G1052,_G1057,_G1062],
 abolish(t_msp,1) .

lit(_G1299,[ident('P'),'('|_G1440],_G1420)  :-
 'M_SearchSpace'(_G1306),
 pc_update(t_msp(_G1306)),
 litarg(_G1323,_G1440,[','|_G1468]),
 litarg(_G1328,_G1468,[','|_G1496]),
 variableOrLabel(_G1333,_G1496,[','|_G1524]),
 litarg(_G1338,_G1524,[')'|_G1420]),
 _G1299=..['P',_G1323,_G1328,_G1333,_G1338],
 abolish(t_msp,1) .

lit(_G1563,[ident('Pa'),'('|_G1704],_G1684)  :-
 'M_SearchSpace'(_G1570),
 pc_update(t_msp(_G1570)),
 litarg(_G1587,_G1704,[','|_G1732]),
 litarg(_G1592,_G1732,[','|_G1760]),
 variableOrLabel(_G1597,_G1760,[','|_G1788]),
 litarg(_G1602,_G1788,[')'|_G1684]),
 _G1563=..['Pa',_G1587,_G1592,_G1597,_G1602],
 abolish(t_msp,1) .

lit('Mod'(_G1827,_G1828),[ident(_G1832),select(@),ident(_G1842),'('|_G1949],_G1923)  :-
 name2id(_G1842,_G1828),
 pc_update(t_msp(_G1828)),
 litarglist(_G1865,_G1949,[')'|_G1923]),
 _G1827=..[_G1832|_G1865],
 abolish(t_msp,1) .

lit(_G1988,[ident(_G1990),'('|_G2109],_G2089)  :-
 \+memberchk(_G1990,[new,not,forall,exists]),
 'M_SearchSpace'(_G2017),
 pc_update(t_msp(_G2017)),
 litarglist(_G2034,_G2109,[')'|_G2089]),
 _G1988=..[_G1990|_G2034],
 abolish(t_msp,1) .

lit(_G2151,['('|_G2287],_G2270)  :-
 'M_SearchSpace'(_G2153),
 pc_update(t_msp(_G2153)),
 litarg1(_G2170,_G2287,[_G2172|_G2315]),
 memberchk(_G2172,[=,<,>,=<,<=,>=,<>,\=]),
 !,
 litarg1(_G2210,_G2315,[')'|_G2270]),
 infixToLiteral(_G2151,_G2170,_G2172,_G2210),
 !,
 abolish(t_msp,1) .

lit(_G2366,['('|_G2464],_G2447)  :-
 'M_SearchSpace'(_G2368),
 pc_update(t_msp(_G2368)),
 litarg(_G2385,_G2464,[_G2387|_G2492]),
 litarg(_G2390,_G2492,[')'|_G2447]),
 infixToLiteral(_G2366,_G2385,_G2387,_G2390),
 !,
 abolish(t_msp,1) .

lit(_G2534,['('|_G2644],_G2627)  :-
 'M_SearchSpace'(_G2536),
 pc_update(t_msp(_G2536)),
 litarg(_G2553,_G2644,['[',_G2558,']'|_G2678]),
 litarg(_G2564,_G2678,[')'|_G2627]),
 metaInfixToLiteral(_G2534,_G2553,_G2558,_G2564),
 !,
 abolish(t_msp,1) .

lit(_G2720,[:,'('|_G2833],_G2813)  :-
 'M_SearchSpace'(_G2722),
 pc_update(t_msp(_G2722)),
 litarg(_G2742,_G2833,[_G2744|_G2861]),
 litarg(_G2747,_G2861,[')',:|_G2813]),
 explicatedToLiteral(_G2720,_G2742,_G2744,_G2747),
 !,
 abolish(t_msp,1) .

lit(_G2906,[:,'('|_G3037],_G3017)  :-
 'M_SearchSpace'(_G2908),
 pc_update(t_msp(_G2908)),
 litarg(_G2928,_G3037,[_G2930,/,_G2936|_G3071]),
 litarg(_G2939,_G3071,[')',:|_G3017]),
 explicatedToLiteral(_G2906,_G2928,[_G2930,_G2936],_G2939),
 !,
 abolish(t_msp,1) .

lit('TRUE',[ident('TRUE')|_G3138],_G3138)  :-
 true .

lit('FALSE',[ident('FALSE')|_G3176],_G3176)  :-
 true .

litarglist([_G3192|_G3193],_G3216,_G3219)  :-
 litarg(_G3192,_G3216,_G3244),
 litarglist_rest(_G3193,_G3244,_G3219) .

litarglist_rest(_G3279,[','|_G3326],_G3312)  :-
 !,
 litarglist(_G3279,_G3326,_G3312) .

litarglist_rest([],_G3372,_G3372)  :-
 ! .

litarg(_G3388,_G3404,_G3407)  :-
 constantval(_G3388,_G3404,_G3407) .

litarg(_G3442,_G3458,_G3461)  :-
 deriveExpression(_G3442,_G3458,_G3461) .

litarg(_G3496,_G3512,_G3515)  :-
 selectExpression(_G3496,_G3512,_G3515) .

litarg(_G3550,_G3566,_G3569)  :-
 variableOrObject(_G3550,_G3566,_G3569) .

litarg1(_G3604,_G3620,_G3623)  :-
 constantval(_G3604,_G3620,_G3623) .

litarg1(_G3658,_G3674,_G3677)  :-
 arExpr(_G3658,_G3674,_G3677) .

litarg1(_G3712,_G3728,_G3731)  :-
 deriveExpression(_G3712,_G3728,_G3731) .

litarg1(_G3766,_G3782,_G3785)  :-
 selectExpression(_G3766,_G3782,_G3785) .

litarg1(_G3820,_G3836,_G3839)  :-
 variableOrObject(_G3820,_G3836,_G3839) .

typeExpr(_G3874,_G3890,_G3893)  :-
 constantval(_G3874,_G3890,_G3893) .

typeExpr(_G3928,_G3944,_G3947)  :-
 regularDeriveExpression(_G3928,_G3944,_G3947) .

typeExpr(_G3982,_G3998,_G4001)  :-
 shortQueryCall(_G3982,_G3998,_G4001) .

typeExpr(_G4036,_G4052,_G4055)  :-
 selectExpression(_G4036,_G4052,_G4055) .

typeExpr(_G4090,_G4106,_G4109)  :-
 objectname(_G4090,_G4106,_G4109) .

variableOrObject(_G4144,[ident(_G4146)|_G4261],_G4261)  :-
 \+memberchk(_G4146,['Known',new,'UNIFIES',in,isA,not,'In',forall,exists,'IDENTICAL','Ai']),
 (
 isVariable(_G4146,_G4144),
 !;
 (
 temp_msp(_G4200),
 t_name2id(_G4200,_G4146,_G4144),
 !;
 report_error('PFNFE',parseAss_dcg,[_G4146]),
 pc_atomconcat('%%UNKNOWN--',_G4146,_G4144),
 !)) .

objectname(_G4280,[ident(_G4282)|_G4363],_G4363)  :-
 \+memberchk(_G4282,['Known',new,'UNIFIES',in,isA,not,'In',forall,exists,'IDENTICAL','Ai']),
 temp_msp(_G4328),
 t_name2id(_G4328,_G4282,_G4280),
 ! .

constantval(_G4388,[realNumber(_G4390)|_G4422],_G4422)  :-
 create_if_builtin_object(_G4390,'Real',_G4388) .

constantval(_G4438,[intNumber(_G4440)|_G4472],_G4472)  :-
 create_if_builtin_object(_G4440,'Integer',_G4438) .

constantval(_G4488,[string(_G4490)|_G4522],_G4522)  :-
 create_if_builtin_object(_G4490,'String',_G4488) .

label(_G4538,[ident(_G4538)|_G4586],_G4586)  :-
 temp_msp(_G4545),
 prove_literal('Mod'('P'(_G4550,_G4551,_G4538,_G4553),_G4545)),
 ! .

label(_G4608,[string(_G4608)|_G4656],_G4656)  :-
 temp_msp(_G4615),
 prove_literal('Mod'('P'(_G4620,_G4621,_G4608,_G4623),_G4615)),
 ! .

variableOrLabel(_G4678,[ident(_G4680)|_G4720],_G4720)  :-
 (
 isVariable(_G4680,_G4678),
 !;
 _G4678=_G4680) .

simplelabel(_G4736,[ident(_G4736)|_G4758],_G4758)  :-
 true .

typelist([_G4774|_G4775],_G4804,_G4807)  :-
 type(_G4774,_G4804,[','|_G4846]),
 typelist(_G4775,_G4846,_G4807) .

typelist([_G4870],_G4889,_G4892)  :-
 type(_G4870,_G4889,_G4892) .

type('VAR',[ident('VAR')|_G4957],_G4957)  :-
 ! .

type(_G4973,_G5006,_G5009)  :-
 'M_SearchSpace'(_G4975),
 pc_update(t_msp(_G4975)),
 typeExpr(_G4973,_G5006,_G5009) .

deriveExpression(_G5053,_G5069,_G5072)  :-
 listModExpression(_G5053,_G5069,_G5072) .

deriveExpression(_G5107,_G5123,_G5126)  :-
 countExpr(_G5107,_G5123,_G5126) .

deriveExpression(_G5161,_G5177,_G5180)  :-
 shortFunctionCall(_G5161,_G5177,_G5180) .

deriveExpression(_G5215,_G5231,_G5234)  :-
 shortQueryCall(_G5215,_G5231,_G5234) .

deriveExpression(_G5269,_G5285,_G5288)  :-
 regularDeriveExpression(_G5269,_G5285,_G5288) .

regularDeriveExpression(derive(_G5323,_G5324),[ident(_G5328),'['|_G5399],_G5382)  :-
 dExpList(_G5324,_G5399,[']'|_G5382]),
 temp_msp(_G5341),
 t_name2id(_G5341,_G5328,_G5323) .

listModExpression(derive(_G5432,_G5433),[ident(listModule),'['|_G5511],_G5494)  :-
 modExpr(_G5433,_G5511,[']'|_G5494]),
 !,
 temp_msp(_G5453),
 t_name2id(_G5453,listModule,_G5432) .

modExpr([substitute(_G5547,module)],_G5591,_G5594)  :-
 modPath(_G5547,_G5591,[/,ident(module)|_G5594]),
 ! .

modExpr([substitute(_G5638,module)],_G5660,_G5663)  :-
 modPath(_G5638,_G5660,_G5663) .

modPath(_G5698,_G5722,_G5725)  :-
 modPathMin(_G5698,_G5722,_G5725),
 ! .

modPath(_G5763,_G5787,_G5790)  :-
 modPathSlash(_G5763,_G5787,_G5790),
 ! .

modPathMin(_G5828,[ident(_G5830),-|_G5901],_G5884)  :-
 modPathMin(_G5838,_G5901,_G5884),
 !,
 pc_atomconcat([_G5830,-,_G5838],_G5828) .

modPathMin(_G5931,[ident(_G5931)|_G5953],_G5953)  :-
 true .

modPathSlash(_G5969,[ident(_G5969),/,ident(module)|_G6013],_G6013)  :-
 ! .

modPathSlash(_G6035,[ident(_G6037),/|_G6108],_G6091)  :-
 modPathSlash(_G6045,_G6108,_G6091),
 !,
 pc_atomconcat([_G6037,/,_G6045],_G6035) .

modPathSlash(_G6138,[ident(_G6138)|_G6171],_G6171)  :-
 _G6138\=module .

countExpr(derive(_G6193,[substitute(_G6187,class)]),[#|_G6252],_G6238)  :-
 litarg(_G6187,_G6252,_G6238),
 temp_msp(_G6203),
 t_name2id(_G6203,'COUNT',_G6193) .

shortFunctionCall(derive(_G6282,[]),[ident(_G6287),'(',')'|_G6336],_G6336)  :-
 temp_msp(_G6298),
 t_name2id(_G6298,_G6287,_G6282) .

shortFunctionCall(derive(_G6361,_G6362),[ident(_G6366),'('|_G6449],_G6432)  :-
 shortdExpList(_G6374,_G6449,[')'|_G6432]),
 temp_msp(_G6379),
 t_name2id(_G6379,_G6366,_G6361),
 isFunction(_G6361),
 plainToSubsts(_G6361,_G6374,_G6362) .

shortQueryCall(derive(_G6488,_G6489),[ident(_G6493),'['|_G6571],_G6554)  :-
 shortdExpList(_G6501,_G6571,[']'|_G6554]),
 temp_msp(_G6506),
 t_name2id(_G6506,_G6493,_G6488),
 plainToSubsts(_G6488,_G6501,_G6489) .

arExpr(_G6607,_G6647,_G6650)  :-
 arTerm(_G6609,_G6647,_G6675),
 arAddExpr(add(_G6611,_G6612),_G6675,_G6650),
 makeAddition(_G6609,_G6611,_G6612,_G6607),
 ! .

arExpr(_G6716,_G6770,_G6773)  :-
 arTerm(_G6718,_G6770,[intNumber(_G6720)|_G6773]),
 pc_atomconcat(-,_G6726,_G6720),
 create_if_builtin_object(_G6726,'Integer',_G6734),
 makeAddition(_G6718,-,_G6734,_G6716),
 ! .

arExpr(_G6823,_G6839,_G6842)  :-
 arTerm(_G6823,_G6839,_G6842) .

arAddExpr(add(_G6877,_G6878),_G6925,_G6928)  :-
 arAddOp(_G6877,_G6925,_G6953),
 arTerm(_G6884,_G6953,_G6978),
 arAddExpr(add(_G6886,_G6887),_G6978,_G6928),
 makeAddition(_G6884,_G6886,_G6887,_G6878),
 ! .

arAddExpr(add(_G7019,_G7020),_G7043,_G7046)  :-
 arAddOp(_G7019,_G7043,_G7071),
 arTerm(_G7020,_G7071,_G7046) .

arTerm(_G7106,_G7146,_G7149)  :-
 arFactor(_G7108,_G7146,_G7174),
 arMultTerm(mult(_G7110,_G7111),_G7174,_G7149),
 makeMultiplication(_G7108,_G7110,_G7111,_G7106),
 ! .

arTerm(_G7215,_G7231,_G7234)  :-
 arFactor(_G7215,_G7231,_G7234) .

arMultTerm(mult(_G7269,_G7270),_G7317,_G7320)  :-
 arMulOp(_G7269,_G7317,_G7345),
 arFactor(_G7276,_G7345,_G7370),
 arMultTerm(mult(_G7278,_G7279),_G7370,_G7320),
 makeMultiplication(_G7276,_G7278,_G7279,_G7270),
 ! .

arMultTerm(mult(_G7411,_G7412),_G7435,_G7438)  :-
 arMulOp(_G7411,_G7435,_G7463),
 arFactor(_G7412,_G7463,_G7438) .

arFactor(_G7498,_G7522,_G7525)  :-
 funcExpr(_G7498,_G7522,_G7525),
 ! .

arFactor(_G7563,_G7587,_G7590)  :-
 constantval(_G7563,_G7587,_G7590),
 ! .

arFactor(_G3,_G12,_G13)  :-
 variableOrObject(_G3,_G12,_G13) .

arFactor(_G36,['('|_G89],_G75)  :-
 arExpr(_G36,_G89,[')'|_G75]),
 ! .

arAddOp(+,[+|_G139],_G139)  :-
 true .

arAddOp(-,[-|_G175],_G175)  :-
 true .

arMulOp(*,[*|_G211],_G211)  :-
 true .

arMulOp(/,[/|_G247],_G247)  :-
 true .

dExpList([_G263],_G282,_G285)  :-
 dExp(_G263,_G282,_G285) .

dExpList([_G320|_G321],_G350,_G353)  :-
 dExp(_G320,_G350,[','|_G392]),
 dExpList(_G321,_G392,_G353) .

dExp(substitute(_G416,_G417),_G449,_G452)  :-
 litarg(_G416,_G449,[/,ident(_G417)|_G452]),
 true .

dExp(specialize(_G496,_G497),_G529,_G532)  :-
 litarg(_G496,_G529,[:,ident(_G497)|_G532]),
 true .

shortdExpList([_G576],_G595,_G598)  :-
 shortdExp(_G576,_G595,_G598) .

shortdExpList([_G633|_G634],_G663,_G666)  :-
 shortdExp(_G633,_G663,[','|_G705]),
 shortdExpList(_G634,_G705,_G666) .

shortdExp(plainarg(_G729),_G747,_G750)  :-
 litarg(_G729,_G747,_G750) .

funcExpr(derive(_G785,_G786),[ident(_G790),'('|_G873],_G856)  :-
 funcArgList(_G798,_G873,[')'|_G856]),
 temp_msp(_G803),
 t_name2id(_G803,_G790,_G785),
 isFunction(_G785),
 plainToSubsts(_G785,_G798,_G786) .

funcExpr(_G912,_G928,_G931)  :-
 countExpr(_G912,_G928,_G931) .

funcExpr(_G966,_G982,_G985)  :-
 shortFunctionCall(_G966,_G982,_G985) .

funcArgList([_G1020],_G1039,_G1042)  :-
 funcArg(_G1020,_G1039,_G1042) .

funcArgList([_G1077|_G1078],_G1107,_G1110)  :-
 funcArg(_G1077,_G1107,[','|_G1149]),
 funcArgList(_G1078,_G1149,_G1110) .

funcArg(plainarg(_G1173),_G1191,_G1194)  :-
 arExpr(_G1173,_G1191,_G1194) .

funcArg(plainarg(_G1229),_G1247,_G1250)  :-
 arFactor(_G1229,_G1247,_G1250) .

selectExpression(_G1285,_G1344,_G1347)  :-
 idorexp(_G1287,_G1344,[select(_G1289)|_G1386]),
 idorexp(_G1294,_G1386,_G1400),
 memberchk(_G1289,[->,=>]),
 !,
 selectExpression2(_G1285,select(_G1287,_G1289,_G1294),_G1400,_G1347) .

selectExpression(_G1451,_G1508,_G1511)  :-
 idorexp(_G1453,_G1508,[select(_G1455)|_G1550]),
 idorexp(_G1460,_G1550,_G1564),
 temp_msp(_G1462),
 eval(_G1462,select(_G1453,_G1455,_G1460),replaceSelectExpression,_G1474),
 selectExpression2(_G1451,_G1474,_G1564,_G1511) .

selectExpression(_G1615,['('|_G1660],_G1646)  :-
 selectExpression(_G1615,_G1660,[')'|_G1646]),
 true .

selectExpression2(_G1694,select(_G1690,_G1691,_G1692),[select(_G1697)|_G1810],_G1792)  :-
 idorexp(_G1702,_G1810,_G1824),
 memberchk(_G1691,[->,=>]),
 memberchk(_G1697,[!,^,@]),
 !,
 temp_msp(_G1736),
 eval(_G1736,select(_G1692,_G1697,_G1702),replaceSelectExpression,_G1748),
 selectExpression2(_G1694,select(_G1690,_G1691,_G1748),_G1824,_G1792) .

selectExpression2(_G1894,select(_G1890,_G1891,_G1892),[select(_G1897)|_G2007],_G1989)  :-
 idorexp(_G1902,_G2007,_G2021),
 memberchk(_G1891,[->,=>]),
 memberchk(_G1897,[->,=>]),
 !,
 temp_msp(_G1933),
 eval(_G1933,select(_G1890,_G1891,_G1892),replaceSelectExpression,_G1945),
 selectExpression2(_G1894,select(_G1945,_G1897,_G1902),_G2021,_G1989) .

selectExpression2(_G2087,_G2088,[select(_G2090)|_G2166],_G2148)  :-
 memberchk(_G2090,[->,=>]),
 !,
 idorexp(_G2112,_G2166,_G2183),
 selectExpression2(_G2087,select(_G2088,_G2090,_G2112),_G2183,_G2148) .

selectExpression2(_G2231,_G2232,[select(_G2234)|_G2308],_G2290)  :-
 idorexp(_G2239,_G2308,_G2322),
 temp_msp(_G2241),
 eval(_G2241,select(_G2232,_G2234,_G2239),replaceSelectExpression,_G2253),
 selectExpression2(_G2231,_G2253,_G2322,_G2290) .

selectExpression2(_G2377,select(_G2373,_G2374,_G2375),_G2417,_G2417)  :-
 !,
 temp_msp(_G2383),
 eval(_G2383,select(_G2373,_G2374,_G2375),replaceSelectExpression,_G2377) .

selectExpression2(_G2443,_G2444,_G2469,_G2469)  :-
 _G2443=_G2444 .

idorexp(_G2489,_G2505,_G2508)  :-
 label(_G2489,_G2505,_G2508) .

idorexp(_G2543,[intNumber(_G2543)|_G2565],_G2565)  :-
 true .

idorexp(_G2581,[realNumber(_G2581)|_G2603],_G2603)  :-
 true .

idorexp(_G2619,['('|_G2664],_G2650)  :-
 selectExpression(_G2619,_G2664,[')'|_G2650]),
 true .

elemSelectExpB(_G2694,_G2758,_G2761)  :-
 litarg(_G2696,_G2758,[ident(in)|_G2800]),
 selectexpb(_G2703,_G2800,_G2761),
 !,
 replaceSelectExpB(_G2703,_G2696,_G2710,_G2711),
 _G2694=and([lit('In'(_G2696,_G2710)),_G2711]) .

elemSelectExpB(_G2833,_G2923,_G2926)  :-
 selectexpb(_G2835,_G2923,[ident(isA)|_G2965]),
 selectexpb(_G2842,_G2965,_G2926),
 !,
 createNewVarname(_G2847),
 replaceSelectExpB(_G2835,_G2847,_G2854,_G2855),
 replaceSelectExpB(_G2842,_G2847,_G2862,_G2863),
 'VarTabInsert'([_G2847],[_G2854]),
 expandQuantifier(forall,vtype([_G2847],[_G2854]),impl(_G2855,_G2863),_G2833) .

elemSelectExpB(_G3007,_G3106,_G3109)  :-
 selectexpb(_G3009,_G3106,[=|_G3148]),
 selectexpb(_G3014,_G3148,_G3109),
 !,
 createNewVarname(_G3019),
 replaceSelectExpB(_G3009,_G3019,_G3026,_G3027),
 replaceSelectExpB(_G3014,_G3019,_G3034,_G3035),
 'VarTabInsert'([_G3019],[_G3026]),
 expandQuantifier(forall,vtype([_G3019],[_G3026]),and([impl(_G3027,_G3035),impl(_G3035,_G3027)]),_G3007) .

selectexpb(selectExpB(_G3190,_G3191,_G3192),[ident(_G3190),select2(_G3191)|_G3246],_G3229)  :-
 selectexpb2(_G3192,_G3246,_G3229) .

selectexpb(selectExpB(_G3270,_G3271,_G3272),[ident(_G3270),select2(_G3271)|_G3326],_G3309)  :-
 restriction(_G3272,_G3326,_G3309) .

selectexpb(selectExpB(_G3350,_G3351,_G3352),[ident(_G3350),select2(_G3351),ident(_G3352)|_G3392],_G3392)  :-
 true .

selectexpb2(_G3414,_G3430,_G3433)  :-
 selectexpb(_G3414,_G3430,_G3433) .

selectexpb2(selectExpB(_G3468,_G3469,_G3470),_G3501,_G3504)  :-
 restriction(_G3468,_G3501,[select2(_G3469)|_G3543]),
 selectexpb2(_G3470,_G3543,_G3504) .

selectexpb2(selectExpB(_G3567,_G3568,_G3569),_G3600,_G3603)  :-
 restriction(_G3567,_G3600,[select2(_G3568)|_G3642]),
 restriction(_G3569,_G3642,_G3603) .

selectexpb2(selectExpB(_G3666,_G3667,_G3668),_G3702,_G3705)  :-
 restriction(_G3666,_G3702,[select2(_G3667),ident(_G3668)|_G3705]),
 true .

restriction(restriction(_G3749,_G3750),['(',ident(_G3749),:,ident(_G3750),')'|_G3800],_G3800)  :-
 true .

restriction(restriction(_G3828,_G3829),['(',ident(_G3828),:|_G3896],_G3876)  :-
 selectExpression(_G3829,_G3896,[')'|_G3876]),
 true .

restriction(restriction(_G3926,_G3927),['(',ident(_G3926),:|_G3994],_G3974)  :-
 selectexpb(_G3927,_G3994,[')'|_G3974]),
 true .

restriction(restriction(_G4026,enumeration(_G4024)),['(',ident(_G4026),:,'['|_G4109],_G4086)  :-
 enumeration(_G4024,_G4109,[']',')'|_G4086]),
 true .

enumeration([class(_G4142)],_G4163,_G4166)  :-
 litarg(_G4142,_G4163,_G4166) .

enumeration([class(_G4201)],_G4222,_G4225)  :-
 selectExpression(_G4201,_G4222,_G4225) .

enumeration(_G4260,_G4304,_G4307)  :-
 litarg(_G4262,_G4304,[','|_G4346]),
 enumeration(_G4267,_G4346,_G4307),
 append([class(_G4262)],_G4267,_G4260) .

enumeration(_G4373,_G4417,_G4420)  :-
 selectExpression(_G4375,_G4417,[','|_G4459]),
 enumeration(_G4380,_G4459,_G4420),
 append([class(_G4375)],_G4380,_G4373) .

foralls(_G4486,_G4487,_G4532,_G4535)  :-
 forall(_G4489,_G4490,_G4532,_G4567),
 foralls(_G4492,_G4493,_G4567,_G4535),
 append(_G4489,_G4492,_G4486),
 append(_G4490,_G4493,_G4487) .

foralls([],[],_G4642,_G4642)  :-
 true .

forall(_G4662,_G4663,[ident(forall)|_G4712],_G4694)  :-
 vartypelist(_G4662,_G4663,_G4712,_G4694) .

buildECArule(ecarule(_G4743,_G4744,_G4745,_G4746,_G4747),_G4785,_G4788)  :-
 optvartypelist(_G4751,[],_G4785,[ident('ON')|_G4834]),
 buildECAruleHelper(ecarule(_G4743,_G4744,_G4745,_G4746,_G4747),_G4834,_G4788) .

buildECAruleHelper(ecarule(_G4861,true,_G4863,[noop],currentqueue),_G4896,_G4899)  :-
 buildECAevent(_G4861,_G4896,[ident('DO')|_G4938]),
 buildECAactionList(_G4863,_G4938,_G4899) .

buildECAruleHelper(ecarule(_G4962,_G4963,_G4964,_G4965,currentqueue),_G5013,_G5016)  :-
 buildECAevent(_G4962,_G5013,_G5041),
 ifClause(_G4972,_G5041,_G5066),
 buildECAcondition(_G4972,_G4963,_G5066,[ident('DO')|_G5112]),
 buildECAactionList(_G4964,_G5112,_G5126),
 optELSEactionList(_G4965,_G5126,_G5016) .

buildECAruleHelper(ecarule(_G5164,true,_G5166,[noop],q1),[ident('TRANSACTIONAL')|_G5224],_G5210)  :-
 buildECAevent(_G5164,_G5224,[ident('DO')|_G5252]),
 buildECAactionList(_G5166,_G5252,_G5210) .

buildECAruleHelper(ecarule(_G5276,_G5277,_G5278,_G5279,q1),[ident('TRANSACTIONAL')|_G5352],_G5338)  :-
 buildECAevent(_G5276,_G5352,_G5366),
 ifClause(_G5291,_G5366,_G5391),
 buildECAcondition(_G5291,_G5277,_G5391,[ident('DO')|_G5437]),
 buildECAactionList(_G5278,_G5437,_G5451),
 optELSEactionList(_G5279,_G5451,_G5338) .

buildECAruleHelper(ecarule(_G5489,true,_G5491,[noop],_G5493),_G5545,_G5548)  :-
 buildECAevent(_G5489,_G5545,[ident('FOR'),ident(_G5493),ident('DO')|_G5593]),
 buildECAactionList(_G5491,_G5593,_G5607),
 optELSEactionList(_G5516,_G5607,_G5548) .

buildECAruleHelper(ecarule(_G5642,_G5643,_G5644,_G5645,_G5646),_G5709,_G5712)  :-
 buildECAevent(_G5642,_G5709,[ident('FOR'),ident(_G5646)|_G5754]),
 ifClause(_G5662,_G5754,_G5768),
 buildECAcondition(_G5662,_G5643,_G5768,[ident('DO')|_G5814]),
 buildECAactionList(_G5644,_G5814,_G5828),
 optELSEactionList(_G5645,_G5828,_G5712) .

ifClause('IFNEW',[ident('IFNEW')|_G5885],_G5885)  :-
 true .

ifClause('IFNEW',[ident('IF'),ident('NEW')|_G5939],_G5939)  :-
 ! .

ifClause('IF',[ident('IF')|_G5980],_G5980)  :-
 true .

optELSEactionList(_G5996,[ident('ELSE')|_G6037],_G6023)  :-
 buildECAactionList(_G5996,_G6037,_G6023) .

optELSEactionList([noop],_G6083,_G6083)  :-
 true .

buildECAevent(_G6099,_G6147,_G6150)  :-
 'ECAeventOperation'(_G6101,_G6147,['('|_G6189]),
 lit(_G6106,_G6189,[')'|_G6150]),
 makeECAevent(_G6101,_G6106,_G6099),
 ! .

buildECAevent(_G6222,_G6258,_G6261)  :-
 'ECAeventOperation'(_G6224,_G6258,_G6286),
 lit(_G6226,_G6286,_G6261),
 makeECAevent(_G6224,_G6226,_G6222),
 ! .

buildECAevent(_G6327,[ident(_G6329),'('|_G6424],_G6407)  :-
 memberchk(_G6329,['Ask',ask]),
 litarg(_G6351,_G6424,[')'|_G6407]),
 resolveDeriveExpression('In'('_tempvarxyz',_G6351),_G6360),
 makeECAevent('Ask',_G6360,_G6327),
 ! .

buildECAevent(_G6463,[ident(_G6465)|_G6545],_G6531)  :-
 memberchk(_G6465,['Ask',ask]),
 litarg(_G6484,_G6545,_G6531),
 resolveDeriveExpression('In'('_tempvarxyz',_G6484),_G6490),
 makeECAevent('Ask',_G6490,_G6463),
 ! .

buildECAcondition(_G6581,_G6582,[ident(_G6582)|_G6627],_G6627)  :-
 memberchk(_G6582,[true,false]),
 ! .

buildECAcondition(_G6650,_G6651,_G6685,_G6688)  :-
 'ECAconditionFormula'(_G6653,_G6685,_G6688),
 makeECAcondition(_G6650,_G6653,_G6651),
 ! .

'ECAconditionFormula'(_G6733,['('|_G6778],_G6764)  :-
 'ECAconditionFormula'(_G6733,_G6778,[')'|_G6764]),
 true .

'ECAconditionFormula'(_G6808,_G6830,_G6833)  :-
 'ECAconditionFormula1'(_G6810,_G6830,_G6858),
 'ECAconditionFormula2'(_G6810,_G6808,_G6858,_G6833) .

'ECAconditionFormula1'(_G6900,_G6916,_G6919)  :-
 ecalit(_G6900,_G6916,_G6919) .

'ECAconditionFormula1'(not(_G6954),[ident(not)|_G7005],_G6991)  :-
 ecalit(_G6954,_G7005,_G6991),
 ! .

'ECAconditionFormula1'(not(_G7032),[ident(not),'('|_G7090],_G7073)  :-
 'ECAconditionFormula'(_G7032,_G7090,[')'|_G7073]),
 true .

'ECAconditionFormula2'(_G7120,and(_G7120,_G7121),[ident(and)|_G7172],_G7154)  :-
 'ECAconditionFormula'(_G7121,_G7172,_G7154) .

'ECAconditionFormula2'(_G7196,or(_G7196,_G7197),[ident(or)|_G7248],_G7230)  :-
 'ECAconditionFormula'(_G7197,_G7248,_G7230) .

'ECAconditionFormula2'(_G7272,_G7272,_G7295,_G7295)  :-
 true .

buildECAactionList([_G7315|_G7316],_G7339,_G7342)  :-
 'ECAaction'(_G7315,_G7339,_G7367),
 buildECAactionList_rest(_G7316,_G7367,_G7342) .

buildECAactionList_rest(_G7402,[','|_G7449],_G7435)  :-
 !,
 buildECAactionList(_G7402,_G7449,_G7435) .

buildECAactionList_rest([],_G7495,_G7495)  :-
 ! .

'ECAaction'(noop,[ident(noop)|_G7541],_G7541)  :-
 ! .

'ECAaction'(noop,[ident(commit)|_G7587],_G7587)  :-
 ! .

'ECAaction'(reject,[ident(reject)|_G7633],_G7633)  :-
 ! .

'ECAaction'(tBegin,[ident(tBegin)|_G33],_G33)  :-
 ! .

'ECAaction'(tEnd,[ident(tEnd)|_G79],_G79)  :-
 ! .

'ECAaction'(_G95,_G143,_G146)  :-
 'ECAactionOperation'(_G97,_G143,['('|_G185]),
 ecalit(_G102,_G185,[')'|_G146]),
 makeECAaction(_G97,_G102,_G95),
 ! .

'ECAaction'(_G218,_G254,_G257)  :-
 'ECAactionOperation'(_G220,_G254,_G282),
 ecalit(_G222,_G282,_G257),
 makeECAaction(_G220,_G222,_G218),
 ! .

'ECAaction'(_G323,[ident(_G325),'('|_G411],_G394)  :-
 memberchk(_G325,['Raise',raise]),
 deriveExpression(_G347,_G411,[')'|_G394]),
 makeECAaction('Raise',_G347,_G323),
 ! .

'ECAaction'(_G447,[ident(_G449)|_G520],_G506)  :-
 memberchk(_G449,['Raise',raise]),
 deriveExpression(_G468,_G520,_G506),
 makeECAaction('Raise',_G468,_G447),
 ! .

'ECAaction'(_G553,[ident(_G555),ident(_G574)|_G615],_G615)  :-
 memberchk(_G555,['Raise',raise]),
 makeECAaction(_G555,_G574,_G553),
 ! .

'ECAeventOperation'(_G640,[ident(_G640)|_G688],_G688)  :-
 memberchk(_G640,['Tell','Untell',tell,untell]),
 ! .

'ECAactionOperation'(_G707,[ident(_G707)|_G776],_G776)  :-
 memberchk(_G707,['Tell','Untell','Retell','Ask','Call','CALL',tell,untell,retell,ask,call]),
 ! .

ecalit(new(_G795),[ident(new),'('|_G853],_G836)  :-
 lit(_G795,_G853,[')'|_G836]),
 true .

ecalit(new(_G883),[_G887|_G935],_G921)  :-
 pc_ascii(_G887,96),
 lit(_G883,_G935,_G921) .

ecalit(_G962,_G978,_G981)  :-
 lit(_G962,_G978,_G981) .

bulkQueryCall(bulkquery(_G1016),[ident(bulk),'['|_G1078],_G1061)  :-
 bulkArgList(_G1016,_G1078,_G1061),
 temp_msp(_G1030) .

bulkArgList([_G1105],_G1130,_G1133)  :-
 bulkArg(_G1105,_G1130,[']'|_G1133]),
 true .

bulkArgList([_G1174|_G1175],_G1204,_G1207)  :-
 bulkArg(_G1174,_G1204,[','|_G1246]),
 bulkArgList(_G1175,_G1246,_G1207) .

bulkArg(plainarg(_G1270),_G1296,_G1299)  :-
 constantval(_G1270,_G1296,_G1299),
 ! .

bulkArg(plainarg(_G1337),_G1363,_G1366)  :-
 selectExpression(_G1337,_G1363,_G1366),
 ! .

bulkArg(plainarg(_G1404),_G1430,_G1433)  :-
 objectname(_G1404,_G1430,_G1433),
 ! .

bulkArg(unknown(_G1471),_G1497,_G1500)  :-
 falseSelectExpression(_G1471,_G1497,_G1500),
 ! .

bulkArg(unknown(_G1538),_G1564,_G1567)  :-
 simplelabel(_G1538,_G1564,_G1567),
 ! .

falseSelectExpression(select(_G1605,_G1606,_G1607),_G1667,_G1670)  :-
 anyArg(_G1605,_G1667,[select(_G1606)|_G1709]),
 anyArg(_G1607,_G1709,_G1670),
 memberchk(_G1606,[->,=>,!,^,@]),
 ! .

falseSelectExpression(_G1739,['('|_G1784],_G1770)  :-
 falseSelectExpression(_G1739,_G1784,[')'|_G1770]),
 true .

anyArg(_G1814,_G1830,_G1833)  :-
 simplelabel(_G1814,_G1830,_G1833) .

anyArg(_G1868,[string(_G1868)|_G1890],_G1890)  :-
 true .

anyArg(_G1906,[intNumber(_G1906)|_G1928],_G1928)  :-
 true .

anyArg(_G1944,[realNumber(_G1944)|_G1966],_G1966)  :-
 true .

anyArg(_G1982,[falseSelectExpression(_G1982)|_G2004],_G2004)  :-
 true .

buildQuerycall(class(_G2020),_G2046,_G2049)  :-
 bulkQueryCall(_G2020,_G2046,_G2049),
 ! .

buildQuerycall(class(_G2087),_G2105,_G2108)  :-
 arExpr(_G2087,_G2105,_G2108) .

buildQuerycall(class(_G2143),_G2161,_G2164)  :-
 deriveExpression(_G2143,_G2161,_G2164) .

convertSelectExpression(_G2199,_G2215,_G2218)  :-
 selectExpression(_G2199,_G2215,_G2218) .

convertSelectExpression(_G2253,_G2269,_G2272)  :-
 objectname(_G2253,_G2269,_G2272) .
