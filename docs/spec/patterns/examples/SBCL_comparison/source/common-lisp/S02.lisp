(defun example (items limit)
  (let ((accepted (remove-if-not (lambda (x) (<= 1 x limit)) items)))
    (list accepted (reduce #'+ accepted :initial-value 0)
          (- (length items) (length accepted)))))
