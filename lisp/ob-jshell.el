
;;; Code:
(require 'ob)
(require 'org-macs)

(add-to-list 'org-babel-tangle-lang-exts '("jshell" . "java"))
(add-to-list 'org-src-lang-modes '("jshell" . java))

;; Tweaked to allow arbitrary output until a timeout (JShell is a mess)
(defmacro jshell-org-babel-comint-with-output (meta &rest body)
  "Evaluate BODY in BUFFER and return process output.
Will wait until EOE-INDICATOR appears in the output, then return
all process output.  If REMOVE-ECHO and FULL-BODY are present and
non-nil, then strip echo'd body from the returned output.  META
should be a list containing the following where the last two
elements are optional.

 (BUFFER EOE-INDICATOR REMOVE-ECHO FULL-BODY)

This macro ensures that the filter is removed in case of an error
or user `keyboard-quit' during execution of body."
  (declare (indent 1))
  (let ((buffer (nth 0 meta))
	(eoe-indicator (nth 1 meta))
	(remove-echo (nth 2 meta))
	(full-body (nth 3 meta)))
    `(org-babel-comint-in-buffer ,buffer
       (let* ((string-buffer "")
	      (comint-output-filter-functions
	       (cons (lambda (text) (setq string-buffer (concat string-buffer text)))
		     comint-output-filter-functions))
	      dangling-text)
	 ;; got located, and save dangling text
	 (goto-char (process-mark (get-buffer-process (current-buffer))))
	 (let ((start (point))
	       (end (point-max)))
	   (setq dangling-text (buffer-substring start end))
	   (delete-region start end))
	 ;; pass FULL-BODY to process
	 ,@body
	 ;; wait for end-of-evaluation indicator
         (setq jshell-initial-size (buffer-size (current-buffer)))
         (message "Size starts at %d" jshell-initial-size)
         (setq jshell-last-size 0)
	 (while (progn
		  (goto-char comint-last-input-end)
		  (not (save-excursion
			 (or  (re-search-forward
			       (regexp-quote ,eoe-indicator) nil t)
			      (re-search-forward
			       comint-prompt-regexp nil t)
                              (and (not (= jshell-last-size jshell-initial-size))
                                   (= jshell-last-size (buffer-size (current-buffer))))))))
           (setq jshell-last-size (buffer-size (current-buffer)))
           (message "Size now %d" jshell-last-size)
           (message "Waiting for %s or %s from %s" (regexp-quote ,eoe-indicator) comint-prompt-regexp comint-last-input-end)
	   (accept-process-output (get-buffer-process (current-buffer)) 0.5)
	   ;; thought the following this would allow async
	   ;; background running, but I was wrong...
	   ;; (run-with-timer .5 .5 'accept-process-output
	   ;; 		 (get-buffer-process (current-buffer)))
	   )
	 ;; replace cut dangling text
	 (goto-char (process-mark (get-buffer-process (current-buffer))))
	 (insert dangling-text)

	 ;; remove echo'd FULL-BODY from input
	 (when (and ,remove-echo ,full-body
		    (string-match
		     (replace-regexp-in-string
		      "\n" "[\r\n]+" (regexp-quote (or ,full-body "")))
		     string-buffer))
	   (setq string-buffer (substring string-buffer (match-end 0))))
	 (split-string string-buffer comint-prompt-regexp)))))

(defun org-babel-execute:jshell (body params)
  "Execute a block of java code with JShell."
  (let* ((session (org-babel-jshell-initiate-session (cdr (assq :session params)) params))
         (result-type (cdr (assq :result-type params)))
         (full-body (org-babel-expand-body:generic body params (org-babel-variable-assignments:jshell params)))

         (results (jshell-org-babel-comint-with-output (session "jshell> ")
                (insert (format "%s\n" (org-trim full-body)))
                (comint-send-input nil t)
                ))
         ;;(lines (split-string full-body "\n"))
         ;;(results (mapcar (lambda (line) (org-babel-jshell-line session line)) lines))
         (result (org-trim (string-join results "\n")))
         )

         ;; (raw (org-babel-comint-with-output
	 ;;          (session org-babel-jshell-eoe t full-body)
         ;;        (insert (org-trim full-body))
         ;;        (comint-send-input nil t)
         ;;        (insert org-babel-jshell-eoe)
         ;;        (comint-send-input nil t)))
         ;; (results (mapcar #'org-strip-quotes
	 ;;                  (cdr (member org-babel-jshell-eoe
         ;;                               (reverse (mapcar #'org-trim raw))))))
         ;; Remove leading and trailing newline
         ;; (cleaned (replace-regexp-in-string "\n$\\|^\n" "" (mapconcat 'identity results "\n"))) ;
         ;; JShell echoes a closing "}" as double "}}"
         ;;(expected-echo (replace-regexp-in-string "}" "}}" full-body))
         ;; JShell changes whitespace in echo, and eats a leading ";"
         ;; (expected-echo-regex
         ;;  (replace-regexp-in-string ";" " *;"
         ;;                            (replace-regexp-in-string "}" "}}?"
         ;;                                                      (replace-regexp-in-string ";$" ""
         ;;                                                                                (replace-regexp-in-string " +" " +" (regexp-quote full-body))))))
         ;; (withoutecho (replace-regexp-in-string expected-echo-regex "" cleaned 'literal)))

    ;; (message "full-body: %s" full-body)
    ;; (message "raw: %s" raw)
    ;; (message "results: %s" results)
    ;; (message "cleaned: %s" cleaned)
    ;; (message "expected echo: %s" expected-echo)
     ;; (message "expected echo regex: %s" expected-echo-regex)
     ;; (message "withoutecho: %s" withoutecho)

         (message "results: %s" results)
         (message "result: %s" result)
    result))

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
  `("mvn" "test-compile" "com.github.johnpoth:jshell-maven-plugin:1.3:run" "-Djshell.options=-q,--no-startup" "-Djshell.scripts=/home/jan/.emacs.d/lisp/imports"))

(defun org-babel-jshell-run (session)
  (let ((command (org-babel-jshell-command))
        (process-environment (cons "JAVA_HOME=/usr/lib/jvm/java-17-jdk/" process-environment)))
    ;; TODO: figure out the appropriate maven pom directory
    ;;  (setq default-directory inferior-haskell-root-dir))
    (switch-to-buffer
     (let ((comint-terminfo-terminal "dumb"))
       (apply 'make-comint session (car command) nil (cdr command)))))
  (setq comint-use-prompt-regexp t)
;;  (setq comint-prompt-regexp "jshell> \\|\\$[0-9]+ ==> \\|\\.\\.\\.>")
  (setq comint-prompt-regexp "jshell> \\|\\$[0-9]+ ==> ")
  (setq comint-process-echoes t)
  (org-babel-comint-wait-for-output (buffer-name)))

(provide 'ob-jshell)
