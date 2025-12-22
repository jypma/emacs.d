;;; Basic setup

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)
(add-to-list 'load-path "~/.emacs.d/lisp/")

(require 'package)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(setq package-enable-at-startup nil)
(package-initialize)

;; Always install use-package, so we can install packages using it
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile (require 'use-package))

(setq use-package-verbose t)
(setq use-package-expand-minimally nil)
;; Always install (ensure) packages when we use-package them
(setq use-package-always-ensure t)

(defun use-package-require (name &optional no-require body)
  (if use-package-expand-minimally
      (use-package-concat
       (unless no-require
         (list (use-package-load-name name)))
       body)
    (if no-require
        body
      (use-package-with-elapsed-timer
          (format "Loading package %s" name)
        `((if (not ,(use-package-load-name name))
              (display-warning 'use-package
                               (format "Cannot load %s" ',name)
                               :error)
            ,@body))))))

;;; Enable emacsclient
(require 'server)
(unless (server-running-p) (server-start))

;;; Customization of built-in features

;; We don't need the tool bar
(tool-bar-mode -1)

;; confirm with y instead of yes
(defalias 'yes-or-no-p 'y-or-n-p)

;; change spelling dictionary
(global-set-key (kbd "<f7>") 'ispell-change-dictionary)

;; Run calculator
(global-set-key (kbd "<f8>") 'calc)

;; Switch buffer with ibuffer (C-x C-b is bound by consult)
(global-set-key (kbd "C-x b") 'ibuffer)

;; Switch windows with M-o
(global-set-key (kbd "M-o") #'other-window)

;; Previous and next flymake error (inside lsp-mode)
(require 'flymake)
(define-key flymake-mode-map (kbd "M-n") 'flymake-goto-next-error)
(define-key flymake-mode-map (kbd "M-p") 'flymake-goto-prev-error)

;; Remember locations in files
(save-place-mode 1)

;; Ctrl-x k always kills current buffer
(global-set-key (kbd "C-x k") 'kill-current-buffer)

;; Don't save duplicates if the head of kill ring is the same
(setq kill-do-not-save-duplicates t)
;; ... but we also don't want duplicates further down the kill ring:
(defun my/remove-existing-kill (args)
  (let ((string (car args))
        (replace (cdr args)))
    (when (member string kill-ring)
      (setq kill-ring (delete string kill-ring)))
    (list string replace)))
(advice-add 'kill-new :filter-args #'my/remove-existing-kill)

;; "Command attempted to use minibuffer while in minibuffer" gets old fast.
(setq enable-recursive-minibuffers t)

;; Insert closing paren with opening one
(electric-pair-mode 1)

;; Remember recently opened files
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

;; scroll only new lines into view as needed, instead of a whole page at once
(setq scroll-conservatively 100)

;; don't make sounds, like, ever.
(setq ring-bell-function 'ignore)

;; enable whitespace-mode to show whitespace (and errors in it)
(require 'whitespace)
(add-hook 'prog-mode-hook #'whitespace-mode)
(add-hook 'conf-mode-hook #'whitespace-mode)
;; no whitespace mode for readonly files
(defun my/read-only-whitespace ()
  (when buffer-read-only
    (whitespace-mode -1)))
(add-hook 'find-file-hook 'my/read-only-whitespace)

;; Use these project markers as project.el root
(setq project-vc-extra-root-markers '(".project.el" ".projectile"))

;; Backup settings
(setq backup-directory-alist `(("." . "~/.cache/emacs-backup")))
(setq delete-old-versions t
  kept-new-versions 6
  kept-old-versions 1000
  vc-make-backup-files t ;; even backup version-controlled files
  version-control t)

;; Autosave settings
(make-directory "~/.cache/emacs-autosave" t)
(setq auto-save-list-file-prefix "~/.cache/emacs-autosave/sessions/"
      auto-save-file-name-transforms `((".*" "~/.cache/emacs-autosave/" t)))

;; Make Emacs backup everytime I save
(defun my/force-backup-of-buffer ()
  "Lie to Emacs, telling it the curent buffer has yet to be backed up."
  (setq buffer-backed-up nil))
(add-hook 'before-save-hook  'my/force-backup-of-buffer)

;; Unbind Ctrl-Z to not minimize emacs in UI mode
(global-unset-key [(control z)])
(global-unset-key [(control x)(control z)])

;; Unbind Ctrl-T since it's annoying (swaps last two characters)
(global-unset-key [(control t)])

;; UTF-8 support
(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

(global-subword-mode)

;; Outline mode: Shift-tab to cycle hiding

(require 'outline)
(keymap-set outline-minor-mode-map "<backtab>" 'outline-cycle)

;; Conf mode setup
(defun my/conf-mode-setup ()
  (setq c-basic-offset 2)
  (setq indent-tabs-mode nil)
  ;;disable for now, we only want this in conf-mode! Maybe make buffer-local?
  ;;(setq indent-line-function #'insert-tab) ;; don't indent relative to prev line
  (setq tab-width 2))
(add-hook 'conf-mode-hook 'my/conf-mode-setup)

;; Auto-save files when switching away from emacs
(add-hook 'focus-out-hook (lambda () (save-some-buffers t)))

;; Auto-revert files and show new contents
(global-auto-revert-mode)

;; Nicer behavior of scrolling
(setq scroll-margin 7)

;;; Duplicate current line feature

;; ============================================================================
;; https://stackoverflow.com/questions/88399/how-do-i-duplicate-a-whole-line-in-emacs
(defun my/duplicate-line (arg)
  "Duplicate current line, leaving point in lower line."
  (interactive "*p")

  ;; save the point for undo
  (setq buffer-undo-list (cons (point) buffer-undo-list))

  ;; local variables for start and end of line
  (let ((bol (save-excursion (beginning-of-line) (point)))
        eol)
    (save-excursion

      ;; don't use forward-line for this, because you would have
      ;; to check whether you are at the end of the buffer
      (end-of-line)
      (setq eol (point))

      ;; store the line and disable the recording of undo information
      (let ((line (buffer-substring bol eol))
            (buffer-undo-list t)
            (count arg))
        ;; insert the line arg times
        (while (> count 0)
          (newline)         ;; because there is no newline in 'line'
          (insert line)
          (setq count (1- count)))
        )

      ;; create the undo information
      (setq buffer-undo-list (cons (cons eol (point)) buffer-undo-list)))
    ) ; end-of-let

  ;; put the point in the lowest line and return
  (next-line arg))

(global-set-key (kbd "C-c d") 'my/duplicate-line)

;;; Color picker
(require 'colorpicker)
(global-set-key (kbd "C-x c") 'colorpicker)

;;; Activate hide-lines feature (from lisp/hide-lines.el)
(require 'hide-lines)
(autoload 'hide-lines "hide-lines" "Hide lines based on a regexp" t)
(global-set-key "\C-ch" 'hide-lines)
;;; Automatically unhide markup under cursor (used in markdown-mode)
;; source: https://emacs.stackexchange.com/questions/47632/how-do-i-make-markdown-or-org-mode-hide-formatting-characters-until-i-edit
(defvar my/current-line '(0 . 0)
  "(start . end) of current line in current buffer")
(make-variable-buffer-local 'my/current-line)

(defun my/unhide-current-line (limit)
  "Font-lock function"
  (let ((start (max (point) (car my/current-line)))
        (end (min limit (cdr my/current-line))))
    (when (< start end)
      ;; FIXME find out if we're inside a ``` block and then remove properties for the whole block. '''
      ;; OR: position the cursor on the right line (one down or up) when moving through a line with nothing visible
      (remove-text-properties start end
                              '(invisible t display "" composition ""))
      (goto-char limit)
      t)))

(defun my/refontify-on-linemove ()
  "Post-command-hook"
  (let* ((start (line-beginning-position))
         (end (line-beginning-position 2))
         (needs-update (not (equal start (car my/current-line)))))
    (setq my/current-line (cons start end))
    (when needs-update
      (message "Updating...")
      (font-lock-fontify-block 3)
      (message "Done.")
      )))
;;; Dired customization

;; dired: automatically move/copy to "other" pane's directory
(setq dired-dwim-target t)

;; activate dired-jump
(require 'dired-x)

;; open file in dired into desktop, mpv, etc.
(defun dired-open-file ()
  "In dired, open the file named on this line."
  (interactive)
  (let* ((file (dired-get-filename nil t)))
    (call-process "xdg-open" nil 0 nil file)))
(define-key dired-mode-map (kbd "C-c o") 'dired-open-file)


;;; EGlot customization and completion
(require 'eglot)
(global-set-key (kbd "C-<tab>") #'completion-at-point)
(define-key eglot-mode-map (kbd "C-c C-SPC") #'eglot-code-actions)

;;; HTML customization
;; Insert closing tags
(require 'sgml-mode)

;; Switch window
(define-key html-mode-map (kbd "M-o") nil)

;;; Elisp-specific customization
(add-hook 'emacs-lisp-mode-hook
          (lambda()
            (setq c-basic-offset 4)
            (setq indent-tabs-mode nil)
            (setq tab-width 4)
            (setq outline-regexp "\\(;;[;]\\{1,8\\} \\|\\((use-package\\)\\)")
            (outline-minor-mode)
            (electric-indent-mode)
            ))
;;; XML-specific customization

;; map some more files to nXML
(setq auto-mode-alist (cons '("\\.stx$" . nxml-mode) auto-mode-alist))

;; load additional nXML schemas
(require `nxml-mode)
(add-to-list `rng-schema-locating-files "~/.emacs.d/schemas/schemas.xml")

;; folding for nxml-mode
(add-to-list 'hs-special-modes-alist
             '(nxml-mode
               "<!--\\|<[^/>]*[^/]>"
               "-->\\|</[^/>]*[^/]>"
               "<!--"
               sgml-skip-tag-forward
               nil))
(add-hook 'nxml-mode-hook 'hs-minor-mode)
(add-hook 'nxml-mode-hook 'visual-line-mode)
(add-hook 'sgml-mode-hook 'hs-minor-mode)
(define-key nxml-mode-map (kbd "<backtab>") 'hs-toggle-hiding)
(define-key sgml-mode-map (kbd "<backtab>") 'hs-toggle-hiding)

;;; Java-specific customization

;; Allow Java indentation to work
(add-hook 'java-mode-hook (lambda ()
                            (remove-hook 'eglot-connect-hook #'eglot-signal-didChangeConfiguration t)))

;; Support jdt:// responses from JDTLS server in eglot
;; see: https://www.reddit.com/r/emacs/comments/1ibkh2h/programming_java_in_emacs_using_eglot/
(defun ak/jdt-file-name-handler (operation &rest args)
  "Support Eclipse jdtls `jdt://' uri scheme."
  (let* ((uri (car args))
         (cache-dir "/tmp/.eglot")
         (source-file
          (expand-file-name
           (file-name-concat
            cache-dir
            (save-match-data
              (when (string-match "jdt://contents/\\(.*?\\)/\\(.*\\)\.class\\?" uri)
                (format "%s.java" (replace-regexp-in-string "/" "." (match-string 2 uri) t t))))))))
    (unless (file-readable-p source-file)
      (let ((content (jsonrpc-request (eglot-current-server) :java/classFileContents (list :uri uri)))
            (metadata-file (format "%s.%s.metadata"
                                   (file-name-directory source-file)
                                   (file-name-base source-file))))
        (unless (file-directory-p cache-dir) (make-directory cache-dir t))
        (with-temp-file source-file (insert content))
        (with-temp-file metadata-file (insert uri))))
    source-file))
(add-to-list 'file-name-handler-alist '("\\`jdt://" . ak/jdt-file-name-handler))

;; Actually has more generics errors than JDTLS:
;; (add-to-list 'eglot-server-programs
;;              '((java-mode java-ts-mode) . ("/usr/share/java/java-language-server/lang_server_linux.sh")))

(add-to-list 'eglot-server-programs
             '((java-mode java-ts-mode) . ("jdtls" :initializationOptions
                                           (:extendedClientCapabilities (:classFileContentsSupport t)
                                            :settings
                                            (:java
                                             (:format
                                              (:enabled "true"
                                                        :settings
                                                        (:url "/home/jan/.emacs.d/eclipse-format-jan.xml"))))))))

;; Only indent inline lambdas one level
(defun my-java-indent-lambda (orig-fun &rest args)
  (let ((symbols (car args)))
       (if (and (eq 2 (length symbols))
                (eq 'arglist-cont-nonempty (car (nth 0 symbols)))
                )
           (apply orig-fun (list (cdr symbols)))
         (apply orig-fun args))))

(advice-add 'c-get-syntactic-indentation :around 'my-java-indent-lambda)

;; Java 13 addition
(font-lock-add-keywords 'java-mode
                        '(("yield" . font-lock-keyword-face)))
(font-lock-add-keywords 'java-mode
                        '(("var" . font-lock-keyword-face)))
(font-lock-add-keywords 'java-mode
                        '(("sealed" . font-lock-keyword-face)))
(font-lock-add-keywords 'java-mode
                        '(("record" . font-lock-keyword-face)) 1)
(font-lock-add-keywords 'java-mode
                        '(("permits" . font-lock-keyword-face)))
(font-lock-add-keywords 'java-mode
                        '(("when" . font-lock-keyword-face)))

(defun my/java-mode-setup ()
  (abbrev-mode 0)
  (visual-line-mode)                       ;; soft-wrap lines on word boundaries
  (setq adaptive-wrap-extra-indent 4)
  (adaptive-wrap-prefix-mode)              ;; indent soft-wrapped lines
  (c-set-offset 'arglist-intro '+)         ;; only 1 indent for multi-line args lists
  ;;(c-set-offset 'arglist-cont-nonempty '+) ;; 0 fixes lambdas, but breaks normal arg lists.
  (c-set-offset 'arglist-cont-nonempty '0) ;; 0 fixes lambdas, but breaks normal arg lists.
  (c-set-offset 'arglist-close '0)         ;; Single closing paren on a line should line up
  (c-set-offset 'case-label '+)            ;; Indent before case labels
  (setq fill-column 130)                   ;; yes, looks worse on github, but, java.
  (setq whitespace-line-column 130)
  (setq c-basic-offset 4)
  (setq indent-tabs-mode nil)
  (setq tab-width 4)
  (eglot-ensure)
  ;; (eglot-inlay-hints-mode -1) ;; eglot just re-enables this once connected
  ;; (outline-minor-mode) ;; doesn't work nicely with tree-sitter-mode
  (setq prettify-symbols-alist '(("<=" . ?≤)
                                 ("->" . ?→)
                                 (">=" . ?≥)))
  (prettify-symbols-mode)
  (electric-indent-mode) ;; Somehow goes missing after eglos
  (message "Java mode is set up.")
  )

(add-hook 'java-mode-hook 'my/java-mode-setup)
(add-hook 'java-ts-mode-hook 'my/java-mode-setup)

(setq major-mode-remap-alist
     '((java-mode . java-ts-mode)))

;;; Javascript-specific customization
(require 'js)
(define-key js-mode-map (kbd "<backtab>") 'hs-toggle-hiding)

(defun my/js-setup ()
  )
(add-hook 'js-mode-hook 'my/js-setup)

;;; Org mode customization
(defun org-journal-find-location ()
  ;; Open today's journal, but specify a non-nil prefix argument in order to
  ;; inhibit inserting the heading; org-capture will insert the heading.
  (org-journal-new-entry t)
  (unless (eq org-journal-file-type 'daily)
    (org-narrow-to-subtree))
  (goto-char (point-max)))

(setq org-capture-templates '(("j" "Journal entry" plain (function org-journal-find-location)
                               "** %(format-time-string org-journal-time-format)%^{Title}\n%i%?"
                               :jump-to-captured t :immediate-finish t)
                              ("t" "Journal entry (with TODO link)" plain (function org-journal-find-location)
                               "** TODO %^{Title}\nSee %a:\n%i%?"
                               :jump-to-captured t :immediate-finish t)))


;; use postgresql with babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((sql . t)
   (shell . t)))

;; use python with babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)))

(require 'ob-jshell)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((jshell . t)))

;; use java with babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((java . t)))

;; use maxima with babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((maxima . t)))

;; Don't indent org documents
(setq org-startup-indented nil)
;; Don't indent when pressing enter after heading
(setq org-adapt-indentation nil)

(require 'ox)
(defun my/org-export-replacements (text backend info)
  "Replace common org-babel source block modes with names that TeX pygmentize understands"
    (with-temp-buffer
      (insert text)

      (goto-char (point-min))
      (while (search-forward "{restclient}" nil t) (replace-match "{text}" nil t))

      (goto-char (point-min))
      (while (search-forward "{sgml}" nil t) (replace-match "{xml}" nil t))

      (goto-char (point-min))
      (while (search-forward "{jshell}" nil t) (replace-match "{java}" nil t))

      (buffer-substring-no-properties (point-min) (point-max))))

;;(make-variable-buffer-local 'org-export-filter-src-block-functions)

(add-to-list 'org-export-filter-src-block-functions
  'my/org-export-replacements)


(require 'org-expiry)
(require 'ox-md nil t)
(require 'ox-beamer)

;; fontify inside org mode
(setq org-src-fontify-natively t)

;; https://emacs.stackexchange.com/questions/44914/choose-individual-startup-visibility-of-org-modes-source-blocks
(defun my/individual-visibility-source-blocks ()
  "Fold some blocks in the current buffer that are marked with :hidden."
  (interactive)
  (org-block-map
   (lambda ()
     (let ((case-fold-search t))
       (when (and
              (save-excursion
                (beginning-of-line 1)
                (looking-at org-block-regexp))
              (cl-assoc
               ':hidden
               (cl-third
                (org-babel-get-src-block-info))))
         (org-hide-block-toggle 1))))))

(defun my/org-mode-setup ()
  (whitespace-mode -1)

  ;; https://orgmode.org/list/87pn8huuq2.fsf@iki.fi/t/
  (electric-indent-local-mode -1)
  ;; Don't indent
  ;; https://orgmode.org/worg/org-faq.html#indentation
  (electric-indent-mode nil)

  ;; Shorten some text
  (setq prettify-symbols-alist
      (assoc-delete-all ">="
        (map-merge 'list prettify-symbols-alist
                   `(
                     ("#+name:" . "✎")
                     ("#+NAME:" . "✎")
                     ("#+BEGIN_SRC" . "➤")
                     ("#+BEGIN_EXAMPLE" . "➤")
                     ("#+END_SRC" . "⏹")
                     ("#+END_EXAMPLE" . "⏹")
                     ("#+RESULTS:" . "🠋")    ;; Font: ttf-symbola
                     ))))
  (prettify-symbols-mode 0)
  (prettify-symbols-mode)

  ;; Auto-wrap lines
  (visual-line-mode)
  (setq adaptive-wrap-extra-indent 2)

  (variable-pitch-mode)
  ;; from https://lepisma.xyz/2017/10/28/ricing-org-mode/
  ;; A little bit of spacing between lines:
  (setq line-spacing 0.0) ;; doesn't look good on tables.
  ;; A little bit of space in the left/right margins:
  (setq left-margin-width 2)
  (setq right-margin-width 2)
  (set-window-buffer nil (current-buffer))

  (flyspell-mode 1)
  (ws-butler-mode 1)

  (defun shk-fix-inline-images ()
    (when org-inline-image-overlays
      (org-redisplay-inline-images)))

  (add-hook 'org-babel-after-execute-hook 'shk-fix-inline-images)
)

(add-hook 'org-mode-hook 'my/org-mode-setup)

;; https://emacs.stackexchange.com/questions/32347/how-to-have-wrapped-text-when-exporting-from-org-to-latex
(add-to-list 'org-latex-packages-alist '("" "tabularx"))
(add-to-list 'org-latex-packages-alist '("" "supertabular"))

;; https://emacs.stackexchange.com/questions/7996/is-there-a-way-to-resize-margins-when-exporting-pdf-in-org-mode
(add-to-list 'org-latex-packages-alist '("margin=2cm" "geometry" nil))

;; https://emacs.stackexchange.com/questions/33010/how-to-word-wrap-within-code-blocks
;; https://emacs.stackexchange.com/questions/27982/export-code-blocks-in-org-mode-with-minted-environment
(add-to-list 'org-latex-packages-alist '("" "minted"))
(setq org-latex-listings 'minted)
(setq org-latex-pdf-process '("%latex -shell-escape -interaction nonstopmode -output-directory %o %f"
                              "%latex -shell-escape -interaction nonstopmode -output-directory %o %f"
                              "%latex -shell-escape -interaction nonstopmode -output-directory %o %f"))
(setq org-latex-minted-options '(("breaklines" "true")
                                 ("breakanywhere" "true")))
(defun my/filter-timestamp (trans back _comm)
  "Remove <> around time-stamps."
  (pcase back
    ((or `jekyll `html)
     (replace-regexp-in-string "&[lg]t;" "" trans))
    (`latex
     (replace-regexp-in-string "[<>]" "" trans))))
(add-to-list 'org-export-filter-timestamp-functions
             #'my/filter-timestamp)

;; Smart beginning and end of line for org mode
(setq org-special-ctrl-a/e t)

(defun my/image-animate ()
    "Starts to animate the image under the cursor"
    (interactive)
    (image-animate (image--get-imagemagick-and-warn)))

(define-key image-map (kbd "a") 'my/image-animate)


;;; Mu4e email
(when (file-exists-p "~/.emacs.d/mu4e.el")
  ;; load mu4e (comes with installation of mu)
  (add-to-list 'load-path "/usr/share/emacs/site-lisp/mu4e")
  (autoload 'mu4e "mu4e" "Launch mu4e and show the main window" t)
  (require 'mu4e-main)

  (setq org-agenda-archives-mode nil)
  (setq org-agenda-skip-comment-trees nil)
  (setq org-agenda-skip-function nil)
  ;; from mu4e-icalendar.el:
  (require 'mu4e-icalendar)
  (require 'gnus-icalendar)
  (setq mu4e-view-use-gnus t)
  (mu4e-icalendar-setup)

  (setq gnus-icalendar-org-capture-file "~/org/calendar-capture.org")
  (setq gnus-icalendar-org-capture-headline '("Calendar"))
  (gnus-icalendar-org-setup)

  ;; Restore keybindings that somehow aren't present by default in mu4e-gnus
  (require 'mu4e-view)
  (define-key mu4e-view-mode-map (kbd "e") 'mu4e-view-save-attachments)

  ;; use mu4e as email client in emacs
  (setq mail-user-agent 'mu4e-user-agent)
  ;; don't keep message buffers around
  (setq message-kill-buffer-on-exit t)
  ;; hide indexer progress so it's not so distracting
  (setq mu4e-hide-index-messages t)
  ;; fix the hideous rendering of html
  (require 'mu4e-contrib)

  ;; Allow to save also inline images using "o" (gnus-mime-save-part)
  ;; (setq gnus-inhibit-mime-unbuttonizing t)

  ;; (setq mu4e-html2text-command "w3m -T text/html")w
  (setq mu4e-html2text-command 'mu4e-shr2text)
  (setq shr-color-visible-luminance-min 80)
  (setq shr-color-visible-distance-min 40)

  (setq mu4e-headers-unread-mark '("u" . " "))
  (setq mu4e-headers-new-mark '("N" . " "))
  (setq mu4e-compose-format-flowed t)

  (load "~/.emacs.d/mu4e.el")
  (bind-keys :package mu4e ("<f9>" . mu4e))
  (setq mu4e-confirm-quit nil) ;; yes I'm sure
  (use-package mu4e-alert
    :after mu4e
    :init
    (mu4e-alert-enable-mode-line-display)
    (mu4e-alert-set-default-style 'libnotify)
    (mu4e-alert-enable-notifications))

;; spell check
  (add-hook 'mu4e-compose-mode-hook
            (defun my/do-compose-stuff ()
              "My settings for message composition."
              (electric-indent-mode -1)
              (flyspell-mode))))

;;; Visual customization

;; Use pretty symbols everywhere
(global-prettify-symbols-mode 1)

;; Highlight the current line
(global-hl-line-mode 1)



;;;; Set correct font
(setq my/frame-font-name "New Heterodox Mono")

(defun my/fontify-frame (frame)
  (interactive)
  (if window-system
      (progn
        (if (> (x-display-pixel-width) 3000)
            (set-frame-font (format "%s 10" my/frame-font-name) nil t) ;; HiDPI but setting Xresources properly
          (if (> (x-display-pixel-width) 2600)
              (set-frame-font (format "%s 15" my/frame-font-name) nil t) ;; HIDPI
            (if (>= (x-display-pixel-width) 1920)
                (set-frame-font (format "%s 12" my/frame-font-name) nil t)
              (set-frame-font (format "%s 10" my/frame-font-name) nil t)
              ))))))

;; Fontify current frame
(my/fontify-frame nil)

;; Fontify any future frames
(push 'my/fontify-frame after-make-frame-functions)

;;;; Customize ellipsis
(defface hs-ellipsis
  '((((class color) (background light)) (:underline t))
    (((class color) (background dark)) (:underline t))
    (t (:underline t)))
  "Face for ellipsis in hideshow mode.")

;; Use this in whitespace-mode
(defun whitespace-change-ellipsis ()
  "Change ellipsis when used with `whitespace-mode'."
  (when buffer-display-table
    (set-display-table-slot buffer-display-table
                            'selective-display
                            ;;(string-to-vector " … ")
                            (let ((face-offset (* (face-id 'hs-ellipsis) (lsh 1 22))))
                              (vconcat (mapcar (lambda (c) (+ face-offset c)) " … ")))
                            )))
(add-hook 'whitespace-mode-hook #'whitespace-change-ellipsis)

;; Use this in non-whitespace modes
(set-display-table-slot
 standard-display-table
 'selective-display
 (let ((face-offset (* (face-id 'hs-ellipsis) (lsh 1 22))))
   (vconcat (mapcar (lambda (c) (+ face-offset c)) " … "))))

;;; Packages
;;;; Markdown
(use-package markdown-mode
  :config
  (add-hook 'markdown-mode-hook (lambda ()
                                  (markdown-toggle-markup-hiding 1)
                                  (font-lock-add-keywords nil '((my/unhide-current-line)) t)
                                  (add-hook 'post-command-hook #'my/refontify-on-linemove nil t)
                                  (visual-line-mode)
                                  (variable-pitch-mode)
                                  (flyspell-mode))))
;;;; EGlot packages
;; (use-package eglot-java
;;   :config
;;   (defun custom-eglot-java-init-opts (server eglot-java-eclipse-jdt)
;;     "Custom options that will be merged with any default settings."
;;     '(:settings
;;       (:java
;;        (:format
;;         (:insertSpaces t
;;          :tabSize 4
;;          :settings
;;          (:url "/home/jan/.emacs.d/eclipse-format-jan.xml")
;;          :enabled t)))))
;;   (setq eglot-java-user-init-opts-fn 'custom-eglot-java-init-opts))
;;;; Scala
(defun my/scala-mode-setup()
  (setq adaptive-wrap-extra-indent 2)
  (setq outline-regexp "[ \t]*\\(def\\|if\\|class\\|object\\|case\\|trait\\|abstract class\\).*$")
  (visual-line-mode)
  (setq indent-region-function nil)
  (setq prettify-symbols-alist (append scala-mode-pretty-arrows-alist
                                       '(("<=" . ?≤)
                                         (">=" . ?≥)
                                         ("<:" . ?⋖)
                                         (">:" . ?⋗)
                                         (">>" . ?≫)
                                         (">>>" . ?⋙)
                                         ("<<" . ?≪)
                                         ("<<<" . ?⋘))))
  (prettify-symbols-mode)
  (eglot-ensure)
  (electric-indent-mode))

(use-package scala-mode
  :mode "\\.s\\(cala\\|bt\\)$"
  :config
  (add-hook 'scala-mode-hook 'my/scala-mode-setup)
  (add-to-list 'hs-special-modes-alist
               '(scala-mode "{" "}" "/[*/]"
                            nil
                            nil))
  (define-key scala-mode-map (kbd "<backtab>") 'hs-toggle-hiding))

;;;; Git
(use-package magit
  :commands (magit-status)
  :config
  ;; See https://github.com/magit/ghub/issues/81, this is needed for github integration
  (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
  ;;  magit default to origin/master instead of just master
  (setq magic-prefer-remote-upstream 1)
  (setq magit-list-refs-sortby "-creatordate")
  ;;  Hide "Recent Commits"
  ;;  https://github.com/magit/magit/issues/3230
  (magit-add-section-hook 'magit-status-sections-hook
                          'magit-insert-unpushed-to-upstream;
                          'magit-insert-unpushed-to-upstream-or-recent
                          'replace)
  (defun my/git-commit-hooks () 
                                    (message "Hello")
                                    (electric-indent-mode -1))
  (add-hook 'git-commit-mode-hook 'my/git-commit-hooks)

  :bind ("C-x g" . magit-status))

(use-package forge
 :after magit)

(use-package git-timemachine
  :commands (git-timemachine))

(use-package magit-todos
 :after magit
 :init
 (magit-todos-mode))
(use-package git-gutter
  :config
  (global-set-key (kbd "C-x v =") 'git-gutter:popup-hunk)
  (global-set-key (kbd "C-x C-p") 'git-gutter:previous-hunk)
  (global-set-key (kbd "C-x C-n") 'git-gutter:next-hunk)
  (global-set-key (kbd "C-x v s") 'git-gutter:stage-hunk)
  (global-set-key (kbd "C-x v k") 'git-gutter:revert-hunk)

  (custom-set-variables
   '(git-gutter:update-interval 1))
  (dolist (mode '(emacs-lisp-mode-hook
                  inferior-lisp-mode-hook
                  c++-mode-hook
                  c-mode-hook
                  scala-mode-hook
                  protobuf-mode-hook
                  javascript-mode-hook
                  js-mode-hook
                  groovy-mode-hook
                  yaml-mode-hook
                  conf-mode-hook
                  nxml-mode-hook
                  java-mode-hook))
    (add-hook mode #'git-gutter-mode)))
;;;; Org mode
(use-package org-journal
  :bind (
         ("C-c c" . org-capture)
         ("C-c C-j" . org-journal-new-entry)))

(use-package htmlize
  ;; Used in org-mode export
  :commands (htmlize-buffer htmlize-region htmlize-file))

;; (use-package org-superstar
;;   :hook (org-mode . org-superstar-mode))

(use-package org-modern
  :hook (
         (org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda)
         ))

(use-package org-appear
  :hook (org-mode . org-appear-mode))

;;;; PlantUML
(use-package plantuml-mode
  :mode "\\.\\(plantuml\\|pum\\|plu\\)\\'"
  :config
  ;; plantuml is in standard arch repositories
  (setq plantuml-default-exec-mode 'jar)
  (setq plantuml-executable-path "plantuml")
  (setq plantuml-jar-path "~/.emacs.d/plantuml.jar")

  ;; Enable plantuml-mode for PlantUML files
  (add-to-list 'auto-mode-alist '("\\.plantuml\\'" . plantuml-mode))

  ;; Allow plantuml in org files
  (add-to-list
   'org-src-lang-modes '("plantuml" . plantuml)))

;; Allow execute of plantuml from org
(require 'ob-plantuml)
(setq org-plantuml-jar-path "~/.emacs.d/plantuml.jar")
(setq org-plantuml-exec-mode 'jar)


;;;; Dired
;; show usage in dired: C-x M-r, toggle display with C-x C-h
(use-package dired-du
  :after dired)

;; auto-collapse directories in dired
(use-package dired-collapse
  :hook (dired-mode . dired-collapse-mode))

;; more colors in dired
(use-package dired-rainbow
  :config
  (dired-rainbow-define-chmod directory "#FF6978" "d.*")
  (dired-rainbow-define html "#eb5286" ("css" "less" "sass" "scss" "htm" "html" "jhtm" "mht" "eml" "mustache" "xhtml"))
  (dired-rainbow-define xml "#f2d024" ("xml" "xsd" "xsl" "xslt" "wsdl" "bib" "json" "msg" "pgn" "rss" "yaml" "yml" "rdata"))
  (dired-rainbow-define document "#9561e2" ("docm" "doc" "docx" "odb" "odt" "pdb" "pdf" "ps" "rtf" "djvu" "epub" "odp" "ppt" "pptx"))
  (dired-rainbow-define markdown "#ffed4a" ("org" "etx" "info" "markdown" "md" "mkd" "nfo" "pod" "rst" "tex" "textfile" "txt"))
  (dired-rainbow-define database "#6574cd" ("xlsx" "xls" "csv" "accdb" "db" "mdb" "sqlite" "nc"))
  (dired-rainbow-define media "#de751f" ("mp3" "mp4" "MP3" "MP4" "avi" "mpeg" "mpg" "flv" "ogg" "mov" "mid" "midi" "wav" "aiff" "flac"))
  (dired-rainbow-define image "#f66d9b" ("tiff" "tif" "cdr" "gif" "ico" "jpeg" "jpg" "png" "psd" "eps" "svg"))
  (dired-rainbow-define log "#c17d11" ("log"))
  (dired-rainbow-define shell "#f6993f" ("awk" "bash" "bat" "sed" "sh" "zsh" "vim"))
  (dired-rainbow-define interpreted "#38c172" ("py" "ipynb" "rb" "pl" "t" "msql" "mysql" "pgsql" "sql" "r" "clj" "cljs" "scala" "js"))
  (dired-rainbow-define compiled "#4dc0b5" ("asm" "cl" "lisp" "el" "c" "h" "c++" "h++" "hpp" "hxx" "m" "cc" "cs" "cp" "cpp" "go" "f" "for" "ftn" "f90" "f95" "f03" "f08" "s" "rs" "hi" "hs" "pyc" ".java"))
  (dired-rainbow-define executable "#8cc4ff" ("exe" "msi"))
  (dired-rainbow-define compressed "#51d88a" ("7z" "zip" "bz2" "tgz" "txz" "gz" "xz" "z" "Z" "jar" "war" "ear" "rar" "sar" "xpi" "apk" "xz" "tar"))
  (dired-rainbow-define packaged "#faad63" ("deb" "rpm" "apk" "jad" "jar" "cab" "pak" "pk3" "vdf" "vpk" "bsp"))
  (dired-rainbow-define encrypted "#ffed4a" ("gpg" "pgp" "asc" "bfe" "enc" "signature" "sig" "p12" "pem"))
  (dired-rainbow-define fonts "#6cb2eb" ("afm" "fon" "fnt" "pfb" "pfm" "ttf" "otf"))
  (dired-rainbow-define partition "#e3342f" ("dmg" "iso" "bin" "nrg" "qcow" "toast" "vcd" "vmdk" "bak"))
  (dired-rainbow-define vc "#0074d9" ("git" "gitignore" "gitattributes" "gitmodules"))
  (dired-rainbow-define-chmod executable-unix "#38c172" "-.*x.*"))

;;;; Org treeslide
(defun my/presentation-setup ()
  (shell-command "dunstctl set-paused true")
  (flyspell-mode 0)
  (menu-bar-mode 0)
  (if (> (x-display-pixel-width) 2600)
      (progn ;; HIDPI
        (setq text-scale-mode-amount 3)
        (setq org-format-latex-options (plist-put org-format-latex-options :scale 3.0))
        (text-scale-mode 1))
    (if (>= (x-display-pixel-width) 1920)
        (progn ;; 1920x1080
          (setq text-scale-mode-amount 1.5)
          (setq org-format-latex-options (plist-put org-format-latex-options :scale 1.5))
          (text-scale-mode 1))
          (setq org-image-actual-width (list (/ (x-display-pixel-width) 3)))
      (progn ;; 1280x720
        (setq org-image-actual-width (list (/ (x-display-pixel-width) 4))))))
  (org-display-inline-images t t)
  (hide-lines-matching "#\\+ATTR_ORG")
  (hide-lines-matching "#\\+ATTR_LATEX")
  (org-latex-preview '(16))
  (font-lock-flush)
  (font-lock-ensure)
  (my/individual-visibility-source-blocks))

(defun my/presentation-end ()
  (shell-command "dunstctl set-paused false")
  (menu-bar-mode 1)
  (org-latex-preview '(64))
  (flyspell-mode 1)
  (text-scale-mode 0)
  (org-remove-inline-images)
  (hide-lines-show-all)
  (font-lock-flush)
  (font-lock-ensure))

(use-package org-tree-slide
  ;; Load immediately, since it messes with org-mode faces
  :demand
  :hook
  ((org-tree-slide-play . my/presentation-setup)
   (org-tree-slide-stop . my/presentation-end))
  :bind
  (:map org-mode-map
        ("<f6>" . org-tree-slide-mode))
  :custom
  (org-image-actual-width nil))

;;;; Elfeed

(defun android-check-p ()
  "Returns whether we're currently running in Termux on Android."
  (or
   (string-match-p (regexp-quote "Android") (shell-command-to-string "uname -o"))
   (string-match-p (regexp-quote "lineageOS") (shell-command-to-string "uname -a"))))

(use-package elfeed
  :bind ("C-x w" . elfeed)
  :config
  (setq elfeed-feeds
        '("https://www.youtube.com/feeds/videos.xml?channel_id=UCM8XE_Gv3Ui5s4F-5TW16jg"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCyDZai57BfE_N0SaBkKQyXg"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCxkMDXQ5qzYOgXPRnOBrp1w"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCL-0gAth4u6Wp-9_98XU3nA"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCgFvT6pUq9HLOvKBYERzXSQ"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCdXHgsCiql_78oT5ydXWvzA"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCF3cDM_hQMtIEJvEW1BZugg"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCEwoFdqY09VwZFESGZ8Qp4A"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UC1O0jDlG51N3jGf6_9t-9mw"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UC873OURVczg_utAk8dXx_Uw"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCivA7_KLKWo43tFcCkFvydw"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCqp2_p4YjtaTKiHuNZv0mAQ"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCiczXOhGpvoQGhOL16EZiTg"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCb8Rde3uRL1ohROUVg46h1A"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCCXhs2CtrCQAHRe702_wuIA"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCmHvGf00GDuPYG9DZqQKd9A"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UC5I2hjZYiW9gZPVkvzM8_Cw"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UC6mIxFTvXkWQVEHPsEdflzQ"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCl2mFZoRqjw_ELax4Yisf6w"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCJ0-OtVpF0wOKEqT2Z1HEtA"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCtM5z2gkrGRuWd0JQMx76qA"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UChWv6Pn_zP0rI6lgGt3MyfA"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCcs0ZkP_as4PpHDhFcmCHyA"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UC2DjFE7Xf11URZqWBigcVOQ"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCQak2_fXZ_9yXI5vB_Kd54g"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCshiNtfJ7Dj3nlh41a6M-kg" ;; Music is Win
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCu7_D0o48KbfhpEohoP7YSQ" ;; Andreas Spiess
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCAYKj_peyESIMDp5LtHlH2A" ;; Unfa
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCdcemy56JtVTrsFIOoqvV8g" ;; ANDREW HUANG
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCS-SFei6NFRuGN8CKtAsYrA" ;; toms 0ad
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCqeg5vkTkH-DYxmOO9FJOHA" ;; Ardour
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCkqe4BYsllmcxo2dsF-rFQw" ;; Bruce Williams Photography
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCr-cm90DwFJC0W3f9jBs5jA" ;; EEVBlog channel 2
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCJquYOG5EL82sKTfH9aMA9Q" ;; Rick Beato
          "https://www.youtube.com/feeds/videos.xml?channel_id=UC_Oa7Ph3v94om5OyxY1nPKg" ;; Paul Davids
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCqepSCHTyWj4BzHxEEUNvlg" ;; Jens Larsen
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCV5vCi3jPJdURZwAOO_FNfQ" ;; Thought Emporium
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCGhzS1GbX-yxyBrUJtnUMoA" ;; DIY guitar pedals
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCtpB66XKjAtFZfZyzmC-_Cg" ;; Hexi Base
          "https://www.youtube.com/feeds/videos.xml?channel_id=UC-GiI_5U-WkPIKqsq056wvg" ;; Brandon Acker
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCEQXp_fcqwPcqrzNtWJ1w9w" ;; Logos by Nick
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCyRhIGDUKdIOw07Pd8pHxCw" ;; Shut up and sit down
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCsaGKqPZnGp_7N80hcHySGQ" ;; Tasting history
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCRwIF4NhKQf6tQpnYDcSC5A" ;; MusicTheoryForGuitar
          "https://www.youtube.com/feeds/videos.xml?channel_id=UC1_uAIS3r8Vu6JjXWvastJg" ;; Mathologer
          "https://www.youtube.com/feeds/videos.xml?channel_id=UC42d7zFnWU0dYVk_M0JED6w" ;; Kevin Darrah
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCm9K6rby98W8JigLoZOh6FQ" ;; Lock picking lowyer
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCp1orOGJwZvjLAvckyxC4Nw" ;; Bosnian Bill
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCwlnFJ4_SlJbVNQ0iye8CqQ" ;; Lucas Brar guitar
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCnkp4xDOwqqJD7sSM3xdUiQ" ;; Adam Neely
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCnjQCcLxBqelGn0sForpAqA" ;; Jonny May
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCu1yiKjTRetsoZ-OSeOMmzg" ;; JAZZ TUTORIAL (Julian Bradley)
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCAiiOTio8Yu69c3XnR7nQBQ" ;; System Crafters
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCHnyfMqiRRG1u-2MsSQLbXA" ;; Veritasium
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCRS4DvO9X7qaqVYUW2_dwOw" ;; Rock the JVM
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCeP0-mA85a1UM05qFMub7Ow" ;; Peter Bence
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCl9OJE9OpXui-gRsnWjSrlA" ;; Photonicinduction
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCvigl2g67gl18hJgFex-3zg" ;; Bad Normals
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCTUtqcDkzw7bisadh6AOx5w" ;; 12 Tone Videos
          "https://www.youtube.com/feeds/videos.xml?channel_id=UUP7H8NPvamkD9mL5sIXnnFQ" ;; CodingKaiju
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCz2iUx-Imr6HgDC3zAFpjOw" ;; David Bennett Piano
          "https://www.youtube.com/feeds/videos.xml?channel_id=UC8Ob-HnnmhlgSv5Vs_i32TQ" ;; Ralph S Bacon
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCchBatdUMZoMfJ3rIzgV84g" ;; VivaLaDirtLeague
          "https://www.youtube.com/feeds/videos.xml?channel_id=UC6gJtkKLq7MTkm0SJRpYBWg" ;;  DECODED
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCsWRAAMs_Cn78_kRLSpkb6w" ;; Fesz Electronics
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCQwyP4Yd0-O49e05kMUJgQQ" ;; Andress Spiess  HB9BLA
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCuWKHSHTHMV_nVSeNH4gYAg" ;; Omri Cohen
          "https://www.youtube.com/feeds/videos.xml?channel_id=UC4PIiYewI1YGyiZvgNlJNrA" ;; Charles Cornell

          "http://planet.emacsen.org/atom.xml"))

  (defun elfeed-play-with-mpv ()
    "Play entry link with mpv."
    (interactive)
    (let ((entry (if (eq major-mode 'elfeed-show-mode) elfeed-show-entry (elfeed-search-selected :single)))
          (quality-arg "")
          (quality-val (completing-read "Max height resolution (0 for unlimited): " '("0" "480" "720") nil nil)))
      (setq quality-val (string-to-number quality-val))
      (message "Opening %s with height≤%s with mpv..." (elfeed-entry-link entry) quality-val)
      (when (< 0 quality-val)
        (setq quality-arg (format "--ytdl-format=[height<=?%s]" quality-val)))
      (start-process "elfeed-mpv" nil "~/bin/mpv" quality-arg (elfeed-entry-link entry))))

  (defvar elfeed-mpv-patterns
    '("youtu\\.?be")
    "List of regexp to match against elfeed entry link to know
whether to use mpv to visit the link.")

  (defun elfeed-visit-or-play-with-mpv ()
    "Play in mpv if entry link matches `elfeed-mpv-patterns', visit otherwise.
See `elfeed-play-with-mpv'."
    (interactive)
    (let ((entry (if (eq major-mode 'elfeed-show-mode) elfeed-show-entry (elfeed-search-selected :single)))
          (patterns elfeed-mpv-patterns))
      (while (and patterns (not (string-match (car elfeed-mpv-patterns) (elfeed-entry-link entry))))
        (setq patterns (cdr patterns)))
      (if patterns
          (if (android-check-p)
              (android-browse-url (elfeed-entry-link entry))
            (elfeed-play-with-mpv))
        (if (eq major-mode 'elfeed-search-mode)
            (elfeed-search-browse-url)
          (elfeed-show-visit)))))

  (define-key elfeed-search-mode-map (kbd "RET") 'elfeed-visit-or-play-with-mpv))

;; On android, open urls with android intents
(when (android-check-p)
  (advice-add 'browse-url-default-browser :override
              (lambda (url &rest args)
                (android-browse-url url))))

;;;; Others
(use-package hl-todo)
(use-package dashboard
  :config
  (global-set-key (kbd "<f5>") (lambda () (interactive) (switch-to-buffer "*dashboard*")))
  (dashboard-setup-startup-hook)
  (setq dashboard-items '((recents  . 25)
                          (bookmarks . 5)
                          (projects . 25))))

(use-package which-key
  :config
  (which-key-mode))

(use-package vertico
  :init
  (vertico-mode)

  ;; Different scroll margin
  ;; (setq vertico-scroll-margin 0)

  ;; Show more candidates
  ;; (setq vertico-count 20)

  ;; Grow and shrink the Vertico minibuffer
  ;; (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  (setq vertico-cycle t)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode))

(use-package vertico-directory
  :after vertico
  :ensure nil
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  ;;(setq completion-styles '(orderless)
  ;;      completion-category-defaults nil
  ;;      completion-category-overrides '((file (styles partial-completion))))

;; (defun basic-remote-try-completion (string table pred point)
;;   (and (vertico--remote-p string)
;;        (completion-basic-try-completion string table pred point)))
;; (defun basic-remote-all-completions (string table pred point)
;;   (and (vertico--remote-p string)
;;        (completion-basic-all-completions string table pred point)))
;; (add-to-list
;;  'completion-styles-alist
;;  '(basic-remote basic-remote-try-completion basic-remote-all-completions nil))
;; (setq completion-styles '(orderless)
  ;;       completion-category-overrides '((file (styles basic-remote partial-completion))))
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion))))
  )

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings (mode-specific-map)
         ("C-c h" . consult-history)
;;         ("C-c m" . consult-mode-command)
         ("C-c b" . consult-bookmark)
         ("C-c k" . consult-kmacro)
         ;; C-x bindings (ctl-x-map)
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x C-b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ;; ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ("<help> a" . consult-apropos)            ;; orig. apropos-command
         ;; M-g bindings (goto-map)
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings (search-map)
         ("M-s f" . consult-find)
         ("M-s F" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s m" . consult-multi-occur)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi))           ;; needed by consult-line to detect isearch

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI. You may want to also
  ;; enable `consult-preview-at-point-mode` in Embark Collect buffers.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Optionally replace `completing-read-multiple' with an enhanced version.
  ;; This might cause problems with lsp-mode's usage of it when generating Java constructors.
  ;;  (advice-add #'completing-read-multiple :override #'consult-completing-read-multiple)

  ;; Use Consult to select xref locations with preview

  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Use `consult-completion-in-region' if Vertico is enabled.
  ;; Otherwise use the default `completion--in-region' function.
  (setq completion-in-region-function
        (lambda (&rest args)
          (apply (if vertico-mode
                     #'consult-completion-in-region
                   #'completion--in-region)
                 args)))
  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key (kbd "M-."))
  ;; (setq consult-preview-key (list (kbd "<S-down>") (kbd "<S-up>")))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme
   :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-recent-file consult--source-project-recent-file consult--source-bookmark
   )

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; (kbd "C-+")

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; Optionally configure a function which returns the project root directory.
  ;; There are multiple reasonable alternatives to chose from.
  ;;;; 1. project.el (project-roots)
  (setq consult-project-root-function
        (lambda ()
          (when-let (project (project-current))
            (car (project-roots project)))))
  ;;;; 2. projectile.el (projectile-project-root)
  ;;(autoload 'projectile-project-root "projectile")
  ;;(setq consult-project-root-function #'projectile-project-root)
  ;;;; 3. vc.el (vc-root-dir)
  ;; (setq consult-project-root-function #'vc-root-dir)
  ;;;; 4. locate-dominating-file
  ;; (setq consult-project-root-function (lambda () (locate-dominating-file "." ".git")))
  )

;; Enable richer annotations using the Marginalia package
(use-package marginalia
  ;; Either bind `marginalia-cycle` globally or only in the minibuffer
  :bind (("M-A" . marginalia-cycle)
         :map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init configuration is always executed (Not lazy!)
  :init

  ;; Must be in the :init section of use-package such that the mode gets
  ;; enabled right away. Note that this forces loading the package.
  (marginalia-mode))

;; Automatically select and expand logical regions
(use-package expand-region
  :bind ("C-=" . er/expand-region))


(use-package ws-butler
  :init
  (ws-butler-global-mode))

;; Local Variables:
;; eval: (outline-hide-sublevels 1)
;; End:

;; highlight #ff etc as actual colors
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode)
  :hook (conf-mode . rainbow-delimiters-mode))
(use-package rainbow-mode
  :after markdown
  ;; sets background color to strings that match color names
  :hook (markdown-mode web-mode help-mode html-mode css-mode js-mode js-jsx-mode emacs-lisp-mode prog-mode))
(use-package visual-regexp
  :bind
  ("C-c r" . 'vr/replace)
  ("C-c q" . 'vr/query-replace))
(use-package adaptive-wrap
  :after markdown
  :hook ((scala-mode java-mode c-mode c++-mode yaml-mode markdown-mode org-mode) . adaptive-wrap-prefix-mode))
(use-package edit-indirect
  ;; To edit code blacks in markdown
  :after markdown)

(defun my/yaml-mode-setup ()
  (setq fill-column 130)
  )
(use-package yaml-mode
  :bind
  (:map yaml-mode-map
        ("C-." . find-file-at-point))
  :hook ((yaml-mode . visual-line-mode)
         (yaml-mode . my/yaml-mode-setup)
         (yaml-mode . whitespace-mode)))
(use-package yasnippet
  :demand ;; doesn't work in org-mode otherwise
  :config
  (yas-global-mode 1)
  (define-key yas-minor-mode-map (kbd "<tab>") nil)
  (define-key yas-minor-mode-map (kbd "TAB") nil)
  (define-key yas-minor-mode-map (kbd "C-t") #'yas-expand))

;; This assumes you've installed the package via MELPA.

;; (use-package ellama
;;   :bind ("C-c e" . ellama)
;;   :init
;;   (require 'llm-ollama)
;;   (setopt ellama-providera
;;           (make-llm-ollama
;;            :chat-model "qwen2.5:7b-instruct-q8_0"
;;            :embedding-model "nomic-embed-text"
;;            :default-chat-non-standard-params '(("num_ctx" . 8192))))
;;   (setopt ellama-coding-provider
;;           (make-llm-ollama
;;            :chat-model "qwen2.5-coder:7b"
;;            :embedding-model "nomic-embed-text"
;;            :default-chat-non-standard-params '(("num_ctx" . 32768))))
;;   )
(use-package gptel
  :config

  ;; from https://github.com/karthink/gptel/issues/604
  (defun cleanup-llm-rewrite-response (beg end)
    "Remove Markdown-style code fences from the GPTel rewrite response."
    (save-excursion
      ;; Remove closing fence
      (goto-char end)
      (beginning-of-line)
      (when (looking-at "^```$")
        (delete-region (line-beginning-position) (line-end-position))
        )

      ;; Remove opening fence
      (goto-char beg)
      (when (looking-at "^```.*$")
        (delete-region (line-beginning-position) (line-end-position))
        (delete-char 1) ;; remove newline
        )
      )
    )
  (add-hook 'gptel-post-rewrite-functions #'cleanup-llm-rewrite-response)

  (setopt
   gtpel-model 'qwen2.5-coder:7b
   gptel-backend (gptel-make-ollama "Ollama"
                                    :host "localhost:11434"
                                    :stream t
                                    :models '(qwen2.5-coder:7b))
   )
  )

(use-package minuet
    :config
    (setq minuet-provider 'openai-fim-compatible)
    (setq minuet-n-completions 1) ; recommended for Local LLM for resource saving
    ;; I recommend beginning with a small context window size and incrementally
    ;; expanding it, depending on your local computing power. A context window
    ;; of 512, serves as an good starting point to estimate your computing
    ;; power. Once you have a reliable estimate of your local computing power,
    ;; you should adjust the context window to a larger value.
    (setq minuet-context-window 512)
    (plist-put minuet-openai-fim-compatible-options :end-point "http://localhost:11434/v1/completions")
    ;; an arbitrary non-null environment variable as placeholder.
    ;; For Windows users, TERM may not be present in environment variables.
    ;; Consider using APPDATA instead.
    (plist-put minuet-openai-fim-compatible-options :name "Ollama")
    (plist-put minuet-openai-fim-compatible-options :api-key "TERM")
    (plist-put minuet-openai-fim-compatible-options :model "qwen2.5-coder:7b")

    (minuet-set-optional-options minuet-openai-fim-compatible-options :max_tokens 56))
(use-package sudo-edit
  )
(use-package latex-preview-pane)
