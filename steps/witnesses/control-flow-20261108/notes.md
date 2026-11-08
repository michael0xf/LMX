# Codex: условия и циклы в чистом графе

## Реализация

If/else, while и for потребляют обычные вложенные Lmx-тела в текущей активации. Условие if вычисляется один раз,
else относится только к непосредственно предыдущему if. While допускает ноль итераций. For исполняет
инициализацию один раз, затем условие/тело/шаг. Continue идёт к условию while или шагу for, redo повторяет тело
без условия/шага, break выходит из ближайшего цикла. Return проходит через общий выход активации и публикацию.
Именованные переходы этим срезом не реализованы.

Обходчик несёт временный адрес канонического слова перехода только по стеку текущего обхода. Native генерирует
условия и переходы на L1, затем обычный машинный код; тело не передаётся интерпретатору. В графе нет ни opcode,
ни сохранённой программы переходов. Имена операторов и ресиверов сравниваются по каноническим адресам строк.
Построитель задаёт вложенность сравнений, !, && и || вместе с прежними арифметическими выражениями. Оба потребителя
вычисляют логические операции коротко; приоритеты не разбираются заново при исполнении.

Построитель собирает int-объявления внутри inline-тел в ту же var, исключая вложенные вызываемые и их данные.
Все эти поля видны с начала тела; инициализатор остаётся на своём месте и исполняется только при посещении.
Обходчик допуска проходит условные тела до эффектов, поэтому отсутствующее обязательное поле выбранных данных
отказывает до вычисления условия. Служебные списки построителя и активации не сохраняются в графе.

Норма: [ветвления и циклы](../../../docs/LMX_semantics.ru.md#branches),
[рабочие значения](../../../docs/LMX_semantics.ru.md#dynamic), [ядро](../../../docs/kernel-implementation.ru.md).
Новых решений автора этот срез не вводит.

## Проверки

Финальный graph24/tool16/rt22: 27/27 исполнений, девять сценариев × interp/native/forced; mutation11/11 и
method-mutation8/8 PASS. Control_flow проверяет обе ветви (10/20), while с нулём итераций, continue в while
и for, шаг for, redo без шага/условия, ближайший break при вложенных циклах, return из вложенного if/while,
собственное поле inline-тела до его объявления, отдельные code/data и корневой цикл с вызовом метода.

Ожидаемые результаты вычислены из исходной программы: loop_result43, short_result16, call_count2,
jump_result35, visible_inline9, nested_result22, data_result30, root_loop12, final_calls4.
Два последних вызова mark происходят в корневом цикле; первые два — только в посещённых операндах &&.
Непосещённые операнды 0&&mark() и 1||mark() не вызывают метод.

Control_missing отказывает3/1/1 до tick: calls остаётся0, Empty содержит прежний other7. Отрицательный
GRAPH-CHECK проверяет статус; GRAPH-AFTER отдельно просмотрен во всех трёх точных логах, включённых в архив.
Регрессии: code_data, body_fields, dynamic_inputs, own_publication, own_error, point_fields, saved_address.
Saved_address выполняется дважды; own_error сохраняет отказ6/1/1 и предыдущую публикацию.

## Tuple и воспроизведение

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe.
TOOL = S/tool16/lmxtool-tool.exe; GRAPH = S/graph24/graph_trans-prod.exe; RT = S/rt22.

- P/pins/codex316-source05.sha256, 311 входов: 05a9fa0fa72c9c4a2e8b77d26ea4f036c9b5f697aa0827b9cbf314d352174dd8.
- TOOL: 8bdb0395a6206770f0de97ef34ee2c61f749c22948bfce5db60c2760f74a200f.
- GRAPH: daaf5459621cbb9f5d4ad6cfc8f781adb495e05a595b61dd59cc1811276d71ba.
- RT/driver.o: ad4467b49ad39e412cfba986af1d919a58ab77f7421bebdc9793f5a12abbe4a5.
- RT/driver-observe.o: 2719fee27a9c85f402b39ce4ef39f8aeab6e84e69d07dbe22a9e301414cd01ad.
- F: b1851f7b56e568088e3e71fdf3b8676de7e01d86481b8c43efe268309778166f.

    TOOL15 0 entry 0 -- build-self R S B F S/rt20/driver.o tool16
    TOOL 0 entry 0 -- build-runtime R S B F rt22
    TOOL 0 entry 0 -- build-graph R S B F RT graph24
    TOOL 0 entry 0 -- graph-check R S B F RT GRAPH OUT SOURCE EXPECTED EXIT COUNT INTERPRETER-ANSWER
    GRAPH 0 entry 0 -- mutation
    GRAPH 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2

OUT — абсолютный S/check24-CASE; SOURCE = R/selfbuild/tests/graph/CASE.lm2, EXPECTED — CASE.expected.
Обычные EXIT=0 COUNT=1 INTERPRETER-ANSWER=0; saved_address COUNT=2. Для control_missing EXIT=1 и
INTERPRETER-ANSWER=3, для own_error EXIT=1 и INTERPRETER-ANSWER=6; при EXIT=1 EXPECTED игнорируется.
Архив точных записей: [список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий Git](records-lf.sha256).
Все сборки и проверки последовательны, через существующий языковой pipeline.

Промежуточный rt21 остановился на пропущенном закрытии вложенного if перед else в L2-исходнике;
graph22 — на локальном имени node, зарезервированном текущим frontend. Обе причины исправлены.
Rt22 и graph23 прошли; graph24 добавил недостающую генерацию обычного вызова метода внутри корневого
управляющего тела и проверку отсутствующего места для его объявления без значения.

## Остаток

Docs-check S/docs21 — PASS: 35 парных разделов семантики, 14 случаев implements, 27 разделов грамматики,
44 дословные выдержки, 615 импортированных файлов, ссылки и LF для22506 tracked files; 81 checks, 0 roots.
Точный лог P/pins/codex316-docs21.log. Private_OUT должен существовать до запуска docs check;
первый запуск с отсутствующим docs20 завершился на открытии вывода проверки EOL, не на дефекте документов.
Scoped git diff --cached --check — PASS.

Until, именованные переходы, finally/throws/catch, остальные типы мест, перепривязка var, общие пути записи,
именованная подача и полные implements/convert ещё не перенесены. Декларации внутри корневого управляющего
тела требуют уже существующего места; полная компоновка остальных корневых форм остаётся впереди.
Codec/copy/merge/attach/GC, корни Message/mail, collector/3pass/FULL, настоящая самосборка с двумя поколениями
и §§8/8a этим срезом не завершены. Единственный writer/build — Codex, цель active.
