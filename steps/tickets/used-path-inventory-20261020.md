# USED-PATH-INVENTORY: общий результат пути вместо старого used-parser

Статус: **OPEN**, обнаружен Codex2026-10-20. Это дефект реализации и
зависимость общего producer вложенных карт, не новая норма языка.
База `01841adf`, последний принятый code slice `c277fab4`.
Frontend17 raw blob `48e945b61576ae59b2e1c35da9615799a8cf4ed4`
совпадает с текущим `dev/l2src_sandbox/l2trans.lm1`.

## Воспроизводимый дефект области видимости

- [shadow](../witnesses/used-scope-20261020/shadow.lm2): вложенный `inner`
  объявляет собственный формал `m`, внешний `check` использует только `m\x`.
  Требуемое наблюдение —7; вложенный формал не требует `y` от внешнего `m`.
- [renamed](../witnesses/used-scope-20261020/renamed.lm2): тот же вложенный
  формал переименован в `q`; внешнее поведение не должно меняться.
- [required](../witnesses/used-scope-20261020/required.lm2): внешний `check`
  действительно читает `m\y`; отсутствие поля должно оставаться отказом.

Норма: новая callable-активация имеет свою область связывания, inline
управление — нет; требования Consumer следуют разрешённым употреблениям,
не совпадению написания имён. См. [инструкцию](../../L2_L3_CODING_INSTRUCTION.md)
и [v3](../../next_core_tasks_v3.md). Здесь нет конфликта двух норм и
не требуется новое решение автора.

`build/codex_used_scope_probe_04/results.json`: на принятом17 shadow
отвергнут при передаче `check(copy)` с `implements is false in function
argument`, renamed даёт L1, required правильно отвергнут; одинаково
native и `--walk-methods`. Тот же результат на private23 сохранён в
`build/codex_used_scope_probe_03/results.json`. Это **12 проверок
трансляции**, не12 реальных исполнений. Renamed ещё требует runtime
oracle7 в обоих режимах и обоих root routes; компиляции во вторую
GCC очередь не запускались. Не добавлять этому GREEN только по MadeL1.

Дополнительно тот же результат подтверждён **шестью трансляциями самим
замороженным опубликованным compiler17**, не только его debug-сборкой:
`build/codex_used_scope_published17_01/results.json`. SHA256 бинарника
`9a7327666a5eff8dad665b678febc7adba85383a1e790fa6cc924ffc743b772b`
проверен по immutable manifest полного08. Для запуска скопированы те же
байты под другим именем, чтобы не попасть в process-name memory sampler
активного full11. Это ещё не runtime-проверки значений и не измерение
изолированного пика памяти.

Источники17/23, три свидетеля, результаты18 завершённых трансляций,
неудачные попытки probe01/02 и обе causal traces заморожены65 независимо
проверенными пинами `build/codex_used_scope_completed_01.inputs.sha256`.
Verifier02 исправляет опечатку в ожидаемом SHA required; verifier01
остановился до создания receipt и ничего не принимал.

Оригинальные build sources соответствуют versioned witnesses по сырым
байтам, а не по текстовому сходству; basename/absolute diagnostic path
у probe другой. SHA256 content:

| Witness | SHA256 |
| --- | --- |
| shadow | `a5513664b2e238a0fa1bdcf46f2c07bbdc4f8a76ca02d50e7b6828dfac726921` |
| renamed | `7617c909685626bed9431539e4e20e72a088df902aa1c1a15a19dce465c57fec` |
| required | `e3e1d3211fef7774261135726b3a46745b93ea0bbe46c56b009d6c1128db9fc0` |

## Причина проверена, не выведена только из grep

`build/codex_used_scope_cause_01.gdb` на23 остановился в
`l2_descriptor_used`: у shadow к Consumer внешнего `check` собраны
`y` и `x`, у renamed — только `x`. Логи по двум программам имеют
prefix `build/codex_used_scope_cause_01.`.

При этом `build/codex_used_scope_roots_01.gdb/.log` показывает, что
общий `l2_path_walk_steps` уже различает исходные употребления:
`m\x` — method0/formal0/schema0; `m\y` — method1/formal0/schema1.
Старый отдельный collector теряет разрешённую принадлежность корня и
потом объединяет их по одному написанию. Следовательно, нельзя лечить
это списком исключений `fn`/`if` либо новым сканером shadowing.

## Оставшиеся отдельные маршруты

Места в принятом17 frontend, не координаты private23:

- `l2_uses_scan_follow`:23877 и `l2_uses_walk_node`:23983 — отдельное
  распознавание строк/атомов и склейка `l2_uses_buf`;
- `l2_descriptor_used`:24032 — повторно делит suffix по `\`, разбирает
  `[N]`, отдельно идёт по двум схемам;
- `l2_anchor_covers`:38783 и `l2_anchor_used`:46388 — другие повторные
  разборы того же буфера;
- `l2_ruse_path`:44943 уже вызывает общий resolver, но получает заново
  склеенный текст от собственного `l2_ruse_follow`/сканера упоминаний;
  `ruse` имеет собственные неизвестность/пересылку/definition эвристики.

Поэтому принятые полные mixed-path folds для эмиссии/receiving ещё
**не являются доказательством единого анализа всех Consumer**.
Прежние выводы конкретных gates остаются в своих границах; весь K09,
общий static path analysis и §§8/8a здесь не объявляются закрытыми.

## Направление одного исправления

Сохранить результат общего root/step resolver с исходным связыванием
и полным AST индексов; именно он должен стать инвентарём требований
Consumer. Передавать требования по существующим адресным фактам
formals/hidden/own/fields/calls, а не считать строку имени идентичностью.
Inline `if`/`for`, копии и тела управления пользуются тем же владельцем
связывания; вложенный callable — своим уже разрешённым namespace.

Из этого одного инвентаря получить static comparison, anchors, coverage,
child-pair projections и обе backend representations. Не сохранять
старые парсеры запасным маршрутом, не брать candidate.parent/global
Model вместо текущего model origin, не публиковать часть nested maps
раньше общего successful admission. Частные ядра pending10 дают
механику совместного доказательства/публикации, а не этот producer.

Перед приёмкой нужны все положительные/отрицательные/forwarding/
capture/node/copy/control/index случаи, реальные значения и `@` в
native/forced walker, mutants потери scope/map и полный gate на тех же
байтах. Не заменять перечисленное условием «добавлен общий helper».

## Частный ранний producer25 — ещё не исправление

В `build/codex_mixed_path_fold_25` существующий `l2_scan_path` прохода
свободных имён сохраняет подготовленный путь, AST индексов и разрешённую
принадлежность корня **до** раннего отсечения кандидатов. Новый сканер
текста или исключение для вложенного `fn` не добавлены. Новые observations
различают исходное употребление и служебный запрос транслятора; stage0
хранит грамматику/корень, stage1 означает выполненный общий semantic walk,
а не обязательно успешное разрешение. Контекст хранится существующим
`L2SourceSite`, освобождение его scopes включено в общий cleanup.

`build/codex_path_facts25_syntax_01/result.json`: frontend и header25
переведены L1→C теми же pinned bootstrap bytes. Чтобы не попасть в sampler
живого full11, использовано другое имя byte-identical бинарника; GCC и
исполнения не запускались.277 syntax/input pins независимо проверены
в `build/codex_pathfacts25_syntax_evidence_01.inputs.sha256`;187 прочих
source files совпадают с24 по сырым байтам. Это **не** C build, runtime
proof, полный инвентарь Consumer или приёмка.25 пока не queued и в dev
не переносился; recipe/probe сохранены для проверки после текущей очереди.

Следующие обязательные зависимости не исчезли: replay сохранённого
контекста после замыкания типов, роли употреблений, перенос требований
по разрешённым forwarding/capture edges и удаление старых consumers.
Передача целой ссылки сама по себе не означает потребление каждого поля
её объявленной модели; нельзя подменять этим точный анализ downstream uses.
