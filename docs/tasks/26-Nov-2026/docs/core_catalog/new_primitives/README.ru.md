# Новые числовые примитивы: руководство интеграции

Каноническое предложение находится в [profiles.lmx](profiles.lmx). Оно добавляет
три числовых семейства к действующему машинному профилю: `bigint` на LibTomMath,
`decimal` на MPDecimal и произвольно-точный двоичный `real` на LibBF. Вторая
реализация того же семейства получает адаптер к тем же LMX данным. Она не
создаёт `LibBFReal`, `MPDecimalDecimal` и другие библиотечные типы языка.

Это **компилируемое C99 руководство**, а не внесённое изменение ядра. Самосборщик
из архива отстаёт от текущей нормативной документации. Его
[primitive.lm2](../../../selfbuild/src/l2src/primitive.lm2), строки 1–10,
прямо говорит, что старые семантические строки `bigint real decimal` не были
импортированы автоматически; таблица машинных значений находится в строках
19–50. По [semantics §19](../../spec/LMX_semantics.en.md#mathematics), строки
2684–2695, семейства доступны через выбранные конструкторы, описания и операции,
а библиотека является реализацией. Настоящие числа не сводятся к C `double`.

## Выбор общей модели

| Семейство | Основная реализация | Сохранённые альтернативы и граница |
|---|---|---|
| `bigint` | LibTomMath из исходного комплекта | IMath даёт независимую реализацию больших целых и точных дробей; LibBF также имеет целочисленные операции. Общая семантика, отдельные native объекты. |
| `decimal` | MPDecimal из исходного комплекта | decNumber и LibBF `bfdec_t`. MPDecimal/decNumber умеют работать с явным decimal context; нормализованный `bfdec_t` не подменяет договор сохранения quantum. |
| `real` | LibBF 2025-06-03, MIT | Произвольная выбранная точность и округление; конечный ресурсный бюджет. Экспериментальная LibTomFloat — независимый backend с другим проверяемым профилем. Binary64/SoftFloat остаются фиксированными форматами. |
| `rational` | Обычная Structure `{numerator, denominator}` над bigint | IMath `mp_rat`; возможна независимая реализация парой LibTomMath. Ненулевой знаменатель, нормализация знака и gcd. Новый физический код пока не нужен. |
| `complex` | Обычная Structure с двумя значениями одного scalar profile | C99 complex, KissFFT/PFFFT, cglm и другие native формы требуют pack/unpack. Для массивов используется `ComplexBuffer`. |
| Fixed-point | Существующий `i32` + явный Q16.16 profile | libfixmath и libfixmatrix; rounding/overflow/saturation определены интерфейсом. Не вводится новый тип на каждую библиотеку. |
| Binary16/32/64/80/128 | Фиксированные слова или Array + формат | SoftFloat и FP16 дают программные операции/конверсию. Сериализация хранит определённый порядок байтов и правила специальных значений. |

Несколько библиотек с одинаковыми задачами полезны как независимые пути решения.
Они сохраняются намеренно: небольшой агент или разработчик может выбрать тот
backend, которым умеет пользоваться. Общими остаются LMX данные и интерфейсы,
а конкретная реализация, округление и формат объявляются в явном профиле.
Проверенные дополнительные библиотеки, их лицензии, размеры и примеры приведены
в [numeric_extra](../../../third_party/lmx_c99_compact/extensions/numeric_extra/README.ru.md).

## Что действительно реализовано

[primitive_runtime.h](primitive_runtime.h) и
[primitive_runtime.c](primitive_runtime.c) показывают:

- выдачу естественно выровненного payload с физическим `int`-кодом ровно в `p-4`;
- стабильные chunks одного логического потока, code-only `uninit:T`;
- локальное представление строк type registry, проверку повторных кодов/имён;
- typed clone, finalizer, `mark/revert` и уничтожение принадлежащей записи памяти.

[numeric_provider.c](numeric_provider.c) реализует parse/add/text для bigint
и decimal, deep copy обоих значений, явный decimal context и двустороннюю
MPDecimal↔decNumber конверсию через точный десятичный текст. Значения никогда
не проходят через `double`. Общие flags ошибок преобразуются по смыслу;
числовые значения enum/bitmask разных библиотек не приводятся друг к другу.

[real_provider.c](real_provider.c) реализует parse/add/sqrt/text и явное сужение
real→binary64. `bf_context_t` принадлежит владельцу, живёт дольше всех его
`bf_t` и не становится глобальной настройкой арифметики. Precision/rounding/
traps передаются каждой операции отдельно. Clone использует контекст
**получателя**: после уничтожения исходной арены и её LibBF context копия
остаётся самостоятельной. Завершение provider context при живых значениях
отказывается, а не оставляет висячие ссылки. Явный owner budget ограничивает
все LibBF allocations, включая allocator headers и caches; отдельные arena
chunks/finalizer ledger учитываются обычным бюджетом арены. Отказ бюджета
проверен без публикации частичного значения.

[conversion_bridge.c](conversion_bridge.c) проверяет диапазоны Buffer,
temporary C strings, extent Tensor и PCM16↔float. Эти функции получают уже
разрешённые typed native данные. Они не заменяют L3 admission, проверку
владельца, реальный тип Array или отдельную проверку ABI конкретного C вызова.

## Физический record и отсутствие значения

Основание: [L2 value record](../../spec/L2_spec_en.md#value-record), строки
164–195; [kernel arena](../../spec/kernel-implementation.en.md#arena), строки
134–184. Код занимает четыре байта. Payload выровнен по своему C типу и минимум
по четырём байтам; padding лежит **между** records, не между кодом и payload.
Обычное чтение кода и значения типизированное и выровненное. Прежнее толкование
«любой payload достаточно выровнять по 4» для восьмибайтового `double` неверно.

Для `uninit:T` выделяется только код, payload отсутствует. В примере внутренний
служебный `LmxRefRecord` имеет `value == NULL` для отсутствующего payload.
Это handle аллокатора, не новый публичный ABI ссылок LMX. Заполнение отсутствующего
поля заменяет графовый фрагмент обычным порядком; адрес будущего T заранее не
резервируется. Пример не обещает сохранения payload address при таком переходе.

Значение `LmxRefBigint`/`LmxRefDecimal` содержит owned native allocation;
`LmxRefReal` содержит `bf_t` и связь с его native owner. Это физическая
реализация числового листа. Существующие служебные структуры ядра должны
учитывать finalization этой памяти, включая rollback. Привязка к библиотеке
не превращает каждую Structure, изображение, формат или decimal precision
в новый фундаментальный тип ([semantics](../../spec/LMX_semantics.en.md#values),
строка 224).

## Реестр, имена и настоящий граф

`LmxRefRegistry` — временный C view строк, переданных вызывающим кодом. Он
не является процессным глобальным реестром и не заменяет контекст Message.
В интеграции строки получают из доступных обычных Structures/описаний, а
канонические имена — из существующего intern/name механизма. Проверка `strcmp`
в учебном validator служит диагностике дубликатов этого массива; она не
переопределяет распознавание LMX слов или dispatch.

Физический код и имя независимы. `real` и `uninit:real` получают допустимые
коды штатного type-контракта; числа 701–704/1701–1704 в тесте — только локальные
демонстрационные значения. Alias разрешает прежнее описание, а не создаёт
второй physical type. Нельзя определять dtype через диапазон адресов арены,
название C библиотеки или состав полей Structure.

Спецификация требует единственный clean graph, локальный R0 и отсутствие
static C DATA mirror ([semantics](../../spec/LMX_semantics.en.md#graph-and-methods-binary),
строки 100–119). Native методы и временные служебные views не дают права
встраивать в бинарник второй граф пакетов или скрытый глобальный указатель R0.
Описание нового числового семейства остаётся достижимыми данными обычного графа.

## Copy, merge, intern, attach и сериализация

Для `independent: immutable:` сохраняется ссылка на исходное значение/ветвь;
новый numeric record и clone native payload при таком sharing не создаются.
Ниже описан отдельный случай обычного копирования изменяемых значений и
explicit typed clone reference-кода; он не меняет правило общих пакетов.

Copy/merge обычного копируемого графа используют **одну штатную source→copy map на всю операцию**;
см. [kernel copy](../../spec/kernel-implementation.en.md), строки 921–936.
Физический primitive clone вызывается, когда обычный обход создаёт новый
числовой record. Повторные ссылки на исходное значение должны получить ссылку
на уже созданную копию. Сам `lmx_ref_record_copy` этого общего графового обхода
не реализует. Имена и внешние связи переносятся через существующий механизм;
native owner/caches не копируются побайтно в другой actor.

`mark/revert` освобождает собственные числовые allocations до освобождения
chunks. GC/обычное завершение вызывает destructor ровно один раз. У реального
ядра учёт finalizers должен быть частью существующего механизма lifetime,
а не параллельным «графом для исполнения». Локальный ledger в reference нужен
только для воспроизводимой демонстрации конструктора и rollback.

Attach переносит chunks без движения records и не меняет лексические parents
([kernel](../../spec/kernel-implementation.en.md#arena), строки 175–184).
Для `real` вместе с ними надо передать владение provider service context либо
сохранить его как зависимость принимающей арены. Нельзя завершить context до
его последних `bf_t`. Receiver после attach может владеть несколькими такими
контекстами; это не несколько копий clean graph. **Attach и GC полного графа
в reference не реализованы** и остаются обязательными пунктами интеграции.

Сериализуется значение и явно нужный числовой профиль, не `mp_int`, `mpd_t`,
`bf_t`, pointer, limb size или кеш backend. В примере:

- bigint использует полный десятичный текст;
- decimal использует десятичный коэффициент/экспоненту и сохраняет quantum,
  включая проверенные `123.4500` и `-0.00`;
- real использует точный hexadecimal significand/exponent text; profile
  precision/rounding/limits передаётся отдельно. Parse отказывает, если
  `exactRequired` несовместим с выбранной точностью.

NaN/infinity, signed zero, NaN payload и decimal quantum не считаются одинаковыми
между всеми backend по умолчанию. LibBF имеет свои специальные значения,
но не обещает сохранить произвольный IEEE NaN payload. Такой format-sensitive
обмен использует fixed-format слова или явно отказывается. Собственный
[sys\toLmx](../../spec/LMX_semantics.en.md#source-codec) должен вызывать числовой
codec и штатное восстановление names/links; этот пример не заменяет весь codec
ядра и не делает JSON частью языка.

## Точки подключения в отстающее ядро

| Шаг | Где смотреть | Что реализовать относительно нынешней спецификации |
|---|---|---|
| Машинное описание | [primitive.lm2](../../../selfbuild/src/l2src/primitive.lm2), строки 12–50 | Согласованные строки семантического семейства и его native binding; реальные size/alignment, explicit conversion keys. |
| Type/absence | [lmx_types.lm2](../../../selfbuild/src/l2src/lmx_types.lm2) | Коды physical leaf/uninit leaf, typeof, constructor и typed access. Не переносить устаревшее pool-based определение типа. |
| Constructor/lifetime | [lmx_value_owned.lm2](../../../selfbuild/src/l2src/lmx_value_owned.lm2), строки 153–221; [arena](../../../selfbuild/src/l2src/lmx_arena.lm2) | Подключить typed init/clone/drop к действительному единому record stream, rollback и GC. Старые ветви служат местами поиска, не нормой нового layout. |
| Copy/merge | [lmx_graph_copy_owned.lm2](../../../selfbuild/src/l2src/lmx_graph_copy_owned.lm2), строки 1–4, 156–192 | Вызывать primitive clone из общего source→copy обхода, сохраняя names, identity и cycles; real использует destination context. |
| L2/native ABI | [kernel scalar carrier](../../spec/kernel-implementation.en.md#primitive-storage), строки 361–372 | Точный typed carrier и статус выполнения. Сложный native `bf_t` не передаётся by-value через выдуманный foreign-struct ABI. |
| L3 call | [numeric boundary](../../spec/LMX_semantics.en.md#mathematics) и [общие модели](../types/README.ru.md) | Обычный callable с DATA/parent, явными precision/ownership/error contracts; C вызов только через L2/native реализацию. |
| Array | [Array contract](../../spec/L2_spec_en.md#method-array) | Для dense `real[]` нужны корректные element init/copy/drop и resize/rollback. Reference проверяет scalar records; dense arrays пока не заявлены готовыми. |

Результаты suitability checking не запускают конверсию сами. При потреблении
вызывается явно выбранный конвертер, а не скрытая цепочка по паре C типов
([semantics §5–6](../../spec/LMX_semantics.en.md#conversion-context), строки
284–322). До завершения этих шагов каталожные LMX строки являются планом,
который агент должен реализовать и проверить актуальным компилятором.

## Офлайн сборка и наблюдавшиеся результаты

После наложения патча на проект из корня проекта:

```sh
cmake -S docs/core_catalog/new_primitives -B build/numeric-reference \
  -DLMX_COLLECTION="$PWD/third_party/lmx_c99_compact" \
  -DCMAKE_BUILD_TYPE=Release
cmake --build build/numeric-reference --parallel
ctest --test-dir build/numeric-reference --output-on-failure
```

Без CMake, при native GCC/Clang и Python 3:

```sh
python3 docs/core_catalog/new_primitives/run_reference.py \
  --collection third_party/lmx_c99_compact \
  --build-dir build/numeric-reference-native --sanitize
```

В отдельной patch-рабочей директории можно передать `--numeric-extra` как путь
к директории `third_party/lmx_c99_compact/extensions/numeric_extra` из патча,
а `--collection` — к исходной коллекции. Аргумент `--numeric-extra` обозначает
директорию, содержащую `prepare_libbf.py`, а не сам Python-файл. Аналогичная
CMake-настройка — `LMX_NUMERIC_EXTRA`. Загрузок в этих командах нет.

[VERIFICATION.json](VERIFICATION.json) фиксирует GCC 14.2, strict C99,
178 translation units, ASan+UBSan и успешное выполнение. Проверены alignment,
code-only absence, стабильность chunks, rollback, deep copy, bigint арифметика,
decimal rounding/exactness/decNumber, `1+2^-100` при 256 битах, сохранение real
после уничтожения исходного владельца, отказ неточного binary64 narrowing
и quota failure с откатом native allocation.
LeakSanitizer отдельно помечен `NOT_RUN`: среда ptrace не поддерживает его.
Выполнение через LMX interpreter/native compiler — `NOT_RUN`; компиляция этого
C99 reference не является доказательством готовности L3 обёрток.
