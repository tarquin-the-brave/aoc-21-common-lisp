(load "~/quicklisp/setup.lisp")
(ql:quickload '("uiop" "str"))

(defun parse-line (line)
  (str:split " | " line))

(defparameter *input*
  (mapcar #'parse-line (uiop:read-file-lines
                         ; "inputs/day8-example.txt"
                         ; "inputs/day8-test.txt"
                         ; "inputs/day8-test-1.txt"
                         "inputs/day8-1.txt"
                         )))

(defvar *signals* (mapcar #'first *input*))
(defvar *output-values* (mapcar #'second *input*))

; Digit -> number of segments
; 1 -> 2
; 4 -> 4
; 7 -> 3
; 8 -> 7
(defvar *easy-digit-count*
  (let ((n 0))
    (loop for output in *output-values* do
      (loop for elem in (str:words output) do
        (when (member (length elem) '(2 3 4 7)) (incf n))))
    n))

(print *easy-digit-count*)

; Decoding:
;
; number of segements -> digits
;
; 2 -> 1
; 3 -> 7
; 4 -> 4
; 5 -> 2 3 5
; 6 -> 0 6 9
; 7 -> 8

; LHS of input lines has all the signals.
; for each segment in the digit we can deduce a rule to find the letter that
; fills it.  We'll call segments i, j, k, l, m, n, o
;
;  iiii
; j    k
; j    k
;  llll
; m    n
; m    n
;  oooo
;
; (i) => segment in 7 and not 1 => difference between 3-letter-code(ikn) and 2-letter-code(kn)
; (i l o) => intersection of all 5 letter codes
;       (l) => intersection of that with jkln
;       (o) => difference ilo '(i l)
; (i j n o) => intersection of 6 letter codes
; (j n) => difference ijno ilo
; (n) => intersection jn ikn
; (j) => difference jn n
; (m k) => difference (ijklmno) (ilo + jn)
; (k) => intersection mk ikn
; (m) => difference mk k
;
; digits -> segments
; 0 -> ijkmno
; 1 -> kn
; 2 -> iklmo
; 3 -> ilkno
; 4 -> jkln
; 5 -> ijlno
; 6 -> ijlmno
; 7 -> ikn
; 8 -> ijklmno
;
; Find the digit values of the line output by matching the sets to the above.
; Match by checking union is the same length.
;

(defun digits-from-signal (signals) "Returns an list of codes where the index represents the digit"
  (let*
    ((sigs (mapcar (lambda (sig) (coerce sig 'list)) (str:words signals))) ; split signals into segment characters
     ; lists of lists of segments
     (2seg (list))
     (3seg (list))
     (4seg (list))
     (5seg (list))
     (6seg (list))
     (7seg (list))
     ; easy segment sets to find
     (kn (list))
     (ikn (list))
     (jkln (list))
     (ijklmno (list))
     ; letters denote members of set
     (ilo (list))
     (ijno (list))
     (jn (list))
     (mk (list))
     ; single member sets
     (i (list))
     (j (list))
     (k (list))
     (l (list))
     (m (list))
     (n (list))
     (o (list)))

    ; separate the signals by their length
    (loop for sig in sigs do
      (let ((len (list-length sig)))
        ; (print "got a new code")
        ; (print len)
        ; (print sig)
        (cond
          ((= len 2) (if 2seg (push sig 2seg) (setf 2seg (list sig))))
          ((= len 3) (if 3seg (push sig 3seg) (setf 3seg (list sig))))
          ((= len 4) (if 4seg (push sig 4seg) (setf 4seg (list sig))))
          ((= len 5) (if 5seg (push sig 5seg) (setf 5seg (list sig))))
          ((= len 6) (if 6seg (push sig 6seg) (setf 6seg (list sig))))
          ((= len 7) (if 7seg (push sig 7seg) (setf 7seg (list sig))))
        )
        ; (print "2seg")
        ; (print 2seg)

        ; (print "3seg")
        ; (print 3seg)

        ; (print "4seg")
        ; (print 4seg)

        ; (print "5seg")
        ; (print 5seg)

        ; (print "6seg")
        ; (print 6seg)

        ; (print "7seg")
        ; (print 7seg)
        ))

    ; (print "2seg")
    ; (print 2seg)

    ; (print "3seg")
    ; (print 3seg)

    ; (print "4seg")
    ; (print 4seg)

    ; (print "5seg")
    ; (print 5seg)

    ; (print "6seg")
    ; (print 6seg)

    ; (print "7seg")
    ; (print 7seg)

    ; find the easy sets.
    (setf kn (first 2seg))
    ; (print "kn")
    ; (print kn)

    (setf ikn (first 3seg))
    ; (print "ikn")
    ; (print ikn)

    (setf jkln (first 4seg))
    ; (print "jkln")
    ; (print jkln)

    (setf ijklmno (first 7seg))
    ; (print "ijklmno")
    ; (print ijklmno)

    ; sets that require some more algebra
    (setf i (set-difference ikn kn))
    ; (print "i")
    ; (print i)

    (setf ilo (reduce (lambda (acc x) (intersection acc x)) 5seg))
    ; (print "ilo")
    ; (print ilo)

    (setf l (intersection ilo jkln))
    ; (print "l")
    ; (print l)

    (setf o (set-difference ilo (concatenate 'list i l)))
    ; (print "o")
    ; (print o)

    (setf ijno (reduce (lambda (acc x) (intersection acc x)) 6seg))
    ; (print "ijno")
    ; (print ijno)

    (setf jn (set-difference ijno ilo))
    ; (print "jn")
    ; (print jn)

    (setf n (intersection jn ikn))
    ; (print "n")
    ; (print n)

    (setf j (set-difference jn n))
    ; (print "j")
    ; (print j)

    (setf mk (set-difference ijklmno (concatenate 'list ilo jn)))
    ; (print "mk")
    ; (print mk)

    (setf k (intersection mk ikn))
    ; (print "k")
    ; (print k)

    (setf m (set-difference mk k))
    ; (print "m")
    ; (print m)

    (list
      (concatenate 'list i j k m n o)
      (concatenate 'list k n)
      (concatenate 'list i k l m o)
      (concatenate 'list i k l n o)
      (concatenate 'list j k l n)
      (concatenate 'list i j l n o)
      (concatenate 'list i j l m n o)
      (concatenate 'list i k n)
      (concatenate 'list i j k l m n o)
      (concatenate 'list i j k l n o))))

(defun digit (digit-codes output-code) "Finds the matching digit - returned as a character"
  (let
    ((i 0) (ocode (coerce output-code 'list)) (dig nil))
    (setf dig (loop for dcode in digit-codes do
      (if (and
            (= (list-length (set-difference dcode ocode)) 0)
            (= (list-length (set-difference ocode dcode)) 0))
          (return i)
          (incf i))))
    (when dig (digit-char dig))))

(defun output-value (signals output)
  (let
    ((digit-codes (digits-from-signal signals)))
  ; (print digit-codes)
  (parse-integer
    (coerce
      (loop for output-code in (str:words output) collect (output-digit digit-codes output-code))
      'string))))

(defun output-digit (digit-codes output)
  (let ((x (digit digit-codes output)))
    ; (print x)
    x))


(defun score (signals outputs)
  (let ((s 0))
    (loop for sigs in signals for output in outputs do
      ; (print sigs)
      ; (print output)
      ; (print (output-value sigs output)))
      (let ((ov (output-value sigs output)))
        ; (print ov)
        (incf s ov)
        ))
    s))

;
; Part 2
;
(print (score *signals* *output-values*))
; (defvar *sigs1* (first *signals*))
; (defvar *out1* (first *output-values*))

; (print *sigs1*)
; (print *out1*)
