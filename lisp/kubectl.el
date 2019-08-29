
;; uses json
;; uses transient

;; TODO
;; - Show JSON details for any resource
;; - List ingresses
;; - Integrate kube-tramp changes

(defvar-local kubectl--namespace "" "Namespace to pass to kubectl, or empty to pass no namespace")

(defvar-local kubectl--context "" "Context to pass to kubectl, or empty to pass no context")

(defvar-local kubectl--pods-selector "" "Selector to filter pods on, or empty to show all pods")

(defvar kubectl--shell "/bin/bash" "Shell to run when opening a term to a pod")

(defvar kubectl--kubectl "/usr/bin/kubectl" "Path to kubectl to use")

(defun kubectl--args (args)
  "Builds a string kubectl commandline that ends with [args]"
  (let ((ns (if (string= "" kubectl--namespace) "" (format "--namespace %s" kubectl--namespace) ))
        (ctx (if (string= "" kubectl--context) "" (format "--context %s" kubectl--context) )))
    (message "%s %s %s %s" kubectl--kubectl ns ctx args)
    (format "%s %s %s %s" kubectl--kubectl ns ctx args)))

(defun kubectl--list-args (args)
  "Builds a list of kubectl commandline arguments that ends with [args]"
  (append
   (if (string= "" kubectl--namespace) nil (list "--namespace" kubectl--namespace))
   (if (string= "" kubectl--context) nil (list "--context" kubectl--context))
   args))

(defun kubectl--context-names ()
  "Invokes kubectl to get a list of contexts"
  (split-string (shell-command-to-string (format "%s config get-contexts --no-headers=true -o name" kubectl--kubectl)) "\n"))

(defun kubectl-choose-context (context)
  "Select a new context interactively"
  (interactive (list (completing-read "Context: " (kubectl--context-names) nil t)))
  (setq kubectl--context context)
  (call-interactively 'kubectl-choose-namespace))

(defun kubectl--namespace-names ()
  "Invokes kubectl to get a list of namespaces"
  ;; TODO handle failure gracefully, and allow user to just type a namespace then
  (split-string (shell-command-to-string (kubectl--args "get namespaces --no-headers=true | awk '{print $1}'")) "\n"))

(defun kubectl-choose-namespace (namespace)
  "Select a new namespace interactively"
  (interactive (list (completing-read "Namespace: " (kubectl--namespace-names) nil t)))
  (setq kubectl--namespace namespace)
  (call-interactively (cdr (car (minor-mode-key-binding "g")))))

(defun kubectl--refresh (name args columns)
  "Refreshes the current view according to [args] as kubectl
  command line, and [columns] as tabulated list columns. The
  buffer is renamed to include [name]."
  (let ((bufname (if (and (string= "" kubectl--namespace) (string= "" kubectl--context))
                     (format "*k8s %s*" name)
                   (format "*k8s %s %s/%s*" name kubectl--context kubectl--namespace))))
    (unless (string= bufname (buffer-name))
      (when (get-buffer bufname)
        (kill-buffer bufname))
      (rename-buffer bufname)))

  (let ((rows (mapcar (lambda (line)
                        (let ((items (split-string line)))
                          (list (car items) (vconcat items))))
                      (seq-filter (lambda (line) (not (string= "" line)))
                                  (split-string (shell-command-to-string
                                                 (kubectl--args args)) "\n"))))
        (oldpos (point)))
    (setq tabulated-list-format columns)
    (setq tabulated-list-entries rows)

    (tabulated-list-init-header)
    (tabulated-list-print)
    (goto-char oldpos)))

(define-transient-command kubectl--pods-log ()
  "Show console log"
  ["Arguments"
   ("-f" "Follow" "-f")
   ("-p" "Previous" "-p")
   ("-n" "Tail" "--tail=")
   ]
  ["Actions"
   ("l" "Log" kubectl--pods-get-log)])

(defun kubectl--pods-get-log (&optional args)
  "Loads the logs of the selected kubernetes pod into a new buffer, passing [args] to the kubectl command"
  (interactive (list (transient-args 'kubectl--pods-log)))
  (let* ((podname (tabulated-list-get-id))
         (bufname (format "*k8s logs:%s*" podname))
         (process (format "*kubectl logs:%s" podname)))
    (when (get-buffer bufname)
      (kill-buffer bufname))
    (apply #'start-process process bufname kubectl--kubectl "logs" podname (kubectl--list-args args))
    (switch-to-buffer bufname)
    (read-only-mode)))

(defun kubectl--pods-term ()
  "Opens up a term for the currently selected pod"
  (interactive)
  (let* ((podname (tabulated-list-get-id))
         (termbuf (apply 'make-term
                         (format "*k8s term:%s*" podname)
                         kubectl--kubectl
                         nil
                         (kubectl--list-args (list "exec" "-ti" podname kubectl--shell)))))
    (set-buffer termbuf)
    (term-mode)
    (term-char-mode)
    (switch-to-buffer termbuf)))

(defun kubectl--pods-run (command)
  "Runs [command] on the given pod, outputting its results asynchronously to a new buffer."
  (interactive "M")
  (let* ((podname (tabulated-list-get-id))
         (bufname (format "*k8s exec %s:%s" podname command))
         (process (format "*kubectl exec %s:%s" podname command))
         (args (append (list "exec" podname) (split-string-and-unquote command))))
    (when (get-buffer bufname)
      (kill-buffer bufname))
    (apply #'start-process process bufname kubectl--kubectl (kubectl--list-args args))
    (switch-to-buffer bufname)
    (read-only-mode)))

(defun kubectl--pods-run-custom (&optional args)
  (interactive)
  (call-interactively 'kubectl--pods-run))

(defun kubectl--pods-run-1 ()
  (interactive)
  (kubectl--pods-run "/usr/bin/jstack 1")) ;; we could do (thread-dump-start) after the process completes

(define-transient-command kubectl-pods-run ()
  "Execute a command"
  []
  ["Actions"
   ("1" "Run jstack" kubectl--pods-run-1)
   ("r" "Run custom command" kubectl--pods-run-custom)])

(defun kubectl-pods-refresh ()
  "Refreshes the current kubernetes pods view"
  (interactive)
  (let ((sel (if (string= "" kubectl--pods-selector) "" (format "--selector %s" kubectl--pods-selector) )))
    (kubectl--refresh (format "pods:%s" kubectl--pods-selector)
                    (format "get pods --no-headers=true %s" sel)
                    [("Pod" 66) ("Ready" 10) ("Status" 24) ("Restarts" 11) ("Age" 10)])))

(define-minor-mode kubectl-pods-mode
  "A minor mode with a keymap for the kubernetes pod list"
  :keymap
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "c") 'kubectl-choose-context)
    (define-key map (kbd "s") 'kubectl-choose-namespace)
    (define-key map (kbd "g") 'kubectl-pods-refresh)
    (define-key map (kbd "l") 'kubectl--pods-log)
    (define-key map (kbd "t") 'kubectl--pods-term)
    (define-key map (kbd "r") 'kubectl-pods-run)
    (define-key map (kbd "d") 'kubectl--list-deployments)
    map))

(defun kubectl-deployments-refresh ()
  "Refreshes the current kubernetes deployments view"
  (interactive)
  (kubectl--refresh "deployments"
                    "get deployments --no-headers=true"
                    [("Deployment" 66) ("Desired" 10) ("Current" 10) ("Up-to-date" 10) ("Age" 10)]))

(defun kubectl-deployments-open ()
  "Opens the deployment currently selected"
  (interactive)
  (kubectl-open-deployment (tabulated-list-get-id)))

(define-minor-mode kubectl-deployments-mode
  "A minor mode with a keymap for the kubernetes deployments list"
  :keymap
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "c") 'kubectl-choose-context)
    (define-key map (kbd "s") 'kubectl-choose-namespace)
    (define-key map (kbd "g") 'kubectl-deployments-refresh)
    (define-key map (kbd "o") 'kubectl-deployments-open)
    (define-key map (kbd "RET") 'kubectl-deployments-open)
    map))

(defun kubectl-deployments ()
  "Select a context and namespace, and show its deployments"
  (interactive)
  (switch-to-buffer "*kubernetes*")
  (tabulated-list-mode)
  (kubectl-deployments-mode)
  (call-interactively 'kubectl-choose-context))

(defun kubectl--list-deployments ()
  (switch-to-buffer "*kubernetes*")
  (tabulated-list-mode)
  (kubectl-deployments-mode)
  (kubectl-deployments-refresh))

(defun kubectl-open-deployment (name)
  (let* ((selflink (shell-command-to-string (kubectl--args (format "get deployment.apps %s -o jsonpath={.metadata.selfLink}" name))))
         (json-object-type 'hash-table)
         (json-array-type 'list)
         (json-key-type 'string)
         (scale (json-read-from-string (shell-command-to-string (kubectl--args (format "get --raw %s/scale" selflink)))))
         (selector (gethash "selector" (gethash "status" scale)))
         (ns kubectl--namespace)
         (ctx kubectl--context))
    (switch-to-buffer "*kubernetes*")
    (tabulated-list-mode)
    (kubectl-pods-mode)
    (setq kubectl--pods-selector selector)
    (setq kubectl--namespace ns)
    (setq kubectl--context ctx)
    (kubectl-pods-refresh)))

(provide 'kubectl)
