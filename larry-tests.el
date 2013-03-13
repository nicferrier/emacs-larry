;;; testing larry

(require 'ert)
(require 'cl)
(require 'elisp-process)

(ert-deftest larry-handle ()
  (let (result)
    (flet ((test-func (x y z)
             (setq result (list x y z)))
           (web-json-post (cb &key url json-array-type)
             (funcall cb (list 'test-func 1 2 3))))
      (larry-handle "10"))))

;; This is a bit complicated but basically it tests the full larry
;; stack including elnode.
;;
;; It could be improved by abstracting more of larry so we don't have
;; to duplicate what larry does.
(ert-deftest larry-handle-end-to-end ()
  (let* (result
         booter pid
         (elisp-process/list (make-hash-table :test 'equal))
         (code [the-test-proc]))
    ;; Now fake the web handling
    (flet ((the-test-proc (x y z)
             (setq result (list x y z)))
           (elisp-process/call-starter (starter)
             (setq booter starter))
           (web-json-post (cb &key url json-array-type)
             (flet ((elnode-send-json (con json) (json-encode json)))
               (let* ((json-data ; Do what elnode would have done
                       (elisp-process/dispatch-handler
                        :httpcon pid (elisp-process/work-test pid)))
                      (lisp-data ; This does some of what larry does
                       (web/json-parse
                        json-data :json-array-type json-array-type)))
                 ;; Now fire the larry callback with what elnode would have sent
                 (funcall cb lisp-data)))))
      ;; Start the process - fake call ends up in 'booter' set
      (setq pid (start-elisp-process :test1 code :fake-server))
      ;; Puts the data on the queue
      (@> pid 11 12 13)
      (funcall booter)
      (should (equal result (list 11 12 13))))))

;;; larry-tests.el ends here
