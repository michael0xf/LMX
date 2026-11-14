# M11.5г/M14: общий рабочий кадр корня, срез378

2026-11-14, Codex. База main/origin:
04fbf275c4801b648f8750d6d57f83641ae4f1f9 (принятый377).
Один writer/build Sol; работа только C:/Nyasha_Planet/LMX, main.

## Контракт и изменение

Корень использует прежние work_open_data/work_finish и block0; native wrapper
закрывает кадр при любом исходе inner body, forced run переиспользует его.
Plain run открывает собственный кадр только при отсутствии кадра активации.
AFTER standalone host печатается после публикации. Новый frame/storage/API не добавлен.
Отдельный root emitter и его таблица прохода removed; общий emit_block исполняет
CODE numeric/reference/assignment через те же mapped helpers, что методы.
Own data_run сохраняет отдельную фазу и не исполняется для ordinary/root data.

Computed fn/sub исполняют прежний fn_apply по настоящему body/index. Existing
binding_open сохраняется для unknown computed names до producer; после него
promoted free row получает F без повторного чтения внешнего fallback.
Typed RHS/actual readers не менялись. Bare primitive value fields стоят в любом
BODY и не создают scanner inputs; настоящий operator AST читает discarded value,
без искусственного требования int. Три старых bare control в control_flow,
place_reference_unknown и sub_calls заменены explicit break:/return:, вместе
с точечным изменением dump в expected; числа и фазы отказов сохраняются.

## Независимые ожидания и измерения

- root_frame_snapshots: x8, snapshot1/again1/direct8; reference snapshot10/direct20.
  В dirty mapped value local3, address/direct1 до публикации; после finish тот же value3.
- root_computed_namespace: first21/second32, made_calls2/made_steps2, source counters0.
- root_computed_early_refused: ответ3, before1/after0/touches0; actual не вычислен.
- discarded_values: before_effect0/after_effect1/after_call2. Bare unknown и control
  words не запускают операторы; formed prefix AST выполняет effect ровно один раз.
- root_frame_error: ответ6, x9/after0; локальная dirty запись опубликована после ошибки.

Все пять окончательных pure случаев прошли на runtime01/graph01. Code Source01
заморожен; Source02/681 добавил четыре пары фикстур. Private01 произвёл50 случаев
в трёх режимах;48 совпали, grouped_actual_contract и computed_data_reentry имели
golden delta чтения root k после nested publication. Независимо подтверждены пять
изменений: closed/open/data_outside8→5, data_result118→115, second892→592.
Open_result55 уже был55 в HEAD377 и сохранён. Root k остаётся локальным5,
физический k в AFTER равен8; open_data даёт100+10+5, второй outer —90+2+500.
Ни один из этих50 бинарников не пересобран ради ожидаемых чисел.

Дополнительный root_frame_error прошёл interp/native/forced. Общий повтор
153 полных AFTER-сравнений всех51 случаев сначала обнаружил отсутствие
finally_body_error.expected/sub_error.expected (по3 режима); прежний negative
graph-check проверял там только ответы6. Добавлены полные expected со значениями
root_trace12/seen12, независимо выведенными по finally публикации.
После этого все153 сравнения и24 mutation checks прошли. Это60 полных наблюдений
20 отрицательных случаев и93 наблюдения31 положительного, а не только exit codes.

Source04/685 проверен, SHA-256
b8e7d5a1a3742540b298ac30f0f1c2cc2f72fa776a358d14258ab1bd77e935d4.
Runtime01 driver97ca2cbc38956da9e99639ffc250d7d6a9ea7af9e99c3e59a5f9d03efbd4c1a5,
driver-observe4e1a4e04d1e1e153e00ca76634a4074a3a3415534a96b41ae088664f2f13c02b.
Graph01 SHA210553b9ff462ebd1b3876ab37ad03d74c877b7dc0a3e0bebb22f943e7defa55.
Whole bootstrap01 quick прошёл; G1/G2, fixedpoint13 и повтор штатным G2 подтверждены ниже.
Docs-check прошёл; далее commit/push main.

## Адреса и открытая construction-миграция

Поздняя норма различает mapped declared cell и local working value: local3 при
address/direct1 до публикации корректен. Formal/free-input получает свою ячейку
активации, поэтому прежний dynamic_inputs контроль7 сохраняется.
Legacy computed-int до публикации всё ещё представлен raw Frame без заранее
физической typed cell. Research-only computed-address-open отвечает3; это
известная общая construction-зависимость M13, не языковая норма отказа.
Нельзя возвращать row.number/transient operand address или вставлять flush ради @.
Зависимость внесена в основной v3. Полный M13, shared direct cache/flush и ordinary
native M14, path-head launch и остатки M11.5г/5д/5е/7/8 остаются OPEN.
Весь goal ACTIVE.

## Самосборка и фактический native

[Whole bootstrap01 quick](bootstrap01.log) построил настоящие G1/G2, по9 smoke.
[Fixedpoint13](fixedpoint01.log) и verify685 прошли; runtime01 тождественен штатному G2.
Штатный G2 [заново построил graph-tool](g2-build01.log) и повторил51 случай в трёх режимах:
[manifest](g2-01.tsv), [receipt](g2-01.log). Все60 [полных AFTER](g2-after01.log)
20 отрицательных случаев и24 [mutation checks](g2-mutation01.log) прошли.
Рабочая связка S/boot-m11-root-frame-01/g2 + graph-m11-root-frame-g2-01.
G2 graph SHA-256 dff1d7202b123be1758e88248960da8ba6f64aed57929729ba8edf453255eed7.

Одноразовый внешний GDB [trace01](native-root-frame01.log) подтвердил вход
lm_graph_root→lm_graph_body→lmx_call0_mode→lmx_graph_call и normal exit.
Actual binary SHA-256 a82eb14bce611fd55ec0eb154cfa645fe665970a8de431b67e99254b60ad6843.
[Генерируемый фрагмент](native-root-frame-generated.txt) показывает mapped stores и wrapper
work_open_data/work_finish; native p.lm1 не содержит вызова lmx_graph_run.
Новый поддерживаемый debugger runner, искусственный метод или рукописный L1 не добавлялся.
Это фактический native root, не утверждение о native любой обычной C в M14.

Baseline377 повторён на окончательных пяти sources без пересборки:
[snapshots](baseline-final-root_frame_snapshots01.log),
[computed namespace](baseline-final-root_computed_namespace01.log),
[early refusal](baseline-final-root_computed_early_refused01.log),
[discarded values](baseline-final-discarded_values01.log),
[dirty-error control](baseline-final-root_frame_error01.log).
Штатный render semantics прошёл:35 пар разделов,14 implements cases, обе исходные выдержки.
Штатные [render semantics](render01.log) и [docs-check](docs-check01.log) прошли:
35/14/27/44/615, ссылки, точное начало семантики и LF индекса27517.
Квитанция docs-check добавлена после проверки с LF. Оба git diff --check чисты.
Два чужих untracked сохранили SHA-256:
627ceecbc7bca3fb54ff8b6fa866f4ee48b5578d671cdc2cb9372db20993b125 и
b6db206a6f05cc58d086aa3c6575c6b27a0e252785c09f6be5c0e87e51e7d910.
