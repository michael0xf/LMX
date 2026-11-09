# Одна карта для слитых мест, место результата, дескриптор интерфейса — 2026-11-09

Исполнитель: opus. Основание: ревью Codex результата 325 (CODEX-OPUS-325-REVIEW-20261109T031106Z-01, копия
[records/pins/codex-325-result-review.txt](records/pins/codex-325-result-review.txt)): дефект карты копии — поле позднего
операнда с совпавшим именем писалось значением в место результата, но его адрес не связывался в карте с этим местом, и
ссылка на него получала новую ячейку; продолжить независимые части — исправление карты, дескриптор без body (книга
:691), хранение результата в обычном месте, копию графа по норме. Уточнение Codex о дескрипторе
([records/pins/codex-326-descriptor-var.txt](records/pins/codex-326-descriptor-var.txt)): у дескриптора отсутствует
body, не var — нужна обычная адресуемая пустая var. Ответ о защищённом файле
([records/pins/codex-326-guard-cwd-reply.txt](records/pins/codex-326-guard-cwd-reply.txt)) — в разделе «Запуски».

## Изменение

- `lmx_graph_run.lm2`, `lmx_graph_merge_values`: порядок делает слитые места одним местом. Сначала набор полей с тем
  полем, которое первым даёт каждый слот; затем копии int-мест результата; затем каждое поле позднего операнда,
  называющее int-место результата, которое оно не даёт, — это место в одной карте (`lmx_graph_merge_alias`: значение →
  место, ячейка, в том числе под `uninit:int`, → ячейка места; уже отображённый источник сохраняет первую копию); только
  потом копии ссылок, Structure и новых полей, затем записи полей позднего операнда в порядке операндов. Карта
  освобождается, только если была открыта.
- `lmx_graph_merge_literal_put`: поле `name: @x` анонимной Structure — новое ссылочное место на ту же ячейку.
- `lmx_graph_exec_statement` и `lm_graph_emit_statements_from`: оператор корня `имя: значение` (два поля), чьё имя не
  разрешается и не слово языка (`lmx_graph_language_word`, общий для обоих), определяет место значением —
  `lmx_graph_define` (`lmx_graph.lm2`): своё место значения (новая int-ячейка; новая int-ссылка на ту же ячейку; свежая
  Structure — результат merge — сама), имя — слово головы, запись в слот оператора; Structure с именем или вызываемое
  сделали бы место ссылкой на экземпляр — открыто (5). Native записывает определение в таблицу объявлений.
- `lm_graph_build_method`: `fn: name args return` без тела — дескриптор интерфейса `[fn, args, return, var]` с
  адресуемой пустой `var` и без body (книга :691); `lmx_graph_descriptor`; дамп печатает заголовок без тела; дескриптор не
  вызываемое (`lmx_graph_method`).
- `tools/build.lm2`: экспорты `lmx_graph` 40 (`lmx_graph_descriptor`, `lmx_graph_define`), `lmx_graph_run` 28
  (`lmx_graph_language_word`). Новый tool26.
- Фикстуры `merge_reference`, `merge_held`, `descriptor` (+ три `.expected`), `descriptor_merge`, `descriptor_body`;
  `inputs.list` — 355 входов.

## Проверки

Значения рассчитаны по норме до запуска; логи `P/pins/opus326-*`.

1. Manifest `opus326-source01` (352), stage-copy, verify 352/0. `T25 build-self … S/rt34/driver.o tool26` — exit 0
   (03:23:28→03:24:14Z); `T26 build-runtime … rt35` — exit 0 (03:24:25→03:25:24Z); `T26 build-graph … S/rt35 graph45`
   — exit 0 (03:25:24→03:25:33Z).
2. `G45 run` (интерпретатор): `merge_reference` — R = merge(M; N; (p(@N\a))) и S = merge(M; (p(@N\a)); N) (ссылка после
   и до совпавшего поля): после `R\a := 9`, `S\a := 7` — r_seen 9, s_seen 7 (ссылка ведёт к месту результата), m_a 1,
   n_a 5 (источники целы), r_a 9. `merge_held` — `pack: merge(mytest\args; (a: int: 5))`, r 35 (`mytest(pack)`), x 4
   (определение int-места), y 5. `descriptor` — `fn: f2 (int: b 7) int` печатается заголовком без тела, r 52 (`f1(5)`),
   v 3 (`merge(f2\var; (q: 3))\q` — пустая var адресуема), b 7 (`f2\args\b`). `descriptor_merge` (`R: merge(f1; f2)`) —
   5: копия вызываемых открыта. `descriptor_body` (`f2\body`) — 3: тела нет. Три `.expected` — GRAPH-AFTER байт в байт;
   manifest `opus326-source02` (355), verify 355/0.
3. `lmxtool checks` `opus326-graph-check45.tsv` (58 строк: 53 прежних с метками rt35/graph45/check45 и пять новых) —
   `CHECKS 58 lines, 0 failed`, 174 PASS. Native: в `merge_reference` два `lmx_graph_define` и два
   `lmx_graph_merge_values`, в `merge_held` два определения; отрицательные — остановка R0 (выход 1).
4. `sub_void_value` 5/5 (частичный L1 — байты graph44); `G45 mutation` 11/11, `G45 method-mutation` 8/8.
5. Мутант: в стейдже (не в репозитории) вызов `lmx_graph_merge_alias` заменён на `status: 0`, собраны rt35m/graph45m
   (03:28:44→03:29:50Z), `merge_reference` даёт r_seen 5, s_seen 5 — ссылка ведёт к новой копии `N\a`; свидетель отличает
   исправление. Стейдж восстановлен stage-copy `opus326-source02` (355/0), исходник сверен с репозиторием (cmp).

## Кортеж

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe; CWD = P/runs/opus326.

- P/pins/opus326-source02.sha256, 355 входов: 0c1f0212e2f2f87d6a9ca19e6d792018331bd32138b0a9b1b1c6c540f0e24947.
- T26 = S/tool26/lmxtool-tool.exe: 3d67a92563311594b062370d7d3390f86906aeed3f90c271ef9126b534a9e8b9 (собран T25 на rt34).
- S/rt35/driver.o: dc6d1c18b9d885824d7a56d9c769b013ad15f4552e79a28cd37b5de81535b0f3.
- S/rt35/driver-observe.o: 47f41259ec510a0cf575a877575c01862bb33125773bcf8443de1c675fb79c44.
- G45 = S/graph45/graph_trans-prod.exe: 4ef4065d489707f9188e3b10b9d396a5de228658f884d8d26b7b885cb2cb22ab.
- Мутант: S/rt35m/driver.o 3afadfc1…, S/graph45m/graph_trans-prod.exe 0ceb2bba… (только для п. 5).

```text
T25 0 entry 0 -- build-self R S B F S/rt34/driver.o tool26
T26 0 entry 0 -- build-runtime R S B F rt35
T26 0 entry 0 -- build-graph R S B F S/rt35 graph45
G45 0 entry 0 -- run S/tests/graph/CASE.lm2 1          (merge_reference, merge_held, descriptor, descriptor_merge, descriptor_body)
T26 0 entry 0 -- checks P/pins/opus326-graph-check45.tsv
G45 0 entry 5 -- run S/tests/graph/sub_void_value.lm2 1
G45 0 entry 5 -- emit-check S/tests/graph/sub_void_value.lm2 S/graph45/sub-void-refused.lm1 native 1
G45 0 entry 0 -- mutation
G45 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2
```

Строка проверки — как у [именованной подачи](../named-arguments-20261109/notes.md), OUT — `S/check45-CASE`. Архив:
[список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий](records-lf.sha256); второй проход —
[список](records2.list), [SHA](records2.sha256), [SHA LF](records2-lf.sha256). 118 копий первого прохода (39 с CR
записаны из индекса в LF) и 7 второго (4 с CR); архивные manifest/stage-copy — из P/runs/opus326. Docs check S/docs36 над
индексом среза — PASS (35 глав, 14 случаев implements, 27 разделов грамматики, 44 выдержки, 615 импортов, ссылки, LF для
23235 файлов); `git diff --cached --check` — PASS; повторный над итоговым индексом — S/docs37 (лог в P).

## Запуски

Драйвер каждой L2-программы открывает в своём CWD файл защищённого имени на запись с усечением
(selfbuild/src/l2src/l2_driver.lm2:3333). В срезах 322–325 команды tool/graph запускались с CWD = корень репозитория и
переписывали корневой экземпляр; прежнее содержимое неизвестно, экземпляры не читались, не перечислялись, не
хешировались, не копировались и не удалялись (сообщено Codex, OPUS-CODEX-326-GUARD-CWD-20261109T0335Z-01; ответ — по
ссылке выше). В этом срезе все команды tool/graph шли из P/runs/opus326: staging, build-self, build-runtime и build-graph
— командами, начинавшимися с `cd …/runs/opus326 &&` (рабочий каталог подтверждён средой), остальные — с
`cd … || exit 1` и строкой `CWD=` в логе или terminal; docs — из новых каталогов S/docsNN.

## Отступления

1. Пять строк экспорта в `tools/build.lm2` изменены одной командой `sed` по номерам строк, не инструментом Edit;
   результат сверен построчно (`sed -n`).
2. В terminal tool26/rt35/graph45 нет строки CWD (записывать её стали после замечания Codex), а их команды не были
   fail-closed; каталог виден по истории команд.
3. Список `opus326-graph-check45.tsv` получен из списка 325 заменой меток (`sed`) и пятью строками `printf`.

## Граница

Копия написанных имён (слов) и вызываемых — с их нужными лексическими предками целиком, через ту же карту до parent 0 —
не реализована (5): поэтому `merge(f1; f2)` и описания структуры отказывают. Сопоставление частей `fn` (слово головы) и
`return` при `merge(f1; f2)` — вопрос Codex автору, без ответа. Прямой вызов дескриптора отказывает формой разбора, без
выделенного ответа; замена Structure- и ссылочного слота, безымянные поля позднего операнда, определение места ссылкой на
существующую Structure и определения в телах методов — открыты. Переиспользование native f1 для построенного
вызываемого не доказано; без доказательства совместимости — интерпретатор (native = 0).
