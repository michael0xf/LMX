# M11.5г/8: общий bounded CodeBody для else/finally, срез382

2026-11-14, Codex. База main/origin:
38cf026c53f3e55fcd099b1e617b71a2d9c35be8 (принятый381).
Работа и коммиты прямо в main, C:/Nyasha_Planet/LMX; root — единственный writer/build.
Статус: private gates, whole bootstrap/fixedpoint, повтор G2 и штатные render/docs gates пройдены;
финальный index-check пройден; далее commit/push main.

## Контракт и реализация

Правило единственной безымянной Structure на принимающей границе сохранено после
снятия parser unwrap: [решение автора](../../../LMX_blog/2026-11-10.md#p0-no-unwrap),
правило исполнения выбранного тела — [семантика](../../../docs/spec/LMX_semantics.ru.md#data-code-roles).
Норма выводится также из прежней спецификации §4.0.1/§20.5.7; нового формала управления нет.

Один экспорт Run code_body возвращает заимствованные body/from/to по прежним ролям
CodeArgument. У else/finally весь хвост принимает единственную написанную группу
один раз. У if/loop уже выбранное тело сохраняется целиком. Прямой tick() остаётся
самим call Frame, а не списком его аргументов. Выбор ничего не вычисляет и не применяет
field_value/frame_value. Новых таблиц, активаций, opcode и копии графа нет.

Один view используют capture scanner, fn_own, обходчик и native на границах else/finally.
Общие block/emit_block/scan_body/fn_own_body не раскрывают группы повторно, в частности
когда finally исполняет остаток уже выбранного тела. Code_parent признаёт именно
выбранную G1 под role3 и даёт внешний lexical CodeBody; физический parent не меняется.
Невыбранная внутренняя группа остаётся значением, неизвестный вызов внутри неё не
становится обязательным входом. Кадр, data, work rows и приоритеты381 сохранены.

## Различающие проверки

Пять новых L3 fixtures имеют заранее выведенные результаты:

- Прямой, single-group и double-group else плюс те же finally дают calls4.
  [Baseline381](baseline-boundaries01.log) давал2. Двойная группа не исполняется,
  прямая call-head не теряется.
- Три cleanup append1/append2/append3 при unwind дают trace21 и return9;
  двойная группа append3 инертна. [Baseline](baseline-unwind01.log) давал trace1.
- Written local leaf7 внутри выбранного else и внешний leaf90 дают790;
  computed leaf8 даёт890. [Baseline](baseline-lexical02.log) давал90/90.
- Own collector даёт late7; finally с собственным late возвращает4, публикует5.
  Double-group с phantom и missing() не создаёт поля и не требует missing: fields0.
  [Baseline](baseline-own01.log) отказывал3 до BODY.
- Ошибка деления сохраняет ответ6; single-group finally и root cleanup публикуют
  trace21/root_trace21. Double-group с missing() инертна. [Baseline](baseline-error01.log)
  оставлял trace2/root_trace0. Сравнивается весь отрицательный AFTER.

[Runtime01](runtime01.log) и [Graph01](graph01.log) построены на Source01/751.
Source02 только добавляет пять fixture pairs; исполняемые исходники не менялись.
[Frozen Source02](source02.sha256), [verify761](verify02.log), SHA-256:
be5db8e3168082a1509b5b035f7d293b0f8ec40a6092c321b247647443e04d7f.
Run53 согласован через отдельный [producer bridge](producer-bridge01.log), собранный
на принятом381 до полного stage sync. Graph71/implements74 и Frame ABI не менялись.

[Private25](private01.log) прошёл в interp/native/forced: пять новых случаев и20
контролей управления, capture, snapshots, nested methods и вызовов. [75 полных AFTER](private-after01.log)
и [mutation24](mutation01.log) прошли. Старые expected не менялись.
[Native trace](native-codebody01.log) подтвердил actual native root, written outer,
computed outer и fn_apply внутри выбранного else, результаты790/890 и normal exit.
Новая dynamic leaf идёт прежним walker fallback; это не приёмка native M14.
GDB command file остаётся в ignored build output; поддерживаемого debug runner нет.

## Настоящие поколения

[Whole bootstrap quick](bootstrap01.log) построил и проверил настоящие G1/G2,
по9 smoke. Actual G1 строит G2, а не запускает прежний frontend от имени нового.
[Fixedpoint13](fixedpoint01.log) сравнил промежуточные L1/C, runtime bytes,
нормализованные executable, frozen Source02 и verify761. Все13 проверок прошли.
[Штатный G2 graph-tool](g2-build01.log) построен заново, SHA-256:
f71df0958fda2d9be2e958b70fcd3b081e2248305aa07a68a7dbf6eda5b89316.
[G2 repeat25](g2-01.log) прошёл в interp/native/forced; [21 полный negative AFTER](g2-after01.log)
и [mutation24](g2-mutation01.log) прошли. Рабочая кодовая связка — boot-m11-codebody-01/g2 +
graph-m11-codebody-g2-01.

## Документация

[Штатный renderer](docs-render01.log) пересоздал35 пар семантики,14 implements cases
и оба source snapshot. [Docs-check01](docs-check01.log) прошёл35/14/27/44/615,
ссылки и LF27661 до staging. PRIVATE_OUT и CWD созданы свежими, грамматика не менялась.
Финальный [staged-index docs-check02](docs-check02.log) прошёл35/14/27/44/615,
ссылки и LF27695. Его собственный receipt добавлен после проверки с UTF-8/LF.
Оба diff --check чисты; два чужих untracked сохранили SHA-256.

## Открытые зависимости

Штатные render/docs gates и финальный index-check пройдены.
Этот срез закрывает структурный приём сохранённой группы на границе else/finally,
не общий вычисляемый или внешний CodeBody. Копия raw объявления и реально удержанная F
проверяются раздельно: [уточнение чтения плана](../../handoff/copy-construction-reading-20261114.md).
Новый binding raw scope не наследует SourceSpace F/data; held F копируется как обычное
значение с текущими parts/aliases, а явный fn создаёт свежие F/D. Этот срез их не реализует.
M11.7/8, M13 и M14 остаются OPEN. Грамматика/P0 не менялись.
Goal ACTIVE; после приёмки продолжить основной v3, сохраняя два чужих untracked.
