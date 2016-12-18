;;;; package.lisp

(defpackage #:trivial-rfc-1123
  (:nicknames :t1123)
  (:use #:cl)
  (:export :parse-date
	   :as-rfc-1123))


