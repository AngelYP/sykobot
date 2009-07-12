;;;; Copyright 2009 Kat Marchan
;;;;
;;;; This file is part of sykobot.
;;;;
;;;; For licensing and warranty information, refer to COPYING
;;;;
;;;; code in this file is largely based on clikibot's chant routine.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(in-package :sykobot)

;; general-purpose util functions/macros/etc go here

(defmacro with-gensyms (vars &body body)
  `(let ,(loop for x in vars collect `(,x (gensym)))
     ,@body))

(defun build-string (&rest data)
  ;; This first form is just to catch idiotic code.
  ;; It should be removed from "out-of-the-box" sykobot distros.
  (when (and (stringp (car data))
             (string-equal (car data) "~A"))
    (error "BUILD-STRING is being called like FORMAT.~@
            Please rewrite this call and join the sensation."))
  (cond ((null data) "")
	((not (stringp (car data)))
	 (warn "Ignoring datum ~A." (car data))
	 (apply #'build-string (cdr data)))
	((unless (scan "~[:@]{0,2}\\n" (car data))
	   (null (cdr data)))
	 (format nil "~A" (car data)))
	(T (apply #'format nil data))))

(defmacro do-lines ((var string &optional result) &body body)
  (with-gensyms (stream)
    `(with-input-from-string (,stream ,string)
       (loop for ,var = (read-line ,stream nil)
          while ,var ,@body
          finally (return ,result)))))

(defun random-elt (sequence)
  (let ((l (length sequence)))
    (if (zerop l)
        nil
        (elt sequence (random (length sequence))))))

(defun hash-table-keys (table)
  (loop for key being the hash-keys of table collect key))

;;; NOTE: Don't use '\' in the separator, it fails.
(defun merge-strings (separator &rest strings)
  (build-string (build-string "~~{~~A~~^~A~~}"
                              (regex-replace-all "~" separator "~~"))
                strings))

(defun flatten (x)
  "Flattens a list."
  (labels ((rec (x acc)
             (cond ((null x) acc)
                   ((atom x) (cons x acc))
                   (t (rec (car x) (rec (cdr x) acc))))))
    (rec x nil)))

