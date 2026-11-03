# Срез 271 — фактическое место INDEX (WIP)

База: опубликованный 45cafc25519123f6b1343d40779342c8efeea686, selfbuild270
b9af771a661c8a2ecff90dcd881c055af974d301460d3493fa5cf9d69533a916, 184 входа.
Единственный writer/build — Codex. Fable остановлен; Opus ожидает.
Цель §§8/8a активна. Этот срез — зависимость общего доступа N4-U, не завершение
C, общего collector, трёх обходов, FULL или §§8/8a.

Рабочий кандидат P/variants/tp133, подготовленный P/cold-tp133;
P = build2/codex_fix250generationchain01. Публикация 270 и её frozen inputs
не меняются. Базовые хэши и точный набор изменений: pins/tp133-baseline.json.
Первоначальный manifest кандидата: faa09e9d15ec4500bd7f112534d0f5e24cc72e1e4b0e361ee29967dc0b7ae622.

Разрыв исходной реализации: путь от FREE разрешал именной шаг через общую
операцию, но INDEX раньше этого требовал статический контракт. Кандидат
сохраняет написанный INDEX и даёт native и ELEM/ELEMPUT одну операцию
lmx_walk_value_index_place. Array использует прежний lmx_value_array_place,
указатель — фактическую классификацию DEREF. Чтение/запись/адрес используют
полученное место; индекс принимается обычным size_t receive. Новой семантики
для var или скрытого изменения data нет.

Разделяющий fixture free_index_places.lm2: скрытые int*/size_t*/Array,
read/write/@, сохранение held bare value, пойманные convert и interpreter.
Результата пока нет. Исходные вхождения s\\[N]field и остальные открытые
границы не объявляются реализованными этим изменением.

Начальные prepare/reuse завершились 6/5 шагами exit 0. Новый tool собирается
обычной L3 rebuild-командой из boot132c/G2; затем runtime/component frontend
и малый фокус. Никакие старые успешные проверки не повторялись.

## Компонентная отладка

Tool133, rt133a и fe133a собраны exit0. Два первых фокуса красные:
suite01 — непойманный отказ; suite02 с временными catch-sentinel в m
локализовал convert в outer_array (160) одинаково native/forced.
До него проходят int*/size_t*: чтение, запись, @, held snapshot и convert
при узком receiving. Это частичное наблюдение, не PASS fixture.

Сгенерированный outer_array имеет физический Array в body/0, но не
регистрирует quote в activation bindings. Поэтому reached callee получает
лексический quote вместо собственного caller Array. Исправление fix04
отделяет общую own binding eligibility от native scalar dirty cache:
Array хранит полный Value существующего descriptor; walker использует
прежнюю OWN/work запись. Ни обход произвольных полей, ни новый граф не
добавлены. Новая функция экспортируется обычным tools/build.lm2.
Кандидат fix04: source manifest63791A42,185inputs,9changed files.
Результат fix04 ещё не проверен; tool133b находится в обычной пересборке.

## Фокус прошёл; цельная самосборка в работе

Tool133b9FC96760 завершён exit0. Component fe133bB609A8FD
(координаты/core/emit,171reuse/47unchanged ABI inputs) завершён exit0;
rt133aB27649DC/observe9DD49F04 сохранён, runtime не менялся.
Suite03 даёт7 в n/f обоих roots. Затем временные catch-sentinel сняты:
финальный fixture21F7582A добавляет caller-only Array через relay,
индекс1 через int* и смешанный named-field/INDEX путь.
Suite04 12:06:55–12:07:21Z:1row/0failures,все4запуска дают7.
OSWALK index01 exit0: в forced обоих roots m1/read_int12/write_nine3/
address_int3/relay_nine1/mixed_read1/mixed_write1; native их не walks.

185inputs заморожены в cold-boot133a; source manifest
66b15db1b3ba4543c11cf99cd49f27c10677302e45b97f0b756fa38f0c43b5c8.
Prepare4steps0. Единственный pipeline boot133a quick запущен из
tool133b + boot132c/G2; завершения пока нет. В selfbuild не посажено,
публикации271 нет. Frozen inputs не менять.

## Завершение процесса bootstrap перед передачей

Terminal boot133a-quick:12:08:22.5906238Z→12:27:02.0057253Z,
BootstrapExit0,1119.42s. Процесс завершён; нового compiler pipeline Codex
не запускал. Детальная проверка generations/inventories и G2 focus ещё
не выполнена и передана Opus по to_opus.md. Это не landing/publication271.
