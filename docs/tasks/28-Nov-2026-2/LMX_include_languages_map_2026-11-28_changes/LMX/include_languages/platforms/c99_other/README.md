# Остальные C99-совместимые платформы

**Требование к архитектуре ядра:** ядро LMX должно собираться на других C99-совместимых платформах. Перечисление именованных платформ не разрешает неявно зашить в общие алгоритмы Windows/POSIX, 64-bit pointers, little endian, JIT или доступность Python.

Переносимый слой включает граф, prepared calls, проверяемые Array/pointer операции, P0, grouping и Message-политику. Реальные filesystem/network/time/native synchronization/executable-memory функции задаются host contracts. Если target не имеет native threads, штатный Message использует доступное последовательное исполнение. Новый scheduler или LMX `synchronized` не добавляются; необходимые физические примитивы остаются внутри L2/host adapter и не заменяются `volatile`.

Использовать C99 integer/size/alignment contracts и checked overflow. `CHAR_BIT`, размеры primitive types и pointer representation проверяются явно. Не разыменовывать typed pointer в недостаточно выровненном arena address; переносить bytes через допустимый access path. C99 не обещает C11 atomics, threads, POSIX `dlopen`, sockets или GNU extensions.

Freestanding и hosted — разные build profiles. Freestanding требует supplied allocation/I/O/runtime services и явного списка исключённых библиотечных возможностей; отсутствие ОС не должно маскироваться fake success. Если физическая representation LMX требует свойство target, build admission фиксирует это как ограничение порта.

Для каждого нового host нужны C99 compilation receipt, реально исполняемый минимальный kernel suite, data-model/byte-order tests, resource ownership и корректные unavailable outcomes. Пропущенный тест не получает статус PASS.

Python — optional provider, описанный отдельно в [PYTHON.md](PYTHON.md). Сборка переносимого ядра не зависит от Python headers, shared library либо package manager.
