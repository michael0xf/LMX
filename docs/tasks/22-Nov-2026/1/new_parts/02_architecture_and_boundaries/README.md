# Архитектура и границы компонентов

[Руководство RU](LMX_Design_Patterns.ru.md) · [Guide EN](LMX_Design_Patterns.en.md)

Все 11 исходных позиций сохранены. Layered, Hexagonal, Clean и Onion перекрываются по приёмам, но различаются акцентом на направления зависимостей. Message служит владельцем изменяемого состояния. Microservices/EDA/Strangler учитывают описанный HTTP и Message transport; их листинги показывают ядро и точные порты, а не обещают реализованную инфраструктуру.

[LMX_Comparison_02_architecture_and_boundaries.xlsx](LMX_Comparison_02_architecture_and_boundaries.xlsx) · [LMX_Comparison_02_architecture_and_boundaries.pdf](LMX_Comparison_02_architecture_and_boundaries.pdf) · [LMX_Comparison_02_architecture_and_boundaries.md](LMX_Comparison_02_architecture_and_boundaries.md)

Редактируемый источник материалов — patterns.json. Листинги вынесены в examples.

## Редакция 22 ноября 2026

[Единое ядро и обзор изменений](../CORE_RECEIVERS_REVIEW.md) · [правила выбора основного варианта](../COMPARISON_RULES.md) · [каталог ресиверов](../RECEIVERS.md) · [общая статистика](../STATISTICS_2026-11-22.md). Основные листинги, сохранённые поясняющие варианты и стоимость общих реализаций учитываются раздельно.
