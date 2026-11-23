(defmacro with-value ((name expression) &body body)
  `(let ((,name ,expression)) ,@body))

(defun example (value)
  (let ((calls 0))
    (list (with-value (x (progn (incf calls) value)) (+ x x))
          calls)))
