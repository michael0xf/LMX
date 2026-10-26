Serial GCC dependency-only readback after whole SHORT80535 actual terminal0
observed2026-10-26T05:27:58UTC. No C compilation, link or fixture rerun.
Use actual frontend/runtime compile include order and macros; replace the
compile/link output action with -MM -MF. Frontend actual source frontend.c,
not l2trans.c. Runtime uses its production OBSERVE_WALK=0 configuration.
Tool C:/Qt/Tools/mingw1310_64/bin/gcc.exe
SHA256920A4FC669E98AD444151AFA558BBC71D1C4773AB136EE4C44374093A90C5ED1
cwd C:/Nyasha_Planet/LMX. One GCC/readback pipeline only.
