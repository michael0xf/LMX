# Saved individual preparation invocations; evidence, not a maintained runner.

cwd: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/runs/manifest-runtime-01
& 'C:/Nyasha_Planet/LMX/build2/codex_fix221/seed-01/lmxtool-tool.exe' 0 entry 0 -- manifest 'C:/Nyasha_Planet/LMX/tools/l2/inputs/runtime.list' 'C:/Nyasha_Planet/LMX/dev/l2src_sandbox' 'C:/Nyasha_Planet/LMX/build2/codex_fix221cold/checks/runtime.sha256'
stdout/stderr: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/trace/manifest-runtime-01.log

cwd: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/runs/copy-runtime-01
& 'C:/Nyasha_Planet/LMX/build2/codex_fix221/seed-01/lmxtool-tool.exe' 0 entry 0 -- stage-copy 'C:/Nyasha_Planet/LMX/build2/codex_fix221cold/checks/runtime.sha256' 'C:/Nyasha_Planet/LMX/dev/l2src_sandbox' 'C:/Nyasha_Planet/LMX/build2/codex_fix221cold/src/l2src'
stdout/stderr: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/trace/copy-runtime-01.log

cwd: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/runs/manifest-p0-01
& 'C:/Nyasha_Planet/LMX/build2/codex_fix221/seed-01/lmxtool-tool.exe' 0 entry 0 -- manifest 'C:/Nyasha_Planet/LMX/tools/l2/inputs/p0.list' 'C:/Nyasha_Planet/LMX/dev/l2src_sandbox/l1src' 'C:/Nyasha_Planet/LMX/build2/codex_fix221cold/checks/p0.sha256'
stdout/stderr: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/trace/manifest-p0-01.log

cwd: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/runs/copy-p0-01
& 'C:/Nyasha_Planet/LMX/build2/codex_fix221/seed-01/lmxtool-tool.exe' 0 entry 0 -- stage-copy 'C:/Nyasha_Planet/LMX/build2/codex_fix221cold/checks/p0.sha256' 'C:/Nyasha_Planet/LMX/dev/l2src_sandbox/l1src' 'C:/Nyasha_Planet/LMX/build2/codex_fix221cold/src/l1src'
stdout/stderr: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/trace/copy-p0-01.log

cwd: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/runs/manifest-driver-01
& 'C:/Nyasha_Planet/LMX/build2/codex_fix221/seed-01/lmxtool-tool.exe' 0 entry 0 -- manifest 'C:/Nyasha_Planet/LMX/tools/l2/inputs/driver.list' 'C:/Nyasha_Planet/LMX/dev/l2src_sandbox/harness' 'C:/Nyasha_Planet/LMX/build2/codex_fix221cold/checks/driver.sha256'
stdout/stderr: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/trace/manifest-driver-01.log

cwd: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/runs/copy-driver-01
& 'C:/Nyasha_Planet/LMX/build2/codex_fix221/seed-01/lmxtool-tool.exe' 0 entry 0 -- stage-copy 'C:/Nyasha_Planet/LMX/build2/codex_fix221cold/checks/driver.sha256' 'C:/Nyasha_Planet/LMX/dev/l2src_sandbox/harness' 'C:/Nyasha_Planet/LMX/build2/codex_fix221cold/src'
stdout/stderr: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/trace/copy-driver-01.log

cwd: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/runs/manifest-tools-01
& 'C:/Nyasha_Planet/LMX/build2/codex_fix221/seed-01/lmxtool-tool.exe' 0 entry 0 -- manifest 'C:/Nyasha_Planet/LMX/tools/l2/inputs/tools.list' 'C:/Nyasha_Planet/LMX/tools/l2' 'C:/Nyasha_Planet/LMX/build2/codex_fix221cold/checks/tools.sha256'
stdout/stderr: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/trace/manifest-tools-01.log

cwd: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/runs/copy-tools-01
& 'C:/Nyasha_Planet/LMX/build2/codex_fix221/seed-01/lmxtool-tool.exe' 0 entry 0 -- stage-copy 'C:/Nyasha_Planet/LMX/build2/codex_fix221cold/checks/tools.sha256' 'C:/Nyasha_Planet/LMX/tools/l2' 'C:/Nyasha_Planet/LMX/build2/codex_fix221cold/tools'
stdout/stderr: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/trace/copy-tools-01.log

cwd: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/runs/manifest-tests-01
& 'C:/Nyasha_Planet/LMX/build2/codex_fix221/seed-01/lmxtool-tool.exe' 0 entry 0 -- manifest 'C:/Nyasha_Planet/LMX/tools/l2/inputs/tests.list' 'C:/Nyasha_Planet/LMX/tests/l2' 'C:/Nyasha_Planet/LMX/build2/codex_fix221cold/checks/tests.sha256'
stdout/stderr: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/trace/manifest-tests-01.log

cwd: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/runs/copy-tests-01
& 'C:/Nyasha_Planet/LMX/build2/codex_fix221/seed-01/lmxtool-tool.exe' 0 entry 0 -- stage-copy 'C:/Nyasha_Planet/LMX/build2/codex_fix221cold/checks/tests.sha256' 'C:/Nyasha_Planet/LMX/tests/l2' 'C:/Nyasha_Planet/LMX/build2/codex_fix221cold/tests'
stdout/stderr: C:/Nyasha_Planet/LMX/build2/codex_fix221cold/trace/copy-tests-01.log
