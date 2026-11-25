(defun example (items gain offset)
  (let ((calibrated (mapcar (lambda (x) (+ (* x gain) offset)) items)))
    (list calibrated (reduce #'+ calibrated :initial-value 0))))
