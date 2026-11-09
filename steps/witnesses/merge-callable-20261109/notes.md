# Копия вызываемого в merge — 2026-11-09

Исполнитель: opus. Основание: ревью Codex результата 327 (CODEX-OPUS-327-REVIEW-20261109T034551Z-01, копия
[records/pins/codex-327-result-review.txt](records/pins/codex-327-result-review.txt)): срез 327 принят; продолжать 328 —
общая копия написанных имён и вызываемых с нужными лексическими предками целиком через одну карту до `parent` 0;
минимальный независимый путь — копия одного вызываемого `merge(f1)` (второй головы `fn`/`return` там нет, ответ автора
не нужен); сохранение и вызов копии по общему механизму, проверка нужной внешней лексической связи и самостоятельности
изменяемых данных; у нового callable `native` = 0, исходный изменяемый `parent` не заимствуется, скрытого замыкания нет.

## Изменение

1. `lmx_graph_run.lm2`. `lmx_graph_merge_check` допускает в используемом графе написанные имена (примитивы-слова) и
   Structure, вызываемые включительно; другой вид примитива по-прежнему открыт (5). Если в графе есть слово или
   вызываемое, проверка ставит признак цепочки. `lmx_graph_merge_copy`: слово — новая ячейка WORD с тем же каноническим
   адресом (`lmx_graph_word_of`), вызываемое — новая Lmx своего числа слотов, заполняемая из рабочего списка, как Structure
   данных. У новой Lmx `native` = 0 (`lmx_value_owned.lm2:86`), поэтому её вызов исполняет интерпретатор
   (`lmx_graph_run.lm2:1121`). `lmx_graph_merge_values` с признаком цепочки копирует `parent` модели и в цикле рабочего
   списка — исходного родителя каждой скопированной Structure через ту же карту, целиком, до `parent` 0; `parent`
   результата — копия родителя модели (если это не сам результат). Без слов и вызываемых у результата родителя нет, как
   раньше.
2. `lmx_graph.lm2`. `lmx_graph_define` принимает местом свежее неназванное вызываемое (результат merge); новая
   `lmx_graph_word_of`. `tools/build.lm2`: экспорт 41 модуля `lmx_graph` — новый tool27.
3. `l2_graph_tool.lm2`. В `lm_graph_emit_number` форма вызова с фактическими, чья голова называет место, определённое
   оператором корня (таблица объявлений эмиттера, `lm_graph_emit_defined`), эмитируется как `lm_graph_emit_call`:
   разрешение, связывание и вызов во время выполнения — native вызываемого или интерпретатор. Путь `имя \ поле` и
   одиночное `(имя)` этим вызовом не являются (исправление после check47, ниже).
4. Фикстура `merge_callable` (+ `.expected`); `inputs.list` — 359 входов.

## Проверки

Все команды tool/graph — из P/runs/opus328 (`cd … || exit 1`, строка CWD= в логах); логи `P/pins/opus328-*`.

1. Manifest `opus328-source01` (358), stage-copy, verify 358/0. `T26 build-self … S/rt36/driver.o tool27` — exit 0
   (03:51:53→03:52:36Z); `T27 build-runtime … rt37` — exit 0 (03:53:15→03:54:14Z); `T27 build-graph … S/rt37 graph47` —
   exit 0 (03:54:51→03:55:00Z). Затем фикстура дополнена чтениями `c1`/`c2`: `opus328-source01b` отличается от source01
   только `tests/graph/merge_callable.lm2`.
2. `G47 run merge_callable.lm2 1` (значения по норме до запуска): `f1(1)` = 15 (живой `k` = 5), `g(1)` = 12 и `g(2)` = 22
   (скопированный `k` = 2), `f1\var\calls` = 1, `g\var\calls` = 2 — копия не делит `calls` с источником. GRAPH-AFTER
   показывает `g` вызываемым с собственной `var`. `.expected` — GRAPH-AFTER байт в байт; `opus328-source02` (359).
3. `lmxtool checks` `opus328-graph-check47.tsv` (60 строк: 59 прежних с метками rt37/graph47/check47 и merge_callable):
   `CHECKS 60 lines, 1 failed` — native у `merge_reference`: новая ветка эмиттера приняла путь `R \ a` (голова —
   определённое место) за вызов, native-программа остановилась на `int: r_a R\a`
   ([run.log](records/cold-graph309-codex01/check47-merge_reference/native/run.log)). Исправлено условием формы вызова
   (пункт 3 изменения); `opus328-source03` отличается от source02 только `src/l2src/l2_graph_tool.lm2`, которого нет во
   входах ядра (в логе build-runtime rt37 его нет). `T27 build-graph … S/rt37 graph48` — exit 0 (03:58:52→03:59:01Z).
4. `opus328-graph-check48.tsv` (те же 60 строк на graph48/check48): `CHECKS 60 lines, 0 failed`, 180 PASS
   (03:59:17→04:00:26Z); merge_callable PASS в interp/native/forced.
5. `sub_void_value` 5/5 (частичный L1 — байты graph46); `G48 mutation` 11/11, `G48 method-mutation` 8/8.
6. `G48 run`: merge_callable — 15/12/22, 1/2; merge_reference — r_seen 9, s_seen 7, m_a 1, n_a 5, r_a 9; merge_held —
   r 35, x 4, y 5.
7. Пограничный запуск (не фикстура): [probe_recursion.lm2](records/runs/opus328/probe_recursion.lm2) —
   `fn: f1 (int: a) int` с `return: a + f1(a - 1)`, затем `g: merge(f1)`: `f1(3)` = 6, `g(3)` — ответ 3 (неизвестное
   имя), [лог](records/pins/opus328-probe-recursion.log).

## Кортеж

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe; CWD = P/runs/opus328.

- P/pins/opus328-source03.sha256, 359 входов: 04dd58912c4885d6f50a16b91eaaa5c3ab631f21896dac4b0e70af1903e828e0.
- T27 = S/tool27/lmxtool-tool.exe: ba0db186aa58f1373d96b3e18af56d3f7149c75681cb8557c0ecc457ca545bb1 (собран T26 на rt36).
- S/rt37/driver.o: 8dd52a7ab71eeba68ea8bbe96425c88e403406dac3cb1db48ebbaba1f9f88fb8.
- S/rt37/driver-observe.o: 2951a3dc253f6082304f3e8a5ab0776265fece16f2d617d8465c34c38c0ff6ad.
- G48 = S/graph48/graph_trans-prod.exe: 9163dc606ef4786daf8630e755cc12456fdfc4556ac194faac4cb86921abfb16.
- Промежуточный G47 = S/graph47/graph_trans-prod.exe: 99e994459e8bc93f008205e27cfe59cc1977815f0a74142c43fb5ab4fde93946.

```text
T26 0 entry 0 -- build-self R S B F S/rt36/driver.o tool27
T27 0 entry 0 -- build-runtime R S B F rt37
T27 0 entry 0 -- build-graph R S B F S/rt37 graph47        (затем graph48 после исправления эмиттера)
G48 0 entry 0 -- run S/tests/graph/CASE.lm2 1              (merge_callable, merge_reference, merge_held)
T27 0 entry 0 -- checks P/pins/opus328-graph-check48.tsv
G48 0 entry 5 -- run S/tests/graph/sub_void_value.lm2 1
G48 0 entry 5 -- emit-check S/tests/graph/sub_void_value.lm2 S/graph48/sub-void-refused.lm1 native 1
G48 0 entry 0 -- mutation
G48 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2
G48 0 entry 0 -- run P/runs/opus328/probe_recursion.lm2 1
```

Строка проверки — как у [именованной подачи](../named-arguments-20261109/notes.md), OUT — `S/check48-CASE`. Архив:
[список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий](records-lf.sha256); второй проход —
[список](records2.list), [SHA](records2.sha256), [SHA LF](records2-lf.sha256). 105 копий первого прохода (31 с CR
записаны из индекса в LF) и 7 второго (4 с CR); архивные команды — из P/runs/opus328. Docs check S/docs41 над индексом
среза — PASS; `git diff --cached --check` — PASS; повторный над итоговым индексом (после второго прохода и этих notes) —
S/docs42 (лог в P).

## Отступления

1. Списки `opus328-graph-check47.tsv` и `-check48.tsv` получены из списка 327 заменой меток (`sed`) и одной строкой
   `printf`.
2. Промежуточный graph47 провалил одну native-строку (merge_reference); его лог проверок и run.log сохранены в архиве.
3. Фикстура дополнена после первого staging (source01 → source01b); прочие входы сборки те же.
4. Пограничный источник — один написанный вручную `.lm2` в P/runs/opus328, исполненный рецептом graph; не фикстура и не
   норма.

## Граница

1. Прежнее имя внутри копии. Одна карта отображает слот модели в скопированном корне в саму копию R; имена — строки
   адресов, и R отвечает именем своего нового места `g`, поэтому в копии имя `f1` не находится нигде: рекурсивный
   `f1(...)` в теле `g` даёт ответ 3. По книге (композиция) имена тела копии не переразрешаются, а слоты предков ведут к
   копиям, так что `f1` внутри копии должно означать R; преграда — представление (одно имя на адрес), семантика здесь не
   решается. Минимальный источник — пункт 7 проверок.
2. Вызов определённого места из native-тела метода: таблица объявлений эмиттера — таблица корня (тела методов получают
   пустую), не обработан и не запускался.
3. Сопоставление частей `fn`/`return` при `merge(f1; f2)` (вопрос автору), замена Structure- и ссылочного слота при
   повторной подаче (5) и композиция неназванных полей Frame-описания (5) остаются открытыми.
