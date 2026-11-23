(defun example (tree)
  (destructuring-bind (a (b c)) tree
    (+ a (* b c))))
