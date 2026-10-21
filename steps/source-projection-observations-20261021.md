# Source projection96: наблюдения до GCC-проверки WIP

Ненормативный checkpoint, 2026-10-21 UTC. Продолжение
[context94/95](receiving-context-frame-20261021.md), не новый результат
полного gate. Codex sole writer/build; goal ACTIVE. Full L295 продолжает
работать в прежней session63720/PID12064; его input/output не менялись.
Второй GCC pipeline не запускался.

## Измеренный старый потребитель общего результата

Actual compiler94:
`build/codex_catalog94_build_01/l2trans.exe`, SHA256
`7B402DD56C1F84175C23B804AAA7C194B35BB902A4BDC2119CD563667AB0A36D`.
Исходник compiler94 совпадает с compiler source95: private95 менял runtime,
не compiler. GDB запускает только собственный новый compiler process;
пользовательские процессы и worker полного gate не меняются.

`build/codex_source96_projection_control_01.ps1`,
[exact commands](witnesses/used-scope-20261020/resolved-source-projection-control.gdb):
два synthetic prepared path records с уже известным leaf Model5.
Один — индексный leaf13, второй — composed reference без named NSF row.
Actual `l2_reference_source_of_path` отвечает1 в обоих случаях — то есть
не возвращает источник. Поле `schema=0` в отладочном output не является
разрешённым Model0: исход результата при отказе недействителен, его нельзя
использовать. Контроль не выполняет L2-программу и не доказывает значения.

В коде причина прямая: после own/formal ветвей требуется `step.kind=10`
и существующая namespace row; Model читается заново через
`l2_nsf_pointee(row)`, а не из полного resolved leaf contract. В итоге
индексный либо безымянный composed leaf теряет уже вычисленный Model.

Private96 WIP проецирует `leaf_model` и `l2_path_rec_leaf_ft` того же
готового результата. Настоящая declaration row добавляет только свой
flow key; её отсутствие не создаёт origin или фальшивый key результата.
Whole Array не объявляется своим element Model. Refused path не становится
успешным источником. Сохраняется прежний отказ при переполнении кодирования
настоящего field key. Дополнительного парсера/поиска имени нет.

Это ещё **не проверенный compiler96**. Только
`build/codex_source96_translate_{01,02}.ps1` дали C, оба executed LM1
snapshots сохранены. Unit13, предлагаемый differential13/6→13/0 и
194 прежних compiler assertions **не выполнялись**. Следующие recipes:
`build/codex_source96_projection_values_01.ps1` и
`build/codex_catalog96_build_01.ps1`, после terminal full95. Не смешивать
два измеренных старых отказа GDB с пока не измеренным13-check control.

## Typed result: не выдавать storage witness за logical Model

[Обычный входной L2 пример](witnesses/used-scope-20261020/receiving-declared-giving-result.lm2)
имеет relay с declared result E. Он успешно переведён actual compiler94
под GDB; пользовательский runtime-код не исполнялся.

`build/codex_source96_return_control_03.ps1` измеряет настоящий native
header producer `l2_emit_parts`: у method2 logical result Model1,
`signature-return=100`, `cell-return=1200`. Control05 с исходной записью
`@: E` даёт ту же тройку: не выводить semantic Model из написания C ABI.

Control04 и [его exact commands](witnesses/used-scope-20261020/typed-result-header-control.gdb)
следуют дальше в `l2_emit_cell_new_ty`: фактические аргументы
`ty=1200 n=0 owner=l2_fkid field=0`. То есть этот вызов конструктора
ячейки получает machine storage type, а не logical Model1.

Это **не доказательство потери Model во всём графе**: declared Model
может быть удержан другими текущими данными/связями. Но нельзя считать
default value этого pointer witness уже доказанным source Model или
восстанавливать Model из его C type. Перед выбором receiving-context
producer нужно проследить фактический текущий declared contract и его
Model address через native header, CALL/EXEC contract, copy и walker.
Не извлекать требование из изменяемого pointer default кандидата,
имени метода, первого layout token или prototype другого вхождения.

Первоначальные return controls01/02 ставили breakpoint в другом producer,
`l2_rw_call_contract`, с условием FILL. Он не был достигнут; после нормального
выхода compiler GDB сообщил `No symbol "mi" in current context`.
Оба неудачных controls сохранены. Отсутствие breakpoint НЕ доказывает
отсутствия result Model или ошибку его парсинга; реальные03/04/05
измеряют правильный native header route.

## Предстоящие source values и честная граница

Подготовлены семь положительных программ с ожидаемыми read9/write41/
address43/sibling7: formal, lexical capture, node, index, result, copy и
глубокий mixed path. Для них получены14 L2→L1→C outputs (native и
forced-method mode). **Ни одного нового value run пока нет.**
Нужно проверить реальные bindings прежде, чем называть вариант pure walker.

Отдельно `build/codex_giving96_covariant_01.lm2` и
`build/codex_giving96_covariant_shape_01.ps1` дают ещё два L2→L1→C outputs,
тоже без запуска значений. Actual target объявляет result D; принимающий
callable interface — R, а тот же raw value имеет конкурирующие D/E views.
Предстоящий oracle — один вызов target, R.v=7/R.w=9, затем write41 и
address-write43 с сохранённым9. Это проверка именно допуска результата
вызова и namespace выбранного callable, не только обычной переменной E.
Не считать её уже RED или GREEN; в229-pin receipt она ещё не входит.

Все source/preparation recipes и случаи перечислены в current.md.
Capture01 с отдельным root/local shadow отвергается compiler с atom=E;
он сохранён, lexical capture02 не объявляется исправлением этого случая.
Erased/cast-erased probes остаются исследуемыми гипотезами, не negative
goldens: их ожидаемым отказом нельзя самовольно определять язык.

Частное исправление сохранения leaf metadata не заменяет общего retained
typed source result. Logical giving Model и возможные physical sources
различны: `L2ReferenceSource.schema` нельзя без проверки объявить current
declared Model. Native/walker должны получить один разрешённый результат
и настоящие Model/reference addresses, не source-specific fallback.
Public dev, uniform native, v3/self-build/mail остаются OPEN.

## Receipt наблюдений, не terminal gate

`build/codex_source96_observations_01.ps1`:229 pins независимо rehashed,
manifest `build/codex_source96_observations_01.inputs.sha256`, SHA256
`E0142E8351C9F89835E2F812C0517393D19AD7F96B80AECDB9E8E6D10529DBF1`.
Включены successful и failed probes, входы/outputs translation-only,
текущий uncompiled WIP96 и его13-check unit. Предыдущий11482 receipt
только referenced. Live full95 subtree не читался этим receipt и не
объявляется завершённым. Forbidden l2_driver_launch.err не тронут.
