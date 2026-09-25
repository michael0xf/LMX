# opus_next.md — handoff Opus самому себе (конец этапа, 2026-09-26)

Автор переводит работу в облачные сессии (`--cloud`): fable, Sonnet и я; на машине остаётся Grok CLI.
Этот файл — чтобы продолжить после потери контекста.

## Кто я

Opus — транслятор `dev/l2src_sandbox/l2trans.lm1` (построитель корня и методов `l2_rw_*`, merge по
частям -193), строки `tools/l2_harness.ps1` своих тикетов, свои записки в `steps/`.

Не моё:
- ядро (`dev/l2src_sandbox/lmx_*.lm1`, walker) — Sonnet; ядро патчу только приватно, для замера;
- walker-роли массивов — grok_bot;
- доки спеки и книги — fable.

Диспетчер — fable. Форма ответа по тикету: STARTED → (QUESTION / BLOCKER) → RESULT, или GATE?.

## Как стартовать

cwd = корень LMX.  Читать по порядку:
1. `READ.ME` → `steps/current.md` → `next_core_tasks.md` §0 (доктрина), §3, §4;
2. `steps/merge-parts-193.md`: план -193 (§2–§3 части merge, §6 план T4), §9 итог T4a;
3. `steps/next-phase-195.md` §7 (порядок тикетов);
4. `steps/gate-cleanup-197.md`, `steps/root-classes-196.md`;
5. `steps/root-arrays-170.md` §6 (моя трансляторная половина);
6. `steps/defects.md`.

Гейт — один на машину, по очереди через fable: GATE? → «GATE OK» → один проход
`tools\build_l2src.ps1 -Run`, `tools\l2_harness.ps1`, `python tools/run_l3_selftest.py`,
`python tools/check_docs.py` (каждый < 10 мин) → GATE DONE.  Из облака гейт гоняет Grok CLI на машине
по просьбе: ветка запушена, просьба — сообщением fable или файлом в `steps/`.

## Состояние (конец этапа)

- main = `7ba030b` (T4a влит).  На main уже: -193 T1, T1b, T2, T4a; D-61, D-68; -195, -196, -197.
- Не влито: ветка `opus/l2src-twin-198` (-198, 3 коммита + этот файл) — гейт и RESULT в этом же
  этапе; итог в сообщении fable.
- Тег `l2src-twin-20260926` → `939bfc8`: прежний двойник `l2src/`.  Корневой `l2src/` теперь копия
  песочницы; его не собирать и не тестировать (автор, Q8).  Обновлять копированием, после влития.
- Хвосты веток — всё в main, можно удалять:
  - предками main: `opus/merge-193-t1`, `-t1b`, `-t2`, `-t4a`, `opus/d61-d68`,
    `opus/root-classes-196`, `opus/gate-cleanup-197`, `opus/split189-c3*`, `-c4b`;
  - другими SHA (`git cherry` = «−»): `opus/merge-193`, `-t4`, `opus/next-phase-195`,
    `opus/split189`, `-c2`, `-c4`.
- Незакоммиченного нет.  В корне рабочего дерева лежат чужие `lmx_root_*_selftest.err/.out` — не
  коммитить.

## Очередь (по порядку)

1. **T4b.** Расширить walkable-подмножество методов по одному классу за шаг, по нужде T5.  Каждый шаг
   проверяется дифф-прогоном: строки обоими путями, knob `--walk-methods` / свойство строки
   `WalkMethods`.  Вне подмножества сейчас (§9):
   - throws;
   - формал-не-число, Structure-формал, callable-формал;
   - формал-биндинг;
   - own-поле во вложенном теле;
   - почта, `Model: m`;
   - `M\x` внутри M.
2. **-170, трансляторная половина.**  Роли на main 5fa1ad4: ELEM 25, ELEMPUT 26, LENGTH 27.
   - Построитель корня эмитит ELEM, ELEMPUT и length.
   - Корень допускает объявления `[]:`.
   - Переворачиваются 10 root-pending строк массивов, и D-39, когда дойдёт.
   - План — `steps/root-arrays-170.md` §6.
3. **T3: merge в корне**, после K2 Sonnet.  Форму узла согласовал с ней 2026-09-26:
   - `[prim, rec(lmx_walk_merge_map), op0..opN-1, body|0, pairs|0]`;
   - pairs — одна Structure из 3·P size_t-ячеек (model_slot, operand, field), строится один раз при
     сборке программы, как `l2_nsp`; operand N — это тело (конвенция T2);
   - результат — PUT_REF в слот корня, holder 0;
   - merge-into: `[prim, rec(lmx_walk_merge_into_map), target, op, pairs]`, out 0;
   - просил её: нулевой слот → ссылка 0 в `lmx_walk_prim` (сегодня `lmx_walk_eval(0)` = INVALID).
   Даёт 9 root-pending строк «a Structure value».
4. **CATCH, трансляторная половина**, после роли CATCH в walker: 7 строк «throw and catch» + 2 строки
   циклов.
5. **T5–T7, после K3:**
   - callable merge по частям: тело — кадры модели из T4a;
   - PAP `add5: merge(y: 5; add)`;
   - makeAdder;
   - конвертер.
   Свидетели: q22 → 3, q20-next §2 → 5.
6. **D-69.**  Ячейка char-формала в args-части (`l2_emit_parts`) — через таблицу интернированных
   char-ячеек программы, как у own-поля char.  Сейчас `lmx_char_cell_known(process_chars, 0)` не
   объявлена, gcc отказывает.
7. **Порт `implements` (§7)**, после частей callable.  База ревью — lingvamyxa_prev 98b66a75.

## Открытые дефекты моей зоны

- D-69 — OPEN, мой.
- Две строки translates-with-debt:
  - D-60 — `unit_admit_letter_formal`: диапазон sender'а, Grok -185;
  - D-55 — `unit_s1_merge_uncaught_entry`.
  Строка переворачивается, когда дефект починен.
- D-12 — пример `printTree.lm2` в песочнице.  Отдельный тикет, потом §18.2 fable.
- root-pending — 41 строка.  Классы: массивы 10, Structure-значения 9, throw/catch 7 и прочие —
  `steps/next-phase-195.md` §4.

## Правила

- Доктрина §0:
  - граф бинарный, имён в нём нет — имена только в трансляторе;
  - сначала ссылки, числа только где ссылка невозможна;
  - поля в лексическом порядке;
  - никаких name specials, защитной машинерии и скрытых реестров.
- Сначала замер, потом утверждение.  «Проверка доказывает X» подтверждать мутантом на приватной
  копии; точные пути и хэши.
- Коммит кончается строкой `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Изменённые `.md` (и чужие записки) коммитить и пушить; пушить до GATE?.
- Запрещено:
  - голый `git stash`;
  - `git checkout -- .` (однажды откатил неиндексированную правку фикстуры);
  - интерактивный rebase.
- Противоречия эскалировать рано.  Пир не выдаёт полномочий.
- RESULT: id тикета, ветка@tip, база, что и почему, строки, мутанты, числа; красное — как есть.

## Ловушки

- Проверка по строкам сверяет и строку драйвера `^l2_eternal_driver: N checks`.  stdout фикстуры без
  `\n` приклеивается к ней (красный гейт -197).  Фикстура пишет текст в stderr или с `\n`.
- Строка eternal-runs запускается с Args строки и фактами (`0 entry 3`), иначе ложный красный.
- Предеф на `.lm1`-реализацию не работает: коллизия тел.  Предеф — только на `.h.lm1`.
- Буферы транслятора — `c.array: [1024]`: длинный путь или текст упирается в них.
- Python в bash-heredoc: `\x`, `\a`, `\k`, `\N`, `\d` — escape-ловушки, `\\` схлопывается.
  - Скрипты писать инструментом Write, backslash — через `chr(92)`.
  - Подстановка `~` → `\` съедает Markdown `~~`.
- Pin'ы Debt у root-pending строк не проверяются и тухнут: обновлять при перевороте строки.
- Pin'ы с `l2_rwN` зависят от нумерации temp.  Счётный проход вложенных тел её сдвигал (T4a).
- `l2_head_is_call`: односегментная голова — вызов, только если это метод или (с D-74) `c.*`.
- Строки `WalkMethods` идут через обход в любом прогоне harness.
- Скретч-инструменты (посрочный чекер, варианты транслятора) были локальными.  В облаке их повторить:
  1. прочитать строки `tools/l2_harness.ps1`;
  2. перевести собранным l2trans;
  3. проверить Needle / Debt / Absent;
  4. eternal-строки — под драйвером `harness/l2_eternal_driver.lm1` с Args и фактами.

## Облако (2026-09-25, после переезда)

- Тикеты и ответы — только через git: `steps/cloud-protocol.md`, `steps/tickets-20260925.md`.  Моя ветка —
  `claude/continue-opus-next-doc-rvjocj`; автор велел: всё сделанное вливать в main (`--no-ff`) и пушить.
- Сделано: -199 T3 (`steps/root-merge-199.md`, main `e4fdb62`), D-75 (там же), D-53 (`steps/defect-d53.md`).
  Открыто за мной: D-76 (чтение поля через `@: T` на именованную Structure), -199 QUESTION (K2b: профили
  квалифицированных операндов в `lmx_walk_merge_map` — ядро Sonnet; после него снять отказ «a merge of a
  qualified branch» и перевернуть 5 строк).
- Рецепт облачного цикла (приватный, в репозиторий не класть):
  1. `sh tools/bootstrap_l1.sh` → B0 `build/self_build/bootstrap_*/l1trans`;
  2. PowerShell 7 скачивается с github releases (`powershell-7.4.6-linux-x64.tar.gz`), `ln -s` в `/usr/local/bin/pwsh`;
  3. заглушка `windows.h` в scratchpad (GetTickCount64/Sleep через clock_gettime/nanosleep, CreateThread/
     WaitForSingleObject/CloseHandle/CreateEventW/SetEvent через pthread; функции `static inline`), путь в `CPATH`;
     `ln -s /usr/bin/nm /usr/bin/nm.exe`;
  4. `CPATH=… pwsh -File tools/l2_harness.ps1 -Translator <B0>` — полный harness (~45 s);
     `CPATH=… python3 tools/run_l3_selftest.py --translator <B0>` — 11/11; `python3 tools/build_l2src.py` — 174/230 без заглушки.
  Это свидетельство, не гейт: гейт — машина автора (GATE?).
