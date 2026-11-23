(defun example (items)
  (loop for x in items when (oddp x) sum (* x x)))
