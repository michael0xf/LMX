# Функция из вычисленных аргументов: `fn: prepared`, `fn: new_name merge(f1, f2)` — 2026-11-09

Исполнитель: opus. Основание — технические уточнения автора 2026-11-09 в [журнале](../../../LMX_blog/2026-11-09.md)
(`fn: prepared`, `fn: new_name merge(f1, f2)`, одинаковое дополнение var, одна форма ресивера с разным числом аргументов,
`merge(f1 f2)` берёт и структуры кода с полем `name`) и ревью Codex: CODEX-OPUS-332R-REVIEW-20261109T084845Z-01
([копия](records/pins/codex-332r-result-review.txt); моё письмо — [records/pins/opus332r-letter-result.txt](records/pins/opus332r-letter-result.txt)),
продолжающее CODEX-OPUS-332-REVIEW-20261109T080211Z-01 и план CODEX-OPUS-332-333-PLAN-REVIEW-20261109T0622Z-01 (копии —
в [записи 332](../fn-traversal-20261109/notes.md)). Предыдущий срез: [332 и проход его ревью](../fn-traversal-20261109/notes.md#review-332).

## Изменение

1. **Когда ресивер применяется.** `lmx_graph_fn_written` (экспорт) отличает объявление с записанными аргументами —
   позиционную форму контракта, чьи аргументы-Structure записаны анонимными Structure: такое F создаётся при входе в блок
   (`lmx_graph_space_declarations` берёт только их) и видно во всём блоке. Остальные Frame `fn`/`sub` — применение
   ресивера к аргументам, которые вычисляет обход: `lmx_graph_fn_apply` (экспорт) создаёт F там, где обход корня дошёл
   до Frame (интерпретатор: `lmx_graph_block` в режиме корня и `lmx_graph_exec_statement`), имя отвечает с этого места.
2. **Формы.** Один аргумент — вся подготовленная Structure (`fn: prepared`): её поля `name`, `args`, `return` (у `fn`),
   `var`, `body` дают аргументы по именам. Два аргумента — записанное имя (не вычисляется) и Structure частей
   (`fn: new_name merge(f1, f2)`); поле `name` такой Structure — обычное поле, не имя. Части читает `lmx_graph_fn_part`
   (экспорт) — одна модель Frame, как у корня: ссылка — цель, Frame `name: value` с одним полем-значением — значение,
   иначе само поле — какую бы Structure ни подали (код, результат `merge`, созданную функцию). F строит прежний
   `lmx_graph_fn_make`, var — `lmx_graph_fn_var`; `parent` F — Frame применения, свободные имена тела разрешаются от F.
   Имя проверяется до вычисления Structure (форма с именем); Structure вычисляется один раз своим выражением.
3. **Отказы и границы.** Имя, уже отвечающее в блоке, — 4. Другое число аргументов, поле вне контракта, нет имени,
   `args` или требования результата — 5 (`fn_without_name`: `fn: merge(f1, f2)`). Применение в теле или во встроенном
   блоке — 5 в обоих потребителях (повторная активация связала бы имя снова), так же именованная подача `name := …` и
   подача частей Frame-ами по головам (`fn: name: …; args: …`, пример автора с `"test"`): граница реализации.
4. **merge функций.** `lmx_graph_merge_values` разделена: уровень `lmx_graph_merge_level` строит результат через ту же
   карту; когда модель — Structure, созданная `fn`/`sub` (`lmx_graph_fn_result`), её части, которые поздние операнды
   дают снова как Structure (`args`, `var`), компонуются тем же уровнем рекурсивно (слот сохраняет форму модели:
   именованная ссылка — на композицию), а их модели получают `parent` — копию родителя модели — после копирования
   цепочки. `lmx_graph_merge_write`: место-слово принимает позднее слово (`return`). Тело не склеивается: у `f2` без
   тела остаётся копия тела `f1`. Композиция частей обычной Structure (не функции) по-прежнему открыта (5).
5. **var.** `lmx_graph_fn_var` решает о цепочке по используемому графу записанной var (`lmx_graph_merge_check`, как
   `merge`) и копирует через ту же карту, целиком, родителя каждой скопированной Structure вне var — нужный лексический
   предок того, что var достигает ссылкой (п. 4 ревью 332R); собственные поля берёт по операторам тела, какой бы
   Structure ни было тело (у `fn: prepared` — Frame `body: (…)`).
6. **Транслятор.** Код корня вызывает `lmx_graph_fn_apply(l2_g, lmx_call_code, i)`; трансляция не создаёт для такой
   функции ни F, ни native — её вызов разрешается при исполнении и уходит в интерпретатор. Имя, которое форма даёт
   (записанное, либо поле `name` Structure, которую namespace трансляции отвечает по написанному слову), входит в
   таблицу объявлений эмиттера (`lm_graph_emit_fn_name`, `lm_graph_emit_defined`): оператор `g(1; 2)` на нём
   выпускается как применение при исполнении, как у интерпретатора. В теле — 5. Имя Structure, которую вычисляет
   выражение (`fn: merge(…)`), трансляция не знает: поле корня, применяющее такое имя, классифицируется при трансляции
   без него (граница).
7. **Печать.** Ссылка на безымянную Structure (части `args`, `body` копии `merge`) печатается блоком этой Structure под
   именем ссылки, именованное место-слово — `name: word`: тот же текст, что у подготовленной Structure
   (`descriptor_merge`). Frame `fn: g merge(…)` печатается блоком по прежнему правилу печати.

## Фикстуры

| Фикстура | Что | graph64 (интерпретатор; native/forced — те же GRAPH-AFTER) |
|---|---|---|
| fn_prepared (новая) | `fn: prepared`; var — `calls` и поле тела `last` | `triple(5)` 19, `triple(2)` 10, calls 2, last 2; prepared как написан |
| fn_new_name (новая) | `fn: g merge(f1, f2)`, f2 — дескриптор `(int: a; int: b)` | f1(1) 15, g(1; 2) 15, g(3; 4) 35; calls 1/2; seen 1/3 |
| fn_without_name (новая, отр.) | `fn: merge(f1, f2)` без имени | интерпретатор 5; native/forced — отрицательный R0 |
| descriptor_merge (была отр. 5) | `R: merge(f1; f2)`, `fn: g R` | f1(1) 12, g(1) 17 (умолчание b 7 дескриптора); R печатается частями |
| merge_callable (была отр. 2) | `fn: g merge(f1)` | 15, 15, 25; calls 1/2 (`k` 5 — от g, созданной в корне) |
| merge_recursion (была отр. 2) | `fn: g merge(f1)`, тело зовёт `f1` | g(3) 6; f1 calls 3, g 1; f1(2) 3; 6/1 |
| defined_call_body (была отр. 4) | g в теле `twice` | 16; 0/2 |
| defined_call_actuals (была отр. 2) | `g(1; 2)`, `g(b := 7; a := 6)` | r 6; f 0/0; g calls 3, last 67 |

Смысловое следствие (п. 2, kernel §3.4/§6.4): функция, которую `fn` создаёт из копии `merge`, разрешает свободные
имена тела от себя, как любая F: её `parent` — Frame применения в корне. Скопированные `merge` лексические предки
остаются данными копии. Поэтому `g(1)` в merge_callable — 15 при `k` 5 (в 328, когда сама копия была вызываемой, — 12 из
скопированного `k` 2), а `f1` в теле g — функция `f1` корня (в 329 рекурсия оставалась в копии). Функции живут только в
namespace обхода; скопированный корень держит объявления как написанные, а не функции.

## Проверки

1. Первый проход graph63 (rt52, source17): `CHECKS 73 lines, 1 failed`, 218 PASS — `descriptor_merge` interp: прежняя
   отрицательная (5) теперь исполнялась, а печать R отказывала на ссылке к безымянной части (п. 7). graph62 — сборка
   не прошла (`l2trans: this C call's actual has no C type…` в свидетеле, вызовы вынесены в типизированные места).
2. Итог на graph64/tool33/rt53 (`opus333-source19`, 383 входа): `checks opus333-graph-check64.tsv` — `CHECKS 73 lines,
   0 failed`, 219 PASS (09:25:56→09:27:12Z); `mutation` 12/12 — новый адресный свидетель
   `var-copy-keeps-the-lexical-chain-of-a-reached-structure` (var F достигает ссылкой Structure C, чей родитель P вне
   var: копия C — под копией P с `k` 7, источники прежние); `method-mutation` 8/8; `sub_void_value` — `run answered 5`,
   `emit answered 5`, частичный L1 = graph58; производственные модули — как на graph61 (primitive и lmxtool — `run
   answered 3`, остальные exit 0), везде GRAPH-BEFORE = GRAPH-AFTER, журналы совпадают с graph61 после строки CWD.
3. Мутант свидетеля: в staged `lmx_graph_run.lm2` (только в S, репозиторий не трогался) копирование предка в
   `lmx_graph_fn_var` отключено условием `chain = 7`; rt54m/graph65m — `mutation` 11 PASS, FAIL ровно
   `var-copy-keeps-the-lexical-chain-of-a-reached-structure`. Затем stage-copy source19 и verify — 383, 0 failed.

## Кортеж

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe; CWD = P/runs/opus333.

- P/pins/opus333-source19.sha256, 383 входа: 37ec6bf813507330bf7b06a9639851495888c54b614283bcd51fbe4a622df955.
- T33 = S/tool33/lmxtool-tool.exe: f0ea801e92793f2618bd6433bea2227b779fbbbdbe920603cb3d31c2ba2edb6b (собран T32 на rt51 из
  source15; build.lm2 после не менялся; graph_run_names 38: + fn_apply, fn_written, fn_part).
- S/rt53/driver.o: 266b4a33242aa01841bfd1ea6d4ccb9311f368e75e64e406bc265afe8ecd07df (source18).
- S/rt53/driver-observe.o: e445e6d3c6a78d139466315e619aa866c16f368f5e4d7f3730eb565500162571.
- G64 = S/graph64/graph_trans-prod.exe: 9e8fe9e1d19e5c405d19a70fcd35c75dc4599c5477a1c77a2f5b98763004febd (source18; source19
  добавляет только descriptor_merge.expected).
- Промежуточные: rt52 driver.o 4d68100b968e87d0a991467d87dc10542f3ce80cc52564f49e2607f572717723, G63
  661df6a99fa98a4cf8d1c49ee9ce49164f18b8ded43204d93409cda65e8376b0.

```text
T32 0 entry 0 -- build-self R S B F S/rt51/driver.o tool33
T33 0 entry 0 -- build-runtime R S B F rt53
T33 0 entry 0 -- build-graph R S B F S/rt53 graph64
T33 0 entry 0 -- checks P/pins/opus333-graph-check64.tsv
G64 0 entry 0 -- mutation
G64 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2
G64 0 entry 5 -- run S/tests/graph/sub_void_value.lm2 1
G64 0 entry 5 -- emit-check S/tests/graph/sub_void_value.lm2 S/graph64/sub-void-refused.lm1 native 1
G64 0 entry 0 -- run S/<production input> 1
```

OUT строк проверки — `S/check64-CASE`. Архив: [список](records.list), [SHA оригиналов](records.sha256), [SHA
LF-копий](records-lf.sha256); docs check и архивные журналы — [список](records2.list), [SHA](records2.sha256),
[SHA LF](records2-lf.sha256).

## Граница и следующее

1. Применение ресивера к вычисленным аргументам — только в корне; в теле и встроенном блоке, именованная подача и
   подача частей по головам — 5.
2. Композиция Structure-частей — для модели-функции; для обычной Structure замена Structure/ссылочного слота открыта.
3. Имя функции, которое даёт Structure, вычисленная выражением, транслятор не знает до исполнения.
4. Открытые с 329–332: адрес `@` ссылки на Structure, внутренняя ссылка в var письменной формой (`@:` в var — 5),
   C-дверь интерпретатора, машинный экспорт из чистого графа (вход F вместо P0).
