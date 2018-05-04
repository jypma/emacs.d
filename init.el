(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(setq package-archive-prioritities '(("melpa-stable" . 1)))

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(require 'whitespace)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (misterioso)))
 '(fill-column 110)
 '(git-gutter:update-interval 1)
 '(global-subword-mode t)
 '(global-whitespace-mode t)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
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
 '(package-selected-packages
   (quote
    (cyberpunk-theme ace-window framemove htmlize elfeed expand-region mu4e-alert dired-du edit-indirect flx-ido dashboard rainbow-delimiters ido-vertical-mode git-gutter eshell-bookmark which-key clang-format flycheck-rtags rtags magit meghanada json-mode markdown-mode smart-shift groovy-mode ## yaml-mode puppet-mode use-package projectile)))
 '(show-paren-delay 0.1)
 '(show-paren-mode t)
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
 '(hl-line ((t (:background "#3d3708"))))
 '(magit-section-highlight ((t (:background "#1c1c1c"))))
 '(markdown-code-face ((t (:inherit (fixed-pitch font-lock-constant-face) :background "#333e4c"))))
 '(markdown-pre-face ((t (:inherit fixed-pitch :background "#333e4c"))))
 '(mode-line ((t (:background "#333333" :foreground "gold3" :box (:line-width -1 :color "gold4")))))
 '(mode-line-inactive ((t (:background "black" :foreground "dark gray" :box (:line-width -1 :color "LightSteelBlue4")))))
 '(region ((t (:background "#5b3636"))))
 '(whitespace-space ((t nil))))

(tool-bar-mode -1)

;; Use pretty symbols everywhere
(global-prettify-symbols-mode 1)

;; Use pretty symbols in scala
(add-hook 'scala-mode-hook (lambda ()
                             (setq prettify-symbols-alist scala-prettify-symbols-alist)
                             (prettify-symbols-mode)))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(use-package projectile
  :ensure t
  :init (projectile-global-mode))

(use-package ensime
  :ensure t
  :pin melpa)

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
            (add-hook 'after-init-hook 'global-company-mode)))

;; Completions + lots of IDE features with RTags
(use-package rtags
  :ensure t
  :config (progn
            (setq rtags-use-ivy t
                  rtags-completions-enabled t)
            (push 'company-rtags company-backends)))
(rtags-enable-standard-keybindings)

;; Error checking with flycheck-rtags as a backend
(use-package flycheck
  :ensure t
  :config (progn
            (add-hook 'c++-mode-hook 'flycheck-mode)
            (add-hook 'c-mode-hook 'flycheck-mode)))

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
  :ensure t)
(which-key-mode)

(use-package eshell-bookmark
  :ensure t
  :config
  (add-hook 'eshell-mode-hook 'eshell-bookmark-setup))

(use-package ido-vertical-mode
  :ensure t
  :init (ido-vertical-mode 1))

(use-package rainbow-delimiters
  :ensure t
  :init (rainbow-delimiters-mode 1))

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
  (load "~/.emacs.d/mu4e.el")
  (use-package mu4e-alert
    :ensure t
    :after mu4e
    :init
    (mu4e-alert-enable-mode-line-display)
    (mu4e-alert-set-default-style 'libnotify)
    (mu4e-alert-enable-notifications)))

;; Ctrl+A in eshell moves to beginning of command, then to real beginning of line
(defun eshell-maybe-bol ()
  (interactive)
  (let ((p (point)))
    (eshell-bol)
    (if (= p (point))
        (beginning-of-line))))
(add-hook 'eshell-mode-hook
          '(lambda () (define-key eshell-mode-map "\C-a" 'eshell-maybe-bol)))

(use-package git-gutter
  :ensure t
  :config
  (global-git-gutter-mode +1)
  (custom-set-variables
   '(git-gutter:update-interval 1)))

(use-package dashboard
  :ensure t
  :config
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
      "https://www.youtube.com/feeds/videos.xml?channel_id=UCjYVl9n1Giijx3spfuOO-zw"
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
          (elfeed-play-with-mpv)
        (if (eq major-mode 'elfeed-search-mode)
            (elfeed-search-browse-url)
          (elfeed-show-visit)))))

  (define-key elfeed-search-mode-map (kbd "RET") 'elfeed-visit-or-play-with-mpv))

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

(global-smart-shift-mode 1)
(setq column-number-mode t)
(setq backup-directory-alist `(("." . "~/.saves")))
(setq delete-old-versions t
  kept-new-versions 6
  kept-old-versions 2
  version-control t)

(require 'meghanada)
(add-hook 'java-mode-hook
          (lambda ()
            ;; Uncomment to auto-start meghanada when opening java file
            ;; (meghanada-mode t) 
            (setq c-basic-offset 4)))

(require 'protobuf-mode)

(defconst my-protobuf-style
  '((c-basic-offset . 4)
    (indent-tabs-mode . nil)))

(add-hook 'protobuf-mode-hook
  (lambda () (c-add-style "my-style" my-protobuf-style t)))

(electric-pair-mode 1)

(global-set-key (kbd "C-x b") 'ibuffer)
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
  (advice-add 'git-commit-turn-on-auto-fill :before #'me/git-commit-set-fill-column))

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
  (if buffer-read-only
    (whitespace-mode -1)
    (whitespace-mode nil)))
(add-hook 'find-file-hook 'my/read-only-whitespace)
(add-hook 'read-only-mode-hook 'my/read-only-whitespace)
;; (add-hook 'post-command-hook 'my/read-only-whitespace) ;; <-- too slow, can't navigate C++

;; save the clipboard into the kill ring before killing
(setq save-interprogram-paste-before-kill t)

;; use postgresql with babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((sql . t)
   (sh . t)))

;; fontify inside org mode
(setq org-src-fontify-natively t)
(use-package htmlize :ensure t)

;; https://emacs.stackexchange.com/questions/19344/why-does-xdg-open-not-work-in-eshell
(setq process-connection-type nil)

;; Unbind Ctrl-Z to not minimize emacs in UI mode
(global-unset-key [(control z)])
(global-unset-key [(control x)(control z)])

;; UTF-8 support
(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))
