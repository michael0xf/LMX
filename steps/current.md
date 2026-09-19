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
- Следующий раздел документации: спецификация L1 на русском и английском на основании прежней спецификации L1 и основной спецификации. Пока в `docs/L1_spec_ru.md` и `docs/L1_spec_en.md` зафиксирована только область описания.
- Корпус тестов парсера перенесён: 615 исходных файлов. Исторические прогоны: 131 случай на каждом из двух прежних парсеров. Это не подтверждение соответствия новой грамматике.
- Пустое вертикальное тело: текущие проверки соответствия обнаруживают расхождение обоих прежних парсеров; их код в этом проекте ещё не исправлялся.
- При дальнейшей работе с P0 сверять детальное поведение Mix-меток, `{#...}` и границ строк с исторической реализацией и тестами; не выдумывать отсутствующие правила.
- После завершённых изменений проверять документацию, делать коммит и push в публичный репозиторий `michael0xf/LMX`.
