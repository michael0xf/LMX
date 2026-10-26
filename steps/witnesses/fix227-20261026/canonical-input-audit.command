Bounded read-only comparison of the exact cold78 list/manifest against five
canonical input roots in tools/l2/inputs/README.md, excluding6 prospective
changed sources. No project/build2 traversal or new fixture execution.
All78 entries are unique;72/72 remaining stage inputs match the cold78pins.
71/72 are byte-equal to canonical226. P0 now equals canonical872a0144,
226745bytes, unlike the earlier225/226 EOF-only stage difference.
One inherited fixture mismatch remains:
tests/native_closure_values.lm2 stage43748B/canonical37624B, +49lines/+6124B.
stage0ac54a83a42aa0748911af049094191955beeffa989f8c9ccd025ee6d136bda0
canonicaledf44893cfca9f2b17defc1b11594cccdfa635a69b2a785e3b115706cccc8197
The stage PHYSICAL-CONSTRUCTION checks are already the same pinned bytes in
packets225 and226, not a new227 change. Keep this snapshot distinction;
do not claim all78 stage inputs are raw-equal to canonical after promotion.
Maintained runtime.list is a separate7th prospective source outsidecold78.
