(defun example (n)
  (labels ((fact (k)
             (if (zerop k) 1 (* k (fact (1- k))))))
    (fact n)))
