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
; A shape with 2 aggregated axes can be seen as a pair of shapes, one for each aggregated axis
(declare-datatypes (T1 T2) ((Pair (mk-pair (first T1) (second T2)))))

;; Rewrites involving Tensor Iota
(push)
  (echo "Verifying Iota(S, d) => Zero, when S[d] = 1")
  ; Rewrite involves two aggregated-axes: ax0, ax1
  ; - ax0 is the iota axis, and hence singleton. Its size is represented as a single integer sz0
  ; - ax1 is the non-iota axis, and hence has arbitrary size. Its size is represented as an array sz1

  (declare-const sz0 Int) ; Size of ax0
  (declare-const sz1 (Array Int Int)) ; Size of ax1
  (declare-const a0 Int) ; Access for ax0
  (declare-const a1 (Array Int Int))  ; Access for ax1

  (define-fun lhsShape () (Pair Int (Array Int Int))
    (mk-pair sz0 sz1)
  )

  (define-fun rhsShape () (Pair Int (Array Int Int))
    (mk-pair sz0 sz1)
  )

  (define-fun precondition () Bool
    (= sz0 1)
  )

  (define-fun lhsValid () Bool
    (and
      (<= 0 sz0)
      (validShape sz1)
    )
  )

  (define-fun lhsAccessValid () Bool
    (and
      (<= 0 a0)
      (< a0 sz0)
      (validAccess a1 sz1)
    )
  )

  (define-fun rhsValid () Bool
    (and
      (<= 0 sz0)
      (validShape sz1)
    )
  )

  (define-fun rhsAccessValid () Bool
    (and
      (<= 0 a0)
      (< a0 sz0)
      (validAccess a1 sz1)
    )
  )

  (define-fun rewriteValid () Bool
    (= a0 0)
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