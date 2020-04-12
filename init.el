
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

;; Always install (ensure) packages when we use-package them
(setq use-package-always-ensure t)

(require 'whitespace)
(add-hook 'prog-mode-hook #'whitespace-mode)

(load "~/.emacs.d/setup-ligatures.el")

(require 'thread-dump)

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(set-face-attribute 'highlight nil :foreground 'unspecified)
(set-face-attribute 'region nil :foreground 'unspecified)

(tool-bar-mode -1)

(defun my/fontify-frame (frame)
  (interactive)
  (if window-system
      (progn
        (if (> (x-display-pixel-width) 2600)
            (set-frame-font "Iosevka 14" nil t) ;; HIDPI
         (set-frame-font "Iosevka 10" nil t)))))

;; Fontify current frame
(my/fontify-frame nil)

;; Fontify any future frames
(push 'my/fontify-frame after-make-frame-functions)

;; magit default to origin/master instead of just master
(setq magic-prefer-remote-upstream 1)

;; Use pretty symbols everywhere
(global-prettify-symbols-mode 1)

;; Winner: use C-c left, right to cycle previous window layouts
(winner-mode 1)

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

;; Hide certain packages from the modeline
(use-package delight)

;; don't show subword mode in modeline
(delight 'subword-mode nil t)

;; Allow tree-semantics for undo operations.
;; Execute (undo-tree-visualize) then navigate along the tree to witness
;; changes being made to your file live!
(use-package undo-tree
  :delight                       ;; Don't show an icon in the modeline
  :config
  ;; Always have it on
  (global-undo-tree-mode)

  ;; Each node in the undo tree should have a timestamp.
  (setq undo-tree-visualizer-timestamps t)

  ;; Show a diff window displaying changes between undo nodes.
  (setq undo-tree-visualizer-diff t))

;; icons for major modes
(use-package all-the-icons)

;; run all-the-icons-install-fonts on first run on a machine.

;; (delight 'emacs-lisp-mode (all-the-icons-fileicon "emacs" :height 0.7) :major)
(delight 'eldoc-mode nil t)
;; (delight 'groovy-mode (all-the-icons-fileicon "groovy" :height 1.2) :major)
;; (delight 'java-mode "J" :major) ;; (the-icons-alltheicon "java") ""
(delight 'sh-mode '(:eval (format "%s" (sh-shell))))

;; customize git modeline display
(setcdr (assq 'vc-mode mode-line-format)
        '((:eval (replace-regexp-in-string "^ Git" "" vc-mode))))

;; easy diff of local history
(require 'backup-walker)
(global-set-key (kbd "C-x v w") 'backup-walker-start)

;; color picker
(require 'colorpicker)
(global-set-key (kbd "C-x c") 'colorpicker)

(require 'uuidgen)

(require 'ordbog)

;; highlight #ff etc as actual colors
(use-package rainbow-mode
  :config
  (add-hook 'scala-mode-hook #'rainbow-mode)
  (add-hook 'markdown-mode-hook #'rainbow-mode)
  (add-hook 'web-mode-hook #'rainbow-mode)
  (add-hook 'help-mode-hook #'rainbow-mode)
  (add-hook 'html-mode-hook #'rainbow-mode)
  (add-hook 'css-mode-hook #'rainbow-mode)
  (add-hook 'js-mode-hook #'rainbow-mode)
  (add-hook 'js-jsx-mode-hook #'rainbow-mode)
  (add-hook 'emacs-lisp-mode-hook #'rainbow-mode)
  (add-hook 'prog-mode-hook #'rainbow-mode)
  :delight)

(use-package projectile
  :init (projectile-global-mode)
  :bind-keymap (("C-c p" . projectile-command-map))

  :config
  (setq projectile-switch-project-action #'projectile-dired)

  (advice-add 'projectile-project-root :around (lambda (orig-fun &optional dir)
                                                 (let ((dir (file-truename (or dir default-directory))))
                                                   (unless (file-remote-p dir)
                                                     (funcall orig-fun dir)))))

  :delight '(:eval (concat " " (projectile-project-name) "  ")))

(use-package goto-addr
  :hook ((compilation-mode . goto-address-mode)
         (prog-mode . goto-address-prog-mode)
         (eshell-mode . goto-address-mode)
         (shell-mode . goto-address-mode))
  :commands (goto-address-prog-mode
             goto-address-mode))

(use-package magit
  :config
  ;; See https://github.com/magit/ghub/issues/81, this is needed for github integration
  (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

  (setq magit-list-refs-sortby "-creatordate")
  ;; Hide "Recent Commits"
  ;; https://github.com/magit/magit/issues/3230
  (magit-add-section-hook 'magit-status-sections-hook
                          'magit-insert-unpushed-to-upstream
                          'magit-insert-unpushed-to-upstream-or-recent
                          'replace))

(use-package forge
  :after magit)

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
  :pin melpa)

(use-package company-emoji)

(use-package company
  :init (global-company-mode)
  :config
  (setq company-minimum-prefix-length 0)
  ;; Don't use company mode in eshell (since tramp gets really slow)
  (setq company-global-modes '(not eshell-mode))

  ;; Don't autocomplete numbers
  (setq company-dabbrev-char-regexp "[A-z:-]")
  (setq company-dabbrev-ignore-case nil)
  (setq company-dabbrev-downcase nil)

  (add-hook 'after-init-hook 'global-company-mode)

  (define-key company-active-map (kbd "TAB") #'company-complete-selection)
  (define-key company-active-map (kbd "SPC") nil)

  :bind ("C-<tab>" . 'company-complete)
  :delight company-mode "  ")


;; Error checking with flycheck-rtags as a backend
(use-package flycheck
  :delight flycheck-mode "  ")

;; Format files consistently
(use-package clang-format)

(use-package which-key
  :config
  (which-key-mode)
  :delight which-key-mode)

(use-package eshell-bookmark
  :config
  (add-hook 'eshell-mode-hook 'eshell-bookmark-setup))

;; auto-save bookmarks
(setq bookmark-save-flag 1)

(use-package ido-vertical-mode
  :init (ido-vertical-mode 1))

(use-package ido-completing-read+
  :init (ido-ubiquitous-mode 1))

(use-package rainbow-delimiters
  :config
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
)

;; Press ) in dired will show git annotations for each dir + file
(package-install-file "~/.emacs.d/lisp/dired-git-info.el")
(with-eval-after-load 'dired
  (define-key dired-mode-map ")" 'dired-git-info-mode))

;; show usage in dired: C-x M-r, toggle display with C-x C-h
(use-package dired-du)

;; auto-collapse directories in dired
(use-package dired-collapse
  :config
  (add-hook 'dired-mode-hook 'dired-collapse-mode))

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
  ;; use mu4e as email client in emacs
  (setq mail-user-agent 'mu4e-user-agent)
  ;; don't keep message buffers around
  (setq message-kill-buffer-on-exit t)
  ;; hide indexer progress so it's not so distracting
  (setq mu4e-hide-index-messages t)
  ;; fix the hideous rendering of html
  (require 'mu4e-contrib)
  (setq mu4e-html2text-command 'mu4e-shr2text)
  (setq shr-color-visible-luminance-min 80)
  (setq shr-color-visible-distance-min 5)

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
          '(lambda () (define-key eshell-mode-map "\C-a" 'eshell-maybe-bol)))

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
                java-mode-hook))
  (add-hook mode #'flyspell-prog-mode)
  (add-hook mode #'ws-butler-mode))

(add-hook 'text-mode-hook (lambda ()
                                (setq company-idle-delay 1.0)
                                (setq company-minimum-prefix-length 3)))

(add-hook 'markdown-mode-hook (lambda ()
                                (ws-butler-mode)
                                (visual-line-mode)
                                (adaptive-wrap-prefix-mode)
                                (flyspell-mode)))

;; use popup menu for completions instead of strange top-of-buffer selector
(use-package flyspell-popup
  :config
;;  (add-hook 'flyspell-mode-hook #'flyspell-popup-auto-correct-mode) ;; don't like it after all
  (define-key flyspell-mode-map (kbd "C-;") #'flyspell-popup-correct))

;; customize minor mode display for flyspell-mode
(delight 'flyspell-mode "   " t)

;; don't show visual-line-mode
(delight 'visual-line-mode "" t)

;; don't create lock files, nobody else is editing on my machine. Plus, we've got autorevert.
(setq create-lockfiles nil)

(use-package git-gutter
  :config
  (global-git-gutter-mode +1)
  (custom-set-variables
   '(git-gutter:update-interval 1))
  :delight)

(use-package diff-hl
  ;; only for dired, we use git-gutter for normal files
  :config
  (add-hook 'dired-mode-hook #'diff-hl-dired-mode-unless-remote))

(use-package dashboard
  :config
  (global-set-key (kbd "<f5>") (lambda () (interactive) (switch-to-buffer "*dashboard*")))
  (dashboard-setup-startup-hook)
  (setq dashboard-items '((recents  . 25)
                          (bookmarks . 5)
                          (projects . 25))))

(use-package flx-ido
  :config
  (ido-mode 1)
  (ido-everywhere 1)
  (flx-ido-mode 1)
  (setq ido-enable-flex-matching t)
  (setq ido-use-faces nil) ;; to see flx highlights
)

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
      "http://nullprogram.com/feed/"
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
      (start-process "elfeed-mpv" nil "mpv" quality-arg (elfeed-entry-link entry))))

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
(global-auto-revert-mode t)
;; Also auto refresh dired, but be quiet about it
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)
(delight 'auto-revert-mode nil t)

(setq column-number-mode t)

;; Backup settings
(setq backup-directory-alist `(("." . "~/.saves")))
(setq delete-old-versions t
  kept-new-versions 6
  kept-old-versions 1000
  vc-make-backup-files t ;; even backup version-controlled files
  version-control t)

;; Make Emacs backup everytime I save
(defun my/force-backup-of-buffer ()
  "Lie to Emacs, telling it the curent buffer has yet to be backed up."
  (setq buffer-backed-up nil))
(add-hook 'before-save-hook  'my/force-backup-of-buffer)

(use-package highlight-symbol
  :config
  (setq highlight-symbol-idle-delay 0.3)
  )


;; Only indent inline lambdas one level
(defun my-java-indent-lambda (orig-fun &rest args)
  (let ((symbols (car args)))
       (if (and (eq 2 (length symbols))
                (eq 'arglist-cont-nonempty (car (nth 0 symbols)))
                )
           (apply orig-fun (list (cdr symbols)))
         (apply orig-fun args))))

(advice-add 'c-get-syntactic-indentation :around 'my-java-indent-lambda)

(add-hook 'java-mode-hook
          (lambda ()
            (abbrev-mode 0)
            (adaptive-wrap-prefix-mode)
            (setq adaptive-wrap-extra-indent 4)
            (c-set-offset 'arglist-intro '+)         ;; only 1 indent for multi-line args lists
            (c-set-offset 'arglist-cont-nonempty '+) ;; 0 fixes lambdas, but breaks normal arg lists.
            (c-set-offset 'arglist-close '0)         ;; Single closing paren on a line should line up
            (highlight-symbol-mode)
            (setq fill-column 130)                   ;; yes, looks worse on github, but, java.
            (setq whitespace-line-column 130)
            (setq c-basic-offset 4)
            (visual-line-mode)))

(add-hook 'scala-mode-hook
          (lambda ()
            (adaptive-wrap-prefix-mode)
            (setq adaptive-wrap-extra-indent 2)
            (setq outline-regexp "[ \t]*\\(def\\|if\\|class\\|object\\|case\\).*\\({\\|=>\\)$")
            (visual-line-mode)))

(require 'c-block-info-inline-mode)

(add-hook 'c++-mode-hook (lambda()
                           (c-set-offset 'substatement-open 0)
                           (c-set-offset 'template-args-cont '+)
                           (c-set-offset 'brace-list-intro '+)
                           (abbrev-mode 0)
                           (adaptive-wrap-prefix-mode)
                           (setq adaptive-wrap-extra-indent 2)
                           (c-block-info-inline-mode)
                           (visual-line-mode)
                           (lsp)))
(add-hook 'c-mode-hook (lambda()
                           (c-set-offset 'substatement-open 0)
                           (c-set-offset 'template-args-cont '+)
                           (c-set-offset 'brace-list-intro '+)
                           (abbrev-mode 0)
                           (adaptive-wrap-prefix-mode)
                           (setq adaptive-wrap-extra-indent 2)
                           (c-block-info-inline-mode)
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

;; Include recentf list in ido buffer switcher
(setq ido-use-virtual-buffers t)

(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)

(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-x v =") 'git-gutter:popup-hunk)
(global-set-key (kbd "C-x C-p") 'git-gutter:previous-hunk)
(global-set-key (kbd "C-x C-n") 'git-gutter:next-hunk)
(global-set-key (kbd "C-x v s") 'git-gutter:stage-hunk)
(global-set-key (kbd "C-x v k") 'git-gutter:revert-hunk)


;; dired: automatically move/copy to "other" pane's directory
(setq dired-dwim-target t)

;; Remember recently opened files
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

;; Auto-set git column to 72 for M-q
(use-package git-commit
  :preface
  (defun me/git-commit-set-fill-column ()
    (setq-local comment-auto-fill-only-comments nil)
    (setq fill-column 72))
  :config
  (advice-add 'git-commit-turn-on-auto-fill :before #'me/git-commit-set-fill-column)
  (add-hook 'git-commit-setup-hook 'git-commit-turn-on-flyspell)
  )

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

(unless (server-running-p) (server-start))

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
(define-key nxml-mode-map (kbd "<backtab>") 'hs-toggle-hiding)

;; customize hideshow ellipsis
(set-display-table-slot standard-display-table
                         'selective-display
                         (string-to-vector "…"))

;; also do the same when in whitespace-mode
(defun whitespace-change-ellipsis ()
  "Change ellipsis when used with `whitespace-mode'."
  (when buffer-display-table
    (set-display-table-slot buffer-display-table
                            'selective-display
                            (string-to-vector "…"))))
(add-hook 'whitespace-mode-hook #'whitespace-change-ellipsis)

;; customize the face as well
(defface hs-ellipsis
  '((((class color) (background light)) (:underline t))
    (((class color) (background dark)) (:underline t))
    (t (:underline t)))
  "Face for ellipsis in hideshow mode.")
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

;; customize whitespace mode display
(delight 'whitespace-mode (all-the-icons-material "space_bar") t)

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

(require 'org-expiry)

;; fontify inside org mode
(setq org-src-fontify-natively t)
(use-package htmlize)

;; https://emacs.stackexchange.com/questions/19344/why-does-xdg-open-not-work-in-eshell
(setq process-connection-type nil)

;; Hide leading stars
(setq org-startup-indented nil
      org-hide-leading-stars t)

(use-package org-bullets)

;; No whitespace mode for org mode (miscolours links and such)
(add-hook 'org-mode-hook '(lambda ()
                            (whitespace-mode -1)
                            (org-bullets-mode)))

;; Smart beginning and end of line for org mode
(setq org-special-ctrl-a/e t)

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

(use-package docker-tramp)

;; enable re-use of ssh connections
;; https://emacs.stackexchange.com/questions/22306/working-with-tramp-mode-on-slow-connection-emacs-does-network-trip-when-i-start
(setq tramp-ssh-controlmaster-options "")

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

(use-package smex
  :bind
  ("M-x" . smex)
  ("M-X" . smex-major-mode-commands)
  ("C-c C-o M-x" . execute-extended-command))

(require 'hide-lines)
(autoload 'hide-lines "hide-lines" "Hide lines based on a regexp" t)
(global-set-key "\C-ch" 'hide-lines)

(use-package super-save
  :config
  (super-save-mode 1)
  (setq super-save-remote-files nil)
  :delight)

(use-package yasnippet
  :config
  (yas-global-mode 1)
  (define-key yas-minor-mode-map (kbd "<tab>") nil)
  (define-key yas-minor-mode-map (kbd "TAB") nil)
  (define-key yas-minor-mode-map (kbd "C-t") #'yas-expand)
  :delight yas-minor-mode)

;; for snippets
(defun my/capitalize-first-char (&optional string)
  "Capitalize only the first character of the input STRING."
  (when (and string (> (length string) 0))
    (let ((first-char (substring string nil 1))
          (rest-str   (substring string 1)))
      (concat (capitalize first-char) rest-str))))

(use-package highlight-symbol
  :config
  (setq highlight-symbol-idle-delay 0.3)
  :delight )

(use-package treemacs)

(use-package lsp-mode
  :hook (scala-mode . lsp)
  :init (setq lsp-eldoc-render-all nil
              lsp-highlight-symbol-at-point nil
              lsp-prefer-flymake nil    ;; for metals, https://scalameta.org/metals/docs/editors/emacs.html
              lsp-inhibit-message t)
  )

(use-package company-lsp
  :after  company
  :config
  (setq company-lsp-cache-candidates t
        company-lsp-async t))

(use-package lsp-ui
  :config
  (setq lsp-ui-sideline-update-mode 'point)
  :bind (
         :map lsp-ui-mode-map
              ("C-c C-SPC" . lsp-execute-code-action)
              )
   )

(use-package lsp-java
  :config
  ;; Allow M-? to work , see https://github.com/emacs-lsp/lsp-java/issues/122
  (setq xref-prompt-for-identifier '(not xref-find-definitions
                                            xref-find-definitions-other-window
                                            xref-find-definitions-other-frame
                                            xref-find-references))

  (add-hook 'java-mode-hook
            (lambda ()
              (setq-local company-backends (list 'company-lsp))))

  (add-hook 'java-mode-hook 'lsp)
  (add-hook 'java-mode-hook 'flycheck-mode)
  (add-hook 'java-mode-hook 'company-mode)
  (add-hook 'java-mode-hook 'lsp-ui-mode))


(use-package dap-mode
  :after lsp-mode
  :config
  (dap-mode t)
  (dap-ui-mode t))

(use-package eyebrowse
  :init
  (eyebrowse-mode t)
  (eyebrowse-setup-opinionated-keys))

(use-package scad-mode)

(use-package adaptive-wrap)

(use-package ws-butler
  :delight)

(use-package dockerfile-mode)

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

(use-package company-emoji)

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
        ("C-." . find-file-at-point)))

(use-package smartparens
  :config
  (require 'smartparens-config))

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

;; Prog-mode defaults
(delight 'outline-minor-mode "" t)
(delight 'hs-minor-mode "" t)
(add-hook 'prog-mode-hook 'outline-minor-mode)
(add-hook 'prog-mode-hook 'hs-minor-mode)

(use-package pdf-tools
  :config
  ;; initialise
  (pdf-tools-install)
  ;; open pdfs scaled to fit page
  (setq-default pdf-view-display-size 'fit-page)
  ;; automatically annotate highlights
  (setq pdf-annot-activate-created-annotations t)
  ;; use normal isearch
  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward))

(use-package puppet-mode
  :pin melpa)

(add-to-list 'load-path "~/.emacs.d/kubectl/")
(require 'kubectl)

;; To edit code blacks in markdown
(use-package edit-indirect)

(use-package logview
  :pin melpa)

(use-package telega
  :commands (telega)
  :defer t)

(use-package plantuml-mode
  :config
  ;; plantuml is in standard arch repositories
  (setq plantuml-default-exec-mode 'executable)
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

;; Allow images to be zoomed in and out
(defun scale-image ()
  "Scale the image by the same factor specified by the text scaling."
  (image-transform-set-scale
   (expt text-scale-mode-step
         text-scale-mode-amount)))

(defun scale-image-register-hook ()
  "Register the image scaling hook."
  (add-hook 'text-scale-mode-hook 'scale-image))

(add-hook 'image-mode-hook 'scale-image-register-hook)
