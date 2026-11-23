(define-condition resource-failure (error)
  ((phase :initarg :phase :reader failure-phase)))

(defstruct resource (value 42) (width 8))

(defun example (mode)
  (let ((trace 0))
    (flet ((event (phase fail)
             (setf trace (+ (* trace 10) phase))
             (when fail (error 'resource-failure :phase phase))))
      (let ((result
              (handler-case
                  (let ((resource (progn (event 1 (= mode 2))
                                         (make-resource))))
                    (unwind-protect
                         (progn (event 2 (member mode '(1 4)))
                                (+ (resource-value resource)
                                   (resource-width resource)))
                      (event 3 (member mode '(3 4)))))
                (resource-failure (failure) (- (failure-phase failure))))))
        (list result trace)))))
