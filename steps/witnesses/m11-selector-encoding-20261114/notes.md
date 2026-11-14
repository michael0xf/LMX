# M11.7: literal names, occurrence steps и compact quoted paths

2026-11-14, Codex. База387 `9897c99fd55408cab3531af809bb885dab5ea85e` принята и отправлена.
Работа в основном `main`; root — один code/test/build writer. Ограниченная кодовая приёмка388 пройдена;
прежний root-case остаётся OPEN, docs/index пройдены; commit/push далее.

## Код

Builder сохраняет occurrence как обычный anonymous Lmx из двух WORD: decimal digits и canonical name.
Literal WORD всегда выбирает буквальное имя, включая `[0]x`. Graph74 occurrence читает только эту форму,
проверяет size_t до умножения и меняет оба out только после полной проверки. Нет tags, нового state/layout,
parser flags, регистров или выделений памяти/intern при доступе. Внешний path3 прежний.
Run54 step/step_place, чтение, запись и admit_path получают raw правое поле; native выпускает тот же get.
Scanner/preflight пропускают selector RHS целиком. Один selector printer различает literal/occurrence,
защищает exact root/component и удваивает backticks.

Manual split compact selector удалён: compound path/index/quoted span использует прежний P0→expression builder.
Parsed WORD остаётся обычной named head, non-WORD получает существующий application carrier.
В P0 общий scan_head заменяет main/lookahead копии; compact_piece в двух callers использует существующий
scan_quoted. Quoted root suffix и quoted component читаются целиком. Global quoted_token_boundary не расширен;
локальный colon delimiter нужен для compact :=/colon после закрывающей quote и исправлен по review.

## Измерения

На seed387 literal `[0]x` даёт7 вместо11; большой ordinal2^128 переполняется до0 и тоже даёт7.
Новый reader даёт literal11/ord7/9. После записей через alias:31/7/29. Quoted occurrence label с backslash
даёт4/6/8, после compact := меняется только выбранный второй slot до16.
Admission использует те же selectors:71109; отсутствие literal-поля даёт4 до тела, calls0/before1/after0.
На seed тот же missing-кандидат ошибочно допускается, результат7. Overflow теперь refusal3/result0/after0.
Bare ambiguous x сохраняет refusal3. Component a\\b:7/9 против nested70; quoted root:11/12/index12/call6.
Doubled backtick с операторами внутри имени даёт7, compact :=/colon9/3, инертный lookahead2/untouched7,
вызовы через occurrence/literal heads11/12/13. Glued quoted name и unclosed quote сохраняют build2 с прежними диагностиками.

Все13 новых fixtures прошли interp/native/forced. Private21 сначала дал18PASS/3FAIL.
Два прежних occurrence golden содержали только лишний outer RHS group со старой формы; числа3/3 сохранены.
8 полных AFTER seed/new/native/forced прошли после форматной правки без пересборок.
Ещё9 runtime-negative AFTER прошли на готовых binaries. В совокупности20/21 целевой случай принят.

## Открытые общие ограничения

root_occurrence_index даёт runtime3 и на seed387, и на388; его source/expected seen3 оставлены неизменными.
Отказ происходит до selector: work_scan_body→work_require теряет declaration site и требует неоднозначное x.
Walk и native declaration execution тоже выбирают row по имени. Следующий код — общий site→existing frame row
путь с сохранением неоднозначности bare x, без root-specific bypass; [передача](../../handoff/m11-place-sites-20261114.md).
Это не повод считать21/21 пройденным или закрыть весь M11.7/M14.

Известная @:pick a внутри written DATA group остаётся raw/deferred и даёт step5 на обеих версиях,
в том числе с одной reference: это construction/admission gap по book815, не selector/duplicates.
Его нельзя исправлять autoexecution DATA initializers внутри step вопреки R12.
Вызовы через повторные обычные Box с собственными fn работают11/12/13 и приняты отдельно.
Ранние int-приёмки untyped primitive slot reference дали1/2; итоговый root/index контроль использует ссылку
на Structure, не обещает готовность преобразования произвольных references в число.

## Сборка

Bridge Tool SHAfe318813ef47588656d308c755eae37b7691797308496c80115e503e2623a6ad PASS.
Runtime01 отказал на неподдержанном !; заменён на condition=0. Runtime02 прошёл; финальный Runtime03
SHA9b1f3ad1e888c52eea53f64608adf544cb62a65ba74e75d7be4c74f8f9483348.
Graph02 SHA91ae4fee480e554bc07f61c7c0e5296d2a40e1b21fb87b7c62434a3ac9cbfdae.
Source04 строил код;05 добавил13 sources/11 expected;06 меняет лишь два прежних golden.
Frozen Source06/867 SHA19d3d5dc9a5f0ea49a60be7fe38319b32d677a87789bfd2f7e5455769141863d,
verify/stage-copy PASS. [Whole quick](bootstrap01.log) boot-m11-selector-encoding-01 прошёл в прежнем stage:
настоящие G1/G2 по9 smoke, [сам G1 выполнил G2 build](bootstrap-g2-build.log).
[Fixedpoint15](fixedpoint01.log) и verify867 PASS: FE/tool L1/C, оба runtime objects, retained Graph/Run headers,
private Runtime03==G2 driver, normalized executables, backend и frozen manifest.
Штатный [G2 Graph](g2-build01.log) SHA0fcf70f9e9c41f04b2912ce1930cb256bd14afde87c0072a6acd330dd937236c.
G2 driver SHA9b1f3ad1e888c52eea53f64608adf544cb62a65ba74e75d7be4c74f8f9483348.
[G2 repeat21](g2-01.log) дал20PASS/1known-rootFAIL, все13 новых cases PASS.
[Девять negative AFTER](g2-after01.log) PASS на готовых binaries. Expected root seen3 не ослаблен.
[Render](docs-render01.log) PASS35 paired/14 cases/both snapshots; grammar unchanged.
[Docs-check01](docs-check01.log) PASS35/14/27/44/615, links/LF27962 из свежих CWD и PRIVATE_OUT.
[Final index-check02](docs-check02.log) PASS35/14/27/44/615, links/LF28021.
Его собственный UTF-8/LF receipt добавлен после проверки; далее оба diff-check и commit/push main.
Working frontend M11.8, полный implements/test, M13/M14 OPEN. Goal ACTIVE; два чужих untracked сохранить.
