# Сравнение: Архитектура и границы компонентов

Контрольные языки: **Java, Go**. Дата редакции: 2026-11-23.

Числа — непробельные символы / непустые строки показанных листингов. Комментарии включены. Использование библиотеки и её реализация имеют отдельные строки; граница одинакова для трёх языков.

| ID | Паттерн | LMX | Java | Go | Граница  Без сложного Throws |
| ---: | --- | ---: | ---: | ---: | --- | ---: |
| 005 | [Layered Architecture](005_layered_architecture_comparision.md) | 187 / 16 | 274 / 10 | 217 / 5 | Ядро сценария | 187 |
| 006 | [Hexagonal Architecture (Ports and Adapters)](006_hexagonal_architecture_comparision.md) | 181 / 14 | 264 / 9 | 183 / 5 | Ядро сценария | 181 |
| 007 | [Clean Architecture](007_clean_architecture_comparision.md) | 286 / 22 | 341 / 9 | 268 / 7 | Ядро сценария | 286 |
| 008 | [Onion Architecture](008_onion_architecture_comparision.md) | 222 / 20 | 363 / 13 | 308 / 8 | Ядро сценария | 222 |
| 009 | [Microservices](009_microservices_comparision.md) | 186 / 11 | 241 / 7 | 211 / 6 | Протокол и порты | 186 |
| 010 | [Event-Driven Architecture](010_event_driven_architecture_comparision.md) | 215 / 13 | 263 / 11 | 241 / 8 | Протокол и порты | 215 |
| 013 | [Pipe and Filter](013_pipe_and_filter_comparision.md) | 202 / 16 | 374 / 11 | 246 / 6 | Использование библиотеки | 202 |
| 093 | [Pipe — implementation](093_pipe_implementation_comparision.md) | 145 / 11 | 215 / 8 | 111 / 5 | Реализация библиотеки | 145 |
| 014 | [Blackboard](014_blackboard_comparision.md) | 354 / 24 | 351 / 18 | 325 / 18 | Ядро сценария | 354 |
| 015 | [Microkernel / Plug-in](015_microkernel_comparision.md) | 355 / 23 | 356 / 14 | 326 / 10 | Ядро сценария | 355 |
| 046 | [Anti-Corruption Layer (ACL)](046_anti_corruption_layer_comparision.md) | 165 / 15 | 177 / 6 | 162 / 5 | Ядро сценария | 165 |
| 047 | [Strangler Fig](047_strangler_fig_comparision.md) | 310 / 21 | 309 / 15 | 227 / 12 | Протокол и порты | 310 |

Java представляет явные интерфейсы, классы и модульную серверную разработку; Go — композицию функций и небольшие сервисные контракты. Пара позволяет проверить, требует ли паттерн иерархии классов или достаточно одинаковых границ и эффектов.

[Методика](../COMPARISON_METHODOLOGY.ru.md). [Проверка](../VALIDATION.md).

Суммарный рейтинг языков по разным группам не строится: состав языков, внешние библиотеки и класс задачи различаются.
