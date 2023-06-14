;;; dot-http.el --- Convenience mode for dot-http command line tool  -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Michael Schlösser

;; Author: Michael Schlösser

;; Keywords: http cli wrapper convenience
;; URL: https://example.com/foo

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;;
;;; dot-http is a convenience mode for the dot-http command line tool.
;;; It enables you to quickly execute HTTP request from files that follow the
;;; HTTP Request in Editor Specification defined by JetBrains.
;;;

;;; Code:
(require 'ivy)

(defvar dot-http-tmp-file "/tmp/dot.http",
  "Defines the location of the temporary file that is needed when executing requests non-file buffers.")

(defconst dot-http-error-buffer-name "*dot-http Errors*"
  "If an error occurs write the error output this named buffer.")

(defun dot-http--write-tmp-buffer (start end)
  "Create a temporary file for execution.
The file contents are defined by START until END (i.e a selected region)."
  (write-region start end dot-http-tmp-file))

(defun dot-http--run-with-file (file line)
  "Run the dot-http shell command for FILE and pass the LINE as an argument."
  (shell-command (concat "dot-http "
			 (format "-l %d " line)
			 (shell-quote-argument file))
		 (format "dot-http-result-%s" (format-time-string "%Y-%m-%dT%H%M%S.%3N"))
		 dot-http-error-buffer-name))

(defconst dot-http-methods '("GET"
			     "HEAD"
			     "POST"
			     "PUT"
			     "DELETE"
			     "CONNECT"
			     "PATCH"
			     "OPTIONS"
			     "TRACE")
  "The HTTP methods to look for.  The list has been taken from the spec document.")

(defun dot-http-find-requests ()
  "Find all requests in a buffer.
Return a list containing the request itself and the line within the file."
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
    (delete-file dot-http-tmp-file)))

(defun dot-http-run-request-at-point ()
  "If point is over a request run it."
  (interactive)

  (if (member (thing-at-point 'word) dot-http-methods)
      (dot-http--prepare-buffer-and-run (line-number-at-pos))
    (error "No request at point")))

(defun dot-http-list-requests ()
  "Search the selected buffer for all requests and provide a list of all findings."
  (interactive)

  (let* ((all-requests (dot-http-find-requests)))
    (ivy-read "HTTP requests: " all-requests
              :action (lambda (x)
			(dot-http--prepare-buffer-and-run (cdr x)))
              :caller 'dot-http-list-requests)))

(define-derived-mode dot-http-mode
  text-mode "dot-http"
  "Major mode for dot-http.")

(provide 'dot-http)

;;; dot-http.el ends here
