;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "alert" "20221213.1619"
  "Growl-style notification system for Emacs."
  '((gntp   "0.1")
    (log4e  "0.3.0")
    (cl-lib "0.5"))
  :url "https://github.com/jwiegley/alert"
  :commit "c762380ff71c429faf47552a83605b2578656380"
  :revdesc "c762380ff71c"
  :keywords '("notification" "emacs" "message")
  :authors '(("John Wiegley" . "jwiegley@gmail.com"))
  :maintainers '(("John Wiegley" . "jwiegley@gmail.com")))
