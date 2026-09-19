# LMX documentation-first restart

- Start from `docs/LMX_semantics.ru.md` / `docs/LMX_semantics.en.md` and the user's current instructions. Do not import old Message/arena/runtime designs as new requirements.
- Keep RU/EN documents synchronized in meaning, order, examples, and cross-references. Preserve the author's Russian semantic opening verbatim.
- Grammar source: `provenance/grammar.json`; render using `python tools/build_docs.py`. Preserve copied examples and their source ranges.
- An explicitly formed empty vertical body is a present empty Structure argument, synonymous with `()`. `receiver:` followed by `---` is valid. Never treat an empty argument's interior as absence of that argument.
- Imported tests and goldens are historical evidence. Do not rewrite them to hide a disagreement. Current language expectations are separate under `tests/parser/current`.
- Work only in this LMX repository unless the user explicitly requests edits to another project. The initial work is documentation and parser-test migration, not kernel implementation.
- Before committing, run `python tools/check_docs.py`. Report parser conformance separately from historical-regression agreement.

## Текущий план и состояние

- Рабочие инструкции и планы хранить в `steps/`, поддерживать актуальными; в спецификациях оставлять описание языка.
- Разделение спецификаций: `LMX_semantics.*.md` — семантика L3; `L2_spec_*.md` — специальные низкоуровневые операции L2 и симметричное точное описание ядра на уровне L2; `L1_spec_*.md` — язык L1, перевод в C99 и все существенные детали реализации ядра.
- Для наполнения L1 изучить прежнюю `L1_spec.txt`, текущий проект L1 и все разделы «реализация на Си» прежней `Lingvamyxa_spec.txt`. Код сопоставлять с решениями автора: расхождения фиксировать, не превращать случайное поведение реализации в норму.
- Описание каждого механизма ядра вести симметрично в L2 и L1, со стабильными якорями и взаимными ссылками на соответствующие параграфы. Существенные детали не оставлять только в L1. Эти пары служат руководством для транслятора L2 и порта L1 → L2; при изменении механизма обновлять обе пары RU/EN. Наличие и соответствие текущего транслятора DeepSeek проверить по исходникам, не считать установленным.
- Первый симметричный раздел — атомарные флаги рукопожатия; ссылки между L1 и L2 ведут непосредственно к нему.
- В L1 и L2 внесено уточнение автора: атомарные флаги рукопожатия находятся в арене родителя; многопоточный доступ к ним включает изменение без синхронизации. Не подменять это дополнительными механизмами. Точный смысл отсутствия синхронизации, используемые атомарные операции и их порядок памяти сверить с текущей реализацией и решениями автора при исследовании, не назначать самостоятельно.
- Корпус тестов парсера перенесён: 615 исходных файлов. Исторические прогоны: 131 случай на каждом из двух прежних парсеров. Это не подтверждение соответствия новой грамматике.
- Пустое вертикальное тело: текущие проверки соответствия обнаруживают расхождение обоих прежних парсеров; их код в этом проекте ещё не исправлялся.
- При дальнейшей работе с P0 сверять детальное поведение Mix-меток, `{#...}` и границ строк с исторической реализацией и тестами; не выдумывать отсутствующие правила.
- После завершённых изменений проверять документацию, делать коммит и push в публичный репозиторий `michael0xf/LMX`.
