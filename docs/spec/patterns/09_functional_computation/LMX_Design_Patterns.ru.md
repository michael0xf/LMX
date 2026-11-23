# LMX: Функциональные вычисления

Haskell даёт естественный контроль для Maybe/Monad и каррирования. Scala сочетает функциональные приёмы с JVM, явным батутом и обычным управлением ресурсами. Эти языки выбраны за подходящие механизмы, а не для универсального рейтинга краткости.

Четыре задачи имеют две полные LMX-записи: процедурную и функциональную. Haskell и Scala сохраняют исходные контрольные программы. Четыре реализации ядра сравниваются отдельно и имеют по одному общему LMX-телу.

## Каталог / Catalog

### [082. Monad](082_monad_comparision.md)

Maybe: явная проверка промежуточного результата и компактная цепочка bind.

Выполнить some(x) bind half bind half. Значение хранится со своим фактическим типом, half получает его обычным вызовом. При None следующие продолжения пропускаются. Проверки остаются 8, 6, 3 и дополнительно 0.

8 → присутствующее 2; 6 → отсутствие после второго half; 3 → отсутствие после первого half, второй half не вызывается. Готовая ссылка на half сама по себе вызовом не является.

### [091. Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md)

Обобщённый Maybe: наличие отделено от нуля, null, void и физического uninit; bind допускает изменение типа полезного значения.

Реализовать some(record), none() и bind(input,next). Полезное значение хранится как запись {type,payload}; отсутствие определяется только флагом present. При наличии next вызывается ровно один раз с полезным значением.

some записи нуля остаётся присутствующим нулём; some записи null остаётся присутствующим null. none не читает value и bind(none,next) не вызывает next. Следующий результат может хранить другой тип.

### [083. Trampoline](083_trampoline_comparision.md)

Паритет: процедурный цикл и функциональный trampoline для конечного неотрицательного n.

Для неотрицательного n определить чётность. Незавершённый шаг возвращает more(partial(другой_шаг; (n−1))) без вызова другого шага. trampoline вызывает по одному сохранённому thunk до done.

0 → true, 1 → false, 100001 → false; LMX возвращает 1, 0, 0. Каждый шаг возвращает управление драйверу; вложенная цепочка вызовов even/odd не накапливается.

### [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md)

Обобщённый Bounce хранит запись произвольного результата либо nullary thunk; runner не знает тип результата или исходную арность шага.

Реализовать done(record), more(thunk) и trampoline(bounce). more сохраняет функцию без вызова; runner вызывает её ровно один раз на итерацию и возвращает результат done. Частичное связывание аргументов вынесено в общий partial.

trampoline(done(record)) возвращает ту же запись результата без вызова continuation. Каждый more запускает сохранённый thunk один раз. Пример чётности даёт 1,0,0 в LMX и true,false,false в контролях, не накапливая рекурсивный стек шагов.

### [084. Execute Around](084_execute_around_comparision.md)

Полный локальный Around и функциональный bracket сохраняют один ресурсный жизненный цикл.

Ресурс содержит42. acquire/action/release добавляют1/2/3 в журнал. Оба полных LMX-варианта сохраняют режимы успеха, отказа action и отказа acquire; освобождается только полученный ресурс.

run(0) → 42123: результат 42, журнал 123. run(1) → −123: ошибка тела дошла до клиента и release выполнен. run(2) → −1: acquisition отказал, release не выполнен. Ресурс не используется после cleanup.

### [098. Execute Around implementation](098_execute_around_implementation_comparision.md)

Обобщённый acquire/action/release: ресурс, полезный результат и дополнительные аргументы не привязаны к int.

Полностью реализовать контракт bracket для одного ресурса: получить один раз, вызвать action один раз, после успешного получения освободить один раз при успехе, допустимой ошибке и штатной остановке; сохранить произвольный результат/void. LMX заранее выделяет аргументы cleanup, сохраняет успешный результат acquire в готовую ячейку и регистрирует finally перед подготовкой action; Haskell использует mask/restore; Scala сохраняет два исключения по правилам приоритета и suppression, как Using.

Успех: журнал 123 и результат action. Ошибка action: журнал 123 и распространение ошибки. Ошибка acquire: журнал 1 без release. Соседний клиент кодирует эти случаи как 42123, −123, −1.

### [085. Currying](085_currying_comparision.md)

Независимые сохранённые префиксы: прямое окружение и общий curry.

Объявить сложение и создать независимые add5/add100 через поэтапный curry либо partial. Контрольные клиенты используют применение Haskell и Function2.curried Scala. Сохранены saved=1000 и повторный add5(1); результат 6101006.

6, 101, 6; demo возвращает 6101006. Возвращённая функция имеет ровно один явный int-вход. Библиотечный LMX-прототип не меняется; две созданные функции независимы.

### [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md)

Общая реализация partial(F;prefix): произвольная смешанная сигнатура, 0≤k≤N, точный остаточный контракт и исходный return.

Реализовать произвольный типизированный префикс без привязки к int и двум входам: сохранить k из N значений в порядке и вернуть callable для N-k входов, не вызывая цель. Haskell Args/Callable и Scala Tuple/Callable задают вектор типов явно; LMX отражает существующий DATA и дополнительно сохраняет его defaults/binding.

Общий случай сохраняет порядок и типы входов, точный R и объявленные failures. Для клиента сложения результат — 6,101,6. Для N=0 фабрика возвращает nullary callable; для k>N отказ происходит до публикации результата.

## Методика / Method

Two complete LMX style clients are compared for082–085; neither is removed by a shortest-source selection. All declarations and Throws count in full. Shared implementation records091/092/098/099 retain one canonical LMX body; foreign sources are unchanged.

[Comparison](LMX_Comparison_09_functional_computation.md) · [Excel](LMX_Comparison_09_functional_computation.xlsx) · [PDF](LMX_Comparison_09_functional_computation.pdf) · [CSV](LMX_Comparison_09_functional_computation.csv)

Runtime LMX: NOT_RUN.
