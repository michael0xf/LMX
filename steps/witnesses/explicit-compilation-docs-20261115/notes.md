# Документация: массивы, явная компиляция и endturn

Пакет Codex от 2026-11-15 меняет нормы и план, не реализацию ядра. M13/M14 остаются OPEN.
Чужой кодовый WIP403, его тесты/manifest/current и связанный блок основного плана не присваиваются
этому документальному срезу. Дословные уточнения автора — в
[журнале](../../../LMX_blog/2026-11-15-explicit-compilation.md).

Обновлены источник семантики и RU/EN, источник грамматики и RU/EN, L1/L2, спецификация ядра,
руководство, заметки реализации, проект mutating API, CORE, инструкции, ТЗ descriptor,
to_sol, основной v3 и его чеклист. Исторические code receipts не переписаны.
Прежнее ограничение снимка C-функцией помечено отменённым в журнале обсуждения.

Цель: сырой L2 offset и одна L3-проверка линейного индекса; L3-ссылка на дескриптор Array + index;
общие переменные массивы, трёхпольный Lmx, capacity в арене; native-дескрипторы в таблицах call
той же арены, прямые известные C-вызовы; явная compile-цепочка, удаление отслеживания правок,
endturn через finally. ToLmx выбранного L3 Thread сохраняет все таблицы его арены, не только R0.
Восстановление готовых бинарников после перезапуска не требует трансляции программы заново.

Использован принятый G2 Tool402:
build2/codex_fix250generationchain01/sol-m14-index-01/boot-m14-index-01/g2/tool/lmxtool-tool.exe.
SHA256: e81ecdcb7ec543aadbabc1234ae5818142154cd5021e7506a7485cfd766a8a92.
Общий pipeline.lock не изменялся. Частные CWD и журналы:
build2/codex_fix250generationchain01/docs-explicit-compilation-20261115-01/.

- render-semantics: FAIL phase5/chapter3/kind7 — оставшийся RU-абзац о фиксированных полях
  расходился с новой EN-ссылкой на переменные массивы. Исправлена норма, проверка не ослаблялась.
- render-semantics-02: PASS, 35 парных глав, 14 implements cases, оба verbatim snapshots, exit0.
- render-grammar: PASS, 27 парных разделов, 47 source excerpts, exit0.
- check: FAIL на line-endings launcher: каталог PRIVATE_OUT ещё не создан, checker не смог
  открыть docs-eol.stdout/stderr. До этого семантика/грамматика/opening/imports/links прошли.
  Это ошибка подготовки запуска, не установленное нарушение LF в исходниках.
- check-02: остановлен собственный docs-check после обнаружения параллельного bootstrap Sol;
  его результат не используется как gate. Чужой bootstrap не прерывался.

Sol read-only audit после handoff нашёл один оставшийся действующий пункт M11.8 основного v3,
требовавший code snapshot/invalidation. Он согласован с M14: прямые известные C-вызовы,
явная компиляция/endturn, без обязательного code snapshot и автоматической инвалидизации.
Нормативные источники semantics-book/grammar.json после успешных render этим не менялись.
Fresh docs-check и document-only index gate выполняются Sol после завершения общего bootstrap.

После terminal whole01 (BOOTSTRAP quick 0 failures) Sol проверил явный документальный индекс30
штатным actual G2 Tool403, SHA256
`3f7572978d61f7d3c53bf455901182c51de9e4751be0040eee2fdbd982547c43`.
Журнал: build2/codex_fix250generationchain01/runs/sol-m14-field-values-20261115-01/docs-index01.log;
новые CWD docs-index01-cwd и PRIVATE_OUT docs-index01-private созданы до запуска.
PASS exit0: 35 paired semantic chapters,14 implements cases,both snapshots;
27 paired grammar sections,44 verbatim excerpts,615 imported files,links/opening;
LF28299 tracked files в индексе. Render semantics35/14 и grammar27/47 выше не повторялись:
нормативные источники после них не менялись, полный checker подтвердил соответствие.
Working и cached git diff --check PASS. Код/manifest/tests403, его current/receipt и два прежних
чужих untracked не включены в документальный индекс. Их SHA сохранены.

Изменённые механизмы не реализовывались и не проверялись кодовыми тестами в этом пакете.
Широкие runtime/bootstrap-прогоны не подменяют документальную проверку.
