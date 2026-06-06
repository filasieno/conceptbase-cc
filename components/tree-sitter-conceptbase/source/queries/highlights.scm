(comment) @comment
(prolog_comment) @comment

[
  "in" "IN"
  "isA" "ISA"
  "with" "WITH"
  "end" "END"
  "endmit" "ENDMIT"
] @keyword

[
  "forall" "FORALL"
  "exists" "EXISTS"
  "not" "NOT"
  "and" "AND"
  "or" "OR"
  "ON" "on"
  "DO" "do"
  "ELSE" "else"
  "FOR" "for"
  "TRANSACTIONAL" "transactional"
  "IF" "IFNEW"
] @keyword.control

[
  "Tell" "tell"
  "Untell" "untell"
  "Retell" "retell"
  "Ask" "ask"
  "Call" "call" "CALL"
  "Raise" "raise"
  "noop" "reject"
] @function

; Builtin functors (From, To, A, Ai, AL, In, Isa, P, …) are ordinary labels,
; so they are not reserved nodes; highlight them as builtin predicates by name.
((label) @function.builtin
  (#match? @function.builtin
   "^(From|To|A|Ai|AL|In|Isa|Label|P|LT|GT|LE|GE|EQ|NE|IDENTICAL|UNIFIES|Known|Terminated)$"))

(assertion_embedding "$" @punctuation.special
                      "$" @punctuation.special)

(string_label) @string
(assertion_embedding) @embedded

(identifier) @variable
(number) @number
(boolean) @constant.builtin
