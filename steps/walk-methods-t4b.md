# T4b: widening the walkable subset of method bodies, one class at a time (Opus)

Ticket: fable's answer, `steps/tickets-20260925.md` §9 («затем T4b»); `opus_next.md` queue 1;
`steps/merge-parts-193.md` §9 (T4a).  Branch `claude/continue-opus-next-doc-rvjocj`, base main `adfa690`.

## k.1 The measure (main `adfa690`)

A private l2trans that prints why `l2_rw_may` refuses a method, run with `--walk-methods` over the
tracked `dev/l2src_sandbox/tests/*.lm2`.  Count = fixtures in which the reason occurs (each reason
once per fixture):

| Reason (`l2_rw_may`) | Fixtures |
|---|---|
| walkable (frames emitted) | 130 |
| throws (declared or implicit, the throw channel) | 51 |
| a formal that is not a number | 25 |
| a result that is not a number | 15 |
| a Structure formal (`T: m`, and since D-76 `@: T m`) | 14 |
| formal binding (an own field named like a formal) | 14 |
| an own field declared in a nested body | 10 |
| dynamic inputs | 6 |
| a callable formal | 5 |

Body refusals (the builder's own «root operation not walkable yet: …» under quiet tries) come after
these shape refusals and are measured per class as it opens.

## Order (one class per step, each with the differential run)

1. **Structure formals.**  A Structure formal j is ARG j, the reference the caller passed; `m\x` is
   OF(ARG j, slot of x in T) as a path root of its own (the D-76 formal root, walked), a write is
   PUT_OF.  The caller passes the Structure as its actual (`l2_rw_struct_arg`).  Rows: the 14
   fixtures' methods under the knob.
2. **Formal binding** (own field named like a formal, -189 c3b-2): the formal's first store binds its
   own field; in the walk a PUT of ARG j into the own slot at the binding line, then the own field.
3. **Own fields in nested bodies** (a hosted own field).
4. Throws and callable formals wait for CATCH (-201) and the callable parts (T5).

Each step: the knob-on differential run over every eternal-runs row (the rows' facts must hold
walked), the corpus diff (knob off: no output change; knob on: only the class's methods gain frames),
a mutant per rule, RESULT, merge into main.

## Посадка Grok, класс 1 — Structure-формал

База main `b5e72d7`. Ветка `grok/walk-methods-t4b`. Ядро не меняется: ARG уже отдаёт ссылку вызывающего (`lmx_walk.lm1`, арм `LMX_WALK_OP_ARG`), OF читает поле Structure, PUT_OF пишет через вычисленный держатель. Вызов с корня уже передаёт Structure через `l2_rw_struct_arg`.

Форма:

- `l2_rw_may`: формал с `l2_nsty_get >= 0` больше не отказывает метод. Callable (`l2_cf_get`) и прочий не-числовой формал по-прежнему вне подмножества.
- Корень пути `path[0] = 6`: имя — Structure-формал метода, который сейчас строится (`l2_formal_find` раньше named Structure и метода: формал прячет одноимённое поле и одноимённый тип). `path[1]` — индекс формала, `path[5] = 1`.
- Уровень 0 этого корня — `[arg, j]`, не DEREF. `m\x` — OF этого ARG на слот `x` в T. Запись — PUT_OF, потому что `path[5] = 1`.
- `@: T m` — тот же `l2_nsty_get`, что и `T: m` (D-76). Отдельной формы нет.

Вне класса, метод остаётся без кадров: throws, formal-binding, own-поле во вложенном теле, callable-формал, формал не число и не Structure, результат не число. Передача Structure-формала дальше как фактического аргумента из тела метода: `l2_rw_struct_arg` по-прежнему ждёт имя поля, такое тело кадров не получает.

Свидетель `unit_walk_struct_formal` (WalkMethods, Entry 7): `sum` читает два формала (3+4), `poke` пишет 9 через формал, `peek` читает 9. Инверсия Entry 0 красная.

Мутанты, с откатом: (а) `l2_rw_may` снова отвергает `nsty >= 0` — у трёх методов остаётся native, строка RED; (б) корень пути формала не строится — тихий отказ «a field path», кадров нет, строка RED; (в) ARG `j + 1` на корне 6 — `sum` не даёт 7; (г) слот PUT_OF у корня 6 сдвинут на 1 — `left\value` остаётся 3, Entry не 7.

## RESULT класса 1

База main `b5e72d7`. Ядро не менялось. Twin `l2src/l2trans.lm1` — копия песочницы.

Свидетель под `--walk-methods`: Entry 7, exit 0. Инверсия `entry 0`: драйвер «exit 7, expected 0», exit 1. Без ручки native трёх методов на месте, кадры ARG те же.

| Что мутировано | Что стало |
| --- | --- |
| `l2_rw_may` снова отвергает `nsty >= 0` | native трёх методов есть, ARG 0; прогон exit 0 (идёт нативный путь). Строка RED: Absent native и Debt ARG |
| корень `path[0] = 6` не строится (`if: 0 = 1`) | то же: native 3, ARG 0, exit 0. Строка RED по пинам |
| ARG на корне 6 пишет `j + 1` | `lmx: walk error: INVALID`, exit 3, не Entry 7 |
| слот первого имени корня 6 сдвинут на 1 | `lmx: walk error: INVALID`, exit 3, не Entry 7 |

Мутации откатены. Повтор зелёного свидетеля: exit 0.

Дифф-прогон: каждая из 215 строк harness, у которой есть прогон, переведена с `--walk-methods` и прогнана с тем же `entry`. 215/215, fail 0. Отдельно до этого: `unit_root_putof`, `unit_local_model_arg`, `unit_field_path_formal`, `unit_ref_formal_path` под ручкой держат свои Entry.

Гейт: build 279/279 (`build/l2src/20260925_131603`), harness 399/399 (`build/l2_harness/20260925_131837`), L3 11/11, check_docs OK, `git diff --check` чисто.

Вне класса: throws, formal-binding, own-поле во вложенном теле, callable-формал, формал не число и не Structure, передача Structure-формала дальше как фактического из тела метода (`l2_rw_struct_arg` ждёт имя поля). Класс 2 — после остатка REVIEW b5e72d7.
