(in-package #:lmx-sbcl-reference)

(defun partial-values (operation arity prefix)
  (function-value operation)
  (check-type arity (integer 0 *))
  (sequence-value prefix)
  (let* ((captured (coerce (snapshot prefix) 'list))
         (remaining (- arity (length captured))))
    (when (minusp remaining) (error "Prefix exceeds positional arity"))
    (lambda (&rest actuals)
      (unless (= (length actuals) remaining)
        (error "Expected ~D residual arguments, got ~D"
               remaining (length actuals)))
      (apply operation (append captured actuals)))))
