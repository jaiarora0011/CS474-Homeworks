; Since Z3 does not support pointwise computations of arbitrary arity on sequences, we model them using quantifiers.
; This file mirrors the array/compare.smt2 rewrite checks, but uses sequences for the shape and access vectors.

; Asserts that all elements of the sequence are less than or equal to elements of another sequence.
(define-fun leqPre ((a (Seq Int)) (b (Seq Int))) Bool
  (and
    (= (seq.len a) (seq.len b))
    (forall ((i Int))
      (=> (and (>= i 0) (< i (seq.len a)))
          (<= (seq.nth a i) (seq.nth b i))))
  )
)

; Asserts that all elements of the sequence are less than elements of another sequence.
(define-fun ltPre ((a (Seq Int)) (b (Seq Int))) Bool
  (and
    (= (seq.len a) (seq.len b))
    (forall ((i Int))
      (=> (and (>= i 0) (< i (seq.len a)))
          (< (seq.nth a i) (seq.nth b i))))
  )
)

(define-fun validShape ((s (Seq Int))) Bool
  (forall ((i Int))
    (=> (and (>= i 0) (< i (seq.len s)))
        (>= (seq.nth s i) 0)))
)

(define-fun validAccess ((a (Seq Int)) (s (Seq Int))) Bool
  (and
    (validShape a)
    (ltPre a s)
  )
)

;; Rewrites involving Tensor Comparison
;; Rules taken from https://github.com/ADAPT-uiuc/TensorRight/blob/master/rules/xla/compare/Main.hs
(push)
  (echo "Verifying Gt(A, A) => False")
  (declare-const s (Seq Int))
  (declare-const a (Seq Int))
  (declare-fun tA ((Seq Int)) Real)

  (define-fun lhsShape () (Seq Int)
    s
  )

  (define-fun rhsShape () (Seq Int)
    s
  )

  (define-fun precondition () Bool
    (and
      (= (seq.len lhsShape) (seq.len rhsShape))
      (= (seq.len a) (seq.len lhsShape))
    )
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
  (declare-const s (Seq Int))
  (declare-const a (Seq Int))
  (declare-fun tA ((Seq Int)) Real)

  (define-fun lhsShape () (Seq Int)
    s
  )

  (define-fun rhsShape () (Seq Int)
    s
  )

  (define-fun precondition () Bool
    (and
      (= (seq.len lhsShape) (seq.len rhsShape))
      (= (seq.len a) (seq.len lhsShape))
    )
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
  (declare-const s (Seq Int))
  (declare-const a (Seq Int))
  (declare-fun tA ((Seq Int)) Real)

  (define-fun lhsShape () (Seq Int)
    s
  )

  (define-fun rhsShape () (Seq Int)
    s
  )

  (define-fun precondition () Bool
    (and
      (= (seq.len lhsShape) (seq.len rhsShape))
      (= (seq.len a) (seq.len lhsShape))
    )
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
  (declare-const s (Seq Int))
  (declare-const a (Seq Int))
  (declare-fun tA ((Seq Int)) Real)

  (define-fun lhsShape () (Seq Int)
    s
  )

  (define-fun rhsShape () (Seq Int)
    s
  )

  (define-fun precondition () Bool
    (and
      (= (seq.len lhsShape) (seq.len rhsShape))
      (= (seq.len a) (seq.len lhsShape))
    )
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
  (declare-const s (Seq Int))
  (declare-const a (Seq Int))
  (declare-fun tA ((Seq Int)) Real)

  (define-fun lhsShape () (Seq Int)
    s
  )

  (define-fun rhsShape () (Seq Int)
    s
  )

  (define-fun precondition () Bool
    (and
      (= (seq.len lhsShape) (seq.len rhsShape))
      (= (seq.len a) (seq.len lhsShape))
    )
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
  (declare-const s (Seq Int))
  (declare-const a (Seq Int))
  (declare-fun tA ((Seq Int)) Real)

  (define-fun lhsShape () (Seq Int)
    s
  )

  (define-fun rhsShape () (Seq Int)
    s
  )

  (define-fun precondition () Bool
    (and
      (= (seq.len lhsShape) (seq.len rhsShape))
      (= (seq.len a) (seq.len lhsShape))
    )
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