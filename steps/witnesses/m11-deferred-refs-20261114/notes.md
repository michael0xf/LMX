# M11.5г — срез 373: вычисляемые ссылочные места

MAIN C:/Nyasha_Planet/LMX, база 372 — 6cef32080ff515831786ac0f2bf253f944f9bbad.
Writer/build — codex Sol; pipeline sol-m11-deferred-refs-20261114-01, общий stage S.
Старое W3 остаётся резервной копией; чужие два untracked не включаются в срез.

## Реализация

Прежняя карта мест принимает retained raw @ с кандидатом: три поля для int-reference,
два для Structure-reference. Общий deferred_kind распознаёт те же поддержанные формы
в data_cell, own-kind, preflight и value reader; FN values не являются объявлениями мест.
При связывании строки expected_kind фиксируется один раз. Initializer поданных данных
не исполняется. Первый store после допуска payload создаёт рабочую typed reference;
прежний flush публикует отдельную physical cell. Последующие записи используют прежний
writer и сохраняют существующие slot/cell. Старые initialized-reference snapshots и
uninit wrappers не заменены новым механизмом, таблиц и initialized-флагов не добавлено.

Классификация и чтение используют ровно один прежний binding search: private
resolve_binding дополнительно возвращает выбранную work row. Ближний formal, own local
или метод данных сохраняет приоритет над отложенным местом внешней активации. Raw int
после рабочей записи читается из row.number, raw reference после записи — из рабочей
reference cell. Value reader сохраняет отказ5 неисполненного вычисления R12; classification
не выдаёт source Frame за обычную Structure/голову запуска. Local_int сведён к known_int:
ссылочная декларация не проходит числовой preflight и не запускает RHS.

## Независимые наблюдения

- deferred_reference_places: Self выполняет свой receiver и меняет p с x40 на y41;
  ordinary Code над D даёт p→y13, s→Target(n30); настоящий Writer над другой D2 даёт p→y23.
  Начальные вычисления D/D2 и модели Writer не выполняются: calls=0. Writer проверяет
  тот же первый store в native метода, без компиляции обычной Structure через fake method.
- deferred_reference_read_refused и deferred_reference_head_refused: 5 при достигнутом
  чтении/вызове p; before=1 публикуется, before=2 не достигается, calls=0, p остаётся raw.
- deferred_reference_type_refused: int destination не принимает reference receiver — 4
  до touch, calls=0 и seen=0.
- deferred_numeric_type_refused: reference destination не принимает int receiver — 4
  до touch, calls=0 и reached=0.
- deferred_binding_priority: ближайшие formal/own/data-method дают 7/8/9; working raw int
  после x:=12 подаётся sink как 12 до публикации на границе вызова. calls=0, D.x=12.

Принятый graph372 на окончательных исходниках: places5 вместо0, binding-priority4 вместо0;
read/head дают5 раньше before1 (before=0). Type-case уже даёт4 без эффектов; numeric-case
раньше отказывает5 на входе, новый preflight даёт4 по типу до RHS. Baseline-final квитанции
сохраняют полные состояния. Ни одно прежнее положительное ожидание не ослаблено.

## Сборка и текущие проверки

Runtime01 остановился на диагностике L2 о типе row.cell; явные native-field casts исправлены.
Runtime02 и graph01 собраны штатными командами из Source02; Source03 добавляет шесть
пар фикстур и уточняет комментарий без изменения алгоритма. Source03: 643 входа, verify прошёл;
manifest 9fd702d046e0ba704b24abd175296bd8ecccf853c9026d2a8d04aef327a145b3.
Driver02: 4295bc63e41b36e01ef36a9f1c83e91c1ddf7b44a00f047964dc1371b4f4753f.
Graph01: e0a05a6b8fa11b5d3c725fdf0fbbf7a1d12a0970e20afcc8b059c437ac7081dc.

Все шесть новых pure случаев прошли. Private01 содержит 22 случая в трёх режимах;
одна строка имела ошибочный ожидаемый ответ4 для старой reference_number_refused. Фактический
ответ2 совпадает с принятыми квитанциями369 и baseline372. Точный повтор обходчика с ожидаемым2
прошёл; оба native режима той строки прошли изначально, повторная C-сборка не нужна.
Остальные 21 строки прошли без поправок. Все 24 полных AFTER-сравнения восьми отрицательных
случаев и все 24 встроенные mutation checks прошли. Исходный неуспешный log не переписан.

Полный bootstrap01 quick из принятого372 прошёл: настоящие G1/G2, по 9 smoke каждый.
Все 13 проверок фиксированной точки прошли, включая оба runtime objects и тождество
частного driver02, Source03 и verify643. Штатный G2 заново собрал graph-tool: все 22 случая
в трёх режимах, AFTER24 и все 24 mutation checks прошли с правильной ожидаемой2 старой строки.
M8 consumer gap2 отдельно воспроизведён и на штатном G2; нормативные n1/calls0 ещё не достигнуты.

Рабочая связка в S: boot-m11-deferred-refs-01/g2 и graph-m11-deferred-refs-g2-01.
G2 driver.o: 4295bc63e41b36e01ef36a9f1c83e91c1ddf7b44a00f047964dc1371b4f4753f.
G2 driver-observe.o: ade1a31343cacf50fd28c974a58826b0362fe57eba1e113a5402806702b39b0d.
G2 graph: cd359877061ce71ac0b9e91b3da67518e3d80374a36b6a7433ae77456299b8e9.
Штатные render semantics и docs check прошли: 35 пар семантики, 14 cases implements,
27 пар грамматики, 44 выдержки, 615 импортов, ссылки, точное начало семантики и LF индекса
для 27 317 файлов на момент проверки. Оба diff --check чисты. Квитанция docs-check01
добавлена после проверки с нормализованными LF. Чужие два untracked сохранили прежние SHA:
627ceecbc7bca3fb54ff8b6fa866f4ee48b5578d671cdc2cb9372db20993b125 и
b6db206a6f05cc58d086aa3c6575c6b27a0e252785c09f6be5c0e87e51e7d910.

## Открытые границы

Независимая дополнительная проба M8 сохранена в m8-one-field-reference-value.lm2:
@: Code (int:p touch()) на нынешнем и принятом372 graph отвечает2. Нормативный результат
по M8/book97, Р17 и reference-binding @2 — Structure Code с одним написанным объявлением,
n=1 и calls=0. Внешний список аргументов читается как код; вложенное written Structure-value
само не выбирается CodeBody. Поздний Р12 не разрешает выполнить этот initializer при
подготовке обычных данных. Группа P0 сохранена; ошибка находится в receiving-context.
Это существовавший до373 остаток, не исправление373 и не зелёная проверка нормативного
результата. M8 consumer вновь открыт в основном v3/чек-листе; после приёмки373 он идёт
перед дальнейшим root/self. Не исправлять его по конкретному имени touch/int/Code или
добавлением второго statement, не раскрывать группы универсально.

Настоящее @:p int без кандидата — kind5 с заранее существующими wrapper8/cell5. Его полная
construction-поддержка остаётся OPEN; форма явно не поддержана, а не ошибочно kind6. Нельзя
создавать это uninit:T первой записью или использовать wrapper как initialized-флаг.
До записи начальное значение не обещано, проверки не читают непредъявленный payload и не
требуют специального отказа. Отказ5 выше относится к retained вычислению с кандидатом R12.

Полный общий root frame, именованные physical reference records в code после публикации,
прямой path-head launch, M11.7/8 и M13/M14/cache/flush/GC живых кадров остаются OPEN.
Весь план v3 остаётся активным; этот срез его не завершает.
