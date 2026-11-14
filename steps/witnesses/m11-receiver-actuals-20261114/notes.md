# M11.5е: прямая подача ресиверу и whole descriptor DATA, срез384

2026-11-14, Codex. База main/origin:58bc7f3a00244d4b6bc6567807a8929ecaaa8120 (принятый383).
Основное дерево C:/Nyasha_Planet/LMX, main; root — единственный code/test/build writer.
Статус: private-проверки, whole G1/G2/fixedpoint, native trace, G2 repeat и штатные docs gates пройдены.

## Изменение

Общий Run.bind_formals связывает прямые актуалы по позиции или label :=. Удалены by_head/mode2
и старый frame_value, который мог снимать написанную группу. Сам parser не менялся.
Structure-формалы fn/sub используют прежний read_received_value(contract2): written_group остаётся DATA,
named Frame вычисляется как actual. Word-формалы name/return сохраняют description contract,
включая написанное @:c.FILE. Приём каждого actual остаётся перед следующим actual.
Целый переданный descriptor читается отдельно прежними bind_fields/field_value как DATA:
его поля name/args/return/data/code не становятся вызовами или прямыми labels.

Чистый fn_decl_name различает direct positional/name:= и ровно один whole descriptor DATA.
Он не раскрывает вложенные группы рекурсивно, не читает direct name: как label, не требует Space,
не исполняет и не создаёт declarations. Frame/Run53/Graph71 ABI сохранены. Новых реестров нет.

## Значения и исходные снимки

[Baseline](baseline-paired.log) даёт direct12/wrapped12. [Старая прямая colon подача](baseline-legacy.log)
ошибочно создаёт old/result7. Неизвестные [args](baseline-unknown-args.log), [data](baseline-unknown-data.log),
[code](baseline-unknown-code.log) ошибочно принимаются как части и продолжают after2.
Новые три fixture отказывают3 при before1/after0; прямая colon форма отказывает3 и не создаёт old.
Name/return остаются описаниями: unsuitable written name отказывает5, а не unknown3.
[Static baseline name](baseline-named-description.log) отказывает при подготовке namespace, before0.
В первом private он также дал emit5 до создания native; эта граница не выдана за runtime proof.
Для достигнутого runtime случая args поданы вычисляемым именем held_args: [reached name5](pure02-receiver_name_refused.log)
даёт before1/after0. Это реально построено и исполнено в трёх режимах.

[Порядок](baseline-actual-order.log) сохраняет effects1/later0/refusal5: int первого producer
не принимается Structure-формалом, следующий producer не вызывается.
[Написанная code группа](baseline-inert-code.log) остаётся инертной, length1/after2.
Изменённые fn_named_supply сохраняют r1..r11=5/12/4/42/31/7/9/10/101/202/303,
c3=2,total6. Fn_return_forms сохраняет один @:c.FILE во всех трёх формах.
Fn_name_call получил явный finally-свидетель [at_end1](pure02-fn_name_call.log) перед refusal5.

[Runtime01](runtime01.log), driver.o SHA210c8f72c8c7789318da00405f80796560d368a6957f1a2d107261a734a2cf0e;
[Graph01](graph01.log), SHA5f7bd3b402b0c29c00be6ff49127008fd24bea97e1e96476fce0f03f7ec520ae,
построены из Source01/781. Source02/797 добавил8fixture pairs; Source03/798 добавляет fn_name_call.expected,
усиливает два fixture и исправляет старые golden. Код после Source01 не менялся.
[Frozen Source03](source03.sha256), [verify798](verify03.log), SHA-256:
ac0d0a1ca48bfdb488c44982ada095ef2e7516dd304831d5987a735c55f13e9f.

## Первоначальные расхождения и повтор

[Private01](private01.log) исполнил32 случая:29 совпали, два имеют stale golden,
один static-name случай отказал при emit5. Ни один первоначальный отказ не скрыт.
Для fn_prepared и call_receivers seed383 даёт тот же полный AFTER, что три новых режима:
6/6 сравнений совпали. Исправлены лишь13 пар внешних RHS скобок старого synthetic wrapper до380;
все числа сохранены. [Baseline fn_prepared](baseline-fn_prepared.log), [call_receivers](baseline-call_receivers.log).
Готовые бинарники переиспользованы. [Private-after01](private-after01.log):87 полных AFTER плюс2baseline,
всего89 language checks PASS. [Private02](private02.log) пересобрал только два действительно изменённых
fixture (reached name5 и observed name-call1); оба прошли interp/native/forced.
[Mutation24](mutation01.log) PASS.

[Whole bootstrap quick](bootstrap01.log) построил настоящие G1/G2, по9 smoke, без ошибок.
[Fixedpoint13](fixedpoint01.log) сравнил frontend/tool L1/C, runtime bytes, нормализованные executable,
backend и frozen manifest/verify798;13/13 PASS.
[Native trace02](native-receiver-actuals02.log) показывает actual native root → fn_apply →
receiver_bind(evaluate1) → actual native first producer body0. AFTER effects1/later0/before1/after0
и ожидаемый host exit1 подтверждают отказ после первого actual без следующего вызова.
[Первый GDB01](native-receiver-actuals01.log) не получил argv, завершился missing roots/code2
и доказательством исполнения не является. Исправленный диагностический запуск переиспользовал тот же бинарник;
нового maintained debug runner нет, одноразовый command file остаётся в ignored build output.

[Штатный G2 graph-tool](g2-build01.log) собран заново, SHA-256:
09f0e983a7baa2b892bd755c5845495355062e673b41ff6556a02a6899004f82.
[G2 repeat32](g2-01.log) прошёл в трёх режимах, [21 полный negative AFTER](g2-after01.log)
и [mutation24](g2-mutation01.log) PASS. Рабочая кодовая связка384 —
boot-m11-receiver-actuals-01/g2 + graph-m11-receiver-actuals-g2-01.

## Остаток

[Штатный renderer](docs-render01.log) пересоздал35 пар семантики,14 implements cases и оба source snapshot.
[Docs-check01](docs-check01.log) прошёл, но был запущен из общего stage CWD. Поэтому [docs-check02](docs-check02.log)
повторён из действительно свежих CWD/PRIVATE_OUT и прошёл:35/14/27/44/615, ссылки/LF27738 до staging.
Грамматика не менялась. [Финальный staged-index check03](docs-check03.log) также прошёл:
35/14/27/44/615, ссылки/LF27793. Его собственный receipt добавлен после проверки с UTF-8/LF.
Оба diff --check чисты; два чужих untracked сохранили SHA. Далее commit/push main.
Полная проверка declarations в args — отдельный открытый пункт M11.5е перед M11.7:
нельзя отвергать допустимые примитивы/квалификаторы/Array узким machine whitelist.
[Исследование declaration-view](../../handoff/graph-declaration-view-20261114.md) — кандидат, не готовая реализация.
Рабочий frontend M11.8, M13 и общий native/cache/flush M14 остаются OPEN. Goal ACTIVE.
Два чужих untracked сохранить; чужой WIP в срез не включать.
