(defparameter *scale* 2)

(defun read-scaled (value)
  (* value *scale*))

(defun example (value factor)
  (list (let ((*scale* factor)) (read-scaled value))
        (read-scaled value)))
