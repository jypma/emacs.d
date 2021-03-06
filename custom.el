(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-auto-commit nil)
 '(company-auto-commit-chars '(119))
 '(company-auto-complete nil)
 '(company-auto-complete-chars '(119))
 '(company-idle-delay 0.3)
 '(company-lsp-enable-recompletion nil)
 '(company-show-numbers t)
 '(company-tooltip-align-annotations t)
 '(compilation-ask-about-save nil)
 '(compilation-auto-jump-to-first-error nil)
 '(compilation-scroll-output t)
 '(csv-align-max-width 20)
 '(csv-comment-start-default nil)
 '(csv-header-lines 1)
 '(custom-enabled-themes '(misterioso))
 '(dired-listing-switches "-al --quoting-style=literal")
 '(eyebrowse-new-workspace "*dashboard*")
 '(fill-column 110)
 '(flymake-no-changes-timeout 60)
 '(forge-topic-list-limit '(60 . 0))
 '(git-gutter:modified-sign "❚")
 '(git-gutter:update-interval 1)
 '(global-subword-mode t)
 '(global-whitespace-mode nil)
 '(highlight-indent-guides-auto-enabled nil)
 '(highlight-indent-guides-method 'bitmap)
 '(highlight-indent-guides-responsive 'top)
 '(ibuffer-projectile-prefix " ")
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(ispell-program-name "/usr/bin/hunspell")
 '(js-indent-level 2)
 '(json-reformat:indent-width 2)
 '(kubectl--known-namespaces
   '(("ISSGi-platform-prdev-cluster" "p2p-dev" "p2p-test" "common")))
 '(kubernetes-clean-up-interactive-exec-buffers nil)
 '(kubernetes-logs-arguments '("--tail=50"))
 '(kubernetes-poll-frequency 5)
 '(kubernetes-redraw-frequency 5)
 '(logview-additional-submodes
   '(("Akka logs"
      (format . "TIMESTAMP LEVEL [NAME]")
      (levels . "SLF4J")
      (timestamp "ISO 8601 datetime + millis")
      (aliases))))
 '(logview-additional-timestamp-formats nil)
 '(lsp-file-watch-threshold 10000)
 '(lsp-headerline-breadcrumb-enable nil)
 '(lsp-java-completion-favorite-static-members
   ["org.junit.Assert.*" "org.junit.Assume.*" "org.junit.jupiter.api.Assertions.*" "org.junit.jupiter.api.Assumptions.*" "org.junit.jupiter.api.DynamicContainer.*" "org.junit.jupiter.api.DynamicTest.*" "org.mockito.Mockito.*" "org.mockito.ArgumentMatchers.*" "org.mockito.Answers.*" "org.assertj.core.api.Assertions.*"])
 '(lsp-java-favorite-static-members
   '("org.junit.Assert.*" "org.junit.Assume.*" "java.util.concurrent.CompletableFuture.completedFuture" "io.vavr.control.Option.*"))
 '(lsp-java-format-settings-url "/home/jan/eclipse-format-jan.xml")
 '(lsp-java-save-action-organize-imports nil)
 '(lsp-java-vmargs
   '("-noverify" "-Xmx8G" "-XX:+UseG1GC" "-XX:+UseStringDeduplication"))
 '(lsp-keep-workspace-alive nil)
 '(lsp-metals-java-home "/usr/lib/jvm/java-8-openjdk")
 '(lsp-ui-doc-enable t)
 '(lsp-ui-doc-include-signature t)
 '(lsp-ui-doc-position 'top)
 '(lsp-ui-flycheck-enable t)
 '(lsp-ui-flycheck-list-position 'right)
 '(lsp-ui-peek-enable t)
 '(lsp-ui-sideline-enable nil)
 '(lsp-ui-sideline-ignore-duplicate t)
 '(lsp-ui-sideline-show-code-actions t)
 '(lsp-ui-sideline-show-hover nil)
 '(lsp-ui-sideline-show-symbol nil)
 '(magit-todos-auto-group-items 'always)
 '(magit-todos-branch-list nil)
 '(magit-todos-scanner nil)
 '(markdown-asymmetric-header t)
 '(markdown-code-lang-modes
   '(("ocaml" . tuareg-mode)
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
     ("xml" . xml-mode)))
 '(markdown-fontify-code-blocks-natively t)
 '(markdown-marginalize-headers nil)
 '(mu4e-attachment-dir "/home/jan/Downloads/")
 '(mu4e-compose-dont-reply-to-self t)
 '(mu4e-headers-fields
   '((:human-date . 12)
     (:flags . 6)
     (:mailing-list . 10)
     (:from . 22)
     (:size . 8)
     (:subject)))
 '(mu4e-use-fancy-chars t)
 '(network-stream-use-client-certificates t)
 '(nxml-slash-auto-complete-flag t)
 '(ordbog-ddocli-path "/home/jan/bin/ddo-cli/ddo.py")
 '(org-adapt-indentation ''headline-data)
 '(org-babel-java-command "java --enable-preview")
 '(org-babel-java-compiler "javac --enable-preview --release 15")
 '(org-babel-no-eval-on-ctrl-c-ctrl-c nil)
 '(org-beamer-theme "LightConsole")
 '(org-catch-invisible-edits 'smart)
 '(org-confirm-babel-evaluate nil)
 '(org-edit-src-content-indentation 0)
 '(org-hide-block-startup t)
 '(org-hide-emphasis-markers t)
 '(org-hide-leading-stars t)
 '(org-latex-active-timestamp-format "%s")
 '(org-latex-inactive-timestamp-format "%s")
 '(org-log-into-drawer t)
 '(org-startup-folded 'content)
 '(org-superstar-headline-bullets-list '(9673 8226 9702 10047))
 '(org-tree-slide-activate-message "Presentation started.")
 '(org-tree-slide-content-margin-top 1)
 '(org-tree-slide-fold-subtrees-skipped nil)
 '(org-tree-slide-heading-emphasis t)
 '(package-selected-packages
   '(org-gtd org transient org-caldav doom-modeline esup flymake-json org-superstar org-superstar-mode org-tree-slide emacs-scroll-on-jump daemons flycheck-rust cargo rust-mode toml-mode ibuffer-projectile lsp-metals emojify csv-mode highlight-indent-guides git-timemachine magit-todos hl-todo irony string-inflection platformio-mode restclient plantuml-mode telega org-plus-contrib org-expiry logview undo-tree auto-package-update forge puppet-mode bicycle calctex deadgrep dired-git-info pdf-tools dired-rainbow dired-collapse smartparens alert cquery emacs-cquery org-jira scad-mode lsp-mode scala-mode sbt-mode super-save visual-regexp company-emoji noccur ob-http dockerfile-mode diff-hl ws-butler adaptive-wrap flycheck yasnippet eyebrowse company ido-completing-read+ dap-mode lsp-ui company-lsp treemacs lsp-java kubernetes highlight-symbol focus-autosave-mode all-the-icons delight smex docker-tramp rainbow-mode flyspell-popup ensime git-auto-commit-mode evil-numbers ace-window framemove htmlize elfeed expand-region mu4e-alert dired-du edit-indirect flx-ido dashboard rainbow-delimiters ido-vertical-mode git-gutter eshell-bookmark which-key clang-format flycheck-rtags rtags magit json-mode markdown-mode groovy-mode ## yaml-mode use-package projectile))
 '(password-cache-expiry 600)
 '(plantuml-indent-level 2)
 '(restclient-content-type-modes
   '(("text/xml" . sgml-mode)
     ("text/plain" . text-mode)
     ("application/xml" . xml-mode)
     ("application/json" . js-mode)
     ("image/png" . image-mode)
     ("image/jpeg" . image-mode)
     ("image/jpg" . image-mode)
     ("image/gif" . image-mode)
     ("text/html" . html-mode)))
 '(safe-local-variable-values
   '((magit-todos-exclude-globs "elpa")
     (magit-todos-exclude-globs "navbi" "environment" "aks-common" "deployments" "p2p-coupa-ubl")
     (magit-todos-exclude-globs "navbi" "environment")
     (magit-todos-exclude-globs "navbi")
     (org-confirm-babel-evaluate)
     (eval setq gac-automatically-push-p 1)))
 '(scroll-error-top-bottom t)
 '(scroll-margin 7)
 '(scroll-preserve-screen-position t)
 '(show-paren-delay 0.1)
 '(show-paren-mode t)
 '(shr-use-colors nil)
 '(shr-use-fonts nil)
 '(tramp-histfile-override nil)
 '(tramp-remote-shell-executable "/bin/sh")
 '(visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))
 '(vr/match-separator-use-custom-face t)
 '(whitespace-display-mappings '((space-mark 160 [164] [95]) (tab-mark 9 [187 9] [92 9])))
 '(whitespace-line-column 110)
 '(whitespace-style
   '(face trailing tabs spaces lines-tail newline empty indentation space-after-tab space-before-tab space-mark tab-mark newline-mark)))

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
 '(fixed-pitch ((t (:height 0.84 :family "Iosevka"))))
 '(flymake-error ((t (:foreground "#8b0000" :box (:line-width 1 :color "#450000" :style released-button) :underline (:color "#5F0000" :style wave) :weight bold))))
 '(font-lock-comment-face ((t (:foreground "#888888" :slant italic))))
 '(font-lock-constant-face ((((class color) (min-colors 89)) (:foreground "#96CBFE"))))
 '(font-lock-doc-face ((t (:inherit font-lock-string-face :foreground "#FFF150"))))
 '(font-lock-string-face ((t (:foreground "#e67128" :slant italic))))
 '(font-lock-type-face ((t (:foreground "#75EE7B"))))
 '(font-lock-variable-name-face ((t (:foreground "#EBEB81"))))
 '(fringe ((t (:background "#000000"))))
 '(git-gutter:modified ((t (:inherit default :foreground "#629CE4" :weight bold))))
 '(highlight ((t (:background "#724F07"))))
 '(highlight-indent-guides-character-face ((t (:foreground "#3F3F3F"))))
 '(highlight-indent-guides-stack-character-face ((t (:foreground "#3F3F3F"))))
 '(highlight-indent-guides-top-character-face ((t (:foreground "#9D9A71"))))
 '(hl-line ((t (:background "#3d3708"))))
 '(hs-ellipsis ((t (:background "#00215D" :box (:line-width 1 :color "#6A85ED" :style pressed-button)))))
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
 '(markdown-bold-face ((t (:inherit bold :foreground "#ffffff"))))
 '(markdown-code-face ((t (:inherit (fixed-pitch font-lock-constant-face) :background "#1b2129"))))
 '(markdown-header-face-1 ((t (:inherit outline-1 :overline t))))
 '(markdown-header-face-2 ((t (:inherit outline-2 :overline t))))
 '(markdown-header-face-3 ((t (:inherit outline-3 :overline t))))
 '(markdown-header-face-4 ((t (:inherit outline-4))))
 '(markdown-header-face-5 ((t (:inherit outline-5))))
 '(markdown-pre-face ((t (:background "#1b2129"))))
 '(mode-line ((t (:background "#333333" :foreground "gold3" :box (:line-width -1 :color "gold4")))))
 '(mode-line-inactive ((t (:background "black" :foreground "dark gray" :box (:line-width -1 :color "LightSteelBlue4")))))
 '(mu4e-header-highlight-face ((t (:inherit region :underline t :weight bold))))
 '(mu4e-unread-face ((t (:inherit font-lock-keyword-face :weight bold))))
 '(org-block ((t (:inherit (shadow fixed-pitch) :background "#1b2129"))))
 '(org-code ((t (:inherit org-block))))
 '(org-date ((t (:inherit fixed-pitch :background "black" :foreground "Cyan" :box (:line-width 1 :color "#00455D") :underline nil))))
 '(org-done ((t (:foreground "#005617" :weight bold))))
 '(org-formula ((t (:inherit fixed-pitch :foreground "#73331A"))))
 '(org-level-1 ((t (:inherit org-tree-slide-heading-level-1-init))))
 '(org-level-2 ((t (:inherit org-tree-slide-heading-level-2-init))))
 '(org-level-3 ((t (:inherit org-tree-slide-heading-level-3-init))))
 '(org-level-4 ((t (:inherit org-tree-slide-heading-level-4-init))))
 '(org-meta-line ((t (:inherit font-lock-comment-face :foreground "#8A8460" :height 0.8))))
 '(org-superstar-item ((t (:inherit default :box (:line-width 4 :color "#000")))))
 '(org-table ((t (:inherit fixed-pitch :foreground "LightSkyBlue"))))
 '(org-todo ((t (:foreground "#DD3794" :weight bold))))
 '(org-tree-slide-header-overlay-face ((t (:background "#000000" :foreground "#d3d3d3" :weight bold :height 1.3))))
 '(org-tree-slide-heading-level-1 ((t (:inherit outline-1))))
 '(org-tree-slide-heading-level-2 ((t (:inherit outline-2))))
 '(org-verbatim ((t (:inherit markdown-code-face))))
 '(outline-1 ((t (:foreground "#A6EDEA" :weight bold :height 1.5))))
 '(outline-2 ((t (:foreground "#EEFFB3" :weight bold :height 1.4))))
 '(outline-3 ((t (:foreground "#A7E2A7" :weight bold :height 1.0))))
 '(outline-4 ((t (:foreground "#D987D8" :weight bold :height 1.0))))
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
 '(variable-pitch ((t (:height 1.3 :family "ETBembo"))))
 '(whitespace-indentation ((t (:foreground "firebrick"))))
 '(whitespace-line ((t (:background "#40002A"))))
 '(whitespace-space ((t (:foreground "#66CACC"))))
 '(whitespace-trailing ((t (:background "dark red")))))
