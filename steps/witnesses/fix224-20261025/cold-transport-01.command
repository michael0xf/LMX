Controller C:/Nyasha_Planet/LMX/build2/codex_fix223seed02/gen/lmxtool-tool.exe, SHA256720FB50CD646CCD274E9AF070F549B1E2C76833D4F101C97EF93C7BE8F67AC73.
Base main d8a89b41b2b74eec0c17d2b39af7c87160e09b48.
Each manifest and copy executes in a distinct fresh codex_fix224cold01/runs/<group>-manifest-01 or <group>-copy-01 cwd.
The existing manifest/stage-copy CLI is used, not a new runner.
runtime: tools/l2/inputs/runtime.list; source dev/l2src_sandbox; target cold01/src/l2src; expected45.
p0: tools/l2/inputs/p0.list; source dev/l2src_sandbox/l1src; target cold01/src/l1src; expected2.
driver01: tools/l2/inputs/driver.list; mistakenly source dev/l2src_sandbox; expected1, actual HASH-FAIL, manifest/outer exit1. No driver copy executed.
tools: tools/l2/inputs/tools.list; source tools/l2; target cold01/tools; expected8.
tests: tools/l2/inputs/tests.list; source tests/l2; target cold01/tests; expected13.
Manifest outputs are codex_fix224/pins/canonical-<group>.sha256; logs cold01/trace/<group>-manifest-01.log and <group>-copy-01.log.
driver02 uses the correct dev/l2src_sandbox/harness source and the already pinned A89128FC driver manifest from223; the failed01 input/manifest/log is not overwritten.
The scanner, parser and recipe224 overlay is explicit and will be pinned before the70-input cold build. No generated C/L1 headers or objects are transported into cold01.
