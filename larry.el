;;; larry.el --- handle elisp processes -*- lexical-binding: t -*-

;; Copyright (C) 2013  Nic Ferrier

;; Author: Nic Ferrier <nferrier@ferrier.me.uk>
;; Keywords: lisp
;; Created: 13th March 2013
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; handler

;;; Code:

(defvar larry/schedule-timer nil
  "Stored timer for larry.")

(defun larry/schedule (fn arg)
  "Schedule the FN to recieve the ARG in 0.01 seconds."
  (setq larry/schedule-timer
        (run-at-time
         "0.01 sec"
         nil
         (lambda ()
           (funcall fn arg)
           ;; Not sure if I should clear up afterwards or not
           (setq larry/schedule-timer nil)))))

(defun larry/call (json-message)
  "Turn the JSON-MESSAGE into a function call."
  (condition-case err
      (let ((func (intern (car json-message)))
            (args (cdr json-message)))
        (message "larry going to (apply %S %S)" func args)
        (apply func args))
    (error (message "larry-handle: oops %S" err))))

(defun larry-handle (pid)
  (web-json-post
   (lambda (data &optional http hdr)
     (message "larry for %s got message %s" pid data)
     (larry/call data)
     ;;(larry/schedule 'larry-handle path))
     (message "larry schedule %s again" pid))
   :url pid
   :json-array-type 'list))

(provide 'larry)

;;; larry.el ends here
