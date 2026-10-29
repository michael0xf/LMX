set pagination off
break *docs_semantics_build
run
set $docs_phase_ptr = *(unsigned long long *)($rsp + 48)
set $docs_return_addr = *(unsigned long long *)$rsp
printf "DOCS_ENTRY phase_ptr=%p return=%p\n", $docs_phase_ptr, $docs_return_addr
tbreak *$docs_return_addr
continue
printf "DOCS_RETURN result=%d phase=%d\n", $eax, *(int *)$docs_phase_ptr
continue
quit
