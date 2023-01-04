/** 'This' module named "parseAss_dcg" was automatically generated from the 'DCG'-grammar file "parseAss.dcg".

	'DO' 'NOT' 'EDIT' 'MANUALLY'
**/

:- module('parseAss_dcg',[

'buildECArule'/3
,'buildMSFOLconstraint'/3
,'buildAssertionRule'/3
,'buildQuerycall'/3
,'convertSelectExpression'/3
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('GeneralUtilities.swi.pl').





:- use_module('SelectExpressions.swi.pl').
:- use_module('PrologCompatibility.swi.pl').

:- use_module('VarTabHandling.swi.pl').


:- use_module('MSFOLassertionParserUtilities.swi.pl').






:- use_module('QueryCompiler.swi.pl').


:- use_module('ErrorMessages.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('FragmentToPropositions.swi.pl').
:- use_module('ECAruleCompiler.swi.pl').






:- use_module('validProposition.swi.pl').







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

idorexp(_G16395, [string(_G16395)|_G16417], _G16417)  :-
 true .

idorexp(_G16433, [assertion(_G16433)|_G16455], _G16455)  :-
 true .

idorexp(_G16471, ['('|_G16516], _G16502)  :-
 selectExpression(_G16471, _G16516, [')'|_G16502]),
 true .

elemSelectExpB(_G16546, _G16610, _G16613)  :-
 litarg(_G16548, _G16610, [ident(in)|_G16652]),
 selectexpb(_G16555, _G16652, _G16613),
 !,
 replaceSelectExpB(_G16555, _G16548, _G16562, _G16563),
 _G16546=and([lit('In'(_G16548, _G16562)), _G16563]) .

elemSelectExpB(_G16685, _G16775, _G16778)  :-
 selectexpb(_G16687, _G16775, [ident(isA)|_G16817]),
 selectexpb(_G16694, _G16817, _G16778),
 !,
 createNewVarname(_G16699),
 replaceSelectExpB(_G16687, _G16699, _G16706, _G16707),
 replaceSelectExpB(_G16694, _G16699, _G16714, _G16715),
 'VarTabInsert'([_G16699], [_G16706]),
 expandQuantifier(forall, vtype([_G16699], [_G16706]), impl(_G16707, _G16715), _G16685) .

elemSelectExpB(_G16859, _G16958, _G16961)  :-
 selectexpb(_G16861, _G16958, [=|_G17000]),
 selectexpb(_G16866, _G17000, _G16961),
 !,
 createNewVarname(_G16871),
 replaceSelectExpB(_G16861, _G16871, _G16878, _G16879),
 replaceSelectExpB(_G16866, _G16871, _G16886, _G16887),
 'VarTabInsert'([_G16871], [_G16878]),
 expandQuantifier(forall, vtype([_G16871], [_G16878]), and([impl(_G16879, _G16887), impl(_G16887, _G16879)]), _G16859) .

selectexpb(selectExpB(_G17042, _G17043, _G17044), [ident(_G17042), select2(_G17043)|_G17098], _G17081)  :-
 selectexpb2(_G17044, _G17098, _G17081) .

selectexpb(selectExpB(_G17122, _G17123, _G17124), [ident(_G17122), select2(_G17123)|_G17178], _G17161)  :-
 restriction(_G17124, _G17178, _G17161) .

selectexpb(selectExpB(_G17202, _G17203, _G17204), [ident(_G17202), select2(_G17203), ident(_G17204)|_G17244], _G17244)  :-
 true .

selectexpb2(_G17266, _G17282, _G17285)  :-
 selectexpb(_G17266, _G17282, _G17285) .

selectexpb2(selectExpB(_G17320, _G17321, _G17322), _G17353, _G17356)  :-
 restriction(_G17320, _G17353, [select2(_G17321)|_G17395]),
 selectexpb2(_G17322, _G17395, _G17356) .

selectexpb2(selectExpB(_G17419, _G17420, _G17421), _G17452, _G17455)  :-
 restriction(_G17419, _G17452, [select2(_G17420)|_G17494]),
 restriction(_G17421, _G17494, _G17455) .

selectexpb2(selectExpB(_G17518, _G17519, _G17520), _G17554, _G17557)  :-
 restriction(_G17518, _G17554, [select2(_G17519), ident(_G17520)|_G17557]),
 true .

restriction(restriction(_G17601, _G17602), ['(', ident(_G17601), :, ident(_G17602), ')'|_G17652], _G17652)  :-
 true .

restriction(restriction(_G17680, _G17681), ['(', ident(_G17680), :|_G17748], _G17728)  :-
 selectExpression(_G17681, _G17748, [')'|_G17728]),
 true .

restriction(restriction(_G17778, _G17779), ['(', ident(_G17778), :|_G17846], _G17826)  :-
 selectexpb(_G17779, _G17846, [')'|_G17826]),
 true .

restriction(restriction(_G17878, enumeration(_G17876)), ['(', ident(_G17878), :, '['|_G17961], _G17938)  :-
 enumeration(_G17876, _G17961, [']', ')'|_G17938]),
 true .

enumeration([class(_G17994)], _G18015, _G18018)  :-
 litarg(_G17994, _G18015, _G18018) .

enumeration([class(_G18053)], _G18074, _G18077)  :-
 selectExpression(_G18053, _G18074, _G18077) .

enumeration(_G18112, _G18156, _G18159)  :-
 litarg(_G18114, _G18156, [ (',')|_G18198]),
 enumeration(_G18119, _G18198, _G18159),
 append([class(_G18114)], _G18119, _G18112) .

enumeration(_G18225, _G18269, _G18272)  :-
 selectExpression(_G18227, _G18269, [ (',')|_G18311]),
 enumeration(_G18232, _G18311, _G18272),
 append([class(_G18227)], _G18232, _G18225) .

foralls(_G18338, _G18339, _G18384, _G18387)  :-
 forall(_G18341, _G18342, _G18384, _G18419),
 foralls(_G18344, _G18345, _G18419, _G18387),
 append(_G18341, _G18344, _G18338),
 append(_G18342, _G18345, _G18339) .

foralls([], [], _G18494, _G18494)  :-
 true .

forall(_G18514, _G18515, [ident(forall)|_G18564], _G18546)  :-
 vartypelist(_G18514, _G18515, _G18564, _G18546) .

buildECArule(ecarule(_G18595, _G18596, _G18597, _G18598, _G18599), _G18637, _G18640)  :-
 optvartypelist(_G18603, [], _G18637, [ident('ON')|_G18686]),
 buildECAruleHelper(ecarule(_G18595, _G18596, _G18597, _G18598, _G18599), _G18686, _G18640) .

buildECAruleHelper(ecarule(_G18713, true, _G18715, [noop], currentqueue), _G18748, _G18751)  :-
 buildECAevent(_G18713, _G18748, [ident('DO')|_G18790]),
 buildECAactionList(_G18715, _G18790, _G18751) .

buildECAruleHelper(ecarule(_G18814, _G18815, _G18816, _G18817, currentqueue), _G18865, _G18868)  :-
 buildECAevent(_G18814, _G18865, _G18893),
 ifClause(_G18824, _G18893, _G18918),
 buildECAcondition(_G18824, _G18815, _G18918, [ident('DO')|_G18964]),
 buildECAactionList(_G18816, _G18964, _G18978),
 optELSEactionList(_G18817, _G18978, _G18868) .

buildECAruleHelper(ecarule(_G19016, true, _G19018, [noop], q1), [ident('TRANSACTIONAL')|_G19076], _G19062)  :-
 buildECAevent(_G19016, _G19076, [ident('DO')|_G19104]),
 buildECAactionList(_G19018, _G19104, _G19062) .

buildECAruleHelper(ecarule(_G19128, _G19129, _G19130, _G19131, q1), [ident('TRANSACTIONAL')|_G19204], _G19190)  :-
 buildECAevent(_G19128, _G19204, _G19218),
 ifClause(_G19143, _G19218, _G19243),
 buildECAcondition(_G19143, _G19129, _G19243, [ident('DO')|_G19289]),
 buildECAactionList(_G19130, _G19289, _G19303),
 optELSEactionList(_G19131, _G19303, _G19190) .

buildECAruleHelper(ecarule(_G19341, true, _G19343, [noop], _G19345), _G19397, _G19400)  :-
 buildECAevent(_G19341, _G19397, [ident('FOR'), ident(_G19345), ident('DO')|_G19445]),
 buildECAactionList(_G19343, _G19445, _G19459),
 optELSEactionList(_G19368, _G19459, _G19400) .

buildECAruleHelper(ecarule(_G19494, _G19495, _G19496, _G19497, _G19498), _G19561, _G19564)  :-
 buildECAevent(_G19494, _G19561, [ident('FOR'), ident(_G19498)|_G19606]),
 ifClause(_G19514, _G19606, _G19620),
 buildECAcondition(_G19514, _G19495, _G19620, [ident('DO')|_G19666]),
 buildECAactionList(_G19496, _G19666, _G19680),
 optELSEactionList(_G19497, _G19680, _G19564) .

ifClause('IFNEW', [ident('IFNEW')|_G19737], _G19737)  :-
 true .

ifClause('IFNEW', [ident('IF'), ident('NEW')|_G19791], _G19791)  :-
 ! .

ifClause('IF', [ident('IF')|_G19832], _G19832)  :-
 true .

optELSEactionList(_G19848, [ident('ELSE')|_G19889], _G19875)  :-
 buildECAactionList(_G19848, _G19889, _G19875) .

optELSEactionList([noop], _G19935, _G19935)  :-
 true .

buildECAevent(_G19951, _G19999, _G20002)  :-
 'ECAeventOperation'(_G19953, _G19999, ['('|_G20041]),
 lit(_G19958, _G20041, [')'|_G20002]),
 makeECAevent(_G19953, _G19958, _G19951),
 ! .

buildECAevent(_G20074, _G20110, _G20113)  :-
 'ECAeventOperation'(_G20076, _G20110, _G20138),
 lit(_G20078, _G20138, _G20113),
 makeECAevent(_G20076, _G20078, _G20074),
 ! .

buildECAevent(_G20179, [ident(_G20181), '('|_G20276], _G20259)  :-
 memberchk(_G20181, ['Ask', ask]),
 litarg(_G20203, _G20276, [')'|_G20259]),
 resolveDeriveExpression('In'('_tempvarxyz', _G20203), _G20212),
 makeECAevent('Ask', _G20212, _G20179),
 ! .

buildECAevent(_G20315, [ident(_G20317)|_G20397], _G20383)  :-
 memberchk(_G20317, ['Ask', ask]),
 litarg(_G20336, _G20397, _G20383),
 resolveDeriveExpression('In'('_tempvarxyz', _G20336), _G20342),
 makeECAevent('Ask', _G20342, _G20315),
 ! .

buildECAcondition(_G20433, _G20434, [ident(_G20434)|_G20479], _G20479)  :-
 memberchk(_G20434, [true, false]),
 ! .

buildECAcondition(_G20502, _G20503, _G20537, _G20540)  :-
 'ECAconditionFormula'(_G20505, _G20537, _G20540),
 makeECAcondition(_G20502, _G20505, _G20503),
 ! .

'ECAconditionFormula'(_G20585, ['('|_G20630], _G20616)  :-
 'ECAconditionFormula'(_G20585, _G20630, [')'|_G20616]),
 true .

'ECAconditionFormula'(_G20660, _G20682, _G20685)  :-
 'ECAconditionFormula1'(_G20662, _G20682, _G20710),
 'ECAconditionFormula2'(_G20662, _G20660, _G20710, _G20685) .

'ECAconditionFormula1'(_G20752, _G20768, _G20771)  :-
 ecalit(_G20752, _G20768, _G20771) .

'ECAconditionFormula1'(not(_G20806), [ident(not)|_G20857], _G20843)  :-
 ecalit(_G20806, _G20857, _G20843),
 ! .

'ECAconditionFormula1'(not(_G20884), [ident(not), '('|_G20942], _G20925)  :-
 'ECAconditionFormula'(_G20884, _G20942, [')'|_G20925]),
 true .

'ECAconditionFormula2'(_G20972, and(_G20972, _G20973), [ident(and)|_G21024], _G21006)  :-
 'ECAconditionFormula'(_G20973, _G21024, _G21006) .

'ECAconditionFormula2'(_G21048, or(_G21048, _G21049), [ident(or)|_G21100], _G21082)  :-
 'ECAconditionFormula'(_G21049, _G21100, _G21082) .

'ECAconditionFormula2'(_G21124, _G21124, _G21147, _G21147)  :-
 true .

buildECAactionList([_G21167|_G21168], _G21191, _G21194)  :-
 'ECAaction'(_G21167, _G21191, _G21219),
 buildECAactionList_rest(_G21168, _G21219, _G21194) .

buildECAactionList_rest(_G21254, [ (',')|_G21301], _G21287)  :-
 !,
 buildECAactionList(_G21254, _G21301, _G21287) .

buildECAactionList_rest([], _G21347, _G21347)  :-
 ! .

'ECAaction'(noop, [ident(noop)|_G21393], _G21393)  :-
 ! .

'ECAaction'(noop, [ident(commit)|_G21439], _G21439)  :-
 ! .

'ECAaction'(reject, [ident(reject)|_G21485], _G21485)  :-
 ! .

'ECAaction'(tBegin, [ident(tBegin)|_G21531], _G21531)  :-
 ! .

'ECAaction'(tEnd, [ident(tEnd)|_G21577], _G21577)  :-
 ! .

'ECAaction'(_G21593, _G21641, _G21644)  :-
 'ECAactionOperation'(_G21595, _G21641, ['('|_G21683]),
 ecalit(_G21600, _G21683, [')'|_G21644]),
 makeECAaction(_G21595, _G21600, _G21593),
 ! .

'ECAaction'(_G21716, _G21752, _G21755)  :-
 'ECAactionOperation'(_G21718, _G21752, _G21780),
 ecalit(_G21720, _G21780, _G21755),
 makeECAaction(_G21718, _G21720, _G21716),
 ! .

'ECAaction'(_G21821, [ident(_G21823), '('|_G21909], _G21892)  :-
 memberchk(_G21823, ['Raise', raise]),
 deriveExpression(_G21845, _G21909, [')'|_G21892]),
 makeECAaction('Raise', _G21845, _G21821),
 ! .

'ECAaction'(_G21945, [ident(_G21947)|_G22018], _G22004)  :-
 memberchk(_G21947, ['Raise', raise]),
 deriveExpression(_G21966, _G22018, _G22004),
 makeECAaction('Raise', _G21966, _G21945),
 ! .

'ECAaction'(_G22051, [ident(_G22053), ident(_G22072)|_G22113], _G22113)  :-
 memberchk(_G22053, ['Raise', raise]),
 makeECAaction(_G22053, _G22072, _G22051),
 ! .

'ECAeventOperation'(_G22138, [ident(_G22138)|_G22186], _G22186)  :-
 memberchk(_G22138, ['Tell', 'Untell', tell, untell]),
 ! .

'ECAactionOperation'(_G22205, [ident(_G22205)|_G22274], _G22274)  :-
 memberchk(_G22205, ['Tell', 'Untell', 'Retell', 'Ask', 'Call', 'CALL', tell, untell, retell, ask, call]),
 ! .

ecalit(new(_G22293), [ident(new), '('|_G22351], _G22334)  :-
 lit(_G22293, _G22351, [')'|_G22334]),
 true .

ecalit(new(_G22381), [_G22385|_G22433], _G22419)  :-
 pc_ascii(_G22385, 96),
 lit(_G22381, _G22433, _G22419) .

ecalit(_G22460, _G22476, _G22479)  :-
 lit(_G22460, _G22476, _G22479) .

bulkQueryCall(bulkquery(_G22514), [ident(bulk), '['|_G22576], _G22559)  :-
 bulkArgList(_G22514, _G22576, _G22559),
 temp_msp(_G22528) .

bulkArgList([_G22603], _G22628, _G22631)  :-
 bulkArg(_G22603, _G22628, [']'|_G22631]),
 true .

bulkArgList([_G22672|_G22673], _G22702, _G22705)  :-
 bulkArg(_G22672, _G22702, [ (',')|_G22744]),
 bulkArgList(_G22673, _G22744, _G22705) .

bulkArg(plainarg(_G22768), _G22794, _G22797)  :-
 constantval(_G22768, _G22794, _G22797),
 ! .

bulkArg(plainarg(_G22835), _G22861, _G22864)  :-
 assertionval(_G22835, _G22861, _G22864),
 ! .

bulkArg(plainarg(_G22902), _G22928, _G22931)  :-
 selectExpression(_G22902, _G22928, _G22931),
 ! .

bulkArg(plainarg(_G22969), _G22995, _G22998)  :-
 objectname(_G22969, _G22995, _G22998),
 ! .

bulkArg(unknown(_G23036), _G23062, _G23065)  :-
 falseSelectExpression(_G23036, _G23062, _G23065),
 ! .

bulkArg(unknown(_G23103), _G23129, _G23132)  :-
 simplelabel(_G23103, _G23129, _G23132),
 ! .

falseSelectExpression(select(_G23170, _G23171, _G23172), _G23232, _G23235)  :-
 anyArg(_G23170, _G23232, [select(_G23171)|_G23274]),
 anyArg(_G23172, _G23274, _G23235),
 memberchk(_G23171, [ (->), =>, !, ^, @]),
 ! .

falseSelectExpression(_G23304, ['('|_G23349], _G23335)  :-
 falseSelectExpression(_G23304, _G23349, [')'|_G23335]),
 true .

anyArg(_G23379, _G23395, _G23398)  :-
 simplelabel(_G23379, _G23395, _G23398) .

anyArg(_G23433, [string(_G23433)|_G23455], _G23455)  :-
 true .

anyArg(_G23471, [assertion(_G23471)|_G23493], _G23493)  :-
 true .

anyArg(_G23509, [intNumber(_G23509)|_G23531], _G23531)  :-
 true .

anyArg(_G23547, [realNumber(_G23547)|_G23569], _G23569)  :-
 true .

anyArg(_G23585, [falseSelectExpression(_G23585)|_G23607], _G23607)  :-
 true .

buildQuerycall(class(_G23623), _G23649, _G23652)  :-
 bulkQueryCall(_G23623, _G23649, _G23652),
 ! .

buildQuerycall(class(_G23690), _G23708, _G23711)  :-
 arExpr(_G23690, _G23708, _G23711) .

buildQuerycall(class(_G23746), _G23764, _G23767)  :-
 deriveExpression(_G23746, _G23764, _G23767) .

convertSelectExpression(_G23802, _G23818, _G23821)  :-
 selectExpression(_G23802, _G23818, _G23821) .

convertSelectExpression(_G23856, _G23872, _G23875)  :-
 objectname(_G23856, _G23872, _G23875) .
