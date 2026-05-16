; Declare a sort for dimension labels, one for each aggregated axis.
; This allows us to reason about maps with symbolic dimension labels, instead of integer dimension numbers (which make the arrays unbounded).
; So all attribute arrays are now of type (Array Dim Int) instead of (Array Int Int).
(declare-sort Dim 0)

; Utility Functions for defining rewrites
(define-fun zeroArr () (Array Dim Int)
  ((as const (Array Dim Int)) 0)
)

(define-fun oneArr () (Array Dim Int)
  ((as const (Array Dim Int)) 1)
)

(define-fun twoArr () (Array Dim Int)
  ((as const (Array Dim Int)) 2)
)

; Asserts that all elements of the array are equal to a constant value
(define-fun constPre ((a (Array Dim Int)) (v Int)) Bool
  (=
    a
    ((as const (Array Dim Int)) v)
  )
)

; Asserts that all elements of the array are less than or equal to elements of another array
(define-fun leqPre ((a (Array Dim Int)) (b (Array Dim Int))) Bool
  (=
    ((_ map (<= (Int Int) Int)) a b)
    ((as const (Array Dim Bool)) true)
  )
)

; Asserts that all elements of the array are less than elements of another array
(define-fun ltPre ((a (Array Dim Int)) (b (Array Dim Int))) Bool
  (=
    ((_ map (< (Int Int) Int)) a b)
    ((as const (Array Dim Bool)) true)
  )
)

(define-fun validShape ((s (Array Dim Int))) Bool
  (leqPre zeroArr s)
)

(define-fun validAccess ((a (Array Dim Int)) (s (Array Dim Int))) Bool
  (and
    (leqPre zeroArr a)
    (ltPre a s)
  )
)

;; Rewrites involving Tensor Comparison
;; Rules taken from https://github.com/ADAPT-uiuc/TensorRight/blob/master/rules/xla/compare/Main.hs
(push)
  (echo "Verifying Gt(A, A) => False")
  (declare-const s (Array Dim Int))
  (declare-const a (Array Dim Int))
  (declare-fun tA ((Array Dim Int)) Real)

  (define-fun lhsShape () (Array Dim Int)
    s
  )

  (define-fun rhsShape () (Array Dim Int)
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
  (declare-const s (Array Dim Int))
  (declare-const a (Array Dim Int))
  (declare-fun tA ((Array Dim Int)) Real)

  (define-fun lhsShape () (Array Dim Int)
    s
  )

  (define-fun rhsShape () (Array Dim Int)
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
  (declare-const s (Array Dim Int))
  (declare-const a (Array Dim Int))
  (declare-fun tA ((Array Dim Int)) Real)

  (define-fun lhsShape () (Array Dim Int)
    s
  )

  (define-fun rhsShape () (Array Dim Int)
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
  (declare-const s (Array Dim Int))
  (declare-const a (Array Dim Int))
  (declare-fun tA ((Array Dim Int)) Real)

  (define-fun lhsShape () (Array Dim Int)
    s
  )

  (define-fun rhsShape () (Array Dim Int)
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
  (declare-const s (Array Dim Int))
  (declare-const a (Array Dim Int))
  (declare-fun tA ((Array Dim Int)) Real)

  (define-fun lhsShape () (Array Dim Int)
    s
  )

  (define-fun rhsShape () (Array Dim Int)
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
  (declare-const s (Array Dim Int))
  (declare-const a (Array Dim Int))
  (declare-fun tA ((Array Dim Int)) Real)

  (define-fun lhsShape () (Array Dim Int)
    s
  )

  (define-fun rhsShape () (Array Dim Int)
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
