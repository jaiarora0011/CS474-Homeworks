# CS 474 Course Project: Tensor graph rewrite verification using Arrays and Sequence

This project contains SMT-LIB files that encode and verify a few rewrite rules for tensor operators. Each file models the preconditions for a rewrite, states the rewrite as a logical implication, and then asks Z3 to prove that no counterexample exists.

The project presents two encodings:

- `array/` uses symbolic dimension labels and SMT arrays to represent shapes and accesses.
- `sequence/` uses Z3 sequences and quantifiers to represent shapes and accesses.

### Array encoding

The files in `array/` model shapes as arrays from a symbolic dimension sort to Int. This avoids treating dimensions as unbounded integer indices (which result in unbounded arrays). Utility predicates such as validShape and validAccess check that shapes are non-negative and that accesses stay within bounds.

The array files cover:

- `add.smt2`: addition rewrites such as Add(A, 0) => A and reassociation of nested additions.
- `compare.smt2`: comparison rewrites such as Gt(A, A) => False, Lt(A, A) => False, and Ne(A, A) => False.
- `iota.smt2`: iota rewrites, including the case where the iota dimension has size 1.
- `reverse.smt2`: reverse rewrites, including reversing a singleton dimension and reversing twice.
- `slice.smt2`: slice rewrites, including the identity slice and a rewrite which is valid for rank 1 but invalid at higher ranks.

### Sequence encoding

The files in `sequence/` mirror the array proofs, but replace the symbolic dimension-array encoding with sequences.
Because Z3 does not support arbitrary pointwise sequence operators directly, the files use quantifiers over indices to express elementwise facts such as equality, ordering, and validity. 
Some of the rewrite encodings also include explicit timeouts (5 seconds) before `check-sat`, since the quantified encodings can take a long time to finish.

