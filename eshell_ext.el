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

;; https://emacs.stackexchange.com/questions/37019/use-sudo-while-editing-over-ssh
(defun my--reopen-remote-file-as-root ()
  "Reopen a remote file as root over tramp."
  (find-alternate-file (let* ((parts (s-split ":" buffer-file-name))
            (hostname (nth 1 parts))
            (filepath (car (last parts))))
           (concat "/ssh" ":" hostname "|" "sudo" ":" hostname ":" filepath))))

(defun my/reopen-file-as-root ()
  "Reopen a local or remote file as root."
  (interactive)
  (if (file-remote-p default-directory)
      (progn
    (my--reopen-remote-file-as-root)))
  (crux-reopen-as-root))

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
