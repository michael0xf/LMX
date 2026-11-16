# Спецификация реализации ядра LMX: Lmx-граф, примитивы, арена, имена

**Норма 2026-11-16:** [запись значения](#value-record) — физический тип и значение лежат в одной записи; тип больше не
узнаётся по диапазону адресов ([L2 §3](L2_spec_ru.md#value-record), [план M15](../next_core_tasks_v3.md#typed-value-records)).
Датированные отчёты ниже, говорящие о типизированных участках, описывают прежнюю схему и нынешний код.

**Норма 2026-11-15:** [локальные кадры без публикации](LMX_semantics.ru.md#call-frame-20261115),
[единый M14 и sys-инструменты](../next_core_tasks_v3.md#native-structures). Датированные отчёты ниже —
история реализации; упоминания load-dirty, общего кеша и flush в них не являются заданиями продолжать эти механизмы.

**Срез401, 2026-11-15 — typed overlap merge; ограниченные кодовые gates PASS.**
Receiving closure задаёт окончательные layouts до Value edges; common copier сохраняет scalar/WORD,
общие CHILDREN и reference Value cells. Graph84 get_in/put_in используют явный Graph context;
legacy raw ABI остаётся для прямого backing. Source07:934, G1/G2 quick/fixedpoint36,
G2 targeted5/0 и Graph6 triple PASS. Это прежняя модель исполнения; новая M14 остаётся OPEN.
[Свидетельство401](../steps/witnesses/m13-overlap-20261115/notes.md).


**Срез400, 2026-11-15 — общий mapped copier и written DATA fn_data; кодовые gates PASS.**
Source04:934, genuine G1/G2 quick/fixedpoint32, actual G2 targeted5/0 и Graph6 triple PASS.
Полный overlap merge, scalar CODE-own и native/cache/flush M14 остаются OPEN.
[Свидетельство400](../steps/witnesses/m13-mapped-data-20261115/notes.md), [текущий конвейер](../steps/current.md).

**Срез399, 2026-11-15 — written SOURCE и hidden transport; кодовые gates PASS.** Исправлены общий
header-source отказ и вывод scalar FREE default metadata. Guard written SOURCE и Model/capture admission сохранены.
Genuine G1/G2 quick/fixedpoint30, actual G2 targeted13/0 и Graph3 triple PASS; render/fresh docs-check/final index PASS.
[Текущий статус](../steps/current.md). Общий copier/construction и native M14 остаются OPEN.

**Срез398, 2026-11-15 — полный scalar Value в рабочем GraphRun.** Обычная Code над supplied typed DATA
сохраняет physical cell/slot, SOURCE места и RHS Model. Private06 и чувствительный GC mutant прошли;
genuine G1/G2 quick/fixedpoint30 и Graph3 triple PASS. Actual G2:6 из9 rows PASS,3 старых L2 header-source
refusals воспроизводятся на accepted397 и остаются OPEN. G2 render35/14, fresh docs-check и final index PASS.
Native/typed args/results/construction,
общий кеш и flush остаются OPEN. [Текущий статус](../steps/current.md).

**Срез397, 2026-11-15 — owned scalar receiving и места формалов, ограниченные кодовые gates PASS.**
Полный ACTIVE SOURCE канонизируется прежним counted TEXT interner отдельно от physical ABI.
Scalar actual/return сохраняет полный Value; callee current Value и ленивое mutable место разделены.
Первый store/address создаёт собственную ячейку, последующие адреса стабильны; escaped pointer удерживает
arena companion после завершения активации. Прямая запись обновляет current, чтение после alias обновляет его
из companion и выдаёт снимок. Runtime08/private13 SUITE1/0 проверяет настоящий dispatcher/scratch exit/GC.
FE07 raw/hosted ordinary-witness05/06 OSWALK0 подтверждает precision/store/address/caller-isolation native/walker.
Source28:932/canonical, genuine G1/G2 quick smoke9/0, fixedpoint29 и actual G2 targeted6/0,
ordinary-witness07/Graph3 triple PASS. G2 render35/14 и fresh docs-check01 PASS35/14/27/44/615, links/LF28283;
финальная проверка индекса — перед коммитом. Semantics source и grammar не менялись.
Typed Run/FFI/Foreign-Array и общий кеш/flush M14 остаются OPEN. [Свидетельство397](../steps/witnesses/m13-scalar-receiving-20261115/notes.md).

**Срез396, 2026-11-15 — public scalar resolver; ограниченные кодовые gates PASS.**
Общий frontend interner сохраняет source word, глубину указателя, const и raw-C роль; native printer
берёт точное scalar spelling из активной primitive.description. Translation-owned aliases проходят прежний
L1 type emitter; номера runtime rows и совпадение C spelling не становятся semantic identity.
Public scalar machine units, включая отдельную переставленную ACTIVE таблицу с ProbeReal, прошли private gates;
обычный метод с double*** прошёл native/обходчик и root0/root1. Машинные FP assertions остаются native.
Whole01 genuine G1/G2 quick/fixedpoint29/canonical931, actual G2 recovery16 и Graph3 triple PASS.
Recovery использует готовые объекты после исправления ошибочного prod path; targeted01 SUITE не объявлен PASS.
G2 render35/14, fresh docs-check02 и indexed01 PASS35/14/27/44/615, links/LF28277/28283.
Owned scalar actual/result, runtime receiving/Run/FFI/Foreign-Array и общий кеш/flush остаются OPEN.
Точные артефакты и пределы проверки — в [свидетельстве396](../steps/witnesses/m13-public-scalars-20261115/notes.md).

**Срез395, 2026-11-15 — GC живого исполнения runtime/native; ограниченные кодовые gates PASS.**
Marker до sweep проходит существующие activation/call_places, рабочие кадры и полные Values.
Временные borrowed spans принадлежат arena исполнения и снимаются до rewind/free; собственные scratch chunks
удерживаются явно, их слова не сканируются как граф. Physical pool.profile — отдельная зависимость живого значения.
Runtime02 и адресные collect/reclaim/pending PRIM/standalone Frame/native C ABI cases прошли n/f/root0/root1.
Native emitter395 подключает working/pending Values и выбранные places к тем же spans; существующие statement,
loop/pad и внутренние branch scopes задают cleanup, trampoline снимает roots тела до следующего poll.
Source27:927/Frontend04: обычный GC fixture прошёл native/обходчик и root0/root1, включая рабочий снимок после
очистки physical DATA, pending actuals, циклы, short-circuit, catch и последующий reclaim. Whole G1/G2 quick/fixedpoint31 PASS.
Public resolver/typed Run/receiving/FFI/Foreign-Array, общий кеш/flush и полные M11/M13/M14 остаются OPEN.

**Текущее состояние, 2026-11-14, срез394 — exact scalar ABI foundation; ограниченные кодовые gates и docs-check PASS.**
Из тех же35 Source rows генерируются header type aliases и profile bodies для32 scalar bindings (§3.2):
None/void без cells, FILE opaque без угаданного binding. Source identity, C ABI и physical profile остаются раздельными.
Machine C ABI unit прошёл native/forced с обычным owner и root0/root1: все32 bindings, точность float/double/flong,
i64/u64 limits, ABI rejection/protected write без изменения значения, immutable identity с nonzero physicalProfile,
copy/projection/qualification/GC. FP assertions остаются в native C ABI unit; общего L3 FP исполнения это не доказывает.
Обычный Graph.kind для Foreign остаётся0; SourceFact читает доказанные typed metadata до этого fallback (§3.5).
Публичный primitive→frontend resolver, Run working/receiving/FFI, activation/pending GC roots и Foreign-Array ABI OPEN.
Source16:925, genuine G1/G2 quick по9 smoke/fixedpoint20 PASS; actual G2 targeted4 n/f/root0/root1 и Graph3 triple PASS.
G2 render35/14, fresh docs-check01 и final indexed01 PASS; links/LF28270/28273.
Полная приёмка общего bridge и M11/M13/M14 не заявлена.

**Предыдущее состояние, 2026-11-14, срез393 — operation-local SourceReader для source interface; ограниченная кодовая приёмка/docs-check PASS.**
Общий implements worker получает name/fact выбранного Source через заимствованный reader текущей операции (§3.5).
Полная literal-проекция35 строк/15 колонок `primitive.description` отделена от физического `Fact.type` и ABI;
совпадение C-spelling не объединяет source contracts. Все33 cell-row identity контроли прошли в private L2 native/forced
с root0/1. Qualifier-chain сохраняется; references/Array дают UNKNOWN без чтения payload.
Construction прямой трёхаргументной `@` проверяет известные candidate/Model только по интерфейсу: доказанно недостающее
поле Model отказывает, `test` не исполняется, raw Model/default сохраняются. Typed storage и runtime admission не заявлены.
Actual G1/G2 quick/fixedpoint15, G2 interp23/AFTER22/image48, Unit08 и legacy2 PASS; полной готовности typed
storage/runtime admission или M11/M13/M14 это не означает. Render35/14 и docs-check01 PASS; финальный индекс проверяется перед коммитом.

**Предыдущее состояние, 2026-11-14, срез392 — ограниченные кодовые gates и docs-check01 пройдены.**
`declaration_parts` заимствует receiving leaf/model/candidate и presence/known, сохраняя исходный root;
DATA logical names требуют доказанного declaring-контракта (§3.5). C-spelling проекция расширяет прежний generated
primitive profile; `c_names` доказывает роли source spellings, не объединяет C-типы с языковыми aliases.
Произвольное `c.*` остаётся provisional UNKNOWN. Constructor не превращает receiving chains и их группы в DATA scopes;
model/default и неподдержанные qualified/Array/deep/typed формы сохраняются raw, typed storage/admission не заявлены.
Финальные private Runtime06/Graph02: префиксы SHA-256 `fe17a328`/`69eab914`; frozen Source08:919, SHA-256
`b8b1b9b6095610b03bd26c80bc5c4988be3cfdc3c7b0eab0512a0c3994f44909`.
Private21: все interp/native/forced и15 полных negative AFTER PASS; construction_shape_presence проходит с прежним expected.
Шесть новых pairs; role oracles effects1/arithmetic15/called6/indexed12/via_whole13/done1.
Whole02: настоящие G1/G2 по9 smoke и tool PASS. Fixedpoint:13 artifact checks и2 canonical checks PASS после
регенерации canonical907→919, без пересборки artifacts. Штатный G2Graph SHA9c44994b построен;
actual G2 interp21/full AFTER21 PASS. Его42 emitted native/forced images и2 libc/backend совпали побайтно —44 PASS;
готовые private binaries переиспользованы без новой компиляции или повторного native/forced запуска.
Actual G1 frontend подтвердил byte equality профиля с quoted FILE; normal profile SHA-256
`d91946148a1c06809cd9ccd1a25a94cac303876a3032070ecb2fc7104a9facd5`; G1/G2 frontend exe equality PASS.
G2 render35 paired/14 cases/оба snapshots PASS, generated semantics и grammar не изменились.
Docs-check01/final index02 PASS35/14/27/44/615, links/LF28235/28262; commit/push392 далее. [Свидетельство392](../steps/witnesses/m11-receiving-view-20261114/notes.md)
сохраняет полные проверки и историю промежуточных попыток.
Общие typed storage/admission и actual C-door bridge, полный M11.7/8, M13/M14 и runtime `merge`/`sys\fromLmx` OPEN.

**Предыдущее состояние, 2026-11-14, срез391 — ограниченная реализация; кодовые gates и docs-check пройдены.**
Изменён только Run: приватные `construct_slot`/`construct_atom`/`construct_value` расширяют bounded конструктор390
на доказанные пути. Экспорты Graph75/Run58, ABI, layout и публичный API не меняются. Именованный шаг использует
`step_index`; числовой индекс выбирает физический слот и сохраняет непосредственное значение, не превращая raw `fn` в F
и не разрешая WORD как имя Structure.
Выполняются только буквальные индексы; выражения индекса не исполняются. Именованный путь сохраняет точное source → F
и существующие masks (§3.5). Typed/qualified/common admission, полный M11.7/8, M13/M14 и новое построение
при runtime `merge`/`sys\fromLmx` остаются OPEN; удержанная F без native-entry использует обходчик.
Добавлены6 sources/5 expected, включая `construction_paths_owned_data`; финальный Source07:907, SHA-256
`329fba48883be5014759e1fc74c4236873286c6050b69567c4ce3206f23ce9c3`.
Прежний Source03/private48 triple и39 полных AFTER прошёл до последнего исправления, включая43 прежних случая
без изменения ожиданий; это промежуточный результат, не финальная приёмка391. Совмещённая проба
охватывает18 контекстов/31 leaf oracle; отдельная F.data-проба проверяет два запуска: initial11, bare8/9, held11/current9;
producer-значения меняются через `:=` существующим местам. Ошибка Graph01 в различении index/atom исправлена в Graph02;
устранён также ложный pending blocker в EXPR. Последнее ревью выявило пропущенный pending audit фактической F.data,
не включённой в очередь материализации: method и bodyless descriptor давали4 вместо2. Приватный `construct_data_scope`
исправляет распознавание её лексической роли без materialization/blueprint walk; новые Runtime03/Graph03 и фокусная
проверка прошли: method/descriptor2/2, data width2/2. Runtime03 SHA-256
`6a6105346ea9e3b841556ff5d29582dca09767931e7cc7bc9d2f88abad437582`, Graph03 SHA-256
`7aad957de36545b74dc225c2214f302357b9bcf48a3ab41ca4f44cc6e1af37c6`.
Первый whole bootstrap01 остановлен владельцем; его процессы завершены, приёмка не заявлена.
Private02: все49 случаев в interp/native/forced и39 полных AFTER прошли; ожидания прежних43 случаев не менялись.
Whole `boot-m11-construction-paths-02` прошёл: настоящие G1/G2 по9 smoke, fixedpoint15/verify907 PASS;
private Runtime03 совпадает с G2 driver. Промежуточный Source06 отличается от проверенного Source05 только форматированием двух
новых fixture sources: убран избыточный одноуровневый `end` после bootstrap-terminal. Полные AFTER совпали для2 случаев,
четыре сгенерированные native/forced программы побайтно совпали. Source07 дополнительно удаляет лишние пустые строки
в конце шести новых fixture sources:10 сгенерированных native/forced программ побайтно совпали с прежними выходами
настоящего G2, build4 control PASS, fixedpoint03:15/verify907 PASS. Ядро и входы сборки компилятора не менялись;
дополнительный whole для этих fixture-only правок не выполнялся. Штатный G2 graph-tool собран, SHA-256
`0cc869f7c12b9b3d7ae57aec8957602fcfaabe0750759ab9f5a131195f17b5a5`.
Повтор G2 всех49 случаев в трёх режимах и negative AFTER39 прошёл. Render35/14 PASS, generated content/grammar unchanged;
Fresh docs-check01 PASS35/14/27/44/615, links/LF28142; final index391 проверяется перед коммитом.

**Предыдущее состояние, 2026-11-14, срез390 — ограниченная реализация, кодовые проверки и docs-check пройдены.**
После заполнения P0-полей `lm_graph_build_root` вызывает `lmx_graph_construct`, затем отдельный чистый preflight (§1a).
Построение имеет свой свежий namespace; удержанные F сохраняются обычными значениями графа, а raw `fn`/`sub`
остаются записанными объявлениями. Известные исходные кандидаты ссылки заполняют места без исполнения CODE,
умолчаний, вычисляемых actuals или `test`; mutable aliases остаются отложенными (§3.5).
Private43 в трёх режимах, включая 36 прежних случаев, и 33 полных AFTER прошли. Отдельно прошли18 logical проб обходчика
и2 FN-image случая в трёх режимах. Начальные ошибки mutable alias1 вместо2 и native image parent0/allocator failure исправлены.
Whole `boot-m11-known-data-01` quick прошёл: настоящие G1/G2 по9 smoke, fixedpoint15/verify896 PASS;
private Runtime03 совпадает с G2 driver. Штатный G2 graph-tool собран, SHA-256
`17d12ce77360e99af075fb90967e0b7aef76f94985566a89e49b617d4bfd058a`; повтор G2 всех 43 случаев в interp/native/forced
и 33 полных negative AFTER на готовых binaries прошёл. Все кодовые gates390 PASS.
Штатные render35/14 и fresh docs-check01 PASS35/14/27/44/615, links/LF28087; final index перед коммитом.
Путь ограничен direct two-argument `@`; пути, type fields и новое построение
при runtime `merge`/`sys\fromLmx` остаются OPEN. Удержанная F без native-entry исполняется обходчиком.
Полные M11.7/8 и M13/M14 остаются OPEN.

**Предыдущее состояние, 2026-11-14, срез388 — ограниченная кодовая и документальная приёмка подтверждены; далее commit/push.**
Occurrence и буквальное exact-имя различаются структурой правого шага прежнего path3 (§3.3):
общий `Graph.occurrence` (Graph74) читает обычную anonymous pair, а `Run.step`/`step_place` принимают raw step (Run54).
Те же reader, admission и native используют этот выбор; P0 сохраняет quoted-компоненты общим сканером головы.
13 новых случаев прошли в трёх режимах; ещё 7 прежних прошли после исправления только форматирования golden:
совокупно 20/21. Настоящие G1/G2 whole quick прошли по 9 smoke; fixedpoint15/verify867 PASS.
Штатный G2 graph-tool построен, префикс SHA-256 `0fcf70f9`; повтор G2 даёт те же 20/21, все 13 новых случаев PASS.
9 полных negative AFTER прошли с переиспользованием готовых binaries.
`root_occurrence_index` отвечает run3 как под seed387, так и под новым кодом;
числовой эталон seen3 сохранён, общая карта declaration-site → frame остаётся OPEN.
Source06:867, префикс SHA-256 `19d3d5dc`. Штатные render и docs-check01 PASS35/14/27/44/615, links/LF27962;
Final index-check02 PASS, links/LF28021; далее commit/push388 в main.
Полные M11.7/8, M13/M14 остаются OPEN.

**Предыдущее состояние, 2026-11-14, срез384 — ограниченная реализация, кодовая приёмка пройдена; база383 `58bc7f3a`.** Прямая именованная подача actuals `fn`/`sub`
связывает формалы только через `:=`; `by_head`/mode2 и прежний `frame_value` удалены из Run.
Целый descriptor читается как DATA: его colon-поля сохраняются без исполнения. Structure-формалы `args`/`data`/`code`
читают actual общим `read_received_value` с contract2: written group инертна, неизвестный named Frame доходит
до применения и отказывает3. `name`/`return` сохраняют written-description контракт, включая `@: c.FILE`.
`fn_decl_name` — graph-only query: прямая подача отделена от одного whole-DATA descriptor, без рекурсивного
раскрытия или зависимости от Space (§3.4). Положительная пара direct/whole DATA даёт12/12;
порядок приёма даёт effects1/later0/refusal5, а сохранённый code-group с missing-вызовом имеет length1 без эффектов.
Runtime01/Graph01, private32 triple,87 полных AFTER,2 baseline checks и mutation24 прошли.
Первый private32 сохранил3 FAIL: два устаревших golden fn_prepared/call_receivers и статическое имя при emit5.
Seed383 подтвердил шесть полных AFTER; исправлены только13 строк synthetic RHS parentheses, числа сохранены.
Static-name probe и emit5 сохранены: для него native runtime не был создан. Новый reached-name случай с computed args
и name-call/finally проверены private02 на двух новых исходниках в трёх режимах:5/before1/after0 и cleanup1.
Source03 SHA-256 `ac0d0a1ca48bfdb488c44982ada095ef2e7516dd304831d5987a735c55f13e9f`.
Whole bootstrap quick прошёл: настоящие G1/G2, по9 smoke; fixedpoint13/verify798 PASS.
Native trace02 подтвердил actual root → `fn_apply` → `receiver_bind` evaluate1 → actual native producer:
effects1/later0/body0/before1/after0, ожидаемый host exit1. Первый GDB01 с missing args сохранён и доказательством не считается.
Штатный G2 graph-tool построен, SHA-256 `09f0e983a7baa2b892bd755c5845495355062e673b41ff6556a02a6899004f82`;
повтор G2:32 triple/21 полных negative AFTER/mutation24 PASS. Проверенная кодовая связка384:
boot-m11-receiver-actuals-01/g2 + graph-m11-receiver-actuals-g2-01.
Штатные render/docs-check384 прошли:35/14/27/44/615, ссылки/LF; далее commit/push main.
Общий каталог/представление деклараций и проверка формалов — OPEN M11.5е;
`by_head` рабочего frontend — OPEN M11.8; весь M11, внешний/вычисленный CodeBody, M13/M14 остаются OPEN.

**Предыдущее состояние, 2026-11-14, срез383; база382 `d0e384c1`.** Изменён только Run:
общий resolver различает чистый query и потребляющее чтение с локальным status. Фактическое чтение raw fn/sub
без F соответствующего scope/source готовит достигнутый блок прежним `space_declarations`/evaluate0;
соседние written методы готовятся в прежнем порядке. Классификация, slot requirements и запросы binder остаются чистыми,
не входят повторно в строящийся receiver. Ошибка конструктора сохраняет свой ответ, не превращаясь в missing3.
Доказательство source/parent учитывает также объемлющий `node`. Copier, `fn_data`, Frame и Run53 ABI не менялись;
нет нового registry/error field, переноса SourceSpace или восстановления FN-role обычной копии F.
10 pure-проб прошли: raw Fn1/2/sub2/marks25 при source3; unentered1/2; named parts7/7;
held aliases8/8/8/9 при source3/next4; explicit clone4/5/source3; ordinary descriptor5;
malformed constructor5/before1/after0, pending3/touch0, ambiguity3; два обхода дают source1/held3.
Private34 triple дал32 PASS и два расхождения только в synthetic assignment RHS parentheses прежних
reference_alias/descriptor_merge. Seed382 подтвердил ту же форму шестью полными AFTER;
исправлены четыре строки скобок, числа сохранены. Все102 полных AFTER на тех же binaries и mutation24 прошли.
Trace подтвердил actual native root → consuming declaration → scope preparation7/7 и normal exit;
новое callable может исполняться обходчиком, M14 OPEN. Код собран на Source01:761; Source02 добавляет10 fixture pairs,
Source03 меняет только четыре прежние строки скобок:781 вход, SHA-256
`4a7ed184d976b820d605f14c2e9a33970b16e0dae54c0ae95e83c35d9b5e5604`.
Whole bootstrap quick прошёл: настоящие G1/G2, по9 smoke; fixedpoint13/verify781 PASS. Штатный G2 graph-tool собран,
SHA-256 `10dbb1b4dab7e7dd3395ea441d8a481ec795e6992bf60f3afa0be91bc0e35b59`.
Повтор G2 (34 случая в трёх режимах, включая runs2; 33 полных negative AFTER; mutation24) прошёл;
Штатные render/docs check383 прошли:35/14/27/44/615, ссылки/LF.
Рабочая связка383 — boot-m11-copy-bindings-01/g2 + graph-m11-copy-bindings-g2-01.
Это ограниченная проверка copy-классов; полный M11, оставшиеся5е/7/8, внешний/вычисленный CodeBody,
native copy и M13/M14 OPEN.

**Предыдущее состояние, 2026-11-14, срез382; база381 `38cf026c`.** Общий `code_body` возвращает
заимствованные `body/from/to` по существующим ролям аргументов управления (§6.3). Для полного хвоста
`else`/`finally` единственная написанная группа выбирается телом один раз; уже выбранное тело и его остаток
повторно не раскрываются. Scanner, `fn_own`, обходчик, native и `code_parent` используют тот же выбор,
без изменения физических родителей, нового кадра или реестра; экспорты Graph71/Run53/implements74.
Runtime01/Graph01 и пять pure-проб прошли: calls4 вместо2, cleanup trace21 вместо1,
written Fn790/computed890 вместо90, own late7/cleanup return4-after5/inert fields0,
включая unknown внутри двойной группы; отрицательная проба отвечает6 с cleanup/root trace21.
Код собран на Source01:751; Source02:761 добавляет только пять fixture pairs, SHA-256
`be5db8e3168082a1509b5b035f7d293b0f8ec40a6092c321b247647443e04d7f`.
Private25 triple/75 полных AFTER/mutation24 и native trace written/computed outer/fn_apply прошли.
Настоящие G1/G2 quick с девятью smoke каждый, fixedpoint13 и verify761 прошли. Штатный G2 graph-tool собран,
SHA-256 `f71df0958fda2d9be2e958b70fcd3b081e2248305aa07a68a7dbf6eda5b89316`.
Повтор G2 (25 случаев в трёх режимах, 21 полный negative AFTER, mutation24) и штатные render/docs check382
прошли:35/14/27/44/615, ссылки/LF. Рабочая связка382 — boot-m11-codebody-01/g2 + graph-m11-codebody-g2-01.
Внешний или вычисленный CodeBody,
копирование raw-объявлений и удержанных F как разных значений, полный M11, M11.7/8 и M13/M14 остаются OPEN.
Приёмка copy-классов разделена в [чтении плана](../steps/handoff/copy-construction-reading-20261114.md):
исходные Space bindings не переносятся, новое применение `fn` остаётся отдельным созданием.

**Предыдущее состояние, 2026-11-14, срез381; база380 `c5ba5ef9`.** `lexical_scope` существующего кадра
отслеживает выбранный физический CodeBody, сохраняя `code`/`body`/`data`; обходчик и native используют общий
`work_scope` (§6.3). Runtime06/graph02, 17 pure-проб, прежние 67 полных AFTER без изменений,
private31 в трёх режимах, AFTER93 и mutation24 прошли на Source07:751. Финальная emitter-only оптимизация
покрывает первый statement entry-prefix без повторного вызова. Graph03/private02 inline triple и native trace
прошли на Source08:751, SHA-256 `b84c11fec03b4eb7fa7a35db19ebf732be8ab13975191eb704207dab0961e906`.
Trace подтвердил actual native outer, `work_scope` и `fn_apply`. Настоящие G1/G2 quick с девятью smoke каждый,
fixedpoint13 и verify751 прошли. Штатный G2 graph-tool собран, SHA-256
`b8abfe4c58cc5702009aa09f65ce0a9b040aec403602c1c31eec88989fbcce4f`.
Повтор штатным G2 (86 случаев в трёх режимах, 102 полных negative AFTER, mutation24) прошёл;
штатные render/docs check381 прошли:35/14/27/44/615, ссылки/LF. Рабочая связка — boot-m11-computed-body-01/g2
и graph-m11-computed-body-g2-01; [свидетельство](../steps/witnesses/m11-computed-body-20261114/notes.md).
Полный M11, копирование live F с её data и M13/M14 остаются OPEN; динамически созданный callee может
исполняться обходчиком, что не подтверждает ordinary native M14.

**Предыдущее состояние, 2026-11-14, срез 378 — приёмка пройдена.** Два исходника ядра:
корень использует общий work frame и block0; native wrapper завершает этот кадр, forced его переиспользует.
Отдельный root emitter удалён. Scalar values стоят без capture; discarded AST читает общий value reader,
computed body bindings используют прежние metadata/rows. Runtime01/graph01 и пять pure-проб прошли.
В private01 исполнены 50 случаев в трёх режимах: 48 совпали со старыми golden, 2 потребовали независимо
выведенных пяти изменений из-за root snapshot k5: три outside8→5, data_result118→115, second892→592;
open_result55 сохранён. Готовые 50 binaries не пересобирались. Дополнительный root_frame_error прошёл triple;
всего 51 случай исполнен в трёх режимах, все 153 полных AFTER-сравнения и mutation24 прошли.
У finally_body_error/sub_error прежде не было expected; добавлены полные AFTER с root_trace12/seen12.
Три прежние fixture pairs переведены на явные control Frames. Source04: 685, SHA-256:
b8e7d5a1a3742540b298ac30f0f1c2cc2f72fa776a358d14258ab1bd77e935d4.
Whole bootstrap01 quick прошёл: настоящие G1/G2, по 9 smoke, fixedpoint13/verify685. Штатный G2 заново собрал
graph-tool и повторил 51 случай в трёх режимах, AFTER60/mutation24; runtime01 совпадает с G2.
Render/docs-check прошли:35/14/27/44/615, ссылки и LF27517; оба diff --check чисты, actual native root trace01 прошёл.
Рабочая связка: boot-m11-root-frame-01/g2 и graph-m11-root-frame-g2-01.
G2 graph SHA-256: dff1d7202b123be1758e88248960da8ba6f64aed57929729ba8edf453255eed7.
Полный M11.5г, path-head calls,
computed ordinary declarations, M11.7/8, legacy computed-int construction M13 и shared cache/flush/ordinary native M14 OPEN.
[Свидетельство 378](../steps/witnesses/m11-root-frame-20261114/notes.md).

**Предыдущее состояние, 2026-11-14, срез 377 — принят `04fbf275`.** В ядре изменён только `lmx_graph_run.lm2`:
открытие кадра готовит written fn/sub выбранных data/body перед work scan, а повторная подготовка использует
существующий binding области и raw source. State сохраняет F и её own data: first1/second2, leaf_count2/sub_count2,
bumped2. Отдельные D/C дают 32/34, data_count12/code_count22, touch_calls0. Два объявления leaf с разными
raw source остаются разными вхождениями; голое обращение к leaf отказывает с 3 до тела, before1/after0. Source02:673;
private38 в трёх режимах, AFTER45/mutation24 прошли. Whole bootstrap01 quick прошёл: настоящие G1/G2,
по 9 smoke, fixedpoint13/verify673. Штатный G2 заново собрал graph-tool и повторил 38 в трёх режимах,
AFTER45/mutation24; runtime02 совпадает с G2. Штатные render/docs check прошли:
35/14/27/44/615, ссылки и LF индекса27467; оба diff --check чисты.
Source02 SHA-256: 1441737c4cf71b27ab81c4734846f1b30a469326f7146f1dc86c33f74f8e4fa9.
Рабочая связка: boot-m11-ordinary-nested-01/g2 и graph-m11-ordinary-nested-g2-01.
G2 graph SHA-256: 039e29be84a420aa7ace00c0ba6003472bb56146c3fb5a40093aba124d6d2f5a.
Весь M11.5г, root-frame, computed ordinary declarations, M11.7/8, M13 и ordinary native M14 остаются OPEN.
[Свидетельство 377](../steps/witnesses/m11-ordinary-nested-20261114/notes.md).

**Предыдущее состояние, 2026-11-14, срез 376 — принят `9039fa89`.** Каноническое `@: p int`
без кандидата предвыделяет wrapper8/cell5 до index/typeof/path; обязательный formal8 получает независимую
reference cell через общий допуск. Source04: 669; runtime02/graph03, пять pure, private36 в трёх режимах,
AFTER42/mutation24 прошли. Настоящий native TypeOnly с physical8 в method.code подтверждён GDB trace03
в частном конвейере с нормальным выходом. Whole bootstrap01 quick прошёл: настоящие G1/G2, по 9 smoke,
fixedpoint13/verify669. Штатный G2 заново построил graph-tool и повторил 36 в трёх режимах,
AFTER42/mutation24; runtime02 тождественен штатной сборке. Рабочая связка:
boot-m11-uninit-reference-01/g2 и graph-m11-uninit-reference-g2-01. Штатные render/docs check прошли:
35/14/27/44/615, ссылки и LF индекса27434; оба diff --check чисты. Прямой G2 trace01 также прошёл.
Source04 SHA-256: de34eb33fb7f603d1ed08c8bf7f69da0c7ffe5cd473d3408f9e770f5e6840daf.
M11.7/8, общий M11, M13 и ordinary native M14 этим не закрыты.
[Свидетельство 376](../steps/witnesses/m11-uninit-reference-20261114/notes.md).

**Предыдущее состояние, 2026-11-14, срез 373 — вычисляемые ссылочные места; кодовая приёмка пройдена.** Прежняя work map
связывает сохранённый raw Frame `@` с кандидатом: три поля для int-ссылки, два для Structure-ссылки.
Допуск не запускает initializer. До рабочей записи чтение или запуск такого места отказывает с 5;
первая запись создаёт рабочую typed reference, штатный flush публикует её через прежний слот.
Существующие инициализированные ячейки и wrappers сохраняют прежний контракт. `@: p int` без кандидата OPEN:
требуются primitive kind5 и заранее выделенные wrapper8/cell5; сейчас форма явно отказывает с 5,
не выдаётся за kind6 и не создаёт хранилище лениво. Это не отказ по содержимому uninit:T.
Runtime02/graph01 прошли шесть pure-interpreter случаев: места 41/13/30/23 при calls0; чтение и запуск — 5
после before1 при calls0; ссылочный и числовой preflight — 4 при calls0; приоритет привязок 7/8/9/12 при calls0.
Полный bootstrap quick построил настоящие G1/G2, по 9 smoke; fixedpoint13 и verify643 прошли.
Штатный G2/graph повторил22 в трёх режимах, AFTER24 и mutation24. Штатные render/docs check прошли:
35/14/27/44/615, ссылки и LF индекса 27 317 файлов; оба diff --check чисты.
Независимая проба вновь открыла M8 consumer для @2 с одно-полевой written Structure; он идёт следующим.
Весь M11.5г, общий корневой маршрут и native обычной Structure M14 остаются OPEN.
[Текущий срез и границы](../steps/current.md).

**2026-11-14, срез 372 — root/self dispatch, M11.5г OPEN.** Именованная голова разрешается по живым данным
и вызывает метод либо запускает обычную Structure общим механизмом, включая корень и запуск над собой.
Написанная анонимная Structure отдельным оператором остаётся значением: её поля не исполняются и не добавляют
входы или собственные места; выбранные тела управления и непосредственно потребляемые выражения сохраняют свои роли.
Частная связка прошла 16 случаев в interp/native/forced, три полных AFTER-сравнения и mutation. Полный bootstrap
quick построил настоящие G1/G2, по 9 smoke; fixedpoint13 и verify631 прошли. Штатный G2/graph повторил
18 случаев в трёх режимах, AFTER3 и mutation24. Штатные генерация и docs-check прошли:
35/14/27/44/615, ссылки и LF индекса 27 273 файлов; diff --check чист.
Корневые числовые/ссылочные публикации и прямой вызов по голове-пути
ещё требуют общего маршрута; весь M11.5г, последующие 5д–5е, M11.7/8 и M13/M14 остаются открытыми.
[Текущие проверки и границы](../steps/current.md). Хроника ниже сохраняет результаты и пределы своих срезов.

Парная версия — [EN](kernel-implementation.en.md). Нормативные источники языка — [семантика L3](LMX_semantics.ru.md),
[грамматика](LMX_grammar.ru.md), [L2](L2_spec_ru.md), [L1](L1_spec_ru.md); этот документ — спецификация **реализации**
ядра и выпускаемого им кода по поручению автора 2026-11-08 (слова автора дословно — [журнал](../LMX_blog/2026-11-08.md),
разделы «Остановка инкрементальных кодов идентификаторов…», «Атом — единственная не-структура…», «namespace — служебные
таблицы обхода…», «Чистый граф…», «Единый механизм неинициализированных примитивов…», «Все проверки — по адресам в
арене…», «Замена указателя — при первом присваивании», «Служебные операторы и ресиверы — без отдельных кодов…», «Термин:
примитив, не атом…»; передачи CODEX-FABLE-AUTHOR-KERNEL-REBUILD-20261108T171209823Z-01,
CODEX-FABLE-AUTHOR-ATOM-ADDRESS-20261108T172249908Z-01, CODEX-FABLE-AUTHOR-NAMESPACE-TRAVERSAL-20261108T172512156Z-01,
CODEX-FABLE-AUTHOR-CLEAN-GRAPH-FRESH-TRAVERSAL-20261108T172943665Z-01,
CODEX-FABLE-AUTHOR-UNIFIED-UNINITIALIZED-TYPES-20261108T180019959Z-01,
CODEX-FABLE-AUTHOR-ARENA-ADDRESS-VERIFICATION-20261108T180226654Z-01,
CODEX-FABLE-AUTHOR-FIRST-ASSIGNMENT-ONLY-20261108T181027312Z-01,
CODEX-FABLE-AUTHOR-OPERATORS-STRING-ADDRESSES-20261108T181832549Z-01,
CODEX-FABLE-AUTHOR-PRIMITIVE-TERMINOLOGY-20261108T182057865Z-01,
CODEX-FABLE-AUTHOR-UNINIT-POINTER-SAME-CELL-20261108T190254726Z-01; проверки Codex
CODEX-FABLE-KERNEL-SPEC-REVIEW-20261108T175116933Z-01 и CODEX-FABLE-KERNEL-SPEC-REVIEW2-20261108T185727823Z-01 внесены).
Статус: **рабочая спецификация перехода; документ целиком Codex принятым не объявлял** — направление и порядок §11 п. 0
разрешены вторым ревью, реализация начата с независимой основы; открытых вопросов автору нет. Пометки: «норма» — слова
автора или действующая книга; «решение» — выбор исполнителя в пределах нормы, проверенный Codex. Хроника срезов ниже
называет части вызываемого так, как их называл срез, — `var`, `body`, — а порядок двух аргументов `call` пишет
`call: code data`; по решению автора 2026-11-11 части называются `data` и `code`, порядок — `call: data code`, и
чистый граф читает их со среза 354 (§3.4).

Реализация Codex graph10/tool11/rt07 выполняет пример Point/take из §10 и проверки используемых полей обоими
потребителями; [свидетельства и границы](../steps/witnesses/clean-call-20261108/notes.md). Это частичный переход:
поддержаны int-результат, тело с одним return, пустая var, позиционные аргументы и int-умолчание.
Следующий [graph11/tool11/rt08](../steps/witnesses/clean-expr-20261108/notes.md) нормализует поддержанные выражения:
бинарная операция — Lmx [левое, слово оператора, правое], префиксная — [слово оператора, операнд]; вложенность задаётся
построителем с учётом разделителей P0. Оба потребителя читают эту форму без разбора приоритетов. Остальные операторы,
формы тел, допуска, примитивов и корней ещё не реализованы. Спецификация ниже задаёт цель,
а не объявляет весь существующий runtime соответствующим ей.

Продолжение [graph15/tool12/rt12](../steps/witnesses/working-var-20261108/notes.md) поддерживает явную int-var и
последовательные тела fn: присваивания, вызовы и return. Рабочие значения принадлежат отдельной активации, реальные
поля остаются в var; изменённые значения публикуются после вычисления аргументов перед вызовом и при выходе, включая
ошибку. Native вычисляет тело сам, используя общий механизм рабочих мест и публикации. 24/24 исполнения и19 проверок
изменения графа прошли.
Следующий [graph18/tool13/rt15](../steps/witnesses/body-inputs-20261108/notes.md) строит собственные int-поля тела в var,
с видимостью с первой строки; инициализаторы тела остаются на своих местах. Динамические int-входы получают локальные
места активации до var; вложенные методы не навязывают свои требования вызывающему. Сбор методов для native выполняется
одним обходом готового графа, независимо от построителя. 30/30 исполнений и19 изменений графа PASS. Управление потоком,
другие типы рабочих мест, полный допуск и общий call:code data тогда оставались открыты.
Следующее [продолжение code/data](../steps/witnesses/code-data-20261108/notes.md) связывает int-места обычной Structure
и fn с явно выбранными данными. Сокращённый call выбирает var; совпадение code/data не меняет механизм. Карта адресов
и рабочие значения живут только в активации, данные не дополняются; native вычисляет тело напрямую. Остальные типы,
управление потоком и полный допуск ещё открыты; вся модель активации не завершена.
Следующий [graph24/tool16/rt22](../steps/witnesses/control-flow-20261108/notes.md) поддерживает if/else, while, for,
ближайшие break/continue/redo и return из inline-тел, сравнения и короткие &&/||. Тела остаются обычными Lmx,
обходятся в текущей активации; построитель добавляет собственные int-поля inline-тел в общую var. Native генерирует
свои условия и переходы. 27/27 исполнений и19 изменений графа PASS.
Текущий [graph28/tool17/rt23](../steps/witnesses/post-loop-20261108/notes.md) строит until как обычную Lmx
[until, условие, тело]. Именованная Structure сохраняет свои поля, а её выполняемое поле ссылается на этот цикл;
общие поля тела и Structure остаются теми же ячейками. Native выделяет каждый встреченный адрес один раз,
временная карта трансляции связывает его с локальной переменной генерируемого конструктора и удаляется после обхода.
Оба потребителя исполняют постусловие после тела, continue идёт к нему, redo пропускает его.
33/33 исполнения и19 изменений графа PASS. Именованные переходы, очистки и остальные типы/формы ещё открыты;
этот срез не завершает всю модель активации или общий codec состояния графа.
Текущий [graph34/tool19/rt26](../steps/witnesses/finally-20261108/notes.md) выполняет достигнутые finally в обратном
порядке при выходе из области: обычном, return, ближайших переходах цикла и поддержанных ошибках. Значение return
удерживается до очистки; dirty-поля публикуются перед очистками выхода из активации и после них. Выход или ошибка
из очистки не запускает её повторно и не пропускает внешние очистки. Native генерирует эти пути напрямую, состояние
регистрации живёт только в текущем обходе/вызове. 42/42 исполнения и19 изменений графа PASS. Именованные цели,
throws/catch, stop/yield, остальные типы и полные активация/codec/самосборка ещё открыты.
Продолжение [graph36/tool21/rt28](../steps/witnesses/sub-calls-20261108/notes.md) проводит sub через общий путь:
слово sub и части args/var/body, без return. Вызовы в корне и вложенном методе, умолчания, явные code/data,
динамические входы, завершение тела, голый return и finally используют те же активацию и публикацию.
Использование sub как числа отвергается до эффектов аргументов. 42/42 исполнения, два отказа результата
и19 изменений графа PASS. fm, остальные типы, полный допуск, исключения, операции состояния графа и §§8/8a не завершены.
Текущий [graph40/tool22/rt30](../steps/witnesses/known-assignment-20261108/notes.md) сохраняет := как Lmx
[слово :=, место, правая часть]. Флаг парсера не сохраняется; путь места — обычная вложенная Lmx.
Оба потребителя проверяют известное int-место до RHS; голое имя пишет рабочее значение, явный путь — граф,
не обновляя рабочий снимок. Native вычисляет RHS напрямую. Типизированный int-литерал строится тем же примитивом.
30 исполнений и19 изменений графа PASS. Остальные типы, запись ссылок, именованная подача := и §§8/8a остаются.
Следующий [graph41/tool23/rt31](../steps/witnesses/named-arguments-20261109/notes.md) — именованная подача `a := v` в
структуре аргументов callable (WIP Codex, проверен и завершён Opus). Один временный binder вызова сопоставляет
написанные позиционные и именованные фактические с физическими слотами формалов выбранного вызываемого по адресам
имён; неизвестное имя, повтор, позиционный после именованного и недостающий обязательный формал — отказ формы до
любых эффектов аргументов. Затем правые части вычисляются в порядке записи, каждая сразу принимается своим формалом;
отказ приёма оставляет следующие невычисленными, тело не начинается. Карта привязок живёт только в вызове; native
выпускает её и вычисляет правые части сам. `a(5)` и `a: 5` — обычные вызовы с позиционным результатом. Все 45 фикстур
графа: 45 запусков graph-check × interp/native/forced PASS (sub_void_value — отдельно), mutation 11/11,
method-mutation 8/8. Вычисляемые умолчания, AXBY с пользовательскими преобразованиями, q/z, merge35 и §§8/8a остаются.
Следующий [graph42/tool24/rt32](../steps/witnesses/whole-arguments-20261109/notes.md) — вся структура аргументов одной
Structure: единственная позиционная фактическая без эффектов (имя или путь), чьи прямые поля называют формалы
выбранного вызываемого того же рода при умолчаниях прочих, подаётся своими полями; иначе она — обычный первый аргумент.
Решение принимает одна функция ядра `lmx_graph_call_single` для интерпретатора и native, по формалам и прямым полям,
без поиска по дереву и второго чтения: `k(s)` даёт q и z из `s` (15), `k(q := s)` — 50. 48 запусков graph-check ×
interp/native/forced, mutation 11/11, method-mutation 8/8 PASS. `merge` в чистом графе (пример 35), производитель
Structure с эффектами и выбор среди двух методов одного имени остаются.
Следующий [graph43/tool24/rt33](../steps/witnesses/whole-empty-20261109/notes.md) по ревью Codex заменяет проверку рода
поля и формала общим допуском подмножества: поле подаётся формалом, только если тот его принимает (`lmx_graph_admit`);
пустая Structure — пустая цепочка полей, вызов нульарного или только с умолчаниями (`zero(zero\var)` = `zero()`,
`defaults(zero\var)` = `defaults()`). Пустую именованную Structure (`Empty: ()`) текущий построитель не строит —
записанное ограничение. 49 запусков graph-check × interp/native/forced PASS.
Следующий [graph44/tool25/rt34](../steps/witnesses/clean-merge-20261109/notes.md) — `merge` в чистом графе (§6.4).
Операнды вычисляются один раз слева направо по своему общему смыслу: имя, путь, вложенный `merge`, вызов; анонимная
Structure `(a: int: 5)` строится по обычным правилам — неизвестное имя определяется своим полем. Затем одна операция ядра
`lmx_graph_merge_values` для интерпретатора и native строит новый корень с раскладкой модели и новыми полями в конце;
одноимённое поле позднего операнда пишется в слот модели допуском присваивания (та же ячейка). Одна карта источник →
копия на все операнды: корни операндов — результат, общие цели и циклы общие, строки имён копий — те же канонические
имена; источники не меняются. Голова-функция вызывается один раз, поле модели вызов не перехватывает: `f(3)` и `f: 3` —
один граф, int-результат не Structure — отказ приёма (4). Frame с головой-не-функцией — описание структуры; его копия
несёт написанные имена, и копия их лексической цепочки открыта (5), как и копия вызываемых, поэтому у результата нет
лексического родителя. `mytest(merge(mytest\args; (a: int: 5)))` = 35 во всех трёх режимах, native-код исполняет `merge`
во время выполнения. `merge(f1; f2)` двух функций (построитель не строит дескриптор без тела), держимое место
`pack: merge(...)` и замена Structure-слота остаются. 53 запуска graph-check × interp/native/forced PASS.
Следующий [graph45/tool26/rt35](../steps/witnesses/merge-places-20261109/notes.md) по ревью Codex: поле позднего операнда,
называющее int-место результата, — то же место в одной карте (значение и ячейка, в том числе под `uninit:int`);
соответствия ставятся до копии ссылок, поэтому ссылка на него в любом порядке полей ведёт к месту результата
(`R\a := 9` → `\R\p` = 9, источники целы; мутант без этого шага даёт 5). Поле `name: @x` анонимной Structure — новое
ссылочное место. Оператор корня `имя: значение` с неизвестным именем определяет место значением
(`lmx_graph_define`, оба потребителя): `pack: merge(mytest\args; (a: int: 5)); mytest(pack)` = 35. Дескриптор интерфейса
`fn: f2 (int: b 7) int` строится с частями `args`, `return` и адресуемой пустой `var`, без тела; он не вызываемое.
Копия написанных имён и вызываемых (с их лексическими предками) и сопоставление частей `fn`/`return` при `merge(f1; f2)`
(вопрос автору) остаются. 58 запусков graph-check × interp/native/forced PASS.
Следующий [graph46/tool26/rt36](../steps/witnesses/merge-repeat-20261109/notes.md) по ревью Codex: повторная подача поля
поздним операндом отличается от первого заполнения слота позицией (операнд, поле) — локальными данными обхода merge, а
не адресом, поэтому тот же источник, поданный снова, пишется снова по порядку операндов: `merge(M; N; M)\a` = 1,
`merge(N; M; N)\a` = 5, источники целы. 59 запусков graph-check × interp/native/forced PASS.
Следующий [graph48/tool27/rt37](../steps/witnesses/merge-callable-20261109/notes.md) по ревью Codex 327: `merge(f1)`
копирует вызываемое — его части как обычные Lmx, написанное слово — новая ячейка WORD с тем же каноническим адресом
(`lmx_graph_word_of`) — и при написанных именах или вызываемых в копии берёт нужных лексических предков целиком через ту
же карту до `parent` = 0; `parent` результата — копия родителя модели. Копия — новая Lmx без `native`: её вызов исполняет
интерпретатор, переиспользование прежней реализации не доказано. Место `g: merge(f1)` определяется значением; вызов
`g(1)` в native-коде корня разрешается, связывается и диспатчится ядром во время выполнения (путь `g \ поле` — чтение,
не вызов). При `int: k 2` и `k: 5` после merge: `f1(1)` = 15 (живой `k`), `g(1)` = 12 и `g(2)` = 22 (скопированный
`k` = 2), собственные `calls` раздельны (`f1\var\calls` = 1, `g\var\calls` = 2). Открыто: прежнее имя внутри копии —
слот `f1` скопированного корня держит саму копию, названную новым местом `g`, поэтому рекурсивный `f1(...)` в теле
копии не находит имени (3); вызов определённого места из native-тела метода. 60 запусков graph-check ×
interp/native/forced PASS.
Следующий [graph49/tool28/rt38](../steps/witnesses/callable-reference-20261109/notes.md) по ревью Codex 328: результат
одного операнда `merge` — копия его корня и сохраняет его имя (§5.1), поэтому слот `f1` скопированного предка отвечает
`f1` у копии и рекурсия копии остаётся в копии: `g(3)` = 6 при `g\var\calls` = 4 и `f1\var\calls` = 0. Новое место для
именованной Structure или вызываемого — новая именованная ссылка на тот же экземпляр (участок `LMX_TYPE_GRAPH_LMX_REF`,
`lmx_graph_ref_lmx`; цель берёт `lmx_graph_target`): `g: merge(f1)` и `h: f1` дают `@: g f1` и `@: h f1`, имя цели не
меняется (`h(2)` = 21, оператор `h(5)`, `f1(3)` = 33, общий `calls` = 3), а `P\a := 7` через `P: M` меняет `M\a`.
Голова вызова в выражении и операторе, путь, запись поля, `call:`, операнд `merge` и цельная структура аргументов берут
цель ссылки в обоих потребителях; копия ссылки указывает на копию цели через ту же карту. Native: вызов головы, которую
трансляция не разрешает, — общий resolve/bind/invoke во время выполнения и в корне, и в теле метода, а оператор на
месте, определяемом при исполнении, решается тогда же (вызов либо запись), как в интерпретаторе: тело `twice` с
оператором `g(a)` и `return: g(a) + 1` даёт 13 при `g\var\calls` = 2. Сбора в чистом графе нет; имя композиции
нескольких корней и части `fn`/`return` (вопрос автору), адрес `@` ссылки на Structure и замена Structure- и ссылочного
слота (5) открыты. 63 запуска graph-check × interp/native/forced PASS.
Следующий [graph50/tool28/rt38](../steps/witnesses/runtime-statement-20261109/notes.md) по ревью Codex 329: за чтением
вызова оператора на месте, определяемом при исполнении, ветка записи берёт только одно поле значения без именованного
фактического (`lm_graph_emit_write_form`); другая форма — несколько фактических, именованные, ни одного — не запись и
при выборе невызываемого места отказывает тогда же (как интерпретатор: ответ 2 или 5), а не обрывает трансляцию верного
вызова. Воспроизведено на graph49 (`graph: emit answered 2`) и исправлено: `f(a; b)` с `calls`/`last`, `g: merge(f)`,
`g(1; 2)` в корне, `g(3; 4)` в native-теле метода и `g(b := 7; a := 6)` дают у копии `calls` = 3, `last` = 67, у `f` —
0 и 0; `x: 4`, `x(1; 2)` — ответ 2; в native/forced R0 останавливается (success 0), `y` не вычислен. 65 запусков
graph-check × interp/native/forced PASS.
Следующий [graph52/tool29/rt40](../steps/witnesses/clean-production-20261109/notes.md) по ревью Codex 330 — первый
production-вход чистого пути, машинный модуль `src/l2src/lmx_schedule.lm2` (его L1 сейчас выпускает F в build-runtime).
Существующей командой `G run` на graph50 граница — построение (`graph: build answered 2`): ссылочный формал `@: s T`
построитель не принимал. Теперь формал `@: name T` строится Frame `[@, name, T]`, названным полем 1 (книга :436), и
печатается; объявления C-двери `include:`/`predef:` — слова состояния (`w_include`, `w_predef`), их операторы остаются в
корне и стоят (корень ничего для них не исполняет; читать их будет машинный выпуск). Граф `lmx_schedule` строится
целиком и печатается одинаково до и после исполнения корня; так же `l2_libc`, `lmx_clock`, `os_native_path`,
`tools/text`. Машинный экспорт из чистого графа (вход F вместо P0) — следующий шаг; C-двери в интерпретаторе пока нет.
66 запусков graph-check × interp/native/forced PASS.

Решение автора 2026-11-10 ([журнал](../LMX_blog/2026-11-10.md#forms-declare-or-call),
[книга](LMX_semantics.ru.md#forms-declare-or-call)): структурные формы только объявляют или вызывают, значение в
известное место записывает `:=`. Далее сохранено историческое описание
[среза 346](../steps/witnesses/colon-declares-clean-graph-20261110/notes.md): определение места значением
(`lmx_graph_define`) и запись формой `имя: значение` сняты у обоих потребителей; описания срезов выше называют
состояние кода до него. Форма корня `Имя: хвост`, голова которой не слово языка, не ресивер и не вызываемое, —
объявление Structure (`lmx_graph_root_declares`), исполняемое там, где обход до неё дошёл (`lmx_graph_space_reach` →
`lmx_graph_root_declare`): атом хвоста, который сейчас называет Structure, вызываемое или место, — сама эта сущность,
её адрес ложится в слот без копии, неизвестный атом остаётся словом; вложенные формы и сохранённые операторы стоят как
написаны. Повторное объявление отдаёт месту имени — слоту корня с прежней Structure — заново объявленную, а слот самой
формы остаётся пустым: второго поля нет, дамп пустой слот не печатает. `Имя: merge(...)` объявляет Structure, которую
строит ресивер: имя получает результат; копия одного операнда уже названа, её держит `@: имя merge(...)`. Голова —
известное место, не являющееся Structure (место `int`, ссылочное место), в корне, в теле и на пути `владелец\поле:` —
отказ: ответ 8 интерпретатора, останов R0 в программе (со среза 356 ссылочное место на обычную Structure в корне и в теле её запускает — ниже; на пути `владелец\поле:` и для места, не ссылающегося ни на вызываемое, ни на Structure, отказ остаётся); транслятор называет `:=` в сообщении и выпускает отказ на месте
оператора. Объявление Structure внутри исполняемого тела и повторное объявление по пути срез не исполняет (5). Поля
письменного операнда `merge` объявляют ресиверы — `int: имя значение`, `@: имя int значение`; поле `имя: хвост` там —
описание структуры (5). Пример автора `Struct2: a b c`, `Struct1: q w e r t`, `Struct1: Struct2` даёт дамп
`Struct2: a b c` и `Struct1: (Struct2 a b c)`. 99 запусков graph-check × interp/native/forced PASS. Понижение L3,
машинный путь L2 и обходчик присваивание двоеточием ещё принимают — раздел [M7 плана](../next_core_tasks_v3.md#m7).
Решения автора 2026-11-11 изменили норму того, что исполняет этот срез, — привязку атома хвоста при объявлении,
замену содержимого при повторе, имя, получающее результат `merge`, печать указуемого в дампе, само объявление
Structure среди исполняемых записей и запись с головой — обычной Structure или местом со ссылкой на неё в коде, которая
теперь запускает Structure по имени; что по ним действует и что чистый граф пока делает иначе, сказано ниже, в абзацах
о ролях `data` и `code`, об ответах автора и о запуске Structure по имени.

Перепись таких записей в рабочем frontend — [срез 347](../steps/witnesses/colon-census-20261110/notes.md), шаг 1
раздела M7. Транслятор сам называет каждый структурный Frame — с двоеточием, компактный или блочный, всё, кроме
оператора `:=`, — который он понижает как запись в место: `lm_compiler_colon_write` (`l2_frontend_types.lm2`)
вызывается в ветвях записи понижения (`lm_compiler_emit_stmts_with_position`, `lm_compiler_emit_loc_stmt`) и
понижения обходчика (`lm_compiler_rw_stmt_content`). Когда окружение называет файл в `L2_COLON_WRITES`, функция
дописывает в него строку: путь трансляции (1 — машинный метод, 2 — понижение L3, 3 — обходчик), вид левой части
(1 — голое имя, 2 — путь по полям, 3 — индекс, 4 — разыменование, 5 — путь по полям памяти C; 6–9 — формы, которые
сами заводят место: имя по значению, ссылка `h: Box`, результат вызываемого `r: h(3)`, место под Structure в голове
`Model: m`), файл, строку, столбец и смещение головы, её длину, флаги Frame и текст головы. Голова — слово языка или
ресивер `@` — строки не даёт: такое объявление делает ресивер. Без переменной функция ничего не делает, выпускаемый
L1 от неё не зависит. Две команды инструмента (`tools/migrate.lm2`) читают отчёт: `colon-report CENSUS STAGE SOURCES`
считает места — одно двоеточие одного файла, сколько бы трансляций и путей его ни назвали — по пути и виду и сверяет
каждую строку с исходным текстом (голова на своём смещении, за ней двоеточие и пробел); `colon-migrate` заменяет
двоеточие каждого сверенного места видов 1–5 на ` :=`, места видов 6–9 печатает и оставляет как написаны, строку,
которую текст не подтвердил, не трогает. По тексту команда ничего не ищет. Отчёт по сборке frontend, ядра,
инструмента, транслятора графа и по полному набору фикстур: 53 998 строк, 193 файла, 34 843 места. Машинный путь —
33 639 мест (имя 20 216, индекс 8 925, разыменование 1 188, путь по полям памяти C 3 310), все подтверждены
текстом. Понижение L3 — 1 309 мест записи (имя 937, путь 215, индекс 140, разыменование 15, память C 2) и 18 мест,
где форма сама заводит место; обходчик назвал 1 276 мест записи (имя 906, путь 215, индекс 140, разыменование 15)
и 18 таких форм. Текст
не подтвердил 76 мест (762 строки): 61 — форма ресивера `@: место значение`, которую frontend приводит к записи по
пути, 15 — блочные и компактные формы Structure на известном месте (`T:` с телом, `Outer\Model()`); команда их не
переводит. Отчёт не видит три рода записей: модули ядра, которые транслируются из чистого графа (`lmx_schedule`,
`lmx_clock`, `lmx_process_deadline`), ветви `default:` блоков `os` (на Windows они не понижаются) и исходные тексты,
которые транслирует только сборка поколения (`l2_frontend_graph.lm2`, `tools/l2trans.lm2`, `tools/lmxchild.lm2`).

Тем же срезом исправлено чтение объявления не на своём месте. Проход, который до связывания вызовов выносит
`merge`, записанный аргументом вызова, в скрытое объявление (`lm_compiler_merge_lift_walk`), спрашивает у каждого
оператора, объявляет ли он, а чтение объявления спрашивает места текущего метода и запоминает ответ для узла
(`lm_compiler_declaration`; повторный ресивер `@` берёт требование прежнего объявления своего имени). Начиная со
второго круга регистрации текущим оставался метод, на котором кончился сбор, — последний метод модуля, — и
`@: p int @ x` любого другого метода читалось как повтор места `p` того метода с двумя значениями: «a declaration
takes one value». Отказ проявлялся, когда указатель с тем же именем в последнем методе стоял ближе к началу своего
файла, чем объявление — к началу своего, то есть через часть программы; так он и был найден — добавлением части
инструмента. Проход теперь читает каждый метод как его собственный (`lm_compiler_merge_lift_methods`) и возвращает
вызвавшему прежнее место чтения; фикстура — `tests/dyn/declaration_site.lm2` с частью
`declaration_site_part.lm2`. `bootstrap quick` — 0 отказов, поколения совпадают; полный набор — `SUITE 140 rows,
0 failures`, 1108 PASS; 99 запусков graph-check × interp/native/forced PASS.

[Срез 348](../steps/witnesses/colon-migrate-machine-20261111/notes.md) закрыл три пробела отчёта и перевёл на `:=`
машинные исходные тексты — транслятор, ядро, инструмент и транслятор графа. Машинный путь из чистого графа
(`lm_compiler_graph_block`, `l2_frontend_graph.lm2`) выпускает оператор `left := value` — безымянную Lmx
[`:=`, левая часть, операнд] построителя — той же записью, что и форму `имя: значение` и `владелец\поле: значение`:
`lmx_schedule` и `lmx_process_deadline`, переведённые на `:=`, дают из графа побайтно прежний L1. Положений в
исходном тексте у чистого графа нет, поэтому строки отчёта для этих модулей даёт трансляция тем же frontend без
слова `--graph`. Цель, для которой выбираются ветви блоков `os`, называет переменная окружения `L2_OS_TARGET` —
`win` или `default`; без неё цель своя у транслятора (`lm_compiler_os_target`). Трансляция для другой цели пишет L1
этой цели; так ветви `default:` понижаются на Windows и называют свои записи. Тексты, которые транслирует только
сборка поколения, даёт `bootstrap` с переменной `L2_COLON_WRITES`. Форма ресивера `@: место значение`, приведённая
frontend к записи по пути, строки больше не даёт; Structure, записанная полями на месте своей головы, — отдельный
вид 10. Команды отчёта отличают запись с двоеточием и пробелом от записи другой формой — компактной или блочной —
и вторую печатают (`COLON-FORM`), не трогая. Полный отчёт по `src` и `tools` — 76 776 строк, 34 117 мест в 101
файле: машинный путь 34 058 (имя 20 547, индекс 8 986, разыменование 1 188, поле памяти C 3 337), корневые программы
инструмента в понижении L3 — имя 64, индекс 19, и четыре формы `MainLetter: m`, которые команда не трогает
([П1](../LMX_blog/q/colon-declares-answered-20261111.md)). Все строки подтверждены текстом, записей
другой формой нет; по тексту вне отчёта не осталось ни одного оператора с двоеточием, голова которого — имя, путь
или разыменование. `colon-migrate` переписала 34 113 мест; каждая изменённая строка отличается от прежней одним
двоеточием, ставшим `:=`. Перевод не изменил ни одного выпускаемого файла: все 172 файла L1 поколения — тексты и
заголовки frontend, ядра и инструмента — побайтно равны файлам поколения до перевода; frontend, `l1trans`,
инструмент и транслятор графа — те же образы (`EXE-SAME 1`), `driver.o` тот же. Для того, что сборка на Windows не
транслирует, сверка отдельная: L1 цели `default` и L1 модулей маршрута графа, прочитанных без `--graph`, до и после
перевода равны. Повторный отчёт по переведённым текстам записей не называет — в нём остались четыре формы
`MainLetter: m`. `bootstrap quick` — 0 отказов, поколения совпадают; полный набор — `SUITE 140 rows, 0 failures`,
1108 PASS. Фикстуры
`tests` вне `tests/graph` этим срезом не переводились.

[Срез 349](../steps/witnesses/colon-migrate-fixtures-20261111/notes.md) перевёл на `:=` фикстуры `selfbuild/tests`
вне `tests/graph` — тексты, которые понижает путь L3: нативное понижение и обходчик. Перепись уточнена. Запись
Structure, которую написала форма ресивера `@: место (поля)`, строки не даёт: происхождение формы хранит свой бит узла
(`lm_compiler_receiver_form_node`), а роль записи по пути остаётся только на первом акте письменной формы. Frame без
полей в теле, который ветвь записи понижает как пустую Structure на известном месте (`Outer\Empty: ()`,
`Outer\Model()`), — вид 10, объявление. Строки дали полный набор, малый набор сборки поколения, список
`smoke-kernel225` и трансляция фикстур с ветвями `default:` для цели `default`: 13 187 строк, 1 221 место в 103
файлах — 1 160 мест записи (нативное понижение: имя 887, путь 211, индекс 45, разыменование 15, поле памяти C 2) и
61 форма, которая объявляет: 54 Structure, записанные на своём месте, четыре места под Structure в голове, две
ссылки и одно имя, определённые значением. Запись в известное место здесь — и запись ссылки на Structure,
`T: Swapped`, `Box\kid: Other`: прежнее чтение присваивало, фикстуры ждут присваивания, и по норме 2026-11-10 оно
писалось `T := Swapped`. `colon-migrate` переписала 1 160 мест. Три формы, которые сами заводили место, переведены
правкой на записи той же нормы — `var := D\var`, `@: b Inner2`, `@: Other Answers`; ещё 15 записей стоят за точкой
отказа в фикстурах строк `refuses`, трансляция до них не доходит, и они переведены чтением текста. Оператор `:=`
знает зарезервированное `var` — ссылку на данные текущего вызова — известным местом: сбор уже делал его входом
активации, отказывала только проверка левой части (`lm_compiler_check_body`). Решение автора 2026-11-11 норму этих
записей изменило: имена Structure не присваиваются — `T := Swapped` ошибочна, присваивают указатели-переменные,
объявленные `@: ptr T`, — а особое имя `var` называется `data` ([книга](LMX_semantics.ru.md#data-code-roles)); их
перевод — шаги 3 и 8 [раздела M11 плана](../next_core_tasks_v3.md#m11).

Проверки среза 349: полный набор — `SUITE 140 rows, 0 failures`, 1108 PASS. Из 220 программ набора у 212 выпущенный
L1 побайтно прежний; у двух (`whole_arguments`) он отличается только именем вынесенного `merge`, в которое входит
смещение в исходном тексте; у шести — фикстуры трёх форм, переведённых правкой, — другая нумерация мест при тех же
результатах. L1 60 программ цели `default` и 16 программ списка `smoke-kernel225` — прежний. Повторный отчёт записей
не называет: в нём 58 объявлений. `bootstrap quick` — 0 отказов, поколения совпадают; `l1trans`, инструмент,
транслятор графа и `driver.o` — те же, что после среза 348. Не переведён `tests/native_closure_values.lm2`: ни одна
команда инструмента его не транслирует. С двоеточием остались объявления: письменные Structure и записи `Имя: (поля)`
([П2](../LMX_blog/q/colon-declares-answered-20261111.md)), место под Structure в голове (П1),
объявления через `merge` (П4), составная форма ([M9](../next_core_tasks_v3.md#m9)) и вторые головы в трёх фикстурах
отказов, которые пересмотрит шаг 4. Понижение L3, машинный путь и обходчик запись двоеточием в этом срезе ещё
принимали.

[Срез 350](../steps/witnesses/colon-refusal-20261111/notes.md) ввёл отказ в рабочем frontend: структурная форма
объявляет или вызывает и известное место не записывает
([книга](LMX_semantics.ru.md#forms-declare-or-call)). Отказ стоит там же, где запись: каждая ветвь, которая
выпустила бы для структурного Frame запись в место, сначала спрашивает функцию переписи
(`lm_compiler_colon_write`, `l2_frontend_types.lm2`), а перепись показала, что через неё проходит каждая запись
нативного понижения L3, обходчика и машинного пути. Форма видов 1–6 — её голова известное место: имя, путь по
полям, элемент, разыменованная ячейка, поле памяти C — отказывает, сообщение называет `:=`: «a form with a colon
declares and writes no known place: assign with :=». Формы видов 7 и 8, которые определяли место значением
(`h: Box`, `r: h(3)`), отказывают своим сообщением: форма с неизвестной головой объявляет Structure с хвостом
внутри, ссылку объявляет `@: имя значение`. Виды 9 и 10 — объявления — проходят. Строка переписи пишется до отказа,
так что отчёт называет форму, остановившую трансляцию. Машинный путь из чистого графа
(`lm_compiler_graph_block`) отказывает в двух своих ветвях, выпускавших запись по формам `имя: значение` и
`владелец\поле: значение`; запись там — только оператор `:=`.

Пределы: понижение L3 строит повторное объявление Structure только по письменному телу; Structure с атомом,
называющим другую сущность, — `Struct1: Struct2` при известной `Struct1`, `h: Box` при неизвестной `h` — оно не
строит и такой форме отказывает, а не присваивает ссылку, как прежде. Такое объявление исполняет чистый граф. Отказ
не различает место-Structure и место значения: сообщение верно для обоих.

Проверки среза 350: девять фикстур отказа (`colon_known_*_refused`, `colon_absent_reference_refused`) — литерал, имя и
результат вызова в хвосте, путь, корень, элемент, разыменование, оператор тела именованной Structure, ссылка по
значению — отказывают нативно и под обходчиком. Мутант — отказ снят — транслирует все девять. Машинный путь
проверен на модуле ядра `lmx_ids` с одной записью, возвращённой к двоеточию: отказ; тот же модуль без правки даёт L1
сборки. Машинный путь из графа — на `lmx_schedule` и `lmx_process_deadline` с одной такой записью: отказ. Две
фикстуры, закреплявшие прежнее правило (`occurrence_bare_refused`, `occurrence_node_refused`: вторая корневая голова
формой `y: 7`), записывают вторую голову повтором объявления; их предмет и сообщение прежние. `bootstrap quick` — 0
отказов, поколения совпадают: в исходных текстах транслятора, ядра и инструмента записей двоеточием нет. Полный
набор — `SUITE 149 rows, 0 failures`, 1162 PASS; L1 всех 220 программ набора побайтно равен L1 прошлого среза;
`l1trans`, инструмент, транслятор графа и `driver.o` прежние.

Решение автора того же дня ([журнал](../LMX_blog/2026-11-10.md#receiver-args-only),
[книга](LMX_semantics.ru.md#receiver-args-only)): место объявляет только форма `ресивер: аргументы`, составная запись
`имя: ресивер: значение` снята. Примеры срезов 304 и 307 выше записаны прежней формой (`(a: int: 5)`); по норме то
же поле пишется `(int: a 5)`, и со среза 351 фикстуры пишут его так.

[Срез 351](../steps/witnesses/composed-form-20261111/notes.md) снял составное чтение в рабочем frontend (шаги 1–3
[раздела M9 плана](../next_core_tasks_v3.md#m9); в чистом графе шаг 3 сделан срезом 346). Составную форму читали
два места `l2_frontend_resolve.lm2`: читатель объявления (`lm_compiler_declaration`) — внешняя голова как место,
ресивер хвоста как утверждаемое требование — и роль содержимого (`lm_compiler_decl_content`, роль 4: «хвост
потреблён ресивером»), по которой Frame не считался определением Structure. Оба чтения оставлены оператору `:=`
(`место := int: 5` — запись значения, которое проверяет ресивер) и форме ресивера, приведённой к записи по пути
(`@: Box\k Model: Other`, бит узла 8192); у формы с двоеточием их нет. Дальше действует общее правило головы.
Неизвестная голова объявляет именованную Structure с хвостом внутри: `holder: int: time` — Structure с полем `time` в
корне, в теле Structure и в теле метода, что бы ни называло `time` снаружи; прежде известное снаружи имя превращало
ту же запись в место со значением. Известное место отказывает сообщением среза 350. Поле операнда `merge`,
записанное именем вперёд (`(a: int: 5)`, метка `MERGE-OPERAND-FORMS`), снято вместе с функцией
`lm_compiler_named_typed_field_kind`: такой операнд отказывает как непониженная форма операнда.

Чтобы `i: int: 6` при известном `i` отказывало по правилу формы, а не словами «int has no value» о её хвосте,
проверка принимаемого значения (`lm_compiler_check_receiving_value_at`, `l2_frontend_emit.lm2`) читает одиночное
применение ресивера примитива выражением: операнд принимается типом ресивера, место принимает этот тип — так же, как
она читала начальное значение ссылки под утверждённым требованием. С этим такое значение принимает и запись по
индексу и через ссылку (`a[1] := int: 6`, `\p := int: 6`); прежде оно проходило в записи по имени — составным
чтением — и по пути.

Предел: Structure с вызовом ресивера внутри — `i: int: 5`, `ptr: @: 0` при неизвестной голове — понижение L3 не
строит. Элемент тела, который есть применение ресивера значения или типа (`int`, `char`, `size_t`, `unsigned`,
`ulong`, `@`) не к имени места, отказывает в `lm_compiler_take_ns_body` на месте применения: «a receiver applied to
a value declares no place, and a Structure declared with it inside is not lowered yet…», сообщение называет форму,
объявляющую место. Зарезервированное `var` с данными, записанными полями (`var: (int: n 3)`), под это правило не
подпадает. Чистый граф такое объявление исполняет.

Проверки среза 351: девять новых строк набора — `composed_declares_structure` и `typed_value_write` дают 7 нативно
и под обходчиком, обоими исполнителями корня; семь фикстур отказа (`composed_value_refused`,
`composed_value_method_refused`, `composed_field_refused`, `composed_reference_refused`, `composed_known_refused`,
`composed_known_root_refused`, `merge_named_field_refused`) отказывают названным сообщением на названном месте.
Мутант — прежнее чтение возвращено в обоих читателях — роняет `composed_declares_structure` («unknown field path
segment» на `box\time`), три формы при неизвестной голове снова делает местом, а две при известном месте
транслирует как запись (выход 6 и 8). Полный набор — `SUITE 158 rows, 0 failures`, 1216 PASS. Первый прогон дал 6
отказов в трёх фикстурах: отказ пункта о применении ресивера был шире нормы и ловил данные `var`, записанные
полями; условие сужено до ресиверов, объявляющих поле, кортеж пересобран. Из 220 программ прошлого среза у 210 L1
побайтно прежний; у двух (`whole_arguments`) отличается только имя вынесенного `merge` со смещением в тексте; у
двух (`explicit_data_var_field`) — одна строка таблицы имён: слово головы `cell` стало словом `int`; у шести
(`free_c_abi`, `free_c_pointer`, `free_value_consumers`) таблица указательных типов стала короче на одну-две
неиспользуемые записи и коды следующих типов сдвинулись. Причина последнего: вопрос «слово типа?»
(`lm_compiler_prim_type_word`) для слова двери `c.` заводит указательный тип побочным действием; прежде его
задавали голове единственного Frame в хвосте любой формы (`return: c.f(x)`), теперь — только в хвосте оператора `:=`
и формы ресивера. `bootstrap quick` — 0 отказов, поколения совпадают; `l1trans`, `driver.o` и транслятор графа прежние,
инструмент — другой (список экспорта frontend стал короче на одно имя).

[Срез 352](../steps/witnesses/receiver-check-20261111/notes.md) сделал в рабочем frontend шаг 4
[раздела M9 плана](../next_core_tasks_v3.md#m9) — одноаргументные формы ресиверов примитивов (`int`, `char`,
`size_t`, `unsigned`, `ulong`). Форма с именем (`int: i`) и её повтор исполнялись и прежде. Добавлены два понижения
по форме записи, оба в `l2_frontend_core.lm2`.

Оператор-проверка (`lm_compiler_receiver_check_lower`). Ресивер примитива, применённый к значению и стоящий
оператором в теле метода или в корне — `int: 5`, `int: bump()`, `int: (2 + 3)`, — проверяет значение: оно вычисляется
один раз, принимается типом ресивера и не сохраняется. Оператор становится объявлением места с именем из
пространства транслятора (`l2_check_<часть>_<смещение>` — одно на место в тексте программы), которое принимает
значение, как всякое объявленное место; проверка, понижение и обходчик читают его как объявление. Перезапись стоит в
двух проходах по операторам — сборе мест (`lm_compiler_collect_asgn_body`) и сборе строк объявлений
(`lm_compiler_collect_decls`) — и повторно не срабатывает: переписанный оператор уже объявление.

Литерал вне типа (`lm_compiler_receiver_literal_lower`). В принимающей позиции у литерала своего типа нет: он берёт
тип места, и литерал, который в место не помещается, отказывает при трансляции. В форме `ресивер: литерал` место —
сам ресивер, а форма и есть проверка, поэтому такой литерал получает тип, который его вмещает, — `int`, иначе
`size_t`, — той же формой: `int: 4294967296U` читается как `int: size_t: 4294967296U`. Внешний ресивер принимает
число другого типа, а это `convert` при исполнении, который принимает `catch: convert ()`, — как при значении другого
типа из переменной. Перезапись делает обход форм, говорящих о себе записью (`lm_compiler_place_write_walk`), до
того, как что-либо читается по смыслу; решение «помещается ли литерал» вынесено из
`lm_compiler_check_literal_kind` в `lm_compiler_literal_kind_fits` и у обоих одно.

Пределы: литерал, который не вмещает ни один числовой тип трансляции (`int: 342348523485629384569384`), отказывает
при трансляции — значения, которое можно принять при исполнении, у него нет; объявление с литералом вне диапазона
(`int: x 4294967296U`) отказывает при трансляции, как прежде; в теле именованной Structure форма со значением — не
оператор, а значение внутри Structure, и отказывает пределом среза 351.

Проверки среза 352: четыре новые строки набора — `receiver_check_statement` и `receiver_literal_range` дают 7 нативно
и под обходчиком, обоими исполнителями корня; `receiver_literal_unrepresentable_refused` и
`receiver_check_structure_refused` отказывают названным сообщением на названном месте. Мутант — обе перезаписи
выключены — не транслирует `receiver_check_statement` («unsupported body» на `int: 5`) и `receiver_literal_range`
(«literal not representable as int»), а третью фикстуру отказывает другим сообщением. Полный набор —
`SUITE 162 rows, 0 failures`, 1240 PASS; L1 всех 224 программ прошлого среза побайтно прежний. `bootstrap quick` — 0
отказов, поколения совпадают; `l1trans`, `driver.o` и транслятор графа прежние, инструмент — другой (список экспорта
frontend стал длиннее на одно имя).

Повтор объявления ресивером в коде своего механизма не имеет: это внеочередная проверка типа с присваиванием, второго
поля не возникает; в данных повторное объявление — ещё одно вхождение имени: прежнего оно не заменяет и в него не
пишет, а имя после него адресуется только с индексом вхождения (уточнение автора 2026-11-11,
[журнал](../LMX_blog/2026-11-11.md#repeat-is-check-and-assignment), и его решение о ролях того же дня; книга —
[структурные формы](LMX_semantics.ru.md#forms-declare-or-call), [имена и пути](LMX_semantics.ru.md#fields)). Оба
транслятора измерены по этому уточнению в том же свидетельстве; найденные расхождения реализации записаны шагом 5
[раздела M9 плана](../next_core_tasks_v3.md#m9) и перенесены в шаги 5 и 8 [раздела M11](../next_core_tasks_v3.md#m11):
рабочий frontend при повторе в явной `var` метода молча читает первое вхождение; чистый граф не записывал место при
повторе в корне, а по голому пути до среза 355 выбирал первое вхождение и не строил путь с индексом вхождения (последние
два снял срез 355, подшаг 5а). Корень единицы
запускается как Structure над самой собой, и обращение без индекса к переменной, объявленной в нём дважды, отказывает
(чтение исполнителя — [ответы](../LMX_blog/q/fable-self-answers-20261110.md), Р6 и Р11).

[Срез 353](../steps/witnesses/call-receivers-20261111/notes.md) исполнил в чистом графе решение автора 2026-11-11 о
запуске кода над данными ([журнал](../LMX_blog/2026-11-11.md#call-receivers); книга —
[ресиверы `call` и `fncall`](LMX_semantics.ru.md#call-receivers); шаги 1–5 [раздела M10
плана](../next_core_tasks_v3.md#m10)). Рабочий frontend новых форм не читает и одноаргументный `call` читает
по-прежнему; имя, употреблённое раньше строки своего объявления, он по прежнему правилу книги отвергает.

Текущий запуск получает actuals отдельно от описания входов data. Ресивер и обычный вызов
сходятся к одному кадру и исполнителю; args не читается как Structure формалов.
Обязательная миграция прежних LmxGraphFrame/work_open_parts — [M10 совместно с M14](../next_core_tasks_v3.md#m10).
Исторические изменения модели мест367 описаны в [свидетельстве](../steps/witnesses/m11-ordinary-model-20261113/notes.md).
Продолжение среза 368 заменяет запуск собственных данных отдельным проходом их корневых
реализованных ресиверов объявления в том же кадре (`lmx_graph_data_run`). Прочие поля, включая
присваивания, test, data, if и вложенные Structure, остаются данными. После вычисляемого
инициализатора рабочая строка заново связывает опубликованную ячейку для следующего чтения.
Обычная запись data()/data(D) теперь использует общий resolve/launch/binder в runtime и native-эмиттере.
Конструктор готовит написанные fn/sub в своих data и code; общий читатель binding_value
возвращает существующий метод с проверкой его исходного родителя, не меняя поле исходного графа.
Подтверждён уникальный написанный метод данных по имени и пути. На рубеже 368 повторные методы с индексом,
ссылочные места и вычисляемые fn/sub в данных, root/self и M14 оставались открытыми;
[проверки и границы](../steps/witnesses/m11-data-roles-20261113/notes.md).
Срез 369 добавляет рабочие значения поддержанных ссылок на int и Structure, общий preflight
known_place и ссылочный writer; known_int остаётся числовым. Собственный кодовый @ пишет место data,
а его implicit own получает настоящий uninit:T со стабильными slot/wrapper/typed-cell.
Рабочий снимок и опубликованная ячейка раздельны: dirty публикуется в стандартных точках,
после вложенного вызова чистый внешний снимок сохраняется. Ожидаемый вид модельного места
сохраняется один раз в expected_kind строки карты; другая data не меняет его тип по RHS.
Native выпускает одну RHS-ветвь для фиксированного вида собственного места метода, сохраняя
тот же preflight и guard; остальные места динамические. API graph68/run52 и поле контракта Work
созданы штатными заголовками. Полный bootstrap quick построил настоящие G1/G2, по 9 smoke-строк; 13 проверок и 614 входов прошли. Настоящий G2/graph повторил 9 случаев в трёх режимах, весь mutation и 6 AFTER-сравнений;
[проверки и оставшиеся задачи](../steps/witnesses/m11-reference-work-20261113/notes.md).
Срез 370 допускает вычисляемые fn/sub в корне собственной data текущего кадра теми же binder/make.
Готовый метод выбирается из прежних Space.rows по owner и parent исходного объявления; его
вычисленное имя доступно по пути, повторный запуск в том же обходе сохраняет его данные.
Если имя локального объявления ещё неизвестно, временный binding_open прежнего кадра отличает
незаконченное связывание от отсутствующего free input. Известные внешние значения удерживаются
на входе; новый local сразу перекрывает entry fallback, в том числе в следующем initializer.
После ordered data оставшийся отсутствующий вход отказывает до body; внешний источник повторно
не читается. В закрытой области отказ по-прежнему предшествует data-initializers.
Native выбирает цель вызова в живом кадре и проверяет результат до аргументов, а не считает
лексический запасной источник окончательным. Возможный entry-снимок неоднозначного аргумента
живёт в прежней строке кадра, но становится входом для дочерних вызовов только при фактическом
потреблении владельцем. Проверка формы его не потребляет. Выбранный по живому контракту режим
чтения хранится в хвосте временной карты вызова и одинаково используется native и обходчиком.
Пустая или частичная whole-Structure сохраняет общий binder/defaults; группы P0 остаются целыми.
Source08:624 входа,19 случаев в трёх режимах, AFTER12 и mutation прошли; полный bootstrap03
quick G1/G2, по9 smoke, fixedpoint13 и повтор на настоящем G2/graph прошли.
Штатные генерация семантики и docs check прошли:35/14/27/44/615, LF27224; diff --check чист.
Вычисляемые объявления в code/inline, root/self и весь M11 ещё открыты;
[проверки и границы](../steps/witnesses/m11-computed-data-20261113/notes.md).
Срез371 обобщает поиск созданного fn/sub до fn_result() с прежними owner/name/parent:
описание функции без тела остаётся доступным по имени, а method() требуется лишь при вызове.
Это сохраняет отсутствие code, без создания искусственного пустого тела. Подготовительные
merge-держатели и ссылки оставшихся фикстур перенесены в own data; полный дамп результатов
сохраняют конечные readouts. Source02:626 входов;15 случаев в трёх режимах, AFTER6/mutation,
полный bootstrap01 G1/G2, fixedpoint13 и настоящий G2/graph прошли. Штатные render/docs check
прошли:35/14/27/44/615, LF27241; diff --check чист;
[изменение и проверки](../steps/witnesses/m11-own-merge-references-20261113/notes.md).
Формалы, тело и результат исполняющийся код читает из кадра
(`lmx_graph_activation_args`, `lmx_graph_method_run`, `lmx_graph_launch_result`), а не из Structure метода;
активация без кадра отвечает по Structure, как прежде. Обычный вызов `f(x)` идёт поэтому тем же путём, что запуск,
которому части поданы.

Ресиверы используют [шесть действующих форм](LMX_semantics.ru.md#call-receivers).
args — поданные значения; data — описание входов, return — описание результата, code — тело.
Сокращения подставляют отсутствие actuals и code как data, не дочернюю data callable.
Обычный вызов и запуск по частям должны пользоваться едиными binding/admission/frame/result;
отдельный путь callable без args и прежний int-only результат заменяются в M10/M14.
Готовность старого launch не означает приёмки новой модели.
[Проверки353](../steps/witnesses/call-receivers-20261111/notes.md) остаются историческим свидетельством.

[Срез354](../steps/witnesses/data-code-names-order-20261111/notes.md) менял имена на data/code
и порядок двухаргументного call на data перед code. Эти решения сохраняются.
Текущий callable содержит единую data, return при наличии результата и code;
args у ресиверов запуска содержит фактические значения. Исторические имена полей
внутренних C/L2-процедур не задают дополнительного языкового контракта.

Проверки среза 354: в 60 отслеживаемых файлах `tests/graph` (44 исходника и 16 ожиданий) `var` → `data`,
`body` → `code` (в `merge_arguments` имя `body` — переменная и осталось); переставлены 18 двухаргументных строк
`call` в 11 фикстурах и те же строки в шести ожиданиях; имена файлов `call_var_not_selected`, `code_data_no_var`,
`var_copy_nesting` прежние. Четыре новые отрицательные фикстуры: `former_var_part` (`f\var\x`, ответ 3),
`former_body_part` (`body := …` в записи `fn`, ответ 5), `former_var_block` (блок `var:`, ответ 3), `former_call_order`
(`call: Code Data`, ответ 3). Graph-check — `CHECKS 113 lines, 0 failed`, 339 `PASS` в трёх режимах; `bootstrap
quick` — 0 отказов, G1 и G2 собраны и испытаны; полный набор рабочего frontend — `SUITE 162 rows, 0 failures`, 1240
`PASS`. Мутант «принято прежнее слово `var`» роняет 3 строки из 3, мутант «прежний порядок аргументов» — 4 из 4; в
обоих списках каждая строка отказывает во всех трёх режимах. Рабочий frontend и его фикстуры (`tests/dyn`,
`tests/os_twins`) читают прежние `var`, `body` и `call: code data` — шаг 8; чистый граф по-прежнему объявляет Structure
при обходе корня — шаг 5, а связывание атома в момент исполнения объявления и замену содержимого при повторе снял
срез 355 (подшаг 5а).

[Срез 355](../steps/witnesses/data-registry-atom-20261111/notes.md) исполнил в чистом графе реестр данных,
атом-указатель без раскрытия и видимость в данных в обе стороны (подшаг 5а
[раздела M11 плана](../next_core_tasks_v3.md#m11); решения автора 2026-11-11 —
[упоминание не раскрывается](../LMX_blog/2026-11-11.md#known-name-not-expanded),
[повтор объявления](../LMX_blog/2026-11-11.md#repeat-is-check-and-assignment),
[роли `data` и `code`](../LMX_blog/2026-11-11.md#data-code-roles),
[дерево парсера не раскрывается](../LMX_blog/2026-11-11.md#parser-tree-not-expanded); чтения исполнителя — Р12–Р15 и Р19
в [ответах](../LMX_blog/q/fable-self-answers-20261110.md)). Реестр данных — `lmx_graph_data_find`: записи
уровня данных, объявляющие имя, читаются целиком при каждом обращении, таблицы нет; одна запись отвечает, при двух и
больше имя без индекса не отвечает (ответ 3), вхождение выбирает путь `s\[N]имя`; строковое кодирование шага среза355
заменено в срезе388 описанным ниже структурным представлением. Шаг пути и атом — `lmx_graph_step`,
`lmx_graph_step_place` (экспорт ядра, 43 имени) и `lmx_graph_atom_target`: атом хвоста объявления при объявлении не
связывается и слот не переписывается, а имя атома ищется, когда путь идёт через него, — лексически от держателя наружу,
уровнями целиком; запись через атом пишет названное место; замена содержимого при повторе объявления снята. Места и
Structure корня отвечают выше и ниже своей строки, `data` в корне, исполняемом над собой, — сам корень. Вычисляемое
объявление поданных данных не исполняется (`lmx_graph_data_realize` снята, Р12): его место без значения, чтение до
значения отвечает 5. Печать графа несёт путь: Structure, встреченная на нём снова, печатается именем.

**Изменение реализации в срезе388, без изменения нормы выбора вхождения.** Внешний path сохраняет три поля
`[owner, WORD("\\"), step]`. Occurrence step — обычная анонимная пара
`[WORD(decimal digits), WORD(canonical name)]`; обычный WORD всегда обозначает буквальное имя, включая `[0]x`.
Общий `lmx_graph_occurrence` (Graph74) читает эту пару без вычисления её полей, проверяет переполнение `size_t`
до умножения на 10 и оставляет выходные параметры нетронутыми при недопустимом unit.
`lmx_graph_step` и `lmx_graph_step_place` принимают raw step; чтение, запись, `lmx_graph_admit_path` и native
используют тот же reader и прежний реестр данных. Нового тега, реестра или parser flag нет.
Compact selector повторно потребляется существующими P0 и построителем выражений вместо отдельного split по bytes;
общий `lm_p0_scan_head` и compact-piece reader используют прежний `lm_p0_scan_quoted`, сохраняя границы
exact root, quoted-компонентов и doubled backticks. Глобальная `lm_p0_is_quoted_token_boundary` не менялась.

Проверки среза 355: 17 новых и 6 изменённых фикстур `tests/graph` (перечень — в
[свидетельстве](../steps/witnesses/data-registry-atom-20261111/notes.md)), в `inputs.list` 499 входов. Graph-check —
`CHECKS 130 lines, 0 failed`, 390 `PASS` в трёх режимах; `bootstrap quick` — 0 отказов, G1 и G2 собраны и испытаны;
полный набор рабочего frontend — `SUITE 162 rows, 0 failures`, 1240 `PASS`. Шесть мутантов убиты во всех трёх режимах.
Пределы: ответ 5 «место без значения» дают только строки запуска, а в корне единицы без кадра чтение имени выше его
вычисляемого объявления отвечает 3 («корень как запуск с кадром» вынесен в подшаг после 5г); чтение места без начального
значения (`int: z`) по-прежнему даёт 0; запись с головой — именем места того же уровня не считается вхождением и в пути
(подшаг 5д); `Имя: merge(...)` по-прежнему объявляет держателя результата структурной записью (перевод в
`@: R merge(...)` — подшаг 5в); дамп раскрывает ссылку на Structure, родитель которой — не держатель (результаты `merge`), а печать такой ссылки именем — отдельная правка. Рабочий frontend этих правил не исполняет — шаг 8.

[Срез 356](../steps/witnesses/callable-data-launch-by-name-20261111/notes.md) исполнил в чистом графе первую часть
подшага 5б [раздела M11 плана](../next_core_tasks_v3.md#m11): запуск Structure по имени, один связыватель форм и
видимость из кода частей вызываемого и Structure данных запуска (решения автора 2026-11-11 —
[запуск по имени](../LMX_blog/2026-11-11.md#structure-call-by-name),
[части вызываемого видят друг друга](../LMX_blog/2026-11-11.md#callable-parts-visibility),
[роли `data` и `code`](../LMX_blog/2026-11-11.md#data-code-roles),
[`data` перед `code`](../LMX_blog/2026-11-11.md#data-before-code); чтения исполнителя — Р16 и Р20–Р23 в
[ответах](../LMX_blog/q/fable-self-answers-20261110.md)). Запись с головой — обычной Structure запускает её в коде
вызываемого и в коде над поданными данными (`lmx_graph_launch_head`, `lmx_graph_eval_launch_record`): `S()` — над собой,
`S(D)` и `S(data := D)` — над `D`; голова — место со ссылкой на обычную Structure запускает её везде, корень включая;
голова — место числа — ответ 8; нет формы (два позиционных аргумента, аргумент другого имени) и запись запуска на месте
операнда — 5. Один связыватель (`lmx_graph_receiver_form_of`) выбирает форму `call`, `fncall` и записи запуска по
написанным фактическим — по позиции или по имени через `:=` — до вычисления любого из них; выпускаемый код связывает
запись при трансляции (`lmx_graph_launch_formals` — экспорт; в списке экспорта интерпретатора 45 имён).
Части вызываемого — data/code/return; args передаёт фактические значения запуска.
Structure данных запуска находит реестр
данных запуска (`lmx_graph_data_find`): имя ищется по строкам кадра, формалам, реестру данных запуска и лексическим
уровням (Р20), Structure отвечает ссылкой, экземпляр один.

Проверки среза 356: 21 новая и одна переписанная фикстура `tests/graph` (перечень — в
[свидетельстве](../steps/witnesses/callable-data-launch-by-name-20261111/notes.md)), в `inputs.list` 536 входов.
Graph-check — `CHECKS 151 lines, 0 failed`, 453 `PASS` в трёх режимах; `bootstrap quick` — 0 отказов, G1 и G2 собраны и
испытаны; полный набор рабочего frontend — `SUITE 162 rows, 0 failures`, 1240 `PASS`. Семь мутантов убиты. Пределы того среза (история): до
подшага 5г корень единицы и Structure над собой роль кода у записи с головой — обычной Structure по имени не исполняют:
`S()` в корне рядом с объявлением `S` остаётся ещё одним вхождением имени (`struct_root_declares`, ответ 3; это
состояние реализации, а не правило — Р22); `data()` в коде пропускается, слова `node` чистый граф не знает, а
многострочная часть `data` в скобках с блоком `end:` читается с лишней записью `end: Имя` — это вторая часть подшага 5б;
P0 разворачивает единственную Structure в скобках в хвост записи, как в `Add((int: v 7))` (долг раздела M8); подачу
головой у частей `fn` и `sub` снимает подшаг 5е; слово ресивера `call` или `fncall` на месте операнда находит строку контракта, как прежде `fn` (состояние реализации, Р23); голова — пустая ссылка (ответ 8 по Р22) фикстурой не показана: `@: p 0` отвечает 4, `@: p` — 5 на своей строке. Рабочий frontend этих правил не исполняет — шаг 8.

Решение автора 2026-11-11 о ролях `data` и `code` ([журнал](../LMX_blog/2026-11-11.md#data-code-roles); книга —
[роли `data` и `code`](LMX_semantics.ru.md#data-code-roles); [раздел M11 плана](../next_core_tasks_v3.md#m11))
чистый граф исполняет пока частично: имена и порядок (срез 354, шаг 4 раздела M11) — части вызываемого называются
`data` и `code`, двухаргументный `call` — `call: data code`; подшаг 5а (срез 355) — данные читаются целиком, реестр
данных, атом-указатель без раскрытия, повтор объявления не заменяет прежнее, видимость в данных в обе стороны; первую
часть подшага 5б (срез 356) — запуск Structure по имени и именованную подачу аргументов у `call` и `fncall`. Остальное
ни одним путём трансляции ещё не исполнено, а рабочий frontend не читает и этого. Для чистого графа решение означает
следующее. Данные читаются целиком до
кода, и реестр их корневых записей — объявления Structure по голове и объявления ресиверами мест по объявленному
имени — известен до первого оператора кода; обход кода ничего не объявляет, кроме вызываемых. В коде всякая запись —
вызов: объявление ресивером — проверка типа с присваиванием в место данных, структурная запись — вызов своей головы:
вызываемого — вызов метода, обычной Structure — её запуск по имени
([журнал](../LMX_blog/2026-11-11.md#structure-call-by-name)); ошибка — когда голова не называет ни вызываемого, ни
Structure. Повторное объявление в данных — ещё одно вхождение имени: прежнего оно не заменяет и
в него не пишет, и имя после него адресуется только с индексом вхождения. Слева от `:=` стоит место примитива или
указатель-переменная: имена Structure и функций не присваиваются. Аргументы вызовов и ресиверов читаются как код:
`f(arg: v)` вызывает `arg`, именованный аргумент подаёт только `:=`, формалы объявляют ресиверы (`int: arg default`,
`@: arg Template`). Запись запуска Structure на месте, где нужно значение (операнд выражения, фактический аргумент
вызова, начальное значение, операнд `merge`), ошибочна: у запуска результата нет (чтение исполнителя —
[ответы](../LMX_blog/q/fable-self-answers-20261110.md), Р22, пункт 3; Р25, пункт 4). Имя формы
`Имя: merge(...)` результата не получает: в коде это вызов `Имя`, в данных —
объявление Structure с записью вызова `merge` внутри, которая там не исполняется; результат держит
указатель-переменная, `@: имя merge(...)` (чтение исполнителя —
[закрытые вопросы](../LMX_blog/q/colon-declares-answered-20261111.md), П4). Слова состояния
`var` и `body` и имена формалов в контрактах ресиверов `fn` и `sub` называются `data` и `code` (чистый граф читает
эти имена со среза 354). Допуск `implements`
выполняется одним проходом при построении графа; вызовы допуска при исполнении остаются только для случаев
[документа](../steps/implements-runtime-cases-20261111.md). В срезе 372 удалены прежние
`lmx_graph_space_reach`, `lmx_graph_root_declares` и `lmx_graph_root_declare`: запись с именованной головой
в корне и над собой доходит до общего разрешения и запуска. Сохранённая анонимная Structure отдельным оператором
не исполняется; тело кода выбирает принимающий ресивер. Это ещё не полный перенос M11: корневые числовые/ссылочные
публикации, вызов по голове-пути, остальные формы 5д–5е и перенос допуска M11.7 остаются открытыми. Выбор между вызовом, объявлением Structure и присваиванием по
голове и хвосту формы решение делает ненужным — его задаёт роль; снятие этих ветвей — шаг 6 раздела M11.

Ответы автора того же дня на вопросы П3, П6 и П7 эту норму дополнили
([упоминание не раскрывается](../LMX_blog/2026-11-11.md#known-name-not-expanded),
[`data` перед `code`](../LMX_blog/2026-11-11.md#data-before-code),
[у Structure над собой своих правил нет](../LMX_blog/2026-11-11.md#self-launch-no-own-rules); книга —
[объявление формой с двоеточием](LMX_semantics.ru.md#colon-declares) и
[видимость](LMX_semantics.ru.md#declaration-visibility)); вопросы закрыты
([закрытые](../LMX_blog/q/colon-declares-answered-20261111.md)). Упоминание известной Structure не раскрывается ни
парсером, ни построителем: в `Struct1: Struct2` под `Struct1` в дереве стоит один атом — указатель на `Struct2`,
неизменяемый по имени; ссылаться на неё он начинает при интерпретации и трансляции, путь через него продолжается в
её поля, а `parent` самой `Struct2` — её место в дереве — не меняется; слот атома переписывается по индексу
(`Struct1[0] := …`), изменяемую ссылку объявляет ресивер (`Model: @: ptr knownModel`). Дамп печатает дерево — атом,
а не указуемое (чтение исполнителя — [ответы](../LMX_blog/q/fable-self-answers-20261110.md), Р2). Видимость именованных Structure и callable
остаётся двусторонней; переменные и const видны последовательно по M14 от2026-11-15.
Замкнутые ссылки на именованные Structure не ошибка. Данные стоят перед кодом в каждой записи: двухаргументный
запуск — `call: data code`. У Structure, запущенной над самой собой, — `call(code)` и корень единицы —
своих правил нет: её записи читаются по обеим ролям общими правилами, неопределённость — ошибка; структурная запись,
до которой дошло исполнение, ошибочна, если её голова не называет ни вызываемого, ни Structure; блок данных внутри
исполняемой Structure — такая же запись, вызов с её собственным хвостом на месте аргумента (абзацы ниже), и поэтому
объявления Structure пишут в данных, а данные и код — раздельно (чтение исполнителя — те же ответы, часть Р). Чистый
граф и здесь пока делает иначе: запись обычной Structure в исполняемом корне не запускает по имени (абзацы ниже) и ей
не отказывает, а объявляет её там, где обход до неё дошёл (§6.1), дочерний блок `data` исполняемой Structure
пропускает. Остальное исполнение — шаг 5 раздела M11 (имена и порядок `call` исполнены шагом 4, подшаг 5а — срезом 355,
первая часть подшага 5б — срезом 356; остаются подшаг 5в и остатки подшагов 5б, 5г, 5д и 5е), в рабочем frontend — шаг 8.

Решение автора 2026-11-11 о запуске Structure по имени ([журнал](../LMX_blog/2026-11-11.md#structure-call-by-name);
чтение исполнителя — [ответы](../LMX_blog/q/fable-self-answers-20261110.md), Р21) изменило эту норму для записи с
головой — обычной Structure (до решения такая запись в коде отказывала, а обычную Structure исполнял только ресивер
`call`). В коде такая запись запускает эту Structure: `S()` — то же, что `call(S, S)` (Structure над самой собой),
`S(D)` — то же, что `call(D, S)` (Structure над поданными данными `D`); так же короткая форма `S: D` и блочная. Это
самостоятельная запись запуска, а не форма ресивера: ресиверы `call` и `fncall` остаются общим механизмом
([ресиверы `call` и `fncall`](LMX_semantics.ru.md#call-receivers)): фактические значения подаёт args,
входные места описывает data. Краткая запись S(D) имеет только аргумент data; явный call принимает и args. Аргумент записи один и называется `data` — тем же именем, которым исполняемый код
называет данные своего запуска ([особое имя `data`](LMX_semantics.ru.md#ordinary-var)); он подаётся позиционно или по
имени, `S(D)` и `S(data := D)` — одна запись, так же как у ресиверов, чьи аргументы именованные и подаются по позиции
или по имени (`call(data := D; code := C)`); другое имя аргумента и два и более позиционных аргумента — ошибка;
аргумент `data` должен давать Structure (имя, путь, место-ссылка, написанная в скобках безымянная Structure), иное —
ошибка. Голова — место со ссылкой: вызывается то, на что ссылка указывает, — вызываемое или Structure; место числа,
пустая ссылка и неизвестное имя — ошибка. В данных ничего не меняется: `S()` по-прежнему объявляет пустую Structure
`S`, а `S(D)` — Structure `S` с атомом `D`; ничего не вызывается.

В корне единицы и в Structure над самой собой каждая запись читается по обеим ролям, поэтому `S()` там — сразу
объявление ещё одной `S` и вызов: если `S` объявлена в той же Structure, у имени два вхождения, без индекса оно не
отвечает, и вызов отказывает; если `S` объявлена снаружи, запись объявляет собственную пустую `S`, и запускается она, а
не внешняя; особого правила для этого нет, а ту же Structure там запускает ресивер `call`. Объявление Structure среди
исполняемых записей по-прежнему, как правило, ошибочно, но по другой причине: в коде такая запись — вызов объявленной
Structure с её собственным хвостом на месте аргумента, и два и более поля в хвосте — не определённое число аргументов
(аргумент один, `data`); одно поле — данные запуска, оно должно давать Structure. Не отказывают вырожденные записи:
пустой хвост, единственный атом, называющий Structure, единственная безымянная Structure в скобках. Объявления
Structure по-прежнему пишут в данных. `data()` в коде — запуск данных текущего запуска над ними же. Чистый граф со среза
356 исполняет запись запуска Structure по имени в коде метода и в коде над поданными данными — `S()`, `S(D)`,
`S(data := D)` — и запись с головой — местом со ссылкой на обычную Structure везде, включая корень единицы, а также
именованную подачу аргументов у `call` и `fncall` (первая часть подшага 5б). Срез 372 снимает прежний пропуск
именованной головы в корне и над собой; частная приёмка и оставшиеся границы 5г указаны в начале документа
и в §6.1. Рабочий
frontend читает прежние имена и порядок и запуска по имени не исполняет (шаг 8).

<a id="principles"></a>
## 1. Принципы (норма)

1. **Lmx-структур достаточно для описания всего**, в том числе выражений, методов и массивов. Программа, её данные и её
   текущее состояние — один Lmx-граф; второго AST, графа данных, «подготовленного» результата транслятора или скрытой
   копии исходника нет ([L2 §2.1](L2_spec_ru.md#interpretable-tree)). «У нас все — просто структура» (автор 18:18Z):
   код и данные — одни и те же Lmx; роль — данные или код — задаёт запуск, а не вид памяти и не сама Structure
   (решение автора 2026-11-11, [книга](LMX_semantics.ru.md#data-code-roles)).
2. **Все проверки — по адресам в арене; адреса не меняются** (автор 18:02Z: «все верификации производим по адресам в
   арене, и имя тоже сравниваем по адрресу его в арене. Адреса не меняются»). Любая проверка — типа, вида, имени,
   соответствия, допуска — опирается на адрес примитива, Lmx или строки в типизированной арене: по адресу известен объект
   (§2.1, §5.1). Имя сравнивается по адресу единственной переиспользуемой строки этого написания (§4) — не байтами, не
   хешем, не инкрементальным кодом. Адреса существующих ячеек и строк не перемещаются; рост и присоединение участков их
   сохраняют (§2.3).
3. **Единственная не-структура — примитив** (автор 17:22Z; термин — 18:20Z: «Это надо называть не атом а примитив. Атом
   это понятие парсера»). `int: i 5` кладётся как примитив: типизированная ячейка арены со значением 5. По её адресу
   известно всё: **тип** — из кода в записи по этому адресу (решение автора 2026-11-16, §2.0; до него — из
   типизированного участка, в котором лежал адрес); **имя** — из
   таблицы адрес → name; **значение** — чтением самой ячейки. Никаких обёрток, листов, «вхождений» и иных сущностей между
   полем содержащей Lmx и примитивом; поле Lmx — ячейка `void *`, ссылающаяся на саму ячейку примитива или на Lmx (§3.1).
4. **Единый механизм неинициализированных примитивов во всех структурах и в сигнатуре** (автор 18:00Z и 18:10Z). Для
   каждого примитивного типа T есть отдельный тип «T без инициализации», различимый тем же механизмом — по участку, в
   котором лежит адрес (с 2026-11-16 — по коду записи, §2.0). Автор 19:02Z: «Сделайте тип "int без инициализации" указателем на ту самую ячейку (массив в
   арене, указателей на такие ячейки), при этом даже отпадает необходимость менять тип при первом присваивании» —
   `uninit:T` есть **примитив-указатель** из типизированного участка указателей, указывающий на **заранее существующую**
   ячейку T с неизменным адресом и типом, ещё не записанную. С решения 2026-11-16 запись `uninit:T` держит запись T
   сразу за своим кодом: указатель из цитаты — постоянное смещение между ними (§3.2). `int: i` — поле `void *`, указывающее на такой указатель
   `uninit:int`, а тот — на ячейку `int` места `i`; `int: i 0` — поле, указывающее на ячейку `int` со значением 0
   напрямую; одно представление в коде, данных и сигнатурах, без признака, флага, битовой карты или таблицы обходчика.
   **Любое присваивание**, включая первое, пишет в **ту же** ячейку T: слот и внутренний указатель сохраняют свои
   адреса, типы и значения. Последний ответ автора на вопрос об `@i` отменил пояснение Codex о переводе слота на прямой
   адрес T. Это способ хранения, а не языковая ссылка: `i` остаётся `int`. Начальное значение не обещано; скрытого
   состояния «уже присвоено» нет. В графе сигнатуры та же форма отличает обязательный формал от умолчания.
5. **Никаких параллельных скрытых структур программы** у интерпретатора и транслятора. Служебные таблицы обхода
   («namespace» в словах автора) исполнитель устраивает как хочет, но **они нигде не хранятся вне обхода**: каждый обход
   начинает с пустых таблиц, пользуется ими и уничтожает их на любом выходе; они не лежат в графе, рядом с ним, в арене как
   обязательная подготовка, в модуле, кэше или скрытом состоянии; повторный обход после изменения графа берёт всё из его
   текущего содержания (§5.2). Таблица адрес → name (§5.1), индекс типизированных участков (§2.1) и таблица строк с её
   индексом (§4) — состояние арены и процесса, не таблицы обхода; они не смешиваются с временными таблицами обхода.
6. **Идентификаторы — переиспользуемые строки со стабильными адресами.** Написание интернируется при вводе (разбор
   текста, загрузка единицы, `sys\fromLmx`, присоединение чужого участка); дальше имя — указатель на единственную строку этого
   написания, и идентификаторы сравниваются указателями. Ни сравнения строк в исполнителе, ни отдельного числового кода как
   идентичности. В каждом процессе — единственный канонический указатель на строку написания; указатели процесса
   транслятора не равны адресам другого процесса, поэтому выпущенная единица при загрузке нормализует свои строки в
   указатели загрузившего процесса (§4, §7). **Служебные операторы и ресиверы — не исключение** (автор 18:18Z: «никакие
   служебные операторы и ресиверы при такой схеме никаких отдельных кодов не имеют!! Те же адреса строк : "for", "=", "**"
   и что угодно. У нас все -- просто структура»): `for`, `=`, `**`, `fn`, `merge` — те же строки участка `text`,
   узнаваемые по адресу; отдельных кодов операторов, ресиверов и слов языка нет — ни числом, ни видом участка памяти
   (§2.2); скрытой программы из кодов нет (§3.3, §6.2).
7. **Арена присоединяет новые куски памяти; запись несёт свой тип** (решение 2026-11-16; до него арена типизировала
   участки). Адресуемые ячейки неподвижны; для представления графа не
   нужны динамические массивы в арене: размеры известны при построении, рост — присоединением нового участка, а не
   переносом старого.
8. **Один контракт для всех:** исходник → построение чистого Lmx-графа → этот же граф потребляют **и** транслятор, **и**
   интерпретатор (§1a). В построенном графе нет ничего, кроме Lmx и примитивов: ни подготовленных интерфейсов, ни планов,
   ни данных обхода, ни сохранённых результатов разрешения имён (§3.5), в том числе замаскированных под Lmx. Дерево
   разбора P0 — внутреннее дело построителя, не обязательный вход транслятора; сохранённые таблицы транслятора — не вход
   интерпретатора.
9. **Native и интерпретатор исполняют один и тот же граф** с одной семантикой локальных кадров и прямой записи; время применения правок исполняемого графа до endturn не гарантируется
   ([L2 §10–11](L2_spec_ru.md#own)); выпущенный `native` не нуждается в именах при вызове, интерпретатор узнаёт голову по
   адресу её слова и находит места по именам через таблицы своего обхода (§5.2, §6.2).
10. **Неясное — спрашивать, не домысливать.** Вопросы идут Codex минимальным случаем; то, что Codex выносит автору,
    до ответа не реализуется, остальное продолжается. Модель автора не переоткрывается.

<a id="contract"></a>
## 1a. Единый контракт: построитель и два потребителя (норма)

```text
исходный текст ──► построитель (разбор + конструирование) ──► чистый Lmx-граф в арене
                                                                 │ примитивы, Lmx, таблица адрес → name, типизированные участки
                                                   ┌─────────────┴─────────────┐
                                             интерпретатор                 транслятор (выпуск native)
                                             обходит граф                  обходит тот же граф
```

**Построитель** — единственное место, где текст становится графом: разбор (сегодня P0) и конструирование ячеек в участках
арены-получателя, интернирование написаний (§4), заполнение таблицы адрес → name (§5.1). Его граница — готовый граф;
дерево разбора, его арены и любые рабочие данные построителя уничтожаются при выходе из построения (как данные обхода,
§5.2). Разбор и непосредственное заполнение полей сохраняют написанное имя примитивом-словом (§3.5), без скрытой
привязки будущего потребителя. Объявления `fn`/`sub` остаются такими, как написаны: F создаёт ресивер в отдельном
обходе, включая явное построение среза390 ниже (§3.4). **Потребители** —
интерпретатор (§6) и транслятор (§7) — читают один и тот же граф и ничего в нём не подготавливают друг для друга.
Транслятор выпускает native-тела и код загрузки единицы. Код загрузки — **сгенерированная инициализация того же чистого
графа**: точные ячейки в типизированных участках, их связи, строки таблицы адрес → name, ссылки `native` — через общий
низкоуровневый конструктор графа, которым пользуются и разбор, и `sys\fromLmx`, и загрузчик (решение, подтверждённое Codex
2026-11-08: это не прежние сгенерированные операции, таблицы мест и скрытые интерфейсы; исходный текст в единице не
хранится как резерв исполнения или восстановления; встраивать разбор P0 в загрузку не требуется). Native-тела связываются
с вызываемыми по адресам построенного графа. Построение из `sys\fromLmx`, `merge`, резервации ребёнка и почты — тот же
конструктор с той же границей.

**Явное построение нового графа, срез390.** В `lm_graph_build_root` эта фаза следует после заполнения всех полей P0
и перед чистым `lmx_graph_preflight`. `lmx_graph_construct` открывает собственный свежий namespace через существующий
`prior`, готовит доказанные written `fn`/`sub` общими declaring-контрактами и сохраняет допустимые известные кандидаты
как обычные значения ссылочных ячеек. На каждом выходе namespace и очереди ролей уничтожаются, прежний обход
восстанавливается; preflight, трансляция и последующее исполнение не наследуют эту таблицу и не повторяют такую
материализацию над существующим DATA. Достигнутые отложенные объявления сохраняют обычный runtime-маршрут.
Это отдельный construction walk, а не исполнение CODE или отложенных инициализаторов.

Обход различает роли данных, кода и выражений по существующим контрактам. Формалы/их умолчания, описание результата
и исходная часть DATA метода не становятся CODE; обычное пользовательское поле с именем `data` само по себе не
является DATA метода. Для уже реально созданной F, в том числе вложенной F в копии DATA внешней F, фаза рассматривает
её доказанный CODE и его текущие объявления. Это ограниченное подмножество не требует рекурсивно материализовать
CODE любого raw `fn`, лежащего в исходном DATA-blueprint, и не меняет этот blueprint. Вызовы, computed actuals,
умолчания и `test` при поиске известного кандидата не исполняются; полного покрытия M11 это не утверждает.

<a id="arena"></a>
## 2. Арена

<a id="value-record"></a>
### 2.0 Запись значения (норма: решение автора 2026-11-16)

Автор ([журнал](../LMX_blog/2026-11-16.md#typed-value-raw-layout)): физический тип и значение лежат в одной записи и
берутся из неё; типизация и извлечение значения больше не идут через проверку адресов. Точный контракт —
[L2 §3–§4](L2_spec_ru.md#value-record). Этот подраздел говорит, что он меняет в настоящем документе; датированный текст
ниже, узнающий тип «по участку, в котором лежит адрес», описывает схему до решения и нынешний код и не является
заданием продолжать тот механизм.

- **Запись.** `int type`, код физического типа, и сразу за ним сырые байты значения: число, слово, ссылка либо
  дескриптор `parent/length/storage`. Каждая ссылка графа — слот, элемент `Array<@>`, ячейка ссылки, `parent`, ключ
  таблицы адрес → name и карты копирования, корень исполнения — относится к записи. Размер записи следует из её
  кода; ничто не меряется по самому большому виду. Хранит ли ссылка адрес кода или адрес значения четырьмя байтами
  дальше — кодировка при той же записи, [вопрос автору](../LMX_blog/q/current/README.md).
- **Выравнивание.** Значение стоит по адресу, кратному `max(alignof(T), 4)`, код — в четырёх байтах вплотную перед
  ним, заполнение — между записями; запись, помещающаяся в 64 байта, не пересекает границу 64-байтового блока.
  Поэтому дескриптор внутри записи выровнен естественно, и его поля читаются по-прежнему.
- **Тип и значение без классификации адреса.** `lmx_range_classify`, `lmx_range_type_of`, `lmx_range_stride`,
  `lmx_domain_kind`, `lmx_domain_type` и построенные на них читатели (`lmx_graph_node_in`, `lmx_graph_cell_in`,
  `lmx_graph_value_in`, `lmx_walk_value_cell`, `lmx_graph_kind`, `lmx_graph_address_type`) берут вид, тип и шаг из
  кода записи. `sys\typeof` отвечает этим кодом; ноль и адрес вне арены Message дают «нет типа» проверкой нуля и
  списка кусков, без поиска по типу.
- **`uninit:T`.** Одна запись: код `uninit:T`, затем полная запись T (§3.2). Слот относится к внешней записи, имя и
  `@x` — к внутренней; указатель прежнего представления — постоянное смещение между ними.
- **Неизменяемость** сообщает код — неизменяемый вариант типа, — а не интервал участка.
- **Плотное хранение.** Элементы числового `Array<T>` и слоты Structure плотны и кодов не несут; тип элементов
  сообщает код записи Array. Типизированные native-локалы и временные значения в записи не упаковываются.
- **Куски.** Индекс интервалов сообщает только, какой арене и какому куску принадлежит адрес: передача, сбор, дом
  имени. Деление арены на куски — политика аллокатора; на первом этапе нынешние пулы сохраняются, ячейка пула
  становится записью с шагом пула. При присоединении куски донора становятся кусками получателя: записи сохраняют
  адреса и коды, для типизации ничего не регистрируется заново. К одной арене нет доступа из нескольких потоков.

Почему: на принятом G2 среза410 одно чтение слота графа штатными читателями стоит 107–170 нс при 0,35–0,53 нс у того
же цикла без вызовов ядра, одна классификация адреса — 10,6 нс при 100 интервалах и 80 нс при 10 000, а `int`,
выделенный отдельно, держит 289 байт кучи против 4 при выделении блоком
([запись исследования](../steps/witnesses/typed-value-research-20261116/notes.md)). Реализация OPEN:
[план M15](../next_core_tasks_v3.md#typed-value-records).

### 2.1 Участки (решение)

Арена Message — список **участков** (`LmxSegment`). Участок — один непрерывный блок памяти ячеек одного C-типа и одного
шага: `{ base, stride, type, count, used, next, owner }`. Тип участка — из закрытого инвентаря (§2.2). Участок никогда не
переразмещается; когда его ячейки кончились, арена присоединяет следующий участок того же типа. Адрес → тип — поиск
участка по полуоткрытому интервалу `[base, base + stride·count)`; индекс интервалов упорядочен по адресам и живёт вне
графа как состояние арены (не таблица обхода: это средство узнать тип по адресу, §1 п. 2). Нынешние
`LmxPool`/`LmxChunk`/`LmxRange` — та же идея (пул чанков одного шага, интервалы), но с профилями, ролями и боковыми
массивами (`links`, `slot_owner`, `holder`, `side_cells`), которые §9 снимает.
С решения 2026-11-16 (§2.0) интервал сообщает только владение: тип читается из записи, а участок ячеек одного типа —
нынешняя политика аллокатора, а не средство типизации.

Программе тот же ответ даёт ресивер `sys\typeof(arg)` — код типа значения по адресу, с решения 2026-11-16 читаемый из
его записи (нынешний код спрашивает участок), — а слоты Structure она
читает как массив ссылок `S[i]` (решения автора 2026-11-10: [книга](LMX_semantics.ru.md#get-type),
[журнал](../LMX_blog/2026-11-10.md)); числовые значения кодов нормой не закреплены. Ресивер реализован в чистом графе
одной операцией ядра для обоих потребителей — `lmx_graph_address_type` над `lmx_range_type_of`: Structure — адрес
своего заголовка, ссылка — адрес, который она хранит, значение `int` адресом не является, написанный ноль — нулевой
адрес ([запись](../steps/witnesses/get-type-20261110/notes.md)). Индекс Structure реализован в чистом графе
([запись](../steps/witnesses/struct-index-20261110/notes.md)): значение `S[i]` — ячейка-указатель отдельного участка
`LMX_TYPE_GRAPH_REF`, «ссылка без типа», которая держит любой адрес арены и в слотах графа не хранится; чтение —
`lmx_graph_index`, запись по временному принимающему описанию физического слота (срез380, §5.2/§6.3) — `lmx_graph_index_write`, число слотов —
`lmx_graph_length`, приём ссылки без типа местом `@: p int` — `lmx_graph_int_ref_of`; по одной операции ядра на оба
потребителя. Индекс вне полей — ответ интерпретатора 7, native и forced останавливают R0.

### 2.2 Типы записей и участков (решение; конечный перечень)

| Тип | Ячейка | Что в ней |
|---|---|---|
| `int`, `char`, `unsigned char`, `size_t`, `unsigned`, `ulong` | число машинного типа | примитив-число; `int: i 5` — ячейка `int` со значением 5 |
| `uninit:int`, `uninit:char`, `uninit:unsigned char`, `uninit:size_t`, `uninit:unsigned`, `uninit:ulong` | `void *` — указатель на ячейку T; с 2026-11-16 — сама запись T сразу за кодом (§3.2) | внутренний примитив-указатель объявления без начального значения (§1 п. 4); указывает на заранее существующую ячейку T. Сохраняется после записи и не делает место языковым указателем. В сигнатуре отличает обязательный формал от умолчания; состояние первой записи не хранит |
| `uninit:ref` | `void *` — указатель на ячейку `ref` | ссылочное место без обещанного начального адреса — `@: p` ([книга :487](LMX_semantics.ru.md#explicit-copy)); аналогия автора «для всех примитивов» прямо распространяется на ссылочный ресивер, у которого «те же формы места и значения, что у `int`» (подтверждено Codex, ревью 2) |
| `word` | `const char *` | примитив-слово: указатель на интернированную строку написания — операторы (`+`, `\`, `[]`, `:=`), слова ресиверов и языка (`fn`, `if`, `return`, `node`, `int`), любое написанное имя (§3.5) |
| `ref` | `void *` | ячейка ссылки: слот поля Lmx или элемента Array, ячейка указателя `@: p T` после первой записи адреса; хранит адрес примитива или Lmx либо 0 |
| `lmx:data`, `lmx:immutable`, `lmx:result` | `Lmx` | заголовок обычной Structure, неизменяемой Structure (`independent: immutable`) и Structure, **созданной исполнением ресивера `fn`** ([L2 §2.1](L2_spec_ru.md#interpretable-tree): пул результатов `fn` получает только структуру, созданную исполнением `fn`, не Structure с похожими частями; [§3](L2_spec_ru.md#type-by-range): обычные и неизменяемые — в разных участках, не по C-типу на модель) |
| `lmx:array<T>`, T ∈ {`int`, `char`, `unsigned char`, `size_t`, `unsigned`, `ulong`, `ref`} | `Lmx` | заголовок graph Array с требованием T к элементам ([L2 §3](L2_spec_ru.md#type-by-range): для Array диапазон указывает и тип элементов); backing — `length` элементов T, для `ref` это `void *` (§3.1) |
| `text` | `char` | байты строк: интернированные написания имён и операторов (§4), пользовательские строковые литералы |
| `name` | `{ void *address; const char *name }` | строка таблицы адрес → name (§5.1) |

Виды заголовков — конечный перечень физических видов [L2 §3](L2_spec_ru.md#type-by-range): обычная, неизменяемая, результат
`fn`, Array с типом элементов; вид читается по коду записи (§2.0; до 2026-11-16 — по участку, в котором лежал адрес самой Lmx, без тега в
заголовке и ячейке), при одной общей записи Lmx (§3.1). **Вид участка — не opcode:** определение `fn`/`sub`, оператор, выражение и
Structure данных — одинаковые Lmx обычного вида; чем является запись, читается не по участку заголовка, а по роли
Structure в запуске и по адресу слова головы (§3.3, §6.1). Служебные типы (`name`, индекс интервалов) видны арене и
исполнителям, но не являются значениями языка.
Пользовательские модели не порождают типов участков: Structure любой модели — ячейка `lmx` плюс её слоты.

### 2.3 Выделение при вводе и построении (норма + решение)

Перед трансляцией граф единицы известен целиком, поэтому выпущенная единица объявляет **точные** размеры своих участков
по типам (число ячеек `int`, `uninit:int`, `ref`, `lmx:*`, `word`, …, длину `text`) и строит граф в них без промежуточных
динамических массивов (ячейка T места без значения выделяется при построении вместе с указателем `uninit:T` на неё, §3.2).
Рост во время исполнения — `merge`, результат ресивера, `sys\fromLmx`, резервация ребёнка, присоединение почты,
исполнение объявления с инициализатором (§3.4) — берёт ячейки из текущего участка нужного типа и
присоединяет новый, когда он полон; размер нового участка — политика арены (решение; не меньше запрошенного), адреса
прежних ячеек не меняются. `lmx_arena_attach` переносит участки донора в список получателя без перемещения
([L2 §6](L2_spec_ru.md#arena)); `mark`/`revert` откатывают неудачное построение, освобождая присоединённые с метки участки
и возвращая `used` прежних.

### 2.4 Сбор (решение)

Живость — достижимость от корней ([книга §22](LMX_semantics.ru.md#memory)). Пометка — по участкам: у каждого участка
битовая карта живых ячеек на текущее поколение (служебная таблица обхода, строится проходом и выбрасывается), ячейка
ничем не помечается. Обход следует слотам ячеек `lmx` (адресу в каждой ячейке `ref` backing), ячейкам указателей,
`parent`, таблице адрес → name (строки живых адресов живут, строки мёртвых — выбрасываются). Слот сохраняет указатель
`uninit:T` после присваиваний; сбор следует через него к ячейке T. Ни первая, ни последующая запись не разрывает эту
связь. Ячейка T живёт также по отдельно взятым адресам; недостижимые ячейки собираются обычным обходом. Участок без
живых ячеек освобождается целиком; участок с живыми — остаётся, его свободные ячейки переиспользуются (решение; без
уплотнения — адреса неподвижны).

<a id="lmx"></a>
## 3. Lmx-граф

### 3.1 Запись Lmx (решение в пределах [L2 §2](L2_spec_ru.md#lmx))

```text
struct: Lmx
    @: parent Lmx        # структурный родитель, 0 у корня
    size_t: length       # число полей Structure или элементов Array
    @: storage void     # адрес хранилища элементов
```

Плоский заголовок содержит только parent/length/storage; native и capacity в нём нет.
Ссылка на Structure или Array указывает на её запись: код типа, затем этот дескриптор (§2.0). Его адрес сохраняется при
изменении размера; storage может перемещаться. Таблица арены «адрес дескриптора → capacity»
содержит резерв в элементах. Общий механизм выделения и изменения размера применяется к Structure,
Array<@>, типизированным и служебным массивам. Отдельная семья List/DynamicArray не нужна.
Стабильные отдельные ячейки примитивов и канонические строки сохраняют свой контракт;
не создавать отдельный Array на каждую ячейку.

Слот Structure или Array<@> содержит void *; числовой Array<T> хранит сами элементы T.
Адреса слотов/элементов имеют тип void **/T * и сохраняются лишь пока storage не перемещено.
Structure и Array<@> взаимозаменяемы во всех общих операциях, включая исполнение и именованные пути
при наличии имён. Различие категории само по себе не основание для отказа.

L2 [] любого конечного ранга — вычисление смещения без проверок length, знака, арены или прежнего поля;
отрицательный индекс допустим. L3 сводит соседние [i][j] к одному линейному индексу и делает одну
проверку 0 <= index < length. L3-ссылка на элемент хранит ссылку на дескриптор массива и index,
никогда адрес storage; свой тип L3-указателя на примитив использует общую типизированную основу.
L2-адрес после перемещения storage автоматически не исправляется. [Точный контракт](L2_spec_ru.md#array-capacity).
Реализация этой миграции [M13](../next_core_tasks_v3.md#flat-lmx-descriptor) остаётся OPEN.

<a id="get-descriptor"></a>
### 3.1.1 Адреса заголовка

Один явный аргумент S выбирает S; без аргумента `sys\descriptor()` / `sys\descriptor:` выбирают текущую data,
как `sys\descriptor(data)`, включая вложенные тела управления. Для code нужен явный аргумент.
Выбор выполняется общим механизмом вызова; контракт адресов результата одинаков для обоих вариантов.

Обычный ресивер `sys\descriptor: S` возвращает Structure с тремя адресами полей parent/length/storage:
Lmx **, size_t *, void **. Разыменованная запись меняет заголовок S непосредственно;
запись в поле результата меняет сам указатель результата. Запись через адрес length не выделяет память:
для согласованного изменения длины/резерва вызываются sys\resize/sys\reserve.
Ни native, ни capacity в результате нет; нет копии, прокси, write-back или отдельного opcode.
S.parent может иметь тот же числовой адрес, что S: типизированное обращение `Lmx **` адресует поле, не второй Lmx.
Получение адреса не продлевает жизнь S и не передаёт владение. Произвольные конечные глубина указателей и мерность
массивов независимы; явные пути и разыменованные записи используют общие типизированные операции, включая ссылки
и указатели на функции. Их не запрещают ограничения присваивания по голому имени Structure или функции.

Адрес `@x` переменной namespace принадлежит локальной ячейке текущего вызова. Для готового поля
`@(data\x)` сохраняет собственный адрес исходной графовой ячейки. Для вычисляемого объявления
`int: field getValue()` выражение `@(data\field)` адресует обычный результат getValue(),
не заменяя исходное объявление. Используется существующее типизированное место результата,
без второй ячейки или специального выделения ради `@`; время жизни обычное.
Типизированная ячейка готового места сохраняет адрес и тип при записи, в том числе через uninit:T;
взятие её адреса не читает незаписанный payload. Это не отменяет вычисления операнда `@`:
для вычисляемого входа `int: x next()` обращение `@x` получает значение и адрес локальной int-ячейки.
Локальную ячейку не подменять исходным полем ради прежнего поведения. [L2](L2_spec_ru.md#lowlevel-address).

<a id="header-receivers"></a>
### 3.1.2 Чтение заголовка и служебных таблиц

`parent(S)`, `length(S)`, `sys\storage(S)` читают поля заголовка напрямую.
`sys\native(S)` читает из таблиц call обычную Structure дескриптора с вариантами native либо 0;
получение дескриптора не исполняет код. `sys\capacity(S)` читает резерв из таблицы арены.
Во всех пяти формах без аргумента выбирается текущая data. Это обычные не объявляющие ресиверы;
одноимённая запись в data остаётся данными. Для простого getter не строить descriptor или прокси.
`sys\resize(S,n)` меняет length и при необходимости storage; `sys\reserve(S,n)` меняет только резерв.
Capacity не участвует в обычном индексном чтении/записи.

Имена size/data заменяются на length/storage в Lmx и его потребителях, не во всех технических структурах.
data/code остаются аргументами-Structure call; node сохраняет существующий смысл и ABI.
[Формы и правила](LMX_semantics.ru.md#header-receivers), [план M13](../next_core_tasks_v3.md#flat-lmx-descriptor).

<a id="system-indexof"></a>
### 3.1.3. Индекс поля

`sys\indexof(field parent)` возвращает физический индекс единственного вхождения `field` среди
непосредственных элементов Structure `parent`. Если поле отсутствует или та же ссылка встречается
несколько раз, операция сообщает ошибку по общим правилам отказа.

`sys\indexof(field index parent)` выбирает вхождение той же ссылки с номером `index`, считая с нуля,
и возвращает его физический индекс в `parent`. Если указанного вхождения нет, это ошибка.
Номер вхождения и возвращаемый индекс — разные величины: при вхождениях одной ссылки в позициях
2 и 5 вызов с `index = 1` возвращает 5. Обе формы получают `parent` явно; формы без аргументов нет.

Искомое поле определяется его идентичностью/ссылкой, а не совпадением имени или примитивного значения.
Поиск не следует вложенным структурам или графовым ссылкам. Для Structure и Array<@> действует один
механизм чтения непосредственных элементов. Использовать существующую адресацию; отдельная таблица
обратных индексов и её обслуживание при записях не нужны.

<a id="primitive-storage"></a>
### 3.2 Примитив (норма: автор 17:22Z, 18:00Z, 18:10Z, 18:20Z)

**Термин.** Единственная сущность графа, не являющаяся Lmx, называется **примитив**; в передачах и разделах журнала до
18:20Z она называлась «атом» — те цитаты не переписаны, термин «атом» в этом документе остаётся только за понятием парсера
(атом P0).

Примитив — одна ячейка арены вне участков `lmx:*`: число, примитив «без инициализации», слово (§2.2) или ссылка. У
примитива нет заголовка; его тип — код, стоящий в записи вплотную перед его ячейкой (§2.0; до 2026-11-16 — тип участка), имя — строка таблицы адрес → name (если примитив именован), значение —
ячейка. `int: i 5` в теле Structure `S`: ячейка `int` = 5 в участке `int`; слот `S` содержит её адрес; строка таблицы имён
`(адрес ячейки) → "i"`. Чтение `S\i`: найти слот `S`, чья ячейка именована `i` (§5.1), прочитать ячейку по её типу. Запись
`S\i := 7` пишет в ту же ячейку по обычному контракту записи ([L2 §10–11](L2_spec_ru.md#own)).

**Место без значения.** `int: x` в коде, в данных и в сигнатуре: при построении место получает свою ячейку `int` в участке
`int` (ещё не записанную; у каждого примитивного места своя ячейка — два места никогда не делят одну, литерал кода не
делится с местом) и примитив-указатель на неё в участке `uninit:int`; слот указывает на этот указатель. «Без
инициализации» — отдельный тип этого указателя, узнаваемый только по адресу (§1 п. 4); то же для каждого примитива. Это не
обещание нуля или случайного значения и не признак вне графа; книга: [:432](LMX_semantics.ru.md#construction) — без придуманного
начального значения, в сигнатуре — обязательный формал; [:123](LMX_semantics.ru.md#fields) — повтор без значения в коде
ничего не пишет и лишь проверяет контракт, а в данных он — ещё одно вхождение имени (отдельной политики повторного
объявления нет, REPEATED-DECL-OTHER-KINDS не меняется).
`int: x 0` — слот на ячейку `int` = 0 напрямую. Различие обязательного формала `int: q` и умолчания `int: q 0` — общая
адресная классификация того, на что указывает слот, без сигнатурной обёртки, маски или стороннего признака. Имя `x` —
строка таблицы для адреса ячейки `int` (она существует с построения; указатель `uninit:int` не именуется).
С решения 2026-11-16 место — одна запись: код `uninit:int`, затем запись `int` места — код `int` и ячейка; слот
относится к внешней записи, имя и `@x` — к внутренней, а указатель прежнего представления — постоянное смещение
между ними (§2.0).

**Присваивание** (`x := 5`, приём аргумента в место кадра): принимаемое значение пишется в **ту же** ячейку `int`.
Слот, внутренний указатель `uninit:int`, адрес и физический тип ячейки сохраняются с первой записи и далее; ничего
не переносится, строка имени остаётся на месте. Внутреннее разыменование — алгоритм поддержки, не оператор пользователя:
`i` остаётся `int`, и выражения/допуск аргументов работают с ним как с обычным целым. `@i` отдельно создаёт языковую
ссылку. Проверка обоими исполнителями: `int: i`; сохранить `@i` без чтения
незаписанных байтов; `i := 5`; чтение по сохранённому адресу даёт 5; `i := 7` даёт 7 по тому же адресу.

**Чтение и допуск.** Внутренний указатель прозрачен: код `uninit:T` (до 2026-11-16 — адресная классификация) определяет путь к ячейке `int`, оттуда
читается значение. Само наличие `uninit:int` не доказывает ни наличие, ни отсутствие предыдущей записи. Прежнее
пояснение Codex ревью 2 о runtime-отказе по этому признаку отменено последним уточнением автора. До записи начальное
значение не обещано; проверки не читают его и не требуют нуля, случайности или специальной ошибки. Сигнатура описывает
обязательность/умолчание и не меняется при вызове; фактические аргументы принимаются в отдельные места кадра.

**Exact scalar foundation, WIP394.** `LmxScalarABI {size, init, copy}` описывает точный доступ к C scalar object.
Один прежний exporter выбирает32 non-reference/non-opaque rows из Source35 и выпускает type aliases в generated header,
а typed init/copy и ABI records — в profile body. Это одна source-проекция; одинаковые C spellings могут разделять
access callbacks, сохраняя различные source descriptions. None/void не получают cell, FILE не получает scalar ABI.

`lmx_arena_scalar_cells_profiled` использует прежние arena/pool; `pool.scalar_abi` входит в физический ключ вместе
с type/stride/profile. ABI не является Model, а pool.profile не заменяет source identity. Полный Value хранит
`scalar_abi`, `physical_profile`, `source_type` отдельно от прежних model/references/referent. Owned FOREIGN capture
сохраняет объект в arena, не адрес локала: mutable load/materialize создаёт собственное storage, а подходящая immutable
cell сохраняет identity, полный physical type и profile. `receive_scalar` проверяет ABI; store использует protected/code
guards до typed copy. Это точный representation transport, не semantic conversion или полное runtime admission.

В срезе398 `prepare_scalar_store` выделен из той же FOREIGN-ветви общего writer: чисто проверяет физическое
место и ABI назначения, сохраняет declared SOURCE места и полный RHS Model/context. Он не выделяет storage,
не публикует payload/companion и не делает snapshot. Рабочий GraphRun отдельно создаёт owned snapshot;
физическая публикация использует прежний `cell_place/value_store` с теми же guards и typed copy.

Сырой allocator создаёт C storage с `present=0`, без current Value. Load и copy сохраняют отсутствие,
не читают source payload; GC удерживает metadata и physical pool.profile и в этом состоянии. Capture проверяет
ABI/stride уже зарегистрированного FOREIGN source до копирования. Copy отвергает ненулевой referent без найденного
физического владельца. Отображение storage на написанные L3 declarations входит в открытый construction bridge.

Общий copier/projection/qualification и GC учитывают scalar payload и cell companion с его графовыми зависимостями;
ABI record остаётся metadata generated module. Runtime11 prod/observe собран; machine unit прошёл native/forced при обычном
owner/root0/root1, включая точность FP, i64/u64 limits, несовместимый ABI, protected write/no mutation, nonzero-profile
immutable identity и copy/projection/qualification/GC. Это ограниченная unit-проверка foundation: public primitive resolver,
Run working/receiving/FFI, activation/pending Value GC roots и Foreign-Array ABI остаются обязательными OPEN работами.
Source16/Unit-machine06 также проверяет незаполненное storage и отказ capture/copy до потери владения. Whole G1/G2
quick/fixedpoint20 и G2 targeted gates PASS; полная приёмка общего bridge впереди, M13 не закрыт.

### 3.3 Выражение (норма: пример автора `x+1`)

`x + 1` — Lmx обычного вида из трёх полей: поле 0 → примитив-слово `x` (написанное имя: ячейка `word` с каноническим
указателем на строку `x`; разрешается в место при исполнении через таблицу текущего обхода, §3.5), поле 1 →
примитив-слово `+` (ячейка `word` с указателем на интернированную строку `+`; решение реализации — физическая ячейка
слова с указателем на каноническую строку, без opcode и без сущности-вхождения), поле 2 → примитив-число `1` (ячейка
`int`, принадлежащая этому выражению). Никакой типизированной записи операции (`LmxOp`), кадра с числовыми селекторами
или особого вида памяти для кода: интерпретатор узнаёт операцию, сравнив указатель слова с интернированными строками
операторов (§6.2), а типы операндов — по участкам их ячеек после разрешения имён. Frame записи `head: a b c` — Lmx,
названная своей головой (строка таблицы адрес → name для адреса этой Lmx — строка `head`), а её поля — аргументы `a`,
`b`, `c` (автор 2026-11-09: «объявление fn в дереве это именованная структура (fn ее название) с аргументами»,
[журнал](../LMX_blog/2026-11-09.md)); чем является запись, определяет потребитель при обходе, не построитель: по
норме — роль Structure в запуске (в данных запись объявляет — место, если её голова — ресивер места, иначе Structure;
в коде она вызов своей головы — вызываемого или, по решению автора 2026-11-11, обычной Structure, которую она запускает
по имени: [книга](LMX_semantics.ru.md#data-code-roles),
[журнал](../LMX_blog/2026-11-11.md#structure-call-by-name)) и общее разрешение головы кода — ресивер языка,
вызываемое или обычная Structure (§3.5); Срез 372 направляет именованную голову в общее разрешение и запуск (§6.1) также в корне
и над собой. Полная приёмка и оставшиеся корневые публикации и головы-пути ещё открыты
([раздел M11 плана](../next_core_tasks_v3.md#m11)). Операция, записанная Frame (`-(2 + 3)`, `\(p)`), остаётся
операцией, как в любом выражении: слово оператора в поле 0 и операнды, без имени; так же `x + 1`, путь и `:=`; анонимная
Structure имени не получает. Вложенная Structure тела — Lmx-ребёнок с `parent` на содержащую. Frame, записанный на
голове-пути, `owner\field: actuals`, — безымянная Lmx [путь, actuals]: выражение пути [owner, \, field] в поле 0,
которое построитель разбивает один раз, пока известны лексические границы (Codex, ревью 331; точный идентификатор в
обратных кавычках остаётся одним именем; срез 337); потребители узнают общую форму пути в поле 0
(`lmx_graph_path_head`) и читают такой оператор одинаково (`lmx_graph_eval_path_statement`,
`lm_graph_emit_path_statement`): поле он не записывает — значение по пути записывает `owner\field := value`;
известное место, не являющееся Structure, в его голове — отказ (ответ 8 интерпретатора; срез 346), остальные
чтения — вызываемое через путь, объявление Structure по пути — пока не исполняются (5). Прежде, до среза 346, такая
форма записывала место одним значением, а ещё раньше голова оставалась одним словом: в корне `Box\hits: 5` определял
новое место с именем `Box\hits`, в теле отвечал 3. Анонимное тело, чей первый оператор — голое чтение пути, за
которым идёт другой оператор, имеет ту же форму и читается этим оператором (такое чтение ничего не делает).

### 3.4 Вызываемое и namespace

<a id="call-receivers"></a>
### Ресиверы `call` и `fncall`

| Форма | Переданные значения `args` | Входные данные | Результат |
|---|---|---|---|
| `call(args data code)` | `args` | `data` | нет |
| `call(data code)` | не поданы | `data` | нет |
| `call(code)` | не поданы | `code` | нет |
| `fncall(args data return code)` | `args` | `data` | по `return` |
| `fncall(data return code)` | не поданы | `data` | по `return` |
| `fncall(return code)` | не поданы | `code` | по `return` |

`args` — Structure фактически передаваемых значений, ровно та, которая является
структурой аргументов обычного вызова. Это не объявления формалов, не сигнатура
и не отдельная часть callable. Входные места, требования и умолчания описывает `data`.
`return` — описание результата, `code` — исполняемая Structure. `call` не возвращает
значения; `fncall` возвращает результат согласно `return`.

Во всех формах без `args` дополнительных фактических значений нет. Отсутствующая
`data` означает саму `code`: `call(C)` равнозначен `call(C C)`, `fncall(R C)` —
`fncall(C R C)`. Дочернее поле `data` внутри `code` автоматически не выбирается.
Это сокращения одной операции, без обязательного создания пустой Structure
или нового служебного объекта для пропущенной `args`.

Все формы и обычные вызовы методов/Structure используют в интерпретаторе один путь:
выбор частей → связывание actuals с data → общий допуск → свежий namespace → исполнение и результат.
Приём actuals не меняет исходную data и не запускает входную инициализацию.
Вызовы из test и преобразователей проходят тот же механизм. Известные native-вызовы
из native по-прежнему могут идти прямо в C, без графовой упаковки.
[Полный контракт и именованная подача](LMX_semantics.ru.md#call-receivers).

<a id="private-binding"></a>
### Ресивер private:

`private:` исключает помеченное поле и соответствующую привязку из динамических источников
вызова. Прямая видимость откуда угодно, явные пути и обычный лексический поиск сохраняются;
правила последовательной видимости и явной передачи аргументов не меняются.
Пропуск поля следует общему порядку связывания, одинаковому для всех форм call/fncall,
обычных вызовов, интерпретатора и native. Это свойство поля, не глобальный запрет имени
и не защита доступа. Использовать общий binder без отдельного реестра или проверок прямых чтений.
[Полный контракт](LMX_semantics.ru.md#private-binding).

<a id="call-frame-20261115"></a>
Каждый вызов создаёт собственный namespace. У fn/sub/catch входы описывает единая data;
args в call/fncall содержит фактические значения. Краткие заголовки сохраняются. Actual заменяет соответствующее
исходное объявление кадра, и его инициализатор не выполняется. Подготовка собирает только корни
data/code, без обхода ветвей и графовых ссылок и без автозаполнения исходной data.

При входе нет фазы исполнения инициализаторов. Готовые объявления сворачиваются при построении
чистого графа без вызовов программы; uninit:T сохраняется. Неиспользуемое вычисляемое поле data
не выполняется. Чтение получает его значение общим механизмом, как `data\field`: исполняется
написанный RHS, а не неявный вызов полученной ссылки. Для `@: fptr getFuncPtr()` запись
`fptr("hello world")` сначала получает указатель, затем вызывает полученную функцию.

Переменные и const видны с первоначального объявления вперёд в своей области и ниже.
Двусторонняя видимость сохраняется у имён Structure и callable, но не у переменной с указателем
на функцию. Новое имя ветви не выходит наружу. Повторное `int: x bump()` сохраняет вычисление,
допуск и запись существующему x; убирается только повторная C-декларация. Физические повторы
полей сохраняются и выбираются `S\[n]x`. Явный путь не ограничивается порядком объявления
голого имени. Раннее чтение объявления через путь не отменяет его RHS при достижении строки code.

Голое x и @x относятся к месту кадра, независимому от замен исходного поля сразу после входа,
даже до первого чтения: сохраняется выбранное значение либо вычисляемое описание.
Правило одно для явной data, лексического и динамического связывания. Это не глубокое копирование
объектов по ссылкам. `x := 0` меняет namespace; `data\x := 0` — исходный граф.
Для вычисляемого входа `int: x next()` обращение @x получает значение и адрес локальной ячейки.
При `@(data\field)` и исходном `int: field getValue()` адресуется результат getValue();
в разобранном native-пути уже есть l2_tN, поэтому используется &l2_tN без дополнительного выделения.
Готовое место адресуется непосредственно; исходное объявление от чтения результата не заменяется.
Время жизни обычное. @f() было исследовательским примером, не задачей отдельной поддержки или запрета.

Обязательное копирование исполняемого code при входе отменено, включая прежнюю копию только кода
C-функции. Независимость выбранных локальных значений/описаний сохраняется; связывание передаётся
скрытыми аргументами, без копии окружения. Методы и обычные Structure компилируются общим механизмом
без data=code; разные реальные подачи дают разные C-сигнатуры. Известный native вызывает известный
native прямо в C. Правка графа не обнуляет native: обновление требует явной компиляции и границы
endturn (§6.5–7). До границы момент применения правки исполняемого графа не гарантируется.

Локальные кадры не публикуются. Load-dirty, общий кеш прямого доступа и flush() отменены;
явные записи наблюдаются через реальные алиасы в порядке исполнения.
[Согласованная норма](LMX_semantics.ru.md#call-frame-20261115),
[единое ТЗ M14](../next_core_tasks_v3.md#native-structures).

Исходная вызываемая Structure сохраняет голову и написанные части data/return/code. Локальный namespace
не становится её дочерним полем. Копия исполняемого code ради одинакового момента применения правок не требуется.
Прежние args и автозаполнение data из code удаляются общим изменением представления/потребителей,
без двух параллельных трактов. Сокращённые заголовки fn/sub/catch сохраняются с единой data;
заголовок без code описывает сигнатуру вызова, а не отдельную полную функцию.

### 3.5 Имена: в графе — слова, разрешение — обходом (решение, проверено Codex, ревью 2)

Переменные и const видны последовательно от первоначального объявления в своём блоке и ниже.
Именованные Structure и callable видны в обе стороны; переменная с callable-значением остаётся переменной.
Namespace собирает только корни data/code, без автозаполнения графа и без исполнения инициализаторов
при входе. Входы data доступны исполняемому code; сбор корня code не открывает будущие локалы.
Новое имя ветви не видно снаружи; повторное объявление уже видимого имени сохраняет вычисление RHS,
допуск и запись в выбранное место. До местного объявления возможна обычная доступная внешняя связь,
без отдельного TDZ. Уточнение2026-11-15 заменяет прежнюю общую двустороннюю видимость.
[Норма](LMX_semantics.ru.md#call-frame-20261115).

Построитель **не вшивает скрытые привязки** будущего обхода в граф: написанные головы, пути, операнды выражений и имена
подачи `a := v` сохраняют примитивы-слова с каноническими указателями на строки (§4). Явное заполнение ссылочного места
известным языковым значением при построении среза390 (§1a) — обычное содержимое графа, а не сохранённая таблица разрешения. Разрешение
имени в место выполняет потребитель при своём обходе, учитывая текущую активацию, выбранные `code`/`data` и текущее
содержание графа: ближайшая локальная привязка вызывающего выражения, унаследованный динамический вход по цепочке
активаций, затем лексический fallback по `parent` ([книга §12, :827–829](LMX_semantics.ru.md#dynamic)); поле выбранного
`data` в `call: data code` — по его слотам; найденные привязки — карты **только текущего обхода** (§5.2), не сохранённый в
графе результат. Прямые графовые ссылки в слотах — только реальные связи языка: значение `@: p Model`, поле, держащее
Structure, адрес, записанный программой, — не скрытый итог разрешения. Упоминание известной Structure — в хвосте
объявления, в аргументах вызова — тоже не раскрывается ни парсером, ни построителем: в дереве стоит атом (в графе —
примитив-слово), указатель на неё, и ссылаться на неё он начинает при интерпретации и трансляции (ответ автора
2026-11-11, [книга](LMX_semantics.ru.md#colon-declares)); чистый граф исполняет это со среза 355: при исполнении
объявления слот такого атома он не переписывает, имя атома ищется при чтении пути через него (подшаг 5а
[раздела M11 плана](../next_core_tasks_v3.md#m11)). Рабочие значения разных рекурсивных активаций живут
каждое в своём кадре и не читаются из общего формала или его умолчания. Транслятор разрешает те же слова при своей
трансляции своими таблицами и выпускает native по найденным адресам (§7); изменение кода само не аннулирует native, обновление требует явной компиляции (§6.5).
Проверяемость: после построения дерево P0 отсутствует (его арены освобождены), а следующий обход начинает с пустых таблиц
— это проверяется критерием чистого обхода (§11 п. 6б). `sys\toLmx` печатает слово по его строке, а именованный примитив или
Lmx — по таблице адрес → name.

В срезе390 этот путь ограничен прямой двухаргументной формой `@: name candidate`: construction-time reader доказывает кандидат по текущему
исходному вхождению, физическому scope и binding созданной F либо по непосредственно написанной Structure.
Он не подменяет формал, собственное место DATA, pending
объявление, неоднозначное имя или свободный вход лексическим совпадением. Mutable alias — отложенное чтение, даже
если его начальная цель известна в этом обходе; её payload не замораживается, цепочка не вычисляется до fixedpoint.
Неизвестный кандидат остаётся записанным и принимается обычным runtime-контрактом при фактическом получении.
Расширение известных путей описано ниже; дополнительные type fields и применение этой новой фазы при runtime `merge`/`sys\fromLmx` остаются OPEN.

**Source-known пути, срез391.** Приватные Run helpers `construct_slot`, `construct_atom` и `construct_value` читают
доказанный исходный путь без activation resolver или вычисления выражений. Именованный шаг использует прежний
выбор поля и точное соответствие raw source → F текущего construction walk. Выбранный atom продолжается только
лексическим поиском; pending audit рассматривает действительные DATA/CODE scopes, а EXPR не создаёт новую такую
область. Ближайший formal, own DATA, pending/ambiguous binding и free-input masks простого имени остаются прежними.

Буквальный числовой индекс проверяет границы физического слота и даёт непосредственный адрес выбранного значения:
если это raw Structure/Frame, конструктор может сохранить именно её; он не применяет `fn` заново к выбранному Frame
и не превращает WORD в лексически названную Structure. Поэтому `A(B)` различает `A\B` и `A[0]`: последний выбирает
WORD-ячейку. В bounded materializer391 такой индекс не является известной Structure, initializer остаётся raw;
достигнутый runtime4 ограниченного `@Struct` не объявляется универсальной нормой ресивера `@`. Вычисляемый индекс
и mutable reference остаются отложенными, их эффекты и initial payload при построении не читаются.

Классификация определяется физическим значением, без исключений по имени части F. Текущая `F.data`, записанная
`fn_make` через `graph_put` как прямой kind4, является известной Structure по общему случаю; текущие ссылки kind6
в `F.args`/`F.code` остаются отложенными. Для pending audit приватный `construct_data_scope` отдельно узнаёт настоящую
лексическую DATA: её `parent` — FN-result, а `method_data(parent)` указывает ровно на эту Structure. Полный
`method()!=0` для этого не требуется: bodyless descriptor тоже имеет собственную DATA. Такая роль не добавляет DATA
в очередь материализации, не обходит исходный blueprint и не исполняет инициализаторы. Пропуск этого audit выявлен
после промежуточного private48: method и bodyless descriptor отвечали4 вместо требуемого2; Runtime03/Graph03 дают2/2,
data width остаётся2/2. Это не меняет ролей сигнатуры, method.DATA или CODE, не открывает раннее
исполнение их содержимого и не добавляет typed/qualified/common admission. Полный M11.7, M13/M14 и применение
новой фазы к runtime `merge`/`sys\fromLmx` остаются OPEN. Private48 triple/AFTER39 предшествует этому исправлению;
после него private02:49 interp/native/forced и AFTER39 прошли на Source05:907, прежние43 expected не менялись.
Первый whole bootstrap01 остановлен без приёмки. Whole `boot-m11-construction-paths-02` прошёл с настоящими G1/G2
по9 smoke и fixedpoint15/verify907; Runtime03 совпадает с G2 driver. Промежуточный Source06 меняет форматирование двух
fixture sources относительно Source05: полные AFTER2 и четыре сгенерированные native/forced программы совпали.
Финальный Source07 удаляет лишние EOF-пустые строки шести новых sources:10 сгенерированных программ совпали с выходами
настоящего G2, build4 control и fixedpoint03:15/verify907 PASS. Ядро и входы сборки компилятора не менялись,
дополнительный whole не выполнялся. Повтор G2 всех49 triple/AFTER39, render35/14 и fresh docs-check01 PASS;
final index перед коммитом.

**Borrowed receiving-view, срез392.** Общий `declaration_parts` читает только receiving-chain и возвращает заимствованные
leaf/model/candidate, наличие кандидата и доказанность ресивера; вызывающий сохраняет исходный root со всеми
qualifier/Array звеньями. Содержимое модели, default и mutable payload не обходится и не вычисляется. Двухаргументный
`@` здесь остаётся неоднозначным; сигнатурный wrapper отдельно сохраняет прежний контракт presence: WORD — требование
без default, явный0 — присутствующее значение. Этот вывод не переносится автоматически на ту же форму в DATA.

DATA/CODE logical name выдаётся только для доказанного declaring-контракта. Generated exporter использует
`primitive.spelling`: в C-проекцию попадают только строки cell1 с одним C-идентификатором. Поэтому `c.uint8_t` может
быть доказан source spelling, а языковой alias `u8` сам по себе не доказывает тип `c.u8`. Остальные `c.*` сохраняют
provisional UNKNOWN; ни префикс, ни число аргументов не заменяют роль реального C-объявления.

Construction пропускает receiving-chain и её группы как отдельные DATA scopes; typed model не становится данными
кандидата. Только прежний прямой `@` с двумя аргументами владеет своим literal-DATA operand и применяет bounded
материализацию390/391. Неподдержанные qualifiers, Array, глубокие и typed объявления сохраняются целиком raw;
logical-step guard сообщает unsupported вместо представления такой записи обычной Structure. Числовой индекс391
по-прежнему выбирает непосредственный физический слот без переинтерпретации atom или `fn`.
`call_single` проверяет логическое описание выбранного whole-field перед admission: raw declaring description
не выдаётся за готовое значение Structure. Обычный whole-Group-as-first fallback сохранён; готовая reference,
полученная физическим индексом, использует общий маршрут. `written_whole` сначала проверяет DATA shape через pure binder,
default-presence и общий declaration proof, затем физические runtime kinds. Ранний contract1/3 gate из `call_reading`
снят; char не попадает ошибочно в FREE scan. Whitelist языковых слов вместо receiving-контракта не вводится.
Private21 triple/negative AFTER15 и whole02 с настоящими G1/G2 прошли; actual G2 interp21/full AFTER21 PASS.
42 emitted native/forced images плюс2 libc/backend дали44 byte-equality PASS, без новой компиляции или повторного
запуска готовых private binaries. Fixedpoint13 artifact/2 canonical checks и G2 render35/14/оба snapshots PASS;
docs-check/index/commit/push392 ещё предстоят. Model/default остаются исходным receiving-описанием: это ещё не typed
storage/admission или actual C-door general bridge. Они остаются OPEN вместе с M13 и полными M11.7/8/M14.

**Source interface, срез393.** `LmxImplSourceReader` передаёт общему implements worker operation-local callbacks имени
и receiving fact, без нового parser или постоянной карты имён/типов рядом с графом. Reader clean Graph использует
тот же borrowed declaration view и `g.names`. Физический `Fact.type`/cell/ABI берётся прежним путём; отдельный source
fact сохраняет исходный receiving root, описание примитива и порядок qualifier-chain. Модель, default и language-reference
payload не вычисляются. Служебный uninit pointer позволяет узнать уже существующую cell, не читать её неполученное значение.

Generated-проекция сохраняет literal35 rows ×15 columns исходной `primitive.description`. Точное source-описание
не выводится из одного machine type или C-spelling; source aliases автоматически не объединяются. Положительные
identity-проверки всех33 cell rows прошли в private L2 native/forced с root0/1. Это проверка source interface,
не реализация physical storage этих33 типов. Qualifiers не стираются; недоказанные references/Array остаются UNKNOWN.

Общий `lmx_implements_source_interface` владеет одной операцией: `require_root`, общий `drain`, затем `resolve_close`
с `published=0` и закрытие scratch. Он не публикует permission, готовую receiving-map или постоянный proof, не запускает
кандидат, преобразователь или `test`. Прямой `@: p Model Value` при известных Model/Value использует эту интерфейсную
проверку; доказанное отсутствие требуемого поля даёт отказ. UNKNOWN не превращается в YES. Само объявление остаётся raw
с Model/default: интерфейсная проверка не выделяет typed storage и не заменяет будущий runtime admission/test.
Ограниченные code/docs gates393 PASS; общий typed storage/runtime admission и полные M11/M13/M14 остаются OPEN.

В WIP394 SourceFact отдельно читает доказанные scalar-pool/companion metadata до прежнего `Graph.kind=0` fallback
для Foreign. Физические kind/type/cell не заменяются source row или ABI pointer; plain validated source evidence может
дать YES, недоказанное или qualified evidence остаётся UNKNOWN. Это не включает общий Foreign runtime в старый Graph.kind.

В срезе 373 `lmx_graph_resolve_binding` одним поиском возвращает выбранное значение и его рабочую строку.
Классификация и читатель значения используют этот общий выбор с прежним приоритетом формалов, собственных мест
и методов данных. Сохранённый deferred Frame не выдаётся за обычную Structure или вызываемое; читатель сохраняет
его отказ 5 до рабочей записи. Не выбирается внешнее одноимённое место вместо уже найденной ближайшей привязки.

<a id="names"></a>
## 4. Строки идентификаторов (норма)

Одно написание — одна строка в процессе: байты интернированного написания лежат в участке `text` арены-владельца
таблицы строк и никогда не перемещаются и не освобождаются раньше процесса. **Состояние строк** — таблица строк процесса
(решение: одна на процесс, как нынешний `lmx_ids`, но хранит только строки) и её индекс поиска по байтам — это состояние
процесса, как таблица адрес → name и индекс участков (§1 п. 5), а не временная таблица обхода: он существует всё время
процесса и нужен только на границе ввода. Интернирование — единственная операция, сравнивающая байты, — выполняется на
границах ввода: разбор P0 (каждый атом и голова получают указатель на свою строку вместе с байтами токена), загрузка
единицы (строки единицы уже интернированы транслятором — выпущенный код несёт их таблицу и переводит её в адреса
процесса один раз при загрузке), `sys\fromLmx`, присоединение участков другого процесса (§8). Дальше всюду — указатели:
сравнение идентификаторов есть сравнение адресов строк в арене (§1 п. 2), `sys\toLmx` печатает байты по указателю. Точный
идентификатор в обратных кавычках — та же строка, что его значение без кавычек ([грамматика
§§3.4.2–3.4.3](LMX_grammar.ru.md)). Пользовательские строковые значения идентификаторами не являются и не интернируются.
Числового кода написания, оператора или ресивера нет: решение автора 2026-11-07 о коде заменено его решениями 2026-11-08,
абзацы книги обновлены как заменённые (подтверждение Codex 2026-11-08, без отдельного ACK автора). Прежнее «таблиц ровно
две» относится к именам — адрес → name и строка написания → адрес строки на границе ввода, — а не к временным таблицам
обхода (§5.2).

<a id="tables"></a>
## 5. Таблицы

### 5.1 Адрес → name (норма: «имя узнаётся из таблицы адрес->name»)

Одна таблица на арену: строки `{ address, name }`, где `address` — адрес **самого именованного примитива или Lmx** (норма
автора 17:22Z: по адресу примитива известны тип, имя и значение; у Lmx аналогично; Codex, ревью 2 — не адрес слота, не
«вхождение», не ключ «владелец + номер»), `name` — указатель на интернированную строку. Операции: `name_of(address)`
(бисекция по адресу в упорядоченной таблице или индекс по участкам — решение), `named_field(lmx, name)` — слот Lmx, чьё
содержимое (адрес примитива или Lmx; у места без значения — запись T внутри записи `uninit:T`, прежде ячейка T за указателем `uninit:T`) именовано `name`:
обход слотов Lmx с одним `name_of` на слот и сравнением указателей. Ячейка места именуется с построения, и первое
присваивание ничего в таблице не меняет (§3.2). Таблица заполняется
при построении (имена объявлений), при `merge`/копировании (копия именованного адреса получает строку с тем же указателем
имени), при `sys\fromLmx`; строки мёртвых адресов снимает сбор. Однозначность — по книге ([имена и
пути](LMX_semantics.ru.md#fields); решения автора 2026-11-11): в Structure как **данных** каждая объявляющая запись её
коренного уровня — вхождение имени; единственное вхождение адресуется голым именем, и `named_field` над ним
однозначен, а при двух и более голый путь — ошибка, и вхождение выбирает индекс: `s\[N]field` с отсчётом `N` от нуля
— N-е по порядку полей вхождение этого имени, и `named_field(lmx, name, N)` считает вхождения в порядке полей.
Повторное объявление в данных прежнего не заменяет и в него не пишет: каждое вхождение — своя Lmx или ячейка со своей
строкой таблицы. В **коде** повтор объявления ресивером второго поля не создаёт — это проверка типа с присваиванием в
то же место, — а структурная запись там — вызов своей головы. Прежде этот абзац говорил иначе: у данных нескольких
одноимённых полей не бывает, а повторные определения одной головы допустимы у кода. Правило вхождений чистый граф
исполняет со среза 355: имя с двумя и более вхождениями без индекса не отвечает, вхождение выбирает путь с индексом;
в пути запись с головой — именем места того же уровня вхождением пока не считается (подшаги 5а и 5д
[раздела M11 плана](../next_core_tasks_v3.md#m11)). Таблица имён семантику повторных объявлений и её узкую паузу
(REPEATED-DECL-OTHER-KINDS) не меняет. Это единственная структура
имён; ни `LmxSourceName (key, port) → code`, ни «таблиц мест», ни порядковых номеров имён нет.

### 5.2 Служебные таблицы по реальной задаче

Таблицы имён, диапазонов типизированной арены, канонических строк и необходимые карты копирования
сохраняют свои существующие обязанности. Namespace и локальные места принадлежат вызову; временные
таблицы построения и копирования принадлежат соответствующей операции и освобождаются на её выходах.
Никаких таблиц публикации кадров, общей согласованности кеша или прежних требований физического
слота для S[n] не требуется. Удаление проверки включает её таблицы и переносы фактов.

При построении чистого графа разрешать известные имена и требования общим кодом сборщика.
Не готовить заранее отдельные runtime-таблицы для гипотетической динамики. Явные sys\check,
sys\checkL3 и sys\translate используют нужные части работающего сборщика, без второй реализации.
Проверка чистого графа не выполняет пользовательские инициализаторы или test.
[Единая постановка](../next_core_tasks_v3.md#graph-tools).

<a id="interpreter"></a>
## 6. Интерпретатор

<a id="direct-access-cache"></a>
Локальные места вызова независимы от исходного графа. Прямой путь или разыменование работают
с реально адресованной ячейкой. Отдельный общий кеш и load-dirty отменены; оптимизация не меняет
последовательное наблюдаемое поведение. [Норма](LMX_semantics.ru.md#call-frame-20261115).

### 6.1 Обход

Исполнение тела — обход Lmx операторов в порядке полей. Оператор — Lmx (§3.3). У именованного Frame `head: a b` голова —
его имя (`name_of`: строка таблицы адрес → name), поля с 0 — аргументы; роль головы — по адресу её канонической строки:
слово языка (`if`/`while`/`return`/…), ресивер (`fn`, `int`, `merge`, `@`, …) или имя, которое разрешается в namespace
текущего обхода таким, каким он стоит у этого поля, а места и Structure корня отвечают по реестру данных выше и ниже своей
строки (§3.5, §5.2). Имя, отвечающее функцией (Structure F, созданной
ресивером `fn`/`sub`, §3.4), с аргументами → вызов ([L2 §11](L2_spec_ru.md#call)); место данных на месте значения → чтение.
В срезе 372 прежнего корневого declaration/reach-маршрута нет: в коде именованная голова разрешается по живым данным
и вызывает выбранный метод либо запускает обычную Structure, непосредственно или через ссылочное место.
Неопределённая голова или неподходящая форма отказывают при достижении записи; форма с двоеточием не присваивает
значение месту. По норме корень единицы запускается как Structure над самой собой: запись читается по обеим ролям,
в данных объявляет, в коде вызывает свою голову (вызываемое — вызовом
метода, обычную Structure — запуском по имени: `S()` — `call(S, S)`, `S(D)` — `call(D, S)`), и структурная запись, до
которой дошло исполнение, ошибочна, если её голова не называет ни вызываемого, ни Structure, а объявления Structure
пишут в данных (ответ автора на П7, [книга](LMX_semantics.ru.md#data-code-roles); решение о запуске по имени —
[журнал](../LMX_blog/2026-11-11.md#structure-call-by-name); чтение исполнителя —
[ответы](../LMX_blog/q/fable-self-answers-20261110.md), Р6, Р7 и Р21; шаг 5
[раздела M11 плана](../next_core_tasks_v3.md#m11), запуск по имени в корне единицы и в Structure над самой собой — его подшаг 5г). Отдельно представленные
выражения сохраняют свою общую форму: операция — безымянная Lmx (слово оператора и операнды, в том числе операция,
записанная Frame, §3.3), путь, `:=`. Голый атом не вызывает ([READ.ME](../READ.ME)); обычная Structure исполняется
ресивером `call` или в коде записью по имени — `S()`, `S(D)`; Срез 372 распространяет общий dispatch именованной
головы на корень и запуск над собой. Корневые числовые/ссылочные публикации и прямой вызов по голове-пути ещё открыты.
По решению автора 2026-11-16 записи самостоятельной написанной анонимной Structure в коде исполняются на месте,
в текущей активации ([семантика](LMX_semantics.ru.md#data-code-roles)); чистый граф среза 372 ещё оставляет её
значением и её записей не исполняет — перенос открыт ([M10](../next_core_tasks_v3.md#m10), решения 2026-11-16, п. 4).
Тела управления исполняются по явному контракту принимающего ресивера.
Выражение
`a op b` — три поля, операнды вычисляются рекурсивно: примитив-число — значение ячейки своего типа,
вложенная Lmx — результат её обхода, имя — чтение ячейки найденного места по её типу (значение `uninit:T` — по общему
допуску, §3.2).
Никакой предтрансляции тела в кадры операций: нынешние `LMX_WALK_OP_*`-кадры и `LmxOp` — второе дерево, §9 снимает их
(K03 плана v3).

### 6.2 Роли по указателям

Слова языка интернируются ядром первыми при старте процесса (`fn`, `fm`, `sub`, `if`, `else`, `while`, `for`, `until`,
`return`, `break`, `continue`, `throw`, `catch`, `merge`, `implements`, `convert`, `interpreter`, `adopt`, `independent`,
`call`, `const`, `immutable`, `data`, `code`, `node`, `int`, `char`, `size_t`, `unsigned`, `ulong`, `void`, операторы
`+ - * / % = != < <= > >= && || ! & | ^ ~ << >> := \ @ [] ()`) и доступны исполнителям как константные указатели
(`lmx_word_if`, …): эти константы — адреса тех же строк участка `text`, а не отдельные коды; у служебных операторов и
ресиверов нет ни числовых кодов, ни особого представления (автор 18:18Z) — `for`, `=`, `**` в графе суть примитивы-слова с
адресами своих строк, и оба потребителя, транслятор и интерпретатор, узнают их одинаково — сравнением адреса. Сравнение
«это ли слово `if`» — сравнение указателя поля с константой; так же список ресиверов языка (`lmx_graph_language_receiver`):
те же канонические строки, интернированные один раз в состояние графа, и сравнение адресов, без побайтного сравнения уже
канонического слова (ревью Codex 332). Имя пользователя в поле слова (§3.5) ищется по порядку книги
сравнением указателей: локальная привязка текущей активации, унаследованный динамический вход по цепочке активаций, затем
лексический fallback по `parent` (`named_field` по слотам известной Structure — выбранного `data`, формалов вызываемого,
собственных полей); не найдено — неявный бросок по книге. Со среза 354 в перечне слов языка выше стоят `data` и `code`
вместо прежних `var` и `body` (решение автора 2026-11-11, [книга](LMX_semantics.ru.md#ordinary-var); шаг 4
[раздела M11 плана](../next_core_tasks_v3.md#m11)).

### 6.3 Активация

Кадр хранит локальные значения, namespace и управление текущим вызовом. Корневые объявления data
сопоставляются входам, затем учитываются корневые объявления code, отсутствующие среди входных мест.
Вложенные ветви и графовые ссылки при подготовке не обходятся. Готовые значения копируются обычным
способом; вычисляемые объявления не исполняются заранее. uninit:T сохраняет отсутствие значения.

@x даёт адрес локальной ячейки текущего вызова. @(data\x) сохраняет адрес готового исходного места;
для вычисляемого объявления адресуется его обычный результат, без замены исходного объявления.
Для вычисляемого входа @x получает значение и адрес обычной локальной ячейки. Используется существующее
место результата, без дополнительной ячейки ради @. Локальное и исходное места нельзя объединять
ради прежней stable-cell модели. Указатели на локальные места следуют общим правилам времени жизни;
новой инфраструктуры escaped locals без конкретной потребности не вводить. Повторный/рекурсивный вход
получает другие локальные места. Возврат и вложенный вызов не публикуют их и не перечитывают внешние локалы.

Обязательное копирование исполняемого code при входе отменено, включая прежнюю копию только кода
C-функции. Независимость выбранных локальных значений/описаний сохраняется; связывание передаётся
скрытыми аргументами, без копии окружения. Методы и обычные Structure компилируются общим механизмом
без data=code; разные реальные подачи дают разные C-сигнатуры. Известный native вызывает известный
native прямо в C. Правка графа не обнуляет native: обновление требует явной компиляции и границы
endturn (§6.5–7). До границы момент применения правки исполняемого графа не гарантируется.

Срезы до400 реализовали рабочие строки с loaded/dirty и публикацией: это прежний механизм, который
нужно упростить, сохранив нужное типизированное хранение и обычный стек/GC. Наличие этих функций
не подтверждает новую модель. Точные места удаления перечислены в [M14](../next_core_tasks_v3.md#native-structures).

### 6.4 Копирование, merge, присоединение

`merge`/копия строят новую Lmx с одной картой адресов источник → копия (служебная таблица на время операции): ячейки
`lmx` и примитивы (косвенное место копируется как ячейка T и указатель `uninit:T` на копию; содержимое T сохраняется,
форма не заменяется прямой; слова копируются как ячейки с тем же указателем строки) копируются в участки своих типов арены-получателя, слоты
переписываются по карте, `parent` — на
копии, общие цели и циклы сохраняются ([L2 §13](L2_spec_ru.md#copy-merge)); строки таблицы имён копируются с тем же
указателем имени для адресов копий; интернированные строки общие для процесса, копировать нечего. Присоединение участков
другой арены того же процесса не трогает ни ячейки, ни имена; присоединение из другого процесса (почта между процессами,
§8) проходит через `sys\fromLmx`-подобную границу интернирования. `independent: immutable` — по книге.

Операнды `merge` — обычные выражения со своим общим смыслом (автор 2026-11-08, [журнал](../LMX_blog/2026-11-08.md)):
голова-функция применяется один раз, и операнд — её результат; одноимённое поле модели этот вызов не перехватывает
(`f(3)` и `f: 3` — один граф). Frame с головой-не-функцией по норме 2026-11-11 в данных объявляет Structure, а в коде
вызывает свою голову — запускает обычную Structure (ошибка, если голова не называет ни вызываемого, ни Structure);
запись запуска Structure на месте, где нужно значение (операнд выражения, фактический аргумент вызова, начальное
значение, операнд `merge`), ошибочна: у запуска результата нет (решения автора 2026-11-11 —
[роли `data` и `code`](../LMX_blog/2026-11-11.md#data-code-roles) и
[запуск по имени](../LMX_blog/2026-11-11.md#structure-call-by-name); чтение исполнителя —
[ответы](../LMX_blog/q/fable-self-answers-20261110.md), Р22, пункт 3; Р25, пункт 4). Рабочий frontend читает
такую запись, как читал до решения 2026-11-11, — до шага 8 [раздела M11 плана](../next_core_tasks_v3.md#m11); состояние чистого графа —
по [срезу 356](../steps/witnesses/callable-data-launch-by-name-20261111/notes.md): запись запуска он исполняет в коде
метода и в коде над поданными данными, а в корне единицы запись запуска на месте операнда отвечает 5 (фикстура
`struct_launch_operand`: `S: (int: k 1)`, `int: r S()`). Одна композиция служит любому операнду,
что бы его ни создало (срез 334; Codex, ревью 333: никакого особого merge функций): слот, чьё значение — Structure,
которую поздние операнды дают снова как Structure, компонуется тем же уровнем `merge` через ту же карту, рекурсивно
(`lmx_graph_merge_level`), каждое поле читается своим значением (`lmx_graph_field_value`) — вложенные части данных
(`merge_nested_part`: часть `P` получает новое поле `v`), описания, записанные кодом с полем `name`
(`merge_code_descriptions`: `d2` без тела), функции namespace (`merge_callable`, `fn_new_name`), — без классификации по
происхождению и по операторам, которые часть держит; место-слово (`return`) принимает позднее слово, слот сохраняет форму
модели (именованная ссылка — ссылка на композицию); у `f2` без тела результат сохраняет копию тела `f1` и получает
сигнатуру обоих: `fn: g merge(f1, f2)` даёт `g` с формалами `a`, `b` и телом `f1` (`fn_new_name`; `descriptor_merge`:
умолчание `b` 7 дескриптора). Каждый корень
операнда в одной карте отображается в результат, а поле позднего операнда, названное как место результата, — в это место
(значение и ячейка), так что ссылка на него ведёт к месту результата; `parent` скопированной Structure — копия её
родителя. Нужный лексический предок — тот, через который разрешается скопированное имя, — копируется как обычная Lmx
через ту же карту, целиком, со своими полями, ссылками и циклами, до `parent` = 0: он не обрезается до встреченных имён,
и это не копия всей арены, а необходимая достижимая closure. Результату без написанных имён и вызываемых предок не нужен,
и его `parent` — 0 (нет лексического родителя, это не объект-корень арены); исходный изменяемый предок не подмешивается,
место исполнения родителя не задаёт. Результат одного операнда — копия его корня и по §5.1 сохраняет его имя. Помимо графа
обход держит только свои таблицы и их корни (§5.2): F, которую программа удержала ссылкой графа, остаётся значением и
копируется как значение; копия не держит привязок, сделанных другим обходом, и новый обход строит таблицы из графа, до
которого доходит, — текущий resolver никакого контекста не исключает. Функция, которую `fn: g merge(f1)` создаёт из
копии, — новое объявление: её `parent` — Frame применения, и свободные имена её тела разрешаются оттуда общим правилом
выбранного метода и узла (книга :110, :784; приоритет динамических входов :829–833) — `merge_recursion`: имя `f1` в
скопированном теле — функция `f1` корня; одна активация `g`, три — `f1`; копия, её тело и её ссылки сохраняют
скопированные цепочки (книга :1205–1207), и ни одна явная ссылка не перенаправляется к источнику. Новое
место для уже именованной Structure или вызываемого — новая именованная ссылка (ячейка `ref`, §2.2) на тот же экземпляр
([книга :441](LMX_semantics.ru.md#resolved-head-consumption), `@: name Model`): у ссылки свой адрес и своё имя, имя
цели не меняется; вызов, путь, запись поля и операнд `merge` через ссылку берут её цель
([книга :454](LMX_semantics.ru.md#ordinary-var), [:1237](LMX_semantics.ru.md#factory-reference-result)), а копия ссылки
указывает на копию цели через ту же карту. Имя функции, созданной из композиции, — аргумент имени ресивера
(`fn: new_name merge(f1, f2)`), не поле и не имена операндов (§3.4). Реализованное подмножество и открытое — в статусе
выше (graph73).

**Чтение скопированного объявления, срез383.** Query и потребление используют общий
`resolve_binding_context`; query не строит F, поскольку тот же поиск нужен binder при создании receiver.
`binding_source_read`/`binding_read` и atom reader при фактическом чтении разрешают подготовку достигнутого owner
через прежний `space_declarations`/evaluate0. Подготовка всего блока сохраняет классификацию соседних written
методов перед последующими computed actuals; computed producer не запускается преждевременно. Общий путь
сохраняет точные scope/source/parent, включая объемлющий `node`, и прежний порядок разрешения/допуска места.
Ошибки передаются локальным status этого чтения; malformed constructor5 не становится missing3,
общего error latch в Space или кадре нет. Код merge и `fn_data` не меняется, чужие bindings не копируются.

Raw-объявление в копии создаёт новую F из своих скопированных аргументов. Удержанная ссылкой F копируется
с текущими частями и алиасами как обычная Structure; явный следующий `fn` создаёт новую F и новую own data.
Чистые запросы не подменяют это потреблением и не классифицируют ordinary descriptor как вызываемое.
Runtime01/Graph01,10 pure,102 полных AFTER34 случаев в трёх режимах на тех же binaries, mutation24 и native trace прошли;
Whole bootstrap quick с настоящими G1/G2, по9 smoke и fixedpoint13/verify781, повтор G2 (34 triple/33 negative AFTER/mutation24)
и штатные render/docs check383 прошли. Охват ограничен этими классами; полный M11, оставшиеся5е/7/8, внешний/вычисленный CodeBody,
native copy и M13/M14 остаются OPEN.

### 6.5 Явная компиляция вместо отслеживания правок

Запись в граф происходит непосредственно и не аннулирует native. Удаляются обслуживающие
отслеживание правок проверки, code_uses, обратные связи, таблицы, переносы и ветви генератора:
lmx_graph_invalidate_prepare/finish/invalidate и части lmx_code_* / reset_gen, существующие только ради сброса.
Общие ссылки, типизированное хранение и обычный GC сохраняются по их самостоятельному назначению.
Не заменять удалённый механизм dirty-журналом, версиями, хешированием на endturn или скрытой перекомпиляцией.
Произвольно испорченный граф не обязан автоматически восстанавливаться.

`sys\compile(S)` явно строит и проверяет чистый граф без исполнения программы, транслирует L1 → C,
компилирует/связывает машинный код и регистрирует готовые результаты в таблицах call; возвращает диагностики.
Ошибочный результат не устанавливается. Рабочий код сборщика переносится в runtime только для
конкретной операции; отдельную универсальную инфраструктуру заранее не создавать.
`sys\translate(S)` по-прежнему возвращает текст L1 и ошибки, а не LMX или машинный код.

<a id="endturn-receiver"></a>
`sys\endturn()` выходит из вложенных вызовов через уже зарегистрированные finally в обратном порядке
к обычной границе такта. Обычный catch его не перехватывает; возврата к месту вызова и продолжения
этого стека нет. Сам ресивер не меняет running/success и не завершает Message. Следующий назначенный
такт начинается обычным входом. Общий cleanup/exit путь должен обслуживать это и в native, и в обходчике.

До границы момент применения изменения исполняемого графа не гарантирован. Только после успешной
явной компиляции и endturn следующий вход обязан использовать подготовленное обновление.
Один endturn не обнаруживает правки, не проверяет граф, не компилирует и не публикует локалы.
Старые native-кадры и finally должны закончить работу до освобождения их машинного кода.
[Норма](LMX_semantics.ru.md#explicit-compilation), [план](../next_core_tasks_v3.md#explicit-compilation-plan).

<a id="flush-receiver-contract"></a>
### 6.6 Отмена flush()

Ресивер flush и публикация локальных кадров сняты решением 2026-11-15. Удаляются только относящиеся
к ним проверки, таблицы, переносы и генерация. Публикация Message и выдача результата построения
не являются обратной записью локального кадра и сохраняют свои отдельные контракты.

<a id="native"></a>
## 7. Native

Дескриптор native — обычная Structure с вариантами реальных сигнатур, идентификаторами бинарного модуля
и входа, путями к исходникам L1/C. Основное хранилище дескрипторов всех компилируемых Structure —
таблицы call. Транслятор добавляет отсутствующее обычное поле native в fn/sub/catch со ссылкой на тот же
дескриптор; другим Structure поле не добавляется. В заголовке Lmx native отсутствует.
При динамическом вызове call выбирает вариант по цели и реальной сигнатуре.

Статически известный native → native выпускается прямым C-вызовом с обычными параметрами и нужными
скрытыми аргументами связывания. Для организации такого вызова не строить граф аргументов, универсальные
Value-обёртки и lookup/trampoline; явно написанный доступ программы к data/code сохраняется.
Методы и обычные Structure используют общий выпуск, без data=code. Сигнатура без code описывает вызов.
Не вводить заранее универсальный реестр вариантов сверх таблиц, требуемых реальными вызовами.

Если A напрямую вызывает B, перекомпиляция только B не переписывает машинный вызов внутри A.
Явно компилируется общая единица с нужными вызывающими и вызываемыми. Автоматическая обратная
зависимость для отслеживания правок не вводится. sys\native — запрос таблиц, sys\translate — L1,
sys\compile — полный явный путь §6.5. Текущие установки decl.native/made.native — прежняя реализация,
которую требуется заменить. Новая модель OPEN; старые receipts остаются историей.

<a id="codec"></a>
## 8. sys\toLmx и sys\fromLmx

`sys\toLmx(S)` сохраняет выбранную S по общим правилам графа: порядок полей, нулевые слоты,
совместные ссылки, циклы, имена и содержимое типизированных ячеек, включая записанные через uninit:T.
`sys\toLmx(Thread)` сохраняет также все таблицы его арены, включая call/native-дескрипторы.
Таблицы принадлежат арене, не полям R0; R0 — частный Thread.
Внешние таблицы call не добавляются скрыто к произвольной S.

`sys\fromLmx` использует общий P0/построитель, канонические строки и восстановление адресных связей.
На той же платформе после перезапуска восстанавливается чистый граф с готовыми ABI-совместимыми
бинарниками, без повторной трансляции программы. Сохраняются идентификаторы модуля/входа и пути
L1/C, а не адреса старого процесса. Резерв capacity можно не сохранять: при загрузке capacity=length.
Нынешний диагностический dump пропускает часть нулевых слотов/безымянных циклов и ещё не является
таким codec; это явная задача [M13](../next_core_tasks_v3.md#flat-lmx-descriptor).

<a id="audit"></a>
## 9. Аудит существующих параллельных представлений

| Нынешнее | Чем является | Решение |
|---|---|---|
| `lmx_ids` (две таблицы «код → имя», «имя → код», коды единицы `l2_ids[K]`, `LMX_ID_*`) | числовой код как идентичность написания | заменить таблицей строк (§4): идентичность — адрес строки; константы слов — указатели §6.2 |
| `LmxSourceName {key, port, code, place_spec, model_layout, place_uses, place_callable}` и `lmx_source_names` | привязка «вхождение + порт → код» с боковыми картами мест | заменить таблицей адрес → name (§5.1); карты мест — нет: поле есть слот |
| `lmx_walk_input_width` считает интерфейс обычной Structure по положительным портам таблицы имён; эмиттер создаёт эти строки (`lmx_source_name_set_at` по `m_dyn`) — пример Codex | интерфейс выводится из побочной таблицы, не из графа | интерфейс Structure — её слоты (`size`, именованные адреса); скрытые входы — по §6.3 |
| Таблицы мест `[m, SIZE_MAX, (код, тип)…]` (`lmx_source_places_set`, кадр `PLACE`, `LmxCallPlaces`) | статическое описание мест процедуры рядом с графом | снять: место — слот; имя — слово, разрешаемое обходом (§3.5) |
| `LmxActivationBinding {code, storage, type, value}`, `lmx_activation_bind` | привязка имени по коду в активации | снять: формал/вход — адрес слота (§6.3), разрешение — таблица обхода |
| Место без начального значения | нельзя вводить скрытый initialized-флаг или превращать внутреннюю адресацию в ссылочный тип языка | постоянный указатель `uninit:T` на ту же T; любая запись — в T, без перепривязки слота; `i` остаётся `int` (§3.2) |
| Кадры обходчика `LMX_WALK_OP_*` (66 операций), `LmxOp {code}`, `lmx_walk_frame_profiled`, числовые селекторы в слотах (`lmx_walk_store_size`), `OF`/`AT`/`PUT_OF` по номерам слотов | второе дерево тела — предтрансляция в операции | снять (K03): тело — Lmx из слов, примитивов и вложенных Lmx (§3.3, §6.1) |
| `l2_bn` массивы имён связывателя, `lmx_call_bind_*` по кодам | имена аргументов как коды | по указателям строк в примитивах-словах именованной подачи |
| `LmxPool.role/profile/sealed`, `LmxRange.links/slot_owner/holder/side_*` | боковые массивы интервалов и профилей результатов | физические виды — коды записей (§2.0, [L2 §3](L2_spec_ru.md#value-record)); роль определения — слово головы |
| `LmxImplEntry/LmxImplContract` (карты `implements`) | адресное соответствие модели и кандидата | данные приёма/обхода (§5.2): удерживаются на время его операций, строятся заново следующим обходом |
| Постоянная карта `implements` арены (`lmx_arena_impl`, `LmxImplEntry.exec_map`, `lmx_arena_impl_prune`) | подготовленные соответствия, пережившие обход | данные приёма/обхода (§5.2): снять постоянное хранилище, L2 §14 обновлён |
| `LmxCodeLink` / reset-only `lmx_code_*`, `reset_gen`, code_uses и инвалидизация | отслеживание правок ради сброса native | удалить вместе с таблицами, переносами и генерацией; общие контексты/GC сохраняются по самостоятельному назначению (§6.5) |
| Транслятор: `LmP0Text\code`, `l2_words`, `lm_compiler_text_same` по кодам (остановленный WIP 308), интерн сигнатур по кодам | числовые коды в трансляторе | `LmP0Text` несёт указатель интернированной строки с разбора; сравнения — указателей; интерн сигнатур — по указателям |
| Транслятор L1 (`l1_text_eq`, `l1_head_is`, …) | сравнение строк | указатели тех же интернированных строк (один P0 у обоих трансляторов) |
| Дерево разбора P0 как вход транслятора (frontend читает `LmP0Node/Frame/Field`), его арены и индексы (`l2_pd`, `pdx`) | отдельная форма программы для одного потребителя | транслятор читает чистый Lmx-граф (§1a, §7); P0 — внутри построителя, уничтожается с построением |
| Строители графа единицы в выпущенном коде: `lmx_walk_frame_profiled` с операциями, `lmx_source_name_set*`, `l2_ids_load`, таблицы мест, `l2_sc*` | сгенерированная вторая форма программы (операции, места, скрытые интерфейсы) | снять; остаётся сгенерированная инициализация **чистого** графа через общий конструктор — ячейки, слоты, слова, адрес → name, участки, ссылки `native` (§1a) |

Остаются: `Lmx.parent/length/storage`, таблицы call и capacity, арена с её кусками и индексом интервалов владения, Message/Thread/почта, `implements` как
правило (носитель — служебная таблица приёма), копирование одной картой, сбор по достижимости.

<a id="example"></a>
## 10. Сквозной пример кадра

Пусть исходная D содержит поле x со значением 1, а выбранное тело C выполняет последовательно
`x := 2` и `data\x := 9`. Это описание пары call(D,C), не новая форма заголовка.

| Момент | Локальное x кадра | Исходное D\x |
| --- | --- | --- |
| После подготовки корневых мест | 1 | 1 |
| После x := 2 | 2 | 1 |
| После data\x := 9 | 2 | 9 |
| После возврата | Кадр завершён | 9 |

`@x` адресует второй столбец, `@(data\x)` — третий. Возврат не переносит 2 в D.
Новый вызов получает свежий namespace. Копия исполняемого C при входе не требуется; правка не
сбрасывает native. После успешной явной компиляции и endturn следующий вход использует обновление;
до границы момент применения правки к исполнению не гарантирован.

По индексу D[n] := p записывается только void*: никаких требований старого x или служебных
фактов слота не переносится. Именованное D\x := value выбирает текущее именованное место
и учитывает его требование при построении чистого графа там, где это известно.

<a id="transition"></a>
## 11. План перехода (согласован с Codex во втором ревью) и удержанное

Переход идёт одним существующим L2/L3 pipeline (один writer/build), срезами, с записью и проверкой Codex после каждого;
код пишется только в согласованной части. Проверки — по риску изменения среза: затронутые фикстуры на native и
интерпретаторе, короткий цикл всей цепочки ([READ.ME](../READ.ME)); полные проверки — весь реестр регрессий (139 рядов
`selfbuild/tests/full-suite.tsv`, native и forced, оба корня), bootstrap quick и full, docs check — в конце этапа и перед
каждой публикацией, не на каждом мелком срезе. Прежние решения и receipts остаются историей; прежние PASS остановленных
срезов не доказывают новую реализацию; остановленные мутанты, bootstrap и публикация 308 не запускаются; задача не
закрыта ни документом, ни одним quick.

0. **Вертикальный срез — первым** (разрешён Codex, ревью 2; без ещё одного ACK). Минимальный построитель → один чистый
   граф → оба потребителя, в таком порядке: (а) граф с уже инициализированным `int`, арифметикой и повторной записью
   (`int: x 5`, `x := x + 1`, `x := 7`); (б) первое присваивание (`int: x`, `x := 5`, `x + 1`), в том числе с заранее взятым
   адресом (`int: i`; `@i` сохранён без чтения незаписанных байтов; `i := 5` — чтение по адресу даёт 5; `i := 7` — 7 по тому же
   адресу; автор 19:02Z), и отдельные чистые обходы (второй обход того же графа с пустыми таблицами); (в) пример §10
   целиком — участки с
   `uninit:int`, слоты, примитивы-слова, таблица адрес → name, интерпретатор по §6, транслятор по §7 с native для `take` и
   сгенерированной инициализацией графа, `sys\toLmx` до и после, паритет native/интерпретатор, критерий чистого обхода
   (п. 6б). Новый путь строится рядом со старым под отдельным входом инструмента и не трогает выпуск старого, пока не
   покроет фикстуру.
1. **Расширение графа по фикстурам реестра**, группами по риску: выражения и `:=`, `merge` и копирование, Array (слоты,
   §3.1), `data` и `call: data code`, броски и `catch`, динамическая видимость, именованная подача, q/z, AXBY —
   каждый перенесённый ряд проходит native и forced на новом пути.
2. **Снятие старых носителей по мере покрытия** (карта в п. 7): `lmx_ids`/коды → строки; `LmxSourceName`, таблицы мест,
   `LmxActivationBinding` → слоты, слова и таблица имён; `LMX_WALK_OP_*`/`LmxOp` → Lmx операторов; профили и боковые
   массивы → участки; постоянная карта `implements` → данные приёма; `LmxCodeLink` → §6.5.
3. **Транслятор над графом полностью.** Frontend читает чистый граф единицы вместо дерева P0; дерево разбора и арены
   построителя уничтожаются с построением; L1-транслятор сравнивает указатели тех же строк; остановленный WIP 308 не
   используется. Маршрут (Codex 2026-11-09, маршрут 331): чистый граф берёт сам существующий frontend F, модуль за
   модулем, первым — машинный модуль `lmx_schedule`, без второго транслятора и без адаптера Lmx → P0; граф F читает
   через ядро, поэтому исполняется программой, связанной с runtime. Шаг 1 (срез 336,
   [запись](../steps/witnesses/frontend-host-20261109/notes.md)): `build-frontend-host` строит языковой корень
   `tools/l2trans.lm2` — argv программы в собственную командную строку frontend `lm_compiler_cli_main`, модули frontend
   собирает L3 (`decl_write` 60: текст собственного корня frontend без его C `main`) — и связывает с `rt/driver.o`; на
   пути P0 он даёт L1 seed байт в байт (`lmx_schedule`, `lmx_graph_run` с заголовком, программа `graph_trans`). Шаг 2
   (срез 338, [запись](../steps/witnesses/graph-machine-20261109/notes.md)): первое слово `--graph` командной строки
   hosted F выбирает вход из чистого графа (`l2_frontend_graph.lm2`, `lm_compiler_graph_main`). Общий построитель —
   теперь отдельный модуль `l2_graph_build.lm2`, общий с graph_trans, — строит граф единицы в арене трансляции, обход
   корня открывает namespace трансляции (Structure каждого записанного `fn:` с частями args, return и body), машинный
   модуль пишется из этих Structure в форме F (метка, преамбула объявлений C-двери, один блок prototype, имена формалов
   `l2_p<f>_<j>_<name>`); имена тела разрешаются по адресам написаний среди формалов; иная форма отказывает на месте,
   отката на P0 нет. `build-runtime … HOSTED-FRONTEND` так переводит `lmx_schedule`: C runtime отличается от прежнего
   только внутри `lmx_schedule_init` и `lmx_schedule_tick`; init/wait/tick/state через C-дверь
   (`tests/cdoor/schedule_machine.lm2`) отвечают 7 на native и walk, мутант `>=` → `>` — 89. Шаг 3 (срез 339,
   [запись](../steps/witnesses/hosted-chain-20261109/notes.md); Codex CODEX-OPUS-338-STEP3-REPLY: собирает готовый
   F(n-1), rt(n) — его результат): hosted F — frontend цепочки. Поколение переводит объекты нового frontend и модули ядра
   своего runtime hosted F предыдущего поколения — `lmx_schedule` из графа в каждом runtime, ни один runtime не берёт его
   из дерева P0, — связывает новый hosted F с этим runtime последним (его объекты никогда — с прежним runtime) и всё
   дальнейшее (smoke, tool) переводит им; отдельный frontend не строится. Связка frontend — `l2trans.exe`,
   `l1trans.exe`, `l2_libc.o` — объявляет запуск в `launch.txt` (`0 entry 0 --`, слова драйвера перед собственными
   словами frontend), и его читает каждый рецепт, запускающий frontend (`bld_frontend_launch`), а не имя программы. Из
   seed-связки fehost03 (собрана обычным seed, связана с rt65) `bootstrap quick` построил G1 и G2 с hosted frontend:
   C их runtime совпадает с rt65 байт в байт, G1 и G2 различаются только штампами связывания (frontend, backend, tool;
   их L1 и C — одни байты). Шаг 4 (срез 340, [запись](../steps/witnesses/clock-graph-20261109/notes.md)): `lmx_clock` —
   второй модуль, который каждый runtime переводит из графа. Граф-путь читает формы, которыми он написан: типы C-двери
   `c.T` у формалов и результата, собственные места функции `T: name [value]` и `@: name T [value]` (объявлены на её
   входе как `l2_q<k>_<name>`, пишутся там, где написаны), `cast:`, вызовы C-двери и функций модуля, выражение в
   скобках — как его единственное поле. Фактические вызова и операнды операции вычисляются один раз, в лексическом
   порядке: значение, вычисляемое до более позднего вызова, сначала держится в локале своего типа (`l2_t<k>`;
   фактический функции модуля — типа её формала); значение без C-типа в графе — вызов C-двери, поле через путь, — которое
   пришлось бы удержать, отказывает на месте, как путь P0 отказывает такой фактический C-вызова. `lmx_clock` не держит
   ни одного значения: C runtime rt67 отличается от rt66 только в четырёх функциях `lmx_clock` (их вызовы записаны
   прямо), а его объекты — те же байты; через C-дверь (`tests/cdoor/clock_machine.lm2`) они отвечают 7, мутант `<` →
   `<=` в `lmx_deadline_passed` — 82. fehost03 этих форм не читает, поэтому цепочка начинается с промежуточного
   поколения — связки fehost07 (её объекты переводит fehost03, связана с rt66): `bootstrap quick` из неё построил G1 и
   G2 без отказов, оба переводят `lmx_schedule` и `lmx_clock` из графа; их runtime совпадают с rt67 байт в байт, G1 и G2
   различаются только штампами связывания (frontend, backend, tool; их L1, C и объекты — одни байты). Шаг 5 (срез 342,
   [запись](../steps/witnesses/door-roles-20261109/notes.md)): `lmx_process_deadline` — третий модуль из графа. Роль
   имени C-двери `c.X` в голове Frame — роль его C-объявления (ответ Codex CODEX-OPUS-341-DOOR-HEAD-REPLY), а не
   двоеточие, скобки или число фактических: граф-путь спрашивает её у существующего импорта C-двери фронтенда по
   predef-замыканию корня единицы и освобождает импорт до выпуска модуля; функция прототипа и необъявленное имя —
   вызов, struct/fnptr-тип — объявление места (такое место пока отказывает), `c.sizeof` — оператор C; строковый
   литерал пишется как написан. Перед этим срез 341 снял фиксированные 2048 байт списка типов заголовочной единицы
   бэкенда ([запись](../steps/witnesses/header-types-20261109/notes.md)). C runtime rt68 отличается от rt67 только в
   трёх функциях `lmx_process_deadline`; через C-дверь (`tests/cdoor/deadline_machine.lm2`) они отвечают 7, мутант
   зажима `INFINITE - 1` → `- 2` — 87. Цепочка начата с промежуточной связки fehost09: `bootstrap quick` построил G1 и
   G2 без отказов, их runtime совпадают с rt68 байт в байт, G1 и G2 различаются только штампами связывания. Следующий
   шаг — следующие машинные модули (`lmx_turn` уже переводится из графа).
4. **Участки арены как единственное хранилище.** `LmxPool/LmxChunk/LmxRange` → участки с индексом интервалов; точные
   размеры участков в выпуске; attach/mark/revert/GC по §2.
5. **Полные итоговые проверки:** весь реестр на обоих исполнителях, bootstrap quick и full, checks, landing, docs render и
   check; п. 6 целиком.
6. **Приёмка перехода.** (а) Нет сравнения строк идентификаторов ни в одной исполняемой цепочке и ни в одном проходе
   транслятора (аудит по грепу `memcmp/strcmp/strncmp` с классификацией остатков по роли), нет `LmxSourceName`, таблиц
   мест, `LmxOp`, числовых кодов, постоянных карт обхода, признаков инициализации вне участков, сохранённых в графе
   результатов разрешения имён; (б) **критерий чистого обхода**, фикстурами языка (`lmxtool`/L2, не maintained runner на
   Python/Perl): программа P (1) строится и исполняется — результат R1 сравнивается с ожидаемым E1, на native и на
   интерпретаторе каждый; (2) изменяется во время исполнения (запись поля, `merge`, построение кода из данных) и исполняется
   снова — результат R2 сравнивается с ожидаемым результатом **изменённой** программы E2 (не с R1), native и интерпретатор
   для этого состояния каждый; (3) `sys\toLmx` изменённого графа, `sys\fromLmx` во **вторую арену, живую одновременно с первой**,
   исполнение там — R3 = E2, и следующий чистый обход первой арены даёт снова E2; между обходами в процессе нет ни одного
   живого объекта таблиц обхода и нет дерева P0 (проверка освобождения на всех выходах, включая бросок и остановку Thread);
   (в) `sys\toLmx` единицы со Structure данных, частью `data` метода (прежде `var`), местом без значения, методом,
   выражением и Array совпадает с программой по составу
   и порядку; (г) соразмерные свидетели явной компиляции/endturn без автоматического сброса native (§6.5); (д) паритет native/интерпретатор на всём реестре; (е) полная
   самосборка.
7. **Карта удаления подготовленной формы** (что и на каком этапе исчезает): этап 2 — `lmx_ids`, `l2_ids`, коды,
   `LmxSourceName`, таблицы мест, `PLACE`, `LmxCallPlaces`, `LmxActivationBinding`, порты `lmx_source_name_*_at`,
   `LMX_WALK_OP_*`-кадры, `LmxOp`, числовые селекторы слотов, `l2_bn`, `LmxPool.role/profile`, боковые массивы
   `LmxRange`, `LmxCodeLink`, постоянная карта `implements`, `LmxChunk.value_contexts`; этап 3 — `LmP0Text\code`,
   `l2_words`, дерево P0 как вход frontend, индексы предефов `l2_pd`/`pdx`, сгенерированные строители `l2_rw*`;
   этап 4 — `LmxPool/LmxChunk/LmxRange`.

**Решено вторым ревью Codex** (CODEX-FABLE-KERNEL-SPEC-REVIEW2-20261108T185727823Z-01): имя — по адресу самого примитива
или Lmx (§5.1); прежнее пояснение о чтении `uninit:T` заменено последним ответом автора: внутренняя адресация прозрачна,
`i` остаётся `int`, слот не меняется (§3.2). `@: p` без адреса — `uninit:ref`, `Point: p` без значения — обычная Lmx объявления (§3.4); Array — Lmx со слотами
без особой inline-формы (§3.1). Единственный вопрос второго ревью — что адресует `@i`, взятый до первого присваивания, —
**закрыт автором 19:02Z** (CODEX-FABLE-AUTHOR-UNINIT-POINTER-SAME-CELL-20261108T190254726Z-01): «T без инициализации» —
указатель на ту самую ячейку T, тип ячейки при первом присваивании не меняется, `@i` до и после адресует одну ячейку
(§1 п. 4, §3.1, §3.2); открытых вопросов автору нет.
