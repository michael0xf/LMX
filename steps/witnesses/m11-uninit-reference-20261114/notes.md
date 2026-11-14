# M11: предвыделенное int-reference без кандидата, срез 376

2026-11-14, Codex. База — принятый 375 в main,
`a8d37639689078d9295dce3b8b6e0e6a9842f627`. Работа только из
`C:/Nyasha_Planet/LMX`; единственный writer/build — Sol, весь goal v3 ACTIVE.

Статус записи: runtime02 и graph03 построены; окончательный source04/669 проверен,
код пяти изменённых файлов заморожен. Пять окончательных pure-interpreter проб
прошли с ответами 0/0/5/4/0. Private36 в трёх режимах, AFTER42/mutation24,
полный bootstrap G1/G2, fixedpoint13 и повтор штатным G2 прошли.
Штатный render/docs cycle прошёл.
Результаты ниже не объявляют закрытие всего M11.5г, M11.8 или M13/M14.

## Норма и объём изменения

- [Объявляющий контракт](../../../provenance/semantics-book.md#receiver-args-only)
  и [представление места](../../../docs/kernel-implementation.ru.md#lmx):
  `@: p int` без кандидата требует заранее существующее место int-reference,
  а не Structure-reference и не тип, определённый первым присваиванием.
  В слоте стоит wrapper8, он указывает на cell5 с именем p. Первое и дальнейшие
  присваивания сохраняют slot/wrapper/cell; начальный payload не обещан.
- Сигнатура не исполняет текст своего формала. Такой formal8 обязателен,
  не имеет умолчания и при допуске actual получает независимую int-reference cell.
  Проверка не читает payload самой сигнатуры. Numeric и Structure receiving-context
  сохраняют свои правила; reference-expression context3 не является новым типом языка.
- [Единственная Structure аргументов](../../../provenance/semantics-book.md#whole-arguments)
  связывает свои поля с формалами; именованный actual остаётся значением выбранного
  формала. Допуск ссылочного actual не меняет исходную ссылочную ячейку вызывающего.
- [Роли данных и кода](../../../provenance/semantics-book.md#data-code-roles):
  достигнутый wrapper8 проверяет int-reference destination без чтения payload и store.
  Явный merge остаётся производителем: соседний вычисляемый initializer исполняется
  один раз; наличие type-only поля этого не отменяет.

Изменены пять существующих исходников: `l2_graph_build.lm2`,
`l2_frontend_graph.lm2`, `l2_graph_tool.lm2`, `lmx_graph.lm2`, `lmx_graph_run.lm2`.
Нового парсера, реестра `@`, runner или отдельного хранилища нет.

Общий private `build_place` продолжает прежний int helper и строит exact named
`@: p int` через `uninit_reference(5)` до классификации Frame как блока. Корректный
`end: @` уже проверен и не препятствует предвыделению; null/end проходят guard,
настоящий `until` сохраняет прежний postloop lowering. Compact non-colon `@`
остаётся операторным выражением. Вычисляемые кандидаты и другие модели не сворачиваются.

Frontend распознаёт formal/declaration/reference kind8; dump сохраняет запись
`@: p int`. Runtime actual-contract3, call-reading и written-whole используют
общий binder; admit8 проверяет actual через `reference_payload` для family5
и создаёт независимый `ref_int`. Прежние numeric/Structure контракты и правило
умолчания только у kind1 не расширены.

Private serializer `emit_node` обрабатывает physical3/5/6/8/9 одной source-address
map вместе со Structure и её parent closure. Адрес резервируется до обхода рёбер;
имена, общие ячейки и физические указательные рёбра сохраняются. Нулевые биты
переносятся как биты исходной памяти, не как придуманное языковое начальное NULL.
Parent edges устанавливаются после выделения адресов. Type-only8/9 в literal-field
получают form4: direct put исходного поля, затем прежнее глубокое merge-copy;
соседние вычисляемые поля проходят обычный producer reader.

## Окончательные пробы

| Фикстура | Независимые ожидания и измеренный pure результат |
| --- | --- |
| [uninit_reference_places.lm2](../../../selfbuild/tests/graph/uninit_reference_places.lm2) | Ответ0, pure04. До записи before_type/old_before_type1001028. Old[0] получает исходный wrapper S[2] без чтения payload; WriteX публикует first_source/first_alias10. Настоящий TypeOnly имеет physical8 в code: code_type1001028, после его type-only проверки after_check10. Grouped20, named23, whole50; after_formals10 доказывает независимость formal reference cell. После WriteY last_source/last_alias20; after_type/old_after_type1001028, source_length3/alias_length1. |
| [uninit_reference_visibility.lm2](../../../selfbuild/tests/graph/uninit_reference_visibility.lm2) | Ответ0, pure02. Первый initializer own data видит предвыделенное позднее D.p: early1001028. После записи и обычного завершения вызова late1001028/seen7; data traversal не создаёт место задним числом. |
| [uninit_reference_missing.lm2](../../../selfbuild/tests/graph/uninit_reference_missing.lm2) | Ответ5, pure02; before1/after0/calls0. `take()` не подаёт обязательный formal8, его непредъявленный payload не превращается в default. |
| [uninit_reference_wrong.lm2](../../../selfbuild/tests/graph/uninit_reference_wrong.lm2) | Ответ4, pure02; before1/after0/calls0. Именованный Structure-reference actual Wrong несовместим с primitive int-reference; тело take не запускается. |
| [uninit_reference_merge.lm2](../../../selfbuild/tests/graph/uninit_reference_merge.lm2) | Ответ0, pure01. Mixed содержит wrapper8 и вычисленное q7, calls/ran1; before_type/after_type1001028, seen10 после Fill, made2/computed7. Type-only поле не подавляет вычисление соседнего initializer и сохраняется при глубоком копировании merge. |

Число1001028 — адресный тип wrapper текущего профиля; универсальный числовой код
типа языком не закреплён. До первого store пробы читают только header/index/type,
а не непредъявленное значение p. Публикацию обеспечивают обычные завершённые
вызовы; от ещё открытого ресивера `flush()` эти фикстуры не зависят.
Old alias независимо обнаруживает замену declaration slot или потерю исходного
wrapper. Прямую неизменность адреса underlying cell дополняют существующие
mutation address checks; один numeric witness не подменяет эту проверку.

## Промежуточные результаты и квитанции

Квитанции находятся в
`build2/codex_fix250generationchain01/runs/sol-m11-uninit-reference-20261114-01`.
`manifest03.log` подтверждает659/0; `runtime02.log` и `graph03.log` — сборки.
Финальные pure: `pure04-uninit_reference_places.log`,
`pure02-uninit_reference_visibility.log`, `pure02-uninit_reference_missing.log`,
`pure02-uninit_reference_wrong.log`, `pure01-uninit_reference_merge.log`.

Историю не считать дополнительными успешными gates: graph01 отказал при сборке
из-за имени var в поддерживаемом профиле; исправление позволило собрать graph02.
На graph02 explicit `end: @` у Old оставлял Structure type13: перенос общего
конструктора primitive place перед block classification исправил это в graph03.
Отдельный mixed merge probe на graph02 сохранял q вычислением и отказывал5 при
чтении; literal-field form4 исправил producer route. На graph03 q7/calls1 подтверждены.

## Границы приёмки

Нормализованный TypeOnly имеет настоящий method.code с physical8 до emit.
Private и штатный G2 выполнили его в native/forced, а одноразовый внешний GDB
подтвердил реальный вход body2→method2→lmx_call_prim_values и normal exit:
[private trace03](native-typeonly03.log), [G2 trace01](g2-native-typeonly01.log).
[Генерируемый фрагмент](native-typeonly-generated.txt) показывает known_place/type5
без чтения payload/store, а также установку method2 на root[7]. Поддерживаемый runner
или искусственный метод для диагностики не добавлялся; выполнялся штатный binary.

Ordinary Self и Types.data из среза375 всё ещё исполняются обходчиком; общий native
обычных Structure и прямое native-покрытие остальных physical5/6/9 остаются M14.
Срез не завершает произвольные formal models, void references, глубину указателей,
мерность Array или весь M13. Отдельные границы whole-missing fallback и explicit
given_args transport не считаются закрытыми допуском нового mandatory formal8.

## Окончательная кодовая приёмка

[Source04](source04.sha256) содержит669 canonical inputs; [verify](manifest04.log) —669/0.
SHA-256 манифеста de34eb33fb7f603d1ed08c8bf7f69da0c7ffe5cd473d3408f9e770f5e6840daf.
После Source03 менялись только пять пар зарегистрированных фикстур, код ядра тот же.
[Runtime02](runtime02.log) и [graph03](graph03.log) построены; driver
a9c9435e3aabbdce31da217e1f7d7a909509711d0c8292b5277ae56fe7d84d11,
driver-observe40910ed0d9206835358df56e1537c5aa15038d6fa9c9bd50d89c5708f2f94143.

Baseline375 повторён на окончательных пяти sources без пересборки:
[places5](baseline-final-uninit_reference_places.log),
[visibility4](baseline-final-uninit_reference_visibility.log),
[missing5](baseline-final-uninit_reference_missing.log),
[wrong4](baseline-final-uninit_reference_wrong.log),
[merge5](baseline-final-uninit_reference_merge.log). Первые два и merge исправлены;
missing/wrong сохраняют прежний правильный отказ до тела.

Все36 случаев прошли в трёх режимах: [manifest](private01.tsv), [receipt](private01.log).
Все42 полных AFTER-сравнения14 отрицательных случаев прошли:
[manifest](private-after01.tsv), [receipt](private-after01.log).
Все24 [mutation checks](mutation01.log) прошли. [Whole bootstrap01 quick](bootstrap01.log)
из принятого375 построил настоящие G1/G2, по9 smoke; [fixedpoint13](fixedpoint01.log)
и verify669 прошли. Сравнения включают оба runtime objects и тождество private driver02.
Штатный G2 [построил graph-tool](g2-build01.log) и повторил36 в трёх режимах:
[manifest](g2-01.tsv), [receipt](g2-01.log), все42 [AFTER](g2-after01.log)
и24 [mutation checks](g2-mutation01.log) прошли.
Рабочая связка S/boot-m11-uninit-reference-01/g2 и graph-m11-uninit-reference-g2-01.
G2 graph SHA-256 2c125a2f3dd931296ec336fad9f2d0a4ec1447c898f3ec0756a0fdf2cd31795d.
G2 TypeOnly native binary b9b1f054904676da31a56a9b7150f866f2230b159eed7e97f582b0ccdc2d74b6;
private binary607b0b751ffef5e2e62be7621012b4061e63e5e24b7dd5d955c755650b478674.
Оба одноразовых GDB trace подтвердили вход в ту же настоящую body2 и normal exit.
Штатный render semantics прошёл:35 пар разделов,14 implements cases и обе исходные выдержки.
Штатный [render](render01.log) и [docs-check](docs-check01.log) прошли:
35/14/27/44/615, ссылки, точное начало семантики и LF индекса27434.
Квитанция docs-check добавлена после проверки с LF. Оба diff --check чисты.
Два чужих untracked сохранили SHA-256:
627ceecbc7bca3fb54ff8b6fa866f4ee48b5578d671cdc2cb9372db20993b125 и
b6db206a6f05cc58d086aa3c6575c6b27a0e252785c09f6be5c0e87e51e7d910.
Приёмка среза не закрывает оставшийся основной v3; goal ACTIVE.
