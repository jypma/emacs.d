;;; Basic setup

(setq custom-file "~/tmp/emacsconf/custom.el")
(load custom-file)
(add-to-list 'load-path "~/tmp/emacsconf/lisp/")

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
(global-set-key (kbd "C-x k") 'kill-this-buffer)

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
(setq-default eglot-workspace-configuration
              '(:java (:format
                       (:settings
                        (:url "/home/jan/eclipse-format-jan.xml")
                        :enabled t))
))

;;; Elisp-specific customization
(add-hook 'emacs-lisp-mode-hook
	  (lambda()
            (setq c-basic-offset 4)
            (setq indent-tabs-mode nil)
            (setq tab-width 4)
	    (setq outline-regexp "\\(;;[;]\\{1,8\\} \\|\\((use-package\\)\\)")
	    (outline-minor-mode)
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
  (setq adaptive-wrap-extra-indent 4)
  (c-set-offset 'arglist-intro '+)         ;; only 1 indent for multi-line args lists
  (c-set-offset 'arglist-cont-nonempty '+) ;; 0 fixes lambdas, but breaks normal arg lists.
  ;;(c-set-offset 'arglist-cont-nonempty '0) ;; 0 fixes lambdas, but breaks normal arg lists.
  (c-set-offset 'arglist-close '0)         ;; Single closing paren on a line should line up
  (c-set-offset 'case-label '+)            ;; Indent before case labels
  (setq fill-column 130)                   ;; yes, looks worse on github, but, java.
  (setq whitespace-line-column 130)
  (setq c-basic-offset 4)
  (setq indent-tabs-mode nil)
  (setq tab-width 4)
  (electric-indent-mode)
  ;; (outline-minor-mode) ;; doesn't work nicely with tree-sitter-mode
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
(use-package eglot-java
  :config
  (add-hook 'java-mode-hook 'eglot-java-mode)
  (add-hook 'java-ts-mode-hook 'eglot-java-mode))
;;;; LSP
;; (use-package company
;;   :defer t
;;   :config
;;   (setq company-minimum-prefix-length 0)
;;   ;; Don't use company mode in eshell (since tramp gets really slow)
;;   (setq company-global-modes '(not eshell-mode))

;;   ;; Don't autocomplete numbers
;;   (setq company-dabbrev-char-regexp "[A-z:-]")
;;   (setq company-dabbrev-ignore-case nil)
;;   (setq company-dabbrev-downcase nil)

;;   (dolist (mode '(emacs-lisp-mode-hook
;;                   java-mode-hook
;;                   scala-mode-hook)) (add-hook mode #'company-mode))
           
;;   ;;(define-key company-active-map (kbd "TAB") #'company-complete-selection)
;;   (define-key company-active-map (kbd "SPC") nil)

;;   :bind ("C-<tab>" . 'company-complete))

;; (use-package lsp-mode
;;   :commands (lsp)
;;   :init (setq ;;lsp-eldoc-render-all nil
;;          lsp-keymap-prefix "C-c l"
;;          ;;lsp-highlight-symbol-at-point nil
;;          ;;lsp-prefer-flymake nil    ;; for metals, https://scalameta.org/metals/docs/editors/emacs.html
;;          lsp-inhibit-message t)
;;   )

;; (use-package lsp-ui
;;   :after lsp-mode
;;   :config
;;   ;;(setq lsp-ui-sideline-update-mode 'point)
;;   :bind (
;;          :map lsp-ui-mode-map
;;               ("C-c C-SPC" . lsp-execute-code-action)
;;               )
;;    )


;; (defun my/lsp-java-setup ()
;;   ;; disable lsp-format-region, maybe it will make ws-butler work better?
;;   (setq lsp-enable-indentation nil)
  
;;   (lsp))
;; (use-package lsp-java
;;   :config
;;   (add-hook 'java-mode-hook #'my/lsp-java-setup)
;;   (add-hook 'java-ts-mode-hook #'my/lsp-java-setup))

;;;; Scala
(use-package scala-mode
  :mode "\\.s\\(cala\\|bt\\)$"
  :pin melpa
  :config
  (add-hook 'scala-mode-hook
          (lambda ()
            (setq adaptive-wrap-extra-indent 2)
            (setq outline-regexp "[ \t]*\\(def\\|if\\|class\\|object\\|case\\|trait\\|abstract class\\).*$")
            (visual-line-mode)
            ;; disable lsp-format-region, since it doesn't work with metals.
            (setq lsp-enable-indentation nil)
            (setq indent-region-function nil)
            (lsp)
            ))
  (add-to-list 'hs-special-modes-alist
             '(scala-mode "{" "}" "/[*/]"
               nil
               nil))
  (define-key scala-mode-map (kbd "<backtab>") 'hs-toggle-hiding))
(use-package lsp-metals
  :after lsp-mode)

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

(use-package org-superstar
  :hook (org-mode . org-superstar-mode))

(use-package org-appear
  :hook (org-mode . org-appear-mode))

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

(use-package yaml-mode
  :bind
  (:map yaml-mode-map
        ("C-." . find-file-at-point))
  :hook ((yaml-mode . visual-line-mode)
         (yaml-mode . whitespace-mode)))
(use-package yasnippet
  :demand ;; doesn't work in org-mode otherwise
  :config
  (yas-global-mode 1)
  (define-key yas-minor-mode-map (kbd "<tab>") nil)
  (define-key yas-minor-mode-map (kbd "TAB") nil)
  (define-key yas-minor-mode-map (kbd "C-t") #'yas-expand))

;; This assumes you've installed the package via MELPA.
