(defun example (items)
  (stable-sort (copy-list items) #'< :key #'first))
