(defun example (opening charges credits)
  (let ((charged (apply #'+ charges))
        (credited (apply #'+ credits)))
    (list charged credited (- (+ opening charged) credited))))
