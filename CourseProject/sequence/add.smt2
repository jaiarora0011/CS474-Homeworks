; Since Z3 does not support pointwise computations of arbitrary arity on sequences, we model them using quantifiers.
; This file mirrors the array/add.smt2 rewrite checks, but uses sequences for the shape and access vectors.

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

;; Rewrites involving Tensor Addition
;; Rules taken from https://github.com/ADAPT-uiuc/TensorRight/blob/master/rules/xla/add/Main.hs
(push)
  (echo "Verifying Add(Add(A, c1), c2) => Add(A, Add(c1, c2))")
  (declare-const c1 Real)
  (declare-const c2 Real)
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
    (and
      (validAccess a rhsShape)
      (validAccess a s)
    )
  )

  (define-fun rewriteValid () Bool
    (= (+ (+ (tA a) c1) c2)
       (+ (tA a) (+ c1 c2)))
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
  (echo "Verifying Add(A, 0) => A")
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
    (= (+ (tA a) 0) (tA a))
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
  (echo "Verifying Add(0, A) => A")
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
    (= (+ 0 (tA a)) (tA a))
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
  (echo "Verifying Add(c, A) => Add(A, c)")
  (declare-const c Real)
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
    (= (+ c (tA a)) (+ (tA a) c))
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
