# Вся структура аргументов одной Structure в чистом графе — 2026-11-09

Исполнитель: opus, единственный writer/build/docs (передача Codex CODEX-OPUS-TAKE-WRITER-20261109T0104Z-01). Продолжение
[именованной подачи](../named-arguments-20261109/notes.md) по ревью Codex CODEX-OPUS-322-RESULT (копия
[records/pins/codex-322-result-review.txt](records/pins/codex-322-result-review.txt)): «use direct fields/common admission,
no tree search or invented ambiguity».

## Норма

Книга, [вся структура аргументов](../../../docs/LMX_semantics.ru.md#whole-arguments): вызов с единственным
аргументом-Structure не отличается от вызова с цепочкой её полей; каждое поле — формалу своего имени, прочие формалы —
свои умолчания; имена и форма целого — до вычисления фактического. Решения автора 2026-11-08
([журнал](../../../LMX_blog/2026-11-08.md)): неоднозначность — только у двух действительно подходящих методов; у одного
метода прямые поля, называющие формалы, подаются полями по базовому правилу, без поиска по дереву: `k (Q: q; int: z 0)` при
`s` с полями `z` = 5 и `q` (`z` = 1) — 15, без умолчания; явная подача `k(q := s)` — 50.

## Изменение

- `selfbuild/src/l2src/lmx_graph_run.lm2`:
  - `lmx_graph_single_candidate` — вызов с одной позиционной фактической, которая называет значение без эффектов: имя
    или путь полей. Литерал, операция, адрес, вызов и именованная фактическая — обычные фактические.
  - `lmx_graph_bind_call` у такого вызова откладывает проверку обязательных формалов до того, как значение известно,
    по-прежнему до любых эффектов аргументов: вычисление имени или пути эффектов не имеет.
  - `lmx_graph_call_single` — после вычисления этого значения. Structure, у которой каждое прямое поле называет формал
    выбранного вызываемого того же рода (int-поле — int-формал, Structure-поле — формал модели), а каждый формал без
    поля имеет прямое умолчание, — вся структура аргументов: поля принимаются своими формалами (общий `lmx_graph_admit`,
    у формала модели — первая часть `implements` по используемым путям) в порядке формалов вызываемого. Иначе значение —
    обычный первый аргумент, и каждый другой формал требует умолчания (иначе отказ формы 5). Решение — по формалам и
    прямым полям значения: ни поиска по дереву, ни второго чтения. Массивы принадлежат одному вызову.
  - `lmx_graph_eval_call`: у такого вызова — связывание, вычисление значения, `lmx_graph_call_single`.
- `selfbuild/src/l2src/l2_graph_tool.lm2`: выпуск native такого вызова — `lmx_graph_bind_call`, операнд, затем та же
  функция ядра `lmx_graph_call_single` (решение при исполнении, одно для обоих потребителей).
- `selfbuild/tools/build.lm2`: `graph_run_names` 20 → 22 (`[20] lmx_graph_single_candidate`, `[21] lmx_graph_call_single`).
- Фикстуры: `whole_arguments` (+ `.expected`), `whole_missing`, `whole_kind`; `inputs.list` — 340 входов.

## Проверки

Последовательно, CWD `C:/Nyasha_Planet/LMX`, логи `P/pins/opus323-*`.

1. Manifest `opus323-source01` (339 входов), stage-copy, verify 339/0; `T23 build-self … S/rt31/driver.o tool24` — exit 0,
   01:49:25→01:49:58Z; `T24 build-runtime … rt32` — exit 0, 01:51:40→01:52:27Z; `T24 build-graph … S/rt32 graph42` —
   exit 0, 01:52:44→01:52:52Z.
2. `G42 run whole_arguments.lm2 1` (интерпретатор): whole_both 47 (`tst(Pack)`: c 4, a 7), whole_one 35 (`tst(Only)`:
   a 5, c — умолчание 3), whole_required 35 (`mytest(Only)`: обязательный `a` из поля), whole_path 61
   (`tst(Holder\Inner)`), qz 15 (`k(s)`: q ← s\q, z ← s\z, умолчание не использовано), qz_named 50 (`k(q := s)`),
   positional 12 (`first(Extra)`: поле `a` не называет формал — обычный первый аргумент, e\a = 1, q 2), number 52
   (`tst(5)`), plain_int 472 (`tst(whole_both)`: int-значение — первый аргумент) — все значения рассчитаны по норме до
   запуска. Поданные Structure и сигнатуры с умолчаниями не изменились. `whole_arguments.expected` — GRAPH-AFTER этого
   запуска, сверен построчно, равен выводу байт в байт. Manifest `opus323-source02` (340 входов), stage-copy, verify
   340/0.
3. `lmxtool checks` по `opus323-graph-check42.tsv` (48 строк: 45 прежних и три новых): `CHECKS 48 lines, 0 failed`,
   144 PASS. Отрицательные: whole_missing — у `mytest(OnlyC)` поле `c` есть, обязательный `a` без поля и без умолчания:
   не вся структура, первый аргумент, отказ формы (интерпретатор 5); whole_kind — Structure-поле `c` у int-формала: не
   вся структура, первый аргумент, отказ приёма int-формалом (интерпретатор 4); native/forced — остановка R0, выход 1;
   `result` во всех трёх режимах — неисполненное объявление.
4. Выпуск native `whole_arguments`: семь вызовов через `lmx_graph_call_single` (whole_both, whole_one, whole_required,
   whole_path, qz, positional, plain_int) и два через `lmx_graph_invoke_bound` (qz_named — именованный, number —
   литерал); forced-программа исполняет граф интерпретатором и вызовов не выпускает.
5. `sub_void_value`: `run` и `emit-check` ответили 5, частичный L1 отказа — байты graph41. `G42 mutation` 11/11,
   `G42 method-mutation tests/graph/point_take.lm2` 8/8.

## Кортеж

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe.

- P/pins/opus323-source02.sha256, 340 входов: 741371b6e48ccbbe2d15283bba27d1d4d9397d326d841cc3e8f394a48c4d6835.
- T24 = S/tool24/lmxtool-tool.exe: d6fab077f11935c95add32cb78e3aaed554d7b07f440d5c0c4f217e721235af5 (собран T23 на rt31).
- S/rt32/driver.o: 29588c83e671561cb066e8a468dafed9033c5b15560275a0306c4626b8ee2be1.
- S/rt32/driver-observe.o: 3b0cf5f0cc5b35d55088cde50cf1f6303a971d13d4f8e6c581b91da07021515e.
- G42 = S/graph42/graph_trans-prod.exe: 6405fa9e7883d3a47990b5c61b8be9fc6f3d12f1ee86fa6a5e3a3ac8db1721c9.
- F: b1851f7b56e568088e3e71fdf3b8676de7e01d86481b8c43efe268309778166f.

```text
T23 0 entry 0 -- build-self R S B F S/rt31/driver.o tool24
T24 0 entry 0 -- build-runtime R S B F rt32
T24 0 entry 0 -- build-graph R S B F S/rt32 graph42
G42 0 entry 0 -- run S/tests/graph/whole_arguments.lm2 1
T24 0 entry 0 -- checks P/pins/opus323-graph-check42.tsv
G42 0 entry 5 -- run S/tests/graph/sub_void_value.lm2 1
G42 0 entry 5 -- emit-check S/tests/graph/sub_void_value.lm2 S/graph42/sub-void-refused.lm1 native 1
G42 0 entry 0 -- mutation
G42 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2
```

Строка проверки — как у [именованной подачи](../named-arguments-20261109/notes.md), OUT — `S/check42-CASE`.
Архив receipts: [список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий Git](records-lf.sha256) —
84 копии языковыми `manifest`/`stage-copy`, 24 копии с CR записаны из индекса в LF; второй проход (docs check и архив) —
[список](records2.list), [SHA](records2.sha256), [SHA LF](records2-lf.sha256). Docs check S/docs28 (PRIVATE_OUT создан
заранее) — PASS: 35 парных глав семантики, 14 случаев implements, оба снимка, 27 разделов грамматики, 44 выдержки,
615 импортов, ссылки, вводная часть, LF для 22855 отслеживаемых файлов; `git diff --cached --check` — PASS; повторный
docs check над итоговым индексом — S/docs29 (лог `P/pins/opus323-docs29.log`, остаётся в P).

## Граница и остаток

Сделано для значения без эффектов (имя, путь) в поддержанном int/Structure-подмножестве. Не сделаны: производитель
Structure с эффектами (вызов, `merge`, записанный в вызове) и ранняя проверка формы для него; `merge` в чистом графе
вообще — поэтому авторский пример `mytest(merge(mytest\args; (a: int: 5)))` = 35 ещё не исполним новым путём; выбор
среди двух методов одного имени и отказ их неоднозначности; поле-ссылка и иные примитивы; вычисляемые умолчания;
AXBY с пользовательскими преобразователями; copy/merge/attach/GC/codec, Message/mail, самосборка, collector/3pass/FULL,
§§8/8a.
