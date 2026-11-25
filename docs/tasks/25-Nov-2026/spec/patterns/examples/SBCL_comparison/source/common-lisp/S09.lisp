(defun example (items start end replacement)
  (let ((updated (replace (copy-list items) replacement :start1 start :end1 end)))
    (list updated (count nil (mapcar #'= updated items))
          (reduce #'+ (mapcar #'- updated items) :initial-value 0))))
