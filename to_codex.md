# to_codex.md — передача дел от fable_pc (2026-10-19, ~09:30 по времени машины)

fable_pc остановлен по указанию автора. Единственный слот writer/build освобождён: с этого момента его держит Codex (или тот, кого
назначит автор). Этот файл — вся передача: что закоммичено, что лежит в рабочем дереве незакоммиченным, что проверено, что нет,
где лежат инструменты и как продолжить или откатить. Ничего из перечисленного ниже я больше не трогаю.

## 1. Закоммичено и запушено

- `15131e71` (main, родитель `373fcd4c`) — U7 срез D4 (a–d): `OF_EDGE` (lmx_walk.h 57, COUNT 58) над `NODE(0)`/`SELF`, три переноса
  записи, исправление регрессии среза d (native проецирует ПЕРВЫЙ прыжок, покидающий вхождение — `l2_emit_graph_path(code_edge)`;
  корень пути четырёхчастного `fn` в обходчике — `NODE(0)`, `l2_rw_path_code_root` читает `l2_m_code_rooted`), свидетели :41840 и
  адреса зелёные, двойник V2 исправлен, дефект WALK-MERGE-BODY-PLACE-RAW-INDEX — FIXED в sandbox, MERGE-OPERAND-METHOD-NODE-FIELD —
  зарегистрирован OPEN с двумя красными позитивами. Раздел в `steps/current.md`: «Потребители путей — срез D4». REPLY 9 отправлен
  (msg_id почтальона f75742c5); файл `build/fable_tools_20261017/reply9_review_path_unify_d4.txt`.
- Гейты этих байтов: replay против D3 чистый (214 строк L1, все классифицированы), 10 мутантов достигнуты, ядро `fable_u7d4e_kernel_01`
  305/0 + L3 11 ok, фокус `fable_u7d4f_focus_01` 134/15 (все 15 — известные красные D3), полный `fable_u7d4g_full_01` 3605/1026
  (против D3: 0 регрессий, 2 новых красных позитива, 1 исправлена). Недействительные по среде прогоны переименованы `*_invalid`
  (`fable_u7d4c_full_02`, `fable_u7d4f_full_01`, `fable_u7d4e_full_01_killed`) — не цитировать.

## 2. Ревью Codex по D4 (CODEX-U7D4-READONLY-20261019T120011Z) — открытые пункты

1. **R2 (п. 2)** — два повторных маршрута в одной фазе: (a) голова-путь nullary-Frame актуала callable-формала разрешалась текстовым
   маршрутом и затем снова эмиттером (`l2_cf_actual_emit` → `l2_emit_path`); (b) `l2_emit_fields` освобождал запись всего списка при
   `fail_why = 1` и операндный маршрут читал тот же спан снова (`steps_run`, `names_only`, `walk`). **Исправление лежит в рабочем дереве
   (п. 3), не гейтовано, не закоммичено.**
2. **MERGE-OPERAND-METHOD-NODE-FIELD (п. 3)** — метод ВЫБРАННОГО операнда `merge` читает `node\x` по лексическому слоту (оба движка 2 вместо
   3). Исправлять через владельца/происхождение координаты предка (запись `lmx_implements_register_map(R, source)` — какой источник), не
   исключением для merge/node. Зависимость N4-U U1/U3. Красные позитивы `unit_merge_operand_method_node_field(_walk)` сохранить.
3. **Доказательство копии (п. 4)** — нужен свидетель: действительно копируемый/исполняемый callable с НЕтождественной картой исполнения,
   исходное ребро 0 → физический слот 1; чтение, запись/сосед и обращение через взятый адрес ДО и ПОСЛЕ копии, native + принудительный
   обходчик. Проверка L3 `lmx_walk_output_place_selftest` (копия без записи → тождество) этого не доказывает. Вопрос: переносит ли копия
   (`lmx_graph_copy_owned`, `lmx_copy_carry_records`) карту исполнения результата `merge`; `lmx_merge_owned` использует
   `exec_compose_copy`. Пока OPEN evidence, не норма «копия теряет карту».
4. **Прочие остатки (п. 5)**: владелец координаты предка; независимо отображённое вложенное значение (комментарий l2trans :41895 «every deeper
   frame is OF» — не доказательство); держатель локальной модели в расщеплённом коде (native `self` vs обходчик `NODE(0)`); сырой прыжок в
   часть у `l2_own_from_expr` (четырёхчастный `fn`) против `OWN` обходчика; A/B/C аудита потребителей путей; M2/N4, N3 по плану v3.
   `unit_address_path_actual_span` — свидетельство только native (обойдённого двойника нет: `check` остаётся native под `--walk-methods`).
   Формулировка «решение за автором» для остатка `after`/`fld` в current.md уже заменена на «технический OPEN по плану» (в рабочем дереве).

## 3. Рабочее дерево сейчас (НЕ закоммичено, НЕ гейтовано) — срез R2

`git status`: `M dev/l2src_sandbox/l2trans.lm1` (sha256 `22a0e6366826afbf…`), `M steps/current.md` (одна фраза, п. 2.4 выше),
`M tools/l2_harness.ps1` (одна новая строка после `unit_cf_call_args.lm2`: `unit_cf_actual_path_head.lm2`, eternal-runs, Args @('0'),
Entry 7, WalkRoot), `?? dev/l2src_sandbox/tests/unit_cf_actual_path_head.lm2` (новый свидетель), `?? l2_driver_launch.err` (НЕ трогать,
не коммитить).

Что сделано в `l2trans.lm1` (патч `d4_r2_patch.py`, 7 замен; исходный текст байтов 15131e71 сохранён в
`<S7>/l2trans_d4e_committed.lm1`):
- `l2_cf_actual_rec`: голова из ≥ 2 сегментов → `l2_path_resolve(t\data, t\length, run)` (при `l2_cur_mi = mi`), `cand =
  l2_path_callee_rec(run)`, `out_held = 1` когда `run = out_run`, иначе `l2_path_release`; `out_kind = 1`. Голова из одного сегмента —
  прежний `l2_call_head_method`.
- `l2_cf_actual_emit`: ветвь `ptext`/`l2_emit_path` для FRAME-головы удалена (переменная `ptext` тоже); остался `return:
  l2_tok_method_occ(cand, dest)`.
- `l2_emit_fields`: локальные `pkeep`, `rkept`; при `pstatus = -1 && prun\fail_why = 1` запись НЕ освобождается (`pkeep: 1; pstatus: 2`);
  в операндном маршруте `run: @ run_value` сбрасывается на каждом операнде, при `pkeep` — `run: prun; rstatus: 0; rkept: 1; pkeep: 0`
  (без `l2_path_steps_run`), и условие второго `l2_path_walk` получило `rkept = 0 &&`.

Что проверено: свидетель `unit_cf_actual_path_head` зелёный на байтах 15131e71 и на байтах R2 во всех четырёх режимах пробы (native /
`--walk-methods` × native-root / walkroot 1), L1 побайтно одинаков между байтами (пробы: `<S7>/probe_cfhead/out_d4e`, `out_r2`).
Что НЕ завершено:
- replay корпуса R2 против D4 (`<S7>/replay_r2_variant` против `<S7>/replay_d4e_variant`) — в момент остановки ещё шёл в фоне
  (процесс `replay.sh` продолжит и завершится сам; результат — `<S7>/cmp_r2_variant.txt`; ожидание: `SAME=3573`, чистый рефакторинг).
  Файл `cmp_r2_variant.txt` до завершения содержит СТАРЫЙ результат пустого прогона (`EXIT=3573`) — перечитать после.
- мутанты `cfhead` (запись головы теряет последний шаг имени после классификации; должен сделать свидетель красным — проверить пробой
  на `<S7>/r2_variant_mut_cfhead`, корпусного покрытия нет) и `trace_kept` (достижимость (b): строка `trace: kept` в stderr) — их сборка
  и replay стоят в той же фоновой цепочке после replay (`d4_stage_mutants.sh <S7> r2_variant cfhead trace_kept`, вывод
  `<S7>/r2_stage_mutants.out`); если цепочку снял жнец памяти — повторить команду.
- гейты: `bash <S7>/r2_gates.sh <S7> r2_variant fable_u7r2 4500` (фокус → ядро+L3 → полный + сравнение с D3 и с `fable_u7d4g_full_01`;
  список фокуса в `d4_stage_focus.sh` уже дополнен семейством callable-формалов и строками двери C).
- документы: `<S7>/section_r2.md` (вставить в `steps/current.md` после раздела D4, перед «## Документы и публикация»),
  `<S7>/reply10_r2.txt`, `<S7>/commit_msg_r2.txt` — с плейсхолдерами `{{...}}`; заполнять вручную по статусам (скрипт
  `fill_values_d4.py` специфичен для D4 и для R2 не годится).
- коммит: `bash build/fable_tools_20261017/commit_slice2.sh build/l2_harness/fable_u7r2_full_01.pregate.txt
  build/l2_harness/fable_u7r2_full_01 <msg>` (сверяет хэши каждого пути из git status с pregate полного гейта; документы освобождены);
  затем вписать SHA в REPLY 10 и отправить через почтальона.

Откат, если срез не нужен: `git checkout -- dev/l2src_sandbox/l2trans.lm1 tools/l2_harness.ps1` и удалить
`dev/l2src_sandbox/tests/unit_cf_actual_path_head.lm2`; правку `steps/current.md` (формулировка п. 5 ревью) стоит оставить.

## 4. Где что лежит

- `<S7>` = `C:\Users\mtkra\AppData\Local\Temp\claude\C--Nyasha-Planet-LMX\9e43eb71-b36e-4ef1-88aa-e209883f6c22\scratchpad\u7`
  (сессионный scratchpad fable_pc; при переносе работы скопировать нужное в `build/fable_tools_20261017/`):
  варианты транслятора `d4e_variant` (= байты 15131e71), `r2_variant` (= рабочее дерево), мутанты `d4e_variant_mut_*`; replay'и
  `replay_d3` (373fcd4c), `replay_d4e_variant` (15131e71), сравнения `cmp_*.txt`, классификация `pure_*.txt` (`classify_diff.py`),
  перепись держателей `census_*.txt` (`census.py`); патчи `d4_kernel_patch.py`, `d4_carry_patch.py`, `d4b/d4c/d4d_patch.py`,
  `d4_r2_patch.py`; мутанты `mutate_d4.py` (edge, self, callee, addr, cf, carry1, trace_carry1, nhop, nhop_self, fnroot, cfhead,
  trace_kept); стадии `d4_stage_replay.sh`, `d4_stage_mutants.sh`, `d4_stage_focus.sh`, `d4_stage_full.sh`, `d4g_full.sh`,
  `r2_gates.sh`, `with_mem.sh`; пробы `probe_run.sh`-штампы `d4d_pstamp`, `pstamp_d4e`, `pstamp_r2` (заголовки ядра D4 +
  соответствующий `l2trans.exe`), `exp_run.sh` (собрать и запустить один готовый L1 против штампа гейта); журнал стадий `d4_chain.log`.
- `build/fable_tools_20261017/`: `vbuild2.sh`, `vbuild.sh`, `replay.sh`, `cmp_replay.py`, `run_focus.sh`, `run_kernel_l3.sh`,
  `run_full_gate.sh`, `compare_gate.py`, `commit_slice2.sh`, `probe_run.sh`, `rows_u7.txt`, тексты отправленных сообщений
  (`status_d4_slice_d_20261019.txt`, `reply9_review_path_unify_d4.txt`).
- Гейты: `build/l2_harness/fable_u7d3_full_01` (база D3), `fable_u7d4f_focus_01`, `fable_u7d4g_full_01` (валидный полный D4),
  `build/l2src/fable_u7d4e_kernel_01` + `build/l3/fable_u7d4e_kernel_01.log`.

## 5. Среда и протокол (измерено)

- Машина: 15,4 ГиБ RAM, лимит commit ≈ 18 ГиБ, из них ~12,5 ГиБ занято другими приложениями в простое. Полный L2 gate в одиночку
  проходит (минимумы в валидном прогоне: 3693 МиБ физической, 3149 МиБ commit свободно); два тяжёлых конвейера одновременно
  исчерпывают commit — дети падают с `0xC0000142`, гейт выглядит как тысячи «l2trans produced no L1» (недействителен по среде, а не
  регрессия). Перед тяжёлой стадией — проверка `Win32_Process` (gcc/cc1/l2trans/l1trans/`l2_harness.ps1`/`run_full_gate.sh`), исключая
  собственную команду запуска (её командная строка содержит те же слова — ложное «занято»).
- Жнец памяти Claude Code убивает только оболочку фоновой задачи; конвейер доживает как сирота — не перезапускать, читать его статус
  потом; снимать дерево только `taskkill //PID <корень> //T //F` после проверки командной строки.
- Replay корпуса ведётся на штампе `fable_u6_full_02`: 696 OK-строк полного гейта он не транслирует (слепое пятно) — их покрывают
  только гейты.
- Почтальон: `lmx_uds` (сессия [74a3ec]); команда доставки: `Get-Content -Raw "<abs file>" | python claude_chat\codex_inbound.py send
  --sender <имя> --request-id <ID>`; ACK — не ответ; технические разъяснения автора архивировать дословно в `LMX_blog/2026-10-18.md`
  по правилам READ.ME; настройки машины и чужие процессы не трогать.
- Авторская директива по OF_EDGE (CODEX-AUTHOR-OF-EDGE-GENERAL-20261019T064748Z) заархивирована дословно; её условие («проекция общая для
  всех путей, физические адреса не отображать повторно») — критерий для оставшихся срезов.
