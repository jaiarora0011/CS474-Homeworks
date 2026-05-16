; Since Z3 does not support pointwise computations of arbitrary arity on sequences, we model them using quantifiers.
; The modeling is tricky because we need to quantify over the sequence indices
(push)
  (declare-const a (Seq Int))
  (declare-const b (Seq Int))
  (declare-const z (Seq Int))

  ; The relation sum(a, b, z) holds if z is the element-wise sum of a and b.
  (define-fun sum ((a (Seq Int)) (b (Seq Int)) (z (Seq Int))) Bool
    (and
      (= (seq.len a) (seq.len b))
      (= (seq.len z) (seq.len a))
      (forall ((i Int))
        (=> (and (>= i 0) (< i (seq.len a)))
            (= (seq.nth z i)
               (+ (seq.nth a i) (seq.nth b i)))))
    )
  )

  (assert (not (= (sum a b z) (sum b a z))))
  (check-sat)
(pop)

; Utility Functions for defining rewrites
(define-fun isZero ((a (Seq Int))) Bool
  (forall ((i Int))
    (=> (and (>= i 0) (< i (seq.len a)))
        (= (seq.nth a i) 0)))
)

; Asserts that all elements of the array are equal to a constant value
(define-fun constPre ((a (Seq Int)) (v Int)) Bool
  (forall ((i Int))
    (=> (and (>= i 0) (< i (seq.len a)))
        (= (seq.nth a i) v)))
)
