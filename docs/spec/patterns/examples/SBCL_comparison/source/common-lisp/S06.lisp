(defun example (items)
  (or (position-if #'minusp items) -1))
