# Codex: процедуры sub в чистом графе

## Реализация

Построитель создаёт sub как обычную Lmx из слова sub и частей args, var, body, ровно по
[спецификации реализации](../../../docs/kernel-implementation.ru.md). Части return нет; у fn она сохранена.
Распознавание использует адрес слова головы и виды адресов частей. Общие функции доступа к var/body учитывают
разную длину двух форм; обходчик, генератор, печать и свежая проверка принадлежности коду используют эту форму.
Новых кодов роли, сохранённой таблицы методов или сигнатурной обёртки нет.

Sub использует существующий допуск аргументов, умолчания, рабочие поля активации, динамические входы и публикацию.
Нормальное окончание тела и return без значения завершают процедуру. Finally применяется тем же путём.
Вызов как отдельный оператор теперь работает также в корне; голое имя не вызывает.
Native процедуры вычисляет тело напрямую и использует общий runtime для приёма и рабочих мест.
Использование sub как числового выражения отвергается по отсутствию результата до вычисления аргументов.

Норма: [callables](../../../docs/LMX_semantics.ru.md#callables),
[части метода](../../../docs/LMX_semantics.ru.md#method-parts), [выходы](../../../docs/LMX_semantics.ru.md#exits).
Новых семантических решений этот срез не вводит.

## Проверки

Graph36/tool21/rt28: 42/42 исполнения — 14 сценариев × interp/native/forced; mutation11/11, method-mutation8/8.
Sub_calls проверяет собственное состояние, умолчание и две формы вызова, прямой call:sub, явные code/data,
ранний return, автозаполненную var, вложенную процедуру до её объявления, динамический вход и return из очистки.
Ожидания выведены из программы: first12, second25, third37, Other.sum112, own_sum37, early_value15,
normal_value8, nested_value44, outer_trace3. Полный GRAPH-AFTER совпал с sub_calls.expected во всех трёх режимах.
Голое add после add() не изменяет first. Запись вложенного capture в динамический total не меняет total вызывающего.

Sub_error отказывает6/1/1; count12 и seen12 подтверждены просмотром GRAPH-AFTER во всех трёх логах.
Регрессии: finally_scope, post_loop, post_error, control_flow, control_missing, code_data, body_fields,
dynamic_inputs, own_publication, own_error, point_fields, saved_address. Saved_address выполняется дважды;
control_missing сохраняет3/1/1, post_error/own_error —6/1/1.

Sub_void_value проверяет отдельную границу результата: int:wrong sink(effect()), где sink — sub.
Интерпретатор возвращает5, оба счётчика calls остаются0. Native отвергает при трансляции с ответом5;
это проверка отказа генератора, не запуск native и не третья успешная программа.
Две проверки отказа учитываются отдельно от42 исполнений.

Первый graph35 отказал при C-компиляции: три новые функции не вошли в список экспортов machine-модуля.
Список исправлен в поддерживаемом L3 build.lm2; новый tool21 пересобрал runtime28, затем graph36.
Source03 отличается от source02 только добавлением проверенного expected; код после сборки tuple не менялся.

## Tuple и воспроизведение

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe.
TOOL = S/tool21/lmxtool-tool.exe; GRAPH = S/graph36/graph_trans-prod.exe; RT = S/rt28.

- P/pins/codex319-source03.sha256, 322 входа: d13e5af52a5d1a59b70c2cfb6175a33a404de625284beec4d27b2af46aa7b6ae.
- TOOL: f5daaf4038aad804c4f904323a46dff471079e436945f758c1a1175f0289c031.
- GRAPH: 550b4309cb7b055d77b7afe621d70cf70e8d809b2cbc3814ca2837d3e540da86.
- RT/driver.o: 5a0278152686daac7eec562eed54c5393637f1c0cffaaacf5ef09ccda94c2db6.
- RT/driver-observe.o: ec6a8bb2bdd2e9770ae69140998073346d1649a84b78d5992202b83b5731f6d9.
- F: b1851f7b56e568088e3e71fdf3b8676de7e01d86481b8c43efe268309778166f.

    TOOL20 0 entry 0 -- build-self R S B F S/rt27/driver.o tool21
    TOOL 0 entry 0 -- build-runtime R S B F rt28
    TOOL 0 entry 0 -- build-graph R S B F RT graph36
    TOOL 0 entry 0 -- graph-check R S B F RT GRAPH OUT SOURCE EXPECTED EXIT COUNT INTERPRETER-ANSWER
    GRAPH 0 entry 5 -- run S/tests/graph/sub_void_value.lm2 1
    GRAPH 0 entry 5 -- emit-check S/tests/graph/sub_void_value.lm2 S/graph36/sub-void-refused.lm1 native 1
    GRAPH 0 entry 0 -- mutation
    GRAPH 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2

OUT — S/check36-CASE; SOURCE — S/tests/graph/CASE.lm2, EXPECTED — CASE.expected.
Обычные EXIT0 COUNT1 INTERPRETER-ANSWER0; saved_address COUNT2. Отрицательные EXIT1, expected не читается;
control_missing INTERPRETER-ANSWER3, sub_error/post_error/own_error —6.
Архив28 записей: [список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий Git](records-lf.sha256).
Сборки и проверки последовательны через существующий языковой pipeline.

## Остаток

Docs-check S/docs24 — PASS: 35 парных разделов семантики, 14 случаев implements, 27 разделов грамматики,
44 дословные выдержки, 615 импортированных файлов, ссылки и LF для22609 tracked files; 81 checks, 0 roots.
Точный лог P/pins/codex319-docs24.log. Scoped git diff --cached --check — PASS.

Fm, остальные типы аргументов/результатов/мест, полный implements/convert, именованная подача, общие операции
codec/copy/merge/attach/GC, исключения и именованные цели ещё не перенесены. Общая самосборка двух поколений,
collector/3pass/FULL, Message/mail и §§8/8a остаются открыты. Codex продолжает единственный pipeline; передачи Opus нет.
