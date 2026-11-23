(defun example (items)
  (remove-duplicates items :from-end t :test #'=))
