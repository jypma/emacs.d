
;; uses json
;; uses transient

(defvar-local kubectl--namespace "" "Namespace to pass to kubectl, or empty to pass no namespace")

(defvar-local kubectl--context "" "Context to pass to kubectl, or empty to pass no context")

(defvar-local kubectl--pods-selector "" "Selector to filter pods on, or empty to show all pods")

(defun kubectl--args (args)
  "Builds a string kubectl commandline that ends with [args]"
  (let ((ns (if (string= "" kubectl--namespace) "" (format "--namespace %s" kubectl--namespace) ))
        (ctx (if (string= "" kubectl--context) "" (format "--context %s" kubectl--context) )))
    (message "kubectl %s %s %s" ns ctx args)
    (format "kubectl %s %s %s" ns ctx args)))

(defun kubectl--list-args (args)
  "Builds a list of kubectl commandline arguments that ends with [args]"
  (append
   (if (string= "" kubectl--namespace) nil (list "--namespace" kubectl--namespace))
   (if (string= "" kubectl--context) nil (list "--context" kubectl--context))
   args))

(defun kubectl--context-names ()
  "Invokes kubectl to get a list of contexts"
  (split-string (shell-command-to-string "kubectl config get-contexts --no-headers=true -o name") "\n"))

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
  (call-interactively (local-key-binding "g")))

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
    (apply #'start-process process bufname "kubectl" "logs" podname (kubectl--list-args args))
    (switch-to-buffer bufname)
    (read-only-mode)))

(defun kubectl-pods-log ()
  "Shows a transient popup to load the logs of the selected kubernetes pod."
  (interactive)
  (when (tabulated-list-get-id)
    (call-interactively 'kubectl--pods-log)))

(defun kubectl-pods-refresh ()
  "Refreshes the current kubernetes pods view"
  (interactive)
  (let ((sel (if (string= "" kubectl--pods-selector) "" (format "--selector %s" kubectl--pods-selector) )))
    (kubectl--refresh (format "pods:%s" kubectl--pods-selector)
                    (format "get pods --no-headers=true %s" sel)
                    [("Pod" 66) ("Ready" 10) ("Status" 24) ("Restarts" 11) ("Age" 10)])))

(defvar kubectl-pods-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "c") 'kubectl-choose-context)
    (define-key map (kbd "s") 'kubectl-choose-namespace)
    (define-key map (kbd "g") 'kubectl-pods-refresh)
    (define-key map (kbd "l") 'kubectl-pods-log)
    map))

(define-derived-mode kubectl-pods-mode tabulated-list-mode "Kubernetes pods"
  "Kubernetes mode to list pods"
  (message "selector: %s" kubectl--pods-selector))

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

(defvar kubectl-deployments-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "c") 'kubectl-choose-context)
    (define-key map (kbd "s") 'kubectl-choose-namespace)
    (define-key map (kbd "g") 'kubectl-deployments-refresh)
    (define-key map (kbd "o") 'kubectl-deployments-open)
    (define-key map (kbd "RET") 'kubectl-deployments-open)
    map))

(define-derived-mode kubectl-deployments-mode tabulated-list-mode "Kubernetes deployments"
  "Kubernetes mode to list deployments"
  (kubectl-deployments-refresh))

(defun kubectl-deployments ()
  (interactive)
  (switch-to-buffer "*kubernetes*")
  (kubectl-deployments-mode))

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
    (kubectl-pods-mode)
    (setq kubectl--pods-selector selector)
    (setq kubectl--namespace ns)
    (setq kubectl--context ctx)
    (kubectl-pods-refresh)))
