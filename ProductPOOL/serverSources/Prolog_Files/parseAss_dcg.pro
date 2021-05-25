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
 typename(_G4090,_G4106,_G4109) .

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

typename(_G4388,[ident(_G4390)|_G4487],_G4487)  :-
 (
 \+memberchk(_G4390,['Known',new,'UNIFIES',in,isA,not,'In',forall,exists,'IDENTICAL','Ai']),
 temp_msp(_G4433),
 t_name2id(_G4433,_G4390,_G4388),
 !;
 report_error('PFNFE',parseAss_dcg,[_G4390]),
 !,
 fail) .

constantval(_G4503,[realNumber(_G4505)|_G4537],_G4537)  :-
 create_if_builtin_object(_G4505,'Real',_G4503) .

constantval(_G4553,[intNumber(_G4555)|_G4587],_G4587)  :-
 create_if_builtin_object(_G4555,'Integer',_G4553) .

constantval(_G4603,[string(_G4605)|_G4637],_G4637)  :-
 create_if_builtin_object(_G4605,'String',_G4603) .

label(_G4653,[ident(_G4653)|_G4701],_G4701)  :-
 temp_msp(_G4660),
 prove_literal('Mod'('P'(_G4665,_G4666,_G4653,_G4668),_G4660)),
 ! .

label(_G4723,[string(_G4723)|_G4771],_G4771)  :-
 temp_msp(_G4730),
 prove_literal('Mod'('P'(_G4735,_G4736,_G4723,_G4738),_G4730)),
 ! .

variableOrLabel(_G4793,[ident(_G4795)|_G4835],_G4835)  :-
 (
 isVariable(_G4795,_G4793),
 !;
 _G4793=_G4795) .

simplelabel(_G4851,[ident(_G4851)|_G4873],_G4873)  :-
 true .

typelist([_G4889|_G4890],_G4919,_G4922)  :-
 type(_G4889,_G4919,[','|_G4961]),
 typelist(_G4890,_G4961,_G4922) .

typelist([_G4985],_G5004,_G5007)  :-
 type(_G4985,_G5004,_G5007) .

type('VAR',[ident('VAR')|_G5072],_G5072)  :-
 ! .

type(_G5088,_G5121,_G5124)  :-
 'M_SearchSpace'(_G5090),
 pc_update(t_msp(_G5090)),
 typeExpr(_G5088,_G5121,_G5124) .

deriveExpression(_G5168,_G5184,_G5187)  :-
 listModExpression(_G5168,_G5184,_G5187) .

deriveExpression(_G5222,_G5238,_G5241)  :-
 countExpr(_G5222,_G5238,_G5241) .

deriveExpression(_G5276,_G5292,_G5295)  :-
 shortFunctionCall(_G5276,_G5292,_G5295) .

deriveExpression(_G5330,_G5346,_G5349)  :-
 shortQueryCall(_G5330,_G5346,_G5349) .

deriveExpression(_G5384,_G5400,_G5403)  :-
 regularDeriveExpression(_G5384,_G5400,_G5403) .

regularDeriveExpression(derive(_G5438,_G5439),[ident(_G5443),'['|_G5514],_G5497)  :-
 dExpList(_G5439,_G5514,[']'|_G5497]),
 temp_msp(_G5456),
 t_name2id(_G5456,_G5443,_G5438) .

listModExpression(derive(_G5547,_G5548),[ident(listModule),'['|_G5626],_G5609)  :-
 modExpr(_G5548,_G5626,[']'|_G5609]),
 !,
 temp_msp(_G5568),
 t_name2id(_G5568,listModule,_G5547) .

modExpr([substitute(_G5662,module)],_G5706,_G5709)  :-
 modPath(_G5662,_G5706,[/,ident(module)|_G5709]),
 ! .

modExpr([substitute(_G5753,module)],_G5775,_G5778)  :-
 modPath(_G5753,_G5775,_G5778) .

modPath(_G5813,_G5837,_G5840)  :-
 modPathMin(_G5813,_G5837,_G5840),
 ! .

modPath(_G5878,_G5902,_G5905)  :-
 modPathSlash(_G5878,_G5902,_G5905),
 ! .

modPathMin(_G5943,[ident(_G5945),-|_G6016],_G5999)  :-
 modPathMin(_G5953,_G6016,_G5999),
 !,
 pc_atomconcat([_G5945,-,_G5953],_G5943) .

modPathMin(_G6046,[ident(_G6046)|_G6068],_G6068)  :-
 true .

modPathSlash(_G6084,[ident(_G6084),/,ident(module)|_G6128],_G6128)  :-
 ! .

modPathSlash(_G6150,[ident(_G6152),/|_G6223],_G6206)  :-
 modPathSlash(_G6160,_G6223,_G6206),
 !,
 pc_atomconcat([_G6152,/,_G6160],_G6150) .

modPathSlash(_G6253,[ident(_G6253)|_G6286],_G6286)  :-
 _G6253\=module .

countExpr(derive(_G6308,[substitute(_G6302,class)]),[#|_G6367],_G6353)  :-
 litarg(_G6302,_G6367,_G6353),
 temp_msp(_G6318),
 t_name2id(_G6318,'COUNT',_G6308) .

shortFunctionCall(derive(_G6397,[]),[ident(_G6402),'(',')'|_G6451],_G6451)  :-
 temp_msp(_G6413),
 t_name2id(_G6413,_G6402,_G6397) .

shortFunctionCall(derive(_G6476,_G6477),[ident(_G6481),'('|_G6564],_G6547)  :-
 shortdExpList(_G6489,_G6564,[')'|_G6547]),
 temp_msp(_G6494),
 t_name2id(_G6494,_G6481,_G6476),
 isFunction(_G6476),
 plainToSubsts(_G6476,_G6489,_G6477) .

shortQueryCall(derive(_G6603,_G6604),[ident(_G6608),'['|_G6686],_G6669)  :-
 shortdExpList(_G6616,_G6686,[']'|_G6669]),
 temp_msp(_G6621),
 t_name2id(_G6621,_G6608,_G6603),
 plainToSubsts(_G6603,_G6616,_G6604) .

arExpr(_G6722,_G6762,_G6765)  :-
 arTerm(_G6724,_G6762,_G6790),
 arAddExpr(add(_G6726,_G6727),_G6790,_G6765),
 makeAddition(_G6724,_G6726,_G6727,_G6722),
 ! .

arExpr(_G6831,_G6885,_G6888)  :-
 arTerm(_G6833,_G6885,[intNumber(_G6835)|_G6888]),
 pc_atomconcat(-,_G6841,_G6835),
 create_if_builtin_object(_G6841,'Integer',_G6849),
 makeAddition(_G6833,-,_G6849,_G6831),
 ! .

arExpr(_G6938,_G6954,_G6957)  :-
 arTerm(_G6938,_G6954,_G6957) .

arAddExpr(add(_G6992,_G6993),_G7040,_G7043)  :-
 arAddOp(_G6992,_G7040,_G7068),
 arTerm(_G6999,_G7068,_G7093),
 arAddExpr(add(_G7001,_G7002),_G7093,_G7043),
 makeAddition(_G6999,_G7001,_G7002,_G6993),
 ! .

arAddExpr(add(_G7134,_G7135),_G7158,_G7161)  :-
 arAddOp(_G7134,_G7158,_G7186),
 arTerm(_G7135,_G7186,_G7161) .

arTerm(_G7221,_G7261,_G7264)  :-
 arFactor(_G7223,_G7261,_G7289),
 arMultTerm(mult(_G7225,_G7226),_G7289,_G7264),
 makeMultiplication(_G7223,_G7225,_G7226,_G7221),
 ! .

arTerm(_G7330,_G7346,_G7349)  :-
 arFactor(_G7330,_G7346,_G7349) .

arMultTerm(mult(_G7384,_G7385),_G7432,_G7435)  :-
 arMulOp(_G7384,_G7432,_G7460),
 arFactor(_G7391,_G7460,_G7485),
 arMultTerm(mult(_G7393,_G7394),_G7485,_G7435),
 makeMultiplication(_G7391,_G7393,_G7394,_G7385),
 ! .

arMultTerm(mult(_G7526,_G7527),_G7550,_G7553)  :-
 arMulOp(_G7526,_G7550,_G7578),
 arFactor(_G7527,_G7578,_G7553) .

arFactor(_G3,_G20,_G21)  :-
 funcExpr(_G3,_G20,_G21),
 ! .

arFactor(_G47,_G71,_G74)  :-
 constantval(_G47,_G71,_G74),
 ! .

arFactor(_G112,_G128,_G131)  :-
 variableOrObject(_G112,_G128,_G131) .

arFactor(_G166,['('|_G219],_G205)  :-
 arExpr(_G166,_G219,[')'|_G205]),
 ! .

arAddOp(+,[+|_G269],_G269)  :-
 true .

arAddOp(-,[-|_G305],_G305)  :-
 true .

arMulOp(*,[*|_G341],_G341)  :-
 true .

arMulOp(/,[/|_G377],_G377)  :-
 true .

dExpList([_G393],_G412,_G415)  :-
 dExp(_G393,_G412,_G415) .

dExpList([_G450|_G451],_G480,_G483)  :-
 dExp(_G450,_G480,[','|_G522]),
 dExpList(_G451,_G522,_G483) .

dExp(substitute(_G546,_G547),_G579,_G582)  :-
 litarg(_G546,_G579,[/,ident(_G547)|_G582]),
 true .

dExp(specialize(_G626,_G627),_G659,_G662)  :-
 litarg(_G626,_G659,[:,ident(_G627)|_G662]),
 true .

shortdExpList([_G706],_G725,_G728)  :-
 shortdExp(_G706,_G725,_G728) .

shortdExpList([_G763|_G764],_G793,_G796)  :-
 shortdExp(_G763,_G793,[','|_G835]),
 shortdExpList(_G764,_G835,_G796) .

shortdExp(plainarg(_G859),_G877,_G880)  :-
 litarg(_G859,_G877,_G880) .

funcExpr(derive(_G915,_G916),[ident(_G920),'('|_G1003],_G986)  :-
 funcArgList(_G928,_G1003,[')'|_G986]),
 temp_msp(_G933),
 t_name2id(_G933,_G920,_G915),
 isFunction(_G915),
 plainToSubsts(_G915,_G928,_G916) .

funcExpr(_G1042,_G1058,_G1061)  :-
 countExpr(_G1042,_G1058,_G1061) .

funcExpr(_G1096,_G1112,_G1115)  :-
 shortFunctionCall(_G1096,_G1112,_G1115) .

funcArgList([_G1150],_G1169,_G1172)  :-
 funcArg(_G1150,_G1169,_G1172) .

funcArgList([_G1207|_G1208],_G1237,_G1240)  :-
 funcArg(_G1207,_G1237,[','|_G1279]),
 funcArgList(_G1208,_G1279,_G1240) .

funcArg(plainarg(_G1303),_G1321,_G1324)  :-
 arExpr(_G1303,_G1321,_G1324) .

funcArg(plainarg(_G1359),_G1377,_G1380)  :-
 arFactor(_G1359,_G1377,_G1380) .

selectExpression(_G1415,_G1474,_G1477)  :-
 idorexp(_G1417,_G1474,[select(_G1419)|_G1516]),
 idorexp(_G1424,_G1516,_G1530),
 memberchk(_G1419,[->,=>]),
 !,
 selectExpression2(_G1415,select(_G1417,_G1419,_G1424),_G1530,_G1477) .

selectExpression(_G1581,_G1638,_G1641)  :-
 idorexp(_G1583,_G1638,[select(_G1585)|_G1680]),
 idorexp(_G1590,_G1680,_G1694),
 temp_msp(_G1592),
 eval(_G1592,select(_G1583,_G1585,_G1590),replaceSelectExpression,_G1604),
 selectExpression2(_G1581,_G1604,_G1694,_G1641) .

selectExpression(_G1745,['('|_G1790],_G1776)  :-
 selectExpression(_G1745,_G1790,[')'|_G1776]),
 true .

selectExpression2(_G1824,select(_G1820,_G1821,_G1822),[select(_G1827)|_G1940],_G1922)  :-
 idorexp(_G1832,_G1940,_G1954),
 memberchk(_G1821,[->,=>]),
 memberchk(_G1827,[!,^,@]),
 !,
 temp_msp(_G1866),
 eval(_G1866,select(_G1822,_G1827,_G1832),replaceSelectExpression,_G1878),
 selectExpression2(_G1824,select(_G1820,_G1821,_G1878),_G1954,_G1922) .

selectExpression2(_G2024,select(_G2020,_G2021,_G2022),[select(_G2027)|_G2137],_G2119)  :-
 idorexp(_G2032,_G2137,_G2151),
 memberchk(_G2021,[->,=>]),
 memberchk(_G2027,[->,=>]),
 !,
 temp_msp(_G2063),
 eval(_G2063,select(_G2020,_G2021,_G2022),replaceSelectExpression,_G2075),
 selectExpression2(_G2024,select(_G2075,_G2027,_G2032),_G2151,_G2119) .

selectExpression2(_G2217,_G2218,[select(_G2220)|_G2296],_G2278)  :-
 memberchk(_G2220,[->,=>]),
 !,
 idorexp(_G2242,_G2296,_G2313),
 selectExpression2(_G2217,select(_G2218,_G2220,_G2242),_G2313,_G2278) .

selectExpression2(_G2361,_G2362,[select(_G2364)|_G2438],_G2420)  :-
 idorexp(_G2369,_G2438,_G2452),
 temp_msp(_G2371),
 eval(_G2371,select(_G2362,_G2364,_G2369),replaceSelectExpression,_G2383),
 selectExpression2(_G2361,_G2383,_G2452,_G2420) .

selectExpression2(_G2507,select(_G2503,_G2504,_G2505),_G2547,_G2547)  :-
 !,
 temp_msp(_G2513),
 eval(_G2513,select(_G2503,_G2504,_G2505),replaceSelectExpression,_G2507) .

selectExpression2(_G2573,_G2574,_G2599,_G2599)  :-
 _G2573=_G2574 .

idorexp(_G2619,_G2635,_G2638)  :-
 label(_G2619,_G2635,_G2638) .

idorexp(_G2673,[intNumber(_G2673)|_G2695],_G2695)  :-
 true .

idorexp(_G2711,[realNumber(_G2711)|_G2733],_G2733)  :-
 true .

idorexp(_G2749,['('|_G2794],_G2780)  :-
 selectExpression(_G2749,_G2794,[')'|_G2780]),
 true .

elemSelectExpB(_G2824,_G2888,_G2891)  :-
 litarg(_G2826,_G2888,[ident(in)|_G2930]),
 selectexpb(_G2833,_G2930,_G2891),
 !,
 replaceSelectExpB(_G2833,_G2826,_G2840,_G2841),
 _G2824=and([lit('In'(_G2826,_G2840)),_G2841]) .

elemSelectExpB(_G2963,_G3053,_G3056)  :-
 selectexpb(_G2965,_G3053,[ident(isA)|_G3095]),
 selectexpb(_G2972,_G3095,_G3056),
 !,
 createNewVarname(_G2977),
 replaceSelectExpB(_G2965,_G2977,_G2984,_G2985),
 replaceSelectExpB(_G2972,_G2977,_G2992,_G2993),
 'VarTabInsert'([_G2977],[_G2984]),
 expandQuantifier(forall,vtype([_G2977],[_G2984]),impl(_G2985,_G2993),_G2963) .

elemSelectExpB(_G3137,_G3236,_G3239)  :-
 selectexpb(_G3139,_G3236,[=|_G3278]),
 selectexpb(_G3144,_G3278,_G3239),
 !,
 createNewVarname(_G3149),
 replaceSelectExpB(_G3139,_G3149,_G3156,_G3157),
 replaceSelectExpB(_G3144,_G3149,_G3164,_G3165),
 'VarTabInsert'([_G3149],[_G3156]),
 expandQuantifier(forall,vtype([_G3149],[_G3156]),and([impl(_G3157,_G3165),impl(_G3165,_G3157)]),_G3137) .

selectexpb(selectExpB(_G3320,_G3321,_G3322),[ident(_G3320),select2(_G3321)|_G3376],_G3359)  :-
 selectexpb2(_G3322,_G3376,_G3359) .

selectexpb(selectExpB(_G3400,_G3401,_G3402),[ident(_G3400),select2(_G3401)|_G3456],_G3439)  :-
 restriction(_G3402,_G3456,_G3439) .

selectexpb(selectExpB(_G3480,_G3481,_G3482),[ident(_G3480),select2(_G3481),ident(_G3482)|_G3522],_G3522)  :-
 true .

selectexpb2(_G3544,_G3560,_G3563)  :-
 selectexpb(_G3544,_G3560,_G3563) .

selectexpb2(selectExpB(_G3598,_G3599,_G3600),_G3631,_G3634)  :-
 restriction(_G3598,_G3631,[select2(_G3599)|_G3673]),
 selectexpb2(_G3600,_G3673,_G3634) .

selectexpb2(selectExpB(_G3697,_G3698,_G3699),_G3730,_G3733)  :-
 restriction(_G3697,_G3730,[select2(_G3698)|_G3772]),
 restriction(_G3699,_G3772,_G3733) .

selectexpb2(selectExpB(_G3796,_G3797,_G3798),_G3832,_G3835)  :-
 restriction(_G3796,_G3832,[select2(_G3797),ident(_G3798)|_G3835]),
 true .

restriction(restriction(_G3879,_G3880),['(',ident(_G3879),:,ident(_G3880),')'|_G3930],_G3930)  :-
 true .

restriction(restriction(_G3958,_G3959),['(',ident(_G3958),:|_G4026],_G4006)  :-
 selectExpression(_G3959,_G4026,[')'|_G4006]),
 true .

restriction(restriction(_G4056,_G4057),['(',ident(_G4056),:|_G4124],_G4104)  :-
 selectexpb(_G4057,_G4124,[')'|_G4104]),
 true .

restriction(restriction(_G4156,enumeration(_G4154)),['(',ident(_G4156),:,'['|_G4239],_G4216)  :-
 enumeration(_G4154,_G4239,[']',')'|_G4216]),
 true .

enumeration([class(_G4272)],_G4293,_G4296)  :-
 litarg(_G4272,_G4293,_G4296) .

enumeration([class(_G4331)],_G4352,_G4355)  :-
 selectExpression(_G4331,_G4352,_G4355) .

enumeration(_G4390,_G4434,_G4437)  :-
 litarg(_G4392,_G4434,[','|_G4476]),
 enumeration(_G4397,_G4476,_G4437),
 append([class(_G4392)],_G4397,_G4390) .

enumeration(_G4503,_G4547,_G4550)  :-
 selectExpression(_G4505,_G4547,[','|_G4589]),
 enumeration(_G4510,_G4589,_G4550),
 append([class(_G4505)],_G4510,_G4503) .

foralls(_G4616,_G4617,_G4662,_G4665)  :-
 forall(_G4619,_G4620,_G4662,_G4697),
 foralls(_G4622,_G4623,_G4697,_G4665),
 append(_G4619,_G4622,_G4616),
 append(_G4620,_G4623,_G4617) .

foralls([],[],_G4772,_G4772)  :-
 true .

forall(_G4792,_G4793,[ident(forall)|_G4842],_G4824)  :-
 vartypelist(_G4792,_G4793,_G4842,_G4824) .

buildECArule(ecarule(_G4873,_G4874,_G4875,_G4876,_G4877),_G4915,_G4918)  :-
 optvartypelist(_G4881,[],_G4915,[ident('ON')|_G4964]),
 buildECAruleHelper(ecarule(_G4873,_G4874,_G4875,_G4876,_G4877),_G4964,_G4918) .

buildECAruleHelper(ecarule(_G4991,true,_G4993,[noop],currentqueue),_G5026,_G5029)  :-
 buildECAevent(_G4991,_G5026,[ident('DO')|_G5068]),
 buildECAactionList(_G4993,_G5068,_G5029) .

buildECAruleHelper(ecarule(_G5092,_G5093,_G5094,_G5095,currentqueue),_G5143,_G5146)  :-
 buildECAevent(_G5092,_G5143,_G5171),
 ifClause(_G5102,_G5171,_G5196),
 buildECAcondition(_G5102,_G5093,_G5196,[ident('DO')|_G5242]),
 buildECAactionList(_G5094,_G5242,_G5256),
 optELSEactionList(_G5095,_G5256,_G5146) .

buildECAruleHelper(ecarule(_G5294,true,_G5296,[noop],q1),[ident('TRANSACTIONAL')|_G5354],_G5340)  :-
 buildECAevent(_G5294,_G5354,[ident('DO')|_G5382]),
 buildECAactionList(_G5296,_G5382,_G5340) .

buildECAruleHelper(ecarule(_G5406,_G5407,_G5408,_G5409,q1),[ident('TRANSACTIONAL')|_G5482],_G5468)  :-
 buildECAevent(_G5406,_G5482,_G5496),
 ifClause(_G5421,_G5496,_G5521),
 buildECAcondition(_G5421,_G5407,_G5521,[ident('DO')|_G5567]),
 buildECAactionList(_G5408,_G5567,_G5581),
 optELSEactionList(_G5409,_G5581,_G5468) .

buildECAruleHelper(ecarule(_G5619,true,_G5621,[noop],_G5623),_G5675,_G5678)  :-
 buildECAevent(_G5619,_G5675,[ident('FOR'),ident(_G5623),ident('DO')|_G5723]),
 buildECAactionList(_G5621,_G5723,_G5737),
 optELSEactionList(_G5646,_G5737,_G5678) .

buildECAruleHelper(ecarule(_G5772,_G5773,_G5774,_G5775,_G5776),_G5839,_G5842)  :-
 buildECAevent(_G5772,_G5839,[ident('FOR'),ident(_G5776)|_G5884]),
 ifClause(_G5792,_G5884,_G5898),
 buildECAcondition(_G5792,_G5773,_G5898,[ident('DO')|_G5944]),
 buildECAactionList(_G5774,_G5944,_G5958),
 optELSEactionList(_G5775,_G5958,_G5842) .

ifClause('IFNEW',[ident('IFNEW')|_G6015],_G6015)  :-
 true .

ifClause('IFNEW',[ident('IF'),ident('NEW')|_G6069],_G6069)  :-
 ! .

ifClause('IF',[ident('IF')|_G6110],_G6110)  :-
 true .

optELSEactionList(_G6126,[ident('ELSE')|_G6167],_G6153)  :-
 buildECAactionList(_G6126,_G6167,_G6153) .

optELSEactionList([noop],_G6213,_G6213)  :-
 true .

buildECAevent(_G6229,_G6277,_G6280)  :-
 'ECAeventOperation'(_G6231,_G6277,['('|_G6319]),
 lit(_G6236,_G6319,[')'|_G6280]),
 makeECAevent(_G6231,_G6236,_G6229),
 ! .

buildECAevent(_G6352,_G6388,_G6391)  :-
 'ECAeventOperation'(_G6354,_G6388,_G6416),
 lit(_G6356,_G6416,_G6391),
 makeECAevent(_G6354,_G6356,_G6352),
 ! .

buildECAevent(_G6457,[ident(_G6459),'('|_G6554],_G6537)  :-
 memberchk(_G6459,['Ask',ask]),
 litarg(_G6481,_G6554,[')'|_G6537]),
 resolveDeriveExpression('In'('_tempvarxyz',_G6481),_G6490),
 makeECAevent('Ask',_G6490,_G6457),
 ! .

buildECAevent(_G6593,[ident(_G6595)|_G6675],_G6661)  :-
 memberchk(_G6595,['Ask',ask]),
 litarg(_G6614,_G6675,_G6661),
 resolveDeriveExpression('In'('_tempvarxyz',_G6614),_G6620),
 makeECAevent('Ask',_G6620,_G6593),
 ! .

buildECAcondition(_G6711,_G6712,[ident(_G6712)|_G6757],_G6757)  :-
 memberchk(_G6712,[true,false]),
 ! .

buildECAcondition(_G6780,_G6781,_G6815,_G6818)  :-
 'ECAconditionFormula'(_G6783,_G6815,_G6818),
 makeECAcondition(_G6780,_G6783,_G6781),
 ! .

'ECAconditionFormula'(_G6863,['('|_G6908],_G6894)  :-
 'ECAconditionFormula'(_G6863,_G6908,[')'|_G6894]),
 true .

'ECAconditionFormula'(_G6938,_G6960,_G6963)  :-
 'ECAconditionFormula1'(_G6940,_G6960,_G6988),
 'ECAconditionFormula2'(_G6940,_G6938,_G6988,_G6963) .

'ECAconditionFormula1'(_G7030,_G7046,_G7049)  :-
 ecalit(_G7030,_G7046,_G7049) .

'ECAconditionFormula1'(not(_G7084),[ident(not)|_G7135],_G7121)  :-
 ecalit(_G7084,_G7135,_G7121),
 ! .

'ECAconditionFormula1'(not(_G7162),[ident(not),'('|_G7220],_G7203)  :-
 'ECAconditionFormula'(_G7162,_G7220,[')'|_G7203]),
 true .

'ECAconditionFormula2'(_G7250,and(_G7250,_G7251),[ident(and)|_G7302],_G7284)  :-
 'ECAconditionFormula'(_G7251,_G7302,_G7284) .

'ECAconditionFormula2'(_G7326,or(_G7326,_G7327),[ident(or)|_G7378],_G7360)  :-
 'ECAconditionFormula'(_G7327,_G7378,_G7360) .

'ECAconditionFormula2'(_G7402,_G7402,_G7425,_G7425)  :-
 true .

buildECAactionList([_G7445|_G7446],_G7469,_G7472)  :-
 'ECAaction'(_G7445,_G7469,_G7497),
 buildECAactionList_rest(_G7446,_G7497,_G7472) .

buildECAactionList_rest(_G7532,[','|_G7579],_G7565)  :-
 !,
 buildECAactionList(_G7532,_G7579,_G7565) .

buildECAactionList_rest([],_G7625,_G7625)  :-
 ! .

'ECAaction'(noop,[ident(noop)|_G31],_G31)  :-
 ! .

'ECAaction'(noop,[ident(commit)|_G77],_G77)  :-
 ! .

'ECAaction'(reject,[ident(reject)|_G123],_G123)  :-
 ! .

'ECAaction'(tBegin,[ident(tBegin)|_G169],_G169)  :-
 ! .

'ECAaction'(tEnd,[ident(tEnd)|_G215],_G215)  :-
 ! .

'ECAaction'(_G231,_G279,_G282)  :-
 'ECAactionOperation'(_G233,_G279,['('|_G321]),
 ecalit(_G238,_G321,[')'|_G282]),
 makeECAaction(_G233,_G238,_G231),
 ! .

'ECAaction'(_G354,_G390,_G393)  :-
 'ECAactionOperation'(_G356,_G390,_G418),
 ecalit(_G358,_G418,_G393),
 makeECAaction(_G356,_G358,_G354),
 ! .

'ECAaction'(_G459,[ident(_G461),'('|_G547],_G530)  :-
 memberchk(_G461,['Raise',raise]),
 deriveExpression(_G483,_G547,[')'|_G530]),
 makeECAaction('Raise',_G483,_G459),
 ! .

'ECAaction'(_G583,[ident(_G585)|_G656],_G642)  :-
 memberchk(_G585,['Raise',raise]),
 deriveExpression(_G604,_G656,_G642),
 makeECAaction('Raise',_G604,_G583),
 ! .

'ECAaction'(_G689,[ident(_G691),ident(_G710)|_G751],_G751)  :-
 memberchk(_G691,['Raise',raise]),
 makeECAaction(_G691,_G710,_G689),
 ! .

'ECAeventOperation'(_G776,[ident(_G776)|_G824],_G824)  :-
 memberchk(_G776,['Tell','Untell',tell,untell]),
 ! .

'ECAactionOperation'(_G843,[ident(_G843)|_G912],_G912)  :-
 memberchk(_G843,['Tell','Untell','Retell','Ask','Call','CALL',tell,untell,retell,ask,call]),
 ! .

ecalit(new(_G931),[ident(new),'('|_G989],_G972)  :-
 lit(_G931,_G989,[')'|_G972]),
 true .

ecalit(new(_G1019),[_G1023|_G1071],_G1057)  :-
 pc_ascii(_G1023,96),
 lit(_G1019,_G1071,_G1057) .

ecalit(_G1098,_G1114,_G1117)  :-
 lit(_G1098,_G1114,_G1117) .

bulkQueryCall(bulkquery(_G1152),[ident(bulk),'['|_G1214],_G1197)  :-
 bulkArgList(_G1152,_G1214,_G1197),
 temp_msp(_G1166) .

bulkArgList([_G1241],_G1266,_G1269)  :-
 bulkArg(_G1241,_G1266,[']'|_G1269]),
 true .

bulkArgList([_G1310|_G1311],_G1340,_G1343)  :-
 bulkArg(_G1310,_G1340,[','|_G1382]),
 bulkArgList(_G1311,_G1382,_G1343) .

bulkArg(plainarg(_G1406),_G1432,_G1435)  :-
 constantval(_G1406,_G1432,_G1435),
 ! .

bulkArg(plainarg(_G1473),_G1499,_G1502)  :-
 selectExpression(_G1473,_G1499,_G1502),
 ! .

bulkArg(plainarg(_G1540),_G1566,_G1569)  :-
 objectname(_G1540,_G1566,_G1569),
 ! .

bulkArg(unknown(_G1607),_G1633,_G1636)  :-
 falseSelectExpression(_G1607,_G1633,_G1636),
 ! .

bulkArg(unknown(_G1674),_G1700,_G1703)  :-
 simplelabel(_G1674,_G1700,_G1703),
 ! .

falseSelectExpression(select(_G1741,_G1742,_G1743),_G1803,_G1806)  :-
 anyArg(_G1741,_G1803,[select(_G1742)|_G1845]),
 anyArg(_G1743,_G1845,_G1806),
 memberchk(_G1742,[->,=>,!,^,@]),
 ! .

falseSelectExpression(_G1875,['('|_G1920],_G1906)  :-
 falseSelectExpression(_G1875,_G1920,[')'|_G1906]),
 true .

anyArg(_G1950,_G1966,_G1969)  :-
 simplelabel(_G1950,_G1966,_G1969) .

anyArg(_G2004,[string(_G2004)|_G2026],_G2026)  :-
 true .

anyArg(_G2042,[intNumber(_G2042)|_G2064],_G2064)  :-
 true .

anyArg(_G2080,[realNumber(_G2080)|_G2102],_G2102)  :-
 true .

anyArg(_G2118,[falseSelectExpression(_G2118)|_G2140],_G2140)  :-
 true .

buildQuerycall(class(_G2156),_G2182,_G2185)  :-
 bulkQueryCall(_G2156,_G2182,_G2185),
 ! .

buildQuerycall(class(_G2223),_G2241,_G2244)  :-
 arExpr(_G2223,_G2241,_G2244) .

buildQuerycall(class(_G2279),_G2297,_G2300)  :-
 deriveExpression(_G2279,_G2297,_G2300) .

convertSelectExpression(_G2335,_G2351,_G2354)  :-
 selectExpression(_G2335,_G2351,_G2354) .

convertSelectExpression(_G2389,_G2405,_G2408)  :-
 objectname(_G2389,_G2405,_G2408) .
