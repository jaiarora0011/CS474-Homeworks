(declare-const p Bool)
(declare-const q Bool)
(declare-const r Bool)

; First clause: {q, !r}
(define-fun C1 () Bool
  (or q (not r))
)

; Second clause: {!p, r}
(define-fun C2 () Bool
  (or (not p) r)
)

; Third clause: {p, !q, r}
(define-fun C3 () Bool
  (or p (not q) r)
)

; Original Formula phi: {C1, C2, C3}
(define-fun phi () Bool
  (and C1 C2 C3)
)
(push)
  ; Check if phi is satisfiable
  (assert phi)
  (echo "Is phi satisfiable?")
  (check-sat)
  (echo "p q r:")
  (get-value (p q r))
(pop)

; New clauses are resolution
; Fourth clause: {!p, q}
(define-fun C4 () Bool
  (or (not p) q)
)

; Fifth clause: {!q, r}
(define-fun C5 () Bool
  (or (not q) r)
)

; New formula psi: {C1, C2, C3, C4, C5}
(define-fun psi () Bool
  (and C1 C2 C3 C4 C5)
)

(push)
  ; Check if psi is equivalent to phi
  (assert (not (= phi psi)))
  (echo "Is psi equivalent to phi? (should be unsat):")
  (check-sat)
(pop)