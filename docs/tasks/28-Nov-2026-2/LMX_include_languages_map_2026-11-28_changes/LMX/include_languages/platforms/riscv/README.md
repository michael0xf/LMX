# Section 3 — RISC-V ISA, цель L1, L1/L2 #5

**Цель L1, native acceptance NOT_RUN.** Основной источник — [RISC-V unprivileged ISA](https://docs.riscv.org/reference/isa/unpriv/unpriv-index.html). Python — в отдельном [PYTHON.md](PYTHON.md).

ISA не определяет ОС, dynamic loader, libc или Python runtime. В target descriptor отдельно задаются XLEN, extensions, endianness, C ABI, float ABI, libc и host services. Для первого hosted acceptance выбран RV64 Linux с явно согласованными extensions/LP64D ABI; это не обещание совместимости со всеми RV32/RV64 устройствами.

Native calls используют реальный [RISC-V ELF psABI](https://riscv-non-isa.github.io/riscv-elf-psabi-doc/), включая integer/float arguments, aggregate return, stack alignment и preserved registers. L1 emitter не угадывает соглашение из одной ISA таблицы. Недостающие M/A/F/D/C/extensions либо эмулируются конкретным проверенным lowering, либо объявляются отсутствующими.

Unaligned memory access, byte order, integer overflow и floating semantics не подменяются поведением x86 host. JIT code publication требует согласованного I-cache protocol и executable-memory host adapter. Compiler builtin/OS fence interface может быть частью adapter; C99 ядро не получает произвольные ISA instructions как обязательные primitives.

Freestanding RISC-V собирает переносимое ядро только с supplied allocation/I/O/scheduling contracts выбранного профиля. Отсутствующие возможности остаются явными; нет обещания host processes, shared libraries или CPython на «голой ISA».

Приёмка: C99/native reference и L1 emitter на одном ABI, реальные integer/float/struct calls, endian/alignment tests, atomics/Message ordering по host contract, instruction-cache publication при наличии JIT. QEMU и физический target receipts различаются.
