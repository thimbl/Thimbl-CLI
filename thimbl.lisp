(defvar *plans* nil "All the plans: us and others")

(defun run-finger (user)
  (run-program "finger" 
               :arguments (list user) :output :stream :wait t))

(defun finger (user)
  "Call the external finger program on USER, and return its result"
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

(defun get-value (symbol list)
  "Get a value associated with a list"
  (cdr (assoc symbol list)))

(defun print-followings (plan)
  "Print bio, name and properties associated with a plan"
  (terpri)
  (let ((fmt "~5a ~10a ~20a~%"))
    (format t fmt "IDX" "NICK" "ADDRESS")
    (loop with idx = 0 with nick with address 
          for followee in (get-value :following plan) do
        
          (incf idx)
          (setf nick (get-value :nick followee))
          (setf address (get-value :address followee))
          (format t fmt idx nick address)))
  (terpri))


(defun print-message (address message)
  (let* ((text (get-value :text message))
         (time (get-value :time message))
         (time-text (write-to-string time))
         (time-elements (loop for i from 0 to 12 by 2
                              collect (subseq time-text i (+ 2 i))))
         (formatted-time (format nil  "~{~a~a-~a-~a ~a:~a:~a~}"
                                 time-elements)))    
    (format t "~a    ~a~%~a~%~%" formatted-time address text)))


(defun plan-key (plan)
  "Return a unique key identifying a plan"
  (get-value :email (get-value :properties plan)))

(defun print-messages ( &optional (plans *plans*))
  "Print all the messages in all PLANS. 
Use global plans if argument not specified"
  (terpri)
  (loop for plan in plans do
        (loop with address = (plan-key  plan)
              for message in (get-value :messages  plan) do
              (print-message address message))))

(defun store-plan-into-global (plan)
  "Insert/replace a plan into the global plans collection"
  (pushnew plan *plans* :key #'plan-key))

;(setf json (finger-to-json "dk@telekommunisten.org"))
(print-followings (first *plans*))
(print-messages *plans*)
; (finger-to-json "foo")
; (saveinitmem)