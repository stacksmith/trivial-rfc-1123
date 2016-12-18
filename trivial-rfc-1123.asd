;;;; trivial-rfc-1123.asd

(asdf:defsystem #:trivial-rfc-1123
  :description "minimal parsing of rfc-1123 date-time strings"
  :author "Stacksmith <fpgasm@apple2.x10.mx>"
  :license "Edi Weitz and BSD 3-clause"
  :depends-on (#:cl-ppcre)
  :serial t
  :components ((:file "package")
               (:file "trivial-rfc-1123")))

