# LMX: Функциональные вычисления

Haskell даёт естественный контроль для Maybe/Monad и каррирования. Scala сочетает функциональные приёмы с JVM, явным батутом и обычным управлением ресурсами. Эти языки выбраны за подходящие механизмы, а не для универсального рейтинга краткости.

Четыре прикладных сценария используют ядро LMX и реальные средства Haskell/Scala. Четыре соседних сравнения показывают самостоятельные реализации соответствующих компонентов; usage-клиенты их не импортируют. Сохранены только альтернативы с другим подходом.

## Files

[Comparison](LMX_Comparison_09_functional_computation.md) · [Excel](LMX_Comparison_09_functional_computation.xlsx) · [PDF](LMX_Comparison_09_functional_computation.pdf) · [CSV](LMX_Comparison_09_functional_computation.csv) · [Implementations](IMPLEMENTATION_DEPENDENCIES.md)

## Catalog

### [082. Monad](082_monad_comparision.md)

Две операции bind над обобщённым Maybe; прикладной half по-прежнему проверяет чётность целого числа.

Вызвать half дважды через bind. В some хранится запись значения с его собственным типом, а next получает само значение по обычному контракту вызова. Для отсутствия продолжение не вызывается. Проверки остаются 8, 6 и 3.

8 → присутствующее 2; 6 → отсутствие после второго half; 3 → отсутствие после первого half, второй half не вызывается. Готовая ссылка на half сама по себе вызовом не является.

### [091. Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md)

Обобщённый Maybe: наличие отделено от нуля, null, void и физического uninit; bind допускает изменение типа полезного значения.

Реализовать some(record), none() и bind(input,next). Полезное значение хранится как запись {type,payload}; отсутствие определяется только флагом present. При наличии next вызывается ровно один раз с полезным значением.

some записи нуля остаётся присутствующим нулём; some записи null остаётся присутствующим null. none не читает value и bind(none,next) не вызывает next. Следующий результат может хранить другой тип.

### [083. Trampoline](083_trampoline_comparision.md)

Взаимные even/odd шаги используют общий Bounce с nullary continuation, созданной partial.

Для неотрицательного n определить чётность. Незавершённый шаг возвращает more(partial(другой_шаг; (n−1))) без вызова другого шага. trampoline вызывает по одному сохранённому thunk до done.

0 → true, 1 → false, 100001 → false; LMX возвращает 1, 0, 0. Каждый шаг возвращает управление драйверу; вложенная цепочка вызовов even/odd не накапливается.

### [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md)

Обобщённый Bounce хранит запись произвольного результата либо nullary thunk; runner не знает тип результата или исходную арность шага.

Реализовать done(record), more(thunk) и trampoline(bounce). more сохраняет функцию без вызова; runner вызывает её ровно один раз на итерацию и возвращает результат done. Частичное связывание аргументов вынесено в общий partial.

trampoline(done(record)) возвращает ту же запись результата без вызова continuation. Каждый more запускает сохранённый thunk один раз. Пример чётности даёт 1,0,0 в LMX и true,false,false в контролях, не накапливая рекурсивный стек шагов.

### [084. Execute Around](084_execute_around_comparision.md)

Переданные acquire/action/release исполняются вокруг защищённого использования ресурса. Основной LMX включает короткий локальный helper целиком; общий bracket сохранён как текущий вариант.

Ресурс содержит 42. acquire добавляет в журнал 1, action — 2, release — 3. Режим 0 успешен, режим 1 падает в action, режим 2 — в acquire. Основной клиент вызывает встроенный bracket / Control.Exception.bracket / Using.resource: освобождает только полученный ресурс и наблюдает ошибку вместе с журналом.

run(0) → 42123: результат 42, журнал 123. run(1) → −123: ошибка тела дошла до клиента и release выполнен. run(2) → −1: acquisition отказал, release не выполнен. Ресурс не используется после cleanup.

### [098. Execute Around implementation](098_execute_around_implementation_comparision.md)

Обобщённый acquire/action/release: ресурс, полезный результат и дополнительные аргументы не привязаны к int.

Полностью реализовать контракт bracket для одного ресурса: получить один раз, вызвать action один раз, после успешного получения освободить один раз при успехе, допустимой ошибке и штатной остановке; сохранить произвольный результат/void. LMX заранее выделяет аргументы cleanup и регистрирует finally с проверкой успешного outcome до получения ресурса; Haskell использует mask/restore; Scala сохраняет два исключения по правилам приоритета и suppression, как Using.

Успех: журнал 123 и результат action. Ошибка action: журнал 123 и распространение ошибки. Ошибка acquire: журнал 1 без release. Соседний клиент кодирует эти случаи как 42123, −123, −1.

### [085. Currying](085_currying_comparision.md)

Прямой partial строит add5 и add100 из обычной функции; процедура копирования окружения вынесена в общую реализацию.

Объявить сложение и создать независимые add5/add100 через поэтапный curry либо partial. Контрольные клиенты используют применение Haskell и Function2.curried Scala. Сохранены saved=1000 и повторный add5(1); результат 6101006.

6, 101, 6; demo возвращает 6101006. Возвращённая функция имеет ровно один явный int-вход. Библиотечный LMX-прототип не меняется; две созданные функции независимы.

### [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md)

Общая реализация partial(F;prefix): произвольная смешанная сигнатура, 0≤k≤N, точный остаточный контракт и исходный return.

Реализовать произвольный типизированный префикс без привязки к int и двум входам: сохранить k из N значений в порядке и вернуть callable для N-k входов, не вызывая цель. Haskell Args/Callable и Scala Tuple/Callable задают вектор типов явно; LMX отражает существующий DATA и дополнительно сохраняет его defaults/binding.

Общий случай сохраняет порядок и типы входов, точный R и объявленные failures. Для клиента сложения результат — 6,101,6. Для N=0 фабрика возвращает nullary callable; для k>N отказ происходит до публикации результата.

## Counting boundary

For each comparable usage layer choose the shortest eligible core/real-library client. Implementation comparisons use full scoped APIs separately. Keep only genuinely different approaches; one-line or type-only alternatives are notes. The source upload is the merge baseline.

Runtime status: LMX, Haskell and Scala NOT_RUN. Prepared edge cases are in [acceptance_cases.json](acceptance_cases.json).
