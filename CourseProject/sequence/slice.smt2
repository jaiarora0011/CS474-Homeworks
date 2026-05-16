; Since Z3 does not support pointwise computations of arbitrary arity on sequences, we model them using quantifiers.
; This file mirrors the array/slice.smt2 rewrite checks, but uses sequences for the shape and access vectors.

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

; Asserts that all elements of the sequence are greater than or equal to a constant value.
(define-fun geqPre ((a (Seq Int)) (v Int)) Bool
  (forall ((i Int))
    (=> (and (>= i 0) (< i (seq.len a)))
        (>= (seq.nth a i) v)))
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

; Division with a default value for division by zero
(define-fun divOr ((a Int) (b Int) (d Int)) Int
  (ite
    (= b 0)
    d
    (div a b)
  )
)

; Modulo with a default value for division by zero
(define-fun modOr ((a Int) (b Int) (d Int)) Int
  (ite
    (= b 0)
    d
    (mod a b)
  )
)

; Ceiling division defined in terms of divOr and modOr
(define-fun ceilingDiv ((a Int) (b Int)) Int
  (ite
    (= (modOr a b 0) 0)
    (divOr a b 0)
    (+ (divOr a b 0) 1)
  )
)

; Ceiling division defined in terms of divOr only
(define-fun safeCeil ((a Int) (b Int)) Int
  (divOr
    (+ a (- b 1))
    b
    0
  )
)

; Slice access function: computes the input access index corresponding to a given output access
(define-fun sliceAcc ((a Int) (s Int) (p Int)) Int
  (+ s (* p a))
)

; Slice shape function: computes the output shape given the input shape and slice parameters
(define-fun sliceShape ((s Int) (e Int) (p Int)) Int
  (ceilingDiv
    (- e s)
    p
  )
)

(define-fun midPoint ((sz Int)) Int
  (divOr (+ sz 1) 2 0)
)

(define-fun sliceAccRel ((a (Seq Int)) (s (Seq Int)) (p (Seq Int)) (ra (Seq Int))) Bool
  (and
    (= (seq.len a) (seq.len s))
    (= (seq.len p) (seq.len a))
    (= (seq.len ra) (seq.len a))
    (forall ((i Int))
      (=> (and (>= i 0) (< i (seq.len a)))
          (= (seq.nth ra i)
             (sliceAcc (seq.nth a i) (seq.nth s i) (seq.nth p i)))))
  )
)

(define-fun sliceShapeRel ((s (Seq Int)) (e (Seq Int)) (p (Seq Int)) (r (Seq Int))) Bool
  (and
    (= (seq.len s) (seq.len e))
    (= (seq.len p) (seq.len s))
    (= (seq.len r) (seq.len s))
    (forall ((i Int))
      (=> (and (>= i 0) (< i (seq.len s)))
          (= (seq.nth r i)
             (sliceShape (seq.nth s i) (seq.nth e i) (seq.nth p i)))))
  )
)

(define-fun midPointRel ((sz (Seq Int)) (m (Seq Int))) Bool
  (and
    (= (seq.len sz) (seq.len m))
    (forall ((i Int))
      (=> (and (>= i 0) (< i (seq.len sz)))
          (= (seq.nth m i)
             (midPoint (seq.nth sz i)))))
  )
)

;; Rewrites involving Tensor Slicing
;; Rules taken from:
;; - https://github.com/ADAPT-uiuc/TensorRight/blob/master/rules/xla/slice/Main.hs
;; - https://github.com/ADAPT-uiuc/TensorRight/blob/master/rules/debug/Main.hs
(push)
  (echo "Verifying Slice(A) => A")
  (declare-const sz (Seq Int)) ; Tensor size
  (declare-const s (Seq Int))  ; Slice start
  (declare-const e (Seq Int))  ; Slice end
  (declare-const p (Seq Int))  ; Slice stride
  (declare-const a (Seq Int))  ; Tensor Access
  (declare-const ra (Seq Int)) ; Slice access
  (declare-const lhsShape (Seq Int))
  (declare-const rhsShape (Seq Int))
  (declare-fun tA ((Seq Int)) Real)

  (define-fun precondition () Bool
    (and
      (constPre s 0)
      (= e sz)
      (constPre p 1)
      (= rhsShape sz)
      (= (seq.len s) (seq.len sz))
      (= (seq.len p) (seq.len sz))
    )
  )

  (define-fun lhsValid () Bool
    (and
      (validShape sz)
      (sliceShapeRel s e p lhsShape)
      (validShape lhsShape)
    )
  )

  (define-fun lhsAccessValid () Bool
    (and
      (validAccess a lhsShape)
      (sliceAccRel a s p ra)
      (validAccess ra sz)
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
  (set-option :timeout 5000)
  (check-sat)
(pop)

(push)
  (echo "Verifying TensorRight Motivating Example: Valid for 1D case but invalid for higher dimensions")
  (declare-const sz (Seq Int)) ; Tensor size
  (declare-const s (Seq Int))  ; Slice start
  (declare-const e (Seq Int))  ; Slice end
  (declare-const pLhs (Seq Int))  ; Slice stride for LHS
  (declare-const pRhs (Seq Int))  ; Slice stride for RHS
  (declare-const offset (Seq Int))  ; Dynamic Update Slice update offset
  (declare-const a (Seq Int))  ; Tensor Access
  (declare-const raLhs (Seq Int)) ; Slice access for LHS
  (declare-const raRhs (Seq Int)) ; Slice access for RHS
  (declare-const lhsShape (Seq Int))
  (declare-const rhsShape (Seq Int))
  (declare-fun tA ((Seq Int)) Real)

  (define-fun precondition () Bool
    (and
      (constPre s 0)
      (midPointRel sz e)
      (constPre pLhs 1)
      (constPre pRhs 2)
      (sliceShapeRel s sz pRhs rhsShape)
      (constPre offset 1)
      (= (seq.len s) (seq.len sz))
      (= (seq.len e) (seq.len sz))
      (= (seq.len pLhs) (seq.len sz))
      (= (seq.len pRhs) (seq.len sz))
      (= (seq.len offset) (seq.len sz))
      (= (seq.len lhsShape) (seq.len sz))
      (= (seq.len rhsShape) (seq.len sz))
      (= (seq.len raLhs) (seq.len sz))
      (= (seq.len raRhs) (seq.len sz))
    )
  )

  (define-fun lhsValid () Bool
    (and
      (validShape sz)
      (sliceShapeRel s e pLhs lhsShape)
      (validShape lhsShape)
      (validShape offset)
    )
  )

  (define-fun lhsAccessValid () Bool
    (and
      (validAccess a lhsShape)
      (sliceAccRel a s pLhs raLhs)
      (validAccess raLhs sz)
      (=> (not (leqPre offset a)) (validAccess a lhsShape))
      (=> (not (leqPre offset a)) (validAccess raLhs sz))
    )
  )

  (define-fun rhsValid () Bool
    (and
      (validShape sz)

      (validShape rhsShape)
      (validShape offset)
    )
  )

  (define-fun rhsAccessValid () Bool
    (and
      (validAccess a rhsShape)
      (sliceAccRel a s pRhs raRhs)
      (validAccess raRhs sz)
      (=> (not (leqPre offset a)) (validAccess a rhsShape))
      (=> (not (leqPre offset a)) (validAccess raRhs sz))
    )
  )

  (define-fun rewriteValid () Bool
    (=
      (ite (leqPre offset a) 0 (tA raLhs))
      (ite (leqPre offset a) 0 (tA raRhs))
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
  ; The rule times out, likely because of another quantifier
  (check-sat)
  ; (get-value (sz s e pLhs pRhs offset a raLhs raRhs lhsShape rhsShape))
(pop)
