# Текущая редакция сравнений и функций ядра

**23 ноября 2026 года.** Основа — `spec.tar(1).gz`, SHA-256 `9d1820dd6c9c459ceff17eb0b92e148f31041bebfef8d641e6e71b314d8eb13a`. Историческое восстановление коротких примеров из `22-Nov-2026-3.tar.gz` уже входит в загруженную основу; этот старый архив не требуется для текущей сборки.

## Что изменено

Восстановлены краткие сопоставимые клиенты и реализации. Обобщённые или асинхронные варианты с другим договором сохранены отдельно. В повторяющемся коде используются обычные функции и copy; динамическое связывание не заменяется лексическими обходами.

Функциональные клиенты имеют обе полные LMX-формы. В исходной восстановленной редакции GoF были изменены два LMX-листинга: Visitor использует общее тело обработчика, Abstract Factory копирует общий набор методов. Эти изменения уже присутствовали в свежем загруженном архиве. Иностранные исходники в текущем обновлении сохранены; в 084 Haskell использует собственный ResourceFailure и типизированный catch.

Каталог содержит **212** канонических публичных имён и **224** типовых вариантов. Все исходные имена имеют явную миграцию в CANONICAL_MIGRATION.json; прежние callable aliases не публикуются. Имя объединяет перегрузки по типам, обе формы сохраняют один алгоритм. Исторические addition manifests считаются по канонической идентичности и варианту.

## Семейства стандартных операций

| Метаданные исторического добавления | Канонических записей |
| --- | ---: |
| [CORE_STANDARD_FUNCTIONAL_ADDITIONS.json](LMX_Fn_Receivers/CORE_STANDARD_FUNCTIONAL_ADDITIONS.json) | 33 |
| [CORE_STANDARD_LISP_ADDITIONS.json](LMX_Fn_Receivers/CORE_STANDARD_LISP_ADDITIONS.json) | 10 |
| [CORE_STANDARD_NUMERIC_ADDITIONS.json](LMX_Fn_Receivers/CORE_STANDARD_NUMERIC_ADDITIONS.json) | 15 |
| [CORE_STANDARD_OBJECT_ADDITIONS.json](LMX_Fn_Receivers/CORE_STANDARD_OBJECT_ADDITIONS.json) | 16 |
| [CORE_STANDARD_TEXT_ADDITIONS.json](LMX_Fn_Receivers/CORE_STANDARD_TEXT_ADDITIONS.json) | 15 |

## Стандартные операции, включённые в текущую основу

| Имя | Договор | Исходник |
| --- | --- | --- |
| `take(items; count)` | Fresh prefix; count is clamped to 0..length. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `drop(items; count)` | Fresh suffix after a clamped count. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `splitAt(items; count)` | Both slices use one clamped cut; source remains unchanged. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `takeWhile(items; accepts)` | Longest true prefix; predicate runs once per visited item, including first rejection. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `dropWhile(items; accepts)` | Suffix begins with first rejected item; no later predicates are evaluated. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `span(items; accepts)` | One prefix scan supplies both parts, without reevaluating an effectful predicate. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `partition(items; accepts)` | Stable two-way partition with exactly one predicate call per item. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `enumerate(items; start=0)` | Indices are admitted to the current int type from exact arithmetic; no wrapping index is accepted. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `windows(items; width=2; step=1; partial=0)` | Positive width/step; full windows by default. partial permits one last nonempty short window. No suffix after a window reaches the end. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `chunks(items; size; strict=0)` | Nonoverlapping chunks, final short chunk permitted unless strict; invalid size fails before iteration. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `intersperse(items; separatorRecord)` | Insert an admitted separator between items; empty and singleton inputs do not admit an unused separator. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `join(parts; separator)` | Separate sequence parts and concatenate; empty parts returns a fresh empty sequence of separator profile. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `unzip(pairs)` | Reverse the existing zip FxPair protocol; empty input returns two fresh empty record Arrays. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `foldr(items; seedRecord; step)` | Strict finite right fold; step(item,accumulator), right-to-left callback order. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `scanr(items; seedRecord; step)` | Right scan includes the seed at the final position; right-to-left callbacks. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `filterMap(items; transform)` | Map to Maybe and keep present values, preserving zero/empty/reference values. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `mapWhile(items; transform)` | Map to Maybe; stop at first none, without calling later items. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `findMap(items; transform)` | Return the first present callback result; return none when all are absent. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `mapAccumL(items; seedRecord; step)` | step(state,item) returns FxPair(next state,output); callbacks left-to-right. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `mapAccumR(items; seedRecord; step)` | Same stateful transform, callbacks right-to-left, outputs at original positions. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `groupAdjacent(items; keyOf=0; sameKey=0)` | stable grouping; optional identity projection and shared equality, each key computed once | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `replicate(valueRecord; count)` | Finite copies of one ready value record; negative count gives empty; reference values retain one target. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `cycle(items; count; rejectNegative=0)` | Required finite repetition count; nonpositive count gives empty; preflight result size. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `starmap(rows; operation)` | Each ready row becomes one actual vector; one typed callback result per row. No source graph field is executed while reading it. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `zipLongest(first; second; fillRecord)` | Two sequences padded to the longer length with the explicit complete fill value record. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `collect(next; limit=-1)` | Nullary producer through the existing call bridge until its Stop(), or finite limit; other declared failures retain their name and payload inside FxCallFailure. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `includes(items; valueRecord; same=0)` | Ordered short-circuit membership with explicit typed equality; no conflict with regex contains. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `adjoin(items; valueRecord; same=0)` | Return original source if already present; otherwise return a fresh same-profile Array with the new value prepended. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `union(first; second; same=0)` | Unique first occurrences from first then second; pure equivalence relation required. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `intersection(first; second; same=0)` | Unique first-source values present in second, preserving first-source order. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `difference(first; second; same=0)` | Unique first-source values absent from second; set difference, not Haskell list multiset subtraction. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `symmetricDifference(first; second; same=0)` | First-only values then second-only values, each once; use existing difference and concat. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `isSubset(first; second; same=0)` | Every equivalence class from first appears in second; multiplicity is ignored. | [coreStandardFunctional.lmx](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `mapOption(input; transform)` | Map one present payload to a new Maybe; absent input skips transform; Some(null) stays present. | [coreStandardObjects.lmx](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `filterOption(input; accepts)` | Retain the same present container when an int predicate accepts its payload; absent or rejected input yields absence. | [coreStandardObjects.lmx](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `orElse(input; fallback)` | Return the existing payload record or an already evaluated fallback record; result is not a Maybe. | [coreStandardObjects.lmx](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `orElseGet(input; fallback)` | Return the payload record; invoke a nullary fallback only when absent. | [coreStandardObjects.lmx](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `orElseOption(input; fallback)` | Return the original present Maybe, or call the nullary fallback once and return its Maybe unchanged. | [coreStandardObjects.lmx](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `foldOption(input; whenEmpty; whenPresent)` | Invoke exactly one branch, a nullary absent branch or unary payload branch; return its typed result record. | [coreStandardObjects.lmx](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `flattenOption(input)` | Flatten one Maybe-of-Maybe level, retaining the nested container identity; absent outer input skips payload access. | [coreStandardObjects.lmx](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `mapResult(input; transform)` | Map only success payload into a fresh ok result; retain the existing error container without invoking transform. | [coreStandardObjects.lmx](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `mapErr(input; transform)` | Map only error payload into a fresh err result; retain the existing success container without invoking transform. | [coreStandardObjects.lmx](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `orElseResult(input; fallback)` | Invoke one error-to-Result continuation only on err; return its Result without nesting; success identity retained. | [coreStandardObjects.lmx](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `foldResult(input; onError; onSuccess)` | Invoke exactly one unary branch with the corresponding typed payload; return its result record. | [coreStandardObjects.lmx](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `attempt(operation; args=())` | Invoke through existing FxTry; return ok(result record) or err(typed reference record to full original FxOutcome); kernel/admission failures propagate. | [coreStandardObjects.lmx](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `tap(value; action)` | Call one effect with the actual typed payload and return the exact original value record; no deep copying or swallowing failure. | [coreStandardObjects.lmx](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `findField(source; label; occurrence)` | Maybe of the selected physical field record; required zero-based occurrence counts equal ready names only; no payload evaluation. | [coreStandardObjects.lmx](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `hasField(source; label; occurrence)` | Whether that physical named occurrence exists; named uninitialized payloads count as present; no payload evaluation. | [coreStandardObjects.lmx](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `getField(source; label; occurrence)` | Return the existing selected field record; missing or negative occurrence raises FxIndex; no payload evaluation. | [coreStandardObjects.lmx](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `assoc(rows; key; same=0; keyIndex=0)` | First matching row as Maybe; keyIndex=1 covers reverse association with the same search; empty rows skipped. | [coreStandardLisp.lmx](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `pairlis(keys; values; tail=())` | Fresh forward-ordered key/value rows then shallow tail rows; equal lengths required. | [coreStandardLisp.lmx](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `getProperty(properties; key; same=0)` | Maybe of the first matching flat property value; present zero/null differs from absent. | [coreStandardLisp.lmx](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `setProperty(properties; key; value; same=0)` | Update first matching value, otherwise append a key/value pair; return same target Array. | [coreStandardLisp.lmx](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `removeProperty(properties; key; same=0)` | Remove first matching key/value pair; return int 1 if found, otherwise 0. | [coreStandardLisp.lmx](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `getProperties(properties; indicators; same=0)` | First property whose key matches any indicator; Maybe of key/value/index; Array index is explicit, not a Lisp cons tail. | [coreStandardLisp.lmx](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `asOperand(operation; priority)` | Construct one ordinary OPERANDS_TEMPLATE-compatible prepared operand; present left then right actuals, exact source R/void and named failures. No new syntax mode. | [coreStandardLisp.lmx](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `mismatch(first; second; same=0)` | Maybe of first differing index, or shared-prefix length when only lengths differ; no difference yields none. | [coreStandardLisp.lmx](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `searchSequence(items; pattern; same=0; start=0)` | Maybe of first full subsequence start at or after start; empty pattern matches start; explicit equality. | [coreStandardLisp.lmx](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `substitute(items; oldValue; newValue; same=0)` | Fresh same-profile Array, replacing every equivalent element; source unchanged and referenced targets shared. | [coreStandardLisp.lmx](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `indexOf(text; part; start=0; same=0)` | First literal byte-substring index at or after clamped start; -1 absent. Empty part matches the chosen valid boundary. | [coreStandardText.lmx](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `lastIndexOf(text; part; start=length(text); same=0)` | Last literal byte-substring index at or before clamped start; overlapping candidates are tested, -1 absent. | [coreStandardText.lmx](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `compare(first; second; order=0)` | Unsigned-octet lexicographic order -1/0/1; exact case-sensitive content, length breaks an equal-prefix tie. | [coreStandardText.lmx](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `trim(text; chars; predicate=0; same=0)` | Fresh byte slice after removing any chosen boundary characters on both sides; default is six ASCII whitespace characters. | [coreStandardText.lmx](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `trimStart(text; chars; predicate=0; same=0)` | The same shared trim algorithm at the start only. | [coreStandardText.lmx](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `trimEnd(text; chars; predicate=0; same=0)` | The same shared trim algorithm at the end only. | [coreStandardText.lmx](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `padLeft(text; width; fill)` | Fresh byte string of at least width units; repeat then truncate fill at the left, preserve text when already long enough. | [coreStandardText.lmx](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `padRight(text; width; fill)` | The same shared padding algorithm with padding on the right. | [coreStandardText.lmx](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `translate(text; from; to; same=0)` | Simultaneous literal byte substitution, equal-size alphabets, first duplicate source entry wins, unknown bytes retained. | [coreStandardText.lmx](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `format(value; base=10) / format(value; profile; arguments=())` | Exact signed bigint to lowercase digits in radix 2..36; shared with the internal nonnegative decimal name builder. | [coreStandardText.lmx](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `parse(text; base=10) / parse(source; profile; arguments=())` | Strict whole-input signed bigint parse in radix 2..36; optional sign, ASCII digits case-insensitive, no whitespace/prefix/trailing text. | [coreStandardText.lmx](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `removePrefix(text; affix; same=0)` | Remove one exact leading affix when present; fresh slice either way. | [coreStandardText.lmx](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `removeSuffix(text; affix; same=0)` | The same affix-removal algorithm at the end. | [coreStandardText.lmx](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `sum(items; initial=(0 record))` | Common (+ initial copy(items)) Expression over actual ready numeric fields; empty input returns the initial value record. | [coreStandardNumeric.lmx](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `product(items; initial=(1 record))` | Common (* initial copy(items)) Expression over actual ready numeric fields; empty input returns the initial value record. | [coreStandardNumeric.lmx](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `minimum(items)` | First least ordered numeric value as its original typed record; empty input raises SequenceSize. | [coreStandardNumeric.lmx](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `maximum(items)` | First greatest ordered numeric value as its original typed record; empty input raises SequenceSize. | [coreStandardNumeric.lmx](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `argMin(items)` | Zero-based first index of the least ordered numeric value, using the same extremum loop. | [coreStandardNumeric.lmx](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `argMax(items)` | Zero-based first index of the greatest ordered numeric value, using the same extremum loop. | [coreStandardNumeric.lmx](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `extrema(items)` | Pair of original minimum and maximum records; delegates to the two existing extremum directions. | [coreStandardNumeric.lmx](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `min(first; second)` | Choose the lesser of two typed ordered numeric value records; first identity wins ties. | [coreStandardNumeric.lmx](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `max(first; second)` | Choose the greater of two typed ordered numeric value records; first identity wins ties. | [coreStandardNumeric.lmx](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `minMax(first; second)` | Both original records in nondecreasing order; ties preserve input order and both identities. | [coreStandardNumeric.lmx](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `clamp(value; lower; upper)` | Closed ordered interval through shared min/max; reversed bounds raise NumericDomain. | [coreStandardNumeric.lmx](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `sign(value)` | Int -1/0/1 for ordered numeric values; no IEEE NaN or complex sign contract is claimed. | [coreStandardNumeric.lmx](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `gcd(first; second)` | Exact nonnegative bigint Euclidean GCD, including gcd(0;0)=0. | [coreStandardNumeric.lmx](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `lcm(first; second)` | Exact nonnegative bigint LCM through gcd; any zero input yields zero. | [coreStandardNumeric.lmx](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `divMod(dividend; divisor)` | Exact bigint floor quotient and remainder with divisor sign; zero divisor raises NumericDomain. | [coreStandardNumeric.lmx](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |

## Границы реализации

`bracket` заранее выделяет ячейку аргумента cleanup, сохраняет успешный acquire в готовую ячейку и регистрирует finally до построения аргументов action. При отказе acquire handler не зарегистрирован. Повторных acquired/ok-проверок нет. Нативная атомарность и Haskell asynchronous masking не объявляются реализованными одним этим исходником.

Новые стандартные операции используют существующие typed value records, containers, names/nil, Pattern, ordinary callbacks и текущие интеграционные входы. Отдельные документы семейств описывают ограниченные конечные коллекции, payload/default правила, владение, ранний выход и отсутствие новых выдуманных providers. Подготовленные acceptance cases помечены NOT_RUN.

Все конечные Throws считаются полностью. Где договор допускает, список копируется из действительно вызываемого метода. Библиотечное тело и его зависимости учитываются отдельно один раз; две клиентские формы сохраняют один наблюдаемый договор.

## Где смотреть

- [Клиенты и девять сравнений реализаций](LIBRARY_COMPONENTS.md).
- [Все 96 примеров](examples/README.md) и [их статистика](examples/STATISTICS.md).
- [Статистика паттернов](STATISTICS_2026-11-22.md), [машинные проверки](validation/current_packet_20261123.json).
- [Optional/Result/object операции](LMX_Fn_Receivers/CORE_STANDARD_OBJECTS.md).
- [Полный реестр ядра](../CORE_FUNCTIONS.md) и [интеграционные требования](LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md).
- [Текущий отчёт проверок](VALIDATION.md).

LMX runtime не поставляется. Статические проверки, Python-модели, генерация публикаций и отдельно выполненные foreign tests не заменяют исполнения LMX. Этот пакет содержит исходники алгоритмов, сравнения и конкретные требования интеграции.
