(in-package :weblocks-utils)

(defun first-active-session ()
  "Returns first active session of current webapp, needs bound weblocks::*current-webapp*"
  (first (weblocks::active-sessions)))

(defun debug-session (session &optional (output-stream t))
  "Shows debug information from session, maybe redirecting it to some stream"
  (maybe-with-first-active-webapp 
    (let ((session-data (weblocks::webapp-session-hash session)))
      (loop for i from 1
            for key being the hash-key of session-data 
            for value being the hash-value of session-data 
            do 
            (format output-stream "~A ~A~%~A~%~%" i key (prin1-to-string value))))))

(defun debug-first-session (&optional (output-stream t))
  "Shows debug information in first active session of first active webapp, see also debug-session"
  (debug-session (first-active-session) output-stream))

(defun debug-single-session (&optional (output-stream t))
  "Same as debug-first session except it shows warning when there are more than one session"
  (when (> (length (weblocks::active-sessions)) 1)
    (warn "There are more than one sessions"))
  (debug-first-session output-stream))

(defun enter-first-active-session ()
  (in-session (hunchentoot:session-id (first-active-session))))

(defmacro with-first-active-session (&body body)
  `(progn 
     (enter-first-active-session)
     ,@body))

(defun find-session-by-id (id)
  (loop for i in (weblocks::active-sessions)
        do (when (equal id (hunchentoot:session-id i))
             (return-from find-session-by-id i))))

(defmacro with-active-session-by-id ((id) &body body)
  `(progn 
     (in-session (hunchentoot:session-id (find-session-by-id ,id)))
     ,@body))
