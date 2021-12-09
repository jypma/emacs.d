;;; gdscript-mode-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "gdscript-comint" "gdscript-comint.el" (0 0
;;;;;;  0 0))
;;; Generated autoloads from gdscript-comint.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-comint" '("gdscript-comint--" "godot-mode")))

;;;***

;;;### (autoloads nil "gdscript-comint-gdformat" "gdscript-comint-gdformat.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from gdscript-comint-gdformat.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-comint-gdformat" '("gdformat-mode" "gdscript-comint-gdformat--")))

;;;***

;;;### (autoloads nil "gdscript-completion" "gdscript-completion.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from gdscript-completion.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-completion" '("gdscript-completion-")))

;;;***

;;;### (autoloads nil "gdscript-customization" "gdscript-customization.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from gdscript-customization.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-customization" '("gdscript-")))

;;;***

;;;### (autoloads nil "gdscript-debug" "gdscript-debug.el" (0 0 0
;;;;;;  0))
;;; Generated autoloads from gdscript-debug.el

(autoload 'gdscript-debug-make-server "gdscript-debug" nil t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-debug" '("gdscript-")))

;;;***

;;;### (autoloads nil "gdscript-docs" "gdscript-docs.el" (0 0 0 0))
;;; Generated autoloads from gdscript-docs.el

(autoload 'gdscript-docs-browse-api "gdscript-docs" "\
Open the main page of Godot API. Use the universal prefix (C-u) to force browsing the online API.

\(fn &optional FORCE-ONLINE)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-docs" '("gdscript-docs-")))

;;;***

;;;### (autoloads nil "gdscript-fill-paragraph" "gdscript-fill-paragraph.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from gdscript-fill-paragraph.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-fill-paragraph" '("gdscript-fill-paragraph")))

;;;***

;;;### (autoloads nil "gdscript-format" "gdscript-format.el" (0 0
;;;;;;  0 0))
;;; Generated autoloads from gdscript-format.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-format" '("gdscript-")))

;;;***

;;;### (autoloads nil "gdscript-godot" "gdscript-godot.el" (0 0 0
;;;;;;  0))
;;; Generated autoloads from gdscript-godot.el

(defvar gdscript-godot--debug-options-hydra :not-list)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-godot" '("gdscript-godot-")))

;;;***

;;;### (autoloads nil "gdscript-history" "gdscript-history.el" (0
;;;;;;  0 0 0))
;;; Generated autoloads from gdscript-history.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-history" '("gdscript-history--")))

;;;***

;;;### (autoloads nil "gdscript-hydra" "gdscript-hydra.el" (0 0 0
;;;;;;  0))
;;; Generated autoloads from gdscript-hydra.el

(defvar gdscript-hydra--open nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-hydra" '("gdscript-hydra-")))

;;;***

;;;### (autoloads nil "gdscript-imenu" "gdscript-imenu.el" (0 0 0
;;;;;;  0))
;;; Generated autoloads from gdscript-imenu.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-imenu" '("gdscript-imenu-")))

;;;***

;;;### (autoloads nil "gdscript-indent-and-nav" "gdscript-indent-and-nav.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from gdscript-indent-and-nav.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-indent-and-nav" '("gdscript-")))

;;;***

;;;### (autoloads nil "gdscript-keywords" "gdscript-keywords.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from gdscript-keywords.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-keywords" '("gdscript-")))

;;;***

;;;### (autoloads nil "gdscript-mode" "gdscript-mode.el" (0 0 0 0))
;;; Generated autoloads from gdscript-mode.el

(add-to-list 'auto-mode-alist '("\\.gd\\'" . gdscript-mode))

(add-to-list 'auto-mode-alist '("\\.tscn\\'" . conf-toml-mode))

(add-to-list 'auto-mode-alist '("\\.tres\\'" . conf-toml-mode))

(autoload 'gdscript-mode "gdscript-mode" "\
Major mode for editing Godot GDScript files.

\(fn)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-mode" '("gdscript-")))

;;;***

;;;### (autoloads nil "gdscript-project" "gdscript-project.el" (0
;;;;;;  0 0 0))
;;; Generated autoloads from gdscript-project.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-project" '("gdscript-project--")))

;;;***

;;;### (autoloads nil "gdscript-rx" "gdscript-rx.el" (0 0 0 0))
;;; Generated autoloads from gdscript-rx.el

(autoload 'gdscript-rx-to-string "gdscript-rx" "\
Translate FORM from `rx' sexp syntax into a string regexp.
The arguments to `literal' and `regexp' forms inside FORM must be
constant strings.
If NO-GROUP is non-nil, don't bracket the result in a non-capturing
group.

For extending the `rx' notation in FORM, use `gdscript-rx-define' or `gdscript-rx-let-eval'.

\(fn FORM &optional NO-GROUP)" nil nil)

(autoload 'gdscript-rx-build-rx "gdscript-rx" "\
Translate regex REGEXPS in sexp form to a regexp string.
Each argument is one of the forms below; RX is a subform, and
RX... stands for zero or more RXs. For details, see Info
node `(elisp) Rx Notation'. See `gdscript-rx-to-string' for the
corresponding function.

STRING         Match a literal string.
CHAR           Match a literal character.

\(seq RX...)    Match the RXs in sequence.  Alias: :, sequence, and.
\(or RX...)     Match one of the RXs.  Alias: |.

\(zero-or-more RX...) Match RXs zero or more times.  Alias: 0+.
\(one-or-more RX...)  Match RXs one or more times.  Alias: 1+.
\(zero-or-one RX...)  Match RXs or the empty string.
Alias: opt, optional.
\(* RX...)       Match RXs zero or more times; greedy.
\(+ RX...)       Match RXs one or more times; greedy.
\(? RX...)       Match RXs or the empty string; greedy.
\(*? RX...)      Match RXs zero or more times; non-greedy.
\(+? RX...)      Match RXs one or more times; non-greedy.
\(?? RX...)      Match RXs or the empty string; non-greedy.
\(= N RX...)     Match RXs exactly N times.
\(>= N RX...)    Match RXs N or more times.
\(** N M RX...)  Match RXs N to M times.  Alias: repeat.
\(minimal-match RX)  Match RX, with zero-or-more, one-or-more, zero-or-one
                and aliases using non-greedy matching.
\(maximal-match RX)  Match RX, with zero-or-more, one-or-more, zero-or-one
                and aliases using greedy matching, which is the default.

\(any SET...)    Match a character from one of the SETs.  Each SET is a
                character, a string, a range as string \"A-Z\" or cons
                (?A . ?Z), or a character class (see below).  Alias: in, char.
\(not CHARSPEC)  Match one character not matched by CHARSPEC.  CHARSPEC
                can be a character, single-char string, (any ...), (or ...),
                (intersection ...), (syntax ...), (category ...),
                or a character class.
\(intersection CHARSET...) Match all CHARSETs.
                CHARSET is (any...), (not...), (or...) or (intersection...),
                a character or a single-char string.
not-newline     Match any character except a newline.  Alias: nonl.
anychar         Match any character.  Alias: anything.
unmatchable     Never match anything at all.

CHARCLASS       Match a character from a character class.  One of:
 alpha, alphabetic, letter   Alphabetic characters (defined by Unicode).
 alnum, alphanumeric         Alphabetic or decimal digit chars (Unicode).
 digit numeric, num          0-9.
 xdigit, hex-digit, hex      0-9, A-F, a-f.
 cntrl, control              ASCII codes 0-31.
 blank                       Horizontal whitespace (Unicode).
 space, whitespace, white    Chars with whitespace syntax.
 lower, lower-case           Lower-case chars, from current case table.
 upper, upper-case           Upper-case chars, from current case table.
 graph, graphic              Graphic characters (Unicode).
 print, printing             Whitespace or graphic (Unicode).
 punct, punctuation          Not control, space, letter or digit (ASCII);
                              not word syntax (non-ASCII).
 word, wordchar              Characters with word syntax.
 ascii                       ASCII characters (codes 0-127).
 nonascii                    Non-ASCII characters (but not raw bytes).

\(syntax SYNTAX)  Match a character with syntax SYNTAX, being one of:
  whitespace, punctuation, word, symbol, open-parenthesis,
  close-parenthesis, expression-prefix, string-quote,
  paired-delimiter, escape, character-quote, comment-start,
  comment-end, string-delimiter, comment-delimiter

\(category CAT)   Match a character in category CAT, being one of:
  space-for-indent, base, consonant, base-vowel,
  upper-diacritical-mark, lower-diacritical-mark, tone-mark, symbol,
  digit, vowel-modifying-diacritical-mark, vowel-sign,
  semivowel-lower, not-at-end-of-line, not-at-beginning-of-line,
  alpha-numeric-two-byte, chinese-two-byte, greek-two-byte,
  japanese-hiragana-two-byte, indian-two-byte,
  japanese-katakana-two-byte, strong-left-to-right,
  korean-hangul-two-byte, strong-right-to-left, cyrillic-two-byte,
  combining-diacritic, ascii, arabic, chinese, ethiopic, greek,
  korean, indian, japanese, japanese-katakana, latin, lao,
  tibetan, japanese-roman, thai, vietnamese, hebrew, cyrillic,
  can-break

Zero-width assertions: these all match the empty string in specific places.
 line-start         At the beginning of a line.  Alias: bol.
 line-end           At the end of a line.  Alias: eol.
 string-start       At the start of the string or buffer.
                     Alias: buffer-start, bos, bot.
 string-end         At the end of the string or buffer.
                     Alias: buffer-end, eos, eot.
 point              At point.
 word-start         At the beginning of a word.  Alias: bow.
 word-end           At the end of a word.  Alias: eow.
 word-boundary      At the beginning or end of a word.
 not-word-boundary  Not at the beginning or end of a word.
 symbol-start       At the beginning of a symbol.
 symbol-end         At the end of a symbol.

\(group RX...)  Match RXs and define a capture group.  Alias: submatch.
\(group-n N RX...) Match RXs and define capture group N.  Alias: submatch-n.
\(backref N)    Match the text that capture group N matched.

\(literal EXPR) Match the literal string from evaluating EXPR at run time.
\(regexp EXPR)  Match the string regexp from evaluating EXPR at run time.
\(eval EXPR)    Match the rx sexp from evaluating EXPR at compile time.

Additional constructs can be defined using `gdscript-rx-define' and
`gdscript-rx-let',which see.

\(fn REGEXPS...)" nil t)

(autoload 'gdscript-rx-let-eval "gdscript-rx" "\
Evaluate BODY with local BINDINGS for `gdscript-rx-to-string'.
BINDINGS, after evaluation, is a list of definitions each on the form
\(NAME [(ARGS...)] RX), in effect for calls to `gdscript-rx-to-string'
in BODY.

For bindings without an ARGS list, NAME is defined as an alias
for the `rx' expression RX.  Where ARGS is supplied, NAME is
defined as an `rx' form with ARGS as argument list.  The
parameters are bound from the values in the (NAME ...) form and
are substituted in RX.  ARGS can contain `&rest' parameters,
whose values are spliced into RX where the parameter name occurs.

Any previous definitions with the same names are shadowed during
the expansion of BODY only.
For extensions when using the `rx' macro, use `gdscript-rx-let'.
To make global rx extensions, use `gdscript-rx-define'.
For more details, see Info node `(elisp) Extending Rx'.

\(fn BINDINGS BODY...)" nil t)

(function-put 'gdscript-rx-let-eval 'lisp-indent-function '1)

(autoload 'gdscript-rx-let "gdscript-rx" "\
Evaluate BODY with local BINDINGS for `rx'.
BINDINGS is an unevaluated list of bindings each on the form
\(NAME [(ARGS...)] RX).
They are bound lexically and are available in `rx' expressions in
BODY only.

For bindings without an ARGS list, NAME is defined as an alias
for the `rx' expression RX.  Where ARGS is supplied, NAME is
defined as an `rx' form with ARGS as argument list.  The
parameters are bound from the values in the (NAME ...) form and
are substituted in RX.  ARGS can contain `&rest' parameters,
whose values are spliced into RX where the parameter name occurs.

Any previous definitions with the same names are shadowed during
the expansion of BODY only.
For local extensions to `gdscript-rx-to-string', use `gdscript-rx-let-eval'.
To make global rx extensions, use `gdscript-rx-define'.
For more details, see Info node `(elisp) Extending Rx'.

\(fn BINDINGS BODY...)" nil t)

(function-put 'gdscript-rx-let 'lisp-indent-function '1)

(autoload 'gdscript-rx-define "gdscript-rx" "\
Define NAME as a global `rx' definition.
If the DEFINITION args list is omitted, define NAME as an alias for the `rx'
expression RX.

If the args list is supplied, define NAME as an `rx' form with
args as argument list.  The parameters are bound from the values
in the (NAME ...) form and are substituted in RX.
args can contain `&rest' parameters, whose values are spliced
into RX where the parameter name occurs.

Any previous global definition of NAME is overwritten with the new one.
To make local rx extensions, use `gdscript-rx-let' for `rx',
`gdscript-rx-let-eval' for `gdscript-rx-to-string'.
For more details, see Info node `(elisp) Extending Rx'.

\(fn NAME [(args...)] RX)" nil t)

(function-put 'gdscript-rx-define 'lisp-indent-function '1)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-rx" '("gdscript-rx")))

;;;***

;;;### (autoloads nil "gdscript-syntax" "gdscript-syntax.el" (0 0
;;;;;;  0 0))
;;; Generated autoloads from gdscript-syntax.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-syntax" '("gdscript-")))

;;;***

;;;### (autoloads nil "gdscript-utils" "gdscript-utils.el" (0 0 0
;;;;;;  0))
;;; Generated autoloads from gdscript-utils.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "gdscript-utils" '("gdscript-")))

;;;***

;;;### (autoloads nil nil ("gdscript-mode-pkg.el") (0 0 0 0))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; gdscript-mode-autoloads.el ends here
