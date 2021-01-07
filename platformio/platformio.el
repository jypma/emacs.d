(defvar platformio--last-environment nil)

(defun platformio--run (&optional args)
  "Runs platformio with [args] as args"
  (interactive (list (transient-args 'platformio-running)))
  (let ((default-directory (platformio--find-root)))
    (compile (format "pio run %s" (string-join args " ")))))


(defun platformio--find-root ()
  "Finds the ancestor directory with platformio.ini in it"
  (let* ((dir (locate-dominating-file default-directory "platformio.ini")))
    (if dir
        dir
      (error "No platformio.ini found in %s or any of its ancestors." default-directory))))

(defun platformio--find-ini ()
  "Finds the path to platformio.ini for the current file"
  (format "%s/platformio.ini" (platformio--find-root)))

;; import json, os; from platformio.project.helpers import load_project_ide_data; print(json.dumps(load_project_ide_data(os.getcwd(), 'esp32')['targets']))

(defun platformio--list-environments ()
  "Returns a list with valid environments, as listed in platformio.ini"
  (let* ((lines (with-temp-buffer
                  (insert-file-contents (platformio--find-ini))
                  (split-string (buffer-string) "\n" t)))
         (sections (mapcan (lambda (s) (when (string-match "\\[env:\\(.*\\)\\]" s)
                                    (list (match-string 1 s)))) lines)))
    (remove-duplicates sections :test #'equal)))

(defun platformio--list-targets (env)
  "Lists the available targets for the given environment"
;; Python magic is borrowed from here: https://github.com/platformio/platformio-node-helpers/blob/master/src/project/tasks.js#L182
  (let* (
         (default-directory (platformio--find-root))
         (json (json-parse-string (shell-command-to-string (format "python -c \"import json, os; from platformio.project.helpers import load_project_ide_data; print(json.dumps(load_project_ide_data(os.getcwd(), '%s')['targets']))\"" env))))
         (targets (mapcar (lambda (m) (gethash "name" m)) json)))
    targets))

(defun platformio--read-environment (&rest _ignore)
  (let* ((env (completing-read "Environment" (platformio--list-environments))))
     (setq platformio--last-environment env)
     env))

(defun platformio--read-target (&rest _ignore)
  (let ((env platformio--last-environment))
    (completing-read "Target" (platformio--list-targets env))))

(defclass platformio--variable (transient-variable)
  ((scope       :initarg :scope)))

(transient-define-argument platformio--environment ()
  :description "Environment for which to run"
  :class 'transient-option
  :key "-e"
  :argument "--environment="
  :reader 'platformio--read-environment
  )

(transient-define-argument platformio--target ()
  :description "Target to run"
  :class 'transient-option
  :key "-t"
  :argument "--target="
  :reader 'platformio--read-target
  )

(transient-define-prefix platformio-running ()
  "Execute platformio"
  ["Arguments"
   (platformio--environment)
   (platformio--target)]
  ["Actions"
   ("r" "Run" platformio--run)])

(define-prefix-command 'platformio-keymap)

(define-key platformio-keymap (kbd "r") 'platformio-running)

(global-set-key (kbd "C-c m") 'platformio-keymap)

(provide 'platformio)
