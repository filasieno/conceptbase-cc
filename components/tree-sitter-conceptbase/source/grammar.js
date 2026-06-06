/**
 * Tree-sitter grammar for ConceptBase model sources (.sml).
 *
 * Specification: docs/SPECIFICATION.md
 */

// Precedence — higher binds tighter. Mirrors the authoritative parsers:
//   * te_parser.y: SELECTOR1 binds tighter than SELECTOR2 (both %left).
//   * parseAss.dcg `exp`: elemexp > and > or > ==> > <==>  (line ~212),
//     and arithmetic arExpr > arTerm > arFactor (mul tighter than add).
const PREC = {
  // Logical connectives (tight -> loose): not/` > and > or > ==> > <==>
  equiv: 20,
  impl: 21,
  or: 22,
  and: 23,
  neg: 31,
  // Arithmetic / comparison (tight -> loose): mul > add > cmp
  cmp: 10,
  add: 11,
  mul: 12,
  // Selectors and derive (frame + assertion object names)
  derive: 1,
  select2: 2,
  select1: 3,
  path: 4,
};

module.exports = grammar({
  name: "conceptbase",

  extras: ($) => [/\s/, $.comment, $.prolog_comment],

  conflicts: ($) => [
    [$.property, $.complex_ref],
    [$.variable_bind, $.var_list],
    [$.assertion, $.constraint],
    [$.rule, $.formula],
    [$.literal_arg, $.ar_factor],
    [$.object_name, $.select_exp_a],
    [$.cond_formula, $.literal],
    [$.object_name, $.ar_factor],
    [$.ar_factor, $.derive_exp],
    [$.single_binding, $.literal_arg],
    [$.object_name, $.literal_arg],
    [$.object_name, $.single_exp],
    [$.select_exp_a, $.assertion_restriction],
    [$.object_name, $.literal2, $.select_exp_a],
    [$.literal_arg, $.select_exp_a],
    [$.variable_bind_list],
    [$.object_name],
    [$.literal, $.fun_expr],
    [$.object_name, $.derive_exp],
    [$.end_spec],
  ],

  rules: {
    source_file: ($) =>
      repeat(choice($.directive, $.telos_object, $.assertion_embedding)),

    directive: ($) =>
      choice(
        token("{$set syntax=CML}"),
        token("{$set syntax=PlainToronto}"),
        token("{$set syntax=PlainAachen}"),
        token(/\{\$set module=[^}]+\}/)
      ),

    comment: ($) => token(prec(-1, /\{[^{}]*\}/)),

    prolog_comment: ($) =>
      token(prec(-1, seq("(*", /[^*]*\*+([^*)][^*]*\*+)*/, ")"))),

    telos_object: ($) =>
      choice(
        seq(
          field("category", $.object_name),
          field("name", $.object_name),
          optional(field("in", seq($.kw_in, $.class_list))),
          optional(field("isa", seq($.kw_isa, $.class_list))),
          optional(field("with", seq($.kw_with, optional($.decl_list)))),
          field("end", $.end_spec)
        ),
        seq(
          field("name", $.object_name),
          optional(field("in", seq($.kw_in, $.class_list))),
          optional(field("isa", seq($.kw_isa, $.class_list))),
          optional(field("with", seq($.kw_with, optional($.decl_list)))),
          field("end", $.end_spec)
        )
      ),

    // endspec --> END | ENDMIT objectname  (te_parser.y).
    // In PlainToronto mode `end` lexes to ENDMIT, so a trailing closing name
    // (conventionally the object's own name) is allowed; make it optional.
    end_spec: ($) =>
      choice(
        prec.dynamic(1, seq($._end_kw, field("name", $.object_name))),
        $._end_kw
      ),

    _end_kw: ($) => choice("end", "END", "endmit", "ENDMIT"),

    class_list: ($) => sep1($.object_name, ","),

    decl_list: ($) => repeat1($.declaration),

    declaration: ($) => seq($.attr_category_list, $.property_list),

    attr_category_list: ($) => sep1($.label, ","),

    property_list: ($) => sep1($.property, ";"),

    property: ($) =>
      choice(
        seq(field("name", $.label), ":", field("value", $.object_name)),
        seq(field("name", $.label), ":", field("value", $.complex_ref)),
        seq(field("name", $.label), ":", field("value", $.enumeration)),
        seq(field("name", $.label), ":", field("value", $.path_expression)),
        seq(
          field("name", $.label),
          ":",
          field("value", $.assertion_embedding)
        )
      ),

    complex_ref: ($) =>
      seq(
        $.object_name,
        optional(seq($.kw_with, optional($.decl_list))),
        $.end_spec
      ),

    enumeration: ($) => seq("[", $.class_list, "]"),

    path_expression: ($) =>
      seq($.object_name, $.select_b, $.path_argument),

    path_argument: ($) =>
      choice(
        $.label,
        seq($.label, $.select_b, $.path_argument),
        seq($.path_restriction, optional(seq($.select_b, $.path_argument)))
      ),

    path_restriction: ($) =>
      choice(
        seq("(", field("label", $.label), ":", field("value", $.enumeration), ")"),
        seq("(", field("label", $.label), ":", field("value", $.path_expression), ")"),
        seq("(", field("label", $.label), ":", field("value", $.object_name), ")")
      ),

    object_name: ($) =>
      choice(
        seq("(", $.object_name, ")"),
        seq($.label, optional($.bindings)),
        prec.left(PREC.select1, seq($.object_name, $.selector1, $.label)),
        prec.left(PREC.select2, seq($.object_name, $.selector2, $.object_name))
      ),

    bindings: ($) => seq("[", $.binding_list, "]"),

    binding_list: ($) => sep1($.single_binding, ","),

    single_binding: ($) =>
      choice(
        seq($.object_name, "/", $.label),
        seq($.label, ":", $.object_name)
      ),

    selector1: ($) => choice("!", "^", "@"),
    selector2: ($) => choice("->", "=>"),
    select_b: ($) => choice(".", "|"),

    label: ($) =>
      choice($.identifier, $.string_label, $.number),

    string_label: ($) => token(seq('"', /([^"\\]|\\.)*/, '"')),

    // LABEL (spec): any run of characters except .|'"$:;!^->=,()[]{}/ and
    // whitespace. We keep a letter/underscore start, but allow extra spec-legal
    // label characters (& % ?) inside, e.g. `onlyConceptRelationship&Attrib_name`.
    identifier: ($) =>
      /[A-Za-z_\u00C0-\u024F\u00B9\u00B2\u00B3][A-Za-z0-9_\u00C0-\u024F\u00B9\u00B2\u00B3&%?]*/,

    number: ($) => choice($.integer, $.real),

    integer: ($) => /-?[0-9]+/,
    real: ($) => /-?([0-9]+\.[0-9]*|[0-9]*\.[0-9]+)([Ee][+-]?[0-9]+)?/,

    kw_in: ($) => choice("in", "IN"),
    kw_isa: ($) => choice("isA", "ISA"),
    kw_with: ($) => choice("with", "WITH"),

    assertion_embedding: ($) =>
      seq("$", field("body", $.assertion), "$"),

    assertion: ($) =>
      choice($.ecarule, $.rule, $.constraint, $.formula),

    rule: ($) =>
      choice(
        seq(
          $.kw_forall,
          field("binds", $.variable_bind_list),
          "(",
          field("condition", $.formula),
          ")",
          "==>",
          field("conclusion", $.literal)
        ),
        seq(
          field("condition", $.formula),
          "==>",
          field("conclusion", $.literal)
        ),
        field("literal", $.literal)
      ),

    constraint: ($) => field("formula", $.formula),

    formula: ($) =>
      choice(
        seq($.kw_exists, field("binds", $.variable_bind_list), field("body", $.formula)),
        seq($.kw_forall, field("binds", $.variable_bind_list), field("body", $.formula)),
        prec(PREC.neg, seq($.kw_not, field("operand", $.formula))),
        prec(PREC.neg, seq("`", field("operand", $.formula))),
        prec.left(PREC.equiv, seq($.formula, "<==>", $.formula)),
        prec.left(PREC.impl, seq($.formula, "==>", $.formula)),
        prec.left(PREC.and, seq($.formula, $.kw_and, $.formula)),
        prec.left(PREC.or, seq($.formula, $.kw_or, $.formula)),
        seq("(", $.formula, ")"),
        $.literal,
        $.literal2
      ),

    variable_bind_list: ($) => repeat1($.variable_bind),

    variable_bind: ($) =>
      choice(
        seq(field("vars", $.var_list), "/", field("type", $.object_name)),
        seq(field("vars", $.var_list), "/", "[", field("types", $.obj_list), "]"),
        seq(field("var", $.identifier), "/", field("type", $.select_exp_b))
      ),

    var_list: ($) => sep1($.identifier, ","),
    obj_list: ($) => sep1($.object_name, ","),

    literal: ($) =>
      choice(
        // Predicate / functor application. Functors (A, Ai, AL, In, Isa, P, …)
        // are not reserved: they are ordinary labels here, so they remain usable
        // as variable names and labels elsewhere (e.g. `forall A,B/VAR`).
        seq(field("predicate", $.label), "(", optional($.literal_arg_list), ")"),
        seq("(", $.literal_arg, $.infix_symbol, $.literal_arg, ")"),
        seq(
          "(",
          $.literal_arg,
          "[",
          field("deep_op", $.infix_symbol),
          "]",
          $.literal_arg,
          ")"
        ),
        prec.left(PREC.cmp, seq("(", $.ar_expr, $.comp_symbol, $.ar_expr, ")")),
        seq(
          "(",
          $.literal_arg,
          field("label", $.label),
          "/",
          field("label2", $.label),
          $.literal_arg,
          ")"
        ),
        $.boolean
      ),

    literal2: ($) =>
      choice(
        seq("(", $.label, $.kw_in, $.select_exp_b, ")"),
        seq("(", $.select_exp_a, $.kw_in, $.select_exp_b, ")"),
        seq("(", $.select_exp_b, $.kw_isa, $.select_exp_b, ")"),
        seq("(", $.select_exp_b, "=", $.select_exp_b, ")")
      ),

    literal_arg_list: ($) => sep1($.literal_arg, ","),
    literal_arg: ($) =>
      choice($.object_name, $.derive_exp, $.implicit_var, $.count_exp),

    implicit_var: ($) => seq("~", $.identifier),

    infix_symbol: ($) =>
      choice($.comp_symbol, $.label, $.kw_in, $.kw_isa),

    comp_symbol: ($) =>
      choice("<", ">", "<=", ">=", "=", "<>", "==", "\\="),

    boolean: ($) => choice("TRUE", "FALSE", "true", "false"),

    ar_expr: ($) =>
      choice(
        prec.left(PREC.add, seq($.ar_expr, choice("+", "-"), $.ar_term)),
        $.ar_term
      ),

    ar_term: ($) =>
      choice(
        prec.left(PREC.mul, seq($.ar_term, choice("*", "/"), $.ar_factor)),
        $.ar_factor
      ),

    ar_factor: ($) =>
      choice(seq("(", $.ar_expr, ")"), $.count_exp, $.object_name, $.fun_expr),

    // COUNT shortcut: `#<litarg>` (parseAss.dcg countExpr --> '#' litarg).
    count_exp: ($) => seq("#", $.literal_arg),

    fun_expr: ($) =>
      choice(
        seq($.label, "(", ")"),
        seq($.label, "(", $.literal_arg_list, ")")
      ),

    select_exp_a: ($) =>
      choice(
        prec.left(PREC.select1, seq($.select_exp_a, $.selector1, $.select_exp_a)),
        prec.left(PREC.select2, seq($.select_exp_a, $.selector2, $.select_exp_a)),
        seq("(", $.select_exp_a, ")"),
        $.label,
        $.derive_exp
      ),

    derive_exp: ($) =>
      choice(
        seq($.label, "[", optional($.derive_exp_list), "]"),
        seq($.label, "[", optional($.literal_arg_list), "]"),
        $.fun_expr
      ),

    derive_exp_list: ($) => sep1($.single_exp, ","),

    single_exp: ($) =>
      choice(
        seq($.literal_arg, "/", $.label),
        seq($.label, ":", $.label)
      ),

    select_exp_b: ($) =>
      choice(
        seq($.label, $.select_b, $.label),
        seq($.label, $.select_b, $.select_exp_b2)
      ),

    select_exp_b2: ($) =>
      choice(
        $.select_exp_b,
        seq($.assertion_restriction, $.select_b, $.label),
        seq($.assertion_restriction, $.select_b, $.select_exp_b2),
        seq($.assertion_restriction, $.select_b, $.assertion_restriction)
      ),

    assertion_restriction: ($) =>
      choice(
        seq("(", $.label, ":", $.label, ")"),
        seq("(", $.label, ":", $.select_exp_a, ")"),
        seq("(", $.label, ":", $.select_exp_b, ")"),
        seq("(", $.label, ":", "[", $.obj_list, "]", ")")
      ),

    kw_forall: ($) => choice("forall", "FORALL"),
    kw_exists: ($) => choice("exists", "EXISTS"),
    kw_not: ($) => choice("not", "NOT"),
    kw_and: ($) => choice("and", "AND"),
    kw_or: ($) => choice("or", "OR"),

    ecarule: ($) =>
      seq(
        optional($.variable_bind_list),
        $.kw_on,
        optional($.kw_transactional),
        field("event", $.eca_event),
        optional(seq($.kw_for, field("queue", $.identifier))),
        optional(seq($.if_clause, field("condition", $.cond_formula))),
        $.kw_do,
        field("actions", $.action_list),
        optional(seq($.kw_else, field("else_actions", $.action_list)))
      ),

    eca_event: ($) =>
      choice(
        seq(field("op", $.event_op), "(", field("literal", $.literal), ")"),
        seq(field("op", $.event_op), field("literal", $.literal)),
        seq(field("op", $.ask_op), "(", field("arg", $.literal_arg), ")"),
        seq(field("op", $.ask_op), field("arg", $.literal_arg))
      ),

    event_op: ($) => choice("Tell", "tell", "Untell", "untell"),
    ask_op: ($) => choice("Ask", "ask"),

    if_clause: ($) => choice("IF", seq("IF", "NEW"), "IFNEW"),

    cond_formula: ($) =>
      choice(
        $.literal,
        $.literal2,
        prec(PREC.neg, seq($.kw_not, $.cond_formula)),
        prec(PREC.neg, seq("`", $.cond_formula)),
        prec.left(PREC.and, seq($.cond_formula, $.kw_and, $.cond_formula)),
        prec.left(PREC.or, seq($.cond_formula, $.kw_or, $.cond_formula)),
        seq("(", $.cond_formula, ")"),
        $.boolean
      ),

    action_list: ($) => sep1($.action, ","),

    action: ($) =>
      choice(
        seq(field("op", $.action_op), "(", field("literal", $.literal), ")"),
        seq(field("op", $.action_op), field("literal", $.literal)),
        "noop",
        "reject"
      ),

    action_op: ($) =>
      choice(
        "Tell",
        "tell",
        "Untell",
        "untell",
        "Retell",
        "retell",
        "Ask",
        "ask",
        "Call",
        "call",
        "CALL",
        "Raise",
        "raise"
      ),

    kw_on: ($) => choice("ON", "on"),
    kw_do: ($) => choice("DO", "do"),
    kw_else: ($) => choice("ELSE", "else"),
    kw_for: ($) => choice("FOR", "for"),
    kw_transactional: ($) => choice("TRANSACTIONAL", "transactional"),
  },
});

function sep1(rule, separator) {
  return seq(rule, repeat(seq(separator, rule)));
}
