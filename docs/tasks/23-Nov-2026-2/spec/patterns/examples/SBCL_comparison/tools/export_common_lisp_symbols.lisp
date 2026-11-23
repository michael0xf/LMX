;;; Read-only inventory of this implementation's COMMON-LISP external symbols.
;;; No standard variable's value and no function body is evaluated.
(let ((symbols nil))
  (do-external-symbols (symbol (find-package "COMMON-LISP"))
    (push symbol symbols))
  (setf symbols (sort symbols #'string< :key #'symbol-name))
  (format t "{~%  ~S: ~S,~%  ~S: ~S,~%  ~S: ~D,~%  ~S: [~%"
          "implementation" (lisp-implementation-type)
          "version" (lisp-implementation-version)
          "count" (length symbols) "symbols")
  (loop for symbol in symbols
        for first = t then nil
        do (unless first (format t ",~%"))
           (format t "    {~S: ~S, ~S: ~A, ~S: ~A, ~S: ~A, ~S: ~A, ~S: ~A}"
                   "symbol" (symbol-name symbol)
                   "function_binding" (if (fboundp symbol) "true" "false")
                   "macro" (if (macro-function symbol) "true" "false")
                   "special_operator" (if (special-operator-p symbol) "true" "false")
                   "value_binding" (if (boundp symbol) "true" "false")
                   "class" (if (find-class symbol nil) "true" "false")))
  (format t "~%  ]~%}~%"))
