; People P = {a,b,c}
; Dogs D = {u, v, w, x, y, z}
; For each p in P and d in D, Qpd = "Person p is assigned dog d"
(declare-const Qau Bool)
(declare-const Qav Bool)
(declare-const Qaw Bool)
(declare-const Qax Bool)
(declare-const Qay Bool)
(declare-const Qaz Bool)

(declare-const Qbu Bool)
(declare-const Qbv Bool)
(declare-const Qbw Bool)
(declare-const Qbx Bool)
(declare-const Qby Bool)
(declare-const Qbz Bool)

(declare-const Qcu Bool)
(declare-const Qcv Bool)
(declare-const Qcw Bool)
(declare-const Qcx Bool)
(declare-const Qcy Bool)
(declare-const Qcz Bool)

; For each p in P, Dp = set of dogs that can be assigned to p
; For each d in D, Ed = set of dogs that it does not get along with

(push)
(echo "Problem 2c (expected sat):")
; Da = {u, v, w, x, y, z}
; Db = {y, z}
; Dc = {w, x}
; Ev = {x}
; All other Ed are empty

; (1) Each person is assigned at least two dogs
(assert ((_ at-least 2) Qau Qav Qaw Qax Qay Qaz))
(assert ((_ at-least 2) Qby Qbz))
(assert ((_ at-least 2) Qcw Qcx))

; (2) No dog is assigned to more than one person
; Constraints on a, b
(assert (not (and Qay Qby)))
(assert (not (and Qaz Qbz)))
; Constraints on a, c
(assert (not (and Qaw Qcw)))
(assert (not (and Qax Qcx)))
; No constraints on b, c as they do not share any dogs

; (3) Dogs only paired with people who want them
; No constraints on Person a since they can be assigned any dog
; Constraints on Person b
(assert (and (not Qbu) (not Qbv) (not Qbw) (not Qbx)))
; Constraints on Person c
(assert (and (not Qcu) (not Qcv) (not Qcy) (not Qcz)))

; (4) Dogs paired with a person must get along with each other
; No constraints in dogs u, w, x, y, z since they get along with all other dogs
; Constraints on dog v
(assert
  (and
    (not (and Qav Qax))
    (not (and Qbv Qbx))
    (not (and Qcv Qcx))
  )
)

(check-sat)
(echo "Adoption Plan for a:")
(get-value (Qau Qav Qaw Qax Qay Qaz))
(echo "Adoption Plan for b:")
(get-value (Qbu Qbv Qbw Qbx Qby Qbz))
(echo "Adoption Plan for c:")
(get-value (Qcu Qcv Qcw Qcx Qcy Qcz))

(pop)

(push)
(echo "Problem 2d (expected unsat):")
; Da = {u, v, w, x, y, z}
; Db = {y, z}
; Dc = {w, x}
; Ev = {u}
; All other Ed are empty

; (1) Each person is assigned at least two dogs
(assert ((_ at-least 2) Qau Qav Qaw Qax Qay Qaz))
(assert ((_ at-least 2) Qby Qbz))
(assert ((_ at-least 2) Qcw Qcx))

; (2) No dog is assigned to more than one person
; Constraints on a, b
(assert (not (and Qay Qby)))
(assert (not (and Qaz Qbz)))
; Constraints on a, c
(assert (not (and Qaw Qcw)))
(assert (not (and Qax Qcx)))
; No constraints on b, c as they do not share any dogs

; (3) Dogs only paired with people who want them
; No constraints on Person a since they can be assigned any dog
; Constraints on Person b
(assert (and (not Qbu) (not Qbv) (not Qbw) (not Qbx)))
; Constraints on Person c
(assert (and (not Qcu) (not Qcv) (not Qcy) (not Qcz)))

; (4) Dogs paired with a person must get along with each other
; No constraints in dogs u, w, x, y, z since they get along with all other dogs
; Constraints on dog v
(assert
  (and
    (not (and Qav Qau))
    (not (and Qbv Qbu))
    (not (and Qcv Qcu))
  )
)
(check-sat)
(pop)