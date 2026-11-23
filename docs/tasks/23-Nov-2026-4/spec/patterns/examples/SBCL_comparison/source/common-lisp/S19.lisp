(defclass rectangle ()
  ((width :initarg :width :accessor width)
   (height :initarg :height :accessor height)))

(defun example (width height new-width)
  (let ((shape (make-instance 'rectangle :width width :height height)))
    (setf (width shape) new-width)
    (list (width shape) (height shape) (* (width shape) (height shape)))))
