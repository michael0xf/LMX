# Каталог LMX: что компилятор действительно знает и где подключать публикацию

2026-11-27. Read-only аудит `core/selfbuild` и исправленных `documentation/docs`. Сборка не запускалась. Snapshot ядра: SHA-256 `36e4dc2b2d2f94a13c4d32157781c93193823b80676882c8b72b7c69ca3c00a7`. Пути `.lm2` ниже относительно `core/selfbuild/src/l2src/`; S — `documentation/docs/spec/LMX_semantics.en.md`, K — `documentation/docs/spec/kernel-implementation.en.md`.

## 1. Рекомендуемый смысл «полной каталогизации»

Компиляция может выдавать **полную инвентаризацию выбранного разрешённого графа и всех обнаруженных в нём occurrences**, с письменными требованиями и доказанными на данном проходе фактами. Это не равнозначно знанию всех будущих значений, адресатов динамических вызовов, достижимости ветвей и внешних эффектов. Неизвестность должна быть записью каталога с причиной, а не пропуском элемента.

Нормативное уточнение автора: kernel `fromLmx(text)` создаёт чистый граф, пригодный для компиляции; kernel `toLmx(S)` выдаёт LMX-код любой Structure и любого L3Thread. Compile basis и каталог берутся из того же clean graph. Пробел текущего dump устраняется в общем kernel receiver; отдельный каталоговый/серверный serializer и сужение `toLmx` не вводятся.

Каталог — производный индекс и свидетельство конкретной подготовки/наблюдения. Главным источником для работы агента остаётся настоящий текущий runtime graph и его полный `toLmx`-экспорт; disk source — дополнительное происхождение. “Последний опубликованный каталог компиляции” не означает “граф сейчас не менялся”: записи графа действуют сразу, не запускают dirty tracking, повторную компиляцию или автоматическую ревизию. Неизвестная актуальность честнее фиктивного `isCurrent=true`.

Каталог должен сохранять раздельно происхождение `written`, `resolved-for-this-compilation`, `runtime-observed`, `dynamic-unresolved` и диагностическую причину. Статус относится к факту и конкретной основе, а не к объекту навсегда. SQL rows не становятся новым runtime namespace, persistent admission map или executable graph.

## 2. Матрица фактов

| Что каталогизировать | Что можно утверждать | Что нельзя вывести без дополнительного выполнения/доказательства | Основание |
| --- | --- | --- | --- |
| Граф, поля, occurrences, имена | Существующие узлы/значения, порядок и индексы полей, отсутствующие slots, sharing, cycles, actual parents; written canonical spelling и unnamed occurrences. | Имя не является уникальной identity; одинаковые имена и повторные occurrences не сливаются. RAM address не portable key. | `l2_graph_tool.lm2:61–125,263–315`; S:301 и правила повторных DATA occurrences. |
| TYPE/requirements | Written complete requirement; нормализованное описание типа, если общий типовой механизм его доказал; известные rank/axes/reference depth в поддержанном профиле; initialized/uninitialized как отдельный факт. | Missing extent не становится нулём; динамический размер, deferred receiver и будущий return value не вычисляются ради индекса. Числовой TypeRef старого процесса не является переносимым описанием. | `lmx_types.lm2:476–754`; `l2_graph_tool.lm2:228–260`; K:1119–1143. |
| DATA/CODE/TYPE/RAW роли | Written occurrence плюс роль конкретного потребителя и прохода; фактический parent(C) для выбранного executable C; declared input/result requirements. | Фиксированная глобальная роль узла по имени поля; поле `code` не делает родительский объект автоматически callable; reference может употребляться в разных ролях. | S:593 и далее, 1641–1697; `lmx_graph_run.lm2:1463–1548`. |
| Defaults и initializers | Присутствует ли initializer; ready literal либо ссылка на точную written computed declaration; explicit omission отличается от 0/empty. | Результат computed default до demand; “без initializer” не означает отказ без `required`, а `private` не уничтожает формальную позицию. | S:2555–2583; `l2_frontend_graph.lm2:268–326`; `lmx_graph_run.lm2:1201–1235`. |
| Binding, private, scope | Written declaration occurrence, lexical ancestry и source-side/receiver-side private marks; доказанный binding для конкретной подготовки. | Все будущие dynamic caller sources или устойчивую адресацию local slots после завершения frame. `private` не является ACL и не скрывает field от прямого пути. | S:2291–2372,2584–2591; `lmx_call.lm2:464–523`; `lmx_graph_run.lm2:2694–2943`. |
| Calls | Все written call-site occurrences; statically known head/candidate/selected profile там, где общий механизм действительно это получил; unresolved head с контекстом/причиной; named actual→formal mapping, когда она доказана. | Из available candidate нельзя сделать факт actual execution. Runtime-selected callable и будущие dynamically supplied actuals могут быть неизвестны; caller requirements не строятся транзитивным замыканием всех потомков. | `l2_graph_tool.lm2:373–459,3631–3681`; `lmx_graph_run.lm2:7297–7402`; S:2341–2358. |
| Reads/writes | Written read/write occurrence; bare logical place либо explicit graph path; static target, если он доказан; role `may-read`/`may-write` для потенциального эффекта. | Полный alias analysis, реально выбранный caller place, конечный target вычисляемого пути, фактическая запись в недостигнутой ветви. Наличие готовых frontend helpers не является effect-system proof. | `l2_frontend_graph.lm2:547–611` — только boolean helpers для порядка вычисления; `l2_graph_tool.lm2:1263–1315,1733–1878`; S:2555–2583. |
| Throw/catch/finally | Written declared throw requirements, throw/catch/finally occurrences, их реальные parents, explicit payload forms и известные lowering exits. | Исчерпывающий набор всех runtime ошибок и foreign C effects; отсутствие записанного throw не доказывает totality/no-failure. | S:2729 и общий admission/exit договор; `l2_graph_tool.lm2:1188–1261`. |
| Import/copy/merge | Written source operands, consumer/placement role и известные relation mappings одной выполненной/подготовленной операции; результат, если он уже существует в наблюдаемом graph. | Нельзя выполнить computed source только ради каталога, стереть written receiver или считать stream recipient новым lexical node; copy не равно serialization. | K:963–1030; `lmx_graph_copy_owned.lm2:4264–4460`; S:3150–3181. |
| Native | Наличие проверенного descriptor, supported ABI/profile, имена entry/module и L1/C artifact paths/hashes, если соответствующий путь их создал; compilation binding к конкретному code occurrence. | Наличие машинного entry не означает admissibility любого вызова; `native_present` не доказывает соответствие изменившемуся graph body. Current code emits one prepared C9 variant; нельзя выдумывать готовую универсальную multiversion систему. | `lmx_call.lm2:134–179`; `l2_graph_tool.lm2:2371–2434`; K:1034–1061,1099–1105. |
| Source provenance | Настоящие source bytes/URI/hash/span, когда они были доступны; происхождение runtime-generated/copy/import и родственные occurrences, если оно фактически сохранено. | Выдуманный file path/line для runtime-generated graph. Отсутствующий disk source не делает graph неполным. Один span может давать много occurrences; многие refs могут вести к одному graph node. | `l2_graph_build.lm2:1171–1201,1505–1530`; P0 документ уничтожается после build; `lmx_source_names.lm2` содержит names/private/place metadata, не универсальную disk sourcemap. |

Не стоит фиксировать внутренние исторические `LmxSourceName` port/occurrence codes как вечный публичный формат. K:1151–1157 относит старые коды и persistent concrete namespace maps к заменяемым механизмам. В каталоге нужны written spelling, occurrence edges и snapshot-local keys.

## 3. Лучшие существующие точки подключения

**A. Начало explicit compile.** Выбрать настоящий runtime graph и owner/context. Source parse нужен только тогда, когда source явно передан. K:1040 прямо допускает уже построенный runtime/clean graph “as it is”. Зафиксировать compile operation, scope, backend/profile и основу наблюдения. Удерживать необходимые roots обычным lifetime; это не повод вводить обязательный candidate copy или global pause.

**B. Общая preparation/translation.** Повторно использовать выбранные parser/builder/type/admission decisions. `lm_graph_emit_program` (`l2_graph_tool.lm2:2511–2572`) открывает operation-local namespace и обходит полный root graph, отдельно выбирая CODE/native body. Инвентаризация должна покрывать весь заявленный graph scope, включая DATA, unnamed nodes и некомпилируемые bodies; список от `lm_graph_native_methods:1712–1731` — только отобранные native кандидаты, не весь каталог.

**C. Existing graph-emission map.** `lm_graph_emit_node:73–125` выделяет локальный label до обхода edges; повторная ссылка использует тот же label. `emit_value:263–274` и `emit_parents:276–312` используют единую map. Это конкретный образец корректного catalogue traversal: один временный identity map, сохранение sharing/cycles и parent edges, затем освобождение map. SQLite получает обычные локальные row keys; исходный RAM address не сохраняется как portable identity. Для интерпретируемых/no-native scopes можно применять тот же общий graph walker через узкую observation boundary, не запускать L1-emission только ради индекса.

**D. Facts из решений, а не повторной догадки.** Emission уже обращается к `lmx_graph_bind_call`, typed actual reader/admit/invoke; динамические heads направляются общему evaluator (`l2_graph_tool.lm2:373–459,3631–3681`). Hook получает факт “эта операция была подготовлена таким образом” и source occurrence; он не создаёт самостоятельный resolver, overload selector или второй parser. Written потенциальные effects допускается перечислять отдельным derived pass, не использовать их как новую authority исполнения.

**E. Завершение explicit compile.** Отдельно записать preparation, tests, translation, machine build/link/registration outcomes и native artifact evidence. Факты compilation basis относятся именно к графу/представлению, потреблённому lowering. Interpreted build tests могут иметь обычные эффекты (K:1058); последующее наблюдение runtime graph нельзя без доказательства приравнять к pre-test lowering input. При необходимости хранить два явно разных наблюдения, а не выдавать “после теста” за исходник уже созданного бинарника.

**F. Endturn publication.** Подготовленный catalogue snapshot остаётся staged до предусмотренной успешной boundary. `endturn` не возвращается: код `endturn(); publishCatalogue()` неверен. Нужен один явно реализованный owner lifecycle hook/continuation обработки подготовленного publication record, связанный с фактическим outcome. Сам `endturn` не обнаруживает edits, не хеширует весь граф, не делает compile и не пересобирает каталог автоматически (K:1047–1058).

## 4. Что в нынешнем source ещё не подключено

`lmx_turn_end_status` (`lmx_turn.lm2:26–105`) публикует либо отбрасывает staged mail и prepared children, выполняет lifecycle checks/GC. Здесь не найден готовый `compile → pending catalogue → SQLite → endturn` путь. `lmx_native_publish` (`lmx_call.lm2:206–268`) валидирует/резервирует и публикует таблицу native associations; обнаруженные callers находятся в graph copy engine (`lmx_graph_copy_owned.lm2:3093,4257,4424`). Это полезные существующие primitives, но не доказательство реализации normative explicit compile/endturn pipeline. SQLite/catalogue hook требуется спроектировать и подключить.

Есть независимые file diagnostics и временные P0 spans, но непрерывная disk-to-runtime-to-catalogue sourcemap для всех runtime edits этим source не подтверждена. Без неё исходник runtime всё равно доступен через общий полный graph codec; provenance отмечается честно, необязательные disk coordinates остаются отсутствующими.

Также полный `toLmx` ещё нельзя считать готовым: нынешний diagnostic dump печатает `...` для неназванных циклов (`lmx_graph.lm2:2748–2759`). Это ограничение касается и сохранения полного snapshot body в SQLite. Простой readable dump не может стать доказательством полной каталогизации.

## 5. Публикация, отказ и SQLite

Базовая схема может хранить одну активную SQL-проекцию на owner/compile scope; история snapshots опциональна. Подготовленные новые rows и переключение active selection внутри самой SQLite обновляются транзакционно. Abandoned/failed compile не подменяет активную проекцию успешной компиляции; хранить ли отдельную историческую запись, решает выбранная retention policy.

SQLite transaction **не даёт общей атомарности** с RAM stores, native installation, внешними эффектами и endturn. Нужен прописанный порядок boundary и состояния как минимум prepared, publication-pending, published, failed, recovery-required. Ответ “published” возможен только после фактического подтверждения согласованной публикации. При отказе SQLite после принятия runtime/native нельзя обещать rollback runtime; каталог сообщает непринятый/устаревший/неподтверждённый индекс, а восстановление обращается к настоящему runtime и подтверждённым compilation artifacts. После рестарта RAM addresses не восстанавливают связи.

Полная таблица на L3 Thread допустима как storage layout; Thread partition сохраняет relation edges текущей проекции, а историю snapshots — только если она включена явной retention policy. При shared immutable branches запись должна отражать reference/owner relation; копия строки для поиска не означает новую семантическую копию graph node. Одна таблица на Thread не должна превращаться во второй Thread membership registry: runtime membership уже хранится в `Thread.children` (S:3353).

Внешний ключ `(catalogue_snapshot, thread_partition, item)` — database identity. Для действия над live объектом сервер заново использует разрешённый context/реальную удержанную reference и ordinary admission; database key не превращается в новую глобальную LMX инструкцию “lookup object by ID”. Совпадение textual name или structural path после edits не гарантирует, что это прежний объект.

## 6. Что выдавать через API и что проверять

Практически полезны поиск symbols/occurrences, входов/результатов/types, письменных callsites, известных и unresolved dependencies, потенциальных reads/writes, native artifacts и source provenance. У каждого ответа должны быть scope, snapshot basis, completeness, unresolved facts и способ запросить **текущий** runtime fragment. Полное runtime `toLmx` может возвращаться чанками; SQL search snippet остаётся кратким поисковым результатом и не выдаётся за полный graph.

Для свежего факта агент сначала получает live inspection/`toLmx` выбранного owner, при необходимости сопоставляет его с конкретным каталогом. Disk source служит происхождением/помощью редактированию. Отсутствие строки в разрешённой частичной выборке, неполном snapshot или unresolved relation не означает отсутствие соответствующей runtime сущности.

Минимальные проверки нового контракта:

1. Inventory сохраняет повторные имена, unnamed cycles, shared refs, null/absent, parents и все written receiver forms; SQL constraints не сливают occurrences по имени.
2. Динамическая callable reference и private/dynamic binding дают unresolved fact либо scoped resolved fact, а не выдуманный статический call edge.
3. Deferred initializer не выполняется ради каталога; direct path и bare logical place различаются; потенциальный effect не объявляется выполненным.
4. Изменение interpreted handler после compile видно в live runtime; старый catalogue snapshot остаётся историческим без native invalidation и автоматического recompile.
5. Неудачная compilation/test не публикует новый active successful snapshot; уже совершённые эффекты не объявляются откатившимися.
6. Endturn publication имеет настоящий hook и проверяется до/после boundary; код после невозвращающегося endturn не считается работающим.
7. SQLite failure/restart между стадиями даёт явный recovery outcome; native state и DB не объявляются общей ACID-транзакцией.
8. Runtime-generated component без disk file получает полный live graph и provenance `runtime-generated`, а не фиктивные file offsets.

Это дополнение к существующему ТЗ, а не заявление о готовом compiler catalogue. Прикладной каталогизатор/запросы/публикация описываются на LMX; SQLite primitive bindings и общий compiler/owner callback — явно названные integration seams.
