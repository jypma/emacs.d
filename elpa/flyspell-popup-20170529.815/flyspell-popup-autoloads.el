;;; flyspell-popup-autoloads.el --- automatically extracted autoloads  -*- lexical-binding: t -*-
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "flyspell-popup" "flyspell-popup.el" (0 0 0
;;;;;;  0))
;;; Generated autoloads from flyspell-popup.el

(autoload 'flyspell-popup-correct "flyspell-popup" "\
Use popup for flyspell correction.
Adapted from `flyspell-correct-word-before-point'." t nil)

(autoload 'flyspell-popup-auto-correct-mode "flyspell-popup" "\
Minor mode for automatically correcting word at point.

This is a minor mode.  If called interactively, toggle the
`Flyspell-Popup-Auto-Correct mode' mode.  If the prefix argument
is positive, enable the mode, and if it is zero or negative,
disable the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `flyspell-popup-auto-correct-mode'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

\(fn &optional ARG)" t nil)

(register-definition-prefixes "flyspell-popup" '("flyspell-popup-"))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; flyspell-popup-autoloads.el ends here
