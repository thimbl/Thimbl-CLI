(ql:quickload "cl-json")
;(ql:quickload "yason")
;(ql:system-apropos "json")
;(ql:quickload "st-json")
(declaim (optimize (debug 3) (safety 3) (speed 0) (space 0)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; finger




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

;(setf json (finger-to-json "dk@telekommunisten.org"))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar *me* '((:bio . "My bio")
               (:name . "My Name")
               (:messages)
               (:replies)
               (:following)
               (:properties (:website . "http://www.example.com")
                            (:mobile . "N/A")
                            (:email . "foo@example.com"))))

(defun setup (address bio name website mobile email)
  (setf *me* `((:bio . ,bio) 
               (:name . ,name)
               (:messages )
               (:replies )
               (:following )
               (:properties (:website . ,website)
                            (:mobile . ,mobile)
                            (:email . ,email)))))

; to get a value: (assoc :bio *me*)
; to se a value: (acons :bio "foo" *me*) XXX
; to set a value:
;    (setf alist (acons 'new-key 'new-value alist))
; or
;    (push (cons 'new-key 'new-value) alist)


;(post "foo")
;(post "bar")

(defmacro with-element (var element plan &body body)
  `(symbol-macrolet ((,var (cdr (assoc ,element ,plan))))
                    ,@body))

(defun now-as-int ()
  "Return the time now as an integer"
  (loop for i from 0 to 5
        for v in (multiple-value-list (get-decoded-time))
        summing (* (expt 100 i) v)))


(defun post (message)
  (with-element msgs :messages *me*
                (push `((:text . ,message) (:time . ,(now-as-int))) msgs))
  t)

(post "using another macro")


 
(defun follow (address &optional (nick ""))
  (with-element follows :following *me*
                (pushnew `((:nick . ,nick) (:address . ,address)) 
                         follows :test #'equalp)) ; FIXME SORT OUT CASE SAME ADDRESS, DIFFERENT NICK
  t)

;(follow "dk@telekommunisten.net" "dk")
  
#|
(setup "ossa@numo.strangled.net" "Rumour Goddess" "Ossa" "http://nummo.strangled.net" "N/A" "ossa@numo.strangled.net")
|#

(defun who-do-i-follow ()
  (with-element follows :following *me*
                (loop for f in follows
                      collect (cadadr f))))

(defvar *plans* nil)

(defun fetch ()
  (setf *plans* (loop for f in (who-do-i-follow)
                      collect (finger-to-json f))))
;(fetch)
        
                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(follow "mike" "mike@mikepearce.net")
(follow "dk" "dk@telekommunisten.org")
(follow "ashull" "ashull@telekommunisten.org")

; (saveinitmem)

