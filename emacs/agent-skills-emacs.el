(require 'cl-lib)

(defun agent-skills--readable-buffer-string (buffer limit)
  "Return up to LIMIT characters from BUFFER."
  (with-current-buffer buffer
    (buffer-substring-no-properties
     (point-min)
     (min (point-max) (+ (point-min) limit)))))

(cl-defun agent-skills/list-functions (prefix)
  "Return a list of interactive function names matching PREFIX."
  (let (result)
    (mapatoms
     (lambda (sym)
       (when (and (fboundp sym)
                  (commandp sym)
                  (string-prefix-p prefix (symbol-name sym)))
         (push (symbol-name sym) result))))
    (sort result #'string<)))

(cl-defun agent-skills/describe-function (name)
  "Return the docstring and argument list for function NAME."
  (let ((sym (intern-soft name)))
    (unless (and sym (fboundp sym))
      (error "Function %s is not defined" name))
    (let ((arglist (help-function-arglist sym t))
          (docstring (documentation sym t)))
      (format "(%s %s)\n\n%s"
              name
              (if arglist (mapconcat #'symbol-name arglist " ") "")
              (or docstring "No documentation available.")))))

(cl-defun agent-skills/eval-expression (expr)
  "Evaluate EXPR (a string) and return the result as a string."
  (format "%S" (eval (car (read-from-string expr)) t)))

(cl-defun agent-skills/load-file (path)
  "Load elisp file at PATH and return a status string."
  (load (expand-file-name path) nil nil nil t)
  (format "Loaded: %s" (expand-file-name path)))

(cl-defun agent-skills/byte-compile-file (path)
  "Byte-compile PATH and return warnings and status."
  (let* ((target (expand-file-name path))
         (log-buffer (get-buffer-create "*Compile-Log*")))
    (with-current-buffer log-buffer
      (erase-buffer))
    (byte-compile-file target)
    (let ((log-output
           (if (buffer-live-p log-buffer)
               (agent-skills--readable-buffer-string log-buffer 4000)
             "")))
      (format "Byte-compiled: %s\n%s"
              target
              (if (equal log-output "")
                  "Compile log is empty."
                log-output)))))

(cl-defun agent-skills/run-ert (selector)
  "Run ERT tests matching SELECTOR regexp or prefix."
  (require 'ert)
  (let* ((pattern (or selector ""))
         (tests
          (ert-select-tests
           (lambda (test)
             (string-match-p pattern (symbol-name (ert-test-name test))))
           t))
         (results-buffer (get-buffer-create "*ERT*")))
    (with-current-buffer results-buffer
      (erase-buffer))
    (if (null tests)
        (format "No ERT tests matched: %s" pattern)
      (let ((stats (ert-run-tests-batch tests)))
        (format "ERT selector: %s\nPassed: %d\nFailed: %d\nSkipped: %d"
                pattern
                (ert-stats-completed-expected stats)
                (ert-stats-completed-unexpected stats)
                (ert-stats-skipped stats))))))

(cl-defun agent-skills/execute-keys (keys)
  "Execute KEYS as if typed by the user.
KEYS is a string in `kbd' format (e.g. \"C-x C-s\", \"S c c\")."
  (execute-kbd-macro (kbd keys))
  (format "Executed: %s" keys))

(cl-defun agent-skills/minibuffer-prompt ()
  "Return the current minibuffer prompt and contents, or nil if inactive."
  (if (minibufferp (window-buffer (minibuffer-window)))
      (with-current-buffer (window-buffer (minibuffer-window))
        (let ((prompt (minibuffer-prompt))
              (contents (minibuffer-contents)))
          (format "Prompt: %s\nContents: %s" (or prompt "") contents)))
    "Minibuffer is not active."))

(cl-defun agent-skills/current-buffer-state ()
  "Return the name, major mode, and first few lines of the user's focused buffer."
  (let ((buf (window-buffer (selected-window))))
    (with-current-buffer buf
      (let ((name (buffer-name))
            (mode (symbol-name major-mode))
            (point (point))
            (excerpt (buffer-substring-no-properties
                      (point-min)
                      (min (point-max) (+ (point-min) 2000)))))
        (format "Buffer: %s\nMode: %s\nPoint: %d\n---\n%s" name mode point excerpt)))))

(cl-defun agent-skills/special-buffer (name &optional limit)
  "Return contents of special buffer NAME up to LIMIT chars."
  (let ((buffer (get-buffer name))
        (max-chars (or limit 3000)))
    (if (not (buffer-live-p buffer))
        (format "Buffer not found: %s" name)
      (format "Buffer: %s\n---\n%s"
              name
              (agent-skills--readable-buffer-string buffer max-chars)))))

(cl-defun agent-skills/toggle-debug-on-error (&optional value)
  "Set `debug-on-error' to VALUE and report the result."
  (setq debug-on-error (if (null value) (not debug-on-error) value))
  (format "debug-on-error=%S" debug-on-error))

(cl-defun agent-skills/toggle-debug-on-quit (&optional value)
  "Set `debug-on-quit' to VALUE and report the result."
  (setq debug-on-quit (if (null value) (not debug-on-quit) value))
  (format "debug-on-quit=%S" debug-on-quit))

(cl-defun agent-skills/feature-state (feature-name)
  "Report whether FEATURE-NAME is loaded."
  (let* ((sym (intern-soft feature-name))
         (loaded (and sym (featurep sym))))
    (format "feature=%s loaded=%S" feature-name loaded)))

(cl-defun agent-skills/symbol-state (name)
  "Report function and variable state for symbol NAME."
  (let* ((sym (intern-soft name))
         (fbound (and sym (fboundp sym)))
         (bound (and sym (boundp sym)))
         (value (if bound (symbol-value sym) :unbound)))
    (format "symbol=%s exists=%S fboundp=%S boundp=%S value=%S"
            name (not (null sym)) fbound bound value)))

(cl-defun agent-skills/buffer-contents (buffer-name &optional limit)
  "Return contents of BUFFER-NAME up to LIMIT chars."
  (let ((buffer (get-buffer buffer-name))
        (max-chars (or limit 3000)))
    (if (not (buffer-live-p buffer))
        (format "Buffer not found: %s" buffer-name)
      (format "Buffer: %s\n---\n%s"
              buffer-name
              (agent-skills--readable-buffer-string buffer max-chars)))))

(cl-defun agent-skills/minibuffer-insert (text)
  "Insert TEXT into the minibuffer at point.
TEXT is inserted at point in the minibuffer. If the minibuffer is
not active, raises an error."
  (if (minibufferp (window-buffer (minibuffer-window)))
      (with-current-buffer (window-buffer (minibuffer-window))
        (insert text)
        (format "Inserted into minibuffer: %s" text))
    (error "Minibuffer is not active")))

(provide 'agent-skills/emacs)
