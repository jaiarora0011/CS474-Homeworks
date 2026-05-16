; Declare a sort for dimension labels, one for each aggregated axis.
; This allows us to reason about maps with symbolic dimension labels, instead of integer dimension numbers (which make the arrays unbounded).
; So all attribute arrays are now of type (Array Dim Int) instead of (Array Int Int).
(declare-sort Dim0 0)
(declare-sort Dim1 0)

; A shape with 2 aggregated axes can be seen as a pair of shapes, one for each aggregated axis
(declare-datatypes (T1 T2) ((Pair (mk-pair (first T1) (second T2)))))

(define-fun zeroArr0 () (Array Dim0 Int)
   ((as const (Array Dim0 Int)) 0)
)

(define-fun zeroArr1 () (Array Dim1 Int)
   ((as const (Array Dim1 Int)) 0)
)

(define-fun oneArr0 () (Array Dim0 Int)
   ((as const (Array Dim0 Int)) 1)
)

(define-fun oneArr1 () (Array Dim1 Int)
   ((as const (Array Dim1 Int)) 1)
)

; Asserts that all elements of the array are less than or equal to elements of another array
(define-fun leqPre0 ((a (Array Dim0 Int)) (b (Array Dim0 Int))) Bool
  (=
    ((_ map (<= (Int Int) Bool)) a b)
    ((as const (Array Dim0 Bool)) true)
  )
)

(define-fun leqPre1 ((a (Array Dim1 Int)) (b (Array Dim1 Int))) Bool
  (=
    ((_ map (<= (Int Int) Bool)) a b)
    ((as const (Array Dim1 Bool)) true)
  )
)

; Asserts that all elements of the array are less than elements of another array
(define-fun ltPre0 ((a (Array Dim0 Int)) (b (Array Dim0 Int))) Bool
  (=
    ((_ map (< (Int Int) Bool)) a b)
    ((as const (Array Dim0 Bool)) true)
  )
)

(define-fun ltPre1 ((a (Array Dim1 Int)) (b (Array Dim1 Int))) Bool
  (=
    ((_ map (< (Int Int) Bool)) a b)
    ((as const (Array Dim1 Bool)) true)
  )
)

(define-fun validShape0 ((s (Array Dim0 Int))) Bool
  (leqPre0 zeroArr0 s)
)

(define-fun validShape1 ((s (Array Dim1 Int))) Bool
  (leqPre1 zeroArr1 s)
)

(define-fun validAccess0 ((a (Array Dim0 Int)) (s (Array Dim0 Int))) Bool
  (and
    (leqPre0 zeroArr0 a)
    (ltPre0 a s)
  )
)

(define-fun validAccess1 ((a (Array Dim1 Int)) (s (Array Dim1 Int))) Bool
  (and
    (leqPre1 zeroArr1 a)
    (ltPre1 a s)
  )
)
; Reverse access function: computes the input access index corresponding to a given output access
(define-fun reverseAcc ((a Int) (sz Int)) Int
  (- sz (- a 1))
)

;; Rewrites involving Tensor Reverse
;; Rules taken from https://github.com/ADAPT-uiuc/TensorRight/blob/master/rules/xla/reverse/Main.hs
(push)
  (echo "Verifying Reverse(A, dims) => A if dims have size 1")
  (declare-const sz (Array Dim0 Int)) ; Tensor size

  (declare-const a (Array Dim0 Int))  ; Tensor Access
  (declare-fun tA ((Array Dim0 Int)) Real)

  (define-fun lhsShape () (Array Dim0 Int)
    sz
  )

  (define-fun rhsShape () (Array Dim0 Int)
    sz
  )

  (define-fun precondition () Bool
    (= sz oneArr0)
  )

  (define-fun lhsValid () Bool
    (and
      (validShape0 sz)
      (validShape0 lhsShape)
    )
  )

  (define-fun lhsAccessValid () Bool
    (and
      (validAccess0 a lhsShape)
      (validAccess0 ((_ map reverseAcc) a sz) sz)
    )
  )

  (define-fun rhsValid () Bool
    (validShape0 rhsShape)
  )

  (define-fun rhsAccessValid () Bool
    (validAccess0 a rhsShape)
  )

  (define-fun rewriteValid () Bool
    (= (tA ((_ map reverseAcc) a sz)) (tA a))
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

(push)
  (echo "Verifying Reverse(Reverse(A, dims), dims) => A")
  (declare-const sz0 (Array Dim0 Int)) ; Tensor size for ax0
  (declare-const sz1 (Array Dim1 Int)) ; Tensor size for ax1

  (declare-const a0 (Array Dim0 Int))  ; Tensor Access for ax0
  (declare-const a1 (Array Dim1 Int))  ; Tensor Access for ax1
  (declare-fun tA ((Pair (Array Dim0 Int) (Array Dim1 Int))) Real)

  (define-fun lhsShape () (Pair (Array Dim0 Int) (Array Dim1 Int))
    (mk-pair sz0 sz1)
  )

  (define-fun rhsShape () (Pair (Array Dim0 Int) (Array Dim1 Int))
    (mk-pair sz0 sz1)
  )

  (define-fun precondition () Bool
    true
  )

  (define-fun lhsValid () Bool
    (and
      (validShape0 sz0)
      (validShape1 sz1)
    )
  )

  (define-fun lhsAccessValid () Bool
    (and
      (validAccess0 a0 sz0)
      (validAccess0 ((_ map reverseAcc) a0 sz0) sz0)
      (validAccess0 ((_ map reverseAcc) ((_ map reverseAcc) a0 sz0) sz0) sz0)
      (validAccess1 a1 sz1)
    )
  )

  (define-fun rhsValid () Bool
    (and
      (validShape0 sz0)
      (validShape1 sz1)
    )
  )

  (define-fun rhsAccessValid () Bool
    (and
      (validAccess0 a0 sz0)
      (validAccess1 a1 sz1)
    )
  )

  (define-fun rewriteValid () Bool
    (=
      (tA (mk-pair ((_ map reverseAcc) ((_ map reverseAcc) a0 sz0) sz0) a1))
      (tA (mk-pair a0 a1))
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
  (check-sat)
(pop)