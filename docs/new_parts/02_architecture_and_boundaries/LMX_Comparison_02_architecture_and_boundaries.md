# Сравнение: Архитектура и границы компонентов

Контрольные языки: **Java, Go**. Дата редакции: 2026-11-21.

Числа — непробельные символы / непустые строки показанных листингов. Комментарии включены. Использование библиотеки и её реализация имеют отдельные строки; граница одинакова для трёх языков.

| ID | Паттерн | LMX | Java | Go | Граница |
| ---: | --- | ---: | ---: | ---: | --- |
| 005 | [Layered Architecture](005_layered_architecture_comparision.md) | 215 / 16 | 274 / 10 | 217 / 5 | Ядро сценария |
| 006 | [Hexagonal Architecture (Ports and Adapters)](006_hexagonal_architecture_comparision.md) | 215 / 14 | 264 / 9 | 183 / 5 | Ядро сценария |
| 007 | [Clean Architecture](007_clean_architecture_comparision.md) | 354 / 24 | 341 / 9 | 268 / 7 | Ядро сценария |
| 008 | [Onion Architecture](008_onion_architecture_comparision.md) | 247 / 20 | 363 / 13 | 308 / 8 | Ядро сценария |
| 009 | [Microservices](009_microservices_comparision.md) | 186 / 11 | 241 / 7 | 211 / 6 | Протокол и порты |
| 010 | [Event-Driven Architecture](010_event_driven_architecture_comparision.md) | 215 / 13 | 263 / 11 | 241 / 8 | Протокол и порты |
| 013 | [Pipe and Filter](013_pipe_and_filter_comparision.md) | 209 / 16 | 308 / 10 | 275 / 7 | Использование библиотеки |
| 093 | [Pipe — implementation](093_pipe_implementation_comparision.md) | 145 / 11 | 215 / 8 | 111 / 5 | Реализация библиотеки |
| 014 | [Blackboard](014_blackboard_comparision.md) | 354 / 24 | 351 / 18 | 325 / 18 | Ядро сценария |
| 015 | [Microkernel / Plug-in](015_microkernel_comparision.md) | 361 / 22 | 356 / 14 | 326 / 10 | Ядро сценария |
| 046 | [Anti-Corruption Layer (ACL)](046_anti_corruption_layer_comparision.md) | 175 / 15 | 177 / 6 | 162 / 5 | Ядро сценария |
| 047 | [Strangler Fig](047_strangler_fig_comparision.md) | 330 / 20 | 309 / 15 | 227 / 12 | Протокол и порты |

Java представляет явные интерфейсы, классы и модульную серверную разработку; Go — композицию функций и небольшие сервисные контракты. Пара позволяет проверить, требует ли паттерн иерархии классов или достаточно одинаковых границ и эффектов.

[Методика](../COMPARISON_METHODOLOGY.ru.md). [Проверка](../VALIDATION.md).

Суммарный рейтинг языков по разным группам не строится: состав языков, внешние библиотеки и класс задачи различаются.
