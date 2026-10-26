Every language command below uses its own newly created runs directory.
Tool boot-quick-01/tool-g2/lmxtool-tool.exe, SHAee945db9.
runs/verify-final3: 0 entry 0 -- verify pins/final-bindings3.sha256 STAGE
runs/verify-source78: 0 entry 0 -- verify ../codex_fix228consumeradmit01/pins/private78.raw.sha256 STAGE
runs/exe-same: 0 entry 0 -- exe-same tool-g1/lmxtool-tool.exe tool-g2/lmxtool-tool.exe
All paths in the actual invocations are absolute.
Independent C:/Git/usr/bin/sha256sum.exe -c reads the same manifests.
Independent C:/Git/usr/bin/cmp.exe reads working versus G2 and canonical
values versus executed stage source. No build or smoke is repeated.

First final3 invocation58647 exited1/3failed: the language verifier treats
manifest paths as root-relative, so the absolute entries could not resolve.
Independent GNU -c passed all3 absolute entries, both rawcmp commands0.
Corrected final-bindings3-relative.sha256 preserves every expected hash and
uses repo-relative paths with REPO as root. Original absolute file and RED
log are retained; this is path correction, not changed expected bytes.
