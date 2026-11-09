# merge в чистом графе — 2026-11-09

Исполнитель: opus. Основание: ревью Codex результата 324 (CODEX-OPUS-324-REVIEW-20261109T021402978Z-01, копия
[records/pins/codex-324-result-review.txt](records/pins/codex-324-result-review.txt)): продолжить merge/копию и пример
автора `mytest(merge(mytest\args; (a: int: 5)))` = 35 тем же графом в обоих потребителях, одной картой источник → копия,
без частного случая. Вопрос Opus о Frame-операнде (OPUS-CODEX-325-MERGE-OPERAND-QUESTION-20261109T0235Z-01) и ответ
Codex ([records/pins/codex-325-merge-review.txt](records/pins/codex-325-merge-review.txt)): тот же построенный граф — та
же семантика, без скрытого флага двоеточия/скобок, но и без безусловной подачи `[слово, значение]` в слот модели;
анонимная Structure примера — по обычным правилам; механика копии — книга :1205–1207 и §6.4, parent = 0 только там, где
лексический родитель действительно не нужен. Два ответа автора 2026-11-08, переданные Codex
([records/pins/codex-author-merge-call-no-intercept.txt](records/pins/codex-author-merge-call-no-intercept.txt),
[records/pins/codex-author-merge-functions-signature.txt](records/pins/codex-author-merge-functions-signature.txt)),
дословно — в [журнале](../../../LMX_blog/2026-11-08.md): голова-функция вызывается один раз, поле модели вызов не
перехватывает; `merge(f1, f2)` — по общим правилам структур (f2 без body меняет сигнатуру f1).

## Норма

Книга, композиция (provenance/semantics-book.md :1203–1219): операнды вычисляются один раз слева направо; новый корень с
раскладкой модели и новыми полями в конце; совпадающее поле позднего операнда пишется в слот модели допуском
присваивания; одна карта источник → копия на все операнды, общие цели и циклы общие, `parent` — на копии, место
исполнения `merge` нового лексического родителя не задаёт. Вся структура аргументов (:731–740): результат `merge`,
поданный единственным аргументом, — вся структура аргументов, `r` = 35. Ядро §6.4, L2 §13. Предложение книги о `v: 9` как
подаче в слот модели (:1215 RU, :1261 EN) согласовано с ответом автора; книга перегенерирована (`docs render semantics`).

## Изменение

- `lmx_graph_run.lm2`: `lmx_graph_eval_value` узнаёт `merge` по адресу слова (`w_merge` состояния) и вызывает
  `lmx_graph_eval_merge`: операнды по одному, слева направо (`lmx_graph_merge_operand`) — анонимная Structure
  (`lmx_graph_merge_literal`: безымянная Lmx, каждое поле которой — `имя: значение`, `int: имя значение` или `int: имя`;
  голова поля, называющая вызываемое, делает его применением) строится `lmx_graph_merge_literal_open/put` (новая
  Structure, у каждого поля своя ячейка, имя — строка таблицы; уже разрешающееся или повторённое имя — открыто, 5);
  Frame с головой-не-функцией (`lmx_graph_merge_description`) — описание структуры, 5; всё прочее — обычное значение
  (`lmx_graph_eval_value`: имя, путь, вложенный merge, вызов). Композиция — `lmx_graph_merge_values` (общая для
  интерпретатора и native): проверка используемого графа (`lmx_graph_merge_check`: int-места, int-ссылки, Structure
  данных; слова и вызываемые — открыто, 5; операнд не Structure — 4), набор полей до выделения Lmx, одна карта
  `LmxCopyMap` (корни всех операндов → результат), копия модели (`lmx_graph_merge_copy`: прямая ячейка; место без
  значения — копия ячейки и новый указатель `uninit:int` на неё; int-ссылка — на копию ячейки; Structure — новая Lmx,
  слоты — из рабочего списка), запись одноимённого поля в слот (`lmx_graph_merge_write`, `lmx_graph_assign_int`; слот не
  int — 5), новые поля в конце, рёбра `parent` после всех копий. `lmx_graph_single_candidate` принимает `merge`;
  `lmx_graph_work_scan` не считает слово `merge` и имена полей анонимной Structure свободными входами
  (`lmx_graph_work_scan_literal`).
- `lmx_graph.lm2`: слово `merge` в состоянии; `lmx_graph_uninit_int_at` — указатель места без значения на существующую
  ячейку (копия такого места).
- `l2_graph_tool.lm2`: `lm_graph_emit_merge` — native вычисляет каждый операнд своим путём (литерал — вызовами ядра
  `lmx_graph_merge_literal_open/put`, остальное — `lm_graph_emit_operand`, вызов — один раз), описание отказывает во время
  выполнения предикатом ядра, затем один вызов `lmx_graph_merge_values`; `merge` не вычисляется заранее.
- `tools/build.lm2`: поле `w_merge` в `LmxGraphState`; экспорты `lmx_graph` 38 (`lmx_graph_uninit_int_at`),
  `lmx_graph_run` 27 (пять функций merge). Новый tool25.
- Фикстуры `merge_arguments` (+ `.expected`), `merge_call_paren`, `merge_call_colon`, `merge_description`;
  `inputs.list` — 347 входов.

## Проверки

Последовательно, CWD `C:/Nyasha_Planet/LMX`, логи `P/pins/opus325-*`.

1. Manifest `opus325-source01` (346), stage-copy, verify 346/0. `T24 build-self … S/rt33/driver.o tool25` — exit 0
   (02:48:27→02:49:05Z); `T25 build-runtime … rt34` — exit 0 (02:49:13→02:50:08Z); `T25 build-graph … S/rt34 graph44` —
   exit 0 (02:50:17→02:50:26Z).
2. `G44 run merge_arguments.lm2 1` (значения рассчитаны по норме до запуска): r 35 (`mytest(merge(mytest\args; (a: int:
   5)))`), both 46, nested 27 (вложенный merge), named 38 (`AV` — именованная Structure, поле `a` пишется в слот модели),
   model 18 (модель `AV`, новое поле `c` в конце, вся структура аргументов), body 39 (`merge` в теле метода, `a` — формал
   `x`), appended 9 (`merge(AV; (z: 9))\z`), kept 10 (`merge(AV; (a: 2))\a + AV\a` — источник не изменён), after 31
   (`mytest(a := 1)` после всех merge — сигнатура и умолчание целы). GRAPH-AFTER сверен построчно; `.expected` — этот
   GRAPH-AFTER байт в байт. Manifest `opus325-source03` (347), verify 347/0.
3. Отрицательные (интерпретатор): `merge_call_paren` (`merge(M; f(3))`) и `merge_call_colon` (`merge(M; f: 3)`) — один
   граф `(merge M (f 3))`; `f` вызвана один раз (`calls 0` → `1`), поле `M\f` = 1 не тронуто, int-результат не Structure
   — отказ приёма, ответ 4. `merge_description` (`merge(M; v: 9)`, `v` не функция) — описание структуры, ответ 5.
4. `lmxtool checks` `opus325-graph-check44.tsv` (53 строки: 49 прежних с метками rt34/graph44/check44 и четыре новые):
   `CHECKS 53 lines, 0 failed`, 159 PASS. Native `merge_arguments`: девять вызовов `lmx_graph_merge_values` (корень и
   native-тело `wrap`), восемь `lmx_graph_merge_literal_open`, шесть `lmx_graph_call_single`; forced исполняет граф
   интерпретатором. Native отрицательных: `calls 0` → `1` в BEFORE/AFTER, остановка R0 (выход 1).
5. `sub_void_value`: `run` и `emit-check` ответили 5, частичный L1 — байты graph43. `G44 mutation` 11/11,
   `G44 method-mutation tests/graph/point_take.lm2` 8/8.
6. Пробы в стейдже вне manifest (`S/tests/graph/opus_probe325a–c.lm2`, логи `P/pins/opus325-probe-*.log`): (a)
   `pack: merge(...)` у корня — 3: оператор корня пишет только существующее место, определение нового места
   Structure-значением в чистом графе не реализовано; (b) `fn: f2 (int: b 7) int` без тела — построитель отказывает (2):
   `lm_graph_build_method` требует тело, дескриптор интерфейса (книга :691) не строится; (c) `merge(f1; f2)` двух полных
   функций — 5: копия вызываемых открыта.

## Кортеж

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe.

- P/pins/opus325-source03.sha256, 347 входов: 47a28b4f4a263c323f9d105164b3e7abce1f7ff4028ceff5133c098320faf637.
- T25 = S/tool25/lmxtool-tool.exe: f1ff147b3e19f40d7447ab80ad1824874259bae889c7814d3828d8dc15722536 (собран T24 на rt33).
- S/rt34/driver.o: 3b24f984d8f0a89b1d9a7832fc113e209a0eb4e4209ada8f9f0b5a2e31da76e6.
- S/rt34/driver-observe.o: a0e89ef50b7d4f305a55c4493fb22d59e28dfbecbb5df71872669782ad374dc6.
- G44 = S/graph44/graph_trans-prod.exe: 7db58362353fc8d56113e09aad588bb1690a54e83887efa8226df8c6e4f4acfe.
- F: b1851f7b56e568088e3e71fdf3b8676de7e01d86481b8c43efe268309778166f.

```text
T24 0 entry 0 -- build-self R S B F S/rt33/driver.o tool25
T25 0 entry 0 -- build-runtime R S B F rt34
T25 0 entry 0 -- build-graph R S B F S/rt34 graph44
G44 0 entry 0 -- run S/tests/graph/merge_arguments.lm2 1
G44 0 entry 0 -- run S/tests/graph/merge_call_paren.lm2 1
G44 0 entry 0 -- run S/tests/graph/merge_call_colon.lm2 1
G44 0 entry 0 -- run S/tests/graph/merge_description.lm2 1
T25 0 entry 0 -- checks P/pins/opus325-graph-check44.tsv
G44 0 entry 5 -- run S/tests/graph/sub_void_value.lm2 1
G44 0 entry 5 -- emit-check S/tests/graph/sub_void_value.lm2 S/graph44/sub-void-refused.lm1 native 1
G44 0 entry 0 -- mutation
G44 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2
T25 0 entry 0 -- docs render semantics R C:/Nyasha_Planet/L1/Lingvamyxa_spec.txt C:/Nyasha_Planet/lingvamyxa/Lingvamyxa_spec.txt
```

Строка проверки — как у [именованной подачи](../named-arguments-20261109/notes.md), OUT — `S/check44-CASE`; render —
из нового каталога S/docs32. Архив: [список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий](records-lf.sha256);
второй проход (docs check и архив) — [список](records2.list), [SHA](records2.sha256), [SHA LF](records2-lf.sha256).
114 копий первого прохода (37 с CR записаны из индекса в LF) и 7 второго (4 с CR). Docs check S/docs33 над индексом
среза — PASS (35 глав, 14 случаев implements, 27 разделов грамматики, 44 выдержки, 615 импортов, ссылки, LF для 23095
файлов); S/docs34 после второго прохода — PASS; повторный над итоговым индексом — S/docs35 (лог в P).

## Отступления

1. Первый запуск `merge_arguments` ответил 2 на строке `both`: в однострочных скобках поле с двоеточием забирает остаток
   строки, и `(c: int: 4; a: int: 6)` построилось как `[c, 4, [a, 6]]` (нормальная форма P0). Строка фикстуры записана
   `(c(4); a(6))` — тот же граф, что `c: 4`; лог первого запуска перезаписан вторым той же командой
   (`P/pins/opus325-run-merge_arguments.log`), до правки — manifest `opus325-source01`.
2. Список `opus325-graph-check44.tsv` получен из списка 324 заменой меток (`sed`) и четырьмя строками `printf`.
3. Пробы a–c записаны в стейдж вне manifest, как прежние пробы; их копии в архиве.
4. Две строки дословной цитаты автора кончаются пробелом, как написано (так же в `LMX_blog/2026-11-07.md`);
   `git diff --cached --check` указывает только на них — в журнале и в двух архивных копиях того же сообщения
   (`records/pins/author-merge-call-no-intercept-quote.txt`, `records/pins/codex-author-merge-call-no-intercept.txt`,
   лог `P/pins/opus325-diff-check.log`, который в архиве повторяет те же строки); без этих файлов проверка проходит.
5. Архивные `manifest`/`stage-copy` запускались с CWD в каталоге записи; драйвер оставил там неотслеживаемый файл
   защищённого имени — он не читался, не копировался и не стейджился (коммит — по списку путей).

## Граница

Копия написанных имён (слов) и вызываемых требует копии их лексической цепочки — открыто (5): поэтому описание
структуры `merge(M; v: 9)`, `merge(f1; f2)` и операнды с кодом отказывают; у результата подмножества нет написанных имён,
и его `parent` — 0. Для указания автора о `merge(f1; f2)` с `f2` без тела не хватает двух частей: построения дескриптора
интерфейса (проба b) и копии вызываемых с их лексической цепочкой (проба c); вызов вновь построенного вызываемого шёл бы
через интерпретатор или совместимый переиспользуемый native-вход — компиляции во время выполнения нет, и native здесь
проверяет только исполнение `merge` уже скомпилированным кодом. Открыты также: держимое место `pack: merge(...)`
(проба a), замена Structure- или ссылочного слота, безымянное поле позднего операнда, повторённое или уже разрешающееся
имя анонимной Structure, значения полей не int, функции с результатом Structure.
