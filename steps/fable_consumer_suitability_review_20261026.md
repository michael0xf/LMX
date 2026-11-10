# Fable: пригодность структуры для реальных Consumer-вызовов (первая часть `implements`)

Дата: 2026-10-26. Автор: fable_pc, независимый консультант Codex (read-only).
HEAD: `39e88ac6c85394afd5d7cfbc8fc789890b953157` (уточнение термина поверх Verified227 `cda0ba49`).
Рабочее дерево на момент разбора: только untracked `steps/witnesses/fix208|209|210|217-*`,
`steps/witnesses/used-scope-20261020/reference-producer117.patch` и protected basename в корне.
Ничего из этого не читалось, не хешировалось, не копировалось и не менялось. Корневой `build` не тронут.
Сборок, тестов, bootstrap, корпуса, runner, веток, worktree, коммитов нет. Единственная запись — этот файл.

Это разбор первой части допуска: пригодности структуры для **реальных** вызовов Consumer.
Слово «аналитическая» ниже относится только ко второй части — `test` — и здесь не используется для первой.
Сравнение ABI, всех сигнатур, арности или числа слотов первой частью не является; это ниже показано на коде.

## 1. Что прочитано

Инструкции и нормы: `AGENTS.md`, `READ.ME`, `steps/current.md` (1–220), `next_core_tasks_v3.md` (целиком),
`next_core_tasks_v3_checklist.md` (строки 41, 46, 610–712), `L2_L3_CODING_INSTRUCTION.md`,
`LMX_blog/2026-10-26.md`, `provenance/semantics-book.md` (admission, строки 215–300 и grep по
`implements`/`Consumer`), `docs/L2_spec_ru.md` §14, `docs/L1_spec_ru.md` §15.

Код (все хеши совпали с pins пакета 227, `steps/witnesses/fix227-20261026/notes.md`):

| Путь | SHA256 (префикс) | Прочитанные места |
| --- | --- | --- |
| `dev/l2src_sandbox/lmx_implements.lm2` | `bf0996ae` | 1–330, 396–660, 818–1000, 1185–1760, 2152–2220, 2895–3040, 3056–3200, 3300–3405, 3538–3650 |
| `dev/l2src_sandbox/lmx_walk_values.lm2` | `8875e29a` | 220–260, 462–600, 673–700, 1573–1830, 1886–2000, 2100–2420, 2820–3000, 3240–3300, 3344–3720, 4190–4215 |
| `dev/l2src_sandbox/l2_consumer_uses.lm2` | `45d9e429` | целиком |
| `dev/l2src_sandbox/l2trans.lm1` | `2331696c` | 5660–5690, 32180–32225, 35694–35775, 45860–45960, 46154–46240, 47360–47740, 50335–50520, 51113–51175, 51384–51520, 52630–52790, 52997–53060, 53205–53245, 58840–58875 |
| `dev/l2src_sandbox/l2_application.h.lm1` | `aedd76dc` | структуры L2ConsumerCallUse 491, L2PathFact 504, L2UsePlanEdge 541, L2UseScope 575, L2SourceSite 661, L2ExpressionSite 775 |
| `dev/l2src_sandbox/lmx_implements.h.lm1`, `lmx_implements_resolve.h.lm1`, `lmx_arena.h.lm1` (LmxImplEntry 32–55), `lmx_walk.h.lm1` (78–108, 395–440, 484–524, 540–575) | generated copies | |
| `tools/l2/build.lm2` | `4e512060` | 863–938 (`decl_implements`, `decl_implements_resolve`), 2687–2751 |
| `tests/l2/lib/lib_owner.lm2`, `tests/l2/lib/lib_m.lm2` | | целиком |
| `steps/witnesses/fix227-20261026/notes.md`, `carrier-native01.command`, хвост `carrier-native01.log` | | |
| `build2/codex_fix228consumeradmit01/pins/plan228.md`; `.../src/l2src/lmx_walk_values.lm2` (`b4d3c2d5`) | | только diff к sandbox-версии (230 строк) |

Генерируемые L1/C, корпус, другие стадии `build2`, transcripts, `l2_driver_launch.err` не читались.

## 2. Норма, против которой сверялся код

Книга семантики (`provenance/semantics-book.md`, admission, RU 219–236, EN 255–272):

- Первая часть — проверка пригодности структуры для реальных вызовов Consumer через направленный
  `implements(aVar, bVar, Consumer)`; при наличии Consumer анализ охватывает его известные обращения к `bVar`,
  неиспользуемые поля не сравниваются; «неизвестный вычисляемый путь не объявляется проверенным».
- «Если Consumer явно вызывает поле, проверяются только записанные вызовы: фактические и именованные аргументы,
  умолчания и доступные преобразования должны удовлетворять выбранному интерфейсу и действительному дескриптору
  реализации; результат и объявленные выходы — требованию Consumer. Непрозрачная передача callable не проверяет
  будущих вызовов.»
- «Анализ не исполняет кандидата, Consumer, метод или преобразователь и не разворачивает все тела вызываемых методов.»
  Положительный результат — общая физическая карта для любой допущенной пары Structure; доступ к сопоставленным полям
  не ищет имена заново (L2 §14, L1 §15).
- «Совместимость аргументов известного вызова проверяется при трансляции; при динамическом выборе — при допуске
  выбранного callable к данному вызову.»

Отсюда три следствия, важные для кода: (1) предмет проверки — записанные вызовы Consumer, а не сигнатура поля;
(2) проверка не исполняет ни одно тело и не ждёт входа в callee; (3) для динамически выбранного callable
(поле Structure-формала или допущенной ссылки) эта проверка происходит в момент допуска кандидата, не в момент вызова.

## 3. Трассировка текущей цепочки (227)

### 3.1 Транслятор: от записанного вызова к шестому слоту record

1. `l2_check_call_arguments` (`l2trans.lm1:35722`): для вызова с головой-путём (`l2_head_follows_value`) и `fi < 0`
   вызывает `l2_use_invoked` (32193), который через `lm_compiler_consumer_call_note` (`l2_consumer_uses.lm2`)
   сохраняет в `L2PathFact\calls` строку `L2ConsumerCallUse` {method, source (P0 узел CALL), signature (CHECK),
   formal, use_site (полный source environment)} и ставит `use_roles |= 4`.
   Вызов через callable-формал (`fi >= 0`, как `f()` в `plus1`) строку **не** получает; это сознательная граница 227
   («root callable formals and forwarding contexts still need occurrence-bearing coverage»).
2. `l2_use_plan_path` (51113): шаг `kind = 4` в конце пути с `use_roles & 4` даёт ребру `edge\called: 1`,
   `edge\calls: fact\calls` (51153). Любое другое употребление callable — `whole`.
3. Покрытие (coverage) записывается `l2_emit_scope_cells` (50335) по `l2_use_scope_cell` (51482):
   уровень = `[count, (edge, below)*]`, `below = -2` (`SIZE_MAX-1`) для called-ребра. Координата пары:
   `l2_use_scope_level_at(scope, level) + 1 + 2*ordinal` (51449); для корневого уровня первая пара в ячейке 2.
4. `l2_rw_receiving_record` (50375) строит record ширины 6: `[catalog, coverage|0, mode, references,
   source_context, call_uses]`; `call_uses` — plain holder `1 + 5*n` ячеек, ячейка 0 = 0 до fixup.
5. `lm_compiler_consumer_calls_emit` (end-of-view fixup, вызовы в 62682/63598/70398) для role-3 сайтов
   со связанным PLACE пишет count и строки `[coordinate, Consumer-code, CALL, null, null]`; CALL берётся из
   role-4 сайта той же view (`consumer_call_site`), иначе ячейки остаются null. Consumer-code — курсор на
   `l2_sc%zu`/`l2_entry_unit` метода-владельца вызова (`consumer_build_cursor`), то есть occurrence кода, без data home.
6. ADMIT_AS везде одинаков: `l2_rw_admit_project_at` (53219) → `[admit_as, record, flag, candidate, model]`;
   рецепция формала `l2_rw_reception` (58851) → `[set_arg, k, [admit_as, record, 0, [arg, k], model], witness]`
   с фасетом RECEPTION. Native trampoline читает тот же record (`l2_emit_tramp_receptions`, 45860).

### 3.2 Runtime: от record к общему DFS

- Walked: `lmx_walk_enter_parts_values` (1918) → `lmx_walk_snapshot_args` (1721, только ENTRY-входы)
  → `lmx_walk_receive` (1886) → `lmx_walk_reception_parts` (1828, декодирует record ширины 6, слот 5 не читает)
  → eval ADMIT_AS → `lmx_walk_admit_op`/`lmx_walk_admit_in` (2318) → `lmx_walk_value_admit` (227)
  → `lmx_implements_admit_receiving_frame`/`_parts` (3329).
- Native: `l2_emit_tramp_receptions` копирует `lmx_input_values` в `l2_received[]` (memcpy при входе) и для
  каждого Structure-формала вызывает `lmx_walk_receiving_header_model` + `lmx_walk_value_admit` с `l2_cp%d` —
  тем же record. Паритет native/walked обеспечен общим ядром ниже.
- `lmx_implements_admit_receiving_parts` (3329–3387): проверяет ширину 6, читает слоты 0–4, строит
  `LmxImplUses{frame: coverage}` при mode 2, **слот 5 не читает**; → `lmx_implements_admit_template_frame_typed`
  → `lmx_implements_admit_operation` (3063) → `lmx_implements_walk_project_resolve` (1338).
- В DFS называемое покрытием ребро с `below = SIZE_MAX-1` даёт `called = 1`, `enter = 0` (1489–1495); у поля
  с `c = required\cell` (дескриптор поля модели) и `a` (значение кандидата по карте) выполняется (1582–1587):
  `lmx_implements_call_takes(arena, a, c)` и при `b != a` ещё раз для `b`.
- `lmx_implements_call_takes` (1281) сравнивает args/return части через `lmx_callable_entry` (1215) и
  `lmx_implements_call_positions` (1242): равная ширина args; на каждой позиции равные kind/type witness-ячеек;
  для pointer-типов равенство **адресов pointee** witness-ячеек; для не-примитивных позиций args — любой объект
  принимается (`received = 1`), в return — UNKNOWN. Умолчания, преобразования, выходы, результат Consumer —
  не рассматриваются (комментарий 1189–1213 это честно называет OPEN).

### 3.3 Где сегодня реально проверяется вызов

Фактическая проверка аргументов происходит только в момент вызова: `lmx_walk_call` (3344) → `lmx_walk_actuals_values`
(2820) сверяет каждое значение с witness контракта и затем callee при входе принимает формалы своей рецепцией
(`lmx_walk_receive`). Это **второй** момент (исполнение), а не первая часть допуска. Поэтому отказ `33`/`34`
в S8.1 сегодня возникает «where M receives it», то есть на входе в `lib_m_bump`, а не при допуске экземпляра к `LibM`.

### 3.4 Что добавляет private228 и чего не добавляет

Diff `b4d3c2d5` к `8875e29a`: три arena-only readers `lmx_walk_shape_op`, `lmx_walk_call_shape`,
`lmx_walk_actual_shape` (вставлены после 2819) и их переиспользование в `lmx_walk_actuals_values` и `lmx_walk_call`
вместо inline-разбора формы CALL/EXEC и NAMED. Readers не читают слот 5, не сравнивают ничего, не выбирают callee.
Это подготовка формы (envelope/coordinate), не подключение Consumer rows и не допуск.

## 4. Существенные дефекты и их последствия

**D1. Первая часть сегодня — именно то, что автор исключил.** На called-ребре решение принимает
`lmx_implements_call_takes`: ширина args, kind/type по позициям, равенство ширины return. Записанные вызовы
(слот 5) не читаются. Следствия: кандидат с формалом другой модели проходит YES (Structure-позиции в args
не решаются, `received = 1`), а провал откладывается на вход в callee при исполнении; умолчание (пустой operand
при равной арности) даёт NO по ширине или проходит без проверки fallback; преобразования и выходы не видны вовсе.

**D2. Носитель строк оборван на входе в ядро.** `LmxImplUses` (header 40–44) переносит только `map|frame|at`;
`lmx_implements_admit_receiving_parts` не читает слот 5. Даже если бы DFS хотел строки, их негде взять без
скрытого контекста. Это ровно место подключения (§7.1).

**D3. Координата пары в DFS затирается.** В `walk_project_resolve` индекс ячейки пары вычисляется
(`index: current\level + 1U + index * 2U`, ~1476) и сразу переписывается значением `edge` (~1487). Для поиска
строк по coverage-coordinate его нужно сохранить отдельно: координата транслятора считается по тому же закону
(`level_at + 1 + 2*ordinal`), что подтверждено свидетелем 227 (coordinate 2 для первой пары корня).

**D4. Ранняя публикация вложенного допуска — реальный риск при наивном подключении.** Любой кадр DFS, потребивший
поле, вызывает `lmx_implements_prepare_view` → запись в `resolver\views`; `admit_operation` после YES публикует
**все** views (`lmx_implements_publish_views`, 2929–3030). Если сверку actual-модели с формалом кандидата
делать дочерними кадрами того же resolver, пары «модель актуала → модель формала кандидата» станут опубликованными
доказательствами, хотя значение ещё не передавалось. Вложенная сверка обязана идти в отдельном resolver с
`lmx_implements_resolve_close(arena, resolver, 0)` (без публикации).

**D5. Null-ячейки CALL/result/exits не имеют читателя, значит не имеют и смысла «отказ».** 227 честно пишет
«Null demands are not blanket permission», но пока слот 5 не читается, это декларация. При подключении
null CALL для called-ребра должен давать UNKNOWN (отказ), а не возврат к `call_takes`. Это может изменить
зелёные программы, где `consumer_call_site` не нашёл сайт (`site\count != 1`, `value_type != signature`,
неоднозначная view): число таких строк в S8.1 программах неизвестно и его надо измерить до переключения (§8).

**D6. Pointer-типизированные позиции сравниваются по адресу pointee между домами.** `call_positions`
для witness pointer-типа требует `lmx_pointer_value_in(a) = lmx_pointer_value_in(b)`; у провайдера и у
требующего дома pointee — разные occurrence модели, значит такой интерфейс (`@: p Model` в args дескриптора)
даёт UNKNOWN всегда. Фикстуры S8.1 этого не покрывают (у них `Model: m`, witness типа LMX). Латентно; проверить.

**D7. Строки есть не для всех called-рёбер семантики.** Вызов через callable-формал (`plus1`: `f()`) и forwarding
не дают строк (3.1 п.1); такие формалы идут через actual-class receiving set (`l2_rw_call_class_receiving`, 50429)
и остаются OPEN. Подключение §7 этого не закрывает, но построено так, чтобы те же record/rows подошли и им.

**D8. Преобразования не представлены в графе.** Конверсии вставляются транслятором как синтетические EXEC с фасетом
`LMX_WALK_SOURCE_CONVERSION` (54740) по таблице `l2_convert_*` (13224–13415), а 227 записывает только исходный
EXEC. Runtime-таблицы доступных преобразований record не несёт. Следовательно позиция с несовпадающим
примитивным представлением в первой части — NO/UNKNOWN, а не «найдём преобразование»; это не дефект 227,
а граница, которую нужно явно зафиксировать в читателе.

**D9. Копирование строк не проверено мной.** 227 утверждает, что ссылки Consumer-code/CALL — обычные graph refs
под картами копирования/квалификации. `lmx_graph_copy_owned.lm2` я не читал; при merge Consumer-occurrence
строки должны указывать на копию, иначе «текущий Consumer home» будет исходным. Вопрос Codex (§10).

## 5. Consumer home и текущие значения формалов

Что есть в коде:

- Walked: `lmx_walk_admit_in` (2318) для RECEIVING-допуска строит копию кадра `space` с `code = source = node =
  receiver` и **обнулёнными** `args/nargs/work/place_table`. В этом доме вычисляется только model operand
  (слот 4). Никаких значений формалов там нет.
- Native: `l2_emit_tramp_receptions` берёт `l2_received[]` как memcpy входов при входе и последовательно
  (k = 0..arity) допускает формал k. При допуске формала k значения `l2_received[j]` для `j > k` ещё не приняты
  (их model/references не установлены), а для любого j позднейшая запись в теле (`seven: other`) недоступна.
- Walked-рецепция `lmx_walk_receive` идёт в живом кадре callee с `f\args`, но тоже по порядку k.

Вывод: ни `l2_received[]`, ни `f\args`, ни `space` не являются «текущими значениями формалов» в момент
первой части. Если Consumer-строка `x\m(seven)` для формала `x` читается при рецепции `x`, значение `seven`
либо ещё не принято (j > k), либо может быть перепривязано позже в теле. Снимок trampoline — состояние входа,
не позднейшее.

Поэтому первая часть должна читать **требования** актуалов, а не их значения, и читать их из деклараций в
текущем Consumer-code:

- ARG-актуал `[arg, ordinal, fallback?, type-witness]`: witness в слоте 3 (его ставит `l2_rw_input_witness`,
  46210, через `l2_declared_graph_witness`, 46154: для Structure-формала — occurrence модели, для callable —
  occurrence дескриптора). Это декларация формала Consumer, одинаковая для native и walked и не зависящая от
  порядка рецепций и от перепривязки.
- OWN/OWN_OF: reference-cell-witness (слот 3, если есть) или типизированная ячейка данных по карте; без witness и
  без карты — UNKNOWN.
- LIT: типизированная ячейка; вложенный CALL/EXEC: return-часть его контракта (`lmx_callable_entry(returns, 0)`);
  OF/PUT_OF: `req` и slot через `lmx_implements_contract_field`. Остальные формы — UNKNOWN («неизвестный
  вычисляемый путь не объявляется проверенным»).

«Текущий Consumer home» при этом = фактически исполняющийся occurrence Consumer-code (после копии — копия,
см. D9) плюс его собственные декларации; data-экземпляр и значения формалов — вход второго момента (вызова),
где callee принимает фактическое значение своей рецепцией. Это согласуется с нормой: переприсваивание формала
само проходит допуск к его объявленному требованию («замена ветви сначала допускает нового кандидата»),
поэтому объявленное требование — корректная верхняя граница того, что Consumer передаст.

Если Codex в 228 планировал строить Consumer home из `l2_received`/`lmx_input_values`, это надо остановить:
кроме несвоевременности снимка, это сломает паритет (у walked-пути такого массива в `lmx_walk_admit_in` нет).

## 6. Структуры, созданные во время исполнения

Кандидат без template/identity-layout/зарегистрированной карты уже обслужен DFS: `lmx_implements_resolved_view`
(525) → при отсутствии source/pending/stored/direct доказательств — `lmx_implements_named_resolve` (имена мест
через `lmx_source_name_get`, вне графа). Это коррекция адресов, не разрешение.

Для первой части важны три случая:

1. Экземпляр библиотеки (`lib_m_new()`): его callable-поля — occurrence методов провайдера с args/return
   частями, SOURCE-парами 226 и THROWS-заголовком (`lmx_walk_throws_node`, 556). Всё читаемо без исполнения.
2. Актуал без объявленного требования (поле, записанное из динамического источника, void-ссылка): требования
   нет → UNKNOWN для этой позиции, отказ допуска по норме. Не угадывать модель по значению.
3. Карты: сверка строк не создаёт и не регистрирует карт для значения; единственная публикуемая карта — пара
   (value, req) корневой операции, как сейчас. Карта для фактически переданного значения публикуется callee при
   его рецепции в момент вызова (существующее поведение). Вложенные сверки — без публикации (D4).

## 7. Минимальный связный шаг через существующие call/implements механизмы

Без отдельного library comparator, без скрытого контекста (строки приходят в том же record), без публикации
вложенных допусков, без нового L2 syntax, runner или C-layout. Один dependency-closed срез.

### 7.1 Носитель: `LmxImplUses.calls`

- `tools/l2/build.lm2:868` (`decl_implements`, текст `struct: LmxImplUses`): добавить поле `@: Lmx calls`
  (узел слота 5 record, или 0). Header — generated copy; регенерировать через существующий `bld_headers`
  (`dev/l2src_sandbox/lmx_implements.h.lm1` руками не править).
- `lmx_implements_admit_receiving_parts` (3329): после чтения слота 1 прочитать слот 5: Structure ширины
  `1 + 5*count`, ячейка 0 — size_t metadata cell (как `lmx_implements_use_cell` проверяет ячейки покрытия),
  `count > 0` при `mode != 2` → UNKNOWN (строки без координат); `scope\calls: node`. Для каждой строки
  координата — metadata cell size_t внутри extent покрытия и указывающая на пару с `below = SIZE_MAX-1`;
  иначе UNKNOWN. Ячейки +1/+2 — graph refs или null; +3/+4 сейчас null.

### 7.2 Точка решения: called-ребро DFS

В `lmx_implements_walk_project_resolve`:

- сохранить индекс ячейки пары в отдельную переменную до `index: edge` (D3);
- при `called != 0`: вместо `lmx_implements_call_takes` перебрать строки `uses\calls` с этой координатой.
  Нет ни одной строки или CALL null → UNKNOWN (D5). Для каждой строки → `lmx_implements_call_written(arena,
  a, c, row, references, source_references)` (новая fn в `lmx_implements.lm2`); любая не-YES → итог.
  `b != a` — так же для `b`. `call_takes` после этого не нужен на этом ребре (оставить только если Codex решит
  держать его как диагностический дубль; я бы удалил, чтобы не было двух правил).

### 7.3 `lmx_implements_call_written`: одна записанная строка против кандидата `a`

Все чтения — arena-only, ничего не исполняется:

1. Конверт: `lmx_walk_call_shape(arena, CALL)` (228) → op, first, count, selector, data, contract.
   Контракт строки — `c` (дескриптор поля требования); `contract` узла CALL может его дублировать, не заменять.
2. Позиции: для j в `0..count-1` — `lmx_walk_actual_shape` → `at` (NAMED: слот 1), payload, named.
   Повтор `at` → UNKNOWN; `at >= width(a\args)` → NO; `count != width(a\args)` → NO (runtime CALL и так требует
   равную арность: `inputs_fields\size != n → INVALID` в `lmx_walk_call`). Пустой payload при `at` → умолчание:
   у кандидата в теле должен быть `[arg, at, fallback, witness]` с непустым fallback (слот 2); нет → NO.
   Обход тела кандидата для ARG — та же рекурсия, что `lmx_walk_entry_node`, только arena-only и без load.
   Если этот поиск Codex считает отдельным срезом, в первом шаге пустой payload → NO с явной пометкой «defaults
   OPEN»; не YES.
3. Требование актуала: по §5 (witness/ячейка/return-часть/req), результат — kind/type и, для Structure/callable,
   модель-occurrence `A_j`.
4. Формал кандидата: `lmx_callable_entry(a\args, at)` → (source, witness). Witness STRUCT → модель `M_j` =
   witness; pointer-witness → pointee; отсутствует (foreign by-value, native-only) → UNKNOWN в первом шаге
   (проекция SOURCE через декодер 226 требует кадра walker; см. Q2).
5. Сверка позиции:
   - примитив: kind/type равны → продолжить; иначе NO (преобразований в графе нет, D8);
   - Structure или callable: найти у кандидата рецепцию формала `at` (SET_ARG RECEPTION в его body-части,
     `lmx_walk_reception_parts(arena, …)` — arena-only) и выполнить **непубликуемую** сверку
     `A_j` против `M_j` с покрытием и строками **этой рецепции** (record кандидата: слот 1 coverage,
     слот 3 references дома провайдера, слот 5 его строки). Без рецепции (дескриптор без тела, формал без
     record) — полная структурная пригодность `A_j` к `M_j` (interface = 1, uses = 0) по норме «без Consumer».
     Для callable-позиции это даёт ровно норму: `lib_m_take (unary: f)` не вызывает `f` → у рецепции нет
     called-рёбер → `seven` (`() int`) проходит; `plus1`-подобный кандидат с `f()` → его строка сверяется
     с дескриптором `seven`. Сравнения описаний `nullary`/`unary` как таковых нет.
6. Результат: пока слот +3 null, требованием Consumer служит return-часть `c` (то, против чего CHECK проверял
   потребление результата у Consumer): `lmx_callable_entry(a\returns, 0)` против `lmx_callable_entry(c\returns, 0)`
   по kind/type; Structure-результат — непубликуемая полная сверка модели результата кандидата к модели
   результата интерфейса. Это явно документировать как «демand = интерфейсная return-часть до появления
   producer result-receivers», не как «null = разрешено».
7. Выходы: ключи THROWS-заголовка кандидата (`lmx_walk_throws_node(arena, a)`) ⊆ ключам THROWS-заголовка `c`;
   лишний объявленный выход → NO. Слот +4 (required-exits) пока null; та же оговорка, что в п.6.

### 7.4 Непубликуемая вложенная сверка

Вынести из `lmx_implements_admit_operation` общую часть «открыть временную арену/scratch, построить resolver с
`references/source/source_references/identity_default`, запустить `walk_project_resolve`, закрыть» в
`lmx_implements_reception_analyse(arena, value_model, req_model, record, …)` с `published = 0` и без
`publish_views`. `admit_operation` вызывает её же плюс публикацию. Так вложенный допуск не публикуется (D4),
а правило одно (общий DFS). Рекурсия ограничена записанными вызовами и `seen`-списком кадров.

### 7.5 Слоистость модулей

`lmx_implements.lm2` сейчас не вызывает `lmx_walk_*`; `lmx_walk.h.lm1` предефайнит только `lmx.h`,
`lmx_arena.h`, `lmx_scratch.h`. Нужные readers (`lmx_walk_role_in`, `lmx_walk_load_numeric`,
`lmx_walk_witness_type`, `lmx_walk_throws_node`, `lmx_walk_reception_parts`, 228-readers) — arena-only.
Минимально: `predef: "l2src/lmx_walk.h.lm1"` в `lmx_implements.lm2` (прототипы, цикла заголовков нет).
Альтернатива — перенести arena-only readers в модуль ниже `implements`. Решение за Codex (Q1).

### 7.6 Транслятор и build в первом шаге

Транслятор не меняется: строки, координаты и record уже есть. `build.lm2` — только текст header-writer (7.1).
`runtime.list` не растёт. Второй шаг (отдельно): producers для слотов +3/+4 в `lm_compiler_consumer_calls_emit` —
GraphPlace потребляющего места результата и THROWS/catch-набор Consumer; после него п.6–7 читают их вместо
интерфейсных частей.

### 7.7 Что остаётся OPEN после первого шага (не выдавать за закрытое)

Умолчания (если п.2 отложен), преобразования (D8), SOURCE-проекция для позиций без witness (Q2), строки для
callable-формалов и forwarding (D7), runtime-callable/Q49, general immutable/native effects, result/exits
producers (7.6), копирование строк при runtime merge (D9).

## 8. Проверка шага без новой тестовой кампании

По приоритету автора — минимум: одна инкрементальная трансляция runtime + strict build, затем существующие
четыре S8.1 лога (native/forced, root0/1) через `lmxtool`/L2 main, без нового runner и probe-скриптов.

Ожидания, которые надо наблюдать, а не предполагать:

- Прежние значения: `41/41/42/42/43/42`, `A1=101/A2=43`, `r=142 p.y=42 p.x=1 p.pad=9 q.w=10`, `C=30`,
  `3 → 8`. `try_m` проходит, потому что `Point` (pad, y, x, next→Leaf{v,pad,w}) покрывает рецепцию
  `lib_m_bump` (`m\y` write, `m\x` read, `m\next\w` write).
- `33` и `34` сохраняются, но **момент** отказа переместится: с входа в `lib_m_bump` на допуск экземпляра к `LibM`
  при `@: m2 LibM lib_m_new()` / `@: m4 LibM lib_m_new()`, потому что записанные вызовы `lib_m_bump(q)` /
  `lib_m_bump(f)` с объявленными `Thin` (нет x) и `Far→Bare` (нет w) не подходят формалу провайдера. Handler
  тот же (`catch: implements` в try_n/try_k), `y` у `Far` остаётся 2. Комментарии фикстуры («refused where M
  receives it») описывают прежнее место и подлежат правке вместе с кодом; норма не меняется.
- Существующий вызов native owner с typed reads (форма `carrier-native01.command`) после пересборки должен
  по-прежнему видеть width 31/count 6/coordinate 2 и null в +3/+4 — читатель их не заполняет.
- До переключения на строки измерить число null-CALL строк в S8.1 программах тем же typed-read драйвером
  (D5): если они есть на called-рёбрах, первый шаг их честно отказывает, и это надо знать заранее.

Мутанты и широкий корпус — после рубежа самосборки, как велит автор.

## 9. Границы этого разбора

- Код не собирался и не запускался; все выводы — чтение источников и свидетелей 227.
- Отождествление `unit[23]` в свидетеле 227 с конкретным методом owner-программы не проверено (generated L1 не
  читался); использовано только то, что утверждает `carrier-native01.command`.
- Тип witness для Structure-формала (`LMX_TYPE_LMX`, occurrence модели) выведен из `lmx_walk_witness_type`
  и `l2_declared_graph_witness`; не подтверждён прогоном.
- `lmx_walk_projection_at`, `lmx_graph_copy_owned.lm2`, `l2_use_plan_*` целиком, `convert.lm2` и
  генерируемые ABI headers 227 не читались.
- Стадия 228 читалась только в разрешённых двух файлах; её runtime01 не рассматривался.
- Норма понята по книге семантики и парным спецификациям; при расхождении с устными уточнениями автора
  первичен блог.

## 10. Вопросы Codex

1. Слоистость: допустим ли `predef: "l2src/lmx_walk.h.lm1"` в `lmx_implements.lm2` ради arena-only readers
   (7.5), или переносить readers в модуль ниже `implements`? Есть ли ограничение в `runtime.list`/порядке L3-писателей?
2. Модель формала кандидата: достаточно ли физического witness из header entry (STRUCT/pointee), или
   требуется проекция SOURCE через декодер 226 (`lmx_walk_receiving_header_model`, нужен кадр walker)?
   Если второе — согласен ли ты на явный fnptr проекции в `LmxImplResolve`/`LmxImplUses` (как `LmxPointerCellRead`),
   а не на перенос проекции под `implements`?
3. Перемещение момента отказа `33`/`34` (§8) — принимаешь как следствие нормы без вопроса автору?
   Я считаю да: норма прямо требует проверки записанных вызовов при допуске; комментарий фикстуры — не норма.
4. Null-CALL строки: подтверди измерением число таких строк на called-рёбрах в S8.1 перед переключением;
   согласен ли, что первый шаг даёт на них UNKNOWN без отката к `call_takes`?
5. Результат/выходы: принимаешь ли интерфейсную return-часть и THROWS-заголовок дескриптора как Consumer-демand
   первого шага (с явной пометкой), а producers слотов +3/+4 — вторым срезом?
6. Строки при runtime merge/копии: подтверди, что копировщик перенаправляет ссылки слота 5 на копию Consumer-occurrence,
   иначе «текущий Consumer home» после merge будет исходным (D9).
7. Планировал ли 228 строить Consumer home из `l2_received`/`lmx_input_values`? Если да — см. §5; это надо снять до
   подключения строк.
8. Умолчания через fallback ARG (7.3 п.2): включаешь в первый шаг или оставляешь явным NO с пометкой OPEN?

Этот файл — единственный мой результат; writer/build не принимаю, lmx_uds не использую.
