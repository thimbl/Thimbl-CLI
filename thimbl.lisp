(ql:quickload "cl-json")

(defclass collection () 
  ((cursor :initform 0)
   (contents :initform (make-array 2 :fill-pointer 0 :adjustable t))))

(defun do-collection (coll function)
  "For each item in collection COLL, call FUNCTION on it"
  (loop for el across (slot-value coll 'contents) do
        (funcall function  el)))

(defun insert (collection value)
  "Add a value to a collection"
  (vector-push-extend value (slot-value collection 'contents)))
  
(defclass followee ()
  ((nick :initarg :nick)
   (address :initarg :address)))

(defclass post () (to text time))

(defclass plan () 
  ((address :initform "--VERY IMPORTANT--")
   (name :initform "ANON")
   (bio :initform "Just a guy")
   (website :initform "www.example.com")
   (email :initform "foo@example.com")
   (mobile :initform "")
   (following :initform (make-instance 'collection))
   (posts :initform (make-instance 'collection))))

(defvar *me* nil "My plan")
(defun reset-me ()(setf *me* (make-instance 'plan)))
(unless *me* (reset-me))

(defun post (text)
  "Post TEXT"
  (insert (slot-value *me* 'posts) text))

(post "hello world")

(defun follow (nick address)
  "Follow someone with nickname NICK and finger address ADDRESS"
  (insert (slot-value *me* 'following) 
          (make-instance 'followee :nick nick :address address)))

(defgeneric display (object)
  (:documentation "Generic method for displaying an object"))

(defmethod display ((f followee))
  (format t "~a~10t~a ~%" 
          (slot-value f 'nick) 
          (slot-value f 'address)))

(defmethod display ((p plan))
  (format t "~a~10t~a ~%" 
          (slot-value p 'bio) 
          (slot-value p 'address)))


(defun following ()
  "Print information about who I am following"
  (do-collection (slot-value *me* 'following) #'display))



(defun plans ()
  "Print information about the plans in the database"
  (do-collection *plans* #'display))

;(setf f (make-instance 'followee :nick "foo" :address "bar"))
(follow "mike" "mike@mikepearce.net")
(follow "dk" "dk@telekommunisten.org")
(follow "ashull" "ashull@telekommunisten.org")
(following)
(plans)


(defvar *plans* nil "All the plans: including me")
(defun reset-plans () 
  (setf *plans* (make-instance 'collection))
  (insert *plans* *me*))

(unless *plans* (reset-plans))



(defun run-finger (user)
  (run-program "finger" 
               :arguments (list user) :output :stream :wait t))

(defun finger (user)
  "Call the external finger program on USER, and return its result"
  (with-open-stream (stream (run-finger user))
    (loop :for line = (read-line stream nil nil)
       :while line :collect line)))

(defun plan-lines (finger-lines)
  "Given a list of lines returned by finger, , extract the lines after the plan"
  (cdr (member "Plan:" finger-lines :test #'equalp)))


(defun finger-to-plan (user)
  "Given a user-name, finger him, and convert the output to lines of a plan"
  (plan-lines (finger user)))

(defun lines-to-string (lines)
  "Convert a list of strings to a single string, separated by newlines"
  (format nil "~{~A~%~}" lines))

(defun finger-to-json (user)
  "Finger a user, returning his plan as a json structure"
  (let* ((lines (finger-to-plan user))
         (string (lines-to-string lines)))
        (json:decode-json-from-string string)))

(defun get-value (symbol list)
  "Get a value associated with a list"
  (assoc symbol list))



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
  (getf plan :address))

(defun print-messages ( &optional (plans *plans*))
  "Print all the messages in all PLANS. 
Use global plans if argument not specified"
  (terpri)
  (loop for plan in plans do
        (loop with address = (plan-key  plan)
              for message in (get-value :messages  plan) do
              (print-message address message))))

(defun store-plan (plan)
  "Insert/replace a plan into the global plans collection"
  (pushnew plan *plans* :key #'plan-key))


(defun address-lambda (address)
  (lambda (x) (equalp (plan-key x) address)))

(defun drop-plan (address)
  (setf *plans* (remove-if (address-lambda address) *plans*))
  (when (equalp *me* address)
    (setf *me* nil)))

(defun find-plan (address)
  (find-if (address-lambda address) *plans*))

(defun fetch (address)
  "Finger ADDRESS, and add the information to the plans"
  "FIXME")
  

  
(setf json (finger-to-json "dk@telekommunisten.org"))
; (saveinitmem)
(setf c (make-instance 'collection))
(add c 42)
