# Повторная подача поля в merge — 2026-11-09

Исполнитель: opus. Основание: ревью Codex результата 326 (CODEX-OPUS-326-REVIEW-20261109T033614Z-01, копия
[records/pins/codex-326-result-review.txt](records/pins/codex-326-result-review.txt)): исправление карты, место
результата и дескриптор приняты; новый дефект — в проходе записей `lmx_graph_merge_values` условие «адрес поля не равен
первому источнику слота» пропускало повторную подачу того же источника поздним операндом, и `merge(M; N; M)` давал
`R\a` = 5 вместо 1 по порядку операндов.

## Изменение

`lmx_graph_run.lm2`, `lmx_graph_merge_values`: для каждого слота результата, кроме значения его первого источника,
хранится позиция этого источника — операнд и поле (`from_k`, `from_j`), локальные данные обхода merge, не сущности
графа. Проходы отображения (`lmx_graph_merge_alias`) и записей отличают первое заполнение слота от подачи по позиции, а не
по адресу: тот же источник, поданный снова, пишется снова по порядку операндов; первое заполнение нового слота (в том
числе Structure или ссылки) по-прежнему только копируется. Фикстура `merge_repeat` (+ `.expected`); `inputs.list` —
357 входов. Экспорты и рецепт не менялись — tool26 прежний.

## Проверки

Все команды tool/graph — из P/runs/opus327 (`cd … || exit 1`, строка CWD= в terminal и логах); логи `P/pins/opus327-*`.

1. Manifest `opus327-source01` (356), stage-copy, verify 356/0; `T26 build-runtime … rt36` — exit 0
   (03:38:40→03:39:35Z); `T26 build-graph … S/rt36 graph46` — exit 0 (03:39:35→03:39:44Z).
2. `G46 run merge_repeat.lm2 1` (значения по норме до запуска): r 1 (`merge(M; N; M)\a`), s 5 (`merge(N; M; N)\a`), m_a 1,
   n_a 5 — источники целы; прежний код дал бы 5 и 1. Свидетели 326 сохранены: merge_reference r_seen 9, s_seen 7;
   merge_held r 35. `.expected` — GRAPH-AFTER байт в байт; manifest `opus327-source02` (357), verify 357/0.
3. `lmxtool checks` `opus327-graph-check46.tsv` (59 строк: 58 прежних с метками rt36/graph46/check46 и merge_repeat):
   `CHECKS 59 lines, 0 failed`, 177 PASS.
4. `sub_void_value` 5/5 (частичный L1 — байты graph45); `G46 mutation` 11/11, `G46 method-mutation` 8/8.

## Кортеж

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe; CWD = P/runs/opus327.

- P/pins/opus327-source02.sha256, 357 входов: a142c7a7edf926e06759b8399cb1fb7e114d53b7d5ae96a42403404626c7a846.
- T26 = S/tool26/lmxtool-tool.exe: 3d67a92563311594b062370d7d3390f86906aeed3f90c271ef9126b534a9e8b9.
- S/rt36/driver.o: 06523724ada7a02ac84906fd92d2e1abda0b4da2030550dcf3da172327e16d01.
- S/rt36/driver-observe.o: e86b23efa11293e9c66f599d97e11b623e1b5a5ffba731fc98a71aabd55b17c5.
- G46 = S/graph46/graph_trans-prod.exe: 4711793750ecd77fc983dbd06c021b3adf278d16994e1c682a964239715217b2.

```text
T26 0 entry 0 -- build-runtime R S B F rt36
T26 0 entry 0 -- build-graph R S B F S/rt36 graph46
G46 0 entry 0 -- run S/tests/graph/CASE.lm2 1          (merge_repeat, merge_reference, merge_held)
T26 0 entry 0 -- checks P/pins/opus327-graph-check46.tsv
G46 0 entry 5 -- run S/tests/graph/sub_void_value.lm2 1
G46 0 entry 5 -- emit-check S/tests/graph/sub_void_value.lm2 S/graph46/sub-void-refused.lm1 native 1
G46 0 entry 0 -- mutation
G46 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2
```

Строка проверки — как у [именованной подачи](../named-arguments-20261109/notes.md), OUT — `S/check46-CASE`. Архив:
[список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий](records-lf.sha256); второй проход —
[список](records2.list), [SHA](records2.sha256), [SHA LF](records2-lf.sha256). 88 копий первого прохода (19 с CR
записаны из индекса в LF) и 7 второго (4 с CR); архивные команды — из P/runs/opus327. Docs check S/docs38 над индексом
среза — PASS; `git diff --cached --check` — PASS; S/docs39 после второго прохода — PASS; повторный над итоговым
индексом — S/docs40 (лог в P).

## Отступления

1. Список `opus327-graph-check46.tsv` получен из списка 326 заменой меток (`sed`) и одной строкой `printf`.

## Граница

Как в [записи 326](../merge-places-20261109/notes.md): копия написанных имён и вызываемых с нужными лексическими
предками целиком (следующий срез), сопоставление частей `fn`/`return` при `merge(f1; f2)` (вопрос автору), замена
Structure- и ссылочного слота при повторной подаче (5) остаются открытыми.
