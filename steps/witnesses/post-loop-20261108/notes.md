# Codex: постусловия и общие ячейки чистого графа

## Реализация

Построитель переводит закрывающий until в обычную Lmx [until, условие, тело]. Служебные объекты парсера и признаки
исходной формы не переходят к потребителям. Анонимное тело исполняется в текущей активации; именованная Structure
остаётся объявлением и исполняется при вызове. Её собственные поля, включая var, доступны обычным образом;
выполняемое поле содержит цикл, тело которого ссылается на те же собственные ячейки.

Until исполняет тело минимум один раз. Continue переходит к постусловию, redo повторяет тело без постусловия,
break выходит из цикла, return выходит из активации. Ошибка в постусловии проходит через общий выход с публикацией
dirty-полей. Native генерирует условия и переходы напрямую; обходчик потребляет тот же Lmx-граф.

Именованное тело выявило дефект генератора: повторная ссылка на примитив раньше создавала другую ячейку.
Генератор теперь использует единую временную карту адресов текущей трансляции для Lmx, примитивов и referent
постоянного uninit-указателя. Адрес регистрируется до обхода полей, повторная ссылка использует прежнюю локальную
переменную генерируемого конструктора. После создания ячеек восстанавливаются parent; карта удаляется после
трансляции. Номера генерируемых локальных переменных не являются кодами имён/операторов и не сохраняются в графе.
Неиспользуемый предварительный рекурсивный обход глубины удалён.

Это исправление генерации начального графа, не полный codec изменённого состояния: неинициализированные байты
не читаются и не объявляются значением по умолчанию; сохранение произвольного текущего содержимого, всех типов
примитивов и ссылок, copy/merge/attach/GC ещё требует общей реализации.

Норма: [ветвления и циклы](../../../docs/LMX_semantics.ru.md#branches),
[грамматика](../../../docs/LMX_grammar.ru.md), [физическая модель](../../../docs/kernel-implementation.ru.md).
Новых решений автора этот срез не вводит.

## Проверки

Финальный graph28/tool17/rt23: 33/33 исполнения, одиннадцать сценариев × interp/native/forced; mutation11/11 и
method-mutation8/8 PASS. Случаи post_loop и post_error добавлены в поддерживаемые L2-входы.

Ожидаемые численные результаты post_loop выведены из программы: result3, before_call0, after_call2,
transitioned3, left1, early_result9, from_body4, condition_calls2, root_value2, own_before0, own_after2,
same_data2, bare_result1. Redo на первой итерации не вызывает condition, continue на второй вызывает её один раз,
третья итерация — второй вызов. Break и return постусловие не исполняют. Именованные Repeat/RepeatOwn/Self инертны
до вызова; call:Self Self сохраняет общий int между внешним полем и телом цикла. Все три GRAPH-AFTER совпадают
с post_loop.expected; логи включены в архив.

Post_error отказывает6/1/1 при делении на ноль в постусловии; count публикуется как1 во всех трёх режимах.
Отрицательный GRAPH-CHECK проверяет статус, GRAPH-AFTER отдельно просмотрен в точных логах.
Регрессии: control_flow, control_missing, code_data, body_fields, dynamic_inputs, own_publication, own_error,
point_fields, saved_address. Saved_address выполняется дважды; control_missing сохраняет3/1/1, own_error6/1/1.

Промежуточный graph25 дал правильный результат обходчика, но native/forced теряли общую ячейку Self; это причина
замены генерации, а не расхождение правил until. Graph26 выявил неверное имя арены lmx_call_arena в генерируемом
конструкторе; исправлено на его аргумент arena. Graph27 прошёл новые случаи; graph28 удалил прежний обход глубины
и прошёл весь указанный набор. Прежние receipts не заменены новыми результатами.

## Tuple и воспроизведение

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe.
TOOL = S/tool17/lmxtool-tool.exe; GRAPH = S/graph28/graph_trans-prod.exe; RT = S/rt23.

- P/pins/codex317-source05.sha256, 314 входов: b76587ec3843004dfa60f4a7aa4d6baa45699a8e47c3d7bcf056f2aa000ef894.
- TOOL: f6337bac7beaf8f0e37a10734a0a7996a50f81bbf9b3252cdccae3d91ef1a119.
- GRAPH: fe68532eb8857d13146d598bb3ee64e9267c185392928a7446733241ee19b4b7.
- RT/driver.o: aa779eab45f26e8efe0ad93b8ab277c13fe3fc32bd2d3471db1d5734ea2db0de.
- RT/driver-observe.o: 55bd9336ffc3d227750ba559a2f49b9070227fc151b23d0eddfa89e1b15a9dac.
- F: b1851f7b56e568088e3e71fdf3b8676de7e01d86481b8c43efe268309778166f.

    TOOL16 0 entry 0 -- build-self R S B F S/rt22/driver.o tool17
    TOOL 0 entry 0 -- build-runtime R S B F rt23
    TOOL 0 entry 0 -- build-graph R S B F RT graph28
    TOOL 0 entry 0 -- graph-check R S B F RT GRAPH OUT SOURCE EXPECTED EXIT COUNT INTERPRETER-ANSWER
    GRAPH 0 entry 0 -- mutation
    GRAPH 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2

OUT — абсолютный S/check28-CASE; SOURCE = S/tests/graph/CASE.lm2 из source05, EXPECTED — CASE.expected.
Обычные EXIT=0 COUNT=1 INTERPRETER-ANSWER=0; saved_address COUNT=2. Для control_missing EXIT=1 и
INTERPRETER-ANSWER=3, для own_error/post_error EXIT=1 и INTERPRETER-ANSWER=6; при EXIT=1 EXPECTED игнорируется.
Архив23 точных записей: [список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий Git](records-lf.sha256).
Все сборки и проверки последовательны, через существующий языковой pipeline.

## Остаток

Docs-check S/docs22 — PASS: 35 парных разделов семантики, 14 случаев implements, 27 разделов грамматики,
44 дословные выдержки, 615 импортированных файлов, ссылки и LF для22536 tracked files; 81 checks, 0 roots.
Точный лог P/pins/codex317-docs22.log. Scoped git diff --cached --check — PASS.

Именованные переходы, finally/throws/catch, остальные типы мест, перепривязка var, общие пути записи,
именованная подача и полные implements/convert ещё не перенесены. Декларации внутри корневого управляющего
тела требуют уже существующего места; полная компоновка остальных корневых форм остаётся впереди.
Codec/copy/merge/attach/GC, корни Message/mail, collector/3pass/FULL, настоящая самосборка с двумя поколениями
и §§8/8a этим срезом не завершены. Единственный writer/build — Codex, цель active; передачи Opus ещё нет.
