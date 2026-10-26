Exact seven-path source patch from published base
a36fd9a7a7f37c48c601c31fb7f61c4557ca1d4e.
Git archive selects only the two maintained files and five removed headers;
GNU tar --force-local extracts into private declcold02/replay7.
GNU patch --batch --fuzz=0 -p1 applies from228.patch, exit0, all seven paths.
Replayed recipe and runtime.list raw-compare equal to canonical, both cmp0.
Canonical recipe raw-compares equal to executed warm/cold1C87 bytes.
The patch removes the same five old files. They are recoverable in Git.
Final packet uses --unified=0: ordinary blank context lines in the initial
generated patch triggered diff-check whitespace. The original context
patch remains private pins/from228-context-original.patch. A fresh exact
base archive is replayed in replay7-u0, patch0 and both rawcmp0 again.

The initial tar invocation without --force-local interpreted C: as a remote
archive prefix and failed before extraction. The corrected explicit-local
invocation succeeded; no source or expectation was changed to hide it.
