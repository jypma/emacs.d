;; Limit garbage collection during startup.
(setq gc-cons-threshold (* 100 1000 1000))
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 2 1000 1000))))

(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(setq package-archive-ties '(("melpa-stable" . 1)))
(add-to-list 'load-path "~/.emacs.d/lisp/")

;; Fix for oauth2.el warnings
(defvar url-http-method)
(defvar url-http-data)
(defvar url-http-extra-headersurl-http-extra-headers)
(defvar oauth--token-data)
(defvar url-callback-function)
(defvar url-callback-arguments)

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

;; Prefer packages from git/ over ones in elpa/
(let ((emacs-git "~/.emacs.d/git/"))
  (mapc (lambda (x)
          (add-to-list 'load-path (expand-file-name x emacs-git)))
        (delete ".." (directory-files emacs-git))))

;; Always install use-package, so we can install packages using it
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile (require 'use-package))

(setq use-package-verbose t)

;; Use a hook so the message doesn't get clobbered by other messages.
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs ready in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; Always install (ensure) packages when we use-package them
(setq use-package-always-ensure t)

(require 'whitespace)
(add-hook 'prog-mode-hook #'whitespace-mode)
(add-hook 'conf-mode-hook #'whitespace-mode)

(load "~/.emacs.d/setup-ligatures.el")

(require 'thread-dump)

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(set-face-attribute 'highlight nil :foreground 'unspecified)
(set-face-attribute 'region nil :foreground 'unspecified)

(tool-bar-mode -1)

(setq my/frame-font-name "New Heterodox Mono")
;;(setq my/frame-font-name "Iosevka")

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

;; Use pretty symbols everywhere
(global-prettify-symbols-mode 1)

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

;; icons for major modes
(use-package all-the-icons
  :demand)

(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode))

;; Allow tree-semantics for undo operations.
;; Execute (undo-tree-visualize) then navigate along the tree to witness
;; changes being made to your file live!
;;(use-package undo-tree
;;  :config
  ;; Always have it on
;;  (global-undo-tree-mode)

  ;; Each node in the undo tree should have a timestamp.
;;  (setq undo-tree-visualizer-timestamps t)

  ;; Show a diff window displaying changes between undo nodes.
;;  (setq undo-tree-visualizer-diff t))

;; run all-the-icons-install-fonts on first run on a machine.


;; customize git modeline display
(setcdr (assq 'vc-mode mode-line-format)
        '((:eval (replace-regexp-in-string "^ Git" "" vc-mode))))

;; easy diff of local history
;; backup-walker uses cl instead of the newer cl-lib. Disable the Emacs 27 warning on this.
(setq byte-compile-warnings '(cl-functions))
(require 'backup-walker)
(global-set-key (kbd "C-x v w") 'backup-walker-start)

;; color picker
(require 'colorpicker)
(global-set-key (kbd "C-x c") 'colorpicker)

;; change spelling dictionary
(global-set-key (kbd "<f7>") 'ispell-change-dictionary)

(require 'uuidgen)

(require 'ordbog)

;; highlight #ff etc as actual colors
(use-package rainbow-mode
  :hook (markdown-mode web-mode help-mode html-mode css-mode js-mode js-jsx-mode emacs-lisp-mode prog-mode))

(use-package projectile
  :init (projectile-global-mode)
  :bind-keymap (("C-c p" . projectile-command-map))

  :config
  (setq projectile-switch-project-action #'projectile-dired)

  (advice-add 'projectile-project-root :around (lambda (orig-fun &optional dir)
                                                 (let ((dir (file-truename (or dir default-directory))))
                                                   (unless (file-remote-p dir)
                                                     (funcall orig-fun dir))))))

(use-package ibuffer-projectile
  :config

  (add-hook 'ibuffer-hook
            (lambda ()
              (ibuffer-projectile-set-filter-groups)
              (unless (eq ibuffer-sorting-mode 'alphabetic)
                (ibuffer-do-sort-by-alphabetic))))
  (setq ibuffer-formats
        '((mark modified read-only " "
                (name 18 18 :left :elide)
                " "
                (size 9 -1 :right)
                " "
                (mode 16 16 :left :elide)
                " "
                project-relative-file))))

(use-package goto-addr
  :hook ((compilation-mode . goto-address-mode)
         (prog-mode . goto-address-prog-mode)
         (eshell-mode . goto-address-mode)
         (shell-mode . goto-address-mode))
  :commands (goto-address-prog-mode
             goto-address-mode))

(use-package transient)


;; See https://github.com/magit/ghub/issues/81, this is needed for github integration
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")


(use-package magit
  :commands (magit-status)
  :config
  ;;  magit default to origin/master instead of just master
  (setq magic-prefer-remote-upstream 1)
  (setq magit-list-refs-sortby "-creatordate")
  ;;  Hide "Recent Commits"
  ;;  https://github.com/magit/magit/issues/3230
  (magit-add-section-hook 'magit-status-sections-hook
                          'magit-insert-unpushed-to-upstream;
                          'magit-insert-unpushed-to-upstream-or-recent
                          'replace)

  :bind ("C-x g" . magit-status))

(use-package forge
 :after magit)

(use-package git-timemachine
  :commands (git-timemachine))

(use-package hl-todo)

(use-package magit-todos
 :after magit
 :init
 (magit-todos-mode))

(use-package sbt-mode
  :pin melpa
  :commands sbt-start sbt-command
  :config
  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
  ;; allows using SPACE when in the minibuffer
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)

  ;; sbt-supershell kills sbt-mode:  https://github.com/hvesalai/emacs-sbt-mode/issues/152
  (setq sbt:program-options '("-Dsbt.supershell=false")))

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

(use-package company-emoji
  :after company)

(use-package company
  :defer t
  :config
  (setq company-minimum-prefix-length 0)
  ;; Don't use company mode in eshell (since tramp gets really slow)
  (setq company-global-modes '(not eshell-mode))

  ;; Don't autocomplete numbers
  (setq company-dabbrev-char-regexp "[A-z:-]")
  (setq company-dabbrev-ignore-case nil)
  (setq company-dabbrev-downcase nil)

  (global-company-mode)

  (define-key company-active-map (kbd "TAB") #'company-complete-selection)
  (define-key company-active-map (kbd "SPC") nil)

  :bind ("C-<tab>" . 'company-complete))

;; Error checking with flycheck-rtags as a backend
(use-package flycheck
  :after lsp)

;; Format files consistently
;; (use-package clang-format)

(use-package which-key
  :config
  (which-key-mode))

(use-package eshell-bookmark
  :hook (eshell-mode . eshell-bookmark-setup))

;; auto-save bookmarks
(setq bookmark-save-flag 1)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode)
  :hook (conf-mode . rainbow-delimiters-mode))

;; Press ) in dired will show git annotations for each dir + file
(package-install-file "~/.emacs.d/lisp/dired-git-info.el")
(with-eval-after-load 'dired
  (define-key dired-mode-map ")" 'dired-git-info-mode))

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

;; open file in dired into desktop, mpv, etc.
(defun dired-open-file ()
  "In dired, open the file named on this line."
  (interactive)
  (let* ((file (dired-get-filename nil t)))
    (call-process "xdg-open" nil 0 nil file)))
(define-key dired-mode-map (kbd "C-c o") 'dired-open-file)

(use-package expand-region
  :bind ("C-=" . er/expand-region))

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
  (setq gnus-icalendar-org-capture-file "~/org/notes.org")
  (setq gnus-icalendar-org-capture-headline '("Calendar"))
  (gnus-icalendar-org-setup)
  (setq mu4e-view-use-gnus t)
  (mu4e-icalendar-setup)

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
              (flyspell-mode))))

(load "~/.emacs.d/eshell_ext.el")

;; Ctrl+A in eshell moves to beginning of command, then to real beginning of line
(defun eshell-maybe-bol ()
  (interactive)
  (let ((p (point)))
    (eshell-bol)
    (if (= p (point))
        (beginning-of-line))))
(add-hook 'eshell-mode-hook
          (lambda () (define-key eshell-mode-map "\C-a" 'eshell-maybe-bol)))

;; enable spell checking in documentation
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
                java-mode-hook))
  (add-hook mode #'flyspell-prog-mode))

(require 'js)
(define-key js-mode-map (kbd "<backtab>") 'hs-toggle-hiding)

(add-hook 'text-mode-hook (lambda ()
                                (setq company-idle-delay 1.0)
                                (setq company-minimum-prefix-length 3)))

(add-hook 'markdown-mode-hook (lambda ()
                                (visual-line-mode)
                                (variable-pitch-mode)
                                (flyspell-mode)))

;; use popup menu for completions instead of strange top-of-buffer selector
(use-package flyspell-popup
  :config
;;  (add-hook 'flyspell-mode-hook #'flyspell-popup-auto-correct-mode) ;; don't like it after all
  (define-key flyspell-mode-map (kbd "C-;") #'flyspell-popup-correct))

;; don't create lock files, nobody else is editing on my machine. Plus, we've got autorevert.
(setq create-lockfiles nil)

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
                  java-mode-hook))
    (add-hook mode #'git-gutter-mode)))

(use-package diff-hl
  ;; only for dired, we use git-gutter for normal files
  :hook (dired-mode . diff-hl-dired-mode-unless-remote))

(use-package dashboard
  :config
  (global-set-key (kbd "<f5>") (lambda () (interactive) (switch-to-buffer "*dashboard*")))
  (dashboard-setup-startup-hook)
  (setq dashboard-items '((recents  . 25)
                          (bookmarks . 5)
                          (projects . 25))))

;; Better window switching with M-o (also across frames)
(use-package ace-window
  :bind ("M-o" . ace-window))

(when (file-exists-p "~/.emacs.d/jira.el")
  (use-package org-jira
    :config
    (load "~/.emacs.d/jira.el")))
;; https://github.com/ahungry/org-jira#authorization-workaround-not-secure
;; (defconst jiralib-token
;;   `("Cookie" . ,(format "__atl_path=...; studio.crowd.tokenkey=...")))

(defun android-browse-url (url)
  "Opens the given url through an android intent, assuming we're running in Termux on Android."
  (start-process-shell-command "open-url" nil
                                             (concat "am start -a android.intent.action.VIEW -d " url))
  )

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

;; How much I like my files indented
(setq c-basic-offset 2)
(defconst my-cc-style
  '("cc-mode"
    (c-offsets-alist . ((innamespace . [0])))))
(c-add-style "my-cc-mode" my-cc-style)
(c-set-offset 'innamespace 0)
(c-set-offset 'case-label '+)

;; Auto refresh buffers if modified externally
(global-auto-revert-mode)
;; Also auto refresh dired, but be quiet about it
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)

(setq column-number-mode t)

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

(use-package highlight-symbol
  :hook (java-mode . highlight-symbol-mode)
  :config
  (setq highlight-symbol-idle-delay 0.3))

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
                        '(("sealed" . font-lock-keyword-face)))
(font-lock-add-keywords 'java-mode
                        '(("record" . font-lock-keyword-face)) 1)
(font-lock-add-keywords 'java-mode
                        '(("permits" . font-lock-keyword-face)))

(add-hook 'java-mode-hook
          (lambda ()
            (abbrev-mode 0)
            (setq adaptive-wrap-extra-indent 4)
            (c-set-offset 'arglist-intro '+)         ;; only 1 indent for multi-line args lists
            (c-set-offset 'arglist-cont-nonempty '+) ;; 0 fixes lambdas, but breaks normal arg lists.
            (c-set-offset 'arglist-close '0)         ;; Single closing paren on a line should line up
            (c-set-offset 'case-label '+)            ;; Indent before case labels
            (setq fill-column 130)                   ;; yes, looks worse on github, but, java.
            (setq whitespace-line-column 130)
            (setq c-basic-offset 4)
            (outline-minor-mode)
            (visual-line-mode)))

(add-hook 'c++-mode-hook (lambda()
                           (c-set-offset 'substatement-open 0)
                           (c-set-offset 'template-args-cont '+)
                           (c-set-offset 'brace-list-intro '+)
                           (c-set-offset 'case-label '+)
                           (c-set-offset 'innamespace '[0])
                           (abbrev-mode 0)
                           (setq adaptive-wrap-extra-indent 2)
                           (visual-line-mode)
                           (lsp)))
(add-hook 'c-mode-hook (lambda()
                           (c-set-offset 'substatement-open 0)
                           (c-set-offset 'template-args-cont '+)
                           (c-set-offset 'brace-list-intro '+)
                           (c-set-offset 'case-label '+)
                           (abbrev-mode 0)
                           (setq adaptive-wrap-extra-indent 2)
                           (visual-line-mode)
                           (lsp)))

(require 'protobuf-mode)

(defconst my-protobuf-style
  '((c-basic-offset . 4)
    (indent-tabs-mode . nil)))

(add-hook 'protobuf-mode-hook
          (lambda () (c-add-style "my-style" my-protobuf-style t)))

(add-to-list 'auto-mode-alist '("\\.proto\\'" . protobuf-mode))

(electric-pair-mode 1)

(global-set-key (kbd "C-x b") 'ibuffer)

(global-set-key (kbd "C-c d") 'my/duplicate-line)

;; dired: automatically move/copy to "other" pane's directory
(setq dired-dwim-target t)

;; Remember recently opened files
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

;; Auto-set git column to 72 for M-q
(use-package git-commit
  :demand
  :hook (git-commit-setup . git-commit-turn-on-flyspell)
  :preface
  (defun me/git-commit-set-fill-column ()
    (setq-local comment-auto-fill-only-comments nil)
    (setq fill-column 72))
  :config
  (advice-add 'git-commit-turn-on-auto-fill :before #'me/git-commit-set-fill-column))

(global-hl-line-mode 1)

;; run bash for ansi-term
(defadvice ansi-term (before force-bash)
  (interactive (list "/bin/bash")))
(ad-activate 'ansi-term)

;; add yank shortcut to term raw mode
;; (this defaults to shift-insert which isn't very nice.)
(eval-after-load "term"
  '(define-key term-raw-map (kbd "C-c C-y") 'term-paste))

;; confirm with y instead of yes
(defalias 'yes-or-no-p 'y-or-n-p)

;; scroll only new lines into view as needed, instead of a whole page at once
(setq scroll-conservatively 100)

;; don't make sounds, like, ever.
(setq ring-bell-function 'ignore)

;; cursor as visible as possible
(set-cursor-color "#ffffff")

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

;; (set-display-table-slot standard-display-table
;;                          'selective-display
;;                          (string-to-vector "…"))

;; customize the face as well
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

;; activate dired-jump
(require 'dired-x)

;; no whitespace mode for readonly files
(defun my/read-only-whitespace ()
  (when buffer-read-only
    (whitespace-mode -1)))
(add-hook 'find-file-hook 'my/read-only-whitespace)

;; save the clipboard into the kill ring before killing
(setq save-interprogram-paste-before-kill t)

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
(use-package htmlize
  :commands (htmlize-buffer htmlize-region htmlize-file))

;; https://emacs.stackexchange.com/questions/19344/why-does-xdg-open-not-work-in-eshell
(setq process-connection-type nil)

;; Don't indent org documents
(setq org-startup-indented nil)

(use-package org-superstar
  :hook (org-mode . org-superstar-mode))

(require 'markdown-mode) ;; We customize org faces to depend on markdown faces

(use-package org-appear
  :hook (org-mode . org-appear-mode))

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

;; http://endlessparentheses.com/better-time-stamps-in-org-export.html
(require 'ox)
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

(use-package evil-numbers
  :bind
  ("C-c =" . evil-numbers/inc-at-pt)
  ("<kp-add>" . evil-numbers/inc-at-pt)
  ("C-c -" . evil-numbers/dec-at-pt)
  ("<kp-subtract>" . evil-numbers/dec-at-pt))

;; enable re-use of ssh connections
;; https://emacs.stackexchange.com/questions/22306/working-with-tramp-mode-on-slow-connection-emacs-does-network-trip-when-i-start
;; https://www.reddit.com/r/emacs/comments/gxhomh/help_tramp_connections_make_emacs_unresponsive_on/
(setq
 tramp-ssh-controlmaster-options "-o ControlMaster=auto -o ControlPath='tramp.%%C' -o ControlPersist=10"
;; Disable version control to avoid delays:
;;vc-ignore-dir-regexp (format "\\(%s\\)\\|\\(%s\\)"
;;vc-ignore-dir-regexp tramp-file-name-regexp)
 tramp-copy-size-limit nil
 tramp-default-method "scpx"
 tramp-completion-reread-directory-timeout t)

;; auto-commit used for org todo list sync
(use-package git-auto-commit-mode)

;; use extra config files for tramp ssh host completion
(require 'tramp)
(require 'tramp-cache)
(tramp-set-completion-function "ssh"
                                  '((tramp-parse-sconfig "/etc/ssh_config")
                                    (tramp-parse-sconfig "~/.ssh/config")
                                    (tramp-parse-sconfig "~/.ssh/config.jyp")
                                    (tramp-parse-sconfig "~/.ssh/config.production")
                                    (tramp-parse-sconfig "~/.ssh/config.sandbox")
                                    (tramp-parse-sconfig "~/.ssh/config.smoketests")
                                    (tramp-parse-sconfig "~/.ssh/config.staging")
                                    ))

;; we do use downcase-region
(put 'downcase-region 'disabled nil)

(require 'hide-lines)
(autoload 'hide-lines "hide-lines" "Hide lines based on a regexp" t)
(global-set-key "\C-ch" 'hide-lines)

(use-package super-save
  :demand ;; defer doesn't actually load and activate this
  :config
  (super-save-mode 1)
  (setq super-save-remote-files nil))

(use-package yasnippet
  :demand ;; doesn't work in org-mode otherwise
  :config
  (yas-global-mode 1)
  (define-key yas-minor-mode-map (kbd "<tab>") nil)
  (define-key yas-minor-mode-map (kbd "TAB") nil)
  (define-key yas-minor-mode-map (kbd "C-t") #'yas-expand))

;; for snippets
(defun my/capitalize-first-char (&optional string)
  "Capitalize only the first character of the input STRING."
  (when (and string (> (length string) 0))
    (let ((first-char (substring string nil 1))
          (rest-str   (substring string 1)))
      (concat (capitalize first-char) rest-str))))

;; (use-package treemacs)

(use-package lsp-mode
  :commands (lsp)
  :init (setq lsp-eldoc-render-all nil
              lsp-keymap-prefix "C-c l"
              lsp-highlight-symbol-at-point nil
              lsp-prefer-flymake nil    ;; for metals, https://scalameta.org/metals/docs/editors/emacs.html
              lsp-inhibit-message t)
  )

(use-package lsp-metals
  :after lsp-mode)

(use-package lsp-ui
  :after lsp-mode
  :config
  (setq lsp-ui-sideline-update-mode 'point)
  :bind (
         :map lsp-ui-mode-map
              ("C-c C-SPC" . lsp-execute-code-action)
              )
   )

(use-package lsp-java
;;  :after lsp-mode
  :config
  ;; Allow M-? to work , see https://github.com/emacs-lsp/lsp-java/issues/122
;;  (setq xref-prompt-for-identifier '(not xref-find-definitions
;;                                            xref-find-definitions-other-window
;;                                            xref-find-definitions-other-frame
;;                                            xref-find-references))

;;  (add-hook 'java-mode-hook
;;            (lambda ()
;;              (setq-local company-backends (list 'company-lsp))))

  (setq lombok-library-path "~/.cache/lombok.jar")

  (unless (file-exists-p lombok-library-path)
    (url-copy-file "https://projectlombok.org/downloads/lombok.jar" lombok-library-path))

  ;; (setq lsp-java-vmargs '("-XX:+UseParallelGC" "-XX:GCTimeRatio=4" "-XX:AdaptiveSizePolicyWeight=90" "-Dsun.zip.disableMemoryMapping=true" "-Xmx4G" "-Xms100m"))

  (push (concat "-javaagent:"
                  (expand-file-name lombok-library-path))
        lsp-java-vmargs)

  (add-hook 'java-mode-hook #'lsp))

(use-package dap-mode
  :after lsp-mode
  :config
  (dap-mode t)
  (dap-ui-mode t))

(use-package eyebrowse
  :defer t
  :init
  (eyebrowse-mode t)
  (eyebrowse-setup-opinionated-keys))

(use-package scad-mode
  :mode "\\.scad\\'")

(use-package adaptive-wrap
  :hook ((scala-mode java-mode c-mode c++-mode yaml-mode markdown-mode org-mode) . adaptive-wrap-prefix-mode))

(use-package ws-butler
  :hook ((yaml-mode conf-mode prog-mode protobuf-mode markdown-mode nxml-mode sgml-mode) . ws-butler-mode))

(use-package dockerfile-mode
  :mode "\\Dockerfile\\'")

(use-package ob-http
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (http . t))))

;; Easily search through the content of files marked in a dired buffer using occur mode
(use-package noccur
  :after projectile
  :bind
  ("C-c o" . 'noccur-project))

(use-package alert
  :commands (alert)
  :init
  (setq alert-default-style 'notifier))

(use-package visual-regexp
  :bind
  ("C-c r" . 'vr/replace)
  ("C-c q" . 'vr/query-replace))

;; Colorize compile buffer if process sends escape codes
;; https://stackoverflow.com/questions/13397737/ansi-coloring-in-compilation-mode
(ignore-errors
  (require 'ansi-color)
  (defun my-colorize-compilation-buffer ()
    (when (eq major-mode 'compilation-mode)
      (ansi-color-apply-on-region compilation-filter-start (point-max))))
  (add-hook 'compilation-filter-hook 'my-colorize-compilation-buffer))

(defun my-compilation-prettify-symbols-predicate (start end match)
  (message "Match: %s" match)
  t)

(defun my-compilation-mode-prettify ()
  "Enable prettify symbols and replace current directory with house symbol."
  (setq prettify-symbols-alist
        `((,(expand-file-name (directory-file-name default-directory)) . ?⌂)
          (,(expand-file-name "~") . ?~)))
  (setq prettify-symbols-compose-predicate 'my-compilation-prettify-symbols-predicate)
  (prettify-symbols-mode t)
  (visual-line-mode 1))

(add-hook 'compilation-mode-hook 'my-compilation-mode-prettify)

;; bloop parse support for compilation mode
(add-to-list 'compilation-error-regexp-alist-alist
             '(bloop
               "\\[.+\\] \\([^\n:]+\\):\\([0-9]+\\):\\([0-9]+\\)"
               1 2 3))

(add-to-list 'compilation-error-regexp-alist 'bloop)

(use-package yaml-mode
  :bind
  (:map yaml-mode-map
        ("C-." . find-file-at-point))
  :hook ((yaml-mode . visual-line-mode)
         (yaml-mode . whitespace-mode)))

;;(use-package smartparens
;;  :config
;;  (require 'smartparens-config))

;; Open compile buffer in the same window
(add-to-list 'same-window-buffer-names "*compilation*")

;; Open compile results in the same window
(defun my-compile-goto-error-same-window ()
  (interactive)
  (let ((display-buffer-overriding-action
         '(display-buffer-reuse-mode-window)))
    (call-interactively #'compile-goto-error)))

(defun my-compilation-mode-hook ()
  (local-set-key (kbd "o") #'my-compile-goto-error-same-window))

(add-hook 'compilation-mode-hook #'my-compilation-mode-hook)

;; Awesome indent-based folding of any file with Shift-Tab and Ctrl-Shift-Tab
(use-package bicycle
  :after outline
  :bind (:map outline-minor-mode-map
              ([backtab] . bicycle-cycle)
              ([C-iso-lefttab] . bicycle-cycle-global)))

(add-hook 'prog-mode-hook 'hs-minor-mode)

(use-package pdf-tools
  :mode  ("\\.pdf\\'" . pdf-view-mode)
  :config
  ;; initialise
  (require 'pdf-tools)
  (require 'pdf-view)
  (require 'pdf-misc)
  (require 'pdf-occur)
  (require 'pdf-util)
  (require 'pdf-annot)
  (require 'pdf-info)
  (require 'pdf-isearch)
  (require 'pdf-history)
  (require 'pdf-links)
  (pdf-tools-install :no-query)
  ;; open pdfs scaled to fit page
  (setq-default pdf-view-display-size 'fit-page)
  ;; automatically annotate highlights
  (setq pdf-annot-activate-created-annotations t)
  ;; use normal isearch
  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward))

(use-package puppet-mode
  :mode "\\.pp\\'"
  :pin melpa)

(use-package platformio
  :ensure nil
  :load-path "~/.emacs.d/platformio/"
  :commands (platformio-running))

;; To edit code blacks in markdown
(use-package edit-indirect)

(use-package logview
  :mode "\\.log\\(?:\\.[0-9]+\\)?\\'"
  :pin melpa)

(use-package telega
  :commands (telega)
  :defer t)

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
(setq org-plantuml-exec-mode 'plantuml)

;; Allow images to be zoomed in and out
(defun scale-image ()
  "Scale the image by the same factor specified by the text scaling."
  (if (derived-mode-p 'image-mode)
      (image-transform-set-scale
       (expt text-scale-mode-step
             text-scale-mode-amount))))

(defun scale-image-register-hook ()
  "Register the image scaling hook."
  (add-hook 'text-scale-mode-hook 'scale-image))

(add-hook 'image-mode-hook 'scale-image-register-hook)

(use-package restclient
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((restclient . t))))

;; From https://github.com/alf/ob-restclient.el
(require 'ob-restclient)

(use-package string-inflection
  :bind
  ;; Toggle string capitalization style (camel, caps, snake, etc.)
  ("C-c C-i" . string-inflection-all-cycle))

(use-package highlight-indent-guides
  :hook ((prog-mode yaml-mode) . highlight-indent-guides-mode))

(use-package csv-mode
  :mode "\\.[Cc][Ss][Vv]\\'")

;; Rust stuff starts here
;; from https://www.reddit.com/r/rust/comments/a3da5g/my_entire_emacs_config_for_rust_in_fewer_than_20/
(use-package toml-mode
  :mode "\\.toml\\'")

(use-package rust-mode
  :hook (rust-mode . lsp))

;; Add keybindings for interacting with Cargo
(use-package cargo
  :hook (rust-mode . cargo-minor-mode))

(use-package flycheck-rust
  :after flycheck
  :hook (flycheck-mode . flycheck-rust-setup))

(use-package daemons)

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
  (org-image-actual-width nil)
  )

;; Enable emacsclient to connect to this emacs (needed for mail trigger)
(require 'server)
(unless (server-running-p) (server-start))

(require 'pkgbuild-mode)

(use-package gdscript-mode
  :hook (gdscript-mode . lsp)
  :bind
  (:map gdscript-mode-map
        ("<f5>" . nil)
        ("<f6>" . nil)
        ("<f7>" . nil)
        ("<f8>" . nil)
        ("<f9>" . nil))
  :config


  ;; https://github.com/godotengine/emacs-gdscript-mode#known-issues
  (defun lsp--gdscript-ignore-errors (original-function &rest args)
    "Ignore the error message resulting from Godot not replying to the `JSONRPC' request."
    (if (string-equal major-mode "gdscript-mode")
        (let ((json-data (nth 0 args)))
          (if (and (string= (gethash "jsonrpc" json-data "") "2.0")
                   (not (gethash "id" json-data nil))
                   (not (gethash "method" json-data nil)))
              nil ; (message "Method not found")
            (apply original-function args)))
      (apply original-function args)))
  ;; Runs the function `lsp--gdscript-ignore-errors` around `lsp--get-message-type` to suppress unknown notification errors.
  (advice-add #'lsp--get-message-type :around #'lsp--gdscript-ignore-errors))

(use-package log4j-mode)

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

(defun basic-remote-try-completion (string table pred point)
  (and (vertico--remote-p string)
       (completion-basic-try-completion string table pred point)))
(defun basic-remote-all-completions (string table pred point)
  (and (vertico--remote-p string)
       (completion-basic-all-completions string table pred point)))
(add-to-list
 'completion-styles-alist
 '(basic-remote basic-remote-try-completion basic-remote-all-completions nil))
(setq completion-styles '(orderless)
      completion-category-overrides '((file (styles basic-remote partial-completion)))))

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
  ;;(setq consult-project-root-function
  ;;      (lambda ()
  ;;        (when-let (project (project-current))
  ;;          (car (project-roots project)))))
  ;;;; 2. projectile.el (projectile-project-root)
  (autoload 'projectile-project-root "projectile")
  (setq consult-project-root-function #'projectile-project-root)
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

(use-package org-journal
  :bind (
         ("C-c c" . org-capture)
         ("C-c C-j" . org-journal-new-entry)))

;; https://github.com/minad/osm/issues/12
(unless (fboundp 'json-available-p)
  (defun json-available-p ()
    (fboundp 'json-parse-string)))
(use-package osm
  :bind (("C-c m h" . osm-home)
         ("C-c m s" . osm-search)
         ("C-c m v" . osm-server)
         ("C-c m t" . osm-goto)
         ("C-c m x" . osm-gpx-show)
         ("C-c m j" . osm-bookmark-jump))

  :custom
  ;; Take a look at the customization group `osm' for more options.
  (osm-server 'default) ;; Configure the tile server
  (osm-copyright nil)     ;; Display the copyright information
)

(use-package nov
  :config
  (add-hook 'nov-mode-hook
          (lambda ()
            (setq adaptive-wrap-extra-indent 2)
            (visual-line-mode)
            )))

(use-package kubernetes)
