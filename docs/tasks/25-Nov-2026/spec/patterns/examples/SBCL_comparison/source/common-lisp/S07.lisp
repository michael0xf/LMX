(defun example (items limit)
  (let* ((ordered (stable-sort (copy-list items) #'< :key #'first))
         (selected (subseq ordered 0 (min limit (length ordered)))))
    (list selected (- (length items) (length selected)))))
