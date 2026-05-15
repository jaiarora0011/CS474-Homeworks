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

;; Rewrites involving Tensor Comparison
(push)
  (echo "Verifying Gt(A, A) => False")
  (declare-const s (Array Int Int))
  (declare-const a (Array Int Int))
  (declare-fun tA ((Array Int Int)) Real)

  (define-fun lhsShape () (Array Int Int)
    s
  )

  (define-fun rhsShape () (Array Int Int)
    s
  )

  (define-fun precondition () Bool
    true
  )

  (define-fun lhsValid () Bool
    (validShape lhsShape)
  )

  (define-fun lhsAccessValid () Bool
    (and
      (validAccess a lhsShape)
      (validAccess a s)
    )
  )

  (define-fun rhsValid () Bool
    (validShape rhsShape)
  )

  (define-fun rhsAccessValid () Bool
    (validAccess a rhsShape)
  )

  (define-fun rewriteValid () Bool
    (=
      (> (tA a) (tA a))
      false
    )
  )

  (define-fun phi () Bool
    (=>
      (and
        precondition
        lhsValid
        lhsAccessValid
      )
      (and
        (= lhsShape rhsShape)
        rhsValid
        rhsAccessValid
        rewriteValid
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

  (define-fun lhsShape () (Array Int Int)
    s
  )

  (define-fun rhsShape () (Array Int Int)
    s
  )

  (define-fun precondition () Bool
    true
  )

  (define-fun lhsValid () Bool
    (validShape lhsShape)
  )

  (define-fun lhsAccessValid () Bool
    (and
      (validAccess a lhsShape)
      (validAccess a s)
    )
  )

  (define-fun rhsValid () Bool
    (validShape rhsShape)
  )

  (define-fun rhsAccessValid () Bool
    (validAccess a rhsShape)
  )

  (define-fun rewriteValid () Bool
    (=
      (< (tA a) (tA a))
      false
    )
  )

  (define-fun phi () Bool
    (=>
      (and
        precondition
        lhsValid
        lhsAccessValid
      )
      (and
        (= lhsShape rhsShape)
        rhsValid
        rhsAccessValid
        rewriteValid
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

  (define-fun lhsShape () (Array Int Int)
    s
  )

  (define-fun rhsShape () (Array Int Int)
    s
  )

  (define-fun precondition () Bool
    true
  )

  (define-fun lhsValid () Bool
    (validShape lhsShape)
  )

  (define-fun lhsAccessValid () Bool
    (and
      (validAccess a lhsShape)
      (validAccess a s)
    )
  )

  (define-fun rhsValid () Bool
    (validShape rhsShape)
  )

  (define-fun rhsAccessValid () Bool
    (validAccess a rhsShape)
  )

  (define-fun rewriteValid () Bool
    (=
      (not (= (tA a) (tA a)))
      false
    )
  )

  (define-fun phi () Bool
    (=>
      (and
        precondition
        lhsValid
        lhsAccessValid
      )
      (and
        (= lhsShape rhsShape)
        rhsValid
        rhsAccessValid
        rewriteValid
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

  (define-fun lhsShape () (Array Int Int)
    s
  )

  (define-fun rhsShape () (Array Int Int)
    s
  )

  (define-fun precondition () Bool
    true
  )

  (define-fun lhsValid () Bool
    (validShape lhsShape)
  )

  (define-fun lhsAccessValid () Bool
    (and
      (validAccess a lhsShape)
      (validAccess a s)
    )
  )

  (define-fun rhsValid () Bool
    (validShape rhsShape)
  )

  (define-fun rhsAccessValid () Bool
    (validAccess a rhsShape)
  )

  (define-fun rewriteValid () Bool
    (=
      (>= (tA a) (tA a))
      true
    )
  )

  (define-fun phi () Bool
    (=>
      (and
        precondition
        lhsValid
        lhsAccessValid
      )
      (and
        (= lhsShape rhsShape)
        rhsValid
        rhsAccessValid
        rewriteValid
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

  (define-fun lhsShape () (Array Int Int)
    s
  )

  (define-fun rhsShape () (Array Int Int)
    s
  )

  (define-fun precondition () Bool
    true
  )

  (define-fun lhsValid () Bool
    (validShape lhsShape)
  )

  (define-fun lhsAccessValid () Bool
    (and
      (validAccess a lhsShape)
      (validAccess a s)
    )
  )

  (define-fun rhsValid () Bool
    (validShape rhsShape)
  )

  (define-fun rhsAccessValid () Bool
    (validAccess a rhsShape)
  )

  (define-fun rewriteValid () Bool
    (=
      (<= (tA a) (tA a))
      true
    )
  )

  (define-fun phi () Bool
    (=>
      (and
        precondition
        lhsValid
        lhsAccessValid
      )
      (and
        (= lhsShape rhsShape)
        rhsValid
        rhsAccessValid
        rewriteValid
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

  (define-fun lhsShape () (Array Int Int)
    s
  )

  (define-fun rhsShape () (Array Int Int)
    s
  )

  (define-fun precondition () Bool
    true
  )

  (define-fun lhsValid () Bool
    (validShape lhsShape)
  )

  (define-fun lhsAccessValid () Bool
    (and
      (validAccess a lhsShape)
      (validAccess a s)
    )
  )

  (define-fun rhsValid () Bool
    (validShape rhsShape)
  )

  (define-fun rhsAccessValid () Bool
    (validAccess a rhsShape)
  )

  (define-fun rewriteValid () Bool
    (=
      (= (tA a) (tA a))
      true
    )
  )

  (define-fun phi () Bool
    (=>
      (and
        precondition
        lhsValid
        lhsAccessValid
      )
      (and
        (= lhsShape rhsShape)
        rhsValid
        rhsAccessValid
        rewriteValid
      )
    )
  )

  (assert (not phi))
  (check-sat)
(pop)
