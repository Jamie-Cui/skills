;;; check_org.el --- Check Org files for structural and markup defects -*- lexical-binding: t; -*-

;; Usage: emacs --batch -Q -l check_org.el -- FILE...

(require 'cl-lib)
(require 'org)
(require 'org-element)
(require 'org-lint)
(require 'subr-x)

(defvar org-authoring--findings nil)

(defun org-authoring--report (file line code message)
  (push (list file line code message) org-authoring--findings))

(defun org-authoring--literal-block-p (position)
  "Return non-nil when POSITION is inside literal or comment content."
  (save-excursion
    (goto-char position)
    (let ((node (org-element-context))
          found)
      (while (and node (not found))
        (when (memq (org-element-type node)
                    '(src-block example-block export-block fixed-width
                      comment comment-block))
          (setq found t))
        (setq node (org-element-property :parent node)))
      found)))

(defun org-authoring--inline-literal-p (position)
  "Return non-nil when POSITION belongs to valid code-like inline markup."
  (save-excursion
    (goto-char position)
    (memq (org-element-type (org-element-context)) '(code verbatim link))))

(defun org-authoring--scan-regexp (file regexp code message &optional inline-safe)
  "Report REGEXP matches outside literal blocks.
When INLINE-SAFE is non-nil, also ignore valid code, verbatim, and link objects."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward regexp nil t)
      (let ((position (match-beginning 0)))
        (unless (or (org-authoring--literal-block-p position)
                    (and inline-safe (org-authoring--inline-literal-p position)))
          (org-authoring--report
           file (line-number-at-pos position) code message))))))

(defun org-authoring--check-headings (file)
  (save-excursion
    (goto-char (point-min))
    (let ((previous-level nil))
      (while (re-search-forward "^\\(\\*+\\)[ \\t]+" nil t)
        (let ((position (match-beginning 0))
              (stars (match-string-no-properties 1)))
          (unless (org-authoring--literal-block-p position)
            (let ((level (length stars)))
              (when (and previous-level (> level (1+ previous-level)))
                (org-authoring--report
                 file (line-number-at-pos position) "ORG101"
                 (format "heading jumps from level %d to %d" previous-level level)))
              (setq previous-level level))))))))

(defun org-authoring--check-blocks (file)
  (save-excursion
    (goto-char (point-min))
    (let (stack)
      (while (re-search-forward
              "^[ \\t]*#\\+\\(begin\\|end\\)_\\([[:alnum:]_-]+\\)\\b" nil t)
        (let ((kind (downcase (match-string 1)))
              (name (downcase (match-string 2)))
              (line (line-number-at-pos (match-beginning 0))))
          (if (string= kind "begin")
              (push (cons name line) stack)
            (cond
             ((null stack)
              (org-authoring--report
               file line "ORG102" (format "unmatched #+end_%s" name)))
             ((string= name (caar stack))
              (pop stack))
             (t
              (org-authoring--report
               file line "ORG102"
               (format "#+end_%s closes open #+begin_%s from line %d"
                       name (caar stack) (cdar stack)))
              (pop stack))))))
      (dolist (entry stack)
        (org-authoring--report
         file (cdr entry) "ORG102" (format "unclosed #+begin_%s" (car entry)))))))

(defun org-authoring--check-link-descriptions (file)
  "Report non-text inline objects in link descriptions in FILE."
  (org-element-map (org-element-parse-buffer) 'link
    (lambda (link)
      (when (cl-some
             (lambda (item)
               (not (eq (org-element-type item) 'plain-text)))
             (org-element-contents link))
        (org-authoring--report
         file (line-number-at-pos (org-element-property :begin link)) "ORG207"
         "link description contains inline markup; use plain text and move markup outside the link")))))

(defun org-authoring--check-code-boundaries (file)
  "Report apparent code spans that Org leaves unparsed in FILE."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "~[^~\n]+~" nil t)
      (let ((position (match-beginning 0)))
        (unless (or (org-authoring--literal-block-p position)
                    (org-authoring--inline-literal-p position))
          (org-authoring--report
           file (line-number-at-pos position) "ORG208"
           "apparent ~code~ span is not parsed by Org; separate it from adjacent text or punctuation"))))))

(defun org-authoring--run-org-lint (file)
  (dolist (report (org-lint--generate-reports (current-buffer) org-lint--checkers))
    (let* ((fields (cadr report))
           (line-text (aref fields 0))
           (description (aref fields 2))
           (checker (aref fields 3))
           (checker-name (org-lint-checker-name checker)))
      (org-authoring--report
       file (string-to-number (substring-no-properties line-text))
       (format "ORG-LINT/%s" checker-name)
       (substring-no-properties description)))))

(defun org-authoring--check-file (file)
  (condition-case error-data
      (with-temp-buffer
        (insert-file-contents file)
        (setq buffer-file-name file)
        (org-mode)
        (org-element-parse-buffer)
        (org-authoring--run-org-lint file)
        (org-authoring--check-headings file)
        (org-authoring--check-blocks file)
        (org-authoring--check-link-descriptions file)
        (org-authoring--check-code-boundaries file)
        (org-authoring--scan-regexp
         file "\\*\\*[^*\n]+\\*\\*" "ORG201"
         "Markdown bold detected; use *text*" t)
        (org-authoring--scan-regexp
         file "`[^`\n]+`" "ORG202"
         "Markdown code span detected; use ~code~" t)
        (org-authoring--scan-regexp
         file "\\[[^]\n]+\\](\\(?:[^()\n]\\|([^()\n]*)\\)+)" "ORG203"
         "Markdown link detected; use [[target][description]]" t)
        (org-authoring--scan-regexp
         file "^[ \\t]*```" "ORG204"
         "Markdown fenced block detected; use #+begin_src and #+end_src")
        (org-authoring--scan-regexp
         file "&\\(?:#x?[[:xdigit:]]+\\|[[:alpha:]][[:alnum:]]*\\);" "ORG205"
         "HTML entity detected in Org prose; use the intended UTF-8 character" t)
        (org-authoring--scan-regexp
         file "=[[:alnum:]_./:+-]+=[^=[:space:]\n]+=\\(?:[^=\n]*=\\)?" "ORG206"
         "ambiguous =name=value= span; use ~name=value~")
        (org-authoring--scan-regexp
         file "=[^=\n]+==[^=\n]*=" "ORG206"
         "verbatim span contains equals; use ~code~"))
    (error
     (org-authoring--report
      file 1 "ORG000" (format "cannot parse file: %s" (error-message-string error-data))))))

(defun org-authoring--main ()
  (let ((files (cl-remove "--" command-line-args-left :test #'string=)))
    (if (null files)
        (progn
          (princ "usage: emacs --batch -Q -l check_org.el -- FILE...\n")
          (kill-emacs 2))
      (dolist (file files)
        (if (file-readable-p file)
            (org-authoring--check-file (expand-file-name file))
          (org-authoring--report file 1 "ORG000" "file is not readable")))
      (dolist (finding
               (sort org-authoring--findings
                     (lambda (a b)
                       (if (string= (car a) (car b))
                           (< (cadr a) (cadr b))
                         (string< (car a) (car b))))))
        (pcase-let ((`(,file ,line ,code ,message) finding))
          (princ (format "%s:%d: %s %s\n" file line code message))))
      (kill-emacs (if org-authoring--findings 1 0)))))

(when noninteractive
  (org-authoring--main))

;;; check_org.el ends here
