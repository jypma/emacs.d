;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "magit" "20250729.2117"
  "A Git porcelain inside Emacs."
  '((emacs         "28.1")
    (compat        "30.1")
    (llama         "1.0.0")
    (magit-section "4.3.8")
    (seq           "2.24")
    (transient     "0.9.3")
    (with-editor   "3.4.4"))
  :url "https://github.com/magit/magit"
  :commit "0064a1601838a496d526834ba9b7a17f9f5ab01e"
  :revdesc "0064a1601838"
  :keywords '("git" "tools" "vc")
  :authors '(("Marius Vollmer" . "marius.vollmer@gmail.com")
             ("Jonas Bernoulli" . "emacs.magit@jonas.bernoulli.dev"))
  :maintainers '(("Jonas Bernoulli" . "emacs.magit@jonas.bernoulli.dev")
                 ("Kyle Meyer" . "kyle@kyleam.com")))
