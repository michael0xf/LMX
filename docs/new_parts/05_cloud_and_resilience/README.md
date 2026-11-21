# Облако, HTTP и отказоустойчивость

[Руководство RU](LMX_Design_Patterns.ru.md) · [Guide EN](LMX_Design_Patterns.en.md)

Сохранены все 12 исходных паттернов группы и добавленный Backpressure. Retry и Ambassador используют общую прикладную RetryLibrary; её полный алгоритм показан отдельным примером реализации. LMX использует Message и уже определённый HTTP-профиль. HTTP admission, исполнение операции и семантический успех различаются. Общая обвязка перечислена отдельно и не считается бесплатной.

[LMX_Comparison_05_cloud_and_resilience.xlsx](LMX_Comparison_05_cloud_and_resilience.xlsx) · [LMX_Comparison_05_cloud_and_resilience.pdf](LMX_Comparison_05_cloud_and_resilience.pdf) · [LMX_Comparison_05_cloud_and_resilience.md](LMX_Comparison_05_cloud_and_resilience.md)

Редактируемый источник материалов — patterns.json. Листинги вынесены в examples.
