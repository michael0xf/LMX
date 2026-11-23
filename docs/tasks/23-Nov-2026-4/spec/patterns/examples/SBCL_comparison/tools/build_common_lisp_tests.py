#!/usr/bin/env python3
"""Regenerate the executable Common Lisp tests from examples.json."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]

def lisp(value):
    if value is None or value is False:
        return 'nil'
    if value is True:
        return 't'
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, list):
        return '(' + ' '.join(map(lisp, value)) + ')'
    raise TypeError(type(value))

def build():
    data = json.loads((ROOT / 'examples.json').read_text())
    cases = []
    for example in data['examples']:
        checks = ["(equalp (apply #'example '" + lisp(case['args']) + ") '" +
                  lisp(case['expected']) + ")" for case in example['test_cases']]
        checks.extend(example.get('foreign_extra_tests', []))
        cases.append([example['id'], checks])
    body = '''(require :sb-concurrency)
(defpackage #:sbcl-comparison-tests (:use #:cl))
(in-package #:sbcl-comparison-tests)
(defparameter *root* (merge-pathnames "../" *load-truename*))
(defparameter *passed* 0)
(defparameter *failed* 0)
(defparameter *cases* 'TEST_DATA)

(format t "RUNTIME ~A ~A~%" (lisp-implementation-type) (lisp-implementation-version))
(dolist (entry *cases*)
  (destructuring-bind (id checks) entry
    (let* ((name (concatenate 'string "SBCL-COMPARISON-" id))
           (package (or (find-package name) (make-package name :use '(#:cl)))))
      (let ((*package* package))
        (load (merge-pathnames (format nil "source/common-lisp/~A.lisp" id) *root*)
              :verbose nil :print nil)
        (when (string= id "S24")
          (load (merge-pathnames "source/common-lisp/S24_host.lisp" *root*)
                :verbose nil :print nil))
        (loop for expression in checks for index from 1
              do (handler-case
                     (if (eval (read-from-string expression))
                         (progn (incf *passed*) (format t "PASS ~A.~D~%" id index))
                         (progn (incf *failed*) (format t "FAIL ~A.~D ~A~%" id index expression)))
                   (error (condition)
                     (incf *failed*)
                     (format t "ERROR ~A.~D ~A~%" id index condition))))))))
(format t "RESULT passed=~D failed=~D~%" *passed* *failed*)
(sb-ext:exit :code (if (zerop *failed*) 0 1))
'''.replace('TEST_DATA', lisp(cases))
    target = ROOT / 'tools/test_common_lisp.lisp'
    target.write_text(body)
    return sum(len(row[1]) for row in cases)

if __name__ == '__main__':
    print(f'Generated {build()} Common Lisp assertions.')
