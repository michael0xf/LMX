# Аудит Common Lisp и стандартных возможностей SBCL

Проверены **все 978 внешних символов пакета COMMON-LISP**, а не только средства,
которые встретились в 24 примерах. Список получен фактическим запуском
`do-external-symbols` в **SBCL 2.2.9.debian**; значения переменных и тела функций
при перечислении не исполнялись. Число совпадает с перечнем CLHS §1.9.

- [Поимённая таблица всех 978 символов](COMMON_LISP_SYMBOLS.md).
- [JSON с классификацией и ограничениями](COMMON_LISP_COVERAGE.json).
- [CSV для фильтрации](COMMON_LISP_COVERAGE.csv).
- [Фактический экспорт из SBCL](validation/common_lisp_symbols.json).
- [Воспроизводимый exporter](tools/export_common_lisp_symbols.lisp) и
  [правила классификации](tools/build_cl_coverage.py).

Источник стандартного перечня:
[CLHS §1.9](https://www.lispworks.com/documentation/HyperSpec/Body/01_i.htm).
Структура охвата сверялась с
[главами CLHS](https://www.lispworks.com/documentation/HyperSpec/Front/Contents.htm).
Таблица — наш аудит задач и существующего LMX-кода; это не скопированный текст
справочника и не заявление о полной совместимости двух языков.

## Что добавлено в общее ядро

| Задача | Новые общие функции | Как устранён повтор |
| --- | --- | --- |
| Поиск строки по ключу или значению | `assoc` | Один `keyIndex` вместо двух алгоритмов ASSOC/RASSOC |
| Построение таблицы пар | `pairlis` | Existing `zip` и `concat` |
| Свойства в плоском массиве | `getProperty`, `setProperty`, `removeProperty`, `getProperties` | Один поиск ключа, existing `replaceRange` |
| Совпадение последовательностей | `mismatch`, `searchSequence` | Один цикл сравнения диапазона |
| Замена эквивалентных элементов | `substitute` | Общий equality и типизированные операции Array |
| Свой обычный операнд Expression | `asOperand` | Одно тело на любой callable, точный результат R/void |

Полные реализации, договоры и 42 пункта приёмки расположены соответственно в
[coreStandardLisp.lmx](../../LMX_Fn_Receivers/src/coreStandardLisp.lmx),
[CORE_STANDARD_LISP.md](../../LMX_Fn_Receivers/CORE_STANDARD_LISP.md) и
[core_standard_lisp_cases.json](../../LMX_Fn_Receivers/tests/core_standard_lisp_cases.json).
Metadata для общего экспорта:
[CORE_STANDARD_LISP_ADDITIONS.json](../../LMX_Fn_Receivers/CORE_STANDARD_LISP_ADDITIONS.json).
Это **написанные реализации** поверх existing kernel adapters; их LMX runtime
статус остаётся **NOT_RUN**.

Общие функциональные, строковые, числовые и объектные дополнения параллельной
ревизии также использованы в соответствиях: последовательности и множества,
текстовый поиск/сравнение/trim/format, арифметические сокращения, Maybe/Result и
доступ к полям. Каждая запись указывает задачу и ограничения профиля; существующую
функцию не переименовывают в CL-аналог, если она возвращает другой вид результата.

## Как читать решения

| Семейство решений | Смысл |
| --- | --- |
| `native_*` | Задача решается обычной семантикой LMX или её явной композицией; оговорённые CL-особенности не переносятся автоматически |
| `core_with_limits` / `added_core` | Есть конкретная общая операция; действует её полный LMX-договор, а не все keyword-варианты CL |
| `provider_*` | Нужны реальные системные возможности, числовой/текстовый профиль или дополнительная библиотека; пустой фасад не выдан за реализацию |
| `dialect_gap` | Точное воспроизведение специфической runtime-семантики CL потребовало бы отдельного договора; обычная LMX-задача часто имеет собственное решение |
| `profile_or_metadata` / `native_or_metadata` | Синтаксический маркер, лимит, compiler/tooling или параметр окружения, а не самостоятельная полезная библиотечная функция |

Символ может иметь несколько ролей: например, `+` — арифметическая функция и
имя REPL history. Одна строка учитывает существование символа, а квалификация
говорит о применимом поведении. Доля строк категории `core` не является процентом
реализованного ANSI Common Lisp.

Сравнения остаются честными по представлению. `getProperties` возвращает индекс
в массиве, не cons-хвост; `assoc` хранит полную исходную строку; `unique` сохраняет
первое вхождение, а профиль `remove-duplicates` в S08 выбран согласованно.
`any` возвращает int 0/1, тогда как для задачи сохранить первое полезное значение
нужен соответствующий `Maybe`/поиск, а не подмена результата. Обычный LMX `merge`
составляет графы и не объявлен тождественным слиянию отсортированных CL sequences.

## Возможности SBCL сверх COMMON-LISP

978 строк охватывают стандартный пакет. Расширения SBCL рассматриваются
**по публичным семействам возможностей**, перечисленным в официальном
[SBCL User Manual](https://www.sbcl.org/manual/). Это не обещание перечислить
все внутренние symbols всех собранных расширений. Открытая документация относится
к текущему сайту; фактически исполнявшийся бинарный файл указан отдельно выше.

| Семейство SBCL | Решение для LMX и остающаяся граница |
| --- | --- |
| Threads, mailbox, queue | Existing `Message`/`post`, S24 и отдельный host fixture; shared-memory thread API не притворяется Message API |
| Atomics, mutex, semaphore, waitqueue | Последовательное владение Message решает собственные задачи; операции с разделяемой памятью требуют явного host/provider договора |
| Timers, deadlines, async interruption | События владельца и выбранный scheduler; точное принудительное прерывание чужого стека не введено |
| C FFI, callbacks, foreign memory | Existing C boundary, полные типы, lifetime и явные callbacks; ABI проверяется отдельно |
| POSIX, processes, sockets, DNS | Конкретные системные providers; краткий wrapper не заменяет их реализацию |
| Unicode, external formats | Existing byte/UTF-8 profiles; versioned properties, case and encoding tables требуют реальной интеграции |
| CLOS/MOP and extended slot access | Обычные Structure, методы и reflection; полноценная чужая metaobject protocol не заявлена |
| Extensible sequences | Общие typed Array algorithms и явные iterators; модель CL subclasses не требуется для обычного массива |
| Gray/Simple streams | Ресурсный объект и provider I/O contract; протокол расширяемого stream нужно реализовать при конкретной потребности |
| Packages, locks, nicknames | Обычные import/path/private; CL intern/package locking — отдельная совместимость |
| Weak pointers, finalization, GC tuning | Ownership/lifetime и явное завершение ресурсов; зависимость от чужих GC callbacks не скрыта |
| Hash-table extensions | Честные equality/association APIs; weak/hash/performance contracts требуют отдельного хеш-профиля |
| Compiler, introspection, profiler, cover | Explicit compilation и существующий observation/debugging договор; инструменты должны работать на реальном executor |
| Images, load systems, ASDF, build helpers | Поставка исходного графа, явный build/host profile; переносимость целого SBCL image не обещана |
| SIMD, implementation numeric extensions | Обычные Arrays и числовой профиль; ускоренные инструкции/ABI требуют native backend |

Никакие внешние процессы, сеть или пользовательские ресурсы при этом аудите не
запускались. В SBCL фактически выполнялись приложенные чистые примеры, локальные
проверки алгоритмов и S24 с локальным потоком/mailbox.

## Что передать Fable

[ТЗ на общие дополнения и оставшиеся границы](TZ_Standard_Lisp_and_Expression.md)
содержит точные относительные пути `spec`, обязательную приёмку asOperand и
13 групп существенных различий. Это конкретные точки интеграции, а не будущие
операции, спрятанные за kernel stub. Полный общий архив содержит и эти core-файлы;
отдельный архив `SBCL_comparison` сохраняет на них относительные ссылки.
