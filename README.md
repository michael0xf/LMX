# LMX

[Русский](README.ru.md) · [English](README.en.md)

[Семантика](docs/LMX_semantics.ru.md) · [Semantics](docs/LMX_semantics.en.md)

[Грамматика](docs/LMX_grammar.ru.md) · [Grammar](docs/LMX_grammar.en.md)

[Заметки о реализации](docs/implementation-notes.ru.md) · [Implementation notes](docs/implementation-notes.en.md)

[Текущий план v3](next_core_tasks_v3.md) · [Карта ядра](CORE.md) · [Связь агентов](work_chat/README.md)

[Памятка всем моделям / Guide for all models](READ.ME)

Срез382 реализует общий bounded CodeBody selector для else/finally; приёмка пройдена:
одна written group выбирается один раз, уже выбранные тела и вложенные самостоятельные группы сохраняют уровень.
Runtime01/Graph01, пять pure-проб, private25 triple/AFTER75/mutation24 и native trace прошли;
настоящие G1/G2 quick, по9 smoke, fixedpoint13/verify761 и пересборка graph-tool штатным G2 прошли.
G2 repeat25 triple/negative AFTER21/mutation24 и штатные render/docs check382 прошли:35/14/27/44/615, ссылки/LF.
Границы382 и открытые зависимости M11/M13/M14 — в [основном плане](next_core_tasks_v3.md).
