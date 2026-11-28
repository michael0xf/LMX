# MIR: Python определяется native host

**Выбор: тот же CPython, который выбран для ОС, исполняющей MIR.** MIR не является отдельной операционной системой и не требует «Python, написанного на MIR». Windows/Linux/macOS используют свой private python-build-standalone; Android — свой CPython Android embeddable. Все profile files находятся в соседних платформенных директориях.

MIR вызывает одну фиксированную host bridge function с согласованным C prototype и обычными request/result carriers. Реальные Python objects остаются у host provider; MIR imports не получают право произвольно разыменовывать LMX/Python pointers. Import регистрируется `MIR_load_external` или штатным resolver и связывается `MIR_link`; это ordinary ABI adapter. [MIR C API](https://github.com/vnmakarov/mir/blob/master/MIR.md).

Установка runtime — обычная app-private установка host-платформы. Сам MIR-модуль не загружает случайный DLL/so по Python module name и не вычисляет runtime filesystem layout. [PythonProfileSelect](../../src/profiles.lmx) для target MIR выбирает только явно заданный host.

**Альтернатива:** `py.*` передаются system-Python worker/endpoint той же host ОС через общий external provider. Вход/выход хранится в bounded DATA/handles; CPython ABI не внедряется в MIR instruction stream.

Пример [platform_selection.lmx](../../examples/platform_selection.lmx) выбирает MIR+Linux profile. Приёмка: общий call/error/lifetime набор плюс MIR prototype/calling convention и фактическая потребность в executable memory. Не обещать поддержку MIR generator на любом C99 host.
