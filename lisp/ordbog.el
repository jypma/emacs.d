(defcustom ordbog-ddocli-path "ddo.py"
  "The full path to ddo-cli's ddo.py script (downloadable from github)"
  :type '(string)
  :group 'ordbog)

(defun ordbog-describe-word ()
  "Looks up the word at point and shows its description in the minibuffer."
  (interactive)
  (let* ((ord (thing-at-point 'word 'no-properties))
         (msg (shell-command-to-string (format "%s %s" ordbog-ddocli-path ord))))
    (message msg)))

(provide 'ordbog)
