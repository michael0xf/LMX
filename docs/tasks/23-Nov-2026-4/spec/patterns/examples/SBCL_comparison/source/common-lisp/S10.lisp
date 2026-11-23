(defun make-adder (first)
  (lambda (second) (+ first second)))

(defun example (value)
  (let ((add5 (make-adder 5)))
    (funcall add5 value)))
