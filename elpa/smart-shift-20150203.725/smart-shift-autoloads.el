;;; smart-shift-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "smart-shift" "smart-shift.el" (0 0 0 0))
;;; Generated autoloads from smart-shift.el

(autoload 'smart-shift-right "smart-shift" "\
Shift the line or region to the ARG times to the right.

\(fn &optional ARG)" t nil)

(autoload 'smart-shift-left "smart-shift" "\
Shift the line or region to the ARG times to the left.

\(fn &optional ARG)" t nil)

(autoload 'smart-shift-up "smart-shift" "\
Shift current line or region to the ARG lines backwardly.

\(fn &optional ARG)" t nil)

(autoload 'smart-shift-down "smart-shift" "\
Shift current line or region to the ARG lines forwardly.

\(fn &optional ARG)" t nil)

(autoload 'smart-shift-pass-through "smart-shift" "\
Finish shifting and invoke the corresponding command.

\(fn)" t nil)

(autoload 'smart-shift-mode "smart-shift" "\
Shift line/region to left/right.

\(fn &optional ARG)" t nil)

(defvar global-smart-shift-mode nil "\
Non-nil if Global Smart-Shift mode is enabled.
See the `global-smart-shift-mode' command
for a description of this minor mode.
Setting this variable directly does not take effect;
either customize it (see the info node `Easy Customization')
or call the function `global-smart-shift-mode'.")

(custom-autoload 'global-smart-shift-mode "smart-shift" nil)

(autoload 'global-smart-shift-mode "smart-shift" "\
Toggle Smart-Shift mode in all buffers.
With prefix ARG, enable Global Smart-Shift mode if ARG is positive;
otherwise, disable it.  If called from Lisp, enable the mode if
ARG is omitted or nil.

Smart-Shift mode is enabled in all buffers where
`smart-shift-mode-on' would do it.
See `smart-shift-mode' for more information on Smart-Shift mode.

\(fn &optional ARG)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "smart-shift" '("smart-")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; smart-shift-autoloads.el ends here
