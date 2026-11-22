# LMX: Функциональные вычисления

Haskell даёт естественный контроль для Maybe/Monad и каррирования. Scala сочетает функциональные приёмы с JVM, явным батутом и обычным управлением ресурсами. Эти языки выбраны за подходящие механизмы, а не для универсального рейтинга краткости.

В архиве одно текущее ядро LMX. Его операции вызываются напрямую; версии Maybe/Curry/Bounce для переключения не предлагаются. Основным выбран короткий корректный вариант текущего контракта и той же границы сравнения. Клиентам готовые компоненты доступны во всех трёх языках; в implementation-строках показаны настоящие тела, а общая инфраструктура посчитана отдельно. Прежние специализированные листинги сохранены рядом как пояснение и исключены из текущего подсчёта: они не подменяют общий контейнер или callable новым int-ограничением.

## Файлы

- [Markdown](LMX_Comparison_09_functional_computation.md)
- [Excel](LMX_Comparison_09_functional_computation.xlsx)
- [PDF](LMX_Comparison_09_functional_computation.pdf)
- [CSV](LMX_Comparison_09_functional_computation.csv)
- [Current core dependencies and implementation cost](IMPLEMENTATION_DEPENDENCIES.md)
- [Validation](VALIDATION_2026-11-22.md)
- [Receiver API](../LMX_Fn_Receivers/API.md)

## Каталог

### [082. Monad](082_monad_comparision.md)

Две операции bind над обобщённым Maybe; прикладной half по-прежнему проверяет чётность целого числа.

**Соседнее сравнение реализации:** [091. Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md)

**Основные варианты:** LMX: core, Haskell: generic, Scala: generic.

**Сценарий:** Вызвать half дважды через bind. В some хранится запись значения с его собственным типом, а next получает само значение по обычному контракту вызова. Для отсутствия продолжение не вызывается. Проверки остаются 8, 6 и 3.

**Наблюдение:** 8 → присутствующее 2; 6 → отсутствие после второго half; 3 → отсутствие после первого half, второй half не вызывается. Готовая ссылка на half сама по себе вызовом не является.

### [091. Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md)

Обобщённый Maybe: наличие отделено от нуля, null, void и физического uninit; bind допускает изменение типа полезного значения.

**Примеры использования:** [082. Monad](082_monad_comparision.md)

**Основные варианты:** LMX: core, Haskell: generic, Scala: generic.

**Сценарий:** Реализовать some(record), none() и bind(input,next). Полезное значение хранится как запись {type,payload}; отсутствие определяется только флагом present. При наличии next вызывается ровно один раз с полезным значением.

**Наблюдение:** some записи нуля остаётся присутствующим нулём; some записи null остаётся присутствующим null. none не читает value и bind(none,next) не вызывает next. Следующий результат может хранить другой тип.

### [083. Trampoline](083_trampoline_comparision.md)

Взаимные even/odd шаги используют общий Bounce с nullary continuation, созданной partial.

**Соседнее сравнение реализации:** [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md), [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md)

**Основные варианты:** LMX: core, Haskell: generic, Scala: generic.

**Сценарий:** Для неотрицательного n определить чётность. Незавершённый шаг возвращает more(partial(другой_шаг; (n−1))) без вызова другого шага. trampoline вызывает по одному сохранённому thunk до done.

**Наблюдение:** 0 → true, 1 → false, 100001 → false; LMX возвращает 1, 0, 0. Каждый шаг возвращает управление драйверу; вложенная цепочка вызовов even/odd не накапливается.

### [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md)

Обобщённый Bounce хранит запись произвольного результата либо nullary thunk; runner не знает тип результата или исходную арность шага.

**Примеры использования:** [083. Trampoline](083_trampoline_comparision.md)

**Основные варианты:** LMX: core, Haskell: generic, Scala: generic.

**Сценарий:** Реализовать done(record), more(thunk) и trampoline(bounce). more сохраняет функцию без вызова; runner вызывает её ровно один раз на итерацию и возвращает результат done. Частичное связывание аргументов вынесено в общий partial.

**Наблюдение:** trampoline(done(record)) возвращает ту же запись результата без вызова continuation. Каждый more запускает сохранённый thunk один раз. Пример чётности даёт 1,0,0 в LMX и true,false,false в контролях, не накапливая рекурсивный стек шагов.

### [084. Execute Around](084_execute_around_comparision.md)

Клиент вызывает прямой bracket; acquire/action/release и наблюдаемый журнал остались прикладным кодом.

**Соседнее сравнение реализации:** [098. Execute Around implementation](098_execute_around_implementation_comparision.md)

**Основные варианты:** LMX: core, Haskell: generic, Scala: generic.

**Сценарий:** Ресурс содержит 42. acquire дописывает 1 в журнал, action — 2, release — 3. Mode 0 успешен, mode 1 бросает ResourceFailure из action, mode 2 — из acquire. Клиент использует одинаковый готовый bracket во всех трёх языках и перехватывает ошибку только для наблюдения журнала.

**Наблюдение:** run(0) → 42123: результат 42, журнал 123. run(1) → −123: ошибка тела дошла до клиента и release выполнен. run(2) → −1: acquisition отказал, release не выполнен. Ресурс не используется после cleanup.

### [098. Execute Around implementation](098_execute_around_implementation_comparision.md)

Обобщённый acquire/action/release: ресурс, полезный результат и дополнительные аргументы не привязаны к int.

**Примеры использования:** [084. Execute Around](084_execute_around_comparision.md)

**Основные варианты:** LMX: core, Haskell: generic, Scala: generic.

**Сценарий:** После успешного acquire зарегистрировать release(resource), затем вызвать action(resource; additionalArgs...). Сохранить типизированную запись результата либо void. При ошибке acquisition release не вызывается; после успешного acquisition он вызывается ровно один раз при любом обычном выходе.

**Наблюдение:** Успех: журнал 123 и результат action. Ошибка action: журнал 123 и распространение ошибки. Ошибка acquire: журнал 1 без release. Соседний клиент кодирует эти случаи как 42123, −123, −1.

### [085. Currying](085_currying_comparision.md)

Прямой partial строит add5 и add100 из обычной функции; процедура копирования окружения вынесена в общую реализацию.

**Соседнее сравнение реализации:** [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md)

**Основные варианты:** LMX: core, Haskell: generic, Scala: generic.

**Сценарий:** Объявить сложение и вызвать partial(add;(5)) и partial(add;(100)). Получить 6,101,6 после завершения фабрики. Локальное saved=1000 не меняет сохранённые значения. Префикс — Structure записей, а не скрытый список только int.

**Наблюдение:** 6, 101, 6; demo возвращает 6101006. Возвращённая функция имеет ровно один явный int-вход. Библиотечный LMX-прототип не меняется; две созданные функции независимы.

### [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md)

Общая реализация partial(F;prefix): произвольная смешанная сигнатура, 0≤k≤N, точный остаточный контракт и исходный return.

**Примеры использования:** [085. Currying](085_currying_comparision.md), [083. Trampoline](083_trampoline_comparision.md)

**Основные варианты:** LMX: core, Haskell: generic, Scala: generic.

**Сценарий:** Исследовать сигнатуру F, принять и сохранить k входных записей, построить callable оставшихся N−k позиций. Захваченные примитивы — снимки значения; ссылочные значения сохраняют идентичность цели. k=0 и k=N допустимы, раннего вызова F нет.

**Наблюдение:** Общий случай сохраняет порядок и типы входов, точный R и объявленные failures. Для клиента сложения результат — 6,101,6. Для N=0 фабрика возвращает nullary callable; для k>N отказ происходит до публикации результата.

## Границы подсчёта

Измеряется только основной вариант — самый короткий рассмотренный допустимый алгоритм текущего контракта. Исторический LMX остаётся рядом с текущим кодом. Компоненты единого ядра и общая инфраструктура считаются отдельно. Выбор и подсчёт не означают успешного исполнения.
