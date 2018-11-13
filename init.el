
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(setq package-archive-ties '(("melpa-stable" . 1)))
(add-to-list 'load-path "~/.emacs.d/lisp/")

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

(require 'whitespace)
(add-hook 'prog-mode-hook #'whitespace-mode)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (misterioso)))
 '(dired-listing-switches "-al --quoting-style=literal")
 '(fill-column 110)
 '(git-gutter:update-interval 1)
 '(global-subword-mode t)
 '(global-whitespace-mode nil)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(lsp-java-format-settings-url "/home/jan/eclipse-format-jan.xml")
 '(lsp-java-save-action-organize-imports nil)
 '(lsp-ui-flycheck-list-position (quote right))
 '(lsp-ui-peek-enable t)
 '(lsp-ui-sideline-enable t)
 '(lsp-ui-sideline-ignore-duplicate t)
 '(lsp-ui-sideline-show-code-actions t)
 '(lsp-ui-sideline-show-hover nil)
 '(lsp-ui-sideline-show-symbol nil)
 '(markdown-code-lang-modes
   (quote
    (("ocaml" . tuareg-mode)
     ("elisp" . emacs-lisp-mode)
     ("ditaa" . artist-mode)
     ("asymptote" . asy-mode)
     ("dot" . fundamental-mode)
     ("sqlite" . sql-mode)
     ("calc" . fundamental-mode)
     ("C" . c-mode)
     ("cpp" . c++-mode)
     ("C++" . c++-mode)
     ("screen" . shell-script-mode)
     ("shell" . sh-mode)
     ("bash" . sh-mode)
     ("xml" . xml-mode))))
 '(markdown-fontify-code-blocks-natively t)
 '(nxml-slash-auto-complete-flag t)
 '(org-log-into-drawer t)
 '(package-selected-packages
   (quote
    (ido-completing-read+ dap-mode lsp-ui company-lsp treemacs lsp-java kubernetes highlight-symbol focus-autosave-mode all-the-icons delight smex docker-tramp rainbow-mode flyspell-popup ensime git-auto-commit-mode evil-numbers undo-tree cyberpunk-theme ace-window framemove htmlize elfeed expand-region mu4e-alert dired-du edit-indirect flx-ido dashboard rainbow-delimiters ido-vertical-mode git-gutter eshell-bookmark which-key clang-format flycheck-rtags rtags magit json-mode markdown-mode smart-shift groovy-mode ## yaml-mode puppet-mode use-package projectile)))
 '(safe-local-variable-values (quote ((eval setq gac-automatically-push-p 1))))
 '(show-paren-delay 0.1)
 '(show-paren-mode t)
 '(visual-line-fringe-indicators (quote (left-curly-arrow right-curly-arrow)))
 '(whitespace-display-mappings
   (quote
    ((space-mark 160
                 [164]
                 [95])
     (tab-mark 9
               [187 9]
               [92 9]))))
 '(whitespace-line-column 110))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((((class color) (min-colors 89)) (:foreground "#d3d3d3" :background "#000000"))))
 '(ensime-implicit-highlight ((t (:underline "dim gray"))))
 '(hl-line ((t (:background "#3d3708"))))
 '(lsp-ui-sideline-code-action ((t (:foreground "#808346"))))
 '(lsp-ui-sideline-global ((t (:foreground "burlywood"))))
 '(magit-section-highlight ((t (:background "#1c1c1c"))))
 '(markdown-code-face ((t (:inherit (fixed-pitch font-lock-constant-face) :background "#1b2129"))))
 '(markdown-pre-face ((t (:inherit fixed-pitch :background "#1b2129"))))
 '(mode-line ((t (:background "#333333" :foreground "gold3" :box (:line-width -1 :color "gold4")))))
 '(mode-line-inactive ((t (:background "black" :foreground "dark gray" :box (:line-width -1 :color "LightSteelBlue4")))))
 '(rainbow-delimiters-depth-1-face ((t (:foreground "#FF5555"))))
 '(rainbow-delimiters-depth-2-face ((t (:foreground "#02B602"))))
 '(rainbow-delimiters-depth-6-face ((t (:foreground "#79C8E1"))))
 '(rainbow-delimiters-depth-8-face ((t (:foreground "#998EDB"))))
 '(rainbow-delimiters-unmatched-face ((t (:inherit rainbow-delimiters-base-face :background "#88090B"))))
 '(region ((t (:background "#5b3636"))))
 '(shadow ((t (:foreground "grey70"))))
 '(whitespace-space ((t nil)))
 '(whitespace-trailing ((t (:background "dark red")))))

(tool-bar-mode -1)

;; magit default to origin/master instead of just master
(setq magic-prefer-remote-upstream 1)

;; Use pretty symbols everywhere
(global-prettify-symbols-mode 1)

;; Use pretty symbols in scala
(add-hook 'scala-mode-hook (lambda ()
                             (setq prettify-symbols-alist scala-prettify-symbols-alist)
                             (prettify-symbols-mode)))
(setq prettify-symbols-unprettify-at-point 'right-edge)

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

;; don't show subword mode in modeline
(delight 'subword-mode nil t)

;; icons for major modes
(use-package all-the-icons
  :ensure t)
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

;; highlight #ff etc as actual colors
(use-package rainbow-mode
  :ensure t
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

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(use-package projectile
  :ensure t
  :init (projectile-global-mode)
  :config
  (defadvice projectile-on (around exlude-tramp activate)
  "This should disable projectile when visiting a remote file"
  (unless  (--any? (and it (file-remote-p it))
                   (list
                    (buffer-file-name)
                    list-buffers-directory
                    default-directory
                    dired-directory))
    ad-do-it))
  (setq projectile-switch-project-action #'projectile-dired)
  :delight '(:eval (concat " " (projectile-project-name) "  ")))

(use-package goto-addr
  :ensure t
  :hook ((compilation-mode . goto-address-mode)
         (prog-mode . goto-address-prog-mode)
         (eshell-mode . goto-address-mode)
         (shell-mode . goto-address-mode))
  :commands (goto-address-prog-mode
             goto-address-mode))

(use-package ensime
  :ensure t
  :pin melpa-stable
  :config
  (setq ensime-startup-notification nil))

(use-package magit
  :ensure t
  :pin melpa-stable
  :config
  (setq magit-list-refs-sortby "-creatordate")
  ;; Hide "Recent Commits"
  ;; https://github.com/magit/magit/issues/3230
  (magit-add-section-hook 'magit-status-sections-hook
                          'magit-insert-unpushed-to-upstream
                          'magit-insert-unpushed-to-upstream-or-recent
                          'replace))

(use-package sbt-mode
  :ensure t
  :pin melpa)

(use-package scala-mode
  :ensure t
  :pin melpa)

(use-package company
  :ensure t
  :init (global-company-mode)
  :config (progn
            (setq company-idle-delay 0.2
                  company-minimum-prefix-length 1)
            ;; Don't use company mode in eshell (since tramp gets really slow)
            (setq company-global-modes '(not eshell-mode))
            (add-hook 'after-init-hook 'global-company-mode))
  :delight company-mode "  ")

;; Completions + lots of IDE features with RTags
(use-package rtags
  :ensure t
  :config (progn
            (setq rtags-use-ivy t
                  rtags-completions-enabled t)
            (push 'company-rtags company-backends))
  (rtags-enable-standard-keybindings)
  (define-key c++-mode-map (kbd "M-.") 'rtags-find-symbol-at-point)
  (define-key c++-mode-map (kbd "M-,") 'rtags-location-stack-back) )

;; Error checking with flycheck-rtags as a backend
(use-package flycheck
  :ensure t
  :config (progn
            (add-hook 'c++-mode-hook 'flycheck-mode)
            (add-hook 'c-mode-hook 'flycheck-mode))
  :delight flycheck-mode "  ")

(use-package flycheck-rtags :ensure t)

(defun my-flycheck-rtags-setup ()
  (flycheck-select-checker 'rtags)
  (setq-local flycheck-highlighting-mode nil)
  (setq-local flycheck-check-syntax-automatically nil))
(add-hook 'c-mode-hook #'my-flycheck-rtags-setup)
(add-hook 'c++-mode-hook #'my-flycheck-rtags-setup)

(use-package cyberpunk-theme
  :ensure t
  :config
  (load-theme 'cyberpunk t)
  (set-cursor-color "#ffffff") ;; somehow not all frames have superwhite cursor by default
  (set-face-attribute 'region nil :foreground 'unspecified)
  (set-face-attribute 'whitespace-line nil :background 'unspecified))

;; Format files consistently
(use-package clang-format
  :ensure t)

(use-package which-key
  :ensure t
  :config
  (which-key-mode)
  :delight which-key-mode)

(use-package eshell-bookmark
  :ensure t
  :config
  (add-hook 'eshell-mode-hook 'eshell-bookmark-setup))

(use-package ido-vertical-mode
  :ensure t
  :init (ido-vertical-mode 1))

(use-package ido-completing-read+
  :ensure t
  :init (ido-ubiquitous-mode 1))

(use-package rainbow-delimiters
  :ensure t
  :config
  :config
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
)

;; show usage in dired: C-x M-r, toggle display with C-x C-h
(use-package dired-du
  :ensure t)

;; open file in dired into desktop, mpv, etc.
(defun dired-open-file ()
  "In dired, open the file named on this line."
  (interactive)
  (let* ((file (dired-get-filename nil t)))
    (call-process "xdg-open" nil 0 nil file)))
(define-key dired-mode-map (kbd "C-c o") 'dired-open-file)

(use-package expand-region
  :ensure t
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
    :ensure t
    :after mu4e
    :init
    (mu4e-alert-enable-mode-line-display)
    (mu4e-alert-set-default-style 'libnotify)
    (mu4e-alert-enable-notifications)))

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
                scala-mode-hook
                java-mode-hook))
  (add-hook mode
            '(lambda ()
               (flyspell-prog-mode))))
(add-hook 'markdown-mode-hook (lambda () (flyspell-mode)))
(add-hook 'java-mode-hook (lambda () (flyspell-prog-mode)))

;; use popup menu for completions instead of strange top-of-buffer selector
(use-package flyspell-popup
  :ensure t
  :config
;;  (add-hook 'flyspell-mode-hook #'flyspell-popup-auto-correct-mode) ;; don't like it after all
  (define-key flyspell-mode-map (kbd "C-;") #'flyspell-popup-correct))

;; customize minor mode display for flyspell-mode
(delight 'flyspell-mode "   " t)

(use-package git-gutter
  :ensure t
  :config
  (global-git-gutter-mode +1)
  (custom-set-variables
   '(git-gutter:update-interval 1))
  :delight)

(use-package dashboard
  :ensure t
  :config
  (global-set-key (kbd "<f5>") (lambda () (interactive) (switch-to-buffer "*dashboard*")))
  (dashboard-setup-startup-hook)
  (setq dashboard-items '((recents  . 25)
                          (bookmarks . 5)
                          (projects . 25))))

(use-package flx-ido
  :ensure t
  :config 
  (ido-mode 1)
  (ido-everywhere 1)
  (flx-ido-mode 1)
  (setq ido-enable-flex-matching t)
  (setq ido-use-faces nil) ;; to see flx highlights
)

;; Better window switching with M-o (also across frames)
(use-package ace-window
  :ensure t
  :bind ("M-o" . ace-window))

(when (file-exists-p "~/.emacs.d/jira.el")
  (use-package org-jira
    :ensure t
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
  (string-match-p (regexp-quote "Android") (shell-command-to-string "uname -o")))

(use-package elfeed
  :ensure t
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

(global-smart-shift-mode 1)
(setq column-number-mode t)
(setq backup-directory-alist `(("." . "~/.saves")))
(setq delete-old-versions t
  kept-new-versions 6
  kept-old-versions 2
  version-control t)


(use-package highlight-symbol
  :ensure t
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
            (c-set-offset 'arglist-intro '+)         ;; only 1 indent for multi-line args lists
            (c-set-offset 'arglist-cont-nonempty '+) ;; 0 fixes lambdas, but breaks normal arg lists.
            (highlight-symbol-mode)
            (setq c-basic-offset 4)))

(add-hook 'c++-mode-hook (lambda()
                           (abbrev-mode 0)))

(require 'protobuf-mode)

(defconst my-protobuf-style
  '((c-basic-offset . 4)
    (indent-tabs-mode . nil)))

(add-hook 'protobuf-mode-hook
  (lambda () (c-add-style "my-style" my-protobuf-style t)))

(electric-pair-mode 1)

(global-set-key (kbd "C-x b") 'ibuffer)

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
  :ensure t
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

;; fontify inside org mode
(setq org-src-fontify-natively t)
(use-package htmlize :ensure t)

;; https://emacs.stackexchange.com/questions/19344/why-does-xdg-open-not-work-in-eshell
(setq process-connection-type nil)

;; Hide leading stars
(setq org-startup-indented t org-hide-leading-stars t)

;; No whitespace mode for org mode (miscolours links and such)
(add-hook 'org-mode-hook '(lambda () (whitespace-mode -1)))


;; Unbind Ctrl-Z to not minimize emacs in UI mode
(global-unset-key [(control z)])
(global-unset-key [(control x)(control z)])

;; UTF-8 support
(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

(use-package undo-tree
  :ensure t
  :config
  (global-undo-tree-mode 1)
  :delight)

(use-package evil-numbers
  :ensure t
  :bind
  ("C-c =" . evil-numbers/inc-at-pt)
  ("<kp-add>" . evil-numbers/inc-at-pt)
  ("C-c -" . evil-numbers/dec-at-pt)
  ("<kp-subtract>" . evil-numbers/dec-at-pt))

(use-package docker-tramp
  :ensure t)

;; auto-commit used for org todo list sync
(use-package git-auto-commit-mode
  :ensure t)

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
  :ensure t
  :bind
  ("M-x" . smex)
  ("M-X" . smex-major-mode-commands)
  ("C-c C-o M-x" . execute-extended-command))

(require 'hide-lines)
(autoload 'hide-lines "hide-lines" "Hide lines based on a regexp" t)
(global-set-key "\C-ch" 'hide-lines)

(use-package focus-autosave-mode
  :ensure t
  :config
  (focus-autosave-mode)
  :delight)

(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1)
  :delight yas-minor-mode)

(use-package highlight-symbol
  :ensure t
  :config
  (setq highlight-symbol-idle-delay 0.3)
  :delight )

(use-package kubernetes
  :ensure t
  :commands (kubernetes-overview))


(use-package treemacs
  :ensure t)

(use-package lsp-mode
  :ensure t
  :init (setq lsp-eldoc-render-all nil
              lsp-highlight-symbol-at-point nil
              lsp-inhibit-message t)
  )

(use-package company-lsp
  :after  company
  :ensure t
  :config
  (setq company-lsp-cache-candidates t
        company-lsp-async t))

(use-package lsp-ui
  :ensure t
  :config
  (setq lsp-ui-sideline-update-mode 'point)
  :bind (
         :map lsp-ui-mode-map
              ("C-c SPC" . lsp-execute-code-action)
              )
   )

(use-package lsp-java
  :ensure t
  :config
  (add-hook 'java-mode-hook
            (lambda ()
              (setq-local company-backends (list 'company-lsp))))

  (add-hook 'java-mode-hook 'lsp-java-enable)
  (add-hook 'java-mode-hook 'flycheck-mode)
  (add-hook 'java-mode-hook 'company-mode)
  (add-hook 'java-mode-hook 'lsp-ui-mode))

(use-package dap-mode
  :ensure t
  :after lsp-mode
  :config
  (dap-mode t)
  (dap-ui-mode t))

(use-package dap-java
  :after (lsp-java))

(use-package lsp-java-treemacs
  :after (treemacs))
