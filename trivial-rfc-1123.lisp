;;;; trivial-rfc-1123.lisp
;;;
;;; Portions ripped out of drakma and are subject to
;;; (c) 2006-2012 Dr. Edmund Weitz, subject to attached license.
;;;
;;; Remaining code is (c) 2015 Stacksmith, subject to attached
;;; BSD 3-clause license (see BSD-LICENSE).

(in-package #:trivial-rfc-1123)
 
(define-condition date-parse-error (error)
  ()
  (:documentation "Signaled when the date cannot be parsed."))

(defun date-parse-error (format-control &rest format-arguments)
  "Signals an error of type DATE-PARSE-ERROR with the provided
format control and arguments."
  (error 'date-parse-error
         :format-control format-control
         :format-arguments format-arguments))

(defun safe-parse-integer (string)
  "Like PARSE-INTEGER, but returns NIL instead of signalling an error."
  (ignore-errors (parse-integer string)))

(defmacro when-letx ((var expr) &body body)
  "Evaluates EXPR, binds it to VAR, and executes BODY if VAR has
a true value."
  `(let ((,var ,expr))
     (when ,var
       ,@body)))

(defvar *time-zone-map*
  ;; list taken from
  ;; <http://www.timeanddate.com/library/abbreviations/timezones/>
  '(("A" . -1)
    ("ACDT" . -10.5)
    ("ACST" . -9.5)
    ("ADT" . 3)
    ("AEDT" . -11)
    ("AEST" . -10)
    ("AKDT" . 8)
    ("AKST" . 9)
    ("AST" . 4)
    ("AWDT" . -9)
    ("AWST" . -8)
    ("B" . -2)
    ("BST" . -1)
    ("C" . -3)
    ("CDT" . 5)
    ("CEDT" . -2)
    ("CEST" . -2)
    ("CET" . -1)
    ("CST" . -10.5)
    ("CST" . -9.5)
    ("CST" . 6)
    ("CXT" . -7)
    ("D" . -4)
    ("E" . -5)
    ("EDT" . 4)
    ("EEDT" . -3)
    ("EEST" . -3)
    ("EET" . -2)
    ("EST" . -11)
    ("EST" . -10)
    ("EST" . 5)
    ("F" . -6)
    ("G" . -7)
    ("GMT" . 0)
    ("H" . -8)
    ("HAA" . 3)
    ("HAC" . 5)
    ("HADT" . 9)
    ("HAE" . 4)
    ("HAP" . 7)
    ("HAR" . 6)
    ("HAST" . 10)
    ("HAT" . 2.5)
    ("HAY" . 8)
    ("HNA" . 4)
    ("HNC" . 6)
    ("HNE" . 5)
    ("HNP" . 8)
    ("HNR" . 7)
    ("HNT" . 3.5)
    ("HNY" . 9)
    ("I" . -9)
    ("IST" . -1)
    ("K" . -10)
    ("L" . -11)
    ("M" . -12)
    ("MDT" . 6)
    ("MESZ" . -2)
    ("MEZ" . -1)
    ("MST" . 7)
    ("N" . 1)
    ("NDT" . 2.5)
    ("NFT" . -11.5)
    ("NST" . 3.5)
    ("O" . 2)
    ("P" . 3)
    ("PDT" . 7)
    ("PST" . 8)
    ("Q" . 4)
    ("R" . 5)
    ("S" . 6)
    ("T" . 7)
    ("U" . 8)
    ("UTC" . 0)
    ("V" . 9)
    ("W" . 10)
    ("WEDT" . -1)
    ("WEST" . -1)
    ("WET" . 0)
    ("WST" . -9)
    ("WST" . -8)
    ("X" . 11)
    ("Y" . 12)
    ("Z" . 0))
  "An alist which maps time zone abbreviations to Common Lisp
timezones.")

(defun interpret-as-month (string)
  "Tries to interpret STRING as a string denoting a month and returns
the corresponding number of the month.  Accepts three-letter
abbreviations like \"Feb\" and full month names likes \"February\".
Finally, the function also accepts strings representing integers from
one to twelve."
  (or (when-letx (pos (position (subseq string 0 (min 3 (length string)))
                               '("Jan" "Feb" "Mar" "Apr" "May" "Jun"
                                       "Jul" "Aug" "Sep" "Oct" "Nov" "Dec")
                               :test #'string-equal))
        (1+ pos))
      (when-letx (num (safe-parse-integer string))
        (when (<= 1 num 12)
          num))))

(defun interpret-as-time-zone (string)
  "Tries to interpret STRING as a time zone abbreviation which can
either be something like \"PST\" or \"GMT\" with an offset like
\"GMT-02:00\"."
  (or (cdr (assoc string *time-zone-map* :test #'string-equal))
      (cl-ppcre:register-groups-bind (sign hours minutes)
	  ("(?:GMT|)\\s*([+-]?)(\\d\\d):?(\\d\\d)" string)
        (* (if (equal sign "-") 1 -1)
           (+ (parse-integer hours)
	      (/ (parse-integer minutes) 60))))
      (date-parse-error "Can't interpret ~S as a time zone." string)))



(defun parse-date (string)
  "Parses a date and returns it as a Lisp universal
time.  Currently understands the following formats:

  \"Wed, 06-Feb-2008 21:01:38 GMT\"
  \"Wed, 06-Feb-08 21:01:38 GMT\"
  \"Tue Feb 13 08:00:00 2007 GMT\"
  \"Wednesday, 07-February-2027 08:55:23 GMT\"
  \"Wed, 07-02-2017 10:34:45 GMT\"

Instead of \"GMT\" time zone abbreviations like \"CEST\" and UTC
offsets like \"GMT-01:30\" are also allowed.
"
  ;; from drakma:
  ;; it seems like everybody and their sister invents their own format
  ;; for this, so (as there's no real standard for it) we'll have to
  ;; make this function more flexible once we come across something
  ;; new; as an alternative we could use net-telent-date, but it also
  ;; fails to parse some of the stuff you encounter in the wild; or we
  ;; could try to employ CL-PPCRE, but that'd add a new dependency
  ;; without making this code much cleaner
  (handler-case 
      (let* ((last-space-pos
              (or (position #\Space string :test #'char= :from-end t)
                  (date-parse-error "Can't parse  date ~S, no space found." string)))
             (time-zone-string (subseq string (1+ last-space-pos)))
             (time-zone (interpret-as-time-zone time-zone-string))
             second minute hour day month year)
	(dolist (part (cl-ppcre:split "[ ,-]" (subseq string 0 last-space-pos)))
          (when (and day month)
            (cond ((every #'digit-char-p part)
                   (when year
                     (date-parse-error "Can't parse date ~S, confused by ~S part."
                                              string part))
                   (setq year (parse-integer part)))
                  ((= (count #\: part :test #'char=) 2)
                   (let ((h-m-s (mapcar #'safe-parse-integer (cl-ppcre:split ":" part))))
                     (setq hour (first h-m-s)
                           minute (second h-m-s)
                           second (third h-m-s))))
                  (t (date-parse-error "Can't parse date ~S, confused by ~S part."
                                              string part))))
          (cond ((null day)
                 (unless (setq day (safe-parse-integer part))               
                   (setq month (interpret-as-month part))))
                ((null month)
                 (setq month (interpret-as-month part)))))
        (unless (and second minute hour day month year)
          (date-parse-error "Can't parse  date ~S, component missing." string))
        (when (< year 100)
          (setq year (+ year 2000)))
        (encode-universal-time second minute hour day month year time-zone))
    (date-parse-error (condition)
      (error condition))))

;;;-----------------------------------------------------------------------------
;;; Wed, 06-Feb-2008 21:01:38
(defparameter +day-names+
    #("Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun"))
(defparameter +month-names+
  #("Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"))
(defun as-rfc-1123 (universal-time &key (stream nil) (timezone 0))
  "format a universal time to string (default) or optional stream, in GMT 
timezone (unless :timezone option is specified, in Lisp sign-inverted manner.
Specifying NIL for timezone will insert machine-local current timezone, which
only makes sense for dealing with current time!"
  ;; Some gymnastics are performed, having to do with sign eating up format
  ;; space, (there is probably a better way, it being Lisp)
  (multiple-value-bind (second minute hour date month year day-of-week ds tz)
      (decode-universal-time universal-time timezone)
    (declare (ignore ds));; Ignoring this - if timezone nil, the user means it..
    (let ((tzout
	   (if (zerop tz)
	       "GMT"
	       (multiple-value-bind (tz-hours tz-fraction) (truncate tz)
		 (format nil "~c~2,'0d~2,'0d"
			 (if (minusp tz)
			     (progn (setf tz-hours (- tz-hours))
				    #\+)
			     #\-) ;; Lisp uses inverted sign
			 tz-hours
			 (truncate (* 60 tz-fraction)))))))
      (format stream "~A, ~2,'0d-~A-~4,'0d ~2,'0d:~2,'0d:~2,'0d ~A"
	      (elt +day-names+ day-of-week)
	      date
	      (elt +month-names+ (1- month))
	      year
	      hour minute second
	      tzout))))
