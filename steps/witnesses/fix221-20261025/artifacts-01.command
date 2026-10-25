# Individual byte-binding invocations, not a maintained runner.
# Manifest includes selected raw221 inputs/artifacts and separately formatted packet copies.
# It excludes itself, mutable notes/current/checklist, new222 and unrelated/protected files.
cwd: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/runs/artifact-manifest-01
& 'C:/Nyasha_Planet/LMX/build2/codex_fix221cold/boot-quick-01/lmxtool.exe' 0 entry 0 -- manifest 'C:/Nyasha_Planet/LMX/steps/witnesses/fix221-20261025/artifacts-01.list' 'C:/Nyasha_Planet/LMX' 'C:/Nyasha_Planet/LMX/steps/witnesses/fix221-20261025/artifacts-01.sha256'
cwd: C:/Nyasha_Planet/LMX
& 'C:/Git/usr/bin/sha256sum.exe' --check --strict 'steps/witnesses/fix221-20261025/artifacts-01.sha256'
cwd: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/runs/artifact-verify-01
& 'C:/Nyasha_Planet/LMX/build2/codex_fix221cold/boot-quick-01/lmxtool.exe' 0 entry 0 -- verify 'C:/Nyasha_Planet/LMX/steps/witnesses/fix221-20261025/artifacts-01.sha256' 'C:/Nyasha_Planet/LMX'
