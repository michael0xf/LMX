set pagination off
break *docs_semantics_prepare
run
set $docs_chapter_ptr = *(unsigned long long *)($rsp + 112)
set $docs_kind_ptr = *(unsigned long long *)($rsp + 120)
set $docs_return_addr = *(unsigned long long *)$rsp
printf "DOCS_PREPARE_ENTRY chapters=%llu chapter_ptr=%p kind_ptr=%p\n", $r8, $docs_chapter_ptr, $docs_kind_ptr
tbreak *$docs_return_addr
continue
printf "DOCS_PREPARE_RETURN result=%d chapter=%llu kind=%d\n", $eax, *(unsigned long long *)$docs_chapter_ptr, *(int *)$docs_kind_ptr
continue
quit
