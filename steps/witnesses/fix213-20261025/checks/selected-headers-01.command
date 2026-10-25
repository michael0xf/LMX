# Same actual ordinary runtime compiler/include order; dependency observation only, no C rebuild.
# Run only in an observed GCC-free interval of the existing chain or after its terminal state.
& 'C:/Qt/Tools/mingw1310_64/bin/gcc.exe' -std=c99 -MM -I 'C:/Nyasha_Planet/LMX/build2/codex_fix213/headers' -I 'C:/Nyasha_Planet/LMX/buold_temp/codex_header98_source_control_06/includes' -I 'C:/Nyasha_Planet/LMX' -I 'C:/Nyasha_Planet/LMX/lm1/build' -I 'C:/Nyasha_Planet/LMX/build2/codex_fix213/src' 'C:/Nyasha_Planet/LMX/build2/codex_fix213/boot-quick-01/runtime/driver.c'
