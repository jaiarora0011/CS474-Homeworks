; Utility Functions for defining rewrites
(define-fun zeroArr () (Array Int Int)
  ((as const (Array Int Int)) 0)
)

(define-fun oneArr () (Array Int Int)
  ((as const (Array Int Int)) 1)
)

(define-fun twoArr () (Array Int Int)
  ((as const (Array Int Int)) 2)
)

; Asserts that all elements of the array are equal to a constant value
(define-fun constPre ((a (Array Int Int)) (v Int)) Bool
  (=
    a
    ((as const (Array Int Int)) v)
  )
)

; Asserts that all elements of the array are less than or equal to elements of another array
(define-fun leqPre ((a (Array Int Int)) (b (Array Int Int))) Bool
  (=
    ((_ map (<= (Int Int) Int)) a b)
    ((as const (Array Int Bool)) true)
  )
)

; Asserts that all elements of the array are less than elements of another array
(define-fun ltPre ((a (Array Int Int)) (b (Array Int Int))) Bool
  (=
    ((_ map (< (Int Int) Int)) a b)
    ((as const (Array Int Bool)) true)
  )
)

(define-fun validShape ((s (Array Int Int))) Bool
  (leqPre zeroArr s)
)

(define-fun validAccess ((a (Array Int Int)) (s (Array Int Int))) Bool
  (and
    (leqPre zeroArr a)
    (ltPre a s)
  )
)

;; Rewrites involving Tensor Addition
(push)
  (echo "Verifying Add(Add(A, c1), c2) => Add(A, Add(c1, c2))")
  (declare-const c1 Real)
  (declare-const c2 Real)
  (declare-const s (Array Int Int))
  (declare-const a (Array Int Int))
  (declare-fun tA ((Array Int Int)) Real)
  (define-fun phi () Bool
    (=>
      (validShape s)
      (=>
        (validAccess a s)
        (and
          (= s s)
          (validShape s)
          (validAccess a s)
          (=
            (+ (+ (tA a) c1) c2)
            (+ (tA a) (+ c1 c2))
          )
        )
      )
    )
  )
  (assert (not phi))
  (check-sat)
(pop)

(push)
  (echo "Verifying Add(A, 0) => A")
  (declare-const s (Array Int Int))
  (declare-const a (Array Int Int))
  (declare-fun tA ((Array Int Int)) Real)
  (define-fun phi () Bool
    (=>
      (validShape s)
      (=>
        (validAccess a s)
        (and
          (= s s)
          (validShape s)
          (validAccess a s)
          (= (+ (tA a) 0) (tA a))
        )
      )
    )
  )
  (assert (not phi))
  (check-sat)
(pop)

(push)
  (echo "Verifying Add(0, A) => A")
  (declare-const s (Array Int Int))
  (declare-const a (Array Int Int))
  (declare-fun tA ((Array Int Int)) Real)
  (define-fun phi () Bool
    (=>
      (validShape s)
      (=>
        (validAccess a s)
        (and
          (= s s)
          (validShape s)
          (validAccess a s)
          (= (+ 0 (tA a)) (tA a))
        )
      )
    )
  )
  (assert (not phi))
  (check-sat)
(pop)

(push)
  (echo "Verifying Add(c, A) => Add(A, c)")
  (declare-const c Real)
  (declare-const s (Array Int Int))
  (declare-const a (Array Int Int))
  (declare-fun tA ((Array Int Int)) Real)
  (define-fun phi () Bool
    (=>
      (validShape s)
      (=>
        (validAccess a s)
        (and
          (= s s)
          (validShape s)
          (validAccess a s)
          (= (+ c (tA a)) (+ (tA a) c))
        )
      )
    )
  )
  (assert (not phi))
  (check-sat)
(pop)
