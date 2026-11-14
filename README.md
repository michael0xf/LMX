# LMX

[Русский](README.ru.md) · [English](README.en.md)

[Семантика](docs/LMX_semantics.ru.md) · [Semantics](docs/LMX_semantics.en.md)

[Грамматика](docs/LMX_grammar.ru.md) · [Grammar](docs/LMX_grammar.en.md)

[Заметки о реализации](docs/implementation-notes.ru.md) · [Implementation notes](docs/implementation-notes.en.md)

[Текущий план v3](next_core_tasks_v3.md) · [Карта ядра](CORE.md) · [Связь агентов](work_chat/README.md)

[Памятка всем моделям / Guide for all models](READ.ME)

**Срез385 — профиль примитивов и declaration-view, ограниченная реализация; кодовая приёмка пройдена.**
Source05:816 de6f1d57; Graph03/private03 проверили quoted7/arity2/escaped8/arity1,40 private full AFTER прошли.
Whole bootstrap01 quick построил настоящие G1/G2, по9 smoke; fixedpoint13/verify816 PASS.
Штатный G2 пересобрал graph-tool e742dba0; repeat15 в трёх режимах/21 negative full AFTER PASS.
Рабочая кодовая связка — boot-m11-formal-declarations-01/g2 + graph-m11-formal-declarations-g2-01.
Render35/14 и docs-check35/14/27/44/615 прошли; далее финальный index-check и commit/push385.
Array runtime, M11.7/8/M13/M14 остаются OPEN.
[Свидетельство385](steps/witnesses/m11-formal-declarations-20261114/notes.md); текущая очередь — в [основном v3](next_core_tasks_v3.md).

Предыдущий срез383 реализует raw bindings после копии и held F; приёмка пройдена:
чистый query ничего не строит, первое потребляющее чтение готовит достигнутый scope прежним механизмом;
SourceSpace bindings не переносятся. Десять pure, private34 triple/102 full AFTER/mutation24 и native scope trace прошли;
в двух старых golden исправлены лишь четыре скобочные строки, числа сохранены.
Настоящие G1/G2 quick, по9 smoke, fixedpoint13/verify781 и пересборка G2 graph прошли.
G2 repeat34 triple с runs2/negative AFTER33/mutation24 и штатные render/docs check383 прошли:35/14/27/44/615, ссылки/LF.
Границы383 и открытые M11.5е перед шагом7, M11.7/8, M13/M14 — в [основном плане](next_core_tasks_v3.md).
