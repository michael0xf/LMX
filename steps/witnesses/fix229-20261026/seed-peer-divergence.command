Completed G1 has L14118F102/C EF20DF9C, not the initial warm-seed
L101EF5257/C E21AE8B0. Original cold73-tool-peers-expected4.sha256 is
preserved and its expectation is contradicted for G1; do not call it PASS.
No source, expected value or compiler pipeline was restarted to hide this.
The actual diff and consumed source/header environments must be compared.
Separate G2 peer expectations use completed G1 bytes before G2 completion,
not a retrospective change of the original seed expectation.
G1 executable0395998C built/linked0; source/bootstrap status still pending.

Complete raw byte comparison (2026-10-26): decode one-to-one ISO-8859-1,
replace only literal l2_u20BD946DAFC5B452_ with l2_u52E20D99D6F98B49_
in warm seed, then compare entire strings ordinally with completed G1.
L1: 64187627 bytes each; 2655 old/new prefix occurrences; exact equality true.
C: 59411460 bytes each; 2453 old/new prefix occurrences; exact equality true.
No generated output was written or changed. Original raw hashes remain RED.
This proves the observed byte delta, not yet the cause of namespace selection.

Source readback establishes cause: existing l2trans.lm1:7239-7244 hashes
raw in_path bytes before parse; main passes argv[a] unchanged at70698 via
70583. Frames63493 and pointer-cell69113 names use the two path hashes.
Seed record:1 uses .../codex_fix229appdecl01/tools/lmxtool.lm2;
cold G1 record:1 uses .../codex_fix229declcold02/tools/lmxtool.lm2.
The different paths select those exact observed namespace prefixes.
This does not change the original raw comparison's RED result.

While G2 strict C compilation runs, independent GNU -c of the separate
pre-completion G1-based expected2 manifest returns0: both G2 L1/C OK.
No extra compiler or test pipeline was launched for these comparisons.
