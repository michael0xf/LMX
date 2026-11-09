# Codex: очистки областей чистого графа

## Реализация

Finally остаётся обычной Lmx со словом finally и полями тела. Достигнутая регистрация защищает остаток текущей
области; очистки выполняются в обратном порядке. Интерпретатор использует стек текущего обхода, native генерирует
переходы через очистки напрямую. Карты, планы и список регистраций в построенном графе не сохраняются.
Слова управления распознаются по каноническим адресам строк. Номера локальных меток — только имена генерируемого кода.

Поддержаны обычное окончание области, return, ближайшие break/continue/redo и ошибки существующих операций.
Значение return вычисляется и удерживается до очисток. Перед очистками выхода из активации публикуются dirty-поля,
после них общий work_finish публикует изменения очисток. Обычный выход внутреннего блока сам по себе не завершает
активацию. Переход из очистки заменяет ожидающий переход; ошибка сохраняет неуспешный исход. Очистка не запускает
себя повторно, применимые внешние регистрации остаются обязательными.

Построитель включает собственные int-поля внутри finally в общую var. Диагностический dump теперь выводит обычное
анонимное последовательное тело между разделителями ---; это не полный codec состояния.
Scratch генератора объявляется существующим L3 build.lm2; это локальные буферы текущей трансляции, не часть графа.

Норма: [области и finally](../../../docs/LMX_semantics.ru.md#branches),
[грамматика](../../../docs/LMX_grammar.ru.md), [физическая модель](../../../docs/kernel-implementation.ru.md).
Новых правил языка этот срез не вводит.

## Проверки

Graph34/tool19/rt26: 42/42 исполнения — 14 сценариев × interp/native/forced; mutation11/11 и method-mutation8/8 PASS.
Новые поддерживаемые входы: finally_scope.lm2 с expected, finally_error.lm2 и finally_body_error.lm2.

Численные ожидания finally_scope выведены из программы до принятия результата: ordered_result9, trace21;
held_result5 при конечных x6 и seen5; scoped_result21; jump_result1234; replacement_result7 и trace1;
nested_result1 и trace123; cleanup_field_result4 и конечное поле5; cleanup_jump_result123;
корневые root_trace231 и after_registration15. Во всех трёх режимах полный GRAPH-AFTER совпал с expected.
Недостигнутый finally в ложной ветке не зарегистрирован; return/continue из очистки не повторяют её.

Finally_error отказывает6/1/1 и оставляет count13: ошибка внутренней очистки не мешает внешней прибавить10.
Finally_body_error отказывает6/1/1 после вложенного fail(); очистка видит опубликованный count2 и оставляет
count12, seen2, корневая очистка видит12. Для отрицательных случаев runner проверяет статус; содержимое GRAPH-AFTER
дополнительно просмотрено в точных логах всех трёх режимов, включённых в архив.

Регрессии: post_loop, post_error, control_flow, control_missing, code_data, body_fields, dynamic_inputs,
own_publication, own_error, point_fields, saved_address. Последний исполняется дважды; control_missing сохраняет
статусы3/1/1, post_error и own_error —6/1/1.

Промежуточный graph32 проходил интерпретацию, но генератор native падал из-за несовпадения fprintf-формата
и аргументов. Graph33 исправил это и выявил отсутствующий разделитель закрытия вложенного L1-блока.
Graph34 исправляет оба дефекта. Первое имя функции body в отрицательном примере перекрывалось её собственным
полем body; пример переименован в failing_body для проверки ошибки вызова, без изменения правил поиска имён.
Source09 отличается от source08 только этим тестом; runtime/tool построены до последних исправлений генератора,
их собственные поддерживаемые исходники после соответствующих сборок не менялись.

## Tuple и воспроизведение

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe.
TOOL = S/tool19/lmxtool-tool.exe; GRAPH = S/graph34/graph_trans-prod.exe; RT = S/rt26.

- P/pins/codex318-source09.sha256, 318 входов: 733d01c20d015f4730777c18c78e87209df782de131ae03d11749efadbdc32ec.
- TOOL: ba265507c9317b3dda1be7afbe840419dfe3c48e133233d8816ab2b01b215c06.
- GRAPH: 516a15993fe7b5a269b38245faa67536de897ee80e8a1db78cc5ea8e24825731.
- RT/driver.o: 5a162eec38b89db84b452a0038b585f4ebe26cf7a95bd26b474c4e19ec3d6489.
- RT/driver-observe.o: e1b65aabe8f79dba3f76ae30908c9556c73f8d2bb48630e8a7b49fa70df0a298.
- F: b1851f7b56e568088e3e71fdf3b8676de7e01d86481b8c43efe268309778166f.

    TOOL18 0 entry 0 -- build-self R S B F S/rt24/driver.o tool19
    TOOL 0 entry 0 -- build-runtime R S B F rt26
    TOOL 0 entry 0 -- build-graph R S B F RT graph34
    TOOL 0 entry 0 -- graph-check R S B F RT GRAPH OUT SOURCE EXPECTED EXIT COUNT INTERPRETER-ANSWER
    GRAPH 0 entry 0 -- mutation
    GRAPH 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2

OUT — S/check34-CASE, кроме S/check34b-finally_body_error. SOURCE — S/tests/graph/CASE.lm2,
EXPECTED — CASE.expected. Обычные EXIT0 COUNT1 INTERPRETER-ANSWER0; saved_address COUNT2.
Отрицательные EXIT1, EXPECTED не читается; control_missing INTERPRETER-ANSWER3, остальные отрицательные6.
Генерация новых ABI-объявлений выполняется новым tool при build-runtime перед build-graph.
Все сборки и проверки последовательны через существующий языковой pipeline.

Архив29 точных записей: [список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий Git](records-lf.sha256).

## Остаток

Docs-check S/docs23 — PASS: 35 парных разделов семантики, 14 случаев implements, 27 разделов грамматики,
44 дословные выдержки, 615 импортированных файлов, ссылки и LF для22573 tracked files; 81 checks, 0 roots.
Точный лог P/pins/codex318-docs23.log. Scoped git diff --cached --check — PASS.

Именованные цели, throws/catch, stop/yield и прочие выходы полного контракта finally ещё не перенесены.
Остальные примитивы/места, общие пути записи и допуска, перепривязка var, codec/copy/merge/attach/GC, корни
Message/mail, collector/3pass/FULL и настоящая самосборка с двумя поколениями и §§8/8a остаются открыты.
Единственный writer/build — Codex, цель active; передачи Opus ещё нет. При фактической передаче цель ставится
на паузу, тот же lmx-goal переключается на контроль Opus.
