(defun example (items start end replacement)
  (replace (copy-list items) replacement :start1 start :end1 end))
