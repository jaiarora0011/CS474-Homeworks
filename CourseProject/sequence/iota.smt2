; Since Z3 does not support pointwise computations of arbitrary arity on sequences, we model them using quantifiers.
; This file mirrors the array/iota.smt2 rewrite check, but uses a sequence for the second aggregated axis.

(define-fun validShape ((s (Seq Int))) Bool
  (forall ((i Int))
    (=> (and (>= i 0) (< i (seq.len s)))
        (>= (seq.nth s i) 0)))
)

(define-fun validAccess ((a (Seq Int)) (s (Seq Int))) Bool
  (and
    (validShape a)
    (and
      (= (seq.len a) (seq.len s))
      (forall ((i Int))
        (=> (and (>= i 0) (< i (seq.len a)))
            (< (seq.nth a i) (seq.nth s i))))
    )
  )
)

; A shape with 2 aggregated axes can be seen as a pair of shapes, one for each aggregated axis.
(declare-datatypes (T1 T2) ((Pair (mk-pair (first T1) (second T2)))))

;; Rewrites involving Tensor Iota
;; Rules taken from https://github.com/ADAPT-uiuc/TensorRight/blob/master/rules/xla/iota/Main.hs
(push)
  (echo "Verifying Iota(S, d) => Zero, when S[d] = 1")
  ; Rewrite involves two aggregated axes:
  ; - ax0 is the iota axis, and hence singleton. Its size is now represented as a singleton sequence sz0.
  ; - ax1 is the non-iota axis, and hence has arbitrary size. Its size is represented as a sequence sz1.

  (declare-const sz0 (Seq Int)) ; Size of ax0
  (declare-const sz1 (Seq Int)) ; Size of ax1
  (declare-const a0 (Seq Int)) ; Access for ax0
  (declare-const a1 (Seq Int)) ; Access for ax1

  (define-fun lhsShape () (Pair (Seq Int) (Seq Int))
    (mk-pair sz0 sz1)
  )

  (define-fun rhsShape () (Pair (Seq Int) (Seq Int))
    (mk-pair sz0 sz1)
  )

  (define-fun precondition () Bool
    (and
      (= (seq.len sz0) 1)
      (= (seq.nth sz0 0) 1)
      (= (seq.len a0) 1)
      (= (seq.len a1) (seq.len sz1))
    )
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
    (= (seq.nth a0 0) 0)
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