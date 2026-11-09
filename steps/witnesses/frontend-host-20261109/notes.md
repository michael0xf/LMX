# Frontend на runtime: маршрут 331, шаг 1 — 2026-11-09

Исполнитель: opus. Основание — маршрут Codex CODEX-OPUS-331-ROUTE-REPLY-20261109T050844Z-01 и ответ на результат 331
CODEX-OPUS-331-REVIEW-REPLY-20261109T052831Z-01 (п. 1: «обычный языковой корень tools/l2trans.lm2 с явным runtime,
существующие frontend-модули и CLI, без отдельного compiler и без нового ручного C main… Сначала проверь сохранность CLI
на старом P0 lowering, затем тот же F переводит lmx_schedule через чистый граф, без Lmx->P0 адаптера»); kernel §11 п. 3;
план — [next_core_tasks_v3.md](../../../next_core_tasks_v3.md). Режим работы — [steps/current.md](../../current.md).

## Изменение

1. **Агрегат модулей frontend — один текст L3.** `decl_l2_frontend_aggregate` (tools/build.lm2) печатает прежние
   predef/import собственного корня frontend; `decl_l2_frontend_root` (вид 56) — комментарий, агрегат и тонкий C `main`,
   как раньше (`frontend-source.lm1` сборки feplain01 совпал с fe309a байт в байт, cbf343676f3e45b7…);
   `decl_l2_frontend_host` (новый вид 60) — тот же агрегат без `main`: `src/l2src/l2_frontend_host.lm1`.
2. **Корень frontend на runtime.** `tools/l2trans.lm2` — обычный языковой корень, как `tools/graph_trans.lm2`:
   `mainArgs` (argv[0] — собственный, затем слова после `--`) в argv и `lm_compiler_cli_main(n, argv)`, выход — его
   ответ. Алгоритмы frontend остаются его машинными модулями L2.
3. **Рецепт.** `bld_frontend_host` / команда `build-frontend-host REPO STAGE BASE FRONTEND RUNTIME-DIR LABEL`: модули P0 и
   frontend переводит FRONTEND (`bld_p0_l2_selected`, как собственная сборка frontend), L3 пишет агрегат (вид 60),
   заголовки C, корень строит FRONTEND и связывает с `RUNTIME-DIR/driver.o` (`-O2 -fno-strict-aliasing`):
   `LABEL/l2trans-host.exe`. Запуск — `l2trans-host.exe 0 entry 0 -- ARGS`; CWD — `src` стадии (пути predef
   относительны CWD, как у обычного F).

## Проверка сохранности CLI на пути P0

CWD = S/src; FRONTEND (seed) = P/cold-graph309/fe309a/l2trans.exe; HOST = S/fehost01/l2trans-host.exe; одни и те же
аргументы, выход в P/runs/opus336/cmp-fehost01:

| Вход | Аргументы | seed = host |
|---|---|---|
| src/l2src/lmx_schedule.lm2 | `--library --machine lmx_schedule_init … _state … convert.lm2 primitive.lm2 OUT` | да, 2169 байт (e35b43a2763eb83a…, тот же L1, что выпустил build-runtime rt62) |
| src/l2src/lmx_graph_run.lm2 | `--library` и 39 `--machine`, `--header H …` | да при одном пути H (b6ebfa9b51f8e4e6…); с разными путями различается только строка `predef: "H"`; заголовок совпал (11e85bc6d48d7a4d…) |
| tools/graph_trans.lm2 | программа, `… convert.lm2 primitive.lm2 OUT` | да, 212208 байт (c27bf24d41b92fb7…) |

Время: seed и host — 0–2 с на каждый вход. Журналы — `records/pins/opus336-rundir-cmp-*.log`.

Прочее: `checks opus336-graph-check74.tsv` на tool35 (rt62/graph73 без изменений) — `CHECKS 81 lines, 0 failed`, 243 PASS.

## Кортеж

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe (b1851f7b56e568088e3e71fdf3b8676de7e01d86481b8c43efe268309778166f);
CWD = P/runs/opus336.

- P/pins/opus336-source30.sha256, 397 входов: 3bd14e8d8c7ff3520e1fc4fd3af5191e60a951d9926b053975b8c8514af6c445.
- T35 = S/tool35/lmxtool-tool.exe: 2ebe452a6a62001bbc9b5ba27782932ec736082fa90a9ca23c1ddd86f4a7300f (T34 build-self на
  rt62/driver.o, 11:28:44→11:29:26Z).
- S/fehost01/l2trans-host.exe: b7430a85b27c01d7b9f82a3c9be6f951c6af81f3be8e86433afc2f4c0dbf8bcf (11:29:34→11:33:42Z);
  агрегат src/l2src/l2_frontend_host.lm1 913fdaa43dc91f7842884162076b0b215d5a93e5073b8da11ae752a172101998.
- S/feplain01/l2trans.exe: 7099bd5d76a5278213ebbfd9725fc997cb31e8b73d8b3016b43b7b6f4743276c (обычная сборка tool35,
  11:35:24→11:39:19Z; frontend-source.lm1 = fe309a).
- rt62 driver.o 7ac7f399b5b6b01cedca7213f61b05c2de8186a06cbf3a6e976faf99b5afccdb (срез 335).

```text
T34 0 entry 0 -- build-self R S B F S/rt62/driver.o tool35
T35 0 entry 0 -- build-frontend-host R S B F S/rt62 fehost01
T35 0 entry 0 -- build-frontend R S B F feplain01
F ARGS OUT-seed ; S/fehost01/l2trans-host.exe 0 entry 0 -- ARGS OUT-host ; cmp OUT-seed OUT-host    (CWD = S/src)
T35 0 entry 0 -- checks P/pins/opus336-graph-check74.tsv
```

Архив: [список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий](records-lf.sha256); docs check и
архивные журналы — [список](records2.list), [SHA](records2.sha256), [SHA LF](records2-lf.sha256).

## Граница и следующее

1. Рецепты сборки (bld_machine_module, bld_program_k, bld_kernel_l2) по-прежнему вызывают обычный F; hosted F пока
   запускается явно.
2. Драйвер hosted F, как у любой программы на runtime, создаёт защищённый файл журнала запуска в своём CWD (`src`
   стадии); его не читать и не перечислять.
3. Шаг 2: hosted F строит чистый граф машинного модуля (общий построитель, как у graph_trans) и выпускает машинные
   функции `lmx_schedule` из графа, затем свидетель C-двери init/wait/tick/state (tests/cdoor).
