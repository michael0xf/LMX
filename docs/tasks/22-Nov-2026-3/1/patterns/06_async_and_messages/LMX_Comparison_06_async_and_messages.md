# Сравнение: Асинхронность, исполнители и Message

Контрольные языки: **Go, Erlang**. Дата редакции: 2026-11-22.

Числа — непробельные символы / непустые строки показанных листингов. Комментарии включены. Использование библиотеки и её реализация имеют отдельные строки; граница одинакова для трёх языков.

| ID | Паттерн | LMX | Go | Erlang | Граница |
| ---: | --- | ---: | ---: | ---: | --- |
| 058 | [Thread Pool](058_thread_pool_comparision.md) | 233 / 20 | 290 / 11 | 322 / 14 | Протокол и порты |
| 059 | [Producer-Consumer](059_producer_consumer_comparision.md) | 225 / 17 | 154 / 7 | 276 / 11 | Протокол и порты |
| 060 | [Actor Model](060_actor_model_comparision.md) | 100 / 9 | 141 / 8 | 144 / 7 | Протокол и порты |
| 061 | [Active Object](061_active_object_comparision.md) | 143 / 14 | 247 / 11 | 194 / 9 | Протокол и порты |
| 062 | [Reactor](062_reactor_comparision.md) | 100 / 10 | 157 / 8 | 168 / 8 | Протокол и порты |
| 063 | [Proactor](063_proactor_comparision.md) | 140 / 11 | 214 / 8 | 106 / 3 | Протокол и порты |
| 064 | [Future / Promise](064_future_promise_comparision.md) | 268 / 21 | 256 / 7 | 292 / 11 | Протокол и порты |
| 071 | [Half-Sync / Half-Async](071_half_sync_half_async_comparision.md) | 174 / 15 | 205 / 10 | 259 / 10 | Протокол и порты |
| 088 | [Structured Concurrency](088_structured_concurrency_comparision.md) | 364 / 28 | 517 / 20 | 602 / 18 | Протокол и порты |
| 089 | [Supervision Tree](089_supervision_tree_comparision.md) | 204 / 14 | 181 / 10 | 269 / 6 | Протокол и порты |
| 090 | [MapReduce](090_map_reduce_comparision.md) | 216 / 22 | 290 / 16 | 267 / 7 | Протокол и порты |

Go показывает каналы и goroutine, Erlang — изолированные процессы, mail и OTP supervision. Это характерные контроли для Message-модели LMX. Сравнения явно различают логического исполнителя, OS thread, readiness и завершение I/O.

[Методика](../COMPARISON_METHODOLOGY.ru.md). [Проверка](../VALIDATION.md).

Суммарный рейтинг языков по разным группам не строится: состав языков, внешние библиотеки и класс задачи различаются.
