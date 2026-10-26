Expected227 G2 L1/C/object are read from completed actual G1, not G2.
Read after G1 strictCC/link both exited0 (object completed07:05:40UTC).
The original expected3 pin file was created2026-10-26T07:06:24.677193Z;
expected2 was created07:04:28.1593726Z. These file times were read back.
G1 object38e86979 and EXEcc23aa03 are stable; actual G1child19496 currently
hashes its L1 under same bootstrap19196/session12137. G2 L1/C/object are
all absent at this read (False/False/False). Earlier original L1/C pins
g2-expected2.sha256 were recorded while G1 CC was still live.
Verify only after actual G2 terminal; no extra compile or bootstrap restart.
This is mixed-bootstrap evidence, not source-closed selfbuild or admission.
