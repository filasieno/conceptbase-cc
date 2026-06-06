%  'This' module named "parseAss_dcg" was automatically generated from the 'DCG'-grammar file "parseAss.dcg".
%
% 	'DO' 'NOT' 'EDIT' 'MANUALLY'
%

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
buildMSFOLconstraint('MSFOLconstraint'(_G1099), _G1125, _G1128)  :-
 parseDecl(_G1099, _G1125, _G1128),
 ! .

buildAssertionRule('MSFOLrule'(_G1166, _G1167, _G1168), _G1253, _G1256)  :-
 foralls(_G1172, _G1173, _G1253, _G1284),
 'VarTabLookup_vars'(_G1166),
 buildAssertionRule2(_G1182, _G1168, _G1284, _G1256),
 !,
 (
 _G1173==[],
 _G1167=_G1182;
 _G1173\==[],
 append(_G1173, [_G1182], _G1205),
 _G1167=and(_G1205)),
 validConclusion(_G1168, _G1166) .

buildAssertionRule2(_G1342, _G1343, _G1377, _G1380)  :-
 exp(_G1345, _G1377, _G1380),
 !,
 splitRule(_G1345, _G1342, _G1343) .

buildAssertionTerm('MSFOLassertion'(_G1425), _G1451, _G1454)  :-
 parseDecl(_G1425, _G1451, _G1454),
 ! .
buildAssertionTerm('MSFOLassertion'(_G1492), _G1518, _G1521)  :-
 exp(_G1492, _G1518, _G1521),
 ! .

shortConclusion(lit(_G1559), _G1577, _G1580)  :-
 lit(_G1559, _G1577, _G1580) .
shortConclusion(lit(_G1615), ['('|_G1662], _G1648)  :-
 lit(_G1615, _G1662, [')'|_G1648]),
 true .

parseDecl(_G1692, _G1716, _G1719)  :-
 exp(_G1692, _G1716, _G1719),
 ! .

exp(_G1757, _G1805, _G1808)  :-
 elemexp(_G1759, _G1805, _G1833),
 andexp(_G1759, _G1762, _G1833, _G1861),
 orexp(_G1762, _G1765, _G1861, _G1893),
 implexp(_G1765, _G1768, _G1893, _G1925),
 equivexp(_G1768, _G1757, _G1925, _G1808),
 ! .

elemexp(_G1974, [ident(forall)|_G2066], _G2052)  :-
 vartypelist(_G1981, _G1982, _G2066, _G2083),
 (
 _G1982==[],
 expandQuantifier(forall, _G1981, _G1989, _G1974);
 _G1982\==[],
 append(_G1982, [_G1989], _G2003),
 expandQuantifier(forall, _G1981, and(_G2003), _G1974)),
 exp(_G1989, _G2083, _G2052) .
elemexp(_G2125, [ident(exists)|_G2217], _G2203)  :-
 vartypelist(_G2132, _G2133, _G2217, _G2234),
 (
 _G2133==[],
 expandQuantifier(exists, _G2132, _G2140, _G2125);
 _G2133\==[],
 append(_G2133, [_G2140], _G2154),
 expandQuantifier(exists, _G2132, and(_G2154), _G2125)),
 exp(_G2140, _G2234, _G2203) .
elemexp(not(_G2276), [ident(not)|_G2319], _G2305)  :-
 elemexp(_G2276, _G2319, _G2305) .
elemexp(_G2343, ['('|_G2388], _G2374)  :-
 exp(_G2343, _G2388, [')'|_G2374]),
 true .
elemexp(lit(_G2418), _G2436, _G2439)  :-
 lit(_G2418, _G2436, _G2439) .
elemexp(_G2474, _G2490, _G2493)  :-
 elemSelectExpB(_G2474, _G2490, _G2493) .

vartypelist([_G2528|_G2529], _G2532, _G2573, _G2576)  :-
 vartype(_G2528, _G2535, _G2573, _G2608),
 optvartypelist(_G2529, _G2538, _G2608, _G2576),
 !,
 append(_G2535, _G2538, _G2532) .

optvartypelist(_G2660, _G2661, _G2681, _G2684)  :-
 vartypelist(_G2660, _G2661, _G2681, _G2684) .
optvartypelist([], [], _G2756, _G2756)  :-
 true,
 ! .

vartype(vtype(_G2779, _G2780), _G2783, _G2835, _G2838)  :-
 varlist(_G2779, _G2835, [/|_G2881]),
 selectexpb(_G2790, _G2881, _G2838),
 replaceSelectExpBList(_G2790, _G2779, _G2780, _G2783),
 'VarTabInsert'(_G2779, [_G2780]) .
vartype(vtype(_G2911, _G2912), [], _G2976, _G2979)  :-
 varlist(_G2911, _G2976, [/, '['|_G3025]),
 typelist(_G2912, _G3025, [']'|_G2979]),
 'VarTabInsert'(_G2911, _G2912),
 !,
 containsNoReservedWord(_G2911) .
vartype(vtype(_G3061, _G3062), [], _G3117, _G3120)  :-
 varlist(_G3061, _G3117, [/|_G3163]),
 type(_G3062, _G3163, _G3120),
 'VarTabInsert'(_G3061, [_G3062]),
 !,
 containsNoReservedWord(_G3061) .

varlist([_G3196|_G3197], [ident(_G3196), (',')|_G3263], _G3246)  :-
 varlist(_G3197, _G3263, _G3246),
 !,
 _G3196\=='~this' .
varlist([_G3293], [ident(_G3293)|_G3332], _G3332)  :-
 !,
 _G3293\=='~this' .

andexp(and_h(_G3351), _G3354, [ident(and)|_G3413], _G3395)  :-
 elemexp(_G3361, _G3413, _G3427),
 andexp(and_h([_G3361|_G3351]), _G3354, _G3427, _G3395) .
andexp(_G3469, _G3470, [ident(and)|_G3532], _G3514)  :-
 elemexp(_G3477, _G3532, _G3546),
 andexp(and_h([_G3477, _G3469]), _G3470, _G3546, _G3514) .
andexp(and_h(_G3588), and(_G3590), _G3618, _G3618)  :-
 reverse(_G3588, _G3590) .
andexp(_G3638, _G3639, _G3664, _G3664)  :-
 _G3639=_G3638 .

orexp(or_h(_G3684), _G3687, [ident(or)|_G3752], _G3734)  :-
 elemexp(_G3694, _G3752, _G3766),
 andexp(_G3694, _G3697, _G3766, _G3794),
 orexp(or_h([_G3697|_G3684]), _G3687, _G3794, _G3734) .
orexp(_G3840, _G3841, [ident(or)|_G3909], _G3891)  :-
 elemexp(_G3848, _G3909, _G3923),
 andexp(_G3848, _G3851, _G3923, _G3951),
 orexp(or_h([_G3851, _G3840]), _G3841, _G3951, _G3891) .
orexp(or_h(_G3997), or(_G3999), _G4027, _G4027)  :-
 reverse(_G3997, _G3999) .
orexp(_G4047, _G4048, _G4073, _G4073)  :-
 _G4048=_G4047 .

implexp(_G4093, _G4094, [ (==>)|_G4161], _G4143)  :-
 elemexp(_G4099, _G4161, _G4175),
 andexp(_G4099, _G4102, _G4175, _G4203),
 orexp(_G4102, _G4105, _G4203, _G4235),
 implexp(impl(_G4093, _G4105), _G4094, _G4235, _G4143) .
implexp(_G4281, _G4282, _G4307, _G4307)  :-
 _G4282=_G4281 .

equivexp(_G4327, _G4328, [<==>|_G4412], _G4394)  :-
 elemexp(_G4333, _G4412, _G4426),
 andexp(_G4333, _G4336, _G4426, _G4454),
 orexp(_G4336, _G4339, _G4454, _G4486),
 implexp(_G4339, _G4342, _G4486, _G4518),
 equivexp(and([impl(_G4327, _G4342), impl(_G4342, _G4327)]), _G4328, _G4518, _G4394) .
equivexp(_G4564, _G4565, _G4590, _G4590)  :-
 _G4565=_G4564 .

lit('Mod'(_G4610, _G4611), [ident(_G4615), select(@), ident(_G4645), '('|_G4786], _G4760)  :-
 memberchk(_G4615, ['A', 'A_e', 'Ai', 'A2']),
 name2id(_G4645, _G4611),
 pc_update(t_msp(_G4611)),
 litarg(_G4668, _G4786, [ (',')|_G4814]),
 label(_G4673, _G4814, [ (',')|_G4842]),
 litarg(_G4678, _G4842, [')'|_G4760]),
 _G4610=..[_G4615, _G4668, _G4673, _G4678],
 abolish(t_msp, 1) .
lit(_G4884, [ident(_G4886), '('|_G5032], _G5009)  :-
 memberchk(_G4886, ['A', 'A_e', 'Ai', 'A2']),
 'M_SearchSpace'(_G4909),
 pc_update(t_msp(_G4909)),
 litarg(_G4926, _G5032, [ (',')|_G5060]),
 label(_G4931, _G5060, [ (',')|_G5088]),
 litarg(_G4936, _G5088, [')'|_G5009]),
 _G4884=..[_G4886, _G4926, _G4931, _G4936],
 abolish(t_msp, 1) .
lit('Mod'(_G5130, _G5131), [ident('AL'), select(@), ident(_G5145), '('|_G5287], _G5261)  :-
 name2id(_G5145, _G5131),
 pc_update(t_msp(_G5131)),
 litarg(_G5168, _G5287, [ (',')|_G5315]),
 label(_G5173, _G5315, [ (',')|_G5343]),
 simplelabel(_G5178, _G5343, [ (',')|_G5371]),
 litarg(_G5183, _G5371, [')'|_G5261]),
 _G5130='A_label'(_G5168, _G5173, _G5183, _G5178),
 abolish(t_msp, 1) .
lit(_G5410, [ident('AL'), '('|_G5541], _G5521)  :-
 'M_SearchSpace'(_G5417),
 pc_update(t_msp(_G5417)),
 litarg(_G5434, _G5541, [ (',')|_G5569]),
 label(_G5439, _G5569, [ (',')|_G5597]),
 simplelabel(_G5444, _G5597, [ (',')|_G5625]),
 litarg(_G5449, _G5625, [')'|_G5521]),
 _G5410='A_label'(_G5434, _G5439, _G5449, _G5444),
 abolish(t_msp, 1) .
lit(_G5664, ['('|_G5772], _G5755)  :-
 'M_SearchSpace'(_G5666),
 pc_update(t_msp(_G5666)),
 litarg(_G5683, _G5772, _G5786),
 label(_G5685, _G5786, [/|_G5825]),
 simplelabel(_G5690, _G5825, _G5839),
 litarg(_G5692, _G5839, [')'|_G5755]),
 _G5664='A_label'(_G5683, _G5685, _G5692, _G5690),
 abolish(t_msp, 1) .
lit('Mod'(_G5889, _G5890), [ident(_G5894), select(@), ident(_G5918), '('|_G6035], _G6009)  :-
 memberchk(_G5894, ['In', 'In2']),
 name2id(_G5918, _G5890),
 pc_update(t_msp(_G5890)),
 litarglist(_G5941, _G6035, [')'|_G6009]),
 _G5949=..[_G5894|_G5941],
 resolveDeriveExpression(_G5918, _G5949, _G5889),
 abolish(t_msp, 1) .
lit(_G6080, [ident(_G6082), '('|_G6199], _G6179)  :-
 memberchk(_G6082, ['In', 'In2']),
 'M_SearchSpace'(_G6101),
 pc_update(t_msp(_G6101)),
 litarglist(_G6118, _G6199, [')'|_G6179]),
 _G6126=..[_G6082|_G6118],
 resolveDeriveExpression(_G6126, _G6080),
 abolish(t_msp, 1) .
lit('Mod'(_G6244, _G6245), [ident('Label'), select(@), ident(_G6259), '('|_G6383], _G6357)  :-
 name2id(_G6259, _G6245),
 pc_update(t_msp(_G6245)),
 litarg(_G6282, _G6383, [ (',')|_G6411]),
 label(_G6287, _G6411, [')'|_G6357]),
 _G6244=..['Label', _G6282, _G6287],
 abolish(t_msp, 1) .
lit(_G6450, [ident('Label'), '('|_G6557], _G6537)  :-
 'M_SearchSpace'(_G6457),
 pc_update(t_msp(_G6457)),
 litarg(_G6474, _G6557, [ (',')|_G6585]),
 label(_G6479, _G6585, [')'|_G6537]),
 _G6450=..['Label', _G6474, _G6479] .
lit('Mod'(_G6621, _G6622), [ident('P'), select(@), ident(_G6636), '('|_G6788], _G6762)  :-
 name2id(_G6636, _G6622),
 pc_update(t_msp(_G6622)),
 litarg(_G6659, _G6788, [ (',')|_G6816]),
 litarg(_G6664, _G6816, [ (',')|_G6844]),
 label(_G6669, _G6844, [ (',')|_G6872]),
 litarg(_G6674, _G6872, [')'|_G6762]),
 _G6621=..['P', _G6659, _G6664, _G6669, _G6674],
 abolish(t_msp, 1) .
lit(_G6911, [ident('P'), '('|_G7052], _G7032)  :-
 'M_SearchSpace'(_G6918),
 pc_update(t_msp(_G6918)),
 litarg(_G6935, _G7052, [ (',')|_G7080]),
 litarg(_G6940, _G7080, [ (',')|_G7108]),
 variableOrLabel(_G6945, _G7108, [ (',')|_G7136]),
 litarg(_G6950, _G7136, [')'|_G7032]),
 _G6911=..['P', _G6935, _G6940, _G6945, _G6950],
 abolish(t_msp, 1) .
lit('Mod'(_G7175, _G7176), [ident(_G7180), select(@), ident(_G7190), '('|_G7297], _G7271)  :-
 name2id(_G7190, _G7176),
 pc_update(t_msp(_G7176)),
 litarglist(_G7213, _G7297, [')'|_G7271]),
 _G7175=..[_G7180|_G7213],
 abolish(t_msp, 1) .
lit(_G7336, [ident(_G7338), '('|_G7457], _G7437)  :-
 \+memberchk(_G7338, [new, not, forall, exists]),
 'M_SearchSpace'(_G7365),
 pc_update(t_msp(_G7365)),
 litarglist(_G7382, _G7457, [')'|_G7437]),
 _G7336=..[_G7338|_G7382],
 abolish(t_msp, 1) .
lit(_G7499, ['('|_G7635], _G7618)  :-
 'M_SearchSpace'(_G7501),
 pc_update(t_msp(_G7501)),
 litarg1(_G7518, _G7635, [_G7520|_G7663]),
 memberchk(_G7520, [=, <, >, =<, <=, >=, <>, \=]),
 !,
 litarg1(_G7558, _G7663, [')'|_G7618]),
 infixToLiteral(_G7499, _G7518, _G7520, _G7558),
 !,
 abolish(t_msp, 1) .
lit(_G7714, ['('|_G7812], _G7795)  :-
 'M_SearchSpace'(_G7716),
 pc_update(t_msp(_G7716)),
 litarg(_G7733, _G7812, [_G7735|_G7840]),
 litarg(_G7738, _G7840, [')'|_G7795]),
 infixToLiteral(_G7714, _G7733, _G7735, _G7738),
 !,
 abolish(t_msp, 1) .
lit(_G7882, ['('|_G7992], _G7975)  :-
 'M_SearchSpace'(_G7884),
 pc_update(t_msp(_G7884)),
 litarg(_G7901, _G7992, ['[', _G7906, ']'|_G8026]),
 litarg(_G7912, _G8026, [')'|_G7975]),
 metaInfixToLiteral(_G7882, _G7901, _G7906, _G7912),
 !,
 abolish(t_msp, 1) .
lit(_G8068, [:, '('|_G8181], _G8161)  :-
 'M_SearchSpace'(_G8070),
 pc_update(t_msp(_G8070)),
 litarg(_G8090, _G8181, [_G8092|_G8209]),
 litarg(_G8095, _G8209, [')', :|_G8161]),
 explicatedToLiteral(_G8068, _G8090, _G8092, _G8095),
 !,
 abolish(t_msp, 1) .
lit(_G8254, [:, '('|_G8385], _G8365)  :-
 'M_SearchSpace'(_G8256),
 pc_update(t_msp(_G8256)),
 litarg(_G8276, _G8385, [_G8278, /, _G8284|_G8419]),
 litarg(_G8287, _G8419, [')', :|_G8365]),
 explicatedToLiteral(_G8254, _G8276, [_G8278, _G8284], _G8287),
 !,
 abolish(t_msp, 1) .
lit('TRUE', [ident('TRUE')|_G8486], _G8486)  :-
 true .
lit('FALSE', [ident('FALSE')|_G8524], _G8524)  :-
 true .

litarglist([_G8540|_G8541], _G8564, _G8567)  :-
 litarg(_G8540, _G8564, _G8592),
 litarglist_rest(_G8541, _G8592, _G8567) .

litarglist_rest(_G8627, [ (',')|_G8674], _G8660)  :-
 !,
 litarglist(_G8627, _G8674, _G8660) .
litarglist_rest([], _G8720, _G8720)  :-
 ! .

litarg(_G8736, _G8752, _G8755)  :-
 constantval(_G8736, _G8752, _G8755) .
litarg(_G8790, _G8806, _G8809)  :-
 deriveExpression(_G8790, _G8806, _G8809) .
litarg(_G8844, _G8860, _G8863)  :-
 selectExpression(_G8844, _G8860, _G8863) .
litarg(_G8898, _G8914, _G8917)  :-
 variableOrObject(_G8898, _G8914, _G8917) .

litarg1(_G8952, _G8968, _G8971)  :-
 constantval(_G8952, _G8968, _G8971) .
litarg1(_G9006, _G9022, _G9025)  :-
 arExpr(_G9006, _G9022, _G9025) .
litarg1(_G9060, _G9076, _G9079)  :-
 deriveExpression(_G9060, _G9076, _G9079) .
litarg1(_G9114, _G9130, _G9133)  :-
 selectExpression(_G9114, _G9130, _G9133) .
litarg1(_G9168, _G9184, _G9187)  :-
 variableOrObject(_G9168, _G9184, _G9187) .

typeExpr(_G9222, _G9238, _G9241)  :-
 constantval(_G9222, _G9238, _G9241) .
typeExpr(_G9276, _G9292, _G9295)  :-
 regularDeriveExpression(_G9276, _G9292, _G9295) .
typeExpr(_G9330, _G9346, _G9349)  :-
 shortQueryCall(_G9330, _G9346, _G9349) .
typeExpr(_G9384, _G9400, _G9403)  :-
 selectExpression(_G9384, _G9400, _G9403) .
typeExpr(_G9438, _G9454, _G9457)  :-
 objectname(_G9438, _G9454, _G9457) .

variableOrObject(_G9492, [ident(_G9494)|_G9609], _G9609)  :-
 \+memberchk(_G9494, ['Known', new, 'UNIFIES', in, isA, not, 'In', forall, exists, 'IDENTICAL', 'Ai']),
 (
 isVariable(_G9494, _G9492),
 !;
 (
 temp_msp(_G9548),
 t_name2id(_G9548, _G9494, _G9492),
 !;
 report_error('PFNFE', parseAss_dcg, [_G9494]),
 pc_atomconcat('%%UNKNOWN--', _G9494, _G9492),
 !)) .

objectname(_G9628, [ident(_G9630)|_G9711], _G9711)  :-
 \+memberchk(_G9630, ['Known', new, 'UNIFIES', in, isA, not, 'In', forall, exists, 'IDENTICAL', 'Ai']),
 temp_msp(_G9676),
 t_name2id(_G9676, _G9630, _G9628),
 ! .

constantval(_G9736, [realNumber(_G9738)|_G9770], _G9770)  :-
 create_if_builtin_object(_G9738, 'Real', _G9736) .
constantval(_G9786, [intNumber(_G9788)|_G9820], _G9820)  :-
 create_if_builtin_object(_G9788, 'Integer', _G9786) .
constantval(_G9836, [string(_G9838)|_G9870], _G9870)  :-
 create_if_builtin_object(_G9838, 'String', _G9836) .

label(_G9886, [ident(_G9886)|_G9934], _G9934)  :-
 temp_msp(_G9893),
 prove_literal('Mod'('P'(_G9898, _G9899, _G9886, _G9901), _G9893)),
 ! .
label(_G9956, [string(_G9956)|_G10004], _G10004)  :-
 temp_msp(_G9963),
 prove_literal('Mod'('P'(_G9968, _G9969, _G9956, _G9971), _G9963)),
 ! .

variableOrLabel(_G10026, [ident(_G10028)|_G10068], _G10068)  :-
 (
 isVariable(_G10028, _G10026),
 !;
 _G10026=_G10028) .

simplelabel(_G10084, [ident(_G10084)|_G10106], _G10106)  :-
 true .

typelist([_G10122|_G10123], _G10152, _G10155)  :-
 type(_G10122, _G10152, [ (',')|_G10194]),
 typelist(_G10123, _G10194, _G10155) .
typelist([_G10218], _G10237, _G10240)  :-
 type(_G10218, _G10237, _G10240) .

type('VAR', [ident('VAR')|_G10305], _G10305)  :-
 ! .
type(_G10321, _G10354, _G10357)  :-
 'M_SearchSpace'(_G10323),
 pc_update(t_msp(_G10323)),
 typeExpr(_G10321, _G10354, _G10357) .

deriveExpression(_G10401, _G10417, _G10420)  :-
 listModExpression(_G10401, _G10417, _G10420) .
deriveExpression(_G10455, _G10471, _G10474)  :-
 countExpr(_G10455, _G10471, _G10474) .
deriveExpression(_G10509, _G10525, _G10528)  :-
 shortFunctionCall(_G10509, _G10525, _G10528) .
deriveExpression(_G10563, _G10579, _G10582)  :-
 shortQueryCall(_G10563, _G10579, _G10582) .
deriveExpression(_G10617, _G10633, _G10636)  :-
 regularDeriveExpression(_G10617, _G10633, _G10636) .

regularDeriveExpression(derive(_G10671, _G10672), [ident(_G10676), '['|_G10747], _G10730)  :-
 dExpList(_G10672, _G10747, [']'|_G10730]),
 temp_msp(_G10689),
 t_name2id(_G10689, _G10676, _G10671) .

listModExpression(derive(_G10780, _G10781), [ident(listModule), '['|_G10859], _G10842)  :-
 modExpr(_G10781, _G10859, [']'|_G10842]),
 !,
 temp_msp(_G10801),
 t_name2id(_G10801, listModule, _G10780) .

modExpr([substitute(_G10895, module)], _G10939, _G10942)  :-
 modPath(_G10895, _G10939, [/, ident(module)|_G10942]),
 ! .
modExpr([substitute(_G10986, module)], _G11008, _G11011)  :-
 modPath(_G10986, _G11008, _G11011) .

modPath(_G11046, _G11070, _G11073)  :-
 modPathMin(_G11046, _G11070, _G11073),
 ! .
modPath(_G11111, _G11135, _G11138)  :-
 modPathSlash(_G11111, _G11135, _G11138),
 ! .

modPathMin(_G11176, [ident(_G11178), -|_G11249], _G11232)  :-
 modPathMin(_G11186, _G11249, _G11232),
 !,
 pc_atomconcat([_G11178, -, _G11186], _G11176) .
modPathMin(_G11279, [ident(_G11279)|_G11301], _G11301)  :-
 true .

modPathSlash(_G11317, [ident(_G11317), /, ident(module)|_G11361], _G11361)  :-
 ! .
modPathSlash(_G11383, [ident(_G11385), /|_G11456], _G11439)  :-
 modPathSlash(_G11393, _G11456, _G11439),
 !,
 pc_atomconcat([_G11385, /, _G11393], _G11383) .
modPathSlash(_G11486, [ident(_G11486)|_G11519], _G11519)  :-
 _G11486\=module .

countExpr(derive(_G11541, [substitute(_G11535, class)]), [#|_G11600], _G11586)  :-
 litarg(_G11535, _G11600, _G11586),
 temp_msp(_G11551),
 t_name2id(_G11551, 'COUNT', _G11541) .

shortFunctionCall(derive(_G11630, []), [ident(_G11635), '(', ')'|_G11684], _G11684)  :-
 temp_msp(_G11646),
 t_name2id(_G11646, _G11635, _G11630) .
shortFunctionCall(derive(_G11709, _G11710), [ident(_G11714), '('|_G11797], _G11780)  :-
 shortdExpList(_G11722, _G11797, [')'|_G11780]),
 temp_msp(_G11727),
 t_name2id(_G11727, _G11714, _G11709),
 isFunction(_G11709),
 plainToSubsts(_G11709, _G11722, _G11710) .

shortQueryCall(derive(_G11836, _G11837), [ident(_G11841), '['|_G11919], _G11902)  :-
 shortdExpList(_G11849, _G11919, [']'|_G11902]),
 temp_msp(_G11854),
 t_name2id(_G11854, _G11841, _G11836),
 plainToSubsts(_G11836, _G11849, _G11837) .

arExpr(_G11955, _G11995, _G11998)  :-
 arTerm(_G11957, _G11995, _G12023),
 arAddExpr(add(_G11959, _G11960), _G12023, _G11998),
 makeAddition(_G11957, _G11959, _G11960, _G11955),
 ! .
arExpr(_G12064, _G12118, _G12121)  :-
 arTerm(_G12066, _G12118, [intNumber(_G12068)|_G12121]),
 pc_atomconcat(-, _G12074, _G12068),
 create_if_builtin_object(_G12074, 'Integer', _G12082),
 makeAddition(_G12066, -, _G12082, _G12064),
 ! .
arExpr(_G12171, _G12187, _G12190)  :-
 arTerm(_G12171, _G12187, _G12190) .

arAddExpr(add(_G12225, _G12226), _G12273, _G12276)  :-
 arAddOp(_G12225, _G12273, _G12301),
 arTerm(_G12232, _G12301, _G12326),
 arAddExpr(add(_G12234, _G12235), _G12326, _G12276),
 makeAddition(_G12232, _G12234, _G12235, _G12226),
 ! .
arAddExpr(add(_G12367, _G12368), _G12391, _G12394)  :-
 arAddOp(_G12367, _G12391, _G12419),
 arTerm(_G12368, _G12419, _G12394) .

arTerm(_G12454, _G12494, _G12497)  :-
 arFactor(_G12456, _G12494, _G12522),
 arMultTerm(mult(_G12458, _G12459), _G12522, _G12497),
 makeMultiplication(_G12456, _G12458, _G12459, _G12454),
 ! .
arTerm(_G12563, _G12579, _G12582)  :-
 arFactor(_G12563, _G12579, _G12582) .

arMultTerm(mult(_G12617, _G12618), _G12665, _G12668)  :-
 arMulOp(_G12617, _G12665, _G12693),
 arFactor(_G12624, _G12693, _G12718),
 arMultTerm(mult(_G12626, _G12627), _G12718, _G12668),
 makeMultiplication(_G12624, _G12626, _G12627, _G12618),
 ! .
arMultTerm(mult(_G12759, _G12760), _G12783, _G12786)  :-
 arMulOp(_G12759, _G12783, _G12811),
 arFactor(_G12760, _G12811, _G12786) .

arFactor(_G12846, _G12870, _G12873)  :-
 funcExpr(_G12846, _G12870, _G12873),
 ! .
arFactor(_G12911, _G12935, _G12938)  :-
 constantval(_G12911, _G12935, _G12938),
 ! .
arFactor(_G12976, _G12992, _G12995)  :-
 variableOrObject(_G12976, _G12992, _G12995) .
arFactor(_G13030, ['('|_G13083], _G13069)  :-
 arExpr(_G13030, _G13083, [')'|_G13069]),
 ! .

arAddOp(+, [+|_G13133], _G13133)  :-
 true .
arAddOp(-, [-|_G13169], _G13169)  :-
 true .

arMulOp(*, [*|_G13205], _G13205)  :-
 true .
arMulOp(/, [/|_G13241], _G13241)  :-
 true .

dExpList([_G13257], _G13276, _G13279)  :-
 dExp(_G13257, _G13276, _G13279) .
dExpList([_G13314|_G13315], _G13344, _G13347)  :-
 dExp(_G13314, _G13344, [ (',')|_G13386]),
 dExpList(_G13315, _G13386, _G13347) .

dExp(substitute(_G13410, _G13411), _G13443, _G13446)  :-
 litarg(_G13410, _G13443, [/, ident(_G13411)|_G13446]),
 true .
dExp(specialize(_G13490, _G13491), _G13523, _G13526)  :-
 litarg(_G13490, _G13523, [:, ident(_G13491)|_G13526]),
 true .

shortdExpList([_G13570], _G13589, _G13592)  :-
 shortdExp(_G13570, _G13589, _G13592) .
shortdExpList([_G13627|_G13628], _G13657, _G13660)  :-
 shortdExp(_G13627, _G13657, [ (',')|_G13699]),
 shortdExpList(_G13628, _G13699, _G13660) .

shortdExp(plainarg(_G13723), _G13741, _G13744)  :-
 litarg(_G13723, _G13741, _G13744) .

funcExpr(derive(_G13779, _G13780), [ident(_G13784), '('|_G13867], _G13850)  :-
 funcArgList(_G13792, _G13867, [')'|_G13850]),
 temp_msp(_G13797),
 t_name2id(_G13797, _G13784, _G13779),
 isFunction(_G13779),
 plainToSubsts(_G13779, _G13792, _G13780) .
funcExpr(_G13906, _G13922, _G13925)  :-
 countExpr(_G13906, _G13922, _G13925) .
funcExpr(_G13960, _G13976, _G13979)  :-
 shortFunctionCall(_G13960, _G13976, _G13979) .

funcArgList([_G14014], _G14033, _G14036)  :-
 funcArg(_G14014, _G14033, _G14036) .
funcArgList([_G14071|_G14072], _G14101, _G14104)  :-
 funcArg(_G14071, _G14101, [ (',')|_G14143]),
 funcArgList(_G14072, _G14143, _G14104) .

funcArg(plainarg(_G14167), _G14185, _G14188)  :-
 arExpr(_G14167, _G14185, _G14188) .
funcArg(plainarg(_G14223), _G14241, _G14244)  :-
 arFactor(_G14223, _G14241, _G14244) .

selectExpression(_G14279, _G14338, _G14341)  :-
 idorexp(_G14281, _G14338, [select(_G14283)|_G14380]),
 idorexp(_G14288, _G14380, _G14394),
 memberchk(_G14283, [ (->), =>]),
 !,
 selectExpression2(_G14279, select(_G14281, _G14283, _G14288), _G14394, _G14341) .
selectExpression(_G14445, _G14502, _G14505)  :-
 idorexp(_G14447, _G14502, [select(_G14449)|_G14544]),
 idorexp(_G14454, _G14544, _G14558),
 temp_msp(_G14456),
 eval(_G14456, select(_G14447, _G14449, _G14454), replaceSelectExpression, _G14468),
 selectExpression2(_G14445, _G14468, _G14558, _G14505) .
selectExpression(_G14609, ['('|_G14654], _G14640)  :-
 selectExpression(_G14609, _G14654, [')'|_G14640]),
 true .

selectExpression2(_G14688, select(_G14684, _G14685, _G14686), [select(_G14691)|_G14804], _G14786)  :-
 idorexp(_G14696, _G14804, _G14818),
 memberchk(_G14685, [ (->), =>]),
 memberchk(_G14691, [!, ^, @]),
 !,
 temp_msp(_G14730),
 eval(_G14730, select(_G14686, _G14691, _G14696), replaceSelectExpression, _G14742),
 selectExpression2(_G14688, select(_G14684, _G14685, _G14742), _G14818, _G14786) .
selectExpression2(_G14888, select(_G14884, _G14885, _G14886), [select(_G14891)|_G15001], _G14983)  :-
 idorexp(_G14896, _G15001, _G15015),
 memberchk(_G14885, [ (->), =>]),
 memberchk(_G14891, [ (->), =>]),
 !,
 temp_msp(_G14927),
 eval(_G14927, select(_G14884, _G14885, _G14886), replaceSelectExpression, _G14939),
 selectExpression2(_G14888, select(_G14939, _G14891, _G14896), _G15015, _G14983) .
selectExpression2(_G15081, _G15082, [select(_G15084)|_G15160], _G15142)  :-
 memberchk(_G15084, [ (->), =>]),
 !,
 idorexp(_G15106, _G15160, _G15177),
 selectExpression2(_G15081, select(_G15082, _G15084, _G15106), _G15177, _G15142) .
selectExpression2(_G15225, _G15226, [select(_G15228)|_G15302], _G15284)  :-
 idorexp(_G15233, _G15302, _G15316),
 temp_msp(_G15235),
 eval(_G15235, select(_G15226, _G15228, _G15233), replaceSelectExpression, _G15247),
 selectExpression2(_G15225, _G15247, _G15316, _G15284) .
selectExpression2(_G15371, select(_G15367, _G15368, _G15369), _G15411, _G15411)  :-
 !,
 temp_msp(_G15377),
 eval(_G15377, select(_G15367, _G15368, _G15369), replaceSelectExpression, _G15371) .
selectExpression2(_G15437, _G15438, _G15463, _G15463)  :-
 _G15437=_G15438 .

idorexp(_G15483, _G15499, _G15502)  :-
 label(_G15483, _G15499, _G15502) .
idorexp(_G15537, [intNumber(_G15537)|_G15559], _G15559)  :-
 true .
idorexp(_G15575, [realNumber(_G15575)|_G15597], _G15597)  :-
 true .
idorexp(_G15613, ['('|_G15658], _G15644)  :-
 selectExpression(_G15613, _G15658, [')'|_G15644]),
 true .

elemSelectExpB(_G15688, _G15752, _G15755)  :-
 litarg(_G15690, _G15752, [ident(in)|_G15794]),
 selectexpb(_G15697, _G15794, _G15755),
 !,
 replaceSelectExpB(_G15697, _G15690, _G15704, _G15705),
 _G15688=and([lit('In'(_G15690, _G15704)), _G15705]) .
elemSelectExpB(_G15827, _G15917, _G15920)  :-
 selectexpb(_G15829, _G15917, [ident(isA)|_G15959]),
 selectexpb(_G15836, _G15959, _G15920),
 !,
 createNewVarname(_G15841),
 replaceSelectExpB(_G15829, _G15841, _G15848, _G15849),
 replaceSelectExpB(_G15836, _G15841, _G15856, _G15857),
 'VarTabInsert'([_G15841], [_G15848]),
 expandQuantifier(forall, vtype([_G15841], [_G15848]), impl(_G15849, _G15857), _G15827) .
elemSelectExpB(_G16001, _G16100, _G16103)  :-
 selectexpb(_G16003, _G16100, [=|_G16142]),
 selectexpb(_G16008, _G16142, _G16103),
 !,
 createNewVarname(_G16013),
 replaceSelectExpB(_G16003, _G16013, _G16020, _G16021),
 replaceSelectExpB(_G16008, _G16013, _G16028, _G16029),
 'VarTabInsert'([_G16013], [_G16020]),
 expandQuantifier(forall, vtype([_G16013], [_G16020]), and([impl(_G16021, _G16029), impl(_G16029, _G16021)]), _G16001) .

selectexpb(selectExpB(_G16184, _G16185, _G16186), [ident(_G16184), select2(_G16185)|_G16240], _G16223)  :-
 selectexpb2(_G16186, _G16240, _G16223) .
selectexpb(selectExpB(_G16264, _G16265, _G16266), [ident(_G16264), select2(_G16265)|_G16320], _G16303)  :-
 restriction(_G16266, _G16320, _G16303) .
selectexpb(selectExpB(_G16344, _G16345, _G16346), [ident(_G16344), select2(_G16345), ident(_G16346)|_G16386], _G16386)  :-
 true .

selectexpb2(_G16408, _G16424, _G16427)  :-
 selectexpb(_G16408, _G16424, _G16427) .
selectexpb2(selectExpB(_G16462, _G16463, _G16464), _G16495, _G16498)  :-
 restriction(_G16462, _G16495, [select2(_G16463)|_G16537]),
 selectexpb2(_G16464, _G16537, _G16498) .
selectexpb2(selectExpB(_G16561, _G16562, _G16563), _G16594, _G16597)  :-
 restriction(_G16561, _G16594, [select2(_G16562)|_G16636]),
 restriction(_G16563, _G16636, _G16597) .
selectexpb2(selectExpB(_G16660, _G16661, _G16662), _G16696, _G16699)  :-
 restriction(_G16660, _G16696, [select2(_G16661), ident(_G16662)|_G16699]),
 true .

restriction(restriction(_G16743, _G16744), ['(', ident(_G16743), :, ident(_G16744), ')'|_G16794], _G16794)  :-
 true .
restriction(restriction(_G16822, _G16823), ['(', ident(_G16822), :|_G16890], _G16870)  :-
 selectExpression(_G16823, _G16890, [')'|_G16870]),
 true .
restriction(restriction(_G16920, _G16921), ['(', ident(_G16920), :|_G16988], _G16968)  :-
 selectexpb(_G16921, _G16988, [')'|_G16968]),
 true .
restriction(restriction(_G17020, enumeration(_G17018)), ['(', ident(_G17020), :, '['|_G17103], _G17080)  :-
 enumeration(_G17018, _G17103, [']', ')'|_G17080]),
 true .

enumeration([class(_G17136)], _G17157, _G17160)  :-
 litarg(_G17136, _G17157, _G17160) .
enumeration([class(_G17195)], _G17216, _G17219)  :-
 selectExpression(_G17195, _G17216, _G17219) .
enumeration(_G17254, _G17298, _G17301)  :-
 litarg(_G17256, _G17298, [ (',')|_G17340]),
 enumeration(_G17261, _G17340, _G17301),
 append([class(_G17256)], _G17261, _G17254) .
enumeration(_G17367, _G17411, _G17414)  :-
 selectExpression(_G17369, _G17411, [ (',')|_G17453]),
 enumeration(_G17374, _G17453, _G17414),
 append([class(_G17369)], _G17374, _G17367) .

foralls(_G17480, _G17481, _G17526, _G17529)  :-
 forall(_G17483, _G17484, _G17526, _G17561),
 foralls(_G17486, _G17487, _G17561, _G17529),
 append(_G17483, _G17486, _G17480),
 append(_G17484, _G17487, _G17481) .
foralls([], [], _G17636, _G17636)  :-
 true .

forall(_G17656, _G17657, [ident(forall)|_G17706], _G17688)  :-
 vartypelist(_G17656, _G17657, _G17706, _G17688) .

buildECArule(ecarule(_G17737, _G17738, _G17739, _G17740, _G17741), _G17779, _G17782)  :-
 optvartypelist(_G17745, [], _G17779, [ident('ON')|_G17828]),
 buildECAruleHelper(ecarule(_G17737, _G17738, _G17739, _G17740, _G17741), _G17828, _G17782) .

buildECAruleHelper(ecarule(_G17855, true, _G17857, [noop], currentqueue), _G17890, _G17893)  :-
 buildECAevent(_G17855, _G17890, [ident('DO')|_G17932]),
 buildECAactionList(_G17857, _G17932, _G17893) .
buildECAruleHelper(ecarule(_G17956, _G17957, _G17958, _G17959, currentqueue), _G18007, _G18010)  :-
 buildECAevent(_G17956, _G18007, _G18035),
 ifClause(_G17966, _G18035, _G18060),
 buildECAcondition(_G17966, _G17957, _G18060, [ident('DO')|_G18106]),
 buildECAactionList(_G17958, _G18106, _G18120),
 optELSEactionList(_G17959, _G18120, _G18010) .
buildECAruleHelper(ecarule(_G18158, true, _G18160, [noop], q1), [ident('TRANSACTIONAL')|_G18218], _G18204)  :-
 buildECAevent(_G18158, _G18218, [ident('DO')|_G18246]),
 buildECAactionList(_G18160, _G18246, _G18204) .
buildECAruleHelper(ecarule(_G18270, _G18271, _G18272, _G18273, q1), [ident('TRANSACTIONAL')|_G18346], _G18332)  :-
 buildECAevent(_G18270, _G18346, _G18360),
 ifClause(_G18285, _G18360, _G18385),
 buildECAcondition(_G18285, _G18271, _G18385, [ident('DO')|_G18431]),
 buildECAactionList(_G18272, _G18431, _G18445),
 optELSEactionList(_G18273, _G18445, _G18332) .
buildECAruleHelper(ecarule(_G18483, true, _G18485, [noop], _G18487), _G18539, _G18542)  :-
 buildECAevent(_G18483, _G18539, [ident('FOR'), ident(_G18487), ident('DO')|_G18587]),
 buildECAactionList(_G18485, _G18587, _G18601),
 optELSEactionList(_G18510, _G18601, _G18542) .
buildECAruleHelper(ecarule(_G18636, _G18637, _G18638, _G18639, _G18640), _G18703, _G18706)  :-
 buildECAevent(_G18636, _G18703, [ident('FOR'), ident(_G18640)|_G18748]),
 ifClause(_G18656, _G18748, _G18762),
 buildECAcondition(_G18656, _G18637, _G18762, [ident('DO')|_G18808]),
 buildECAactionList(_G18638, _G18808, _G18822),
 optELSEactionList(_G18639, _G18822, _G18706) .

ifClause('IFNEW', [ident('IFNEW')|_G18879], _G18879)  :-
 true .
ifClause('IFNEW', [ident('IF'), ident('NEW')|_G18933], _G18933)  :-
 ! .
ifClause('IF', [ident('IF')|_G18974], _G18974)  :-
 true .

optELSEactionList(_G18990, [ident('ELSE')|_G19031], _G19017)  :-
 buildECAactionList(_G18990, _G19031, _G19017) .
optELSEactionList([noop], _G19077, _G19077)  :-
 true .

buildECAevent(_G19093, _G19141, _G19144)  :-
 'ECAeventOperation'(_G19095, _G19141, ['('|_G19183]),
 lit(_G19100, _G19183, [')'|_G19144]),
 makeECAevent(_G19095, _G19100, _G19093),
 ! .
buildECAevent(_G19216, _G19252, _G19255)  :-
 'ECAeventOperation'(_G19218, _G19252, _G19280),
 lit(_G19220, _G19280, _G19255),
 makeECAevent(_G19218, _G19220, _G19216),
 ! .
buildECAevent(_G19321, [ident(_G19323), '('|_G19418], _G19401)  :-
 memberchk(_G19323, ['Ask', ask]),
 litarg(_G19345, _G19418, [')'|_G19401]),
 resolveDeriveExpression('In'('_tempvarxyz', _G19345), _G19354),
 makeECAevent('Ask', _G19354, _G19321),
 ! .
buildECAevent(_G19457, [ident(_G19459)|_G19539], _G19525)  :-
 memberchk(_G19459, ['Ask', ask]),
 litarg(_G19478, _G19539, _G19525),
 resolveDeriveExpression('In'('_tempvarxyz', _G19478), _G19484),
 makeECAevent('Ask', _G19484, _G19457),
 ! .

buildECAcondition(_G19575, _G19576, [ident(_G19576)|_G19621], _G19621)  :-
 memberchk(_G19576, [true, false]),
 ! .
buildECAcondition(_G19644, _G19645, _G19679, _G19682)  :-
 'ECAconditionFormula'(_G19647, _G19679, _G19682),
 makeECAcondition(_G19644, _G19647, _G19645),
 ! .

'ECAconditionFormula'(_G19727, ['('|_G19772], _G19758)  :-
 'ECAconditionFormula'(_G19727, _G19772, [')'|_G19758]),
 true .
'ECAconditionFormula'(_G19802, _G19824, _G19827)  :-
 'ECAconditionFormula1'(_G19804, _G19824, _G19852),
 'ECAconditionFormula2'(_G19804, _G19802, _G19852, _G19827) .

'ECAconditionFormula1'(_G19894, _G19910, _G19913)  :-
 ecalit(_G19894, _G19910, _G19913) .
'ECAconditionFormula1'(not(_G19948), [ident(not)|_G19999], _G19985)  :-
 ecalit(_G19948, _G19999, _G19985),
 ! .
'ECAconditionFormula1'(not(_G20026), [ident(not), '('|_G20084], _G20067)  :-
 'ECAconditionFormula'(_G20026, _G20084, [')'|_G20067]),
 true .

'ECAconditionFormula2'(_G20114, and(_G20114, _G20115), [ident(and)|_G20166], _G20148)  :-
 'ECAconditionFormula'(_G20115, _G20166, _G20148) .
'ECAconditionFormula2'(_G20190, or(_G20190, _G20191), [ident(or)|_G20242], _G20224)  :-
 'ECAconditionFormula'(_G20191, _G20242, _G20224) .
'ECAconditionFormula2'(_G20266, _G20266, _G20289, _G20289)  :-
 true .

buildECAactionList([_G20309|_G20310], _G20333, _G20336)  :-
 'ECAaction'(_G20309, _G20333, _G20361),
 buildECAactionList_rest(_G20310, _G20361, _G20336) .

buildECAactionList_rest(_G20396, [ (',')|_G20443], _G20429)  :-
 !,
 buildECAactionList(_G20396, _G20443, _G20429) .
buildECAactionList_rest([], _G20489, _G20489)  :-
 ! .

'ECAaction'(noop, [ident(noop)|_G20535], _G20535)  :-
 ! .
'ECAaction'(noop, [ident(commit)|_G20581], _G20581)  :-
 ! .
'ECAaction'(reject, [ident(reject)|_G20627], _G20627)  :-
 ! .
'ECAaction'(tBegin, [ident(tBegin)|_G20673], _G20673)  :-
 ! .
'ECAaction'(tEnd, [ident(tEnd)|_G20719], _G20719)  :-
 ! .
'ECAaction'(_G20735, _G20783, _G20786)  :-
 'ECAactionOperation'(_G20737, _G20783, ['('|_G20825]),
 ecalit(_G20742, _G20825, [')'|_G20786]),
 makeECAaction(_G20737, _G20742, _G20735),
 ! .
'ECAaction'(_G20858, _G20894, _G20897)  :-
 'ECAactionOperation'(_G20860, _G20894, _G20922),
 ecalit(_G20862, _G20922, _G20897),
 makeECAaction(_G20860, _G20862, _G20858),
 ! .
'ECAaction'(_G20963, [ident(_G20965), '('|_G21051], _G21034)  :-
 memberchk(_G20965, ['Raise', raise]),
 deriveExpression(_G20987, _G21051, [')'|_G21034]),
 makeECAaction('Raise', _G20987, _G20963),
 ! .
'ECAaction'(_G21087, [ident(_G21089)|_G21160], _G21146)  :-
 memberchk(_G21089, ['Raise', raise]),
 deriveExpression(_G21108, _G21160, _G21146),
 makeECAaction('Raise', _G21108, _G21087),
 ! .
'ECAaction'(_G21193, [ident(_G21195), ident(_G21214)|_G21255], _G21255)  :-
 memberchk(_G21195, ['Raise', raise]),
 makeECAaction(_G21195, _G21214, _G21193),
 ! .

'ECAeventOperation'(_G21280, [ident(_G21280)|_G21328], _G21328)  :-
 memberchk(_G21280, ['Tell', 'Untell', tell, untell]),
 ! .

'ECAactionOperation'(_G21347, [ident(_G21347)|_G21416], _G21416)  :-
 memberchk(_G21347, ['Tell', 'Untell', 'Retell', 'Ask', 'Call', 'CALL', tell, untell, retell, ask, call]),
 ! .

ecalit(new(_G21435), [ident(new), '('|_G21493], _G21476)  :-
 lit(_G21435, _G21493, [')'|_G21476]),
 true .
ecalit(new(_G21523), [_G21527|_G21575], _G21561)  :-
 pc_ascii(_G21527, 96),
 lit(_G21523, _G21575, _G21561) .
ecalit(_G21602, _G21618, _G21621)  :-
 lit(_G21602, _G21618, _G21621) .

bulkQueryCall(bulkquery(_G21656), [ident(bulk), '['|_G21718], _G21701)  :-
 bulkArgList(_G21656, _G21718, _G21701),
 temp_msp(_G21670) .

bulkArgList([_G21745], _G21770, _G21773)  :-
 bulkArg(_G21745, _G21770, [']'|_G21773]),
 true .
bulkArgList([_G21814|_G21815], _G21844, _G21847)  :-
 bulkArg(_G21814, _G21844, [ (',')|_G21886]),
 bulkArgList(_G21815, _G21886, _G21847) .

bulkArg(plainarg(_G21910), _G21936, _G21939)  :-
 constantval(_G21910, _G21936, _G21939),
 ! .
bulkArg(plainarg(_G21977), _G22003, _G22006)  :-
 selectExpression(_G21977, _G22003, _G22006),
 ! .
bulkArg(plainarg(_G22044), _G22070, _G22073)  :-
 objectname(_G22044, _G22070, _G22073),
 ! .
bulkArg(unknown(_G22111), _G22137, _G22140)  :-
 falseSelectExpression(_G22111, _G22137, _G22140),
 ! .
bulkArg(unknown(_G22178), _G22204, _G22207)  :-
 simplelabel(_G22178, _G22204, _G22207),
 ! .

falseSelectExpression(select(_G22245, _G22246, _G22247), _G22307, _G22310)  :-
 anyArg(_G22245, _G22307, [select(_G22246)|_G22349]),
 anyArg(_G22247, _G22349, _G22310),
 memberchk(_G22246, [ (->), =>, !, ^, @]),
 ! .
falseSelectExpression(_G22379, ['('|_G22424], _G22410)  :-
 falseSelectExpression(_G22379, _G22424, [')'|_G22410]),
 true .

anyArg(_G22454, _G22470, _G22473)  :-
 simplelabel(_G22454, _G22470, _G22473) .
anyArg(_G22508, [string(_G22508)|_G22530], _G22530)  :-
 true .
anyArg(_G22546, [intNumber(_G22546)|_G22568], _G22568)  :-
 true .
anyArg(_G22584, [realNumber(_G22584)|_G22606], _G22606)  :-
 true .
anyArg(_G22622, [falseSelectExpression(_G22622)|_G22644], _G22644)  :-
 true .

buildQuerycall(class(_G22660), _G22686, _G22689)  :-
 bulkQueryCall(_G22660, _G22686, _G22689),
 ! .
buildQuerycall(class(_G22727), _G22745, _G22748)  :-
 arExpr(_G22727, _G22745, _G22748) .
buildQuerycall(class(_G22783), _G22801, _G22804)  :-
 deriveExpression(_G22783, _G22801, _G22804) .

convertSelectExpression(_G22839, _G22855, _G22858)  :-
 selectExpression(_G22839, _G22855, _G22858) .
convertSelectExpression(_G22893, _G22909, _G22912)  :-
 objectname(_G22893, _G22909, _G22912) .
