# M11.5е: объявления пользовательских формалов

2026-11-14, Codex. База384 `62072bca543a257af71ab95bfa520781524bfef6` принята и отправлена.
Работа в основном `main`, один последовательный producer; чужие два untracked не включать.
Кодовая приёмка385, docs-check01 и финальный index-check02 пройдены; commit/push выполняются.

## Изменение

Frontend проецирует уже разобранную `primitive.description` через прежние source-table,
snapshot и publication фазы. Generated unit содержит canonical names и cell flags; нового
runtime parser или второго ручного каталога нет. Активный source profile35 включает
прежние23 строки,10 C99/profile строк старого каталога и явные schar/_Bool.
Импорт каталога не обещает выполнение всех его типов: None/void имеют cell0,
остальные33 строки — cell1. Прежние usize/isize и semantic/library rows вслепую не перенесены.
Lower использует тот же payload для backquoted cell/convert flags.

Graph загружает профиль в suffix существующего receivers. Чистый declaration_name
узнаёт непосредственное объявление формала через primitive/C-door, reference depth,
qualification и Array chains/rank. Он сохраняет материализованные клетки, не исполняет
default и не входит в model subtree. fn_make проверяет каждый immediate user arg до
выделения F и fn_data. Обычная Structure в этой роли отказывает5. Псевдоформалы
встроенных ресиверов и общий data-field reader сохраняют прежнюю роль.
Произвольная голова больше не становится неявной Structure-моделью.
Graph exports72, Run53; layouts прежние.

Array head `[]/[][]...` больше не читается как attached index с пустой базой.
Построитель канонизирует идентификаторы на границе P0→Graph, после lexical dispatch;
backquotes снимаются, doubled backquotes становятся одним payload byte.
Это не декодирование строк и не изменение lexer/parser.

## Поведение и частная приёмка

Baseline384 принимает arg:Model/Model:arg, включая computed args, и продолжает after2.
Новые positional/named/whole descriptor Fn и Sub случаи отказывают5 на достигнутом
создании: before1/after0. Так же отказывают empty Structure, void(cell0), qualified
Structure и quoted node. Default/model subtrees не проверяются как immediate args.

Metadata-only fixture принимает34 формала (33cell rows и c.FILE), qualified3,
Array chain1, rectangular rank>64, reference depth>64, deferred1 и model1.
default_calls0 и deferred_data0. Это проверка создания descriptor, не приёмка
выполнения Array, deep reference или computed default. Quoted identity даёт7/arity2,
escaped formal с doubled backquote —8/arity1.

Четыре старых Point формала мигрированы с Point:p на @:p Point. Значения прежние:
take1; fields31/42/32 и length1/3; required5; missing4. Две positive golden
исправлены также на четыре давно исчезнувшие synthetic RHS пары скобок;
baseline384 показывает тот же вид RHS и те же числовые результаты.

[Private01](private01.log) исполнил13 случаев в трёх режимах:12PASS, p0_argument_structure имел
только две старые RHS пары скобок. Seed384 подтвердил тот же полный AFTER и7/7;
исправлен expected, готовые binaries сохранены. [Private-after01](private-after01.log):40 полных AFTER
(39 от13×3 и один [baseline](baseline-p0_argument_structure.log)),0 failures. [Private02](private02.log): quoted и quoted node, оба triplePASS.
После добавления doubled-backquote fixture пересобран только изменённый quoted
случай в [private03](private03.log);7/2/8/1 и три режима PASS.

[Profile quoted/plain output](profile-quoted.lm1) одинаков, как и normal Lower L1.
[Duplicate class](profile-duplicate.log) и [cell2](profile-badflag.log) отказывают до публикации,
предыдущий OUT сохранён. [Snap-touch02](profile-touch02.log) с index1
даёт одну frontend диагностику изменения источника, прежний OUT сохранён, temp нет.
Первый snap-touch получил путь вместо числового индекса и не включил fault;
он не принят как проверка ошибки snapshot.

## Сборочная цепочка

Bridge01 отказал на reserved local length; исправлено имя name_size. Bridge02
отказал на missing c.prefix bound_free; исправлено. Standalone bridge03 собран,
но не имеет hosted Graph route. Поэтому Runtime01 остановился на Clock --graph:
успешные переводы Graph/Run не выданы за собранный runtime.
Transient link-frontend CLI был снят; не является частью итогового инструмента.
BridgeTool02 попытка остановилась на headers, очищенных незавершённым Runtime01.
Использован существующий build-frontend-host: bridge04 собран с прежним runtime,
затем штатные Runtime02 и Graph01 прошли. Builder-only canonical fixes дали Graph02/03.

[Runtime02](runtime02.log) driver.o SHA-256:
84b2f626a031e7cfd13e5c61206e65589a47ff398716981e2c249ccd15b7fd1c.
Private [Graph03](graph03.log) SHA-256:
87fe3b07f0902797db8d73d13909263af00fdfae1b276259326a62979f9d8546.
Frozen [Source05/816](source05.sha256) SHA-256:
de6f1d57c5143ad000872c9c13b4cf792ae771211489c37ba3bdccb2a7750edb.
[Verify816](verify05.log) прошёл. Source03 строил Runtime02; поздние семантические изменения
относятся только к builder, комментарии Graph/profile не меняют generated runtime.
[Whole quick bootstrap](bootstrap01.log) прошёл без ошибок: настоящие G1/G2, по9 smoke.
[G2 build](bootstrap-g2-build.log) выполнен первым поколением. [Fixedpoint13](fixedpoint01.log)
сравнил frontend/tool L1/C, runtime, нормализованные executable, backend и frozen manifest/verify816: PASS.
Штатный [G2 Graph](g2-build01.log) SHA-256:
e742dba04a06366ab8e45ab921f145a7d5b0bac4dc23142600e43093f3114021.
[G2 repeat15](g2-01.log) прошёл в трёх режимах; [21 negative full AFTER](g2-after01.log) PASS.
Рабочая кодовая связка385 — boot-m11-formal-declarations-01/g2 + graph-m11-formal-declarations-g2-01.
[Штатный render](docs-render01.log) пересоздал35 пар семантики,14 implements cases и оба source snapshot.
Грамматика не менялась. [Docs-check01](docs-check01.log) прошёл из свежих CWD/PRIVATE_OUT:
35/14/27/44/615, ссылки и LF27794 до staging. Финальный [index-check02](docs-check02.log)
также прошёл:35/14/27/44/615, ссылки/LF27868. Его собственный receipt добавлен после проверки.
Diff-check первоначально нашёл пустую строку EOF в двух generated Lower L1 copies;
нормализованы только witness-копии до одного конечного LF. SAME проверял исходные выходы в ignored out,
а код, тестовые ожидания и compiled artifacts не менялись. Оба diff-check прошли чисто перед commit/push main.

## Открытые границы

Общий admission M11.7, рабочий frontend M11.8, storage M13 и native/cache/flush M14
остаются открыты. Root @:Model actual admission4 — отдельная граница чтения модели,
не повод разрешать structural formals. Полный validator всех типов и их lowering
не объявляются реализованными этой metadata приёмкой.
Quoted path components с backslash и collision exact name `[0]x` со строковым occurrence
encoding включаются отдельной OPEN задачей M11.7; этот срез их не закрывает.
Goal ACTIVE, продолжать основной v3.
