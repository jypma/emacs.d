
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

(require 'whitespace)
(add-hook 'prog-mode-hook #'whitespace-mode)

(load "~/.emacs.d/setup-ligatures.el")

(require 'thread-dump)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-auto-complete nil)
 '(company-auto-complete-chars (quote (32 95 40 41 46)))
 '(company-idle-delay 0.3)
 '(company-lsp-enable-recompletion nil)
 '(company-show-numbers t)
 '(company-tooltip-align-annotations t)
 '(compilation-ask-about-save nil)
 '(compilation-auto-jump-to-first-error nil)
 '(compilation-scroll-output t)
 '(custom-enabled-themes (quote (misterioso)))
 '(dired-listing-switches "-al --quoting-style=literal")
 '(eyebrowse-new-workspace "*dashboard*")
 '(fill-column 110)
 '(flymake-no-changes-timeout 60)
 '(git-gutter:update-interval 1)
 '(global-subword-mode t)
 '(global-whitespace-mode nil)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(js-indent-level 2)
 '(json-reformat:indent-width 2)
 '(kubernetes-clean-up-interactive-exec-buffers nil)
 '(kubernetes-logs-arguments (quote ("--tail=50")))
 '(kubernetes-poll-frequency 5)
 '(kubernetes-redraw-frequency 5)
 '(lsp-java-favorite-static-members
   (quote
    ("org.junit.Assert.*" "org.junit.Assume.*" "java.util.concurrent.CompletableFuture.completedFuture" "io.vavr.control.Option.*")))
 '(lsp-java-format-settings-url "/home/jan/eclipse-format-jan.xml")
 '(lsp-java-save-action-organize-imports nil)
 '(lsp-java-vmargs
   (quote
    ("-noverify" "-Xmx8G" "-XX:+UseG1GC" "-XX:+UseStringDeduplication" "-Djavax.net.ssl.keyStore=/home/jan/.ssh/jyp.p12" "-Djavax.net.ssl.keyStoreType=pkcs12" "-Djavax.net.ssl.keyStorePassword=csvfiles")))
 '(lsp-keep-workspace-alive nil)
 '(lsp-ui-doc-enable t)
 '(lsp-ui-doc-include-signature t)
 '(lsp-ui-doc-position (quote top))
 '(lsp-ui-flycheck-enable t)
 '(lsp-ui-flycheck-list-position (quote right))
 '(lsp-ui-peek-enable t)
 '(lsp-ui-sideline-enable nil)
 '(lsp-ui-sideline-ignore-duplicate t)
 '(lsp-ui-sideline-show-code-actions t)
 '(lsp-ui-sideline-show-hover nil)
 '(lsp-ui-sideline-show-symbol nil)
 '(magithub-issue-sort-function (quote magithub-issue-sort-descending))
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
    (deadgrep dired-git-info pdf-tools dired-rainbow dired-collapse smartparens alert cquery emacs-cquery org-jira scad-mode lsp-mode scala-mode sbt-mode super-save visual-regexp slack company-emoji noccur ob-http dockerfile-mode diff-hl ws-butler adaptive-wrap flycheck yasnippet eyebrowse company ido-completing-read+ dap-mode lsp-ui company-lsp treemacs lsp-java kubernetes highlight-symbol focus-autosave-mode all-the-icons delight smex docker-tramp rainbow-mode flyspell-popup ensime git-auto-commit-mode evil-numbers ace-window framemove htmlize elfeed expand-region mu4e-alert dired-du edit-indirect flx-ido dashboard rainbow-delimiters ido-vertical-mode git-gutter eshell-bookmark which-key clang-format flycheck-rtags rtags magit json-mode markdown-mode groovy-mode ## yaml-mode use-package projectile)))
 '(password-cache-expiry 600)
 '(safe-local-variable-values
   (quote
    ((org-confirm-babel-evaluate)
     (eval setq gac-automatically-push-p 1))))
 '(scroll-error-top-bottom t)
 '(scroll-margin 7)
 '(scroll-preserve-screen-position t)
 '(show-paren-delay 0.1)
 '(show-paren-mode t)
 '(tramp-histfile-override nil)
 '(tramp-remote-shell-executable "/bin/sh")
 '(visual-line-fringe-indicators (quote (left-curly-arrow right-curly-arrow)))
 '(vr/match-separator-use-custom-face t)
 '(whitespace-display-mappings
   (quote
    ((space-mark 160
                 [164]
                 [95])
     (tab-mark 9
               [187 9]
               [92 9]))))
 '(whitespace-line-column 110)
 '(whitespace-style
   (quote
    (face trailing tabs spaces lines-tail newline empty indentation space-after-tab space-before-tab space-mark tab-mark newline-mark))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((((class color) (min-colors 89)) (:foreground "#d3d3d3" :background "#000000" :family "Iosevka" :slant normal :weight normal :height 98 :width normal))))
 '(diff-hl-change ((t (:background "#FFA060" :foreground "#000000"))))
 '(diff-hl-dired-unknown ((t (:inherit dired-ignored :background "#3CD681" :foreground "#000000"))))
 '(dired-rainbow-directory-face ((t (:foreground "#EB6C88" :weight bold))))
 '(ensime-implicit-highlight ((t (:underline "dim gray"))))
 '(eyebrowse-mode-line-active ((t (:inherit mode-line-emphasis :underline t))))
 '(fixed-pitch ((t (:family "Iosevka"))))
 '(flymake-error ((t (:foreground "#8b0000" :box (:line-width 1 :color "#450000" :style released-button) :underline (:color "#5F0000" :style wave) :weight bold))))
 '(font-lock-comment-face ((t (:foreground "#888888" :slant italic))))
 '(font-lock-constant-face ((((class color) (min-colors 89)) (:foreground "#96CBFE"))))
 '(font-lock-doc-face ((t (:inherit font-lock-string-face :foreground "#FFF150"))))
 '(font-lock-string-face ((t (:foreground "#e67128" :slant italic))))
 '(font-lock-type-face ((t (:foreground "#75EE7B"))))
 '(font-lock-variable-name-face ((t (:foreground "#EBEB81"))))
 '(highlight ((t (:box (:line-width 1 :color "#03686D" :style released-button)))))
 '(hl-line ((t (:background "#3d3708"))))
 '(italic ((t (:slant italic))))
 '(kubernetes-progress-indicator ((t (:foreground "#40E974"))))
 '(lsp-ui-doc-header ((t (:background "#5D5FB1" :foreground "black"))))
 '(lsp-ui-sideline-code-action ((t (:foreground "#808346"))))
 '(lsp-ui-sideline-global ((t (:foreground "burlywood"))))
 '(magit-mode-line-process ((t (:foreground "#74E815" :weight bold))))
 '(magit-section-highlight ((t (:background "#1c1c1c"))))
 '(markdown-code-face ((t (:inherit (fixed-pitch font-lock-constant-face) :background "#1b2129"))))
 '(markdown-header-face-1 ((t (:inherit markdown-header-face :height 1.3))))
 '(markdown-header-face-2 ((t (:foreground "spring green" :weight bold :height 1.2))))
 '(markdown-header-face-3 ((t (:inherit markdown-header-face :foreground "lemon chiffon" :height 1.0))))
 '(markdown-pre-face ((t (:inherit fixed-pitch :background "#1b2129"))))
 '(mode-line ((t (:background "#333333" :foreground "gold3" :box (:line-width -1 :color "gold4")))))
 '(mode-line-inactive ((t (:background "black" :foreground "dark gray" :box (:line-width -1 :color "LightSteelBlue4")))))
 '(rainbow-delimiters-depth-1-face ((t (:foreground "#FF5555"))))
 '(rainbow-delimiters-depth-2-face ((t (:foreground "#02B692"))))
 '(rainbow-delimiters-depth-5-face ((t (:foreground "#00FFC7"))))
 '(rainbow-delimiters-depth-6-face ((t (:foreground "#79C8E1"))))
 '(rainbow-delimiters-depth-8-face ((t (:foreground "#998EDB"))))
 '(rainbow-delimiters-unmatched-face ((t (:inherit rainbow-delimiters-base-face :background "#88090B"))))
 '(region ((t (:background "#5b3636"))))
 '(shadow ((t (:foreground "grey70"))))
 '(term-color-red ((t (:background "#8c5353" :foreground "#FF0000"))))
 '(whitespace-line ((t (:background "#40002A"))))
 '(whitespace-space ((t (:background "#000000" :foreground "#66CACC"))))
 '(whitespace-trailing ((t (:background "dark red")))))

(set-face-attribute 'highlight nil :foreground 'unspecified)
(set-face-attribute 'highlight nil :background 'unspecified)

(tool-bar-mode -1)

(defun my/fontify-frame (frame)
  (interactive)
  (if window-system
      (progn
        (if (> (x-display-pixel-width) 2000)
            (set-frame-parameter frame 'font "Iosevka 14") ;; HIDPI
         (set-frame-parameter frame 'font "Iosevka 10")))))

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

(use-package delight
  :ensure t)

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

(require 'uuidgen)

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
  :bind-keymap (("C-c p" . projectile-command-map))

  :config
  (setq projectile-switch-project-action #'projectile-dired)

  (advice-add 'projectile-project-root :around (lambda (orig-fun &optional dir)
                                                 (let ((dir (file-truename (or dir default-directory))))
                                                   (unless (file-remote-p dir)
                                                     (funcall orig-fun dir)))))

  :delight '(:eval (concat " " (projectile-project-name) "  ")))

(use-package goto-addr
  :ensure t
  :hook ((compilation-mode . goto-address-mode)
         (prog-mode . goto-address-prog-mode)
         (eshell-mode . goto-address-mode)
         (shell-mode . goto-address-mode))
  :commands (goto-address-prog-mode
             goto-address-mode))

(use-package magit
  :ensure t
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

(use-package magithub
  :ensure t
  :after magit
  :after transient
  :config
  (magithub-feature-autoinject t)
  (setq magithub-clone-default-directory "~/workspace"))

(use-package sbt-mode
  :ensure t
  :pin melpa
  :commands sbt-start sbt-command
  :config
  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
  ;; allows using SPACE when in the minibuffer
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map))

(use-package scala-mode
  :ensure t
  :mode "\\.s\\(cala\\|bt\\)$"
  :pin melpa)

(use-package company-emoji
  :ensure t)

(use-package company
  :ensure t
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

  ;; Company appears to override the above keymap based on company-auto-complete-chars.
  ;; Turning it off ensures we have full control.
  (setq company-auto-complete-chars nil)

  :bind ("C-<tab>" . 'company-complete)
  :delight company-mode "  ")


;; Error checking with flycheck-rtags as a backend
(use-package flycheck
  :ensure t
  :delight flycheck-mode "  ")

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

;; auto-save bookmarks
(setq bookmark-save-flag 1)

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

;; Press ) in dired will show git annotations for each dir + file
(package-install-file "~/.emacs.d/lisp/dired-git-info.el")
(with-eval-after-load 'dired
  (define-key dired-mode-map ")" 'dired-git-info-mode))

;; show usage in dired: C-x M-r, toggle display with C-x C-h
(use-package dired-du
  :ensure t)

;; auto-collapse directories in dired
(use-package dired-collapse
  :ensure t
  :config
  (add-hook 'dired-mode-hook 'dired-collapse-mode))

;; more colors in dired
(use-package dired-rainbow
  :ensure t
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
                protobuf-mode-hook
                javascript-mode-hook
                groovy-mode-hook
                java-mode-hook))
  (add-hook mode #'flyspell-prog-mode)
  (add-hook mode #'ws-butler-mode))

(add-hook 'markdown-mode-hook (lambda ()
                                (setq company-idle-delay 1.0)
                                (ws-butler-mode)
                                (visual-line-mode)
                                (flyspell-mode)))

;; use popup menu for completions instead of strange top-of-buffer selector
(use-package flyspell-popup
  :ensure t
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
  :ensure t
  :config
  (global-git-gutter-mode +1)
  (custom-set-variables
   '(git-gutter:update-interval 1))
  :delight)

(use-package diff-hl
  :ensure t
  ;; only for dired, we use git-gutter for normal files
  :config
  (add-hook 'dired-mode-hook #'diff-hl-dired-mode-unless-remote))

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
  (or
   (string-match-p (regexp-quote "Android") (shell-command-to-string "uname -o"))
   (string-match-p (regexp-quote "lineageOS") (shell-command-to-string "uname -a"))))

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
      "https://www.youtube.com/feeds/videos.xml?channel_id=UCqeg5vkTkH-DYxmOO9FJOHA" ;; Ardour
      "https://www.youtube.com/feeds/videos.xml?channel_id=UCkqe4BYsllmcxo2dsF-rFQw" ;; Bruce Williams Photography
      "https://www.youtube.com/feeds/videos.xml?channel_id=UCr-cm90DwFJC0W3f9jBs5jA" ;; EEVBlog channel 2
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

(add-hook 'c++-mode-hook (lambda()
                           (c-set-offset 'substatement-open 0)
                           (c-set-offset 'brace-list-intro '+)
                           (abbrev-mode 0)))

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

;; use python with babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)))

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

;; Unbind Ctrl-T since it's annoying (swaps last two characters)
(global-unset-key [(control t)])

;; UTF-8 support
(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

(use-package evil-numbers
  :ensure t
  :bind
  ("C-c =" . evil-numbers/inc-at-pt)
  ("<kp-add>" . evil-numbers/inc-at-pt)
  ("C-c -" . evil-numbers/dec-at-pt)
  ("<kp-subtract>" . evil-numbers/dec-at-pt))

(use-package docker-tramp
  :ensure t)

;; enable re-use of ssh connections
;; https://emacs.stackexchange.com/questions/22306/working-with-tramp-mode-on-slow-connection-emacs-does-network-trip-when-i-start
(setq tramp-ssh-controlmaster-options "")

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

(use-package super-save
  :ensure t
  :config
  (super-save-mode 1)
  (setq super-save-remote-files nil)
  :delight)

(use-package yasnippet
  :ensure t
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
  :ensure t
  :config
  (setq highlight-symbol-idle-delay 0.3)
  :delight )

(use-package kubernetes
  :ensure t)
;;  :commands (kubernetes-overview))

(require 'kubernetes-tramp)
(kubernetes-tramp-define-method "sand" "sand" "default")
(kubernetes-tramp-define-method "prod" "prod" "default")
(kubernetes-tramp-define-method "smok" "smoketest" "smoketest")

(use-package treemacs
  :ensure t)

(use-package lsp-mode
  :ensure t
  :hook (scala-mode . lsp)
  :init (setq lsp-eldoc-render-all nil
              lsp-highlight-symbol-at-point nil
              lsp-prefer-flymake nil    ;; for metals, https://scalameta.org/metals/docs/editors/emacs.html
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
              ("C-c C-SPC" . lsp-execute-code-action)
              )
   )

(use-package lsp-java
  :ensure t
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
  :ensure t
  :after lsp-mode
  :config
  (dap-mode t)
  (dap-ui-mode t))

(use-package dap-java
  :after (lsp-java))

(use-package lsp-java-treemacs
  :after (treemacs))

(use-package eyebrowse
  :ensure t
  :init
  (eyebrowse-mode t)
  (eyebrowse-setup-opinionated-keys))

(use-package scad-mode
  :ensure t)

(use-package adaptive-wrap
  :ensure t)

(use-package ws-butler
  :ensure t
  :delight)

(use-package dockerfile-mode
  :ensure t)

(use-package ob-http
  :ensure t
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (http . t))))

;; Easily search through the content of files marked in a dired buffer using occur mode
(use-package noccur
  :ensure t
  :after projectile
  :bind
  ("C-c o" . 'noccur-project))

(use-package company-emoji
  :ensure t)

(use-package alert
  :ensure t
  :commands (alert)
  :init
  (setq alert-default-style 'notifier))

(use-package slack
  :ensure t
  :init
  (setq slack-buffer-emojify t) ;; if you want to enable emoji, default nil
  (setq slack-prefer-current-team t))

(use-package visual-regexp
  :ensure t
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
  (prettify-symbols-mode t))

(add-hook 'compilation-mode-hook 'my-compilation-mode-prettify)

;; bloop parse support for compilation mode
(add-to-list 'compilation-error-regexp-alist-alist
             '(bloop
               "\\[.+\\] \\([^\n:]+\\):\\([0-9]+\\):\\([0-9]+\\)"
               1 2 3))

(add-to-list 'compilation-error-regexp-alist 'bloop)

(use-package cquery
  :ensure t
  :config
  (setq cquery-executable "/usr/bin/cquery")
  (add-hook 'c++-mode-hook 'lsp)
  (add-hook 'c-mode-hook 'lsp))

(use-package yaml-mode
  :ensure t)

(use-package smartparens
  :ensure t
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
  :ensure t
  :after outline
  :bind (:map outline-minor-mode-map
              ([backtab] . bicycle-cycle)
              ([C-iso-lefttab] . bicycle-cycle-global)))

(use-package prog-mode
  :config
  (delight 'outline-minor-mode)
  (delight 'hs-minor-mode "" t)
  (add-hook 'prog-mode-hook 'outline-minor-mode)
  (add-hook 'prog-mode-hook 'hs-minor-mode))

(use-package pdf-tools
  :ensure t
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
  :ensure t)

(require 'kubectl)
