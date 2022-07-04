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

buildMSFOLconstraint('MSFOLconstraint'(_G1154), _G1180, _G1183)  :-
 parseDecl(_G1154, _G1180, _G1183),
 ! .

buildAssertionRule('MSFOLrule'(_G1221, _G1222, _G1223), _G1308, _G1311)  :-
 foralls(_G1227, _G1228, _G1308, _G1339),
 'VarTabLookup_vars'(_G1221),
 buildAssertionRule2(_G1237, _G1223, _G1339, _G1311),
 !,
 (
 _G1228==[],
 _G1222=_G1237;
 _G1228\==[],
 append(_G1228, [_G1237], _G1260),
 _G1222=and(_G1260)),
 validConclusion(_G1223, _G1221) .

buildAssertionRule2(_G1397, _G1398, _G1432, _G1435)  :-
 exp(_G1400, _G1432, _G1435),
 !,
 splitRule(_G1400, _G1397, _G1398) .

buildAssertionTerm('MSFOLassertion'(_G1480), _G1506, _G1509)  :-
 parseDecl(_G1480, _G1506, _G1509),
 ! .

buildAssertionTerm('MSFOLassertion'(_G1547), _G1573, _G1576)  :-
 exp(_G1547, _G1573, _G1576),
 ! .

shortConclusion(lit(_G1614), _G1632, _G1635)  :-
 lit(_G1614, _G1632, _G1635) .

shortConclusion(lit(_G1670), ['('|_G1717], _G1703)  :-
 lit(_G1670, _G1717, [')'|_G1703]),
 true .

parseDecl(_G1747, _G1771, _G1774)  :-
 exp(_G1747, _G1771, _G1774),
 ! .

exp(_G1812, _G1860, _G1863)  :-
 elemexp(_G1814, _G1860, _G1888),
 andexp(_G1814, _G1817, _G1888, _G1916),
 orexp(_G1817, _G1820, _G1916, _G1948),
 implexp(_G1820, _G1823, _G1948, _G1980),
 equivexp(_G1823, _G1812, _G1980, _G1863),
 ! .

elemexp(_G2029, [ident(forall)|_G2121], _G2107)  :-
 vartypelist(_G2036, _G2037, _G2121, _G2138),
 (
 _G2037==[],
 expandQuantifier(forall, _G2036, _G2044, _G2029);
 _G2037\==[],
 append(_G2037, [_G2044], _G2058),
 expandQuantifier(forall, _G2036, and(_G2058), _G2029)),
 exp(_G2044, _G2138, _G2107) .

elemexp(_G2180, [ident(exists)|_G2272], _G2258)  :-
 vartypelist(_G2187, _G2188, _G2272, _G2289),
 (
 _G2188==[],
 expandQuantifier(exists, _G2187, _G2195, _G2180);
 _G2188\==[],
 append(_G2188, [_G2195], _G2209),
 expandQuantifier(exists, _G2187, and(_G2209), _G2180)),
 exp(_G2195, _G2289, _G2258) .

elemexp(not(_G2331), [ident(not)|_G2374], _G2360)  :-
 elemexp(_G2331, _G2374, _G2360) .

elemexp(_G2398, ['('|_G2443], _G2429)  :-
 exp(_G2398, _G2443, [')'|_G2429]),
 true .

elemexp(lit(_G2473), _G2491, _G2494)  :-
 lit(_G2473, _G2491, _G2494) .

elemexp(_G2529, _G2545, _G2548)  :-
 elemSelectExpB(_G2529, _G2545, _G2548) .

vartypelist([_G2583|_G2584], _G2587, _G2628, _G2631)  :-
 vartype(_G2583, _G2590, _G2628, _G2663),
 optvartypelist(_G2584, _G2593, _G2663, _G2631),
 !,
 append(_G2590, _G2593, _G2587) .

optvartypelist(_G2715, _G2716, _G2736, _G2739)  :-
 vartypelist(_G2715, _G2716, _G2736, _G2739) .

optvartypelist([], [], _G2811, _G2811)  :-
 true,
 ! .

vartype(vtype(_G2834, _G2835), _G2838, _G2890, _G2893)  :-
 varlist(_G2834, _G2890, [/|_G2936]),
 selectexpb(_G2845, _G2936, _G2893),
 replaceSelectExpBList(_G2845, _G2834, _G2835, _G2838),
 'VarTabInsert'(_G2834, [_G2835]) .

vartype(vtype(_G2966, _G2967), [], _G3031, _G3034)  :-
 varlist(_G2966, _G3031, [/, '['|_G3080]),
 typelist(_G2967, _G3080, [']'|_G3034]),
 'VarTabInsert'(_G2966, _G2967),
 !,
 containsNoReservedWord(_G2966) .

vartype(vtype(_G3116, _G3117), [], _G3172, _G3175)  :-
 varlist(_G3116, _G3172, [/|_G3218]),
 type(_G3117, _G3218, _G3175),
 'VarTabInsert'(_G3116, [_G3117]),
 !,
 containsNoReservedWord(_G3116) .

varlist([_G3251|_G3252], [ident(_G3251), (',')|_G3318], _G3301)  :-
 varlist(_G3252, _G3318, _G3301),
 !,
 _G3251\=='~this' .

varlist([_G3348], [ident(_G3348)|_G3387], _G3387)  :-
 !,
 _G3348\=='~this' .

andexp(and_h(_G3406), _G3409, [ident(and)|_G3468], _G3450)  :-
 elemexp(_G3416, _G3468, _G3482),
 andexp(and_h([_G3416|_G3406]), _G3409, _G3482, _G3450) .

andexp(_G3524, _G3525, [ident(and)|_G3587], _G3569)  :-
 elemexp(_G3532, _G3587, _G3601),
 andexp(and_h([_G3532, _G3524]), _G3525, _G3601, _G3569) .

andexp(and_h(_G3643), and(_G3645), _G3673, _G3673)  :-
 reverse(_G3643, _G3645) .

andexp(_G3693, _G3694, _G3719, _G3719)  :-
 _G3694=_G3693 .

orexp(or_h(_G3739), _G3742, [ident(or)|_G3807], _G3789)  :-
 elemexp(_G3749, _G3807, _G3821),
 andexp(_G3749, _G3752, _G3821, _G3849),
 orexp(or_h([_G3752|_G3739]), _G3742, _G3849, _G3789) .

orexp(_G3895, _G3896, [ident(or)|_G3964], _G3946)  :-
 elemexp(_G3903, _G3964, _G3978),
 andexp(_G3903, _G3906, _G3978, _G4006),
 orexp(or_h([_G3906, _G3895]), _G3896, _G4006, _G3946) .

orexp(or_h(_G4052), or(_G4054), _G4082, _G4082)  :-
 reverse(_G4052, _G4054) .

orexp(_G4102, _G4103, _G4128, _G4128)  :-
 _G4103=_G4102 .

implexp(_G4148, _G4149, [ (==>)|_G4216], _G4198)  :-
 elemexp(_G4154, _G4216, _G4230),
 andexp(_G4154, _G4157, _G4230, _G4258),
 orexp(_G4157, _G4160, _G4258, _G4290),
 implexp(impl(_G4148, _G4160), _G4149, _G4290, _G4198) .

implexp(_G4336, _G4337, _G4362, _G4362)  :-
 _G4337=_G4336 .

equivexp(_G4382, _G4383, [<==>|_G4467], _G4449)  :-
 elemexp(_G4388, _G4467, _G4481),
 andexp(_G4388, _G4391, _G4481, _G4509),
 orexp(_G4391, _G4394, _G4509, _G4541),
 implexp(_G4394, _G4397, _G4541, _G4573),
 equivexp(and([impl(_G4382, _G4397), impl(_G4397, _G4382)]), _G4383, _G4573, _G4449) .

equivexp(_G4619, _G4620, _G4645, _G4645)  :-
 _G4620=_G4619 .

lit('Mod'(_G4665, _G4666), [ident(_G4670), select(@), ident(_G4700), '('|_G4841], _G4815)  :-
 memberchk(_G4670, ['A', 'A_e', 'Ai', 'A2']),
 name2id(_G4700, _G4666),
 pc_update(t_msp(_G4666)),
 litarg(_G4723, _G4841, [ (',')|_G4869]),
 label(_G4728, _G4869, [ (',')|_G4897]),
 litarg(_G4733, _G4897, [')'|_G4815]),
 _G4665=..[_G4670, _G4723, _G4728, _G4733],
 abolish(t_msp, 1) .

lit(_G4939, [ident(_G4941), '('|_G5087], _G5064)  :-
 memberchk(_G4941, ['A', 'A_e', 'Ai', 'A2']),
 'M_SearchSpace'(_G4964),
 pc_update(t_msp(_G4964)),
 litarg(_G4981, _G5087, [ (',')|_G5115]),
 label(_G4986, _G5115, [ (',')|_G5143]),
 litarg(_G4991, _G5143, [')'|_G5064]),
 _G4939=..[_G4941, _G4981, _G4986, _G4991],
 abolish(t_msp, 1) .

lit('Mod'(_G5185, _G5186), [ident('AL'), select(@), ident(_G5200), '('|_G5342], _G5316)  :-
 name2id(_G5200, _G5186),
 pc_update(t_msp(_G5186)),
 litarg(_G5223, _G5342, [ (',')|_G5370]),
 label(_G5228, _G5370, [ (',')|_G5398]),
 simplelabel(_G5233, _G5398, [ (',')|_G5426]),
 litarg(_G5238, _G5426, [')'|_G5316]),
 _G5185='A_label'(_G5223, _G5228, _G5238, _G5233),
 abolish(t_msp, 1) .

lit(_G5465, [ident('AL'), '('|_G5596], _G5576)  :-
 'M_SearchSpace'(_G5472),
 pc_update(t_msp(_G5472)),
 litarg(_G5489, _G5596, [ (',')|_G5624]),
 label(_G5494, _G5624, [ (',')|_G5652]),
 simplelabel(_G5499, _G5652, [ (',')|_G5680]),
 litarg(_G5504, _G5680, [')'|_G5576]),
 _G5465='A_label'(_G5489, _G5494, _G5504, _G5499),
 abolish(t_msp, 1) .

lit(_G5719, ['('|_G5827], _G5810)  :-
 'M_SearchSpace'(_G5721),
 pc_update(t_msp(_G5721)),
 litarg(_G5738, _G5827, _G5841),
 label(_G5740, _G5841, [/|_G5880]),
 simplelabel(_G5745, _G5880, _G5894),
 litarg(_G5747, _G5894, [')'|_G5810]),
 _G5719='A_label'(_G5738, _G5740, _G5747, _G5745),
 abolish(t_msp, 1) .

lit('Mod'(_G5944, _G5945), [ident(_G5949), select(@), ident(_G5973), '('|_G6090], _G6064)  :-
 memberchk(_G5949, ['In', 'In2']),
 name2id(_G5973, _G5945),
 pc_update(t_msp(_G5945)),
 litarglist(_G5996, _G6090, [')'|_G6064]),
 _G6004=..[_G5949|_G5996],
 resolveDeriveExpression(_G5973, _G6004, _G5944),
 abolish(t_msp, 1) .

lit(_G6135, [ident(_G6137), '('|_G6254], _G6234)  :-
 memberchk(_G6137, ['In', 'In2']),
 'M_SearchSpace'(_G6156),
 pc_update(t_msp(_G6156)),
 litarglist(_G6173, _G6254, [')'|_G6234]),
 _G6181=..[_G6137|_G6173],
 resolveDeriveExpression(_G6181, _G6135),
 abolish(t_msp, 1) .

lit('Mod'(_G6299, _G6300), [ident('Label'), select(@), ident(_G6314), '('|_G6438], _G6412)  :-
 name2id(_G6314, _G6300),
 pc_update(t_msp(_G6300)),
 litarg(_G6337, _G6438, [ (',')|_G6466]),
 label(_G6342, _G6466, [')'|_G6412]),
 _G6299=..['Label', _G6337, _G6342],
 abolish(t_msp, 1) .

lit(_G6505, [ident('Label'), '('|_G6612], _G6592)  :-
 'M_SearchSpace'(_G6512),
 pc_update(t_msp(_G6512)),
 litarg(_G6529, _G6612, [ (',')|_G6640]),
 label(_G6534, _G6640, [')'|_G6592]),
 _G6505=..['Label', _G6529, _G6534] .

lit('Mod'(_G6676, _G6677), [ident('P'), select(@), ident(_G6691), '('|_G6843], _G6817)  :-
 name2id(_G6691, _G6677),
 pc_update(t_msp(_G6677)),
 litarg(_G6714, _G6843, [ (',')|_G6871]),
 litarg(_G6719, _G6871, [ (',')|_G6899]),
 label(_G6724, _G6899, [ (',')|_G6927]),
 litarg(_G6729, _G6927, [')'|_G6817]),
 _G6676=..['P', _G6714, _G6719, _G6724, _G6729],
 abolish(t_msp, 1) .

lit('Mod'(_G6966, _G6967), [ident('Pa'), select(@), ident(_G6981), '('|_G7133], _G7107)  :-
 name2id(_G6981, _G6967),
 pc_update(t_msp(_G6967)),
 litarg(_G7004, _G7133, [ (',')|_G7161]),
 litarg(_G7009, _G7161, [ (',')|_G7189]),
 label(_G7014, _G7189, [ (',')|_G7217]),
 litarg(_G7019, _G7217, [')'|_G7107]),
 _G6966=..['Pa', _G7004, _G7009, _G7014, _G7019],
 abolish(t_msp, 1) .

lit(_G7256, [ident('P'), '('|_G7397], _G7377)  :-
 'M_SearchSpace'(_G7263),
 pc_update(t_msp(_G7263)),
 litarg(_G7280, _G7397, [ (',')|_G7425]),
 litarg(_G7285, _G7425, [ (',')|_G7453]),
 variableOrLabel(_G7290, _G7453, [ (',')|_G7481]),
 litarg(_G7295, _G7481, [')'|_G7377]),
 _G7256=..['P', _G7280, _G7285, _G7290, _G7295],
 abolish(t_msp, 1) .

lit(_G7520, [ident('Pa'), '('|_G7661], _G7641)  :-
 'M_SearchSpace'(_G7527),
 pc_update(t_msp(_G7527)),
 litarg(_G7544, _G7661, [ (',')|_G7689]),
 litarg(_G7549, _G7689, [ (',')|_G7717]),
 variableOrLabel(_G7554, _G7717, [ (',')|_G7745]),
 litarg(_G7559, _G7745, [')'|_G7641]),
 _G7520=..['Pa', _G7544, _G7549, _G7554, _G7559],
 abolish(t_msp, 1) .

lit('Mod'(_G7784, _G7785), [ident(_G7789), select(@), ident(_G7799), '('|_G7906], _G7880)  :-
 name2id(_G7799, _G7785),
 pc_update(t_msp(_G7785)),
 litarglist(_G7822, _G7906, [')'|_G7880]),
 _G7784=..[_G7789|_G7822],
 abolish(t_msp, 1) .

lit(_G7945, [ident(_G7947), '('|_G8066], _G8046)  :-
 \+memberchk(_G7947, [new, not, forall, exists]),
 'M_SearchSpace'(_G7974),
 pc_update(t_msp(_G7974)),
 litarglist(_G7991, _G8066, [')'|_G8046]),
 _G7945=..[_G7947|_G7991],
 abolish(t_msp, 1) .

lit(_G8108, ['('|_G8244], _G8227)  :-
 'M_SearchSpace'(_G8110),
 pc_update(t_msp(_G8110)),
 litarg1(_G8127, _G8244, [_G8129|_G8272]),
 memberchk(_G8129, [=, <, >, =<, <=, >=, <>, \=]),
 !,
 litarg1(_G8167, _G8272, [')'|_G8227]),
 infixToLiteral(_G8108, _G8127, _G8129, _G8167),
 !,
 abolish(t_msp, 1) .

lit(_G8323, ['('|_G8421], _G8404)  :-
 'M_SearchSpace'(_G8325),
 pc_update(t_msp(_G8325)),
 litarg(_G8342, _G8421, [_G8344|_G8449]),
 litarg(_G8347, _G8449, [')'|_G8404]),
 infixToLiteral(_G8323, _G8342, _G8344, _G8347),
 !,
 abolish(t_msp, 1) .

lit(_G8491, ['('|_G8601], _G8584)  :-
 'M_SearchSpace'(_G8493),
 pc_update(t_msp(_G8493)),
 litarg(_G8510, _G8601, ['[', _G8515, ']'|_G8635]),
 litarg(_G8521, _G8635, [')'|_G8584]),
 metaInfixToLiteral(_G8491, _G8510, _G8515, _G8521),
 !,
 abolish(t_msp, 1) .

lit(_G8677, [:, '('|_G8790], _G8770)  :-
 'M_SearchSpace'(_G8679),
 pc_update(t_msp(_G8679)),
 litarg(_G8699, _G8790, [_G8701|_G8818]),
 litarg(_G8704, _G8818, [')', :|_G8770]),
 explicatedToLiteral(_G8677, _G8699, _G8701, _G8704),
 !,
 abolish(t_msp, 1) .

lit(_G8863, [:, '('|_G8994], _G8974)  :-
 'M_SearchSpace'(_G8865),
 pc_update(t_msp(_G8865)),
 litarg(_G8885, _G8994, [_G8887, /, _G8893|_G9028]),
 litarg(_G8896, _G9028, [')', :|_G8974]),
 explicatedToLiteral(_G8863, _G8885, [_G8887, _G8893], _G8896),
 !,
 abolish(t_msp, 1) .

lit('TRUE', [ident('TRUE')|_G9095], _G9095)  :-
 true .

lit('FALSE', [ident('FALSE')|_G9133], _G9133)  :-
 true .

litarglist([_G9149|_G9150], _G9173, _G9176)  :-
 litarg(_G9149, _G9173, _G9201),
 litarglist_rest(_G9150, _G9201, _G9176) .

litarglist_rest(_G9236, [ (',')|_G9283], _G9269)  :-
 !,
 litarglist(_G9236, _G9283, _G9269) .

litarglist_rest([], _G9329, _G9329)  :-
 ! .

litarg(_G9345, _G9361, _G9364)  :-
 constantval(_G9345, _G9361, _G9364) .

litarg(_G9399, _G9415, _G9418)  :-
 deriveExpression(_G9399, _G9415, _G9418) .

litarg(_G9453, _G9469, _G9472)  :-
 selectExpression(_G9453, _G9469, _G9472) .

litarg(_G9507, _G9523, _G9526)  :-
 variableOrObject(_G9507, _G9523, _G9526) .

litarg1(_G9561, _G9577, _G9580)  :-
 constantval(_G9561, _G9577, _G9580) .

litarg1(_G9615, _G9631, _G9634)  :-
 arExpr(_G9615, _G9631, _G9634) .

litarg1(_G9669, _G9685, _G9688)  :-
 deriveExpression(_G9669, _G9685, _G9688) .

litarg1(_G9723, _G9739, _G9742)  :-
 selectExpression(_G9723, _G9739, _G9742) .

litarg1(_G9777, _G9793, _G9796)  :-
 variableOrObject(_G9777, _G9793, _G9796) .

typeExpr(_G9831, _G9847, _G9850)  :-
 constantval(_G9831, _G9847, _G9850) .

typeExpr(_G9885, _G9901, _G9904)  :-
 regularDeriveExpression(_G9885, _G9901, _G9904) .

typeExpr(_G9939, _G9955, _G9958)  :-
 shortQueryCall(_G9939, _G9955, _G9958) .

typeExpr(_G9993, _G10009, _G10012)  :-
 selectExpression(_G9993, _G10009, _G10012) .

typeExpr(_G10047, _G10063, _G10066)  :-
 typename(_G10047, _G10063, _G10066) .

variableOrObject(_G10101, [ident(_G10103)|_G10218], _G10218)  :-
 \+memberchk(_G10103, ['Known', new, 'UNIFIES', in, isA, not, 'In', forall, exists, 'IDENTICAL', 'Ai']),
 (
 isVariable(_G10103, _G10101),
 !;
 (
 temp_msp(_G10157),
 t_name2id(_G10157, _G10103, _G10101),
 !;
 report_error('PFNFE', parseAss_dcg, [_G10103]),
 pc_atomconcat('%%UNKNOWN--', _G10103, _G10101),
 !)) .

objectname(_G10237, [ident(_G10239)|_G10320], _G10320)  :-
 \+memberchk(_G10239, ['Known', new, 'UNIFIES', in, isA, not, 'In', forall, exists, 'IDENTICAL', 'Ai']),
 temp_msp(_G10285),
 t_name2id(_G10285, _G10239, _G10237),
 ! .

typename(_G10345, [ident(_G10347)|_G10444], _G10444)  :-
 (
 \+memberchk(_G10347, ['Known', new, 'UNIFIES', in, isA, not, 'In', forall, exists, 'IDENTICAL', 'Ai']),
 temp_msp(_G10390),
 t_name2id(_G10390, _G10347, _G10345),
 !;
 report_error('PFNFE', parseAss_dcg, [_G10347]),
 !,
 fail) .

constantval(_G10460, [realNumber(_G10462)|_G10494], _G10494)  :-
 create_if_builtin_object(_G10462, 'Real', _G10460) .

constantval(_G10510, [intNumber(_G10512)|_G10544], _G10544)  :-
 create_if_builtin_object(_G10512, 'Integer', _G10510) .

constantval(_G10560, [string(_G10562)|_G10594], _G10594)  :-
 create_if_builtin_object(_G10562, 'String', _G10560) .

assertionval(_G10610, [assertion(_G10612)|_G10649], _G10649)  :-
 temp_msp(_G10617),
 t_name2id(_G10617, _G10612, _G10610) .

label(_G10668, [ident(_G10668)|_G10716], _G10716)  :-
 temp_msp(_G10675),
 prove_literal('Mod'('P'(_G10680, _G10681, _G10668, _G10683), _G10675)),
 ! .

label(_G10738, [string(_G10738)|_G10786], _G10786)  :-
 temp_msp(_G10745),
 prove_literal('Mod'('P'(_G10750, _G10751, _G10738, _G10753), _G10745)),
 ! .

variableOrLabel(_G10808, [ident(_G10810)|_G10850], _G10850)  :-
 (
 isVariable(_G10810, _G10808),
 !;
 _G10808=_G10810) .

simplelabel(_G10866, [ident(_G10866)|_G10888], _G10888)  :-
 true .

typelist([_G10904|_G10905], _G10934, _G10937)  :-
 type(_G10904, _G10934, [ (',')|_G10976]),
 typelist(_G10905, _G10976, _G10937) .

typelist([_G11000], _G11019, _G11022)  :-
 type(_G11000, _G11019, _G11022) .

type('VAR', [ident('VAR')|_G11087], _G11087)  :-
 ! .

type(_G11103, _G11136, _G11139)  :-
 'M_SearchSpace'(_G11105),
 pc_update(t_msp(_G11105)),
 typeExpr(_G11103, _G11136, _G11139) .

deriveExpression(_G11183, _G11199, _G11202)  :-
 listModExpression(_G11183, _G11199, _G11202) .

deriveExpression(_G11237, _G11253, _G11256)  :-
 countExpr(_G11237, _G11253, _G11256) .

deriveExpression(_G11291, _G11307, _G11310)  :-
 shortFunctionCall(_G11291, _G11307, _G11310) .

deriveExpression(_G11345, _G11361, _G11364)  :-
 shortQueryCall(_G11345, _G11361, _G11364) .

deriveExpression(_G11399, _G11415, _G11418)  :-
 regularDeriveExpression(_G11399, _G11415, _G11418) .

regularDeriveExpression(derive(_G11453, _G11454), [ident(_G11458), '['|_G11529], _G11512)  :-
 dExpList(_G11454, _G11529, [']'|_G11512]),
 temp_msp(_G11471),
 t_name2id(_G11471, _G11458, _G11453) .

listModExpression(derive(_G11562, _G11563), [ident(listModule), '['|_G11641], _G11624)  :-
 modExpr(_G11563, _G11641, [']'|_G11624]),
 !,
 temp_msp(_G11583),
 t_name2id(_G11583, listModule, _G11562) .

modExpr([substitute(_G11677, module)], _G11721, _G11724)  :-
 modPath(_G11677, _G11721, [/, ident(module)|_G11724]),
 ! .

modExpr([substitute(_G11768, module)], _G11790, _G11793)  :-
 modPath(_G11768, _G11790, _G11793) .

modPath(_G11828, _G11852, _G11855)  :-
 modPathMin(_G11828, _G11852, _G11855),
 ! .

modPath(_G11893, _G11917, _G11920)  :-
 modPathSlash(_G11893, _G11917, _G11920),
 ! .

modPathMin(_G11958, [ident(_G11960), -|_G12031], _G12014)  :-
 modPathMin(_G11968, _G12031, _G12014),
 !,
 pc_atomconcat([_G11960, -, _G11968], _G11958) .

modPathMin(_G12061, [ident(_G12061)|_G12083], _G12083)  :-
 true .

modPathSlash(_G12099, [ident(_G12099), /, ident(module)|_G12143], _G12143)  :-
 ! .

modPathSlash(_G12165, [ident(_G12167), /|_G12238], _G12221)  :-
 modPathSlash(_G12175, _G12238, _G12221),
 !,
 pc_atomconcat([_G12167, /, _G12175], _G12165) .

modPathSlash(_G12268, [ident(_G12268)|_G12301], _G12301)  :-
 _G12268\=module .

countExpr(derive(_G12323, [substitute(_G12317, class)]), [#|_G12382], _G12368)  :-
 litarg(_G12317, _G12382, _G12368),
 temp_msp(_G12333),
 t_name2id(_G12333, 'COUNT', _G12323) .

shortFunctionCall(derive(_G12412, []), [ident(_G12417), '(', ')'|_G12466], _G12466)  :-
 temp_msp(_G12428),
 t_name2id(_G12428, _G12417, _G12412) .

shortFunctionCall(derive(_G12491, _G12492), [ident(_G12496), '('|_G12579], _G12562)  :-
 shortdExpList(_G12504, _G12579, [')'|_G12562]),
 temp_msp(_G12509),
 t_name2id(_G12509, _G12496, _G12491),
 isFunction(_G12491),
 plainToSubsts(_G12491, _G12504, _G12492) .

shortQueryCall(derive(_G12618, _G12619), [ident(_G12623), '['|_G12701], _G12684)  :-
 shortdExpList(_G12631, _G12701, [']'|_G12684]),
 temp_msp(_G12636),
 t_name2id(_G12636, _G12623, _G12618),
 plainToSubsts(_G12618, _G12631, _G12619) .

arExpr(_G12737, _G12777, _G12780)  :-
 arTerm(_G12739, _G12777, _G12805),
 arAddExpr(add(_G12741, _G12742), _G12805, _G12780),
 makeAddition(_G12739, _G12741, _G12742, _G12737),
 ! .

arExpr(_G12846, _G12900, _G12903)  :-
 arTerm(_G12848, _G12900, [intNumber(_G12850)|_G12903]),
 pc_atomconcat(-, _G12856, _G12850),
 create_if_builtin_object(_G12856, 'Integer', _G12864),
 makeAddition(_G12848, -, _G12864, _G12846),
 ! .

arExpr(_G12953, _G12969, _G12972)  :-
 arTerm(_G12953, _G12969, _G12972) .

arAddExpr(add(_G13007, _G13008), _G13055, _G13058)  :-
 arAddOp(_G13007, _G13055, _G13083),
 arTerm(_G13014, _G13083, _G13108),
 arAddExpr(add(_G13016, _G13017), _G13108, _G13058),
 makeAddition(_G13014, _G13016, _G13017, _G13008),
 ! .

arAddExpr(add(_G13149, _G13150), _G13173, _G13176)  :-
 arAddOp(_G13149, _G13173, _G13201),
 arTerm(_G13150, _G13201, _G13176) .

arTerm(_G13236, _G13276, _G13279)  :-
 arFactor(_G13238, _G13276, _G13304),
 arMultTerm(mult(_G13240, _G13241), _G13304, _G13279),
 makeMultiplication(_G13238, _G13240, _G13241, _G13236),
 ! .

arTerm(_G13345, _G13361, _G13364)  :-
 arFactor(_G13345, _G13361, _G13364) .

arMultTerm(mult(_G13399, _G13400), _G13447, _G13450)  :-
 arMulOp(_G13399, _G13447, _G13475),
 arFactor(_G13406, _G13475, _G13500),
 arMultTerm(mult(_G13408, _G13409), _G13500, _G13450),
 makeMultiplication(_G13406, _G13408, _G13409, _G13400),
 ! .

arMultTerm(mult(_G13541, _G13542), _G13565, _G13568)  :-
 arMulOp(_G13541, _G13565, _G13593),
 arFactor(_G13542, _G13593, _G13568) .

arFactor(_G13628, _G13652, _G13655)  :-
 funcExpr(_G13628, _G13652, _G13655),
 ! .

arFactor(_G13693, _G13717, _G13720)  :-
 constantval(_G13693, _G13717, _G13720),
 ! .

arFactor(_G13758, _G13774, _G13777)  :-
 variableOrObject(_G13758, _G13774, _G13777) .

arFactor(_G13812, ['('|_G13865], _G13851)  :-
 arExpr(_G13812, _G13865, [')'|_G13851]),
 ! .

arAddOp(+, [+|_G13915], _G13915)  :-
 true .

arAddOp(-, [-|_G13951], _G13951)  :-
 true .

arMulOp(*, [*|_G13987], _G13987)  :-
 true .

arMulOp(/, [/|_G14023], _G14023)  :-
 true .

dExpList([_G14039], _G14058, _G14061)  :-
 dExp(_G14039, _G14058, _G14061) .

dExpList([_G14096|_G14097], _G14126, _G14129)  :-
 dExp(_G14096, _G14126, [ (',')|_G14168]),
 dExpList(_G14097, _G14168, _G14129) .

dExp(substitute(_G14192, _G14193), _G14225, _G14228)  :-
 litarg(_G14192, _G14225, [/, ident(_G14193)|_G14228]),
 true .

dExp(specialize(_G14272, _G14273), _G14305, _G14308)  :-
 litarg(_G14272, _G14305, [:, ident(_G14273)|_G14308]),
 true .

shortdExpList([_G14352], _G14371, _G14374)  :-
 shortdExp(_G14352, _G14371, _G14374) .

shortdExpList([_G14409|_G14410], _G14439, _G14442)  :-
 shortdExp(_G14409, _G14439, [ (',')|_G14481]),
 shortdExpList(_G14410, _G14481, _G14442) .

shortdExp(plainarg(_G14505), _G14523, _G14526)  :-
 litarg(_G14505, _G14523, _G14526) .

funcExpr(derive(_G14561, _G14562), [ident(_G14566), '('|_G14649], _G14632)  :-
 funcArgList(_G14574, _G14649, [')'|_G14632]),
 temp_msp(_G14579),
 t_name2id(_G14579, _G14566, _G14561),
 isFunction(_G14561),
 plainToSubsts(_G14561, _G14574, _G14562) .

funcExpr(_G14688, _G14704, _G14707)  :-
 countExpr(_G14688, _G14704, _G14707) .

funcExpr(_G14742, _G14758, _G14761)  :-
 shortFunctionCall(_G14742, _G14758, _G14761) .

funcArgList([_G14796], _G14815, _G14818)  :-
 funcArg(_G14796, _G14815, _G14818) .

funcArgList([_G14853|_G14854], _G14883, _G14886)  :-
 funcArg(_G14853, _G14883, [ (',')|_G14925]),
 funcArgList(_G14854, _G14925, _G14886) .

funcArg(plainarg(_G14949), _G14967, _G14970)  :-
 arExpr(_G14949, _G14967, _G14970) .

funcArg(plainarg(_G15005), _G15023, _G15026)  :-
 arFactor(_G15005, _G15023, _G15026) .

selectExpression(_G15061, _G15120, _G15123)  :-
 idorexp(_G15063, _G15120, [select(_G15065)|_G15162]),
 idorexp(_G15070, _G15162, _G15176),
 memberchk(_G15065, [ (->), =>]),
 !,
 selectExpression2(_G15061, select(_G15063, _G15065, _G15070), _G15176, _G15123) .

selectExpression(_G15227, _G15284, _G15287)  :-
 idorexp(_G15229, _G15284, [select(_G15231)|_G15326]),
 idorexp(_G15236, _G15326, _G15340),
 temp_msp(_G15238),
 eval(_G15238, select(_G15229, _G15231, _G15236), replaceSelectExpression, _G15250),
 selectExpression2(_G15227, _G15250, _G15340, _G15287) .

selectExpression(_G15391, ['('|_G15436], _G15422)  :-
 selectExpression(_G15391, _G15436, [')'|_G15422]),
 true .

selectExpression2(_G15470, select(_G15466, _G15467, _G15468), [select(_G15473)|_G15586], _G15568)  :-
 idorexp(_G15478, _G15586, _G15600),
 memberchk(_G15467, [ (->), =>]),
 memberchk(_G15473, [!, ^, @]),
 !,
 temp_msp(_G15512),
 eval(_G15512, select(_G15468, _G15473, _G15478), replaceSelectExpression, _G15524),
 selectExpression2(_G15470, select(_G15466, _G15467, _G15524), _G15600, _G15568) .

selectExpression2(_G15670, select(_G15666, _G15667, _G15668), [select(_G15673)|_G15783], _G15765)  :-
 idorexp(_G15678, _G15783, _G15797),
 memberchk(_G15667, [ (->), =>]),
 memberchk(_G15673, [ (->), =>]),
 !,
 temp_msp(_G15709),
 eval(_G15709, select(_G15666, _G15667, _G15668), replaceSelectExpression, _G15721),
 selectExpression2(_G15670, select(_G15721, _G15673, _G15678), _G15797, _G15765) .

selectExpression2(_G15863, _G15864, [select(_G15866)|_G15942], _G15924)  :-
 memberchk(_G15866, [ (->), =>]),
 !,
 idorexp(_G15888, _G15942, _G15959),
 selectExpression2(_G15863, select(_G15864, _G15866, _G15888), _G15959, _G15924) .

selectExpression2(_G16007, _G16008, [select(_G16010)|_G16084], _G16066)  :-
 idorexp(_G16015, _G16084, _G16098),
 temp_msp(_G16017),
 eval(_G16017, select(_G16008, _G16010, _G16015), replaceSelectExpression, _G16029),
 selectExpression2(_G16007, _G16029, _G16098, _G16066) .

selectExpression2(_G16153, select(_G16149, _G16150, _G16151), _G16193, _G16193)  :-
 !,
 temp_msp(_G16159),
 eval(_G16159, select(_G16149, _G16150, _G16151), replaceSelectExpression, _G16153) .

selectExpression2(_G16219, _G16220, _G16245, _G16245)  :-
 _G16219=_G16220 .

idorexp(_G16265, _G16281, _G16284)  :-
 label(_G16265, _G16281, _G16284) .

idorexp(_G16319, [intNumber(_G16319)|_G16341], _G16341)  :-
 true .

idorexp(_G16357, [realNumber(_G16357)|_G16379], _G16379)  :-
 true .

idorexp(_G16395, ['('|_G16440], _G16426)  :-
 selectExpression(_G16395, _G16440, [')'|_G16426]),
 true .

elemSelectExpB(_G16470, _G16534, _G16537)  :-
 litarg(_G16472, _G16534, [ident(in)|_G16576]),
 selectexpb(_G16479, _G16576, _G16537),
 !,
 replaceSelectExpB(_G16479, _G16472, _G16486, _G16487),
 _G16470=and([lit('In'(_G16472, _G16486)), _G16487]) .

elemSelectExpB(_G16609, _G16699, _G16702)  :-
 selectexpb(_G16611, _G16699, [ident(isA)|_G16741]),
 selectexpb(_G16618, _G16741, _G16702),
 !,
 createNewVarname(_G16623),
 replaceSelectExpB(_G16611, _G16623, _G16630, _G16631),
 replaceSelectExpB(_G16618, _G16623, _G16638, _G16639),
 'VarTabInsert'([_G16623], [_G16630]),
 expandQuantifier(forall, vtype([_G16623], [_G16630]), impl(_G16631, _G16639), _G16609) .

elemSelectExpB(_G16783, _G16882, _G16885)  :-
 selectexpb(_G16785, _G16882, [=|_G16924]),
 selectexpb(_G16790, _G16924, _G16885),
 !,
 createNewVarname(_G16795),
 replaceSelectExpB(_G16785, _G16795, _G16802, _G16803),
 replaceSelectExpB(_G16790, _G16795, _G16810, _G16811),
 'VarTabInsert'([_G16795], [_G16802]),
 expandQuantifier(forall, vtype([_G16795], [_G16802]), and([impl(_G16803, _G16811), impl(_G16811, _G16803)]), _G16783) .

selectexpb(selectExpB(_G16966, _G16967, _G16968), [ident(_G16966), select2(_G16967)|_G17022], _G17005)  :-
 selectexpb2(_G16968, _G17022, _G17005) .

selectexpb(selectExpB(_G17046, _G17047, _G17048), [ident(_G17046), select2(_G17047)|_G17102], _G17085)  :-
 restriction(_G17048, _G17102, _G17085) .

selectexpb(selectExpB(_G17126, _G17127, _G17128), [ident(_G17126), select2(_G17127), ident(_G17128)|_G17168], _G17168)  :-
 true .

selectexpb2(_G17190, _G17206, _G17209)  :-
 selectexpb(_G17190, _G17206, _G17209) .

selectexpb2(selectExpB(_G17244, _G17245, _G17246), _G17277, _G17280)  :-
 restriction(_G17244, _G17277, [select2(_G17245)|_G17319]),
 selectexpb2(_G17246, _G17319, _G17280) .

selectexpb2(selectExpB(_G17343, _G17344, _G17345), _G17376, _G17379)  :-
 restriction(_G17343, _G17376, [select2(_G17344)|_G17418]),
 restriction(_G17345, _G17418, _G17379) .

selectexpb2(selectExpB(_G17442, _G17443, _G17444), _G17478, _G17481)  :-
 restriction(_G17442, _G17478, [select2(_G17443), ident(_G17444)|_G17481]),
 true .

restriction(restriction(_G17525, _G17526), ['(', ident(_G17525), :, ident(_G17526), ')'|_G17576], _G17576)  :-
 true .

restriction(restriction(_G17604, _G17605), ['(', ident(_G17604), :|_G17672], _G17652)  :-
 selectExpression(_G17605, _G17672, [')'|_G17652]),
 true .

restriction(restriction(_G17702, _G17703), ['(', ident(_G17702), :|_G17770], _G17750)  :-
 selectexpb(_G17703, _G17770, [')'|_G17750]),
 true .

restriction(restriction(_G17802, enumeration(_G17800)), ['(', ident(_G17802), :, '['|_G17885], _G17862)  :-
 enumeration(_G17800, _G17885, [']', ')'|_G17862]),
 true .

enumeration([class(_G17918)], _G17939, _G17942)  :-
 litarg(_G17918, _G17939, _G17942) .

enumeration([class(_G17977)], _G17998, _G18001)  :-
 selectExpression(_G17977, _G17998, _G18001) .

enumeration(_G18036, _G18080, _G18083)  :-
 litarg(_G18038, _G18080, [ (',')|_G18122]),
 enumeration(_G18043, _G18122, _G18083),
 append([class(_G18038)], _G18043, _G18036) .

enumeration(_G18149, _G18193, _G18196)  :-
 selectExpression(_G18151, _G18193, [ (',')|_G18235]),
 enumeration(_G18156, _G18235, _G18196),
 append([class(_G18151)], _G18156, _G18149) .

foralls(_G18262, _G18263, _G18308, _G18311)  :-
 forall(_G18265, _G18266, _G18308, _G18343),
 foralls(_G18268, _G18269, _G18343, _G18311),
 append(_G18265, _G18268, _G18262),
 append(_G18266, _G18269, _G18263) .

foralls([], [], _G18418, _G18418)  :-
 true .

forall(_G18438, _G18439, [ident(forall)|_G18488], _G18470)  :-
 vartypelist(_G18438, _G18439, _G18488, _G18470) .

buildECArule(ecarule(_G18519, _G18520, _G18521, _G18522, _G18523), _G18561, _G18564)  :-
 optvartypelist(_G18527, [], _G18561, [ident('ON')|_G18610]),
 buildECAruleHelper(ecarule(_G18519, _G18520, _G18521, _G18522, _G18523), _G18610, _G18564) .

buildECAruleHelper(ecarule(_G18637, true, _G18639, [noop], currentqueue), _G18672, _G18675)  :-
 buildECAevent(_G18637, _G18672, [ident('DO')|_G18714]),
 buildECAactionList(_G18639, _G18714, _G18675) .

buildECAruleHelper(ecarule(_G18738, _G18739, _G18740, _G18741, currentqueue), _G18789, _G18792)  :-
 buildECAevent(_G18738, _G18789, _G18817),
 ifClause(_G18748, _G18817, _G18842),
 buildECAcondition(_G18748, _G18739, _G18842, [ident('DO')|_G18888]),
 buildECAactionList(_G18740, _G18888, _G18902),
 optELSEactionList(_G18741, _G18902, _G18792) .

buildECAruleHelper(ecarule(_G18940, true, _G18942, [noop], q1), [ident('TRANSACTIONAL')|_G19000], _G18986)  :-
 buildECAevent(_G18940, _G19000, [ident('DO')|_G19028]),
 buildECAactionList(_G18942, _G19028, _G18986) .

buildECAruleHelper(ecarule(_G19052, _G19053, _G19054, _G19055, q1), [ident('TRANSACTIONAL')|_G19128], _G19114)  :-
 buildECAevent(_G19052, _G19128, _G19142),
 ifClause(_G19067, _G19142, _G19167),
 buildECAcondition(_G19067, _G19053, _G19167, [ident('DO')|_G19213]),
 buildECAactionList(_G19054, _G19213, _G19227),
 optELSEactionList(_G19055, _G19227, _G19114) .

buildECAruleHelper(ecarule(_G19265, true, _G19267, [noop], _G19269), _G19321, _G19324)  :-
 buildECAevent(_G19265, _G19321, [ident('FOR'), ident(_G19269), ident('DO')|_G19369]),
 buildECAactionList(_G19267, _G19369, _G19383),
 optELSEactionList(_G19292, _G19383, _G19324) .

buildECAruleHelper(ecarule(_G19418, _G19419, _G19420, _G19421, _G19422), _G19485, _G19488)  :-
 buildECAevent(_G19418, _G19485, [ident('FOR'), ident(_G19422)|_G19530]),
 ifClause(_G19438, _G19530, _G19544),
 buildECAcondition(_G19438, _G19419, _G19544, [ident('DO')|_G19590]),
 buildECAactionList(_G19420, _G19590, _G19604),
 optELSEactionList(_G19421, _G19604, _G19488) .

ifClause('IFNEW', [ident('IFNEW')|_G19661], _G19661)  :-
 true .

ifClause('IFNEW', [ident('IF'), ident('NEW')|_G19715], _G19715)  :-
 ! .

ifClause('IF', [ident('IF')|_G19756], _G19756)  :-
 true .

optELSEactionList(_G19772, [ident('ELSE')|_G19813], _G19799)  :-
 buildECAactionList(_G19772, _G19813, _G19799) .

optELSEactionList([noop], _G19859, _G19859)  :-
 true .

buildECAevent(_G19875, _G19923, _G19926)  :-
 'ECAeventOperation'(_G19877, _G19923, ['('|_G19965]),
 lit(_G19882, _G19965, [')'|_G19926]),
 makeECAevent(_G19877, _G19882, _G19875),
 ! .

buildECAevent(_G19998, _G20034, _G20037)  :-
 'ECAeventOperation'(_G20000, _G20034, _G20062),
 lit(_G20002, _G20062, _G20037),
 makeECAevent(_G20000, _G20002, _G19998),
 ! .

buildECAevent(_G20103, [ident(_G20105), '('|_G20200], _G20183)  :-
 memberchk(_G20105, ['Ask', ask]),
 litarg(_G20127, _G20200, [')'|_G20183]),
 resolveDeriveExpression('In'('_tempvarxyz', _G20127), _G20136),
 makeECAevent('Ask', _G20136, _G20103),
 ! .

buildECAevent(_G20239, [ident(_G20241)|_G20321], _G20307)  :-
 memberchk(_G20241, ['Ask', ask]),
 litarg(_G20260, _G20321, _G20307),
 resolveDeriveExpression('In'('_tempvarxyz', _G20260), _G20266),
 makeECAevent('Ask', _G20266, _G20239),
 ! .

buildECAcondition(_G20357, _G20358, [ident(_G20358)|_G20403], _G20403)  :-
 memberchk(_G20358, [true, false]),
 ! .

buildECAcondition(_G20426, _G20427, _G20461, _G20464)  :-
 'ECAconditionFormula'(_G20429, _G20461, _G20464),
 makeECAcondition(_G20426, _G20429, _G20427),
 ! .

'ECAconditionFormula'(_G20509, ['('|_G20554], _G20540)  :-
 'ECAconditionFormula'(_G20509, _G20554, [')'|_G20540]),
 true .

'ECAconditionFormula'(_G20584, _G20606, _G20609)  :-
 'ECAconditionFormula1'(_G20586, _G20606, _G20634),
 'ECAconditionFormula2'(_G20586, _G20584, _G20634, _G20609) .

'ECAconditionFormula1'(_G20676, _G20692, _G20695)  :-
 ecalit(_G20676, _G20692, _G20695) .

'ECAconditionFormula1'(not(_G20730), [ident(not)|_G20781], _G20767)  :-
 ecalit(_G20730, _G20781, _G20767),
 ! .

'ECAconditionFormula1'(not(_G20808), [ident(not), '('|_G20866], _G20849)  :-
 'ECAconditionFormula'(_G20808, _G20866, [')'|_G20849]),
 true .

'ECAconditionFormula2'(_G20896, and(_G20896, _G20897), [ident(and)|_G20948], _G20930)  :-
 'ECAconditionFormula'(_G20897, _G20948, _G20930) .

'ECAconditionFormula2'(_G20972, or(_G20972, _G20973), [ident(or)|_G21024], _G21006)  :-
 'ECAconditionFormula'(_G20973, _G21024, _G21006) .

'ECAconditionFormula2'(_G21048, _G21048, _G21071, _G21071)  :-
 true .

buildECAactionList([_G21091|_G21092], _G21115, _G21118)  :-
 'ECAaction'(_G21091, _G21115, _G21143),
 buildECAactionList_rest(_G21092, _G21143, _G21118) .

buildECAactionList_rest(_G21178, [ (',')|_G21225], _G21211)  :-
 !,
 buildECAactionList(_G21178, _G21225, _G21211) .

buildECAactionList_rest([], _G21271, _G21271)  :-
 ! .

'ECAaction'(noop, [ident(noop)|_G21317], _G21317)  :-
 ! .

'ECAaction'(noop, [ident(commit)|_G21363], _G21363)  :-
 ! .

'ECAaction'(reject, [ident(reject)|_G21409], _G21409)  :-
 ! .

'ECAaction'(tBegin, [ident(tBegin)|_G21455], _G21455)  :-
 ! .

'ECAaction'(tEnd, [ident(tEnd)|_G21501], _G21501)  :-
 ! .

'ECAaction'(_G21517, _G21565, _G21568)  :-
 'ECAactionOperation'(_G21519, _G21565, ['('|_G21607]),
 ecalit(_G21524, _G21607, [')'|_G21568]),
 makeECAaction(_G21519, _G21524, _G21517),
 ! .

'ECAaction'(_G21640, _G21676, _G21679)  :-
 'ECAactionOperation'(_G21642, _G21676, _G21704),
 ecalit(_G21644, _G21704, _G21679),
 makeECAaction(_G21642, _G21644, _G21640),
 ! .

'ECAaction'(_G21745, [ident(_G21747), '('|_G21833], _G21816)  :-
 memberchk(_G21747, ['Raise', raise]),
 deriveExpression(_G21769, _G21833, [')'|_G21816]),
 makeECAaction('Raise', _G21769, _G21745),
 ! .

'ECAaction'(_G21869, [ident(_G21871)|_G21942], _G21928)  :-
 memberchk(_G21871, ['Raise', raise]),
 deriveExpression(_G21890, _G21942, _G21928),
 makeECAaction('Raise', _G21890, _G21869),
 ! .

'ECAaction'(_G21975, [ident(_G21977), ident(_G21996)|_G22037], _G22037)  :-
 memberchk(_G21977, ['Raise', raise]),
 makeECAaction(_G21977, _G21996, _G21975),
 ! .

'ECAeventOperation'(_G22062, [ident(_G22062)|_G22110], _G22110)  :-
 memberchk(_G22062, ['Tell', 'Untell', tell, untell]),
 ! .

'ECAactionOperation'(_G22129, [ident(_G22129)|_G22198], _G22198)  :-
 memberchk(_G22129, ['Tell', 'Untell', 'Retell', 'Ask', 'Call', 'CALL', tell, untell, retell, ask, call]),
 ! .

ecalit(new(_G22217), [ident(new), '('|_G22275], _G22258)  :-
 lit(_G22217, _G22275, [')'|_G22258]),
 true .

ecalit(new(_G22305), [_G22309|_G22357], _G22343)  :-
 pc_ascii(_G22309, 96),
 lit(_G22305, _G22357, _G22343) .

ecalit(_G22384, _G22400, _G22403)  :-
 lit(_G22384, _G22400, _G22403) .

bulkQueryCall(bulkquery(_G22438), [ident(bulk), '['|_G22500], _G22483)  :-
 bulkArgList(_G22438, _G22500, _G22483),
 temp_msp(_G22452) .

bulkArgList([_G22527], _G22552, _G22555)  :-
 bulkArg(_G22527, _G22552, [']'|_G22555]),
 true .

bulkArgList([_G22596|_G22597], _G22626, _G22629)  :-
 bulkArg(_G22596, _G22626, [ (',')|_G22668]),
 bulkArgList(_G22597, _G22668, _G22629) .

bulkArg(plainarg(_G22692), _G22718, _G22721)  :-
 constantval(_G22692, _G22718, _G22721),
 ! .

bulkArg(plainarg(_G22759), _G22785, _G22788)  :-
 assertionval(_G22759, _G22785, _G22788),
 ! .

bulkArg(plainarg(_G22826), _G22852, _G22855)  :-
 selectExpression(_G22826, _G22852, _G22855),
 ! .

bulkArg(plainarg(_G22893), _G22919, _G22922)  :-
 objectname(_G22893, _G22919, _G22922),
 ! .

bulkArg(unknown(_G22960), _G22986, _G22989)  :-
 falseSelectExpression(_G22960, _G22986, _G22989),
 ! .

bulkArg(unknown(_G23027), _G23053, _G23056)  :-
 simplelabel(_G23027, _G23053, _G23056),
 ! .

falseSelectExpression(select(_G23094, _G23095, _G23096), _G23156, _G23159)  :-
 anyArg(_G23094, _G23156, [select(_G23095)|_G23198]),
 anyArg(_G23096, _G23198, _G23159),
 memberchk(_G23095, [ (->), =>, !, ^, @]),
 ! .

falseSelectExpression(_G23228, ['('|_G23273], _G23259)  :-
 falseSelectExpression(_G23228, _G23273, [')'|_G23259]),
 true .

anyArg(_G23303, _G23319, _G23322)  :-
 simplelabel(_G23303, _G23319, _G23322) .

anyArg(_G23357, [string(_G23357)|_G23379], _G23379)  :-
 true .

anyArg(_G23395, [assertion(_G23395)|_G23417], _G23417)  :-
 true .

anyArg(_G23433, [intNumber(_G23433)|_G23455], _G23455)  :-
 true .

anyArg(_G23471, [realNumber(_G23471)|_G23493], _G23493)  :-
 true .

anyArg(_G23509, [falseSelectExpression(_G23509)|_G23531], _G23531)  :-
 true .

buildQuerycall(class(_G23547), _G23573, _G23576)  :-
 bulkQueryCall(_G23547, _G23573, _G23576),
 ! .

buildQuerycall(class(_G23614), _G23632, _G23635)  :-
 arExpr(_G23614, _G23632, _G23635) .

buildQuerycall(class(_G23670), _G23688, _G23691)  :-
 deriveExpression(_G23670, _G23688, _G23691) .

convertSelectExpression(_G23726, _G23742, _G23745)  :-
 selectExpression(_G23726, _G23742, _G23745) .

convertSelectExpression(_G23780, _G23796, _G23799)  :-
 objectname(_G23780, _G23796, _G23799) .
