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
  (echo "Verifying Gt(A, A) => False")
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
            (> (tA a) (tA a))
            false
          )
        )
      )
    )
  )
  (assert (not phi))
  (check-sat)
(pop)

(push)
  (echo "Verifying Lt(A, A) => False")
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
            (< (tA a) (tA a))
            false
          )
        )
      )
    )
  )
  (assert (not phi))
  (check-sat)
(pop)

(push)
  (echo "Verifying Ne(A, A) => False")
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
            (not (= (tA a) (tA a)))
            false
          )
        )
      )
    )
  )
  (assert (not phi))
  (check-sat)
(pop)

(push)
  (echo "Verifying Ge(A, A) => True")
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
            (>= (tA a) (tA a))
            true
          )
        )
      )
    )
  )
  (assert (not phi))
  (check-sat)
(pop)

(push)
  (echo "Verifying Le(A, A) => True")
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
            (<= (tA a) (tA a))
            true
          )
        )
      )
    )
  )
  (assert (not phi))
  (check-sat)
(pop)

(push)
  (echo "Verifying Eq(A, A) => True")
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
            (= (tA a) (tA a))
            true
          )
        )
      )
    )
  )
  (assert (not phi))
  (check-sat)
(pop)
