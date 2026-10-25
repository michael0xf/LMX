# Actual generated module publication uses absolute paths, cwd211/src.
# Prior relative Copy-Item resolved inside src and FAILED; no C was produced or compiled then.
# Source05/module05 bytes unchanged, generated header remains its real sibling in src/l2src.
Copy-Item -LiteralPath C:/Nyasha_Planet/LMX/build2/codex_fix211/gen/lmx_walk_values-05.lm1 -Destination C:/Nyasha_Planet/LMX/build2/codex_fix211/src/l2src/lmx_walk_values.lm1
C:/Nyasha_Planet/LMX/bin/l1trans.exe C:/Nyasha_Planet/LMX/build2/codex_fix211/src/l2src/lmx_walk_values.lm1 C:/Nyasha_Planet/LMX/build2/codex_fix211/gen/lmx_walk_values-05.c
C:/Qt/Tools/mingw1310_64/bin/gcc.exe -pipe -std=c99 -O2 -fstrict-aliasing -Wall -Wextra -Werror=implicit-function-declaration -Werror=implicit-int -Werror=incompatible-pointer-types -Werror=discarded-qualifiers -I C:/Nyasha_Planet/LMX/build2/codex_fix211/headers -I C:/Nyasha_Planet/LMX/buold_temp/codex_header98_source_control_06/includes -I C:/Nyasha_Planet/LMX -I C:/Nyasha_Planet/LMX/lm1/build -I C:/Nyasha_Planet/LMX/build2/codex_fix211/src -fsyntax-only C:/Nyasha_Planet/LMX/build2/codex_fix211/gen/lmx_walk_values-05.c
