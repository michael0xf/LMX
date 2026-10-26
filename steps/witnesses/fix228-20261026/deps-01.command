After bootstrap45474 terminal0 and all verifier sessions terminal, serial
GCC dependency-only readback; no compile/link or new smoke.
GCC C:/Qt/Tools/mingw1310_64/bin/gcc.exe SHA920a4fc669e98ad444151afa558bbc71d1c4773ab136ee4c44374093a90c5ed1.
STAGE=C:/Nyasha_Planet/LMX/build2/codex_fix228interface03
REPO=C:/Nyasha_Planet/LMX
Frontend01: actual -std=c99 -O0 -DLMX_OBSERVE_WALK=0 and four guards;
include order STAGE/headers, REPO/buold_temp/codex_header98_source_control_06/includes,
REPO/build2/includes, REPO, REPO/lm1/build, STAGE/src; -MM -MF pins/deps-frontend-01.d
input boot-quick-01/frontend/frontend.c; actual exit0.
Runtime01: same frontend flags/order against runtime/driver.c; exit0,
retained as nonexact readback. Runtime02: actual -O2 -fstrict-aliasing,
same guards/OBSERVE_WALK=0, runtime includes omit REPO/build2/includes;
--param ggc-min-heapsize=16384 --param ggc-min-expand=20,
-MM -MF pins/deps-runtime-02.d boot-quick-01/runtime/driver.c; actual0.
Selected frontend13/runtime39 Cheaders all resolve below STAGE/headers.
