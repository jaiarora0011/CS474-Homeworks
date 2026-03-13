(push)
  (declare-const l1 Real)
  (declare-const u1 Real)
  (declare-const l2 Real)
  (declare-const u2 Real)

  (define-fun phi () Bool
    (forall ((z Real))
      (=>
        (and (< l1 z) (< z u1) (< l2 z) (< z u2))
        (exists ((w Real))
          (and (< l1 w) (< w u1) (< l2 w) (< w u2) (not (= w z)))
        )
      )
    )
  )
  (assert phi)
  ; (apply (using-params qe :qe-nonlinear true))
  (apply qe)
(pop)

(push)
  ; Interval graph with 4 vertices v1, v2, v3, v4
  ; Open interval bounds for v1: (l1, u1)
  (declare-const l1 Real)
  (declare-const u1 Real)
  ; Open interval bounds for v2: (l2, u2)
  (declare-const l2 Real)
  (declare-const u2 Real)
  ; Open interval bounds for v3: (l3, u3)
  (declare-const l3 Real)
  (declare-const u3 Real)
  ; Open interval bounds for v4: (l4, u4)
  (declare-const l4 Real)
  (declare-const u4 Real)

  ; Returns a formula which is valid iff the open intervals
  ; (li, ui) and (lj, uj) intersect
  (define-fun intersects ((li Real) (ui Real) (lj Real) (uj Real)) Bool
    (exists ((z Real))
      (and (< li z) (< z ui) (< lj z) (< z uj))
    )
  )

  (define-fun valid-interval ((li Real) (ui Real)) Bool
    (< li ui)
  )

  ; All intervals must be valid
  (define-fun valid-intervals () Bool
    (and
      (valid-interval l1 u1)
      (valid-interval l2 u2)
      (valid-interval l3 u3)
      (valid-interval l4 u4)
    )
  )

  ; Graph has edges (v1, v2), (v2, v3), (v3, v4), (v4, v1)
  (define-fun positive () Bool
    (and
      (intersects l1 u1 l2 u2) ; v1 and v2 intersect
      (intersects l2 u2 l3 u3) ; v2 and v3 intersect
      (intersects l3 u3 l4 u4) ; v3 and v4 intersect
      (intersects l4 u4 l1 u1) ; v4 and v1 intersect
    )
  )

  ; Graph does not have the edges (v1, v3) and (v2, v4)
  (define-fun negative () Bool
    (and
      (not (intersects l1 u1 l3 u3)) ; v1 and v3 do not intersect
      (not (intersects l2 u2 l4 u4)) ; v2 and v4 do not intersect
    )
  )

  (assert (and valid-intervals positive negative))
  (echo "Is there an interval representation of the graph? (should be unsat):")
  (check-sat)
(pop)

