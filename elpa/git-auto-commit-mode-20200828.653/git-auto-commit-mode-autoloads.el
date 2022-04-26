;;; git-auto-commit-mode-autoloads.el --- automatically extracted autoloads  -*- lexical-binding: t -*-
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "git-auto-commit-mode" "git-auto-commit-mode.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from git-auto-commit-mode.el

(autoload 'git-auto-commit-mode "git-auto-commit-mode" "\
Automatically commit any changes made when saving with this
mode turned on and optionally push them too.

This is a minor mode.  If called interactively, toggle the
`Git-Auto-Commit mode' mode.  If the prefix argument is positive,
enable the mode, and if it is zero or negative, disable the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `git-auto-commit-mode'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

\(fn &optional ARG)" t nil)

(register-definition-prefixes "git-auto-commit-mode" '("gac-"))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; git-auto-commit-mode-autoloads.el ends here
