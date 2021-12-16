(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#2d3743" "#ff4242" "#74af68" "#dbdb95" "#34cae2" "#008b8b" "#00ede1" "#e1e1e0"])
 '(auth-source-save-behavior nil)
 '(company-auto-commit nil)
 '(company-auto-commit-chars '(119))
 '(company-auto-complete nil)
 '(company-auto-complete-chars '(119))
 '(company-idle-delay 0.3)
 '(company-lsp-enable-recompletion nil)
 '(company-show-numbers t)
 '(company-show-quick-access t)
 '(company-tooltip-align-annotations t)
 '(compilation-ask-about-save nil)
 '(compilation-auto-jump-to-first-error nil)
 '(compilation-scroll-output t)
 '(csv-align-max-width 20)
 '(csv-comment-start-default nil)
 '(csv-header-lines 1)
 '(custom-enabled-themes '(dark))
 '(custom-safe-themes
   '("b878c14a064b9dc4624dbb3c8eda465eed89b538d713a8e9c9eb2ee05227a134" "072b4bed0714912511330a3df481f8cafc37503465a4094908af9361577e9ae4" "89c29d889a0bade1bf7979bb602c3f27c1db2e2036b296abd63e079589daa2d9" "b4d6a42be9eae8619b280d0155697b43d0774e5bdedad0ea01de63b996c91eb9" "03f59154b9915f3e7ea3f570c91884f13c7cad7cf7f8a5dd2220d436a940c658" "4d565f25c6480cc3e6aed8aeb70ba777caff40e416586b3ee483ec91ae9d528c" default))
 '(dired-listing-switches "-al --quoting-style=literal")
 '(docker-tramp-use-names t)
 '(eyebrowse-new-workspace "*dashboard*")
 '(fill-column 110)
 '(flymake-no-changes-timeout 60)
 '(forge-topic-list-limit '(60 . 0))
 '(git-gutter:modified-sign "❚")
 '(git-gutter:update-interval 1)
 '(global-subword-mode t)
 '(global-whitespace-mode nil)
 '(gnus-article-date-headers '(combined-local-lapsed))
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
 '(lsp-java-java-path "/usr/lib/jvm/java-17-jdk/bin/java")
 '(lsp-java-save-action-organize-imports nil)
 '(lsp-java-vmargs
   '("-noverify" "-Xmx8G" "-XX:+UseG1GC" "-XX:+UseStringDeduplication"))
 '(lsp-keep-workspace-alive nil)
 '(lsp-metals-java-home "/usr/lib/jvm/java-11-openjdk")
 '(lsp-ui-doc-enable t)
 '(lsp-ui-doc-include-signature t)
 '(lsp-ui-doc-position 'top)
 '(lsp-ui-flycheck-enable t)
 '(lsp-ui-flycheck-list-position 'right)
 '(lsp-ui-peek-enable t)
 '(lsp-ui-sideline-diagnostic-max-lines 7)
 '(lsp-ui-sideline-enable nil)
 '(lsp-ui-sideline-ignore-duplicate t)
 '(lsp-ui-sideline-show-code-actions t)
 '(lsp-ui-sideline-show-hover nil)
 '(lsp-ui-sideline-show-symbol nil)
 '(lsp-xml-validation-resolve-external-entities t)
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
 '(org-babel-java-compiler "javac --enable-preview --release 17")
 '(org-babel-no-eval-on-ctrl-c-ctrl-c nil)
 '(org-beamer-theme "LightConsole")
 '(org-catch-invisible-edits 'smart)
 '(org-confirm-babel-evaluate nil)
 '(org-edit-src-content-indentation 0)
 '(org-fontify-done-headline nil)
 '(org-hide-block-startup nil)
 '(org-hide-emphasis-markers t)
 '(org-hide-leading-stars t)
 '(org-latex-active-timestamp-format "%s")
 '(org-latex-inactive-timestamp-format "%s")
 '(org-log-into-drawer t)
 '(org-startup-folded 'content)
 '(org-superstar-headline-bullets-list '(9673 8226 9702 10047))
 '(org-tree-slide-activate-message "Presentation started.")
 '(org-tree-slide-content-margin-top 1)
 '(org-tree-slide-cursor-init nil)
 '(org-tree-slide-fold-subtrees-skipped nil)
 '(org-tree-slide-heading-emphasis t)
 '(org-tree-slide-heading-level-1 '(outline-1 bold))
 '(org-tree-slide-heading-level-2 '(outline-2 bold))
 '(org-tree-slide-heading-level-3 '(outline-3 bold))
 '(org-tree-slide-heading-level-4 '(outline-4 bold))
 '(package-selected-packages
   '(marginalia consult orderless vertico log4j-mode gdscript-mode org-gtd org transient org-caldav doom-modeline esup flymake-json org-superstar org-superstar-mode org-tree-slide emacs-scroll-on-jump daemons flycheck-rust cargo rust-mode toml-mode ibuffer-projectile lsp-metals emojify csv-mode highlight-indent-guides git-timemachine magit-todos hl-todo irony string-inflection platformio-mode restclient plantuml-mode telega org-plus-contrib org-expiry logview undo-tree auto-package-update forge puppet-mode bicycle calctex deadgrep dired-git-info pdf-tools dired-rainbow dired-collapse smartparens alert cquery emacs-cquery org-jira scad-mode lsp-mode scala-mode sbt-mode super-save visual-regexp company-emoji noccur ob-http dockerfile-mode diff-hl ws-butler adaptive-wrap flycheck yasnippet eyebrowse company ido-completing-read+ dap-mode lsp-ui company-lsp treemacs lsp-java kubernetes highlight-symbol focus-autosave-mode all-the-icons delight smex docker-tramp rainbow-mode flyspell-popup ensime git-auto-commit-mode evil-numbers ace-window framemove htmlize elfeed expand-region mu4e-alert dired-du edit-indirect flx-ido dashboard rainbow-delimiters ido-vertical-mode git-gutter eshell-bookmark which-key clang-format flycheck-rtags rtags magit json-mode markdown-mode groovy-mode ## yaml-mode use-package projectile))
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
 '(savehist-file "~/.cache/emacs-history")
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
 '(flycheck-warning ((t (:underline "chocolate")))))
