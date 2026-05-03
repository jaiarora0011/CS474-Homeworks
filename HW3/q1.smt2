(declare-sort A)
(declare-fun f (A A) A)
(declare-const e A)
; Skolem function from inverse axiom
(declare-fun g (A) A)

(push)
  (echo "Task 1: Identity element is unique")
  ; Skolem constant from negation of the property
  (declare-const c A)

  ; Instantiate A2 with c
  (assert (= (f c e) c))
  (assert (= (f e c) c))
  ; Instantiate psi with e
  (assert (= (f e c) e))
  (assert (= (f c e) e))
  (assert (not (= c e)))
  (check-sat)
(pop)

(push)
  (echo "Task 2: Inverse of every element is unique")
  ; Skolem constants from negation of the property
  (declare-const c A)
  (declare-const d A)
  
  ; Instantiate A2 with d
  (assert (= (f d e) d))
  (assert (= (f e d) d))
  ; Instantiate A3 with c
  (assert (= (f c (g c)) e))
  (assert (= (f (g c) c) e))
  ; Instantiate A2 with g(c)
  (assert (= (f (g c) e) (g c)))
  (assert (= (f e (g c)) (g c)))
  ; Instantiate A1 with g(c), c, d
  (assert (= (f (f (g c) c) d) (f (g c) (f c d))))
  ; psi
  (assert (= (f c d) e))
  (assert (= (f d c) e))
  (assert (not (= d (g c))))
  (check-sat)
(pop)
