;;; dot-http.el --- Convenience mode for dot-http command line tool  -*- lexical-binding: t; -*-

;; Copyright (C) 2010-2021 Your Name


;; Author: Michael Schlösser
;; Created: 07 Jun 2023

;; Keywords: http cli wrapper convenience
;; URL: https://example.com/foo

;; This file is not part of GNU Emacs.

;; This file is free software…

;; along with this file.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;;
;;; dot-http is a convenience mode for the dot-http command line tool.
;;; It enables you to quickly execute HTTP request from files that follow the
;;; HTTP Request in Editor Specification defined by JetBrains.
;;;

;;; Code:
(require 'ivy)

(defvar dot-http-tmp-file "/tmp/dot.http",
  "Defines where the temporary file is created")

(defun dot-http--write-tmp-buffer (start end)
  "Create a temporary file for execution.  The file contents go from START until END."
  (write-region start end dot-http-tmp-file))

(defun dot-http--run-with-file (file line)
  "Run the actual shell command for FILE and pass the LINE as an argument."
  (shell-command (concat "dot-http "
			 (format "-l %d " line)
			 (shell-quote-argument file))
		 "dot-http Out"
		 "*dot-http Error*")
  )

(defconst dot-http-methods '("GET"
			     "HEAD"
			     "POST"
			     "PUT"
			     "DELETE"
			     "CONNECT"
			     "PATCH"
			     "OPTIONS"
			     "TRACE")
  "The HTTP methods to look for.")

(defun dot-http-find-requests ()
  "Find all requests in a buffer."
  
  (let (found-requests '())
    (goto-char (point-min))
    (while (not (eobp))
      (when (member (thing-at-point 'word) dot-http-methods)
	(add-to-list 'found-requests
		     (cons (string-trim (thing-at-point 'line)) (line-number-at-pos)) t))
      (forward-line 1))
    found-requests))

(defun dot-http--prepare-buffer-and-run (selected-line)
  "Prepare the buffer and run the SELECTED-LINE."
  (if buffer-file-name (dot-http--run-with-file buffer-file-name selected-line)
    ;; Since dot-http only allows files to be passed to the command,
    ;; create a temporary file and delete it after completion.
    (dot-http--write-tmp-buffer (point-min) (point-max))
    (dot-http--run-with-file dot-http-tmp-file selected-line)
    (delete-file dot-http-tmp-file))
  )

(defun dot-http-list-requests ()
  "Search the selected buffer for all requests and provide a list of all findings."
  (interactive)

  (let* ((all-requests (dot-http-find-requests)))
    (ivy-read "HTTP requests: " all-requests
              :action (lambda (x)
			(dot-http--prepare-buffer-and-run (cdr x)))
              :caller 'dot-http-test)))


(provide 'dot-http)

;;; dot-http.el ends here
