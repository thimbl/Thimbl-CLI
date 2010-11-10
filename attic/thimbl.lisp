(ql:quickload "cl-json")


(defvar *vfs* nil "a virtual file system")





(defgeneric display (object)
  (:documentation "Generic method for displaying an object"))

(defun display-slots (fmt obj slot-names)
  (format t fmt (loop for slot-name in slot-names collect (slot-value obj slot-name))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; collection object

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; followee object
 
(defclass followee ()
  ((nick :initarg :nick)
   (address :initarg :address)))

(defmethod display ((f followee)) (display-slots "~{~10a~a~%~}" f '(nick address)))

(defun follow (nick address)
  "Follow someone with nickname NICK and finger address ADDRESS"
  (insert (slot-value *me* 'following) 
          (make-instance 'followee :nick nick :address address)))

(defun following ()
  "Print information about who I am following"
  (do-collection (slot-value *me* 'following) #'display))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; post object

(defclass post () 
  ((to :initarg :to)
   (text :initarg :text)
   (time :initarg :time)))

(defmethod display ((p post)) (display-slots "~{~12a~15a~50a~%~}" p '(to time text)))

(defun posts (plan)
  (do-collection (slot-value plan 'posts) #'display))

(defun post (text)
  "Post TEXT"
  (insert (slot-value *me* 'posts) (make-instance 'post :time 666 :text text)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; plan object

(defclass plan () 
  ((address :reader address :writer set-address :initform "--VERY IMPORTANT--" )
   (name :initform "ANON")
   (bio :initform "Just a guy")
   (website :initform "www.example.com")
   (email :initform "foo@example.com")
   (mobile :initform "")
   (following :initform (make-instance 'collection))
   (posts :initform (make-instance 'collection))))

; (address plan) , or (set-address value plan)


(defmethod display ((p plan)) (display-slots "~{~20a~a~%~}" p '(address bio)))


(defvar *me* nil "My plan")
(defun reset-me ()(setf *me* (make-instance 'plan)))
(unless *me* (reset-me))

(defvar *plans* nil "All the plans: including me")
(defun reset-plans () 
  (setf *plans* (make-instance 'collection))
  (reset-me)
  (insert *plans* *me*))
(unless *plans* (reset-plans))





(post "hello world")















(defun plans ()
  "Print information about the plans in the database"
  (do-collection *plans* #'display))

;(setf f (make-instance 'followee :nick "foo" :address "bar"))
(follow "mike" "mike@mikepearce.net")
(follow "dk" "dk@telekommunisten.org")
(follow "ashull" "ashull@telekommunisten.org")
(following)
(plans)



(posts *me*)






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

(setf json (finger-to-json "dk@telekommunisten.org"))


(defun json-to-fs (json)
  "Convert a json structure to a file system"
  (print json)
  (if (atom (car json))
      (let ((rest (cdr json)))
        (if (atom rest)
            rest
      (if (atom 
  (if (atom json) 
      json
    (progn 
      (print (car json))

      (if (keywordp (car json))
          (let ((vector (make-array 2 :fill-pointer 0 :adjustable t)))
            (loop for el in (cdr json) do
                  (print "vector")
                  (vector-push-extend (json-to-fs el) vector))
            vector)

        (progn
          (if (car json)
              (let ((table (make-hash-table)))
                (loop for  el in json do
                      (print "hash")
                      (print (cdr el))
                      (setf (gethash (car el) table) (json-to-fs (cdr el))))
                table)
            (error "Unexpect type")))))))
        

;(setf tree (json-to-fs json))

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
  

  

; (saveinitmem)
(setf c (make-instance 'collection))
(add c 42)
