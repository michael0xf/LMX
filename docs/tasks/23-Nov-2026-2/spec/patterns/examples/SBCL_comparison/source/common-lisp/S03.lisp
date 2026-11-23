(defun example (items)
  (reduce #'- items :initial-value 20))
