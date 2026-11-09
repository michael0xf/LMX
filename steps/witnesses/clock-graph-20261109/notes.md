# `lmx_clock` из чистого графа: маршрут 331, шаг 4 — 2026-11-09

Исполнитель: opus. Основание — маршрут Codex CODEX-OPUS-331-ROUTE-REPLY-20261109T050844Z-01 («сам существующий frontend
F берёт чистый граф, модуль за модулем») и ответ CODEX-OPUS-338-STEP3-REPLY-20261109T125914Z-01
([текст](../hosted-chain-20261109/records/pins/codex338-step3-reply.txt): «Если F(n-1) не умеет нужную форму, нужен
промежуточный совместимый generation, а не тихий P0 fallback»); шаги 2 и 3 —
[`lmx_schedule` из графа](../graph-machine-20261109/notes.md), [hosted F — frontend цепочки](../hosted-chain-20261109/notes.md);
порядок фактических — L2 spec (`docs/L2_spec_en.md`: «L2 arguments are evaluated once in the ordinary lexical order»).

## Изменение (src/l2src/l2_frontend_graph.lm2, tools/build.lm2, tests/cdoor/clock_machine.lm2)

1. **Формы `lmx_clock` в граф-пути.** Типы C-двери `c.T` у формалов и результата (`c.uint64_t: start`, результат
   `c.uint64_t`; в L1 — `uint64_t`). Собственные места функции — `T: name [value]` (T — C-скаляр, int с вычисляемым
   значением включительно) и `@: name T [value]`: объявлены на её входе как `l2_q<k>_<name>` с 0 (нумерация — через
   модуль, как у пути P0) и пишутся там, где написаны; имя, уже занятое формалом или местом, отказывает, место типа
   C-двери (`c.T: name`) — тоже (граф-путь ещё не знает, число ли это). Запись формала или места `name: value`.
   `cast:` к C-скаляру, типу двери или ссылке `@: T`. Вызовы C-двери `c.f(...)` и функций модуля (Structure, которую
   обход создал в namespace корня; фактических столько, сколько формалов, иначе отказ). Выражение в скобках —
   неименованный Lmx одного поля — читается как это поле, как ядро вычисляет операнд (`lmx_graph_eval_value`): так
   записан второй фактический `lmx_clock_since`.
2. **Порядок вызовов.** Фактические вызова и операнды операции вычисляются один раз, в лексическом порядке; C оставляет
   оба порядка открытыми (свои операнды упорядочивают только `&&` и `||`). Значение, вычисляемое до более позднего
   вызова того же вызова или операции, сначала держится в собственном локале — `T: l2_t<k> (value)` перед оператором,
   k через функцию, — когда порядок может проявиться: ни одно из двух значений не стабильно и одно из них выполняет
   вызов (`lm_compiler_graph_before`). Стабильны числа, имена двери, формалы и места функции (граф-путь не пишет их
   адресов, и вызов их не меняет) и их операции и приведения. Локал фактического функции модуля имеет тип её формала (C
   всё равно приводит фактический к нему при вызове); иное удерживаемое значение — собственный тип: формал или место,
   `cast:`, вызов функции модуля (результат), сравнение и короткая логика (int), арифметика — тип левого операнда (как
   путь P0 типизирует значение по ведущему имени). Вызов C-двери и чтение поля через путь C-типа в графе не имеют:
   удерживаемые, они отказывают — как путь P0 отказывает такой фактический C-вызова (Verified182). Значение внутри
   правого операнда `&&`/`||` перед оператором не удерживается (оно выполняется, только если левый позволит): отказ.
   Запись через голову-путь читает владельца головы до значения, как левый операнд операции.
3. **Рецепт.** `bld_kernel_l2` переводит `lmx_clock` из графа (`bld_machine_module_from(…, 1, …, "lmx_clock",
   clock_names, 7, 0)`) в каждом runtime, как `lmx_schedule`; комментарии `bld_runtime` и `build_generation` называют
   оба модуля входа из графа.
4. **Свидетель C-двери** `tests/cdoor/clock_machine.lm2` (строка smoke `runs cdoor/clock_machine.lm2 7 nf`): половина
   диапазона size_t — `SIZE_MAX / 2 + 1`; дедлайн 100 прошёл при 100 и 150, не при 99; дедлайн 0 не прошёл на половине и
   прошёл на одну меньше; ожидание `deadline - now` до срока, затем 0; показание часов не идёт назад, время с `now` мало.
   Выход 7, 80… — номер проверки.

## Вывод `lmx_clock` из графа

Вывод граф-пути — 1933 байта, 5af3e1b51cfae0faaae55873054aebfeb712be4f8cf4f39c0aa94116feed7bf8
([целиком](records/pins/opus340-rundir-graph-lmx_clock.lm1)); вывод P0 того же hosted F — 2176 байт, b8e2c8ff7ae8c7ac…
([целиком](records/pins/opus340-rundir-p0-lmx_clock.lm1)). Отличие формы: вызовы функций модуля записаны прямо (у P0 —
временные `l2_t0…`); ни одно значение не удерживается — до вызова в фактических стоят только формалы:

```text
fn: lmx_clock_since (uint64_t: l2_p3_0_start) uint64_t
    return: lmx_clock_elapsed(l2_p3_0_start, (cast: (uint64_t) c.GetTickCount64()))
end: lmx_clock_since

fn: lmx_clock_half () size_t
    size_t: l2_q0_zero 0
    l2_q0_zero: 0U
    return: ((l2_q0_zero - 1U) / 2U) + 1U
end: lmx_clock_half
```

## Проверки

1. **Первые пробы.** Связка fehost04 (T40 `build-frontend-host` от fehost03 на rt66, source38):
   `lmx_schedule` — 89fdc1c2… (= срез 338), `lmx_clock` — отказ «fn lmx_clock_since, statement 1: … binary operations
   and paths: no other operation yet» ([журнал](records/pins/opus340-rundir-probe-clock.log)): второй фактический —
   скобки, неименованный Lmx одного поля. После правила скобок (fehost05) `lmx_clock` переводится
   ([журнал](records/pins/opus340-rundir-probe-clock5.log)); вывод графа и вывод P0 — l1trans и `gcc -std=c99 -O2
   -Wall -Wextra -Werror=…` — 0 ([журнал](records/pins/opus340-rundir-probe-clock-cc.log)).
2. **Порядок вызовов** (связка fehost07, source39; [журнал](records/pins/opus340-rundir-probe-order7.log)). Проба
   [order_probe.lm2](records/pins/opus340-rundir-order_probe.lm2), 10 функций: два фактических с вызовами
   (`l2_t0` — первый), стабильный первый фактический (не удерживается), вложенный вызов (два локала по порядку),
   результат C-двери как фактический функции модуля (локал типа формала, `int`), фактический C-двери (`size_t` из
   `cast:`), операция с вызовами с двух сторон, места с вычисляемым значением, `&&` с вызовами в левом операнде,
   запись через голову-путь с вызовом в значении (владелец стабилен) — выпуск
   ([L1](records/pins/opus340-rundir-order_probe.lm1)) → l1trans → gcc (`-c`, флаги выше) — 0
   ([C](records/pins/opus340-rundir-order_probe.c)). Отказы на месте, вывода не остаётся:
   [поле через путь до вызова](records/pins/opus340-rundir-order_refuse_path.lm2), [удержание в правом операнде
   `&&`](records/pins/opus340-rundir-order_refuse_cond.lm2), [результат C-двери до вызова в вызове
   C-двери](records/pins/opus340-rundir-order_refuse_door.lm2). Вывод `lmx_clock` и `lmx_schedule` fehost07 —
   5af3e1b5… и 89fdc1c2…, те же байты, что до правила.
3. **Runtime связан с выводом графа.** `build-runtime R S B S/fehost07/l2trans.exe rt67` (14:18:23→14:19:21Z): в записи
   шага `lmx_clock` — команда hosted F с `--graph`, `in` b8e2c8ff… (вывод P0 от rt66), `out` 5af3e1b5…; `driver.c` rt67
   отличается от rt66 только в `lmx_clock_since`, `lmx_clock_half`, `lmx_deadline_passed` и `lmx_deadline_wait`
   ([diff](records/pins/opus340-driver-rt66-rt67.diff)), а `driver.o` и `driver-observe.o` rt67 — те же байты, что у
   rt66 (fa5b2855…, 6efcd754…): gcc -O2 даёт из обоих выводов один машинный код.
4. **Значения через C-дверь.** `suite S/tests/smoke.tsv` на rt67 (fehost07) — `SUITE 8 rows, 0 failures`;
   `clock_machine` и `schedule_machine` дают 7 на native и forced, корни 0 и 1
   ([журнал](records/pins/opus340-suite-smoke-rt67.log)). Мутант стадии (`<` → `<=` в `lmx_deadline_passed`,
   [diff](records/pins/opus340-mutant-lmx_clock.diff); rt67m из графа тем же fehost07, `driver.c` отличается от rt67
   одной строкой — [diff](records/pins/opus340-driver-rt67-rt67m.diff)): 4 отказа, `exit 82, expected 7` на native и
   forced, корни 0 и 1 (проверка 82: дедлайн 0 на половине диапазона уже «прошёл»), остальные 7 строк — PASS
   ([журнал](records/pins/opus340-mutant-rt67m.log)); стадия восстановлена копией `lmx_clock.lm2` из репозитория,
   `verify` source39 — 403 файла, 0 отказов ([журнал](records/pins/opus340-restore39.log)).
5. **Сожжённая метка.** fehost06: первая сборка связки с правилом порядка остановилась на переводе
   `l2_frontend_graph.lm2` — «unknown type» в сигнатуре (`@@: void kept`: объявление L2 — имя, затем тип, а `@@: void`
   типа нет; [журнал](records/pins/opus340-build-fehost06.log)). Модуль затем переводился отдельно fehost03 тем же
   рецептом (`--library --machine lm_compiler_graph_main --header …`, CWD = S/src): попытка с `@@: c.Lmx kept` (снова тип
   перед именем) — «incompatible entry signature» (её журнал перезаписан следующей попыткой); с `@@: kept c.Lmx` и
   `@: kn size_t` — L2 0 ([журнал](records/pins/opus340-rundir-fg-probe.log); l1trans этой пробы отказал только потому,
   что заголовок пробы лежал вне корня единицы). Затем собрана связка fehost07.
6. **Цепочка.** fehost03 форм `lmx_clock` не читает, и новый рецепт с ним отказал бы на первой функции; поэтому цепочка
   начата с промежуточного поколения — связки fehost07 (объекты frontend source39 перевёл fehost03, связана с rt66).
   `T40 bootstrap quick R S B S/fehost07/l2trans.exe boot340 S/tests/smoke.tsv` — `BOOTSTRAP quick 0 failures`
   (14:23:22→14:36:14Z; [журнал](records/pins/opus340-bootstrap-quick.log), G2 —
   [журнал](records/cold-graph309-codex01/boot340/g2-build.log)). G1: объекты, runtime и корень frontend переводит
   fehost07, `lmx_schedule` и `lmx_clock` — с `--graph` (в записи runtime G1 шаг `lmx_clock`: `in` 13641521… — вывод
   мутанта rt67m, оставшийся в стадии, `out` 5af3e1b5…); G2 — hosted frontend G1 так же (вывод `lmx_clock` — те же
   байты 5af3e1b5…). Smoke обоих поколений — 8 строк, 0 отказов; `clock_machine` и `schedule_machine` дают 7 на
   native и forced, корни 0 и 1. runtime G1 = runtime G2 = rt67 (`driver.c`, `driver.o`, `driver-observe.o` байт в
   байт); frontend, backend и tool G1 и G2 — одни образы кроме штампа (`exe-same` 1), их `l2trans.lm1/.c`,
   `lmxtool.lm1/.c`, `l2_libc.o`, `launch.txt` — одни байты; fehost07 = frontend и backend G1 кроме штампа
   ([сравнение](records/pins/opus340-compare-g1-g2.log)). Рабочий инструмент boot340/lmxtool.exe = tool G2.

## Кортеж

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; CWD = P/runs/opus340 (hosted F — CWD = S/src).

- P/pins/opus340-source38.sha256, 403 входа: 02eb70fbf38364038acbb4b93d0404bb5b81b11c783edd7e5e0ae6f4fb698f59
  (recipe `lmx_clock` из графа, свидетель, граф-путь до правила скобок); opus340-source39.sha256:
  7e27ca717f865e894840d409a3be18af62f020f6046a084e67211218ffa67ac3 (отличается только `l2_frontend_graph.lm2`,
  ac7d96ea…); opus340-source40.sha256: c2ba096dadfa5bec41408c60f28ff8cf3cf915109f50b2d9e1e6ccb694ec30bf (отличается от
  source39 только комментариями `tools/build.lm2` и `tools/suite.lm2`).
- T40 S/tool40/lmxtool-tool.exe bcf1a3270c08992778bd01710dc9408b00ab7be0d6a74f1a08978ab34ace6d6b (T39 `build-self` с
  fehost03 на rt66, source38).
- S/fehost07: l2trans.exe 3827eadc36fd1200ea54a6346b93c0fa19cd20bf4789a226cad86d3cbb1f8044, l1trans.exe
  c51895c51984768d…, l2_libc.o af9fdae33655f8e6… (= fehost03), launch.txt 52ce29dadaeed2b1…; объекты — fehost03,
  связана с rt66.
- S/rt67/driver.c 3074975fd2b9d6aa8daa19327e6f7bf9cd728f422b534e95e46b6f4f896b1c60; driver.o
  fa5b2855afd0e55fb27f7d2cb836be6e709be9e8006f199024dae3b2aa231123, driver-observe.o
  6efcd754c269fe6c428a66182af49e7f25b22dd68bd826b8228d26f7b5cb3a23 (= rt66 = rt65).
- boot340: связки G1 и G2 — [g1](records/cold-graph309-codex01/boot340/g1/bundle.sha256),
  [g2](records/cold-graph309-codex01/boot340/g2/bundle.sha256); frontend G2 l2trans.exe c7c54a1a7912f1d2…, рабочий
  lmxtool.exe be5b6852d57efeb80b8ee8426169a6a3ce577ad0d65769bcda730f4ae3d9634e (tool G2).

```text
T39 0 entry 0 -- build-self R S B F(fehost03) S/rt66/driver.o tool40
T40 0 entry 0 -- build-frontend-host R S B F(fehost03) S/rt66 fehost04|fehost05|fehost07   (пробы; fehost06 сожжена)
S/fehost07/l2trans.exe 0 entry 0 -- --graph --library --machine lmx_clock_now … SRC convert primitive OUT   (CWD = S/src)
T40 0 entry 0 -- build-runtime R S B S/fehost07/l2trans.exe rt67 | rt67m (мутант)
T40 0 entry 0 -- suite S/tests/smoke.tsv R S B S/fehost07/l2trans.exe S/rt67/driver.o S/smoke340-rt67 S/rt67/driver-observe.o
T40 0 entry 0 -- bootstrap quick R S B S/fehost07/l2trans.exe boot340 S/tests/smoke.tsv
```

Архив: [список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий](records-lf.sha256); docs check и
архивные журналы — [список](records2.list), [SHA](records2.sha256), [SHA LF](records2-lf.sha256).

## Граница и следующее

1. Граф-путь переводит два модуля (`lmx_schedule`, `lmx_clock`); следующие машинные модули ядра — по их формам:
   `sub`, `--header`, циклы, места типа C-двери.
2. Удержание значения в правом операнде `&&`/`||` и удержание значения без C-типа (вызов C-двери, поле через путь)
   отказывают на месте: механизм для первого — условный блок, вычисляющий операцию в локал, для второго — тип,
   который граф-путь получит из объявлений C-двери; ни один модуль ядра их пока не требует.
3. Граф-инструмент (graph77) не пересобирался: его источники не менялись, `checks` не запускался.
4. `bootstrap full` с hosted F не запускался (ПОЗЖЕ).
