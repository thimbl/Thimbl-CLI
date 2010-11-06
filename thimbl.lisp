(defvar *plans* nil "All the plans: us and others")

(defun run-finger (user)
  (run-program "finger" 
               :arguments (list user) :output :stream :wait t))

(defun finger (user)
  (with-output-to-string 
    (out)
    (with-open-stream (stream (run-finger user))
                      (do ((x (read-char stream nil stream) 
                              (read-char stream nil stream)))
                          ((eq x stream))
                          (write-char x out))
                      out)))

(defun finger-output-to-plan (finger-output-text)
  "Convert raw text provided by finger and obtain its plan"
  (let (re plan)
    (setf re (cl-ppcre:create-scanner "^.*Plan:\\s*"  :single-line-mode t))
    (setf plan (cl-ppcre:regex-replace re finger-output-text ""))
    plan))

(defun finger-to-plan (user)
  "Obtain a user-name, finger him, and convert the output to a plan"
  (let (raw)
    (setf raw (finger user))
    (finger-output-to-plan raw)))


(defun finger-to-json (user)
  "Finger a user, returning his plan as a json structure"
  (setf plan (finger-to-plan user))
  (json:decode-json-from-string plan))


(defun print-followings (plan)
  "Print bio, name and properties associated with a plan"
  (terpri)
  (let ((fmt "~5a ~10a ~20a~%"))
    (format t fmt "IDX" "NICK" "ADDRESS")
    (loop with idx = 0 with nick with address 
          for followee in (cdr (assoc :following plan)) do
        
          (incf idx)
          (setf nick (cdr (assoc :nick followee)))
          (setf address (cdr (assoc :address followee)))
          (format t fmt idx nick address)))
  (terpri))

; FIXME use more extensively
(defun get-value (symbol list)
  "Get a value associated with a list"
  (cdr (assoc symbol list)))

(defun print-message (address message)

  (let ((text (get-value :text message))
        (time (get-value :time message))
        year month day hour min sec)
    (setf time (write-to-string time))
    ;(break)
    (setf year (subseq time 0 4))
    (setf month (subseq time 4 6))
    (setf day (subseq time 6 8))
    (setf hour (subseq time 8 10))
    (setf min (subseq time 10 12))
    (setf sec (subseq time 12 14))
    (setf time (format nil "~a-~a-~a ~a:~a:~a" year month day hour min sec))
    (format t "~a ~a~%~a~%~%" time address text)))

(defun print-messages (plans)
  "Print all the messages in all plans"
  (terpri)
  (loop for plan in plans do
        (loop with address = (get-value :email (get-value :properties plan))
              for message in (get-value :messages  plan) do
              (print-message address message))))


;(setf json (finger-to-json "dk@telekommunisten.org"))
(print-followings (first *plans*))
(print-messages *plans*)
; (finger-to-json "foo")
; (saveinitmem)