(defun example (items)
  (let* ((bad (position-if #'minusp items))
         (accepted (subseq items 0 (or bad (length items)))))
    (list accepted (reduce #'+ accepted :initial-value 0) (or bad -1))))
