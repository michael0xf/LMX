(defun area (&key (width 1) (height 1))
  (* width height))

(defun example (width height)
  (list (area :height height :width width)
        (area :width width)))
