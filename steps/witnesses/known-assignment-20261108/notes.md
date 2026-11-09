# Известное int-место и := в чистом графе — 2026-11-08

Исполнитель: codex. Продолжение опубликованного 9d495f25; единственный writer/build/docs остаётся Codex.
Передачи Opus нет. Последний прочитанный usage79%/остаток21%; передача требуется при остатке строго менее20%.
При фактическом принятии Opus Codex ставит coding-цель на паузу и переключает ту же часовую автоматизацию.

## Изменение

Построитель раньше терял флаг := из дерева парсера, оставляя ту же форму, что для двоеточия.
Теперь результат — обычная Lmx [слово :=, место, правая часть]; слово каноническое, без отдельного кода.
Путь левой части построитель выражает вложенными Lmx [левое, слово \, имя поля], как остальные пути.
Дерево парсера и его флаг не передаются потребителям. int:7 строится обычным примитивом со значением7;
общие вычисляемые ресиверы примитивных типов этим не завершены.

В текущем int-пути оба потребителя проверяют известное место до вычисления RHS.
Голая запись использует существующие рабочие own-значения или значения формалов/динамических входов.
Явный путь пишет физический граф через общий kernel write, сохраняя адрес ячейки и правило сброса native;
он не публикует и не обновляет рабочий снимок активации. Native генерирует вычисление RHS непосредственно,
без передачи его интерпретатору. Неизвестная цель не объявляет поле; имя самого метода не становится int-местом.
Обе формы a:=5 и a := 5 одинаковы. Старые формы с двоеточием сохраняются.

Норма: [известное место](../../../docs/LMX_semantics.ru.md#assign-known) и раздел рабочего состояния
[книги](../../../docs/LMX_semantics.ru.md#dynamic), в особенности различие голого имени и явного пути.
Новой семантики приоритетов/ассоциативности, значения присваивания или снятия уровней @ здесь нет.

## Реальные проверки

Финальный graph40/tool22/rt30: 30/30 исполнений, десять сценариев в interp/native/forced, плюс mutation11/11
и method-mutation8/8. Known_assignment даёт root20; сохранённый @i видит5 и7; local_result15,
calls1; procedure_count5; Data.x11/Data.y22 при model_x1; changed17; nested_value11.
Clean_snapshot19 и clean_published9 доказывают, что путь var\x меняет граф, сохраняя рабочий x1.
Dirty_snapshot209 и dirty_published2 доказывают, что последующая публикация собственного dirty x2 обычная.
Формал arg изменён только в активации; его обязательная форма сигнатуры сохранена.
Полный GRAPH-AFTER сопоставлен с known_assignment.expected во всех трёх режимах.

Отрицательные случаи: unknown и path_missing — ответ3/1/1, method —4/1/1,
selected —3/1/1 (interp/native/forced). GRAPH-AFTER просмотрен во всех12 логах:
calls0, неизвестных полей нет; у selected исходная Data.x10 не изменена до отказа отсутствующего y.
Регрессии: sub_calls, finally_scope, code_data, dynamic_inputs и saved_address; последний выполняется дважды.
19 изменений графа сохраняют проверки адресов, выборочного сброса native и свежих обходов.

Graph37/38 остановились на ошибках поддерживаемого L2: зарезервированное имя length у временной переменной,
затем const-квалификация указателя на текст парсера. Исправлено в исходнике; точные два отказа сохранены.
Предварительный graph39/rt29 прошёл те же30 исполнений. Затем представление типизированного литерала
уточнено: обычный примитив вместо исполняемого int-ресивера. После изменения заново собраны rt30/graph40
и проведены все указанные проверки. Source06 — финальные328 входов, после него код не изменялся.

## Tuple и воспроизведение

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe.
TOOL = S/tool22/lmxtool-tool.exe; GRAPH = S/graph40/graph_trans-prod.exe; RT = S/rt30.

- P/pins/codex320-source06.sha256, 328 входов: 7f43b023068dfef4c9ddcdcac40c2709090d147933a6b4347ac30fe504b046d6.
- TOOL: 0f2130c10ab3aac79ccaaba40ba85f3effdfbe2170b954a74ee2d3efab4942d4.
- GRAPH: c1b53d2b40044e4a0bd922eb3f73b33804600dc844f5ae23ce8564d6a7f1c7d6.
- RT/driver.o: 4e9eda249c2957118801d4667b3dce08786a00f740e9a2d962997b06ad538c44.
- RT/driver-observe.o: 8ef01daaa12646f8458bce5f3a24ea09a0e0cea4c3c00db4131d6a408c4ce76a.
- F: b1851f7b56e568088e3e71fdf3b8676de7e01d86481b8c43efe268309778166f.

    TOOL21 0 entry 0 -- build-self R S B F S/rt28/driver.o tool22
    TOOL 0 entry 0 -- build-runtime R S B F rt30
    TOOL 0 entry 0 -- build-graph R S B F RT graph40
    TOOL 0 entry 0 -- graph-check R S B F RT GRAPH OUT SOURCE EXPECTED EXIT COUNT INTERPRETER-ANSWER
    GRAPH 0 entry 0 -- mutation
    GRAPH 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2

OUT — S/check40-CASE, SOURCE — S/tests/graph/CASE.lm2, EXPECTED — CASE.expected.
Положительные EXIT0 COUNT1 INTERPRETER-ANSWER0; saved_address COUNT2.
Отрицательные EXIT1; expected не читается, INTERPRETER-ANSWER — указанный выше ответ.
Архив33 именованных файлов: [список](records.list), [SHA оригиналов](records.sha256),
[SHA LF-копий Git](records-lf.sha256). Pipeline выполнялся последовательно штатными L2/L3-командами.

## Граница и остаток

Этот срез не завершает общий :=: остальные примитивы, ссылки/ссылки на методы, именованная подача,
общие implements/convert и вычисляемые ресиверы остаются. Неявное разыменование или новый приоритет не добавлены.
Fm, исключения и именованные цели, полные copy/merge/attach/GC/codec, самосборка двух поколений,
collector/3pass/FULL и Message/mail §§8/8a открыты.

Docs-check S/docs25 — PASS: 35 парных разделов семантики, 14 случаев implements, 27 разделов грамматики,
44 дословные выдержки, 615 импортированных файлов, ссылки и LF для22652 tracked files; 81 checks, 0 roots.
Точный лог P/pins/codex320-docs25.log. Scoped git diff --cached --check — PASS.
