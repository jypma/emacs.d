(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-auto-complete nil)
 '(company-auto-complete-chars (quote (119)))
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
 '(forge-topic-list-limit (quote (60 . 0)))
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
 '(logview-additional-submodes
   (quote
    (("Akka logs"
      (format . "TIMESTAMP LEVEL [NAME]")
      (levels . "SLF4J")
      (timestamp "ISO 8601 datetime + millis")
      (aliases)))))
 '(logview-additional-timestamp-formats nil)
 '(lsp-file-watch-threshold 10000)
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
    (plantuml-mode telega org-plus-contrib org-expiry logview undo-tree auto-package-update forge puppet-mode bicycle calctex deadgrep dired-git-info pdf-tools dired-rainbow dired-collapse smartparens alert cquery emacs-cquery org-jira scad-mode lsp-mode scala-mode sbt-mode super-save visual-regexp company-emoji noccur ob-http dockerfile-mode diff-hl ws-butler adaptive-wrap flycheck yasnippet eyebrowse company ido-completing-read+ dap-mode lsp-ui company-lsp treemacs lsp-java kubernetes highlight-symbol focus-autosave-mode all-the-icons delight smex docker-tramp rainbow-mode flyspell-popup ensime git-auto-commit-mode evil-numbers ace-window framemove htmlize elfeed expand-region mu4e-alert dired-du edit-indirect flx-ido dashboard rainbow-delimiters ido-vertical-mode git-gutter eshell-bookmark which-key clang-format flycheck-rtags rtags magit json-mode markdown-mode groovy-mode ## yaml-mode use-package projectile)))
 '(password-cache-expiry 600)
 '(plantuml-indent-level 2)
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
 '(company-preview ((t (:background "#292500"))))
 '(company-tooltip ((t (:background "#2B2A00"))))
 '(company-tooltip-selection ((t (:background "#1F1F00"))))
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
 '(highlight ((t (:background "#724F07"))))
 '(hl-line ((t (:background "#3d3708"))))
 '(italic ((t (:slant italic))))
 '(kubernetes-progress-indicator ((t (:foreground "#40E974"))))
 '(logview-information-entry ((t (:background "#022502"))))
 '(logview-timestamp ((t (:inherit font-lock-builtin-face :overline t :underline nil))))
 '(logview-warning-entry ((t (:background "#221900"))))
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
 '(org-block ((t (:inherit shadow :background "#1b2129"))))
 '(outline-4 ((t (:foreground "#D987D8"))))
 '(rainbow-delimiters-depth-1-face ((t (:foreground "#FF5555"))))
 '(rainbow-delimiters-depth-2-face ((t (:foreground "#02B692"))))
 '(rainbow-delimiters-depth-3-face ((t (:inherit rainbow-delimiters-base-face :foreground "#F0BA6D"))))
 '(rainbow-delimiters-depth-5-face ((t (:foreground "#00FFC7"))))
 '(rainbow-delimiters-depth-6-face ((t (:foreground "#79C8E1"))))
 '(rainbow-delimiters-depth-7-face ((t (:inherit rainbow-delimiters-base-face :foreground "#DE56C5"))))
 '(rainbow-delimiters-depth-8-face ((t (:foreground "#998EDB"))))
 '(rainbow-delimiters-unmatched-face ((t (:inherit rainbow-delimiters-base-face :background "#88090B"))))
 '(region ((t (:background "#5b3636"))))
 '(shadow ((t (:foreground "grey70"))))
 '(show-paren-match ((t (:background "#4C7E28"))))
 '(term-color-red ((t (:background "#8c5353" :foreground "#FF0000"))))
 '(whitespace-line ((t (:background "#40002A"))))
 '(whitespace-space ((t (:foreground "#66CACC"))))
 '(whitespace-trailing ((t (:background "dark red")))))
