;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "forge" "20241018.1648"
  "Access Git forges from Magit."
  '((emacs         "27.1")
    (compat        "30.0.0.0")
    (closql        "2.0.0")
    (dash          "2.19.1")
    (emacsql       "4.0.3")
    (ghub          "4.1.1")
    (let-alist     "1.0.6")
    (magit         "4.1.1")
    (markdown-mode "2.6")
    (seq           "2.24")
    (transient     "0.7.6")
    (yaml          "0.5.5"))
  :url "https://github.com/magit/forge"
  :commit "9f2efc3c03719af60be6f9da2835336aedb522be"
  :revdesc "9f2efc3c0371"
  :keywords '("git" "tools" "vc")
  :authors '(("Jonas Bernoulli" . "emacs.forge@jonas.bernoulli.dev"))
  :maintainers '(("Jonas Bernoulli" . "emacs.forge@jonas.bernoulli.dev")))
