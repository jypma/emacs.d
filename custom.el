(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(adaptive-fill-mode t)
 '(custom-enabled-themes '(dark))
 '(custom-safe-themes
   '("50a808e6ffedc0abfad25e11a6208c158df1dc68f1d3cd9d0624afa1ef546838" "3b71d9d8571b0199bf420371f38248cbc5dc934e55f3f32cce9ecb04b97ed881" "85fd51046e93893b286e413c897852e7a6fcbb0ce9e5ba04e87db3a12da075db" "b878c14a064b9dc4624dbb3c8eda465eed89b538d713a8e9c9eb2ee05227a134" default))
 '(git-gutter:update-interval 1)
 '(js-indent-level 2)
 '(lsp-java-completion-favorite-static-members
   ["org.junit.Assert.*" "org.junit.Assume.*" "org.junit.jupiter.api.Assertions.*" "org.junit.jupiter.api.Assumptions.*" "org.junit.jupiter.api.DynamicContainer.*" "org.junit.jupiter.api.DynamicTest.*" "org.mockito.Mockito.*" "org.mockito.ArgumentMatchers.*" "org.mockito.Answers.*" "org.assertj.core.api.Assertions.*"])
 '(lsp-java-configuration-maven-default-mojo-execution-action "execute")
 '(lsp-java-eclipse-download-sources t)
 '(lsp-java-favorite-static-members
   '("org.junit.Assert.*" "org.junit.Assume.*" "java.util.concurrent.CompletableFuture.completedFuture" "io.vavr.control.Option.*"))
 '(lsp-java-format-settings-url "/home/jan/.emacs.d/eclipse-format-jan.xml")
 '(lsp-java-jdt-download-url
   "https://www.eclipse.org/downloads/download.php?file=/jdtls/milestones/1.41.0/jdt-language-server-1.41.0-202410311350.tar.gz")
 '(lsp-java-maven-download-sources t)
 '(lsp-java-save-action-organize-imports nil)
 '(lsp-java-vmargs
   '("-javaagent:/home/jan/.cache/lombok.jar" "-noverify" "-Xmx8G" "-XX:+UseG1GC" "-XX:+UseStringDeduplication" "-DtolerateIllegalAmbiguousVarargsInvocation=true"))
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
     ("js" . javascript-mode)
     ("json" . js-json-mode)))
 '(markdown-fontify-code-blocks-natively t)
 '(nxml-slash-auto-complete-flag t)
 '(org-adapt-indentation ''headline-data)
 '(org-agenda-files '("~/Nextcloud/journal/20230425"))
 '(org-babel-java-command "java --enable-preview")
 '(org-babel-java-compiler "javac --enable-preview --release 17")
 '(org-babel-no-eval-on-ctrl-c-ctrl-c nil)
 '(org-beamer-theme "LightConsole")
 '(org-catch-invisible-edits 'smart)
 '(org-confirm-babel-evaluate nil)
 '(org-cycle-hide-block-startup nil)
 '(org-edit-src-content-indentation 0)
 '(org-fold-catch-invisible-edits 'smart)
 '(org-fontify-done-headline nil)
 '(org-footnote-define-inline t)
 '(org-hide-block-startup nil)
 '(org-hide-emphasis-markers t)
 '(org-hide-leading-stars t)
 '(org-icalendar-alarm-time 15)
 '(org-journal-dir "~/Nextcloud/journal/")
 '(org-journal-file-type 'daily)
 '(org-journal-find-file 'find-file)
 '(org-journal-find-file-fn 'find-file)
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
   '(eglot-java ligatures ligature yasnippet lsp-metals scala-mode yaml-mode dired-rainbow dired-collapse dired-du rainbow-delimiters edit-indirect adaptive-wrap visual-regexp git-gutter rainbow-mode lsp-mode org-appear org-superstar htmlize org-journal mu4e-alert hl-todo magit-todos git-timemachine forge magit lsp-ui ws-butler expand-region dashboard orderless vertico marginalia consult which-key lsp-java company))
 '(project-vc-ignores '("target" "target-ide"))
 '(safe-local-variable-values
   '((magit-todos-exclude-globs "elpa")
     (eval outline-hide-sublevels 1)))
 '(whitespace-line-column 110)
 '(whitespace-style
   '(face trailing tabs lines-tail newline missing-newline-at-eof empty space-after-tab space-before-tab tab-mark))
 '(world-clock-list
   '(("UTC" "UTC")
     ("Europe/Copenhagen" "Copenhagen")
     ("Europe/Kiev" "Kiev")
     ("Asia/Kuala_Lumpur" "Kuala Lumpur")
     ("Australia/Brisbane" "Brisbane"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(flymake-error ((t (:box (:line-width (1 . 1) :color "#450000" :style released-button) :underline (:color "#5F0000" :style wave :position nil) :weight bold))))
 '(org-tag ((t (:background "dark khaki" :foreground "black" :box (:line-width (2 . 2) :color "DarkGoldenrod3" :style released-button) :weight bold)))))
