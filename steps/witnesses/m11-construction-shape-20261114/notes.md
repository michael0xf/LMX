# M11.7: source-known call-shape до исполнения

2026-11-14, Codex. База386 `713af7183aad7009ac549ef59a3b3607171655a7` принята и отправлена.
Исходники и коммит — основное дерево `main`; отдельного Git worktree нет. Один последовательный producer.
Ограниченная кодовая приёмка387, docs-check01 и final index-check02 пройдены; далее commit/push main.
Первичный отказ старой known_assignment разобран и устранён миграцией теста по норме публикации, без правок ядра.

## Изменение

Graph73 объединяет declaration name/default-presence в одном узком receiving view.
Presence0/1/-1 означает отсутствие, наличие или неизвестную роль default, без его вычисления.
Числовой null0 отличается от WORD `0`; qualifiers наследуют presence, Array остаётся unknown.
Run54 использует общий binder в pure/runtime режимах: runtime result/default guards до actuals сохранены.
Builder вызывает preflight после заполнения всех полей. Проход читает существующие CodeBody,
namespace, карты формалов и очереди; он не создаёт activation, не вычисляет actual/default/test,
не запускает DATA и закрывает свой временный namespace. Более приоритетные formal/DATA/pending
и внешние FREE bindings не заменяются предположительным lexical target.

Обычный named Frame в CODE — применение, поэтому не скрывает written F внешнего CodeBody.
Expression/path-head сохраняет инертную written actual-группу. For condition исключается только
у точного header holder, а не у второго поля любого BODY. Эти три исправления получены ревью кода.
GraphTool `check FILE` использует тот же loader/build с runs0; отдельного проверяющего парсера нет.

## Ранние измерения и границы

На seed386 unknown/duplicate/missing/order в `if:0` строились и исполнялись успешно.
Новый Graph02 даёт build5; nested-local и required WORD0 тоже build5.
Controls дают positional7/named7/whole9/effects0. Inert/default/nonint/FREE/path-group сохранены.
Широкие default/qualified/null-ref/char-whole metadata проходят check0/effects0.
Char-whole runtime3 одинаков у seed386 и Graph02; это прежний предел исполнения, не его реализация.
Indirect non-int result guard даёт runtime5/effects0/before1/after0 на обеих версиях.
Общий formal/data/pending probe проходит construction, но даёт runtime5 на обеих версиях;
он не подтверждает ожидавшийся result7. Старый Graph02 пропускал for BODY local F во втором поле;
regression fixture добавлена вместе с exact-header исправлением.

Bridge Tool01 SHA6d048bec881b0899b9c459b943f00b211b804e849a999b08a0a00487a76423c3.
Runtime01/02 не прошли C-field actual typing; оба явных cast исправлены. Runtime03
SHAb4688358037c6aa81d8effc4e80dcf484fd23692063c475c0799a13786bebd21 прошёл.
Graph02 SHAaa29a2b339244d5e7670ce86e7ab7d2c0a6b718e211509904afb73be0be82c7e прошёл.
Этот private runtime предшествует exact-header исправлению; итоговый код проверяется whole G1/G2.

## Сборка

Frozen Source06 содержит843 maintained inputs: добавлены12 источников и5 expected.
Verify/stage-copy прошли. Новый каталог артефактов — `P/sol-m11-construction-fresh01`;
до bootstrap `src/l2src/lmx_graph_run.h.lm1` и `headers/l2src/lmx_graph_run.lm1.h` отсутствовали.
Новый G0 Tool исполняет прежние producer-блоки в порядке runtime → frontend objects → link.
Этот же build_generation должен реально исполняться самим G1 Tool для G2.
Не используются stale Run headers или новый bootstrap/header-generator CLI.

Frozen [Source06](source06.sha256) SHA-256:
19dbb3ff5cc94e2c75ea34ce1b0534528babe3495171988d7c2fbf7f400bebde.
[Whole quick](bootstrap01.log) прошёл: настоящие G1/G2 по9 smoke.
[G2 build](bootstrap-g2-build.log) выполнен самим G1 Tool, а не повторным ручным G0.
[Fixedpoint13](fixedpoint01.log) сравнил frontend/tool L1/C, оба runtime objects, retained Run header,
нормализованные executables, backend, frozen manifest и verify843: PASS.
Штатный [G2 Graph](g2-build01.log) SHA-256:
d816ba5c2e71006183d9d9f7f99750487f5dc992b899f7426e7c939a9a2d95f6.
G2 driver.o SHA-256:
ff20e0647b81bee07eb81145bc132f2cd30f402dfacc2eb18fedd30172fc74e9.

[Первичный целевой прогон](g2-01.log) содержит22 строки:21 прошла в interp/native/forced, одна legacy-проба отказала.
Все11 новых исполняемых fixture прошли triple, включая7 build5 до emission; for BODY теперь build5.
Двенадцатая новая fixture — [широкая metadata check](g2-presence-check01.log), без исполнения;
[сравнение AFTER](g2-presence-same01.log) PASS, effects0. [Masks check](g2-masks-check01.log) тоже PASS.
Пять старых named-shape отказов теперь build5; formal_declarations, deferred_binding_priority,
computed_data_named, admission values/snapshot сохранили полные AFTER.
[Три negative AFTER](g2-after01.log) для indirect runtime guard прошли на готовых binaries.

## Миграция legacy-пробы и финальный frozen input

known_assignment использует старый formal `Box: target`; seed386 даёт [runtime5](baseline-known-assignment.log),
новый pass — build5. В ignored диагностическом варианте заменён только formal на `@: target Box`:
[seed386](baseline-known-assignment-corrected01.log) и [новый G2](known-assignment-corrected01.log)
исполняются успешно, но оба дают first0/second0 вместо старого expected5/7; есть также старые лишние скобки RHS.
Это не регрессия387 и не дефект alias. По книге1121–1127,1186/1225 bare i:= меняет working local;
`@i` сохраняет адрес физической typed cell, а `\p` читает её до публикации. Initial payload uninitialized int не обещан.
[Контроль с initialized i1 и обычными call boundaries](published-address01.log) даёт before1/first5/second7;
[seed386](baseline-published-address01.log) даёт то же. Ядро в ответ на эту диагностику не менялось.

known_assignment переведён на initialized i1, дополнительный before_publish1 и обычные checkpoint() перед
старыми first5/second7; числовые ожидаемые5/7 сохранены. Formal и лишние RHS-скобки обновлены по действующим правилам.
Полные AFTER [seed386](baseline-known-assignment-migrated-same01.log) и [G2](known-assignment-migrated-same01.log) совпали.
Пересобрана только эта изменённая fixture: [interp/native/forced PASS](g2-02-known_assignment.log).
21 прежний успешный результат и готовые binaries переиспользованы; повтор всех22 сборок не заявляется.
В совокупности все22 целевых случая приняты после исправления stale fixture.

Final [Source07/843](source07.sha256) SHA-256:
cbaac64eb9a44d3cbc338a230499f0f319057bad557628f4c876c9c3be326615.
Diff06→07 — ровно два файла known_assignment.lm2/.expected; compiler/runtime/tool source не менялся.
[Verify07](verify07.log), [stage-copy07](stage07.log) и [fixedpoint02/13](fixedpoint02.log) PASS на тех же G1/G2 binaries.
Whole bootstrap относится к Source06; это точное различие тестовых входов не требует пересборки неизменного ядра.

[Render](docs-render01.log) PASS35 paired/14 cases/both snapshots; grammar unchanged.
[Docs-check01](docs-check01.log) PASS35/14/27/44/615, links/LF27906 из свежих CWD и PRIVATE_OUT.
Final [index-check02](docs-check02.log) PASS35/14/27/44/615, links/LF27961.
Его собственный UTF-8/LF receipt добавлен после проверки; оба diff-check чистые.
Далее commit/push main. Полный implements/test, dynamic/path/group contracts,
quoted selectors, рабочий frontend M11.8, storage M13 и native/cache/flush M14 OPEN.
Два чужих untracked сохранить. Goal ACTIVE, продолжать основной v3.
