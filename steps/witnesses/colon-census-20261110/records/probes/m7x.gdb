set pagination off
set confirm off
break lm_compiler_own_host_at if *(long long*)($rdx+8) == 1 && **(char**)$rdx == 'p' && (int)$rcx != 0
commands
silent
printf "own_host_at mi=%d here_mi=%d cur_mi=%d at=%p at.offset=%d own_n=%d\n", (int)$rcx, (int)l2_here_mi, (int)l2_cur_mi, $r9, (int)*(long long*)(*(char**)((char*)$r9+8)+16), (int)l2_own_n
bt 9
continue
end
run C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/runs/fable-m6-probe01/m7t-main.lm2 C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/runs/fable-m6-probe01/m7t-part.lm2 C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/fable-main01/src/l2src/convert.lm2 C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/fable-main01/src/l2src/primitive.lm2 C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/runs/fable-m6-probe01/m7x.lm1
quit
