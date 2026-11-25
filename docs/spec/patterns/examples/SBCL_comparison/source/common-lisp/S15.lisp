(defun example (n capacity)
  (multiple-value-bind (full remainder) (floor n capacity)
    (list full remainder (+ full (if (zerop remainder) 0 1))
          (if (zerop remainder) 0 (- capacity remainder)))))
