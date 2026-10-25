nm.exe build2/codex_fix210/boot-quick-02/runtime/driver.o | Select-String lmx_thread_current
nm.exe build2/codex_fix210/boot-quick-02/smoke/lib_owner-native/p.o | Select-String lmx_thread_current
rg -n 'lmx_thread_current_slot|lmx_thread_current\(' build2/codex_fix210/boot-quick-02/runtime/driver.c build2/codex_fix210/boot-quick-02/smoke/lib_owner-native/p.c
