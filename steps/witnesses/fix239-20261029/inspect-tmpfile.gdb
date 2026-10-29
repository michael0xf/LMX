set pagination off
break *tmpfile
run
set $docs_return_addr = *(unsigned long long *)$rsp
tbreak *$docs_return_addr
continue
printf "DOCS_TMPFILE_RETURN ptr=%p\n", $rax
continue
quit
