Exact7-source staged Git -U0 patch, base223f43aa7c1772feb2daee56f8dd828ead5f1cff.
git archive exports only the6 existing base paths to pins/base226-source6.tar;
GNU tar --force-local extracts to fresh source-replay02. New helper is absent
in the base and created by the patch. GNU patch --batch --fuzz=0 -p1 succeeds0,
then GNU sha256sum of all7 final source pins succeeds0. Log source-replay02.log.
No maintained generated L1/API/C header, unrelated file or protected basename
is an archive/patch/hash/staging target. Canonical7 raw pins also pass GNU0.
