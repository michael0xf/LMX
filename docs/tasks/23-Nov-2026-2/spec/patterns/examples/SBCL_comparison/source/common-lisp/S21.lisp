(define-condition input-failure (error) ())

(defun checked (value)
  (when (minusp value) (error 'input-failure))
  (* value 2))

(defun example (value)
  (handler-case (checked value)
    (input-failure () 99)))
