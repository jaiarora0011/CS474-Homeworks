(define-fun validProb ((p Real)) Bool
    (and (>= p 0.0) (<= p 1.0))
)

; Payoff for Player R
(define-fun payoffR ((r Real) (s Real) (rff Real) (rfb Real) (rbf Real) (rbb Real)) Real
  (+
    (* r s rff) ; S serves F and R expects F
    (* r (- 1 s) rfb) ; S serves B and R expects F
    (* (- 1 r) s rbf) ; S serves F and R expects B
    (* (- 1 r) (- 1 s) rbb) ; S serves B and R expects B
  )
)
; Payoff for Player S
(define-fun payoffS ((r Real) (s Real) (sff Real) (sfb Real) (sbf Real) (sbb Real)) Real
  (+
    (* r s sff) ; S serves F and R expects F
    (* r (- 1 s) sfb) ; S serves B and R expects F
    (* (- 1 r) s sbf) ; S serves F and R expects B
    (* (- 1 r) (- 1 s) sbb) ; S serves B and R expects B
  )
)

(push)
  (echo "Task 1: Finding a Nash equilibrium for a given payoff matrix")
  ; Payoff matrix for R
  (define-fun rff () Real 90.0)
  (define-fun rfb () Real 20.0)
  (define-fun rbf () Real 30.0)
  (define-fun rbb () Real 60.0)
  ; Payoff matrix for S
  (define-fun sff () Real 10.0)
  (define-fun sfb () Real 80.0)
  (define-fun sbf () Real 70.0)
  (define-fun sbb () Real 40.0)

  ; Expresses that r and s form a Nash equilibrium
  (define-fun phi ((r Real) (s Real)) Bool
    (and
      (validProb r) ; r is a valid probability
      (validProb s) ; s is a valid probability
      (forall ((x Real))
        (=> (validProb x)
          (<= (payoffR x s rff rfb rbf rbb) (payoffR r s rff rfb rbf rbb))
        )
      )
      (forall ((y Real))
        (=> (validProb y)
          (<= (payoffS r y sff sfb sbf sbb) (payoffS r s sff sfb sbf sbb))
        )
      )
    )
  )

  (declare-const r Real)
  (declare-const s Real)
  (assert (phi r s))
  (check-sat)
  (echo "Nash equilibrium probabilities (r s):")
  (get-value (r s))
(pop)

(push)
  (echo "Task 2: Proving the existence of a Nash equilibrium an arbitrary payoff matrix")

  (define-fun psi () Bool
    (forall ((rff Real) (rfb Real) (rbf Real) (rbb Real) (sff Real) (sfb Real) (sbf Real) (sbb Real))
      (exists ((r Real) (s Real))
        (and
          (validProb r) ; r is a valid probability
          (validProb s) ; s is a valid probability
          (forall ((x Real))
            (=> (validProb x)
              (<= (payoffR x s rff rfb rbf rbb) (payoffR r s rff rfb rbf rbb))
            )
          )
          (forall ((y Real))
            (=> (validProb y)
              (<= (payoffS r y sff sfb sbf sbb) (payoffS r s sff sfb sbf sbb))
            )
          )
        )
      )
    )
  )
  (assert (not psi))
  ; This checks takes a long time to run, so commenting out for now.
  ; (check-sat)
(pop)

(push)
  (declare-const rff Real)
  (declare-const rfb Real)
  (declare-const rbf Real)
  (declare-const rbb Real)
  (declare-const sff Real)
  (declare-const sfb Real)
  (declare-const sbf Real)
  (declare-const sbb Real)
  (declare-const r Real)
  (declare-const s Real)
  (define-fun psi () Bool
    (and
      (validProb r) ; r is a valid probability
      (validProb s) ; s is a valid probability
      (forall ((x Real))
        (=> (validProb x)
          (<= (payoffR x s rff rfb rbf rbb) (payoffR r s rff rfb rbf rbb))
        )
      )
      (forall ((y Real))
        (=> (validProb y)
          (<= (payoffS r y sff sfb sbf sbb) (payoffS r s sff sfb sbf sbb))
        )
      )
    )
  )
  (assert psi)
  (apply (using-params qe :qe-nonlinear true))
(pop)