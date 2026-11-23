(defpackage #:lmx-sbcl-reference
  (:use #:cl)
  (:export #:map-values #:filter-values #:compress-values #:fold-values #:zip-with-values
           #:any-value #:all-value #:index-value #:record-value
           #:sort-values #:unique-values #:replace-range
           #:partial-values #:memoize-values))
(in-package #:lmx-sbcl-reference)

(defun sequence-value (value)
  (check-type value sequence)
  value)

(defun function-value (value)
  (check-type value function)
  value)

(defun integer-truth (value)
  (check-type value integer)
  (not (zerop value)))

(defun snapshot (items)
  (sequence-value items)
  (let* ((size (length items)) (out (make-array size)))
    (loop for item across (coerce items 'vector)
          for i from 0 do (setf (aref out i) item))
    out))

(defun same-profile (source items)
  (if (listp source)
      (coerce items 'list)
      (let ((out (make-array (length items)
                             :element-type (array-element-type source))))
        (dotimes (i (length items) out)
          (setf (aref out i) (aref items i))))))

(defun checked-bounds (size begin end)
  (check-type begin integer)
  (check-type end integer)
  (unless (<= 0 begin end size)
    (error "Sequence bounds: ~D ~D ~D" size begin end))
  (- end begin))
