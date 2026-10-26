set pagination off
set confirm off
break *lm_p0_pointer_source_offset
run C:/Nyasha_Planet/LMX/build2/codex_fix225p0fields01/ptrdiff-values-01/mix_brace_keeps_structure.lm2 C:/Nyasha_Planet/LMX/build2/codex_fix225receivingseed02/src/l2src/convert.lm2 C:/Nyasha_Planet/LMX/build2/codex_fix225receivingseed02/src/l2src/primitive.lm2 C:/Nyasha_Planet/LMX/build2/codex_fix225p0fields01/ptrdiff-values-01/p.lm1
set $actual_document = $rcx
set $actual_pointer = $rdx
set $actual_out = $r8
# LmP0Document.source is the first declared field in the generated P0 ABI.
set $actual_begin = *(unsigned long long *)$actual_document
printf "ACTUAL-P0-PTRDIFF pointer=%llu begin=%llu difference=%llu\n", $actual_pointer, $actual_begin, $actual_pointer-$actual_begin
finish
printf "ACTUAL-P0-PTRDIFF status=%d stored-offset=%llu\n", $eax, *(unsigned long long *)$actual_out
continue
quit
