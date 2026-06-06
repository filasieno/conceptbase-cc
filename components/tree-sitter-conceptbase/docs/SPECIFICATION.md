# ConceptBase language — specification sources and grammar coverage

This document records where the ConceptBase surface language is defined and how
completely `source/grammar.js` implements it.

## Primary specification (user manual)

| Topic | Location | EBNF section |
|-------|----------|--------------|
| Telos frames | `components/doc/user-manual/chapters/SyntaxDef.typ` | *Syntax specifications for Telos frames* |
| CBL rules / constraints | same file | *Syntax of the rule and constraint language* |
| ECArules | same file | `<sec:ecasyntax>` — *Syntax of active rules* |
| Terminals (labels, numbers, selectors) | same file | *Terminal symbols* |
| Prolog embeddings in models | `components/doc/user-manual/chapters/Language.typ` | `<sec:rulesyntax>` — formulas between `$` delimiters |

## Reference implementations (lexer / parser)

| Artifact | Path | Role |
|----------|------|------|
| Telos flex lexer | `components/libcbtelos/src/te_parser.l` | Comments `{…}`, directives `{$set …}`, `$…$` strings, CML/PT `end`/`endmit` |
| Token DCG | `components/grammar-compiler/src/tokens.dcg` | Identifiers, assertion strings, `(* … *)` Prolog comments, `~` implicit vars |
| Assertion DCG | `components/grammar-compiler/src/parseAss.dcg` | CBL + ECArule semantics, module `@` qualifiers, `Terminated` functor |
| Syntax (legacy TeX) | `conceptbase-cc-git/ProductPOOL/doc/UserManual/SyntaxDef.tex` | Same EBNF as Typst manual |

## Grammar rule mapping

### Telos frames (`SyntaxDef.typ` lines 6–73)

| EBNF | Tree-sitter rule | Status |
|------|------------------|--------|
| `<object>` | `telos_object` | Implemented (single- and two-name forms) |
| `<objectname>` | `object_name` | Implemented (+ `@` selector, see extensions) |
| `<bindings>` … `<singlebinding>` | `bindings`, `binding_list`, `single_binding` | Implemented |
| `<inspec>` / `<isaspec>` / `<withspec>` | optional `in` / `isa` / `with` fields | Implemented |
| `<decllist>` / `<declaration>` | `decl_list`, `declaration` | Implemented |
| `<property>` (4 value kinds) | `property` | Implemented + `assertion_embedding` for rule/constraint values |
| `<complexref>` | `complex_ref` | Implemented |
| `<enumeration>` | `enumeration` | Implemented |
| `<pathexpression>` … `<restriction>` | `path_expression`, `path_argument`, `path_restriction` | Implemented |
| `<endspec>` | `end_spec` | Implemented (`end`, `END`, `endmit`, `ENDMIT`) |
| `<label>` | `label` | Implemented (`identifier`, `"…"`, `$…$`, numbers) |

### CBL (`SyntaxDef.typ` lines 85–190)

| EBNF | Tree-sitter rule | Status |
|------|------------------|--------|
| `<assertion>` | `assertion` | Implemented (`ecarule`, `rule`, `constraint`, `formula`) |
| `<rule>` / `<constraint>` | `rule`, `constraint` | Implemented |
| `<formula>` | `formula` | Implemented (operator precedence per `parseAss.dcg`) |
| `<variableBind>` … | `variable_bind_list`, `variable_bind`, `var_list` | Implemented |
| `<literal>` / `<literal2>` | `literal`, `literal2` | Implemented |
| `<infixSymbol>` incl. `in` / `isA` | `infix_symbol` | Implemented |
| `<arExpr>` … `<funExpr>` | `ar_expr`, `ar_term`, `ar_factor`, `fun_expr` | Implemented |
| `<selectExpA>` / `<deriveExp>` | `select_exp_a`, `derive_exp` | Implemented (both `deriveExpList` and `literalArgList` bracket forms) |
| `<selectExpB>` … `<restriction>` | `select_exp_b`, `select_exp_b2`, `assertion_restriction` | Implemented |
| `FUNCTOR` list | `functor` | Implemented (+ `Terminated` from `parseAss.dcg`) |
| `BOOLEAN` | `boolean` | Implemented |

### ECArules (`SyntaxDef.typ` lines 199–245)

| EBNF | Tree-sitter rule | Status |
|------|------------------|--------|
| `<ecarule>` | `ecarule` | Implemented |
| `<ifclause>` (`IF`, `IFNEW`) | `if_clause` | Implemented (`IF NEW` alias) |
| `<ecaevent>` / `<ecacondition>` | `eca_event`, `cond_formula` | Implemented |
| `<actionlist>` / `<action>` | `action_list`, `action` | Implemented |
| `<optelseaction>` | optional `else_actions` | Implemented |

### Terminals (`SyntaxDef.typ` lines 249–282)

| Terminal | Implementation | Status |
|----------|----------------|--------|
| `ALPHANUM` / `LABEL` (unquoted) | `identifier` regex + accent chars | Implemented |
| `LABEL` in `"…"` | `string_label` token (supports `\"` escapes) | Implemented |
| `$ … $` (assertion embedding) | `assertion_embedding` with `$` delimiters; body parsed as `assertion` | Implemented |
| `NUMBER` / `REAL` / `INTEGER` | `number`, `integer`, `real` | Implemented |
| `SELECTOR1` `!` `^` | `selector1` | Implemented (+ `@` from `te_parser.l`) |
| `SELECTOR2` `->` `=>` | `selector2` | Implemented |
| `SELECTORB` `.` `\|` | `select_b` | Implemented |
| `COMPSYMBOL` / `INFIXSYMBOL` | `comp_symbol`, `infix_symbol` | Implemented |

### Directives (`te_parser.l`)

| Directive | Status |
|-----------|--------|
| `{$set syntax=CML}` | Implemented |
| `{$set syntax=PlainToronto}` | Implemented |
| `{$set syntax=PlainAachen}` | Implemented |
| `{$set module=…}` | Implemented |

### Lexer extensions (`tokens.dcg`, `te_parser.l`)

| Feature | Status |
|---------|--------|
| Telos comments `{…}` | `comment` |
| Prolog comments `(* … *)` | `prolog_comment` |
| Implicit variables `~name` | `implicit_var` in `literal_arg` |
| Module qualifier `@Mod` on functors | Parsed as `@` in `selector1` on object names (structural; semantic desugaring is server-side) |

## Operator precedence (verified against YACC / DCG)

`grammar.js` precedence was cross-checked against the two authoritative parsers.
Tree-sitter resolves conflicts in favour of the **higher** precedence number, so
"binds tighter" ⇒ higher `PREC` value.

### Frame selectors — `components/libcbtelos/src/te_parser.y`

```
%left  SELECTOR2   /* lower priority than SELECTOR1 (see comment lines 150–153) */
%left  SELECTOR1
```

Both selectors are left-associative and `SELECTOR1` (`!` `^` `@`) binds tighter
than `SELECTOR2` (`->` `=>`). Grammar: `PREC.select1 (3) > PREC.select2 (2)`,
both `prec.left`. **Matches.** The same file's `object` rule (lines 238–248)
also confirms the two-name frame form binds `$1` as the **category**
(`new_Class($1)`) and `$2` as the object name — implemented as the
`category` / `name` fields on `telos_object`.

### Assertion connectives — `components/grammar-compiler/src/parseAss.dcg`

The `exp` rule (lines 212–218) is a layered precedence climb
`elemexp → and → or → ==> → <==>`, and line 338 states *"'and' has a higher
priority than 'or'"*. `not` (line 246, `elemexp(not(_t)) ==> [not], elemexp(_t)`)
binds only to the following atom. Resulting order, tight → loose:

| Operator | DCG layer | `PREC` | Assoc |
|----------|-----------|--------|-------|
| `not` / `` ` `` | `elemexp` | `neg` (31) | prefix |
| `and` | `andexp` | `and` (23) | left (flat list) |
| `or` | `orexp` | `or` (22) | left (flat list) |
| `==>` | `implexp` | `impl` (21) | left (line 364 recurses on `impl(_t1,_t5)`) |
| `<==>` | `equivexp` | `equiv` (20) | left |

Locked by corpus tests *"Connective precedence: …"* in `test/corpus/assertions.txt`.

### Arithmetic — `parseAss.dcg` lines 944–1047

`arExpr → arTerm → arFactor` makes `*` `/` bind tighter than `+` `-`, with
comparison (`COMPSYMBOL`) loosest. Grammar: `PREC.mul (12) > PREC.add (11) >
PREC.cmp (10)`; the layered `ar_expr` / `ar_term` / `ar_factor` rules also
enforce this structurally.

## UTF-8 and UTF-16 (C / C++ LSP)

Tree-sitter generates a **single** `parser.c`. Input encoding is not baked into the
grammar; it is passed to the runtime when parsing:

| API | Encoding |
|-----|----------|
| `conceptbase_parse_utf8()` | `TSInputEncodingUTF8` |
| `conceptbase_parse_utf16le()` | `TSInputEncodingUTF16LE` |
| `conceptbase_parse_utf16be()` | `TSInputEncodingUTF16BE` |
| `conceptbase::Parser::parse()` (C++) | UTF-8 `std::string_view` |
| `conceptbase::Parser::parse_utf16le()` | UTF-16 code units |

Headers installed for LSP integration:

- `tree-sitter-conceptbase.h` — `tree_sitter_conceptbase()`
- `conceptbase_parser.h` — C helpers
- `conceptbase_parser.hpp` — C++ RAII wrappers and `utf8_to_utf16le()`

Libraries: `libtree-sitter-conceptbase.so` (shared) and `libtree-sitter-conceptbase.a`
(static). Optional `tree-sitter-conceptbase.wasm` for the WASM backend.

The `tree-sitter parse --encoding utf16-be` CLI path is unreliable in tree-sitter
0.26.x; UTF-16BE is verified via the C API (`tests/test_parse.c`).

## Intentionally out of scope

| Item | Reason |
|------|--------|
| SML fragment Prolog syntax (`SyntaxDef.typ` `<sec:fragments>`) | Internal representation only; not used in `.sml` model files |
| Full semantic validation (predicate typing, stratification) | Server / `parseAss.dcg` runtime checks |
| `new(…)` / `CALL(…)` ECArule builtins beyond syntax | Accepted as ordinary `literal` / `fun_expr` shapes where syntactically valid |

## Known limitations

1. **`$ … $` is assertion-only** — Per `te_parser.l` (the `\$` → `rule_state` rule, lines 269–300), `$ … $` is exclusively the delimiter for an embedded CBL/Prolog assertion (rule / constraint / formula / ECArule). It is *not* a general label form, so the grammar parses the body structurally as an `assertion`. Double-quoted `"…"` is the only quoted-label form.
2. **CML keyword casing** — Both `in`/`IN`, `with`/`WITH`, etc. are accepted (per `te_parser.l` start states).
3. **`id_NUMBER` labels** — Forbidden in Telos per manual note; not generated by the grammar.

## Completeness verdict

The tree-sitter grammar is **complete for the published surface syntax** in `SyntaxDef.typ` for:

- Telos model files (`.sml`)
- CBL assertions in `$ … $` embeddings
- ECArule assertion bodies in `$ … $` embeddings
- ConceptBase source directives and both comment styles

It does **not** implement the internal SML-fragment interchange grammar (historical / server-internal).
