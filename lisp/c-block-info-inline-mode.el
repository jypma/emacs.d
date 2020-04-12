(require 'cc-mode)


(defface c-block-info-inline-mode-open-string
  '((t :slant italic
       :foreground "slate gray"))
  "")


(defun c-block-info-inline-mode-process-window ()
  (interactive)
  (when (boundp 'c-block-info-inline-mode-overlays)
    (dolist (overlay c-block-info-inline-mode-overlays)
      (delete-overlay overlay))
    (setq-local c-block-info-inline-mode-stashed-overlay nil))

  (setq-local c-block-info-inline-mode-overlays nil)

  (unless (boundp 'c-block-info-inline-mode-stashed-overlay)
    (setq-local c-block-info-inline-mode-stashed-overlay nil))


  (save-excursion
    (goto-char (window-start))
    (c-block-info-inline-mode-setup-overlays))

  (add-hook 'post-command-hook 'c-block-info-inline-mode-post-command t t)
  (add-hook 'window-scroll-functions 'c-block-info-inline-mode-window-scroll t t))



(defun c-block-info-inline-mode-setup-overlays ()
  (let ((end (window-end)))
    (while (search-forward "}" end t)
      (let ((existing-overlay (car (overlays-at (1- (point))))))
        (unless existing-overlay
          (let* ((start (point))
                 (begin
                  (save-excursion
                    (let ((text (c-block-info-inline-mode-get-matching-text (window-start))))
                      (if (equal text "else")
                          (concat text " of: " (c-block-info-inline-mode-get-matching-text))
                        text)))))
            (if (and begin
                     (not (equal begin "")))
                (let ((o (make-overlay (1- (point)) (point))))
                  (overlay-put o

                               'after-string
                               (propertize (concat " // " begin)
                                           'face 'c-block-info-inline-mode-open-string))
                  (push o c-block-info-inline-mode-overlays))))))))
  (add-hook 'before-change-functions 'c-block-info-inline-mode-before-change t t))


(defun c-block-info-inline-mode-get-matching-text (&optional limit)
  (ignore-errors
    (while (progn
             (skip-syntax-backward " ")
             (eq (char-before) 10))
      (backward-char))

    (if (eq (char-syntax (char-before)) ?\))
        (backward-sexp))

    (when (or (not limit)
              (< (point) limit))
      (c-beginning-of-statement-1)
      (buffer-substring-no-properties (point) (line-end-position)))))




(defun c-block-info-inline-mode-before-change (begin end)
  (dolist (overlay c-block-info-inline-mode-overlays)
    (if (and (overlay-start overlay)
             (>= (overlay-start overlay) begin))
        (delete-overlay overlay)))

  (run-with-idle-timer
   0.3 nil
   (lambda (begin)
     (save-excursion
       (goto-char begin)
       (c-block-info-inline-mode-setup-overlays)))
   begin)
  (remove-hook 'before-change-functions 'c-block-info-inline-mode-before-change t))


(defun c-block-info-inline-mode-window-scroll (window start)
  (run-with-idle-timer
   0.01 nil
   (lambda (buffer)
     (with-current-buffer buffer
       (c-block-info-inline-mode-process-window)))
   (window-buffer window))
  (remove-hook 'window-scroll-functions 'c-block-info-inline-mode-window-scroll t)
  )


(defun c-block-info-inline-mode-post-command ()
  (when (boundp 'c-block-info-inline-mode-stashed-overlay)
    (when (and c-block-info-inline-mode-stashed-overlay
               (not (eq (point) (plist-get c-block-info-inline-mode-stashed-overlay 'point))))
      (let ((p (plist-get c-block-info-inline-mode-stashed-overlay 'point)))
        (move-overlay (plist-get c-block-info-inline-mode-stashed-overlay 'overlay)
                      (1- p) p))
      (setq-local c-block-info-inline-mode-stashed-overlay nil))

    (let ((o (car (overlays-at (1- (point))))))
      (when o
        (setq-local c-block-info-inline-mode-stashed-overlay
                    (list 'point (point)
                          'overlay o))
        (delete-overlay o)))))



(define-minor-mode c-block-info-inline-mode
  ""
  :init-value nil
  :lighter " CPInline"
  (if c-block-info-inline-mode
      (c-block-info-inline-mode-process-window)

    (dolist (overlay c-block-info-inline-mode-overlays)
      (delete-overlay overlay))

    (setq-local c-block-info-inline-mode-overlays nil)
    (setq-local c-block-info-inline-mode-stashed-overlay nil)

    (remove-hook 'before-change-functions 'c-block-info-inline-mode-before-change t)
    (remove-hook 'window-scroll-functions 'c-block-info-inline-mode-window-scroll t)
    (remove-hook 'post-command-hook 'c-block-info-inline-mode-post-command t)))



(provide 'c-block-info-inline-mode)
