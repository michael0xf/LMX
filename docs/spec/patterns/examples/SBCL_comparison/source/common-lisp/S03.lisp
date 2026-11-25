(defun example (initial costs)
  (reduce (lambda (state cost)
            (destructuring-bind (remaining accepted rejected) state
              (if (<= cost remaining)
                  (list (- remaining cost) (1+ accepted) rejected)
                  (list remaining accepted (1+ rejected)))))
          costs :initial-value (list initial 0 0)))
