(define-fun nonNegative ((s Int)) Bool
  (>= s 0)
)

(define-fun validShape ((s (Array Int Int))) Bool
  (= 
    ((_ map nonNegative) s)
    ((as const (Array Int Bool)) true)
  )
)

(define-fun inRange ((a Int) (s Int)) Bool
  (and
    (>= a 0)
    (< a s)
  )
)

(define-fun validAccess ((a (Array Int Int)) (s (Array Int Int))) Bool
  (=
    ((_ map inRange) a s)
    ((as const (Array Int Bool)) true)
  )
)

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
