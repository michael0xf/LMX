# Section 1 — MIR, цель L1, L1/L2 #2

**Нормативная цель backend, implementation acceptance NOT_RUN.** MIR — промежуточное представление и C API; ОС и Python deployment определяются native host. См. отдельный [PYTHON.md](PYTHON.md).

Основное описание: [MIR.md](https://github.com/vnmakarov/mir/blob/master/MIR.md), включая `MIR_context_t`, модули, инструкции, imports и C интерфейс. Модули можно читать/писать через `MIR_read`/`MIR_write`, загружать `MIR_load_module`, связывать `MIR_link`, исполнять interpreter через `MIR_interp_arr`. Native C imports задаются `MIR_load_external` либо resolver. Разные contexts могут принадлежать разным threads; один общий context не получает такой гарантии автоматически.

LMX L1 lowering потребляет общий подготовленный граф/операции LMX. Он не строит новый parser, не переопределяет precedence и не меняет L2/C boundary. Типы, signed/unsigned arithmetic, traps и pointer ownership сохраняются в явном ABI plan. Backend является необязательным способом исполнения C-совместимого runtime.

Interpreter API и C-callable trampoline — разные режимы: MIR документирует, что C interface для интерпретируемой функции использует generated machine interface и ограничен поддержанными generator targets. Поэтому нельзя заявить portable executable-memory-free режим для всех разновидностей MIR foreign call. Для запрета JIT на host сначала проверить фактическую цепочку входа/выхода и выбрать допустимый interpreter/host import route.

Приёмка: одинаковые результаты с native C path, реальные import prototypes, values/float/stack alignment, lifetime contexts, повторное link/versioning, interpreter-only нужной платформы и отдельно разрешённый JIT. Готовность CPython host не доказывает корректность MIR bridge.
