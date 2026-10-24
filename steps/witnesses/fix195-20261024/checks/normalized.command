# Text comparisons only; no translation, compilation or program execution.
# cwd C:/Nyasha_Planet/LMX/build2; bash, the same path-prefix normalisation as slice 192.
E='s/l2_u[0-9A-F]\{16\}_/l2_uHASH_/g'
diff <(sed "$E" opus_fix194/boot-quick-01/tool-g2/lmxtool.lm1) <(sed "$E" codex_fix195/boot-quick-01/tool-g2/lmxtool.lm1)
printf 'tool_l1_diff_exit=%s\n' "$?"
diff <(sed "$E" opus_fix194/boot-quick-01/tool-g2/lmxtool.c) <(sed "$E" codex_fix195/boot-quick-01/tool-g2/lmxtool.c)
printf 'tool_c_diff_exit=%s\n' "$?"
diff -rq --exclude=l2_driver_launch.err opus_fix194/src codex_fix195/src
printf 'src_diff_exit=%s\n' "$?"
diff -rq --exclude=l2_driver_launch.err opus_fix194/headers codex_fix195/headers
printf 'headers_diff_exit=%s\n' "$?"
