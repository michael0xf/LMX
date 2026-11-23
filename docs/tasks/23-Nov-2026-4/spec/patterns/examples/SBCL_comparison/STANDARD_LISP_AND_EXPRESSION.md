# Общие Lisp-задачи и обычный Expression

## Поставка и статус

Выполненная общая ревизия содержит десять обычных LMX-функций. Никаких новых
parser modes, типов операнда или дополнительных VM здесь нет. Тела находятся
в ядре; эта директория содержит сравнения, ссылки и приёмку. **LMX NOT_RUN**.

| Цель относительно `spec` | Назначение |
| --- | --- |
| [patterns/LMX_Fn_Receivers/src/coreStandardLisp.lmx](../../LMX_Fn_Receivers/src/coreStandardLisp.lmx) | Полные тела, один equality/поиск, один адаптер callable |
| [patterns/LMX_Fn_Receivers/CORE_STANDARD_LISP_ADDITIONS.json](../../LMX_Fn_Receivers/CORE_STANDARD_LISP_ADDITIONS.json) | Точные public lowerCamelCase имена, definitions и hashes |
| [patterns/LMX_Fn_Receivers/CORE_STANDARD_LISP.md](../../LMX_Fn_Receivers/CORE_STANDARD_LISP.md) | Полные договоры и ограничения |
| [patterns/LMX_Fn_Receivers/tests/core_standard_lisp_cases.json](../../LMX_Fn_Receivers/tests/core_standard_lisp_cases.json) | 42 содержательные runtime-проверки |
| [patterns/LMX_Fn_Receivers/src/coreStandardText.lmx](../../LMX_Fn_Receivers/src/coreStandardText.lmx) | Общий `format`, используемый asOperand |
| [patterns/LMX_Fn_Receivers/src/regex/operands.lmx](../../LMX_Fn_Receivers/src/regex/operands.lmx) | Уже существующий общий `RxLogicalArguments` |
| [patterns/LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md](../../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md) | Existing `signatureData`, `callable`, `attempt`, `raise` |
| [patterns/tools/lmx_style_variants.py](../../tools/lmx_style_variants.py) | Две полные LMX-формы одного договора и точные метрики |
| [patterns/examples/SBCL_comparison/source/lmx/Expression_examples.lm3](source/lmx/Expression_examples.lm3) | Полный короткий пример двух положений одного операнда |

## Приёмка asOperand без нового примитива

Основания: [структурное обнаружение](../../../LMX_semantics.en.md#operand-receiver),
[prepared left/right](../../../LMX_semantics.en.md#prepared-operands),
[единственное RHS-открытие](../../../LMX_semantics.en.md#operand-right-only-opening),
[единая композиция](../../../LMX_semantics.en.md#composition).

1. `signatureData(inputs; void; labels)` по существующему договору **не создаёт
   return declaration**. Поэтому private-поток входов содержит ровно left/right;
   отдельный `signatureData((); R; ())` добавляет один return:R, либо ничего для
   procedure. Проверить это на фактическом графе.
2. `FxOwnPolicy` хранит `source:=contract`; provider `callable` должен сохранить
   обычные DATA declarations, private/required и две готовые константы. Проверить
   structural discovery на настоящем `parent` результата после выхода фабрики.
   Нельзя оставить вместо DATA только позиционную пару типов, утратив свойства.
3. `(myOp 1 2 3 4 5)` и `(1 myOp 2 3 4 5)` вызывают одну и ту же функцию,
   задавая одинаковую итоговую последовательность actual. Не переносить первый
   right в left до адаптера; missing left остаётся отсутствием.
4. Проверить отсутствие левого actual при одноимённой внешней переменной,
   пустой right, ноль, null, uninit, контейнер как один actual, обычные defaults и
   required/private, динамический проход через неиспользующий имя посредник.
5. Сохранить точный R для primitive, Array, Structure, callable и procedure;
   исходные объявленные failures проходят со своим именем и payload. Не вводить
   catch-all или побайтовые проверки имени в клиенте.
6. Проверить interpreter/native сочетания и lifetime результата. Ни F, ни его
   defaults не запускаются при конструировании. Объявление свойств и body не
   парсятся заново на каждом вызове; новая ABI не использует чужую native entry.

Если текущий provider нарушит пункт 1 или 2, это дефект/недостаток конкретной
интеграции существующего `signatureData/callable`, а не повод добавлять новый
«тип префиксного операнда». Фикстура должна показать реальный граф и результат;
подготовленный текст сам по себе этого не доказывает.

Отдельно проверить `(+ 0 copy(items))` и `(0 + copy(items))`: пустой stream,
плотные numeric Arrays, Structure из готовых числовых записей, 0 против uninit,
однократное вычисление источника. [Полевая выдача](../../../LMX_semantics.en.md#stream-or-group)
явная; автоматического раскрытия произвольного Array нет.

## Оставшиеся группы совместимости

Эти пункты не требуют переносить чужой runtime в LMX. Сначала выбирается задача
и её LMX-native решение. Только если требуется отмеченное точное поведение,
нужен конкретный provider или дополнительная библиотека с реализацией.

### L01. Multiple values

Обычный структурный результат, positional destructuring, `copy` и `apply`
закрывают передачу нескольких результатов. CL-правила динамического числа
values, заполнения/отбрасывания лишних values и специальных consumers не
возникают автоматически. Основание:
[структурный результат](../../../LMX_semantics.en.md#structure-result).

### L02. Symbols и packages

Использовать обычные имена, `sys\name`, reflection, `import`, пути и `private`.
Если действительно нужны интернированные символы с отдельными function/value/
plist cells и точной identity, определить их как предметную библиотеку. Нельзя
выдать сравнение строк за полную symbol identity или создать вторую таблицу имён
самого языка. Основание: [sys\name](../../../LMX_semantics.en.md#string-identifier).

### L03. Reader и macro environments

Обычные receiver-формы и Expression уже задают пользовательскую запись операций.
Для исходного CODE существует raw mode и `sys\eval` с сохранённым исходным
контекстом. `asOperand` принимает готовые значения и не заменяет произвольный
macroexpander. Отдельные reader tables для чтения Lisp-данных нужны только
явному compatibility consumer. Основание:
[raw operands](../../../LMX_semantics.en.md#raw-operands).

### L04. CLOS/MOP

Обычные Structure, методы и структурные требования покрывают объекты примеров.
Полная multiple dispatch, method combination, class redefinition и чужая MOP
требуют отдельного договора. Не объявлять их реализованными одним методом area.
Основание: [callable/requirements](../../../LMX_semantics.en.md#fn-satisfies).

### L05. Conditions и resumable restarts

`throw/catch/finally`, конечные declared failures и typed payload уже решают
показанные ошибки. Возобновление произвольного стека и поиск restart в чужом
динамическом окружении не имитируются возвратом 0 или общим exception wrapper.
Для такой задачи задаётся явный continuation protocol либо настоящий provider.
Основание: [выходы](../../../LMX_semantics.en.md#exits).

### L06. FORMAT и pretty printing

Общие text API и ограниченный positional formatter сокращают обычную запись.
Полный FORMAT DSL, pretty-print dispatch, графовые циклы/readably Lisp-печать —
отдельная библиотечная задача; один `format` не считается всей её реализацией.
Использовать existing `toLmx` для родной сериализации графа.

### L07. Streams, filesystem и network

Ownership, cleanup и Message уже определены, но реальные read/write/path/OS/
socket действия требуют конкретных host/provider функций. Их договор должен
фиксировать units/encoding, EOF, partial I/O, cancellation и lifetime. Фасад без
реального backend не добавляется как якобы готовая реализация.

### L08. Clock, random и environment

Нужен фактический provider с единицами времени, профилем календаря/timezone и
договорами random state/entropy. Метаданные среды читаются из настоящего host.
Задержка не реализуется busy wait; случайность не подменяется константой.

### L09. Hash tables

`assoc`, `same` и `memoize` честно покрывают конечные линейные задачи. Для
ожидаемой hash-сложности нужны согласованные equality/hash, политики изменяемых
ключей и итерации; weak keys потребуют настоящего lifetime/GC профиля. Этот
пакет не объявляет линейный поиск O(1) таблицей.

### L10. Полный числовой профиль

Обычная арифметика, bigint/rational/complex и написанные сокращения действуют
в выбранном профиле. Точные rounding/remainder варианты, float decomposition,
числовые пределы и transcendental functions требуют подтверждённых тел/provider.
Различия машинного int и CL integer не скрываются доменом одного примера.

### L11. Unicode и external formats

ByteText и UTF-8 scalar TextView уже различаются. Полные case mapping/folding,
titlecase, контекстные правила, character properties и дополнительные encodings
требуют **версионированных таблиц** и определённого профиля. ASCII-преобразование
не маркируется как стандартный Unicode. Основание:
[text profiles](../../../CORE_SEQUENCES_REGEX.en.md).

### L12. Cons identity и деревья

Array/Structure, copy, references и индексные пути задают родное представление.
Нужно сохранять требуемые aliases/cycles; shallow copy-list не заменяется
deep copy(graph), а общий индекс не называется cons tail. Рекурсивные tree
замены требуют явного договора на форму и shared nodes.

### L13. Compiler и инструменты

Использовать явную компиляцию, реальную reflection и существующий debugging
протокол. Профилировщик, debugger, coverage и image/build инструменты должны
работать на соответствующем executor; подготовленная таблица не является
измерением скорости, памяти или фактического native исполнения.

## Учёт двух LMX-стилей и Throws

Процедурный и функциональный исходники каждого договора сравниваются отдельно. Полный размер включает все объявления, local helpers и Throws; `copy(method\throws)` сохраняет связь с действительным договором метода. Дополнительного счёта с удалением аргументов Throws нет. Общие ядровые реализации и их уникальные зависимости учитываются один раз в отдельной реализации, без копий по стилям.
