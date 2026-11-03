# Срез 273 — указательный параметр C принимает значение по своему контракту

Опубликован 2026-11-03, Opus. Закрывает находку Codex P1-C-POINTEE
(CODEX-OPUS-272-REVIEW-U5-20261103T154220Z-01) в коде среза 272.

P = build2/codex_fix250generationchain01. Архивные копии в [records](records)
приведены к UTF-8 LF без BOM и хвостовых пробелов, исходные receipts в P/pins не
менялись и связаны хэшами [evidence.sha256](evidence.sha256).

## Дефект и что изменилось

В срезе 272 для любого указательного параметра C-двери лист принудительно становился
`LMX_TYPE_NONE`. На глубине 1 это отключало проверку указуемого, поэтому неподходящий указатель или
ссылка на граф проходили в C под приведением к типу параметра. Зелёный `free_c_abi` проверял только
допустимые аргументы и этого не видел. Минимальный свидетель на кортеже 272: `size_t*` у параметра `int*`
вызвал функцию, `convert` не было.

Теперь контракт параметра решает, что проверяется. Новая операция ядра одна,
`lmx_walk_value_receive_c_pointer`:

- Лист `void` — действительно опаковый контракт: принимается любая ссылка.
- Лист с типом ядра (`int`, `char`, `size_t`, `unsigned`, `ulong`, `Lmx`, `LmxArray`) проверяется по
  фактическим указуемым тем же `lmx_walk_value_receive_pointer`. Несовпадение — `convert`. Указатель, чей
  указуемый ядро здесь типизировать не может, тоже `convert`, а не поздний `UNSUPPORTED`.
- C-тип без типа ядра известен только по коду указателя в записи. Один C-тип имеет код на каждое написание
  (`T`, `c.T`, их const-формы), поэтому транслятор спрашивает все свои коды этого слова и глубины
  (`lm_compiler_emit_c_pointer_receive`). Таблицы по именам C-функций нет.
- При любом листе присутствующий null принимается, указатель `void*` принимается как есть (программа
  привела его явно, C его преобразует). Число и внешнее значение — `convert`.
- Graph Array у `int*` — `convert`: Array не становится сырым массивом C (L2 §19). Явный машинный cast
  проходит как и раньше (L2 §20).

Лист по слову вынесен в `lm_compiler_dyn_leaf_of_word`, общий с `lm_compiler_dyn_pointer_shape`.
Типизированная C-дверь не менялась: там тип проверяет компилятор C.

Свидетель `tests/dyn/free_c_pointer.lm2`, строка `runs … 7 nf`, 1 новый вход. Потребители
(`lmx_walk_value_number`, `lmx_walk_value_field_place`, `lmx_range_slot_holder`) при нулевом первом аргументе
возвращают значение, не трогая указатель, поэтому дошедший неверный указатель виден как это значение, а не
как `convert`, и опасный вызов libc не нужен. Проверены `int*`, `size_t*`, `char*`, `void*` и внешний
`LmxWalkValue*` с фактическими `int*`, `size_t*`, `char*`, null, числом, Structure, Array, `void*` и явным cast.

| Кортеж | Результат `free_c_pointer` | Receipt |
| --- | --- | --- |
| Срез 272, G2 boot134b | exit 82 в обоих режимах: неверный указатель дошёл до функции | [terminal](records/pins/tp135-probe-sep272.terminal.txt) |
| Кандидат 273 | 7 в обоих режимах и обоих roots | [terminal](records/pins/tp135-probe-s02.terminal.txt) |

## Приёмка на замороженных байтах

Вход: 189 файлов, manifest `985904fd0bf0d09b9011fd9b9c594484c3d1ede2474c489becfe16336ac16378`, `P/cold-boot135a`.

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Whole boot135a | 16:00:57.2597788Z→16:18:22.0790541Z, BootstrapExit 0, 1044.82 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях | [terminal](records/pins/boot135a-quick.terminal.txt), [log](records/pins/boot135a-quick.log) |
| Сверка | source 189/0; producers g1 и g2: frontend 33, runtime 39, tool 6 шагов, все exit 0; 248/248, 496 хэшей, 0 stale; 245 raw-equal; 3 равных по размеру PE отличаются только байтами 136, 137, 216, 217; consumed 306/306 raw-equal; рабочий tool и bundle равны G2; runtime равен изолированному `rt135b` | [сверка](records/pins/boot135a-compare.txt) |
| G2 focus | 16:19:22.7347109Z→16:23:34.3741423Z, SuiteExit 0, `SUITE 37 rows, 0 failures` | [terminal](records/pins/tp135a-suite-g2.terminal.txt), [log](records/pins/tp135a-suite-g2.log), [список](records/pins/focus135-final.tsv) |
| G2-наблюдение free_c_pointer | 16:23:37.7226392Z→16:23:59.6623932Z, WitnessExit 0, 88 PASS; результат 7 во всех запусках; forced в обоих roots: m 1, outer_int 1, outer_size 1, outer_text 1, outer_null 1, outer_number 1, outer_graph 1, outer_array 1, refused_int 6, refused_size 3, refused_text 2, refused_record 2, refused_void 1; native этих тел не обходит. Тела `door_*`, `outer_void`, `outer_record` содержат C-дверь или cast и остаются native | [terminal](records/pins/tp135a-obs-pointerg2.terminal.txt), [log](records/pins/tp135a-obs-pointerg2.log) |

Tuple G2, `P/cold-boot135a/quick135a`:

| Артефакт | SHA-256 |
| --- | --- |
| `lmxtool.exe`, `g2/tool/lmxtool-tool.exe` | `edbba01de59e68f74038d6c67cd5d3d618357159189554c5c2f7011c19c307c2` |
| `g2/frontend/l2trans.exe` | `e53a3b0142b1306a6a55c0bbfb628a4acaebc7277723c39ec85c1d0c68da8518` |
| `g2/frontend/l1trans.exe` | `49a0f6a35c4a0de6eb27967c95bd812261028d929b667e3943e21b2bb47f557a` |
| `g2/frontend/l2_libc.o` | `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37` |
| `g2/runtime/driver.o` | `2417e433153a9b4a7ffb6531d1dbdb92800a228cb9e01ec68abb90d3171a0248` |
| `g2/runtime/driver-observe.o` | `5ba219c73c9724c620de322e4dbba98ac4340213d53bd26b37fcba16f5970c0c` |

G0: `P/cold-tp135/tool135a/lmxtool-tool.exe` `ca6b32821ba54b2121b8457042a9870f1c3526e54f30ee16a8ab01f31ea15dc8`. Предыдущий frontend — G2 среза 272
`c2ea29ac…`.

Посадка [land273](records/pins/land273.command): 8 шагов exit 0 ([terminal](records/pins/land273.terminal.txt)), 189 файлов, оба
поднабора по 65 исходников проверены. `selfbuild/inputs.sha256` побайтно равен frozen `985904FD…`, `inputs.list` —
`cbe2a92eab355e30fc48808075e63f9a4baf4f0daf02e5b8ed5c996cafe1c41e`.

## Границы

Открыто: U5 (тело с машинной операцией после записи кода), source-occurrence, вывод throws, остатки
proof-only/preflight, общий collector/resolver, три прохода, FULL, §§8/8a.

Const-вариант внешнего параметра и `char**` в свидетеле не проверены: код их поддерживает, но подходящего
потребителя без разыменования в predef нет.

В этом срезе Codex также попросил уточнить запись 272: predef — источник контракта, реализованный там, а не
норма; `[]: xs quote` — текущий предел реализации. [Запись 272](../fix272-20261103/notes.md) исправлена.

## Документальная часть

Книга и грамматика не менялись, поэтому `docs render` не запускался. Проверка новым рабочим tool на
проиндексированных путях среза, [docs273-check](records/pins/docs273-check.command),
16:25:13.7865356Z→16:25:41.3356930Z, exit 0: 35 парных глав, 14 случаев implements, 27 парных разделов
грамматики, 44 дословных фрагмента, 615 импортированных файлов, ссылки
([log](records/pins/docs273-check.log)). После неё менялись только эта запись, `evidence.*` и архивные
копии.
