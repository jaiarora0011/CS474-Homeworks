; Step 0
(declare-const w0 Bool)
(declare-const g0 Bool)
(declare-const c0 Bool)

; Step 1
(declare-const w1 Bool)
(declare-const g1 Bool)
(declare-const c1 Bool)

; Step 2
(declare-const w2 Bool)
(declare-const g2 Bool)
(declare-const c2 Bool)

; Step 3
(declare-const w3 Bool)
(declare-const g3 Bool)
(declare-const c3 Bool)

; Step 4
(declare-const w4 Bool)
(declare-const g4 Bool)
(declare-const c4 Bool)

; Step 5
(declare-const w5 Bool)
(declare-const g5 Bool)
(declare-const c5 Bool)

; Step 6
(declare-const w6 Bool)
(declare-const g6 Bool)
(declare-const c6 Bool)

; Step 7
(declare-const w7 Bool)
(declare-const g7 Bool)
(declare-const c7 Bool)


(define-fun no-moves-right
  ((wi Bool) (gi Bool) (ci Bool) (wj Bool) (gj Bool) (cj Bool)) Bool
    (and
      (=> (not wi) (not wj))
      (=> (not gi) (not gj))
      (=> (not ci) (not cj))
    )
)

(define-fun no-moves-left
  ((wi Bool) (gi Bool) (ci Bool) (wj Bool) (gj Bool) (cj Bool)) Bool
    (and
      (=> wi wj)
      (=> gi gj)
      (=> ci cj)
    )
)

(define-fun at-most-one-move
  ((wi Bool) (gi Bool) (ci Bool) (wj Bool) (gj Bool) (cj Bool)) Bool
    ((_ at-most 1)
      (not (= wi wj))
      (not (= gi gj))
      (not (= ci cj))
    )
)

(define-fun safety-left
  ((wi Bool) (gi Bool) (ci Bool)) Bool
    (not
      (or
        (and wi gi)
        (and gi ci)))
)

(define-fun safety-right
  ((wi Bool) (gi Bool) (ci Bool)) Bool
    (and
      (or wi gi)
      (or gi ci))
)

;; State transitions
; initial state (ensure initial state involving w0,g0,c0 is correct)
(assert (and w0 g0 c0)) ; all on the left bank

; left to right move state 0 -> state 1, involving w0,g0,c0,w1,g1,c1
; Anything on the right bank in state 0 must be on the right bank in state 1
(assert (no-moves-right w0 g0 c0 w1 g1 c1))
; Ensure that at most one of w0,g0,c0 moves
(assert (at-most-one-move w0 g0 c0 w1 g1 c1))

; right to left move state 1 -> state 2 involving w1,g1,c1,w2,g2,c2
; Anything on the left bank in state 1 must be on the left bank in state 2
(assert (no-moves-left w1 g1 c1 w2 g2 c2))
; Ensure that at most one of w1,g1,c1 moves
(assert (at-most-one-move w1 g1 c1 w2 g2 c2))

; left to right move state 2 -> state 3 involving w2,g2,c2,w3,g3,c3
; Anything on the right bank in state 2 must be on the right bank in state 3
(assert (no-moves-right w2 g2 c2 w3 g3 c3))
; Ensure that at most one of w2,g2,c2 moves
(assert (at-most-one-move w2 g2 c2 w3 g3 c3))

; right to left move state 3 -> state 4 involving w3,g3,c3,w4,g4,c4
; Anything on the left bank in state 3 must be on the left bank in state 4
(assert (no-moves-left w3 g3 c3 w4 g4 c4))
; Ensure that at most one of w3,g3,c3 moves
(assert (at-most-one-move w3 g3 c3 w4 g4 c4))

; left to right move state 4 -> state 5 involving w4,g4,c4,w5,g5,c5
; Anything on the right bank in state 4 must be on the right bank in state 5
(assert (no-moves-right w4 g4 c4 w5 g5 c5))
; Ensure that at most one of w4,g4,c4 moves
(assert (at-most-one-move w4 g4 c4 w5 g5 c5))

; right to left move state 5 -> state 6 involving w5,g5,c5,w6,g6,c6
; Anything on the left bank in state 5 must be on the left bank in state 6
(assert (no-moves-left w5 g5 c5 w6 g6 c6))
; Ensure that at most one of w5,g5,c5 moves
(assert (at-most-one-move w5 g5 c5 w6 g6 c6))

; left to right move state 6 -> state 7 involving w6,g6,c6,w7,g7,c7
; Anything on the right bank in state 6 must be on the right bank in state 7
(assert (no-moves-right w6 g6 c6 w7 g7 c7))
; Ensure that at most one of w6,g6,c6 moves
(assert (at-most-one-move w6 g6 c6 w7 g7 c7))

;; safety
; safety of state 1; left bank only checked
; - Wolf and goat cannot be together on the left bank
; - Goat and cabbage cannot be together on the left bank
(assert (safety-left w1 g1 c1))

; safety of state 2; right bank only checked
; - Wolf and goat cannot be together on the right bank
; - Goat and cabbage cannot be together on the right bank
(assert (safety-right w2 g2 c2))

; safety of state 3; left bank only checked
; - Wolf and goat cannot be together on the left bank
; - Goat and cabbage cannot be together on the left bank
(assert (safety-left w3 g3 c3))

; safety of state 4; right bank only checked
; - Wolf and goat cannot be together on the right bank
; - Goat and cabbage cannot be together on the right bank
(assert (safety-right w4 g4 c4))

; safety of state 5; left bank only checked
; - Wolf and goat cannot be together on the left bank
; - Goat and cabbage cannot be together on the left bank
(assert (safety-left w5 g5 c5))

; safety of state 6; right bank only checked
; - Wolf and goat cannot be together on the right bank
; - Goat and cabbage cannot be together on the right bank
(assert (safety-right w6 g6 c6))

; safety of state 7 need not be checked as it’s the goal state that is safe
; reach goal; property of state 7
; Wolf, goat, and cabbage are all on the right bank
(assert (and (not w7) (not g7) (not c7)))

(echo "Solution to the Wolf, Goat, Cabbage problem (expected sat):")
(check-sat)
(echo "w0 g0 c0:")
(get-value (w0 g0 c0))
(echo "w1 g1 c1:")
(get-value (w1 g1 c1))
(echo "w2 g2 c2:")
(get-value (w2 g2 c2))
(echo "w3 g3 c3:")
(get-value (w3 g3 c3))
(echo "w4 g4 c4:")
(get-value (w4 g4 c4))
(echo "w5 g5 c5:")
(get-value (w5 g5 c5))
(echo "w6 g6 c6:")
(get-value (w6 g6 c6))
(echo "w7 g7 c7:")
(get-value (w7 g7 c7))

(push)
; Add a constraint that the goat is not taken across in the first move
; and check if a solution still exists
(assert g1)
(echo "Goat is not taken across in the first move (Expected unsat).")
(check-sat)
(pop)
