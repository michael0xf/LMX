# M11.5г: written nested methods ordinary Structure, срез 377

2026-11-14, Codex. База main/origin:
9039fa892658ba6c12f91e35f576c52b9f2a02a7 (принятый376).
Работа только C:/Nyasha_Planet/LMX, main, один writer/build Sol.

Норма: written fn/sub отвечает в обе стороны своего блока; F создаётся из
написанного объявления в namespace текущего обхода. Повторный запуск в том же
обходе использует то же значение F и его own data. Следующий независимый обход
строит свою F. Видимость метода не запускает вычисляемые initializers ordinary data.
Источники: [части и создание метода](../../../provenance/semantics-book.md#method-parts) и
[kernel §3.4](../../../docs/kernel-implementation.ru.md).

Изменён только lmx_graph_run.lm2: work_open_parts перед work_scan готовит
непосредственные written declarations data/body прежним space_declarations.
Когда data=body, проход один. space_declare переиспользует существующий
binding_method(scope, raw), который проверяет made.parent=raw; одно имя
само по себе не является доказательством того же объявления.
Ordinary data_run и computed fn_apply не расширены, новой таблицы или ABI нет.

Baseline376 на ordinary-nested-probe отвечает3: ordinary State не находит
leaf до написанного fn. Независимое ожидание двух запусков first1/second2;
companion D/C должен дать11/12, touch_calls0, без чтения cold initializer.
Первоначальная pure probe дала first1/second2 и D11/12/cold0 на runtime02/graph02.
Окончательная расширенная фикстура проверяет fn и sub в State, методы в data D
и выбранном body C. Результаты: first1/second2, leaf_count2/sub_count2/bumped2,
from_data32/from_data_again34, data_count12/code_count22, ignored_initializer0.
State запускается над собой: primitive bumps является текущей source/data cell,
поэтому повторный запуск не восстанавливает отдельный литерал0.
Два разных raw fn leaf в Bad сохраняют отказ3, before1/after0/out0.

Зарегистрированы ordinary_nested_methods и ordinary_nested_duplicate_refused;
Source02 содержит673 inputs, SHA-256
1441737c4cf71b27ab81c4734846f1b30a469326f7146f1dc86c33f74f8e4fa9.
Private38 в трёх режимах,45 полных AFTER-сравнений15 отрицательных случаев
и24 mutation checks прошли. Whole bootstrap01 quick, fixedpoint13 и повтор штатным G2 прошли;
штатный render/docs-check также прошёл.

Расширенная pure-final01 была неверной пробой: node вложенного bump обозначает
его внешнюю State, а не корень единицы, где был записан bumps. В pure-final02
path State\bump был неоднозначен: отдельно существуют вызов bump() и fn/sub
того же имени. После правильного node scope и State\[1]bump окончательный
pure-final03 прошёл. Реализация после Source01 не менялась.

Попытка runtime01/graph01 использовала прежний stage376: canonical Source01
был обновлён, но stage-copy ещё не выполнялся. Её отказ3 не проверяет новую
реализацию и не является её regression gate. После явного штатного stage-copy
Source01/verify669 запущены runtime02/graph02; stage source содержит новые вызовы.
Поддерживаемого shell runner для build/test не добавлено: работают прежние L2 команды.

Весь M11.5г, общий root frame, computed ordinary declarations,5д/5е/7/8,
M13 и native ordinary M14 остаются OPEN. Весь goal ACTIVE.

## Окончательная кодовая приёмка

Окончательный [Source02](source02.sha256), [manifest](manifest02.log) и
[stage verify](stage-verify02.log) подтверждают673/0. После Source01 добавлены
только две пары фикстур; код lmx_graph_run тот же.
[Runtime02](runtime02.log): driver
f5f909e7ff5d4933e0dcff28bd5193050b5eec8cce8d0fcc1c4549c201abae36,
driver-observe b70ff2700853b0822b561e967f7ffeebc14aefe709203a39cd0af65d28d4fed4.
[Graph02](graph02.log) построен на этих объектах.

Baseline376 повторён на окончательных sources:
[methods3](baseline-final-methods01.log), [duplicate3](baseline-final-duplicate01.log).
Первый отказ исправлен; второй сохраняет правильное различие вхождений.
Чистый обходчик: [исходная probe](pure02.log),
[окончательная положительная](pure-final03.log),
[отказ одинакового имени](pure-duplicates01.log).
Все38 случаев в трёх режимах: [manifest](private01.tsv), [receipt](private01.log).
Все45 полных AFTER-сравнений15 отрицательных случаев:
[manifest](private-after01.tsv), [receipt](private-after01.log).
Все24 [mutation checks](mutation01.log) прошли.

[Whole bootstrap01 quick](bootstrap01.log) из принятого376 построил настоящие
G1/G2, по9 smoke. [Fixedpoint13](fixedpoint01.log) и verify673 прошли;
оба runtime objects совпадают между поколениями, driver02 совпадает со штатным G2.
Штатный G2 [заново построил graph-tool](g2-build01.log) и повторил38 в трёх режимах:
[manifest](g2-01.tsv), [receipt](g2-01.log), все45 [AFTER](g2-after01.log)
и24 [mutation checks](g2-mutation01.log) прошли.
Рабочая связка S/boot-m11-ordinary-nested-01/g2 и graph-m11-ordinary-nested-g2-01.
G2 graph SHA-256 039e29be84a420aa7ace00c0ba6003472bb56146c3fb5a40093aba124d6d2f5a.
Обычные State/C продолжают исполняться обходчиком; успех native внешнего root
не объявляет машинную компиляцию обычных Structure M14 реализованной.
Штатный render semantics прошёл:35 пар разделов,14 implements cases и обе исходные выдержки.
Штатные [render semantics](render01.log) и [docs-check](docs-check01.log) прошли:
35/14/27/44/615, ссылки, точное начало семантики и LF индекса27467.
Квитанция docs-check добавлена после проверки с LF. Оба git diff --check чисты.
Два чужих untracked сохранили SHA-256:
627ceecbc7bca3fb54ff8b6fa866f4ee48b5578d671cdc2cb9372db20993b125 и
b6db206a6f05cc58d086aa3c6575c6b27a0e252785c09f6be5c0e87e51e7d910.
