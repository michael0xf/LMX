# Стандартные функциональные операции и коллекции

Редакция: 23 ноября 2026 года. [Исходник](src/coreStandardFunctional.lmx) · [Реестр 33 публичных имён](CORE_STANDARD_FUNCTIONAL_ADDITIONS.json) · [Приёмочные случаи](tests/standard_functional_acceptance.json).

Добавлены 33 обычных ресивера. Они сокращают повторяемые обходы, выбор префикса, разбиение, свёртки, преобразования Maybe, обработку состояния и операции над множествами. Все алгоритмы написаны на LMX через уже имеющиеся операции; новых FxKernel-провайдеров и режимов парсера нет. Это конкретный законченный набор, а не заявление, что перенесены все стандартные библиотеки всех языков.

## Что уже было

Повторно используются map/filter, foldl/scanl, zip/zipWith, bind/traverse, concat/reverse/slice/range, index/count/findFirst, unique/sort и общий typed-record механизм. Python chain и Haskell concatMap не получают ещё одно имя там, где существующие concat и bind уже выражают тот же finite-контракт. functools.partial/reduce и обычная композиция сопоставлены с имеющимися partial/foldl/compose; политика Python cache не приравнивается к отличающемуся контракту memoize. [Python functools](https://docs.python.org/3/library/functools.html).

## Публичные функции

Сначала указаны параметры LMX; их порядок не выдается за порядок параметров иностранного API. `*Record` означает полноценную запись тип/значение из существующего `(value record)`, не адрес сырого payload. `FxPair` имеет поля `first` и `second`, каждое ссылается на полную запись значения.

| Имя | Аргументы | Результат и договор |
| --- | --- | --- |
| `take` | `items; count` | Fresh prefix; count is clamped to 0..length. |
| `drop` | `items; count` | Fresh suffix after a clamped count. |
| `splitAt` | `items; count` | Both slices use one clamped cut; source remains unchanged. |
| `takeWhile` | `items; accepts` | Longest true prefix; predicate runs once per visited item, including first rejection. |
| `dropWhile` | `items; accepts` | Suffix begins with first rejected item; no later predicates are evaluated. |
| `span` | `items; accepts` | One prefix scan supplies both parts, without reevaluating an effectful predicate. |
| `partition` | `items; accepts` | Stable two-way partition with exactly one predicate call per item. |
| `enumerate` | `items; start=0` | Indices are admitted to the current int type from exact arithmetic; no wrapping index is accepted. |
| `windows` | `items; width=2; step=1; partial=0` | Positive width/step; full windows by default. partial permits one last nonempty short window. No suffix after a window reaches the end. |
| `chunks` | `items; size; strict=0` | Nonoverlapping chunks, final short chunk permitted unless strict; invalid size fails before iteration. |
| `intersperse` | `items; separatorRecord` | Insert an admitted separator between items; empty and singleton inputs do not admit an unused separator. |
| `join` | `parts; separator` | Separate sequence parts and concatenate; empty parts returns a fresh empty sequence of separator profile. |
| `unzip` | `pairs` | Reverse the existing zip FxPair protocol; empty input returns two fresh empty record Arrays. |
| `foldr` | `items; seedRecord; step` | Strict finite right fold; step(item,accumulator), right-to-left callback order. |
| `scanr` | `items; seedRecord; step` | Right scan includes the seed at the final position; right-to-left callbacks. |
| `filterMap` | `items; transform` | Map to Maybe and keep present values, preserving zero/empty/reference values. |
| `mapWhile` | `items; transform` | Map to Maybe; stop at first none, without calling later items. |
| `findMap` | `items; transform` | Return the first present callback result; return none when all are absent. |
| `mapAccumL` | `items; seedRecord; step` | step(state,item) returns FxPair(next state,output); callbacks left-to-right. |
| `mapAccumR` | `items; seedRecord; step` | Same stateful transform, callbacks right-to-left, outputs at original positions. |
| `groupAdjacent` | `items; keyOf=0; sameKey=0` | Consecutive equal-key runs; selected projection once per item and shared/explicit equality for adjacent keys. |
| `replicate` | `valueRecord; count` | Finite copies of one ready value record; negative count gives empty; reference values retain one target. |
| `cycle` | `items; count; rejectNegative=0` | Required finite repetition count; nonpositive count gives empty unless the explicit rejecting profile is selected; preflight result size. |
| `starmap` | `rows; operation` | Each ready row becomes one actual vector; one typed callback result per row. No source graph field is executed while reading it. |
| `zipLongest` | `first; second; fillRecord` | Two sequences padded to the longer length with the explicit complete fill value record. |
| `collect` | `next; limit=-1` | Nullary producer through the existing call bridge until its Stop(), or finite limit; other declared failures retain their name and payload inside FxCallFailure. |
| `includes` | `items; valueRecord; same=0` | Ordered short-circuit membership with shared ordinary/deep Array equality or an explicit comparator; no conflict with regex contains. |
| `adjoin` | `items; valueRecord; same=0` | Return original source if already present; otherwise return a fresh same-profile Array with the new value prepended. |
| `union` | `first; second; same=0` | Unique first occurrences from first then second; pure equivalence relation required. |
| `intersection` | `first; second; same=0` | Unique first-source values present in second, preserving first-source order. |
| `difference` | `first; second; same=0` | Unique first-source values absent from second; set difference, not Haskell list multiset subtraction. |
| `symmetricDifference` | `first; second; same=0` | First-only values then second-only values, each once; use existing difference and concat. |
| `isSubset` | `first; second; same=0` | Every equivalence class from first appears in second; multiplicity is ignored. |

## Переиспользование реализации

`take`/`drop`/`splitAt` используют один расчёт границы и существующий slice. `takeWhile`/`dropWhile`/`span` используют один сканер префикса. При span predicate не запускается заново для второго результата. `chunks` пользуется windows. `join` складывается из intersperse и concat; cycle — из replicate и concat с проверкой итогового размера.

`foldr`/`scanr` используют foldl/scanl, flip и reverse. `filterMap`, `mapWhile`, `findMap` отличаются только политикой остановки одного engine. `mapAccumL`/`mapAccumR` делят один цикл; направления меняют порядок callback, но не позиции выходного массива. Set-операции используют один membership и один выбор элементов; symmetricDifference повторно применяет difference, union — concat и unique.

## Сопоставление с исходными библиотеками

- Названия take/drop/splitAt/span, intersperse/join, правые свёртки и mapAccum берутся из [Data.List](https://hackage-content.haskell.org/package/base-4.20.2.0/docs/Data-List.html). Здесь результат конечный и строгий: ленивые бесконечные списки Haskell не имитируются.
- Конечные операции группировки, starmap, zipLongest и разбиения сопоставлены с [Python itertools](https://docs.python.org/3/library/itertools.html). Python возвращает потребляемые итераторы, LMX — описанные новые массивы. cycle требует count, а collect отдельно обслуживает nullary-источник с Stop.
- filterMap/mapWhile/findMap следуют привычным операциям [Rust Iterator](https://doc.rust-lang.org/std/iter/trait.Iterator.html); отсутствие выражается существующим FxMaybe. [Rust slices](https://doc.rust-lang.org/std/primitive.slice.html) дают ориентир для полных windows и chunks. Параметр partial явный.
- Для span/partition и скользящих групп дополнительно сверены [Scala List](https://www.scala-lang.org/api/2.13.18/scala/collection/immutable/List.html). Проверки predicate сохраняют указанный здесь порядок, независимо от ленивости иностранного представления.
- union/intersection/difference/symmetricDifference/isSubset сопоставлены с [Python set](https://docs.python.org/3/builtins/stdtypes.html#set-types-set-frozenset) и [Rust HashSet](https://doc.rust-lang.org/std/collections/struct.HashSet.html). Семантика множества отделена от Data.List, а стабильный порядок LMX выбран явно; хеширование не обещается.
- [Python enumerate](https://docs.python.org/3/builtins/functions.html#enumerate) соответствует паре индекс/элемент; LMX проверяет собственный int-профиль, не принимает переполнение за индекс.
- [Common Lisp adjoin](https://www.lispworks.com/documentation/HyperSpec/Body/f_adjoin.htm) добавляет отсутствующий элемент в начало и возвращает оригинал при наличии. LMX сохраняет эти наблюдения, но новый результат — массив, без обещания cons-tail sharing. Стабильные уникальные set-массивы описаны отдельно; это не скрытая подмена list-мультимножеств.

## Типы, время жизни и отказы

Выбор элементов, разбиения и cycle сохраняют плотный профиль исходного []T. Внешние массивы результатов и пары создаются через существующий allocator; ссылки на пользовательские объекты не копируются глубоко. Для concat-профиля действуют уже описанные правила: одинаковые плотные типы сохраняются, смешанные части дают []@. Для join без частей профиль берётся у separator. adjoin при наличии — явное исключение из правила нового внешнего массива.

FxApply возвращает реальное типизированное значение по существующему call bridge. Структурный результат Maybe/Pair поступает непосредственно; дополнительный слой @ не выдумывается, безусловного разыменования packed нет. Значение some(0), пустая строка и null-reference не становятся none. Алгоритмы используют реальное чтение элементов, не reinterpret_cast плотного массива в массив указателей. [Модель вызова](../../LMX_semantics.en.md#call-frame-20261115) · [Копирование](../../LMX_semantics.en.md#composition) · [Текущие последовательности](../../CORE_SEQUENCES_REGEX.en.md).

Callback-операции используют существующий конечный договор FxCallFailure: исходный именованный отказ и payload сохраняются внутри него. collect вызывает nullary producer через FxTry; только его Stop означает завершение, прочие объявленные отказы возвращаются в FxCallFailure. Проверка имени переиспользует общий FxEqualFields, своего цикла сравнения нет. Успех добавляет готовую запись истинного типа результата; ошибки самого call bridge и добавления не становятся Stop. При limit=0 producer не вызывается; limit=-1 означает до Stop либо отказа ресурса. Короткий локальный Cycles с обычными именами ошибок остаётся отдельным примером H09. [Конечные Throws](../../LMX_semantics.en.md#exceptions) · [существующий call bridge](KERNEL_REQUIREMENTS.md).

Predicate/step не должны менять длину и выбранные ячейки активного source. Уже выполненные пользовательские эффекты не откатываются. Equality множеств и sameKey для сопоставления с группировкой требуют чистого отношения эквивалентности. Сложность includes и стабильных set-операций линейная/квадратичная согласно обходам; хеш-таблица не подразумевается.

## Обычный синтаксис операндов

Нового вида «префиксный операнд» не вводится. Один OPERANDS_TEMPLATE и обычные left/right поддерживают существующие записи `(myOp 1 2 3)` и `(1 myOp 2 3)`. Все операции этого файла имеют обычную и операндную формы с одним каноническим именем. Подготовленные VALUE-формы используют общий `asOperand`, другие роли маршрутизирует транслятор по исходному контракту. Алгоритмы не копируются; новый parser/discriminator или Lisp-evaluator не вводится. Конкретные пары перечислены в [каталоге](CATALOG.md) и [договоре публикации](PUBLICATION_CONTRACT.md).

## Проверка и границы готовности

Исходник, реестр имён, внутренние ссылки и связь приёмочных случаев проверяются как публикация. Приёмка включает пустые входы, асимметричную правую свёртку, callback-order, сохранение профиля, zero/some, source Stop, identity и жизненные сроки. **LMX runtime не запускался; все случаи имеют NOT_RUN.** Fable должен выполнить их интерпретатором и компилированными переходами после объединения с существующими bridges. Нет нового требования реализовать отдельный runtime для этих алгоритмов.
