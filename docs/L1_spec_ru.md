# Спецификация L1

Область — язык L1, трансляция в C99 и реализация ядра L2 на L1/C. Основание — `l1src/` (16 файлов с корня L1) и `l2src/` (песочный снимок ядра), коммит L1 `b2a7c98aa59aaf9654f2180e6f2a149e58aa48ee`. Семантика L3 — [основная спецификация](LMX_semantics.ru.md). Операции и модель ядра на уровне L2 — [спецификация L2](L2_spec_ru.md). Срез и расхождения — [журнал миграции](../steps/l1-l2-migration.md).

Каждый механизм ядра имеет основное определение в L2; здесь — как он записан на L1 и во что опускается в C99. Не повторять общие правила: ссылаться на якорь L2.

<a id="scope"></a>
## 1. Предмет

Translator-L1 (`l1src/l1trans.lm1`) — синтаксически направленный понижатель wrapperless `.lm1` в одну единицу трансляции ANSI C99 на вызов. Это не L2: в профиле L1 нет онтологии `Lmx`, арены Message и таблиц `implements` как языковых форм. Ядро L2 **написано** на L1 и является входом того же транслятора. Самосборка: `l1src/build_l1.lm1`, поколения gen0…gen3 (см. `l1src/README.md`). Пин рабочего `l1trans.exe` в корне L1: `L1_PIN.txt` = `4E0B7F5D942C291AFD4C2CEB8FBBA5B20EECC44BF7B455A40D8E564846D80DE7`. Парсер P0 — `parser.lm1` + `p0.h` / `p0.h.lm1` + `own.lm1`.

<a id="translator"></a>
## 2. Транслятор

Вход: файл с конечным расширением `.lm1`. Временный совместимый путь явного `L1:` в `.lm2` не делает два транслятора взаимозаменяемыми. Понижение членов в C — не контракт разрешения путей L2 через граф `Lmx`.

Префикс `@` в L1 — взятие адреса C этой привязки (`p: @ value` → `&value`). Длинные прогоны `@` в деклараторах — звёзды указателя C, не повторный address-of. Обратный слэш: ведущий `\` — сырая загрузка указателя; `value\field` — поле, в C `->`. Повторяющиеся короткие объявления, `c.array`, `define`/`ifdef`, `os: win:/default:` — приняты проверяемыми наборами `tests/l1/run_*.ps1` в дереве L1 (исторические прогоны; в LMX не импортированы как норма).

Дверь в libc — объявления в `l1src/libc_abi.lm1` и вызовы `c.имя`. Заголовочные единицы L1 объявляют; исполняемое тело в заголовке отказывается.

Измеренные ловушки транслятора (deepseek, не норма языка, пока автор не подтвердит): `\` по значению эмитится как `->`; присваивание не объявляет локальную; на измеренной платформе `ulong` 4 байта, `size_t` 8; `predef:` тянет весь исходник. Форма `@(TYPE) name` не разбирается; нужно `@(TYPE name)` или `@: TYPE name` (коммит L1 `18bdab8`).

<a id="lmx"></a>
## 3. `Lmx` на L1

Определение полей — [L2 §2](L2_spec_ru.md#lmx). На L1 это `struct: Lmx` в `l2src/lmx.h.lm1`; C-заголовок порождается транслятором. Поля — L1-типы `@: Lmx`, `int`, `@: void`. Нет отдельного тега в записи. Слот ребёнка — ячейка массива `void *`; адрес слота даёт `lmx_arena_refs` / прежний `lmx_branch_slot`.

<a id="type-by-range"></a>
## 4. Тип по диапазону на L1

Правило — [L2 §3](L2_spec_ru.md#type-by-range). Перечисления и `LmxRange` — тот же `lmx.h.lm1`. Индекс принадлежит арене; классификация — функции `lmx_range_*` из `lmx_arena.h.lm1`, тела в `lmx_range.lm1` / `lmx_arena.lm1`. Домены механизмов — `#define` в `lmx_implements.h.lm1`, не поля `LmxMsg`.

<a id="pool"></a>
## 5. Пул на L1

Правило — [L2 §4](L2_spec_ru.md#pool). Структуры чанка и пула — `lmx.h.lm1`. Акты `lmx_pool_open`, `lmx_pool_make`, `lmx_pool_take`, `lmx_pool_take_n`, `lmx_pool_add_chunk` объявлены в `lmx_pool.h.lm1`, реализованы в `lmx_pool.lm1`. Рост — новый чанк как блоки арены, чтобы `revert` снял интервал вместе с ними.

<a id="method-array"></a>
## 6. METHOD и Array на L1

Правило — [L2 §5](L2_spec_ru.md#method-array). `fnptr: LmxEntry () void`; `struct: LmxMethod` и `LmxArrayDesc` в `lmx.h.lm1`. Типизированные пулы Array — модули `lmx_array_owned`, `lmx_array_ref_owned`, `lmx_chars_owned`, `lmx_value_owned`.

<a id="arena"></a>
## 7. Арена на L1

Правило — [L2 §6](L2_spec_ru.md#arena). `struct: LmxArena` и прототипы — `lmx_arena.h.lm1`; тела — `lmx_arena.lm1`. Блоки — `lmx_arena_blocks.h.lm1` / `.lm1`. Слоты Structure — `lmx_arena_refs.h.lm1` / `.lm1`. Поколение сборщика — поле `generation`; простой режим — `simple`.

<a id="message"></a>
## 8. Message на L1

Правило — [L2 §7](L2_spec_ru.md#message). `type: LmxFlag uint_fast8_t`; `struct: LmxMsg` в `lmx_message.h.lm1`. Комментарий исходника задаёт чтение `running` / `handoff_ready` через нагрузку вроде `__atomic_load_n(..., RELAXED)` там, где это совпадает с обычной volatile-нагрузкой, без RMW и без лишнего fence; это описание реализации, не новое правило L3. Самотест порядка полей — `lmx_message_selftest.lm1`. Хуки опроса объявлены в `lmx.h.lm1` (`lmx_msg_poll_abort`, `lmx_msg_poll_escape`), тела — на стороне ядра.

<a id="thread"></a>
## 9. L3 Thread на L1

Правило — [L2 §8](L2_spec_ru.md#thread). `struct: LmxThread` / `LmxLink` — `lmx_thread.h.lm1`; тела — `lmx_thread.lm1`. Ход — `lmx_thread_turn`. Планировщик объекта — `lmx_manager` / `lmx_schedule`, открывается `lmx_thread_scheduler_open`. Цепочка детей — ячейки арены родителя.

<a id="mailbox"></a>
## 10. Почта на L1

Правило — [L2 §9](L2_spec_ru.md#mailbox). `struct: LmxPost`, кольцо inbox и списки outbox/staged — `lmx_post.h.lm1`; тела — `lmx_post.lm1`. Допуск цели — `lmx_post_admits` через домен адреса. Доставка между объектами — `lmx_deliver`.

<a id="own"></a>
## 11. Own на L1

Правило — [L2 §10](L2_spec_ru.md#own). `lmx_own_load` / `lmx_own_write` / `lmx_own_checkpoint` — `lmx_own.lm1`. Смежная книга dirty на ходе — `lmx_dirty.h.lm1`.

<a id="call"></a>
## 12. Вызов на L1

Правило — [L2 §11](L2_spec_ru.md#call). `fnptr: LmxCallEntry (@: Lmx node) int`; `lmx_call0` — `lmx_call.lm1`. Сопоставление сигнатуры — обязанность транслятора, не этого модуля.

<a id="child"></a>
## 13. Ребёнок на L1

Правило — [L2 §12](L2_spec_ru.md#child). `lmx_child_create` / `reserve` / `publish_prepared` / `drop_prepared` / `handoff` — `lmx_child.lm1`.

<a id="copy-merge"></a>
## 14. Копия и merge на L1

Правило — [L2 §13](L2_spec_ru.md#copy-merge). `lmx_graph_copy_owned.lm1`, `lmx_merge_owned.lm1` и парные `.h.lm1`.

<a id="implements"></a>
## 15. `implements` на L1

Правило — [L2 §14](L2_spec_ru.md#implements). `lmx_implements` отвечает «один ли это род по диапазону». `lmx_runtime_implements` обходит used-дерево Consumer. Это не полный исходный предикат L2 §2.1.

<a id="gc"></a>
## 16. Сбор на L1

Правило — [L2 §15](L2_spec_ru.md#gc). `lmx_gc_collect` — `lmx_gc.lm1`.

<a id="c99"></a>
## 17. Опускание в C99

Один вызов транслятора даёт один `.c`. Строгая сборка поколений: `-std=c99 -Wall -Wextra -Wpedantic` и `-Werror=` на несовместимые указатели, отброшенные квалификаторы, неявные объявления. `os:` выбирает Windows или POSIX (`l1trans.lm1`). `include:` / `predef:` становятся включениями C. Агрегаты L1 `struct:` / `enum:` / `fnptr:` / `type:` опускаются в C99 typedef/struct. Это не модель памяти L2: модель памяти задаёт арена ([L2 §6](L2_spec_ru.md#arena)).

<a id="unresolved"></a>
## 18. Неразрешённое

См. [L2 §17](L2_spec_ru.md#unresolved) и [журнал](../steps/l1-l2-migration.md). Дополнительно по транслятору: пробелы разбора на модулях порта mixa (`empty colon Frame`, `unsupported statement atom`, trailer на узле) записаны deepseek как измерения, не как правила L1.
