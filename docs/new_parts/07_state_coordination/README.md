# Координация состояния: Message и общая память

[Руководство RU](LMX_Design_Patterns.ru.md) · [Guide EN](LMX_Design_Patterns.en.md)

Все шесть исходных паттернов сохранены отдельно. LMX-альтернатива через Message обеспечивает выбранные наблюдения, но не притворяется shared-memory RW lock, DCL fast path или OS-thread-local storage. Различия параллелизма, affinity и latency указаны по каждому примеру.

[LMX_Comparison_07_state_coordination.xlsx](LMX_Comparison_07_state_coordination.xlsx) · [LMX_Comparison_07_state_coordination.pdf](LMX_Comparison_07_state_coordination.pdf) · [LMX_Comparison_07_state_coordination.md](LMX_Comparison_07_state_coordination.md)

Редактируемый источник материалов — patterns.json. Листинги вынесены в examples.
