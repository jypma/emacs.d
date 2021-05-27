
;;; Code:
(require 'ob)
(require 'org-macs)

(add-to-list 'org-babel-tangle-lang-exts '("jshell" . "java"))
(add-to-list 'org-src-lang-modes '("jshell" . java))

(defun org-babel-execute:jshell (body params)
  "Execute a block of matlab code with JShell."
  (let* ((session (org-babel-jshell-initiate-session (cdr (assq :session params)) params))
         (result-type (cdr (assq :result-type params)))
         (full-body
          (replace-regexp-in-string "\n" " "
                                    (org-babel-expand-body:generic
                                     body params (org-babel-variable-assignments:jshell params))))
         (raw (org-babel-comint-with-output
	          (session org-babel-jshell-eoe t full-body)
                (insert (org-trim full-body))
                (comint-send-input nil t)
                (insert org-babel-jshell-eoe)
                (comint-send-input nil t)))
         (results (mapcar #'org-strip-quotes
		          (cdr (member org-babel-jshell-eoe
                                       (reverse (mapcar #'org-trim raw))))))
         ;; Remove leading and trailing newline
         (cleaned (replace-regexp-in-string "\n$\\|^\n" "" (mapconcat 'identity results "\n")))
         ;; JShell echoes a closing "}" as double "}}"
         ;;(expected-echo (replace-regexp-in-string "}" "}}" full-body))
         ;; JShell changes whitespace in echo, and eats a leading ";"
         (expected-echo-regex
          (replace-regexp-in-string ";" " *;"
                                    (replace-regexp-in-string "}" "}}?"
                                                              (replace-regexp-in-string ";$" ""
                                                                                        (replace-regexp-in-string " +" " +" (regexp-quote full-body))))))
         (withoutecho (replace-regexp-in-string expected-echo-regex "" cleaned 'literal)))

    ;; (message "full-body: %s" full-body)
    ;; (message "raw: %s" raw)
    ;; (message "results: %s" results)
    ;; (message "cleaned: %s" cleaned)
    ;; (message "expected echo: %s" expected-echo)
     (message "expected echo regex: %s" expected-echo-regex)
     (message "withoutecho: %s" withoutecho)

    withoutecho))

(defvar org-babel-jshell-eoe "\"org-babel-jshell-eoe\"")

(defun org-babel-variable-assignments:jshell (params)
  "Return list of jshell statements assigning the block's variables."
  (mapcar
   (lambda (pair)
     (format "var %s=%s;"
	     (car pair)
	     (org-babel-jshell-var-to-jshell (cdr pair))))
   (org-babel--get-vars params)))

(defun org-babel-jshell-var-to-jshell (var)
  "Convert an emacs-lisp value into a jshell variable.
Converts an emacs-lisp variable into a string of jshell code
specifying a variable of the same value."
  (if (listp var)
      (concat "java.util.List.of(" (mapconcat #'org-babel-jshell-var-to-jshell var ", ") ")")
    (cond
     ((stringp var)
      (format "\"%s\"" var))
     (t
      (format "%s" var)))))

(defun org-babel-jshell-initiate-session (session params)
  "Create an jshell inferior process buffer.
If there is not a current inferior-process-buffer in SESSION then
create.  Return the initialized session."
  ;; TODO default to current dir as jsnell buffer name
  (let ((session (format "*JShell:%s*" session)))
    (message "ses2: %s" session)
    (if (org-babel-comint-buffer-livep session) session
      (save-window-excursion
        (if (get-buffer session)
            (kill-buffer session))
        (org-babel-jshell-run session)
	(rename-buffer (if (bufferp session) (buffer-name session)
                         (if (stringp session) session (buffer-name))))
	(current-buffer)))))

(defun org-babel-jshell-command ()
  "Returns the jshell command and arguments, as a list"
  ;; TODO add "compile" first as option
  `("mvn" "com.github.johnpoth:jshell-maven-plugin:1.3:run" "-Djshell.options=-q,--no-startup" "-Djshell.scripts=/home/jan/.emacs.d/lisp/imports"))

(defun org-babel-jshell-run (session)
  (let ((command (org-babel-jshell-command)))
    ;; TODO: figure out the appropriate maven pom directory
    ;;  (setq default-directory inferior-haskell-root-dir))
    (switch-to-buffer
     (let ((comint-terminfo-terminal "dumb"))
       (apply 'make-comint session (car command) nil (cdr command)))))
  (setq comint-use-prompt-regexp t)
  (setq comint-prompt-regexp "jshell> \\|\\$[0-9]+ ==> ")
  (setq comint-process-echoes t)
  (org-babel-comint-wait-for-output (buffer-name))

  )

(provide 'ob-jshell)
