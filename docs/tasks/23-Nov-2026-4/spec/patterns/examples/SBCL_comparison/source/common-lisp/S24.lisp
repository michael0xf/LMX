(require :sb-concurrency)

(defun worker (inbox)
  (loop for message = (sb-concurrency:receive-message inbox)
        until (eq message :stop)
        sum message))

(defun produce (inbox items)
  (dolist (item items) (sb-concurrency:send-message inbox item))
  (sb-concurrency:send-message inbox :stop))
