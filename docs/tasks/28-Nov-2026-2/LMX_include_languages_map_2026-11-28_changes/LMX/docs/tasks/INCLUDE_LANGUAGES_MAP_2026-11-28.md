# Платформы, Python, com.mtk.map и P0–MIX

Рабочее задание и отчёт по архиву `LMX-28-Nov-2026.tar.gz`.
Дата редакции: **28 ноября 2026**.

## Договор этой редакции

1. `include_languages` содержит только C-совместимые целевые профили и
   подключение Python через `py.*`. Для каждой платформы выделены отдельные
   `README.md` и `PYTHON.md`. `c.*` остаётся специфическими воротами L2.
2. `com.mtk.map` перенесён в документацию как **LMX DRAFT**. Исходный Java-код
   сохранён рядом без изменений в `docs/com.mtk.map/java_original/`.
3. P0 строит своё дерево при заполнении MIX, получает прямые Cursor и отвечает
   на изменения через Message. Продолжение разбора использует существующий P0.
4. Каждый ограниченный `{LMX}`-фрагмент имеет собственный MIX-документ,
   локальный корень P0 и Var-якорь. Отдельный MIX-анализатор связывает Var в
   Tag одним проходом; интервалы могут перекрываться.
5. Каталог design patterns дополнен примерами Request–Response / Ask,
   Become / Selective Stash, Phased Lifecycle и External Blocking Adapter.

**Message не вводит deadlock.** В этих LMX-примерах нет `synchronized`:
низкоуровневая синхронизация принадлежит L2. Работа с ожидаемыми ответами —
данные протокола и последующие обработчики. Служебные запросы, ответы,
отмена и завершение остаются обрабатываемыми в соответствующих состояниях.

## 1. Платформы и Python

[Новый каталог](../../include_languages/README.md) —
[API](../../include_languages/python/API.md) —
[архитектура](../../include_languages/python/ARCHITECTURE.md) —
[установка](../../include_languages/python/DEPLOYMENT.md) —
[native-порты](../../include_languages/python/NATIVE_PORTS.md) —
[первичные источники](../../include_languages/SOURCES.md).

| Профиль | Основной Python внутри приложения | Существующий Python |
| --- | --- | --- |
| [Windows](../../include_languages/platforms/windows/README.md) | CPython, python-build-standalone, app-private installation | Отдельный worker/endpoint с handshake. |
| [Linux / Ubuntu](../../include_languages/platforms/linux_ubuntu/README.md) | CPython, python-build-standalone, совместимый libc/ABI | Изолированный worker выбранного установленного Python. |
| [macOS](../../include_languages/platforms/macos/README.md) | CPython, python-build-standalone, согласованный signing/deployment profile | Явно выбранный worker; app lifecycle и filesystem profile сохранены. |
| [Android NDK](../../include_languages/platforms/android_ndk/README.md) | Официальный CPython Android embedding, libpython и app-private assets | Явно предоставленный endpoint другого Python; app sandbox учитывается. |
| [MIR](../../include_languages/platforms/mir/README.md) | Python-профиль фактического native host | Те же внешние ворота host-профиля. |
| [WASM linear](../../include_languages/platforms/wasm_linear/README.md) | Pyodide / Emscripten с подходящими wheels | Явный host bridge; browser не запускает произвольный OS executable. |
| [RISC-V](../../include_languages/platforms/riscv/README.md) | CPython PBS для допустимого Linux RV64 profile | Host/endpoint; freestanding ISA сама по себе не предоставляет Python services. |
| [Прочие C99](../../include_languages/platforms/c99_other/README.md) | CPython только при наличии его реальных host dependencies | Bridge, если доступен транспорт и внешний Python. |

В каждом каталоге отдельный `PYTHON.md` фиксирует выбранную реализацию,
порядок установки, ABI, допустимые native extensions и альтернативный путь.
Версии и артефакты входят в install plan с хешами; имя платформы само по себе
не доказывает совместимость конкретного wheel.

Опубликованы 15 ворот: `py.open`, `py.close`, `py.install`, `py.import`,
`py.getattr`, `py.setattr`, `py.call`, `py.getitem`, `py.setitem`, `py.retain`,
`py.release`, `py.toValue`, `py.fromValue`, `py.buffer`,
`py.releaseBuffer`. Они соответствуют обычным LMX-телам; их подключение
к production runtime помечено `REQUIRE_IMPLEMENTATION`.

В LMX реализованы проверка install plan, установка через staging, admission
runtime/wheel, registry handles, отдельное владение native references,
преобразования и управление buffer leases. Физическая работа CPython C API,
filesystem/network и browser promises остаётся на явно типизированной
границе provider. Native GIL относится к C/L2.

## 2. Исходная map-библиотека и LMX-перенос

[LMX и аудит](../com.mtk.map/README.md) —
[сохранённый Java-код](../com.mtk.map/java_original/) —
[контрольные суммы](../com.mtk.map/validation/java_original_manifest.json).

В присланной Java-версии есть внутренние `synchronized` и ветви
неодинаковой глубины. Это проверено по исходникам и настоящей Java-пробой:
листовые глубины 1 и 2 под общим корнем, разные capacity ветвей, mixed-radix
адрес, изменения Cursor, изолированные bunch и параллельное добавление.
[Исходник пробы](../com.mtk.map/validation/OriginalMapProbe.java) и
[результат](../com.mtk.map/validation/original_java_probe.json) сохранены.

В LMX Java monitors заменены владением документа одним Message owner.
Композиция моделей использует текущие `copy`/`merge`, объявления DATA/CODE
и обычные ссылки. Глубина размещения не выравнивается в скрытое полное дерево.
Сохранены отдельные понятия страниц, ветвей, bunch, Cursor, словарей,
значений и перекрывающихся Tag.

Таблицы соответствия учитывают методы, конструкторы, интерфейсные и вложенные
объявления исходного Java AST. `SOURCE_TODO` означает незавершённый исходный
метод; `EXTERNAL_DEPENDENCY` — адаптер отсутствующей в архиве библиотеки.
Такие строки не объявляются реализованным production-кодом. Общий алгоритм
может обслуживать несколько Java overloads, с явными параметрами и результатом.

## 3. Cursor ↔ P0 ↔ MIX

[Архитектура и точные hooks](../com.mtk.map/p0/README.md).

Один owner удерживает исходный MIX, прямые Cursor, P0 bindings и принятый
корень. Первичный reader добавляет байты в MIX во время чтения P0.
Каждый байт получает отдельный скалярный record; изменение входного массива
не становится незарегистрированной правкой документа.

После правки используются журнал последовательных ревизий, перенос dirty
границ через каждый edit, ближайший допустимый предыдущий checkpoint и
точная сходимость состояния общего P0. Неизменённые узлы переиспользуются.
Снятие кавычки или структурной границы вправе расширить реально затронутую
область до EOF; запрещено принудительно публиковать неверный маленький фрагмент.

Группировка едина. Подпарсер `[]` понимает `[op` без пробела и slices
`var[arg:arg2:arg3]`; при выражении или `{...}` вызывает основной парсер и
получает позицию продолжения. Самостоятельного поиска закрытия чужой
грамматики у него нет. Новые incremental hooks обслуживают этот общий код.

P0 не удаляет события, ожидаемые другими consumers. В автономном профиле он
единственный потребитель; в общем профиле подтверждение проходит через
`MapOwnerAcknowledge` и минимальную ревизию всех подписчиков.
Ответы содержат скалярные receipts, изменяемые session и Cursor остаются
у владельца. Ошибка нового синтаксиса сохраняет исходник и диагностику,
а удерживаемое прежнее дерево явно помечается устаревшим.

## 4. Отдельные документы внутри якорей

Каждый mark связывает `Var.childDocument`, локальный `p0Root`, checkpoints,
две живые границы и owner binding. `MapSpan` удерживает диапазон общего
источника; отдельный изменяемый текст для него не дублируется.
Нотация `{LMX}` / `{MIX}` не вводит таких буквальных ключевых слов в языке.

MIX scan читает готовые Var и их атрибуты. `{end}` выбирает последнее активное
открытие, `{end: red}` — последнее активное открытие с соответствующим
close value. Пересечение red/green допустимо. Var сохраняют свою identity
и получают общие Tag/partner; они не исчезают вместе со ссылками P0.

Текущий `atom_char` в присланном P0 считает code points исходного токена.
Он не является UTF-8 byte offset и не считается автоматически координатой
декодированной строки. Скалярные offsets старого узла привязаны к ревизии;
актуальная позиция читается из живого binding.

## 5. Четыре дополнительных design patterns

[Каталог асинхронных шаблонов](../spec/patterns/06_async_and_messages/README.md).

| Шаблон | Обязательное поведение |
| --- | --- |
| Request–Response / Ask | Correlation, состояние pending, обработчик ответа, deadline и подавление позднего/повторного ответа; обработчик не блокирует поток. |
| Become / Selective Stash | Отложены только зависимые business requests; запросы данных, ответы, отмена и служебные сообщения продолжают обслуживаться. |
| Phased Lifecycle | Завершение запрашивается заранее, завершения фаз принимаются отдельными сообщениями; generation отделяет старый child от нового; PostStop не ждёт другого owner. |
| External Blocking Adapter | Владелец принимает работу и completion сообщениями; физическая блокирующая операция относится к L2/native adapter, состояние LMX owner не удерживается внешним Lock. |

Существующие Actor, Active Object, Future, Guarded Suspension,
Structured Concurrency и Supervision служат контекстом. Дополнения оформляются
в том же каталожном формате со сценарием, сопоставимыми листингами,
метриками, границей общего runtime и честным статусом исполнения.

## Проверки и оставшаяся реализация ядра

Проверки разделены по исполнявшемуся коду:

- Java probe действительно компилирует и запускает исходную Java-библиотеку.
- CPython host probe действительно использует native C API доступного CPython.
- Host oracle проверяет арифметику dirty intervals, выбор checkpoint и
  исходные coordinate fixtures.
- Static reports проверяют состав файлов, ссылки, ограниченные
  лексические/отступные свойства, разрешение имён и сохранность Java.
- LMX production parser, TYPE/effect admission, Message execution и новые
  native P0/Python adapters остаются `NOT_RUN` / `REQUIRE_IMPLEMENTATION`,
  пока отсутствует полный пригодный для этих проверок runtime.

Следующая реализация в ядре должна:

1. Подключить и проверить обычные LMX-модули текущим P0 и common translator,
   включая `record`, квалифицированный `MapNil`, DATA/CODE и корневой запуск.
2. Реализовать объявленные Python native/installer ports для первого
   Ubuntu host и конечные bindings `py.*`; прогнать реальные reference,
   buffer, исключения, lifecycle и внешние worker cases.
3. Выделить continuation-state и Cursor-source существующего P0, провести
   hooks в общий builder, сохранить правильное владение native arenas и
   LMX bindings. Не дублировать parser/grouping.
4. Исполнить incremental acceptance с измерением прочитанных байтов,
   заменённых и переиспользованных узлов; проверить edits на границах,
   неверный промежуточный текст, Unicode и раздельные child scopes.
5. Исполнить четыре Message-протокола с доставкой ответов в разном порядке,
   deadline/cancel, повтором, старой generation и отказом native provider.
6. Повторить host/ABI/package проверки для остальных платформ согласно
   их отдельным справкам; C99-переносимость ядра проверяется независимо
   от доступности Python на конкретном устройстве.

Готовность документации и черновиков не превращает отсутствующий native
provider в успешную заглушку. Каждый неподключённый порт оставлен явным.
