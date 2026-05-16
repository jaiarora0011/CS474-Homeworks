; Declare a sort for dimension labels, one for each aggregated axis.
; This allows us to reason about maps with symbolic dimension labels, instead of integer dimension numbers (which make the arrays unbounded).
; So all attribute arrays are now of type (Array Dim Int) instead of (Array Int Int).
(declare-sort Dim 0)

; Utility Functions for defining rewrites
(define-fun zeroArr () (Array Dim Int)
   ((as const (Array Dim Int)) 0)
)

(define-fun oneArr () (Array Dim Int)
  ((as const (Array Dim Int)) 1)
)

(define-fun twoArr () (Array Dim Int)
  ((as const (Array Dim Int)) 2)
)

; Asserts that all elements of the array are equal to a constant value
(define-fun constPre ((a (Array Dim Int)) (v Int)) Bool
  (=
    a
    ((as const (Array Dim Int)) v)
  )
)

; Asserts that all elements of the array are less than or equal to elements of another array
(define-fun leqPre ((a (Array Dim Int)) (b (Array Dim Int))) Bool
  (=
    ((_ map (<= (Int Int) Int)) a b)
    ((as const (Array Dim Bool)) true)
  )
)

; Asserts that all elements of the array are less than elements of another array
(define-fun ltPre ((a (Array Dim Int)) (b (Array Dim Int))) Bool
  (=
    ((_ map (< (Int Int) Int)) a b)
    ((as const (Array Dim Bool)) true)
  )
)

(define-fun validShape ((s (Array Dim Int))) Bool
  (leqPre zeroArr s)
)

(define-fun validAccess ((a (Array Dim Int)) (s (Array Dim Int))) Bool
  (and
    (leqPre zeroArr a)
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

(push)
  (echo "Checking ceiling definition: ceilingDiv(a, b) = safeCeil(a, b) for a >= 0 and b > 0")
  (declare-const a Int)
  (declare-const b Int)
  (assert
    (and
      (>= a 0)
      (> b 0)
      (not
        (= (ceilingDiv a b) (safeCeil a b))
      )
    )
  )
  (check-sat)
(pop)

;; Rewrites involving Tensor Slicing
;; Rules taken from:
;; - https://github.com/ADAPT-uiuc/TensorRight/blob/master/rules/xla/slice/Main.hs
;; - https://github.com/ADAPT-uiuc/TensorRight/blob/master/rules/debug/Main.hs
(push)
  (echo "Verifying Slice(A) => A")
  (declare-const sz (Array Dim Int)) ; Tensor size
  (declare-const s (Array Dim Int))  ; Slice start
  (declare-const e (Array Dim Int))  ; Slice end
  (declare-const p (Array Dim Int))  ; Slice stride
  (declare-const a (Array Dim Int))  ; Tensor Access
  (declare-fun tA ((Array Dim Int)) Real)

  (define-fun lhsShape () (Array Dim Int)
    ((_ map sliceShape) s e p)
  )

  (define-fun rhsShape () (Array Dim Int)
    sz
  )

  (define-fun precondition () Bool
    (and
      (= s zeroArr)
      (= e sz)
      (= p oneArr)
    )
  )

  (define-fun lhsValid () Bool
    (and
      (validShape sz)
      (leqPre zeroArr s)
      (leqPre s e)
      (leqPre e sz)
      (ltPre zeroArr p)
      (validShape lhsShape)
    )
  )

  (define-fun lhsAccessValid () Bool
    (and
      (validAccess a lhsShape)
      (validAccess ((_ map sliceAcc) a s p) sz)
    )
  )

  (define-fun rhsValid () Bool
    (validShape rhsShape)
  )

  (define-fun rhsAccessValid () Bool
    (validAccess a rhsShape)
  )

  (define-fun rewriteValid () Bool
    (= (tA ((_ map sliceAcc) a s p)) (tA a))
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
  (echo "Verifying TensorRight Motivating Example: Valid for 1D case but invalid for higher dimensions")
  (declare-const sz (Array Dim Int)) ; Tensor size
  (declare-const s (Array Dim Int))  ; Slice start
  (declare-const e (Array Dim Int))  ; Slice end
  (declare-const pLhs (Array Dim Int))  ; Slice stride for LHS
  (declare-const pRhs (Array Dim Int))  ; Slice stride for RHS
  (declare-const offset (Array Dim Int))  ; Dynamic Update Slice update offset
  (declare-const a (Array Dim Int))  ; Tensor Access
  (declare-fun tA ((Array Dim Int)) Real)

  (define-fun midPoint ((sz Int)) Int
    (divOr (+ sz 1) 2 0)
  )

  (define-fun lhsShape () (Array Dim Int)
    ((_ map sliceShape) s e pLhs)
  )

  (define-fun rhsShape () (Array Dim Int)
    ((_ map sliceShape) s sz pRhs)
  )

  (define-fun precondition () Bool
    (and
      (= s zeroArr)
      (= e ((_ map midPoint) sz))
      (= pLhs oneArr)
      (= pRhs twoArr)
    )
  )

  (define-fun lhsValid () Bool
    (and
      (validShape sz)
      (leqPre zeroArr s)
      (leqPre s e)
      (leqPre e sz)
      (ltPre zeroArr pLhs)
      (validShape lhsShape)
      (leqPre zeroArr offset)
    )
  )

  (define-fun lhsAccessValid () Bool
    (and
      (validAccess a lhsShape)
      (=> (not (leqPre offset a)) (validAccess a lhsShape))
      (=> (not (leqPre offset a)) (validAccess ((_ map sliceAcc) a s pLhs) sz))
    )
  )

  (define-fun rhsValid () Bool
    (and
      (validShape sz)
      (leqPre zeroArr s)
      (leqPre s e)
      (leqPre e sz)
      (ltPre zeroArr pRhs)
      (validShape rhsShape)
      (leqPre zeroArr offset)
    )
  )

  (define-fun rhsAccessValid () Bool
    (and
      (validAccess a rhsShape)
      (=> (not (leqPre offset a)) (validAccess a rhsShape))
      (=> (not (leqPre offset a)) (validAccess ((_ map sliceAcc) a s pRhs) sz))
    )
  )

  (define-fun rewriteValid () Bool
    (=
      (ite (leqPre oneArr a) 0 (tA ((_ map sliceAcc) a s pLhs)))
      (ite (leqPre oneArr a) 0 (tA ((_ map sliceAcc) a s pRhs)))
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
  ; Expected to be satisfiable, since the rewrite is invalid for higher-dimensional cases
  (check-sat)
(pop)

(push)
  (echo "Verifying TensorRight Motivating Example: Instantiated to 1D case")
  (declare-const sz (Array Dim Int)) ; Tensor size
  (declare-const s (Array Dim Int))  ; Slice start
  (declare-const e (Array Dim Int))  ; Slice end
  (declare-const pLhs (Array Dim Int))  ; Slice stride for LHS
  (declare-const pRhs (Array Dim Int))  ; Slice stride for RHS
  (declare-const offset (Array Dim Int))  ; Dynamic Update Slice update offset
  (declare-const a (Array Dim Int))  ; Tensor Access
  (declare-fun tA ((Array Dim Int)) Real)

  (declare-const dim Dim)

  (define-fun midPoint ((sz Int)) Int
    (divOr (+ sz 1) 2 0)
  )

  (define-fun lhsShape () (Array Dim Int)
    ((_ map sliceShape) s e pLhs)
  )

  (define-fun rhsShape () (Array Dim Int)
    ((_ map sliceShape) s sz pRhs)
  )

  (define-fun precondition () Bool
    (and
      (= s zeroArr)
      (= e ((_ map midPoint) sz))
      (= pLhs oneArr)
      (= pRhs twoArr)
    )
  )

  (define-fun lhsValid () Bool
    (and
      (validShape sz)
      (leqPre zeroArr s)
      (leqPre s e)
      (leqPre e sz)
      (ltPre zeroArr pLhs)
      (validShape lhsShape)
      (leqPre zeroArr offset)
    )
  )

  (define-fun lhsAccessValid () Bool
    (and
      (validAccess a lhsShape)
      (=> (not (leqPre offset a)) (validAccess a lhsShape))
      (=> (not (leqPre offset a)) (validAccess ((_ map sliceAcc) a s pLhs) sz))
    )
  )

  (define-fun rhsValid () Bool
    (and
      (validShape sz)
      (leqPre zeroArr s)
      (leqPre s e)
      (leqPre e sz)
      (ltPre zeroArr pRhs)
      (validShape rhsShape)
      (leqPre zeroArr offset)
    )
  )

  (define-fun rhsAccessValid () Bool
    (and
      (validAccess a rhsShape)
      (=> (not (leqPre offset a)) (validAccess a rhsShape))
      (=> (not (leqPre offset a)) (validAccess ((_ map sliceAcc) a s pRhs) sz))
    )
  )

  (define-fun rewriteValid () Bool
    (=
      (ite (leqPre oneArr a) 0 (tA ((_ map sliceAcc) a s pLhs)))
      (ite (leqPre oneArr a) 0 (tA ((_ map sliceAcc) a s pRhs)))
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

  (assert
    (forall ((i Dim)) (= i dim))
  )

  (assert (not phi))
  ; The cardinality of the universe of Dim is 1, so all arrays are essentially 
  ; of length 1. Since the rewrite is valid for the 1D case, we expect this to
  ; be unsat.
  (check-sat)
(pop)
