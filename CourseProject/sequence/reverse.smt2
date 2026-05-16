; Since Z3 does not support pointwise computations of arbitrary arity on sequences, we model them using quantifiers.
; This file mirrors the array/add.smt2 rewrite checks, but uses sequences for the shape and access vectors.

(declare-datatypes (T1 T2) ((Pair (mk-pair (first T1) (second T2)))))

(define-fun constPre ((s (Seq Int)) (v Int)) Bool
  (forall ((i Int))
    (=> (and (>= i 0) (< i (seq.len s)))
        (= (seq.nth s i) v)))
)

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

; Reverse access function: computes the input access index corresponding to a given output access
(define-fun reverseAcc ((a Int) (sz Int)) Int
  (- sz (- a 1))
)

(define-fun reverseAccRel ((a (Seq Int)) (sz (Seq Int)) (ra (Seq Int))) Bool
  (and
    (= (seq.len a) (seq.len sz))
    (= (seq.len ra) (seq.len a))
    (forall ((i Int))
      (=> (and (>= i 0) (< i (seq.len a)))
          (= (seq.nth ra i)
             (- (seq.nth sz i) (- (seq.nth a i) 1)))))
  )
)

;; Rewrites involving Tensor Reverse
;; Rules taken from https://github.com/ADAPT-uiuc/TensorRight/blob/master/rules/xla/reverse/Main.hs
(push)
  (echo "Verifying Reverse(A, dims) => A if dims have size 1")
  (declare-const sz (Seq Int)) ; Tensor size
  (declare-const ra (Seq Int)) ; Reverse access

  (declare-const a (Seq Int))  ; Tensor Access
  (declare-fun tA ((Seq Int)) Real)

  (define-fun lhsShape () (Seq Int)
    sz
  )

  (define-fun rhsShape () (Seq Int)
    sz
  )

  (define-fun precondition () Bool
    (constPre sz 1)
  )

  (define-fun lhsValid () Bool
    (and
      (validShape sz)
      (validShape lhsShape)
    )
  )

  (define-fun lhsAccessValid () Bool
    (and
      (validAccess a lhsShape)
      (reverseAccRel a sz ra)
    )
  )

  (define-fun rhsValid () Bool
    (validShape rhsShape)
  )

  (define-fun rhsAccessValid () Bool
    (validAccess a rhsShape)
  )

  (define-fun rewriteValid () Bool
    (= (tA ra) (tA a))
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
  (echo "Verifying Reverse(Reverse(A, dims), dims) => A")
  (declare-const sz0 (Seq Int)) ; Tensor size for ax0
  (declare-const sz1 (Seq Int)) ; Tensor size for ax1
  (declare-const ra0 (Seq Int)) ; Reverse access for first reverse
  (declare-const rra0 (Seq Int)) ; Reverse access for second reverse

  (declare-const a0 (Seq Int))  ; Tensor Access for ax0
  (declare-const a1 (Seq Int))  ; Tensor Access for ax1
  (declare-fun tA ((Seq Int) (Seq Int)) Real)

  (define-fun lhsShape () (Pair (Seq Int) (Seq Int))
    (mk-pair sz0 sz1)
  )

  (define-fun rhsShape () (Pair (Seq Int) (Seq Int))
    (mk-pair sz0 sz1)
  )

  (define-fun precondition () Bool
    true
  )

  (define-fun lhsValid () Bool
    (and
      (validShape sz0)
      (validShape sz1)
    )
  )

  (define-fun lhsAccessValid () Bool
    (and
      (validAccess a0 sz0)
      (reverseAccRel a0 sz0 ra0)
      (reverseAccRel ra0 sz0 rra0)
      (validAccess a1 sz1)
    )
  )

  (define-fun rhsValid () Bool
    (and
      (validShape sz0)
      (validShape sz1)
    )
  )

  (define-fun rhsAccessValid () Bool
    (and
      (validAccess a0 sz0)
      (validAccess a1 sz1)
    )
  )

  (define-fun rewriteValid () Bool
    (=
      (tA rra0 a1)
      (tA a0 a1)
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
  ; Timeout of 5 seconds
  (set-option :timeout 5000)
  ; The rule times out, likely because of the another quantifier
  (check-sat)
(pop)