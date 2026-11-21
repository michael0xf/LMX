# Функциональные вычисления

[Руководство RU](LMX_Design_Patterns.ru.md) · [Guide EN](LMX_Design_Patterns.en.md)

Четыре исходных паттерна 82–85 сохранены как клиентские сравнения готовых компонентов. Рядом с каждым находится полная собственная реализация одной и той же библиотеки во всех трёх языках: Maybe/bind, Bounce/runner, synchronous around и capture первого int. Клиентские и implementation-размеры считаются отдельно и могут суммироваться для standalone-примера. Операнд bind использует готовые значения; остальные helpers сохраняют обычные вызовы там, где OPERANDS_TEMPLATE добавил бы только оболочку.

[LMX_Comparison_09_functional_computation.xlsx](LMX_Comparison_09_functional_computation.xlsx) · [LMX_Comparison_09_functional_computation.pdf](LMX_Comparison_09_functional_computation.pdf) · [LMX_Comparison_09_functional_computation.md](LMX_Comparison_09_functional_computation.md)

Редактируемый источник материалов — patterns.json. Листинги вынесены в examples.
