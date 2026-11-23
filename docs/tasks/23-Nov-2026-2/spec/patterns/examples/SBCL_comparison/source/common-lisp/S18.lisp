(defclass rectangle ()
  ((width :initarg :width :reader width)
   (height :initarg :height :reader height)))

(defclass square ()
  ((side :initarg :side :reader side)))

(defmethod area ((shape rectangle))
  (* (width shape) (height shape)))

(defmethod area ((shape square))
  (* (side shape) (side shape)))

(defun example (width height side)
  (mapcar #'area
          (list (make-instance 'rectangle :width width :height height)
                (make-instance 'square :side side))))
