(defun example (items)
  (let ((cache (make-hash-table :test #'eql)) (calls 0))
    (flet ((square (x)
             (multiple-value-bind (value present) (gethash x cache)
               (if present value
                   (progn (incf calls)
                          (setf (gethash x cache) (* x x)))))))
      (list (mapcar #'square items) calls))))
