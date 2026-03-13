; Using Real sort since z3 does not support Rationals
(define-fun psi () Bool
  (forall ((x Real))
    (exists ((y Real))
      (and
        (> (* 2 y) (* 3 x))
        (< (* 4 y) (+ (* 8 x) 10))
      )
    )
  )
)

(assert psi)
(echo "Applying quantifier elimination to psi (expected false):")
(apply qe)
