;; https://emacs.stackexchange.com/questions/12235/edit-file-as-root-over-when-already-using-tramp
(defun my/edit-file-as-root ()
  "Open the current file as root"
  (interactive)
  (let*
    ((sudo (/= (call-process "sudo" nil nil "-n true") 0))
      (file-name
        (if (tramp-tramp-file-p buffer-file-name)
          (with-parsed-tramp-file-name buffer-file-name parsed
            (tramp-make-tramp-file-name
              (if sudo "sudo" "su")
              "root"
              parsed-host
              parsed-localname
              (let ((tramp-postfix-host-format "|")
                     (tramp-prefix-format))
                (tramp-make-tramp-file-name
                  parsed-method
                  parsed-user
                  parsed-host
                  ""
                  parsed-hop))))
          (concat (if sudo
                    "/sudo::"
                    "/su::")
            buffer-file-name))))
    (find-alternate-file file-name)))  

;; https://www.reddit.com/r/emacs/comments/5pziif/cd_to_home_directory_of_server_when_using_eshell/
(defun eshell/lcd (&optional directory)
  "Change directory relative to the current TRAMP remote host"
  (if (file-remote-p default-directory)
      (with-parsed-tramp-file-name default-directory nil
        (eshell/cd (tramp-make-tramp-file-name
                    (tramp-file-name-method v)
                    (tramp-file-name-user v)
                    (tramp-file-name-host v)
                    (or directory "")
                    (tramp-file-name-hop v))))
    (eshell/cd directory)))

(defun eshell/lsu ()
  "Become root through sudo on the current TRAMP remote host or local"
  (let*
      ((sudo (/= (call-process "sudo" nil nil "-n true") 0))
       (newdir
        (if (tramp-tramp-file-p default-directory)
            (with-parsed-tramp-file-name default-directory parsed
              (if (string= "sudo" parsed-method)
                  ;;remove sudo, remove leading "|" from hop
                  (concat "/" (substring parsed-hop 0 -1) ":" parsed-localname)
                ;; add sudo
                (tramp-make-tramp-file-name
                 (if sudo "sudo" "su")
                 "root"
                 parsed-host
                 parsed-localname
                 (let ((tramp-postfix-host-format "|")
                       (tramp-prefix-format))
                   (tramp-make-tramp-file-name
                    parsed-method
                    parsed-user
                    parsed-host
                    ""
                    parsed-hop)))
                )

              )
          (concat (if sudo
                      "/sudo::"
                    "/su::")
                  default-directory))))
    (message "cd %s" newdir)
    (eshell/cd newdir)))

;; http://www.howardism.org/Technical/Emacs/eshell-present.html
(defun eshell/-buffer-as-args (buffer separator command)
  "Takes the contents of BUFFER, and splits it on SEPARATOR, and
runs the COMMAND with the contents as arguments. Use an argument
`%' to substitute the contents at a particular point, otherwise,
they are appended."
  (let* ((lines (with-current-buffer buffer
                  (split-string
                   (buffer-substring-no-properties (point-min) (point-max))
                   separator)))
         (subcmd (if (-contains? command "%")
                     (-flatten (-replace "%" lines command))
                   (-concat command lines)))
         (cmd-str  (string-join subcmd " ")))
    (message cmd-str)
    (eshell-command-result cmd-str)))

(defun eshell/bargs (buffer &rest command)
  "Passes the lines from BUFFER as arguments to COMMAND."
  (eshell/-buffer-as-args buffer "\n" command))

(defun eshell/sargs (buffer &rest command)
  "Passes the words from BUFFER as arguments to COMMAND."
  (eshell/-buffer-as-args buffer nil command))


(require 'cl-lib)
(defun my/similar-buffers ()
  "Returns similar buffers to the current one, e.g. living on different remote servers."
  (if (tramp-tramp-file-p buffer-file-name)
      (let* ((current-localname (with-parsed-tramp-file-name buffer-file-name parsed
                                  parsed-localname)))
        (cl-remove-if-not
         (lambda (buf)
           (let ((otherfile (buffer-file-name buf)))
             (cond ((string= otherfile buffer-file-name) nil)
                   ((not (tramp-tramp-file-p otherfile)) nil)
                   (t (with-parsed-tramp-file-name otherfile parsed
                        (string= parsed-localname current-localname)))
                   )
             )
           )
         (buffer-list))
        )
    ()))

(defun my/copy-to-similar-buffers ()
  "Copies the current buffer's contents to similar buffers"
  (interactive)
  (let ((source (current-buffer)))
    (mapc (lambda (buf)
            (with-current-buffer buf (let ((p (point)))
                                       (progn
                                         ;; TODO use replace-buffer-contents on 26.1+
                                          (erase-buffer)
                                          (insert-buffer-substring source)
                                          (goto-char p)))))
          (my/similar-buffers))))

(defun my/copy-to-similar-buffers-and-save ()
  "Copies the current buffer's contents to similar buffers, and saves all of them"
  (interactive)
  (my/copy-to-similar-buffers)
  (save-buffer)
  (mapc (lambda (buf)
          (with-current-buffer buf (save-buffer)))
        (my/similar-buffers)))

(defun my/toggle-fold ()
  "Toggle fold all lines larger than indentation on current line"
  (interactive)
  (let ((col 1))
    (save-excursion
      (back-to-indentation)
      (setq col (+ 1 (current-column)))
      (set-selective-display
       (if selective-display nil (or col 1))))))

(defun my/java-toggle-spec ()
  "Switches between a *.java file and its *Spec.java test"
  (interactive)
  (let (
        (idx (string-match "src/main/java" buffer-file-name)))
    (if (and idx (string-match "\\.java" buffer-file-name))
        (find-file (concat
                    (substring buffer-file-name 0 idx)
                    "src/test/java"
                    (substring buffer-file-name (+ idx 13) -5)
                    "Spec.java"))
        )
    )
  )

(defun my/scala-toggle-spec ()
  "Switches between a *.scala file and its *Spec.scala test"
  (interactive)
  (let (
        (idx (string-match "src/main/scala" buffer-file-name)))
    (if (and idx (string-match "\\.scala" buffer-file-name))
        (find-file (concat
                    (substring buffer-file-name 0 idx)
                    "src/test/scala"
                    (substring buffer-file-name (+ idx 14) -6)
                    "Spec.scala"))
        )
    )
  )

(defun my/scala-zio-spec-name ()
  "Returns the name of the innermost test() or testM() invocation"
  (save-excursion
    (if (re-search-backward "test.?(\"\\(.+\\)\")" nil t)
        (match-string-no-properties 1)
      nil)
    )
  )

(defun my/java-extra-test-args ()
  "Returns extra bloop arguments for testing, e.g. which spec inside the test to run"
  (let ((spec (my/scala-zio-spec-name)))
    (if spec
        (format "-t \"%s\"" (my/scala-zio-spec-name))
      ""
        )
    )
  )

(defun my/java-run-test ()
  "Runs the test for the current *.java or *.scala file (or the file itself, if it is a test)"
  (interactive)
  (let ((default-directory (projectile-project-root)))
    (compile (format "bloop test %s --reporter scalac -o %s" (my/module-name-for-buffer) (my/test-name-for-buffer)))))

(defun my/java-run-test-case ()
  "Runs the test for the current *.java or *.scala file (or the
file itself, if it is a test), limiting the run to only the
current test case"
  (interactive)
  (let ((default-directory (projectile-project-root)))
    (compile (format "bloop test %s --reporter scalac -o %s -- %s" (my/module-name-for-buffer) (my/test-name-for-buffer) (my/java-extra-test-args)))))

(defun my/root-project-name-from-buildsbt (dir)
  "Returns the name of the root project defined in build.sbt in directory [dir]"
  (let ((build (f-read-text (format "%s/build.sbt" dir))))
    (cond
     ((string-match "val `\\(.+\\)` = (project in file(\".\"))" build) (match-string 1 build))
     (t "root"))
  ))

(defun my/module-name-for-buffer ()
  "Returns the sbt or maven module name for the current buffer"
  (when (string-match "\\(.+\\)/src/[^/]+/\\(?:java\\|scala\\)/.*" buffer-file-name)
    (let ((baseName (match-string 1 buffer-file-name)))
      (if (file-exists-p (s-concat baseName "/build.sbt"))
          ;; this isn't a multi-module project, since our src folder is where build.sbt is.
          (my/root-project-name-from-buildsbt baseName)
        (file-name-base baseName)))))

(defun my/-module-name-or-parent (dir)
  (if (file-exists-p (s-concat dir "/../build.sbt")))
  )

(defun my/test-name-for-buffer ()
  "Returns the classname of the spec/test that would test the current buffer"
  (cond
   ((string-match "src/main/\\(?:java\\|scala\\)/\\(.*\\)/\\([^/]+\\)\\.\\(?:java\\|scala\\)" buffer-file-name)
    (let* ((packageDir (match-string 1 buffer-file-name))
           (name (match-string 2 buffer-file-name)))
      (if (s-blank? packageDir)
          name
        (s-concat (s-replace "/" "." packageDir) "." name "Spec"))))
   ((string-match "src/test/\\(?:java\\|scala\\)/\\(.*\\)/\\([^/]+\\)\\.\\(?:java\\|scala\\)" buffer-file-name)
    (let* ((packageDir (match-string 1 buffer-file-name))
           (name (match-string 2 buffer-file-name)))
      (if (s-blank? packageDir)
          name
        (s-concat (s-replace "/" "." packageDir) "." name))))
   ))

(defun my/complete-ssh-host (prefix)
  "Finds any ssh host that starts with prefix"
  (let* ((parsed (append
                  (tramp-parse-sconfig "~/.ssh/config.production")
                  (tramp-parse-sconfig "~/.ssh/config.sandbox")
                  (tramp-parse-sconfig "~/.ssh/config.smoketests")
                  (tramp-parse-sconfig "~/.ssh/config.jyp")))
         (filtered (seq-map 'cadr parsed)))
    (seq-find (lambda (host) (string-prefix-p prefix host)) filtered))
  )

(defun ts/tramp-host (prefix) (format "/ssh:%s:/" (my/complete-ssh-host prefix)))

(defun my/replace-or-delete-pair (open)
  "Replace pair at point by OPEN and its corresponding closing character.
The closing character is lookup in the syntax table or asked to
the user if not found."
  (interactive
   (list
    (read-char
     (format "Replacing pair %c%c by (or hit RET to delete pair):"
             (char-after)
             (save-excursion
               (forward-sexp 1)
               (char-before))))))
  (if (memq open '(?\n ?\r))
      (delete-pair)
    (let ((close (cdr (aref (syntax-table) open))))
      (when (not close)
        (setq close
              (read-char
               (format "Don't know how to close character %s (#%d) ; please provide a closing character: "
                       (single-key-description open 'no-angles)
                       open))))
      (my/replace-pair open close))))

(defun my/replace-pair (open close)
  "Replace pair at point by respective chars OPEN and CLOSE.
If CLOSE is nil, lookup the syntax table. If that fails, signal
an error."
  (let ((close (or close
                   (cdr-safe (aref (syntax-table) open))
                   (error "No matching closing char for character %s (#%d)"
                          (single-key-description open t)
                          open)))
        (parens-require-spaces))
    (insert-pair 1 open close))
  (delete-pair)
  (backward-char 1))

(global-set-key "\333" (quote my/replace-or-delete-pair)) ;; Meta-[

;; https://stackoverflow.com/questions/88399/how-do-i-duplicate-a-whole-line-in-emacs
(defun my/duplicate-line (arg)
  "Duplicate current line, leaving point in lower line."
  (interactive "*p")

  ;; save the point for undo
  (setq buffer-undo-list (cons (point) buffer-undo-list))

  ;; local variables for start and end of line
  (let ((bol (save-excursion (beginning-of-line) (point)))
        eol)
    (save-excursion

      ;; don't use forward-line for this, because you would have
      ;; to check whether you are at the end of the buffer
      (end-of-line)
      (setq eol (point))

      ;; store the line and disable the recording of undo information
      (let ((line (buffer-substring bol eol))
            (buffer-undo-list t)
            (count arg))
        ;; insert the line arg times
        (while (> count 0)
          (newline)         ;; because there is no newline in 'line'
          (insert line)
          (setq count (1- count)))
        )

      ;; create the undo information
      (setq buffer-undo-list (cons (cons eol (point)) buffer-undo-list)))
    ) ; end-of-let

  ;; put the point in the lowest line and return
  (next-line arg))

(defun my/grab-number-quick-calc ()
  "Grab the current number into quick-calc"
  (interactive)
  (save-excursion
    (skip-chars-backward "0123456789")
    (skip-chars-backward "-")
    (if (looking-at "-?\\([0-9]+\\)")
        (progn
          (set-mark (point))
          (activate-mark)
          (re-search-forward "-?\\([0-9]+\\)")
          (let ((num (buffer-substring (mark) (point))))
            (calc)
            (calc-eval num 'push)
            ))
      (calc))))

(defun my/message-auto-ispell-language ()
  "Auto-detect ispell language for composing e-mails"
  (interactive)
  (let ((receivers (format "%s %s" (message-fetch-field "cc") (message-fetch-field "to"))))
    (when (string-match-p "\\.dk" receivers)
      (ispell-change-dictionary "dansk")
      )))

(add-hook 'mu4e-compose-mode-hook 'my/message-auto-ispell-language)

(global-set-key (kbd "<f8>") 'my/grab-number-quick-calc)

(defun my/pretty-print-xml-region (begin end)
  "Pretty format XML markup in region. You need to have nxml-mode
http://www.emacswiki.org/cgi-bin/wiki/NxmlMode installed to do
this.  The function inserts linebreaks to separate tags that have
nothing but whitespace between them.  It then indents the markup
by using nxml's indentation rules."
  (interactive "r")
  (save-excursion
    (goto-char begin)
    (while (search-forward-regexp "\>[ \\t]*\<" nil t)
      (backward-char) (insert "\n"))
    (indent-region begin end)))

;; from https://www.emacswiki.org/emacs/NxmlMode#toc11
(defun nxml-where ()
  "Display the hierarchy of XML elements the point is on as a path."
  (interactive)
  (let ((path nil))
    (save-excursion
      (save-restriction
        (widen)
        (while (and (< (point-min) (point)) ;; Doesn't error if point is at beginning of buffer
                    (condition-case nil
                        (progn
                          (nxml-backward-up-element) ; always returns nil
                          t)
                      (error nil)))
          (setq path (cons (xmltok-start-tag-local-name) path)))
        (if (called-interactively-p t)
            (message "/%s" (mapconcat 'identity path "/"))
          (format "/%s" (mapconcat 'identity path "/")))))))

;; https://emacs.stackexchange.com/questions/10245/counting-sub-headings-in-org-mode-using-elisp
(defun my/org-number-of-subentries (&optional pos match scope level)
  "Return number of subentries for entry at POS.
MATCH and SCOPE are the same as for `org-map-entries', but
SCOPE defaults to 'tree.
By default, all subentries are counted; restrict with LEVEL."
  (interactive)
  (save-excursion
    (goto-char (or pos (point)))
    ;; If we are in the middle ot an entry, use the current heading.
    (org-back-to-heading t)
    (let ((maxlevel (when (and level (org-current-level))
                      (+ level (org-current-level)))))
      (message "%s subentries"
               (1- (length
                    (delq nil
                          (org-map-entries
                           (lambda ()
                             ;; Return true, unless below maxlevel.
                             (or (not maxlevel)
                                 (<= (org-current-level) maxlevel)))
                           match (or scope 'tree)))))))))

  (defun my-randomize-region (beg end)
    "Randomize lines in region from BEG to END."
    (interactive "*r")
    (let ((lines (split-string
                   (delete-and-extract-region beg end) "\n")))
      (when (string-equal "" (car (last lines 1)))
        (setq lines (butlast lines 1)))
      (apply 'insert
        (mapcar 'cdr
        (sort (mapcar (lambda (x) (cons (random) (concat x "\n"))) lines)
              (lambda (a b) (< (car a) (car b))))))))
