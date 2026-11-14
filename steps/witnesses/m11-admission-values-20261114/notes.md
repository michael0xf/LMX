# M11.7: выбранное Structure-value в допуске

2026-11-14, Codex. База385 `9edf9666cd9fb5a2715a6e37c6b0db0330d06f5b` принята и отправлена.
Основное дерево main; один последовательный producer. Кодовая приёмка386 и обе docs-проверки пройдены; commit/push выполняются.

## Исправление

Прежний admit получал Model через общий resolver. Для ссылочного места результатом была
уже выбранная reference-cell, в том числе рабочий снимок активации, а admit_paths сразу
требовал raw Structure. Три новые положительные fixture на seed385 поэтому отказывают4.

admit_paths теперь один раз применяет существующий target к локальным model/candidate,
затем сохраняет прежний kind4 gate и used-path/type checks. Общий resolver не раскрывает
ссылки иначе; admit возвращает прежний actual. Нет повторного поиска физического Model,
копии Structure, новой таблицы, публикации или рекурсивного раскрытия ссылок.
Run53/Graph72 и layouts сохранены. Это исправление потребителя, не полный implements.

## Проверенные значения

- Literal, ссылочное место и алиас дают7/7/7. Запись через алиас видна как8 у обоих
  держателей; Model.v остаётся0, calls3. Неиспользуемый Model.unused не требуется кандидату.
- Кандидаты из обычного поля, ссылки и индексированного слота дают7/8/9. Слот, начавшийся
  атомом, после приёма значения допускает другую Structure: released length1. Его NONE
  не превращается в требование Model. Неиспользуемый цикл кандидата сохраняет ответ10,
  длина ссылки на самого себя3; полного обхода кандидата при таком допуске нет.
- Первый actual выбирает A. Второй пишет опубликованное p на B, меняет A.v с7 на9
  и неиспользуемое Model.unused на99. Тело видит выбранную A с9; рабочее p остаётся9,
  прямое data.p даёт20, финальное опубликованное p —20. effects1, Model.v0.
- Отсутствующее используемое поле и неверный вид поля дают4 до входа в тело:
  calls0/before1/after0.

Ранние диагностические варианты не приняты как proof: root Slots:=Alias отказал до
целевого вызова; третье поле Self без предоставленного значения отказало при создании
цикла. Контроль использует известное Other, создаёт цикл и достигает read(Alias,3).
Новых core workaround для этих вариантов нет.

[Private10](private01.log) прошёл в interp/native/forced без изменения старых expected.
Кроме пяти новых случаев повторены Point take/fields, reference_work/reference_alias
и slot_atom_replace. [Шесть полных negative AFTER](private-after01.log) также PASS;
бинарники для этого сравнения переиспользованы.

## Сборка и границы

[Runtime01](runtime01.log) driver.o SHA-256:
075c4f9fb81719ebc7dd6a63769fdbe4a1ca4ad35b7097cc13ffbec09da77f59.
[Graph01](graph01.log) SHA-256:
7317b6d54a6693d0888f7a7832f945e84f293a2970e819877593b0e24cd7c913.
Source01/816 строил код. Source02 добавил только пять fixture pairs и inventory;
код после Source01 не менялся. Frozen [Source02/826](source02.sha256) SHA-256:
59768bbeaeac8be960aff581fb0ccc6164a9f597a161e49ab36b9b7db9d856ac.
[Verify826](verify02.log) и stage-copy PASS. [Whole quick bootstrap](bootstrap01.log) прошёл:
настоящие G1/G2, по9 smoke; [G2 build](bootstrap-g2-build.log) выполнен самим G1.
[Fixedpoint13](fixedpoint01.log) сравнил frontend/tool L1/C, runtime objects, нормализованные
executable, backend и frozen manifest/verify826: PASS.
Штатный [G2 Graph](g2-build01.log) SHA-256:
908154b9bbcefb94eddf238f0d93248087f171abbec9fee91e396ed1c7c7739e.
[G2 repeat10](g2-01.log) прошёл в трёх режимах; [6 negative full AFTER](g2-after01.log) PASS.
Рабочая кодовая связка — boot-m11-admission-values-01/g2 + graph-m11-admission-values-g2-01.
[Штатный render](docs-render01.log) пересоздал35 пар семантики,14 implements cases и оба source snapshot;
грамматика не менялась. [Docs-check01](docs-check01.log) PASS из свежих CWD/PRIVATE_OUT:
35/14/27/44/615, ссылки/LF27869 до staging. [Final index-check02](docs-check02.log) тоже PASS:
35/14/27/44/615, ссылки/LF27905. Его собственный UTF-8/LF receipt добавлен после проверки.
Оба diff-check чистые; два чужих untracked сохранили исходные SHA. Далее commit/push main.

Следующий код — pure source-known call-shape/default preflight после построения,
с отдельным runtime guard поддержанных результатов. Конкретный алгоритм и ABI-зависимость
описаны в [handoff](../../handoff/m11-admission-structure-value-20261114.md).
Полный used-interface admission/test, quoted-selector encoding, M11.8/M13/M14 OPEN.
Проверки снимков не объявляют общий кеш/flush M14 реализованным. Чужие два untracked сохранить.
Goal ACTIVE, продолжать основной v3.
