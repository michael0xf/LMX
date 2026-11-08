# Codex: общий вызов code/data для int-мест чистого графа

## Реализация

Обычная Structure и fn получают один временный рабочий кадр для выбранных code/data. Требуемые места связываются
по каноническим именам и проверенным адресам ячеек; совпадение порядка полей не требуется. Переданный data не
растёт. Dirty-публикация пишет готовые рабочие значения в физические слоты той же карты, без повторного исполнения
выражений. Служебная карта освобождается на выходе, следующий вызов строит свою по текущему графу.

Полная форма call выбирает два обычных структурных значения при исполнении. Сокращение выбирает var фактического
code; отсутствие var оставляет отсутствие данных, без скрытого data=code. Явное call:code code проходит тем же
путём. Метод может использовать отдельные данные и свои обычные умолчания аргументов; его var от этого не меняется.
Ссылка var в текущей активации обозначает выбранные данные. Свободный int-вход сохраняет локальное значение и не
пишет обратно лексическому источнику.

Транслятор тем же обходом собирает обычные именованные исполняемые Structure и методы, не считая args/return/var/body
метода самостоятельными вызываемыми. Чистые структуры только с данными не получают дополнительного native.
Native содержит арифметику и записи своего тела; общие функции дают допуск мест, кадр и публикацию, не исполняют за
него тело обходчиком. Слова call/var интернируются один раз при создании состояния и дальше сравниваются адресами.

Источники нормы: [L2 §11](../../../docs/L2_spec_ru.md#call), [части метода](../../../docs/LMX_semantics.ru.md#method-parts),
[спецификация реализации](../../../docs/kernel-implementation.ru.md). Нового решения автора этот срез не вводит.

## Проверки

Финальный graph21/tool15/rt20: **36/36 исполнений** (12 сценариев × interp/native/forced), mutation11/11 и
method-mutation8/8 PASS. Кроме трёх новых code_data-случаев, сохранены body_fields, dynamic_inputs, dynamic_missing,
own_effects, own_publication, own_initializer, own_error, point_fields и saved_address (два обхода).

Основной code_data проверяет переставленный Data (extra,y,x): Code меняет x10→11 и y30→22, не трогая свою var;
сокращённый call затем меняет собственную var x1→2,y2→4; call:Self Self пишет4→6. Метод с умолчанием step3 пишет
отдельный Data.x11→14 при сохранении method.var.x1. Вложенный вызов даёт15, свободная локальная запись оставляет
внешнее x40, чтение var\\x в отдельном code/data даёт следующую запись Data.x16.

code_data_missing отказал3/1/1 до tick, сохранив tick.calls0 и единственное поле Empty.other8.
code_data_no_var отказал3/1/1 без неявной подстановки code, внешний x остался5. Отрицательные GRAPH-CHECK проверяют
статус; эти состояния отдельно проверены по GRAPH-AFTER всех трёх interp.log/native/run.log/forced/run.log и сохранены
в архиве. Это не автоматическое сравнение состояния отрицательного случая.

## Tuple и воспроизведение

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe.
TOOL = S/tool15/lmxtool-tool.exe; GRAPH = S/graph21/graph_trans-prod.exe; RT = S/rt20.

- P/pins/codex315-source06.sha256, 308 входов: a93d6cbe4f1780805c46ac42063084a3273fa2076902695eff747e136720066e.
- TOOL: cdc8bcfc34ed38c8405184d9f28335f9366ea4e96ec0f7ec15cebcfe18eb873b.
- GRAPH: 249a7842d1205494a242ba3ed2d62ebf2c9310b193b04c0dea13edb4e756690d.
- RT/driver.o: 00eab875329464c3a66087daa46ac43f0fdf8afe21ee7b5d88d7f297f165f0be.
- RT/driver-observe.o: 7c3b4a9a4530260d239384da956553206f9d360a98a6e9bfec5f5a66ebb3f625.
- F: b1851f7b56e568088e3e71fdf3b8676de7e01d86481b8c43efe268309778166f.

    TOOL14 0 entry 0 -- build-self R S B F S/rt19/driver.o tool15
    TOOL 0 entry 0 -- build-runtime R S B F rt20
    TOOL 0 entry 0 -- build-graph R S B F RT graph21
    TOOL 0 entry 0 -- graph-check R S B F RT GRAPH OUT SOURCE EXPECTED EXIT COUNT INTERPRETER-ANSWER
    GRAPH 0 entry 0 -- mutation
    GRAPH 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2

OUT — абсолютный новый S/check21-CASE; SOURCE = R/selfbuild/tests/graph/CASE.lm2, EXPECTED — CASE.expected.
Обычные EXIT=0 COUNT=1 INTERPRETER-ANSWER=0; saved_address COUNT=2. Для code_data_missing/code_data_no_var/
dynamic_missing EXIT=1 INTERPRETER-ANSWER=3; для own_error EXIT=1 INTERPRETER-ANSWER=6. При EXIT=1 EXPECTED игнорируется.
Архив содержит24 копии: [список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий Git](records-lf.sha256).
Оригиналы в P сохранены. Сборки, проверки и docs выполняются последовательно через поддерживаемый языковой driver.

Промежуточные rt16/graph19 выявили пропуск публикации у не-fn и ошибочный сбор частей метода как отдельных native.
Обе причины исправлены. Rt17 отказал на обращении к полю приведённого указателя; явный типизированный указатель
устранил отказ. Rt18/rt19 и graph20 проверили рабочий путь; в финальном tuple операторы call/var сравниваются с
каноническими адресами состояния, без повторного интернирования в горячем обходе. Исторические receipts не заменяют
результаты указанного финального tuple.

Docs-check S/docs19 — PASS: 35 парных разделов семантики, 14 случаев implements, 27 разделов грамматики,
44 дословные выдержки, 615 импортированных файлов, ссылки и LF для22478 tracked files; 81 checks, 0 roots.
Точный лог P/pins/codex315-docs19.log. Scoped git diff --cached --check — PASS.

## Граница

Это перенос общего пути для уже поддержанных int-мест, а не завершение N4. Остальные примитивы и ссылочные места,
перепривязка резервной var, все формы записи через путь, управление потоком, индексы одноимённых полей,
именованные аргументы, полные implements/convert/throws/catch, codec/copy/merge/attach/GC и корни Message/mail ещё
не перенесены полностью. Проверки этого среза не доказывают collector/3pass/FULL, чистую самосборку, два поколения
или §§8/8a. Единственный writer/build — Codex, цель active.
